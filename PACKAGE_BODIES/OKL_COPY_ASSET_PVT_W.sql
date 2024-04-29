--------------------------------------------------------
--  DDL for Package Body OKL_COPY_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_ASSET_PVT_W" as
  /* $Header: OKLECALB.pls 115.7 2003/10/16 09:58:00 avsingh noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

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
  )

  as
    ddp_from_cle_id_tbl okl_copy_asset_pvt.klev_tbl_type;
    ddx_cle_id_tbl okl_copy_asset_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_from_cle_id_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );









    -- here's the delegated call to the old PL/SQL routine
    okl_copy_asset_pvt.copy_asset_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_from_cle_id_tbl,
      p_to_cle_id,
      p_to_chr_id,
      p_to_template_yn,
      p_copy_reference,
      p_copy_line_party_yn,
      p_renew_ref_yn,
      p_trans_type,
      ddx_cle_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_cle_id_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      , p13_a24
      , p13_a25
      , p13_a26
      , p13_a27
      , p13_a28
      , p13_a29
      , p13_a30
      , p13_a31
      , p13_a32
      , p13_a33
      , p13_a34
      , p13_a35
      , p13_a36
      , p13_a37
      , p13_a38
      , p13_a39
      , p13_a40
      , p13_a41
      , p13_a42
      , p13_a43
      , p13_a44
      , p13_a45
      , p13_a46
      , p13_a47
      , p13_a48
      , p13_a49
      , p13_a50
      , p13_a51
      , p13_a52
      , p13_a53
      , p13_a54
      , p13_a55
      , p13_a56
      , p13_a57
      , p13_a58
      , p13_a59
      , p13_a60
      , p13_a61
      , p13_a62
      , p13_a63
      , p13_a64
      , p13_a65
      , p13_a66
      , p13_a67
      , p13_a68
      , p13_a69
      , p13_a70
      , p13_a71
      , p13_a72
      , p13_a73
      , p13_a74
      , p13_a75
      , p13_a76
      , p13_a77
      , p13_a78
      , p13_a79
      , p13_a80
      , p13_a81
      , p13_a82
      , p13_a83
      , p13_a84
      , p13_a85
      , p13_a86
      , p13_a87
      , p13_a88
      , p13_a89
      , p13_a90
      , p13_a91
      , p13_a92
      , p13_a93
      , p13_a94
      , p13_a95
      , p13_a96
      , p13_a97
      , p13_a98
      );
  end;

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
  )

  as
    ddp_from_cle_id_tbl okl_copy_asset_pvt.klev_tbl_type;
    ddx_cle_id_tbl okl_copy_asset_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_from_cle_id_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );









    -- here's the delegated call to the old PL/SQL routine
    okl_copy_asset_pvt.copy_all_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_from_cle_id_tbl,
      p_to_cle_id,
      p_to_chr_id,
      p_to_template_yn,
      p_copy_reference,
      p_copy_line_party_yn,
      p_renew_ref_yn,
      p_trans_type,
      ddx_cle_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_cle_id_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      , p13_a24
      , p13_a25
      , p13_a26
      , p13_a27
      , p13_a28
      , p13_a29
      , p13_a30
      , p13_a31
      , p13_a32
      , p13_a33
      , p13_a34
      , p13_a35
      , p13_a36
      , p13_a37
      , p13_a38
      , p13_a39
      , p13_a40
      , p13_a41
      , p13_a42
      , p13_a43
      , p13_a44
      , p13_a45
      , p13_a46
      , p13_a47
      , p13_a48
      , p13_a49
      , p13_a50
      , p13_a51
      , p13_a52
      , p13_a53
      , p13_a54
      , p13_a55
      , p13_a56
      , p13_a57
      , p13_a58
      , p13_a59
      , p13_a60
      , p13_a61
      , p13_a62
      , p13_a63
      , p13_a64
      , p13_a65
      , p13_a66
      , p13_a67
      , p13_a68
      , p13_a69
      , p13_a70
      , p13_a71
      , p13_a72
      , p13_a73
      , p13_a74
      , p13_a75
      , p13_a76
      , p13_a77
      , p13_a78
      , p13_a79
      , p13_a80
      , p13_a81
      , p13_a82
      , p13_a83
      , p13_a84
      , p13_a85
      , p13_a86
      , p13_a87
      , p13_a88
      , p13_a89
      , p13_a90
      , p13_a91
      , p13_a92
      , p13_a93
      , p13_a94
      , p13_a95
      , p13_a96
      , p13_a97
      , p13_a98
      );
  end;

end okl_copy_asset_pvt_w;

/
