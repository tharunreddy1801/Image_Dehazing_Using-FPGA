# 🌫️ Real-Time Accelerated Image Dehazing Using FPGA

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![HDL](https://img.shields.io/badge/HDL-Verilog-informational) ![Toolchain](https://img.shields.io/badge/Tools-Vivado%20%7C%20Vitis%20%7C%20MATLAB-blue)

## 🚀 Overview

This project implements a **hardware-accelerated real-time image dehazing pipeline on FPGA** using the **Dark Channel Prior (DCP)** algorithm. It is targeted at high-performance applications such as:

- Autonomous driving 🚗
- Aerial and satellite imaging 🛰️
- Surveillance systems 🔍
- Remote sensing in adverse weather conditions 🌧️

✅ Designed using **Verilog HDL**, tested on **Xilinx FPGA** (ZedBoard/Zynq), and optimized using **Vivado & Vitis toolchains**.

---

## 🎯 Objectives

- ⚡ **Accelerate DCP-based dehazing** using FPGA for real-time performance.
- 🔁 **Modular Verilog Implementation** of each processing stage: dark channel, atmospheric light, transmission map, and restoration.
- 🔧 **Optimize for low-latency and energy efficiency** using pipelining and parallelism.
- 🌐 Integrate with high-level tools like **MATLAB (HDL Coder)** and **Python** for simulation and visualization.
- 💻 Enable **deployment on embedded platforms** (Zynq SoC) with **AXI-stream interface**.

---

## 🧠 Key Features

| Module | Description |
|--------|-------------|
| `Register Bank` | Sliding 3×3 window buffer for streaming pixel input. |
| `Dark Channel` | Min-channel computation for haze region localization. |
| `Atmospheric Light` | Brightest pixel estimation from dark channel. |
| `Transmission Map` | Light transmission modeling using physics-based equations. |
| `Image Restoration` | Reconstructs haze-free image using physical haze model. |

---

## 🛠️ Tools & Technologies

- 💻 **Vivado** – RTL Design, Simulation, Bitstream Generation
- ⚙️ **Vitis** – Software integration, AXI Stream interface, deployment
- 📊 **MATLAB + HDL Coder** – Algorithm simulation, RTL generation
- 🐍 **Python** – Pre/post-processing and visualization support

---

## 📁 Repository Structure

**Image_Dehazing_Using-FPGA**
```bash
│
├── MATLAB/              # MATLAB scripts and testbench
├── Python/              # Python utilities for image testing
├── VerilogCodes/        # Complete RTL modules for each dehazing block
├── VerilogModules/      # HDL hierarchy and IP-wrapped top modules
├── LICENSE              # MIT License
└── README.md            # You're reading it!
```
---

## 🖼️ Demo

| Original Image | Dehazed Output |
|----------------|----------------|
| ![Hazy](samples/hazy.png) | ![Clear](samples/dehazed.png) |

*Test images were streamed via AXI interface and processed in real time on Zynq FPGA.*

---

## 📈 Performance Highlights

- ✅ **~60 FPS** on VGA resolution (512x512) using pipelined Verilog
- ⏱️ **Low latency:** ~16ms per frame
- 💡 **Parallelized modules** for speed and power efficiency
- 🔌 Ready for integration with **camera modules and embedded SoCs**

---

## 📚 References

- [Dark Channel Prior - IEEE TPAMI](https://ieeexplore.ieee.org/document/6126344)
- [FPGA4Student - Verilog Image Processing](https://www.fpga4student.com/2020/06/image-processing-on-fpga-using-verilog-hdl.html)
- [MATLAB HDL Coder](https://www.mathworks.com/products/hdl-coder.html)

---

## 👨‍💻 Author

- **Yennam Sai Tharun Reddy**
*(Dept. of ECE, Vasavi College of Engineering)*

---

## 📌 Keywords

`FPGA` • `Real-Time Processing` • `Image Dehazing` • `Computer Vision` • `Dark Channel Prior` • `Verilog HDL` • `Embedded Vision` • `Zynq SoC` • `Hardware Acceleration` • `Vivado` • `Vitis` • `AXI Stream` • `Autonomous Systems`

---

> ✨ *If you found this work interesting, consider starring 🌟 this repo or connecting with the authors on LinkedIn!*
