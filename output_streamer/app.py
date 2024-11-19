from flask import Flask, render_template
import json
from fluvio import Fluvio, Offset
from threading import Thread
import time
from flask_cors import CORS

app = Flask(__name__)
CORS(app, origins="*")

fluvio = Fluvio.connect()

def create_consumer():
    try:
        consumer = fluvio.partition_consumer('traffic-boxes', 0)
        return consumer
    except Exception as e:
        print(f"Error: {e}")
        return None

consumer = create_consumer()
stream = None

if consumer:
    stream = consumer.stream(Offset.beginning())

record = ""

def fetch_box():
    global record
    if stream:
        for i in stream:
            record = i.value_string()

@app.route('/')
def display_traffic_image():
    global record
    if record:
        # Parse the JSON string into a Python dictionary before passing it to the template
        parsed_record = json.loads(record)
        return render_template('index.html', record=parsed_record)
    else:
        return "No data found...", 200 

@app.route('/test')
def test():
    return "Hello world",200

def start_background_task():
    thread = Thread(target=fetch_box)
    thread.daemon = True
    thread.start()

if __name__ == '__main__':
    start_background_task()
    app.run(host='0.0.0.0', port=5001)

