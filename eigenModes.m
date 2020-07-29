function [phi,wn] = eigenModes(geometry,BC,Nmodes)
% 
% [phi,wn] = eigenModes(geometry,BC,Nmodes) computes eigen frequencies and
% mode shapes of a beam with different boundary conditions.
% 
% Input
% geometry: structure with fields defined in the Example.m file
% BC : 1,2,3 or 4 : Boundaries conditions (cf Example.m)
% Nmodes : Number of modes wished
% 
% Output
% Phi : Matrix of mode shapes is a [Nmodes x Nz] vector.
% wn is a  vector of size [1 x Nmodes ] in rad/sec.
% 
% Example: case of a beam with a circular cross section with a constant diameter D
% clearvars;clc;close all;
% geometry.L = 100; % beam length (m)
% D = geometry.L/20; % beam diameter (m) 
% geometry.E = 2.1e11; % Young Modulus (Pa)
% geometry.nu = 0.3; % Poisson ratio
% geometry.rho = 7850; % density (kg/m^3)
% geometry.I = pi.*D.^4./64; % affectation of quadratic moment
% geometry.y = linspace(0,geometry.L ,100); % number of discretisation points for the beam
% geometry.m = geometry.rho.*(pi.*D.^2*geometry.L)./geometry.L; % mass of the beam per unit length
% Nmodes =4; % number of mode wanted
% BC = 1; % pinned-pinned
% [phi,wn] = eigenModes(geometry,BC,Nmodes);
% 
% Author info
% E. Cheynet - UiS - last modified: 11.02.2018
% 


%%  check input

if ~isnumeric(BC),    error('BC must be an integer between 1 and 4');end
if max(ismember([1,2,3,4],BC))==0,    error('BC is unknown. Please, choose BC = 1,2,3 or 4');end
if ~isnumeric(Nmodes),    error('Nmodes must be an integer');end

name = [{'L'},{'E'},{'rho'},{'I'},{'y'},{'m'}];
for ii=1:numel(name),
    if ~isfield(geometry,name{ii}),
        error([' The field ',name{ii},' is missing in the structure "geometry".'])
    end
end

%%
y= geometry.y;
Nz = numel(y); % number of discrete elements

% volume V and mass m of the beam
m = geometry.m;
L = geometry.L;

% get the non trivial solution of f

if Nmodes<10,
    Ndummy=1:Nmodes^2; % the number is arbitrary fixed as the square of the number of Nmodes.
else
    Ndummy=1:100; % the number is arbitrary fixed as the square of the number of Nmodes.
end
tolX = 1e-8;
tolFun = 1e-8;
options=optimset('TolX',tolX,'TolFun',tolFun,'Display','off');
h =fsolve(@modeShape,Ndummy,options);
% small values of h come from numerical errors
h(h<0.4)=[];
% Analytically, many solutions are identical to each other, but numerically, it is not the
% case. Therefore I need to limit the prceision of the solutions to 1e-4.
h = round(h*1e4).*1e-4;
% the uniques solution are called beta:
beta = unique(h);
beta = beta(1:min(numel(beta),Nmodes));



%modes shapes calculations
if Nmodes>numel(beta),
    warning([' Mode shape required is too high. The number is set to',num2str(numel(beta)),' \n\n'])
    Nmodes=numel(beta)
end
wn = beta.^2.*sqrt(geometry.E*geometry.I./(m.*geometry.L^4)); % in rad
phi = zeros(Nmodes,Nz);

for ii=1:Nmodes,
    switch BC,
        
        
        case 1,% pinned-pinned
            phi(ii,:)=sin(beta(ii)*y./L);
            
            phi(ii,:)=phi(ii,:)./max(abs(phi(ii,:)));
            
            
        case 2 % clamped-free
            
            phi(ii,:)=(cosh(beta(ii)*y./L)-cos(beta(ii)*y./L))+...
                ((cosh(beta(ii))+cos(beta(ii))).*(sin(beta(ii)*y./L)-sinh(beta(ii)*y./L)))./...
                (sin(beta(ii))+sinh(beta(ii)));
            
            phi(ii,:)=phi(ii,:)./max(abs(phi(ii,:)));
            
            
        case 3 % clamped-clamped
            
            phi(ii,:)=sin(beta(ii)*y./L)-sinh(beta(ii)*y./L)-...
                ((sin(beta(ii))-sinh(beta(ii))).*(cos(beta(ii)*y./L)-cosh(beta(ii)*y./L)))./...
                (cos(beta(ii))-cosh(beta(ii)));
            
            phi(ii,:)=phi(ii,:)./max(abs(phi(ii,:)));
            
            
            
        case 4 % clamped-pinned
            
            phi(ii,:)=sin(beta(ii)*y./L)-sinh(beta(ii)*y./L)-...
                ((sin(beta(ii))-sinh(beta(ii))).*(cos(beta(ii)*y./L)-cosh(beta(ii)*y./L)))./...
                (cos(beta(ii))-cosh(beta(ii)));
            
            phi(ii,:)=phi(ii,:)./max(abs(phi(ii,:)));
    end
    
end



% Function to solve is different for each BC:

    function [f] = modeShape(y)
        switch BC,
            case 1,% pinned-pinned
                f=sin(y).*sinh(y);
            case 2 % clamped-free
                f=cos(y).*cosh(y)+1;
            case 3 % clamped-clamped
                f=cos(y).*cosh(y)-1;
            case 4 % clamped-pinned
                f=cos(y).*sinh(y)-sin(y).*cosh(y);
        end
    end

end

