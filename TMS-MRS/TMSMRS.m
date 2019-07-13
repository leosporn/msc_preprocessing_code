classdef TMSMRS < MRS
    properties
        Spikes         (:, 1) RFSpikes
        SpikesRemoved  (1, 1) logical = false
    end
    properties (SetAccess = immutable)
        CoilStatus            CoilStatus = -1
        CoilPosition   (3, 1) double
        Depth          (1, 1) double
        PulseIntensity (1, 1) double
        PulseDelay     (1, 1) double
    end
    properties (Dependent)
        hasSpikes      (1, 1) logical
        dVC            (1, 1) double
    end
    methods
        % Constructor
        function obj = TMSMRS(filename, varargin)
            KW = parse_input(varargin{:});
            obj@MRS(filename, KW);
            obj.CoilStatus = KW.CoilStatus;
            obj.CoilPosition = KW.CoilPosition;
            obj.PulseIntensity = KW.PulseIntensity;
            obj.PulseDelay = KW.PulseDelay;
            if obj.hasSpikes && KW.RemoveSpikes
                [obj.Data, idx, y0] = fixFIDSpikes(obj.Data, obj.t, ...
                                                   KW.SpikeWindowSize, ...
                                                   KW.SpikeThreshold);
                for n = 1:obj.nFID
                    obj.Spikes = cat(1, obj.Spikes, ...
                                        RFSpikes(idx(:, n), ...
                                                 obj.Data(:, n), ...
                                                 y0(:, n), ...
                                                 KW.SpikeThreshold, ...
                                                 KW.SpikeWindowSize));
                    obj.SpikesRemoved = true;
                end
            end
            function KW = parse_input(varargin)
                p = inputParser;
                addParameter(p, 'CoilStatus', -1)
                addParameter(p, 'CoilPosition', NaN(3, 1))
                addParameter(p, 'PulseIntensity', 0)
                addParameter(p, 'PulseDelay', 0)
                addParameter(p, 'RemoveSpikes', true)
                addParameter(p, 'SpikeThreshold', 4)
                addParameter(p, 'SpikeWindowSize', 60)
                addParameter(p, 'Depth', NaN)
                % ======================= From MRS =======================
                addParameter(p, 'nDummyScans', 2)
                addParameter(p, 'nPhaseCycleSteps', 16)
                addParameter(p, 'WS', 'None')
                addParameter(p, 'ScanDateFormat', 'yyyy.MM.dd HH:mm:ss')
                addParameter(p, 'FixFirstPoints', true)
                addParameter(p, 'FirstPointsIDX', 3:7)
                addParameter(p, 'FirstPoints2Remove', 2)
                addParameter(p, 'LastPointsIDX', 2:50)
                addParameter(p, 'LastPoints2Remove', 1)
                addParameter(p, 'doPhaseCorrection', false)
                addParameter(p, 'PhaseAlignTimes', [0.1 0.4])
                addParameter(p, 'AverageData', false)
                addParameter(p, 'NoiseFloorStartTime', NaN)
                addParameter(p, 'Subject', -1)
                % ========================= Done =========================
                parse(p, varargin{:})
                KW = p.Results;
            end
        end
        % Getters
        function x = get.Spikes(obj)
            x = obj.Spikes;
        end
        function x = get.SpikesRemoved(obj)
            x = obj.SpikesRemoved;
        end
        function x = get.CoilStatus(obj)
            x = obj.CoilStatus;
        end
        function x = get.CoilPosition(obj)
            x = obj.CoilPosition;
        end
        function x = get.PulseIntensity(obj)
            if obj.CoilStatus.isPulsing
                x = obj.PulseIntensity;
            else
                x = 0;
            end
        end
        function x = get.PulseDelay(obj)
            if obj.CoilStatus.isPulsing
                x = obj.PulseDelay;
            else
                x = 0;
            end
        end
        function x = get.hasSpikes(obj)
            x = obj.CoilStatus.isPulsing && obj.Subject.isPhantom;
        end
        function x = get.dVC(obj)
            x = norm(obj.CoilPosition - obj.VoxelPosition);
        end
        % Setters
        % Other
        function obj = SwitchSpikes(obj, spikes_removed_condition, fn)
            if obj.hasSpikes && obj.SpikesRemoved == spikes_removed_condition
                for n = 1:obj.nFID
                    S = obj.Spikes(n);
                    obj.Data(S.idx, n) = fn(obj.Data(S.idx, n), S.Factor);
                end
                obj.SpikesRemoved = ~obj.SpikesRemoved;
            end
        end
        function obj = RemoveSpikes(obj)
            obj = obj.SwitchSpikes(false, @times);
        end
        function obj = ApplySpikes(obj)
            obj = obj.SwitchSpikes(true, @rdivide);
        end
    end
end