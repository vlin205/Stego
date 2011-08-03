clearvars;

x = input('Image to embed message into:\n', 's');
y = input('Enter image format:\n', 's');
z = input('Enter text file that contains message to be embedded:\n', 's');
a = input('Save stego image as:\n', 's');
b = input('Type stego image format:\n', 's');
c = input('Enter stego key (16 < key < 262128):\n');

OriginalImage = imread(x,y);
Imagevalues = double(OriginalImage);

fid = fopen(z);
Input = textscan(fid, '%s', 'whitespace', '');
plainText = char(cellstr(Input{1}));
Namevalues = double(plainText);
%Input = 'Vincent Lin';
%Namevalues = double(Input);%creates array that lists Name as unsigned ints
nsize = size(Namevalues, 2);%length of array Namevalues
index = 1;%initialize Array index for Namebinary

%creates array that lists Name bit by bit
for i = 1:nsize
    for j = 1:8
        Namebinary(index) = bitget(Namevalues(i), 9-j);
        index = index + 1;
    end
end

stegoLength = 16;
length = size(Namebinary, 2);%length of array Namebinary
key = c; %stego key (16 < key < 262128 = 512*512 - 16 = 262144 - 16)
embeddedKey = dec2bin(key, stegoLength);
embeddedKeyArray = uint8(embeddedKey) - uint8('0');

embeddedLength = dec2bin(length, stegoLength);
embeddedLengthArray = uint8(embeddedLength) - uint8('0');
embedLength = key - stegoLength;

pixels = size(Imagevalues, 1) * size(Imagevalues, 2);
embedKey = pixels - stegoLength;

%embed the stego key in the last 16 pixels of the image
for i = 1:stegoLength
    Imagevalues(embedKey) = bitor(bitand(Imagevalues(embedKey), ...
        bitcmp(1, 8)), embeddedKeyArray(i));
    embedKey = embedKey + 1;
end

%embed the length of the cipher in the 16 bits before the cipher starts
for i = 1:stegoLength
    Imagevalues(embedLength) = bitor(bitand(Imagevalues(embedLength), ...
        bitcmp(1, 8)), embeddedLengthArray(i));
    embedLength = embedLength + 1;
end

%keeps the first 7 bits of Imagevalues(i) and replaces the lsb with 0,
%then replaces the lsb (0) with the value in Namebinary(i)
for i = 1:length
    Imagevalues(key) = bitor(bitand(Imagevalues(key), ...
        bitcmp(1, 8)), Namebinary(i));
    key = key + 1;
end

%debugging
%fid = fopen('testEmbed.txt','wt');
%fprintf(fid,'%f\n', Imagevalues);
%fclose(fid);

EmbedImage = uint8(Imagevalues);

imwrite(EmbedImage,a,b);
exit;