%   This is an electrode processor script: it imprints an arbitrary number
%   of electrodes
%
%   Copyright SNM 2012-2020

clear all %#ok<CLALL>
if ~isunix
    s = pwd; addpath(strcat(s(1:end-11), '\Engine'));
    s = pwd; addpath(strcat(s(1:end-11), '\Model'));
else
    s = pwd; addpath(strcat(s(1:end-11), '/Engine'));
    s = pwd; addpath(strcat(s(1:end-11), '/Model'));
end

%%   Load skin shell 
name       = '110411_skin.mat';            %     file to import
load(name);
NumberOfTrianglesOriginal = size(t, 1)

%%  Target stimulation domain centerline (in mm)
name       = '110411_skin.mat';            %    file to import
Target      = [31 0 56];                   %    in mm here
[pointsline] = targetctr(name, Target);

%%  Determine electrode number/position/radius/current
strge.NumberOfElectrodes = 9; 
strge.PositionOfElectrodes(1, :) = [36.32  24.57 63.87];        %   F4 in mm, right
strge.PositionOfElectrodes(2, :) = [-32.6  21.54 66.28];        %   F3 in mm, left
strge.PositionOfElectrodes(3, :) = [76.35  -15.9 35.87];        %   T4  in mm, bottom
strge.PositionOfElectrodes(4, :) = [42.09  -16.09 71.37];       %   C4 in mm, left
strge.PositionOfElectrodes(5, :) = [3.199  -17.33 81.50];       %   Ref(Cz) in mm, right
strge.PositionOfElectrodes(6, :) = [-36.71  -17.96 72.76];      %   C3 in mm, right
strge.PositionOfElectrodes(7, :) = [-70.21  -19.31 41.35];      %   T3 in mm, right
strge.PositionOfElectrodes(8, :) = [33.16  -75.05 45.93];       %   O2 in mm, right
strge.PositionOfElectrodes(9, :) = [-26.88  -76.09 45.83];      %   O1 in mm, right

strge.RadiusOfElectrodes         = 6*ones(1, strge.NumberOfElectrodes); % in mm here
strge.Color(1)        = 'r';
strge.Color(2)        = 'r';
strge.Color(3)        = 'r';
strge.Color(4)        = 'r';
strge.Color(5)        = 'b';
strge.Color(6)        = 'r';
strge.Color(7)        = 'r';
strge.Color(8)        = 'r';
strge.Color(9)        = 'r';

%%   Imprint electrodes
[P, t, normals, IndicatorElectrodes] = meshimprint(P, t, normals, strge);

%%  Plot
figure;
%   Skin surface
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==0, :));
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';

%   Electrodes
for m = 1:strge.NumberOfElectrodes    
    p = patch('vertices', P, 'faces', t(IndicatorElectrodes==m, :));
    p.FaceColor = strge.Color(m);
    p.EdgeColor = 'none';
    p.FaceAlpha = 1.0;
end

%   Centerline
hold on;
plot3(pointsline(:, 1), pointsline(:, 2), pointsline(:, 3), '-r', 'lineWidth', 6);

daspect([1 1 1])
view(33, 53); axis off; camzoom(2)
camlight; lighting flat
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
grid on; 
set(gca, 'Clipping', 'off');
set(gcf,'Color','White');
    
NumberOfTrianglesWithElectrodes = size(t, 1)
QualityFactor = min(simpqual(P, t))

%%   Save
name = 'electrode_data.mat';
save(name, 'IndicatorElectrodes', 'strge', 'pointsline');
name       = '110411_skin_mod.mat';            %     file to import
cd ..
cd Model
save(name, 'P', 't', 'normals');
cd ..
cd Electrodes

