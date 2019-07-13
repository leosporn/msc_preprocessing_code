function spar = read_spar_file(filename)
    % READ_SPAR_FILE  load data from .SPAR file.
    %
    % spar = READ_SPAR_FILE(spar_filename) opens .SPAR file and uses it to
    % create a struct.
    %
    txt = open_spar_text_file(filename);
    txt(1, :) = format_fields(txt(1, :));
    txt(2, :) = format_values(txt(2, :));
    spar = struct(txt{:});
    spar = rescale_synthesizer_frequency(spar);
    spar = add_nonexistent_fields(spar);
    function txt = open_spar_text_file(filename)
        [pathname, filename, ~] = fileparts(filename);
        fileID = fopen(fullfile(pathname, [filename '.SPAR']));
        txt = textscan(fileID, '%s', 'delimiter', '', 'whitespace', '');
        fclose(fileID);
        txt = txt{1};
        txt = txt(cellfun(@(x) ~startsWith(x, '!'), txt));
        txt = strtrim(split(txt, ' :'))';
    end
    function fn = format_fields(fn)
        fn = regexprep(fn, {'\s' '\.'}, {'' '_'});
    end
    function vn = format_values(vn)
        vn = cellfun(@(s) format_value(s), vn, 'UniformOutput', false);
        function v = format_value(v)
            n = str2double(v);
            if ~isnan(n)
                v = n;
            end
        end
    end
    function spar = rescale_synthesizer_frequency(spar)
        if spar.synthesizer_frequency < 1e4
            warning('synthesizer frequency = %d\nmultiplying by 1000', ...
                    spar.synthesizer_frequency)
            spar.synthesizer_frequency = 1e3*spar.synthesizer_frequency;
        end
    end
    function spar = add_nonexistent_fields(spar)
        fields = {'lr_angulation' 'si_lr_angulation';
                  'ap_angulation' 'si_ap_angulation';
                  'cc_angulation' 'si_cc_angulation';
                  'lr_size'       'phase_encoding_fov';
                  'ap_size'       'phase_encoding_fov';
                  'cc_size'       'slice_thickness'};
        for n = 1:size(fields, 1)
            if ~isfield(spar, (fields{n, 1}))
                if isfield(spar, fields{n, 2})
                    spar.(fields{n, 1}) = spar.(fields{n, 2});
                else
                    warning('unable to replace %s, %s does not exist', ...
                            fields{n, 1}, fields{n, 2})
                end
            end
        end
    end
end