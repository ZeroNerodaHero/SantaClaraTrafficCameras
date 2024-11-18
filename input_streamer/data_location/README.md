# SantaClaraTrafficCameras
Includes a docker container that easily streams the data from Santa Clara's open traffic.

# Installation
Just install docker and run the following:
1. This installs the image
`docker build -t flask-traffic-image .`
2. This runs the docker image
`docker run -p 3000:3000 flask-traffic-image`

# Endpoints
Gets you the image
1. 'http://localhost:3000/traffic-image-raw'
Gets you the image in json file with timestamp as well as the image as a base64 binary. 
2. 'http://localhost:3000/traffic-image-json'
`
{
  "camera": "GATasman",
  "event": {
    "event_timestamp": "2024-11-17T00:42:43.789009",
    "image_binary": "..."
  }
}
`
