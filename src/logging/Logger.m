classdef Logger
% Logger Simple logging utility for the LaserDynamicsSimulator.
%
% Provides leveled logging (debug, info, warning, error) to the console
% and optionally to a file. Each message is timestamped.
%
% Usage:
%   Logger.configure('info');                          % Console only
%   Logger.configure('debug', true, 'simulation.log'); % Console + file
%   Logger.info('Pump power: %.2f W', Ip_W);
%   Logger.warning('Population exceeded ndop');
%   Logger.error('ODE solver failed: %s', ME.message);
%
% Log levels (lowest to highest):
%   debug < info < warning < error
%
% See also: getSimulationConfig

    methods (Static)
        function configure(level, toFile, logFile)
        % configure Sets up the logger. Call once at startup.
        %
        % Inputs:
        %   level  - Minimum log level: 'debug', 'info', 'warning', 'error'
        %   toFile - (optional) Boolean, write to file. Default: false.
        %   logFile - (optional) Path to log file. Default: 'simulation.log'.

            if nargin < 2, toFile  = false;           end
            if nargin < 3, logFile = 'simulation.log'; end

            state = Logger.getState();
            state.level   = Logger.levelToInt(level);
            state.toFile  = toFile;
            state.logFile = logFile;
            Logger.setState(state);
        end

        function debug(msg, varargin)
        % debug Logs a debug-level message.
            Logger.log(0, 'DEBUG', msg, varargin{:});
        end

        function info(msg, varargin)
        % info Logs an info-level message.
            Logger.log(1, 'INFO', msg, varargin{:});
        end

        function warning(msg, varargin)
        % warning Logs a warning-level message (does NOT throw).
            Logger.log(2, 'WARNING', msg, varargin{:});
        end

        function error(msg, varargin)
        % error Logs an error-level message (does NOT throw).
        %   Use MATLAB's built-in error() to throw exceptions.
            Logger.log(3, 'ERROR', msg, varargin{:});
        end
    end

    methods (Static, Access = private)
        function log(levelInt, levelStr, msg, varargin)
        % log Internal method that formats and writes the log entry.
            state = Logger.getState();
            if levelInt < state.level
                return;
            end

            if ~isempty(varargin)
                msg = sprintf(msg, varargin{:});
            end

            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            entry = sprintf('[%s] [%-7s] %s\n', timestamp, levelStr, msg);

            % Write to stderr so it does not interfere with data output
            fprintf(2, '%s', entry);

            % Optionally write to file
            if state.toFile
                try
                    fid = fopen(state.logFile, 'a');
                    if fid ~= -1
                        fprintf(fid, '%s', entry);
                        fclose(fid);
                    end
                catch
                    % Silently ignore file write failures to avoid
                    % disrupting the simulation.
                end
            end
        end

        function state = getState()
        % getState Returns the persistent logger state.
            persistent loggerState;
            if isempty(loggerState)
                loggerState = struct( ...
                    'level',   1, ...           % Default: info
                    'toFile',  false, ...
                    'logFile', 'simulation.log' ...
                );
            end
            state = loggerState;
        end

        function setState(state)
        % setState Stores the persistent logger state.
            persistent loggerState;
            loggerState = state;
        end

        function lvl = levelToInt(levelStr)
        % levelToInt Converts a level string to its integer value.
            switch lower(levelStr)
                case 'debug',   lvl = 0;
                case 'info',    lvl = 1;
                case 'warning', lvl = 2;
                case 'error',   lvl = 3;
                otherwise
                    lvl = 1;  % Default to info
                    fprintf(2, '[Logger] Unknown log level "%s", defaulting to info.\n', levelStr);
            end
        end
    end
end
