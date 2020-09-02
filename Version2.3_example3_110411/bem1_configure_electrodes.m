%   This script introduces electrode data
%
%   Copyright SNM 2018-2020

electrode_path =   [s, slash, 'Electrodes']; 
addpath(electrode_path);
load electrode_data;

%%  Define global electrode indexes (cell array ElectrodeIndexes)
ElectrodeIndexes = cell(max(IndicatorElectrodes), 1);
for j = 1:max(IndicatorElectrodes)
    ElectrodeIndexes{j} = find(IndicatorElectrodes==j);
end

%   Redefine array of contrasts for electrodes
for j = 1:length(ElectrodeIndexes)
    contrast(ElectrodeIndexes{j})   = 1;
end

%%  Define the voltage excitation vector
% Voltage (V) applied to each electrode
electrodeVoltages = [+1, -1];                       % For electrode configuration 1
%electrodeVoltages = [+1 -1 -1 -1 -1];              % For electrode configuration 2
%electrodeVoltages = [+1 +1 +1 +1 -1 +1 +1 +1 +1];   % For electrode configuration 3


V = zeros(size(t, 1), 1);                %    Preallocate facet voltage list
for enumber = 1:length(ElectrodeIndexes)
    index = ElectrodeIndexes{enumber};
    V(index, :) = electrodeVoltages(enumber);
end
indexe = transpose(vertcat(ElectrodeIndexes{:}));
 

%%  Target stimulation domain centerline (in mm)
name       = '110411_skin.mat';            %    file to import
Target      = [31 0 56];                   %    in mm here
[pointsline] = targetctr(name, Target);

%%  Plot the experimental configuration
% Get the tissue that should be plotted
tissue_to_plot = 'GM';                  % Name of the tissue to be plotted
h    = waitbar(0.5, 'Please wait - plotting the electrode configuration');    
t0 = t(Indicator==find(strcmp(tissue, tissue_to_plot)), :);
str.EdgeColor = 'none'; str.FaceColor = [1 0.75 0.65]; str.FaceAlpha = 1.0;

% Plot the tissue
figure;
bemf2_graphics_base(P, t0, str);
title(strcat('Total number of facets: ', num2str(size(t, 1))));     
close(h);
camlight('headlight');
lighting phong;

% Plot the electrodes
bemf1_graphics_electrodes(P, t(Indicator==1, :), strge, IndicatorElectrodes, -1);

% Plot the centerline passing through the targeted area
hold on;
plot3(1e-3*pointsline(:, 1), 1e-3*pointsline(:, 2), 1e-3*pointsline(:, 3), '-r', 'lineWidth', 6);

% General settings
axis 'equal';  axis 'tight';   
daspect([1 1 1]);
set(gcf,'Color','White');
view(33, 53); axis off; camzoom(2)

