require 'unimidi'

# message body
# body = [
#   0x00,0x07,                # iCA4+ product ID
#   0x00,0x00,0x00,0x00,0x00,  # serial number
#   0x00,0x00,                 # transaction ID
#   0x40,0x4B,                 # command: SetAudioControlDetailValue
#   0x00,0x08,                 # number of bytes that follow, which contain command data (9 in decimal)
#   0x01,                      # command version number (1)
#   0x00,0x03,                 # audio port ID (3)
#   0x01,                      # controller number (1)
#   0x01,                      # detail number (1-4)
#   0x06,                      # controller type (6 = feature)
#   0b10,                      # only mute value follows
#   0x01,                      # mute control value: on
# ]

def send_message(body)
  # checksum
  body << ((~body.sum+1) & 0x7F)

  # sysex wrapper and header
  msg = [
    0xF0,
    0x00,0x01,0x73,0x7E,       # header: iConnectivity's manufacturer ID and message class
    *body,
    0xF7
  ]

  # send sysex
  output = UniMIDI::Output.first
  output.puts(msg)
end

# SetMixerInputControlValue (volume)
body = [
  0x00,0x07,
  0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,
  0x40,0x5D,               # SetMixerInputControlValue
  0x00,0x09,               # data length
  0x01,                    # command version number
  0x00,0x03,               # audio port ID
  0x01,                    # mixer output number (01: submix 1, 03: submix 2)
  0x09,                    # mixer input number (1-8)
  0b1,                     # value flags: only volume
  0x00,0x7F,0x00,          # volume
]

# SetMixerInputControlValue (mute)
body = [
  0x00,0x07,
  0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,
  0x40,0x5D,               # SetMixerInputControlValue
  0x00,0x07,               # data length
  0x01,                    # command version number
  0x00,0x03,               # audio port ID
  0x01,                    # mixer output number (01: submix 1, 03: submix 2)
  0x02,                    # mixer input number (1-8)
  0b10,                    # value flags: only mute
  0x7f,                    # mute
]

# volume range:
# inputs: 0 to +60 dB
# submixes: -∞ (-78) to +6 dB
# outputs: -∞ (-63) to 0 dB


def calc_volume(db_value)
  if db_value >= 0
    [0x00, (db_value * 2).floor]
  else
    [0x03, 128 + (db_value * 2).floor]
  end
end

vol_sign, vol_level = calc_volume(-65)


# SetMixerOutputControlValue
body = [
  0x00,0x07,
  0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,
  0x40,0x5F,               # SetMixerOutputControlValue
  0x00,0x08,               # data length
  0x01,                    # command version number
  0x00,0x03,               # audio port ID (always 3)
  0x03,                    # mixer output number (01: submix 1, 03: submix 2)
  0b1,                     # value flags: only volume
  vol_sign,vol_level,0x00,          # volume
]

# SetMixerOutputControlValue
body = [
  0x00,0x07,
  0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,
  0x40,0x5F,               # SetMixerOutputControlValue
  0x00,0x06,               # data length
  0x01,                    # command version number
  0x00,0x03,               # audio port ID
  0x03,                    # mixer output number (01: submix 1, 03: submix 2)
  0b10,                    # value flags: only mute
  0x01                     # mute
]


# SetAudioControlDetailValue (output volume)
body = [
  0x00,0x07,
  0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,
  0x40,0x4B,
  0x00,0x0D,
  0x01,
  0x00,0x03, #audio port
  0x03, # controller num (01: input, 02: output, 03: headphones)
  0x02, # detail num (1-4: outputs 1-4, headphones are not 5-6??)
  0x06, # controller type
  0b1,
  0x03,0x00,0x00, #volume
  0x00,0x00,0x00, #trim
]

# send_message(body)
