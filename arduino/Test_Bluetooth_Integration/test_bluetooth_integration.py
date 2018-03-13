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
BROKEN_END = 9999999999999999999999999999999


class Requester(GATTRequester):
    def is_done(self):
        return self.done

    def set_done(self, state):
        self.done = state

    def num_lines(self):
        return self.num_lines

    def set_num_lines(self, num):
        self.num_lines = num;

    def get_bulk_data(self):
        return self.bulk_data;

    def set_bulk_data(self, data):
        self.bulk_data = data

    def on_notification(self, handle, data):
        message = data_pb2.GoYoData()
        data_striped = data.replace('\x1b%\x00', '')
        if '\r\n' in data_striped:
            self.bulk_data = data_striped.replace('\r\n', '')
            self.set_done(True)
        else:
            message.ParseFromString(data_striped)
            self.num_lines = self.num_lines + 1
            self.bulk_data.append(message)
            if message.fsr == 999:
                self.set_done(True)


# MAC_ADDRESS = '58:7A:62:4F:99:03'
MAC_ADDRESS = '58:7A:62:4F:9D:75'
WRITE_HANDLE = 0x0025


def setup_request():
    req = Requester(MAC_ADDRESS)
    req.set_done(False)
    req.set_num_lines(0)
    req.set_bulk_data([])
    return req


def dump_data(req):
    req.write_by_handle(WRITE_HANDLE, 'd')
    start_time = time.time()
    while req.is_done() != True:
        if time.time() > start_time+5:
            end_time = BROKEN_END
            return start_time, end_time
        continue
    end_time = time.time()
    return start_time,end_time


def determine_correct(test_length, num_recieved_lines, data):
    num_correct = 0
    num_incorrect = test_length-num_recieved_lines+1
    for i in range(0,num_recieved_lines-1):
        if test_data1[(i+1)%3] == data[i]:
            num_correct += 1
        else:
            num_incorrect += 1
    return num_correct, num_incorrect


def test_many_dumps(num_dumps):
    print("\nTesting {} dumps".format(num_dumps))
    dump_stats = []
    for i in range(0,num_dumps):
        req = setup_request()
        start_time, end_time = dump_data(req)
        req.disconnect()
        print("dump {} duration = {}".format(i, end_time-start_time))
        num_correct, num_incorrect = determine_correct(test_length,req.num_lines,req.get_bulk_data())
        broken = 1 if end_time == BROKEN_END else 0
        dump_stats.append(
            {'duration':end_time-start_time,
             'num_correct': num_correct,
             'num_incorrect': num_incorrect,
             'broken': broken
            }
        )
    num_broken = sum(int(v['broken']) for v in dump_stats)
    sum_dur = 0
    for stat in dump_stats:
        if not stat['broken']:
            sum_dur += stat['duration']
    average_duration = sum_dur/((num_dumps-num_broken)*1.00000)
    print("Average duration = {}".format(average_duration))
    print("total num_correct = {}".format(sum(int(v['num_correct']) for v in dump_stats)))
    print("total num_incorrect = {}".format(sum(int(v['num_incorrect']) for v in dump_stats)))
    print("total broken = {}".format(num_broken))


def test_get_millis():
    delay_time = 10;
    print("\nTesting millis")
    req = setup_request()
    req.write_by_handle(WRITE_HANDLE, 'm')
    while req.is_done() != True:
        continue
    time1 = req.get_bulk_data()
    req.disconnect()
    req = setup_request()
    req.write_by_handle(WRITE_HANDLE, 'm')
    while req.is_done() != True:
        continue
    time2 = req.get_bulk_data()

    print("millis1 = {}, millis2  = {}".format(time1, time2))
    print("millis difference = {}".format(int(time2)-int(time1)))
    req.disconnect()


def main():
    # test_get_millis()
    test_many_dumps(4)


if __name__ == "__main__":
    main()
