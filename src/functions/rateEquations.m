function dn_dt = rateEquations(~, n, Ip_W, constants)
% rateEquations Defines the coupled rate equations for a four-level Tm:YLF laser.
%
% Energy level diagram:
%   Level 4 (^3H_4) - Pump level, absorbs pump photons from level 1
%   Level 3 (^3H_5) - Intermediate, fed by ETU2 and branching from level 4
%   Level 2 (^3F_4) - Upper laser level, fed by cross-relaxation
%   Level 1 (^3H_6) - Ground state, initial population = ndop
%
% Physical processes modeled:
%   - Ground-state pump absorption: n1 -> n4        (rate: Re)
%   - Cross-relaxation:             n1 + n4 -> 2*n2 (rate: kcr * n1 * n4)
%   - ETU type 1:                   2*n2 -> n1 + n4 (rate: ketu1 * n2^2)
%   - ETU type 2:                   2*n2 -> n1 + n3 (rate: ketu2 * n2^2)
%   - Spontaneous decay from level i with lifetime tau_i and branching ratios beta_ij
%
% Conservation law: n1 + n2 + n3 + n4 = ndop (constant, enforced implicitly)
%
% Pump rate:
%   Re = sigmaPumpAbs * n1 * Ip_W * lambdaPump / (h * c)
%   where n1 = ndop - n2 - n3 - n4
%
% Inputs:
%   ~         - Time (unused, autonomous system).
%   n         - 4x1 column vector of current population densities [cm^-3].
%   Ip_W      - Pump power [W].
%   constants - Struct of physical constants (from getDefaultConstants).
%
% Output:
%   dn_dt - 4x1 column vector of time derivatives [cm^-3 / s].
%
% See also: simulateLaserDynamics, getDefaultConstants

    % Unpack populations
    n1 = n(1);
    n2 = n(2);
    n3 = n(3);
    n4 = n(4);

    % Unpack constants
    kcr          = constants.kcr;
    ketu1        = constants.ketu1;
    ketu2        = constants.ketu2;
    tau2         = constants.tau2;
    tau3         = constants.tau3;
    tau4         = constants.tau4;
    ndop         = constants.ndop;
    sigmaPumpAbs = constants.sigmaPumpAbs;
    lambdaPump   = constants.lambdaPump;
    h            = constants.h;
    c            = constants.c;
    beta43       = constants.beta43;
    beta42       = constants.beta42;
    beta32       = constants.beta32;

    % Derived branching ratios (probability conservation)
    beta41 = 1 - beta43 - beta42;
    beta31 = 1 - beta32;

    % Pump rate [cm^-3 / s]
    Re = (sigmaPumpAbs * (ndop - n2 - n3 - n4) * Ip_W * lambdaPump) / (h * c);

    % Rate equations [cm^-3 / s]
    dn1dt = -Re - kcr * n1 * n4 + (ketu1 + ketu2) * n2^2 ...
            + beta41 * n4 / tau4 + beta31 * n3 / tau3 + n2 / tau2;

    dn2dt = 2 * kcr * n1 * n4 - 2 * (ketu1 + ketu2) * n2^2 ...
            + beta32 * n3 / tau3 + beta42 * n4 / tau4 - n2 / tau2;

    dn3dt = ketu2 * n2^2 + beta43 * n4 / tau4 ...
            - (beta31 + beta32) * n3 / tau3;

    dn4dt = Re - kcr * n1 * n4 + ketu1 * n2^2 ...
            - (beta41 + beta42 + beta43) * n4 / tau4;

    dn_dt = [dn1dt; dn2dt; dn3dt; dn4dt];
end
