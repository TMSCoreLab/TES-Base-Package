%   This script accurately computes and displays electric fields sampled in
%   a volume via the FMM method with accurate neighbor integration
%
%   Copyright SNM/WAW 2018-2020

%%  Load/prepare data

xmin = -450e-3;
xmax = +450e-3;
ymin = -450e-3;
ymax = +450e-3;
zmin = -450e-3;
zmax = +450e-3;

%% Define observation points in the volume
Ms = 50;
x = linspace(xmin, xmax, Ms);
y = linspace(ymin, ymax, Ms);
z = linspace(zmin, zmax, Ms);
[X, Y, Z]  = meshgrid(x, y, z);
clear points;
Ns = length(x)*length(y)*length(z);
points(:, 1) = reshape(X, 1, Ns);
points(:, 2) = reshape(Y, 1, Ns);  
points(:, 3) = reshape(Z, 1, Ns);

%% Find the E-field at each observation point in the volume      
tic
R = 2;          %   precise integration
Esec            = bemf5_volume_field_electric(points, c, P, t, Center, Area, normals, R);
Etotal          = Esec;   
fieldTime       = toc  

%%   Write points to text file
fileID      = fopen('points.pts', 'w');
for m = 1:size(points, 1)
    fprintf(fileID, '%f%f%f\n', points(m, :));
end
fclose(fileID);

%%   Comparison with ANSYS
fid             = fopen('efield_plus_00%_volume.txt');
a               = fscanf(fid, '%f');
clear EA;
EA(:, 1)        = +a(1:3:end);
EA(:, 2)        = +a(2:3:end);
EA(:, 3)        = +a(3:3:end);
EAMAG           = sqrt(dot(EA, EA, 2));
NORMA           = norm(EAMAG);

EM              = Etotal;
EMMAG           = sqrt(dot(EM, EM, 2));
NORMM           = norm(EMMAG);

Error_2norm = norm(EA - EM)/norm(EA)
Diff        = EA - EM;
DiffMAG     = sqrt(dot(Diff, Diff, 2));  
Error_V    = sqrt(sum(DiffMAG.*DiffMAG))/sqrt(sum(EAMAG.*EAMAG))

