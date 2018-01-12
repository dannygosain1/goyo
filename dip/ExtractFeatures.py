#! python3.6

import pandas
import argparse
import scipy
from scipy.signal import periodogram
from scipy.stats import mode


def bandpower(x, fs, fmin, fmax):
    f, Pxx = periodogram(x, fs=fs)
    ind_min = scipy.argmax(f > fmin) - 1
    ind_max = scipy.argmax(f > fmax) - 1
    return scipy.trapz(Pxx[ind_min: ind_max], f[ind_min: ind_max])

def extract_windowed_features(data, window_size, sample_freq):
    sample_mode = lambda a: mode(a)[0]
    sample_bandpower = lambda a: bandpower(a, sample_freq, a.min(), a.max())
    data_win = data.rolling(window_size)

    # NOTE:[window_size-1::window_size] extracts the last element off the rolling window
    data_features = {
        'x_mean': data_win.top_x.mean()[window_size-1::window_size],
        'y_mean': data_win.top_y.mean()[window_size-1::window_size],
        'z_mean': data_win.top_z.mean()[window_size-1::window_size],
        'x_var': data_win.top_x.var()[window_size-1::window_size],
        'y_var': data_win.top_y.var()[window_size-1::window_size],
        'z_var': data_win.top_z.var()[window_size-1::window_size],
        'x_energy': data_win.top_x.apply(sample_bandpower)[window_size-1::window_size],
        'z_energy': data_win.top_z.apply(sample_bandpower)[window_size-1::window_size],
        'y_energy': data_win.top_y.apply(sample_bandpower)[window_size-1::window_size],
        'fsr1_med': data_win.fsr1.median()[window_size-1::window_size],
        'fsr2_med': data_win.fsr2.median()[window_size-1::window_size],
        'is_walking': data_win.is_walking.apply(sample_mode)[window_size-1::window_size]
    }
    return pandas.DataFrame(data=data_features)

def main(args):
    raw_data = pandas.read_csv(args.filename[0])

    is_walking = raw_data.is_walking
    fsr_data = [raw_data.fsr1, raw_data.fsr2]
    accelerometer_data = [raw_data.top_x, raw_data.top_y, raw_data.top_z]
    rate = 24                   # Hz
    window_size_sec = 1         # sec
    window_size = rate*window_size_sec
    features = extract_windowed_features(raw_data, window_size, rate)
    features.to_csv('extracted_features.csv')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract features")
    parser.add_argument('--filename', nargs=1, default=["raw_demo_data.csv"], type=str,  dest="filename", help='the relative filepath')
    args = parser.parse_args()

    main(args)
