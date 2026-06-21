#!/usr/bin/env bash
# Start RViz on a remote workstation and subscribe to the robot ROS2 graph.
# Usage: ROS_DOMAIN_ID=20 bash scripts/rviz_remote.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source /opt/ros/jazzy/setup.bash
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-20}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"

if [[ -n "${CYCLONEDDS_URI:-}" ]]; then
  export CYCLONEDDS_URI
fi

CONFIG="${RVIZ_CONFIG:-${REPO_ROOT}/ros_pkg/our_robot/config/robot_view.rviz}"

ros2 daemon stop >/dev/null 2>&1 || true
sleep 1

echo "Starting RViz with ROS_DOMAIN_ID=${ROS_DOMAIN_ID}; config=${CONFIG}"
exec rviz2 -d "$CONFIG"
