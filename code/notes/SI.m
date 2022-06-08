% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef SI
% A collection of physical constants and unit defintions as of May 2019.
    
    properties(Constant)
        
        % Constants
        dV_Cs = 9192631770        % Hyperfine transition frequency of cesium-133 in [Hz].
        c     = 299792458         % Speed of light in vacuum [meter/second].
        h     = 6.62607015*10^34  % Plank's constant [Joule*second].
        q_e   = 1.602176634*10^19 % Elementary charge [Coulomb].
        kB    = 1.380649*10^-23   % Boltzmann constant [Joule*Kelvin].
        N_A   = 6.02214076*10^23  % Avogadro constant [mol^-1].
        K_cd  = 683               % Luminous efficacy [lm*W^-1].
        
        % Derived
        m_e   = 9.109383701528*10^31;        % Mass of electron at rest [kg].
        Z_0   = pi*119.9169832               % Impedence of vacuum [Ohm].
        h_bar = h/(2*pi);                    % Reduced plank's constant [Joule*second].
        alpha = (q_e*Z_0)/(4*pi*h_bar);      % Hyperfine structure constant [Dimensionless].
        eps_0 = q_e^2/(2*alpha*h*c);         % Electrical permittivity of vacuum [Farad/meter].
        mu_0  = (2*alpha*h)/(q_e^2*c);       % Magnetic permeability of vacuum [Henry/meter].
        a_0   = h_bar/(m_e*c*alpha);         % Bohr radius [meter].
        K_J   = 2*q_e/h;                     % Josephson constant.
        R_inf = (alpha^2*m_e*c)/(4*pi*h_bar) % Rydberg constant.
        R_K   = h/q_e^2;                     % Von Klitzing constant.
        
        
        % Base units
        base_units = ['Second', 'Meter', 'Kilogram', 'Ampere', 'Kelvin', 'Mole', 'Candela'];
        
    end
    
end

