function SSGain = calculateGain(n_populations, constants)
% calculateGain Calculates the small-signal gain.
%
% Inputs:
%   n_populations - Vector of population densities at steady state.
%   constants     - Structure containing simulation constants.
%
% Output:
%   SSGain        - Calculated small-signal gain.

% Unpack constants
sigmaEmission = constants.sigmaEmission;
sigmaAbsorption = constants.sigmaAbsorption;
ndop = constants.ndop;
L = constants.L;

n2 = n_populations(2);
n3 = n_populations(3);
n4 = n_populations(4);

% Calculate gain coefficient
g0 = sigmaEmission * n2 - sigmaAbsorption * (ndop - n2 - n3 - n4);

% Calculate gain
SSGain = exp(g0 * L);
end
