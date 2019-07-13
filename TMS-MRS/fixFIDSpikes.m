function [y, idx, y0] = fixFIDSpikes(y0, x, window, threshold)
    % FIXFIDSPIKES  removes spikes from FID,
    %
    % y = FIXFIDSPIKES(y0, x, window, threshold) removes spikes from the
    % input FID y0 by (1) calculating the second derivative of the FID, and
    % (2), identifying all points where its value is higher than that of a
    % mvoing mean of width window on either side, multiplied by threshold.
    %
    % [y, idx] = FIXFIDSPIKES(y0, x, window, threshold) also returns the
    % indec of the points that are part of spikes.
    %
    if isscalar(window)
        window = repmat(window, [2 1]);
    end
    y = y0(:, :);
    d2 = abs(diff(y, 2, 1));
    idx = false(size(y));
    idx(2:(end - 1), :) = d2./movmean(d2, window) > threshold;
    for n = 1:size(idx(:, :), 2)
        y(:, n) = interpFID(y(:, n), x, find(idx(:, n)));
    end
    y = reshape(y, size(y0));
end