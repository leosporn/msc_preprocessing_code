classdef RFSpikes
    properties (SetAccess = immutable)
        Spikes (:, 1) RFSpike
        Threshold (:, 1) double
        Window (:, 1) double
    end
    properties (Dependent)
        nS (1, 1) double
        idx (:, 1) double
        Factor (:, 1) double
        Amplitude (:, 1) double
    end
    methods
        % Constructor
        function obj = RFSpikes(idx, y, y0, threshold, window)
            obj.Threshold = threshold;
            obj.Window = window;
            if isscalar(obj.Window)
                obj.Window = repmat(obj.Window, [2 1]);
            end
            iS = find( idx(2:end) & ~idx(1:(end - 1))); iS = iS + 1;
            iE = find(~idx(2:end) &  idx(1:(end - 1)));
            for n = 1:numel(iE)
                idx = iS(n):iE(n);
                obj.Spikes = cat(1, obj.Spikes, ...
                                    RFSpike(idx, y(idx), y0(idx)));
            end
        end
        % Getters
        function x = get.Spikes(obj)
            x = obj.Spikes;
        end
        function x = get.Threshold(obj)
            x = obj.Threshold;
        end
        function x = obj.getWindow(obj)
            x = obj.Window;
        end
        function x = get.nS(obj)
            x = numel(obj.Spikes);
        end
        function x = get.idx(obj)
            x = [];
            for n = 1:obj.nS
                x = cat(1, x, obj.Spikes(n).idx);
            end
        end
        function x = get.Factor(obj)
            x = [];
            for n = 1:obj.nS
                x = cat(1, x, obj.Spikes(n).Factor);
            end
        end
        function x = get.Amplitude(obj)
            x = NaN([obj.nS 1]);
            for n = 1:obj.nS
                x(n) = obj.Spikes(n).Amplitude;
            end
        end
        % Setters
        % Other
    end
end