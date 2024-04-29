--------------------------------------------------------
--  DDL for Package OKL_DEAL_CREAT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_CREAT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEDCRS.pls 120.10.12010000.2 2009/06/02 10:33:18 racheruv ship $ */
  procedure rosetta_table_copy_in_p7(t out nocopy okl_deal_creat_pvt.deal_tab_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_500
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_DATE_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_500
    , a86 JTF_VARCHAR2_TABLE_500
    , a87 JTF_VARCHAR2_TABLE_500
    , a88 JTF_VARCHAR2_TABLE_500
    , a89 JTF_VARCHAR2_TABLE_500
    , a90 JTF_VARCHAR2_TABLE_500
    , a91 JTF_VARCHAR2_TABLE_500
    , a92 JTF_VARCHAR2_TABLE_500
    , a93 JTF_VARCHAR2_TABLE_500
    , a94 JTF_VARCHAR2_TABLE_500
    , a95 JTF_VARCHAR2_TABLE_500
    , a96 JTF_VARCHAR2_TABLE_500
    , a97 JTF_VARCHAR2_TABLE_500
    , a98 JTF_VARCHAR2_TABLE_500
    , a99 JTF_VARCHAR2_TABLE_500
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t okl_deal_creat_pvt.deal_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_500
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_500
    , a86 out nocopy JTF_VARCHAR2_TABLE_500
    , a87 out nocopy JTF_VARCHAR2_TABLE_500
    , a88 out nocopy JTF_VARCHAR2_TABLE_500
    , a89 out nocopy JTF_VARCHAR2_TABLE_500
    , a90 out nocopy JTF_VARCHAR2_TABLE_500
    , a91 out nocopy JTF_VARCHAR2_TABLE_500
    , a92 out nocopy JTF_VARCHAR2_TABLE_500
    , a93 out nocopy JTF_VARCHAR2_TABLE_500
    , a94 out nocopy JTF_VARCHAR2_TABLE_500
    , a95 out nocopy JTF_VARCHAR2_TABLE_500
    , a96 out nocopy JTF_VARCHAR2_TABLE_500
    , a97 out nocopy JTF_VARCHAR2_TABLE_500
    , a98 out nocopy JTF_VARCHAR2_TABLE_500
    , a99 out nocopy JTF_VARCHAR2_TABLE_500
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p9(t out nocopy okl_deal_creat_pvt.party_tab_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
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
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p9(t okl_deal_creat_pvt.party_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p11(t out nocopy okl_deal_creat_pvt.deal_values_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_500
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_DATE_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_500
    , a86 JTF_VARCHAR2_TABLE_500
    , a87 JTF_VARCHAR2_TABLE_500
    , a88 JTF_VARCHAR2_TABLE_500
    , a89 JTF_VARCHAR2_TABLE_500
    , a90 JTF_VARCHAR2_TABLE_500
    , a91 JTF_VARCHAR2_TABLE_500
    , a92 JTF_VARCHAR2_TABLE_500
    , a93 JTF_VARCHAR2_TABLE_500
    , a94 JTF_VARCHAR2_TABLE_500
    , a95 JTF_VARCHAR2_TABLE_500
    , a96 JTF_VARCHAR2_TABLE_500
    , a97 JTF_VARCHAR2_TABLE_500
    , a98 JTF_VARCHAR2_TABLE_500
    , a99 JTF_VARCHAR2_TABLE_500
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p11(t okl_deal_creat_pvt.deal_values_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_500
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_500
    , a86 out nocopy JTF_VARCHAR2_TABLE_500
    , a87 out nocopy JTF_VARCHAR2_TABLE_500
    , a88 out nocopy JTF_VARCHAR2_TABLE_500
    , a89 out nocopy JTF_VARCHAR2_TABLE_500
    , a90 out nocopy JTF_VARCHAR2_TABLE_500
    , a91 out nocopy JTF_VARCHAR2_TABLE_500
    , a92 out nocopy JTF_VARCHAR2_TABLE_500
    , a93 out nocopy JTF_VARCHAR2_TABLE_500
    , a94 out nocopy JTF_VARCHAR2_TABLE_500
    , a95 out nocopy JTF_VARCHAR2_TABLE_500
    , a96 out nocopy JTF_VARCHAR2_TABLE_500
    , a97 out nocopy JTF_VARCHAR2_TABLE_500
    , a98 out nocopy JTF_VARCHAR2_TABLE_500
    , a99 out nocopy JTF_VARCHAR2_TABLE_500
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure update_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  DATE
    , p5_a19  DATE
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  NUMBER
    , p5_a52  NUMBER
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  NUMBER
    , p5_a59  VARCHAR2
    , p5_a60  VARCHAR2
    , p5_a61  VARCHAR2
    , p5_a62  VARCHAR2
    , p5_a63  NUMBER
    , p5_a64  NUMBER
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  NUMBER
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  NUMBER
    , p5_a72  NUMBER
    , p5_a73  VARCHAR2
    , p5_a74  VARCHAR2
    , p5_a75  NUMBER
    , p5_a76  NUMBER
    , p5_a77  VARCHAR2
    , p5_a78  VARCHAR2
    , p5_a79  VARCHAR2
    , p5_a80  NUMBER
    , p5_a81  DATE
    , p5_a82  VARCHAR2
    , p5_a83  NUMBER
    , p5_a84  VARCHAR2
    , p5_a85  VARCHAR2
    , p5_a86  VARCHAR2
    , p5_a87  VARCHAR2
    , p5_a88  VARCHAR2
    , p5_a89  VARCHAR2
    , p5_a90  VARCHAR2
    , p5_a91  VARCHAR2
    , p5_a92  VARCHAR2
    , p5_a93  VARCHAR2
    , p5_a94  VARCHAR2
    , p5_a95  VARCHAR2
    , p5_a96  VARCHAR2
    , p5_a97  VARCHAR2
    , p5_a98  VARCHAR2
    , p5_a99  VARCHAR2
    , p5_a100  NUMBER
    , p5_a101  NUMBER
    , p5_a102  VARCHAR2
    , p5_a103  NUMBER
    , p5_a104  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  VARCHAR2
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  VARCHAR2
    , p6_a100 out nocopy  NUMBER
    , p6_a101 out nocopy  NUMBER
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  NUMBER
    , p6_a104 out nocopy  VARCHAR2
  );
  procedure load_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  DATE
    , p5_a19  DATE
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  NUMBER
    , p5_a52  NUMBER
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  NUMBER
    , p5_a59  VARCHAR2
    , p5_a60  VARCHAR2
    , p5_a61  VARCHAR2
    , p5_a62  VARCHAR2
    , p5_a63  NUMBER
    , p5_a64  NUMBER
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  NUMBER
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  NUMBER
    , p5_a72  NUMBER
    , p5_a73  VARCHAR2
    , p5_a74  VARCHAR2
    , p5_a75  NUMBER
    , p5_a76  NUMBER
    , p5_a77  VARCHAR2
    , p5_a78  VARCHAR2
    , p5_a79  VARCHAR2
    , p5_a80  NUMBER
    , p5_a81  DATE
    , p5_a82  VARCHAR2
    , p5_a83  NUMBER
    , p5_a84  VARCHAR2
    , p5_a85  VARCHAR2
    , p5_a86  VARCHAR2
    , p5_a87  VARCHAR2
    , p5_a88  VARCHAR2
    , p5_a89  VARCHAR2
    , p5_a90  VARCHAR2
    , p5_a91  VARCHAR2
    , p5_a92  VARCHAR2
    , p5_a93  VARCHAR2
    , p5_a94  VARCHAR2
    , p5_a95  VARCHAR2
    , p5_a96  VARCHAR2
    , p5_a97  VARCHAR2
    , p5_a98  VARCHAR2
    , p5_a99  VARCHAR2
    , p5_a100  NUMBER
    , p5_a101  NUMBER
    , p5_a102  VARCHAR2
    , p5_a103  NUMBER
    , p5_a104  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  VARCHAR2
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  VARCHAR2
    , p6_a100 out nocopy  NUMBER
    , p6_a101 out nocopy  NUMBER
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  NUMBER
    , p6_a104 out nocopy  VARCHAR2
  );
  procedure create_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
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
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
  );
  procedure update_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
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
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
  );
  procedure load_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  VARCHAR2
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  NUMBER
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  VARCHAR2
    , p6_a100 out nocopy  VARCHAR2
    , p6_a101 out nocopy  VARCHAR2
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  VARCHAR2
    , p6_a104 out nocopy  VARCHAR2
    , p6_a105 out nocopy  VARCHAR2
    , p6_a106 out nocopy  NUMBER
    , p6_a107 out nocopy  VARCHAR2
    , p6_a108 out nocopy  VARCHAR2
    , p6_a109 out nocopy  VARCHAR2
    , p6_a110 out nocopy  VARCHAR2
    , p6_a111 out nocopy  VARCHAR2
    , p6_a112 out nocopy  VARCHAR2
    , p6_a113 out nocopy  VARCHAR2
    , p6_a114 out nocopy  VARCHAR2
    , p6_a115 out nocopy  NUMBER
    , p6_a116 out nocopy  DATE
  );
  procedure load_booking_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
  );
end okl_deal_creat_pvt_w;

/
