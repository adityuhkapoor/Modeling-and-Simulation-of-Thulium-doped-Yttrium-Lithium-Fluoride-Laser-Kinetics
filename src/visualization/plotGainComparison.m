function fig = plotGainComparison(pumpPowers, simulatedGains, experimentalGains, options)
% plotGainComparison Simulated vs experimental gain with residuals.

    if nargin < 4, options = struct(); end
    if ~isfield(options, 'title'), options.title = 'Simulated vs Experimental Gain'; end

    fig = figure('Name', options.title);

    subplot(3, 1, [1, 2]);
    plot(pumpPowers / 1e3, simulatedGains, '-o', 'MarkerSize', 6, 'DisplayName', 'Simulated');
    hold on;
    plot(pumpPowers / 1e3, experimentalGains, '-x', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Experimental');
    hold off;
    ylabel('Single-pass gain');
    title(options.title);
    legend('Location', 'northwest');

    SS_res = sum((experimentalGains(:) - simulatedGains(:)).^2);
    SS_tot = sum((experimentalGains(:) - mean(experimentalGains(:))).^2);
    if SS_tot > 0
        R2 = 1 - SS_res / SS_tot;
        text(0.95, 0.08, sprintf('R^2 = %.4f', R2), ...
            'Units', 'normalized', 'HorizontalAlignment', 'right', 'FontSize', 11);
    end

    subplot(3, 1, 3);
    stem(pumpPowers / 1e3, simulatedGains(:) - experimentalGains(:), 'filled', 'MarkerSize', 4);
    hold on;
    yline(0, '--', 'Color', [0.5 0.5 0.5]);
    hold off;
    xlabel('Pump power (kW)');
    ylabel('Residual');
    title('Residuals');

    if isfield(options, 'savePath')
        saveas(fig, options.savePath);
    end
end
