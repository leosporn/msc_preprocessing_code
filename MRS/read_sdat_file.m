function [FID, spar] = read_sdat_file(filename, varargin)
    % READ_SDAT_FILE  load data from .SDAT file.
    %
    % FID = READ_SDAT_FILE(sdat_filename) opens .SDAT file and returns the
    % raw FID data in a NxM complex array, where N is the number of
    % datapoints in each FID and M is the number of FIDs.
    %
    % FID = READ_SDAT_FILE(sdat_filename, spar_filename)
    %
    % FID = READ_SDAT_FILE(sdat_filename, spar)
    %
    % [FID, spar] = READ_SDAT_FILE(...) also returns the .SPAR struct (see
    % READ_SPAR_FILE).
    %
    spar = read_spar_data(filename, varargin{:});
    FID = open_sdat_data_file(filename);
    FID = reshape(complex(FID(1:2:end), FID(2:2:end)), spar.samples, []);
    function spar = read_spar_data(filename, varargin)
        if nargin == 1
            [pathname, filename, ~] = fileparts(filename);
            spar = read_spar_data(fullfile(pathname, [filename '.SDAT']), ...
                                  fullfile(pathname, [filename '.SPAR']));
        elseif isstruct(varargin{1})
            spar = varargin{1};
        elseif isfile(varargin{1})
            spar = read_spar_file(varargin{1});
        else
            error('spar not found')
        end
    end
    function FID = open_sdat_data_file(filename)
        [pathname, filename] = fileparts(filename);
        fileID = fopen(fullfile(pathname, [filename '.SDAT']), 'r', 'ieee-le');
        FID = read_vax(fileID, 'VAXD', inf, 'float');
        fclose(fileID);
    end
end