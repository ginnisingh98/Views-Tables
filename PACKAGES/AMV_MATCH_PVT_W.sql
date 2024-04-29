--------------------------------------------------------
--  DDL for Package AMV_MATCH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_MATCH_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amvwmats.pls 120.2 2005/06/30 08:06 appldev ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy amv_match_pvt.terr_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p3(t amv_match_pvt.terr_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p4(t out nocopy amv_match_pvt.terr_name_tbl_type, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p4(t amv_match_pvt.terr_name_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000);

  procedure do_itemchannelmatch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_category_id  NUMBER
    , p_channel_id  NUMBER
    , p_item_id  NUMBER
    , p_table_name_code  VARCHAR2
    , p_match_type  VARCHAR2
    , p_territory_tbl JTF_NUMBER_TABLE
  );
  procedure get_userterritory(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , x_terr_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_terr_name_tbl out nocopy JTF_VARCHAR2_TABLE_4000
  );
  procedure get_publishedterritories(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_terr_id  NUMBER
    , p_table_name_code  VARCHAR2
    , x_item_id_tbl out nocopy JTF_NUMBER_TABLE
  );
end amv_match_pvt_w;

 

/
