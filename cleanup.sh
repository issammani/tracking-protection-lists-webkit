# Clean up all records
curl -X DELETE ${SERVER}/buckets/main-workspace/collections/${COLLECTION_ID}/records -H "Authorization:${BEARER_TOKEN}"