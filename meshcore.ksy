meta:
  id: meshcore
  endian: le
enums:
  route_type:
    0x0: transport_flood
    0x1: flood
    0x2: direct
    0x3: transport_direct
  payload_type:
    0x0: req
    0x1: response
    0x2: txt_msg
    0x3: ack
    0x4: advert
    0x5: grp_txt
    0x6: grp_data
    0x7: anon_req
    0x8: path
    0x9: trace
    0xA: multipart
    0xF: raw_custom
  node_type:
    0x1: chat
    0x2: repeater
    0x3: room_server
    0x4: sensor
types:
  header:
    seq:
      - id: payload_version
        type: b2
      - id: payload_type
        type: b4
        enum: payload_type
      - id: route_type
        type: b2
        enum: route_type
  path:
    seq:
      - id: num_nodes
        type: u1
      - id: nodes
        type: u1
        repeat: expr
        repeat-expr: num_nodes
  payload_enc_directed:
    seq:
      - id: dst_hash
        type: u1
      - id: src_hash
        type: u1
      - id: cipher_mac
        type: u2
      - id: ciphertext
        size-eos: true
  payload_ack:
    seq:
      - id: checksum
        type: u4
  advert_appdata_header:
    seq:
      - id: has_location
        type: b1
      - id: has_feat1
        type: b1
      - id: has_feat2
        type: b1
      - id: has_name
        type: b1
      - id: node_type
        type: b4
        enum: node_type
  advert_appdata:
    seq:
      - id: header
        type: advert_appdata_header
      - id: latitude_microdegrees
        if: header.has_location
        type: s4
      - id: longitude_microdegrees
        if: header.has_location
        type: s4
      - id: feat1
        if: header.has_feat1
        type: u2
      - id: feat2
        if: header.has_feat2
        type: u2
      - id: name
        type: str
        encoding: UTF-8
        size-eos: true
    instances:
      latitude:
        value: latitude_microdegrees / 1000000.0
      longitude:
        value: longitude_microdegrees / 1000000.0
  payload_advert:
    seq:
      - id: public_key
        size: 32
      - id: timestamp
        type: u4
      - id: signature
        size: 64
      - id: appdata
        if: not _io.eof
        type: advert_appdata
  grp_data:
    seq:
      - id: channel_hash
        type: u1
      - id: cipher_mac
        type: u2
      - id: ciphertext
        size-eos: true
  anon_req:
    seq:
      - id: dst_hash
        type: u1
      - id: public_key
        size: 32
      - id: cipher_mac
        type: u2
      - id: ciphertext
        size-eos: true
  trace:
    seq:
      - id: trace_tag
        type: u4
      - id: auth_code
        type: u4
      - id: flags
        type: u1
      - id: path
        type: u1
        repeat: eos
  multipart:
    seq:
      - id: remaining
        type: b4
      - id: payload_type
        type: b4
        enum: payload_type
      - id: data
        size-eos: true
  raw_custom:
    seq:
      - id: data
        size-eos: true
seq:
  - id: header
    type: header
  - id: path
    type: path
  - id: payload
    type:
      switch-on: header.payload_type
      cases:
        payload_type::req: payload_enc_directed
        payload_type::response: payload_enc_directed
        payload_type::txt_msg: payload_enc_directed
        payload_type::ack: payload_ack
        payload_type::advert: payload_advert
        payload_type::grp_txt: grp_data
        payload_type::grp_data: grp_data
        payload_type::anon_req: anon_req
        payload_type::path: payload_enc_directed
        payload_type::trace: trace
        payload_type::multipart: multipart
        payload_type::raw_custom: raw_custom
