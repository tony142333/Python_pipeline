# Use a lightweight Python base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# 1. Copy dependencies
# We are in Root, so we look down into PHASE1/app
COPY PHASE1/app/requirements.txt .

# 2. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy the application code
# Copy everything from PHASE1/app into the container
COPY PHASE1/app/ .

# 4. Command to run the app
CMD ["python", "app.py"]