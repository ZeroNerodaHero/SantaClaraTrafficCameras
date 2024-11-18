FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
COPY templates .
COPY app.py .

RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 3000
CMD ["python", "app.py"]

