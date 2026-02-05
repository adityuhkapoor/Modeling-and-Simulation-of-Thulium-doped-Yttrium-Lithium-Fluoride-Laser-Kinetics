function constants = getTestConstants()
% getTestConstants Returns the canonical constants struct for testing.
%
% Delegates to getDefaultConstants to ensure tests always use the same
% values as production code. Never define constants directly in tests.
%
% Output:
%   constants - Struct of physical constants (same as getDefaultConstants).
%
% See also: getDefaultConstants

    % Ensure the config path is accessible
    srcConfig = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src', 'config');
    addpath(srcConfig);

    constants = getDefaultConstants();
end
