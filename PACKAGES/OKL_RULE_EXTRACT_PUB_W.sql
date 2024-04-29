--------------------------------------------------------
--  DDL for Package OKL_RULE_EXTRACT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RULE_EXTRACT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUREXS.pls 115.7 2003/10/14 18:36:04 ashariff noship $ */
  procedure get_subclass_rgs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_rg_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rgd_code  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_rule_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rgd_code  VARCHAR2
    , p_rgs_code  VARCHAR2
    , p_buy_or_sell  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_rules_metadata(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rgd_code  VARCHAR2
    , p_rgs_code  VARCHAR2
    , p_buy_or_sell  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p_party_id  NUMBER
    , p_template_table  VARCHAR2
    , p_rule_id_column  VARCHAR2
    , p_entity_column  VARCHAR2
    , p14_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_1000
    , p14_a26 out nocopy JTF_VARCHAR2_TABLE_1000
    , p14_a27 out nocopy JTF_VARCHAR2_TABLE_100
  );
end okl_rule_extract_pub_w;

 

/
