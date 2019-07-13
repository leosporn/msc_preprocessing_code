classdef MRS
    properties
        Data       double
        DataDomain datadomainMRS = datadomainMRS.Time
    end
    properties (SetAccess = immutable)
        t             (:, 1) double
        nt            (1, 1) double
        dt            (1, 1) double
        f             (:, 1) double
        nf            (1, 1) double
        df            (1, 1) double
        ppm           (:, 1) double
        nPC           (1, 1) double = 16
        nDS           (1, 1) double = 2
        WS            (:, 1) logical
        SPARfilename         char
        SDATfilename         char
        ScanDate             datetime
        TR            (1, 1) double
        TE            (1, 1) double
        VoxelSize     (3, 1) double
        VoxelPosition (3, 1) double
        VoxelAngle    (3, 1) double
        Subject              subjectMRS = -1
        doAvData      (1, 1) logical
        NoiseFloor    (1, 1) double
    end
    properties (Dependent)
        AvData               double
        DataModified  (1, 1) logical
        DataWS               double
        DataNWS              double
        nFID          (1, 1) double
        SNR           (1, 1) double
    end
    methods
        % Constructor
        function obj = MRS(varargin)
            if isobject(varargin{1})
                obj = varargin{1}; return
            end
            filename = varargin{1};
            KW = parse_input(varargin{2:end});
            obj.SPARfilename = change_filename_ext(filename, '.SPAR');
            obj.SDATfilename = change_filename_ext(filename, '.SDAT');
            [obj.Data, spar] = read_sdat_file(obj.SDATfilename);
            [obj.t, obj.nt, obj.dt, ...
             obj.f, obj.nf, obj.df, ...
             obj.ppm] = get_tf_info(spar);
            obj.nDS = KW.nDummyScans;
            obj.nPC = KW.nPhaseCycleSteps;
            obj.Data = reshape(obj.Data, obj.nt, obj.nPC, []);
            obj.WS = getWS(size(obj.Data, 3), KW.WS);
            obj.ScanDate = datetime(spar.scan_date, ...
                                    'InputFormat', KW.ScanDateFormat);
            obj.TR = spar.repetition_time;
            obj.TE = spar.echo_time;
            obj.VoxelSize     = [spar.lr_size;
                                 spar.cc_size;
                                 spar.ap_size];
            obj.VoxelPosition = [spar.lr_off_center;
                                 spar.cc_off_center;
                                 spar.ap_off_center];
            obj.VoxelAngle    = [spar.lr_angulation;
                                 spar.cc_angulation;
                                 spar.ap_angulation];
            obj.Subject = KW.Subject;
            if KW.FixFirstPoints
                obj = fixPoints(obj, KW, 'First');
                obj = fixPoints(obj, KW, 'Last');
            end
            if KW.doPhaseCorrection
                obj = obj.PhaseAdjust(KW.PhaseAlignTimes);
            end
            obj.doAvData = KW.AverageData;
            if isnan(KW.NoiseFloorStartTime)
                obj.NoiseFloor = NaN;
            else
                obj.NoiseFloor = find(obj.t > KW.NoiseFloorStartTime, 1);
            end
            function KW = parse_input(varargin)
                if nargin == 0 || ~isstruct(varargin{1})
                    KW = parse_input(struct(), varargin{:}); return
                end
                p = inputParser;
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
                parse(p, varargin{2:end})
                KW = p.Results;
                fn = fieldnames(varargin{1});
                for n = 1:numel(fn)
                    KW.(fn{n}) = varargin{1}.(fn{n});
                end
            end
            function filename = change_filename_ext(filename, ext)
                [pn, fn, ~] = fileparts(filename);
                filename = fullfile(pn, [fn ext]);
            end
            function [t, nt, dt, f, nf, df, ppm] = get_tf_info(spar)
                nt  = spar.dim1_pnts;
                dt  = spar.dim1_step;
                t   = (0:(nt - 1))*dt; t = t(:);
                nf  = nt;
                df  = spar.sample_frequency/nf;
                f   = ((1:nf) - nf/2 - 1)*df; f = f(:);
                sf  = spar.synthesizer_frequency;
                ppm = 1e6*f/sf + 4.7;
            end
            function WS = getWS(n, varargin)
                if nargin == 1
                    WS = getWS(n, 'None');
                elseif ischar(varargin{1}) && strcmpi(varargin{1}, 'None')
                    WS = false([n 1]);
                elseif ischar(varargin{1}) && strcmpi(varargin{1}, 'All')
                    WS = true([n 1]);
                else
                    WS = false([n 1]);
                    WS(varargin{1}:end) = true;
                end
            end
            function obj = fixPoints(obj, KW, pos)
                [obj, dd] = obj.setDataDomain();
                switch pos
                    case 'First'
                        idx1 = 1:KW.FirstPoints2Remove;
                        idx2 = KW.FirstPointsIDX;
                    case 'Last'
                        idx1 = obj.nt - (KW.LastPoints2Remove:-1:1) + 1;
                        idx2 = obj.nt - KW.LastPointsIDX(end:-1:1) + 1;
                    otherwise, return
                end
                obj.Data = interpFID(obj.Data, obj.t, idx1, idx2);
                obj = obj.setDataDomain(dd);
            end
        end
        % Getters
        function x = get.Data(obj)
            x = obj.Data;
        end
        function x = get.DataDomain(obj)
            x = obj.DataDomain;
        end
        function x = get.t(obj)
            x = obj.t;
        end
        function x = get.nt(obj)
            x = obj.nt;
        end
        function x = get.dt(obj)
            x = obj.dt;
        end
        function x = get.f(obj)
            x = obj.f;
        end
        function x = get.nf(obj)
            x = obj.nf;
        end
        function x = get.df(obj)
            x = obj.df;
        end
        function x = get.ppm(obj)
            x = obj.ppm;
        end
        function x = get.nPC(obj)
            x = obj.nPC;
        end
        function x = get.nDS(obj)
            x = obj.nDS;
        end
        function x = get.WS(obj)
            x = obj.WS;
        end
        function x = get.SPARfilename(obj)
            x = obj.SPARfilename;
        end
        function x = get.SDATfilename(obj)
            x = obj.SDATfilename;
        end
        function x = get.ScanDate(obj)
            x = obj.ScanDate;
        end
        function x = get.TR(obj)
            x = obj.TR;
        end
        function x = get.TE(obj)
            x = obj.TE;
        end
        function x = get.VoxelSize(obj)
            x = obj.VoxelSize;
        end
        function x = get.VoxelPosition(obj)
            x = obj.VoxelPosition;
        end
        function x = get.VoxelAngle(obj)
            x = obj.VoxelAngle;
        end
        function x = get.DataModified(obj)
            x = all(obj.Data == read_sdat_file(obj.SDATfilename), 'all');
        end
        function x = get.DataNWS(obj)
            x = obj.Data(:, :, ~obj.WS);
        end
        function x = get.DataWS(obj)
            x = obj.Data(:, :,  obj.WS);
        end
        function x = get.nFID(obj)
            x = numel(obj.Data)/obj.nt;
        end
        function x = get.doAvData(obj)
            x = obj.doAvData;
        end
        function x = get.AvData(obj)
            if obj.doAvData
                x = mean(obj.Data(:, :), 2);
            else
                x = NaN;
            end
        end
        function x = get.NoiseFloor(obj)
            x = obj.NoiseFloor;
        end
        function x = get.SNR(obj)
            if ~isempty(obj.NoiseFloor) && obj.doAvData
                S = abs(obj.AvData(1));
                N = rms(obj.AvData(obj.NoiseFloor:end));
                x = S/N;
            end
        end
        % Setters
        function obj = set.DataDomain(obj, x)
            obj.DataDomain = x;
        end
        function obj = set.Data(obj, x)
            obj.Data = x;
        end
        % Other
        function [obj, dd0] = setDataDomain(obj, varargin)
            dd0 = obj.DataDomain;
            if nargin == 1
                dd1 = datadomainMRS.Time;
            else
                dd1 = datadomainMRS(varargin{1});
            end
            if      dd0 && ~dd1
                fn = @(x)  fftshift( fft(x, [], 1), 1);
            elseif ~dd0 &&  dd1
                fn = @(x) ifft(ifftshift(x, 1), [], 1);
            else
                fn = @(x) x;
            end
            obj.Data = fn(obj.Data);
            obj.DataDomain = dd1;
        end
        function obj = PhaseAdjust(obj, w)
            obj.Data = first_order_phase_correction(obj.Data, obj.t, w);
        end
    end
end