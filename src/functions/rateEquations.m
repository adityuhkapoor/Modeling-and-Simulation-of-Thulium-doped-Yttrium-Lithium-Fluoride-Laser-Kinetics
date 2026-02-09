function dn_dt = rateEquations(~, n, Ip_W, constants)
% rateEquations Coupled ODEs for the four-level Tm:YLF laser.
%
% Models pump absorption, cross-relaxation, ETU, and spontaneous decay.
% Conservation: n1 + n2 + n3 + n4 = ndop.

    n1 = n(1);  n2 = n(2);  n3 = n(3);  n4 = n(4);

    kcr    = constants.kcr;
    ketu1  = constants.ketu1;
    ketu2  = constants.ketu2;
    tau2   = constants.tau2;
    tau3   = constants.tau3;
    tau4   = constants.tau4;
    ndop   = constants.ndop;
    beta43 = constants.beta43;
    beta42 = constants.beta42;
    beta32 = constants.beta32;
    beta41 = 1 - beta43 - beta42;
    beta31 = 1 - beta32;

    % Pump rate
    Re = (constants.sigmaPumpAbs * (ndop - n2 - n3 - n4) * Ip_W * constants.lambdaPump) ...
         / (constants.h * constants.c);

    dn1dt = -Re - kcr*n1*n4 + (ketu1+ketu2)*n2^2 ...
            + beta41*n4/tau4 + beta31*n3/tau3 + n2/tau2;

    dn2dt = 2*kcr*n1*n4 - 2*(ketu1+ketu2)*n2^2 ...
            + beta32*n3/tau3 + beta42*n4/tau4 - n2/tau2;

    dn3dt = ketu2*n2^2 + beta43*n4/tau4 - (beta31+beta32)*n3/tau3;

    dn4dt = Re - kcr*n1*n4 + ketu1*n2^2 - (beta41+beta42+beta43)*n4/tau4;

    dn_dt = [dn1dt; dn2dt; dn3dt; dn4dt];
end
