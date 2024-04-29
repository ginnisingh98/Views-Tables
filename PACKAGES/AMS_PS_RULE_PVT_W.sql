--------------------------------------------------------
--  DDL for Package AMS_PS_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PS_RULE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswruls.pls 120.0 2005/05/31 14:00:18 appldev noship $ */
  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_ps_rule_pvt.ps_rules_tuple_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ams_ps_rule_pvt.ps_rules_tuple_tbl_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t OUT NOCOPY ams_ps_rule_pvt.ps_rules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t ams_ps_rule_pvt.ps_rules_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_NUMBER_TABLE
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a27 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    );

  procedure create_ps_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , x_rule_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_ps_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_ps_rule_alt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p_vistype_change  number
    , p_rem_change  number
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure delete_ps_rule_alt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_object_version_number  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_ps_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_ps_rules_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_filters(p_rulegroup_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY  VARCHAR2
  );
  procedure update_strategy_params(p_rulegroup_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY  VARCHAR2
  );
  procedure validate_ps_rules_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
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
  );
end ams_ps_rule_pvt_w;

 

/
