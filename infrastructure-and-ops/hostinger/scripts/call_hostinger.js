const { spawn } = require('child_process');

async function callTool(toolName, args) {
  const mcp = spawn('npx', ['hostinger-api-mcp'], {
    env: process.env,
  });

  let buffer = '';
  
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      mcp.kill();
      reject(new Error('Timeout waiting for MCP response'));
    }, 15000);

    mcp.stdout.on('data', (data) => {
      buffer += data.toString();
      const lines = buffer.split('\n');
      buffer = lines.pop();
      for (const line of lines) {
        if (!line.trim()) continue;
        try {
          const response = JSON.parse(line);
          if (response.id === 2) {
            clearTimeout(timeout);
            resolve(response.result);
            mcp.kill();
          }
        } catch (e) {}
      }
    });

    mcp.on('close', (code) => {
      clearTimeout(timeout);
      reject(new Error(`MCP server closed with code ${code}`));
    });

    // 1. Send initialize request
    mcp.stdin.write(JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "initialize",
      params: {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: { name: "script-client", version: "1.0.0" }
      }
    }) + '\n');

    // 2. Send initialized notification
    mcp.stdin.write(JSON.stringify({
      jsonrpc: "2.0",
      method: "notifications/initialized"
    }) + '\n');

    // 3. Send tool call
    mcp.stdin.write(JSON.stringify({
      jsonrpc: "2.0",
      id: 2,
      method: "tools/call",
      params: {
        name: toolName,
        arguments: args
      }
    }) + '\n');
  });
}

const tool = process.argv[2];
const argsStr = process.argv[3];

if (!tool) {
  console.error('Usage: node call_hostinger.js <toolName> [argumentsJson]');
  process.exit(1);
}

let args = {};
if (argsStr) {
  try {
    args = JSON.parse(argsStr);
  } catch (e) {
    console.error('Invalid arguments JSON:', e.message);
    process.exit(1);
  }
}

callTool(tool, args)
  .then(res => {
    console.log(JSON.stringify(res, null, 2));
    process.exit(0);
  })
  .catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
  });
