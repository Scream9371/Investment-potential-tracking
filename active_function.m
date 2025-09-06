function [b, r] = active_function(b_full_year, b_half_year, active_factor_full_year, active_factor_half_year, data, inspect_wins, reverse_factor, risk_factor)
    [m_periods, n_assets] = size(data);
    b = zeros(m_periods, n_assets);
    r = zeros(m_periods, 1);

    for i = 1:m_periods - inspect_wins

        if active_factor_full_year(i) <= 0.0003
            r(i + inspect_wins) = -2 * reverse_factor;
            b(i + inspect_wins, :) = b_full_year(i, :);
        elseif active_factor_full_year(i) <= 0.006
            r(i + inspect_wins) = -reverse_factor;
            b(i + inspect_wins, :) = b_full_year(i, :);
        else

            if active_factor_half_year(i + inspect_wins / 2) <= 0.0054
                r(i + inspect_wins) = 0;
                b(i + inspect_wins, :) = b_half_year(i + inspect_wins / 2, :);
            elseif active_factor_half_year(i + inspect_wins / 2) <= 0.0057
                r(i + inspect_wins) = risk_factor;
                b(i + inspect_wins, :) = b_half_year(i + inspect_wins / 2, :);
            else
                r(i + inspect_wins) = 2 * risk_factor;
                b(i + inspect_wins, :) = b_half_year(i + inspect_wins / 2, :);
            end

        end

    end
