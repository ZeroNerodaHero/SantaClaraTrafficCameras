import time
import json
import requests
from datetime import datetime
from flask import Flask, jsonify, render_template, Response
from threading import Thread
import base64
import boto3
import os

app = Flask(__name__)

image_data = None
camera="TasmanOldIronsides"
counter = 0

def get_image(counter):
    image_id = f"{counter:03}"
    url = f"http://trafficcam.santaclaraca.gov/Feeds/{camera}/snap_{image_id}_c1.jpg"
    
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"Failed to download image {image_id}")
        return None
    
    image_bytes = response.content
    return image_bytes

def export_json(image_data):
    global counter
    image_bytes = image_data
    if None:
        return None

    image_base64 = base64.b64encode(image_bytes).decode('utf-8')
    
    return {
        "camera": camera,
        "event": {
            "counter": counter,
            "url": f"http://trafficcam.santaclaraca.gov/Feeds/{camera}/snap_{counter:03}_c1.jpg",
            "event_timestamp": datetime.utcnow().isoformat(),
            "image_binary": image_base64
        }
    }

def fetch_image():
    global image_data,counter
    counter = 0
    
    while True:
        event_data = get_image(counter)
        
        if event_data:
            image_data = event_data
            time.sleep(1.1)  
        counter = (counter+1)%256

@app.route('/', methods=['GET'])
def index():
    return '<a href="/traffic-image-json">View Traffic Image JSON</a>'


@app.route('/traffic-image-json', methods=['GET'])
def get_traffic_image_json():
    if image_data:
        return jsonify(export_json(image_data))
    else:
        return jsonify({"error": "Image not available"}), 404

@app.route('/traffic-image-raw', methods=['GET'])
def get_traffic_image_raw():
    if image_data:
        return Response(image_data, content_type='image/jpeg')
    else:
        return jsonify({"error": "Image not available"}), 404

def start_background_task():
    thread = Thread(target=fetch_image)
    thread.daemon = True
    thread.start()

if __name__ == '__main__':
    start_background_task()
    app.run(debug=True, host="0.0.0.0", port=3000)

