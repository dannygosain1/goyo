#! /usr/bin/env/python2
import serial
import csv
import time
import datetime
import argparse

def main(args):

    print("starting up")
    data_feed = serial.Serial()
    data_feed.port =  args.port[0]
    data_feed.baudrate = 9600
    data_feed.open()

    start_time = time.time()
    duration = args.duration[0]
    endtime = 0
    collecting = True

    with open('data.csv', 'wb') as csvfile:
        fieldnames = ['timestamp', 'is_walking', 'fsr', 'x_acc', 'y_acc', 'z_acc']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter=',', quoting=csv.QUOTE_MINIMAL)

        writer.writeheader()
        while collecting:
            dp = data_feed.readline().split(" ")
            if len(dp) == 4:
                print(dp)
                # time_stamp = datetime.datetime.fromtimestamp(
                #     time.time()).strftime("%Y-%m-%dT%H:%M:%S")
                writer.writerow(
                    {'timestamp': dp[0].strip(),
                    'is_walking': dp[1].strip(), 'fsr': dp[2].strip(),
                    'x_acc': dp[3].strip(), 'y_acc': dp[4].strip(), 'z_acc': dp[5].strip()
                })

            if time.time() > start_time + duration:
                endtime = time.time()
                collecting = False

    data_feed.close()
    print("start time: {}".format(start_time))
    print("end time: {}".format(endtime))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Collect data on serial port")
    parser.add_argument('--port', nargs=1, default=["/dev/ttyACM0"], type=str,  dest="port", help='selects the port')
    parser.add_argument('--duration', nargs=1, default=[100], type=int, dest="duration", help="duration of data collection")
    args = parser.parse_args()

    main(args)
