function [cum_wealth, daily_return, b_history] = IPT_run(x_rel, win_size, trans_cost, w_YAR, Q_factor)
    % IPT_run - Main execution of Investment Potential Tracking strategy
    %
    % This function implements the core Investment Potential Tracking (IPT) algorithm,
    % an improved version of Peak Price Tracking (PPT)[1]. It dynamically adjusts
    % portfolio weights based on asset performance trends and risk factors.
    %
    % References:
    % [1] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. "A peak price tracking 
    %     based learning system for portfolio selection", IEEE Transactions on Neural Networks and Learning Systems, 2017. Accepted.
    % [2] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. "Radial basis functions 
    %     with adaptive input and composite trend representation for portfolio selection", 
    %     IEEE Transactions on Neural Networks and Learning Systems, 2018. Accepted.
    % [3] Pei-Yi Yang, Zhao-Rong Lai*, Xiaotian Wu, Liangda Fang. "Trend Representation 
    %     Based Log-density Regularization System for Portfolio Optimization", 
    %     Pattern Recognition, vol. 76, pp. 14-24, Apr. 2018.
    % [4] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra. "Efficient
    %     projections onto the l1-ball for learning in high dimensions", in
    %     Proceedings of the International Conference on Machine Learning (ICML 2008), 2008.
    % [5] B. Li, D. Sahoo, and S. C. H. Hoi. Olps: a toolbox for on-line portfolio selection.
    %     Journal of Machine Learning Research, 17, 2016.
    %
    % Inputs:
    %   x_rel       - T x N matrix of price relatives (daily returns)
    %   win_size    - Lookback window size for peak price
    %   trans_cost  - Transaction cost rate (e.g., 0.001 = 0.1%)
    %   w_YAR       - T x N matrix of Yield-Adjusted Risk (YAR) values
    %   Q_factor    - T x 1 vector of effect factor coefficients
    %
    % Outputs:
    %   cum_wealth  - T x 1 cumulative wealth curve
    %   daily_return - T x 1 daily portfolio returns
    %   b_history   - N x T matrix of portfolio weights over time

    [T, n_assets] = size(x_rel);

    % Initialize variables
    cum_wealth = ones(T, 1);
    daily_return = ones(T, 1);
    b_current = ones(n_assets, 1) / n_assets; % Equal initial weights
    b_history = zeros(n_assets, T);
    b_prev = zeros(n_assets, 1); % Previous adjusted weights

    % Construct close price series
    p_close = cumprod([ones(1, n_assets); x_rel]);

    % Main loop
    for t = 1:T
        % Record current portfolio
        b_history(:, t) = b_current;

        % Calculate daily return with transaction cost
        port_return = x_rel(t, :) * b_current;
        turnover_cost = trans_cost / 2 * sum(abs(b_current - b_prev));
        daily_return(t) = port_return * (1 - turnover_cost);

        % Update cumulative wealth
        cum_wealth(t) = cum_wealth(max(1, t - 1)) * daily_return(t);

        % Adjust previous portfolio for cost calculation
        b_prev = (b_current .* x_rel(t, :)') / (x_rel(t, :) * b_current);

        % Update portfolio for next period (except last)
        if t < T
            b_current = IPT(p_close, x_rel, t, b_current, win_size, w_YAR, Q_factor);
        end

    end
