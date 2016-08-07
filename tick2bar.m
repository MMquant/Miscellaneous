function [ varargout ] = tick2bar(dates,price,amount,barlength,bartype,sparse)
%tick2bar Converts ticks to OHLCV matrix
%   tick2bar function converts input ticks into OHLCV matrix.
%   Input
%       datesin: datetime array
%       price: traded price in tick granularity
%       amount: volume in tick granularity
%       barlength: barlength in bartype resolution
%       bartype: choose one from
%           s(seconds),m(minutes),h(hours),d(days),M(months),Y(years)
%       sparsity: {0,1} determine whether you want to include zero volume
%       intervals in output OHLCV matrix. Default behaviour is sparse = 0
%       because it's common for ordinary OHLCV bars.
%   Output
%       varargout(1): datetime array for particular interval(interval starting datetime)
%       varargout(2): OHLCV matrix
%
%   Example:
%   If we want 2min bars we choose barlength = 2 and bartype = 'm'
%
%
%   Written by Maple Mapleson
%   jvr23@linuxmail.org
%   
% 

%% Input variables check
narginchk(5,6)
assert(ismember(bartype,{'s','m','h','d','M','Y'}),'Not valid bartype input!');
refsize = size(dates,1);
assert(...
    (size(price,1) == refsize) && ...
    (size(amount,1) == refsize), ...
    'Input vector sizes don''t match!');
assert(isnumeric(barlength),'Not valid barlength input!');

if exist('sparse','var')
    
    assert(sparse == 0 || sparse == 1,'Not valid sparse input, valid inputs are 0 or 1!');
    
end

switch nargin

    case 5
        sparsity = 0;
    case 6
        sparsity = 1;
        
end

%% Aggregate by interval
switch bartype
    
    case 's'
        assert(barlength >= 1 && barlength <= 59,'Not valid barlength for seconds!');
        workdatevec = 6;
    case 'm'
        assert(barlength >= 1 && barlength <= 59,'Not valid barlength for minutes!');
        workdatevec = 5;
    case 'h'
        assert(barlength >= 1 && barlength <= 23,'Not valid barlength for hours!');
        workdatevec = 4;
    case 'd'
        assert(barlength >= 1 && barlength <= 30,'Not valid barlength for days!');
        workdatevec = 3;
    case 'M'
        assert(barlength >= 1 && barlength <= 11,'Not valid barlength for months!');
        workdatevec = 2;
    case 'Y'
        assert(barlength >= 1 && barlength <= 10,'Not valid barlength for years!');
        workdatevec = 1;
        
end

datetimemesh = (dates(1):1/24/60/60:dates(end))';
datetimemesh = datevec(datetimemesh);
datetimemesh2 = datetimemesh(:,1:workdatevec);
datetimemesh2(:,workdatevec) = floor(datetimemesh(:,workdatevec)/barlength);
[uniqdatetimemesh,~,~] = unique(datetimemesh2(:,1:workdatevec),'rows');

datevector = datevec(dates);
datevector2 = datevector(:,1:workdatevec);
datevector2(:,workdatevec) = floor(datevector(:,workdatevec)/barlength);
[uniqdatevec,~,subs] = unique(datevector2(:,1:workdatevec),'rows');

% Interval Open calculation
O = accumarray(subs,price,[],@(x) x(1));
% Interval High calculation
H = accumarray(subs,price,[],@max);
% Interval Low calculation
L = accumarray(subs,price,[],@min);
% Interval Close calculation
C = accumarray(subs,price,[],@(x) x(end));
% Interval Volume calculation
V = accumarray(subs,amount,[],@sum);

%% Output
uniqdatevec(:,workdatevec) = uniqdatevec(:,workdatevec).*barlength;

if size(uniqdatevec,2) < 6
    
    uniqdatevec = [uniqdatevec,zeros(size(uniqdatevec,1),6-size(uniqdatevec,2))];
    
end
datesout = datetime(uniqdatevec);
OHLCV = [O,H,L,C,V];

% OHLCV "sparse" matrix without zero volume bars
if  sparsity == 1
    varargout{1} = datesout;
    varargout{2} = OHLCV;
    
    % OHLCV matrix with zero volume bars
elseif  sparsity == 0
    
    uniqdatetimemesh(:,workdatevec) = uniqdatetimemesh(:,workdatevec).*barlength;
    
    if size(uniqdatetimemesh,2) < 6
        
        uniqdatetimemesh = [uniqdatetimemesh,zeros(size(uniqdatetimemesh,1),6-size(uniqdatetimemesh,2))];
        
    end
    
    datesoutmesh = datetime(uniqdatetimemesh);
    [~,id] = ismember(datesout,datesoutmesh);
    OHLCV_on_date_mesh(id,:) = OHLCV;
    
    for rows = 1:length(OHLCV_on_date_mesh)
       for cols = 1:4
           
          if OHLCV_on_date_mesh(rows,cols) == 0
              
              OHLCV_on_date_mesh(rows,cols) = OHLCV_on_date_mesh(rows - 1,4);
              
          end
          
       end
    end
    
    varargout{1} = datesoutmesh;
    varargout{2} = OHLCV_on_date_mesh;
    
end
end