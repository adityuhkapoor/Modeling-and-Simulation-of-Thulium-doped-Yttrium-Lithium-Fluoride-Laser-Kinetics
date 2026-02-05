% test_calculateGain.m - Unit tests for the calculateGain function.

function tests = test_calculateGain
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'logging'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    Logger.configure('error');  % Suppress log noise during tests
    testCase.TestData.constants = getTestConstants();
end

function testGainWithKnownPopulations(testCase)
% Verify gain formula: g0 = sigmaE * n2 - sigmaA * (ndop - n2 - n3 - n4)
    c = testCase.TestData.constants;
    n_pop = [8.299e20, 1e18, 0, 0];
    expected_g0 = c.sigmaEmission * n_pop(2) - c.sigmaAbsorption * (c.ndop - n_pop(2) - n_pop(3) - n_pop(4));
    expectedGain = exp(expected_g0 * c.L);
    actualGain = calculateGain(n_pop, c);
    verifyEqual(testCase, actualGain, expectedGain, 'AbsTol', 1e-10);
end

function testZeroPopulationInversion(testCase)
% All ions in ground state -> gain < 1 (pure absorption)
    c = testCase.TestData.constants;
    n_pop = [c.ndop, 0, 0, 0];
    gain = calculateGain(n_pop, c);
    % g0 = 0 - sigmaAbsorption * ndop < 0, so exp(g0*L) < 1
    verifyLessThan(testCase, gain, 1.0);
    verifyGreaterThan(testCase, gain, 0.0);
end

function testTransparencyCondition(testCase)
% When g0 = 0, SSGain should equal 1.0.
% g0 = sigmaE * n2 - sigmaA * n1 = 0  =>  n2 = sigmaA * n1 / sigmaE
    c = testCase.TestData.constants;
    % Set n3=n4=0, then n1 = ndop - n2
    % sigmaE * n2 = sigmaA * (ndop - n2)
    % n2 * (sigmaE + sigmaA) = sigmaA * ndop
    n2_transparency = c.sigmaAbsorption * c.ndop / (c.sigmaEmission + c.sigmaAbsorption);
    n_pop = [c.ndop - n2_transparency, n2_transparency, 0, 0];
    gain = calculateGain(n_pop, c);
    verifyEqual(testCase, gain, 1.0, 'AbsTol', 1e-10);
end

function testGainPositive(testCase)
% Gain should always be positive (exp of any real number is positive)
    c = testCase.TestData.constants;
    n_pop = [8.0e20, 3.0e19, 1.0e18, 5.0e17];
    gain = calculateGain(n_pop, c);
    verifyGreaterThan(testCase, gain, 0);
    verifyTrue(testCase, isfinite(gain));
end

function testInvalidPopulationSize(testCase)
% Passing wrong number of elements should throw an error
    c = testCase.TestData.constants;
    verifyError(testCase, @() calculateGain([1, 2, 3], c), 'calculateGain:invalidInput');
    verifyError(testCase, @() calculateGain([1, 2, 3, 4, 5], c), 'calculateGain:invalidInput');
end
