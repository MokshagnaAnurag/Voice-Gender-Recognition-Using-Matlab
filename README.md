# Voice Gender Recognition MATLAB

A MATLAB-based graphical user interface (GUI) that enables users to upload, analyze, and classify the gender of a speaker from a voice recording. The app visualizes various acoustic features including waveform, pitch, spectrogram, formants, and frequency spectrum to enhance understanding and interpretability.

## Features

- 🎵 **Audio Playback & Recording**: Load `.wav` files, play/stop audio, or record your own voice.
- 📈 **Waveform Visualization**: Time-domain display of the audio signal.
- ⚡ **FFT Spectrum Analysis**: Frequency-domain visualization using Fast Fourier Transform.
- 🌈 **Spectrogram Display**: Time-frequency representation of the voice.
- 🔁 **Pitch Estimation**: Extract pitch contour over time using cepstral analysis.
- 🔍 **Formant Estimation**: Identify Formant 1 & 2 using Linear Predictive Coding (LPC).
- 🧠 **Gender Classification**: Classify as 'Male' or 'Female' based on pitch and formants.

## GUI Overview

| Component              | Description                                         |
|------------------------|-----------------------------------------------------|
| **Select File**        | Load a `.wav` audio file from your system.         |
| **Play/Stop Buttons**  | Listen to the audio or stop playback.              |
| **Record & Recognize** | Record your voice and classify gender instantly.   |
| **Analyze Audio**      | Extract features and visualize the plots.          |
| **Results Panel**      | Displays average pitch, formant values, and gender.|

## Installation

1. Clone this repository or download the `.m` file.
2. Open the file `voice_gender_recognition_app.m` in MATLAB.
3. Run the script.

> ⚠️ **Dependencies**: Make sure you have the Audio Toolbox and Signal Processing Toolbox installed.

## Usage

1. Click **Select File** to load a `.wav` file or **Record & Recognize** to record a new one.
2. Press **Analyze Audio** to view plots and gender prediction.
3. Use the **Play** and **Stop** buttons to listen to the audio.
4. All feature values and the classification result will be displayed on the right panel.

## Gender Classification Logic

The gender is classified using:
- **Pitch Range** (Fundamental Frequency):
  - Male: 80 Hz – 180 Hz (can be flexible up to 210 Hz)
  - Female: 150 Hz – 300 Hz
- **Formant Frequencies** (F1 & F2 via LPC)

Scoring is done based on which typical range the features fall into, and tie-breakers use pitch values.

## Example
![image](https://github.com/user-attachments/assets/d7ce14b8-2e4f-4bab-b170-a6e9324ee4ed)


_Example of the app in action, analyzing and classifying gender from voice._

## Contributing

Pull requests are welcome! If you have ideas for better pitch estimation, improved ML-based classification, or UI upgrades — feel free to contribute.

## License

MIT License. Feel free to use and modify for personal or academic projects.

---

**Author:** Mokshagna Anurag Kankati  
