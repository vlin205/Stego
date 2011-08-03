clearvars;

x = input('Enter stego image:\n', 's');
y = input('Enter stego image format:\n', 's');
z = input('Enter file to write retrieved text to:\n', 's');

EncryptedImage = imread(x,y);
ImageValues = double(EncryptedImage);

stegoLength = 16;
pixels = size(ImageValues, 1) * size(ImageValues, 2);
decKey = pixels - stegoLength;
stegoKeyBinString = '';

%creates a string containing the 16-bit representation of the stego key
%from the last 16 bits of the image
for i = 1:stegoLength
    tmp = bitget(ImageValues(decKey), 1);%get lsb
    stegoKeyBinString = strcat(stegoKeyBinString, int2str(tmp));
    decKey = decKey + 1;
end

stegoKey = bin2dec(stegoKeyBinString);
lengthEmbedBinString = '';
decLength = stegoKey - stegoLength;

%creates a string containing the 16-bit representation of the length
%of the embedded cipher
for i = 1:stegoLength
    tmp2 = bitget(ImageValues(decLength), 1);
    lengthEmbedBinString = strcat(lengthEmbedBinString, int2str(tmp2));
    decLength = decLength + 1;
end

cipherLength = bin2dec(lengthEmbedBinString);
cipherEnd = stegoKey + cipherLength;
cipherBinString = '';

%creates a string containing all of the cipher as a binary string
for i = stegoKey:cipherEnd
    tmp3 = bitget(ImageValues(i), 1);
    cipherBinString = strcat(cipherBinString, int2str(tmp3));
end

tmpVal = '';
cipherChars = cipherLength/8;

%parses 8 bits of the cipher string at a time and converts that to its
%ASCII representation to generate the retrieved message
for index = 1:cipherChars
    for j = 1:8
        index2 = 8 * (index - 1) + j;
        tmpVal = strcat(tmpVal, cipherBinString(index2));
    end
    cipher(index) = char(bin2dec(tmpVal));
    tmpVal = '';
end

fid = fopen(z, 'wt');
fprintf(fid, '%s', cipher);
fclose(fid);

exit;