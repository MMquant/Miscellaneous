function [ sigma_hat ] = ewma( y,lambda,r_bar )
%ewma() Computes EWMA 
%   ewma() function computes exponentially weighted moving average of variance
%   given input vector y, weight(memory) lambda and mean of input series r_bar.
%   This function returns variance of logarithmic returns of input series.
%   Note that we should do a statistical test about H_0 : r_bar = 0 before we
%   drop the r_bar term from the model.

% Petr Javorik (2016) maple@mmquant.net

% input check
assert(lambda > 0 && lambda < 1,'Lambda must be a real number between 0 and 1.');

% returns
ylag1 = [0;y(1:end-1)];
y(1) = [];
ylag1(1) = [];
r = log(y./ylag1);

% sigma_hat calculation
sigma_hat = zeros(size(r));
sigma_hat(1,1) = 0;
for t = 2:length(y)
    
    sigma_hat(t,1) = (1-lambda)*(r(t-1,1)-r_bar)^2 + lambda*sigma_hat(t-1,1);

end