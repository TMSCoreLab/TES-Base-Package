%   This is an electrode processor script: it imprints an arbitrary number
%   of electrodes
%
%   Copyright SNM 2012-2018

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
M = 80;         %   number of electrodes
strge.NumberOfElectrodes = M; 
Prays = positions(M, pi/2);
strge.PositionOfElectrodes = zeros(M, 3);
for m = 1:M
    d = meshsegtrintersection([0 0 0], Prays(m, :), 1e3, P, t);
    strge.PositionOfElectrodes(m, :) = d(d>0)*Prays(m, :);
end
strge.RadiusOfElectrodes   = 7*ones(1, M); % in mm here
strge.Current = 1e-3*strge.PositionOfElectrodes(:, 2); %  in A 
strge.Current = strge.Current - mean(strge.Current);
test = sum(strge.Current(strge.Current>0));
strge.Current = strge.Current/test;

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
    p.FaceColor = 'c';
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


function [P] = positions(N, theta0)
%   Generate N equidistributed points on the surface of a unit sphere above
%   a certain angle theta0. After Markus Deserno, Max-Planck-Institut fuer¨
%   Polymerforschung, Ackermannweg 10, 55128 Mainz, Germany

%   Copyright SNM 2018
    for M = N:10000
        Ncount = 1;
        a       = 4*pi/M;
        d       = sqrt(a);
        Mtheta  = round(pi/d);
        dtheta  = pi/Mtheta;
        dphi    = a/dtheta;
        for m = 0:Mtheta -1
            theta = pi*(m+0.5)/Mtheta;
            Mphi = round(2*pi*sin(theta)/dphi);
            if theta > theta0; continue; end;
            for n = 0:Mphi-1
                phi = 2*pi*n/Mphi;
                P(Ncount, 1) = sin(theta)*cos(phi);
                P(Ncount, 2) = sin(theta)*sin(phi);
                P(Ncount, 3) = cos(theta);
                Ncount = Ncount + 1;
            end
        end
        if Ncount == N+1; break; end;
    end
end

function d = meshsegtrintersection(orig0, dir0, dist0, P0, t0)
%   SYNTAX
%   d = meshsegtrintersection(orig0, dir0, dist0, P0, t0)
%   DESCRIPTION
%   This function checks whether or not a segment characterized by orig0,
%   dir0, dist0 intersects a manifold mesh P0, t0.
%   Inputs:
%   orig0   - Origin of the segment (1 x 3)
%   dir0    - Normalized direction of the segment from origin (1 x 3)
%   dist0   - Length of the segment (1 x 1)
%   P0, t0  - Triangulation to be tested 
%   Output:
%   d -  Distances of points of intersection from the origin of the segment
%   (N x 1). If there is no intersection, the corresponding field is zero.
%   The tolerance is given internally
%   The function implements the method described in 
%   Tomas Moeller and Ben Trumbore, “Fast, Minimum Storage Ray/Triangle
%   Intersection”, Journal of Graphics Tools, 2(1):21—28, 1997
%   See also
%   http://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
%   http://www.mathworks.com/matlabcentral/fileexchange/33073-triangle-ray-intersection
%   Authors: Vishal Rathi (vkrathi@wpi.edu)
%   Janakinadh Yanamadala (jyanamadala@wpi.edu), SNM (makarov@wpi.edu)
%
%   To display the mesh use: fv.faces = d; fv.vertices = P;
%   patch(fv, 'FaceColor', 'y'); axis equal; view(160, 60); grid on;
%
%   Low-Frequency Electromagnetic Modeling for Electrical and Biological
%   Systems Using MATLAB, Sergey N. Makarov, Gregory M. Noetscher, and Ara
%   Nazarian, Wiley, New York, 2015, 1st ed.

    vert1 = P0(t0(:, 1),:);
    vert2 = P0(t0(:, 2),:);
    vert3 = P0(t0(:, 3),:);
    orig = repmat(orig0, size(vert1, 1),1);             
    dist = repmat(dist0, size(vert1, 1),1);
    dir  = repmat(dir0, size(vert1, 1),1);

    % Initialization of u,v and d
    u = zeros (size(vert1,1),1);
    d = u; v = u;

    % Finding edges
    edge1 = vert2 - vert1;
    edge2 = vert3 - vert1;

    tvec = orig - vert1;                            %   Distance to vert1 from segment origin
    pvec = cross(dir, edge2, 2);                    %   Parameter to calculate u
    det  = dot(edge1, pvec, 2);                     %   Determinant of matrix M
    parallel = abs(det)< 1024*eps*max(abs(det));    %   To test edges parallel with the segment
    if all(parallel)                                %   If all parallel then no intersections
        return;
    end

    det(parallel) = 1;              %   To avoid division by zero
    inv_det = 1.0 ./ det;           %   Find inverse of the determinant
    u = dot(tvec,pvec,2);           %   Calculate the u parameter
    u = u.*inv_det;

    % Conditional tests for u and v
    layer1 = (~ parallel & u<0 | u>1);
    if all(layer1)
        return;
    end

    qvec (~layer1,:) = cross(tvec(~layer1,:), edge1(~layer1,:), 2);             %   Parameter to calculate v
    v (~layer1,:) = dot(dir(~layer1,:),qvec(~layer1,:),2).*inv_det(~layer1,:);  %   Calculate v
    layer2 = (v<=0 | u+v>1);
    if all(layer2)
        return;
    end

    layer = (~layer1&~layer2);
    d(layer,:) = dot(edge2(layer,:),qvec(layer,:),2).*inv_det(layer,:);         %   Calculate d
    d(d<0 | d>dist) = 0;                                                        %   Compare distances and d
    d(parallel) = 0;                                                            %   Avoid values of d in parallel cases
    d(isnan(d))= 0;                                                             %   Avoid NaN (Not-a-Number) when the right-angled triangles are present
end


