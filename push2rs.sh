#!/bin/sh

source .env

ls -al ContentBlockingLists
for FILEPATH in "$LISTS_DIR"/*.json; do
    RECORD_ID=$(uuidgen)
    FILENAME=$(basename "$FILEPATH" .json)

    curl -X POST "${SERVER}/buckets/${BUCKET}/collections/${COLLECTION_ID}/records/${RECORD_ID}/attachment" \
        -H "Content-Type:multipart/form-data" \
        -H "Authorization:${BEARER_TOKEN}" \
        -F "data={\"name\": \"${FILENAME}\"}" \
        -F "attachment=@${FILEPATH};type=application/json"

    echo "Uploading ${FILENAME} with file ${FILEPATH}  to ${SERVER}/buckets/${BUCKET}/collections/${COLLECTION}/records/${RECORD_ID}/attachment"
done

# Sign the changes
curl -X PATCH ${SERVER}/buckets/main-workspace/collections/${COLLECTION_ID} \
     -H 'Content-Type:application/json' \
     -d '{"data": {"status": "to-review"}}' \
     -H "Authorization:${BEARER_TOKEN}"


# Sanity check to see if you are authorized to access the server
#curl -s ${SERVER}/ -H "Authorization:${BEARER_TOKEN}" | jq .user

# # Check for the collection editors/reviewers ( I am the only one in it for now)
# curl -s ${SERVER}/buckets/main-workspace/groups/${COLLECTION_ID}-editors -H "Authorization:${BEARER_TOKEN}" | jq
# curl -s ${SERVER}/buckets/main-workspace/groups/${COLLECTION_ID}-reviewers -H "Authorization:${BEARER_TOKEN}" | jq

# curl -s ${SERVER}/buckets/main-workspace/collections/${COLLECTION_ID}/records \
#      -H 'Content-Type:application/json' \
#      -H "Authorization:${BEARER_TOKEN}"