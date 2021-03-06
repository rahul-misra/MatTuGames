function [v_t,sS,PlyMat2]=HMS_TwoReduced_game(v,x,str)
% HMS_TWOREDUCED_GAME computes from (v,x) all Hart/Mas-Colell 
% singleton and two-person reduced games on S at x of game v.
%
% Usage: v_t=HMS_Reduced_game(v,x,str)
%
% Define variables:
%
%  output:
%  v_t{1,:} -- All Hart-MasColell single and two-person reduced games w.r.t. x.
%  v_t{2,:} -- The corresponding Shapley values of all single and two-person reduced games.
%  v_t{3,:} -- The corresponding sub-coalitions which define a reduced game.
%
%  input:
%  v        -- A Tu-Game v of length 2^n-1. 
%  x        -- payoff vector of size(1,n). Must be efficient.
%  str      -- A string that defines different Methods. 
%              Permissible methods are: 
%              'PRN' that is, the Hart-MasColell reduced game 
%               in accordance with the pre-nucleolus.
%              'PRK' that is, the Hart-MasColell reduced game 
%               in accordance with pre-kernel solution.
%              'SHAP' that is, Hart-MasColell reduced game 
%               in accordance with the Shapley Value, 
%               which is, the original definition. 
%              'MODIC' that is, the Hart-MasColell reduced game 
%               in accordance with the modiclus.
%              Default is 'SHAP'.

%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   08/13/2018        1.0             hme
%                

if nargin<2
  x=ShapleyValue(v);
  n=length(x);
  str='SHAP';
elseif nargin<3
  n=length(x);
  str='SHAP';
elseif nargin<4
  n=length(x);
else
  n=length(x);
end


N=length(v);
S=1:N;
PlyMat=false(N,n);
for k=1:n, PlyMat(:,k) = bitget(S,k)==1;end

sumPM=PlyMat*ones(n,1);
slcl2=sumPM<=2;
sS=S(slcl2);
PlyMat2=PlyMat(slcl2,:);
lS2=length(sS);
  
v_t=cell(3,N-1);

for k=1:lS2
  [v_t{1,k} v_t{2,k} v_t{3,k}]=hms_red_game(v,sS(k),n,str);
end

%---------------------------------
function [vt subg_sh T]=hms_red_game(v,S,n,str)


J=1:n;
lmcS=bitget(S,J)==0;
plcS=J(lmcS);
cSpot=2.^(plcS-1);
cS=cSpot*ones(length(plcS),1);
T=SubSets(S,n);
lgt=length(T);
 

vt=zeros(1,lgt);
TorcS=bitor(T,cS);

subT=cell(1,lgt);
subg=cell(1,lgt);
subg_sh=cell(1,lgt);
lg=cell(1,lgt);
plT=cell(1,lgt);
Tz=cell(1,lgt);
sum_py=cell(1,lgt);

for k=1:lgt
 subT{k}=SubSets(TorcS(k),n);
 subg{k}=v(subT{k});
 if strcmp(str,'SHAP')
   subg_sh{k}=ShapleyValue(subg{k});
 elseif strcmp(str,'PRN')
   if length(subg{k})==1
      subg_sh{k}=subg{k};
   else
      try
        subg_sh{k}=Prenucl(subg{k});
      catch
        subg_sh{k}=PreNucl(subg{k}); % use a thrid party solver instead! 
      end
   end
elseif strcmp(str,'MODIC')
   if length(subg{k})==1
      subg_sh{k}=subg{k};
   else
      try
        subg_sh{k}=cplex_modiclus(subg{k});
      catch
        subg_sh{k}=Modiclus(subg{k}); % use a thrid party solver instead! 
      end
   end
 elseif strcmp(str,'PRK')
   subg_sh{k}=PreKernel(subg{k});
 else
   subg_sh{k}=ShapleyValue(subg{k});
 end
 Qk=TorcS(k);
 it=0:-1:1-n;
 lg{k}=rem(floor(Qk(:)*pow2(it)),2)==1;
 plT{k}=J(lg{k});
 Tz{k}=ismember(plT{k},plcS);
 sum_py{k}=Tz{k}*subg_sh{k}';
 vt(k)=v(TorcS(k))-sum_py{k};
end
