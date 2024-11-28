function image = decode_image_from_uint8(bytes_of_image)
    % max image size : 255x255
    % convert the the image to a chain of bytes
    % for each byte, the LSB is the first pixel
    % image dimensions are incoded in the first 2 bytes encoded, (height, width)
    height = bytes_of_image(1);
    width = bytes_of_image(2);

    line_image = zeros(1, height*width);
    for i = 1:(length(bytes_of_image)-2)
        for k = 0:7
            line_image( ((i-1)*8+1) +k) = bitget(bytes_of_image(i+2), k+1, 'uint8');
        end
    end
    image = reshape(line_image, height, width);
end