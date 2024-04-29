--------------------------------------------------------
--  DDL for Package OKL_COPY_ASSET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_ASSET_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCALS.pls 115.6 2003/10/16 10:00:03 avsingh noship $ */
  procedure copy_asset_lines(p_api_version  NUMBER
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
    , p_to_cle_id  NUMBER
    , p_to_chr_id  NUMBER
    , p_to_template_yn  VARCHAR2
    , p_copy_reference  VARCHAR2
    , p_copy_line_party_yn  VARCHAR2
    , p_renew_ref_yn  VARCHAR2
    , p_trans_type  VARCHAR2
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a7 out nocopy JTF_NUMBER_TABLE
    , p13_a8 out nocopy JTF_NUMBER_TABLE
    , p13_a9 out nocopy JTF_DATE_TABLE
    , p13_a10 out nocopy JTF_NUMBER_TABLE
    , p13_a11 out nocopy JTF_NUMBER_TABLE
    , p13_a12 out nocopy JTF_NUMBER_TABLE
    , p13_a13 out nocopy JTF_NUMBER_TABLE
    , p13_a14 out nocopy JTF_NUMBER_TABLE
    , p13_a15 out nocopy JTF_NUMBER_TABLE
    , p13_a16 out nocopy JTF_NUMBER_TABLE
    , p13_a17 out nocopy JTF_NUMBER_TABLE
    , p13_a18 out nocopy JTF_NUMBER_TABLE
    , p13_a19 out nocopy JTF_NUMBER_TABLE
    , p13_a20 out nocopy JTF_DATE_TABLE
    , p13_a21 out nocopy JTF_DATE_TABLE
    , p13_a22 out nocopy JTF_NUMBER_TABLE
    , p13_a23 out nocopy JTF_NUMBER_TABLE
    , p13_a24 out nocopy JTF_DATE_TABLE
    , p13_a25 out nocopy JTF_DATE_TABLE
    , p13_a26 out nocopy JTF_DATE_TABLE
    , p13_a27 out nocopy JTF_NUMBER_TABLE
    , p13_a28 out nocopy JTF_NUMBER_TABLE
    , p13_a29 out nocopy JTF_NUMBER_TABLE
    , p13_a30 out nocopy JTF_NUMBER_TABLE
    , p13_a31 out nocopy JTF_NUMBER_TABLE
    , p13_a32 out nocopy JTF_NUMBER_TABLE
    , p13_a33 out nocopy JTF_NUMBER_TABLE
    , p13_a34 out nocopy JTF_DATE_TABLE
    , p13_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a36 out nocopy JTF_DATE_TABLE
    , p13_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a38 out nocopy JTF_NUMBER_TABLE
    , p13_a39 out nocopy JTF_NUMBER_TABLE
    , p13_a40 out nocopy JTF_NUMBER_TABLE
    , p13_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a42 out nocopy JTF_DATE_TABLE
    , p13_a43 out nocopy JTF_NUMBER_TABLE
    , p13_a44 out nocopy JTF_NUMBER_TABLE
    , p13_a45 out nocopy JTF_DATE_TABLE
    , p13_a46 out nocopy JTF_NUMBER_TABLE
    , p13_a47 out nocopy JTF_DATE_TABLE
    , p13_a48 out nocopy JTF_DATE_TABLE
    , p13_a49 out nocopy JTF_DATE_TABLE
    , p13_a50 out nocopy JTF_NUMBER_TABLE
    , p13_a51 out nocopy JTF_NUMBER_TABLE
    , p13_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a53 out nocopy JTF_NUMBER_TABLE
    , p13_a54 out nocopy JTF_NUMBER_TABLE
    , p13_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a57 out nocopy JTF_NUMBER_TABLE
    , p13_a58 out nocopy JTF_DATE_TABLE
    , p13_a59 out nocopy JTF_NUMBER_TABLE
    , p13_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a76 out nocopy JTF_NUMBER_TABLE
    , p13_a77 out nocopy JTF_NUMBER_TABLE
    , p13_a78 out nocopy JTF_NUMBER_TABLE
    , p13_a79 out nocopy JTF_DATE_TABLE
    , p13_a80 out nocopy JTF_NUMBER_TABLE
    , p13_a81 out nocopy JTF_DATE_TABLE
    , p13_a82 out nocopy JTF_NUMBER_TABLE
    , p13_a83 out nocopy JTF_DATE_TABLE
    , p13_a84 out nocopy JTF_DATE_TABLE
    , p13_a85 out nocopy JTF_DATE_TABLE
    , p13_a86 out nocopy JTF_DATE_TABLE
    , p13_a87 out nocopy JTF_NUMBER_TABLE
    , p13_a88 out nocopy JTF_NUMBER_TABLE
    , p13_a89 out nocopy JTF_NUMBER_TABLE
    , p13_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a91 out nocopy JTF_NUMBER_TABLE
    , p13_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a93 out nocopy JTF_NUMBER_TABLE
    , p13_a94 out nocopy JTF_NUMBER_TABLE
    , p13_a95 out nocopy JTF_DATE_TABLE
    , p13_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a98 out nocopy JTF_NUMBER_TABLE
  );
  procedure copy_all_lines(p_api_version  NUMBER
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
    , p_to_cle_id  NUMBER
    , p_to_chr_id  NUMBER
    , p_to_template_yn  VARCHAR2
    , p_copy_reference  VARCHAR2
    , p_copy_line_party_yn  VARCHAR2
    , p_renew_ref_yn  VARCHAR2
    , p_trans_type  VARCHAR2
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a7 out nocopy JTF_NUMBER_TABLE
    , p13_a8 out nocopy JTF_NUMBER_TABLE
    , p13_a9 out nocopy JTF_DATE_TABLE
    , p13_a10 out nocopy JTF_NUMBER_TABLE
    , p13_a11 out nocopy JTF_NUMBER_TABLE
    , p13_a12 out nocopy JTF_NUMBER_TABLE
    , p13_a13 out nocopy JTF_NUMBER_TABLE
    , p13_a14 out nocopy JTF_NUMBER_TABLE
    , p13_a15 out nocopy JTF_NUMBER_TABLE
    , p13_a16 out nocopy JTF_NUMBER_TABLE
    , p13_a17 out nocopy JTF_NUMBER_TABLE
    , p13_a18 out nocopy JTF_NUMBER_TABLE
    , p13_a19 out nocopy JTF_NUMBER_TABLE
    , p13_a20 out nocopy JTF_DATE_TABLE
    , p13_a21 out nocopy JTF_DATE_TABLE
    , p13_a22 out nocopy JTF_NUMBER_TABLE
    , p13_a23 out nocopy JTF_NUMBER_TABLE
    , p13_a24 out nocopy JTF_DATE_TABLE
    , p13_a25 out nocopy JTF_DATE_TABLE
    , p13_a26 out nocopy JTF_DATE_TABLE
    , p13_a27 out nocopy JTF_NUMBER_TABLE
    , p13_a28 out nocopy JTF_NUMBER_TABLE
    , p13_a29 out nocopy JTF_NUMBER_TABLE
    , p13_a30 out nocopy JTF_NUMBER_TABLE
    , p13_a31 out nocopy JTF_NUMBER_TABLE
    , p13_a32 out nocopy JTF_NUMBER_TABLE
    , p13_a33 out nocopy JTF_NUMBER_TABLE
    , p13_a34 out nocopy JTF_DATE_TABLE
    , p13_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a36 out nocopy JTF_DATE_TABLE
    , p13_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a38 out nocopy JTF_NUMBER_TABLE
    , p13_a39 out nocopy JTF_NUMBER_TABLE
    , p13_a40 out nocopy JTF_NUMBER_TABLE
    , p13_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a42 out nocopy JTF_DATE_TABLE
    , p13_a43 out nocopy JTF_NUMBER_TABLE
    , p13_a44 out nocopy JTF_NUMBER_TABLE
    , p13_a45 out nocopy JTF_DATE_TABLE
    , p13_a46 out nocopy JTF_NUMBER_TABLE
    , p13_a47 out nocopy JTF_DATE_TABLE
    , p13_a48 out nocopy JTF_DATE_TABLE
    , p13_a49 out nocopy JTF_DATE_TABLE
    , p13_a50 out nocopy JTF_NUMBER_TABLE
    , p13_a51 out nocopy JTF_NUMBER_TABLE
    , p13_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a53 out nocopy JTF_NUMBER_TABLE
    , p13_a54 out nocopy JTF_NUMBER_TABLE
    , p13_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a57 out nocopy JTF_NUMBER_TABLE
    , p13_a58 out nocopy JTF_DATE_TABLE
    , p13_a59 out nocopy JTF_NUMBER_TABLE
    , p13_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p13_a76 out nocopy JTF_NUMBER_TABLE
    , p13_a77 out nocopy JTF_NUMBER_TABLE
    , p13_a78 out nocopy JTF_NUMBER_TABLE
    , p13_a79 out nocopy JTF_DATE_TABLE
    , p13_a80 out nocopy JTF_NUMBER_TABLE
    , p13_a81 out nocopy JTF_DATE_TABLE
    , p13_a82 out nocopy JTF_NUMBER_TABLE
    , p13_a83 out nocopy JTF_DATE_TABLE
    , p13_a84 out nocopy JTF_DATE_TABLE
    , p13_a85 out nocopy JTF_DATE_TABLE
    , p13_a86 out nocopy JTF_DATE_TABLE
    , p13_a87 out nocopy JTF_NUMBER_TABLE
    , p13_a88 out nocopy JTF_NUMBER_TABLE
    , p13_a89 out nocopy JTF_NUMBER_TABLE
    , p13_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a91 out nocopy JTF_NUMBER_TABLE
    , p13_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a93 out nocopy JTF_NUMBER_TABLE
    , p13_a94 out nocopy JTF_NUMBER_TABLE
    , p13_a95 out nocopy JTF_DATE_TABLE
    , p13_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a98 out nocopy JTF_NUMBER_TABLE
  );
end okl_copy_asset_pub_w;

 

/
