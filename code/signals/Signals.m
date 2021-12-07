% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Signals
% Defines signals that can be used with Matlabs transform functions.
    
    methods (Static)
        function sig = impulse(n)
            sig = kroneckerDelta(n);
        end
        
        function sig = step(n)
            sig = heaviside(n) + 0.5*kroneckerDelta(n);
        end
        
        function xq = quantize(x, L, min_L, max_L)
        % Implements a uniform quantizer of L reproducer levels. Input signal x is a vector.
        % If L is odd -> 'midtread'. When L is even -> 'midrise'. Decision levels = L + 1.

            N = length(x); xq = zeros(1,N);
            Delta = (max_L - min_L)/L;

            % Calculate decision levels and reproducer values.
            dec_lev = min_L + Delta*(0:L);
            rep_val = min_L:max_L;

            % Uniformly quantize.
            for k=1:N
                for level=1:L
                    if x(k) >= dec_lev(level) && x(k) < dec_lev(level+1)
                        xq(k) = rep_val(level);
                    elseif x(k) > dec_lev(L)
                        xq(k) = rep_val(L);
                    elseif x(k) < dec_lev(1)
                        xq(k) = rep_val(1);
                    end
                end
            end
        end
        
        function sig = pcm(sig, bits, mode)
        % Pulse-Code Modulation
            sig = de2bi(sig, bits, 'left-msb');
            
            switch mode
                case 'unrz'
                    return;
                case 'pnrz'
                    sig(sig == 0) = -1;
            end
        end
    end
end

