--------------------------------------------------------
--  DDL for Package OKL_MASS_REBOOK_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MASS_REBOOK_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEMRPS.pls 120.3 2007/07/11 16:52:29 ssdeshpa ship $ */
  procedure rosetta_table_copy_in_p31(t out nocopy okl_mass_rebook_pvt.crit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p31(t okl_mass_rebook_pvt.crit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p33(t out nocopy okl_mass_rebook_pvt.rbk_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_600
    );
  procedure rosetta_table_copy_out_p33(t okl_mass_rebook_pvt.rbk_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_600
    );

  procedure rosetta_table_copy_in_p35(t out nocopy okl_mass_rebook_pvt.strm_lalevl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p35(t okl_mass_rebook_pvt.strm_lalevl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p37(t out nocopy okl_mass_rebook_pvt.strm_trx_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p37(t okl_mass_rebook_pvt.strm_trx_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p39(t out nocopy okl_mass_rebook_pvt.kle_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p39(t okl_mass_rebook_pvt.kle_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure build_and_get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_name  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_600
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_600
    , p6_a7 JTF_VARCHAR2_TABLE_600
    , p6_a8 JTF_VARCHAR2_TABLE_600
    , p6_a9 JTF_VARCHAR2_TABLE_2000
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_DATE_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_DATE_TABLE
    , x_rbk_count out nocopy  NUMBER
  );
  procedure build_and_get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_name  VARCHAR2
    , p_transaction_date  date
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_600
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_600
    , p7_a7 JTF_VARCHAR2_TABLE_600
    , p7_a8 JTF_VARCHAR2_TABLE_600
    , p7_a9 JTF_VARCHAR2_TABLE_2000
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_DATE_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_DATE_TABLE
    , x_rbk_count out nocopy  NUMBER
  );
  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
  );
  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
  );
  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p_transaction_date  date
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
  );
  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , x_mass_rebook_trx_id out nocopy  NUMBER
  );
  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , p_transaction_date  date
    , x_mass_rebook_trx_id out nocopy  NUMBER
  );
  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , p_transaction_date  date
    , x_mass_rebook_trx_id out nocopy  NUMBER
    , p_ppd_amount  NUMBER
    , p_ppd_reason_code  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_500
    , p13_a3 JTF_VARCHAR2_TABLE_500
    , p13_a4 JTF_VARCHAR2_TABLE_500
    , p13_a5 JTF_VARCHAR2_TABLE_500
    , p13_a6 JTF_VARCHAR2_TABLE_500
    , p13_a7 JTF_VARCHAR2_TABLE_500
    , p13_a8 JTF_VARCHAR2_TABLE_500
    , p13_a9 JTF_VARCHAR2_TABLE_500
    , p13_a10 JTF_VARCHAR2_TABLE_500
    , p13_a11 JTF_VARCHAR2_TABLE_500
    , p13_a12 JTF_VARCHAR2_TABLE_500
    , p13_a13 JTF_VARCHAR2_TABLE_500
    , p13_a14 JTF_VARCHAR2_TABLE_500
    , p13_a15 JTF_VARCHAR2_TABLE_500
    , p13_a16 JTF_VARCHAR2_TABLE_500
    , p13_a17 JTF_VARCHAR2_TABLE_100
    , p13_a18 JTF_VARCHAR2_TABLE_100
    , p13_a19 JTF_VARCHAR2_TABLE_200
    , p13_a20 JTF_VARCHAR2_TABLE_100
    , p13_a21 JTF_VARCHAR2_TABLE_200
    , p13_a22 JTF_VARCHAR2_TABLE_100
    , p13_a23 JTF_VARCHAR2_TABLE_200
    , p13_a24 JTF_VARCHAR2_TABLE_100
    , p13_a25 JTF_VARCHAR2_TABLE_100
    , p13_a26 JTF_VARCHAR2_TABLE_100
  );
  procedure update_mass_rbk_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
  );
  procedure create_mass_rbk_set_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_name  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_600
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_600
    , p6_a7 JTF_VARCHAR2_TABLE_600
    , p6_a8 JTF_VARCHAR2_TABLE_600
    , p6_a9 JTF_VARCHAR2_TABLE_2000
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_DATE_TABLE
    , p7_a31 out nocopy JTF_NUMBER_TABLE
  );
end okl_mass_rebook_pvt_w;

/
