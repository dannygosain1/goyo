#! python3.6
import os
import pandas
import argparse
import scipy
from scipy.signal import periodogram
from scipy.stats import mode
from sklearn import preprocessing

def bandpower(x, fs, fmin, fmax):
    f, Pxx = periodogram(x, fs=fs)
    return scipy.trapz(Pxx, f)

def extract_windowed_features(data, window_size, sample_freq):
    sample_mode = lambda a: mode(a)[0]
    sample_bandpower = lambda a: bandpower(a, sample_freq, a.min(), a.max())
    data_win = data.rolling(window_size)
    sample_win = int(window_size/2)
    # NOTE:[sample_win::sample_win+1] extracts the last element off the rolling window
    data_features = {
        'x_mean': data_win.x_acc.mean()[sample_win::sample_win+1],
        'y_mean': data_win.y_acc.mean()[sample_win::sample_win+1],
        'z_mean': data_win.z_acc.mean()[sample_win::sample_win+1],
        'x_var': data_win.x_acc.var()[sample_win::sample_win+1],
        'y_var': data_win.y_acc.var()[sample_win::sample_win+1],
        'z_var': data_win.z_acc.var()[sample_win::sample_win+1],
        'x_energy': data_win.x_acc.apply(sample_bandpower)[sample_win::sample_win+1],
        'z_energy': data_win.z_acc.apply(sample_bandpower)[sample_win::sample_win+1],
        'y_energy': data_win.y_acc.apply(sample_bandpower)[sample_win::sample_win+1],
        'fsr_med': data_win.fsr.median()[sample_win::sample_win+1],
        'is_walking': data_win.is_walking.apply(sample_mode)[sample_win::sample_win+1]
    }
    feature_data = pandas.DataFrame(data=data_features).dropna()
    return feature_data

def process_features(features):
    #reorder columns
    reordered_columns = [
        'is_walking',
        'fsr_med',
        'x_mean',
        'y_mean',
        'z_mean',
        'x_var',
        'y_var',
        'z_var',
        'x_energy',
        'y_energy',
        'z_energy'
    ]
    features = features[reordered_columns]
    #normalize columns based on min-max normalization
    features[features.columns] = preprocessing.minmax_scale(features[features.columns])

    return features

def raw_data_to_vectors(raw_data):
    rate = 50                   # Hz
    window_size_sec = 2         # sec
    window_size = rate*window_size_sec
    return extract_windowed_features(raw_data, window_size, rate)

def generate_features(raw_data):
    return process_features(raw_data_to_vectors(raw_data))

def create_feature_file(filename):
    raw_data = pandas.read_csv(filename)
    features = generate_features(raw_data)
    features_filename = "%s_extracted_features.csv" % filename.split(".")[0]
    features.to_csv(features_filename, index=False)

def main(args):
    if args.data_dir is not None:
        raw_data_files = os.listdir(args.data_dir)
        for raw_data_file in raw_data_files:
            print("Generating features from raw data file {0}".format(raw_data_file))
            create_feature_file("{0}/{1}".format(args.data_dir, raw_data_file))
    elif args.filename is not None:
        create_feature_file(args.filename)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract features")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--filename', default=["raw_demo_data.csv"], type=str,  dest="filename", help='the relative filepath')
    group.add_argument('--dir', type=str,  dest="data_dir", help='the relative filepath of where the raw data is')
    args = parser.parse_args()

    main(args)
