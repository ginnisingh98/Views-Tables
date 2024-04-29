--------------------------------------------------------
--  DDL for Package AML_TIMEFRAME_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_TIMEFRAME_PUB_W" AUTHID CURRENT_USER as
  /* $Header: amlwtfrs.pls 115.1 2003/01/03 18:44:44 chchandr noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy aml_timeframe_pub.timeframe_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t aml_timeframe_pub.timeframe_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_timeframe(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_timeframe_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  DATE := fnd_api.g_miss_date
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_timeframe(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  DATE := fnd_api.g_miss_date
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure delete_timeframe(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  DATE := fnd_api.g_miss_date
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
  );
end aml_timeframe_pub_w;

 

/
