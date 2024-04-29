--------------------------------------------------------
--  DDL for Package INV_TRANSACTION_FLOW_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTION_FLOW_PUB_W" AUTHID CURRENT_USER as
  /* $Header: INVWICTS.pls 115.1 2003/12/18 16:12:23 sthamman noship $ */
  procedure rosetta_table_copy_in_p9(t out nocopy inv_transaction_flow_pub.g_transaction_flow_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p9(t inv_transaction_flow_pub.g_transaction_flow_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy inv_transaction_flow_pub.number_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p10(t inv_transaction_flow_pub.number_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p11(t out nocopy inv_transaction_flow_pub.varchar2_tbl, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p11(t inv_transaction_flow_pub.varchar2_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure get_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_DATE_TABLE
    , p3_a12 out nocopy JTF_DATE_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_NUMBER_TABLE
    , p3_a22 out nocopy JTF_NUMBER_TABLE
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_start_operating_unit  NUMBER
    , p_end_operating_unit  NUMBER
    , p_flow_type  NUMBER
    , p_organization_id  NUMBER
    , p_qualifier_code_tbl JTF_NUMBER_TABLE
    , p_qualifier_value_tbl JTF_NUMBER_TABLE
    , p_transaction_date  DATE
    , p_get_default_cost_group  VARCHAR2
  );
  procedure get_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_DATE_TABLE
    , p3_a12 out nocopy JTF_DATE_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_NUMBER_TABLE
    , p3_a22 out nocopy JTF_NUMBER_TABLE
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_header_id  NUMBER
    , p_get_default_cost_group  VARCHAR2
  );
  procedure check_transaction_flow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_start_operating_unit  NUMBER
    , p_end_operating_unit  NUMBER
    , p_flow_type  NUMBER
    , p_organization_id  NUMBER
    , p_qualifier_code_tbl JTF_NUMBER_TABLE
    , p_qualifier_value_tbl JTF_NUMBER_TABLE
    , p_transaction_date  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_header_id out nocopy  NUMBER
    , x_new_accounting_flag out nocopy  VARCHAR2
    , x_transaction_flow_exists out nocopy  VARCHAR2
  );
  procedure create_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_header_id out nocopy  NUMBER
    , x_line_number_tbl out nocopy JTF_NUMBER_TABLE
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_org_id  NUMBER
    , p_end_org_id  NUMBER
    , p_flow_type  NUMBER
    , p_organization_id  NUMBER
    , p_qualifier_code  NUMBER
    , p_qualifier_value_id  NUMBER
    , p_asset_item_pricing_option  NUMBER
    , p_expense_item_pricing_option  NUMBER
    , p_new_accounting_flag  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_line_number_tbl JTF_NUMBER_TABLE
    , p_from_org_id_tbl JTF_NUMBER_TABLE
    , p_from_organization_id_tbl JTF_NUMBER_TABLE
    , p_to_org_id_tbl JTF_NUMBER_TABLE
    , p_to_organization_id_tbl JTF_NUMBER_TABLE
    , p_line_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_ship_organization_id_tbl JTF_NUMBER_TABLE
    , p_sell_organization_id_tbl JTF_NUMBER_TABLE
    , p_vendor_id_tbl JTF_NUMBER_TABLE
    , p_vendor_site_id_tbl JTF_NUMBER_TABLE
    , p_customer_id_tbl JTF_NUMBER_TABLE
    , p_address_id_tbl JTF_NUMBER_TABLE
    , p_customer_site_id_tbl JTF_NUMBER_TABLE
    , p_cust_trx_type_id_tbl JTF_NUMBER_TABLE
    , p_ic_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_revalue_average_flag_tbl JTF_VARCHAR2_TABLE_200
    , p_freight_code_comb_id_tbl JTF_NUMBER_TABLE
    , p_inv_currency_code_tbl JTF_NUMBER_TABLE
    , p_ic_cogs_acct_id_tbl JTF_NUMBER_TABLE
    , p_inv_accrual_acct_id_tbl JTF_NUMBER_TABLE
    , p_exp_accrual_acct_id_tbl JTF_NUMBER_TABLE
  );
  procedure update_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_header_id  NUMBER
    , p_flow_type  NUMBER
    , p_start_date  DATE
    , p_end_date  DATE
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_line_number_tbl JTF_NUMBER_TABLE
    , p_line_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_ship_organization_id_tbl JTF_NUMBER_TABLE
    , p_sell_organization_id_tbl JTF_NUMBER_TABLE
    , p_vendor_id_tbl JTF_NUMBER_TABLE
    , p_vendor_site_id_tbl JTF_NUMBER_TABLE
    , p_customer_id_tbl JTF_NUMBER_TABLE
    , p_address_id_tbl JTF_NUMBER_TABLE
    , p_customer_site_id_tbl JTF_NUMBER_TABLE
    , p_cust_trx_type_id_tbl JTF_NUMBER_TABLE
    , p_ic_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_revalue_average_flag_tbl JTF_VARCHAR2_TABLE_200
    , p_freight_code_comb_id_tbl JTF_NUMBER_TABLE
    , p_inv_currency_code_tbl JTF_NUMBER_TABLE
    , p_ic_cogs_acct_id_tbl JTF_NUMBER_TABLE
    , p_inv_accrual_acct_id_tbl JTF_NUMBER_TABLE
    , p_exp_accrual_acct_id_tbl JTF_NUMBER_TABLE
  );
end inv_transaction_flow_pub_w;

 

/
