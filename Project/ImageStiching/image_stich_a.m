function [ims] = image_stich_a(images)
    I3 = zeros(3);
    for i = 1:3
        I3(i, i) = 1;
    end
    
    for i = 1:length(images)
        trans_matrices(i) = maketform('projective', I3);
    end
    
    for i = 2:length(images)
        T = getTForm(images{i}, images{i-1});
        trans_matrices(i).tdata.T = trans_matrices(i-1).tdata.T * T.T;
    end
    
    XPos = zeros(length(images), 2);

    for i = 1:length(images) 
        tempT = trans_matrices(i);
        [~,xcoord,ycoord] = imtransform(images{i}, tempT);
        XPos(i, :) = xcoord;   
    end
    
    [~, index] = sort(mean(XPos, 2));
    center = floor((length(trans_matrices)+1)/2);

    center_idx = index(center);

%     for i = 1:length(images)    
%         trans_matrices(i).tdata.T = inv(trans_matrices(center_idx).tdata.T) * trans_matrices(i).tdata.T;
%     end
    
%     Tinv = inv(trans_matrices(center_idx).tdata.T);

    for i = 1:numel(trans_matrices)    
        trans_matrices(i).tdata.T = inv(trans_matrices(center_idx).tdata.T) * trans_matrices(i).tdata.T;
    end
    
    xMin = 1;
    yMin = 1;
    
    yMax = 1;
    xMax = 1;

    for i = 1:length(images) 
        [~,xcoord,ycoord] = imtransform(images{i},trans_matrices(i));
        xMin = min([xMin, xcoord(1)]);
        yMin = min([yMin, ycoord(1)]);
        xMax = max([xMax, xcoord(2)]);
        yMax = max([yMax, ycoord(2)]);
    end
    
%     panX  = round(xMax - xMin);
%     panY = round(yMax - yMin);

    %% Step 4 - Create the Panorama
    % Use |imwarp| to map images into the panorama and use
    % |vision.AlphaBlender| to overlay the images together.
    
    %panorama = zeros([panX panY 3], 'like', images{1});
    panorama = zeros([round(yMax - yMin) round(xMax - xMin) 3], 'like', images{1});

    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');  

    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    [p_rows, p_cols, ~] = size(panorama);
    panoramaView = imref2d([p_rows p_cols], xLimits, yLimits);

    % Create the panorama.
    for i = 1:length(images)

        I = images{i};
        
        curr_projection = projective2d(I3);
        curr_projection.T = trans_matrices(i).tdata.T;

        % Transform I into the panorama.
        warpedImage = imwarp(I, curr_projection, 'OutputView', panoramaView);

        % Overlay the warpedImage onto the panorama.
        panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
    end

    figure
    imshow(panorama)
    
    
end