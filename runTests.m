% runTests.m - Run from project root: >> runTests

clear; clc;

addpath('src/functions', 'src/config', 'src/logging', 'tests', 'tests/fixtures');

fprintf('Running tests...\n\n');
results = runtests('tests', 'IncludeSubfolders', true);

fprintf('\n');
disp(table(results));

nPassed = sum([results.Passed]);
nFailed = sum([results.Failed]);
fprintf('\n%d/%d passed, %d failed\n', nPassed, numel(results), nFailed);
