--------------------------------------------------------
--  DDL for Package HZ_MIXNM_WEBUI_UTILITY_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_WEBUI_UTILITY_JW" AUTHID CURRENT_USER as
  /* $Header: ARHXWUJS.pls 120.2 2005/06/18 04:28:30 jhuang noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy hz_mixnm_webui_utility.idlist, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t hz_mixnm_webui_utility.idlist, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out nocopy hz_mixnm_webui_utility.varcharlist, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t hz_mixnm_webui_utility.varcharlist, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure create_rule_1(p_rule_type  VARCHAR2
    , p_rule_id in out nocopy  NUMBER
    , p_rule_name  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_flag_tab JTF_VARCHAR2_TABLE_100
    , p_os_tab JTF_VARCHAR2_TABLE_100
  );
  procedure update_rule_2(p_rule_type  VARCHAR2
    , p_rule_id  NUMBER
    , p_rule_name  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_flag_tab JTF_VARCHAR2_TABLE_100
    , p_os_tab JTF_VARCHAR2_TABLE_100
  );
  procedure update_thirdpartyrule_3(p_rule_exists  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_flag_tab JTF_VARCHAR2_TABLE_100
    , p_os_tab JTF_VARCHAR2_TABLE_100
  );
  procedure set_datasources_4(p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_range_tab JTF_NUMBER_TABLE
    , p_data_sources_tab JTF_VARCHAR2_TABLE_100
    , p_ranking_tab JTF_NUMBER_TABLE
  );
  procedure get_datasourcesforagroup_5(p_entity_type  VARCHAR2
    , p_entity_attr_id_tab JTF_NUMBER_TABLE
    , x_has_same_setup out nocopy  VARCHAR2
    , x_data_sources_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_meaning_tab out nocopy JTF_VARCHAR2_TABLE_100
    , x_ranking_tab out nocopy JTF_NUMBER_TABLE
  );
  procedure set_datasourcesforagroup_6(p_entity_attr_id_tab JTF_NUMBER_TABLE
    , p_attribute_group_name_tab JTF_VARCHAR2_TABLE_100
    , p_data_sources_tab JTF_VARCHAR2_TABLE_100
    , p_ranking_tab JTF_NUMBER_TABLE
  );
end hz_mixnm_webui_utility_jw;

 

/
