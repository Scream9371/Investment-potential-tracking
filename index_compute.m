function [index] = index_compute(data)
    [m_periods, n_assets] = size(data);
    stock_price = ones(m_periods, n_assets);

    for i = 2:m_periods
        stock_price(i, :) = stock_price(i - 1, :) .* data(i, :);
    end

    index = ones(m_periods, 1);

    for i = 2:m_periods
        index(i) = sum(stock_price(i, :)) / sum(stock_price(i - 1, :));
    end
