function [ims] = image_stich(left_orig, right_orig)
    T = getTForm(left_orig, right_orig);
    
    % [new_im, x, y] = imtransform(left_orig, T);
    % 
    % x_size = [min(1, x(1)), max(right_orig, 2), x(2))];
    % y_size = [min(1, y(1)), max(right_orig, 1), y(2))];

    % im1 = imtransorm(

    % figure()
    % subplot(121);
    % imagesc(left_orig); hold on; axis image; axis off;
    % subplot(122);
    % imagesc(new_im); hold on; axis image; axis off;


    [~,xcoord,ycoord] = imtransform(right_orig,T);

    ycombo(1, 1) = min(1,ycoord(1));
    ycombo(1, 2) = max(size(left_orig,1),ycoord(2));

    I3 = zeros(3);
    for i = 1:3
        I3(i, i) = 1;
    end

    xcombo(1, 1) = min(1,xcoord(1));
    xcombo(1, 2) = max(size(left_orig,2),xcoord(2));

    im2t = imtransform(right_orig,T,'XData',xcombo,'YData',ycombo);
    im1t = imtransform(left_orig,maketform('affine',I3),'XData',xcombo,'YData',ycombo);

    ims=max(im1t,im2t);
end