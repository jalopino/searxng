FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir uwsgi

# Copy the application
COPY . .

# Compile Python files
RUN python -m compileall -q searx

# Set environment variables
ENV SEARXNG_SETTINGS_PATH=/app/searx/settings.yml
ENV PYTHONPATH=/app

# Expose port
EXPOSE 8080

# Start command
CMD ["uwsgi", "--http-socket", "0.0.0.0:8080", "--module", "searx.webapp", "--callable", "app", "--workers", "2", "--threads", "2", "--master", "--die-on-term"] 