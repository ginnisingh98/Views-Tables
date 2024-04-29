--------------------------------------------------------
--  DDL for Package OKL_AM_CALC_QUOTE_PYMNT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CALC_QUOTE_PYMNT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLECQPS.pls 120.2 2005/10/30 04:05:34 appldev noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_am_calc_quote_pymnt_pvt.pymt_smry_uv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p23(t okl_am_calc_quote_pymnt_pvt.pymt_smry_uv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_payment_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_qte_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , x_pymt_smry_tbl_count out nocopy  NUMBER
    , x_total_curr_amt out nocopy  NUMBER
    , x_total_prop_amt out nocopy  NUMBER
  );
end okl_am_calc_quote_pymnt_pvt_w;

 

/
