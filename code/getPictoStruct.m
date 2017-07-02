function edges = getPictoStruct(skel,S)

graph = skel.tree;
level = zeros(length(graph),1);
for i = 1:length(graph)
    queue = [graph(i).children];
    if ~isempty(queue)
        for j = 1:length(queue)
            graph(queue(j)).parent = i;
            graph(queue(j)).dist_to_parent = norm(S(1:3,i)-S(1:3,queue(j)));
        end
        while ~isempty(queue)
            level(queue(1)) = level(queue(1)) + 1;
            queue = [queue,graph(queue(1)).children];
            queue(1) = [];
        end
    end
end

[~,trans_order] = sort(level,'descend');

for i = 1:length(trans_order)-1
    edges(i).child = trans_order(i);
    edges(i).parent = graph(edges(i).child).parent;
    edges(i).length = graph(edges(i).child).dist_to_parent;
end



