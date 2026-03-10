# serial_bridge.py
import serial, socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# ser = serial.Serial('/dev/ttyACM0', 9600) # arduino
ser = serial.Serial('/dev/ttyUSB0', 9600) # lilypad

while True:
    line = ser.readline().decode().strip()
    sock.sendto(line.encode(), ('127.0.0.1', 4242))
    print(line)