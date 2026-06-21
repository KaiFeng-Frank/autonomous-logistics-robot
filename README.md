# Autonomous Logistics Robot

ROS2 Jazzy logistics robot prototype built around a Raspberry Pi 5, ESP32-S3
micro-ROS motor controller, mecanum chassis, QR perception, SLAM, Nav2, and a
fork-lift style delivery mechanism.

The robot was designed for a compact indoor logistics field: detect shelf QR
codes, navigate to the rack, lift the payload, move to the assigned drop zone,
release, and repeat the mission cycle.

## Status

This is a completed robot prototype and a public engineering
archive. The repository is useful for studying the ROS2 integration, mission
state machine, hardware bring-up notes, QR workflow, and Pi/ESP32 deployment
scripts. It is not a generic off-the-shelf robot stack; several launch files and
calibrations are specific to the physical robot and field layout used in the
demo.

Demo and submission materials:

- [Google Drive folder](https://drive.google.com/drive/folders/1jJu_jJcTyburXDEJXnJ0v87mApNDu1qE?usp=sharing)
- [Field video](https://drive.google.com/file/d/1Um9JuQaaRrmgw0-fhiDYiSQS8zMbOaa8/view?usp=sharing)
- [QR scan and timing video](https://drive.google.com/file/d/18qLlR4JD5wtBqxEszsLlZKlroklsS2be/view?usp=sharing)
- [Presentation](https://drive.google.com/file/d/1C4D9pZIuZg_dDBKVw3HzxvJLAhAreFF4/view?usp=sharing)
- [CAD archive](https://drive.google.com/file/d/1k36CBbZSns01qzZIZNJbJJtI8B1uHejJ/view?usp=sharing)

## Hardware

| Module | Role |
|---|---|
| Raspberry Pi 5 | ROS2 Jazzy host, camera, LiDAR, SLAM, Nav2, mission logic |
| ESP32-S3 | micro-ROS motor and servo interface |
| Mecanum chassis | holonomic base for tight indoor navigation |
| Oradar MS200 LiDAR | 2D scan source for SLAM/Nav2/safety gate |
| USB camera | QR detection and optional YOLO demo stream |
| Fork-lift mechanism | payload lift and release |

## Software Stack

- ROS2 Jazzy
- Nav2 and `slam_toolbox`
- micro-ROS serial agent
- Pi camera stack through `camera_ros`
- QR detection with OpenCV/pyzbar
- Optional YOLOv8 ONNX detector for visual demo overlays
- systemd and udev deployment helpers for the Raspberry Pi

## Quick Start

```bash
git clone https://github.com/KaiFeng-Frank/autonomous-logistics-robot.git
cd autonomous-logistics-robot
```

Pi 5 deployment:

```bash
cd rpi5_setup
sudo bash install.sh
sudo reboot
```

Typical bring-up order:

```bash
# Motor and QR checks
python3 scripts/test_motor_straight.py
python3 scripts/test_qr_matrix.py

# LiDAR-only driver check
ros2 launch oradar_lidar ms200_scan.launch.py
ros2 topic hz /scan

# Camera calibration
ros2 launch our_robot calibration.launch.py
ros2 run camera_calibration cameracalibrator --size 8x6 --square 0.030 image:=/camera/image_raw camera:=/camera

# Mapping and mission launch
ros2 launch our_robot slam_mapping.launch.py
bash scripts/save_map.sh
ros2 launch our_robot robot_full.launch.py
```

The current deployment expects the factory Yahboom `microROS_Robot V2.0.0`
ESP32 firmware at `921600` baud and `ROS_DOMAIN_ID=20`.

## Repository Layout

```text
docs/                  field, wiring, PID tuning, and deployment notes
firmware/esp32/        archived Arduino firmware notes
ros_pkg/our_robot/     main ROS2 package, launch files, configs, URDF, nodes
rpi5_setup/            Pi setup, systemd units, and udev rules
scripts/               QR generation, tests, deployment, map saving, utilities
```

## Main ROS2 Topics

| Topic | Type | Role |
|---|---|---|
| `/cmd_vel` | `geometry_msgs/Twist` | Nav2/safety/FSM command to ESP32 |
| `/odom_raw` | `nav_msgs/Odometry` | ESP32 odometry source |
| `/scan_lidar` | `sensor_msgs/LaserScan` | USB LiDAR scan for SLAM/Nav2 |
| `/camera/image_raw/compressed` | `sensor_msgs/CompressedImage` | camera stream for QR and YOLO nodes |
| `/qr_result` | `std_msgs/String` | decoded rack QR result |
| `/servo_s2` | `std_msgs/Int32` | lift servo command |
| `/map` | `nav_msgs/OccupancyGrid` | SLAM map for Nav2 |

Note: the ESP32 firmware also publishes `/scan`, but the physical LiDAR used by
this project is the USB Oradar stream remapped to `/scan_lidar`.

## Key Files

| File | Purpose |
|---|---|
| `ros_pkg/our_robot/our_robot/mission_fsm_node.py` | autonomous delivery state machine |
| `ros_pkg/our_robot/our_robot/qr_scanner_node.py` | QR detection pipeline |
| `ros_pkg/our_robot/our_robot/manual_mission_node.py` | manual mission mode |
| `ros_pkg/our_robot/our_robot/laser_safety_node.py` | teleop safety gate |
| `ros_pkg/our_robot/config/nav2_params.yaml` | Nav2 tuning |
| `ros_pkg/our_robot/config/slam_toolbox_params.yaml` | SLAM tuning |
| `rpi5_setup/install.sh` | Raspberry Pi dependency setup |
| `rpi5_setup/install_systemd.sh` | systemd and udev installation |

## Limitations

- Hardware dimensions, rack coordinates, and QR labels must be recalibrated for a
  new field.
- The factory ESP32 firmware path is the maintained deployment path; the older
  custom firmware remains only as project history.
- Demo videos and CAD archives are hosted externally to keep the repository
  focused on source and documentation.
