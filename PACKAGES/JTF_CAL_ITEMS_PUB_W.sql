--------------------------------------------------------
--  DDL for Package JTF_CAL_ITEMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_ITEMS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfcwits.pls 120.2 2006/04/28 00:14 deeprao ship $ */
  procedure createitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  DATE
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  DATE
    , p6_a14  NUMBER
    , p6_a15  DATE
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , x_cal_item_id out nocopy  NUMBER
  );
  procedure updateitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  NUMBER
    , p7_a15  DATE
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , x_object_version_number out nocopy  NUMBER
  );
end jtf_cal_items_pub_w;

 

/
