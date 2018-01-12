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
    data_features = {
        'x_mean': data_win.top_x.mean(),
        'y_mean': data_win.top_y.mean(),
        'z_mean': data_win.top_z.mean(),
        'x_var': data_win.top_x.var(),
        'y_var': data_win.top_y.var(),
        'z_var': data_win.top_z.var(),
        'x_energy': data_win.top_x.apply(sample_bandpower),
        'y_energy': data_win.top_y.apply(sample_bandpower),
        'z_energy': data_win.top_z.apply(sample_bandpower),
        'fsr1_med': data_win.fsr1.median(),
        'fsr2_med': data_win.fsr2.median(),
        'is_walking': data_win.is_walking.apply(sample_mode)
    }
    # sample_mean = [data_win.top_x.mean(), data_win.top_y.mean(), data_win.top_z.mean()]
    # sample_var = [data_win.top_x.var(), data_win.top_y.var(), data_win.top_z.var()]
    # sample_energy = [data_win.top_x.apply(sample_bandpower), data_win.top_y.apply(sample_bandpower), data_win.top_z.apply(sample_bandpower)]
    # sample_fsr = [data_win.fsr1.median(), data_win.fsr2.median()]
    # is_walking = data_win.is_walking.apply(sample_mode)

    return pandas.DataFrame(data=data_features)

def main(args):
    raw_data = pandas.read_csv(args.filename[0])

    is_walking = raw_data.is_walking
    fsr_data = [raw_data.fsr1, raw_data.fsr2]
    accelerometer_data = [raw_data.top_x, raw_data.top_y, raw_data.top_z]

    num_features = 6
    rate = 24                   # Hz
    window_size_sec = 2         # sec

    window_size = rate*window_size_sec
    features = extract_windowed_features(raw_data, window_size, rate)
    features.to_csv('extracted_features.csv')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract features")
    parser.add_argument('--filename', nargs=1, default=["raw_demo_data.csv"], type=str,  dest="filename", help='the relative filepath')
    args = parser.parse_args()

    main(args)
