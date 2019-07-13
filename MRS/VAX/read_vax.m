function vax = read_vax(fileID, varargin)
    % READ_VAX  opens a VAX file and converts it to its IEEE-LE
    % representation. Based on MATLAB code that no longer exists.
    %
    % VAX = READ_VAX(fileID, fmt, n, method)
    %
    % VAX = READ_VAX(fileID)
    %
    [fmt, n, method] = parse_input(varargin{:});
    switch method
        case {'float32' 'single'},   fmt = 'VAXF';
        case {'float64' 'double'},   n   = 2*n;
        case {'float'}
            if intmax == 2147483647, fmt = 'VAXF';
            else,                    n   = 2*n;
            end
        otherwise
            vax = fread(fileID, n, method); return
    end
    int = fread(fileID, n, 'uint32=>uint32');
    vax = uint2vax(int, fmt);
    function [fmt, n, method] = parse_input(varargin)
        switch nargin
            case 0, fmt = 'VAXD'; n = inf; method = 'float';
            case 1, fmt = 'VAXD'; n = inf; method = varargin{1};
            case 2, fmt = 'VAXD'; [n, method] = varargin{:};
            case 3, [fmt, n, method] = varargin{:};
        end
    end
end