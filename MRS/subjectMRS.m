classdef subjectMRS < double
    enumeration
        Unspecified  ( -1)
        Braino       (0.1)
        FBIRN        (0.2)
        PB           (0.3)
        Bb           (0.4)
        TMS_Subject1 (1.1)
    end
    methods
        function x = isSpecified(obj)
            x = obj >= 0;
        end
        function x = isPhantom(obj)
            x = floor(obj) == 0;
        end
        function x = isHuman(obj)
            x = obj.isSpecified && ~obj.isPhantom;
        end
    end
end