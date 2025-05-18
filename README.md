# Digital Potentiometer X9C MATLAB-Simscape Electrical Simulation Toolkit
![MATLAB](https://img.shields.io/badge/MATLAB-R2023a-red)

![Simscape](https://img.shields.io/badge/Simscape-Electrical-blue)

The X9C10C is a digitally controlled potentiometer (digipot) from the X9C series, providing 1 / 10 / 50 / 100 kΩ resistance with 100 tap points (0-99) and ±20% resistance tolerance, that can be adjusted via digital signals. 
It features a non-volatile memory to store wiper positions. Operates on -5 to 5V logic levels. The device uses a 3-wire interface (CS, U/D', INC) for increment/decrement control, with 1µs typical step response time, making it ideal for applications requiring programmable resistance like gain adjustment, calibration, or volume control. 

**Pinout diagram**: https://github.com/tingerlingerr/DigiPotX9C/blob/main/wiring/circuit.png

**Advantages**: Unlike mechanical potentiometers, it offers repeatable digital control without physical wear, though it has limited current handling (~1mA) and exhibits ±1 LSB wiper position uncertainty. 

**Reason for building**: The simulation models in this repository aims to accurately replicate its timing characteristics and resistance taper behaviour.
This repository presents MATLAB/Simscape Simulation codes of X9C digital potentiometers with real-time delay modeling.

## :clipboard: Folder Structure

```
DigitalPotX9C_MATLAB/
├── docs/
├── examples/
└── src/
     ├── MATLAB/
     └── Simscape/
            ├── Basic/
            └── Intermediate/

```

## 🧞 Features

Currently supports two Simscape simulation models:

| Model                     | Description                                      |  Usage                                            |  Note
| :------------------------ | :----------------------------------------------- |  :----------------------------------------------- |  :----------------------------------------------- |
| `Basic`                   | User may run the Simscape model as they want. Real-time delay as per datasheet is provided.          | Open the Simscape model, update WIPER_CMD value and Run. If satisfied, you may directly copy it to any larger model you may want to control via a Digital Pot            |  Although mentioned 103s, changing the total resistance in the block will simulate any Digipot  |
| `Intermediate`            | For wider control and programming, this model was developed for Simscape-MATLAB co-simulation environment. However, feel free to use it for Simscape-only usage.  |  This can be run both from the example matlab script, or directly from Simscape (logic similar to Basic model)  |:exclamation::exclamation:Incremental control and Storage functions have been written but their implementation is not proper. :grey_exclamation:Requesting help. Need to be improved currently.

## Credit

1. Renesas  X9C102, X9C103, X9C104, X9C503 Digitally Controlled Potentiometer (XDCP™) Datasheet
(https://www.renesas.com/en/document/dst/x9c102-x9c103-x9c104-x9c503-datasheet?r=502676)

2. Simscape and Matlab Official Documentation
