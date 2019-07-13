function vax = uint2vax(int, varargin)
    % UINT2VAX  converts from IEEE-LE (UINT32) to VAX (double), based on
    % MATLAB code that no longer exists. Default is VAXD
    %
    % See http://www.opengroup.org/onlinepubs/9629399/chap14.htm#tagfcjh_20
    %
    % VAX = UINT2VAX(int, fmt) converts either a single 32 bit unsigned
    % integer int and converts it into a VAXF (single precision), or takes
    % a column of 32 bit integers and combines them into a 64 bit VAXD or
    % VAXG (depending of format fmt).
    % unsigned integers 
    %
    if nargin == 1
        fmt = 'VAXD';
    else
        fmt = varargin{1};
    end
    [A, B, C, D, S, E, F] = get_vax_specific_parameters(fmt);
    switch upper(fmt)
        case {'VAXF' 'F'}
            vaxInt = uint2vaxInt(int);
        case {'VAXD' 'D' 'VAXG' 'G'}
            int  = reshape(int, 2, [])';
            vaxIntA = uint64(uint2vaxInt(int(:, 1)));
            vaxIntB = uint64(uint2vaxInt(int(:, 2)));
            vaxInt  = bitor(mbs(vaxIntA, 32), vaxIntB);
    end
    S = mbs(vaxInt, S);
    E = mbs(vaxInt, E);
    F = mbs(vaxInt, F);
    G = 1./C + double(F)./D;
    vax = (-1).^double(S).*G.*A.^(double(E) - B);
    function [A, B, C, D, S, E, F] = get_vax_specific_parameters(fmt)
        M = [   2    2    2;
              128  128 1024;
                2    2    2;
                0    0    0;
              -31  -63  -63;
                1    1    1;
              -24  -56  -53;
                9    9   12;
               -9   -9  -12];
        M = cat(1, M, [16777216 72057594037927936 9007199254740992]);
        switch upper(fmt)
            case {'VAXF' 'F'}, idx = 1;
            case {'VAXD' 'D'}, idx = 2;
            case {'VAXG' 'G'}, idx = 3;
        end
        A  = M(  1, idx);
        B  = M(  2, idx);
        C  = M(  3, idx);
        S  = M(4:5, idx);
        E  = M(6:7, idx);
        F  = M(8:9, idx);
        D  = M(10, idx);
    end
    function vaxInt = uint2vaxInt(int)
        w1 = mbs(int, [16 -16]);
        w2 = mbs(int, [ 0 -16]);
        vaxInt = bitor(mbs(w1, 16), ...
                       mbs(w2, []));
%         w1 = bitshift(bitshift(int, 16), -16);
%         w2 = bitshift(bitshift(int,  0), -16);
%         vaxInt = bitor(bitshift(w1, 16), bitshift(w2, 0));
    end
    function y = mbs(x, s)
        if isempty(s)
            y = x;
        else
            y = mbs(bitshift(x, s(1)), s(2:end));
        end
    end
end