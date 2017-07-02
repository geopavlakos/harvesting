function marginal = inferPict3D_SumProd(unary,edges)

% initialize
marginal = unary;

% upstream message passing
for i = 1:length(edges)
    msg =  msgpass_sumprod(marginal{edges(i).child},...
        edges(i).length,edges(i).sigma,edges(i).tol) + eps;
    marginal{edges(i).parent} = msg .* marginal{edges(i).parent};
end

% downstream message passing
for i = length(edges):-1:1
    msg =  msgpass_sumprod(marginal{edges(i).parent},...
        edges(i).length,edges(i).sigma,edges(i).tol) + eps;
    marginal{edges(i).child} = msg .* marginal{edges(i).child};
end

% normalize
for i = 1:length(marginal)
    marginal{i} = marginal{i} / sum(marginal{i}(:));
end
