--------------------------------------------------------
--  DDL for Package OKL_INS_CLAIM_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_CLAIM_ASSET_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLICLAS.pls 115.2 2003/05/26 07:45:30 arajagop noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy okl_ins_claim_asset_pvt.stmid_rec_type_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t okl_ins_claim_asset_pvt.stmid_rec_type_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_lease_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a29 in out nocopy JTF_DATE_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_NUMBER_TABLE
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_DATE_TABLE
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_NUMBER_TABLE
    , p5_a38 in out nocopy JTF_DATE_TABLE
    , p5_a39 in out nocopy JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_DATE_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_NUMBER_TABLE
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_DATE_TABLE
    , p6_a29 in out nocopy JTF_NUMBER_TABLE
    , p6_a30 in out nocopy JTF_DATE_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_DATE_TABLE
    , p6_a33 in out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a14 in out nocopy JTF_NUMBER_TABLE
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_NUMBER_TABLE
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 in out nocopy JTF_DATE_TABLE
    , p7_a19 in out nocopy JTF_DATE_TABLE
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_800
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a33 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a36 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a37 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_DATE_TABLE
    , p7_a43 in out nocopy JTF_NUMBER_TABLE
    , p7_a44 in out nocopy JTF_DATE_TABLE
    , p7_a45 in out nocopy JTF_NUMBER_TABLE
    , p7_a46 in out nocopy JTF_DATE_TABLE
    , p7_a47 in out nocopy JTF_NUMBER_TABLE
    , p7_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a51 in out nocopy JTF_NUMBER_TABLE
    , p7_a52 in out nocopy JTF_DATE_TABLE
  );
  procedure hold_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  );
end okl_ins_claim_asset_pvt_w;

 

/
