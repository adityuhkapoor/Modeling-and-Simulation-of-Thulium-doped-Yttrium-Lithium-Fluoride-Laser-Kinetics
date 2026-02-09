function constants = getDefaultConstants()
% getDefaultConstants Physics constants for the Tm:YLF laser model.

    constants = struct( ...
        'kcr',             6.85e-19, ...   % Cross-relaxation coefficient [cm^3/s]
        'ketu1',           2.1e-21,  ...   % ETU coefficient 1 [cm^3/s]
        'ketu2',           2.1e-21,  ...   % ETU coefficient 2 [cm^3/s]
        'tau2',            16.3e-3,  ...   % Level 2 lifetime [s]
        'tau3',            2.258e-3, ...   % Level 3 lifetime [s]
        'tau4',            56.63e-6, ...   % Level 4 lifetime [s]
        'ndop',            8.3e20,   ...   % Dopant concentration [cm^-3]
        'sigmaEmission',   4e-21,    ...   % Emission cross-section [cm^2]
        'sigmaAbsorption', 9e-22,    ...   % Absorption cross-section [cm^2]
        'sigmaPumpAbs',    6.978e-21, ...  % Pump absorption cross-section [cm^2]
        'lambdaPump',      7.913e-5, ...   % Pump wavelength [cm]
        'h',               6.626e-34, ...  % Planck's constant [J*s]
        'c',               3e8,      ...   % Speed of light [m/s]
        'beta43',          0.100,    ...   % Branching ratio 4->3
        'beta42',          0.030,    ...   % Branching ratio 4->2
        'beta32',          0.030,    ...   % Branching ratio 3->2
        'L',               3.5       ...   % Crystal length [cm]
    );
end
