#!/bin/bash

echo ECS_CLUSTER=${ECS_CLUSTER} >> /etc/ecs/ecs.config;
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
echo ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=60m >> /etc/ecs/ecs.config;
echo ECS_IMAGE_CLEANUP_INTERVAL=60m >> /etc/ecs/ecs.config;
echo ECS_IMAGE_MINIMUM_CLEANUP_AGE=60m >> /etc/ecs/ecs.config;
echo ECS_NUM_IMAGES_DELETE_PER_CYCLE=25 >> /etc/ecs/ecs.config;
echo ECS_IMAGE_PULL_BEHAVIOR=default >> /etc/ecs/ecs.config;
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config;
echo ECS_CONTAINER_STOP_TIMEOUT=10s >> /etc/ecs/ecs.config;
echo ECS_CONTAINER_START_TIMEOUT=2m >> /etc/ecs/ecs.config;

echo "OPTIONS=\"--storage-opt dm.basesize=${VOLUME_SIZE}G\"" >> /etc/sysconfig/docker;

/etc/init.d/docker restart
