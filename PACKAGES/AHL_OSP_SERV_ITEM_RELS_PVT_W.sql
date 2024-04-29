--------------------------------------------------------
--  DDL for Package AHL_OSP_SERV_ITEM_RELS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_SERV_ITEM_RELS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWOSRS.pls 120.0 2005/07/06 15:53:57 jeli noship $ */
  procedure process_serv_itm_rels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  DATE
    , p5_a10 in out nocopy  DATE
    , p5_a11 in out nocopy  VARCHAR
    , p5_a12 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_osp_serv_item_rels_pvt_w;

 

/
