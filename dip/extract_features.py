#! python3.6
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
        'x_mean': data_win.top_x.mean()[sample_win::sample_win+1],
        'y_mean': data_win.top_y.mean()[sample_win::sample_win+1],
        'z_mean': data_win.top_z.mean()[sample_win::sample_win+1],
        'x_var': data_win.top_x.var()[sample_win::sample_win+1],
        'y_var': data_win.top_y.var()[sample_win::sample_win+1],
        'z_var': data_win.top_z.var()[sample_win::sample_win+1],
        'x_energy': data_win.top_x.apply(sample_bandpower)[sample_win::sample_win+1],
        'z_energy': data_win.top_z.apply(sample_bandpower)[sample_win::sample_win+1],
        'y_energy': data_win.top_y.apply(sample_bandpower)[sample_win::sample_win+1],
        'fsr1_med': data_win.fsr1.median()[sample_win::sample_win+1],
        'fsr2_med': data_win.fsr2.median()[sample_win::sample_win+1],
        'is_walking': data_win.is_walking.apply(sample_mode)[sample_win::sample_win+1]
    }
    feature_data = pandas.DataFrame(data=data_features).dropna()
    return feature_data

def process_features(features):
    #reorder columns
    reordered_columns = [
        'is_walking', 
        'fsr1_med',
        'fsr2_med',
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
    features[features.columns] = preprocessing.maxabs_scale(features[features.columns])

    return features

def raw_data_to_vectors(raw_data):
    is_walking = raw_data.is_walking
    fsr_data = [raw_data.fsr1, raw_data.fsr2]
    accelerometer_data = [raw_data.top_x, raw_data.top_y, raw_data.top_z]
    rate = 24                   # Hz
    window_size_sec = 2         # sec
    window_size = rate*window_size_sec
    return extract_windowed_features(raw_data, window_size, rate)

def generate_features(raw_data):
    return process_features(raw_data_to_vectors(raw_data))

def main(args):
    raw_data = pandas.read_csv(args.filename[0])
    features = generate_features(raw_data) 
    features_filename = "%s_extracted_features.csv" % args.filename[0].split(".")[0]
    features.to_csv(features_filename, index=False)
    return processed_features

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract features")
    parser.add_argument('--filename', nargs=1, default=["raw_demo_data.csv"], type=str,  dest="filename", help='the relative filepath')
    args = parser.parse_args()

    main(args)
