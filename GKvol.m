function sigma_hat = GKvol(O,H,L,Cl,k)
%GKvol() Computes historical volatility using Garman-Klass estimator
%   GKvol() function computes historical volatility using Garman-Klass
%   estimator and OHLC data.

% INPUT:
%   O   - opens
%   H   - highs
%   L   - lows
%   C   - close
%   k   - rolling window size

% OUTPUT:
%   sigma_hat       - historical volatility estimate


%   Petr Javorik (2016) maple@mmquant.net


%   http://mmquant.net/introduction-to-volatility-models-with-matlab-sma-ewma-cc-range-estimators/


% input check
assert(k <= length(H),'Window length is greater than time series length!');
assert(length(H)==length(L) &&...
    length(H)==length(O) &&...
    length(H)==length(Cl),'Sizes of OHLC series are not equal.');

% GK computation
% A,B,C are terms in (2) on the left in brackets respectively
sigma_hat = zeros(size(H));
A = 0.511*log(H./L).^2;
B = 0.019*log(Cl./O).*log(H.*L./O.^2);
C = 2*log(H./O).*log(L./O);
for t = k+1:length(H)
    
    sigma_hat(t,1) = 1/k * sum(A(t-k:t-1)-B(t-k:t-1)-C(t-k:t-1));
    
end

sigma_hat = sqrt(sigma_hat) * sqrt(252);


end
