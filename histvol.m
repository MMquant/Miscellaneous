function [ sigma_hat ] = histvol( y,k )
%histvol() Computes historical volatility
%   histvol() function computes historical volatility given input vector y
%   and window size k.
%   Find more info in my article http://mmquant.net/introduction-to-volatility-models/


% Petr Javorik (2016) maple@mmquant.net

% input check
assert(k <= length(y),'Window length is greater than time series length!');

% returns
ylag1 = [0;y(1:end-1)];
y(1) = [];
ylag1(1) = [];
r = log(y./ylag1);

% sample mean mu_hat(t)
mu_hat = zeros(size(r));
for t = k+1:length(r)
    
    mu_hat(t,1) = sum(r(t-k:t-1)) / k;
    
end

% historical volatility (sample variance)
sigma_hat = zeros(size(r));
for t = k+1:length(r)
    
    sigma_hat(t,1) = sum((r(t-k:t-1) - mu_hat(t)).^2) / (k-1);
    
end


end

