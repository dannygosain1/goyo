from gattlib import GATTRequester, GATTResponse
import time
import data_pb2
import re


class Requester(GATTRequester):
    def is_done(self):
        return self.done

    def set_done(self, state):
        self.done = state

    def num_lines(self):
        return self.num_lines

    def set_num_lines(self, num):
        self.num_lines = num;

    def on_notification(self, handle, data):
        message = data_pb2.Data()
        data_striped = data.replace('\x1b%\x00', '')
        message.ParseFromString(data_striped)
        self.num_lines = self.num_lines + 1
        if message.fsr == 999:
            self.set_done(True)


MAC_ADDRESS = '58:7A:62:4F:99:03'
# MAC_ADDRESS = '58:7A:62:4F:9D:75'
WRITE_HANDLE = 0x0025


def main():
    print("trying to connect")
    req = Requester(MAC_ADDRESS)
    req.set_done(False)
    req.set_num_lines(0)

    print("getting ready to collect data")
    req.write_by_handle(WRITE_HANDLE, 'd')
    start_time = time.time()
    while req.is_done() != True:
        continue
    end_time = time.time()
    print("done - start: {}, end: {}".format(start_time, end_time))
    print("duration = {}".format(end_time-start_time))
    print("num lines {}".format(req.num_lines))
    req.disconnect()


if __name__ == "__main__":
    main()
