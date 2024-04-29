--------------------------------------------------------
--  DDL for Package HZ_PARTY_USG_ASSIGNMENT_PVT_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USG_ASSIGNMENT_PVT_JW" AUTHID CURRENT_USER as
  /* $Header: ARHPUPJS.pls 120.0 2005/05/24 01:29:40 jhuang noship $ */
  procedure assign_party_usage_1(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  DATE := null
    , p2_a3  DATE := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
  );
  procedure update_usg_assignment_2(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_party_usg_assignment_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := null
    , p3_a1  VARCHAR2 := null
    , p3_a2  DATE := null
    , p3_a3  DATE := null
    , p3_a4  VARCHAR2 := null
    , p3_a5  VARCHAR2 := null
    , p3_a6  NUMBER := null
    , p3_a7  VARCHAR2 := null
    , p3_a8  VARCHAR2 := null
    , p3_a9  VARCHAR2 := null
    , p3_a10  VARCHAR2 := null
    , p3_a11  VARCHAR2 := null
    , p3_a12  VARCHAR2 := null
    , p3_a13  VARCHAR2 := null
    , p3_a14  VARCHAR2 := null
    , p3_a15  VARCHAR2 := null
    , p3_a16  VARCHAR2 := null
    , p3_a17  VARCHAR2 := null
    , p3_a18  VARCHAR2 := null
    , p3_a19  VARCHAR2 := null
    , p3_a20  VARCHAR2 := null
    , p3_a21  VARCHAR2 := null
    , p3_a22  VARCHAR2 := null
    , p3_a23  VARCHAR2 := null
    , p3_a24  VARCHAR2 := null
    , p3_a25  VARCHAR2 := null
    , p3_a26  VARCHAR2 := null
    , p3_a27  VARCHAR2 := null
    , p3_a28  VARCHAR2 := null
  );
end hz_party_usg_assignment_pvt_jw;

 

/
