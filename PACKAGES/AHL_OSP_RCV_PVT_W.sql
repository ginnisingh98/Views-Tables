--------------------------------------------------------
--  DDL for Package AHL_OSP_RCV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_RCV_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWORCS.pls 120.0 2008/02/05 16:16:29 mpothuku noship $ */
  procedure receive_against_rma(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  DATE
    , p8_a7  NUMBER
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , x_return_line_id out nocopy  NUMBER
  );
end ahl_osp_rcv_pvt_w;

/
