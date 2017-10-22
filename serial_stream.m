%% EGH449 Serial Stream
% Used to stream a section of imported audio.
% Converts to int8 and sends and receives one byte at a time from the
% serial connection.

% Make sure to use the right COM port and that the audio is in the right
% folder path.
my_com_port = 'COM10';
my_audio_file_path = 'audio/Vivaldi_test.wav';

%% Connect teh serial port thing

% Close the com ports incase they are wierdly open for some reason. (Matlab amirite?)
% if ~isempty(instrfind)
%     fclose(instrfind);
%     delete(instrfind);
% end

% Create and open the serial link
s = serial(my_com_port,'BaudRate',115200);
fopen(s);

%% Open the audio (or whatever data)
[audio, fs] = audioread(my_audio_file_path);

% Convert to 8 bit audio
audio = int8(floor(audio*127 + 0.5));

% Use to only send a sample of the data
start = 440000;
n = 100;
finish = start + n - 1;
in = audio(start:finish , 1); % Selects only the 1 channel too.

%% Send and recieve the data
% Preallocate for speeeeeeed
out = zeros(size(in), 'int8');
count = 0; % Just used for printing pretty dots to your screen
for i = 1:size(in,1)
    for channel = 1:size(in,2)
        % Write the 8 bits to UART
        sample = in(i,channel);
        fwrite(s, sample, 'int8');
        % Read 8 bits from the UART
        out(i,channel) = fread(s,1,'int8');
        
        % Just display something to the cmd window while working so it 
        % looks good
        fprintf(1,'.');
        if count >= 49
            fprintf(1,'\n')
        end
        count = mod(count+1, 50);
    end
end

%% Plot the input and output
figure();
plot(in);
hold on;
plot(out,'--');
legend('in','out')

%% Close the serial link down so other things can use it
fclose(s);
delete(s);
clear s
