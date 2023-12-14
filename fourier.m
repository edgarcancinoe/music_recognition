function X = fourier(song, intervalos, maxfreq)
        
        % Number of data points in 1 second
        oneSecond = song.Frequency;

        % Number of data points in each segment
        nPoints = oneSecond*intervalos;

        % Retrieve song audio data
        audioData = song.Data;
        dataLength = length(audioData);

        % We want to divide the song data in the necessary number of
        % fragments so that we can ensure information can be evaluated 
        % every n seconds and that each fragment will have the same number
        % of points m, so we add trailing zeros.

        difference = nPoints - mod(dataLength, nPoints);
        dataLength = dataLength + difference;
        aux = zeros(1, difference);

        audioData = [audioData' aux];
        
        % Analyze song 

        % Matrix to store frequencies and magnitudes for each song fragment
        X = zeros(dataLength/nPoints, maxfreq);

        cont = 1;
        for t = nPoints:nPoints:dataLength
            % Compute FFT for audio sample and keep magnitude only.
            fourierData = audioData(t-nPoints+1 : t);
            FDT = abs(fft(fourierData));  

            % Keep first half only (duplicated data)
            FDT = FDT(1:ceil(length(FDT)/2));
 
            % Cap frequencies, as to discard unrelevant frequencies
            
            FDT = FDT(1:maxfreq);

            % Matrix: de (t x f) x k
            % t is time chunk
            % f are frequencies
            % k is magnitude

            X(cont,:) = FDT;
            cont = cont + 1;        
        end
end