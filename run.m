w_inspect_wins=252;
r_inspect_wins=84;
win_size = 5;
tran_cost = 0.001;
[datasets_T,datasets_N ]=size(datasets);

% 以全年为窗口观察的w
w_full_year = zeros(datasets_T,datasets_N);
w_value_full_year = sortino_w(datasets,w_inspect_wins);
w_full_year(w_inspect_wins+1:datasets_T,:) = w_value_full_year(:,:);
% 以半年为窗口观察的w
w_half_year = zeros(datasets_T,datasets_N);
w_value_half_year = sortino_w(datasets,w_inspect_wins/2);
w_half_year(w_inspect_wins/2+1:datasets_T,:) = w_value_half_year(:,:);

index = index_compute(datasets);
reverse_factor = 5;
risk_factor = 5;

% 以全年为窗口观察的激活因子
active_factor_full_year = zeros(datasets_T,1);
active_factor_value_full_year=sortino_r(index(w_inspect_wins-r_inspect_wins+1:datasets_T,:),r_inspect_wins);
active_factor_full_year(w_inspect_wins+1:datasets_T,1) = active_factor_value_full_year(:,1);
% 以半年为窗口观察的激活因子
active_factor_half_year = zeros(datasets_T,1);
active_factor_value_half_year=sortino_r(index(w_inspect_wins/2-r_inspect_wins/2+1:datasets_T,:),r_inspect_wins/2);
active_factor_half_year(w_inspect_wins/2+1:datasets_T,1) = active_factor_value_half_year(:,1);

[w,r] = active_function(w_value_full_year,w_value_half_year,active_factor_value_full_year,active_factor_value_half_year,datasets,w_inspect_wins,reverse_factor,risk_factor);

[cum_wealth, daily_incre_fact, daily_port_total] = RPPT_run(datasets, win_size, tran_cost,w,r);

