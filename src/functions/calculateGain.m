function SSGain = calculateGain(n_populations, constants)
% calculateGain Calculates the small-signal gain from population densities.
%
% Computes the gain coefficient g0 from the population inversion and
% applies Beer-Lambert law: SSGain = exp(g0 * L).
%
% Gain formula:
%   g0 = sigma_emission * n2 - sigma_absorption * n1
%   where n1 = ndop - n2 - n3 - n4  (ground state population)
%
% Inputs:
%   n_populations - 1x4 (or 4x1) vector of population densities [cm^-3].
%                   Order: [n1, n2, n3, n4].
%   constants     - Struct containing at minimum:
%                   sigmaEmission, sigmaAbsorption, ndop, L.
%
% Output:
%   SSGain - Small-signal single-pass gain [dimensionless].
%
% See also: simulateLaserDynamics, getDefaultConstants

    % Validate population vector size
    if numel(n_populations) ~= 4
        error('calculateGain:invalidInput', ...
            'n_populations must have exactly 4 elements. Got: %d', numel(n_populations));
    end

    % Unpack
    sigmaEmission   = constants.sigmaEmission;
    sigmaAbsorption = constants.sigmaAbsorption;
    ndop = constants.ndop;
    L    = constants.L;

    n2 = n_populations(2);
    n3 = n_populations(3);
    n4 = n_populations(4);

    % Gain coefficient [cm^-1]
    g0 = sigmaEmission * n2 - sigmaAbsorption * (ndop - n2 - n3 - n4);

    % Overflow protection for exp(g0 * L)
    exponent = g0 * L;
    MAX_EXPONENT = 700;  % exp(709) approaches realmax for double precision
    if exponent > MAX_EXPONENT
        Logger.warning('Gain exponent overflow: g0*L = %.3e. Clamping to exp(%d).', ...
            exponent, MAX_EXPONENT);
        exponent = MAX_EXPONENT;
    end

    SSGain = exp(exponent);

    if ~isfinite(SSGain)
        Logger.warning('Non-finite gain: SSGain=%g (g0=%.3e, L=%.2f)', SSGain, g0, L);
    end
end
