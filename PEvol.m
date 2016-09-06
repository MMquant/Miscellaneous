function sigma_hat = PEvol(H,L,k)
%PEvol() Computes historical volatility using Parkinson estimator
%   PEvol() function computes historical volatility using Parkinson
%   estimator and extreme price values.

% INPUT:
%   H   - highs
%   L   - lows
%   k   - rolling window size. integer

% OUTPUT:
%   sigma_hat       - historical volatility estimate


%   Petr Javorik (2016) maple@mmquant.net


%   http://mmquant.net/introduction-to-volatility-models-with-matlab-sma-ewma-cc-range-estimators/


% input check
assert(k <= length(H),'Window length is greater than time series length!');
assert(length(H)==length(L),'Sizes of High and Low series are not equal');

% PE computation
sigma_hat = zeros(size(H));
sqlogdiff = log(H./L).^2;
for t = k+1:length(H)
    
    sigma_hat(t,1) = 1/4*k*log(2) * sum(sqlogdiff(t-k:t-1));
    
end

sigma_hat = sqrt(sigma_hat);


end
