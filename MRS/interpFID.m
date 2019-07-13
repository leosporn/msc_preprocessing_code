function y = interpFID(y, x, varargin)
    % INTERPFID  replace points on FID with those linearly interpolated
    %            from neighbouring points
    %
    %    Usage:
    %    y = interpFID(y, x, i1)
    %    y = interpFID(y, x, i1, i2)
    %        y  - initial FID
    %        x  - corresponding x value (time)
    %        i1 - index of points to remove
    %        i2 - index of points to use in interpolation
    %
    %    Returns:
    %        y  - interpolated FID
    %
    switch nargin
        case 3
            i1 = varargin{1};
            i2 = ~ismember(1:numel(x), i1);
            fn = @simple_interp;
        case 4
            i1 = varargin{1};
            i2 = varargin{2};
            fn = @complex_interp;
    end
    for n = 1:size(y(:, :), 2)
        y(:, n) = fn(x, y(:, n), i1, i2);
    end
    function y = simple_interp(x, y, i1, i2)
        y(i1) = interp1(x(i2), y(i2), x(i1));
    end
    function y = complex_interp(x, y, i1, i2)
        if ismember(1, i1)
            r = pvpf(x, abs(y), i1, i2, 1);
            a = pvpf(x, unwrap(angle(y)), i1, i2, 2);
            y = r.*exp(complex(0, a));
        else
            y = pvpf(x, y, i1, i2, 1);
        end
        function y = pvpf(x, y, i1, i2, n)
            y(i1) = polyval(polyfit(x(i2), y(i2), n), x(i1));
        end
    end
end