function [prkQ smat e]=p_PModPrekernelQ(clv,x,tol)
% P_PMODPREKERNELQ checks whether the imputation x is a proper modified pre-kernel element 
% of the TU-game v.
% 
%  Usage:[prkQ smat e]=clv.P_PModPrekernelQ(x,tol);
%
%
% Define variables:
%  output:
%  prkQ     -- Returns 1 (true) whenever the impuatation x is 
%              a proper modified pre-kernel element, otherwise 0 (false).
%  smat     -- Matrix of maximum surpluses.
%  input:
%  clv      -- TuGame class object.
%  x        -- payoff vector of size(1,n) (optional)
%  tol      -- Tolerance value. By default, it is set to 10^6*eps.
%             (optional) 
%

%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   03/11/2018        1.0              hme
%                


v=clv.tuvalues;
N=clv.tusize;
n=clv.tuplayers;

if nargin < 2
  x=clv.p_PreKernel();
  warning('PKQ:NoPayoffInput','Computing default payoff!');
  tol=10^6*eps;
elseif nargin< 3
  tol=10^6*eps;
end
smat=-inf;
e=0;
effQ=abs(v(end)-sum(x))<tol;
prkQ=false;
if effQ==0, return; end

dv=clv.dual_game();
N1=N+1;
n1=2*n;
N2=2^n1-1;
ii=1;
vs1=zeros(1,N2);
vs2=vs1;
for k=1:N1
    for jj=1:N1
          if k>1 && jj >1
             ii=(k-1)+(jj-1)*N1;
             vs1(ii)=v(k-1)+dv(jj-1);
             vs2(ii)=v(jj-1)+dv(k-1);
           elseif k==1 && jj >1
             ii=N1*(jj-1);
             vs1(ii)=dv(jj-1);
             vs2(ii)=v(jj-1);
           elseif k>1 && jj==1
             ii=k-1;
             vs1(ii)=v(k-1);
             vs2(ii)=dv(k-1);
           end
    end
end
vm=max(vs1,vs2);
y=[x,x];

[e, smat]=p_msrpls(vm,y);
e=e';
lms=abs(smat-smat')<tol;
prkQ=all(all(lms));


%-------------------------------------
function [e, smat]=p_msrpls(v,x)
% Computes the maximum surpluses w.r.t. payoff x.
% output:
%  e        -- Excess vector
%  smat     -- Matrix of maximum surpluses.
%
%  input:
%  v      -- A Tu-Game v of length 2^n-1.
%  x      -- payoff vector of length(1,n)


N=length(v); n=length(x);
% the excesses of x wrt. the game v
% Borrowed from J. Derks
Xm{1}=x(1); for ii=2:n, Xm{1}=[Xm{1} x(ii) Xm{1}+x(ii)]; end
% Determining max surpluses.
v=parallel.pool.Constant(v);
cXm=parallel.pool.Constant(Xm{1});
clear Xm;
spmd
%cv=codistributed(v);
%cXm=codistributed(Xm{1});
e=v.Value-cXm.Value;
[se1, sC1]=sort(e,'descend');
Smat=-inf(n);
end
sC=gather(sC1);
se=gather(se1);
clear sC1 se1;
sC=parallel.pool.Constant(sC);
se=parallel.pool.Constant(se);
q0=n^2-n;
q=0;
k=1;
pl=1:n;
spmd
 while q~=q0
   kS=sC.Value(k);
   ai=bitget(kS,pl)==1;
   bj=ai==0;
   pli=pl(ai);
   plj=pl(bj);
   if isempty(plj)==0
     for i=1:numel(pli)
       for j=1:numel(plj)
         if Smat(pli(i),plj(j))==-Inf
            Smat(pli(i),plj(j))=se.Value(k); % max surplus of i against j.
            q=q+1;
         end
       end
     end
   end
   k=k+1;
 end
end
smat=Smat{1};
smat=tril(smat,-1)+triu(smat,1);
