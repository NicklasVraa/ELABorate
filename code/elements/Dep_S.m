% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Dep_S < Element
% The abstract basis for all dependent sources.
    
    properties
        anode; cathode;
        v_across; i_through;
    end
end

