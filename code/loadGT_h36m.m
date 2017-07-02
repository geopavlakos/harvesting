function [S_gt,W_gt,camParam] = loadGT_h36m(datapath,subject,action,cam_name)

    if sum(ismember([1,5,6,7,8],subject))
        set = 'train';
    elseif sum(ismember([9,11],subject))
        set = 'valid';
    end

    imnames = importdata(sprintf('%s/annot/%s_images.txt',datapath,set));
    load(sprintf('%s/annot/%s.mat',datapath,set));

    camParam = cell(length(cam_name),1);
    W_gt = cell(length(cam_name),1);
    S_gt = [];
    
    for j = 1:length(cam_name)
        idxs = strfind(imnames, sprintf('S%d_%s.%s',subject,action,cam_name{j}));
        ind = [];
        for i = 1:length(idxs)
            if ~isempty(idxs{i})
                ind = [ind;i];
            end
        end
        camParam{j} = annot.cam{ind(1)};
        W_gt{j} = annot.part(ind,:,:);
        S_gt = annot.S_glob(ind,:,:);
        % reshape
        W_gt{j} = permute(W_gt{j},[2,1,3]);
        W_gt{j} = reshape(W_gt{j},2*size(W_gt{j},2),size(W_gt{j},3));
        S_gt = permute(S_gt,[2,1,3]);
        S_gt = reshape(S_gt,3*size(S_gt,2),size(S_gt,3));
    end
