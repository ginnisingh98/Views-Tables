--------------------------------------------------------
--  DDL for Package OKL_KLE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_KLE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLIKLES.pls 115.5 2002/12/20 19:17:52 avsingh noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_kle_pvt.kle_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_DATE_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_DATE_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t okl_kle_pvt.kle_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_VARCHAR2_TABLE_500
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_VARCHAR2_TABLE_500
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_500
    , a67 out nocopy JTF_VARCHAR2_TABLE_500
    , a68 out nocopy JTF_VARCHAR2_TABLE_500
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_DATE_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_DATE_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_NUMBER_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy okl_kle_pvt.okl_k_lines_h_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_500
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_DATE_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_DATE_TABLE
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_NUMBER_TABLE
    , a96 JTF_DATE_TABLE
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_kle_pvt.okl_k_lines_h_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_VARCHAR2_TABLE_500
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_VARCHAR2_TABLE_500
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_500
    , a67 out nocopy JTF_VARCHAR2_TABLE_500
    , a68 out nocopy JTF_VARCHAR2_TABLE_500
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_500
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_DATE_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_DATE_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_NUMBER_TABLE
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_NUMBER_TABLE
    , a96 out nocopy JTF_DATE_TABLE
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy okl_kle_pvt.klev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_DATE_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_DATE_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_500
    , a71 JTF_VARCHAR2_TABLE_500
    , a72 JTF_VARCHAR2_TABLE_500
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_500
    , a75 JTF_VARCHAR2_TABLE_500
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_DATE_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_DATE_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t okl_kle_pvt.klev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_DATE_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_VARCHAR2_TABLE_500
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_500
    , a67 out nocopy JTF_VARCHAR2_TABLE_500
    , a68 out nocopy JTF_VARCHAR2_TABLE_500
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_500
    , a71 out nocopy JTF_VARCHAR2_TABLE_500
    , a72 out nocopy JTF_VARCHAR2_TABLE_500
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_500
    , a75 out nocopy JTF_VARCHAR2_TABLE_500
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_NUMBER_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_NUMBER_TABLE
    );

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  VARCHAR2
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
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  DATE
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  NUMBER
    , p6_a83 out nocopy  DATE
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  DATE
    , p6_a86 out nocopy  DATE
    , p6_a87 out nocopy  NUMBER
    , p6_a88 out nocopy  NUMBER
    , p6_a89 out nocopy  NUMBER
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  NUMBER
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  NUMBER
    , p6_a94 out nocopy  NUMBER
    , p6_a95 out nocopy  DATE
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  );
  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a76 out nocopy JTF_NUMBER_TABLE
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_DATE_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_DATE_TABLE
    , p6_a82 out nocopy JTF_NUMBER_TABLE
    , p6_a83 out nocopy JTF_DATE_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_DATE_TABLE
    , p6_a86 out nocopy JTF_DATE_TABLE
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_NUMBER_TABLE
    , p6_a89 out nocopy JTF_NUMBER_TABLE
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_NUMBER_TABLE
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_NUMBER_TABLE
    , p6_a94 out nocopy JTF_NUMBER_TABLE
    , p6_a95 out nocopy JTF_DATE_TABLE
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a98 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  VARCHAR2
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
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  DATE
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  NUMBER
    , p6_a83 out nocopy  DATE
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  DATE
    , p6_a86 out nocopy  DATE
    , p6_a87 out nocopy  NUMBER
    , p6_a88 out nocopy  NUMBER
    , p6_a89 out nocopy  NUMBER
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  NUMBER
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  NUMBER
    , p6_a94 out nocopy  NUMBER
    , p6_a95 out nocopy  DATE
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a76 out nocopy JTF_NUMBER_TABLE
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_DATE_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_DATE_TABLE
    , p6_a82 out nocopy JTF_NUMBER_TABLE
    , p6_a83 out nocopy JTF_DATE_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_DATE_TABLE
    , p6_a86 out nocopy JTF_DATE_TABLE
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_NUMBER_TABLE
    , p6_a89 out nocopy JTF_NUMBER_TABLE
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_NUMBER_TABLE
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_NUMBER_TABLE
    , p6_a94 out nocopy JTF_NUMBER_TABLE
    , p6_a95 out nocopy JTF_DATE_TABLE
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a98 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
  );
end okl_kle_pvt_w;

 

/
