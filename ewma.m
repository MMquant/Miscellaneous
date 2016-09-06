function out = ewma(y,lambda,r_bar)
%ewma() Computes EWMA 
%   ewma() function computes exponentially weighted moving average of log
%   return variance.

% INPUT:
%   y       - price time series
%   lambda  - memory
%   r_bar   - mean of log returns estimate (use 0)

% OUTPUT:
%   out.sigma_hat       - historical volatility estimate
%   out.sigma_hat_1d    - historical volatility estimate per 1 day
%   out.sigma_hat_1y    - historical volatility estimate annualized


%   Petr Javorik (2016) maple@mmquant.net

%   http://mmquant.net/introduction-to-volatility-models-with-matlab-sma-ewma-cc-range-estimators/


% input check
assert(lambda > 0 && lambda < 1,'Lambda must be a real number between 0 and 1.');

% returns
ylag1 = [0;y(1:end-1)];
y(1) = [];
ylag1(1) = [];
r = log(y./ylag1);

% sigma_hat calculation
out.sigma_hat = zeros(size(r));
out.sigma_hat(1,1) = 0;
for t = 2:length(y)
    
    out.sigma_hat(t,1) = (1-lambda)*(r(t-1,1)-r_bar)^2 + lambda*out.sigma_hat(t-1,1);

end

% historical volatility for 1 time unit
out.sigma_hat_1d = sqrt(out.sigma_hat);

% historical volatility annualized
out.sigma_hat_1y = out.sigma_hat_1d * (sqrt(252));


end