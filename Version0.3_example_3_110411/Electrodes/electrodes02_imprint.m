%   This is an electrode processor script: it imprints an arbitrary number
%   of electrodes
%
%   Copyright SNM 2012-2019

clear all %#ok<CLALL>
if ~isunix
    s = pwd; addpath(strcat(s(1:end-11), '\Engine'));
    s = pwd; addpath(strcat(s(1:end-11), '\Model'));
else
    s = pwd; addpath(strcat(s(1:end-11), '/Engine'));
    s = pwd; addpath(strcat(s(1:end-11), '/Model'));
end

%%  Target stimulation domain centerline (in mm)
name       = '110411_skin.mat';            %    file to import
Target      = [45.2 -7.0 48.1];                   %    in mm here
[pointsline] = targetctr(name, Target);

%%   Load shell to imprint 
name       = '110411_skin.mat';            %     file to import
load(name);
NumberOfTrianglesOriginal = size(t, 1);
center = meshtricenter(P, t);

%%  Determine electrode number/position/radius/current
strge.NumberOfElectrodes = 5; 
strge.PositionOfElectrodes(1, :) = [52.17  -6.69 63.18];      %   in mm, center
strge.PositionOfElectrodes(2, :) = [32.03  0.08 71.91];       %   in mm, top
strge.PositionOfElectrodes(3, :) = [69.57  -10.87 46.27];     %   in mm, bottom
strge.PositionOfElectrodes(4, :) = [52.23  17.31 56.57];      %   in mm, left
strge.PositionOfElectrodes(5, :) = [52.5  -29.43 65.09];      %   in mm, right
strge.RadiusOfElectrodes         = [6 6 6 6 6];               %   in mm
strge.Color(1)        = 'r';
strge.Color(2)        = 'b';
strge.Color(3)        = 'b';
strge.Color(4)        = 'b';
strge.Color(5)        = 'b';

%%   Imprint electrodes
[P, t, normals, IndicatorElectrodes] = meshimprint(P, t, normals, strge);

%%  Plot
figure;
%   Skin surface
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==0, :));
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';

%   Centerline
hold on;
plot3(pointsline(:, 1), pointsline(:, 2), pointsline(:, 3), '-r', 'lineWidth', 6);

%   Electrodes
for m = 1:strge.NumberOfElectrodes    
    p = patch('vertices', P, 'faces', t(IndicatorElectrodes==m, :));
    p.FaceColor = strge.Color(m);
    p.EdgeColor = 'none';
    p.FaceAlpha = 1.0;
end

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
save(name, 'IndicatorElectrodes', 'strge');
name       = '110411_skin_mod.mat';            %     file to import
cd ..
cd Model
save(name, 'P', 't', 'normals');
cd ..
cd Electrodes

