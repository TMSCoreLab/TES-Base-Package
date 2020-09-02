function [E] = bemf4_surface_field_electric_accurate(c, Center, Area, integralxd, integralyd, integralzd, ineighborE)                                                                         

%   This function computes CONTINUOUS electric field and the full potential
%   on a surface facet due to charges on ALL OTHER facets including
%   accurate neighbor integrals. Self-terms causing discontinuity may not
%   be included for electric field
%   To obtain the true field/potential, divide the result(s) by eps0;
%   Copyright SNM 2017-2020    
   
    %  FMM 2019   
    %----------------------------------------------------------------------
    %   Fields plus potentials of surface charges
    %   FMM plus correction
    tic
    const           = 1/(4*pi);
    prec             = 1e-1;
    pg              = 2;
    srcinfo.sources = Center';
    srcinfo.charges = (c.*Area)';
    U               = lfmm3d(prec, srcinfo, pg);
    P               = +U.pot';
    E               = -U.grad'; 
    M = size(Center, 1); 
    for m = 1:M            
        index = ineighborE(:, m);                  
        E(index, :) = E(index, :)   + c(m)*[integralxd(:, m) integralyd(:, m) integralzd(:, m)];                                                   
    end       
    E = const*E;
    toc 
    
end
