% simulate pot

clear; close all; clc;

% Customize default properties
model_name = 'X9C10C';   % name of simscape block
digitpot_model = 104;    % 102 - 1kohm, 103 - 10kohm, 104 - 100kohm
sim_time = 3;  % seconds

% Begin simulation
wiper_cmd = 46;

pot = X9C(model_name, digitpot_model, sim_time);

pot.setWiperPos_Ideal(wiper_cmd);  % does not account for real-time digital logic delays

disp("Finished.");
