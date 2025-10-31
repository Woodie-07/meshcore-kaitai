meta:
  id: companion_cmds
  endian: le
  bit-endian: le
  imports:
    - meshcore
    - companion_common
enums:
  command:
    1: app_start
    2: send_txt_msg
    3: send_channel_txt_msg
    4: get_contacts
    5: get_device_time
    6: set_device_time
    7: send_self_advert
    8: set_advert_name
    9: add_update_contact
    10: sync_next_message
    11: set_radio_params
    12: set_radio_tx_power
    13: reset_path
    14: set_advert_latlon
    15: remove_contact
    16: share_contact
    17: export_contact
    18: import_contact
    19: reboot
    20: get_batt_and_storage
    21: set_tuning_params
    22: device_query
    23: export_private_key
    24: import_private_key
    25: send_raw_data
    26: send_login
    27: send_status_req
    28: has_connection
    29: logout
    30: get_contact_by_key
    31: get_channel
    32: set_channel
    33: sign_start
    34: sign_data
    35: sign_finish
    36: send_trace_path
    37: set_device_pin
    38: set_other_params
    39: send_telemetry_req
    40: get_custom_vars
    41: set_custom_var
    42: get_advert_path
    43: get_tuning_params
    50: send_binary_req
    51: factory_reset
    52: send_path_discovery_req
types:
  app_start:
    seq:
      - id: reserved
        size: 7
      - id: app_name
        type: str
        encoding: UTF-8
        size-eos: true
  send_txt_msg:
    seq:
      - id: txt_type
        type: u1
        enum: companion_common::txt_type
      - id: attempt
        type: u1
      - id: msg_timestamp
        type: u4
      - id: pub_key_prefix
        size: 6
      - id: text
        type: str
        encoding: UTF-8
        size-eos: true
  send_channel_txt_msg:
    seq:
      - id: txt_type
        type: u1
        enum: companion_common::txt_type
        valid: companion_common::txt_type::plain
      - id: channel_idx
        type: u1
      - id: msg_timestamp
        type: u4
      - id: text
        type: str
        encoding: UTF-8
        size-eos: true
  get_contacts:
    seq:
      - id: since
        type: u4
        if: not _io.eof
  set_device_time:
    seq:
      - id: secs
        type: u4
  send_self_advert:
    seq:
      - id: flood
        type: u1
        if: not _io.eof
  set_advert_name:
    seq:
      - id: name
        type: str
        encoding: UTF-8
        size-eos: true
  add_update_contact_loc:
    seq:
      - id: latitude_microdegrees
        type: u4
      - id: longitude_microdegrees
        type: u4
    instances:
      latitude:
        value: latitude_microdegrees / 1000000.0
      longitude:
        value: longitude_microdegrees / 1000000.0
  add_update_contact:
    seq:
      - id: pub_key
        size: 32
      - id: type
        type: u1
        enum: meshcore::node_type
      - id: flags
        type: companion_common::contact_flags
      - id: num_out_path
        type: u1
      - id: out_path
        type: u1
        repeat: expr
        repeat-expr: 64
      - id: name
        type: str
        size: 32
        encoding: UTF-8
        terminator: 0
      - id: last_advert_timestamp
        type: u4
      - id: location
        type: add_update_contact_loc
        if: not _io.eof
      - id: lastmod
        type: u4
        if: not _io.eof
  set_radio_params:
    seq:
      - id: freq_khz
        type: u4
      - id: bw_khz
        type: u4
      - id: sf
        type: u1
      - id: cr
        type: u1
    instances:
      freq_mhz:
        value: freq_khz / 1000.0
      bw_mhz:
        value: bw_khz / 1000.0
  set_radio_tx_power:
    seq:
      - id: tx_power
        type: u1
  pub_key_payload:
    seq:
      - id: pub_key
        size: 32
  set_advert_latlon:
    seq:
      - id: latitude_microdegrees
        type: u4
      - id: longitude_microdegrees
        type: u4
      - id: altitude
        type: u4
        if: not _io.eof
    instances:
      latitude:
        value: latitude_microdegrees / 1000000.0
      longitude:
        value: longitude_microdegrees / 1000000.0
  export_contact:
    seq:
      - id: pub_key
        size: 32
        if: not _io.eof
  import_contact:
    seq:
      - id: advert_packet
        type: meshcore
        valid:
          expr: _.header.payload_type == meshcore::payload_type::advert
  reboot:
    seq:
      - id: reboot
        size: 6
        contents: reboot
  set_tuning_params:
    seq:
      - id: rx
        type: u4
      - id: af
        type: u4
  device_query:
    seq:
      - id: app_target_ver
        type: u1
  import_private_key:
    seq:
      - id: private_key
        size: 64
  send_raw_data:
    seq:
      - id: num_path
        type: u1
      - id: path
        type: u1
        repeat: expr
        repeat-expr: num_path
  send_login:
    seq:
      - id: pub_key
        size: 32
      - id: password
        type: str
        encoding: UTF-8
        size-eos: true
  get_channel:
    seq:
      - id: channel_idx
        type: u1
  set_channel:
    seq:
      - id: channel_idx
        type: u1
      - id: channel_name
        type: str
        size: 32
        encoding: UTF-8
        terminator: 0
      - id: channel_secret
        size: 16
  sign_data:
    seq:
      - id: data
        size-eos: true
  send_trace_path:
    seq:
      - id: tag
        type: u4
      - id: auth
        type: u4
      - id: flags
        type: u1
      - id: path
        size-eos: true
  set_device_pin:
    seq:
      - id: pin
        type: u4
  set_other_params_telemetry:
    seq:
      - id: telemetry_mode_base
        type: b2
      - id: telemetry_mode_loc
        type: b2
      - id: telemetry_mode_env
        type: b2
  set_other_params:
    seq:
      - id: manual_add_contacts
        type: u1
      - id: telemetry
        type: set_other_params_telemetry
        if: not _io.eof
      - id: multi_acks
        type: u1
        if: not _io.eof
      - id: advert_loc_policy
        type: u1
        enum: companion_common::advert_loc_policy
        if: not _io.eof
  send_telemetry_req:
    seq:
      - id: unused
        size: 3
      - id: pub_key
        size: 32
  set_custom_var:
    seq:
      - id: value
        type: str
        encoding: UTF-8
        size-eos: true
        doc: name:value string
  get_advert_path:
    seq:
      - id: reserved
        type: u1
      - id: pub_key
        size: 32
  send_binary_req:
    seq:
      - id: pub_key
        size: 32
      - id: req_data
        size-eos: true
  factory_reset:
    seq:
      - id: reset
        size: 5
        contents: reset
  send_path_discovery_req:
    seq:
      - id: reserved
        type: u1
        valid: 0
      - id: pub_key
        size: 32
