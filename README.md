# WebKit consumable tracking protection lists

This repository is a temporary setup for generating,and uploading tracking protection lists to RS to be used in Firefox iOS. The project uses a multi-stage Docker build that includes Python and Swift-based stages to create, compile, and upload the JSON lists.

## Prerequisites
- Ensure `Docker` is installed on your system to build and run the container.
- `curl` and `jq` for running shell scripts.

## Setup

1. Create a `.env` file in the root of the project, using the `.env.example` file as a template. The `.env.example` file has all the needed env vars except the RS `BEARER_TOKEN`. You need to fetch that from Kinto.

2. The Dockerfile defines a multi-stage build process for generating content-blocking lists. Run the following command to build the Docker image:
```bash
docker build -t content-blocking-lists .
```

3. After building the image, run the container to start the process of generating, compiling, and uploading the lists:
```sh
docker run  content-blocking-lists
```

## Cleaning up
After running the docker container you will create records on RS. To cleanup run:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

## Where to look in RS
By default the `push2rs.sh` script pushes to the dev server:
- The dev server is located at:  https://remote-settings-dev.allizom.org/v1/.
- The collection name is: `tracking-protection-lists-ios` and is located at: https://remote-settings-dev.allizom.org/v1/buckets/main-preview/collections/tracking-protection-lists-ios
- The records are accessible at: https://remote-settings-dev.allizom.org/v1/buckets/main-preview/collections/tracking-protection-lists-ios/records
- Each record has a `name` and an `attachment`. The `name`is the list name and the `attachment` is a json file in the WebKit format.
- In order to access an attachment we need:
  - The `base_url` of the attachment server which can be found using:
  ```bash
  SERVER_URL="https://remote-settings-dev.allizom.org/v1"
  BASE_URL=$(curl -L $SERVER_URL | jq -r .capabilities.attachments.base_url)
  ```
  - The specific attachment path, e.g the first list in `tracking-protection-lists-ios` could be fetched using:
  ```bash
  COLLECTIONS_URL="$SERVER_URL/buckets/main-preview/collections"
  COLLECTION_ID="tracking-protection-lists-ios"
  ATTACHMENT_URL=$(curl -L ${COLLECTIONS_URL}/${COLLECTION_ID}/records | jq -r '.data.[0].attachment.location')
  echo ${BASE_URL}${ATTACHMENT_URL} # This is the final url for the attachment
  ```
