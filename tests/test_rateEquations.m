% test_rateEquations.m - Unit tests for rateEquations.

function tests = test_rateEquations
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    testCase.TestData.constants = getTestConstants();
end

function testPopulationConservation(testCase)
    c = testCase.TestData.constants;
    n = [7e20; 1e20; 3e18; 2e18];
    dn_dt = rateEquations(0, n, 10000, c);
    verifyEqual(testCase, sum(dn_dt), 0, 'AbsTol', 1e5);
end

function testEquilibriumNoPump(testCase)
    c = testCase.TestData.constants;
    n = [c.ndop; 0; 0; 0];
    dn_dt = rateEquations(0, n, 0, c);
    verifyEqual(testCase, dn_dt, zeros(4, 1), 'AbsTol', 1e5);
end

function testPumpingDirections(testCase)
    c = testCase.TestData.constants;
    n = [c.ndop; 0; 0; 0];
    dn_dt = rateEquations(0, n, 10000, c);
    verifyLessThan(testCase, dn_dt(1), 0);
    verifyGreaterThan(testCase, dn_dt(4), 0);
end

function testOutputShape(testCase)
    c = testCase.TestData.constants;
    n = [c.ndop; 0; 0; 0];
    dn_dt = rateEquations(0, n, 10000, c);
    verifySize(testCase, dn_dt, [4, 1]);
end

function testConservationWithArbitraryState(testCase)
    c = testCase.TestData.constants;
    n = [4e20; 2e20; 1.5e20; 0.8e20];
    dn_dt = rateEquations(0, n, 5000, c);
    verifyEqual(testCase, sum(dn_dt), 0, 'AbsTol', 1e5);
end
