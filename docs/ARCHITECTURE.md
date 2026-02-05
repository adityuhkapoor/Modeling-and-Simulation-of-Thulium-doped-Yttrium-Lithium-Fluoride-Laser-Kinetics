# Architecture

## Overview

The LaserDynamicsSimulator models a four-level Thulium-doped Yttrium Lithium Fluoride (Tm:YLF) laser system. It solves coupled rate equations to predict population densities across energy levels, then computes the resulting optical gain.

## Directory Structure

```
LaserDynamicsSimulator/
  src/
    main.m                              Entry point
    config/
      getDefaultConstants.m             Single source of truth for physics constants
      getSimulationConfig.m             Solver, file path, and logging settings
      loadConfig.m                      Optional JSON config override
      defaultConfig.json                Example JSON configuration file
    functions/
      simulateLaserDynamics.m           ODE solver wrapper (returns final state)
      simulateLaserDynamicsFull.m       ODE solver wrapper (returns full time history)
      calculateGain.m                   Small-signal gain from populations
      rateEquations.m                   Coupled ODEs for population dynamics
      optimizeParameters.m              Least-squares parameter fitting
      validateInputs.m                  Input validation for all functions
    logging/
      Logger.m                          Leveled logging (debug/info/warning/error)
    visualization/
      configurePlotDefaults.m           Publication-quality plot styling
      plotPopulationDynamics.m          Time-domain population evolution
      plotGainComparison.m              Simulated vs experimental gain + residuals
      plotConvergenceAnalysis.m         Temporal and solver convergence
      plotParameterSensitivity.m        One-at-a-time parameter sweeps
  tests/
    test_calculateGain.m                Gain formula unit tests
    test_simulateLaserDynamics.m        Simulation unit tests
    test_rateEquations.m                Rate equation unit tests
    test_validateInputs.m               Validation unit tests
    test_Logger.m                       Logger unit tests
    test_numericalStability.m           Edge case and overflow tests
    test_integration.m                  End-to-end pipeline tests
    test_convergence.m                  ODE convergence verification
    fixtures/
      getTestConstants.m                Shared test constants (delegates to config)
  legacy/                               Archived deprecated code (see legacy/README.md)
  data/
    Pump_Data.xlsx                      Experimental pump power and gain data
    experimentalGains.mat               MATLAB binary experimental data
  docs/
    ARCHITECTURE.md                     This file
    ThuliumLaserPresentation.pdf        Project presentation
  runTests.m                            Test suite runner
  .gitignore                            Git ignore rules
  README.md                             Project documentation
  LICENSE                               MIT License
```

## Data Flow

```
  [Pump_Data.xlsx]
        |
        v
     main.m  -->  getDefaultConstants()  -->  constants struct
        |         getSimulationConfig()  -->  config struct
        |
        v
  for each pump power:
        |
        v
  simulateLaserDynamics(Ip_W, endTime, constants)
        |
        +--> validateInputs(...)
        +--> ode45( rateEquations(...) )
        |         |
        |         +--> Computes dn1/dt, dn2/dt, dn3/dt, dn4/dt
        |         +--> Returns derivatives for each time step
        |
        +--> Returns n_populations = [n1, n2, n3, n4] at t=endTime
        |
        v
  calculateGain(n_populations, constants)
        |
        +--> g0 = sigmaE * n2 - sigmaA * n1
        +--> SSGain = exp(g0 * L)
        |
        v
  [simulatedGains array]
        |
        v
  plotGainComparison(pumpPowers, simulated, experimental)
```

## Physical Model

### Energy Levels

```
  Level 4 (^3H_4)  ----  Pump level (absorbs 791 nm photons)
        |
        | beta43, beta42, beta41 (branching ratios)
        v
  Level 3 (^3H_5)  ----  Intermediate level
        |
        | beta32, beta31 (branching ratios)
        v
  Level 2 (^3F_4)  ----  Upper laser level (emits ~1.9 um)
        |
        | 1/tau2 (spontaneous decay)
        v
  Level 1 (^3H_6)  ----  Ground state (initial population = ndop)
```

### Key Processes

1. **Pump absorption**: Ground state ions absorb pump photons and are excited to level 4.
2. **Cross-relaxation**: An ion in level 4 and one in level 1 both transition to level 2 (2-for-1 process, efficient for Thulium).
3. **Energy transfer upconversion (ETU)**: Two ions in level 2 interact; one goes to level 1, the other to level 3 or 4.
4. **Spontaneous decay**: Ions in excited states decay radiatively with characteristic lifetimes.

### Rate Equations

```
dn1/dt = -Re - kcr*n1*n4 + (ketu1+ketu2)*n2^2 + beta41*n4/tau4 + beta31*n3/tau3 + n2/tau2
dn2/dt = 2*kcr*n1*n4 - 2*(ketu1+ketu2)*n2^2 + beta32*n3/tau3 + beta42*n4/tau4 - n2/tau2
dn3/dt = ketu2*n2^2 + beta43*n4/tau4 - (beta31+beta32)*n3/tau3
dn4/dt = Re - kcr*n1*n4 + ketu1*n2^2 - (beta41+beta42+beta43)*n4/tau4

where Re = sigmaPumpAbs * n1 * Ip_W * lambdaPump / (h * c)
      n1 = ndop - n2 - n3 - n4  (conservation law)
```

### Gain Calculation

```
g0 = sigmaEmission * n2 - sigmaAbsorption * n1    [cm^-1]
SSGain = exp(g0 * L)                                [dimensionless]
```

## Configuration

Constants and settings are centralized in `src/config/`:

- **`getDefaultConstants()`** - Returns all physics parameters with units documented.
- **`getSimulationConfig()`** - Returns solver settings, file paths, logging config.
- **`loadConfig(jsonFile)`** - Optionally override any parameter from a JSON file.

To run with different parameters without editing code, create a JSON file:

```json
{
    "constants": { "kcr": 7.0e-19 },
    "config": { "endTime": 0.020 }
}
```

Then in MATLAB:

```matlab
[constants, config] = loadConfig('my_config.json');
```
