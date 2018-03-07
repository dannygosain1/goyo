from gattlib import GATTRequester, GATTResponse
import time


class Requester(GATTRequester):
    def on_notification(self, handle, data):
        print("{}: {}\n".format(time.time(), data))


MAC_ADDRESS = '58:7A:62:4F:99:03'
WRITE_HANDLE = 0x0025


def main():
    req = Requester(MAC_ADDRESS)
    req.write_by_handle(WRITE_HANDLE, 'd')
    time.sleep(30)
    req.disconnect()


if __name__ == "__main__":
    main()
