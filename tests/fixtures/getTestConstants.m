function constants = getTestConstants()
% getTestConstants Delegates to getDefaultConstants for test consistency.

    srcConfig = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src', 'config');
    addpath(srcConfig);
    constants = getDefaultConstants();
end
