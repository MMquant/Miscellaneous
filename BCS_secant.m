function [sigma_secant,sigma_BCS,BS] = BCS_secant(T_t_var,V,S,K,r,type,varargin)
%BCS_secant() Computes implied volatility
%   BCS_secant() function computes implied volatility of an underlying asset using
%   Bharadia-Christopher-Salkin model, secant method and input
%   values.

% INPUT:
%   T_t     - time to option's expiry in N/252 fraction (variable)
%   V       - value of the option
%   S       - spot price of the underlying asset
%   K       - strike price (constant)
%   r       - risk-free return rate
%   type    - option type 'C' or 'P'
%
% OPTIONAL INPUT:
%   err_thr         - secant method error tolerance (accuracy), default = 1e-4 

% OUTPUT:
%   sigma_secant    - final implied volatility from secant method
%   sigma_BCS       - initial sigma as input into secant method(sigma_0 = 0, sigma_1 = sigma_BCS)
%   BS              - theoretical option value from BS equation


%   Petr Javorik (2016) maple@mmquant.net, http://mmquant.net/introduction-to-volatility-models/


% input check
narginchk(6,7);
if nargin == 7
    
    assert(isnumeric(varargin{1}) && varargin{1} > 0 && varargin{1} <= 0.1,...
        'Invalid input for secant method accuracy, 0 < accuracy <= 0.1 .');
    err_thr = varargin{1};
    
else
    
    err_thr = 1e-4;
    
end
assert(ismember(type,{'C','P'}),'Invalid option type, valid input: ''C'' or ''P''');

% IV values by B-C-S model are used as initial guess in secant method
% (sigma_0=0,sigma_1=sigma_BCS(t)).
sigma_secant = zeros(size(S));
sigma_BCS = zeros(size(S));
for t = 1:length(S)
    
    delta = (1/2)*(S(t) - K*exp(-r*T_t_var(t))); % (6)
    sigma_BCS(t,1) = sqrt(2*pi-T_t_var(t)) * (V(t)-delta)/(S(t)-delta); % (6)
    
end

% IV computation using secant method (7)
BS = zeros(size(S));
switch type
    
    case 'C'
        
        for t = 1:length(S)
            
            % BS theoretical value for call option
            d1 = (log(S(t)/K) + (r+1/2*sigma_BCS(t,1)^2)*(T_t_var(t))) / sigma_BCS(t,1)*sqrt(T_t_var(t)); % (5)
            d2 = d1 - sigma_BCS(t)*T_t_var(t);
            BS(t) = S(t)*cdf('normal',d1,0,1) - K*exp(-r*T_t_var(t))*cdf('normal',d2,0,1); % (5) for call option
            
            % secant method
            err = 1; % Initial error value
            temp_sigma(1:2,1) = [0,sigma_BCS(t,1)]; % initialization of temp_sigma
            temp_BS(1:2,1) = [0,BS(t,1)]; % initialization of temp_BS
            while err >= err_thr
                
                % error update - step 6
                err = (temp_BS(2,1) - V(t)) * ... 
                    ((temp_sigma(2,1) - temp_sigma(1,1)) / (temp_BS(2,1) - temp_BS(1,1))); % (7) error corresponding to last computed sigma
                
                % sigma_{i+1} update - step 7
                temp_sigma(3,1) = temp_sigma(2,1) - err; % new sigma from secant iteration
                temp_sigma(1) = []; % old sigma no more needed in next loop
                
                % BS(sigma_{i+1}) update - step 8
                d1 = (log(S(t)/K) + (r+1/2*temp_sigma(2,1)^2)*(T_t_var(t))) / temp_sigma(2,1)*sqrt(T_t_var(t)); % (5)
                d2 = d1 - temp_sigma(2,1)*T_t_var(t); % (5)
                temp_BS(3,1) = S(t)*cdf('normal',d1,0,1) - K*exp(-r*T_t_var(t))*cdf('normal',d2,0,1); % (5) for call option
                temp_BS(1) = []; % old BS(sigma) no more needed in next loop
                
            end
            sigma_secant(t,1) = temp_sigma(2,1);
            
        end
        
    case 'P'
        
        for t = 1:length(S)
            
            % BS theoretical value for call option
            d1 = (log(S(t)/K) + (r+1/2*sigma_BCS(t,1)^2)*(T_t_var(t))) / sigma_BCS(t,1)*sqrt(T_t_var(t)); % (5)
            d2 = d1 - sigma_BCS(t)*T_t_var(t);
            BS(t) = K*exp(-r*T_t_var(t))*cdf('normal',-d2,0,1) - S(t)*cdf('normal',-d1,0,1); % (5) for put option
            
            % secant method
            err = 1; % initial error value
            temp_sigma(1:2,1) = [0,sigma_BCS(t,1)]; % initialization of temp_sigma
            temp_BS(1:2,1) = [0,BS(t,1)]; % initialization of temp_BS
            while err >= err_thr
                
                % error update - step 6
                err = (temp_BS(2,1) - V(t)) * ...
                    ((temp_sigma(2,1) - temp_sigma(1,1)) / (temp_BS(2,1) - temp_BS(1,1))); % (7) error corresponding to last computed sigma
                
                % sigma_{i+1} update - step 7
                temp_sigma(3,1) = temp_sigma(2,1) - err; % new sigma from secant iteration
                temp_sigma(1) = []; % old sigma no more needed in next loop
                
                % BS(sigma_{i+1}) update - step 8
                d1 = (log(S(t)/K) + (r+1/2*temp_sigma(2,1)^2)*(T_t_var(t))) / temp_sigma(2,1)*sqrt(T_t_var(t)); % (5)
                d2 = d1 - temp_sigma(2,1)*T_t_var(t); % (5)
                temp_BS(3,1) = K*exp(-r*T_t_var(t))*cdf('normal',-d2,0,1) - S(t)*cdf('normal',-d1,0,1); % (5) for put option
                temp_BS(1) = []; % old BS(sigma) no more needed in next loop
                
            end
            sigma_secant(t,1) = temp_sigma(2,1);
            
        end
        
end


end

