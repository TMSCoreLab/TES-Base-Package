%   This script computes the induced surface charge density for an
%   inhomogeneous multi-tissue object given the primary electric field, with
%   accurate neighbor integration
%
%   Copyright SNM/WAW 2017-2020

%%  Parameters of the iterative solution
iter         = 30;                      %    Maximum possible number of iterations in the solution 
relres       = 1e-12;                   %    Minimum acceptable relative residual 
weight       = 1/2;                     %    Weight of the charge conservation law to be added (empirically found)
weightP      = 1./full(spdiags(PC, 0)); %    Weight of the TES integral equation

%%  Right-hand side b of the matrix equation Zc = b
%   Surface charge density is normalized by eps0: real charge density is eps0*c
tic
b           = zeros(size(t, 1), 1);         %  Right-hand side of the matrix equation
b(indexe)   = weightP(indexe).*V(indexe);   %  Electrodes with constant voltage no matteer what
                       

%%  GMRES iterative solution (native MATLAB GMRES is used)
h           = waitbar(0.5, 'Please wait - Running MATLAB GMRES');  
%   MATVEC is the user-defined function of c equal to the left-hand side of the matrix equation LHS(c) = b
MATVEC = @(c) bemf4_surface_field_lhs(c, Center, Area, contrast, normals, weight, weightP, EC, PC, indexe);     
[c, flag, rres, its, resvec] = gmres(MATVEC, b, [], relres, iter, [], [], b); 
close(h);

%%  Plot convergence history
figure; 
semilogy(resvec/resvec(1), '-o'); grid on;
title('Relative residual of the iterative solution');
xlabel('Iteration number');
ylabel('Relative residual');

%%  Check charge conservation law (optional)
conservation_law_error = sum(c.*Area)/sum(abs(c).*Area)

%%  Check the residual of the integral equation
solution_error = resvec(end)/resvec(1)

%%   Topological low-pass solution filtering (repeat if necessary)
%c = (c.*Area + sum(c(tneighbor).*Area(tneighbor), 2))./(Area + sum(Area(tneighbor), 2));

%%  Save solution data (surface charge density, principal value of surface field)
tic
save('output_charge_solution', 'c', 'resvec', 'conservation_law_error', 'solution_error');

%%   Find and save surface electric potential
Padd = bemf4_surface_field_potential_accurate(c, Center, Area, PC);
Ptot = Padd;     %   Continuous total electric potential at interfaces
save('output_efield_solution.mat', 'Ptot');
