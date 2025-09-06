w_inspect_wins = 252;
r_inspect_wins = 84;
win_size = 5;
tran_cost = 0.001;

% Load dataset
load('Data Set\nyse-o.mat');

[m_periods, n_assets] = size(data);

% Weights for full-year observation window
b_full_year = zeros(m_periods, n_assets);
b_value_full_year = sortino_w(data, w_inspect_wins);
b_full_year(w_inspect_wins + 1:m_periods, :) = b_value_full_year(:, :);

% Weights for half-year observation window
b_half_year = zeros(m_periods, n_assets);
b_value_half_year = sortino_w(data, w_inspect_wins / 2);
b_half_year(w_inspect_wins / 2 + 1:m_periods, :) = b_value_half_year(:, :);

index = index_compute(data);
reverse_factor = 5;
risk_factor = 5;

% Active factors for full-year observation window
active_factor_full_year = zeros(m_periods, 1);
active_factor_value_full_year = sortino_r(index(w_inspect_wins - r_inspect_wins + 1:m_periods, :), r_inspect_wins);
active_factor_full_year(w_inspect_wins + 1:m_periods, 1) = active_factor_value_full_year(:, 1);

% Active factors for half-year observation window
active_factor_half_year = zeros(m_periods, 1);
active_factor_value_half_year = sortino_r(index(w_inspect_wins / 2 - r_inspect_wins / 2 + 1:datasets_T, :), r_inspect_wins / 2);
active_factor_half_year(w_inspect_wins / 2 + 1:m_periods, 1) = active_factor_value_half_year(:, 1);

[b, r] = active_function(b_value_full_year, b_value_half_year, active_factor_value_full_year, active_factor_value_half_year, data, w_inspect_wins, reverse_factor, risk_factor);

[cum_wealth, daily_incre_fact, daily_port_total] = IPT_run(data, win_size, tran_cost, w, r);
