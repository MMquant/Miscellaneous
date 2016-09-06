function sigma_hat = RSvol(O,H,L,Cl,k)
%RSvol() Computes historical volatility using Roger-Satchell estimator
%   RSvol() function computes historical volatility using Roger-Satchell
%   estimator and OHLC data. R-S estimator allows for arbitrary drift.

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

% RS computation
% A,B,C are terms in (5) on the left in brackets respectively
sigma_hat = zeros(size(H));
A = log(H./Cl).*log(H./O);
B = log(L./Cl).*log(L./O);
for t = k+1:length(H)
    
    sigma_hat(t,1) = 1/k * sum(A(t-k:t-1) + B(t-k:t-1));
    
end

sigma_hat = sqrt(sigma_hat) * sqrt(252);


end
