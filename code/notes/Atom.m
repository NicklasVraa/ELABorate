% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Atom
% The Atomic element class.
    
    properties
        name;
        num;
        group;
        period;
        mass;
        class;
        e_lvls;
        e_neg;
    end
    
    methods(Static)
        function obj = Atom(name, num, group, period, mass)
            obj.name = name;
            obj.num = num;
            obj.group = group;
            obj.period = period;
            obj.mass = mass;
        end
    end
end

