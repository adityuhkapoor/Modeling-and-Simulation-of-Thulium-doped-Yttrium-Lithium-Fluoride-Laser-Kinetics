function n_populations = simulateLaserDynamics(Ip_W, endTime, constants)
% simulateLaserDynamics Simulates the laser dynamics.
%
% Inputs:
%   Ip_W      - Input pump power in Watts.
%   endTime   - Simulation end time in seconds.
%   constants - Structure containing simulation constants.
%
% Output:
%   n_populations - Population densities at the final time step.

% Time parameters
tspan = [0, endTime];

% Initial conditions
n0 = [constants.ndop; 0; 0; 0]; % [n1; n2; n3; n4]

% ODE options
options = odeset('RelTol',1e-6,'AbsTol',1e-9);

% Solve ODE
[t, n] = ode45(@(t, n) rateEquations(t, n, Ip_W, constants), tspan, n0, options);

% Return populations at the final time step
n_populations = n(end, :);
end
