%   This script accurately computes and displays electric potential sampled
%   on a cross-section (coronal plane) via the FMM method with accurate
%   neighbor integration
%
%   Copyright SNM/WAW 2018-2020

%%  Load/prepare data
planeABCD = [0 1 0 -Y*1e-3];


%%  Define observation points in the cross-section   
Ms = 200;
x = linspace(xmin, xmax, Ms);
z = linspace(zmin, zmax, Ms);
[X0, Z0]  = meshgrid(x, z);
clear pointsXZ;
pointsXZ(:, 1) = reshape(X0, 1, Ms^2);
pointsXZ(:, 2) = Y*ones(1, Ms^2);
pointsXZ(:, 3) = reshape(Z0, 1, Ms^2);  

%%  Find the potential at each observation point in the cross-section
tic
pointsXZ       = 1e-3*pointsXZ;     % Convert back to m
Psec           = zeros(Ms*Ms, 1);
R = 2;  %   precise integration            
Psec           = bemf5_volume_field_potential(pointsXZ, c, P, t, Center, Area, normals, R, planeABCD);
Ptotal         = Psec;   
fieldPlaneTime = toc  

%%  Plot the potential in the cross-section
figure
%  Potential contour plot
temp      = Ptotal;
th1 = +0.6;           %   in V/m
th2 = 0;           %   in V/m
levels      = 20;
bemf2_graphics_vol_field(temp, th1, th2, levels, x, z);
xlabel('Distance x, mm');
ylabel('Distance z, mm');
title(strcat('Potential V, ', label, '-in the coronal plane'));

%  Elecrode projection
bemf1_graphics_electrodes(1e3*P, t(Indicator==1, :), strge, IndicatorElectrodes, 2);
 
% Tissue boundaries
color   = prism(length(tissue)); color(4, :) = [0 1 1];
for m = countXZ
    edges           = EofXZ{m};              %   this is for the contour
    points          = [];
    points(:, 1)    = +PofXZ{m}(:, 1);       %   this is for the contour  
    points(:, 2)    = +PofXZ{m}(:, 3);       %   this is for the contour
    patch('Faces', edges, 'Vertices', points, 'EdgeColor', color(m, :), 'LineWidth', 2.0);    %   this is contour plot
end

%  Plot centerline
hold on;
plot(pointsline(:, 1), pointsline(:, 3), '-r', 'lineWidth', 3);

%   General settings 
axis 'equal';  axis 'tight';     
colormap parula; colorbar;
axis([xmin xmax zmin zmax]);
grid on; set(gcf,'Color','White');