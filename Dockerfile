FROM python:3.11-slim

# Prevent Python from writing pyc files
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies required for OpenCV / dlib / face_recognition
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libx11-6 \
    libgtk-3-0 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx \
 && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy app code
COPY . .

# Collect static files (ignore errors if manage.py isn't ready)
RUN python manage.py collectstatic --noinput || true

# Start Gunicorn
CMD ["gunicorn", "nasa.wsgi:application", "--chdir", "medical_inventory", "--bind", "0.0.0.0:8000"]
