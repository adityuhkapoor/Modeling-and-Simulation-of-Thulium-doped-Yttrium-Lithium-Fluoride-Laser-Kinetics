function fig = plotConvergenceAnalysis(Ip_W, constants, options)
% plotConvergenceAnalysis Temporal and solver tolerance convergence plots.

    if nargin < 3, options = struct(); end

    fig = figure('Name', 'Convergence Analysis');

    % Temporal convergence
    endTimes = [1e-3, 2e-3, 5e-3, 8e-3, 10e-3, 12e-3, 15e-3, 20e-3, 30e-3, 50e-3];
    n2_temporal = zeros(size(endTimes));
    for i = 1:numel(endTimes)
        n_pop = simulateLaserDynamics(Ip_W, endTimes(i), constants);
        n2_temporal(i) = n_pop(2);
    end

    subplot(1, 2, 1);
    plot(endTimes * 1e3, n2_temporal / constants.ndop, '-o', 'MarkerSize', 6);
    xlabel('Simulation end time (ms)');
    ylabel('n_2 / n_{dop}');
    title('Temporal Convergence');

    % Solver tolerance convergence
    relTols = [1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9, 1e-10];
    n2_solver = zeros(size(relTols));
    tspan = [0, 15e-3];
    n0 = [constants.ndop; 0; 0; 0];
    for i = 1:numel(relTols)
        opts = odeset('RelTol', relTols(i), 'AbsTol', relTols(i) * 1e-3, ...
                      'NonNegative', [1 2 3 4]);
        [~, n] = ode45(@(t, nv) rateEquations(t, nv, Ip_W, constants), tspan, n0, opts);
        n2_solver(i) = n(end, 2);
    end

    subplot(1, 2, 2);
    semilogx(relTols, n2_solver / constants.ndop, '-s', 'MarkerSize', 6);
    set(gca, 'XDir', 'reverse');
    xlabel('Relative tolerance');
    ylabel('n_2 / n_{dop}');
    title('Solver Tolerance Convergence');

    if isfield(options, 'savePath'), saveas(fig, options.savePath); end
end
