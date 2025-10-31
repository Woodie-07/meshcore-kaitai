meta:
  id: companion_common
  bit-endian: le
enums:
  txt_type:
    0: plain
    1: cli_data
    2: signed_plain
  advert_loc_policy:
    0: none
    1: share
types:
  contact_flags:
    seq:
      - id: favourite
        type: b1
      - id: telem_perm_base
        type: b1
      - id: telem_perm_location
        type: b1
      - id: telem_perm_environment
        type: b1
      - id: unused
        type: b4
