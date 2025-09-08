function [YAR_factor] = yar_factors(index, inspect_wins)
    % yar_factors - Calculate YAR (Yield-Adjusted Risk) factor for market index data
    %
    %   [YAR_factor] = yar_factors(index, inspect_wins) computes the YAR factor
    %   (risk-adjusted factor) for portfolio adjustment using YAR methodology on
    %   market index data as proposed in the IPT paper.
    %
    %   Inputs:
    %     index          - Matrix of market index data (n × m), where n is number of
    %                      time periods and m is number of assets
    %     inspect_wins   - Integer, window size for rolling calculation
    %
    %   Output:
    %     YAR_factor     - Matrix of YAR factors (n - inspect_wins × m) used for
    %                      portfolio risk management and adjustment
    %
    %   Algorithm (following IPT paper):
    %       1. Calculate rolling mean returns for each asset over the inspection window
    %       2. Compute ADV (Average Downside Volatility) by considering only negative returns
    %       3. Calculate YAR factor as ADV divided by (mean returns + 1)
    %       4. The result is used to adjust portfolio weights based on market conditions

    [n_periods, m_assets] = size(index);
    mean_returns_total = ones(n_periods - inspect_wins, m_assets);

    for i = 1:n_periods - inspect_wins
        returns_sample_mean = mean(index(i:inspect_wins + i - 1, :));
        mean_returns_total(i, :) = returns_sample_mean(1, :);
    end

    % Calculate ADV (Average Downside Volatility) - core component of YAR
    ADV_total = ones(n_periods - inspect_wins, m_assets);

    for i = 1:n_periods - inspect_wins
        negative_periods_count = zeros(1, m_assets);
        returns_minus_one = index(i:inspect_wins + i - 1, :) - 1;
        % returns_minus_mean = index(i:inspect_wins+i-1,:)-mean(index(i:inspect_wins+i-1,:));
        for k = 1:inspect_wins

            for j = 1:m_assets

                if returns_minus_one(k, j) > 0
                    returns_minus_one(k, j) = 0;
                else
                    negative_periods_count(1, j) = negative_periods_count(1, j) + 1;
                end

            end

        end

        downside_volatility_sqrt = ones(1, m_assets);
        downside_returns_sample = ones(1, inspect_wins);

        for j = 1:m_assets

            for k = 1:inspect_wins
                downside_returns_sample(1, k) = (returns_minus_one(k, j)) ^ 2;
            end

            % ADV calculation: sqrt(sum(negative_returns_squared) / negative_periods_count)
            downside_volatility_sqrt(1, j) = sqrt(sum(downside_returns_sample)) / (negative_periods_count(1, j));
        end

        ADV_total(i, :) = downside_volatility_sqrt(1, :);
    end

    % Calculate YAR factor = ADV / (mean_returns + 1)
    YAR_factor = ADV_total ./ (mean_returns_total + 1);
