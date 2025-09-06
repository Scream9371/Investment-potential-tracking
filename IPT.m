function [b_next] = IPT(p_close, x_rel, current_t, b_current, win_size, w_YAR, Q_factor)
    % IPT - Investment Potential Tracking algorithm for portfolio selection
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
    %   p_close       - T x N matrix of close price sequences for T time periods and N assets
    %   x_rel         - T x N matrix of price relative sequences (daily price ratios)
    %   current_t     - Current time step t (integer)
    %   b_current     - N x 1 vector of portfolio weights at time t
    %   win_size      - Window size for peak price calculation (integer)
    %   w_YAR         - T x N matrix of Yield-Adjusted Risk values
    %   Q_factor      - T x 1 vector of effect factor coefficients
    %
    % Output:
    %   b_next        - N x 1 vector of updated portfolio weights at time t+1
    %
    % Example:
    %   b_next = IPT(p_close, x_rel, current_t, b_current, win_size, w_YAR, Q_factor);
    
    epsilon = 100; % Learning rate parameter controlling the update step size
    %a = 0.5;

    nstk = size(x_rel, 2); % Number of assets in the portfolio

    % Check if we have enough data for window-based peak prediction
    if current_t < win_size + 1
        % Early period: use simple price relative with risk adjustment
        x_tplus1 = 1.0 .* x_rel(current_t, :) - Q_factor(current_t) .* w_YAR(current_t, :);
    else
        % Sufficient data: use peak price prediction from historical window
        closebefore = p_close((current_t - win_size + 1):(current_t), :);
        closepredict = max(closebefore); % Peak price within the window

        % Alternative prediction method (commented out):
        % closepredict = (a.*closebefore(5,:) + a.*(1-a).*closebefore(4,:) +
        %               a.*(1-a)^2.*closebefore(3,:) + a.*(1-a)^3.*closebefore(2,:) +
        %               a.*(1-a)^4.*closebefore(1,:));

        % Calculate expected return using predicted peak price
        x_tplus1 = 1.0 .* (closepredict ./ p_close(current_t, :)) - Q_factor(current_t) .* w_YAR(current_t, :);
    end

    % Center the return vector by removing mean component
    onesd = ones(nstk, 1);
    centering_matrix = eye(nstk) - onesd * onesd' / nstk; % Centering matrix
    x_tplus1_cent = centering_matrix * x_tplus1'; % Centered expected returns

    % Update portfolio weights using gradient-based approach
    if norm(x_tplus1_cent) ~= 0
        % Normalize the centered returns and apply learning rate
        b_current = b_current + epsilon * x_tplus1_cent / norm(x_tplus1_cent);
    end

    % Project portfolio onto simplex to ensure constraints (sum=1, non-negative)
    b_next = simplex_projection_selfnorm2(b_current, 1);
