% test_rateEquations.m - Unit tests for the rateEquations function.

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
% Sum of all rate equations should be zero (conservation law).
% d(n1+n2+n3+n4)/dt = 0 for any population state.
    c = testCase.TestData.constants;
    n = [7e20; 1e20; 3e18; 2e18];
    dn_dt = rateEquations(0, n, 10000, c);
    verifyEqual(testCase, sum(dn_dt), 0, 'AbsTol', 1e5);
end

function testEquilibriumNoPump(testCase)
% With zero pump and all ions in ground state, all derivatives should be zero.
    c = testCase.TestData.constants;
    n = [c.ndop; 0; 0; 0];
    dn_dt = rateEquations(0, n, 0, c);
    verifyEqual(testCase, dn_dt, zeros(4, 1), 'AbsTol', 1e5);
end

function testPumpingDirections(testCase)
% With pump on and initial conditions: n4 should increase (pumping),
% n1 should decrease (depletion).
    c = testCase.TestData.constants;
    n = [c.ndop; 0; 0; 0];
    dn_dt = rateEquations(0, n, 10000, c);
    verifyLessThan(testCase, dn_dt(1), 0);    % n1 decreases (ground state depletion)
    verifyGreaterThan(testCase, dn_dt(4), 0);  % n4 increases (pump absorption)
end

function testOutputShape(testCase)
% Rate equations should return a 4x1 column vector.
    c = testCase.TestData.constants;
    n = [c.ndop; 0; 0; 0];
    dn_dt = rateEquations(0, n, 10000, c);
    verifySize(testCase, dn_dt, [4, 1]);
end

function testConservationWithArbitraryState(testCase)
% Conservation should hold for any population distribution.
    c = testCase.TestData.constants;
    n = [4e20; 2e20; 1.5e20; 0.8e20];
    dn_dt = rateEquations(0, n, 5000, c);
    verifyEqual(testCase, sum(dn_dt), 0, 'AbsTol', 1e5);
end
