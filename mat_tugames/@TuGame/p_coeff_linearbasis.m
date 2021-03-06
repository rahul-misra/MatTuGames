function [lcf, lb]=p_coeff_linearbasis(clv,method)
% P_COEFF_LINEARBASIS computes the coeffients of the linear basis of
% game v using Matlab's PCT.
% For n>12 this function needs some time to complete.
%
% Usage: [lcf lb]=p_coeff_linearbasis(clv,method)
%
% Define variables:
%  output:
%  lcf      -- Coeffients of the linear basis of a game v.
%  lb       -- linear basis of game v.
%
%  input:
%  clv    -- TuGame class object.
%  method   -- A string to format the matrix. Permissible methods
%              to format the matrices are 'full','sparse' or the
%              empty string '', to invoke the default, which is sparse.

%

%  Author:        Holger I. Meinhardt (hme)
%  E-Mail:        Holger.Meinhardt@wiwi.uni-karlsruhe.de
%  Institution:   University of Karlsruhe (KIT)  
%
%  Record of revisions:
%   Date              Version         Programmer
%   ====================================================
%   06/21/2013        0.4             hme
%   02/15/2014        0.5             hme
%                

v=clv.tuvalues;
n=clv.tuplayers;
if nargin < 2
   method='sparse';
else
   if isempty(method)
      method='sparse';
   end
end


lb=p_linear_basis(n,method);
lcf=(lb\v')';
if nargout==2
   if strcmp(method,'full')
      lb=full(lb);
   end
end
