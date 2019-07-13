classdef CoilStatus < double
    enumeration
        Unspecified (-1)
        NoCoil      ( 0)
        Unplugged   ( 1)
        Plugged     ( 2)
        Pulsing     ( 3)
    end
    methods
        function x = isX(obj, n)
            x = obj > n;
        end
        function x = isSpecified(obj)
            x = obj.isX(-1);
        end
        function x = isPresent(obj)
            x = obj.isX( 0);
        end
        function x = isPlugged(obj)
            x = obj.isX( 1);
        end
        function x = isPulsing(obj)
            x = obj.isX( 2);
        end
    end
end