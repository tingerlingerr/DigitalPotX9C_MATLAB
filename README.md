# Digital Potentiometer X9C Simulation Toolkit
![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-red)

![Simscape](https://img.shields.io/badge/Simscape-Electrical-blue)

MATLAB/Simscape simulation of X9C digital potentiometers with real-time delay modeling.

## Quick Start
```matlab
% Add to path
addpath(genpath('src'));

## Folder Structure
DigitalPotX9C_MATLAB/
├── src/
│   ├── MATLAB/
│   └── Simscape/
│       ├── Basic/
│       └── Intermediate/
├── examples/
└── docs/

## Features
Currently supports two simulation models:
Basic - User may run the Simscape model as they want. Real-time delay as per datasheet is provided.
Intermediate - For wider control and programming, this model was developed for Simscape-MATLAB co-simulation environment. However, feel free to use it for Simscape-only usage.

NOTE: Incremental control and Storage functions need to be improved currently
