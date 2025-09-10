# HMAC-Signatur Verifikation Snippet

```javascript
/**
 * HMAC-Signatur prüfen
 * Erwartet:
 *  - Header "X-Signature" (hex oder base64)
 *  - Secret in ENV: HMAC_SECRET (im n8n-Container setzen)
 *  - Body: raw JSON (nutze Webhook Node: "Binary Data" deaktiviert, JSON aktiv)
 */
const crypto = require('crypto');

const SECRET = $env.HMAC_SECRET || '';
if (!SECRET) {
  throw new Error('HMAC_SECRET not set on server');
}

function toBuffer(sig) {
  // akzeptiere hex oder base64
  if (/^[0-9a-f]+$/i.test(sig)) return Buffer.from(sig, 'hex');
  return Buffer.from(sig, 'base64');
}

const headerName = 'x-signature';
const sigHeader = (Object.keys($json.headers || {})
   .find(k => k.toLowerCase() === headerName) || headerName);

const received = ($json.headers?.[sigHeader] || '').trim();
if (!received) {
  return [{ json: { ok: false, reason: 'missing-signature' }, pairedItem: { item: 0 }, continue: false }];
}

const body = JSON.stringify($json.body ?? $json);
const hmac = crypto.createHmac('sha256', SECRET).update(body, 'utf8').digest();
const receivedBuf = toBuffer(received);

// timing-safe compare
const ok = (hmac.length === receivedBuf.length) && crypto.timingSafeEqual(hmac, receivedBuf);

if (!ok) {
  return [{ json: { ok: false, reason: 'bad-signature' }, pairedItem: { item: 0 }, continue: false }];
}

// gültig -> downstream weitergeben
return [{ json: { ok: true, verified: true, data: $json.body ?? $json } }];
```

## Client-Seite

Signature = HMAC_SHA256(secret, rawBody) und in Header X-Signature senden.

## Container-ENV (n8n)

```bash
HMAC_SECRET=<starkes_shared_secret>
```
