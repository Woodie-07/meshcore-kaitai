meta:
  id: companion
  endian: le
  bit-endian: le
  imports:
    - meshcore
    - companion_common
enums:
  resp_code:
    0: ok
    1: err
    2: contacts_start
    3: contact
    4: end_of_contacts
    5: self_info
    6: sent
    7: contact_msg_recv
    8: channel_msg_recv
    9: curr_time
    10: no_more_messages
    11: export_contact
    12: batt_and_storage
    13: device_info
    14: private_key
    15: disabled
    16: contact_msg_recv_v3
    17: channel_msg_recv_v3
    18: channel_info
    19: sign_start
    20: signature
    21: custom_vars
    22: advert_path
    23: tuning_params
  push_code:
    0x00: advert
    0x01: path_updated
    0x02: send_confirmed
    0x03: msg_waiting
    0x04: raw_data
    0x05: login_success
    0x06: login_fail
    0x07: status_response
    0x08: log_rx_data
    0x09: trace_data
    0x0A: new_advert
    0x0B: telemetry_response
    0x0C: binary_response
    0x0D: path_discovery_response
  err_code:
    1: unsupported_cmd
    2: not_found
    3: table_full
    4: bad_state
    5: file_io_error
    6: illegal_arg
types:
  err:
    seq:
      - id: err_code
        type: u1
        enum: err_code
  contacts_start:
    seq:
      - id: num_contacts
        type: u4
  contact:
    seq:
      - id: pub_key
        size: 32
      - id: node_type
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
        size: 32
        terminator: 0
      - id: last_advert_timestamp
        type: u4
      - id: latitude_microdegrees
        type: u4
      - id: longitude_microdegrees
        type: u4
      - id: lastmod
        type: u4
    instances:
      has_out_path:
        value: num_out_path != 0xFF
      latitude:
        value: latitude_microdegrees / 1000000.0
      longitude:
        value: longitude_microdegrees / 1000000.0
  end_of_contacts:
    seq:
      - id: lastmod
        type: u4
  self_info:
    seq:
      - id: advert_type
        type: u1
      - id: tx_power_dbm
        type: u1
      - id: max_tx_power_dbm
        type: u1
      - id: public_key
        size: 32
      - id: latitude_microdegrees
        type: u4
      - id: longitude_microdegrees
        type: u4
      - id: multi_acks
        type: u1
      - id: advert_loc_policy
        type: u1
        enum: companion_common::advert_loc_policy
      - id: telemetry_mode_base
        type: b2
      - id: telemetry_mode_loc
        type: b2
      - id: telemetry_mode_env
        type: b2
      - id: unused
        type: b2
      - id: manual_add_contacts
        type: u1
      - id: raw_freq
        type: u4
      - id: raw_bw
        type: u4
      - id: sf
        type: u1
      - id: cr
        type: u1
      - id: node_name
        type: str
        encoding: UTF-8
        size-eos: true
    instances:
      latitude:
        value: latitude_microdegrees / 1000000.0
      longitude:
        value: longitude_microdegrees / 1000000.0
      freq:
        value: raw_freq / 1000.0
      bw:
        value: raw_bw / 1000.0
  contact_msg_recv:
    seq:
      - id: from_pub_key_prefix
        size: 6
      - id: path_len
        type: u1
      - id: txt_type
        type: u1
        enum: companion_common::txt_type
      - id: sender_timestamp
        type: u4
      - id: sender_prefix
        if: txt_type == companion_common::txt_type::signed_plain
        size: 4
      - id: text
        type: str
        encoding: UTF-8
        size-eos: true
    instances:
      is_flood:
        value: path_len != 0xFF
  channel_msg_recv:
    seq:
      - id: channel_idx
        type: u1
      - id: path_len
        type: u1
      - id: txt_type
        type: u1
        enum: companion_common::txt_type
      - id: sender_timestamp
        type: u4
      - id: text
        type: str
        encoding: UTF-8
        size-eos: true
    instances:
      is_flood:
        value: path_len != 0xFF
  curr_time:
    seq:
      - id: secs
        type: u4
  device_info:
    seq:
      - id: firmware_ver_code
        type: u1
      - id: max_contacts_raw
        type: u1
      - id: max_group_channels
        type: u1
      - id: ble_pin
        type: u4
      - id: firmware_build_date
        type: str
        size: 12
        terminator: 0
        encoding: UTF-8
      - id: board_name
        type: str
        size: 40
        terminator: 0
        encoding: UTF-8
      - id: firmware_version
        type: str
        size: 20
        terminator: 0
        encoding: UTF-8
    instances:
      max_contacts:
        value: max_contacts_raw * 2
  private_key:
    seq:
      - id: private_key
        size: 64
  channel_msg_recv_v3:
    seq:
      - id: snr_raw
        type: s1
      - id: reserved1
        type: u1
      - id: reserved2
        type: u1
      - id: message
        type: channel_msg_recv
    instances:
      snr:
        value: snr_raw / 4.0
  contact_msg_recv_v3:
    seq:
      - id: snr_raw
        type: s1
      - id: reserved1
        type: u1
      - id: reserved2
        type: u1
      - id: message
        type: contact_msg_recv
    instances:
      snr:
        value: snr_raw / 4.0
  channel_info:
    seq:
      - id: index
        type: u1
      - id: name
        type: str
        size: 32
        encoding: UTF-8
        terminator: 0
      - id: secret
        size: 16
  pub_key_payload:
    seq:
      - id: pub_key
        size: 32
  send_confirmed:
    seq:
      - id: ack_crc
        size: 4
      - id: trip_time
        type: u4
  raw_data:
    seq:
      - id: snr_raw
        type: s4
      - id: rssi
        type: s4
      - id: reserved
        type: u1
      - id: payload
        size-eos: true
    instances:
      snr:
        value: snr_raw / 4.0
  login:
    seq:
      - id: pub_key_prefix
        size: 6
      - id: tag
        type: u4
      - id: acl_permissions
        type: u1
      - id: firmware_ver_level
        type: u1
  login_success:
    seq:
      - id: permissions
        type: u1
      - id: login
        type: login
        if: not _io.eof
  login_fail:
    seq:
      - id: reserved
        type: u1
  status_response:
    seq:
      - id: reserved
        type: u1
      - id: pub_key_prefix
        size: 6
      - id: data
        size-eos: true
  log_rx_data:
    seq:
      - id: snr_raw
        type: s1
      - id: rssi
        type: s1
      - id: packet
        type: meshcore
    instances:
      snr:
        value: snr_raw / 4.0
  snr_item:
    seq:
      - id: snr_raw
        type: u1
    instances:
      snr:
        value: snr_raw / 4.0
  trace_data:
    seq:
      - id: reserved
        type: u1
      - id: num_path
        type: u1
      - id: flags
        type: u1
      - id: tag
        type: u4
      - id: auth_code
        type: u4
      - id: path_hashes
        type: u1
        repeat: expr
        repeat-expr: num_path
      - id: path_snrs_raw
        type: snr_item
        repeat: expr
        repeat-expr: num_path
      - id: final_snr_raw
        type: s1
    instances:
      final_snr:
        value: final_snr_raw / 4.0
  new_advert:
    seq:
      - id: pub_key
        size: 32
      - id: node_type
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
        size: 32
        terminator: 0
      - id: last_advert_timestamp
        type: u4
      - id: latitude_microdegrees
        type: u4
      - id: longitude_microdegrees
        type: u4
      - id: lastmod
        type: u4
    instances:
      latitude:
        value: latitude_microdegrees / 1000000.0
      longitude:
        value: longitude_microdegrees / 1000000.0
  telemetry_response:
    seq:
      - id: reserved
        type: u1
      - id: pub_key_prefix
        size: 6
      - id: data
        size-eos: true
  binary_response:
    seq:
      - id: reserved
        type: u1
      - id: tag
        type: u4
      - id: data
        size-eos: true
  path_discovery_response:
    seq:
      - id: reserved
        type: u1
      - id: pub_key_prefix
        size: 6
      - id: num_out_path
        type: u1
      - id: out_path
        type: u1
        repeat: expr
        repeat-expr: num_out_path
      - id: num_in_path
        type: u1
      - id: in_path
        type: u1
        repeat: expr
        repeat-expr: num_in_path
