function fig = plotParameterSensitivity(pumpPowers, experimentalGains, constants, paramName, paramRange, options)
% plotParameterSensitivity Sweep one parameter and show effect on gain.

    if nargin < 6, options = struct(); end
    if ~isfield(options, 'endTime'), options.endTime = 15e-3; end

    nParams = numel(paramRange);
    nPumps  = numel(pumpPowers);
    allGains = zeros(nPumps, nParams);

    for j = 1:nParams
        modConst = constants;
        modConst.(paramName) = paramRange(j);
        for i = 1:nPumps
            n_pop = simulateLaserDynamics(pumpPowers(i), options.endTime, modConst);
            allGains(i, j) = calculateGain(n_pop, modConst);
        end
    end

    fig = figure('Name', sprintf('Sensitivity: %s', paramName));
    colors = parula(nParams);
    hold on;
    for j = 1:nParams
        plot(pumpPowers / 1e3, allGains(:, j), 'Color', colors(j, :), ...
            'DisplayName', sprintf('%s = %.3e', paramName, paramRange(j)));
    end
    plot(pumpPowers / 1e3, experimentalGains, 'k--x', 'LineWidth', 2, 'DisplayName', 'Experimental');
    hold off;

    xlabel('Pump power (kW)');
    ylabel('Single-pass gain');
    title(sprintf('Sensitivity to %s', paramName));
    legend('Location', 'bestoutside', 'FontSize', 8);
    colorbar;

    if isfield(options, 'savePath'), saveas(fig, options.savePath); end
end
