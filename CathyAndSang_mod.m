%% EE417 Final Project
% Modulation: jpg -> wav
% Team name: CathyAndSang
% Team members: Yi-Ching Oun, Sang Uk Sagong
clear; close all; clc

%% 1. Read JPEG image file
filename = 'modfinaltest1';
jpgMat = imread([filename '.jpg']);

% convert uint8 to double so we can manipulate the values
jpgMat = im2double(jpgMat);

% check if the input image is rgb. If it is, convert it to grayscale
if (size(jpgMat,3) == 3)    
    jpgMat = rgb2gray(jpgMat);
end

% Find the size of the image so that we can construct a wav file
[Row Col X] = size(jpgMat);

%% 2. Construct APT line matrix
% create different element matrix of APT line
SpaceDataA = ones(Row, 47)+11/255;
SpaceDataB = ones(Row, 47)+11/255;
TeleA = ones(Row, 45)+11/255;
TeleB = ones(Row, 45)+11/255;

% SyncA and SyncB patterns
syncACol = [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
syncBCol = [0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0];

% scale SyncA and SyncB
syncACol = (syncACol*233)+11;
syncBCol = (syncBCol*233)+11;
syncACol = (syncACol)./255;
syncBCol = (syncBCol)./255;

% convert SyncA and SyncB from a vector to a matrix
SyncA = repmat(syncACol, Row, 1);
SyncB = repmat(syncBCol, Row, 1);

% ChannelA is just the image, and ChannelB is the mirror image of ChannelA
ChannelA = jpgMat;
ChannelB = fliplr(jpgMat);

% construct APT line matrix
APT_line = [SyncA SpaceDataA ChannelA TeleA SyncB SpaceDataB ChannelB TeleB];

% convert APT_line from 2080 words to 8320 samples by duplicating each
% element in the matrix 4 times.
APT_lineNew = ones(Row, 2080*4);
for i = 1:2080
    APT_lineNew(:,4*i-3) = APT_line(:,i);
    APT_lineNew(:,4*i-2) = APT_line(:,i);
    APT_lineNew(:,4*i-1) = APT_line(:,i);
    APT_lineNew(:,4*i) = APT_line(:,i);
end

%% 3. Apply carrier frequency
% Carrier frequency = 2.4 kHz
carrierFreq = 2400;
t_range = 0:1/16000:(8000*Row-1)/16000;
cosTerm = cos(2*pi*carrierFreq*t_range);

% Resample to 8000 sample per 0.5 second (16000 Hz)
frmMatRes = zeros(Row,8000);
for itr=1:Row
    frmMatRes(itr,:) = resample(APT_lineNew(itr,:), 8000, 8320);
end

% Reshape the matrix into a vector then apply carrier frequency
frmMatVec = reshape(transpose(frmMatRes), 1, 8000*Row);
output = frmMatVec .* cosTerm;


%% 4. Generate WAV file
nBit = 16;
outputname = ['CathyAndSang-' filename '.wav'];
wavwrite(output, 16000, nBit, outputname);