seq:
  - id: is_push
    type: b1be
  - id: resp_code
    type: b7be
    enum: resp_code
    if: not is_push
  - id: push_code
    type: b7be
    enum: push_code
    if: is_push
  - id: resp_payload
    if: not is_push
    type:
      switch-on: resp_code
      cases:
        resp_code::err: err
        resp_code::contacts_start: contacts_start
        resp_code::contact: contact
        resp_code::end_of_contacts: end_of_contacts
        resp_code::self_info: self_info
        resp_code::contact_msg_recv: contact_msg_recv
        resp_code::channel_msg_recv: channel_msg_recv
        resp_code::curr_time: curr_time
        resp_code::device_info: device_info
        resp_code::private_key: private_key
        resp_code::contact_msg_recv_v3: contact_msg_recv_v3
        resp_code::channel_msg_recv_v3: channel_msg_recv_v3
        resp_code::channel_info: channel_info
  - id: push_payload
    if: is_push
    type:
      switch-on: push_code
      cases:
        push_code::advert: pub_key_payload
        push_code::path_updated: pub_key_payload
        push_code::send_confirmed: send_confirmed
        push_code::raw_data: raw_data
        push_code::login_success: login_success
        push_code::login_fail: login_fail
        push_code::status_response: status_response
        push_code::log_rx_data: log_rx_data
        push_code::trace_data: trace_data
        push_code::new_advert: new_advert
        push_code::telemetry_response: telemetry_response
        push_code::binary_response: binary_response
        push_code::path_discovery_response: path_discovery_response
