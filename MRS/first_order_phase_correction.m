function FID = first_order_phase_correction(FID, t, window)
    A = unwrap(angle(FID), [], 1);
    idx = window(1) < t & t < window(2);
    for n = 1:size(A(:, :), 2)
        A(:, n) = A(:, n) - polyval(polyfit(t(idx), A(idx, n), 1), t);
    end
    FID = abs(FID).*exp(complex(0, A));
end