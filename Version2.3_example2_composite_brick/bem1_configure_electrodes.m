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

V = zeros(size(t, 1), 1);                %    Preallocate facet voltage list
for enumber = 1:length(ElectrodeIndexes)
    index = ElectrodeIndexes{enumber};
    V(index, :) = electrodeVoltages(enumber);
end
indexe = transpose(vertcat(ElectrodeIndexes{:}));
    
    %%  Structured graphics  
str.EdgeColor = 'c'; str.FaceColor = 'y'; str.FaceAlpha = 1.0; 
bemf2_graphics_base(1e3*P, t, str);

for m = 1:length(ElectrodeIndexes)
    t0 = t(ElectrodeIndexes{m}, :);    % electrode #m
    str.EdgeColor = 'k'; str.FaceColor = 'r'; str.FaceAlpha = 1.0; 
    bemf2_graphics_base(1e3*P, t0, str);
end

title(strcat('Total number of facets: ', num2str(size(t, 1))));     
view(30, 60); set(gcf, 'Color', 'White'); grid off