function x=Anti_PropModPreKernel(clv,x)
%ANTI_PROPMODPREKERNEL computes from (v,x) a proper modified anti-pre-kernel element.
%
%  Inspiered by P. Sudh¨olter. Nonlinear Self Dual Solutions for TU-Games. In Potters J.A.M. Raghavan T.E.S. Ray D. Sen A.
%               Parthasarathy T., Dutta B., editor, Game Theoretical Applications to Economics and Operations Research, volume
%               18 of Theory and Decision Library: Series C, pages 33–50, Boston, MA, 1997b. Springer.
%
%               H. I. Meinhardt. Reconsidering Related Solutions of the Modiclus. Technical report, Karlsruhe Institute of Technology (KIT),
%               Karlsruhe, Germany, 2018. URL http://dx.doi.org/10.13140/RG.2.2.27739.82729.
%
% Usage: [x Lerr smat xarr]=clv.Anti_PropModPreKernel(x)
%
% Define variables:
%  output:
%  x        -- A proper modified anti-pre-Kernel element (output)
%  Lerr     -- List of computed function values of hx and h. 
%  smat     -- Matrix of maximum surpluses.
%  xarr     -- History of computed solution at each iteration step.
%
%  input:

%  x        -- payoff vector of size(1,n) (optional)


%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   03/10/2018        1.0             hme
%


n=clv.tuplayers;

vm=clv.DualFloor();
y=Anti_PreKernel(vm);
x=y(1:n);
