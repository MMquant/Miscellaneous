function out = optionparse(path2csv,provider,underlying)
%optionparse() parses option data file to matlab table
%   This is supplementary function which parses data file with historical
%   option chains for given equity into matlab table data type.

% INPUT:
%   path2csv        - path to .csv file with historical option chains
%   provider        - provider of data (different providers have different data file headers)
%   underlying      - type of the underlying (different types of the underlying can have different
%                     headers even if they are from same provider)

% OUTPUT:
%   out - parsed data file to matlab table

% Petr Javorik (2016) maple@mmquant.net

% Input check
providers = {'ivolatility'}; % more to be added
underlyings = {'equity'}; % more to be added
assert(nargin == 3,'Valid arguments are optionparse(path2csv,provider,underlying).');
assert(exist(path2csv, 'file') == 2,'Data file doesn''t exist.');
assert(ismember(provider,providers),'Unknown datafile provider.');
assert(ismember(underlying,underlyings),'Unknown datafile provider.');

switch provider
    
    case 'ivolatility'
        
        if strcmp(underlying,'equity')
            
            header = {'symbol','exchange','date','adjusted_stock_close_price','option_symbol',...
                'expiration','strike','call_put','style','ask','bid','volume','open_interest',...
                'unadjusted_stock_price'};
            
            % Parse
            out.data = readtable(path2csv,'ReadVariableNames',false,'HeaderLines',1,...
                'Format','%s%s%{MM/dd/yy}D%f32%s%{MM/dd/yy}D%f32%s%s%f32%f32%u16%u16%f32');
            out.data.Properties.VariableNames = header;
            
        end
        
    case '' % new provider
        
        % ...
        
end



end

