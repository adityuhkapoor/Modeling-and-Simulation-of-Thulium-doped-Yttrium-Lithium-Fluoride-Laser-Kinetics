function fig = plotPopulationDynamics(t, n, constants, options)
% plotPopulationDynamics Plots time-domain evolution of energy level populations.
%
% Creates a figure showing how all four population densities evolve over
% time during the pump pulse.
%
% Inputs:
%   t         - Time vector [Nx1] in seconds (from simulateLaserDynamicsFull).
%   n         - Population matrix [Nx4], columns: [n1, n2, n3, n4] in cm^-3.
%   constants - Constants struct (for ndop normalization).
%   options   - (optional) Struct with display options:
%     .normalize - Boolean, plot as fraction of ndop. Default: true.
%     .logScale  - Boolean, use log scale for y-axis. Default: false.
%     .title     - String, custom figure title.
%     .savePath  - String, if provided, save figure to this path.
%
% Output:
%   fig - Handle to the created figure.
%
% See also: simulateLaserDynamicsFull, configurePlotDefaults

    % Default options
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

    if options.logScale
        set(gca, 'YScale', 'log');
    end

    if isfield(options, 'savePath')
        saveas(fig, options.savePath);
    end
end
