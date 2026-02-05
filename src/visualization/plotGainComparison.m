function fig = plotGainComparison(pumpPowers, simulatedGains, experimentalGains, options)
% plotGainComparison Publication-quality comparison of simulated vs experimental gain.
%
% Creates a two-panel figure:
%   Top:    Gain vs pump power with both simulated and experimental curves.
%   Bottom: Residuals (simulated - experimental) as a stem plot.
%
% Includes R-squared annotation on the main plot.
%
% Inputs:
%   pumpPowers        - Pump power values [W] (Nx1 or 1xN).
%   simulatedGains    - Simulated gain values (Nx1 or 1xN).
%   experimentalGains - Experimental gain values (Nx1 or 1xN).
%   options           - (optional) Struct with display options:
%     .title    - String, custom title for the main plot.
%     .savePath - String, if provided, save figure to this path.
%
% Output:
%   fig - Handle to the created figure.
%
% See also: configurePlotDefaults, plotPopulationDynamics

    if nargin < 4, options = struct(); end
    if ~isfield(options, 'title'), options.title = 'Simulated vs Experimental Gain'; end

    fig = figure('Name', options.title);

    % Top panel: Gain comparison
    subplot(3, 1, [1, 2]);
    plot(pumpPowers / 1e3, simulatedGains, '-o', 'MarkerSize', 6, 'DisplayName', 'Simulated');
    hold on;
    plot(pumpPowers / 1e3, experimentalGains, '-x', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Experimental');
    hold off;
    ylabel('Single-pass gain');
    title(options.title);
    legend('Location', 'northwest');

    % R-squared
    SS_res = sum((experimentalGains(:) - simulatedGains(:)).^2);
    SS_tot = sum((experimentalGains(:) - mean(experimentalGains(:))).^2);
    if SS_tot > 0
        R2 = 1 - SS_res / SS_tot;
        text(0.95, 0.08, sprintf('R^2 = %.4f', R2), ...
            'Units', 'normalized', 'HorizontalAlignment', 'right', 'FontSize', 11);
    end

    % Bottom panel: Residuals
    subplot(3, 1, 3);
    stem(pumpPowers / 1e3, simulatedGains(:) - experimentalGains(:), ...
        'filled', 'MarkerSize', 4);
    hold on;
    yline(0, '--', 'Color', [0.5 0.5 0.5]);
    hold off;
    xlabel('Pump power (kW)');
    ylabel('Residual');
    title('Residuals (Simulated - Experimental)');

    if isfield(options, 'savePath')
        saveas(fig, options.savePath);
    end
end
