require 'unimidi'

output = UniMIDI::Output.first
puts "12,"
mixer_index = 1

# message body
body = [
  0x00,0x07,                 # iCA4+ product ID
  0x00,0x00,0x00,0x00,0x00,  # serial number
  0x00,0x00,                 # transaction ID
  0x40,0x4B,                 # command: SetAudioControlDetailValue
  0x00,0x08,                 # number of bytes that follow, which contain command data (9 in decimal)
  0x01,                      # command version number (1)
  0x00,0x03,                 # audio port ID (3)
  0x01,                      # controller number (1)
  mixer_index,               # detail number (1-4)
  0x06,                      # controller type (6 = feature)
  0b10,                      # which values are included*
  0x01,                      # mute control value
]

# checksum
body << ((~body.sum+1) & 0x7F)

p body.map

# sysex wrapper and header
msg = [
  0xF0,
  0x00,0x01,0x73,0x7E,       # header: iConnectivity's manufacturer ID and message class
  *body,
  0xF7
]

# send sysex
output.puts(msg)


# *mixer values included:
#
# bit 0     set if volume & trim control values are included (16 bit value encoded in 3 bytes)
# bit 1     set if mute control value is included (0 = mute off, 1 = mute on)
# bit 2     set if phantom power control value included (0 = phantom power off, 1 = phantom power on)
# bit 3     set if high impedance control value included (0 = high impedance off, 1 = high impedance on)
# bit 4     set if stereo link control value is included (0 = link off, 1 = link on)
# bits 5-7  always zero
