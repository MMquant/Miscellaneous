%% GARCHestimation.m

% Supporting script for my blog post about GARCH models.


%   Petr Javorik (2016) maple@mmquant.net


%   http://mmquant.net/introduction-to-volatility-models-with-matlab-garch


%% input data
C = BFX_day1_OHLCV(:,4);
date = BFX_day1_date;

%% Returns. Note that we don't know return for C(1) so we drop first element
r = double((log(C(2:end)./C(1:end-1)))*100); % scaled returns in [%] for numerical stability
e = r - mean(r); % innovations after simple linear regression of returns
C = C(2:end);
date = date(2:end);

%% Plot C and r
% C
figure1 = figure;
subplot1 = subplot(2,1,1,'Parent',figure1);
hold(subplot1,'on');
plot(date,C,'Parent',subplot1);
ylabel('Closing price');
box(subplot1,'on');
set(subplot1,'FontSize',16,'XMinorGrid','on','XTickLabelRotation',45,'YMinorGrid','on');
% r
subplot2 = subplot(2,1,2,'Parent',figure1);
hold(subplot2,'on');
plot(date,r,'Parent',subplot2);
ylabel('returns [%]');
box(subplot2,'on');
set(subplot2,'FontSize',16,'XMinorGrid','on','XTickLabelRotation',45,'YMinorGrid','on');

%% Autocorrelation of returns innovations - ACF, PACF, Ljung-Box test
% ACF
figure2 = figure;
subplot3 = subplot(2,1,1,'Parent',figure2);
hold(subplot3,'on');
autocorr(e); % input to ACF are innovations after simple linear regression of returns
% PACF
subplot4 = subplot(2,1,2,'Parent',figure2);
hold(subplot4,'on');
parcorr(e); % input to ACF are innovations after simple linear regression of returns
% Ljung-Box test
[hLB,pLB] = lbqtest(e,'Lags',3);

%% Conditional heteroskedasticity of returns - ACF, PACF, Engle's ARCH test
% ACF
figure3 = figure;
subplot5 = subplot(2,1,1,'Parent',figure3);
hold(subplot5,'on');
autocorr(e.^2);
% PACF
subplot6 = subplot(2,1,2,'Parent',figure3);
hold(subplot6,'on');
parcorr(e.^2);
% ARCH test
[hARCH,pARCH] = archtest(e,'lags',2);

%% AR-GARCH model, ARIMA object
MdlG = arima('ARLags',2,'Variance',garch(1,1)); % normal innovations
MdlT = arima('ARLags',2,'Variance',garch(1,1)); % t-distributed innovations
MdlT.Distribution = 't';

%% Parameters estimation
% normal innovations
EstMdlG = estimate(MdlG,r);
% t-distributed innovations
EstMdlT = estimate(MdlT,r);

%% Volatility inference and log-likelihood objective function value from estimated AR-GARCH model
[~,vG,logLG] = infer(EstMdlG,r);
[~,vT,logLT] = infer(EstMdlT,r);

%% Fitted models comparison using AIC, BIC
% AIC,BIC
% inputs: values of loglikelihood objective functions for particular model, number of parameters
% and length of time series
[aic,bic] = aicbic([logLG,logLT],[5,6],length(r))

%% AR-GJR-GARCH, ARIMA object
MdlGJR_T = arima('ARLags',2,'Variance',gjr(1,1));
MdlGJR_T.Distribution = 't';

%% Parameters estimation
% t-distributed innovations
EstMdlGJR_T = estimate(MdlGJR_T,r);

%% Volatility inference from estimated AR-GJR-GARCH model
[~,v_GJR_T,logL_GJR_T] = infer(EstMdlGJR_T,r);

%% Fitted models comparison using BIC, AIC
[aic2,bic2] = aicbic([logLT,logL_GJR_T],[6,7],length(r));

%% plot results
% Closing prices
figure4 = figure;
subplot7 = subplot(2,1,1,'Parent',figure4);
hold(subplot7,'on');
plot(date,C);
ylabel('Closing price');
set(subplot7,'FontSize',16,'XMinorGrid','on','XTickLabelRotation',45,'YMinorGrid','on','ZMinorGrid',...
    'on');
% volatility AR-GARCH, innovations t-distributed
subplot8 = subplot(2,1,2,'Parent',figure4);
hold(subplot8,'on');
plot(date,vT);
% volatility AR-GARCH, innovations normally distributed
plot(date,vG);
ylabel('volatility');
legend({'$\varepsilon_t$ $t$-distributed','$\varepsilon_t$ normally distributed'},'Interpreter','latex');
set(subplot8,'FontSize',16,'XMinorGrid','on','XTickLabelRotation',45,'YMinorGrid','on','ZMinorGrid',...
    'on');