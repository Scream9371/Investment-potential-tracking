function [w]=sortino_w(data,inspect_wins)
[T, N]=size(data);
return_rate_mean_total = ones(T-inspect_wins,N);
for i = 1:T-inspect_wins
    return_rate_sample_mean = mean(data(i:inspect_wins+i-1,:));
    return_rate_mean_total(i,:) = return_rate_sample_mean(1,:);
end

R_total = ones(T-inspect_wins,N);
for i = 1:T-inspect_wins
    x_minus_mean = data(i:inspect_wins+i-1,:)-1;
    x_minus_mean_sum_sqrt = ones(1,N);
    x_minus_mean_sample = ones(1,inspect_wins);
    for j = 1:N
        for k = 1:inspect_wins
        x_minus_mean_sample(1,k) = (x_minus_mean(k,j))^2;
        end
        x_minus_mean_sum_sqrt(1,j) = sqrt(sum(x_minus_mean_sample)/(inspect_wins));
    end
    R_total(i,:) =  x_minus_mean_sum_sqrt(1,:);
end
w = R_total;

DR_total = ones(T-inspect_wins,N);

for i = 1:T-inspect_wins
    negetive_date = zeros(1,N);
    x_minus_mean = data(i:inspect_wins+i-1,:)-1;
    %%x_minus_mean = data(i:inspect_wins+i-1,:)-mean(data(i:inspect_wins+i-1,:));
    for k = 1:inspect_wins
        for j = 1:N
            if x_minus_mean(k,j)>0
                x_minus_mean(k,j) = 0;
            else
                negetive_date(1,j) = negetive_date(1,j)+1;
            end
        end
    end
    x_minus_mean_sum_sqrt = ones(1,N);
    x_minus_mean_sample = ones(1,inspect_wins);
    for j = 1:N
        for k = 1:inspect_wins
        x_minus_mean_sample(1,k) = (x_minus_mean(k,j))^2;
        end
        x_minus_mean_sum_sqrt(1,j) = sqrt(sum(x_minus_mean_sample)/(negetive_date(1,j)));
    end
    DR_total(i,:) =  x_minus_mean_sum_sqrt(1,:);
end
%w = DR_total./return_rate_mean_total;
w = DR_total;
    


