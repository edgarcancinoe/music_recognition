%{ 
    __ Load data __

    Load '/songs' directory to analyze files and get relevant information out of
    them.

    (Needs to be run only if new songs added or songs have not been processed)

%}
    clc, clear, close all
    directory = 'Songs/'; 
    load_songs(directory); 

%%
%{
    __ Fourier matrices __
    
    Lada must have been already loaded into the '/SongsData' directory,
    containing the songs name, sampling frequency and audio data.

    Here we compute the fourier transform along the songs data in subsets
    of a certain duration t seconds and the inforomation is stored in a
    matrix where each column corresponds to a ceratin frequency, every row
    corresponds to to the i^{th} fragment and the value is the FFT
    magnitude for that frequence in that moment, i.e., a value for the
    importance of that frequency in that specific moment of the song.

%}
    clc, clear, close all
    directory = 'SongsData/';

    % Audio data fragments duration

    interval_duration = 0.1;  

    maxfreq = 700;   % Maximum relevant frequency

    matrices(directory, interval_duration, maxfreq);

%%
clc, clear, close all

%{
    Visualization

    Visualization of the matrix containing the fourier analysis: 
    time x frequencies x magnitude

%}
    clc, clear, close all
    cancion = 'Rocket Man.mat';       % Elegir la canción a desplegar
    
    song = load(strcat('SongsData/',cancion));
    S = song.song;
    
    X = S.Matrix;
    freq = S.Frequency;
    interval = S.interval_duration;
    
    [m, n] = size(X);
    [XX, YY] = meshgrid([0:m-1], [0:n-1]);

    s = mesh(XX,YY,X','FaceAlpha','1');
    s.FaceColor = 'flat';
    title(S.Name);

    xlabel('Time');
    ylabel('Frequency');
    zlabel('Magnitude');

    % Scale YY axis values to get second values in axis
    xticklabels(get(gca, 'XTick') * interval);
    ylabel('Time (s)');

    %%
    clc, clear, close all
%{
    Song temporal frequency analysis
    
    For each song in the library we create Hash Vector storing the information
    of the most important frequencies for each analyzed time fragment.
    
    Methodology: Search frequency with the highest magnitude in 4 different
    ranges for each song fragment:

        40 <= f <= 80; 
        80 <= f <= 120; 
        160 <= f <= 200; 
        160 <= f <= 200
%}
    
    directory = 'SongsData/';
    lista = dir(directory);
    num = length(lista);

    % Array to store names
    biblioteca = cell(num-3,1); 
    for i = 4:num
        nom = lista(i).name; 
        biblioteca{i-3} = nom(1:length(nom)); 
    end
    
    for i=1:num-3
        song = load(strcat('SongsData/', biblioteca{i}));
        song = song.song;
        X = song.Matrix;        
        
        [m, n] = size(X);  % m es song segment and n is frequency
        hashV = zeros(1, m); % Allocate memory
        
        for t = 1:m
            maxFreq = []; % Vector to store the most important frequency for each range (according to its magnitude)
            for j=40:40:160
                range = X(t,j:j+39);
                maxMagnitude = max(range);
                maxFreq = [maxFreq find(range==maxMagnitude)];
            end
            hashV(t) = hash(maxFreq);  % Hash function to get i^th segments key 
        end
        % Add hash vector to struct
        song.HashVector = hashV;
        save(strcat('SongsData/', biblioteca{i}), 'song');
    end

%%
%   Random sample from audio file
    clc, clear, close all
    [sample, fz] = audioread("Songs/Underwater.mp3");
    sampleMono = (sample(:,1) + sample(:,2))./2;

    n = randi(20);
    seg = 4;

    % Extract random segment of duration 'seg'
    start_sample = round(n * fz) + 1;
    end_sample = round((n + seg) * fz);

    sampleMono = sampleMono(start_sample:end_sample);

    audioSample = sampleMono;
    oneSecond = fz;

%%

%   Song identification using microphone input
%   Input device's id can be searche din the Matlab console using 'audiodevinfo'
    
clc
    oneSecond=44100; % Sample from microphone
    %oneSecond=fz;  % Sample from file
    
    bits = 24;
    channels = 1;
    id = 1;
    audio = audiorecorder(oneSecond, bits, channels, id);
    audiolength = 10; % (Seconds)
    fprintf('Recording audio sample (%ds)...\n', audiolength);
    recordblocking(audio, audiolength);
    sample = getaudiodata(audio);

    %audioSample = (sample(:,1) + sample(:,2))./2; % If two channels
    audioSample = sample;


%{
   An analysis similar to the one done in the learning phase, is carried
    out on the input sample.
    
    1. Compute FFT for each segment t.
    2. Extract most important frequencies for each segment in the ranges of
    interest.
    3. Get hash vector containing time and frequency information of the
    sample.
%}

    % Learning and sampling interval durations must be equal
    intervalo = 0.1;
    maxfreq = 700;
    s = struct('Data', audioSample, 'Frequency', oneSecond);
    
    X = fourier(s, intervalo, maxfreq);     
                                            
    % Compute Hash Vector
    [m,n] = size(X);
    hashVector = zeros(1,m-1);
    for t = 1:m-1
        maxFreq = []; % Array to store most important frequency of ranges
        for j=40:40:160
          range = X(t,j:j+39);
          maxMagnitude = max(range);
          maxFreq = [maxFreq find(range==maxMagnitude)];
        end
        hashVector(t) = hash(maxFreq);      % Get hash value for time (interval) t
    end   

    lista = dir('SongsData/');
    num = length(lista); 
    biblioteca = cell(num-3,1);
    for i = 4:num
        nom = lista(i).name; 
        biblioteca{i-3} = nom(1:length(nom)); 
    end
    var = num-3;
    ratios = zeros(1,var);
    sampleHash = hashVector;
    for i = 1:var
        song = load(strcat('SongsData/',biblioteca{i}));
        song = song.song;
        song = song.HashVector;
        temp = [];
        l = length(sampleHash);
        matches = [];
        for j=1:l
            matches = [matches find(song==sampleHash(j)) - j];
        end
        m = mode(matches);
        nmatches = sum(matches(:) == m);
        ratios(i) = nmatches/length(sampleHash);
        fprintf("Song: %s  Matches: %i\n", biblioteca{i},nmatches);
    end
   
 [maximum, index] = max(ratios);
 fprintf("\nThe closest match is %s with ratio of match %f\n", biblioteca{index}, round(maximum,2));

%%
function h = hash(v)
    h = 3;
    for k=1:length(v)
        h = h*17*v(k);
    end
    h = round(h/100000);
end