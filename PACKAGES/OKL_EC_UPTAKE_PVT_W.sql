--------------------------------------------------------
--  DDL for Package OKL_EC_UPTAKE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EC_UPTAKE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEECXS.pls 120.7 2006/03/08 11:38:00 ssdeshpa noship $ */
  procedure rosetta_table_copy_in_p18(t out nocopy okl_ec_uptake_pvt.okl_number_table_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p18(t okl_ec_uptake_pvt.okl_number_table_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p19(t out nocopy okl_ec_uptake_pvt.okl_varchar2_table_type, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p19(t okl_ec_uptake_pvt.okl_varchar2_table_type, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p20(t out nocopy okl_ec_uptake_pvt.okl_date_tabe_type, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p20(t okl_ec_uptake_pvt.okl_date_tabe_type, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p22(t out nocopy okl_ec_uptake_pvt.okl_qa_result_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p22(t okl_ec_uptake_pvt.okl_qa_result_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p24(t out nocopy okl_ec_uptake_pvt.okl_lease_rate_set_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p24(t okl_ec_uptake_pvt.okl_lease_rate_set_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p26(t out nocopy okl_ec_uptake_pvt.okl_std_rate_tmpl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p26(t okl_ec_uptake_pvt.okl_std_rate_tmpl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p28(t out nocopy okl_ec_uptake_pvt.okl_prod_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p28(t okl_ec_uptake_pvt.okl_prod_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p30(t out nocopy okl_ec_uptake_pvt.okl_vp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p30(t okl_ec_uptake_pvt.okl_vp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    );

  procedure populate_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a5 out nocopy JTF_DATE_TABLE
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_std_rate_tmpl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_DATE_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p_target_eff_from  DATE
    , p_term  NUMBER
    , p_territory  VARCHAR2
    , p_deal_size  NUMBER
    , p_customer_credit_class  VARCHAR2
    , p_down_payment  NUMBER
    , p_advance_rent  NUMBER
    , p_trade_in_value  NUMBER
    , p_currency_code  VARCHAR2
    , p_item_table JTF_NUMBER_TABLE
    , p_item_categories_table JTF_NUMBER_TABLE
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_DATE_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_std_rate_tmpl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p_target_eff_from  DATE
    , p_term  NUMBER
    , p_territory  VARCHAR2
    , p_deal_size  NUMBER
    , p_customer_credit_class  VARCHAR2
    , p_down_payment  NUMBER
    , p_advance_rent  NUMBER
    , p_trade_in_value  NUMBER
    , p_currency_code  VARCHAR2
    , p_item_table JTF_NUMBER_TABLE
    , p_item_categories_table JTF_NUMBER_TABLE
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p15_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a6 out nocopy JTF_DATE_TABLE
    , p15_a7 out nocopy JTF_DATE_TABLE
    , p15_a8 out nocopy JTF_NUMBER_TABLE
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_vendor_program(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p_target_eff_from  DATE
    , p_term  NUMBER
    , p_territory  VARCHAR2
    , p_deal_size  NUMBER
    , p_customer_credit_class  VARCHAR2
    , p_down_payment  NUMBER
    , p_advance_rent  NUMBER
    , p_trade_in_value  NUMBER
    , p_item_table JTF_NUMBER_TABLE
    , p_item_categories_table JTF_NUMBER_TABLE
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a2 out nocopy JTF_DATE_TABLE
    , p14_a3 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_ec_uptake_pvt_w;

/
