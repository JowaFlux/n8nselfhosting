PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS documents (
  id TEXT PRIMARY KEY, name TEXT, source TEXT, mime TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS chunks (
  id TEXT PRIMARY KEY, doc_id TEXT NOT NULL, chunk_index INTEGER NOT NULL,
  text TEXT, embedding TEXT,
  FOREIGN KEY (doc_id) REFERENCES documents(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chunks_doc_id ON chunks(doc_id);
CREATE TABLE IF NOT EXISTS runs (
  run_id TEXT PRIMARY KEY, started_at DATETIME, finished_at DATETIME,
  status TEXT, score INTEGER, summary TEXT
);
CREATE TABLE IF NOT EXISTS steps (
  step_id TEXT PRIMARY KEY, run_id TEXT NOT NULL, name TEXT NOT NULL,
  status TEXT, started_at DATETIME, finished_at DATETIME,
  duration_ms INTEGER, retries INTEGER DEFAULT 0, message TEXT,
  FOREIGN KEY (run_id) REFERENCES runs(run_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS artifacts (
  artifact_id TEXT PRIMARY KEY, run_id TEXT NOT NULL, step_id TEXT,
  path TEXT, mime TEXT, size_bytes INTEGER, checksum TEXT,
  FOREIGN KEY (run_id) REFERENCES runs(run_id) ON DELETE CASCADE,
  FOREIGN KEY (step_id) REFERENCES steps(step_id) ON DELETE SET NULL
);
