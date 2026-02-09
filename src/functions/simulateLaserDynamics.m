function [out1, t_out, diagnostics] = simulateLaserDynamics(Ip_W, endTime, constants)
% simulateLaserDynamics Solves the Tm:YLF rate equations via ode45.
%
%   n_pop = simulateLaserDynamics(Ip_W, endTime, constants)
%       Returns 1x4 final populations [n1, n2, n3, n4].
%
%   [t, n, diag] = simulateLaserDynamics(Ip_W, endTime, constants)
%       Returns full time history and solver diagnostics.

    validateInputs(Ip_W, endTime, constants);

    tspan = [0, endTime];
    n0 = [constants.ndop; 0; 0; 0];

    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'NonNegative', [1 2 3 4]);

    [t, n] = ode45(@(t, n) rateEquations(t, n, Ip_W, constants), tspan, n0, options);

    n_final = n(end, :);

    % Clamp negative populations (solver artifacts)
    if any(n_final < 0)
        n_final = max(n_final, 0);
    end

    if nargout <= 1
        % Simple mode: return final populations only
        out1 = n_final;
    else
        % Full mode: return time history + diagnostics
        out1 = t;
        t_out = n;

        diagnostics = struct();
        diagnostics.totalPopulation = sum(n, 2);
        diagnostics.conservationError = abs(diagnostics.totalPopulation - constants.ndop) / constants.ndop;
        diagnostics.maxConservationError = max(diagnostics.conservationError);
        diagnostics.finalPopulations = n_final;

        nSteps = size(n, 1);
        nLast = max(1, ceil(0.1 * nSteps));
        if nSteps > nLast + 1
            relChange = max(abs(n(end, :) - n(end - nLast, :))) / max(abs(n(end, :)));
            diagnostics.steadyStateReached = relChange < 1e-3;
            diagnostics.relChangeLastDecile = relChange;
        else
            diagnostics.steadyStateReached = false;
            diagnostics.relChangeLastDecile = NaN;
        end
    end
end
