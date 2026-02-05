function optimizedConstants = optimizeParameters(initialConstants, experimentalData)
% optimizeParameters Optimizes model parameters to fit experimental data.
%
% Uses MATLAB's lsqnonlin (Levenberg-Marquardt / trust-region-reflective)
% to minimize the sum of squared residuals between simulated and
% experimental single-pass gains.
%
% Optimized parameters: kcr, ketu1, ketu2, tau2, tau3, tau4.
% All other constants remain fixed at their initial values.
%
% Inputs:
%   initialConstants - Struct of initial physics constants (from getDefaultConstants).
%   experimentalData - Struct with fields:
%     .pumpPowers - Array of pump power values [W].
%     .gains      - Array of experimental gain values (same length as pumpPowers).
%     .endTime    - Simulation end time [s].
%
% Output:
%   optimizedConstants - Struct with optimized parameter values.
%
% Requires: Optimization Toolbox (lsqnonlin).
%
% See also: simulateLaserDynamics, calculateGain, getDefaultConstants

    % Validate experimentalData structure
    requiredFields = {'pumpPowers', 'gains', 'endTime'};
    for i = 1:numel(requiredFields)
        if ~isfield(experimentalData, requiredFields{i})
            error('optimizeParameters:missingField', ...
                'experimentalData missing required field: %s', requiredFields{i});
        end
    end
    if isempty(experimentalData.pumpPowers) || isempty(experimentalData.gains)
        error('optimizeParameters:emptyData', 'experimentalData contains empty arrays.');
    end
    if numel(experimentalData.pumpPowers) ~= numel(experimentalData.gains)
        error('optimizeParameters:sizeMismatch', ...
            'pumpPowers (%d) and gains (%d) must have the same length.', ...
            numel(experimentalData.pumpPowers), numel(experimentalData.gains));
    end

    % Parameters to optimize
    paramNames = {'kcr', 'ketu1', 'ketu2', 'tau2', 'tau3', 'tau4'};

    % Extract initial values
    initialValues = cellfun(@(name) initialConstants.(name), paramNames);

    % Physical lower bounds (all must be positive)
    lowerBounds = initialValues * 0.01;   % 1% of initial
    upperBounds = initialValues * 100;    % 100x initial

    Logger.info('Starting parameter optimization with %d data points.', ...
        numel(experimentalData.pumpPowers));
    Logger.info('Optimizing: %s', strjoin(paramNames, ', '));

    % Objective function: returns residual vector
    objectiveFunc = @(params) computeResiduals(params, paramNames, initialConstants, experimentalData);

    % Optimization options
    options = optimoptions('lsqnonlin', ...
        'Display',       'iter', ...
        'TolFun',        1e-6, ...
        'TolX',          1e-8, ...
        'MaxIterations',  200, ...
        'MaxFunctionEvaluations', 1000 ...
    );

    % Run optimizer with bounds
    try
        [optimizedValues, resnorm, residuals, exitflag, output] = ...
            lsqnonlin(objectiveFunc, initialValues, lowerBounds, upperBounds, options);
    catch ME
        Logger.error('Optimization failed: %s', ME.message);
        error('optimizeParameters:optimizationFailed', ...
            'lsqnonlin failed: %s', ME.message);
    end

    % Log results
    Logger.info('Optimization finished. Exit flag: %d, Residual norm: %.6e', exitflag, resnorm);
    for i = 1:numel(paramNames)
        Logger.info('  %s: %.6e -> %.6e (%.1f%% change)', ...
            paramNames{i}, initialValues(i), optimizedValues(i), ...
            (optimizedValues(i) - initialValues(i)) / initialValues(i) * 100);
    end

    if exitflag <= 0
        Logger.warning('Optimizer did not converge (exit flag: %d). Results may be unreliable.', exitflag);
    end

    % Build output struct
    optimizedConstants = initialConstants;
    for i = 1:numel(paramNames)
        optimizedConstants.(paramNames{i}) = optimizedValues(i);
    end
end


function residuals = computeResiduals(params, paramNames, constants, experimentalData)
% computeResiduals Calculates residuals between simulated and experimental gains.

    % Update constants with current parameter values
    for i = 1:numel(paramNames)
        constants.(paramNames{i}) = params(i);
    end

    % Simulate gains for all pump powers
    nPoints = numel(experimentalData.pumpPowers);
    simulatedGains = zeros(nPoints, 1);
    for i = 1:nPoints
        n_populations = simulateLaserDynamics(experimentalData.pumpPowers(i), ...
            experimentalData.endTime, constants);
        simulatedGains(i) = calculateGain(n_populations, constants);
    end

    % Residual vector (lsqnonlin minimizes sum of squares)
    residuals = simulatedGains - experimentalData.gains(:);
end
