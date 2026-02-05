function configurePlotDefaults()
% configurePlotDefaults Sets publication-quality defaults for all figures.
%
% Call once at the start of a session to set consistent font sizes,
% line widths, colors, and figure dimensions across all plots.
%
% See also: plotPopulationDynamics, plotGainComparison

    set(groot, 'DefaultAxesFontSize', 12);
    set(groot, 'DefaultTextFontSize', 12);
    set(groot, 'DefaultLineLineWidth', 1.5);
    set(groot, 'DefaultAxesLineWidth', 1.0);
    set(groot, 'DefaultFigurePosition', [100, 100, 800, 600]);
    set(groot, 'DefaultAxesBox', 'on');
    set(groot, 'DefaultAxesXGrid', 'on');
    set(groot, 'DefaultAxesYGrid', 'on');
end
