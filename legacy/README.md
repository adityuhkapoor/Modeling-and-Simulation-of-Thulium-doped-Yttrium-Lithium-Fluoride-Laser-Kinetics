# Legacy Code

These files are **DEPRECATED** and retained for historical reference only. They have been superseded by the modular code in `src/`.

## File Inventory

| File | Original Purpose | Superseded By |
|------|-----------------|---------------|
| `legacy_lasersimulation.m` | Monolithic simulation + rate equations + gain calculation | `src/functions/simulateLaserDynamics.m`, `rateEquations.m`, `calculateGain.m` |
| `legacy_SSGainvsEndTimeandIp.m` | Gain vs time and pump power with original constants | `src/functions/simulateLaserDynamics.m` |
| `legacy_SSGainvsEndTimeandIpNewConstants.m` | Same as above with post-optimization constants | `src/functions/optimizeParameters.m` |
| `legacy_SimulatedGain.m` | Batch gain computation over hardcoded pump powers | `src/main.m` simulation loop |
| `legacy_MeritValCalc.m` | Sum-of-squared-errors cost function (single parameter) | `src/functions/optimizeParameters.m` (objectiveFunc) |
| `legacy_MeritValCalcArray.m` | Array-based cost function | `src/functions/optimizeParameters.m` |
| `legacy_MeritValCalcMultArray.m` | Cost function with unit scaling | `src/functions/optimizeParameters.m` |
| `legacy_MeritValueProducer.m` | Computes simulated data and squared differences | `src/functions/optimizeParameters.m` |
| `legacy_CurveFittingComparison.m` | Compare pre/post optimization gains with MSE | `src/visualization/plotGainComparison.m` |
| `legacy_15ms_Data.m` | Load and extract experimental data from Excel | `src/main.m` data loading |

## Terminology Changes

The legacy code uses the term **"merit value"** for what is now called the **objective function** (or cost function / loss function). This is the standard terminology in optimization and machine learning:

| Legacy Term | Standard Term | Description |
|-------------|--------------|-------------|
| Merit value | Objective function | The function being minimized by the optimizer |
| Merit value calculation | Cost/loss evaluation | Computing the sum of squared residuals |

## Known Constant Discrepancies

| Constant | Current (`src/`) | Legacy | Notes |
|----------|-----------------|--------|-------|
| `c` | `3e8` (m/s, SI) | `3e10` (cm/s, CGS) | Unit system difference |
| `h` | `6.626e-34` (precise) | `6.6e-34` (rounded) | Precision difference |
| Pump rate | `(ndop - n2 - n3 - n4)` | `(ndop - n2 - n3)` | Formula difference (see below) |

### Pump Rate Formula Discrepancy

- **Current code**: `Re = sigmaPumpAbs * (ndop - n2 - n3 - n4) * Ip * lambda / (h * c)`
  - `(ndop - n2 - n3 - n4)` equals `n1` (ground state population via conservation law)
  - This represents ground-state absorption, which is physically correct

- **Legacy code**: `Re = sigmaPumpAbs * (ndop - n2 - n3) * Ip * lambda / (h * c)`
  - `(ndop - n2 - n3)` equals `n1 + n4`
  - This may have been an approximation or error in the original code

### Post-Optimization Constants

The file `legacy_SSGainvsEndTimeandIpNewConstants.m` contains optimized parameter values that differ significantly from the initial values:

| Parameter | Initial | Optimized | Change |
|-----------|---------|-----------|--------|
| `kcr` | 6.85e-19 | 7.8953e-19 | +15% |
| `ketu1` | 2.1e-21 | 1.4132e-21 | -33% |
| `ketu2` | 2.1e-21 | 9.017e-21 | +329% |
| `tau2` | 16.3e-3 | 0.12 | +636% |
| `tau3` | 2.258e-3 | 11.3837e-3 | +404% |
| `tau4` | 56.63e-6 | 20.725e-6 | -63% |
