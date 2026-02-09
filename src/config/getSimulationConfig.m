function config = getSimulationConfig()
% getSimulationConfig Solver settings, file paths, and logging options.

    config = struct();

    config.endTime   = 15e-3;  % 15 ms pump duration
    config.dataFile  = fullfile('..', 'data', 'Pump_Data.xlsx');
    config.sheetName = '15ms_Pump_Data';

    config.solver.relTol      = 1e-6;
    config.solver.absTol      = 1e-9;
    config.solver.nonNegative = [1 2 3 4];

    config.logging.level   = 'info';
    config.logging.toFile  = false;
    config.logging.logFile = 'simulation.log';
end
