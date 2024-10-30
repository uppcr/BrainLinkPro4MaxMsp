<img width="514" alt="image" src="https://github.com/user-attachments/assets/e9275c1a-b2c4-4dc2-bbbc-35d6057d6855">

BrainLinkPro4MaxMsp 是一个用于将 BrainLink Pro 脑机接口数据实时转发至 Max/MSP 的项目。通过该工具，开发者和音乐创作者能够利用来自 BrainLink Pro 的脑电波、重力、眨眼等数据流，驱动 Max/MSP 中的创意音频、视觉效果，或其他交互内容。

![image](https://github.com/user-attachments/assets/467e82f6-d0c6-4262-80e6-f5436c66554b)


项目背景

BrainLink Pro 是一款消费者级的脑机接口设备，支持实时监测脑电波、重力等生物信号数据。然而，将这些数据无缝集成到 Max/MSP 这样的平台中以进行实时处理，通常需要自定义的数据转发解决方案。本项目旨在为此提供一个简洁、快速的桥梁，帮助用户在 macOS 环境下轻松实现脑波数据的实时交互。

功能特性

	•	支持实时数据传输：将 BrainLink Pro 的各类数据（脑电波、重力、眨眼、温度等）通过 OSC（Open Sound Control）协议发送至 Max/MSP。
	•	自定义数据端口：不同数据类型可通过独立的端口发送，以适应 Max/MSP 不同频率的响应需求。
	•	高频数据采集：支持高频采样，适用于细腻的数据分析和高灵敏度的创意应用。
	•	兼容性：优化于 macOS 环境，适用于各种 BrainLink Pro 硬件配置。

使用指南

	1.	硬件准备：确保 BrainLink Pro 设备已连接并成功与电脑配对。
	2.	运行MAC_HZLBlue4.0forMaxMsp.app || 通过 Xcode 打开项目文件，编译并运行，项目将自动开始数据采集与转发。
	3.	配置 Max/MSP：在 Max/MSP 中创建接收端口，并根据需求设计交互逻辑。
	4.	自定义设置：可调整数据传输频率、端口号等设置，满足个性化需求。

系统要求

	•	操作系统：macOS Catalina 或更高版本
	•	开发环境：Xcode
	•	硬件：BrainLink Pro by Macrotellect

许可证

本项目基于开源许可协议发布，使用和分发前请确保理解并遵守相关条款。
