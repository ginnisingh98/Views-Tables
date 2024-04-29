--------------------------------------------------------
--  DDL for Package CN_RULES_DISP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULES_DISP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwruls.pls 115.5 2002/11/25 23:50:28 fting ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_rules_disp_pub.rls_dsp_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t cn_rules_disp_pub.rls_dsp_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure get_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p_ruleset_id  NUMBER
    , p_parent_id  NUMBER
    , p_date  date
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p12_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_rules_count out nocopy  NUMBER
  );
end cn_rules_disp_pub_w;

 

/
