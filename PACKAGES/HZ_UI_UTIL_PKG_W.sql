--------------------------------------------------------
--  DDL for Package HZ_UI_UTIL_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_UI_UTIL_PKG_W" AUTHID CURRENT_USER as
  /* $Header: ARHPUIJS.pls 115.1 2003/02/25 00:53:52 chsaulit noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy HZ_MIXNM_UTILITY.indexvarchar30list, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t HZ_MIXNM_UTILITY.indexvarchar30list, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p1(t out nocopy HZ_MIXNM_UTILITY.indexvarchar1list, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t HZ_MIXNM_UTILITY.indexvarchar1list, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure check_columns(p_entity_name  VARCHAR2
    , p_data_source  VARCHAR2
    , p_entity_pk1  VARCHAR2
    , p_entity_pk2  VARCHAR2
    , p_party_id  NUMBER
    , p_function_name  VARCHAR2
    , p_attribute_list JTF_VARCHAR2_TABLE_100
    , p_value_is_null_list JTF_VARCHAR2_TABLE_100
    , x_viewable_list out nocopy JTF_VARCHAR2_TABLE_100
    , x_updateable_list out nocopy JTF_VARCHAR2_TABLE_100
  );
end hz_ui_util_pkg_w;

 

/
