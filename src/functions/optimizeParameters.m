function optimizedConstants = optimizeParameters(initialConstants, experimentalData)
% optimizeParameters Fits kcr, ketu1, ketu2, tau2, tau3, tau4 to experimental gain data.
%
% Uses lsqnonlin to minimize squared residuals between simulated and measured gains.

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

    paramNames = {'kcr', 'ketu1', 'ketu2', 'tau2', 'tau3', 'tau4'};
    initialValues = cellfun(@(name) initialConstants.(name), paramNames);
    lowerBounds = initialValues * 0.01;
    upperBounds = initialValues * 100;

    fprintf('Optimizing %s against %d data points...\n', ...
        strjoin(paramNames, ', '), numel(experimentalData.pumpPowers));

    objectiveFunc = @(params) computeResiduals(params, paramNames, initialConstants, experimentalData);

    options = optimoptions('lsqnonlin', ...
        'Display',       'iter', ...
        'TolFun',        1e-6, ...
        'TolX',          1e-8, ...
        'MaxIterations',  200, ...
        'MaxFunctionEvaluations', 1000 ...
    );

    [optimizedValues, resnorm, ~, exitflag] = ...
        lsqnonlin(objectiveFunc, initialValues, lowerBounds, upperBounds, options);

    fprintf('Done. Exit flag: %d, residual norm: %.6e\n', exitflag, resnorm);
    for i = 1:numel(paramNames)
        fprintf('  %s: %.6e -> %.6e (%.1f%%)\n', ...
            paramNames{i}, initialValues(i), optimizedValues(i), ...
            (optimizedValues(i) - initialValues(i)) / initialValues(i) * 100);
    end

    if exitflag <= 0
        warning('optimizeParameters:noConvergence', ...
            'Optimizer did not converge (exit flag: %d).', exitflag);
    end

    optimizedConstants = initialConstants;
    for i = 1:numel(paramNames)
        optimizedConstants.(paramNames{i}) = optimizedValues(i);
    end
end


function residuals = computeResiduals(params, paramNames, constants, experimentalData)
    for i = 1:numel(paramNames)
        constants.(paramNames{i}) = params(i);
    end

    nPoints = numel(experimentalData.pumpPowers);
    simulatedGains = zeros(nPoints, 1);
    for i = 1:nPoints
        n_populations = simulateLaserDynamics(experimentalData.pumpPowers(i), ...
            experimentalData.endTime, constants);
        simulatedGains(i) = calculateGain(n_populations, constants);
    end

    residuals = simulatedGains - experimentalData.gains(:);
end
