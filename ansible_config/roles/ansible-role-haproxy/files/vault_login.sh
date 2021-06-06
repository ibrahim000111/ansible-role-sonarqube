#!/bin/bash

# ------------------------------------------------------------
# Check required variables to start
# ------------------------------------------------------------
# User for jenkins to login into vault
if [ -z "$VAULT_JENKINS_USER" ]; then
    echo -e "${RED}[ERROR]${NC} No VAULT_JENKINS_USER variable set was found. Please check and try again"
    exit 500
fi
echo -e "${GREEN}[OK]${NC} Found variable VAULT_JENKINS_USER"

if [ -z "$VAULT_JENKINS_PASS" ]; then
    echo -e "${RED}[ERROR]${NC} No VAULT_JENKINS_PASS variable set was found. Please check and try again"
    exit 500
fi
echo -e "${GREEN}[OK]${NC} Found variable VAULT_JENKINS_PASS"

if [ -z "$VAULT_ADDR" ]; then
    echo -e "${RED}[ERROR]${NC} No VAULT_ADDR variable set was found. Please check and try again"
    exit 500
fi
echo -e "${GREEN}[OK]${NC} Found variable VAULT_ADDR"

# ------------------------------------------------------------
# Retrieve information from Vault
# ------------------------------------------------------------
vault login -method=userpass username=$VAULT_JENKINS_USER password=$VAULT_JENKINS_PASS