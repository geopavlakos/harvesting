function [S_hat,info] = Multiview3DPict(boxCenter,boxSize,camParam,heatmaps,bbox2D,skel,template)

    njoint = size(template,2);
    heatmapSize = [size(heatmaps{1},1),size(heatmaps{1},2)];

    % discretizing solution space
    nBins = 32;
    %nBins = heatmapSize(1);

    grid1D = linspace(-boxSize/2,boxSize/2,nBins);
    [GridX,GridY,GridZ] = ndgrid(grid1D+boxCenter(1),...
                                 grid1D+boxCenter(2),...
                                 grid1D+boxCenter(3));
    xyz = [GridX(:),GridY(:),GridZ(:)]';

    % unary terms
    unary = cell(njoint,1);
    for i = 1:njoint
        unary{i} = ones(size(GridX));
    end

    % assign unary values
    for camID = 1:length(camParam)

        xy = proj22D(xyz,camParam{camID});
        xy(1,:) = (xy(1,:)-bbox2D{camID}(1))/(bbox2D{camID}(3)-bbox2D{camID}(1))*(heatmapSize(2));
        xy(2,:) = (xy(2,:)-bbox2D{camID}(2))/(bbox2D{camID}(4)-bbox2D{camID}(2))*(heatmapSize(1));

        for i = 1:njoint
            hmap = double(heatmaps{camID}(:,:,i));
            hmap(hmap(:)<0) = 0; % hmap = hmap/sum(hmap(:)); 
            score = interp2(hmap,xy(1,:)',xy(2,:)','linear',0) + eps;
            unary{i} = unary{i} .* reshape(score,size(unary{i}));
        end

    end

    % construct pictorial model
    edges = getPictoStruct(skel,template);
    for i = 1:length(edges)
        edges(i).length = edges(i).length * nBins/boxSize;
        edges(i).sigma = inf; % uniform prior
        edges(i).tol = 1; % in a restricted limb length range
    end

    % solve the inference
    marginal = inferPict3D_SumProd(unary,edges);
    S_hat = zeros(size(template));
    for i = 1:njoint
        mu = xyz*marginal{i}(:);
        cov = bsxfun(@times,marginal{i}(:)',bsxfun(@minus,xyz,mu))*bsxfun(@minus,xyz,mu)';
        S_hat(:,i) = mu;
        info.mu(:,i) = mu;
        info.cov(:,:,i) = cov;
    end
    for i = 1:njoint
        info.marginal{i} = single(marginal{i});
    end
