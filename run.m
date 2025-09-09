% Main execution script for IPT (Investment Potential Tracking) algorithm
% This script implements the complete IPT workflow:
% 1. Data loading and parameter initialization
% 2. YAR calculation for long-term and near-term windows
% 3. UBAH portfolio price ratio calculation
% 4. Three-state model selection strategy
% 5. IPT model execution with BP algorithm optimization

% Window parameters
win_year = 252; % Long-term window size for YAR calculation (~1 year)
win_4mon = 84; % Window size for UBAH YAR calculation (~4 months)
win_bp = 5; % Window size for peak price tracking (BP algorithm, ω=5)

% Transaction and model parameters
tran_cost = 0.001; % Transaction cost rate (0.1 %)

% Load dataset
load('Data Set\nyse-n.mat');
[n_periods, m_assets] = size(data);

% Step 1: Calculate YAR weights for long-term and near-term windows
% w_{t+1,long-term} and w_{t+1,near-term}
weights_long = zeros(n_periods, m_assets);
yar_weights_long = yar_weights(data, win_year); % YAR for each asset in long-term window (d_l = 252)
weights_long(win_year + 1:n_periods, :) = yar_weights_long(:, :);

weights_near = zeros(n_periods, m_assets);
yar_weights_near = yar_weights(data, win_year / 2); % YAR for each asset in near-term window (d_n = 126)
weights_near(win_year / 2 + 1:n_periods, :) = yar_weights_near(:, :);

% Step 2: Calculate UBAH portfolio price ratios P^{ubah}_t / P^{ubah}_{t-1}
% Where P^{ubah}_t = ∑(p_t^i) / m
ratio = ubah_price_ratio(data);

% Step 3: Calculate YAR factors for UBAH model under different windows
% YAR_{t+1}^{ubah} = [√∑(min(P^{ubah}_t/P^{ubah}_{t-1} - 1, 0))² / n_negative] / [(1/n)∑r_t^i + 1]
ubah_long = zeros(n_periods, 1);
yar_ubah_long = yar_ubah(ratio(win_4mon - win_4mon + 1:n_periods, :), win_4mon); % YAR of long-term window under UBAH model
ubah_long(win_4mon + 1:n_periods, 1) = yar_ubah_long(:, 1);

yar_near = zeros(n_periods, 1);
yar_ubah_near = yar_ubah(ratio(win_4mon / 2 - win_4mon / 2 + 1:n_periods, :), win_4mon / 2); % YAR of near-term window under UBAH model
yar_near(win_4mon / 2 + 1:n_periods, 1) = yar_ubah_near(:, 1);

% Step 4: Three-state model selection strategy, determines Q_{t+1} and selects appropriate w_{t+1}
[w_YAR, Q] = active_function(yar_weights_long, yar_weights_near, yar_ubah_long, yar_ubah_near, data, win_year);

% Step 5: IPT model execution with BP algorithm optimization, maximizes cumulative wealth through gradient projection
[cum_wealth, daily_return, b_history] = IPT_run(data, win_bp, tran_cost, w_YAR, Q);
