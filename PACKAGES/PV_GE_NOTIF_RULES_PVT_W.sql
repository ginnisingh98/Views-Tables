--------------------------------------------------------
--  DDL for Package PV_GE_NOTIF_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_NOTIF_RULES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwgnrs.pls 115.2 2002/11/21 08:55:17 anubhavk ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_ge_notif_rules_pvt.ge_notif_rules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_4000
    , a21 JTF_VARCHAR2_TABLE_4000
    , a22 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p2(t pv_ge_notif_rules_pvt.ge_notif_rules_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , a22 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure create_ge_notif_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_notif_rule_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_ge_notif_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_ge_notif_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  DATE := fnd_api.g_miss_date
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  DATE := fnd_api.g_miss_date
    , p3_a19  NUMBER := 0-1962.0724
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_ge_notif_rules_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_ge_notif_rules_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
  );
end pv_ge_notif_rules_pvt_w;

 

/