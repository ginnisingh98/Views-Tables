--------------------------------------------------------
--  DDL for Package AS_INTEREST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_PUB_W" AUTHID CURRENT_USER as
  /* $Header: asxwints.pls 115.14 2003/11/06 13:58:31 gbatra ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy as_interest_pub.interest_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
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
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t as_interest_pub.interest_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy as_interest_pub.interest_code_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t as_interest_pub.interest_code_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_interest(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_customer_id  NUMBER
    , p_address_id  NUMBER
    , p_contact_id  NUMBER
    , p_lead_id  NUMBER
    , p_interest_use_code  VARCHAR2
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_return_status out nocopy  VARCHAR2
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_interest_out_id out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p14_a0  VARCHAR2 := fnd_api.g_miss_char
    , p14_a1  VARCHAR2 := fnd_api.g_miss_char
    , p14_a2  VARCHAR2 := fnd_api.g_miss_char
    , p14_a3  VARCHAR2 := fnd_api.g_miss_char
    , p14_a4  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_interest(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_interest_use_code  VARCHAR2
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interest_id out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure delete_interest(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_interest_use_code  VARCHAR2
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
  );
end as_interest_pub_w;

 

/
