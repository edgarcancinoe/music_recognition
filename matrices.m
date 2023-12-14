function matrices(directory, interval_duration, maxfreq)
    list = dir(directory);
    num = length(list); 
    library = cell(num-3,1);
    
    for i = 4:num
        nom = list(i).name; 
        library{i-3} = nom(1:length(nom)); 
    end 
    
    for i = 1:num-3
        % The song variable corresponds to the struct containing the name, 
        % frequency and song data.
        song = load(strcat('SongsData/', library{i}));
        song = song.song;

        % The fourier function returns the FFT data as specified before:
        %{
            Here we compute the fourier transform along the songs data in subsets
            of a certain duration and the information is stored in a
            matrix where each column corresponds to a ceratin frequency, every row
            corresponds to to the i^{th} fragment and the value is the FFT
            magnitude for that frequency in that moment, i.e., a value for the
            importance of that frequency in that specific moment of the song.
        %}
        
        X = fourier(song, interval_duration, maxfreq);
        % The fourier data is added to the struct and saved in the file.
        song.Matrix = X;   
        song.interval_duration = interval_duration;
        save(strcat('SongsData/', library{i}), 'song');
    end

    fprintf("\n The Fast Fourier Transform has been computed, along the time-frequency matrix for each song.\n");
end