function load_songs(folder)
    files = dir(folder);
    num = length(files); 
    library = cell(num - 3, 1); 

    for i = 4:num
        nom = files(i).name; 
        library{i-3} = nom(1:length(nom)); 
    end
    
    newFolder = 'SongsData/';
    for i = 1:num - 3
        songName = strrep(library{i},'.m4a','');
        songName = strrep(songName,'.mp3','');
        songName = strrep(songName,'.mp4','');

        [data, fz] = audioread(strcat(folder,library{i}));
        monoVector = (data(:,1) + data(:,2))./2;
        
        song = struct('Name', songName, 'Frequency', fz, 'Data', monoVector);
        structName = strcat(newFolder,songName,'.mat');
        save(structName, 'song');
        
    end
end
