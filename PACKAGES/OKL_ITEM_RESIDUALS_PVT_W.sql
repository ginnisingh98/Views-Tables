--------------------------------------------------------
--  DDL for Package OKL_ITEM_RESIDUALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ITEM_RESIDUALS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEIRSS.pls 120.2 2005/07/22 10:09:19 smadhava noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy okl_item_residuals_pvt.lrs_ref_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_item_residuals_pvt.lrs_ref_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_irs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
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
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  );
  procedure update_version_irs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
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
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  );
  procedure create_version_irs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
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
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  );
  procedure change_lrs_sts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_confirm_yn  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , x_change_sts out nocopy  VARCHAR2
  );
  procedure remove_terms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  );
  procedure create_irs_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
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
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  );
  procedure update_version_irs_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
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
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  );
  procedure create_version_irs_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
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
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  );
end okl_item_residuals_pvt_w;

 

/
