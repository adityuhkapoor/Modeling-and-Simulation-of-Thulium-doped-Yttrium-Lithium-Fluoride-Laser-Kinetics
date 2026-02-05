# Modeling and Simulation of Thulium-doped Yttrium Lithium Fluoride Laser Kinetics

## Abstract

MATLAB simulation of a four-level Thulium-doped Yttrium Lithium Fluoride (Tm:YLF) laser kinetics model. The simulation solves coupled first-order differential equations representing the rate dynamics of the laser system and compares simulated single-pass gain against experimental measurements.

## Quick Start

1. Open MATLAB and navigate to the project root directory.
2. Run the simulation:
   ```matlab
   cd src
   main
   ```
3. Run the test suite:
   ```matlab
   runTests
   ```

## Project Structure

```
src/
  main.m                    Entry point: loads data, simulates, plots
  config/                   Centralized configuration
    getDefaultConstants.m   Single source of truth for physics constants
    getSimulationConfig.m   Solver settings, file paths, logging options
    loadConfig.m            Optional JSON-based config override
  functions/                Core simulation logic
    simulateLaserDynamics.m     Solves ODEs, returns final populations
    simulateLaserDynamicsFull.m Solves ODEs, returns full time history + diagnostics
    calculateGain.m             Computes small-signal gain
    rateEquations.m             Four-level rate equations (ODEs)
    optimizeParameters.m        Least-squares parameter fitting
    validateInputs.m            Input validation
  logging/
    Logger.m                Leveled logging utility
  visualization/            Publication-quality plotting functions
    plotPopulationDynamics.m
    plotGainComparison.m
    plotConvergenceAnalysis.m
    plotParameterSensitivity.m
tests/                      MATLAB unit and integration tests
legacy/                     Archived deprecated code (see legacy/README.md)
data/                       Experimental data files
docs/                       Documentation and presentations
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture documentation including data flow, physics model, and equations.

## Configuration

All physical constants are defined in `src/config/getDefaultConstants.m`. To run with different parameters without editing code, create a JSON file and load it:

```matlab
[constants, config] = loadConfig('my_params.json');
```

See `src/config/defaultConfig.json` for the full list of configurable values.

## Visualization

After running the simulation, additional analysis plots are available:

```matlab
addpath('src/functions', 'src/config', 'src/logging', 'src/visualization');
configurePlotDefaults();
constants = getDefaultConstants();

% Population dynamics over time
[t, n, diag] = simulateLaserDynamicsFull(10000, 15e-3, constants);
plotPopulationDynamics(t, n, constants);

% Convergence analysis
plotConvergenceAnalysis(10000, constants);

% Parameter sensitivity
kcrRange = linspace(0.5, 2.0, 8) * constants.kcr;
plotParameterSensitivity(pumpPowers_W, experimentalGain, constants, 'kcr', kcrRange);
```

## Testing

Run the full test suite from the project root:

```matlab
runTests
```

The suite includes unit tests, integration tests, numerical stability tests, and convergence verification.

## Requirements

- MATLAB R2021a or later
- Optimization Toolbox (for parameter fitting via `optimizeParameters.m`)

## Key Equations

- **Rate Equations**: Coupled ODEs for populations n1, n2, n3, n4 governing pump absorption, cross-relaxation, energy transfer upconversion, and spontaneous decay.
- **Gain Calculation**: `g0 = sigma_emission * n2 - sigma_absorption * n1`, then `SSGain = exp(g0 * L)`.

## Acknowledgements

I would like to thank my supervisor, Dr. David Klotzkin, for guidance throughout this project.

## License

MIT License - see [LICENSE](LICENSE) for details.
