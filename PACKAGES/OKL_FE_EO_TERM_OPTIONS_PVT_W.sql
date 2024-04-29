--------------------------------------------------------
--  DDL for Package OKL_FE_EO_TERM_OPTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_EO_TERM_OPTIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEEOTS.pls 120.0 2005/07/07 10:37:29 viselvar noship $ */
  procedure rosetta_table_copy_in_p9(t out nocopy okl_fe_eo_term_options_pvt.invalid_object_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t okl_fe_eo_term_options_pvt.invalid_object_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_item_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_end_of_term_id  NUMBER
    , p_version  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_DATE_TABLE
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_DATE_TABLE
    , p7_a28 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_eo_term_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_end_of_term_id  NUMBER
    , p_version  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_DATE_TABLE
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_DATE_TABLE
    , p7_a25 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_end_of_term_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_eot_id  NUMBER
    , p_version  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  DATE
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  DATE
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_DATE_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_NUMBER_TABLE
  );
  procedure insert_end_of_term_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  DATE
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  DATE
    , p6_a4  DATE
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  DATE
    , p6_a27  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
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
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_DATE_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_500
    , p8_a7 JTF_VARCHAR2_TABLE_500
    , p8_a8 JTF_VARCHAR2_TABLE_500
    , p8_a9 JTF_VARCHAR2_TABLE_500
    , p8_a10 JTF_VARCHAR2_TABLE_500
    , p8_a11 JTF_VARCHAR2_TABLE_500
    , p8_a12 JTF_VARCHAR2_TABLE_500
    , p8_a13 JTF_VARCHAR2_TABLE_500
    , p8_a14 JTF_VARCHAR2_TABLE_500
    , p8_a15 JTF_VARCHAR2_TABLE_500
    , p8_a16 JTF_VARCHAR2_TABLE_500
    , p8_a17 JTF_VARCHAR2_TABLE_500
    , p8_a18 JTF_VARCHAR2_TABLE_500
    , p8_a19 JTF_VARCHAR2_TABLE_500
    , p8_a20 JTF_VARCHAR2_TABLE_500
    , p8_a21 JTF_NUMBER_TABLE
    , p8_a22 JTF_DATE_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_NUMBER_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  NUMBER
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  DATE
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  DATE
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  DATE
    , p9_a33 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  DATE
    , p10_a4 out nocopy  DATE
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  NUMBER
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  NUMBER
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_NUMBER_TABLE
    , p11_a25 out nocopy JTF_DATE_TABLE
    , p11_a26 out nocopy JTF_NUMBER_TABLE
    , p11_a27 out nocopy JTF_DATE_TABLE
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a21 out nocopy JTF_NUMBER_TABLE
    , p12_a22 out nocopy JTF_DATE_TABLE
    , p12_a23 out nocopy JTF_NUMBER_TABLE
    , p12_a24 out nocopy JTF_DATE_TABLE
    , p12_a25 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_end_of_term_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
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
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_DATE_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_DATE_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_NUMBER_TABLE
  );
  procedure create_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
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
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_DATE_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_DATE_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_NUMBER_TABLE
  );
  procedure invalid_objects(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_version_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure calculate_start_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , x_cal_eff_from out nocopy  DATE
  );
end okl_fe_eo_term_options_pvt_w;

 

/
