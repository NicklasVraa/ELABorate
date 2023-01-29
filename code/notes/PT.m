% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef PT
% The Periodic Table of Elements.
    
    properties(Constant)
        H  = Atom('Hydrogen',1,1,1,1.0080);
        He = Atom('Helium',2,18,1,4.0026);
        Li = Atom('Lithium',3,1,2,6.9400);
        Be = Atom('Beryllium',4,2,2,9.0122);
        B  = Atom('Boron',5,13,2,10.8100);
        C
        N
        O
        F
        Ne
        Na
        Mg
        Al
        Si
        P
        S
        Cl
        Ar
        K
        Ca
        Sc
        Ti
        V
        Cr
        Mn
        Fe
        Co
        Ni
        Cu
        Zn
        Ga
        Ge
        As
        Se
        Br
        Kr
    end
    
    methods(Static)
        function help()
            fprintf('See README.md and Manual.md');
        end
    end
end

