%% EE417 Final Project
% AWGN: add noise at receiver
% Team name: CathyAndSang
% Team members: Yi-Ching Oun, Sang Uk Sagong
clear; close all; clc

%% Impairment Generator
teamname = 'CathyAndSang-';
filename = 'finaltest1';
inputWav = wavread([filename '.wav']);

% use rms() to find the input signal power
sigPower = rms(inputWav);

% generate AWGN noise
N = length(inputWav);
AWGN_plus10 = sqrt((sigPower/10))*randn(N,1);
AWGN_plus2 = sqrt(sigPower*(10^(-1/5)))*randn(N,1); % more noisy
AWGN_minus10 = sqrt(sigPower*10)*randn(N,1);

% Construct new noisy signals by adding AWGN with the input wav file
NewSignalp10 = inputWav + AWGN_plus10;
NewSignalp2 = inputWav + AWGN_plus2;
NewSignalm10 = inputWav + AWGN_minus10;

Fs = 16000;
wavwrite(NewSignalm10, Fs, [teamname 'impairM10dB.wav']);
wavwrite(NewSignalp2, Fs, [teamname 'impairP2dB.wav']);
wavwrite(NewSignalp10, Fs, [teamname 'impairP10dB.wav']);

