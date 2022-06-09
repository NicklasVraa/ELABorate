% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef ELAB < Analyzer & Modeller & Visualizer & Transmuter
% The combination of the main classes of the ELABorate project.
    
    properties
        notes;
    end

    methods(Static)
        
        function help()
            fprintf('See README.md and Manual.md');
        end
        
        function credits()
            fprintf('Built by Nicklas Vraa');
        end
    end
end