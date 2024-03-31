function SSGain = SSGainvsEndTimeandIp(Ip_W, endTime)
    % Define constants as global variables
    global kcr ketu1 ketu2 tau2 tau3 tau4 ndop Ap Ab sigmaemission sigmaabsorption sigmapabs lambdapump h c beta43 beta42 beta32 beta41 beta31 L f21 f14 f15 f11 f42 f41 Ipsat Ip_in;
    Ip_in=Ip_W;
    % Initialize constants
    kcr = 6.85e-19;
    ketu1 = 2.1e-21;
    ketu2 = 2.1e-21;
    tau2 = 16.3e-3;
    tau3 = 2.258e-3;
    tau4 = 56.63e-6;
    ndop = 8.3e20;
    Ap = 1.0;
    Ab = 0.99;
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
    f21 = 0.289;
    f14 = 0.053;
    f15 = 0.045;
    f11 = 0.192;
    f42 = 0.168;
    f41 = 0.190;
    Ipsat = 1.159e4;

    % Time parameters
    STARTTIME = 0;
    STOPTIME = endTime;
    DT = 1e-5;
    tspan = STARTTIME:DT:STOPTIME;

    % Initial conditions
    n1_0 = 8.30e20;
    n2_0 = 0;
    n3_0 = 0;
    n4_0 = 0;
    y0 = [n1_0, n2_0, n3_0, n4_0];

    % Solve ODE
    [~, y] = ode45(@(t, y) odefun(t, y), tspan, y0);

    % Calculate gain
    g0 = (sigmaemission * y(end, 2) - sigmaabsorption * (ndop - y(end, 2) - y(end, 3) - y(end, 4)));
    SSGain = exp(g0 * L);
end

% Define odefun
function dydt = odefun(~, y)
    global kcr ketu1 ketu2 tau2 tau3 tau4 ndop Ap Ab sigmaemission sigmaabsorption sigmapabs lambdapump h c beta43 beta42 beta32 beta41 beta31 L f21 f14 f15 f11 f42 f41 Ipsat Ip_in;

    n1 = y(1);
    n2 = y(2);
    n3 = y(3);
    n4 = y(4);

    % Calculate Re
    Re = (sigmapabs * (ndop - n2 - n3 - n4) * Ip_in * lambdapump) / (h * c);

    dydt = zeros(4, 1);
    dydt(1) = -Re - kcr * n1 * n4 + ketu1 * (n2^2) + ketu2 * (n2^2) + beta41 * (n4 / tau4) + beta31 * (n3 / tau3) + (n2 / tau2);
    dydt(2) = 2 * kcr * n1 * n4 - 2 * (ketu1 + ketu2) * (n2^2) + beta32 * (n3 / tau3) + beta42 * (n4 / tau4) - (n2 / tau2);
    dydt(3) = ketu2 * (n2^2) + beta43 * (n4 / tau4) - beta31 * (n3 / tau3)-beta32* (n3 /tau3);
    dydt(4) = Re - kcr * n1 * n4 + ketu1 * (n2^2) - beta41 * (n4 / tau4) - beta43 * (n4 / tau4) - beta42 * (n4 / tau4);
end
