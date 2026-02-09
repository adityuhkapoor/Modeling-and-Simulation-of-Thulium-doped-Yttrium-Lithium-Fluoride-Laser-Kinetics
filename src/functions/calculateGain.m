function SSGain = calculateGain(n_populations, constants)
% calculateGain Small-signal single-pass gain from population densities.
%
% g0 = sigmaEmission*n2 - sigmaAbsorption*n1, SSGain = exp(g0*L).

    if numel(n_populations) ~= 4
        error('calculateGain:invalidInput', ...
            'n_populations must have exactly 4 elements. Got: %d', numel(n_populations));
    end

    n2 = n_populations(2);
    n3 = n_populations(3);
    n4 = n_populations(4);
    n1 = constants.ndop - n2 - n3 - n4;

    g0 = constants.sigmaEmission * n2 - constants.sigmaAbsorption * n1;

    exponent = g0 * constants.L;
    if exponent > 700
        exponent = 700;  % prevent overflow
    end

    SSGain = exp(exponent);
end
