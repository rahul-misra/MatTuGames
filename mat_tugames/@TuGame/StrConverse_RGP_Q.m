function [CRGP CRGPC]=StrConverse_RGP_Q(clv,x,str,tol)
% StrConverse_RGP_Q checks whether an imputation x satisfies the strong CRGP, 
% that is, the strong converse reduced game property (converse consistency). 
% Note that, strong CRGP is stronger than the usual definition of CRGP, 
% since it checks whether CRGP holds for all S subsets of N.
%
% Usage: [CRGP CRGPC]=clv.StrConverse_RGP_Q(x,str,tol)
%
% Define variables:
%  output: Fields
%  CrgpQ    -- Returns 1 (true) whenever the strong CRGP is satisfied, 
%              otherwise 0 (false).
%  crgpQ    -- Gives a precise list of reduced games for which the 
%              restriction of x on S is a solution of the reduced game vS. 
%              It returns a list of zeros and ones.
%  vS       -- All Davis-Maschler or Hart-MasColell reduced games on S at x.
%  impVec   -- Returns a vector of restrictions of solution x on S for all S. 
%  sV_sol   -- Returns a vector of solutions x_s for all reduced games vS.
%  sV_x     -- Returns a vector of extended solutions x_s to x_N for 
%              all reduced games vS.              
%
%  input:
%  clv      -- TuGame class object.
%  x        -- payoff vector of size(1,n). Must be efficient.
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
%               in accordance with the pre-nucleolus.
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

v=clv.tuvalues;
N=clv.tusize;
n=clv.tuplayers;


if nargin<2
   if isa(clv,'TuSol')
      x=clv.tu_prk;
   elseif isa(clv,'p_TuSol')
      x=clv.tu_prk;
   else
      x=clv.PreKernel();
   end
   if isempty(x)
     x=clv.PreKernel();
   end
  tol=10^6*eps;
  str='PRK';
elseif nargin<3
  tol=10^6*eps;
  str='PRK';
elseif nargin<4
  tol=10^6*eps;
else
  tol=10^6*eps;
end

S=1:N;
crgpQ=false(1,N);
PlyMat=false(N,n);
for k=1:n, PlyMat(:,k) = bitget(S,k)==1;end

crgpq=cell(1,N);
impVec=cell(1,N);
sV_sol=cell(1,N);
sV_x=cell(1,N);
rS=cell(1,N);

vS=cell(2,N);
if strcmp(str,'SHAP')
  vS=clv.HMS_Reduced_game(x,'SHAP');
elseif strcmp(str,'HMS_PK')
  vS=clv.HMS_Reduced_game(x,'PRK');
elseif strcmp(str,'HMS_PN')
  vS=clv.HMS_Reduced_game(x,'PRN');
else
  vS=clv.DM_Reduced_game(x);
end


for k=1:N-1
 sV_x{1,k}=x;
 impVec{1,k}=x(PlyMat(k,:));
  if strcmp(str,'PRK')
    sV_sol{1,k}=PreKernel(vS{1,k},impVec{1,k});  % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  elseif strcmp(str,'PRN')
    if length(impVec{1,k})==1
       sV_sol{1,k}=PreKernel(vS{1,k},impVec{1,k});
       rS{k}=PlyMat(k,:);
       sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
    else
       try
         sV_sol{1,k}=Prenucl(vS{1,k}); % solution x restricted to S.
       catch
         sV_sol{1,k}=PreNucl(vS{1,k}); % use a third party solver instead!
       end
       rS{k}=PlyMat(k,:);
       sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
    end
  elseif strcmp(str,'SHAP')
    sV_sol{1,k}=ShapleyValue(vS{1,k}); % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  else
    sV_sol{1,k}=PreKernel(vS{1,k},impVec{1,k});  % solution x restricted to S.
    rS{k}=PlyMat(k,:);
    sV_x{1,k}(rS{k})=sV_sol{1,k}; % extension to (x,x_N\S).
  end
  crgpq{k}=abs(sV_x{1,k}-x)<tol;
  crgpQ(k)=all(crgpq{k});
end

if strcmp(str,'PRK')
  sV_sol{1,N}=clv.PreKernel(x);
elseif strcmp(str,'PRN')
  try
    sV_sol{1,N}=clv.Prenucl();
  catch
    sV_sol{1,N}=clv.PreNucl();
  end
elseif strcmp(str,'SHAP')
  sV_sol{1,N}=clv.ShapleyValue();
else
  sV_sol{1,N}=clv.PreKernel(x);
end
crgpq{N}=abs(sV_sol{1,N}-x)<tol;
crgpQ(N)=all(crgpq{N});
CrgpQ=all(crgpQ);
%Formatting Output
if nargout>1
 CRGP=struct('CrgpQ',CrgpQ,'crgpQ',crgpQ);
 CRGPC={'vS',vS,'sV_x',sV_x};
else
  CRGP=struct('CrgpQ',CrgpQ,'crgpQ',crgpQ);
end
