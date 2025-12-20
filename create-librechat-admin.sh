#!/usr/bin/env bash
set -e

echo "▶ Loading .env"
set -a
source .env
set +a

echo "▶ Checking required variables in .env"

grep -q "^LIBRECHAT_ADMIN_EMAIL=" .env || {
  echo "❌ LIBRECHAT_ADMIN_EMAIL not found in .env"
  exit 1
}

grep -q "^LIBRECHAT_ADMIN_PASSWORD=" .env || {
  echo "❌ LIBRECHAT_ADMIN_PASSWORD not found in .env"
  exit 1
}

echo "✔ .env looks good"
echo "  Admin email: $LIBRECHAT_ADMIN_EMAIL"
echo "  Admin password: (hidden)"

echo
echo "▶ Generating bcrypt hash inside LibreChat container"

HASHED_PASSWORD=$(podman exec -i librechat node -e "
  const bcrypt = require('bcryptjs');
  const fs = require('fs');
  const pass = fs.readFileSync(0, 'utf8').trim();
  bcrypt.hash(pass, 10).then(h => console.log(h));
" <<< "$LIBRECHAT_ADMIN_PASSWORD")

echo "✔ Password hash generated"

echo
echo "▶ Creating admin user in MongoDB"

podman exec mongo mongosh --quiet <<EOF
use librechat

db.users.deleteOne({ email: "$LIBRECHAT_ADMIN_EMAIL" })

db.users.insertOne({
  email: "$LIBRECHAT_ADMIN_EMAIL",
  password: "$HASHED_PASSWORD",
  role: "ADMIN",
  provider: "local",
  emailVerified: true,
  createdAt: new Date(),
  updatedAt: new Date()
})

print("✔ User inserted")
EOF

echo
echo "▶ Verifying user"

podman exec mongo mongosh --quiet <<EOF
use librechat
db.users.find(
  { email: "$LIBRECHAT_ADMIN_EMAIL" },
  { email: 1, role: 1 }
).pretty()
EOF

echo
echo "▶ Restarting LibreChat container"
podman restart librechat >/dev/null
echo "✔ LibreChat restarted"

echo
echo "✅ DONE"
echo "Login using:"
echo "  Email:    $LIBRECHAT_ADMIN_EMAIL"
echo "  Password: (value from .env)"
