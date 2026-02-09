% test_validateInputs.m - Unit tests for validateInputs.

function tests = test_validateInputs
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    testCase.TestData.constants = getTestConstants();
end

function testValidInputsNoError(testCase)
    c = testCase.TestData.constants;
    validateInputs(10000, 15e-3, c);
    verifyTrue(testCase, true);
end

function testZeroPumpPowerValid(testCase)
    c = testCase.TestData.constants;
    validateInputs(0, 15e-3, c);
    verifyTrue(testCase, true);
end

function testNegativePumpPowerInvalid(testCase)
    c = testCase.TestData.constants;
    verifyError(testCase, @() validateInputs(-100, 15e-3, c), 'validateInputs:invalidPumpPower');
end

function testInfPumpPowerInvalid(testCase)
    c = testCase.TestData.constants;
    verifyError(testCase, @() validateInputs(Inf, 15e-3, c), 'validateInputs:invalidPumpPower');
end

function testNaNPumpPowerInvalid(testCase)
    c = testCase.TestData.constants;
    verifyError(testCase, @() validateInputs(NaN, 15e-3, c), 'validateInputs:invalidPumpPower');
end

function testZeroEndTimeInvalid(testCase)
    c = testCase.TestData.constants;
    verifyError(testCase, @() validateInputs(10000, 0, c), 'validateInputs:invalidEndTime');
end

function testNegativeEndTimeInvalid(testCase)
    c = testCase.TestData.constants;
    verifyError(testCase, @() validateInputs(10000, -1, c), 'validateInputs:invalidEndTime');
end

function testMissingConstantField(testCase)
    c = testCase.TestData.constants;
    c = rmfield(c, 'kcr');
    verifyError(testCase, @() validateInputs(10000, 15e-3, c), 'validateInputs:missingField');
end

function testNegativeConstantInvalid(testCase)
    c = testCase.TestData.constants;
    c.tau2 = -0.001;
    verifyError(testCase, @() validateInputs(10000, 15e-3, c), 'validateInputs:invalidConstant');
end

function testBranchingRatioExceedsOne(testCase)
    c = testCase.TestData.constants;
    c.beta43 = 0.8;
    c.beta42 = 0.5;
    verifyError(testCase, @() validateInputs(10000, 15e-3, c), 'validateInputs:invalidBranching');
end

function testNegativeBranchingRatio(testCase)
    c = testCase.TestData.constants;
    c.beta32 = -0.1;
    verifyError(testCase, @() validateInputs(10000, 15e-3, c), 'validateInputs:invalidBranching');
end
