"""
Base AI Agent - Example Implementation
This is a sample agent that demonstrates health endpoints and basic structure.
"""

import os
import logging
from datetime import datetime
from flask import Flask, jsonify, request
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry.instrumentation.flask import FlaskInstrumentor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Configure Azure Application Insights
app_insights_connection_string = os.getenv('APPLICATIONINSIGHTS_CONNECTION_STRING')
if app_insights_connection_string:
    configure_azure_monitor(connection_string=app_insights_connection_string)
    FlaskInstrumentor().instrument_app(app)
    logger.info("Application Insights configured")
else:
    logger.warning("Application Insights not configured - missing connection string")

# Agent configuration from environment variables
AGENT_NAME = os.getenv('AGENT_NAME', 'base-agent')
AGENT_DESCRIPTION = os.getenv('AGENT_DESCRIPTION', 'Base AI Agent')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
COSMOS_DB_ENDPOINT = os.getenv('COSMOS_DB_ENDPOINT')
REDIS_HOSTNAME = os.getenv('REDIS_HOSTNAME')

# Agent state
agent_state = {
    'name': AGENT_NAME,
    'description': AGENT_DESCRIPTION,
    'environment': ENVIRONMENT,
    'version': '1.0.0',
    'status': 'initializing',
    'started_at': datetime.utcnow().isoformat(),
    'requests_processed': 0
}


@app.route('/')
def home():
    """Root endpoint with agent information"""
    return jsonify({
        'agent': agent_state['name'],
        'description': agent_state['description'],
        'version': agent_state['version'],
        'status': agent_state['status'],
        'endpoints': {
            'health': '/health',
            'ready': '/ready',
            'metrics': '/metrics',
            'process': '/process'
        }
    })


@app.route('/health')
def health():
    """
    Health check endpoint (liveness probe)
    Returns 200 if the agent is alive
    """
    return jsonify({
        'status': 'healthy',
        'agent': AGENT_NAME,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/ready')
def ready():
    """
    Readiness check endpoint (readiness probe)
    Returns 200 if the agent is ready to accept traffic
    """
    # Check if agent has initialized properly
    is_ready = agent_state['status'] in ['ready', 'running']

    # Check external dependencies (example)
    dependencies_ready = True
    dependencies = {}

    if COSMOS_DB_ENDPOINT:
        dependencies['cosmos_db'] = 'configured'

    if REDIS_HOSTNAME:
        dependencies['redis'] = 'configured'

    if is_ready and dependencies_ready:
        return jsonify({
            'status': 'ready',
            'agent': AGENT_NAME,
            'dependencies': dependencies,
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    else:
        return jsonify({
            'status': 'not_ready',
            'agent': AGENT_NAME,
            'dependencies': dependencies,
            'timestamp': datetime.utcnow().isoformat()
        }), 503


@app.route('/metrics')
def metrics():
    """
    Metrics endpoint for monitoring
    Returns agent performance metrics
    """
    return jsonify({
        'agent': AGENT_NAME,
        'uptime_seconds': (
            datetime.utcnow() - datetime.fromisoformat(agent_state['started_at'])
        ).total_seconds(),
        'requests_processed': agent_state['requests_processed'],
        'status': agent_state['status'],
        'timestamp': datetime.utcnow().isoformat()
    })


@app.route('/process', methods=['POST'])
def process():
    """
    Main processing endpoint
    This is where the agent's core logic would go
    """
    try:
        data = request.get_json()

        # Log the request
        logger.info(f"Processing request: {data}")

        # Increment request counter
        agent_state['requests_processed'] += 1

        # Process the request (example)
        result = {
            'agent': AGENT_NAME,
            'status': 'success',
            'message': f'Request processed by {AGENT_NAME}',
            'input': data,
            'timestamp': datetime.utcnow().isoformat()
        }

        logger.info(f"Request processed successfully")

        return jsonify(result), 200

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return jsonify({
            'agent': AGENT_NAME,
            'status': 'error',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500


@app.before_request
def before_request():
    """Log all incoming requests"""
    logger.debug(f"{request.method} {request.path} from {request.remote_addr}")


@app.after_request
def after_request(response):
    """Log all responses"""
    logger.debug(f"{request.method} {request.path} - Status: {response.status_code}")
    return response


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested endpoint does not exist',
        'agent': AGENT_NAME
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {error}", exc_info=True)
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred',
        'agent': AGENT_NAME
    }), 500


def initialize_agent():
    """Initialize the agent and its dependencies"""
    logger.info(f"Initializing {AGENT_NAME}...")

    # Check environment configuration
    if not COSMOS_DB_ENDPOINT:
        logger.warning("COSMOS_DB_ENDPOINT not configured")
    else:
        logger.info(f"Cosmos DB endpoint: {COSMOS_DB_ENDPOINT}")

    if not REDIS_HOSTNAME:
        logger.warning("REDIS_HOSTNAME not configured")
    else:
        logger.info(f"Redis hostname: {REDIS_HOSTNAME}")

    # Set agent as ready
    agent_state['status'] = 'ready'
    logger.info(f"{AGENT_NAME} initialized successfully")


if __name__ == '__main__':
    # Initialize the agent
    initialize_agent()

    # Get port from environment
    port = int(os.getenv('PORT', 8080))

    # Start the Flask server
    logger.info(f"Starting {AGENT_NAME} on port {port}")
    app.run(host='0.0.0.0', port=port, debug=(ENVIRONMENT == 'development'))
