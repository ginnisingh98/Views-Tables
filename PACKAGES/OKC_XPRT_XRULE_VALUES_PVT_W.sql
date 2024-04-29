--------------------------------------------------------
--  DDL for Package OKC_XPRT_XRULE_VALUES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_XRULE_VALUES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKCWXXRULVS.pls 120.3 2005/12/14 16:11 arsundar noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy okc_xprt_xrule_values_pvt.sys_var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2500
    );
  procedure rosetta_table_copy_out_p4(t okc_xprt_xrule_values_pvt.sys_var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2500
    );

  procedure rosetta_table_copy_in_p5(t out nocopy okc_xprt_xrule_values_pvt.category_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p5(t okc_xprt_xrule_values_pvt.category_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p6(t out nocopy okc_xprt_xrule_values_pvt.item_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p6(t okc_xprt_xrule_values_pvt.item_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p7(t out nocopy okc_xprt_xrule_values_pvt.constant_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t okc_xprt_xrule_values_pvt.constant_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p9(t out nocopy okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2500
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p9(t okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2500
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy okc_xprt_xrule_values_pvt.udf_var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2500
    );
  procedure rosetta_table_copy_out_p10(t okc_xprt_xrule_values_pvt.udf_var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2500
    );

  procedure rosetta_table_copy_in_p11(t out nocopy okc_xprt_xrule_values_pvt.var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2500
    );
  procedure rosetta_table_copy_out_p11(t okc_xprt_xrule_values_pvt.var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2500
    );

  procedure get_system_variables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_only_doc_variables  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_2500
  );
  procedure get_constant_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_intent  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_line_system_variables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_org_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_2500
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , x_line_count out nocopy  NUMBER
    , x_line_variables_count out nocopy  NUMBER
  );
  procedure get_user_defined_variables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_org_id  NUMBER
    , p_intent  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_2500
  );
  procedure get_document_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_2500
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_2500
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , x_line_count out nocopy  NUMBER
    , x_line_variables_count out nocopy  NUMBER
    , x_intent out nocopy  VARCHAR2
    , x_org_id out nocopy  NUMBER
  );
end okc_xprt_xrule_values_pvt_w;

 

/
