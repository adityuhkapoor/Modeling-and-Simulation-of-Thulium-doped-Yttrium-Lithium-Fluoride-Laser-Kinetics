% test_integration.m - End-to-end pipeline tests.

function tests = test_integration
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'logging'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    testCase.TestData.constants = getTestConstants();
end

function testFullPipelineProducesFiniteGains(testCase)
    c = testCase.TestData.constants;
    pumpPowers = [100, 1000, 5000, 10000, 15000];
    gains = zeros(size(pumpPowers));
    for i = 1:numel(pumpPowers)
        n_pop = simulateLaserDynamics(pumpPowers(i), 15e-3, c);
        gains(i) = calculateGain(n_pop, c);
    end
    verifyTrue(testCase, all(isfinite(gains)));
    verifyGreaterThan(testCase, gains, zeros(size(gains)));
end

function testGainMonotonicallyIncreases(testCase)
    c = testCase.TestData.constants;
    pumpPowers = [500, 2000, 5000, 10000, 15000];
    gains = zeros(size(pumpPowers));
    for i = 1:numel(pumpPowers)
        n_pop = simulateLaserDynamics(pumpPowers(i), 15e-3, c);
        gains(i) = calculateGain(n_pop, c);
    end
    for i = 2:numel(gains)
        verifyGreaterThanOrEqual(testCase, gains(i), gains(i-1));
    end
end

function testFullSimulationDiagnostics(testCase)
    c = testCase.TestData.constants;
    [t, n, diag] = simulateLaserDynamics(10000, 15e-3, c);
    verifyGreaterThan(testCase, numel(t), 1);
    verifySize(testCase, n, [numel(t), 4]);
    verifyLessThan(testCase, diag.maxConservationError, 1e-4);
    verifyTrue(testCase, all(isfinite(n(:))));
end

function testConfigModulesReturnValidStructs(testCase)
    c = getDefaultConstants();
    cfg = getSimulationConfig();
    verifyTrue(testCase, isstruct(c));
    verifyTrue(testCase, isstruct(cfg));
    verifyTrue(testCase, isfield(c, 'kcr'));
    verifyTrue(testCase, isfield(c, 'L'));
    verifyTrue(testCase, isfield(cfg, 'endTime'));
    verifyTrue(testCase, isfield(cfg, 'solver'));
end
