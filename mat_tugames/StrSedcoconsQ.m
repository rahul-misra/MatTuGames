function [SCOSED SCOSEDC]=StrSedcoconsQ(v,x,str,tol)
% STRLEDCOCONSQ checks whether an imputation x satisfies satisfies strong small excess difference converse
% consistency (SEDCOCONS), that is, the converse SEDCONS (converse modified consistency).
% Note that, strong SEDCOCONS is stronger than the usual definition of SEDCONS, 
% since it checks whether SEDCONS holds for all S subsets of N.
%
% Source:  H. I. Meinhardt. The Modiclus Reconsidered. Technical report, Karlsruhe Institute of Technology (KIT), Karlsruhe, Germany,
%          2018. URL http://dx.doi.org/10.13140/RG.2.2.32651.75043.
%
%          Meinhardt (2018), "Analysis of Cooperative Games with Matlab and Mathematica".
%
% Usage: [SCOSED SCOSEDC]=StrSedcoconsQ(v,x,str,tol)
%
% Define variables:
%
%  output: Fields
%  CrgpQ    -- Returns 1 (true) whenever the StrSedcocons is satisfied, 
%              otherwise 0 (false).
%  crgpQ    -- Gives a precise list of reduced games for which the 
%              restriction of x on S is a solution of the reduced game vS. 
%              It returns a list of zeros and ones.
%  vS       -- All Davis-Maschler or Hart-MasColell reduced games on S at x.
%  impVec   -- Returns a vector of restrictions of solution x on S for all S. 
%  sV_sol   -- Returns a vector of solutions x_s for all reduced games vS.
%  sV_x     -- Returns a vector of extended solutions x_s to x_N for 
%              all reduced games vS.              
%  input:
%  v        -- A Tu-Game v of length 2^n-1. 
%  x        -- payoff vector of size(1,n). Must be efficient.
%  str      -- A string that defines different Methods. 
%              Permissible methods are: 
%              'MAPRK' that is, the Davis-Maschler anti-reduced game 
%               in accordance with the modified anti-pre-kernel solution.
%              'PMAPRK' that is, the Davis-Maschler anti-reduced game 
%               in accordance with the proper modified anti-pre-kernel solution.
%              'SHAP' that is, Hart-MasColell anti-reduced game 
%               in accordance with the Shapley Value.
%              'MODIC' that is, the Davis-Maschler anti-reduced game
%               equivalence in accordance with the modiclus.
%              'APRN' that is, the Davis-Maschler anti-reduced game 
%               in accordance with the anti-pre-nucleolus.
%              'APRK' that is, the Davis-Maschler anti-reduced game 
%               in accordance with anti-pre-kernel solution.
%              'HMS_APK' that is, Hart-MasColell anti-reduced game 
%               in accordance with the anti-pre-kernel solution.
%              'HMS_APN' that is, Hart-MasColell anti-reduced game 
%               in accordance with the anti-pre-nucleous.
%              Default is 'MPRK'.
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
%   03/10/2018        1.0             hme
%                


if nargin<2
  x=Anti_ModPreKernel(v);
  n=length(x);
  tol=10^6*eps;
  str='MAPRK';
elseif nargin<3
  n=length(x);
  tol=10^6*eps;
  str='MAPRK';
elseif nargin<4
  n=length(x);
  tol=10^6*eps;
else
  n=length(x);
end

N=length(v);
S=1:N;
crgpQ=false(1,N);
PlyMat=false(N,n);
for k=1:n, PlyMat(:,k) = bitget(S,k)==1;end

crgpq=cell(1,N);
impVec=cell(1,N);
sV_sol=cell(1,N);
sV_x=cell(1,N);
rS=cell(1,N);

v_x=ECFloorGame(v,x);

vS=cell(2,N);
if strcmp(str,'SHAP')
  vS=HMS_AntiReduced_game(v,x,'SHAP');
elseif strcmp(str,'HMS_AMPK')
  vS=HMS_AntiReduced_game(v,x,'APRK');
elseif strcmp(str,'HMS_APMPK')
  vS=HMS_AntiReduced_game(v_x,x,'APRK');
else
  vS=DM_AntiReduced_game(v_x,x);
end


for k=1:N-1
 sV_x{1,k}=x;
 impVec{1,k}=x(logical(PlyMat(k,:)));
  if strcmp(str,'MAPRK')
    sV_sol{1,k}=Anti_ModPreKernel(vS{1,k},impVec{1,k});  % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  elseif strcmp(str,'PMAPRK')
    sV_sol{1,k}=Anti_PModPreKernel(vS{1,k},impVec{1,k});  % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  elseif strcmp(str,'MODIC')
    if length(impVec{1,k})==1
       sV_sol{1,k}=Modiclus(vS{1,k},impVec{1,k});
       rS{k}=PlyMat(k,:);
       sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
    else
       try
         sV_sol{1,k}=cplex_modiclus(vS{1,k}); % solution x restricted to S.
       catch
         sV_sol{1,k}=Modiclus(vS{1,k}); % use a third party solver instead!
       end
       rS{k}=PlyMat(k,:);
       sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
    end
  elseif strcmp(str,'APRK')
    sV_sol{1,k}=Anti_PreKernel(vS{1,k},impVec{1,k});  % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  elseif strcmp(str,'APRN')
    if length(impVec{1,k})==1
       sV_sol{1,k}=Anti_PreKernel(vS{1,k},impVec{1,k});
       rS{k}=PlyMat(k,:);
       sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
    else
       try
         sV_sol{1,k}=cplex_AntiPreNucl_llp(vS{1,k}); % solution x restricted to S.
       catch
         sV_sol{1,k}=Anti_PreNucl_llp(vS{1,k}); % use a third party solver instead!
       end
       rS{k}=PlyMat(k,:);
       sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
    end
  elseif strcmp(str,'SHAP')
    sV_sol{1,k}=ShapleyValue(vS{1,k}); % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  else
    sV_sol{1,k}=Anti_ModPreKernel(vS{1,k},impVec{1,k});  % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  end
  crgpq{k}=abs(sV_x{1,k}-x)<tol;
  crgpQ(k)=all(crgpq{k});
end

if strcmp(str,'MAPRK')
  sV_sol{1,N}=Anti_ModPreKernel(v,x);
elseif strcmp(str,'PMAPRK')
  sV_sol{1,N}=Anti_PModPreKernel(v,x);
elseif strcmp(str,'MODIC')
  try
    sV_sol{1,N}=cplex_modiclus(v);
  catch
    sV_sol{1,N}=Modilcus(v); % use a third party solver instead!
  end
elseif strcmp(str,'APRK')
  sV_sol{1,N}=Anti_PreKernel(v,x);
elseif strcmp(str,'APRN')
  try
    sV_sol{1,N}=cplex_AntiPreNucl_llp(v);
  catch
    sV_sol{1,N}=Anti_PreNucl_llp(v); % use a third party solver instead!
  end
elseif strcmp(str,'SHAP')
  sV_sol{1,N}=ShapleyValue(v);
else
  sV_sol{1,N}=ModPreKernel(v,x);
end
crgpq{N}=abs(sV_sol{1,N}-x)<tol;
crgpQ(N)=all(crgpq{N});
CrgpQ=all(crgpQ);
%Formatting Output 
if nargout>1
 SCOSED=struct('SEDCOCQ',CrgpQ,'sedcocQ',crgpQ);
 SCOSEDC={'vS',vS,'sV_x',sV_x};
else
 SCOSED=struct('SEDCOCQ',CrgpQ,'sedcocQ',crgpQ);
end
