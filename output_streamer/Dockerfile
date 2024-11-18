FROM rust:1-slim-bookworm

RUN rustup target add wasm32-wasip1 && \
    apt-get update && \
    apt-get install -y curl unzip tini openssl ca-certificates python3 python3-pip python3-venv && \
    curl -fsS "https://hub.infinyon.cloud/install/install.sh" | bash && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="$PATH:/root/.fluvio/bin"
ENV PATH="$PATH:/root/.fvm/bin"

WORKDIR /usr/src/app
COPY requirements.txt .
RUN python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 3000
CMD ["/venv/bin/python", "app.py"]

