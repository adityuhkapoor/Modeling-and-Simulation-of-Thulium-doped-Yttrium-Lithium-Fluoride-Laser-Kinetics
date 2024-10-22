% Define constants
kcr = 6.85e-19;
ketu1 = 2.1e-21;
ketu2 = 2.1e-21;
tau2 = 16.3e-3;
tau3 = 2.258e-3;
tau4 = 56.63e-6;
ndop = 8.3e20;
sigmaemission = 4e-21;
sigmaabsorption = 9e-22;
sigmapabs = 6.978e-21;
lambdapump = 7.913e-5;
h = 6.6e-34;
c = 3e10;
beta43 = 0.100;
beta42 = 0.030;
beta32 = 0.030;
beta41 = 1 - beta43 - beta42;
beta31 = 1 - beta32;
L = 3.5;
Ip = 16e3;

% Initial conditions
N0 = [8.3e20; 0; 0; 0]; % [n1; n2; n3; n4]

% Time span for the ODE solver
tspan = [0 16e-3]; % For a 16ms simulation

% Create an anonymous function that includes the additional parameters
odefcn = @(t, N) rateEquations(t, N, kcr, ketu1, ketu2, tau2, tau3, tau4, ndop, ...
                               sigmaemission, sigmaabsorption, sigmapabs, lambdapump, ...
                               h, c, beta43, beta42, beta32, beta41, beta31, L, Ip);

% Solve the system of equations using ode45
[t, N] = ode45(odefcn, tspan, N0);

% Extract populations at the final time point
n2_end = N(end, 2);
n1_end = N(end, 1);
n3_end = N(end, 3);
n4_end = N(end, 4);

% Calculate the small-signal gain coefficient and gain
g0 = (sigmaemission*n2_end - sigmaabsorption*(ndop - n2_end - n3_end - n4_end));
SSGain = exp(g0 * L);

% Display the results
fprintf('Small-Signal Gain Coefficient (g0): %e\n', g0);
fprintf('Small-Signal Gain: %f\n', SSGain);

% Define the rate equations
function dNdt = rateEquations(t, N, kcr, ketu1, ketu2, tau2, tau3, tau4, ndop, ...
                              sigmaemission, sigmaabsorption, sigmapabs, lambdapump, ...
                              h, c, beta43, beta42, beta32, beta41, beta31, L, Ip)
    n1 = N(1);
    n2 = N(2);
    n3 = N(3);
    n4 = N(4);

    % Calculate pump rate
    Re = (sigmapabs*(ndop-n2-n3)*Ip*lambdapump)/(h*c);
    
    % Implement the square pulse condition for the pump
    if t <= 15e-3
        Re = Re;
    else
        Re = 0;
    end

    % System of differential equations
    dn4dt = Re - kcr*n1*n4 + ketu1*(n2^2) - (beta41 + beta43 + beta42)*(n4/tau4);
    dn3dt = ketu2*(n2^2) + beta43*(n4/tau4) - (beta31 + beta32)*(n3/tau3);
    dn2dt = 2*kcr*n1*n4 - 2*(ketu1 + ketu2)*(n2^2) + beta32*(n3/tau3) + beta42*(n4/tau4) - (n2/tau2);
    dn1dt = -Re - kcr*n1*n4 + (ketu1 + ketu2)*(n2^2) + beta41*(n4/tau4) + beta31*(n3/tau3) + (n2/tau2);

    dNdt = [dn1dt; dn2dt; dn3dt; dn4dt];
end
