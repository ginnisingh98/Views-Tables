--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCOUNT_ROLE_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCOUNT_ROLE_V2PUB_JW" AUTHID CURRENT_USER as
  /* $Header: ARH2CRJS.pls 120.3 2005/06/18 04:27:49 jhuang noship $ */
  procedure create_cust_account_role_1(p_init_msg_list  VARCHAR2
    , x_cust_account_role_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
  );
  procedure update_cust_account_role_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
  );
  procedure get_cust_account_role_rec_3(p_init_msg_list  VARCHAR2
    , p_cust_account_role_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  NUMBER
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_role_responsibility_4(p_init_msg_list  VARCHAR2
    , x_responsibility_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a22  NUMBER := null
  );
  procedure update_role_responsibility_5(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a22  NUMBER := null
  );
  procedure get_role_responsibility_rec_6(p_init_msg_list  VARCHAR2
    , p_responsibility_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end hz_cust_account_role_v2pub_jw;

 

/
