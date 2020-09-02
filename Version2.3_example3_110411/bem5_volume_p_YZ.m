%   This script accurately computes and displays electric potential sampled
%   on a cross-section (sagittal plane) via the FMM method with accurate
%   neighbor integration
%
%   Copyright SNM/WAW 2018-2020

%%  Load/prepare data
planeABCD = [1 0 0 -X*1e-3];


%%  Define observation points in the cross-section 
Ms = 200;
y = linspace(ymin, ymax, Ms);
z = linspace(zmin, zmax, Ms);
[Y0, Z0]  = meshgrid(y, z);
clear pointsYZ;
pointsYZ(:, 1) = X*ones(1, Ms^2);
pointsYZ(:, 2) = reshape(Y0, 1, Ms^2);
pointsYZ(:, 3) = reshape(Z0, 1, Ms^2);

%%  Find the potential at each observation point in the cross-section         
tic
pointsYZ       = 1e-3*pointsYZ;     % Convert back to m
Psec           = zeros(Ms*Ms, 1); 
R = 2;          %   precise integration                                    
Psec           = bemf5_volume_field_potential(pointsYZ, c, P, t, Center, Area, normals, R, planeABCD);
Ptotal         = Psec;
fieldPlaneTime = toc  

%%  Plot the potential in the cross-section
figure;
%  Potential contour plot
temp      = Ptotal;
th1 = +0.8;           %   in V
th2 = -0.2;           %   in V
levels      = 20;
bemf2_graphics_vol_field(temp, th1, th2, levels, y, z);
xlabel('Distance y, mm');
ylabel('Distance z, mm');
title(strcat('Potential V, ', label, '-in the sagittal plane'));

%  Elecrode projection
bemf1_graphics_electrodes(1e3*P, t(Indicator==1, :), strge, IndicatorElectrodes, 3);

% Tissue boundaries
color   = prism(length(tissue)); color(4, :) = [0 1 1];
for m = countYZ
    edges           = EofYZ{m};              %   this is for the contour
    points          = [];
    points(:, 1)    = +PofYZ{m}(:, 2);       %   this is for the contour  
    points(:, 2)    = +PofYZ{m}(:, 3);       %   this is for the contour
    patch('Faces', edges, 'Vertices', points, 'EdgeColor', color(m, :), 'LineWidth', 2.0);    %   this is contour plot
end

% centerline
hold on;
plot(pointsline(:, 2), pointsline(:, 3), '-r', 'lineWidth', 3);

%   General settings 
axis 'equal';  axis 'tight';     
colormap parula; colorbar;
axis([ymin ymax zmin zmax]);
grid on; set(gcf,'Color','White');