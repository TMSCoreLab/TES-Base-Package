%   This script plots a thresholded surface electric field just
%   inside/outside any brain compartment surface
%
%   Copyright SNM/WAW 2018-2020

%%   Identify the tissue and field to plot
tissue_to_plot = 'WM';
Field          = Eoutside_m;

%%  Set threshold for the focality estimate field (as a percentage of maximum observed E-field)
margin = 0.75;

%%  Identify the point cloud
% Find locations on the selected tissue surface that experience an E-field
% at least as strong as [margin]*[maximum E-field on that surface]
objectnumber = find(strcmp(tissue, tissue_to_plot));
i            = Indicator==objectnumber;
temp         = Field(i);
[MAX, m]     = max(abs(temp))
Points       = Center(i, :);
th          = margin*MAX;
index       = find(abs(temp)>=th);
cloud       = Points(index, :);
position    = Points(m, :)
area        = Area(i);
TotalArea   = 1e6*sum(area(index))      % in mm^2

%% Plot the field focality estimate
%   Display the point cloud
S = load('sphere');
N = length(index);
n = length(S.P);
scale = 2.5;
figure;
for m = 1:N
    p = patch('vertices', scale*S.P+repmat(cloud(m, :), n, 1), 'faces', S.t);
    p.FaceColor = 'c';
    p.EdgeColor = 'none';
    p.FaceAlpha = 1.0;
end

%   Display the shell
p = patch('vertices', P, 'faces', t(i, :));
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';
p.FaceAlpha = 1.0;
daspect([1 1 1]);
camlight; lighting phong;
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');

percentage  = num2str(margin*100);
maximum     = num2str(max(temp));
firstline   = strcat('Cortical field is >', percentage, '%');
secondline  = strcat(' of the maximum value Emax=', maximum, ' V/m');
title({firstline; secondline});

%  Display the electrodes
bemf1_graphics_electrodes(P, t(Indicator==1, :), strge, IndicatorElectrodes, -1);

%  Display the centerline 
hold on;
plot3(1e-3*pointsline(:, 1), 1e-3*pointsline(:, 2), 1e-3*pointsline(:, 3), '-m', 'lineWidth', 5);

% General
view(124, 46); axis off; camzoom(3)
brighten(0.4);
