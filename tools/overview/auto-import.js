import fetch from "node-fetch";
import "dotenv/config";
import { readFileSync, readdirSync } from "fs";
import { join, extname } from "path";

const {
  N8N_BASE_URL = "http://localhost:5678",
  N8N_API_KEY = "",
  PROJECT_WORKFLOWS_DIR = "./workflows"
} = process.env;

const H = {
  "Authorization": `Bearer ${N8N_API_KEY}`,
  "Content-Type": "application/json"
};

async function api(path, init = {}) {
  const r = await fetch(`${N8N_BASE_URL}${path}`, { headers: H, ...init });
  if (!r.ok) throw new Error(`${path} -> HTTP ${r.status}`);
  return r.json();
}

async function upsertWorkflow(json) {
  // Wenn ID existiert → Update, sonst Create
  if (json.id) {
    return api(`/rest/workflows/${json.id}`, { method: "PATCH", body: JSON.stringify(json) });
  } else {
    return api(`/rest/workflows`, { method: "POST", body: JSON.stringify(json) });
  }
}

(async () => {
  const files = readdirSync(PROJECT_WORKFLOWS_DIR).filter(f => extname(f) === ".json");
  const results = [];
  for (const f of files) {
    const wf = JSON.parse(readFileSync(join(PROJECT_WORKFLOWS_DIR, f), "utf-8"));
    const res = await upsertWorkflow(wf);
    results.push({ file: f, name: wf.name, id: res.id, status: "imported/updated" });
  }
  console.log(JSON.stringify({ imported: results.length, results }, null, 2));
})().catch(err => {
  console.error(JSON.stringify({ error: true, message: err.message }, null, 2));
  process.exit(1);
});
