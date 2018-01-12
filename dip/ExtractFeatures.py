#! python3.6

import pandas
import argparse


def extract_signal_features(sample):
    pass

def create_windows(data, rate, window_size, window_overlap):
    pass

def main(args):
    raw_data = pandas.read_csv(args.filename[0])

    is_walking = raw_data.is_walking
    fsr_data = [raw_data.fsr_bottom, raw_data.fsr_top]
    accelerometer_data = [raw_data.top_x, raw_data.top_y, raw_data.top_z]

    num_features = 6
    rate = 24               # Hz
    window_size = 2         # sec
    window_overlap = 1      # sec

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract features")
    parser.add_argument('--filename', nargs=1, default=["raw_demo_data.csv"], type=str,  dest="filename", help='the relative filepath')
    args = parser.parse_args()

    main(args)
