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
                series_done = Modeller.simplify_series(obj);
                parallel_done = Modeller.simplify_parallel(obj);
                if series_done && parallel_done
                    break;
                end
            end
            
            Modeller.rename(obj);
            obj.update;
            obj.reset;
        end
                
        function obj = dc_eq(obj)
        % Short-circuit AC voltage sources and inductors.
        % Open-circuit AC current sources and capacitors.
            
            to_be_shorted = [];
            to_be_opened = [];

            for index = 1:obj.num_Indep_VSs
                if obj.Indep_VSs(index).is_AC
                    to_be_shorted = [to_be_shorted, obj.Indep_VSs(index)];
                end
            end

            for index = 1:obj.num_Indep_ISs
                if obj.Indep_ISs(index).is_AC
                    to_be_opened = [to_be_opened, obj.Indep_ISs(index)];
                end
            end

            for index = 1:obj.num_inductors
                to_be_shorted = [to_be_shorted, obj.Inductors(index)];
            end
            
            for index = 1:obj.num_capacitors
                to_be_opened = [to_be_opened, obj.Capacitors(index)];
            end
            
            for index = 1:length(to_be_shorted)
                obj.short(to_be_shorted(index));
            end

            for index = 1:length(to_be_opened)
                obj.open(to_be_opened(index));
            end

            obj.trim;
        end
        
        function obj = ac_eq(obj)
        % Short-circuit DC sources.
            
            to_be_shorted = [];
            to_be_opened = [];
            
            for index = 1:obj.num_Indep_VSs
                if ~obj.Indep_VSs(index).is_AC
                    to_be_shorted = [to_be_shorted, obj.Indep_VSs(index)];
                end
            end

            for index = 1:obj.num_Indep_ISs
                if ~obj.Indep_ISs(index).is_AC
                    to_be_opened = [to_be_opened, obj.Indep_ISs(index)];
                end
            end
            
            for index = 1:length(to_be_shorted)
                obj.short(to_be_shorted(index));
            end

            for index = 1:length(to_be_opened)
                obj.open(to_be_opened(index));
            end

            obj.trim;
        end
        
        function obj = remove_sources(obj)
        % Short voltage-sources and open current-sources.

            to_be_shorted = [];
            to_be_opened = [];

            for index = 1:obj.num_Indep_VSs
                to_be_shorted = [to_be_shorted, obj.Indep_VSs(index)];
            end

            for index = 1:obj.num_VCVSs
                to_be_shorted = [to_be_shorted, obj.VCVSs(index)];
            end

            for index = 1:obj.num_CCVSs
                to_be_shorted = [to_be_shorted, obj.CCVSs(index)];
            end

            for index = 1:obj.num_Indep_ISs
                to_be_opened = [to_be_opened, obj.Indep_ISs(index)];
            end

            for index = 1:obj.num_VCCSs
                to_be_opened = [to_be_opened, obj.VCCSs(index)];
                obj.open(obj.VCCSs(index));
            end

            for index = 1:obj.num_CCCSs
                to_be_opened = [to_be_opened, obj.CCCSs(index)];
            end

            for index = 1:length(to_be_shorted)
                obj.short(to_be_shorted(index));
            end

            for index = 1:length(to_be_opened)
                obj.open(to_be_opened(index));
            end

            obj.trim;
        end

        function obj = thevenin(obj, load)
        % Returns the Thevenin-equivalent of the given circuit,
        % as seen by the given load.

            % Load object is deleted upon envoking open().
            load_id = load.id;
            load_val = load.impedance;
            
            ports = load.terminals;
            obj.open(load);
            ELAB.evaluate(obj);
            
            if ports(1) == 0, v1 = 0;
            else, v1 = rhs(obj.numerical_node_voltages(ports(1)));
            end

            if ports(2) == 0, v2 = 0;
            else, v2 = rhs(obj.numerical_node_voltages(ports(2)));
            end
            
            Modeller.remove_sources(obj);
            Modeller.simplify(obj);
            v_th = v1 - v2;
            r_th = obj.Resistors(1).impedance;

            obj.add(Indep_VS('Vth', 1, 0, 'DC', v_th));
            obj.add(Resistor('Rth', 1, 2, r_th));
            obj.open(obj.Resistors(1));
            obj.add(Resistor(load_id, 2, 0, load_val));
        end
        
        function obj = norton(obj, load)
        % Returns the Norton-equivalent of the given circuit,
        % as seen by the given load.
            
            % Load object is deleted upon envoking open().
            load_id = load.id;
            load_val = load.impedance;

            ports = load.terminals;
            obj.open(load);
            ELAB.evaluate(obj);
            
            if ports(1) == 0, v1 = 0;
            else, v1 = rhs(obj.numerical_node_voltages(ports(1)));
            end

            if ports(2) == 0, v2 = 0;
            else, v2 = rhs(obj.numerical_node_voltages(ports(2)));
            end
            
            Modeller.remove_sources(obj);
            Modeller.simplify(obj);
            v_th = v1 - v2;
            r_th = obj.Resistors(1).impedance;
            i_no = v_th / r_th;
            
            obj.add(Indep_IS('Ino', 1, 0, 'DC', i_no));
            obj.add(Resistor('Rno', 1, 0, r_th));
            obj.open(obj.Resistors(1));
            obj.add(Resistor(load_id, 1, 0, load_val));
        end

        function obj = hybrid_pi(obj, freq)
        % Replace all transistors with their low/high-frequency-hybrid-pi model.
            
            % Short DC-VS's and open DC-CS's.
            obj = Modeller.ac_eq(obj);
        
            % Replace MOSFETS.
            for index = 1:obj.num_MOSFETs
                M = obj.MOSFETs(index);
                
                % Add new elements.
                id = sprintf('R_o_%s', M.id);
                R_o = Resistor(id, M.drain_node, M.source_node, id);
                obj.Resistors(end+1) = R_o;

                id = sprintf('G_m_%s', M.id);
                G_m = VCCS(id, M.drain_node, M.source_node, M.source_node, M.gate_node, id);
                obj.VCCSs(end+1) = G_m;
                
                if freq == "hf" % High frequency model.
                    id = sprintf('C_pi_%s', M.id);
                    C_pi = Capacitor(id, M.gate_node, M.source_node, id);
                    obj.Capacitors(end+1) = C_pi;

                    id = sprintf('C_mu_%s', M.id);
                    C_mu = Capacitor(id, M.gate_node, M.drain_node, id);
                    obj.Capacitors(end+1) = C_mu;
                end

                obj.remove(M); obj.update;
            end

            for index = 1:obj.num_BJTs
                Q = obj.BJTs(index);

                % Add new elements.
                id = sprintf('R_pi_%s', Q.id);
                R_pi = Resistor(id, Q.base_node, Q.emitter_node, id);
                obj.Resistors(end+1) = R_pi;

                id = sprintf('R_o_%s', Q.id);
                R_o = Resistor(id, Q.collector_node, Q.emitter_node, id);
                obj.Resistors(end+1) = R_o;

                id = sprintf('G_m_%s', Q.id);
                G_m = VCCS(id, Q.collector_node, Q.emitter_node, Q.emitter_node, Q.base_node, id);
                obj.VCCSs(end+1) = G_m;

                if freq == "hf" % High frequency model.
                    id = sprintf('C_pi_%s', Q.id);
                    C_pi = Capacitor(id, Q.base_node, Q.emitter_node, id);
                    obj.Capacitors(end+1) = C_pi;

                    id = sprintf('R_mu_%s', Q.id);
                    R_mu = Resistor(id, Q.base_node, Q.collector_node, id);
                    obj.Resistors(end+1) = R_mu;

                    id = sprintf('C_mu_%s', Q.id);
                    C_mu = Capacitor(id, Q.base_node, Q.collector_node, id);
                    obj.Capacitors(end+1) = C_mu;
                end

                obj.remove(Q); obj.update;
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
        
        function done = simplify_parallel(obj)
        % Simplifies parallel elements of same type and returns how many pairs were found.
            
            done = true;

            R = Modeller.find_parallel(obj, obj.Resistors);
            if ~isempty(R)
                eq = simplify(R(1).resistance * R(2).resistance / (R(1).resistance + R(2).resistance));
                obj.Resistors(end+1) = Resistor('Req', R(1).anode, R(1).cathode, eq);
                obj.remove(R(1)); obj.remove(R(2)); done = false;
            end
            
            L = Modeller.find_parallel(obj, obj.Inductors);
            if ~isempty(L)
                eq = simplify(L(1).inductance * L(2).inductance / (L(1).inductance + L(2).inductance));
                obj.Inductors(end+1) = Inductor('Leq', L(1).anode, L(1).cathode, eq);
                obj.remove(L(1)); obj.remove(L(2)); done = false;
            end

            C = Modeller.find_parallel(obj, obj.Capacitors);
            if ~isempty(C)
                eq = simplify(C(1).capacitance + C(2).capacitance);
                obj.Capacitors(end+1) = Capacitor('Ceq', C(1).anode, C(1).cathode, eq);
                obj.remove(C(1)); obj.remove(C(2)); done = false;
            end
            
            V = Modeller.find_parallel(obj, obj.Indep_VSs);
            if ~isempty(V)
                if V(1).voltage == V(2).voltage && V(1).is_AC == V(2).is_AC % Same type.
                    eq = V(1).voltage;
                    if V(1).is_AC, type = 'AC'; else, type = 'DC'; end
                    obj.Indep_VSs(end+1) = Indep_VS('Veq', V(1).anode, V(1).cathode, type, eq);
                    obj.remove(V(1)); obj.remove(V(2)); done = false;
                end
            end

            I = Modeller.find_parallel(obj, obj.Indep_ISs);
            if ~isempty(I)
                if I(1).is_AC == I(2).is_AC
                    eq = I(1).current + I(2).current;
                    if I(1).is_AC, type = 'AC'; else, type = 'DC'; end
                    obj.Indep_ISs(end+1) = Indep_IS('Ieq', I(1).anode, I(1).cathode, type, eq);
                    obj.remove(I(1)); obj.remove(I(2)); done = false;
                end
            end
        end

        function done = simplify_series(obj)
        % Simplifies series elements of same type and returns how many pairs were found.
            
            done = true;

            R = Modeller.find_series(obj, obj.Resistors);
            if ~isempty(R)
                eq = simplify(R(1).resistance + R(2).resistance);
                obj.Resistors(end+1) = Resistor('Req', R(1).anode, R(1).cathode, eq);
                obj.remove(R(1)); obj.short(R(2)); done = false;
            end
            
            L = Modeller.find_series(obj, obj.Inductors);
            if ~isempty(L)
                eq = simplify(L(1).inductance + L(2).inductance);
                obj.Inductors(end+1) = Inductor('Leq', L(1).anode, L(1).cathode, eq);
                obj.remove(L(1)); obj.short(L(2)); done = false;
            end

            C = Modeller.find_series(obj, obj.Capacitors);
            if ~isempty(C)
                eq = simplify(C(1).capacitance * C(2).capacitance / (C(1).capacitance + C(2).capacitance));
                obj.Capacitors(end+1) = Capacitor('Ceq', C(1).anode, C(1).cathode, eq);
                obj.remove(C(1)); obj.short(C(2)); done = false;
            end
            
            V = Modeller.find_series(obj, obj.Indep_VSs);
            if ~isempty(V)
                if V(1).is_AC == V(2).is_AC
                    eq = V(1).voltage + V(2).voltage;
                    if V(1).is_AC, type = 'AC'; else, type = 'DC'; end
                    obj.Indep_VSs(end+1) = Indep_VS('Veq', V(1).anode, V(1).cathode, type, eq);
                    obj.remove(V(1)); obj.short(V(2)); done = false;
                end
            end
        end
        
        function pair = find_parallel(~, Xs)
        % Returns only parallel elements from Xs.
            
            pair = [];
            for index_1 = 1:length(Xs)
                X1 = Xs(index_1);
                for index_2 = 1 + index_1:length(Xs)
                    X2 = Xs(index_2);
                    if Modeller.is_parallel(X1, X2)
                        pair = [X1, X2];
                        return;
                    end
                end
            end
        end
 
        function pair = find_series(obj, Xs)
        % Returns only series elements from Xs.    
            
            pair = [];
            for index_1 = 1:length(Xs)
                X1 = Xs(index_1);
                for index_2 = 1 + index_1:length(Xs)
                    X2 = Xs(index_2);
                    if Modeller.is_series(obj, X1, X2)
                        pair = [X1, X2];
                        return;
                    end
                end
            end
        end
        
        function rename(obj)
        % Rename elements to maintain netlist order.

            Modeller.rename_eqs(obj.Resistors);
            Modeller.rename_eqs(obj.Inductors);
            Modeller.rename_eqs(obj.Capacitors);
            Modeller.rename_eqs(obj.Indep_VSs);
            Modeller.rename_eqs(obj.Indep_ISs);
        end

        function rename_eqs(Xs)
        % Rename any element in a given list, which is an equivalent of others.
            
            eqs = 0;
            for index = 1:length(Xs)
                X = Xs(index);
                if strcmp(X.id(2:end), 'eq')
                    eqs = eqs + 1;
                    X.id = sprintf('%seq%d', X.id(1), eqs);
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

