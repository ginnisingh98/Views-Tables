--------------------------------------------------------
--  DDL for Package JTF_IH_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PUB_W" AUTHID CURRENT_USER as
  /* $Header: JTFIHJWS.pls 115.32 2003/07/14 17:55:54 ialeshin ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy jtf_ih_pub.activity_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_1000
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t jtf_ih_pub.activity_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_1000
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy jtf_ih_pub.mlcs_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t jtf_ih_pub.mlcs_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_VARCHAR2_TABLE_300
    , p11_a5 JTF_DATE_TABLE
    , p11_a6 JTF_DATE_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_VARCHAR2_TABLE_100
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_NUMBER_TABLE
    , p11_a13 JTF_NUMBER_TABLE
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_1000
    , p11_a18 JTF_NUMBER_TABLE
    , p11_a19 JTF_VARCHAR2_TABLE_300
    , p11_a20 JTF_NUMBER_TABLE
    , p11_a21 JTF_VARCHAR2_TABLE_100
    , p11_a22 JTF_NUMBER_TABLE
    , p11_a23 JTF_VARCHAR2_TABLE_100
    , p11_a24 JTF_NUMBER_TABLE
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_VARCHAR2_TABLE_200
    , p11_a36 JTF_VARCHAR2_TABLE_200
    , p11_a37 JTF_VARCHAR2_TABLE_200
    , p11_a38 JTF_VARCHAR2_TABLE_200
    , p11_a39 JTF_VARCHAR2_TABLE_200
    , p11_a40 JTF_VARCHAR2_TABLE_100
    , p11_a41 JTF_VARCHAR2_TABLE_300
    , p11_a42 JTF_VARCHAR2_TABLE_300
    , p11_a43 JTF_NUMBER_TABLE
    , p11_a44 JTF_NUMBER_TABLE
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  );
  procedure create_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 JTF_DATE_TABLE
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_DATE_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_VARCHAR2_TABLE_100
    , p11_a11 JTF_VARCHAR2_TABLE_300
    , p11_a12 JTF_VARCHAR2_TABLE_300
    , p11_a13 JTF_NUMBER_TABLE
    , p11_a14 JTF_NUMBER_TABLE
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_media_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_medialifecycle(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0  DATE := fnd_api.g_miss_date
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
  );
  procedure open_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  );
  procedure update_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER DEFAULT NULL
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  );
  procedure close_interaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER DEFAULT NULL
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  DATE := fnd_api.g_miss_date
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := 'PARTY'
    , p10_a40  VARCHAR2 := 'RS_EMPLOYEE'
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  NUMBER := 0-1962.0724
    , p10_a45  NUMBER := 0-1962.0724
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  NUMBER := 0-1962.0724
    , p10_a48  NUMBER := 0-1962.0724
  );
  procedure add_activity(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_activity_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  DATE := fnd_api.g_miss_date
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  NUMBER := 0-1962.0724
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  NUMBER := 0-1962.0724
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := fnd_api.g_miss_char
    , p10_a40  VARCHAR2 := fnd_api.g_miss_char
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  NUMBER := 0-1962.0724
    , p10_a44  NUMBER := 0-1962.0724
  );
  procedure update_activity(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER DEFAULT NULL
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  DATE := fnd_api.g_miss_date
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  NUMBER := 0-1962.0724
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  NUMBER := 0-1962.0724
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  NUMBER := 0-1962.0724
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  VARCHAR2 := fnd_api.g_miss_char
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := fnd_api.g_miss_char
    , p10_a40  VARCHAR2 := fnd_api.g_miss_char
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  NUMBER := 0-1962.0724
    , p10_a44  NUMBER := 0-1962.0724
  );
  procedure update_activityduration(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_activity_id  NUMBER
    , p_end_date_time  date
    , p_duration  NUMBER
    , p_object_version  NUMBER DEFAULT NULL
  );
  procedure open_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_media_id out nocopy  NUMBER
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER DEFAULT NULL
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure close_mediaitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER DEFAULT NULL
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  DATE := fnd_api.g_miss_date
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  DATE := fnd_api.g_miss_date
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  NUMBER := 0-1962.0724
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure add_medialifecycle(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_milcs_id out nocopy  NUMBER
    , p10_a0  DATE := fnd_api.g_miss_date
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
  );
  procedure update_medialifecycle(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version  NUMBER DEFAULT NULL
    , p10_a0  DATE := fnd_api.g_miss_date
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  NUMBER := 0-1962.0724
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  NUMBER := 0-1962.0724
  );
end jtf_ih_pub_w;

 

/
