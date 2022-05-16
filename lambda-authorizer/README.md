# Lambda Authorizer

> Running locally example:

```bash
JWT_SECRET=zpjtbzebqsh5plbor0zwtiewfkpimx7p ENV=local python index.py
```

> Run linter

```bash
docker container run --rm \
  --name py-lint \
  -v $(pwd):/usr/src/app \
  -w /usr/src/app \
  --entrypoint "" \
  cytopia/black:latest-0.2 sh -c "black --check -v ."
```
