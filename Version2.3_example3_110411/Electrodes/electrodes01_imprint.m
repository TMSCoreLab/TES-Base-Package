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

%%  Target stimulation domain centerline (in mm)
name       = '110411_skin.mat';            %    file to import
Target      = [31 0 56];                   %    in mm here
[pointsline] = targetctr(name, Target);

%%   Load shell to imprint 
name       = '110411_skin.mat';            %     file to import
load(name);
NumberOfTrianglesOriginal = size(t, 1);
center = meshtricenter(P, t);

%%  Determine electrode number/position/radius
strge.NumberOfElectrodes = 2; 
strge.PositionOfElectrodes(1, :)= [28.8 -26.3 76.8];        %   in mm
strge.PositionOfElectrodes(2, :)= [3.2 75.7 46.8];          %   in mm
strge.RadiusOfElectrodes        = [20 20];                  %   in mm here
strge.Color(1)      = 'r';
strge.Color(2)      = 'b';

%%   Imprint electrodes
[P, t, normals, IndicatorElectrodes] = meshimprint(P, t, normals, strge);

%%  Plot
figure;
%   Skin surface
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==0, :));
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';

%   Electrode 1
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==1, :));
p.FaceColor = strge.Color(1);
p.EdgeColor = 'none';

%   Electrode 2
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==2, :));
p.FaceColor = strge.Color(2);
p.EdgeColor = 'none';

p.FaceAlpha = 1.0;
daspect([1 1 1])
camlight; lighting flat
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
grid on; 
set(gca, 'Clipping', 'off');
set(gcf,'Color','White');
view(33, 53); axis off; camzoom(2)
    
NumberOfTrianglesWithElectrodes = size(t, 1)
QualityFactor = min(simpqual(P, t))

%   Centerline
hold on;
plot3(pointsline(:, 1), pointsline(:, 2), pointsline(:, 3), '-r', 'lineWidth', 6);

%%   Save
save('electrode_data.mat', 'IndicatorElectrodes', 'strge', 'pointsline');
name        = strcat(name(1:end-4), '_mod.mat' );            %     file to import
cd ..
cd Model
save(name, 'P', 't', 'normals');
cd ..
cd Electrodes

