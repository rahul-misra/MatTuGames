function [kCRGP kCRGPC]=k_Converse_RGP_Q(clv,x,K,str,tol)
% k_Converse_RGP_Q checks whether an imputation x satisfies the k-CRGP, 
% that is, the k-converse reduced game property (k-converse consistency).
%
% Usage: [kCRGP kCRGPC]=clv.k_Converse_RGP_Q(x,K,str,tol)
%
% Define variables:
%  output: Fields
%  CrgpQ    -- Returns 1 (true) whenever the k-CRGP is satisfied, 
%              otherwise 0 (false).
%  crgpQ    -- Gives a precise list of reduced games for which the 
%              restriction of x on S is a solution of the reduced game vS. 
%              It returns a list of zeros and ones.
%  vS       -- All Davis-Maschler or Hart-MasColell reduced games on S at x 
%              with k-players.
%  sV_x     -- Returns a vector of extended solutions x_s to x_N for 
%              all reduced games vS.              
%  input:
%  clv      -- TuGame class object.
%  x        -- payoff vector of size(1,n). Must be efficient.
%  K        -- An integer value equal to or greater than 2, 
%              but not larger than n.
%  str      -- A string that defines different Methods. 
%              Permissible methods are: 
%              'PRN' that is, the Davis-Maschler reduced game 
%               in accordance with the pre-nucleolus.
%              'PRK' that is, the Davis-Maschler reduced game 
%               in accordance with pre-kernel solution.
%              'SHAP' that is, the Hart-MasColell reduced game
%               in accordance with the Shapley value.
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
  K=2;
elseif nargin<3
  tol=10^6*eps;
  str='PRK';
  K=2;
elseif nargin<4
  tol=10^6*eps;
  str='PRK';
elseif nargin<5
  tol=10^6*eps;
else
  tol=10^6*eps;
end

S=1:N;
PlyMat=false(N,n);
for k=1:n, PlyMat(:,k) = bitget(S,k)==1;end

% Checking now whether the imputation solves the reduced game for 
% every K-player coalitions.
sumPM=PlyMat*ones(n,1);
slcl2=sumPM==K;
cl2=S(slcl2);
PlyMat2=PlyMat(cl2,:);
siPM2=size(PlyMat2,1);


vS=cell(1,siPM2);
stdsol=cell(1,siPM2);
crgpq=cell(1,siPM2);
crgpQ=false(1,siPM2);
sV_x=cell(1,siPM2);
rS=cell(1,siPM2);

for k=1:siPM2
sV_x{1,k}=x;
 if strcmp(str,'SHAP')
   vS{1,k}=clv.HMS_RedGame(x,cl2(k)); %Hart-MasColell reduced game.
   stdsol{1,k}=ShapleyValue(vS{1,k}); % solution x restricted to S.
   rS{k}=PlyMat2(k,:);
   sV_x{1,k}(rS{k})=stdsol{1,k}; % extension to (x,x_N\S).
   crgpq{k}=abs(sV_x{1,k}-x)<tol;
   crgpQ(k)=all(crgpq{k});
 elseif strcmp(str,'PRK')
   rS{k}=PlyMat2(k,:);
   vS{1,k}=clv.RedGame(x,cl2(k)); % Davis-Maschler reduced game.
   stdsol{1,k}=PreKernel(vS{1,k},x(rS{k})); % solution x restricted to S.
   sV_x{1,k}(rS{k})=stdsol{1,k}; % extension to (x,x_N\S).
   crgpQ(k)=clv.PrekernelQ(sV_x{1,k});
 elseif strcmp(str,'PRN')
   rS{k}=PlyMat2(k,:);
   vS{1,k}=clv.RedGame(x,cl2(k)); % Davis-Maschler reduced game.
   try
     stdsol{1,k}=Prenucl(vS{1,k},x(rS{k})); % solution x restricted to S.
   catch
     stdsol{1,k}=PreNucl2(vS{1,k},x(rS{k})); % use a third party solver instead!
   end
   sV_x{1,k}(rS{k})=stdsol{1,k}; % extension to (x,x_N\S).
   crgpq{k}=abs(sV_x{1,k}-x)<tol;
   crgpQ(k)=all(crgpq{k});
 else
   rS{k}=PlyMat2(k,:);
   vS{1,k}=clv.RedGame(x,cl2(k)); % Davis-Maschler reduced game.
   stdsol{1,k}=PreKernel(vS{1,k},x(rS{k})); % solution x restricted to S.
   sV_x{1,k}(rS{k})=stdsol{1,k}; % extension to (x,x_N\S).
   crgpQ(k)=clv.PrekernelQ(sV_x{1,k});
  end
end
CrgpQ=all(crgpQ);
%Formatting Output
if nargout>1
 kCRGP=struct('CrgpQ',CrgpQ,'crgpQ',crgpQ);
 kCRGPC={'vS',vS,'sV_x',sV_x};
else
  kCRGP=struct('CrgpQ',CrgpQ,'crgpQ',crgpQ);
end