seq:
  - id: command
    type: u1
    enum: command
  - id: payload
    type:
      switch-on: command
      cases:
        command::app_start: app_start
        command::send_txt_msg: send_txt_msg
        command::send_channel_txt_msg: send_channel_txt_msg
        command::get_contacts: get_contacts
        command::set_device_time: set_device_time
        command::send_self_advert: send_self_advert
        command::set_advert_name: set_advert_name
        command::add_update_contact: add_update_contact
        command::set_radio_params: set_radio_params
        command::set_radio_tx_power: set_radio_tx_power
        command::reset_path: pub_key_payload
        command::set_advert_latlon: set_advert_latlon
        command::remove_contact: pub_key_payload
        command::share_contact: pub_key_payload
        command::export_contact: export_contact
        command::import_contact: import_contact
        command::reboot: reboot
        command::set_tuning_params: set_tuning_params
        command::device_query: device_query
        command::import_private_key: import_private_key
        command::send_raw_data: send_raw_data
        command::send_login: send_login
        command::send_status_req: pub_key_payload
        command::has_connection: pub_key_payload
        command::logout: pub_key_payload
        command::get_contact_by_key: pub_key_payload
        command::get_channel: get_channel
        command::set_channel: set_channel
        command::sign_data: sign_data
        command::send_trace_path: send_trace_path
        command::set_device_pin: set_device_pin
        command::set_other_params: set_other_params
        command::send_telemetry_req: send_telemetry_req
        command::set_custom_var: set_custom_var
        command::get_advert_path: get_advert_path
        command::send_binary_req: send_binary_req
        command::factory_reset: factory_reset
        command::send_path_discovery_req: send_path_discovery_req
