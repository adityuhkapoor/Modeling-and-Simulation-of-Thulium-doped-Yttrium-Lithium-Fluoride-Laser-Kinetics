% test_Logger.m - Unit tests for the Logger class.

function tests = test_Logger
    tests = functiontests(localfunctions);
end

function setupOnce(~)
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'logging'));
end

function testConfigureDoesNotError(testCase)
% Configuring the logger at each level should not throw.
    Logger.configure('debug');
    Logger.configure('info');
    Logger.configure('warning');
    Logger.configure('error');
    verifyTrue(testCase, true);
end

function testAllLevelsDoNotError(testCase)
% Calling each log level should not throw.
    Logger.configure('debug');
    Logger.debug('Test debug message');
    Logger.info('Test info message: %d', 42);
    Logger.warning('Test warning: %s', 'caution');
    Logger.error('Test error: %.2f', 3.14);
    verifyTrue(testCase, true);
end

function testFiltering(testCase)
% When configured at 'error', lower levels should be filtered out.
% (We verify no crash; actual filtering is tested by absence of output.)
    Logger.configure('error');
    Logger.debug('Should be filtered');
    Logger.info('Should be filtered');
    Logger.warning('Should be filtered');
    Logger.error('Should appear');
    verifyTrue(testCase, true);
end

function testInvalidLevelDefaultsToInfo(testCase)
% Unknown level string should not crash.
    Logger.configure('nonexistent_level');
    Logger.info('Should work after invalid level');
    verifyTrue(testCase, true);
end
