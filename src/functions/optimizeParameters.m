function optimizedConstants = optimizeParameters(initialConstants, experimentalData)
% optimizeParameters Optimizes model parameters to fit experimental data.
%
% Inputs:
%   initialConstants - Structure of initial constants.
%   experimentalData - Structure containing experimental pump powers and gains.
%
% Output:
%   optimizedConstants - Structure of optimized constants.

% Define parameters to optimize
paramNames = {'kcr', 'ketu1', 'ketu2', 'tau2', 'tau3', 'tau4'};

% Extract initial values
initialValues = cellfun(@(name) initialConstants.(name), paramNames);

% Objective function
objectiveFunc = @(params) meritFunction(params, paramNames, initialConstants, experimentalData);

% Optimization options
options = optimoptions('lsqnonlin', 'Display', 'iter', 'TolFun', 1e-6);

% Perform optimization
[optimizedValues, ~] = lsqnonlin(objectiveFunc, initialValues, [], [], options);

% Update constants with optimized values
optimizedConstants = initialConstants;
for i = 1:length(paramNames)
    optimizedConstants.(paramNames{i}) = optimizedValues(i);
end
end

function residuals = meritFunction(params, paramNames, constants, experimentalData)
% meritFunction Calculates residuals between simulated and experimental gains.

% Update constants with current parameters
for i = 1:length(paramNames)
    constants.(paramNames{i}) = params(i);
end

% Simulate gains
simulatedGains = zeros(length(experimentalData.pumpPowers), 1);
for i = 1:length(experimentalData.pumpPowers)
    n_populations = simulateLaserDynamics(experimentalData.pumpPowers(i), experimentalData.endTime, constants);
    simulatedGains(i) = calculateGain(n_populations, constants);
end

% Calculate residuals
residuals = simulatedGains - experimentalData.gains;
end
