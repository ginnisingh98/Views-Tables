--------------------------------------------------------
--  DDL for Package HZ_GEO_UI_UTIL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_UI_UTIL_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ARHGEUJS.pls 120.3 2005/09/28 20:10:37 sroychou noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy hz_geo_ui_util_pub.tax_geo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t hz_geo_ui_util_pub.tax_geo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure update_map_usages(p_map_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_400
    , p1_a2 JTF_VARCHAR2_TABLE_400
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_400
    , p2_a2 JTF_VARCHAR2_TABLE_400
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_show_gnr out nocopy  VARCHAR2
  );
end hz_geo_ui_util_pub_w;

 

/
