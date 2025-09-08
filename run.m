% Window parameters
win_year = 252; % YAR of each assets window size (~1 year)
win_season = 84; % UBAH model window size (~4 months)
win_bp = 5; % Backpropagation window size (BP algorithm)

% Transaction and model parameters
tran_cost = 0.001; % Transaction cost rate (0.1 %)

% Load dataset
load('Data Set\nyse-n.mat');
[n_periods, m_assets] = size(data);

% PPT portfolio weights calculation
weights_long = zeros(n_periods, m_assets);
yar_weights_long = yar_weights(data, win_year); % The YAR of each assets in a long-term window
weights_long(win_year + 1:n_periods, :) = yar_weights_long(:, :);

weights_near = zeros(n_periods, m_assets);
yar_weights_near = yar_weights(data, win_year / 2); % The YAR of each assets in a near-term window
weights_near(win_year / 2 + 1:n_periods, :) = yar_weights_near(:, :);

% Calculate UBAH portfolio price index
index = index_compute(data);

% YAR factors calculation
yar_long = zeros(n_periods, 1);
yar_ubah_long = yar_factors(index(win_season - win_season + 1:n_periods, :), win_season); % YAR of long-term window under the UBAH model
yar_long(win_season + 1:n_periods, 1) = yar_ubah_long(:, 1);

yar_near = zeros(n_periods, 1);
yar_ubah_near = yar_factors(index(win_season / 2 - win_season / 2 + 1:n_periods, :), win_season / 2); % YAR of near-term window under the UBAH model
yar_near(win_season / 2 + 1:n_periods, 1) = yar_ubah_near(:, 1);

% Three-state model selection strategy
[w_YAR, Q] = active_function(yar_weights_long, yar_weights_near, yar_ubah_long, yar_ubah_near, data, win_year);

% IPT model execution (BP algorithm optimization)
[cum_wealth, daily_return, b_history] = IPT_run(data, win_bp, tran_cost, w_YAR, Q);
