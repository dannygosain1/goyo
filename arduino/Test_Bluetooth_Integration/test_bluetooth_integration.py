from gattlib import GATTRequester, GATTResponse
import time
import data_pb2
import re

test_data1 = [
    data_pb2.GoYoData(fsr=234,x_accel=134,y_accel=124,z_accel=764),
    data_pb2.GoYoData(fsr=363,x_accel=518,y_accel=111,z_accel=134),
    data_pb2.GoYoData(fsr=166,x_accel=646,y_accel=662,z_accel=698)
]
test_length = 50


class Requester(GATTRequester):
    def is_done(self):
        return self.done

    def set_done(self, state):
        self.done = state

    def num_lines(self):
        return self.num_lines

    def set_num_lines(self, num):
        self.num_lines = num;

    def bulk_data(self):
        return self.bulk_data;

    def set_bulk_data(self, data):
        self.bulk_data = data

    def on_notification(self, handle, data):
        message = data_pb2.GoYoData()
        data_striped = data.replace('\x1b%\x00', '')
        message.ParseFromString(data_striped)
        self.num_lines = self.num_lines + 1
        self.bulk_data.append(message)
        if message.fsr == 999:
            self.set_done(True)


# MAC_ADDRESS = '58:7A:62:4F:99:03'
MAC_ADDRESS = '58:7A:62:4F:9D:75'
WRITE_HANDLE = 0x0025


def test_dump_data():
    print("trying to connect")
    req = Requester(MAC_ADDRESS)
    req.set_done(False)
    req.set_num_lines(0)
    req.set_bulk_data([])

    print("getting ready to collect data")
    req.write_by_handle(WRITE_HANDLE, 'd')
    start_time = time.time()
    while req.is_done() != True:
        continue
    end_time = time.time()
    print("start: {}, end: {}".format(start_time, end_time))
    print("duration = {}".format(end_time-start_time))
    print("num lines {}".format(req.num_lines))
    req.disconnect()
    num_correct = 0
    num_incorrect = 0
    for i in range(0,req.num_lines-1):
        if test_data1[(i+1)%3] == req.bulk_data[i]:
            num_correct += 1
        else:
            num_incorrect += 1
    req.set_bulk_data([])
    print("num_correct: %s, num_incorrect: %s" % (num_correct, num_incorrect))


def main():
    test_dump_data()


if __name__ == "__main__":
    main()
