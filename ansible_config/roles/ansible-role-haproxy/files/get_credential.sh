#!/bin/bash

# ------------------------------------------------------------
# Check required variables to start
# ------------------------------------------------------------
if [ -z "$CREDENTIAL_TO_LOOK_FOR" ]; then
    echo -e "${RED}[ERROR]${NC} No CREDENTIAL_TO_LOOK_FOR variable set was found. Please check and try again"
    exit 500
fi

if [ -z "$PATH_TO_EXTRACT" ]; then
    echo -e "${RED}[ERROR]${NC} No PATH_TO_EXTRACT variable set was found. Please check and try again"
    exit 500
fi

# ------------------------------------------------------------
# Retrieve information from Vault
# ------------------------------------------------------------
CREDENTIAL=$(vault kv get -format=json secret/nexus/$CREDENTIAL_TO_LOOK_FOR | jq "$PATH_TO_EXTRACT" -r)

# ------------------------------------------------------------
# Check found information
# ------------------------------------------------------------
if [ -z "$CREDENTIAL" ]; then
    echo -e "${RED}[ERROR]${NC} No CREDENTIAL was found. Please check and try again"
    exit 500
fi

CREDENTIAL=$(sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//' <<<"$CREDENTIAL")

echo $CREDENTIAL