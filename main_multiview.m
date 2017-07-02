function main_multiview(data)

    startup

    datapath = 'pose-hg-demo/';
    load('h36m_structure.mat')
    
    if strcmp(data,'demo')
        input.datapath = datapath;
        input.subject = 9;
        input.motion = 'Posing_1';
        test_wrapper(input);
    else
        if strcmp(data,'train')
            subject_set = [1,5,6,7,8];
        elseif strcmp(data,'valid')
            subject_set = [9,11];
        end

        % prepare input structs
        c = 0;
        for i = 1:length(subject_set)
            subject = subject_set(i);
            list = {motions{:,subject}};
            for j = 1:length(list) 
                c = c + 1;
                input{c}.datapath = datapath;
                input{c}.subject = subject;
                input{c}.motion = list{j};
            end
        end

        % multi-view pose estimation on each input sequence
        for i = 1:length(input)
            test_wrapper(input{i});
        end
    end

end

function test_wrapper(input)

    % read input variables
    datapath = input.datapath;
    subject = input.subject;
    motion = input.motion;

    savepath = sprintf('result/');
    if ~exist(savepath,'dir')
        mkdir(savepath);
    end

    camName = {'54138969','55011271','58860488','60457274'};
    load('skel_h36m_hg.mat');

    % read heatmaps
    cnn_output = cell(length(camName),1);
    valid = false(length(camName),1);
    for i = 1:length(camName)
        filename = [motion '.' camName{i}];
        try
            cnn_output{i} = loadHeatMap_h36m(datapath,subject,filename);
            valid(i) = true;
        end
    end

    if sum(valid) < 2
        return
    end

    camName = camName(valid);
    cnn_output = cnn_output(valid);

    frames = cnn_output{1}.frames;
    [S_gt,W_gt,camParam] = loadGT_h36m(datapath,subject,motion,camName);

    % the Human3.6M joints are different than the MPII joints
    h36m_2_mpii = [7,6,5,2,3,4,1,9,10,11,17,16,15,12,13,14];
    S_gt = S_gt(:,h36m_2_mpii);
    for camID = 1:length(camParam)
        W_gt{camID} = W_gt{camID}(:,h36m_2_mpii);
    end

    S_hat = [];
    W_hat = cell(length(camParam),1);

    for frameID = 1:length(frames)

        % prepare input
        S0 = sampleShapes(S_gt,frameID);

        boxCenter = (max(S0,[],2)+min(S0,[],2))/2;
        boxSize = max(max(S0,[],2)-min(S0,[],2));

        heatmaps = cell(length(camParam),1);
        bbox2D = cell(length(camParam),1);
        for camID = 1:length(camParam)
            heatmaps{camID} = cnn_output{camID}.heatmap(:,:,:,frameID);
            bbox2D{camID} = cnn_output{camID}.bbox(frameID,:);
        end

        % multiview optimization
        [S,info] = Multiview3DPict(boxCenter,boxSize,camParam,heatmaps,bbox2D,skel,S0);
        S_hat = [S_hat;S];
        distr(frameID) = info;
        distr(frameID).marginal = [];

        % compute per frame errors
        for camID = 1:length(camParam)
            W_hat{camID} =  proj22D(S_hat,camParam{camID});
            E2D{camID} = computeError2D(W_hat{camID},W_gt{camID});
        end
        E3D(frameID,:) = computeError3D(centralize(S0),centralize(S));
        
        fprintf('Frame %d 3D error = %f\n',frameID,mean(E3D(frameID,:)));

    end

    save(sprintf('%s/S%d-%s.mat',savepath,subject,motion),...
        'subject','motion','camName','camParam','frames',...
        'S_gt','W_gt','S_hat','W_hat','distr','skel','E3D','E2D');

end

