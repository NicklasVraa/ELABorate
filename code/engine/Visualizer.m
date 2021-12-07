% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Visualizer
% A collection of visualization- and graphing-functionality, specifically
% designed to further the user's understanding of a given system.

    properties(Constant, Access = private)
        M = containers.Map({'impulse','step','ramp', 'sin', 'cos'}, ...
            {tf(1,1), tf(1,[1,0]), tf(1,[1,0,0]), tf(1,[1,0,1]), tf([1,0],[1,0,1])})
    end
    
    methods(Static)
        
        function res = response(sys, ref)
        % Plots the response of the given system, using the given reference.
            name = '';
            
            % Input validity check.
            if ~isa(sys, 'tf')
                if isa(sys, 'sym')
                    disp('Converting symbolic to tf-object.');
                    ELAB.transmute(sys, 'td', 'tf', false);
                else
                    error('Sys must be system object, like ''tf''.');
                end
            end
            
            % If ref is a string, map it to a function.
            if ~isa(ref,'tf')
                if isa(ref, 'char')
                    name = ref;
                    ref = Visualizer.M(lower(ref));
                elseif isa(ref, 'sym')
                    disp('Converting symbolic to tf-object.');
                    ref = ELAB.transmute(ref, 'td', 'tf', false);
                else
                    error('Reference signal type invalid. Try using its name.');
                end
            end
            
            impulse(ref); hold on;
            impulse(sys * ref);

            title([char(name), ' Response']);
            legend('Reference', 'Response'); hold off; grid off;
            res = sys * ref;
        end
        
        function plot_pz(sys)
        % Plots pole-zero diagram of the circuit.
            
            pzmap(sys);
            fprintf('For continuous-time system:\n');
            fprintf('- Stable if all poles are left of imaginary axis.\n\n');
            fprintf('For discrete-time system:\n');
            fprintf('- Stable if all poles are within unit-circle.\n\n');
            
        end
        
        function plot_bode(sys)
        % Plots Bode-diagram of the circuit.
            
        end
        
        function plot_nyq(sys)
        % Plots Nyquist-diagram of the circuit.
            
        end
        
        function lat = plot_eq(sym, fontsize)
        % Displays an equation in a plot-window.

            if ~isa(sym,'sym'); error('Input must be a symbolic expression'); end
            if nargin == 1; fontsize = 18; end
            
            T = { 'alpha', 'beta', 'gamma', 'Gamma', 'delta', 'Delta',   ...
                  'epsilon', 'zeta', 'eta', 'theta','Theta', 'iota',     ...
                  'kappa', 'lamba', 'Lambda', 'mu', 'nu', 'xi', 'Xi',    ...
                  'pi', 'Pi', 'rho', 'sigma', 'Sigma', 'tau', 'upsilon', ...
                  'Upsilon', 'phi', 'Phi', 'chi', 'Chi', 'psi', 'Psi',   ...
                  'omega', 'Omega'};

            C  = {'b\eta', 'th\eta', 'Th\eta', 'Th\eta','u\psilon', 'U\psilon' ; 
                  'beta',  'theta',  'Theta',  'Theta', 'upsilon',  'Upsilon'  };

            lat = ['$$',latex(sym),'$$'];            % Math typesetting environment
            for k = 1:numel(T)                       % Add '\' before greek.
                lat = strrep(lat, T{k}, ['\',T{k}]);
            end
            lat = strrep(lat,'\\','\');              % Some function e.g. Gamma already has '\'.
            for k = 1:numel(C)/2                     % Correct false '\', e.g. 'th\eta'.
                lat = strrep(lat, C{1,k}, C{2,k});
            end
            
            figure('Color','white','Menu','none')    % Change to 'figure' for menu bar.
            text(0.5, 0.5, lat, 'FontSize',fontsize, 'Color','k', ...
                'HorizontalAlignment','Center', 'VerticalAlignment','Middle', ...
                'Interpreter','Latex');
            axis off;
        end
    end
end

