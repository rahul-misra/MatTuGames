function [KRGP KRGPC]=p_k_Reduced_game_propertyQ(v,x,K,str,tol)
% P_K_REDUCED_GAME_PROPERTYQ checks whether an imputation x satisfies the
% k-reduced game property (k-consistency) using Matlab's PCT.
%
% Usage: [KRGP KRGPC]=p_k_Reduced_game_propertyQ(v,x,K,str,tol)
% Define variables:
%  output: Fields
%  rgpQ     -- Returns 1 (true) whenever the RGP is satisfied, 
%              otherwise 0 (false).
%  rgpq     -- Gives a precise list of reduced games for which the 
%              restriction of x on S is a solution of the reduced game vS. 
%              It returns a list of zeros and ones.
%  vS       -- All Davis-Maschler or Hart-MasColell reduced games on S at x.
%  impVec   -- Returns a vector of restrictions of x on all S.
%
%  input:
%  v        -- A Tu-Game v of length 2^n-1. 
%  x        -- payoff vector of size(1,n). Must be efficient.
%  K        -- An integer value equal to or greater than 2,
%              but not larger than n.
%  str      -- A string that defines different Methods. 
%              Permissible methods are: 
%              'PRN' that is, the Davis-Maschler reduced game 
%               in accordance with the pre-nucleolus.
%              'PRK' that is, the Davis-Maschler reduced game 
%               in accordance with pre-kernel solution.
%              'SHAP' that is, Hart-MasColell reduced game 
%               in accordance with the Shapley Value.
%              'HMS_PK' that is, Hart-MasColell reduced game 
%               in accordance with the pre-kernel solution.
%              'HMS_PN' that is, Hart-MasColell reduced game 
%               in accordance with the pre-nucleous.
%              Default is 'PRK'.
%  tol      -- Tolerance value. By default, it is set to 10^6*eps.
%              (optional) 
%              

%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   05/29/2013        0.3             hme
%                



if nargin<2
  x=p_PreKernel(v);
  n=length(x);
  tol=10^6*eps;
  str='PRK';
  K=2;
elseif nargin<3
  n=length(x);
  tol=10^6*eps;
  str='PRK';
  K=2;
elseif nargin<4
  n=length(x);
  tol=10^6*eps;
  str='PRK';
  if K<2 
     K=2;
  elseif K>n
     K=n;
  elseif isinteger(K)==0
     K=round(K);
  end
elseif nargin<5
  n=length(x);
  tol=10^6*eps;
  if K<2
     K=2;
  elseif K>n
     K=n;
  elseif isinteger(K)==0
     K=round(K);
  end
else
  n=length(x);
  if K<2
     K=2;
  elseif K>n
     K=n;
  elseif isinteger(K)==0
     K=round(K);
  end
end

N=length(v);
S=1:N;
it=0:-1:1-n;
PlyMat=rem(floor(S(:)*pow2(it)),2)==1;
% Selecting all coalitons having size K or less.
sumPM=PlyMat*ones(n,1);
slcl2=sumPM<=K;
cl2=S(slcl2);
siPM2=length(cl2);
rgpq=false(1,siPM2);
PlyMat2=PlyMat(slcl2,:);

vS=cell(1,siPM2);
impVec=cell(1,siPM2);
rgpq_sol=cell(1,siPM2);
sol=cell(1,siPM2);


parfor k=1:siPM2
 impVec{k}=x(PlyMat2(k,:)); 
  if strcmp(str,'SHAP')
% Checks whether a solution x restricted to S is a solution of the 
% reduced game vS.
   vS{k}=HMS_RedGame(v,x,cl2(k)); %Hart-MasColell reduced game.
   sol{k}=ShapleyValue(vS{k});
   rgpq_sol{k}=abs(sol{k}-impVec{k})<tol;
   rgpq(k)=all(rgpq_sol{k});
  elseif strcmp(str,'PRK')
% Checks whether a solution x restricted to S is a solution of the 
% reduced game vS.  
   vS{k}=RedGame(v,x,cl2(k)); % Davis-Maschler reduced game.
   rgpq(k)=PrekernelQ(vS{k},impVec{k}); 
  elseif strcmp(str,'PRN')
   vS{k}=RedGame(v,x,cl2(k)); % Davis-Maschler reduced game.
   if length(vS{k})==1
     rgpq(k)=PrekernelQ(vS{k},impVec{k});
   else
     try
        sol{k}=Prenucl(vS{k},impVec{k}); % using adjusted Derks pre-nucleolus function.
     catch
        sol{k}=PreNucl2(vS{k},impVec{k}); % use a third party solver instead!
     end
     rgpq_sol{k}=abs(sol{k}-impVec{k})<tol;
     rgpq(k)=all(rgpq_sol{k});
   end
  elseif strcmp(str,'HMS_PK')
   vS{k}=HMS_RedGame(v,x,cl2(k)); % Hart-MasColell reduced game.
   rgpq(k)=PrekernelQ(vS{k},impVec{k});
  elseif strcmp(str,'HMS_PN')
   vS{k}=HMS_RedGame(v,x,cl2(k)); % Hart-MasColell reduced game.
   if length(vS{k})==1
     rgpq(k)=PrekernelQ(vS{k},impVec{k});
   else
     try
        sol{k}=Prenucl(vS{k},impVec{k}); % using adjusted Derks pre-nucleolus function.
     catch
        sol{k}=PreNucl2(vS{k},impVec{k}); % use a third party solver instead!
     end
     rgpq_sol{k}=abs(sol{k}-impVec{k})<tol;
     rgpq(k)=all(rgpq_sol{k});
   end
  end
end

rgpQ=all(rgpq);
%Formatting Output
if nargout>1
 KRGP=struct('rgpQ',rgpQ,'rgpq',rgpq);
 KRGPC={'vS',vS,'impVec',impVec};
else
  KRGP=struct('rgpQ',rgpQ,'rgpq',rgpq);
end
