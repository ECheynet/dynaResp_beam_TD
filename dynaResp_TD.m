function [Do] = dynaResp_TD(m,z,phi,wn,zetaStruct,Fload,t,varargin)
% [Do] = dynaResp_TD(Geometry,Wind,varargin) computes the time-domain displacement
% response of a line-like structure using direct time integration with the
% Runge-Kutta order 4 or Newmark beta algorithm.
% 
% Input
% m: lineic mass of the structure in kg pr unit length
% z: vector corresponding to the nodes of the structure. z(end) = length of
% the structure
% phi: matrix [Nmodes x Nyy] of eigen modes
% wn: matrix [Nmodes x 1] or [1 x Nmodes ] of eigen frequencies
% zetaStruct: matrix [Nmodes x 1] or [1 x Nmodes ] of structural damping
% Fload: matrix [Nyy x N] of nodal Load (N)
% t: vector [ 1 x N] of time
% varargin: 'method' is either 'RK4' (Runge-Kutta order 4) or 'Newmark'
% (Newmark beta)
%
% Output
% Do: matrix [Nyy x N] of nodal displacement (in meters)
% 
% Author info: 
% Etienne Cheynet - UiB - 28.03.2023
% 

%% Inputparser
p = inputParser();
p.CaseSensitive = false;
p.addOptional('method','Newmark');
p.parse(varargin{:});
% shorthen the variables name
method = p.Results.method ;


%% Initalisation and checks
dt = median(diff(t));
fs = 1/dt;
N = numel(t);
% Definition of Nyy, and Nmodes:
[Nmodes,Nyy]= size(phi);

if fs/2.3<=max(wn)/(2*pi) && strcmpi(method,'RK4'),
    warning(' The Runge-Kutta at order 4 algorith may fail to converge because the sampling frequency is too small with respect to the eigen frequencies of the structure');
end


%% MODAL MASS AND STIFNESS CALCULATION

M = zeros(Nmodes);
for pp=1:Nmodes,
    M(pp,pp)  = trapz(z,m.*phi(pp,:).^2);
end

K = diag(wn(:)).^2*M;
C = 2.*diag(wn(:))*M*diag(zetaStruct(:));


%% INITIALISATION
Do = zeros(Nyy,N);
displResp = zeros(2*Nmodes,Nmodes); %buffeting response matrix


for idt=1:N,
    % get  modal forces
        Fl = repmat(Fload(:,idt),1,Nmodes)';
        Fmodal = trapz(z,Fl.*phi,2);
        Fmodal = diag(Fmodal(:));
    % Numerical solver
    if strcmpi(method,'RK4'),
        % Runge Kutta Method
        [Do(:,idt),Vo,displResp] = solveWithRK(displResp,M,K,C,Nmodes,Fmodal,t(idt),dt);
      
    elseif strcmpi(method,'Newmark'),
        if idt ==1,
            % initial acceleration
            DoM = zeros(size(M));
            VoM = zeros(size(M));
            AoM = M\(Fmodal-C.*VoM-K.*DoM);
            [DoM,VoM,AoM,Do(:,idt),Vo] = Newmark(dt,DoM,VoM,AoM,Fmodal,M,K,C);
        else
            [DoM,VoM,AoM,Do(:,idt),Vo] = Newmark(dt,DoM,VoM,AoM,Fmodal,M,K,C);
        end
    else
        error('Numerical method unknown');
    end
end





    function [Do,Vo,Resp] = solveWithRK(Resp,M,K,C,Nmodes,Fmodal,t,dt)
        
        inputBuff.A = [zeros(Nmodes), eye(Nmodes);-M\K,-M\C];
        inputBuff.F =[zeros(Nmodes,Nmodes);M\Fmodal];
        inputBuff.Y= Resp;
        
        dYdT = @(Y,A,F) A*Y+ F;% function for RG 4: [Y' = AY + F] -> cf state space model for 2nd  Newtown law
        [Resp] = RK4(dYdT,dt,inputBuff); % is [2*3*Nmodes,3*Nmodes]
               
        doModal=diag(Resp(1:Nmodes,:));
        voModal=diag(Resp(Nmodes+1:2*Nmodes,:));
        Do = phi'*doModal;
        Vo = phi'*voModal;
        
        
        
        
        
    end
    function [y] = RK4(Fun,dt,inputFun)
        %% 4th order
        Y = inputFun.Y;
        F = inputFun.F;
        A = inputFun.A;
        
        k_1 = Fun(Y,A,F);
        k_2 = Fun(Y+0.5*dt*k_1,A,F);
        k_3 = Fun(Y+0.5*dt*k_2,A,F);
        k_4 = Fun(Y+k_3*dt,A,F);
        
        y = Y + (1/6)*(k_1+2*k_2+2*k_3+k_4)*dt;  % main equation
    end
    function [x1,dx1,ddx1,Do,Vo] = Newmark(dt,x0,dx0,ddx0,F,M,K,C,varargin)
        % options: default values
        inp = inputParser();
        inp.CaseSensitive = false;
        inp.addOptional('alpha',1/12);
        inp.addOptional('beta',1/2);
        inp.parse(varargin{:});
        % shorthen the variables name
        alphaCoeff = inp.Results.alpha ;
        beta = inp.Results.beta;
        
        aDT2 = (alphaCoeff.*dt.^2);
        aDT = (alphaCoeff.*dt);
        
        A = (1./aDT2.*M+beta/aDT*C+K);
        B1 = F+M.*(1./aDT2*x0+1./aDT*dx0+(1/(2*alphaCoeff)-1)*ddx0);
        B2 = C.*(beta/aDT*x0+(beta/alphaCoeff-1).*dx0);
        B3 = C.*((beta/alphaCoeff-2)*dt/2*ddx0);
        
        x1 = A\(B1+B2+B3);
        ddx1= 1/aDT2.*(x1-x0)-1/aDT.*dx0-(1/(2*alphaCoeff)-1).*ddx0;
        dx1= dx0+(1-beta).*dt*ddx0+beta.*dt*ddx1;
        
        x2=diag(x1);
        dx2=diag(dx1);
        
        Do = phi'*x2;
        Vo = phi'*dx2;
        
        
        
    end

end