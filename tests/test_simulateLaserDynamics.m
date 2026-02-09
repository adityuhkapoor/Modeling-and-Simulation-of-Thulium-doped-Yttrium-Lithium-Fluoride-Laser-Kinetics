% test_simulateLaserDynamics.m - Unit tests for simulateLaserDynamics.

function tests = test_simulateLaserDynamics
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'logging'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    testCase.TestData.constants = getTestConstants();
end

function testOutputShape(testCase)
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(10000, 15e-3, c);
    verifySize(testCase, n_pop, [1, 4]);
end

function testPopulationConservation(testCase)
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(10000, 15e-3, c);
    verifyEqual(testCase, sum(n_pop), c.ndop, 'RelTol', 1e-4);
end

function testNonNegativePopulations(testCase)
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(10000, 15e-3, c);
    verifyGreaterThanOrEqual(testCase, n_pop, zeros(1, 4));
end

function testZeroPumpPower(testCase)
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(0, 15e-3, c);
    expectedPop = [c.ndop, 0, 0, 0];
    verifyEqual(testCase, n_pop, expectedPop, 'AbsTol', 1e10);
end

function testShortTime(testCase)
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(10000, 1e-9, c);
    verifyEqual(testCase, n_pop(1), c.ndop, 'RelTol', 1e-3);
end

function testPumpingIncreasesUpperLevels(testCase)
    c = testCase.TestData.constants;
    n_pop = simulateLaserDynamics(10000, 15e-3, c);
    verifyGreaterThan(testCase, n_pop(2), 0);
end

function testHigherPumpGivesMoreInversion(testCase)
    c = testCase.TestData.constants;
    n_low  = simulateLaserDynamics(1000,  15e-3, c);
    n_high = simulateLaserDynamics(15000, 15e-3, c);
    verifyGreaterThan(testCase, n_high(2), n_low(2));
end
