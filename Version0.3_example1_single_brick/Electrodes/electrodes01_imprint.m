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

%%   Load shell to imprint 
name       = 'brick01.mat';            %     file to import
load(name);
NumberOfTrianglesOriginal = size(t, 1)

%%  Determine electrode number/position/radius/current
strge.NumberOfElectrodes = 2; 
strge.PositionOfElectrodes(1, :) = 1e3*[-0.25 0 0.5];       %   in mm
strge.PositionOfElectrodes(2, :) = 1e3*[+0.25 0 0.5];       %   in mm
strge.RadiusOfElectrodes   = 1e3*[0.1 0.1];                 %   in mm here
strge.Voltage              = [+1 -1];                       %   in V 
strge.Color(1)      = 'r';
strge.Color(2)      = 'b';

%%   Imprint electrodes
[P, t, normals, IndicatorElectrodes] = meshimprint(P, t, normals, strge);

%%  Plot
%   Skin surface
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==0, :));
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'k';

%   Electrode 1
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==1, :));
p.FaceColor = strge.Color(1);
p.EdgeColor = 'k';

%   Electrode 2
p = patch('vertices', P, 'faces', t(IndicatorElectrodes==2, :));
p.FaceColor = strge.Color(2);
p.EdgeColor = 'k';

p.FaceAlpha = 1.0;
daspect([1 1 1])
camlight; lighting flat
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
grid on; 
set(gca, 'Clipping', 'off');
set(gcf,'Color','White');
view(150, 50);
    
NumberOfTrianglesWithElectrodes = size(t, 1)
QualityFactor = min(simpqual(P, t))

%%   Save
save('electrode_data.mat', 'IndicatorElectrodes', 'strge');
name        = strcat(name(1:end-4), '_mod.mat' );            %     file to import
cd ..
cd Model
save(name, 'P', 't', 'normals');
cd ..
cd Electrodes

