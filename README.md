# Modeling and Simulation of Thulium-doped Yttrium Lithium Fluoride Laser Kinetics

MATLAB simulation of a four-level Tm:YLF laser. Solves coupled rate equations for population dynamics and compares simulated single-pass gain against experimental measurements.

## Quick Start

```matlab
cd src
main
```

Run tests:
```matlab
runTests
```

## Project Structure

```
src/
  main.m                    Entry point
  config/                   Constants and simulation settings
  functions/                Rate equations, gain calculation, ODE solver, optimization
  logging/                  Simple logging wrapper
  visualization/            Plotting functions
tests/                      Unit and integration tests
legacy/                     Archived deprecated code (see legacy/README.md)
data/                       Experimental data files
```

## Configuration

All physical constants are in `src/config/getDefaultConstants.m`. To override via JSON:

```matlab
[constants, config] = loadConfig('my_params.json');
```

## Rate Equations

Four-level system: ground state (^3H_6), upper laser level (^3F_4), intermediate (^3H_5), pump level (^3H_4). Key processes: ground-state pump absorption, cross-relaxation (2-for-1 into upper laser level), energy transfer upconversion, and spontaneous decay.

```
dn1/dt = -Re - kcr*n1*n4 + (ketu1+ketu2)*n2^2 + beta41*n4/tau4 + beta31*n3/tau3 + n2/tau2
dn2/dt = 2*kcr*n1*n4 - 2*(ketu1+ketu2)*n2^2 + beta32*n3/tau3 + beta42*n4/tau4 - n2/tau2
dn3/dt = ketu2*n2^2 + beta43*n4/tau4 - (beta31+beta32)*n3/tau3
dn4/dt = Re - kcr*n1*n4 + ketu1*n2^2 - (beta41+beta42+beta43)*n4/tau4

Re = sigmaPumpAbs * n1 * Ip * lambdaPump / (h * c)
g0 = sigmaEmission * n2 - sigmaAbsorption * n1
SSGain = exp(g0 * L)
```

## Requirements

- MATLAB R2021a or later
- Optimization Toolbox (for `optimizeParameters.m`)

## Acknowledgements

I would like to thank my supervisor, Dr. David Klotzkin, for guidance throughout this project.

## License

MIT License - see [LICENSE](LICENSE) for details.
