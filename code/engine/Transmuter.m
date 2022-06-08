% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Transmuter
% A collection of functions designed to transmute a system into 
% another form, that may be more helpful for analysis or design.
    
    methods(Static)
        
        function out = transmute(in, type_in, type_out, show)
        % Convert any representation of a system into another representation
        % of the type, denoted by target. Act as a switcher for sub-functions.
        
        % 'sd' = Symbolic s-domain       'td' = Symbolic t-domain.
        % 'tf' = Transfer function obj.  'ss' = State space.
        % 'zp' = Zero-pole-gain.         'de' = Differential equation.
        % 'ce' = Characteristic eq.      'ec' = Electrical circuit.
        
            if nargin < 4; show = false; end

            switch type_in
                case 'sd'
                    switch type_out
                        case 'td'
                            out = ELAB.sd2td(in, show);
                        case 'tf' 
                            out = ELAB.sd2tf(in, show);
                        case 'ss' 
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2ss(in, show);
                        case 'zp'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2zp(in, show);
                        case 'de' 
                            out = ELAB.sd2de(in, show);
                        case 'ce' 
                            out = ELAB.sd2ce(in, show);
                        otherwise; error('Invalid type_out');
                    end
                case 'tf'
                    switch type_out
                        case 'sd'
                            out = ELAB.tf2sd(in, show);
                        case 'td'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2td(in, show);
                        case 'ss'
                            out = ELAB.tf2ss(in, show);
                        case 'zp'
                            out = ELAB.tf2zp(in, show);
                        case 'de'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2de(in, show);
                        case 'ce'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2ce(in, show);
                        otherwise; error('Invalid type_out');
                    end
                case 'td'
                    in = ELAB.td2sd(in, show);
                    switch type_out
                        case 'sd'
                            out = in;
                        case 'tf'
                            out = ELAB.sd2tf(in, show);
                        case 'ss'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2ss(in, show);
                        case 'zp'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2zp(in, show);
                        case 'de'
                            out = ELAB.sd2de(in, show);
                        case 'ce'
                            out = ELAB.sd2ce(in, show);
                        otherwise; error('Invalid type_out');
                    end
                case 'ss'
                    in = ELAB.ss2tf(in, show);
                    switch type_out
                        case 'sd'
                            out = ELAB.tf2sd(in, show);
                        case 'td'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2td(in, show);
                        case 'tf'
                            out = in;
                        case 'zp'
                            out = ELAB.tf2zp(in, show);
                        case 'de'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2de(in, show);
                        case 'ce'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2ce(in, show);
                        otherwise; error('Invalid type_out');
                    end
                case 'zp'
                    in = ELAB.zp2tf(in, show);
                    switch type_out
                        case 'sd'
                            out = ELAB.tf2sd(in, show);
                        case 'td'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2td(in, show);
                        case 'tf'
                            out = in;
                        case 'ss'
                            out = ELAB.tf2ss(in, show);
                        case 'de'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2de(in, show);
                        case 'ce'
                            in  = ELAB.tf2sd(in, show);
                            out = ELAB.sd2ce(in, show);
                        otherwise; error('Invalid type_out');
                    end
                case 'de'
                    in = ELAB.de2sd(in, show);
                    switch type_out
                        case 'sd'
                            out = in;
                        case 'td'
                            out = ELAB.sd2td(in, show);
                        case 'tf'
                            out = ELAB.sd2tf(in, show);
                        case 'ss'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2ss(in, show);
                        case 'zp'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2zp(in, show);
                        case 'ce'
                            out = ELAB.sd2ce(in, show);
                        otherwise; error('Invalid type_out');
                    end
                case 'ce'
                    in = ELAB.ce2sd(in, show);
                    switch type_out
                        case 'sd'
                            out = in;
                        case 'td'
                            out = ELAB.sd2td(in, show);
                        case 'tf'
                            out = ELAB.sd2tf(in, show);
                        case 'ss'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2ss(in, show);
                        case 'zp'
                            in  = ELAB.sd2tf(in, show);
                            out = ELAB.tf2zp(in, show);
                        case 'de'
                            out = ELAB.sd2de(in, show);
                        otherwise; error('Invalid type_out');
                    end
                otherwise
                    error('Invalid type_in');
            end
        end
        
        function out = sd2tf(in, show)
        % Symbolic expression to transfer function.
            
            if nargin < 2; show = false; end
            eval("s = tf('s');");
            eval(['T = ', char(in), ';']);

            out = minreal(T);
        end
        
        function out = zd2tf(in, show)
        % Symbolic expression to transfer function.
            
            if nargin < 2; show = false; end
            eval("z = tf('z');");
            eval(['T = ', char(in), ';']);
            out = minreal(T);
        end
        
        function out = tf2sd(in, show)
        % Transfer function to symbolic expression.
            
            if nargin < 2; show = false; end
            syms s;
            out = poly2sym(cell2mat(in.num),s)/poly2sym(cell2mat(in.den),s);
        end
        
        function out = tf2ss(in, show)
        % Transfer function to state space.
            
            if nargin < 2; show = false; end
            out = ss(in);
        end
        
        function out = ss2tf(in, show)
        % State space to transfer function.
            
            if nargin < 2; show = false; end
            [num, den] = ss2tf(in.A, in.B, in.C, in.D);
            out = tf(num,den);
        end
        
        function out = tf2zp(in, show)
        % Transfer function to zero-pole-gain function.
            
            if nargin < 2; show = false; end
            out = zpk(in);
        end
        
        function out = zp2tf(in, show)
        % Zero-pole-gain function to transfer function.
            
            if nargin < 2; show = false; end
            out = tf(in);
        end
        
        function out = de2sd(in, show)
        % Differential equation to symbolic expression.
            
            if nargin < 2; show = false; end
            syms y(t) s Y;
            eq = laplace(in.eq, t, s);
            eq = subs(eq, laplace(y, t, s), Y);
            
            if ~isempty(in.cond)
                eq = subs(eq, y(0), in.cond(1));
            end
            if length(in.cond) > 1
                eq = subs(eq, subs(diff(y(t), t), t, 0), in.cond(2));
            end
            warning('off','all'); 
            out = solve(eq,Y); warning('on','all');
            
            
            if show
                disp('Diff. equation'); disp(in.eq);
                disp('Laplace transform:'); disp(eq);
                disp('Solve for tf:'); disp(out);
            end
        end
        
        function out = sd2de(in, show)
        % Symbolic expression to differential equation.
            
            if nargin < 2; show = false; end
            out = in;
            error('Not yet implemented');
        end
        
        function out = sd2ce(in, show)
        % Symbolic expression to characteristic equation.
            
            if nargin < 2; show = false; end
            syms s;
            eq1 = expand(in);
            eq2 = numden(simplify(eq1)); % Extract numerator.
            char_eq = collect(eq2);
            out = flip(coeffs(char_eq, s));
            
            if show
                disp('Original expression:'); disp(in);
                disp('Expanded form:'); disp(eq1);
                disp('Set equal to 0, then simplify:'); disp(eq2);
                disp('Collect terms of equal power:'); disp(char_eq);
            end
        end
        
        function out = ce2sd(in, show)
        % Characteristic equation to symbolic expression.
            
            if nargin < 2; show = false; end
            syms s;
            out = poly2sym(in,s);
        end
        
        function out = sd2td(in, show)
        % Symbolic in s-domain to t-domain.
            
            if nargin < 2; show = false; end
            syms s t;
            pf = partfrac(in);
            out = ilaplace(pf, s, t);
            
            if show
                disp('In s-domain'); disp(in);
                disp('Partial fraction decomp:'); disp(pf);
                disp('Inverse Laplace:'); disp(out);
            end
        end
        
        function out = td2sd(in, show)
        % Symbolic in t-domain to s-domain.
            
            if nargin < 2; show = false; end
            syms s t;
            ex = expand(in);
            tr = laplace(ex, t, s);
            out = simplify(tr);
            out = collect(out);
            
            if show
                disp('In t-domain'); disp(in);
                disp('Expanded:'); disp(ex);
                disp('Laplace transform:'); disp(tr);
                disp('Collected and simplified:'); disp(out);
            end
        end
        
        function out = nd2zd(in, show)
        % Symbolic in n-domain to z-domain.
            
            if nargin < 2; show = false; end
            syms n z;
            ex = expand(in);
            tr = ztrans(ex, n, z);
            out = simplify(tr);
            out = collect(out);
            
            if show
                disp('In n-domain'); disp(in);
                disp('Expanded:'); disp(ex);
                disp('Z-transform:'); disp(tr);
                disp('Collected and simplified:'); disp(out);
            end
        end
    end
end
