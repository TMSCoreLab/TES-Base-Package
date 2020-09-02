%   This script computes and plots the electric field just inside/outside
%   any brain compartment surface (plots the surface field + optionally
%   coil geometry).
%
%   Copyright SNM/WAW 2017-2020

%%   Find the E-field just inside or just outside any model surface
par = -1;    %      par=-1 -> E-field just inside surface; par=+1 -> E-field just outside surface     
Einside  = Eadd + par/(2)*normals.*repmat(c, 1, 3);    %   full field
par = +1;    %      par=-1 -> E-field just inside surface; par=+1 -> E-field just outside surface  
Eoutside = Eadd + par/(2)*normals.*repmat(c, 1, 3);    %   full field

%%  Find total, normal, and tangential fields just inside
Einside_n   = sum(Einside.*normals, 2);             %   this is a projection onto the normal vector (directed outside!)
temp        = normals.*repmat(Einside_n, 1, 3);
Einside_t   = Einside - temp;                       %   this is the tangential field
Einside_t   = sqrt(dot(Einside_t, Einside_t, 2));   %   this is the magnitude of the tangential field
Einside_m   = sqrt(dot(Einside, Einside, 2));       %   this is the magnitude of the total field           

%%  Find total, normal, and tangential fields just outside
Eoutside_n   = sum(Eoutside.*normals, 2);             %   this is a projection onto the normal vector (directed outside!)
temp        = normals.*repmat(Eoutside_n, 1, 3);
Eoutside_t   = Eoutside - temp;                       %   this is the tangential field
Eoutside_t   = sqrt(dot(Eoutside_t, Eoutside_t, 2));   %   this is the magnitude of the tangential field
Eoutside_m   = sqrt(dot(Eoutside, Eoutside, 2));       %   this is the magnitude of the total field

%%  Select the field for the following plots
tissue_to_plot  = 'WM';
objectnumber    = find(strcmp(tissue, tissue_to_plot));
temp            = Eoutside_m(Indicator==objectnumber);

%%   Graphics
figure;
bemf2_graphics_surf_field(P, t, temp, Indicator, objectnumber);
title(strcat('Solution: E-field (total, normal, or tang.) in V/m - ', tissue{objectnumber}));

% Centerline graphics 
hold on;
plot3(1e-3*pointsline(:, 1), 1e-3*pointsline(:, 2), 1e-3*pointsline(:, 3), '-m', 'lineWidth', 5);

%%  Elecrode graphics
bemf1_graphics_electrodes(P, t(Indicator==1, :), strge, IndicatorElectrodes, -1);

% General
view(124, 46); axis off; camzoom(3)
brighten(0.4);