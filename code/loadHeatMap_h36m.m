function heatmap = loadHeatMap_h36m(datapath,subject,filename)

    if sum(ismember([1,5,6,7,8],subject))
        set = 'train';
    elseif sum(ismember([9,11],subject))
        set = 'valid';
    end

    imnames = importdata(sprintf('%s/annot/%s_images.txt',datapath,set));
    load(sprintf('%s/annot/%s.mat',datapath,set));
    idxs = strfind(imnames, sprintf('S%d_%s',subject,filename));

    counter = 0;
    for i = 1:numel(imnames)
        if ~isempty(idxs{i})
            counter = counter + 1;

            frame = imnames{i}(end-9:end-4);
            hm = h5read(sprintf('%s/preds/%s_%d.h5',datapath,set,i),'/heatmaps');
            hm = permute(hm,[2,1,3]);
            center = annot.center(i,:);
            scale = annot.scale(i);
            bbox = getHGbbox(center,scale);
            
            heatmap.frames(counter) = str2double(frame);
            heatmap.heatmap(:,:,:,counter) = hm;
            heatmap.bbox(counter,:) = bbox;

        end
    end