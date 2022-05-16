FROM public.ecr.aws/lambda/python:3.8
LABEL maintainer="Julio Cesar <julio@blackdevs.com.br>"

# ENV LAMBDA_TASK_ROOT=/var/task
# ENV LAMBDA_RUNTIME_DIR=/var/runtime
WORKDIR ${LAMBDA_TASK_ROOT}

COPY requirements.txt .
RUN pip3 install -r \
    requirements.txt \
    --target "${LAMBDA_TASK_ROOT}"
COPY . .

CMD [ "index.handler" ]
