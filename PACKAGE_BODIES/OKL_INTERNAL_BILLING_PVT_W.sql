--------------------------------------------------------
--  DDL for Package Body OKL_INTERNAL_BILLING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTERNAL_BILLING_PVT_W" as
  /* $Header: OKLEIARB.pls 120.0 2007/07/16 14:37:28 gkhuntet noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure create_billing_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_3000
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_VARCHAR2_TABLE_500
    , p6_a37 JTF_VARCHAR2_TABLE_500
    , p6_a38 JTF_VARCHAR2_TABLE_500
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_DATE_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_NUMBER_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_3000
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_VARCHAR2_TABLE_100
    , p7_a17 JTF_VARCHAR2_TABLE_2000
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_DATE_TABLE
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_VARCHAR2_TABLE_500
    , p7_a28 JTF_VARCHAR2_TABLE_500
    , p7_a29 JTF_VARCHAR2_TABLE_500
    , p7_a30 JTF_VARCHAR2_TABLE_500
    , p7_a31 JTF_VARCHAR2_TABLE_500
    , p7_a32 JTF_VARCHAR2_TABLE_500
    , p7_a33 JTF_VARCHAR2_TABLE_500
    , p7_a34 JTF_VARCHAR2_TABLE_500
    , p7_a35 JTF_VARCHAR2_TABLE_500
    , p7_a36 JTF_VARCHAR2_TABLE_500
    , p7_a37 JTF_VARCHAR2_TABLE_500
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_DATE_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_VARCHAR2_TABLE_200
    , p7_a51 JTF_VARCHAR2_TABLE_200
    , p7_a52 JTF_DATE_TABLE
    , p7_a53 JTF_DATE_TABLE
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_3000
    , p7_a58 JTF_DATE_TABLE
    , p7_a59 JTF_VARCHAR2_TABLE_300
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_100
    , p7_a62 JTF_DATE_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  DATE
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  NUMBER
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  DATE
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  NUMBER
    , p8_a50 out nocopy  DATE
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  NUMBER
    , p8_a53 out nocopy  DATE
    , p8_a54 out nocopy  NUMBER
    , p8_a55 out nocopy  DATE
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  NUMBER
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  NUMBER
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  VARCHAR2
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_DATE_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_NUMBER_TABLE
    , p9_a46 out nocopy JTF_DATE_TABLE
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_DATE_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_DATE_TABLE
    , p9_a53 out nocopy JTF_NUMBER_TABLE
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_DATE_TABLE
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_NUMBER_TABLE
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_DATE_TABLE
    , p10_a42 out nocopy JTF_NUMBER_TABLE
    , p10_a43 out nocopy JTF_NUMBER_TABLE
    , p10_a44 out nocopy JTF_NUMBER_TABLE
    , p10_a45 out nocopy JTF_DATE_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_DATE_TABLE
    , p10_a48 out nocopy JTF_NUMBER_TABLE
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a52 out nocopy JTF_DATE_TABLE
    , p10_a53 out nocopy JTF_DATE_TABLE
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , p10_a58 out nocopy JTF_DATE_TABLE
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a62 out nocopy JTF_DATE_TABLE
    , p10_a63 out nocopy JTF_NUMBER_TABLE
    , p10_a64 out nocopy JTF_NUMBER_TABLE
    , p10_a65 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_taiv_rec okl_tai_pvt.taiv_rec_type;
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddp_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddx_taiv_rec okl_tai_pvt.taiv_rec_type;
    ddx_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddx_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_taiv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_taiv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_taiv_rec.sfwt_flag := p5_a2;
    ddp_taiv_rec.currency_code := p5_a3;
    ddp_taiv_rec.currency_conversion_type := p5_a4;
    ddp_taiv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_taiv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_taiv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_taiv_rec.cra_id := rosetta_g_miss_num_map(p5_a8);
    ddp_taiv_rec.tap_id := rosetta_g_miss_num_map(p5_a9);
    ddp_taiv_rec.qte_id := rosetta_g_miss_num_map(p5_a10);
    ddp_taiv_rec.tcn_id := rosetta_g_miss_num_map(p5_a11);
    ddp_taiv_rec.tai_id_reverses := rosetta_g_miss_num_map(p5_a12);
    ddp_taiv_rec.ipy_id := rosetta_g_miss_num_map(p5_a13);
    ddp_taiv_rec.trx_status_code := p5_a14;
    ddp_taiv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a15);
    ddp_taiv_rec.try_id := rosetta_g_miss_num_map(p5_a16);
    ddp_taiv_rec.ibt_id := rosetta_g_miss_num_map(p5_a17);
    ddp_taiv_rec.ixx_id := rosetta_g_miss_num_map(p5_a18);
    ddp_taiv_rec.irm_id := rosetta_g_miss_num_map(p5_a19);
    ddp_taiv_rec.irt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_taiv_rec.svf_id := rosetta_g_miss_num_map(p5_a21);
    ddp_taiv_rec.amount := rosetta_g_miss_num_map(p5_a22);
    ddp_taiv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a23);
    ddp_taiv_rec.amount_applied := rosetta_g_miss_num_map(p5_a24);
    ddp_taiv_rec.description := p5_a25;
    ddp_taiv_rec.trx_number := p5_a26;
    ddp_taiv_rec.clg_id := rosetta_g_miss_num_map(p5_a27);
    ddp_taiv_rec.pox_id := rosetta_g_miss_num_map(p5_a28);
    ddp_taiv_rec.cpy_id := rosetta_g_miss_num_map(p5_a29);
    ddp_taiv_rec.attribute_category := p5_a30;
    ddp_taiv_rec.attribute1 := p5_a31;
    ddp_taiv_rec.attribute2 := p5_a32;
    ddp_taiv_rec.attribute3 := p5_a33;
    ddp_taiv_rec.attribute4 := p5_a34;
    ddp_taiv_rec.attribute5 := p5_a35;
    ddp_taiv_rec.attribute6 := p5_a36;
    ddp_taiv_rec.attribute7 := p5_a37;
    ddp_taiv_rec.attribute8 := p5_a38;
    ddp_taiv_rec.attribute9 := p5_a39;
    ddp_taiv_rec.attribute10 := p5_a40;
    ddp_taiv_rec.attribute11 := p5_a41;
    ddp_taiv_rec.attribute12 := p5_a42;
    ddp_taiv_rec.attribute13 := p5_a43;
    ddp_taiv_rec.attribute14 := p5_a44;
    ddp_taiv_rec.attribute15 := p5_a45;
    ddp_taiv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a46);
    ddp_taiv_rec.request_id := rosetta_g_miss_num_map(p5_a47);
    ddp_taiv_rec.program_application_id := rosetta_g_miss_num_map(p5_a48);
    ddp_taiv_rec.program_id := rosetta_g_miss_num_map(p5_a49);
    ddp_taiv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_taiv_rec.org_id := rosetta_g_miss_num_map(p5_a51);
    ddp_taiv_rec.created_by := rosetta_g_miss_num_map(p5_a52);
    ddp_taiv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_taiv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a54);
    ddp_taiv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_taiv_rec.last_update_login := rosetta_g_miss_num_map(p5_a56);
    ddp_taiv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a57);
    ddp_taiv_rec.investor_agreement_number := p5_a58;
    ddp_taiv_rec.investor_name := p5_a59;
    ddp_taiv_rec.okl_source_billing_trx := p5_a60;
    ddp_taiv_rec.inf_id := rosetta_g_miss_num_map(p5_a61);
    ddp_taiv_rec.invoice_pull_yn := p5_a62;
    ddp_taiv_rec.due_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_taiv_rec.consolidated_invoice_number := p5_a64;
    ddp_taiv_rec.isi_id := rosetta_g_miss_num_map(p5_a65);
    ddp_taiv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a66);
    ddp_taiv_rec.cust_trx_type_id := rosetta_g_miss_num_map(p5_a67);
    ddp_taiv_rec.customer_bank_account_id := rosetta_g_miss_num_map(p5_a68);
    ddp_taiv_rec.tax_exempt_flag := p5_a69;
    ddp_taiv_rec.tax_exempt_reason_code := p5_a70;
    ddp_taiv_rec.reference_line_id := rosetta_g_miss_num_map(p5_a71);
    ddp_taiv_rec.private_label := p5_a72;

    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      );

    okl_tld_pvt_w.rosetta_table_copy_in_p8(ddp_tldv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_internal_billing_pvt.create_billing_trx(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec,
      ddp_tilv_tbl,
      ddp_tldv_tbl,
      ddx_taiv_rec,
      ddx_tilv_tbl,
      ddx_tldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_taiv_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_taiv_rec.object_version_number);
    p8_a2 := ddx_taiv_rec.sfwt_flag;
    p8_a3 := ddx_taiv_rec.currency_code;
    p8_a4 := ddx_taiv_rec.currency_conversion_type;
    p8_a5 := rosetta_g_miss_num_map(ddx_taiv_rec.currency_conversion_rate);
    p8_a6 := ddx_taiv_rec.currency_conversion_date;
    p8_a7 := rosetta_g_miss_num_map(ddx_taiv_rec.khr_id);
    p8_a8 := rosetta_g_miss_num_map(ddx_taiv_rec.cra_id);
    p8_a9 := rosetta_g_miss_num_map(ddx_taiv_rec.tap_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_taiv_rec.qte_id);
    p8_a11 := rosetta_g_miss_num_map(ddx_taiv_rec.tcn_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_taiv_rec.tai_id_reverses);
    p8_a13 := rosetta_g_miss_num_map(ddx_taiv_rec.ipy_id);
    p8_a14 := ddx_taiv_rec.trx_status_code;
    p8_a15 := rosetta_g_miss_num_map(ddx_taiv_rec.set_of_books_id);
    p8_a16 := rosetta_g_miss_num_map(ddx_taiv_rec.try_id);
    p8_a17 := rosetta_g_miss_num_map(ddx_taiv_rec.ibt_id);
    p8_a18 := rosetta_g_miss_num_map(ddx_taiv_rec.ixx_id);
    p8_a19 := rosetta_g_miss_num_map(ddx_taiv_rec.irm_id);
    p8_a20 := rosetta_g_miss_num_map(ddx_taiv_rec.irt_id);
    p8_a21 := rosetta_g_miss_num_map(ddx_taiv_rec.svf_id);
    p8_a22 := rosetta_g_miss_num_map(ddx_taiv_rec.amount);
    p8_a23 := ddx_taiv_rec.date_invoiced;
    p8_a24 := rosetta_g_miss_num_map(ddx_taiv_rec.amount_applied);
    p8_a25 := ddx_taiv_rec.description;
    p8_a26 := ddx_taiv_rec.trx_number;
    p8_a27 := rosetta_g_miss_num_map(ddx_taiv_rec.clg_id);
    p8_a28 := rosetta_g_miss_num_map(ddx_taiv_rec.pox_id);
    p8_a29 := rosetta_g_miss_num_map(ddx_taiv_rec.cpy_id);
    p8_a30 := ddx_taiv_rec.attribute_category;
    p8_a31 := ddx_taiv_rec.attribute1;
    p8_a32 := ddx_taiv_rec.attribute2;
    p8_a33 := ddx_taiv_rec.attribute3;
    p8_a34 := ddx_taiv_rec.attribute4;
    p8_a35 := ddx_taiv_rec.attribute5;
    p8_a36 := ddx_taiv_rec.attribute6;
    p8_a37 := ddx_taiv_rec.attribute7;
    p8_a38 := ddx_taiv_rec.attribute8;
    p8_a39 := ddx_taiv_rec.attribute9;
    p8_a40 := ddx_taiv_rec.attribute10;
    p8_a41 := ddx_taiv_rec.attribute11;
    p8_a42 := ddx_taiv_rec.attribute12;
    p8_a43 := ddx_taiv_rec.attribute13;
    p8_a44 := ddx_taiv_rec.attribute14;
    p8_a45 := ddx_taiv_rec.attribute15;
    p8_a46 := ddx_taiv_rec.date_entered;
    p8_a47 := rosetta_g_miss_num_map(ddx_taiv_rec.request_id);
    p8_a48 := rosetta_g_miss_num_map(ddx_taiv_rec.program_application_id);
    p8_a49 := rosetta_g_miss_num_map(ddx_taiv_rec.program_id);
    p8_a50 := ddx_taiv_rec.program_update_date;
    p8_a51 := rosetta_g_miss_num_map(ddx_taiv_rec.org_id);
    p8_a52 := rosetta_g_miss_num_map(ddx_taiv_rec.created_by);
    p8_a53 := ddx_taiv_rec.creation_date;
    p8_a54 := rosetta_g_miss_num_map(ddx_taiv_rec.last_updated_by);
    p8_a55 := ddx_taiv_rec.last_update_date;
    p8_a56 := rosetta_g_miss_num_map(ddx_taiv_rec.last_update_login);
    p8_a57 := rosetta_g_miss_num_map(ddx_taiv_rec.legal_entity_id);
    p8_a58 := ddx_taiv_rec.investor_agreement_number;
    p8_a59 := ddx_taiv_rec.investor_name;
    p8_a60 := ddx_taiv_rec.okl_source_billing_trx;
    p8_a61 := rosetta_g_miss_num_map(ddx_taiv_rec.inf_id);
    p8_a62 := ddx_taiv_rec.invoice_pull_yn;
    p8_a63 := ddx_taiv_rec.due_date;
    p8_a64 := ddx_taiv_rec.consolidated_invoice_number;
    p8_a65 := rosetta_g_miss_num_map(ddx_taiv_rec.isi_id);
    p8_a66 := rosetta_g_miss_num_map(ddx_taiv_rec.receivables_invoice_id);
    p8_a67 := rosetta_g_miss_num_map(ddx_taiv_rec.cust_trx_type_id);
    p8_a68 := rosetta_g_miss_num_map(ddx_taiv_rec.customer_bank_account_id);
    p8_a69 := ddx_taiv_rec.tax_exempt_flag;
    p8_a70 := ddx_taiv_rec.tax_exempt_reason_code;
    p8_a71 := rosetta_g_miss_num_map(ddx_taiv_rec.reference_line_id);
    p8_a72 := ddx_taiv_rec.private_label;

    okl_til_pvt_w.rosetta_table_copy_out_p8(ddx_tilv_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      );

    okl_tld_pvt_w.rosetta_table_copy_out_p8(ddx_tldv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      , p10_a56
      , p10_a57
      , p10_a58
      , p10_a59
      , p10_a60
      , p10_a61
      , p10_a62
      , p10_a63
      , p10_a64
      , p10_a65
      );
  end;

  procedure update_manual_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_3000
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_VARCHAR2_TABLE_500
    , p6_a37 JTF_VARCHAR2_TABLE_500
    , p6_a38 JTF_VARCHAR2_TABLE_500
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_DATE_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_NUMBER_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  NUMBER
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  DATE
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  NUMBER
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  DATE
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  NUMBER
    , p7_a53 out nocopy  DATE
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  DATE
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  NUMBER
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  NUMBER
    , p7_a72 out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_DATE_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_DATE_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_DATE_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_DATE_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_DATE_TABLE
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_DATE_TABLE
    , p9_a42 out nocopy JTF_NUMBER_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_DATE_TABLE
    , p9_a46 out nocopy JTF_NUMBER_TABLE
    , p9_a47 out nocopy JTF_DATE_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a52 out nocopy JTF_DATE_TABLE
    , p9_a53 out nocopy JTF_DATE_TABLE
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , p9_a58 out nocopy JTF_DATE_TABLE
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a62 out nocopy JTF_DATE_TABLE
    , p9_a63 out nocopy JTF_NUMBER_TABLE
    , p9_a64 out nocopy JTF_NUMBER_TABLE
    , p9_a65 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_taiv_rec okl_tai_pvt.taiv_rec_type;
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddx_taiv_rec okl_tai_pvt.taiv_rec_type;
    ddx_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddx_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_taiv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_taiv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_taiv_rec.sfwt_flag := p5_a2;
    ddp_taiv_rec.currency_code := p5_a3;
    ddp_taiv_rec.currency_conversion_type := p5_a4;
    ddp_taiv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_taiv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_taiv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_taiv_rec.cra_id := rosetta_g_miss_num_map(p5_a8);
    ddp_taiv_rec.tap_id := rosetta_g_miss_num_map(p5_a9);
    ddp_taiv_rec.qte_id := rosetta_g_miss_num_map(p5_a10);
    ddp_taiv_rec.tcn_id := rosetta_g_miss_num_map(p5_a11);
    ddp_taiv_rec.tai_id_reverses := rosetta_g_miss_num_map(p5_a12);
    ddp_taiv_rec.ipy_id := rosetta_g_miss_num_map(p5_a13);
    ddp_taiv_rec.trx_status_code := p5_a14;
    ddp_taiv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a15);
    ddp_taiv_rec.try_id := rosetta_g_miss_num_map(p5_a16);
    ddp_taiv_rec.ibt_id := rosetta_g_miss_num_map(p5_a17);
    ddp_taiv_rec.ixx_id := rosetta_g_miss_num_map(p5_a18);
    ddp_taiv_rec.irm_id := rosetta_g_miss_num_map(p5_a19);
    ddp_taiv_rec.irt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_taiv_rec.svf_id := rosetta_g_miss_num_map(p5_a21);
    ddp_taiv_rec.amount := rosetta_g_miss_num_map(p5_a22);
    ddp_taiv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a23);
    ddp_taiv_rec.amount_applied := rosetta_g_miss_num_map(p5_a24);
    ddp_taiv_rec.description := p5_a25;
    ddp_taiv_rec.trx_number := p5_a26;
    ddp_taiv_rec.clg_id := rosetta_g_miss_num_map(p5_a27);
    ddp_taiv_rec.pox_id := rosetta_g_miss_num_map(p5_a28);
    ddp_taiv_rec.cpy_id := rosetta_g_miss_num_map(p5_a29);
    ddp_taiv_rec.attribute_category := p5_a30;
    ddp_taiv_rec.attribute1 := p5_a31;
    ddp_taiv_rec.attribute2 := p5_a32;
    ddp_taiv_rec.attribute3 := p5_a33;
    ddp_taiv_rec.attribute4 := p5_a34;
    ddp_taiv_rec.attribute5 := p5_a35;
    ddp_taiv_rec.attribute6 := p5_a36;
    ddp_taiv_rec.attribute7 := p5_a37;
    ddp_taiv_rec.attribute8 := p5_a38;
    ddp_taiv_rec.attribute9 := p5_a39;
    ddp_taiv_rec.attribute10 := p5_a40;
    ddp_taiv_rec.attribute11 := p5_a41;
    ddp_taiv_rec.attribute12 := p5_a42;
    ddp_taiv_rec.attribute13 := p5_a43;
    ddp_taiv_rec.attribute14 := p5_a44;
    ddp_taiv_rec.attribute15 := p5_a45;
    ddp_taiv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a46);
    ddp_taiv_rec.request_id := rosetta_g_miss_num_map(p5_a47);
    ddp_taiv_rec.program_application_id := rosetta_g_miss_num_map(p5_a48);
    ddp_taiv_rec.program_id := rosetta_g_miss_num_map(p5_a49);
    ddp_taiv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_taiv_rec.org_id := rosetta_g_miss_num_map(p5_a51);
    ddp_taiv_rec.created_by := rosetta_g_miss_num_map(p5_a52);
    ddp_taiv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_taiv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a54);
    ddp_taiv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_taiv_rec.last_update_login := rosetta_g_miss_num_map(p5_a56);
    ddp_taiv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a57);
    ddp_taiv_rec.investor_agreement_number := p5_a58;
    ddp_taiv_rec.investor_name := p5_a59;
    ddp_taiv_rec.okl_source_billing_trx := p5_a60;
    ddp_taiv_rec.inf_id := rosetta_g_miss_num_map(p5_a61);
    ddp_taiv_rec.invoice_pull_yn := p5_a62;
    ddp_taiv_rec.due_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_taiv_rec.consolidated_invoice_number := p5_a64;
    ddp_taiv_rec.isi_id := rosetta_g_miss_num_map(p5_a65);
    ddp_taiv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a66);
    ddp_taiv_rec.cust_trx_type_id := rosetta_g_miss_num_map(p5_a67);
    ddp_taiv_rec.customer_bank_account_id := rosetta_g_miss_num_map(p5_a68);
    ddp_taiv_rec.tax_exempt_flag := p5_a69;
    ddp_taiv_rec.tax_exempt_reason_code := p5_a70;
    ddp_taiv_rec.reference_line_id := rosetta_g_miss_num_map(p5_a71);
    ddp_taiv_rec.private_label := p5_a72;

    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_internal_billing_pvt.update_manual_invoice(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec,
      ddp_tilv_tbl,
      ddx_taiv_rec,
      ddx_tilv_tbl,
      ddx_tldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_taiv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_taiv_rec.object_version_number);
    p7_a2 := ddx_taiv_rec.sfwt_flag;
    p7_a3 := ddx_taiv_rec.currency_code;
    p7_a4 := ddx_taiv_rec.currency_conversion_type;
    p7_a5 := rosetta_g_miss_num_map(ddx_taiv_rec.currency_conversion_rate);
    p7_a6 := ddx_taiv_rec.currency_conversion_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_taiv_rec.khr_id);
    p7_a8 := rosetta_g_miss_num_map(ddx_taiv_rec.cra_id);
    p7_a9 := rosetta_g_miss_num_map(ddx_taiv_rec.tap_id);
    p7_a10 := rosetta_g_miss_num_map(ddx_taiv_rec.qte_id);
    p7_a11 := rosetta_g_miss_num_map(ddx_taiv_rec.tcn_id);
    p7_a12 := rosetta_g_miss_num_map(ddx_taiv_rec.tai_id_reverses);
    p7_a13 := rosetta_g_miss_num_map(ddx_taiv_rec.ipy_id);
    p7_a14 := ddx_taiv_rec.trx_status_code;
    p7_a15 := rosetta_g_miss_num_map(ddx_taiv_rec.set_of_books_id);
    p7_a16 := rosetta_g_miss_num_map(ddx_taiv_rec.try_id);
    p7_a17 := rosetta_g_miss_num_map(ddx_taiv_rec.ibt_id);
    p7_a18 := rosetta_g_miss_num_map(ddx_taiv_rec.ixx_id);
    p7_a19 := rosetta_g_miss_num_map(ddx_taiv_rec.irm_id);
    p7_a20 := rosetta_g_miss_num_map(ddx_taiv_rec.irt_id);
    p7_a21 := rosetta_g_miss_num_map(ddx_taiv_rec.svf_id);
    p7_a22 := rosetta_g_miss_num_map(ddx_taiv_rec.amount);
    p7_a23 := ddx_taiv_rec.date_invoiced;
    p7_a24 := rosetta_g_miss_num_map(ddx_taiv_rec.amount_applied);
    p7_a25 := ddx_taiv_rec.description;
    p7_a26 := ddx_taiv_rec.trx_number;
    p7_a27 := rosetta_g_miss_num_map(ddx_taiv_rec.clg_id);
    p7_a28 := rosetta_g_miss_num_map(ddx_taiv_rec.pox_id);
    p7_a29 := rosetta_g_miss_num_map(ddx_taiv_rec.cpy_id);
    p7_a30 := ddx_taiv_rec.attribute_category;
    p7_a31 := ddx_taiv_rec.attribute1;
    p7_a32 := ddx_taiv_rec.attribute2;
    p7_a33 := ddx_taiv_rec.attribute3;
    p7_a34 := ddx_taiv_rec.attribute4;
    p7_a35 := ddx_taiv_rec.attribute5;
    p7_a36 := ddx_taiv_rec.attribute6;
    p7_a37 := ddx_taiv_rec.attribute7;
    p7_a38 := ddx_taiv_rec.attribute8;
    p7_a39 := ddx_taiv_rec.attribute9;
    p7_a40 := ddx_taiv_rec.attribute10;
    p7_a41 := ddx_taiv_rec.attribute11;
    p7_a42 := ddx_taiv_rec.attribute12;
    p7_a43 := ddx_taiv_rec.attribute13;
    p7_a44 := ddx_taiv_rec.attribute14;
    p7_a45 := ddx_taiv_rec.attribute15;
    p7_a46 := ddx_taiv_rec.date_entered;
    p7_a47 := rosetta_g_miss_num_map(ddx_taiv_rec.request_id);
    p7_a48 := rosetta_g_miss_num_map(ddx_taiv_rec.program_application_id);
    p7_a49 := rosetta_g_miss_num_map(ddx_taiv_rec.program_id);
    p7_a50 := ddx_taiv_rec.program_update_date;
    p7_a51 := rosetta_g_miss_num_map(ddx_taiv_rec.org_id);
    p7_a52 := rosetta_g_miss_num_map(ddx_taiv_rec.created_by);
    p7_a53 := ddx_taiv_rec.creation_date;
    p7_a54 := rosetta_g_miss_num_map(ddx_taiv_rec.last_updated_by);
    p7_a55 := ddx_taiv_rec.last_update_date;
    p7_a56 := rosetta_g_miss_num_map(ddx_taiv_rec.last_update_login);
    p7_a57 := rosetta_g_miss_num_map(ddx_taiv_rec.legal_entity_id);
    p7_a58 := ddx_taiv_rec.investor_agreement_number;
    p7_a59 := ddx_taiv_rec.investor_name;
    p7_a60 := ddx_taiv_rec.okl_source_billing_trx;
    p7_a61 := rosetta_g_miss_num_map(ddx_taiv_rec.inf_id);
    p7_a62 := ddx_taiv_rec.invoice_pull_yn;
    p7_a63 := ddx_taiv_rec.due_date;
    p7_a64 := ddx_taiv_rec.consolidated_invoice_number;
    p7_a65 := rosetta_g_miss_num_map(ddx_taiv_rec.isi_id);
    p7_a66 := rosetta_g_miss_num_map(ddx_taiv_rec.receivables_invoice_id);
    p7_a67 := rosetta_g_miss_num_map(ddx_taiv_rec.cust_trx_type_id);
    p7_a68 := rosetta_g_miss_num_map(ddx_taiv_rec.customer_bank_account_id);
    p7_a69 := ddx_taiv_rec.tax_exempt_flag;
    p7_a70 := ddx_taiv_rec.tax_exempt_reason_code;
    p7_a71 := rosetta_g_miss_num_map(ddx_taiv_rec.reference_line_id);
    p7_a72 := ddx_taiv_rec.private_label;

    okl_til_pvt_w.rosetta_table_copy_out_p8(ddx_tilv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      );

    okl_tld_pvt_w.rosetta_table_copy_out_p8(ddx_tldv_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      );
  end;

end okl_internal_billing_pvt_w;

/
