function [constants, config] = loadConfig(jsonFilePath)
% loadConfig Loads configuration from a JSON file, merging with defaults.
%
% If no file is provided or the file does not exist, returns defaults.
% Fields in the JSON file override the corresponding default values.
% Unknown fields produce a warning and are ignored.
%
% Inputs:
%   jsonFilePath - (optional) Path to a JSON configuration file.
%
% Outputs:
%   constants - Physics constants struct (from getDefaultConstants, with overrides).
%   config    - Simulation config struct (from getSimulationConfig, with overrides).
%
% JSON file format:
%   {
%     "constants": { "kcr": 7.0e-19, "tau2": 0.015 },
%     "config": { "endTime": 0.020, "solver": { "relTol": 1e-8 } }
%   }
%
% See also: getDefaultConstants, getSimulationConfig

    constants = getDefaultConstants();
    config    = getSimulationConfig();

    if nargin < 1 || isempty(jsonFilePath)
        return;
    end

    if ~isfile(jsonFilePath)
        warning('loadConfig:fileNotFound', ...
            'Config file not found: %s. Using defaults.', jsonFilePath);
        return;
    end

    try
        raw = jsondecode(fileread(jsonFilePath));
    catch ME
        warning('loadConfig:parseError', ...
            'Failed to parse JSON config: %s. Using defaults.', ME.message);
        return;
    end

    % Merge constants overrides
    if isfield(raw, 'constants')
        fnames = fieldnames(raw.constants);
        for i = 1:numel(fnames)
            if isfield(constants, fnames{i})
                constants.(fnames{i}) = raw.constants.(fnames{i});
            else
                warning('loadConfig:unknownConstant', ...
                    'Unknown constant in config file: %s (ignored).', fnames{i});
            end
        end
    end

    % Merge top-level config overrides
    if isfield(raw, 'config')
        topFields = {'endTime', 'dataFile', 'sheetName'};
        for i = 1:numel(topFields)
            if isfield(raw.config, topFields{i})
                config.(topFields{i}) = raw.config.(topFields{i});
            end
        end

        % Merge solver sub-struct
        if isfield(raw.config, 'solver')
            solverFields = fieldnames(raw.config.solver);
            for i = 1:numel(solverFields)
                if isfield(config.solver, solverFields{i})
                    config.solver.(solverFields{i}) = raw.config.solver.(solverFields{i});
                else
                    warning('loadConfig:unknownSolverField', ...
                        'Unknown solver config: %s (ignored).', solverFields{i});
                end
            end
        end

        % Merge logging sub-struct
        if isfield(raw.config, 'logging')
            logFields = fieldnames(raw.config.logging);
            for i = 1:numel(logFields)
                if isfield(config.logging, logFields{i})
                    config.logging.(logFields{i}) = raw.config.logging.(logFields{i});
                else
                    warning('loadConfig:unknownLoggingField', ...
                        'Unknown logging config: %s (ignored).', logFields{i});
                end
            end
        end
    end
end
