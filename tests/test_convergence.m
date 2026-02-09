% test_convergence.m - ODE solver convergence tests.

function tests = test_convergence
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'functions'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'config'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'logging'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'fixtures'));
    testCase.TestData.constants = getTestConstants();
end

function testPopulationConservationOverTime(testCase)
    c = testCase.TestData.constants;
    [~, ~, diag] = simulateLaserDynamics(10000, 15e-3, c);
    verifyLessThan(testCase, diag.maxConservationError, 1e-6);
end

function testSteadyStateReached(testCase)
    c = testCase.TestData.constants;
    [~, ~, diag] = simulateLaserDynamics(10000, 15e-3, c);
    verifyTrue(testCase, diag.steadyStateReached);
end

function testTemporalConvergence(testCase)
    c = testCase.TestData.constants;
    n_15ms = simulateLaserDynamics(10000, 15e-3, c);
    n_50ms = simulateLaserDynamics(10000, 50e-3, c);
    relDiff = max(abs(n_15ms - n_50ms)) / max(abs(n_15ms));
    verifyLessThan(testCase, relDiff, 0.05);
end

function testSolverToleranceConvergence(testCase)
    c = testCase.TestData.constants;
    n_default = simulateLaserDynamics(10000, 15e-3, c);

    tspan = [0, 15e-3];
    n0 = [c.ndop; 0; 0; 0];
    options_tight = odeset('RelTol', 1e-10, 'AbsTol', 1e-13, 'NonNegative', [1 2 3 4]);
    [~, n] = ode45(@(t, nv) rateEquations(t, nv, 10000, c), tspan, n0, options_tight);
    n_tight = n(end, :);

    relDiff = max(abs(n_default - n_tight)) / max(abs(n_tight));
    verifyLessThan(testCase, relDiff, 1e-4);
end
