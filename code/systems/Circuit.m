% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Circuit < Base_System
% Circuit model, utilizing the Element subclasses.
    
    properties
    % Information about this object, available to the user.    
        
        % Globals.
        file_name;  num_nodes;  num_elements; list;
        
        % Arrays of elements.
        Indep_VSs = Indep_VS.empty;    Indep_ISs = Indep_IS.empty;
        Resistors = Resistor.empty;    Inductors = Inductor.empty;
        Capacitors = Capacitor.empty;  Ideal_OpAmps = Ideal_OpAmp.empty;
        VCVSs = VCVS.empty;            CCCSs = CCCS.empty;
        VCCSs = VCCS.empty;            CCVSs = CCVS.empty;
        BJTs = BJT.empty;              MOSFETs = MOSFET.empty;
        
        % Results.
        equations;
        symbolic_transfer_function;    numerical_transfer_function;  
        symbolic_node_voltages;        numerical_node_voltages;
        symbolic_element_voltages;     numerical_element_voltages;
        symbolic_element_currents;     numerical_element_currents;
        symbolic_source_currents;      numerical_source_currents;
    end

    properties (Access = {?ELAB, ?Analyzer, ?Modeller, ?Transmuter, ?Visualizer})
    % Information only available to object itself.
        
        % Flags.
        symbolically_analyzed = false;     numerically_analyzed = false;
        symbolic_transfer_found = false;   numerical_transfer_found = false;
        
        % Lengths of arrays.
        num_passives;    num_transistors;  num_VSs;        num_ISs; 
        num_Indep_VSs;   num_Indep_ISs;    num_resistors;  num_inductors; 
        num_capacitors;  num_VCVSs;        num_VCCSs;      num_CCVSs; 
        num_CCCSs;       num_op_amps;      num_BJTs;       num_MOSFETs;
        num_Indep_Ss;    num_Dep_Ss;
        
        % Combined element arrays.
        Elements = Element.empty;          Indep_Ss = Indep_S.empty;
        Passives = Passive.empty;          Dep_Ss = Dep_S.empty;
        Transistors = Transistor.empty;
        
        % For calculations.
        of_interest; expressions; netlist;
    end

    methods
    
        function obj = Circuit(file_name)
        % Constructor of the circuit class.
            
            % Parse a text file.
            obj.file_name = file_name;
            file = fopen(file_name);
            netlist = textscan(file,'%s %s %s %s %s %s %s %s', 'CollectOutput', 1);
            obj.netlist = {netlist{1}(:,1) netlist{1}(:,2) netlist{1}(:,3) netlist{1}(:,4) ...
                netlist{1}(:,5) netlist{1}(:,6) netlist{1}(:,7) netlist{1}(:,8)};
            [Name, N1, N2, arg3, arg4, arg5, arg6, arg7] = obj.netlist{:};
            fclose(file);
            obj.num_elements = length(Name);
            N1 = str2double(N1); N2 = str2double(N2);
            obj.num_nodes = max([N1; N2]);

            % Creating element objects.
            for i = 1:obj.num_elements
                id = Name{i}(1:end); X = id(1);
                switch X % First letter.
                    case {'V'}
                        obj.Indep_VSs(end+1) = Indep_VS(id, N1(i), N2(i), arg3{i}, arg4{i});
                    case {'I'}
                        obj.Indep_ISs(end+1) = Indep_IS(id, N1(i), N2(i), arg3{i}, arg4{i});
                    case {'R'}
                        obj.Resistors(end+1) = Resistor(id, N1(i), N2(i), arg3{i});
                    case {'L'}
                        obj.Inductors(end+1) = Inductor(id, N1(i), N2(i), arg3{i});
                    case {'C'}
                        obj.Capacitors(end+1) = Capacitor(id, N1(i), N2(i), arg3{i});
                    case {'E'}
                        obj.VCVSs(end+1) = VCVS(id, N1(i), N2(i), str2double(arg3{i}), ...
                            str2double(arg4{i}), arg5{i});
                    case {'G'}
                        obj.VCCSs(end+1) = VCCS(id, N1(i), N2(i), str2double(arg3{i}), ...
                            str2double(arg4{i}), arg5{i});
                    case {'H'}
                        obj.CCVSs(end+1) = CCVS(id, N1(i), N2(i), arg3{i}, arg4{i});
                    case {'F'}
                        obj.CCCSs(end+1) = CCCS(id, N1(i), N2(i), arg3{i}, arg4{i});
                    case {'O'}
                        obj.Ideal_OpAmps(end+1) = Ideal_OpAmp(id, N1(i), N2(i), str2double(arg3{i}));
                    case {'Q'}
                        obj.BJTs(end+1) = BJT(id, N1(i), N2(i), str2double(arg3{i}), arg4{i}, ...
                            arg5{i}, arg6{i}, arg7{i});
                    case {'M'}
                        obj.MOSFETs(end+1) = MOSFET(id, N1(i), N2(i), str2double(arg3{i}), ...
                            arg4{i}, arg5{i}, arg6{i}, arg7{i});
                end
            end
            obj.update();
        end
        
        function status(obj)
        % Prints the status of the circuit object.
        
            fprintf('<strong>%Status:</strong>\n', obj.id);
            fprintf('- Symbolically analyzed: %s\n', mat2str(obj.symbolically_analyzed));
            fprintf('- Numerically analyzed: %s\n', mat2str(obj.numerically_analyzed));
            fprintf('- Symbolic transfer function found: %s\n', ...
                mat2str(obj.symbolic_transfer_found));
            fprintf('- Numerical transfer function found: %s\n\n', ...
                mat2str(obj.numerical_transfer_found));
        end
        
        function update_netlist(obj)
        % Returns netlist-string describing circuit object.
        
            list = [];
            for index = 1:obj.num_elements
                list = [list, obj.Elements(index).to_net];
            end
            obj.list = list;
            obj.netlist = textscan(list,'%s %s %s %s %s %s %s %s');
        end
        
        function short(obj, X)
        % Update circuit object, after effectively shorting element X.
            
            new_node = min(X.terminals);
            
            for index = 1:X.num_terminals
                node = X.terminals(index);
                
                Ys = get_connected(obj, X, node);
                for index_1 = 1:length(Ys)
                    Y = Ys{index_1};

                    for index_2 = 1:Y.num_terminals
                        if Y.terminals(index_2) == node
                            Y.update_terminals(index_2, new_node);
                        end
                    end
                end
            end
            remove(obj, X);
        end
        
        function open(obj, X)
        % Update circuit object, after effectively open-circuiting element X.
        
            remove(obj, X);
            trim(obj);
        end
        
        function clean(obj)
        % Update node numbering to avoid skips in indexing.
            
            for k = 1:obj.num_nodes
                % Make list of all terminals.
                nodes = [];
                for index = 1:obj.num_elements
                    X = obj.Elements(index);
                    nodes = [nodes, X.terminals];
                end
                % Find smallest number above k
                m = min(nodes(nodes > k));
                
                % Replace any terminal value matching m with k+1.
                for index = 1:obj.num_elements
                    X = obj.Elements(index);
                    for t = 1:X.num_terminals
                        if X.terminals(t) == m
                            X.update_terminals(t, k+1);
                        end
                    end
                end
            end
        end
    end

    methods(Access = {?ELAB, ?Analyzer, ?Modeller, ?Transmuter, ?Visualizer})
        
        function connected = get_connected(obj, X, node)
        % Get all the elements connected to given element X at given node.
        
            connected = [];
            connected = [connected, Circuit.check_elem_array(obj.Indep_VSs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.Indep_ISs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.Resistors, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.Inductors, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.Capacitors, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.VCVSs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.VCCSs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.CCVSs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.CCCSs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.Ideal_OpAmps, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.BJTs, X, node)];
            connected = [connected, Circuit.check_elem_array(obj.MOSFETs, X, node)];      
        end
        
        function remove(obj, X)
        % Remove X from circuit's element-arrays, without updating connections.
        
            if     isa(X, 'Resistor'),  Xs = obj.Resistors;  obj.Resistors  = Xs(Xs ~= X);
            elseif isa(X, 'Inductor'),  Xs = obj.Inductors;  obj.Inductors  = Xs(Xs ~= X);
            elseif isa(X, 'Capacitor'), Xs = obj.Capacitors; obj.Capacitors = Xs(Xs ~= X);
            elseif isa(X, 'Indep_VS'), Xs = obj.Indep_VSs; obj.Indep_VSs = Xs(Xs ~= X);
            elseif isa(X, 'Indep_IS'), Xs = obj.Indep_ISs; obj.Indep_ISs = Xs(Xs ~= X);
            elseif isa(X, 'VCVS'), Xs = obj.VCVSs; obj.VCVSs = Xs(Xs ~= X);
            elseif isa(X, 'VCCS'), Xs = obj.VCCSs; obj.VCCSs = Xs(Xs ~= X);
            elseif isa(X, 'CCVS'), Xs = obj.CCVSs; obj.CCVSs = Xs(Xs ~= X);
            elseif isa(X, 'CCCS'), Xs = obj.CCCSs; obj.CCCSs = Xs(Xs ~= X);
            elseif isa(X, 'Ideal_OpAmp'), Xs = obj.Ideal_OpAmps; obj.Ideal_OpAmps = Xs(Xs ~= X);
            elseif isa(X, 'BJT'), Xs = obj.BJTs; obj.BJTs = Xs(Xs ~= X);
            elseif isa(X, 'MOSFET'), Xs = obj.MOSFETs; obj.MOSFETs = Xs(Xs ~= X);
            end
            
            delete(X); 
            obj.update;
        end
        
        function update(obj)
        % Updates all circuit properties.
        
            obj.update_nums; 
            obj.update_arrays;
            obj.update_num_nodes;
            obj.update_netlist;
            obj.clean;
        end
        
        function reset(obj)
        % Reset flags and arrays.
        
            obj.symbolic_node_voltages = [];                 
            obj.symbolic_source_currents = [];
            obj.symbolic_element_voltages = [];  
            obj.symbolic_element_currents = [];
            obj.symbolic_transfer_function = [];
            obj.numerical_node_voltages = [];                
            obj.numerical_source_currents = [];
            obj.numerical_transfer_function = [];            
            obj.numerical_element_voltages = [];
            obj.numerical_element_currents = [];
            obj.equations = [];
            
            obj.symbolically_analyzed = false;     
            obj.numerically_analyzed = false;
            obj.symbolic_transfer_found = false;   
            obj.numerical_transfer_found = false;
        end
        
        function trim(obj)
        % Remove elements not affecting circuit.
        
            to_be_removed = [];
            
            % Find anything not connected to anything else.
            for index = 1:obj.num_elements
                X = obj.Elements(index);
                sum = 0;
                
                for index_1 = 1:X.num_terminals
                    node = X.terminals(index_1);
                    
                    if node ~= 0
                        sum = sum + length(get_connected(obj, X, node));
                    end
                end
                
                if sum == 0, to_be_removed = [to_be_removed, X];
                end
            end
            
            % Find anything connected only to itself.
            for index = 1:obj.num_elements
                found = false;
                X = obj.Elements(index);
                
                for index_1 = 1:X.num_terminals
                    for index_2 = (1 + index_1):X.num_terminals
                        if X.terminals(index_1) ~= X.terminals(index_2)
                            found = true; break;
                        end
                    end
                end
                
                if ~found
                    disp(['Removing ', X.id, ' (self connected).']);
                    to_be_removed = [to_be_removed, X];
                end
            end
            
            % Remove found elements.
            for index = 1:length(to_be_removed)
                remove(obj, to_be_removed(index));
            end
        end
    end
    
    methods(Access = private)
        
        function update_num_nodes(obj)
        % Check and update the number of nodes in the circuit.
        
            n = [];
            for index = 1:obj.num_elements
                X = obj.Elements(index);
                n = [n, X.terminals];
            end
            % Find how many unique nodes, minus ground.
            obj.num_nodes = length(unique(n)) - 1;
        end
        
        function update_nums(obj)
        % Check and update the number of each element in the circuit.
        
            obj.num_Indep_VSs = length(obj.Indep_VSs);  obj.num_Indep_ISs = length(obj.Indep_ISs);
            obj.num_resistors = length(obj.Resistors);  obj.num_capacitors = length(obj.Capacitors);
            obj.num_inductors = length(obj.Inductors);  obj.num_op_amps = length(obj.Ideal_OpAmps);
            obj.num_VCVSs = length(obj.VCVSs);          obj.num_VCCSs = length(obj.VCCSs);
            obj.num_CCVSs = length(obj.CCVSs);          obj.num_CCCSs = length(obj.CCCSs);
            obj.num_BJTs = length(obj.BJTs);            obj.num_MOSFETs = length(obj.MOSFETs);
            
            obj.num_Indep_Ss = obj.num_Indep_VSs + obj.num_Indep_ISs;
            obj.num_Dep_Ss = obj.num_VCVSs + obj.num_CCVSs + obj.num_VCCSs + obj.num_CCCSs;
            obj.num_VSs = obj.num_Indep_VSs + obj.num_op_amps + obj.num_VCVSs + obj.num_CCVSs;
            obj.num_ISs = obj.num_Indep_ISs + obj.num_VCCSs + obj.num_CCCSs;
            obj.num_passives = obj.num_resistors + obj.num_inductors + obj.num_capacitors;
            obj.num_transistors = obj.num_BJTs + obj.num_MOSFETs;
            obj.num_elements = obj.num_VSs + obj.num_ISs + obj.num_passives + obj.num_transistors;
        end
        
        function update_arrays(obj)
        % Update heterogeneous arrays.
        
            obj.Indep_Ss = [obj.Indep_VSs, obj.Indep_ISs];
            obj.Passives = [obj.Resistors, obj.Inductors, obj.Capacitors];
            obj.Dep_Ss = [obj.VCVSs, obj.VCCSs, obj.CCVSs, obj.CCCSs];
            obj.Transistors = [obj.BJTs, obj.MOSFETs];
            obj.Elements = [obj.Indep_Ss, obj.Passives, obj.Dep_Ss, obj.Transistors];
        end
    end

    methods(Static)
        
        function connected = check_elem_array(Xs, Y, node)
        % Return all elements in given array, connected to given node.
        
            connected = cell.empty;
            for index_1 = 1:length(Xs)
                X = Xs(index_1);
                if X ~= Y
                    bools = X.is_connected(node);
                    for index_2 = 1:length(bools)
                        if bools(index_2)
                            connected{end+1} = X;
                        end
                    end
                end
            end
        end   
    end
end