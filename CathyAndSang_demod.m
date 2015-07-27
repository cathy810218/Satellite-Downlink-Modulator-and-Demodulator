% EE417 Final Project
% Demodulation: wav -> jpg
% Team name: CathyAndSang
% Team members: Yi-Ching Oun, Sang Uk Sagong
clear; close all; clc

%% 1. Read wav file
filename = 'finaltest2';
wavMat = wavread([filename '.wav']);

%% 2. Rescale input wav file
WordsPerAPT = 2080;
CarrierFreq = 2400;

% Hilbert transform in order to take phase into account.
wavHilb = hilbert(wavMat);
phase = angle(wavHilb);

% apply carrier freq
cosTerm = cos(phase);
wavMatCarr = wavMat .* cosTerm;

% First, resample wav file with carrier freq from 8000 to 2080
wavMatRes = resample(wavMatCarr, 2080, 8000);
lengthWavRes = length(wavMatRes);

% minimum value after rescaled = 11/255
% maximum value after rescaled = 244/255
minRescaled = 11/255;
maxRescaled = 244/255;
minInitial = min(wavMatRes);
maxInitial = max(wavMatRes);

% Rescale equation
wavMatRes = ((maxRescaled-minRescaled)/(maxInitial-minInitial)).*(wavMatRes-minInitial)+minRescaled;

% Possible number of rows
remain = mod(lengthWavRes,2080);
numRow = (lengthWavRes-remain)/2080 - 1;


%% 3. Check the correlation values for syncA
% SyncA Pattern
SyncPattern = [0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

% Compute the correlation value for first 2080 samples of wavMatRes in
% order to find the correlation values
correlation = zeros(1, 2080);

for itr_Cor = 1:2080
    correlation(itr_Cor) = corr(wavMatRes(itr_Cor:itr_Cor+38), SyncPattern');
end

% Take the index whose correlation value is greater than 99% of maximum 
% correlation.
% Give 1% margin when selecting the index of highest correlation value
indexSync(1) = find(correlation > max(correlation)*0.99);

% finding the index that is the starting point of sync A
for itr = 1:numRow
    if itr==1
        itrIndex = indexSync(1);
    else
        itrIndex = 2080+indexSync(itr-1);
    end
    
    % if the index is exceeding the length of resampled wav file, break!
    if (itrIndex+38+2080 > lengthWavRes)
        break;
    end
    
    % Find syncA by computing the correlation values for current and next 
    % 2080 samples
    corrValCurrent = corr(wavMatRes(itrIndex:itrIndex+38), SyncPattern');
    corrValNext = corr(wavMatRes(itrIndex+2080:itrIndex+38+2080), SyncPattern');

    % if the current and next correlation values are same, then we find the
    % syncA pattern. Store the index value. In order to find the simliarity
    % of current syncA and next syncA, we give 1% margin.
    if ((corrValCurrent > max(correlation)*0.99) && (corrValNext > max(correlation)*0.99))
        indexSync(itr) = itrIndex;
    
    % if we cannot find the next syncA, we have missing data.
    % so we keep finding the next syncA.
    else
        for itr_Corr = 1:2080
            correlation(itr_Corr) = corr(wavMatRes(itrIndex+2079+itr_Corr:itrIndex+2079+itr_Corr+38), SyncPattern');
        end
        tempIndex = find(correlation > max(correlation)*0.99)+itrIndex+2079;
        indexSync(itr) = tempIndex(1);
        itrIndex = tempIndex(1);
    end
end

% Generate a vector 'wavMatSync' which contains only synchronized data
lengthIndex = length(indexSync);
wavMatSync = [];
for itr_Sync = 1:(lengthIndex-1)
    wavMatSync = [wavMatSync wavMatRes(indexSync(itr_Sync):indexSync(itr_Sync)+2079)'];
end

% Convert the wavMatSync vector to a matrix
wavMat2D = vec2mat(wavMatSync,2080);
[Row Col X] = size(wavMat2D);


%% 4. Extracting image part 
% The matrices that contains the image data
channelA = zeros(Row, 909);
channelB = zeros(Row, 909);

i = 1; 
j = 1;
% From the APT line, we know that the channel A is in between 87~995 and
% channel B is in between 1127~2035
for itr=1:WordsPerAPT
    if (itr>86 && itr<996)
        channelA(:,i) = wavMat2D(:,itr);
        i=i+1;
    end
    
    if (itr > 1126 && itr < 2036)
        channelB(:,j) = wavMat2D(:,itr);
        j = j + 1;
    end
end

% construct the image by concatenating chanelA and channelB
jpgMatFinal = [channelA channelB];

%% 5. Generate the output jpg
outputname = ['CathyAndSang-' filename '.jpg'];
imwrite((jpgMatFinal),outputname);
temp = imread(outputname);
figure
imshow(temp)