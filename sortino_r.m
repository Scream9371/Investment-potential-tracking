function [active_factor] = sortino_r(index, inspect_wins)
% SORTINO_R Calculate active factor based on Sortino ratio for market index data
%
%   [active_factor] = sortino_r(index, inspect_wins) computes the active factor
%   (risk factor) for portfolio adjustment using Sortino ratio methodology on
%   market index data.
%
%   Inputs:
%       index       - Matrix of market index data (T x N), where T is number of
%                     time periods and N is number of assets
%       inspect_wins - Integer, window size for rolling calculation
%
%   Output:
%       active_factor - Matrix of risk factors (T-inspect_wins x N) used for
%                       portfolio risk management
%
%   Algorithm:
%       1. Calculate rolling mean returns for each asset over the inspection window
%       2. Compute downside risk (DR) by considering only negative returns
%       3. Calculate active factor as DR divided by mean returns
%       4. The result is used to adjust portfolio weights based on market conditions
    [T, N] = size(index);
    return_rate_mean_total = ones(T - inspect_wins, N);

    for i = 1:T - inspect_wins
        return_rate_sample_mean = mean(index(i:inspect_wins + i - 1, :));
        return_rate_mean_total(i, :) = return_rate_sample_mean(1, :);
    end

    DR_total = ones(T - inspect_wins, N);

    for i = 1:T - inspect_wins
        negetive_date = zeros(1, N);
        x_minus_mean = index(i:inspect_wins + i - 1, :) - 1;
        %%x_minus_mean = index(i:inspect_wins+i-1,:)-mean(index(i:inspect_wins+i-1,:));
        for k = 1:inspect_wins

            for j = 1:N

                if x_minus_mean(k, j) > 0
                    x_minus_mean(k, j) = 0;
                else
                    negetive_date(1, j) = negetive_date(1, j) + 1;
                end

            end

        end

        x_minus_mean_sum_sqrt = ones(1, N);
        x_minus_mean_sample = ones(1, inspect_wins);

        for j = 1:N

            for k = 1:inspect_wins
                x_minus_mean_sample(1, k) = (x_minus_mean(k, j)) ^ 2;
            end

            x_minus_mean_sum_sqrt(1, j) = sqrt(sum(x_minus_mean_sample)) / (negetive_date(1, j));
        end

        DR_total(i, :) = x_minus_mean_sum_sqrt(1, :);
    end

    active_factor = DR_total ./ return_rate_mean_total;
