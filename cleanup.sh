source .env
# Clean up all records
curl -X DELETE "${SERVER}/buckets/${BUCKET}/collections/${COLLECTION_ID}/records" -H "Authorization:${BEARER_TOKEN}"
# Sign the changes
curl -X PATCH ${SERVER}/buckets/main-workspace/collections/${COLLECTION_ID} \
     -H 'Content-Type:application/json' \
     -d '{"data": {"status": "to-review"}}' \
     -H "Authorization:${BEARER_TOKEN}"