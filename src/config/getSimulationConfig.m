function config = getSimulationConfig()
% getSimulationConfig Returns simulation configuration parameters.
%
% Centralizes all configurable simulation settings: file paths, solver
% tolerances, logging options, and timing parameters.
%
% Output:
%   config - struct with fields:
%     endTime          - Simulation end time [s]
%     dataFile         - Path to experimental data file
%     sheetName        - Excel sheet name to read
%     solver           - ODE solver settings substruct
%       .relTol        - Relative tolerance for ODE solver
%       .absTol        - Absolute tolerance for ODE solver
%       .nonNegative   - Indices of state variables constrained >= 0
%     logging          - Logging settings substruct
%       .level         - Log level: 'debug', 'info', 'warning', 'error'
%       .toFile        - Whether to also log to file
%       .logFile       - Path to log file (if toFile is true)
%
% See also: getDefaultConstants, loadConfig

    config = struct();

    % Timing
    config.endTime   = 15e-3;  % 15 ms pump duration

    % Data source
    config.dataFile  = fullfile('..', 'data', 'Pump_Data.xlsx');
    config.sheetName = '15ms_Pump_Data';

    % ODE solver settings
    config.solver.relTol      = 1e-6;
    config.solver.absTol      = 1e-9;
    config.solver.nonNegative = [1 2 3 4];  % All population levels >= 0

    % Logging settings
    config.logging.level   = 'info';
    config.logging.toFile  = false;
    config.logging.logFile = 'simulation.log';
end
