% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Analyzer
% A collection of functions designed to facilitate symbolic 
% and numerical analysis of a given circuit object.
    
    methods(Static)
        
        function analyze(obj)
        % Symbolic analysis of given circuit object.
            
            if obj.symbolically_analyzed
                return
            end

            tic;

            % Array allocation.
            G = cell(obj.num_nodes, obj.num_nodes);  [G{:}] = deal('0');
            B = cell(obj.num_nodes, obj.num_VSs);    [B{:}] = deal('0');
            C = cell(obj.num_VSs,   obj.num_nodes);  [C{:}] = deal('0');
            D = cell(obj.num_VSs,   obj.num_VSs);    [D{:}] = deal('0');
            i = cell(obj.num_nodes, 1);              [i{:}] = deal('0');
            e = cell(obj.num_VSs,   1);              [e{:}] = deal('0');
            j = cell(obj.num_VSs,   1);              [j{:}] = deal('0');
            v = compose('v_%d', (1:obj.num_nodes)');

            % Building circuit equations:
            num_vs_parsed = 0;

            % Impedances (R, L, C).
            for index = 1:obj.num_impedances
                X = obj.Impedances(index);
                if     isa(X, 'Resistor'), g = ['1/' X.id];
                elseif isa(X, 'Inductor'), g = ['1/s/' X.id];
                elseif isa(X, 'Capacitor'), g = ['s*' X.id];
                elseif isa(X, 'Impedance'), g = ['1/' X.id];
                end
                
                if X.anode == 0
                    G{X.cathode, X.cathode} = sprintf('%s + %s', G{X.cathode, X.cathode}, g);
                elseif X.cathode == 0
                    G{X.anode,   X.anode}   = sprintf('%s + %s', G{X.anode,   X.anode}, g);
                else
                    G{X.anode,   X.anode}   = sprintf('%s + %s', G{X.anode,   X.anode}, g);
                    G{X.cathode, X.cathode} = sprintf('%s + %s', G{X.cathode, X.cathode}, g);
                    G{X.anode,   X.cathode} = sprintf('%s - %s', G{X.anode,   X.cathode}, g);
                    G{X.cathode, X.anode}   = sprintf('%s - %s', G{X.cathode, X.anode}, g);
                end
            end

            % Independent voltage sources (V).
            for index = 1:obj.num_Indep_VSs
                V = obj.Indep_VSs(index);
                num_vs_parsed = num_vs_parsed + 1;

                if V.anode ~= 0
                    B{V.anode, num_vs_parsed} = [B{V.anode, num_vs_parsed} ' + 1'];
                    C{num_vs_parsed, V.anode} = [C{num_vs_parsed, V.anode} ' + 1'];
                end
                if V.cathode ~= 0
                    B{V.cathode, num_vs_parsed} = [B{V.cathode, num_vs_parsed} ' - 1'];
                    C{num_vs_parsed, V.cathode} = [C{num_vs_parsed, V.cathode} ' - 1'];
                end
                e{num_vs_parsed} = V.id;
                j{num_vs_parsed} = ['I_' V.id];
            end

            % Independent current sources (I).
            for index = 1:obj.num_Indep_ISs
                I = obj.Indep_ISs(index);

                if I.anode ~= 0
                    i{I.anode} = [i{I.anode} ' - ' I.id];
                end
                if I.cathode ~= 0
                    i{I.cathode} = [i{I.cathode} ' + ' I.id];
                end
            end

            % Op-amps (O).
            for index = 1:obj.num_op_amps
                O = obj.Ideal_OpAmps(index);
                num_vs_parsed = num_vs_parsed + 1;

                B{O.output, num_vs_parsed} = [B{O.output, num_vs_parsed} ' + 1'];

                if O.input_1 ~= 0
                    C{num_vs_parsed, O.input_1} = [C{num_vs_parsed, O.input_1} ' + 1'];
                end
                if O.input_2 ~= 0
                    C{num_vs_parsed, O.input_2} = [C{num_vs_parsed, O.input_2} ' - 1'];
                end
                j{num_vs_parsed} = ['I_' O.id];
            end

            % Voltage Controlled Voltage Sources, VCVS (E).
            for index = 1:obj.num_VCVSs
                VCVS = obj.VCVSs(index);
                num_vs_parsed = num_vs_parsed + 1;
                ctrl_node_1 = VCVS.ctrl_anode;
                ctrl_node_2 = VCVS.ctrl_cathode;

                if VCVS.anode ~= 0
                    B{VCVS.anode, num_vs_parsed} = [B{VCVS.anode, num_vs_parsed} ' + 1'];
                    C{num_vs_parsed, VCVS.anode} = [C{num_vs_parsed, VCVS.anode} ' + 1'];
                end
                if VCVS.cathode ~= 0
                    B{VCVS.cathode, num_vs_parsed} = [B{VCVS.cathode, num_vs_parsed} ' - 1'];
                    C{num_vs_parsed, VCVS.cathode} = [C{num_vs_parsed, VCVS.cathode} ' - 1'];
                end
                if ctrl_node_1 ~= 0
                    C{num_vs_parsed, ctrl_node_1} = [C{num_vs_parsed, ctrl_node_1} ' - ' VCVS.id];
                end
                if ctrl_node_2 ~= 0
                    C{num_vs_parsed, ctrl_node_2} = [C{num_vs_parsed, ctrl_node_2} ' + ' VCVS.id];
                end

                j{num_vs_parsed} = ['I_' VCVS.id];
            end

            % Voltage Controlled Current Sources, VCCS (G).
            for index = 1:obj.num_VCCSs
                VCCS = obj.VCCSs(index);

                pattern = num2str([VCCS.anode ~= 0, VCCS.cathode ~= 0, ...
                    VCCS.ctrl_anode ~= 0, VCCS.ctrl_cathode ~= 0]);
                pattern = pattern(~isspace(pattern));

                switch pattern
                    case {'0000', '0001',  '0010', '0011', '0100', '1000', '1100'}
                        error('Invalid VCCS configuration.');
                    case '1111' % If nothing is grounded.
                        G{VCCS.anode,   VCCS.ctrl_anode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_anode}   ' + ' VCCS.id];
                        G{VCCS.anode,   VCCS.ctrl_cathode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_cathode} ' - ' VCCS.id];
                        G{VCCS.cathode, VCCS.ctrl_anode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_anode}   ' - ' VCCS.id];
                        G{VCCS.cathode, VCCS.ctrl_cathode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_cathode} ' + ' VCCS.id];
                    case '0111' % If only anode is grounded.
                        G{VCCS.cathode, VCCS.ctrl_anode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_anode}   ' - ' VCCS.id];
                        G{VCCS.cathode, VCCS.ctrl_cathode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_cathode} ' + ' VCCS.id];
                    case '0101' % If only anodes and control anode are grounded.
                        G{VCCS.cathode, VCCS.ctrl_cathode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_cathode} ' + ' VCCS.id];
                    case '0110' % If only anode and control cathode are grounded.
                        G{VCCS.cathode, VCCS.ctrl_anode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_anode}   ' - ' VCCS.id];
                    case '1011' % If only cathode is grounded.
                        G{VCCS.anode,   VCCS.ctrl_anode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_anode}   ' + ' VCCS.id];
                        G{VCCS.anode,   VCCS.ctrl_cathode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_cathode} ' - ' VCCS.id];
                    case '1001' % If only cathode and control anode are grounded.
                        G{VCCS.anode,   VCCS.ctrl_cathode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_cathode} ' - ' VCCS.id];
                    case '1010' % If only both cathodes are grounded.
                        G{VCCS.anode,   VCCS.ctrl_anode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_anode}   ' + ' VCCS.id];
                    case '1101' % If only control anode is grounded.
                        G{VCCS.anode,   VCCS.ctrl_cathode} ...
                            = [G{VCCS.anode,   VCCS.ctrl_cathode} ' - ' VCCS.id];
                        G{VCCS.cathode, VCCS.ctrl_cathode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_cathode} ' + ' VCCS.id];
                    case '1110' % If only control cathode is grounded.
                        G{VCCS.anode,   VCCS.ctrl_anode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_anode}   ' + ' VCCS.id];
                        G{VCCS.cathode, VCCS.ctrl_anode} ...
                            = [G{VCCS.cathode, VCCS.ctrl_anode}   ' - ' VCCS.id];
                end
            end

            % Current Controlled Voltage Sources, CCVS (H).
            for index = 1:obj.num_CCVSs
                CCVS = obj.CCVSs(index);
                num_vs_parsed = num_vs_parsed + 1;

                if CCVS.anode ~= 0
                    B{CCVS.anode, num_vs_parsed} = [B{CCVS.anode, num_vs_parsed} ' + 1'];
                    C{num_vs_parsed, CCVS.anode} = [C{num_vs_parsed, CCVS.anode} ' + 1'];
                end
                if CCVS.cathode ~= 0
                    B{CCVS.cathode, num_vs_parsed} = [B{CCVS.cathode, num_vs_parsed} ' - 1'];
                    C{num_vs_parsed, CCVS.cathode} = [C{num_vs_parsed, CCVS.cathode} ' - 1'];
                end

                j{num_vs_parsed} = ['I_' CCVS.id]; % Edit this to fit the others.
                
                % Add -CCVS_id to matrix D.
                ctrl_voltage = CCVS.ctrl_anode;
                ctrl_voltage_index = find(contains(j, ctrl_voltage));
                h_index = find(contains(j, CCVS.id));
                D{h_index, ctrl_voltage_index} = ['-' CCVS.id];
            end

            % Current Controlled Current Sources, CCCS (F).
            for index = 1:obj.num_CCCSs
                CCCS = obj.CCCSs(index);

                ctrl_voltage = obj.CCCSs(index).ctrl_anode;
                ctrl_voltage_index = find(contains(j, ctrl_voltage));

                if (CCCS.anode ~= 0)
                    B{CCCS.anode, ctrl_voltage_index} ...
                        = [B{CCCS.anode, ctrl_voltage_index} ' + ' CCCS.id];
                end
                if (CCCS.cathode ~= 0)
                    B{CCCS.cathode, ctrl_voltage_index} ...
                        = [B{CCCS.cathode, ctrl_voltage_index} ' - ' CCCS.id];
                end
            end

            % Matrix formation.
            A = str2sym([G B; C D]); x = str2sym([v;j]); z = str2sym([i;e]);
            syms([symvar(A), symvar(x), symvar(z)]);

            % Solving circuit equations.
            obj.equations = A * x == z;
            a = simplify(A \ z);
            obj.of_interest = x;
            obj.expressions = a;
            solutions = x == eval(a);
            obj.symbolic_node_voltages = solutions(1:obj.num_nodes,:);
            obj.symbolic_source_currents = solutions(obj.num_nodes + 1:end,:);
            obj.symbolically_analyzed = true;
            Analyzer.find_v_and_i(obj);
            fprintf('Symbolic analysis successful (%g sec).\n', toc);
        end
        
        function evaluate(obj)
        % Analyze circuit, using numerical values, if any exist.
            
            obj.numerical_element_voltages = [];
            obj.numerical_element_currents = [];
            
            Analyzer.analyze(obj)
            
            if obj.numerically_analyzed
                return
            end

            tic; syms('s');
            [Name, ~, ~, arg3, arg4, arg5] = obj.netlist{:};

            for index = 1:obj.num_elements
                switch Name{index}(1)
                    case {'V', 'I'}
                        if isempty(arg4{index})
                            syms(Name{index});
                        else
                            [num, status] = str2num(arg4{index});
                            if status
                                eval(sprintf('%s = %g;', Name{index}, num));
                            else
                                if strcmp(arg3{index}, 'AC')
                                    syms t;
                                    exp = laplace(str2sym(arg4{index}));
                                    eval(sprintf('%s = %s;', Name{index}, exp));
                                else
                                    syms(Name{index});
                                end
                            end
                        end
                    case {'R', 'L', 'C'}
                        if isempty(arg3{index})
                            syms(Name{index});
                        else
                            [num, status] = str2num(arg3{index});
                            if status
                                eval(sprintf('%s = %g;', Name{index}, num));
                            else
                                syms(Name{index});
                            end
                        end
                    case {'H', 'F'}
                        if isempty(arg4{index})
                            syms(Name{index});
                        else
                            [num, status] = str2num(arg4{index});
                            if status
                                eval(sprintf('%s = %g;', Name{index}, num));
                            else
                                syms(Name{index});
                            end
                        end
                    case {'E', 'G'}
                        if isempty(arg5{index})
                            syms(Name{index});
                        else
                            [num, status] = str2num(arg5{index});
                            if status
                                eval(sprintf('%s = %g;', Name{index}, num));
                            else
                                syms(Name{index});
                            end
                        end
                end
            end

            for index = 1:length(obj.of_interest)
                eval(sprintf('%s = %s;',obj.of_interest(index), obj.expressions(index)));
            end

            solutions = obj.of_interest == eval(obj.of_interest);
            obj.numerical_node_voltages = solutions(1:obj.num_nodes,:);
            obj.numerical_source_currents = solutions(obj.num_nodes + 1:end,:);

            obj.numerical_element_voltages = ...
                lhs(obj.symbolic_element_voltages) == eval(rhs(obj.symbolic_element_voltages));
            obj.numerical_element_currents = ...
                lhs(obj.symbolic_element_currents) == eval(rhs(obj.symbolic_element_currents));

            obj.numerically_analyzed = true;
            fprintf('\nNumerical evaluation successful (%g sec).\n', toc);
        end
        
        function out = ec2sd(obj, node_in, node_out)
        % Returns symbolic transfer function of circuit, given input and output node.
            
            tic;
            Analyzer.analyze(obj);
            
            v_in = obj.symbolic_node_voltages(node_in);
            v_out = obj.symbolic_node_voltages(node_out);
            out = collect(v_out/v_in);
            obj.symbolic_transfer_function = out;
            obj.symbolic_transfer_found = true;
            fprintf('Symbolic transfer function calculated successfully (%s sec).\n', toc);
        end
        
        function out = ec2tf(obj, node_in, node_out)
        % Returns transfer function object of circuit, given input and output node.
            
            tic;
            Analyzer.evaluate(obj);
            
            v_in = obj.numerical_node_voltages(node_in);
            v_out = obj.numerical_node_voltages(node_out);
            H = collect(v_out/v_in);
            [numerator, denominator] = numden(rhs(H));
            out = minreal(tf(sym2poly(numerator), sym2poly(denominator)));
            obj.numerical_transfer_function = out;
            obj.numerical_transfer_found = true;
            fprintf('Transfer function object created successfully (%s sec).\n', toc);
        end

        function RA = routh(poly_coeffs, show, epsilon)
        % Takes the coefficients of a characteristic equation of a system 
        % and returns the Routh array for stability analysis.
            
            if nargin < 2; show = false; end
            if nargin < 3; syms epsilon; end

            dim = size(poly_coeffs);              % Get size of poly_coeffs.	
            coeff = dim(2);                       % Get number of coefficients.
            RA = sym(zeros(coeff,ceil(coeff/2))); % Initialize symbolic Routh array.

            for i = 1:coeff
                RA(2-rem(i,2),ceil(i/2)) = poly_coeffs(i); % Assemble 1st and 2nd rows.
            end

            rows = coeff-2;                       % Number of rows that need determinants.
            index = zeros(rows,1);                % Inits columns-per-row index vector.

            for i = 1:rows
                index(rows-i+1) = ceil(i/2);      % Form index vector from bottom to top.
            end

            for i = 3:coeff                       % Go from 3rd row to last.
                if all(RA(i-1,:) == 0)            % Row of zeros.
                    disp('Special Case: Row of zeros.');
                    a = coeff-i+2;                % Order of auxiliary equation.
                    b = ceil(a/2)-rem(a,2)+1;     % Number of auxiliary coeffs.
                    tmp1 = RA(i-2,1:b);           % Get auxiliary polynomial.
                    tmp2 = a:-2:0;                % Auxiliry polynomial powers.
                    RA(i-1,1:b) = tmp1.*tmp2;	  % Derivative of auxiliary.
                elseif RA(i-1,1) == 0             % First element in row is zero.
                    disp('Special Case: First element is zero.');
                    RA(i-1,1) = epsilon;          % Replace by epsilon.
                end

                for j = 1:index(i-2) % Compute the Routh array elements.
                    RA(i,j) = -det([RA(i-2,1) RA(i-2,j+1); RA(i-1,1) RA(i-1,j+1)])/RA(i-1,1);
                end
            end
            
            RA = simplify(RA);
            if show; disp('Routh Array'); disp(RA); end
        end
        
        function cr = critical(RA, show)
        % Takes Routh-array and finds interval of symbolic, where system is stable.
        
            if nargin < 2; show = false; end
            
            try
                % Solve for K.
                roi = size(RA,1); % Row of interest.
                eq1 = RA(roi - 1) == 0; eq2 = RA(roi) == 0;
                k1 = solve(eq1); k2 = solve(eq2);
                K = [k1, k2];
            
                % Solve for s, given K.
                syms s;
                eq3 = RA(roi - 2)*s^2 + K == 0;

                S = [];
                for i = 1:length(eq3)
                    S = [S, solve(eq3(i))];
                end

                if show
                    disp('Solving equations for param:'); 
                    disp(eq1); disp(eq2);
                    fprintf('For stability, param (K) = ]%d;%d[\n\n', K(1), K(2));
                    disp('From s^2 auxiliary equation:'); disp(eq3);
                    disp('Solved for s:'); disp(S);
                end
            catch
                disp('No critical points. Parameter does not affect stability.');
                cr = 0;
            end
        end
        
        function bp = breakaway(sys, gain, show)
        % Returns breakaway points for root locus.
            
            if nargin < 3; show = false; end
            
            eq1 = solve(sys, gain);
            eq2 = collect(eq1);
            eq3 = diff(eq2);
            eq4 = solve(eq3 == 0);
            s = double(eq4);
            K = double(subs(eq2));
            bp = [s K];

            if show
                disp('Solving closed-loop for gain:'); disp(gain == eq1);
                disp('Expanding expression:'); disp(gain == eq2);
                disp('Derivative of gain of s:'); disp(eq3);
                disp('Solving diff(gain) = 0 for s:'); disp('s' == eq4');
                disp('Sub s in 1st equation, solving for gain.');
                disp('Breakaway points [s, gain]:');
                disp(bp);
            end
        end

        function [ord, type] = order_type(G, show)
        % Returns the order and type of the given system.
        
            if nargin < 2; show = false; end
            
            ord = order(G);
            type = sum(pole(G) == 0);
            
            if show
                fprintf('Order: %d\n', ord);
                fprintf('Type : %d\n', type);
            end
        end
        
        function [Kp, Kv, Ka] = static_error_K(G, show)
        % Returns static position error, static velocity error and static
        % acceleration error and steady-state error of the given system.
        
            if nargin < 2; show = false; end
            
            g = ELAB.tf2sd(G); syms s;
            Kp = double(limit(g, s, 0, 'right'));
            s = tf('s'); g = ELAB.tf2sd(s*G); syms s;
            Kv = double(limit(g, s, 0, 'right'));
            s = tf('s'); g = ELAB.tf2sd(s^2*G); syms s;
            Ka = double(limit(g, s, 0, 'right'));
            
            if show
                disp('Static error constants:');
                disp('  Position:');
                fprintf('    As s -> 0, G(s) -> K_p = %.2f\n', Kp);
                disp('  Velocity:');
                fprintf('    As s -> 0, s*G(s) -> K_v = %.2f\n', Kv);
                disp('  Acceleration:');
                fprintf('    As s -> 0, s^2*G(s) -> K_a = %.2f\n', Ka);
                disp('Steady-state error e_ss:');
                
                [~, type] = ELAB.order_type(G);
                switch type
                    case 0; disp('  Step: 1/(1+K)  Ramp: Inf  Accel: Inf');
                    case 1; disp('  Step: 0  Ramp: 1/K  Accel: Inf');
                    case 2; disp('  Step: 0  Ramp: 0  Accel: 1/K');
                end
            end
        end
        
        function dp = dominant(G)
        % Returns dominant poles, i.e. closest to imaginary axis.
        
            poles = pole(G);
            dom = max(real(nonzeros(poles)));
            dp = poles(real(poles) == dom);
        end
        
        function [wn, zeta] = damp(G, show)
        % Returns the natural frequency and damping ratio of a given system.
        
            if nargin < 2; show = false; end
            
            p = ELAB.dominant(G);
            wn = abs(p(1));
            zeta = -cos(angle(p(1)));
            
            if show
                fprintf('\nNatural frequency  = |%f%+fj|\n', real(p(1)), imag(p(1)));
                fprintf('Damping ratio zeta = -cos(angle(%f%+fj))\n', real(p(1)), imag(p(1)));
            end
        end
    
        function N = period(x)
        % Find fundamental period of function.
            try
                n = 0:1:100;
                x = double(subs(x));
                N = seqperiod(x);
                if N == length(n)
                    disp('Function is aperiodic.'); N = 0;
                end
            catch
                disp('Function is aperiodic.'); N = 0;
            end
        end
        
        function out = observable(in)
            out = canon(in, 'companion');
        end
        
        function out = controllable(in)
            out = ELAB.observable(in).';
        end
        
        function out = jordan(in)
            out = canon(in, 'modal');
        end
    end
    
    methods(Static, Access = private)
        
        function find_v_and_i(obj)
         % Find voltages and currents in single array of specific element-type.
            
            obj.symbolic_element_voltages = sym.empty;  
            obj.symbolic_element_currents = sym.empty;
         
            for index = 1:obj.num_impedances
                X = obj.Impedances(index); from_node = 0; to_node = 0;
                if X.anode > 0, from_node = obj.expressions(X.anode); end
                if X.cathode > 0, to_node = obj.expressions(X.cathode); end
                X.v_across = simplify(from_node - to_node);
                obj.symbolic_element_voltages(end+1) = sym(sprintf('v_%s', X.id)) == X.v_across;
                X.i_through = simplify(X.v_across / X.id);
                obj.symbolic_element_currents(end+1) = sym(sprintf('i_%s', X.id)) == X.i_through;
            end
            
            obj.symbolic_element_voltages = obj.symbolic_element_voltages(:);
            obj.symbolic_element_currents = obj.symbolic_element_currents(:);
        end
    end
end