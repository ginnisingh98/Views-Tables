--------------------------------------------------------
--  DDL for Package JTF_FM_OCM_REND_REQ_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_OCM_REND_REQ_W" AUTHID CURRENT_USER as
  /* $Header: jtfgfmrws.pls 120.1 2005/07/02 00:44:17 appldev noship $ */
  procedure create_fulfillment_rendition(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  NUMBER
    , p5_a16  NUMBER
    , p5_a17  NUMBER
    , p5_a18  VARCHAR2
    , p5_a19  JTF_NUMBER_TABLE
    , p5_a20  JTF_VARCHAR2_TABLE_1000
    , p5_a21  JTF_VARCHAR2_TABLE_1000
    , p5_a22  JTF_VARCHAR2_TABLE_1000
    , p5_a23  JTF_VARCHAR2_TABLE_1000
    , p5_a24  JTF_VARCHAR2_TABLE_1000
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p_request_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  VARCHAR2
    , x_request_history_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
  );
end jtf_fm_ocm_rend_req_w;

 

/
