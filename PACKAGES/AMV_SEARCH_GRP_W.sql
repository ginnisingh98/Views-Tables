--------------------------------------------------------
--  DDL for Package AMV_SEARCH_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_SEARCH_GRP_W" AUTHID CURRENT_USER as
  /* $Header: amvwsrgs.pls 120.2 2005/06/30 08:44 appldev ship $ */
  procedure find_repositories(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_object_version_number  NUMBER
    , p_repository_id  NUMBER
    , p_repository_code  VARCHAR2
    , p_repository_name  VARCHAR2
    , p_status  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_NUMBER_TABLE
  );
  procedure find_repository_areas(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
  );
  procedure content_search(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_area_array JTF_VARCHAR2_TABLE_4000
    , p_content_array JTF_VARCHAR2_TABLE_4000
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_400
    , p_imt_string  VARCHAR2
    , p_days  NUMBER
    , p_user_id  NUMBER
    , p_category_id JTF_NUMBER_TABLE
    , p_include_subcats  VARCHAR2
    , p_external_contents  VARCHAR2
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  NUMBER
    , p18_a2 out nocopy  NUMBER
    , p19_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p19_a3 out nocopy JTF_NUMBER_TABLE
    , p19_a4 out nocopy JTF_NUMBER_TABLE
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p17_a0  NUMBER := 0-1962.0724
    , p17_a1  NUMBER := 0-1962.0724
    , p17_a2  VARCHAR2 := fnd_api.g_miss_char
  );
end amv_search_grp_w;

 

/
