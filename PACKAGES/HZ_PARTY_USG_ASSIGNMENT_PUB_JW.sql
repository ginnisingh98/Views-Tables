--------------------------------------------------------
--  DDL for Package HZ_PARTY_USG_ASSIGNMENT_PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USG_ASSIGNMENT_PUB_JW" AUTHID CURRENT_USER as
  /* $Header: ARHPUSJS.pls 120.0 2005/05/24 01:36:00 jhuang noship $ */
  procedure assign_party_usage_1(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  DATE := null
    , p1_a3  DATE := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
  );
  procedure update_usg_assignment_2(p_init_msg_list  VARCHAR2
    , p_party_usg_assignment_id  NUMBER
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
end hz_party_usg_assignment_pub_jw;

 

/
