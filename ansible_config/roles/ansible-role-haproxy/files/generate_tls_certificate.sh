#!/bin/bash

# ------------------------------------------------------------
# Check required variables to start
# ------------------------------------------------------------
if [ -z "$VAULT_ADDR" ]; then
    echo -e "${RED}[ERROR]${NC} No VAULT_ADDR variable set was found. Please check and try again"
    exit 500
fi
echo -e "${GREEN}[OK]${NC} Found variable VAULT_ADDR"

if [ -z "$DESTINY_FOLDER" ]; then
    echo -e "${RED}[ERROR]${NC} No DESTINY_FOLDER variable set was found. Please check and try again"
    exit 500
fi
echo -e "${GREEN}[OK]${NC} Found variable DESTINY_FOLDER"

# ------------------------------------------------------------
# Grab variables from vault
# ------------------------------------------------------------
CERTIFICATE_FULL_CHAIN=$(vault kv get -format=json path/to/my/certificates | jq .data.fullchain -r)
CERTIFICATE_KEY=$(vault kv get -format=json path/to/my/certificates | jq .data.key -r)

# ------------------------------------------------------------
# Check input variables
# ------------------------------------------------------------
if [ -z "$CERTIFICATE_FULL_CHAIN" ]; then
    echo -e "${RED}[ERROR]${NC} No CERTIFICATE_FULL_CHAIN variable set was found. Please check and try again"
    exit 500
fi
echo -e "${GREEN}[OK]${NC} Found variable CERTIFICATE_FULL_CHAIN"

# ------------------------------------------------------------
# Create certificate for TLS
# ------------------------------------------------------------
DESTINY_FOLDER="$DESTINY_FOLDER"/fullchain.pem
touch $DESTINY_FOLDER

echo -e "${GREEN}[OK]${NC} Created file on $DESTINY_FOLDER"

echo $CERTIFICATE_FULL_CHAIN > cert.pem
echo $CERTIFICATE_KEY > key.pem

cert_full_chain_raw=$(base64 -d cert.pem)
cert_key_raw=$(base64 -d key.pem)

echo "$cert_full_chain_raw" > cert.pem
echo "$cert_key_raw" > key.pem

cat cert.pem key.pem > $DESTINY_FOLDER

if [ $? -gt 0 ]; then
    echo -e "${RED}[ERROR]${NC} Failed generating certificate"
    exit 101
fi