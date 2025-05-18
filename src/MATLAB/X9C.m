%%% SCRIPT BEGIN

% Datasheet - https://www.renesas.com/en/document/dst/x9c102-x9c103-x9c104-x9c503-datasheet?r=502676

% Script
classdef X9C
    
    
    properties
        cs logical = true     % Chip Select (active low)
        cmd logical = true    % Up/Down Command control
        inc logical = true    % Increment control
        
        wiperPos uint8 = 0;     % Initial wiper position (0-99)
        time double = 0;        % Used for simulation and timestamping
        sim_time double = 0;    % Total simulation
                
        % Timing parameters - Page 5 datasheet
        T_IH double = 1e-6   % INC high time
        T_IL double = 1e-6   % INC low time
        T_DI double = 2.9e-6   % Direction setup time
        T_CPH_S double = 20e-3  % CS pulse width (store)
        T_CPH_NS double = 100e-9 % CS pulse width (no store)
        
        StoreFile char = 'pot_data.csv' % Data log file
        ModelName char = 'X9C10C';    % Model name
        Digital_Pot_Model = 102;    % ## USER INPUT ## 102 - 1kohm, 103 - 10kohm, 104 - 100kohm
            
    end

    methods
        function obj = X9C(model_name, digitpot_model, sim_tm)    % Constructor
            obj = logState(obj, 'Initial_State');

            obj.ModelName = model_name;
            obj.sim_time = sim_tm;
            obj.Digital_Pot_Model = digitpot_model;

            
            % Open and load simscape model - OPTIONAL
            if exist([obj.ModelName '.slx'], 'file')                
                
                open_system(obj.ModelName);
                pause(2);
                load_system(obj.ModelName);
                pause(1);
                
                
                set_param(obj.ModelName, 'Solver', 'ode23t');   % ## USER INPUT ##
                % ode15s - fastest, less precise; ode23t - just a little slower, good precision; daessc - slowest, excellent precision
                set_param(obj.ModelName, 'ZeroCrossAlgorithm','Adaptive'); % dont change
                set_param(obj.ModelName, 'AbsTol', '1e-5'); % Absolute tolerance for the sim ## USER INPUT ##
                set_param(obj.ModelName, 'RelTol', '1e-5'); % Relative tolerance for the sim ## USER INPUT ##
                set_param(obj.ModelName, 'StopTime', num2str(obj.sim_time)); % Simulation stop time ## USER INPUT ##
                set_param(obj.ModelName, 'FastRestart', 'off'); 
    
                try
                    set_param([obj.ModelName '/R_pot'], 'LinkStatus', 'inactive');
                    set_param([obj.ModelName '/WIPER_CMD'], 'LinkStatus', 'inactive');

                    % Force-enable tunability
                    h1 = get_param([obj.ModelName '/R_pot'], 'Handle');
                    p1 = get(h1, 'ObjectParameters');
                    p1.R0.Attributes = 'tunable';
                    set(h1, 'ObjectParameters', p1);

                    h2 = get_param([obj.ModelName '/WIPER_CMD'], 'Handle');
                    p2 = get(h2, 'ObjectParameters');
                    p2.constant.Attributes = 'tunable';
                    set(h2, 'ObjectParameters', p2);
                    
                catch
                end
                set_param([obj.ModelName '/R_pot'], 'LinkStatus', 'restore');
                set_param([obj.ModelName '/WIPER_CMD'], 'LinkStatus', 'restore');

                set_param([obj.ModelName '/R_pot'], 'R0', num2str((10^(obj.Digital_Pot_Model-101))/10));
                
                pause(0.5);
                
                save_system('X9C10C');

                obj = logState(obj, 'Simscape Model initialised');
            end

            
        end

        function obj = setWiperPos_Ideal(obj, value)    % does not account for digital logic delays
             if(value >= 99)
                 value = 99;
             end
             if(value <= 0)
                 value = 0;
             end

             set_param([obj.ModelName '/WIPER_CMD'], 'constant', num2str(value));
             simOut = sim(obj.ModelName);
             
             if(obj.Digital_Pot_Model==102)
                 disp("Resistance set to: "+num2str(((10^(obj.Digital_Pot_Model-101)))*value)+"Ω");
             else
                 disp("Resistance set to: "+num2str(((10^(obj.Digital_Pot_Model-101))/1000)*value)+"kΩ");
             end
        end
                


        function obj = setWiperPos_Real(obj, value) % emulates how it actually happens
             if(value >= 99)
                 value = 99;
             end
             if(value <= 0)
                 value = 0;
             end
            
            for i = 0:value
                if(value>obj.wiperPos)
                    incr(obj)
                else
                    decr(obj)
                end
                
            end


            % set_param([obj.ModelName '/WIPER_CMD'], 'constant', num2str(value));
            % set_param(obj.ModelName, 'SimulationCommand', 'update');
            
            if(obj.Digital_Pot_Model==102)
                 disp("Resistance set to: "+num2str(((10^(obj.Digital_Pot_Model-101)))*value)+"Ω");
            else
                 disp("Resistance set to: "+num2str(((10^(obj.Digital_Pot_Model-101))/1000)*value)+"kΩ");
            end
        end

        function obj = incr(obj)    % ## USER INPUT ##
            if(obj.wiperPos < 99)
                obj.inc = true;
                obj = logState(obj, 'UD_Changed');

                obj = movePOT(obj, obj.inc); % Increment by 1

                % Update Simulink model during simulation
                set_param([obj.ModelName '/WIPER_CMD'], 'constant', num2str(obj.wiperPos));
                % set_param(obj.ModelName, 'SimulationCommand', 'update');
            else
                obj = logState(obj, 'High_Limit_Reached');
                disp("High Limit Reached");
            
            end
            simOut = sim(obj.ModelName);
         end 

         function obj = decr(obj)    % ## USER INPUT ##
            if(obj.wiperPos > 0)
                obj.inc = false;
                obj = logState(obj, 'UD_Changed');

                obj = movePOT(obj, obj.inc); % Decrement by 1

                % Update Simulink model during simulation
                set_param([obj.ModelName '/WIPER_CMD'], 'constant', num2str(obj.wiperPos));
                % set_param(obj.ModelName, 'SimulationCommand', 'update');
            else
                obj = logState(obj, 'Low_Limit_Reached');
                disp("Low limit reached");

            end
            simOut = sim(obj.ModelName);
         end 

        function obj = store(obj)  % ## USER INPUT ##

            obj = logState(obj, 'Store_Start');

            obj.cs = false;
            obj = logState(obj, 'CS_Low');
            obj.cmd = true;
            obj = logState(obj, 'CMD_High');
            obj.time = obj.time + 1e-6;    % comment if unnecessary
            
            obj.cs = true;
            obj.time = obj.time + obj.T_CPH_S;
            obj = logState(obj, 'CS_Low');

            obj = logState(obj, 'Store_Complete');

        end
        
        
    end % public methods

    methods (Access = private)
        
        function obj = movePOT(obj, inc_dec)   % inc_dec is true/false
            
            obj.cmd = inc_dec;
            if(inc_dec == true)
                obj = logState(obj, 'Direction_Increment');
            else 
                if(inc_dec == false)
                    obj = logState(obj, 'Direction_Decrement');
                end
            end

            obj.time = obj.time + obj.T_DI;
            obj = logState(obj, 'Direction_Setup_Complete');

            obj.cs = false;
            obj = logState(obj, 'CS_Active');

            obj.inc = true;
            obj = logState(obj, 'INC_High');
            obj.time = obj.time + obj.T_IH;

            obj.inc = false;
            obj = logState(obj, 'INC_Low');
            obj.time = obj.time + obj.T_IL;


            if inc_dec
                obj.wiperPos = min(obj.wiperPos + 1, 99);
            else
                obj.wiperPos = max(obj.wiperPos - 1, 0);
            end
            
            % OPTIONAL - Simscape
            if exist([obj.ModelName '.slx'], 'file')
                set_param([obj.ModelName '/WIPER_CMD'], 'constant', num2str(obj.wiperPos));
            end

            obj = logState(obj, 'Wiper_Pos_Updated');

            
            % No Store, Return to Standby Mode
            obj = logState(obj, 'No_Store_Start');
            obj.cmd = false;
            obj = logState(obj, 'INC_LOW');
            obj.time = obj.time + obj.T_IL;
            obj.cs = true;
            obj = logState(obj, 'CS_HIGH');
            obj.time = obj.time + obj.T_CPH_NS;
            obj.cmd = true;
            obj = logState(obj, 'INC_HIGH');
            obj.time = obj.time + obj.T_IH;
            obj = logState(obj, 'No_Store_Complete');

        end

        function obj = logState(obj, event)
            event_str = string(event);

            % Log all signals with virtual timestamp
            data = table(...
                obj.time, ...
                event_str, ...
                obj.cs, ...
                obj.cmd, ...
                obj.inc, ...
                obj.wiperPos, ...
                'VariableNames', ...
                {'Time', 'Event', 'CS', 'UD', 'INC', 'WiperPos'}...
            );
            
            if exist(obj.StoreFile, 'file')
                writetable(data, obj.StoreFile, 'WriteMode', 'append');
            else
                writetable(data, obj.StoreFile);
            end
        end
    end

   
end

