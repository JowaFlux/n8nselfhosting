#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null; then
  echo "Docker required." >&2; exit 1
fi

read -r -p "Basic-Auth Benutzername: " USER
read -r -s -p "Basic-Auth Passwort: " PASS; echo

# Caddy-Container nutzt eingebauten Bcrypt-Hasher
HASH=$(docker run --rm caddy:2 caddy hash-password --plaintext "$PASS")

echo "Hash erzeugt."
echo "Trage in .env.caddy ein:"
echo "BASIC_USER=$USER"
echo "BASIC_HASH=$HASH"
