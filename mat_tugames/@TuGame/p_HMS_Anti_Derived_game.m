function v_t=p_HMS_Anti_Derived_game(clv,x,str)
% P_HMS_ANTI_DERIVED_GAME computes from (v,x,S) a modified Hart-Mas-Colell anti-derived game vS on S at x for
% game v using Matlab's PCT.
%
%
% Source:  H. I. Meinhardt. The Modiclus Reconsidered. Technical report, Karlsruhe Institute of Technology (KIT), Karlsruhe, Germany,
%          2018. URL http://dx.doi.org/10.13140/RG.2.2.32651.75043.
%
%          Meinhardt (2018), "Analysis of Cooperative Games with Matlab and Mathematica".
%
%
% Usage: vt=clv.p_HMS_Anti_Derived_game(x)
%
% Define variables:
%
%  output:
%  v_t     -- A set of modified Davis-Maschler anti-derived game vS w.r.t. x.
%
%  input:
%  clv      -- TuGame class object.
%  x        -- payoff vector of size(1,n).
%  str      -- A string that defines different Methods.
%              Permissible methods are:
%              'APRN' that is, the Hart-MasColell anti-derived game
%               in accordance with the anti-pre-nucleolus.
%              'MODIC' that is, the Hart-MasColell anti-derived game
%               equivalence in accordance with the modiclus.
%              'APRK' that is, the Hart-MasColell anti-derived game
%               in accordance with anti-pre-kernel solution.
%              'SHAP' that is, Hart-MasColell anti-derived game
%               in accordance with the Shapley Value,
%               which is, the original definition.
%              Default is 'SHAP'.
%


%
%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   03/01/2018        1.0             hme
%                



if nargin<2
  x=clv.ShapleyValue;
  n=clv.tuplayers;
  str='SHAP';
elseif nargin<3
  str='SHAP';
  n=clv.tuplayers;
else
  n=clv.tuplayers;
end

v=clv.tuvalues;
N=clv.tusize;


exc_v=clv.excess(x);
dv=clv.dual_game();
exc_dv=excess(dv,x);
[sx_v,idx_v]=sort(exc_v,'ascend');
[sx_dv,idx_dv]=sort(exc_dv,'ascend');
mx_v=sx_v(1);
mx_dv=sx_dv(1);
v_t=cell(1,N-1);
%dv_t=cell(2,N-1);

vSa=clv.p_HMS_AntiReduced_game(x,str);
vS=vSa{:,1};
clear vSa;
dvSa=p_HMS_AntiReduced_game(dv,x,str);
dvS=dvSa{:,1};
clear dvSa;


parfor k=1:N-1
    mv=min(vS{1,k}-mx_v,dvS{1,k}-mx_dv);
    mv(end)=vS{1,k}(end);
    v_t{1,k}=mv;
end
v_t{1,N}=min(v-mx_v,dv-mx_dv);
v_t{1,N}(end)=v(N);
