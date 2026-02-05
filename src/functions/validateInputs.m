function validateInputs(Ip_W, endTime, constants)
% validateInputs Validates all inputs to the laser dynamics simulation.
%
% Throws descriptive errors if any input is invalid or physically
% unreasonable. Call this at the entry of any simulation function.
%
% Inputs:
%   Ip_W      - Pump power [W]. Must be finite and non-negative.
%   endTime   - Simulation end time [s]. Must be finite and positive.
%   constants - Struct of physical constants (from getDefaultConstants).
%
% Throws:
%   validateInputs:invalidPumpPower   - If Ip_W is not a finite non-negative scalar.
%   validateInputs:invalidEndTime     - If endTime is not a finite positive scalar.
%   validateInputs:missingField       - If constants struct is missing a required field.
%   validateInputs:invalidConstant    - If a constant has an unphysical value.
%   validateInputs:invalidBranching   - If branching ratios violate probability constraints.
%
% See also: getDefaultConstants, simulateLaserDynamics

    % --- Pump power ---
    if ~isscalar(Ip_W) || ~isnumeric(Ip_W) || ~isfinite(Ip_W) || Ip_W < 0
        error('validateInputs:invalidPumpPower', ...
            'Ip_W must be a finite non-negative scalar. Got: %s', mat2str(Ip_W));
    end

    % --- End time ---
    if ~isscalar(endTime) || ~isnumeric(endTime) || ~isfinite(endTime) || endTime <= 0
        error('validateInputs:invalidEndTime', ...
            'endTime must be a finite positive scalar. Got: %s', mat2str(endTime));
    end

    % --- Constants struct completeness ---
    requiredFields = { ...
        'kcr', 'ketu1', 'ketu2', 'tau2', 'tau3', 'tau4', ...
        'ndop', 'sigmaEmission', 'sigmaAbsorption', ...
        'sigmaPumpAbs', 'lambdaPump', 'h', 'c', ...
        'beta43', 'beta42', 'beta32', 'L' ...
    };
    for i = 1:numel(requiredFields)
        if ~isfield(constants, requiredFields{i})
            error('validateInputs:missingField', ...
                'Constants struct missing required field: %s', requiredFields{i});
        end
    end

    % --- Strictly positive constants ---
    positiveFields = { ...
        'kcr', 'ketu1', 'ketu2', 'tau2', 'tau3', 'tau4', ...
        'ndop', 'sigmaEmission', 'sigmaPumpAbs', ...
        'lambdaPump', 'h', 'c', 'L' ...
    };
    for i = 1:numel(positiveFields)
        val = constants.(positiveFields{i});
        if ~isfinite(val) || val <= 0
            error('validateInputs:invalidConstant', ...
                'Constant "%s" must be finite and positive. Got: %g', ...
                positiveFields{i}, val);
        end
    end

    % --- Non-negative constants (can be zero) ---
    if ~isfinite(constants.sigmaAbsorption) || constants.sigmaAbsorption < 0
        error('validateInputs:invalidConstant', ...
            'sigmaAbsorption must be finite and non-negative. Got: %g', ...
            constants.sigmaAbsorption);
    end

    % --- Branching ratio constraints ---
    beta4_sum = constants.beta43 + constants.beta42;
    if beta4_sum > 1
        error('validateInputs:invalidBranching', ...
            'beta43 + beta42 must be <= 1 (probability). Got: %g', beta4_sum);
    end
    if constants.beta32 > 1
        error('validateInputs:invalidBranching', ...
            'beta32 must be <= 1 (probability). Got: %g', constants.beta32);
    end
    if constants.beta43 < 0 || constants.beta42 < 0 || constants.beta32 < 0
        error('validateInputs:invalidBranching', ...
            'Branching ratios must be non-negative.');
    end
end
