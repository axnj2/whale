function bytes_of_image = encode_image_to_uint8(image)
    % max image size : 255x255
    % convert the the image to a chain of bytes
    % for each byte, the LSB is the first pixel
    % image dimensions are incoded in the first 2 bytes encoded, (height, width)
    line_image = reshape(image, 1, []);
    bytes_of_image = uint8(zeros(1, length(line_image)/8));
    for i = 1:(length(line_image)/8)
        for k = 0:7
            bytes_of_image(i) = uint8(bytes_of_image(i) + line_image( ((i-1)*8+1) +k)*2^k);
        end
    end

    % add the dimensions of the image in the first 2 bytes
    bytes_of_image = [uint8(size(image, 1)), uint8(size(image, 2)), bytes_of_image];
end