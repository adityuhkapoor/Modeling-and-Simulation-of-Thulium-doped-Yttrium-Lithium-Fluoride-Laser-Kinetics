function fig = plotPopulationDynamics(t, n, constants, options)
% plotPopulationDynamics Time evolution of energy level populations.

    if nargin < 4, options = struct(); end
    if ~isfield(options, 'normalize'), options.normalize = true;  end
    if ~isfield(options, 'logScale'),  options.logScale  = false; end
    if ~isfield(options, 'title'),     options.title = 'Population Dynamics'; end

    fig = figure('Name', options.title);

    levelNames = {'n_1 (^3H_6)', 'n_2 (^3F_4)', 'n_3 (^3H_5)', 'n_4 (^3H_4)'};
    colors = [0 0.447 0.741; 0.850 0.325 0.098; 0.929 0.694 0.125; 0.494 0.184 0.556];

    hold on;
    for i = 1:4
        if options.normalize
            yData = n(:, i) / constants.ndop;
        else
            yData = n(:, i);
        end
        plot(t * 1e3, yData, 'Color', colors(i, :), 'DisplayName', levelNames{i});
    end
    hold off;

    xlabel('Time (ms)');
    if options.normalize
        ylabel('Population fraction (n_i / n_{dop})');
    else
        ylabel('Population density (cm^{-3})');
    end
    title(options.title);
    legend('Location', 'east');

    if options.logScale, set(gca, 'YScale', 'log'); end
    if isfield(options, 'savePath'), saveas(fig, options.savePath); end
end
