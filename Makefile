IMAGE_NAME = fluvio:sdf
WORKER_NAME = docker-worker
SDF_WORKER = sdf-worker

.PHONY: sdf

default: help
up: build compose runconn sdf startflask
build:
	docker build -t $(IMAGE_NAME) .
compose:
	docker-compose up -d
	fluvio profile add sdf-docker 127.0.0.1:9103  docker
	sdf worker register $(WORKER_NAME) $(SDF_WORKER)
	fluvio topic create traffic-camera --retention-time 30s
	fluvio topic create traffic-boxes --retention-time 30s
runconn:
	make batch folder=A_conn/
sdf:
	@echo ""
	@echo "==================================================================="
	@echo "PLEASE\033[1m CONTROL + C\033[0m TO EXIT FROM SDF AFTER IT FINISHES"
	@echo "IT WILL AUTOMATOMATICALLY START THE FLASK SERVER"
	@echo "==================================================================="
	@echo ""
	sdf deploy --dataflow-file sdf/dataflow.yaml -e hg_apikey=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
startflask-local:
	python3 -m venv output_streamer/venv
	source output_streamer/venv/bin/activate
	pip install -r output_streamer/requirements.txt
	python app.py
startflask:
	docker build -t output-site ./output_streamer
	docker run -it --rm \
	  --network host \
	  --name output-site \
	  -v fluvio-data:/fluvio/data \
	  -e FLUVIO_PROFILE=docker \
	  output-site /bin/sh -c "fluvio profile add docker 127.0.0.1:9103 docker && /venv/bin/python app.py"

ifneq ($(MAKECMDGOALS),)
    ifeq ($(MAKECMDGOALS), connector)
        ifeq ($(config),)
            $(error You must specify a connector. Usage: make connector config=<ex. connector.yaml>)
        endif
    endif
endif
connector:
	docker cp manage_docker.sh connector:/fluvio/
	docker cp $(config) connector:/fluvio/
	docker exec connector sh -c "./manage_docker.sh start $(shell basename $(config))"

ifneq ($(MAKECMDGOALS),)
    ifeq ($(MAKECMDGOALS), shutdown)
        ifeq ($(name),)
            $(error You must specify a running connector. Usage make shutdown name=<...>)
        endif
    endif
endif
shutdown_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector sh -c "./manage_docker.sh shutdown $(name)"

clean_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector ./manage_docker.sh clean

stat_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector ./manage_docker.sh status

ifneq ($(MAKECMDGOALS),)
    ifeq ($(MAKECMDGOALS), batch)
        ifeq ($(folder),)
            $(error You must specify a running connector. Usage make batch folder=<...>)
        endif
    endif
endif
batch:
	docker cp manage_docker.sh connector:/fluvio/
	find A_conn -type f -exec make connector config={} \;

down:
	docker-compose down 
clean: 
	docker-compose down -v
	docker image prune

help:
	@echo "The following will run a whole project that digests information from Santa Clara's public traffic camera through a fluvio cluster. And apply a yolos object detection via yolos. After the service starts, the port 5001 should output the object detection."
	@echo ""
	@echo "Usage: make <target> [arguments]"
	@echo ""
	@echo "Targets:"
	@echo "  \033[1mup\033[0m				Runs the whole process"
	@echo ""
	@echo "  \033[1mrunconn\033[0m			Only starts the connector. Will automatically all prereqs"
	@echo ""
	@echo "  \033[1mstartflask-local\033[0m         	Starts a local flask server instead of starting the container" 
	@echo ""
	@echo "  \033[1mclean\033[0m           		Cleans up the entire environment"
.PHONY: all build up update clean
