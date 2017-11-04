#!/usr/bin/python2
import csv
import argparse

def main(args):
    csv_data = []
    with open(args.filename[0], 'rb') as data_file:
        data_csv = csv.reader(data_file)
        for row in data_csv:
            csv_data.append(row)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Analyze data")
    parser.add_argument('--filename', nargs=1, default=["/"], type=str,  dest="filename", help='the relative filepath') 
    args = parser.parse_args()

    main(args)

