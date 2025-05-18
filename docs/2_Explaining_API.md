API is present for the intermediate level model.
Unfortunately, only the simple and ideal API is currently functional. Working towards correcting the others, help is appreciated!

- **Location**: `src/Simscape/Intermediate/X9C10C.slx`
- **Features**:
  - MATLAB - Simscape Electrical co-simulation (requires 'src/MATLAB/X9C.m')
  - Programmatic control
  - Ideal for understanding timing constraints
 
# MATLAB Class Reference

## X9C Class
```
classdef X9C
```

## Implementation File (refer examples)
```
model_name = 'xxx';                        % simscape .slx file name
digitpot_model = yyy;                      % 102 - 1kohm
                                           % 103 - 10kohm
                                           % 104 - 100kohm
sim_time = zzz;                            % simulation seconds

% Begin simulation
wiper_cmd = w;                             % wiper position command

obj = X9C(model_name, pot_type, sim_time)  % intialise the constructor

obj.function1();                           % function 1
obj.function2();                           % function 2
.
.
.

```
|Constructor       | Parameters   |  Usage  |  Notes  |
| :---- | :-------    | :------ |  :------ |
| `Parametric Constructor` | obj = X9C(model_name, pot_type, sim_time) | Initialisation  |  :grey_exclamation:Could think of introducing both default and parametric constructors  |

|Methods       | Parameters   |  Usage  |  Notes |
| :---- | :-------    | :------ |  :------ |
| `setWiperPos_Ideal(obj, position)` | position | Sets the POT wiper to a user-settable position | Does not emulate real-world digital-logic delays |
| `setWiperPos_Real(obj, position)` | position | Sets the POT wiper to a user-settable position | Emulates real-world digital-logic delays.<br>:exclamation:In development |
| `incr(obj)` |  | Increments the wiper by 1 position | Max increment is capped at 99. Emulates real-world digital-logic delays.<br>:exclamation:In development|
| `decr(obj)` |  | Decrements the wiper by 1 position | Max decrement is 0. Emulates real-world digital-logic delays.<br>:exclamation:In development|
| `store(obj)` |  | Emulates the wiper position storage function of the chip | Emulates real-world digital-logic delays.<br>:exclamation:In development|
