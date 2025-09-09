function [w_YAR, Q] = active_function(yar_weights_long, yar_weights_near, yar_ubah_long, yar_ubah_near, data, win_long)
    % active_function - Three-state selection strategy for IPT model portfolio adjustment
    %
    %   [w_YAR, Q] = active_function(yar_weights_long, yar_weights_near, yar_ubah_long, yar_ubah_near, data, win_long)
    %   implements a three-state model selection strategy that adapts to varying
    %   market conditions by integrating recent trend, reversal potential and
    %   historical risk to calculate investment potential scores and model parameters.
    %
    %   This function is a core component of the Investment Potential Tracking (IPT)
    %   model, implementing the three-state selection strategy. It dynamically selects
    %   appropriate investment strategies based on overall market risk levels and outputs
    %   corresponding investment potential scores and model parameters Q_{t+1}.
    %
    % Inputs:
    %   yar_weights_long         - YAR factors from long-term window (n × m)
    %                              Yield-Adjusted Risk factors for long-term risk assessment \mathbf{w}_{t+1,\text{long-term}}
    %   yar_weights_near         - YAR factors from near-term window (n × m)
    %                              Yield-Adjusted Risk factors for near-term risk assessment \mathbf{w}_{t+1,\text{near-term}}
    %   yar_ubah_long            - YAR under UBAH model from long-term window (n × 1)
    %                              Yield-Adjusted Risk of UBAH portfolio for long-term market analysis w_{t+1,\text{long-term}}^{\text{ubah}}
    %   yar_ubah_near            - YAR under UBAH model from near-term window (n × 1)
    %                              Yield-Adjusted Risk of UBAH portfolio for near-term market analysis w_{t+1,\text{near-term}}^{\text{ubah}}
    %   data                     - Asset price data matrix (n × m)
    %                              The relative price for all assets over time periods \mathbf{x}_t
    %   win_long                 - Window size for long-term calculation (scalar)
    %                              Number of periods used for calculating long-term statistics d_l
    %
    % Outputs:
    %   w_YAR                    - Selected YAR weight matrix (n × m)
    %   Q                        - Model parameter Q_{t+1} vector (n × 1)
    %                              Represent different market states and strategies

    % Initialize model parameters
    alpha_reverse = 5; % Reversal coefficient for reversal effect intensity
    beta_reverse = 2; % Reversal multiplier for enhancing reversal intensity
    alpha_risk = 5; % Risk coefficient for risk effect intensity
    beta_risk = 2; % Risk multiplier for enhancing risk intensity
    q = 0.2; % Percentage value for distinguishing risk levels (20 %)
    L = 0.006; % Maximum YAR value under normal conditions

    % Calculate risk thresholds based on parameters' setting
    extremely_low_risk_threshold = q * L / 2;
    low_risk_threshold = q * L;
    normal_risk_threshold = (1 - q) * L;
    high_risk_threshold = (1 - q / 2) * L;

    % Initialize output matrices following problem setting: m = assets, n = periods
    [n_periods, m_assets] = size(data);
    w_YAR = zeros(n_periods, m_assets); % Investment potential score matrix (n × m)
    Q = zeros(n_periods, 1); % Model parameter Q_{t+1} vector (n × 1)

    % Iterate through each time period to determine optimal strategy
    for i = 1:n_periods - win_long

        % State 1: Extremely Low Risk Market (YAR <= extremely_low_risk_threshold)
        if yar_ubah_long(i) <= extremely_low_risk_threshold
            Q(i + win_long) = -beta_reverse * alpha_reverse; % Q_{t+1} = -10
            w_YAR(i + win_long, :) = yar_weights_long(i, :); % Use long-term portfolio weights

            % State 2: Low Risk Market (extremely_low_risk_threshold < YAR <= low_risk_threshold)
        elseif yar_ubah_long(i) <= low_risk_threshold
            Q(i + win_long) = -alpha_reverse; % Q_{t+1} = -5
            w_YAR(i + win_long, :) = yar_weights_long(i, :); % Use long-term portfolio weights

            % State 3: Normal/High Risk Market (YAR > low_risk_threshold)
        else

            % Analyze near-term risk using half-year window for finer granularity
            % Note: Index adjustment (i + win_long / 2) aligns with half-year timing

            % State 3a: Normal Risk sub-state (YAR <= normal_risk_threshold)
            if yar_ubah_near(i + win_long / 2) <= normal_risk_threshold
                Q(i + win_long) = 0; % Q_{t+1} = 0
                w_YAR(i + win_long, :) = yar_weights_near(i + win_long / 2, :); % Use near-term weights

                % State 3b: High Risk sub-state (normal_risk_threshold < YAR <= high_risk_threshold)
            elseif yar_ubah_near(i + win_long / 2) <= high_risk_threshold
                Q(i + win_long) = alpha_risk; % Q_{t+1} = 5
                w_YAR(i + win_long, :) = yar_weights_near(i + win_long / 2, :); % Use near-term weights

                % State 3c: Extremely High Risk sub-state (YAR > high_risk_threshold)
            else
                Q(i + win_long) = beta_risk * alpha_risk; % Q_{t+1} = 10
                w_YAR(i + win_long, :) = yar_weights_near(i + win_long / 2, :); % Use near-term weights for maximum risk control
            end
        end
    end
