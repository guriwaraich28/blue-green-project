# Use minimal base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY . .

# Create non-root user
RUN useradd -m appuser
USER appuser

# Expose app port
EXPOSE 5000

# Start app
CMD ["python", "app.py"]
