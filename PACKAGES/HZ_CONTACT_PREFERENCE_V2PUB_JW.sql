--------------------------------------------------------
--  DDL for Package HZ_CONTACT_PREFERENCE_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_PREFERENCE_V2PUB_JW" AUTHID CURRENT_USER as
  /* $Header: ARH2CTJS.pls 120.2 2005/06/18 04:27:39 jhuang noship $ */
  procedure create_contact_preference_1(p_init_msg_list  VARCHAR2
    , x_contact_preference_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  DATE := null
    , p1_a9  DATE := null
    , p1_a10  NUMBER := null
    , p1_a11  NUMBER := null
    , p1_a12  NUMBER := null
    , p1_a13  NUMBER := null
    , p1_a14  NUMBER := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
  );
  procedure update_contact_preference_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  DATE := null
    , p1_a9  DATE := null
    , p1_a10  NUMBER := null
    , p1_a11  NUMBER := null
    , p1_a12  NUMBER := null
    , p1_a13  NUMBER := null
    , p1_a14  NUMBER := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
  );
  procedure get_contact_preference_rec_3(p_init_msg_list  VARCHAR2
    , p_contact_preference_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  DATE
    , p2_a9 out nocopy  DATE
    , p2_a10 out nocopy  NUMBER
    , p2_a11 out nocopy  NUMBER
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  NUMBER
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end hz_contact_preference_v2pub_jw;

 

/
