# Santa Clara Real Time Traffic Camera Streamer
The following repo contains a program that streams traffic data from santa clara's open traffic cameras. It streams the image(a very small binary file) into a fluvio topic. If you run sdf dataflow, you can apply a hugging face yolo transformation that does object detection. 
![Alt text](traffic.png)

A makefile is there for u to run 
1. `make up` will generate all the required docker images
2. visit [localhost:5001](localhost:5001)


To clean
1. `make clean` will clean the docker and the volumes



