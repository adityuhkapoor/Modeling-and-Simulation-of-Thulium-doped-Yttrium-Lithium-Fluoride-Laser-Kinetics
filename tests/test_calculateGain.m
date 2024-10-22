% test_calculateGain.m

function tests = test_calculateGain
tests = functiontests(localfunctions);
end

function testGainCalculation(testCase)
constants = struct('sigmaEmission', 4e-21, 'sigmaAbsorption', 9e-22, 'ndop', 8.3e20, 'L', 3.5);
n_populations = [8.3e20, 1e18, 0, 0];
expectedGain = exp((constants.sigmaEmission * n_populations(2) - constants.sigmaAbsorption * (constants.ndop - sum(n_populations(2:end)))) * constants.L);
actualGain = calculateGain(n_populations, constants);
verifyEqual(testCase, actualGain, expectedGain, 'AbsTol', 1e-6);
end
