function [t, n, diagnostics] = simulateLaserDynamicsFull(Ip_W, endTime, constants)
% simulateLaserDynamicsFull Runs the simulation and returns full time history.
%
% Unlike simulateLaserDynamics (which returns only the final state), this
% function returns the complete time evolution and solver diagnostics.
% Use this for visualization, convergence analysis, and debugging.
%
% Inputs:
%   Ip_W      - Pump power [W]. Must be finite and non-negative.
%   endTime   - Simulation end time [s]. Must be finite and positive.
%   constants - Struct of physical constants (from getDefaultConstants).
%
% Outputs:
%   t           - Time vector [Nx1] in seconds.
%   n           - Population matrix [Nx4], columns: [n1, n2, n3, n4] in cm^-3.
%   diagnostics - Struct with solver and convergence information:
%     .totalPopulation       - Total population at each time step [Nx1].
%     .conservationError     - Relative conservation error at each step [Nx1].
%     .maxConservationError  - Peak conservation error over entire run.
%     .steadyStateReached    - Boolean, true if populations converged.
%     .relChangeLastDecile   - Relative change in last 10% of time points.
%     .finalPopulations      - Population densities at t=endTime [1x4].
%
% See also: simulateLaserDynamics, rateEquations, plotPopulationDynamics

    % Validate inputs
    validateInputs(Ip_W, endTime, constants);

    Logger.info('Running full simulation: Ip_W=%.2f W, endTime=%.3e s', Ip_W, endTime);

    % Time span and initial conditions
    tspan = [0, endTime];
    n0 = [constants.ndop; 0; 0; 0];

    % ODE solver options
    options = odeset( ...
        'RelTol',      1e-6, ...
        'AbsTol',      1e-9, ...
        'NonNegative', [1 2 3 4] ...
    );

    % Solve
    try
        [t, n] = ode45(@(t, n) rateEquations(t, n, Ip_W, constants), tspan, n0, options);
    catch ME
        Logger.error('ODE solver failed: %s', ME.message);
        rethrow(ME);
    end

    % Build diagnostics
    diagnostics = struct();
    diagnostics.totalPopulation      = sum(n, 2);
    diagnostics.conservationError    = abs(diagnostics.totalPopulation - constants.ndop) / constants.ndop;
    diagnostics.maxConservationError = max(diagnostics.conservationError);
    diagnostics.finalPopulations     = n(end, :);

    % Check steady-state convergence (last 10% of time points)
    nSteps = size(n, 1);
    nLast  = max(1, ceil(0.1 * nSteps));
    if nSteps > nLast + 1
        relChange = max(abs(n(end, :) - n(end - nLast, :))) / max(abs(n(end, :)));
        diagnostics.steadyStateReached  = relChange < 1e-3;
        diagnostics.relChangeLastDecile = relChange;
    else
        diagnostics.steadyStateReached  = false;
        diagnostics.relChangeLastDecile = NaN;
    end

    % Log diagnostics
    if diagnostics.maxConservationError > 1e-6
        Logger.warning('Max conservation error: %.3e', diagnostics.maxConservationError);
    end
    if ~diagnostics.steadyStateReached
        Logger.warning('Steady state may not be reached (relative change in last 10%%: %.3e).', ...
            diagnostics.relChangeLastDecile);
    end

    Logger.info('Full simulation complete. %d time steps, max conservation error: %.3e', ...
        nSteps, diagnostics.maxConservationError);
end
