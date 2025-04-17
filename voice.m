function voice_gender_recognition_app
    fig = uifigure('Name', 'Voice Gender Recognition', 'Position', [100, 100, 1200, 600]);
    
    % File Selection UI
    uilabel(fig, 'Text', 'File Name:', 'Position', [10, 550, 60, 20]);
    filePathEdit = uieditfield(fig, 'text', 'Position', [80, 550, 500, 22]);
    selectFileBtn = uibutton(fig, 'push', 'Text', 'Select File', 'Position', [600, 550, 100, 22], 'ButtonPushedFcn', @(btn, event) selectFile());
    
    % Play and Stop Buttons
    playBtn = uibutton(fig, 'push', 'Text', 'Play', 'Position', [80, 520, 60, 22], 'ButtonPushedFcn', @(btn, event) playAudio());
    stopBtn = uibutton(fig, 'push', 'Text', 'Stop', 'Position', [150, 520, 60, 22], 'ButtonPushedFcn', @(btn, event) stopAudio(), 'BackgroundColor', 'r');
    
    % Analyze Button
    analyzeBtn = uibutton(fig, 'push', 'Text', 'Analyze Audio', 'Position', [80, 490, 120, 22], 'ButtonPushedFcn', @(btn, event) analyzeAudio());
    
    % Frequency & Gender Output
    uilabel(fig, 'Text', 'Average Pitch (Hz):', 'Position', [750, 550, 100, 20]);
    freqEdit = uieditfield(fig, 'numeric', 'Position', [850, 550, 100, 22], 'Editable', 'off');
    
    uilabel(fig, 'Text', 'Gender:', 'Position', [750, 520, 100, 20]);
    genderEdit = uieditfield(fig, 'text', 'Position', [850, 520, 150, 22], 'Editable', 'off');
    
    % Additional Features Display
    uilabel(fig, 'Text', 'Formant 1 (Hz):', 'Position', [750, 490, 100, 20]);
    formant1Edit = uieditfield(fig, 'numeric', 'Position', [850, 490, 100, 22], 'Editable', 'off');
    
    uilabel(fig, 'Text', 'Formant 2 (Hz):', 'Position', [750, 460, 100, 20]);
    formant2Edit = uieditfield(fig, 'numeric', 'Position', [850, 460, 100, 22], 'Editable', 'off');
    
    recordBtn = uibutton(fig, 'push', 'Text', 'Record & Recognize', 'Position', [850, 430, 150, 22], 'ButtonPushedFcn', @(btn, event) recordAudio());
    playRecordBtn = uibutton(fig, 'push', 'Text', 'Play Recording', 'Position', [1020, 430, 150, 22], 'ButtonPushedFcn', @(btn, event) playRecording());
    
    % Axes for plots
    axWaveform = uiaxes(fig, 'Position', [50, 250, 400, 200]);
    title(axWaveform, 'Waveform'); xlabel(axWaveform, 'Time (s)'); ylabel(axWaveform, 'Amplitude');
    
    axFFT = uiaxes(fig, 'Position', [500, 250, 400, 200]);
    title(axFFT, 'FFT Spectrum'); xlabel(axFFT, 'Frequency (Hz)'); ylabel(axFFT, 'Magnitude');
    
    axSpectrogram = uiaxes(fig, 'Position', [50, 50, 400, 200]);
    title(axSpectrogram, 'Spectrogram'); xlabel(axSpectrogram, 'Time (s)'); ylabel(axSpectrogram, 'Frequency (Hz)');
    
    axPitch = uiaxes(fig, 'Position', [500, 50, 400, 200]);
    title(axPitch, 'Pitch Contour'); xlabel(axPitch, 'Time (s)'); ylabel(axPitch, 'Pitch (Hz)');
    
    % Variables for recording
    recorder = [];
    recordedAudio = [];
    Fs = 44100;
    
    function selectFile()
        [file, path] = uigetfile('*.wav');
        if file
            filePathEdit.Value = fullfile(path, file);
        end
    end
    
    function playAudio()
        if ~isempty(filePathEdit.Value)
            [y, Fs] = audioread(filePathEdit.Value);
            sound(y, Fs);
        end
    end
    
    function stopAudio()
        clear sound;
    end
    
    function analyzeAudio()
        if isempty(filePathEdit.Value)
            return;
        end
        
        try
            [y, Fs] = audioread(filePathEdit.Value);
            t = (0:length(y)-1)/Fs;
            
            % Plot waveform
            plot(axWaveform, t, y, 'b');
            xlabel(axWaveform, 'Time (s)'); ylabel(axWaveform, 'Amplitude');
            
            % Plot FFT
            Y = abs(fft(y));
            f = (0:length(Y)-1) * Fs / length(Y);
            plot(axFFT, f(1:floor(end/2)), Y(1:floor(end/2)), 'b'); 
            xlim(axFFT, [0, 5000]);
            xlabel(axFFT, 'Frequency (Hz)'); ylabel(axFFT, 'Magnitude');
            
            % Plot spectrogram
            [S, F, T, P] = spectrogram(y, 256, 250, 256, Fs, 'yaxis');
            imagesc(axSpectrogram, T, F, 10*log10(abs(P))); 
            axis(axSpectrogram, 'xy'); 
            colormap(axSpectrogram, 'jet');
            ylim(axSpectrogram, [0, 8000]);
            xlabel(axSpectrogram, 'Time (s)'); ylabel(axSpectrogram, 'Frequency (Hz)');
            
            % Estimate pitch and plot
            pitchValues = estimatePitch(y, Fs);
            timeAxis = linspace(0, length(y)/Fs, length(pitchValues));
            plot(axPitch, timeAxis, pitchValues, 'r', 'LineWidth', 1.5);
            ylim(axPitch, [50, 400]);
            xlabel(axPitch, 'Time (s)'); ylabel(axPitch, 'Pitch (Hz)');
            
            % Calculate voice features
            validPitches = pitchValues(~isnan(pitchValues));
            if ~isempty(validPitches)
                avgPitch = mean(validPitches);
                freqEdit.Value = avgPitch;
                
                % Calculate formants (additional gender features)
                [formant1, formant2] = estimateFormants(y, Fs);
                formant1Edit.Value = formant1;
                formant2Edit.Value = formant2;
                
                % Improved gender classification
                gender = classifyGender(avgPitch, formant1, formant2);
                genderEdit.Value = gender;
            else
                freqEdit.Value = 0;
                formant1Edit.Value = 0;
                formant2Edit.Value = 0;
                genderEdit.Value = 'Unknown';
            end
            
        catch ME
            errordlg(['Error analyzing audio: ' ME.message], 'Analysis Error');
        end
    end
    
    function pitchValues = estimatePitch(y, Fs)
        frameDuration = 0.03;
        frameLength = round(frameDuration * Fs);
        
        % Use cepstral pitch detection which is more robust
        pitchValues = zeros(floor(length(y)/frameLength), 1);
        
        for i = 1:length(pitchValues)
            frame = y((i-1)*frameLength+1 : min(i*frameLength, length(y)));
            
            % Simple cepstral pitch detection
            cepstrum = ifft(log(abs(fft(frame)).^2));
            cepstrum = cepstrum(1:floor(length(cepstrum)/2));
            
            [~, maxIdx] = max(cepstrum(20:end)); % Skip very short periods
            maxIdx = maxIdx + 19;
            
            if ~isempty(maxIdx) && maxIdx > 0
                pitchValues(i) = Fs/maxIdx;
            else
                pitchValues(i) = NaN;
            end
        end
    end
    
    function [formant1, formant2] = estimateFormants(y, Fs)
        % Simple formant estimation using LPC
        frameLength = round(0.03 * Fs);
        frame = y(1:min(frameLength, length(y)));
        
        % Pre-emphasis
        preemph = [1 -0.97];
        frame = filter(preemph, 1, frame);
        
        % LPC analysis
        order = 12; % Typical for formant estimation
        a = lpc(frame, order);
        
        % Find formants (roots of the polynomial)
        r = roots(a);
        r = r(imag(r) > 0); % Keep only complex roots
        [~, idx] = sort(angle(r)); % Sort by angle (frequency)
        r = r(idx);
        
        % Convert to Hz
        formants = angle(r) * (Fs/(2*pi));
        
        if length(formants) >= 2
            formant1 = formants(1);
            formant2 = formants(2);
        else
            formant1 = 0;
            formant2 = 0;
        end
    end
    
    function gender = classifyGender(avgPitch, formant1, formant2)
        % Improved gender classification using multiple features
        
        % Typical male ranges
        malePitchRange = [80, 810];
        maleFormant1Range = [400, 900];
        
        % Typical female ranges
        femalePitchRange = [150, 300];
        femaleFormant1Range = [400, 1200];
        
        % Score based on features
        maleScore = 0;
        femaleScore = 0;
        
        % Pitch scoring
        if avgPitch >= malePitchRange(1) && avgPitch <= malePitchRange(2)
            maleScore = maleScore + 1;
        end
        if avgPitch >= femalePitchRange(1) && avgPitch <= femalePitchRange(2)
            femaleScore = femaleScore + 1;
        end
        
        % Formant 1 scoring
        if formant1 >= maleFormant1Range(1) && formant1 <= maleFormant1Range(2)
            maleScore = maleScore + 1;
        end
        if formant1 >= femaleFormant1Range(1) && formant1 <= femaleFormant1Range(2)
            femaleScore = femaleScore + 1;
        end
        
        % Decision
        if maleScore > femaleScore
            gender = 'Male';
        elseif femaleScore > maleScore
            gender = 'Female';
        else
            % If scores are equal, use pitch as tie-breaker
            if avgPitch < 165
                gender = 'Male';
            else
                gender = 'Female';
            end
        end
    end
    
    function recordAudio()
        % Stop any existing recording
        if ~isempty(recorder)
            stop(recorder);
            delete(recorder);
        end
        
        % Create new recorder
        recorder = audiorecorder(Fs, 16, 1);
        record(recorder);
        uialert(fig, 'Recording started click OK .', 'Recording', 'Icon', 'info', 'CloseFcn', @(h, e) stopRecording());
    end
    
    function stopRecording()
        if ~isempty(recorder) && isrecording(recorder)
            stop(recorder);
            recordedAudio = getaudiodata(recorder);
            
            % Save to temporary file for analysis
            filePathEdit.Value = 'recording.wav';
            audiowrite('recording.wav', recordedAudio, Fs);
            
            % Analyze the recording
            analyzeAudio();
        end
    end
    
    function playRecording()
        if ~isempty(recordedAudio)
            sound(recordedAudio, Fs);
        end
    end
end