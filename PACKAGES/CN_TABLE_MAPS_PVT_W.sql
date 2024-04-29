--------------------------------------------------------
--  DDL for Package CN_TABLE_MAPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TABLE_MAPS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwtmaps.pls 120.2 2005/09/14 03:44 vensrini noship $ */
  procedure create_map(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_name  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  DATE
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  DATE
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  NUMBER
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  NUMBER
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , x_event_id_out out nocopy  NUMBER
  );
end cn_table_maps_pvt_w;

 

/
