---
name: hostinger
description: Manage Hostinger services (DNS, domains, billing) via Hostinger API MCP server.
---

# Hostinger API MCP Server Skill

This skill allows you to interact with the Hostinger API using the Model Context Protocol (MCP) server suite (`hostinger-api-mcp`). You can manage DNS records, domains, billing, and VPS configurations directly.

## Authentication

The Hostinger MCP server authenticates in one of two ways:

1.  **OAuth 2.0 PKCE:** Done interactively via the browser. Credentials are saved automatically to:
    *   macOS / Linux: `~/.config/hostinger-mcp/credentials.json`
2.  **API Token:** Bypasses OAuth. Set the `HOSTINGER_API_TOKEN` environment variable.

### Initiating Login
To trigger the browser login flow and authenticate the server:
```bash
npx hostinger-api-mcp --login
```

If the browser does not open automatically, copy the authorization URL printed in `stdout` and open it manually. Once you approve the login, the server captures the code and stores the credentials.

---

## Helper Script

This skill packages a generic helper script to run any Hostinger MCP tool via the command line:

*   **Location:** `scripts/call_hostinger.js`
*   **Usage:**
    ```bash
    node scripts/call_hostinger.js <toolName> [argumentsJson]
    ```

### Example Commands:

#### 1. List Portfolio Domains
```bash
node scripts/call_hostinger.js domains_getDomainListV1
```

#### 2. Get DNS Zone Records for a Domain
```bash
node scripts/call_hostinger.js DNS_getDNSRecordsV1 '{"domain":"example.com"}'
```

#### 3. Update DNS Records
Using `overwrite: true` deletes existing records matching the name and type and creates the new ones:
```bash
node scripts/call_hostinger.js DNS_updateDNSRecordsV1 '{
  "domain": "example.com",
  "overwrite": true,
  "zone": [
    {
      "name": "@",
      "type": "MX",
      "ttl": 14400,
      "records": [
        {
          "content": "10 mx-forwarding.example-mail.com."
        }
      ]
    }
  ]
}'
```

---

## Tool Reference

The following are key tools provided by the `hostinger-api-mcp` server:

### DNS Management (`hostinger-dns-mcp`)
*   `DNS_getDNSRecordsV1` — Retrieve DNS zone records for a specific domain.
*   `DNS_updateDNSRecordsV1` — Create/overwrite DNS zone records.
*   `DNS_deleteDNSRecordsV1` — Delete specific DNS zone records.
*   `DNS_resetDNSRecordsV1` — Reset DNS zone to default.

### Domain Portfolio (`hostinger-domains-mcp`)
*   `domains_getDomainListV1` — List all registered domains in the Hostinger account.
*   `domains_getDomainDetailsV1` — Show details for a specific registered domain.
*   `domains_checkDomainAvailabilityV1` — Check if a domain name is available for purchase.
