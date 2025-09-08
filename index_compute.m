function [index] = index_compute(data)
    [n_periods, m_assets] = size(data);
    stock_price = ones(n_periods, m_assets);

    for i = 2:n_periods
        stock_price(i, :) = stock_price(i - 1, :) .* data(i, :);
    end

    index = ones(n_periods, 1);

    for i = 2:n_periods
        index(i) = sum(stock_price(i, :)) / sum(stock_price(i - 1, :));
    end
