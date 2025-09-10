import fetch from "node-fetch";
import "dotenv/config";
import { scanLocalWorkflows, scanCustomNodes } from "./fs-scan.js";

const {
  N8N_BASE_URL = "http://localhost:5678",
  N8N_API_KEY = "",
  PROJECT_WORKFLOWS_DIR = "./workflows",
  PROJECT_CUSTOM_NODES_DIR = "./custom-nodes"
} = process.env;

const H = {
  "Authorization": `Bearer ${N8N_API_KEY}`,
  "Content-Type": "application/json"
};

async function api(path) {
  const r = await fetch(`${N8N_BASE_URL}${path}`, { headers: H });
  if (!r.ok) throw new Error(`${path} -> HTTP ${r.status}`);
  return r.json();
}

function byNameIndex(arr) {
  const idx = {};
  for (const w of arr || []) idx[(w.name || "").toLowerCase()] = w;
  return idx;
}

(async () => {
  const [serverWorkflows, execRunning, execRecent] = await Promise.all([
    api("/rest/workflows"),
    api("/rest/executions-current"),
    api("/rest/executions?limit=25")
  ]);

  const localWorkflows = scanLocalWorkflows(PROJECT_WORKFLOWS_DIR);
  const customNodes = scanCustomNodes(PROJECT_CUSTOM_NODES_DIR);

  const serverList = serverWorkflows?.data ?? serverWorkflows ?? [];
  const serverIdx = byNameIndex(serverList);
  const merged = localWorkflows.map(loc => {
    const srv = serverIdx[loc.name.toLowerCase()];
    return {
      name: loc.name,
      local: { file: loc.file, nodes: loc.nodes, updatedAtLocal: loc.updatedAtLocal },
      server: srv ? {
        id: srv.id, active: !!srv.active,
        versionId: srv.versionId ?? null,
        updatedAtServer: srv.updatedAt ?? srv.updatedAtUNIX ?? null
      } : null,
      status: srv ? (srv.active ? "deployed:active" : "deployed:inactive") : "local-only"
    };
  });

  const localNames = new Set(localWorkflows.map(w => w.name.toLowerCase()));
  const serverOnly = serverList
    .filter(w => !localNames.has((w.name || "").toLowerCase()))
    .map(w => ({
      name: w.name,
      server: {
        id: w.id, active: !!w.active,
        versionId: w.versionId ?? null,
        updatedAtServer: w.updatedAt ?? w.updatedAtUNIX ?? null
      },
      status: "server-only"
    }));

  const out = {
    meta: { generatedAt: new Date().toISOString(), baseUrl: N8N_BASE_URL },
    summary: {
      localWorkflows: localWorkflows.length,
      serverWorkflows: serverList.length,
      customNodes: customNodes.length,
      executions: {
        running: execRunning?.data?.length ?? execRunning?.length ?? 0,
        recent: execRecent?.data?.length ?? execRecent?.length ?? 0
      }
    },
    inventories: {
      workflows: [...merged, ...serverOnly],
      customNodes,
      executions: {
        running: execRunning?.data ?? execRunning ?? [],
        recent: execRecent?.data ?? execRecent ?? []
      }
    },
    recommendations: [
      "Alle produktiven Workflows im Repo versionieren (server-only vermeiden).",
      "CI-Schritt: Repo → /rest/workflows Import nach Merge in main.",
      "Kritische Flows markieren und 'Save execution progress' aktivieren."
    ]
  };

  console.log(JSON.stringify(out, null, 2));
})().catch(err => {
  console.error(JSON.stringify({ error: true, message: err.message }, null, 2));
  process.exit(1);
});
