% main.m - Entry point for the Tm:YLF laser dynamics simulation.
%
% Loads experimental data, runs the simulation for each pump power,
% compares simulated gains against experimental measurements, and
% generates visualization plots.

clear; close all; clc;

% Add paths
addpath('config');
addpath('functions');
addpath('logging');
addpath('visualization');

% Load configuration and constants
constants = getDefaultConstants();
config    = getSimulationConfig();

% Initialize logger
Logger.configure(config.logging.level, config.logging.toFile, config.logging.logFile);
Logger.info('LaserDynamicsSimulator started.');

% Load experimental data
try
    data = readtable(config.dataFile, 'Sheet', config.sheetName);
catch ME
    Logger.error('Failed to load data file "%s" (sheet: %s): %s', ...
        config.dataFile, config.sheetName, ME.message);
    error('main:dataLoadFailed', ...
        'Cannot read "%s" (sheet: %s): %s', ...
        config.dataFile, config.sheetName, ME.message);
end

% Validate expected columns
requiredCols = {'PumpPower_W_', 'Single_PassGain'};
for i = 1:numel(requiredCols)
    if ~ismember(requiredCols{i}, data.Properties.VariableNames)
        error('main:missingColumn', ...
            'Data file missing required column: %s', requiredCols{i});
    end
end

pumpPowers_W     = data.PumpPower_W_;
experimentalGain = data.Single_PassGain;
Logger.info('Loaded %d pump power data points from %s.', length(pumpPowers_W), config.dataFile);

% Run simulation for each pump power
simulatedGains = zeros(length(pumpPowers_W), 1);
for i = 1:length(pumpPowers_W)
    n_populations     = simulateLaserDynamics(pumpPowers_W(i), config.endTime, constants);
    simulatedGains(i) = calculateGain(n_populations, constants);
end
Logger.info('Simulation complete for all %d pump powers.', length(pumpPowers_W));

% --- Visualizations ---
configurePlotDefaults();

% 1. Gain comparison with residuals
plotGainComparison(pumpPowers_W, simulatedGains, experimentalGain);

% 2. Population dynamics for the highest pump power
[t, n, diag] = simulateLaserDynamicsFull(pumpPowers_W(end), config.endTime, constants);
plotPopulationDynamics(t, n, constants);

% --- Optional analyses (uncomment to run) ---

% 3. Convergence analysis
% plotConvergenceAnalysis(pumpPowers_W(6), constants);

% 4. Parameter sensitivity (example: sweep kcr)
% kcrRange = linspace(0.5, 2.0, 8) * constants.kcr;
% plotParameterSensitivity(pumpPowers_W, experimentalGain, constants, 'kcr', kcrRange);

% --- Optional: Parameter Optimization ---
% Uncomment to optimize parameters against experimental data.
% Requires Optimization Toolbox.
%
% experimentalData = struct( ...
%     'pumpPowers', pumpPowers_W, ...
%     'gains',      experimentalGain, ...
%     'endTime',    config.endTime ...
% );
% optimizedConstants = optimizeParameters(constants, experimentalData);
% Logger.info('Optimization complete. Rerunning with optimized constants...');
