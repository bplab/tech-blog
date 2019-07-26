#!/bin/sh

cd $(cd "$(dirname "$0")" && pwd)

# Create .env file
echo "host_path=""$(pwd)" > .env

# Run docker-compose
docker-compose up
