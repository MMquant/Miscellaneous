function out = histvol(y,k,cc)
%histvol() Computes historical volatility
%   histvol() function computes historical volatility of logarithmic
%   returns.

% INPUT:
%   y   - price time series.
%   k   - rolling window size.
%   cc  - switches simple close-close volatility estimator mode. 0 or 1

% OUTPUT:
%   out.sigma_hat       - historical volatility estimate
%   out.sigma_hat_1d    - historical volatility estimate per 1 day
%   out.sigma_hat_1y    - historical volatility estimate annualized


%   Petr Javorik (2016) maple@mmquant.net

%   http://mmquant.net/introduction-to-volatility-models-with-matlab-sma-ewma-cc-range-estimators/


% input check
assert(k <= length(y),'Window length is greater than time series length!');
assert(ismember(cc,[0,1]) ,'Invalid input for cc argument. Valid inputs are 0 or 1.');

% returns
ylag1 = [0;y(1:end-1)];
y(1) = [];
ylag1(1) = [];
r = log(y./ylag1);

% sample mean mu_hat(t)
mu_hat = zeros(size(r));
if cc == 0
    for t = k+1:length(r)
        
        mu_hat(t,1) = sum(r(t-k:t-1)) / k;
        
    end
end

% historical volatility (sample variance) for k time units
out.sigma_hat = zeros(size(r));
for t = k+1:length(r)
    
    out.sigma_hat(t,1) = sum((r(t-k:t-1) - mu_hat(t)).^2) / (k-1);
    
end

% historical volatility for 1 time unit
out.sigma_hat_1d = sqrt(out.sigma_hat);

% historical volatility annualized
out.sigma_hat_1y = out.sigma_hat_1d * (sqrt(252));


end
