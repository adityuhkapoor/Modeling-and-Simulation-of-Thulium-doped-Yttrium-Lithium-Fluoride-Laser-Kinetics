% test_numericalStability.m - Tests for numerical edge cases and stability.

function tests = test_numericalStability
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'logging'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    Logger.configure('error');
    testCase.TestData.constants = getTestConstants();
end

function testExtremePumpPower(testCase)
% Very high pump power should still produce finite results.
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(1e6, 15e-3, c);
    verifyTrue(testCase, all(isfinite(n_pop)));
    verifyGreaterThanOrEqual(testCase, n_pop, zeros(1, 4));
end

function testGainOverflowProtection(testCase)
% Construct populations that would cause exp(g0*L) overflow.
% Large n2 -> large positive g0 -> overflow without clamping.
    c = testCase.TestData.constants;
    n_pop = [0, c.ndop, 0, 0];  % All ions in n2 (extreme inversion)
    gain = calculateGain(n_pop, c);
    verifyTrue(testCase, isfinite(gain));
    verifyGreaterThan(testCase, gain, 1.0);
end

function testNearZeroPopulations(testCase)
% Tiny populations should not produce NaN in gain calculation.
    c = testCase.TestData.constants;
    n_pop = [c.ndop, 1e-30, 0, 0];
    gain = calculateGain(n_pop, c);
    verifyTrue(testCase, isfinite(gain));
end

function testPopulationConservationUnderStress(testCase)
% Conservation should hold even with high pump power.
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(1e5, 15e-3, c);
    verifyEqual(testCase, sum(n_pop), c.ndop, 'RelTol', 1e-3);
end

function testVeryLongSimulation(testCase)
% 100 ms simulation should converge to steady state.
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(10000, 100e-3, c);
    verifyTrue(testCase, all(isfinite(n_pop)));
    verifyEqual(testCase, sum(n_pop), c.ndop, 'RelTol', 1e-3);
end
