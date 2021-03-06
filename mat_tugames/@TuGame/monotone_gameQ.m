function [mq A]=monotone_gameQ(clv,tol)
% MONOTONE_GAMEQ returns 1 whenever the game v is monotone.
%
%
% Usage: [mq A]=monotone_gameQ(clv,tol)
%
% Define variables:
%  output:
%  mq       -- Returns 1 (true) or 0 (false).
%  A        -- A vector which indicates whether the 
%              marginal contribution of player i are 
%              increasing (1) or not (0).
%  input:
%  clv      -- TuGame class object.
%  tol      -- Tolerance value. By default, it is set to (-2*10^4*eps).
%              (optional) 


%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   10/28/2012        0.3             hme
%                

if nargin<2
   tol=-2*10^4*eps;
end

v=clv.tuvalues;
N=clv.tusize;
n=clv.tuplayers;

A=false(n,1);
S=1:N;
Tni=cell(n,1);
Ti=cell(n,1);
T=cell(n,1);
dv=cell(n,1);
zi=zeros(n,1);
dz=zeros(n,1);

for i=1:n
   zi(i)=bitset(0,i); % empty set.
   dz(i)=v(zi(i))>=tol; 
   Tni{i}=bitget(S,i)==0; % non-empty sets. 
   T{i}=S(Tni{i});
   Ti{i}=bitset(T{i},i);
   dv{i}=v(Ti{i})-v(T{i})>=tol;
   A(i)=all([all(dv{i}),dz(i)]);
end
 
mq=all(A);
