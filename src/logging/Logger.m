classdef Logger
% Simple console logging.

    methods (Static)
        function configure(~, ~, ~), end

        function debug(~, varargin), end

        function info(msg, varargin)
            fprintf([msg '\n'], varargin{:});
        end

        function warning(msg, varargin)
            fprintf(2, ['Warning: ' msg '\n'], varargin{:});
        end

        function error(msg, varargin)
            fprintf(2, ['Error: ' msg '\n'], varargin{:});
        end
    end
end
