% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Circuit < Base_System
% Circuit model, utilizing the Element subclasses.
    
    properties
    % Information about this circuit object, available to the user.    
        
        % Globals.
        file_name;  num_nodes;  num_elements; list;
        
        % Arrays of elements.
        Indep_VSs = Indep_VS.empty;    Indep_ISs = Indep_IS.empty;
        Resistors = Resistor.empty;    Inductors = Inductor.empty;
        Capacitors = Capacitor.empty;  Ideal_OpAmps = Ideal_OpAmp.empty;
        Generic_zs = Impedance.empty;
        
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
    % Information only available to ELABorate modules.
        
        % Flags.
        symbolically_analyzed = false;     numerically_analyzed = false;
        symbolic_transfer_found = false;   numerical_transfer_found = false;
        
        % Lengths of arrays.
        num_impedances;  num_transistors;  num_VSs;        num_ISs; 
        num_Indep_VSs;   num_Indep_ISs;    num_resistors;  num_inductors; 
        num_capacitors;  num_VCVSs;        num_VCCSs;      num_CCVSs; 
        num_CCCSs;       num_op_amps;      num_BJTs;       num_MOSFETs;
        num_Indep_Ss;    num_Dep_Ss;
        num_generic_zs;
        
        % Combined element arrays.
        Elements = Element.empty;          Indep_Ss = Indep_S.empty;
        Transistors = Transistor.empty;    Dep_Ss = Dep_S.empty;
        Impedances = Impedance.empty;
        
        % For calculations.
        of_interest; expressions; netlist;
    end

    methods
    % Methods pertaining to this circuit.
    
        function obj = Circuit(file_name)
        % Constructor of the circuit class.
            
            % Parse the text file at the given path (file_name).
            obj.file_name = file_name;
            file = fopen(file_name);

            % Convert to cell matrix, based on line number and spaces.
            netlist = textscan(file,'%s %s %s %s %s %s %s %s', 'CollectOutput', 1);
            obj.netlist = {netlist{1}(:,1) netlist{1}(:,2) netlist{1}(:,3) ...
                           netlist{1}(:,4) netlist{1}(:,5) netlist{1}(:,6) ...
                           netlist{1}(:,7) netlist{1}(:,8)};
            fclose(file);

            % Split cell matrix into vectors.
            [Name, N1, N2, arg3, arg4, arg5, arg6, arg7] = obj.netlist{:};
            
            % Convert node values from string-type to number-type.
            N1 = str2double(N1); N2 = str2double(N2);

            % Find number of elements by number of entries in the vectors.
            obj.num_elements = length(Name);
            obj.num_nodes = length(unique([N1; N2])) - 1;

            % Creating element objects based the parsed netlist information.
            for i = 1:obj.num_elements

                % Element id is always in the same place.
                id = Name{i}(1:end);

                % First letter in ID tells the type of element.
                switch id(1) 
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
                    case {'Z'}
                        obj.Impedances(end+1) = Impedance(id, N1(i), N2(i), arg3{i});
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
                        obj.Ideal_OpAmps(end+1) = Ideal_OpAmp(id, N1(i), N2(i), ...
                                                              str2double(arg3{i}));
                    case {'Q'}
                        obj.BJTs(end+1) = BJT(id, N1(i), N2(i), str2double(arg3{i}), ...
                                              arg4{i}, arg5{i}, arg6{i}, arg7{i});
                    case {'M'}
                        obj.MOSFETs(end+1) = MOSFET(id, N1(i), N2(i), str2double(arg3{i}), ...
                                                    arg4{i}, arg5{i}, arg6{i}, arg7{i});
                end
            end

            % This creates compound element arrays and handles setup.
            obj.update();
        end
        
        function export(obj, name)
        % Create a circuit file from the circuit object 
        % netlist in the current working directory.

            file = fopen(name,'w');
            fprintf(file,'%s %s %s %s %s %s %s %s', obj.list);
            fclose(file);
        end    
        
        function copy = clone(obj)
        % Creates a standalone object, that is a clone of the given circuit.
        % i.e. not a reference to the original object.
            
            obj.export('tmp.txt');
            copy = Circuit('tmp.txt');
            delete('tmp.txt');
        end

        function status(obj)
        % Prints the status of the circuit object.
        
            fprintf('<strong>%Status:</strong>\n', obj.id);
            fprintf('- Sym. analyzed: %s\n', mat2str(obj.symbolically_analyzed));
            fprintf('- Num. analyzed: %s\n', mat2str(obj.numerically_analyzed));
            fprintf('- Sym. transfer function found: %s\n', ...
                mat2str(obj.symbolic_transfer_found));
            fprintf('- Num. transfer function found: %s\n\n', ...
                mat2str(obj.numerical_transfer_found));
        end
        
        function update_netlist(obj)
        % Returns a netlist-string which describes this circuit object.
        
            L = [];
            for index = 1:obj.num_elements
                L = [L, obj.Elements(index).to_net];
            end

            obj.list = L;
            obj.netlist = textscan(L,'%s %s %s %s %s %s %s %s');
        end
        
        function short(obj, X)
        % Update circuit object, after effectively shorting element X.
            
            % After shorting, use the node with the lowest number.
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
            
            for k = 0:obj.num_nodes
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
            obj.update;
        end
    
        function add(obj, X)
        % Add element to circuit and update appropriately.
            
            if X.num_terminals == 2

                % If it is necessary to create a new node.
                if X.anode == -1 || X.cathode == -1
                    new_node = obj.num_nodes + 1;

                    if X.anode == -1
                        node = X.cathode;
                        X.anode = new_node;
                        X.update_terminals(1,new_node);
                    elseif X.cathode == -1
                        node = X.anode;
                        X.cathode = new_node;
                        X.update_terminals(2,new_node);
                    end
                    
                    connected = get_connected(obj, X, node);

                    for index = 1:length(connected)
                        Y = connected{index};
                        if Y.anode == node
                            prompt = sprintf('Re-assign %s''s anode:', Y.id);
                            new_connection = inputdlg({prompt},'Nodal ambiguity',[1,50]);
                            Y.anode = str2double(new_connection);
                        elseif Y.cathode == node
                            prompt = sprintf('Re-assign %s''s cathode:', Y.id);
                            new_connection = inputdlg({prompt},'Nodal ambiguity',[1,50]);
                            Y.cathode = str2double(new_connection);
                        end
                    end
                end
            end

            switch X.id(1)
                case {'V'}
                    obj.Indep_VSs(end+1) = X;
                case {'I'}
                    obj.Indep_ISs(end+1) = X;
                case {'R'}
                    obj.Resistors(end+1) = X;
                case {'L'}
                    obj.Inductors(end+1) = X;
                case {'C'}
                    obj.Capacitors(end+1) = X;
                case {'Z'}
                    obj.Generic_zs(end+1) = X;
            end

            obj.update;
            obj.reset;
        end
    end

    methods(Access = {?ELAB, ?Analyzer, ?Modeller, ?Transmuter, ?Visualizer})
    % Methods only available to ELABorate modules.
        
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
            elseif isa(X, 'Impedance'), Xs = obj.Generic_zs; obj.Generic_zs = Xs(Xs ~= X);
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
            obj.clean;
            obj.reset;
        end
        
        function update(obj)
        % Updates all circuit properties.
        
            obj.update_nums;       obj.update_arrays;
            obj.update_num_nodes;  obj.update_netlist;
        end
        
        function reset(obj)
        % Reset flags and arrays, for example when the structure of the
        % circuit is altered.
        
            obj.symbolic_node_voltages = [];      obj.symbolic_source_currents = [];
            obj.symbolic_element_voltages = [];   obj.symbolic_element_currents = [];
            obj.symbolic_transfer_function = [];  obj.numerical_node_voltages = [];                
            obj.numerical_source_currents = [];   obj.numerical_transfer_function = [];            
            obj.numerical_element_voltages = [];  obj.numerical_element_currents = [];
            obj.equations = [];
            
            obj.symbolically_analyzed = false;    obj.numerically_analyzed = false;
            obj.symbolic_transfer_found = false;  obj.numerical_transfer_found = false;
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
                
                if sum == 0
                    to_be_removed = [to_be_removed, X];
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
    % Methods only available to this circuit object.
        
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
            
            % Elements
            obj.num_Indep_VSs = length(obj.Indep_VSs);   obj.num_Indep_ISs = length(obj.Indep_ISs);
            obj.num_resistors = length(obj.Resistors);   obj.num_capacitors = length(obj.Capacitors);
            obj.num_inductors = length(obj.Inductors);   obj.num_generic_zs = length(obj.Generic_zs);
            obj.num_VCVSs = length(obj.VCVSs);           obj.num_VCCSs = length(obj.VCCSs);
            obj.num_CCVSs = length(obj.CCVSs);           obj.num_CCCSs = length(obj.CCCSs);
            obj.num_BJTs = length(obj.BJTs);             obj.num_MOSFETs = length(obj.MOSFETs);
            obj.num_op_amps = length(obj.Ideal_OpAmps);
            
            % Super-classes
            obj.num_Indep_Ss = obj.num_Indep_VSs + obj.num_Indep_ISs;
            obj.num_Dep_Ss = obj.num_VCVSs + obj.num_CCVSs + obj.num_VCCSs + obj.num_CCCSs;
            obj.num_VSs = obj.num_Indep_VSs + obj.num_op_amps + obj.num_VCVSs + obj.num_CCVSs;
            obj.num_ISs = obj.num_Indep_ISs + obj.num_VCCSs + obj.num_CCCSs;
            obj.num_transistors = obj.num_BJTs + obj.num_MOSFETs;
            obj.num_impedances = obj.num_generic_zs + obj.num_resistors ...
                               + obj.num_inductors + obj.num_capacitors;
            
            % All
            obj.num_elements = obj.num_VSs + obj.num_ISs + obj.num_impedances + obj.num_transistors;
        end
        
        function update_arrays(obj)
        % Update heterogeneous arrays.
        
            obj.Indep_Ss = [obj.Indep_VSs, obj.Indep_ISs];
            obj.Impedances = [obj.Generic_zs, obj.Resistors, obj.Inductors, obj.Capacitors];
            obj.Dep_Ss = [obj.VCVSs, obj.VCCSs, obj.CCVSs, obj.CCCSs];
            obj.Transistors = [obj.BJTs, obj.MOSFETs];
            obj.Elements = [obj.Indep_Ss, obj.Impedances, obj.Dep_Ss, ...
                            obj.Ideal_OpAmps, obj.Transistors];
        end
    end

    methods(Static)
    % Methods shared among objects of this class.
        
        function connected = check_elem_array(Xs, Y, node)
        % Return all elements in given array, connected to the given node.
        
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