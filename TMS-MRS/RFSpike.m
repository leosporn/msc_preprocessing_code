classdef RFSpike
    properties (SetAccess = immutable)
        idx       (:, 1) double
        Factor    (:, 1) double
    end
    properties (Dependent)
        Amplitude (1, 1) double
    end
    methods
        % Constructor
        function obj = RFSpike(idx, y, y0)
            obj.idx = idx;
            obj.Factor = y./y0;
        end
        % Getters
        function x = get.idx(obj)
            x = obj.idx;
        end
        function x = get.Factor(obj)
            x = obj.Factor;
        end
        function x = get.Amplitude(obj)
            [~, I] = max(log(abs(obj.Factor)));
            x = obj.Factor(I);
        end
        % Setters
        % Other
    end
end