--------------------------------------------------------
--  DDL for Package OZF_TP_UTIL_QUERIES_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TP_UTIL_QUERIES_OA" AUTHID CURRENT_USER as
  /* $Header: ozfatpqs.pls 115.0 2003/11/07 18:45:30 gramanat noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_tp_util_queries.qualifier_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ozf_tp_util_queries.qualifier_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_list_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_obj_id  NUMBER
    , p_obj_type  VARCHAR2
    , p_product_attribute  VARCHAR2
    , p_product_attr_value  VARCHAR2
    , p_fcst_uom  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_price_list_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_VARCHAR2_TABLE_100
    , x_list_price out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ozf_tp_util_queries_oa;

 

/
