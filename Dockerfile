# Use a lightweight Python base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# 1. Copy dependencies first to leverage Docker cache
# We see you have requirements.txt in the root
COPY requirements.txt .

# 2. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy the rest of your application code
COPY . .

# 4. Command to run the app
# We see your main file is named app.py
CMD ["python", "app.py"]

