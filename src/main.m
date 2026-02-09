% main.m - Tm:YLF laser dynamics simulation.
%
% Loads experimental data, simulates gain for each pump power,
% and plots results against measurements.

clear; close all; clc;

addpath('config', 'functions', 'logging', 'visualization');

constants = getDefaultConstants();
config    = getSimulationConfig();

% Load experimental data
data = readtable(config.dataFile, 'Sheet', config.sheetName);

requiredCols = {'PumpPower_W_', 'Single_PassGain'};
for i = 1:numel(requiredCols)
    if ~ismember(requiredCols{i}, data.Properties.VariableNames)
        error('main:missingColumn', 'Missing column: %s', requiredCols{i});
    end
end

pumpPowers_W     = data.PumpPower_W_;
experimentalGain = data.Single_PassGain;
fprintf('Loaded %d data points from %s.\n', length(pumpPowers_W), config.dataFile);

% Simulate
simulatedGains = zeros(length(pumpPowers_W), 1);
for i = 1:length(pumpPowers_W)
    n_populations     = simulateLaserDynamics(pumpPowers_W(i), config.endTime, constants);
    simulatedGains(i) = calculateGain(n_populations, constants);
end
fprintf('Simulation complete.\n');

% Plot
configurePlotDefaults();
plotGainComparison(pumpPowers_W, simulatedGains, experimentalGain);

[t, n, ~] = simulateLaserDynamics(pumpPowers_W(end), config.endTime, constants);
plotPopulationDynamics(t, n, constants);

% Optional analyses (uncomment to run):
% plotConvergenceAnalysis(pumpPowers_W(6), constants);
% kcrRange = linspace(0.5, 2.0, 8) * constants.kcr;
% plotParameterSensitivity(pumpPowers_W, experimentalGain, constants, 'kcr', kcrRange);
