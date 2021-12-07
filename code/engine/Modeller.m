% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Modeller
% A collection of functions, specifically for safely altering the 
% circuit object or even converting the circuit to another form.
    
    methods(Static)
       
        function obj = simplify(obj)
        % Simplifies the given circuit object.
            
            obj.reset;
            
            while true
                num_series = Modeller.simplify_series(obj);
                num_parallels = Modeller.simplify_parallel(obj);
                if num_parallels == 0 && num_series == 0, break; end
            end
            
            obj.update;
        end
                
        function obj = dc_eq(obj)
        % Short-circuit AC sources and inductors, open-circuit capacitors.
            
            to_be_shorted = [];
        
            for index = 1:obj.num_Indep_Ss
                if obj.Indep_Ss(index).is_AC
                    to_be_shorted = [to_be_shorted, obj.Indep_Ss(index)];
                end
            end
            
            for index = 1:obj.num_inductors
                obj.short(obj.Inductors(index));
            end
            
            for index = 1:obj.num_capacitors
                obj.open(obj.Capacitors(index));
            end
            
            for index = 1:length(to_be_shorted)
                obj.short(to_be_shorted(index));
            end
            
            obj.trim;
        end
        
        function obj = ac_eq(obj)
        % Short-circuit DC sources.
            
            to_be_shorted = [];
            
            for index = 1:obj.num_Indep_Ss
                if ~obj.Indep_Ss(index).is_AC
                    to_be_shorted = [to_be_shorted, obj.Indep_Ss(index)];
                end
            end
            
            for index = 1:length(to_be_shorted)
                obj.short(to_be_shorted(index));
            end
            
        end
        
        function obj = ssm(obj)
        % Replace all transistors with their small-signal-model.
            
            % Short DC-VS's and open DC-CS's.
            obj = Modeller.ac_eq(obj);
        
            % Replace MOSFETS.
            for index = 1:obj.num_MOSFETs
                M = obj.MOSFETs(index);
                
                % Decide on names for new components.
                id_1 = sprintf('R_pi_%s', M.id);
                id_2 = sprintf('R_o_%s', M.id);
                id_3 = sprintf('G_m_%s', M.id);
                
                % Create components.
                R_o = Resistor(id_2, M.drain_node, M.source_node, id_2);
                G_m = VCCS(id_3, M.drain_node, M.source_node, M.source_node, M.gate_node, id_3);
                
                % Add and remove components.
                obj.Resistors(end+1) = R_o;
                obj.VCCSs(end+1) = G_m;
                obj.remove(M); obj.update;
                Modeller.simplify(obj);
            end
        end
        
        function bool = is_same_type(X1, X2)
        % Checks if elements, X1 and X2, are of the same class.
        
            bool = isequal(class(X1), class(X2));
        end
        
        function bool = is_parallel(X1, X2)
        % Checks if 2-terminal-elements, X1 and X2, are parallel.
        
            if X1 == X2, error('Comparing an object to itself'); end
            
            if X1.num_terminals == 2 && X2.num_terminals == 2
                bool = (X1.anode == X2.anode && X1.cathode == X2.cathode)...
                    || (X1.anode == X2.cathode && X1.cathode == X2.anode);        
            else
                error('Given elements are not 2-terminal-components');
            end
        end
        
        function bool = is_series(obj, X1, X2)
        % Checks if 2-terminal-elements, X1 and X2, are parallel.
            
            bool = true;
            if X1.num_terminals > 2 || X2.num_terminals > 2
                error('Given elements are not 2-terminal-components');
            end
            
            if Modeller.is_parallel(X1, X2), bool = false; return; end

            if X1.anode == X2.anode || X1.anode == X2.cathode
                shared = X1.anode;
            elseif X1.cathode == X2.anode || X1.cathode == X2.cathode
                shared = X1.cathode;
            else
                bool = false;
                return;
            end
            
            if  Modeller.check_shared(obj.Indep_VSs, X1, X2, shared) || ...
                Modeller.check_shared(obj.Indep_ISs, X1, X2, shared) || ...
                Modeller.check_shared(obj.Resistors, X1, X2, shared) || ...
                Modeller.check_shared(obj.Inductors, X1, X2, shared) || ...
                Modeller.check_shared(obj.Capacitors, X1, X2, shared) || ...
                Modeller.check_shared(obj.VCVSs, X1, X2, shared) || ...
                Modeller.check_shared(obj.VCCSs, X1, X2, shared) || ...
                Modeller.check_shared(obj.CCVSs, X1, X2, shared) || ...
                Modeller.check_shared(obj.CCCSs, X1, X2, shared) || ...
                Modeller.check_shared(obj.Ideal_OpAmps, X1, X2, shared) || ...
                Modeller.check_shared(obj.BJTs, X1, X2, shared) || ...
                Modeller.check_shared(obj.MOSFETs, X1, X2, shared)
                bool = false;
            end
        end
    end
    
    methods(Static, Access = private)
        
        function num_parallels = simplify_parallel(obj)
        % Simplifies parallel elements of same type and returns how many
        % was pairs were found.
            
            num_parallels = 0;
            parallels = Modeller.find_parallels(obj, obj.Resistors);
            num_parallels = num_parallels + length(parallels);
            for index = 1:length(parallels)
                pair = parallels{index}; R1 = pair{1}; R2 = pair{2};
                eq = (R1.resistance * R2.resistance / (R1.resistance + R2.resistance));
                eq_id = sprintf('Req%s', num2str(index));
                obj.Resistors(end+1) = Resistor(eq_id, R1.anode, R1.cathode, eq);
                obj.remove(R1); obj.remove(R2);
            end
            
            parallels = Modeller.find_parallels(obj, obj.Inductors);
            num_parallels = num_parallels + length(parallels);
            for index = 1:length(parallels)
                pair = parallels{index}; L1 = pair{1}; L2 = pair{2};
                eq = (L1.inductance * L2.inductance / (L1.inductance + L2.inductance));
                eq_id = sprintf('Leq%s', num2str(index));
                obj.Inductors(end+1) = Inductor(eq_id, L1.anode, L1.cathode, eq);
                obj.remove(L1); obj.remove(L2);
            end
            
            parallels = Modeller.find_parallels(obj, obj.Capacitors);
            num_parallels = num_parallels + length(parallels);
            for index = 1:length(parallels)
                pair = parallels{index}; C1 = pair{1}; C2 = pair{2};
                eq = (C1.capacitance + C2.capacitance);
                eq_id = sprintf('Ceq%s', num2str(index));
                obj.Capacitors(end+1) = Capacitor(eq_id, C1.anode, C1.cathode, eq);
                obj.remove(C1); obj.remove(C2);
            end
            
            parallels = Modeller.find_parallels(obj, obj.Indep_VSs);
            num_parallels = num_parallels + length(parallels);
            for index = 1:length(parallels)
                pair = parallels{index}; V1 = pair{1}; V2 = pair{2};
                if V1.voltage == V2.voltage && V1.is_AC == V2.is_AC
                    eq = V1.voltage;
                    if V1.is_AC, type = 'AC'; else, type = 'DC'; end
                    eq_id = sprintf('Veq%s', num2str(index));
                    obj.Indep_VSs(end+1) = Indep_VS(eq_id, V1.anode, V1.cathode, type, eq);
                    obj.remove(V1); obj.remove(V2);
                end
            end
            
            parallels = Modeller.find_parallels(obj, obj.Indep_ISs);
            num_parallels = num_parallels + length(parallels);
            for index = 1:length(parallels)
                pair = parallels{index}; I1 = pair{1}; I2 = pair{2};
                if I1.is_AC == I2.is_AC
                    eq = I1.current + I2.current;
                    if I1.is_AC, type = 'AC'; else, type = 'DC'; end
                    eq_id = sprintf('Ieq%s', num2str(index));
                    obj.Indep_ISs(end+1) = Indep_IS(eq_id, I1.anode, I1.cathode, type, eq);
                    obj.remove(I1); obj.remove(I2);
                end
            end
        end
        
        function parallels = find_parallels(~, Xs)
        % Returns only parallel elements from Xs.
            
            parallels = cell.empty;
            for index_1 = 1:length(Xs)
                X1 = Xs(index_1);
                for index_2 = 1 + index_1:length(Xs)
                    X2 = Xs(index_2);
                    if Modeller.is_parallel(X1, X2)
                        parallels{end+1} = {X1, X2};
                    end
                end
            end
        end
        
        function num_series = simplify_series(obj)
        % Simplifies series elements of same type and returns how many
        % was pairs were found.
        
            num_series = 0;
            series = Modeller.find_series(obj, obj.Resistors);
            num_series = num_series + length(series);
            for index = 1:length(series)
                pair = series{index}; R1 = pair{1}; R2 = pair{2};
                eq = (R1.resistance + R2.resistance);
                eq_id = sprintf('Req%s', num2str(index));
                obj.Resistors(end+1) = Resistor(eq_id, R1.anode, R2.cathode, eq);
                obj.remove(R1); obj.remove(R2);
            end
            
            series = Modeller.find_series(obj, obj.Inductors);
            num_series = num_series + length(series);
            for index = 1:length(series)
                pair = series{index}; L1 = pair{1}; L2 = pair{2};
                eq = (L1.inductance + L2.inductance);
                eq_id = sprintf('Leq%s', num2str(index));
                obj.Inductors(end+1) = Inductor(eq_id, L1.anode, L2.cathode, eq);
                obj.remove(L1); obj.remove(L2);
            end
            
            series = Modeller.find_series(obj, obj.Capacitors);
            num_series = num_series + length(series);
            for index = 1:length(series)
                pair = series{index}; C1 = pair{1}; C2 = pair{2};
                eq = (C1.capacitance * C2.capacitance / (C1.capacitance + C2.capacitance));
                eq_id = sprintf('Ceq%s', num2str(index));
                obj.Capacitors(end+1) = Capacitor(eq_id, C1.anode, C2.cathode, eq);
                obj.remove(C1); obj.remove(C2);
            end
            
            series = Modeller.find_series(obj, obj.Indep_VSs);
            num_series = num_series + length(series);
            for index = 1:length(series)
                pair = series{index}; V1 = pair{1}; V2 = pair{2};
                eq = V1.voltage + V2.voltage;
                eq_id = sprintf('Veq%s', num2str(index));
                obj.Indep_VSs(end+1) = Indep_VS(eq_id, V1.anode, V2.cathode, eq);
                obj.remove(V1); obj.remove(V2);
            end
        end
        
        function series = find_series(obj, Xs)
        % Returns only series elements from Xs.    
        
            series = cell.empty;
            for index_1 = 1:length(Xs)
                X1 = Xs(index_1);
                for index_2 = 1 + index_1:length(Xs)
                    X2 = Xs(index_2);
                    if Modeller.is_series(obj, X1, X2)
                        series{end+1} = {X1, X2};
                    end
                end
            end
        end
        
        function bool = check_shared(Xs, X1, X2, node)
        % Check if any element is connected to given node. X1 and X2 are not checked.
        
            bool = false;
            for index_1 = 1:length(Xs)
                X = Xs(index_1);
                if X ~= X1 && X ~= X2
                    bools = X.is_connected(node);
                    for index_2 = 1:length(bools)
                        if bools(index_2)
                            bool = true;
                            return;
                        end
                    end
                end
            end
        end
    end
end

