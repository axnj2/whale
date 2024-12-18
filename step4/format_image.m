function image = format_image(raw_image)
    raw_image = rgb2gray(raw_image);
    
    % resize the image to a max dimension of 64 pixels
    max_dimension = 64;
    [rows, cols] = size(raw_image);
    if rows > cols
        raw_image = imresize(raw_image, [max_dimension NaN]);
    else
        raw_image = imresize(raw_image, [NaN max_dimension]);
    end

    % convert to image to 1 bit grayscale
    image = raw_image > 128;
end