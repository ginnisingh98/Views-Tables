--------------------------------------------------------
--  DDL for Package OKL_AM_INVOICES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_INVOICES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEAMIS.pls 120.5 2008/06/16 18:33:37 asahoo ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy okl_am_invoices_pvt.ariv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_am_invoices_pvt.ariv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy okl_am_invoices_pvt.tld_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t okl_am_invoices_pvt.tld_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy okl_am_invoices_pvt.sdd_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t okl_am_invoices_pvt.sdd_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_vendor_billing_info(p_cpl_id  NUMBER
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  NUMBER
    , p1_a2 in out nocopy  VARCHAR2
    , p1_a3 in out nocopy  VARCHAR2
    , p1_a4 in out nocopy  VARCHAR2
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  DATE
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  NUMBER
    , p1_a9 in out nocopy  NUMBER
    , p1_a10 in out nocopy  NUMBER
    , p1_a11 in out nocopy  NUMBER
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  VARCHAR2
    , p1_a15 in out nocopy  NUMBER
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  NUMBER
    , p1_a18 in out nocopy  NUMBER
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  NUMBER
    , p1_a21 in out nocopy  NUMBER
    , p1_a22 in out nocopy  NUMBER
    , p1_a23 in out nocopy  DATE
    , p1_a24 in out nocopy  NUMBER
    , p1_a25 in out nocopy  VARCHAR2
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  NUMBER
    , p1_a28 in out nocopy  NUMBER
    , p1_a29 in out nocopy  NUMBER
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  VARCHAR2
    , p1_a33 in out nocopy  VARCHAR2
    , p1_a34 in out nocopy  VARCHAR2
    , p1_a35 in out nocopy  VARCHAR2
    , p1_a36 in out nocopy  VARCHAR2
    , p1_a37 in out nocopy  VARCHAR2
    , p1_a38 in out nocopy  VARCHAR2
    , p1_a39 in out nocopy  VARCHAR2
    , p1_a40 in out nocopy  VARCHAR2
    , p1_a41 in out nocopy  VARCHAR2
    , p1_a42 in out nocopy  VARCHAR2
    , p1_a43 in out nocopy  VARCHAR2
    , p1_a44 in out nocopy  VARCHAR2
    , p1_a45 in out nocopy  VARCHAR2
    , p1_a46 in out nocopy  DATE
    , p1_a47 in out nocopy  NUMBER
    , p1_a48 in out nocopy  NUMBER
    , p1_a49 in out nocopy  NUMBER
    , p1_a50 in out nocopy  DATE
    , p1_a51 in out nocopy  NUMBER
    , p1_a52 in out nocopy  NUMBER
    , p1_a53 in out nocopy  DATE
    , p1_a54 in out nocopy  NUMBER
    , p1_a55 in out nocopy  DATE
    , p1_a56 in out nocopy  NUMBER
    , p1_a57 in out nocopy  NUMBER
    , p1_a58 in out nocopy  VARCHAR2
    , p1_a59 in out nocopy  VARCHAR2
    , p1_a60 in out nocopy  VARCHAR2
    , p1_a61 in out nocopy  NUMBER
    , p1_a62 in out nocopy  VARCHAR2
    , p1_a63 in out nocopy  DATE
    , p1_a64 in out nocopy  VARCHAR2
    , p1_a65 in out nocopy  NUMBER
    , p1_a66 in out nocopy  NUMBER
    , p1_a67 in out nocopy  NUMBER
    , p1_a68 in out nocopy  NUMBER
    , p1_a69 in out nocopy  VARCHAR2
    , p1_a70 in out nocopy  VARCHAR2
    , p1_a71 in out nocopy  NUMBER
    , p1_a72 in out nocopy  VARCHAR2
    , p1_a73 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
  );
  procedure contract_remaining_sec_dep(p_contract_id  NUMBER
    , p_contract_line_id  NUMBER
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , x_total_amount out nocopy  NUMBER
  );
  procedure create_repair_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a73 out nocopy JTF_DATE_TABLE
  );
  procedure create_remarket_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_order_line_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a73 out nocopy JTF_DATE_TABLE
  );
  procedure create_quote_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_quote_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a73 out nocopy JTF_DATE_TABLE
  );
  procedure create_scrt_dpst_dsps_inv(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_contract_line_id  NUMBER
    , p_dispose_amount  NUMBER
    , p_quote_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a27 out nocopy JTF_NUMBER_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a46 out nocopy JTF_DATE_TABLE
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_DATE_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_NUMBER_TABLE
    , p9_a53 out nocopy JTF_DATE_TABLE
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_DATE_TABLE
    , p9_a56 out nocopy JTF_NUMBER_TABLE
    , p9_a57 out nocopy JTF_NUMBER_TABLE
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_NUMBER_TABLE
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a63 out nocopy JTF_DATE_TABLE
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a65 out nocopy JTF_NUMBER_TABLE
    , p9_a66 out nocopy JTF_NUMBER_TABLE
    , p9_a67 out nocopy JTF_NUMBER_TABLE
    , p9_a68 out nocopy JTF_NUMBER_TABLE
    , p9_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a71 out nocopy JTF_NUMBER_TABLE
    , p9_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a73 out nocopy JTF_DATE_TABLE
  );
end okl_am_invoices_pvt_w;

/
