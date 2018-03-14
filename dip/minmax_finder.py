import model_kfold as mkf
import extract_features as ex
import argparse
import pandas as pd
import os


def min_max_norm_features(data):
    target = data[:, 0]
    fsr = data[:, 1]
    x_mean = data[:, 2]
    y_mean = data[:, 3]
    z_mean = data[:, 4]
    x_var = data[:, 5]
    y_var = data[:, 6]
    z_var = data[:, 7]

    print("fsr med: min = %s  max = %s" % (fsr.min(), fsr.max()))
    print("x mean: min = %s  max = %s" % (x_mean.min(), x_mean.max()))
    print("y mean: min = %s  max = %s" % (y_mean.min(), y_mean.max()))
    print("z mean: min = %s  max = %s" % (z_mean.min(), z_mean.max()))
    print("x var: min = %s  max = %s" % (x_var.min(), x_var.max()))
    print("y var: min = %s  max = %s" % (y_var.min(), y_var.max()))
    print("z var: min = %s  max = %s" % (z_var.min(), z_var.max()))


def load_files(dir):
    files = os.listdir(dir)
    files = list(map(lambda file: "{0}/{1}".format(dir, file), files))
    data = pd.concat((pd.read_csv(f) for f in files))
    return data


def main(args):
    rate = 50                   # Hz
    window_size_sec = 2         # sec
    window_size = rate*window_size_sec
    raw_data = load_files(args.data_dir)
    print("loaded files")
    features = ex.extract_windowed_features(raw_data, window_size, rate)
    features.to_csv('concatenated_features.csv')
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
    print("got windowed features")
    min_max_norm_features(features.values)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="determine raw min-max")
    parser.add_argument('--data', type=str,  dest="data_dir", help='the relative filepath of data dir')
    args = parser.parse_args()

    main(args)
