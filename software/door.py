#!/usr/bin/python

import time
import RPi.GPIO as GPIO
import sys

# RPi.GPIO Layout verwenden (wie Pin-Nummern)
GPIO.setmode(GPIO.BOARD)

# power on motor (PA)
motorPower = 11

# close door (A1)
motorLock = 13

# open door (A2)
motorUnlock = 15

# green/white = GND
# green = 3.3V
# orange = opto->open
# orange/white = opto->closed

optoUnlocked = 16
optoLocked = 18

GPIO.setup(motorPower, GPIO.OUT)
GPIO.setup(motorLock, GPIO.OUT)
GPIO.setup(motorUnlock, GPIO.OUT)

GPIO.setup(optoUnlocked, GPIO.IN)
GPIO.setup(optoLocked, GPIO.IN)

GPIO.output(motorPower, GPIO.LOW)
GPIO.output(motorLock, GPIO.LOW)
GPIO.output(motorUnlock, GPIO.LOW)

# zusperren
GPIO.output(motorPower, GPIO.HIGH)
GPIO.output(motorLock, GPIO.HIGH)
time.sleep(0.5)
GPIO.output(motorPower, GPIO.LOW)
GPIO.output(motorLock, GPIO.LOW)

# aufsperren

# time.sleep(0.5)
# GPIO.output(motorPower, GPIO.LOW)
# GPIO.output(motorUnlock, GPIO.LOW)

def unlockDoor(timeout):
	if GPIO.input(optoUnlocked) == GPIO.HIGH:
		GPIO.output(motorPower, GPIO.HIGH)
		GPIO.output(motorUnlock, GPIO.HIGH)
		elapsed = time.time() + timeout
		print 'unlocking...'
		while GPIO.input(optoUnlocked) == GPIO.HIGH:
			if time.time() > elapsed:
				print 'TIMEOUT'
				return False
		GPIO.output(motorPower, GPIO.LOW)
		GPIO.output(motorUnlock, GPIO.LOW)
		return True
	else:
		print 'already unlocked'
		return False

def lockDoor(timeout):
	if GPIO.input(optoLocked) == GPIO.HIGH:
		GPIO.output(motorPower, GPIO.HIGH)
		GPIO.output(motorLock, GPIO.HIGH)
		elapsed = time.time() + timeout
		print 'locking...'
		while GPIO.input(optoLocked) == GPIO.HIGH:
			if time.time() > elapsed:
				print 'TIMEOUT'
				return False
		GPIO.output(motorPower, GPIO.LOW)
		GPIO.output(motorLock, GPIO.LOW)
		return True
	else:
		print 'already locked'
		return False

def leave(status):
	GPIO.cleanup()
	if (status):
		exit(0)
	else:
		exit(1)

cmd = sys.argv[1]

if cmd == 'lock':
	leave(lockDoor(3))
elif cmd == 'unlock':
	leave(unlockDoor(3))
else:
	print 'invalid command'
	leave(False)




