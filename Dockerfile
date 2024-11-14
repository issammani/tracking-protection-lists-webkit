FROM python:3.8 as build-json-lists

WORKDIR /shavar-lists

RUN git clone https://github.com/issammani/shavar-list-creation.git .

RUN pip install -r requirements.txt

# TODO(issam): for now only dev lists are generated
RUN cp rs_dev.ini shavar_list_creation.ini
RUN python3 lists2safebrowsing.py

# Copy entitylist into normalized-lists
# TODO(issam): Change code in swift so that this is also under normalized-lists
# TODO(issam): We should also copy this as part of lists2safebrowsing ( probably ? )
RUN curl -L -o /shavar-lists/normalized-lists/disconnect-entitylist.json \
    https://raw.githubusercontent.com/mozilla-services/shavar-prod-lists/refs/heads/master/disconnect-entitylist.json


# We need a swift base image since the content blocking generator is written in swift
# TODO(issam): consider moving this to python ( not a blocker for now )
FROM swift:5.10 as webkit-list-generator

WORKDIR /app

# TODO(issam): We clone the whole repo which is slow. We need to move the ContentBlockingGen directory to this project
RUN git clone https://github.com/mozilla-mobile/firefox-ios.git firefox-ios

# Copy the generated normalized-lists from the build-json-lists stage
COPY --from=build-json-lists /shavar-lists/normalized-lists /app/firefox-ios/shavar-prod-lists/normalized-lists
COPY --from=build-json-lists /shavar-lists/normalized-lists/disconnect-entitylist.json /app/firefox-ios/shavar-prod-lists/disconnect-entitylist.json

WORKDIR /app/firefox-ios/BrowserKit
RUN swift package resolve
RUN swift build --product ExecutableContentBlockingGenerator -c release

# Generate the content blocking list for webkit
RUN /app/firefox-ios/BrowserKit/.build/release/ExecutableContentBlockingGenerator



FROM alpine:latest

WORKDIR /app

# Copy generated webkit lists
COPY --from=webkit-list-generator /app/firefox-ios/ContentBlockingLists/ /app/ContentBlockingLists/

COPY .env .
COPY push2rs.sh .
RUN chmod +x push2rs.sh

RUN apk add --no-cache curl jq uuidgen

ENTRYPOINT ["/bin/sh", "push2rs.sh"]