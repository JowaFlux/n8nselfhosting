import { readdirSync, readFileSync, statSync } from "fs";
import { join, extname, basename } from "path";

export function scanLocalWorkflows(dir) {
  try {
    const files = readdirSync(dir).filter(f => extname(f).toLowerCase() === ".json");
    return files.map(f => {
      const p = join(dir, f);
      const raw = JSON.parse(readFileSync(p, "utf-8"));
      return {
        file: f,
        name: raw?.name ?? basename(f, ".json"),
        id: raw?.id ?? null,
        nodes: Array.isArray(raw?.nodes) ? raw.nodes.length : null,
        updatedAtLocal: statSync(p).mtime.toISOString()
      };
    });
  } catch {
    return [];
  }
}

export function scanCustomNodes(dir) {
  const out = [];
  const walk = (d) => {
    try {
      for (const entry of readdirSync(d)) {
        const p = join(d, entry);
        const st = statSync(p);
        if (st.isDirectory()) walk(p);
        if (entry === "package.json") {
          const pkg = JSON.parse(readFileSync(p, "utf-8"));
          out.push({
            name: pkg.name ?? "(unbenannt)",
            version: pkg.version ?? "0.0.0",
            private: pkg.private ?? false,
            main: pkg.main ?? null,
            description: pkg.description ?? null,
            dir: d
          });
        }
      }
    } catch {}
  };
  try { walk(dir); } catch {}
  return out;
}
