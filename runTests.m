% runTests.m - Test runner for the LaserDynamicsSimulator.
%
% Run from the project root directory:
%   >> runTests
%
% Executes all test files in the tests/ directory and prints a summary.

clear; clc;

% Set up paths
addpath('src/functions');
addpath('src/config');
addpath('src/logging');
addpath('tests');
addpath('tests/fixtures');

% Run all tests
fprintf('Running LaserDynamicsSimulator test suite...\n\n');
results = runtests('tests', 'IncludeSubfolders', true);

% Display summary
fprintf('\n');
disp(table(results));

nTotal  = numel(results);
nPassed = sum([results.Passed]);
nFailed = sum([results.Failed]);

fprintf('\n--- Summary: %d/%d passed, %d failed ---\n', nPassed, nTotal, nFailed);
if nFailed > 0
    fprintf('*** %d TEST(S) FAILED ***\n', nFailed);
else
    fprintf('*** ALL TESTS PASSED ***\n');
end
