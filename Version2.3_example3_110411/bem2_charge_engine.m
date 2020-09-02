%   This script computes the induced surface charge density for an
%   inhomogeneous multi-tissue object given the primary electric field, with
%   accurate neighbor integration
%
%   Copyright SNM/WAW 2017-2020

%%  Parameters of the iterative solution
iter         = 25;                      %    Maximum possible number of iterations in the solution 
relres       = 1e-12;                   %    Minimum acceptable relative residual 
weight       = 1/2;                     %    Weight of the charge conservation law to be added (empirically found)
weightP      = 1./full(spdiags(PC, 0)); %    Weight of the TES integral equation

%%  Right-hand side b of the matrix equation Zc = b
%   Surface charge density is normalized by eps0: real charge density is eps0*c
tic
b           = zeros(size(t, 1), 1);         %  Right-hand side of the matrix equation
b(indexe)   = weightP(indexe).*V(indexe);   %  Electrodes held at constant voltage
                       

%%  GMRES iterative solution (native MATLAB GMRES is used)
h           = waitbar(0.5, 'Please wait - Running MATLAB GMRES');
tic;
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

%%  Check the residual of the integral equation
solution_error = resvec(end)/resvec(1)

%%   Topological low-pass solution filtering (repeat if necessary)
%c = (c.*Area + sum(c(tneighbor).*Area(tneighbor), 2))./(Area + sum(Area(tneighbor), 2));

%%  Save solution data (surface charge density, principal value of surface field)
tic
save('output_charge_solution', 'c', 'resvec', 'conservation_law_error', 'solution_error');

%%   Find and save surface electric potential and surface electric field
h           = waitbar(0.5, 'Please wait - Calculating surface electric field and potential');
tic
[Ptot, Eadd] = bemf4_surface_field_electric_subdiv(c, P, t, Area, 'barycentric', 3);
disp([newline 'Surface E-field/potential calculated in ' num2str(toc) ' s']);
%Eadd_time = toc
close(h);

tic
save('output_efield_solution.mat', 'Ptot', 'Eadd');
disp([newline 'E-field/potential solution saved in ' num2str(toc) ' s']);
%saveEfieldSolution_time = toc

%%   Find the total electrode current
electrodeCurrents = zeros(length(ElectrodeIndexes), 1);
Enoutside       = condin./(condin-condout).*c; 
for j = 1:length(ElectrodeIndexes)
    index = ElectrodeIndexes{j};
    %Note: cond(1) is the conductivity of the skin surface
    electrodeCurrents(j) = cond(1)*sum(Enoutside(index).*Area(index));
end

electrodeCurrents