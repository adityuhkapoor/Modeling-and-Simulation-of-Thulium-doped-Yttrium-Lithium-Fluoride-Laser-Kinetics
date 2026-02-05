function n_populations = simulateLaserDynamics(Ip_W, endTime, constants)
% simulateLaserDynamics Simulates the Tm:YLF four-level laser population dynamics.
%
% Solves the coupled rate equations using MATLAB's ode45 (adaptive
% Runge-Kutta 4th/5th order) with non-negativity constraints on all
% population variables.
%
% Inputs:
%   Ip_W      - Pump power [W]. Must be finite and non-negative.
%   endTime   - Simulation end time [s]. Must be finite and positive.
%   constants - Struct of physical constants (from getDefaultConstants).
%
% Output:
%   n_populations - 1x4 row vector of population densities at t=endTime [cm^-3].
%                   Order: [n1, n2, n3, n4].
%
% Throws:
%   simulateLaserDynamics:solverFailed - If the ODE solver fails.
%
% See also: rateEquations, calculateGain, getDefaultConstants

    % Validate inputs
    validateInputs(Ip_W, endTime, constants);

    Logger.debug('Starting simulation: Ip_W=%.2f W, endTime=%.3e s', Ip_W, endTime);

    % Time span and initial conditions
    tspan = [0, endTime];
    n0 = [constants.ndop; 0; 0; 0];  % All ions in ground state

    % ODE solver options with non-negativity constraint
    options = odeset( ...
        'RelTol',      1e-6, ...
        'AbsTol',      1e-9, ...
        'NonNegative',  [1 2 3 4] ...
    );

    % Solve the rate equations
    try
        [~, n] = ode45(@(t, n) rateEquations(t, n, Ip_W, constants), tspan, n0, options);
    catch ME
        Logger.error('ODE solver failed for Ip_W=%.2f W: %s', Ip_W, ME.message);
        error('simulateLaserDynamics:solverFailed', ...
            'ODE45 failed for Ip_W=%.2f W: %s', Ip_W, ME.message);
    end

    % Extract final populations
    n_populations = n(end, :);

    % Post-solve sanity checks
    totalPop = sum(n_populations);
    conservationError = abs(totalPop - constants.ndop) / constants.ndop;
    if conservationError > 0.01
        Logger.warning('Population conservation violated: total=%.3e, ndop=%.3e (%.2f%% error)', ...
            totalPop, constants.ndop, conservationError * 100);
    end

    if any(n_populations < 0)
        Logger.warning('Negative populations detected: [%.3e, %.3e, %.3e, %.3e]. Clamping to zero.', ...
            n_populations(1), n_populations(2), n_populations(3), n_populations(4));
        n_populations = max(n_populations, 0);
    end

    Logger.debug('Simulation complete. Populations: [%.3e, %.3e, %.3e, %.3e]', ...
        n_populations(1), n_populations(2), n_populations(3), n_populations(4));
end
