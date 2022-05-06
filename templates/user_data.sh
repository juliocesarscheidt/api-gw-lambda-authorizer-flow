#!/bin/bash

sleep 15
docker container run -d --name http-simple-api --restart always --env API_PORT=5000 -p 5000:5000 juliocesarmidia/http-simple-api:v2.0.0
