#!/usr/bin/env bash
set -euo pipefail

# Run:
#   ./server.sh
# Optional overrides:
#   BRANCH=main PROCESS_MANAGER=pm2 ./server.sh

EC2_USER="${EC2_USER:-ubuntu}"
EC2_HOST="${EC2_HOST:-65.0.235.207}"
SSH_KEY_PATH="${SSH_KEY_PATH:-C:/Users/hp/Downloads/docker-key.pem}"
SSH_PORT="${SSH_PORT:-22}"

REPO_URL="${REPO_URL:-https://github.com/Adarshjain3011/docker-bullmq-demo.git}"
APP_DIR="${APP_DIR:-/home/${EC2_USER}/docker-bullmq-demo}"
BRANCH="${BRANCH:-main}"

PROJECT_NAME="${PROJECT_NAME:-docker-bullmq-demo}"
API_IMAGE="${API_IMAGE:-${PROJECT_NAME}-api:latest}"
WORKER_IMAGE="${WORKER_IMAGE:-${PROJECT_NAME}-worker:latest}"
API_PROCESS="${API_PROCESS:-${PROJECT_NAME}-api}"
WORKER_PROCESS="${WORKER_PROCESS:-${PROJECT_NAME}-worker}"
API_CONTAINER="${API_CONTAINER:-${PROJECT_NAME}-api}"
WORKER_CONTAINER="${WORKER_CONTAINER:-${PROJECT_NAME}-worker}"
API_PORT="${API_PORT:-3000}"

# The user requested pm3. If your server uses pm2 instead, run:
#   PROCESS_MANAGER=pm2 ./server.sh
PROCESS_MANAGER="${PROCESS_MANAGER:-pm3}"

if [[ -z "${EC2_HOST}" ]]; then
  echo "Missing EC2_HOST. Example: EC2_HOST=ec2-1-2-3-4.compute.amazonaws.com ./server.sh"
  exit 1
fi

SSH_ARGS=(-p "${SSH_PORT}" -o StrictHostKeyChecking=accept-new)
if [[ -n "${SSH_KEY_PATH}" ]]; then
  SSH_ARGS+=(-i "${SSH_KEY_PATH}")
fi

echo "Deploying ${PROJECT_NAME} to ${EC2_USER}@${EC2_HOST}:${APP_DIR}"

ssh "${SSH_ARGS[@]}" "${EC2_USER}@${EC2_HOST}" \
  "REPO_URL='${REPO_URL}' APP_DIR='${APP_DIR}' BRANCH='${BRANCH}' PROJECT_NAME='${PROJECT_NAME}' API_IMAGE='${API_IMAGE}' WORKER_IMAGE='${WORKER_IMAGE}' API_PROCESS='${API_PROCESS}' WORKER_PROCESS='${WORKER_PROCESS}' API_CONTAINER='${API_CONTAINER}' WORKER_CONTAINER='${WORKER_CONTAINER}' API_PORT='${API_PORT}' PROCESS_MANAGER='${PROCESS_MANAGER}' bash -s" <<'REMOTE_SCRIPT'
set -euo pipefail

echo "Checking required commands..."
command -v git >/dev/null
command -v docker >/dev/null
command -v "${PROCESS_MANAGER}" >/dev/null

if [[ ! -d "${APP_DIR}/.git" ]]; then
  echo "Repository not found at ${APP_DIR}. Cloning..."
  mkdir -p "$(dirname "${APP_DIR}")"
  git clone "${REPO_URL}" "${APP_DIR}"
fi

echo "Pulling latest code from ${BRANCH}..."
cd "${APP_DIR}"
git fetch origin "${BRANCH}"
git checkout "${BRANCH}"
git pull --ff-only origin "${BRANCH}"

echo "Building Docker images..."
docker build -f Dockerfile.api -t "${API_IMAGE}" .
docker build -f Dockerfile.worker -t "${WORKER_IMAGE}" .

ENV_ARGS=()
if [[ -f .env ]]; then
  ENV_ARGS=(--env-file "$(pwd)/.env")
fi

echo "Stopping old PM processes and containers..."
"${PROCESS_MANAGER}" delete "${API_PROCESS}" >/dev/null 2>&1 || true
"${PROCESS_MANAGER}" delete "${WORKER_PROCESS}" >/dev/null 2>&1 || true
docker rm -f "${API_CONTAINER}" >/dev/null 2>&1 || true
docker rm -f "${WORKER_CONTAINER}" >/dev/null 2>&1 || true

echo "Starting containers with ${PROCESS_MANAGER}..."
"${PROCESS_MANAGER}" start docker --name "${API_PROCESS}" -- \
  run --rm \
  --name "${API_CONTAINER}" \
  -p "${API_PORT}:3000" \
  "${ENV_ARGS[@]}" \
  "${API_IMAGE}" \
  node src/api/index.js

"${PROCESS_MANAGER}" start docker --name "${WORKER_PROCESS}" -- \
  run --rm \
  --name "${WORKER_CONTAINER}" \
  "${ENV_ARGS[@]}" \
  "${WORKER_IMAGE}"

"${PROCESS_MANAGER}" save || true
"${PROCESS_MANAGER}" status

echo "Deployment finished."
REMOTE_SCRIPT
