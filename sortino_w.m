function [w] = sortino_w(data, inspect_wins)
    % SORTINO_W Calculate portfolio weights based on Sortino ratio for stock price data
    %
    %   [w] = sortino_w(data, inspect_wins) computes portfolio weights using
    %   Sortino ratio methodology on relative stock price data. The function
    %   calculates downside risk to determine optimal asset allocation weights.
    %
    %   Inputs:
    %       data        - Matrix of relative stock prices (T x N), where T is number of
    %                     time periods and N is number of assets
    %       inspect_wins - Integer, window size for rolling calculation
    %
    %   Output:
    %       w           - Matrix of portfolio weights (T-inspect_wins x N) representing
    %                     the proportion of investment allocated to each asset
    %
    %   Algorithm:
    %       1. Calculate rolling mean returns for each asset over the inspection window
    %       2. Compute total risk (R) using all returns in the window
    %       3. Compute downside risk (DR) considering only negative returns
    %       4. Return downside risk as portfolio weights for asset allocation
    %
    %   Note: The function uses downside deviation (only negative returns) instead of
    %         standard deviation, which is the key characteristic of Sortino ratio
    [m_periods, n_assets] = size(data);
    return_rate_mean_total = ones(m_periods - inspect_wins, n_assets);

    for i = 1:m_periods - inspect_wins
        return_rate_sample_mean = mean(data(i:inspect_wins + i - 1, :));
        return_rate_mean_total(i, :) = return_rate_sample_mean(1, :);
    end

    R_total = ones(m_periods - inspect_wins, n_assets);

    for i = 1:m_periods - inspect_wins
        x_minus_mean = data(i:inspect_wins + i - 1, :) - 1;
        x_minus_mean_sum_sqrt = ones(1, n_assets);
        x_minus_mean_sample = ones(1, inspect_wins);

        for j = 1:n_assets

            for k = 1:inspect_wins
                x_minus_mean_sample(1, k) = (x_minus_mean(k, j)) ^ 2;
            end

            x_minus_mean_sum_sqrt(1, j) = sqrt(sum(x_minus_mean_sample) / (inspect_wins));
        end

        R_total(i, :) = x_minus_mean_sum_sqrt(1, :);
    end

    DR_total = ones(m_periods - inspect_wins, n_assets);

    for i = 1:m_periods - inspect_wins
        negetive_date = zeros(1, n_assets);
        x_minus_mean = data(i:inspect_wins + i - 1, :) - 1;
        %%x_minus_mean = data(i:inspect_wins+i-1,:)-mean(data(i:inspect_wins+i-1,:));
        for k = 1:inspect_wins

            for j = 1:n_assets

                if x_minus_mean(k, j) > 0
                    x_minus_mean(k, j) = 0;
                else
                    negetive_date(1, j) = negetive_date(1, j) + 1;
                end

            end

        end

        x_minus_mean_sum_sqrt = ones(1, n_assets);
        x_minus_mean_sample = ones(1, inspect_wins);

        for j = 1:n_assets

            for k = 1:inspect_wins
                x_minus_mean_sample(1, k) = (x_minus_mean(k, j)) ^ 2;
            end

            x_minus_mean_sum_sqrt(1, j) = sqrt(sum(x_minus_mean_sample) / (negetive_date(1, j)));
        end

        DR_total(i, :) = x_minus_mean_sum_sqrt(1, :);
    end

    %w = DR_total./return_rate_mean_total;
    w = DR_total;
