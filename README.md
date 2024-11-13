# Modeling and Simulation of Thulium-doped Yttrium Lithium Fluoride Laser Kinetics

## Abstract
This repository contains the MATLAB simulation code for a four-level Thulium-doped Yttrium Lithium Fluoride (let's just refer to them as Thulium lasers for short) laser kinetics model. The primary goal is to adjust model parameters and simulation works with a set of first-order differential equations representing the rate dynamics of the laser system.

## Table of Contents
- Introduction
- Objectives
- Methodology
- Results
- Conclusion
- Acknowledgements

## Introduction
Thulium-doped Yttrium Lithium Fluoride lasers are significant in various applications due to their emission in the 2 μm region, which is useful for medical, military, and scientific applications. Understanding the kinetics of these lasers is crucial for optimizing their performance. This project aims to simulate the laser kinetics to match experimental observations and gain deeper insights into the underlying physical processes.

## Objectives
- Develop a kinetic model of the Thulium laser using first-order differential equations.
- Adjust and optimize model parameters to align simulation results with experimental data.
- Analyze the behavior of the laser under different pumping conditions.
- Provide insights into the population dynamics of the energy levels involved.

## Methodology
- Laser Kinetics Modeling: Modeled the laser as a four-level system with specific rate equations governing the population of each energy level.
- Differential Equations: Utilized MATLAB's ODE solvers to numerically solve the coupled differential equations over time.
- Parameter Optimization: Employed optimization techniques to adjust parameters such as cross-relaxation coefficients, lifetimes, and pump rates to minimize the difference between simulated and experimental gains.
- Data Analysis: Compared the simulated gains with experimental data to evaluate the accuracy of the model.

## Key Equations
- Rate Equations: Defined for populations n_1, n_2, n_3, n_4, with parameters like pump rate, R_e, decay rates, and cross-relaxation terms.
- Gain Calculation: Small-signal gain calculated using g_0 = σ(n_3 - n_2)

## Tools and Libraries
- MATLAB R2021a for simulation and data analysis.
- Optimization Toolbox for parameter fitting.

## Results
- Simulation vs. Experimental Data: Achieved a close match between simulated gains and experimental gains after parameter optimization.
- Optimized Parameters: Identified key parameters that significantly affect the laser dynamics, such as the cross-relaxation coefficient and excited-state lifetimes.
- Gain Curves: Plotted gain versus input power, showing the laser's performance under various pumping conditions.

## Conclusion
The simulation successfully models the kinetics of a Thulium laser and provides insights into the population dynamics. By adjusting the model parameters, the simulated gains align closely with experimental data, validating the effectiveness of the kinetic model. This work contributes to a better understanding of Thulium lasers and can aid in their optimization for practical applications.

## Acknowledgements
I would like to thank my supervisor, Dr. David Klotzkin, for guidance throughout this project. 
