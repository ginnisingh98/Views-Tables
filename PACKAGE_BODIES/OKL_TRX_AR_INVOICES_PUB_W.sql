--------------------------------------------------------
--  DDL for Package Body OKL_TRX_AR_INVOICES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRX_AR_INVOICES_PUB_W" as
  /* $Header: OKLUTAIB.pls 120.4 2007/11/06 14:07:44 veramach ship $ */
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

  procedure insert_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_400
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_VARCHAR2_TABLE_4000
    , p5_a73 JTF_DATE_TABLE
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
  )

  as
    ddp_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddx_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tai_pvt_w.rosetta_table_copy_in_p8(ddp_taiv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.insert_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_tbl,
      ddx_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p6_a0
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
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      );
  end;

  procedure insert_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  DATE
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
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
    ddx_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
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
    ddp_taiv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.insert_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec,
      ddx_taiv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_taiv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_taiv_rec.object_version_number);
    p6_a2 := ddx_taiv_rec.sfwt_flag;
    p6_a3 := ddx_taiv_rec.currency_code;
    p6_a4 := ddx_taiv_rec.currency_conversion_type;
    p6_a5 := rosetta_g_miss_num_map(ddx_taiv_rec.currency_conversion_rate);
    p6_a6 := ddx_taiv_rec.currency_conversion_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_taiv_rec.khr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_taiv_rec.cra_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_taiv_rec.tap_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_taiv_rec.qte_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_taiv_rec.tcn_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_taiv_rec.tai_id_reverses);
    p6_a13 := rosetta_g_miss_num_map(ddx_taiv_rec.ipy_id);
    p6_a14 := ddx_taiv_rec.trx_status_code;
    p6_a15 := rosetta_g_miss_num_map(ddx_taiv_rec.set_of_books_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_taiv_rec.try_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_taiv_rec.ibt_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_taiv_rec.ixx_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_taiv_rec.irm_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_taiv_rec.irt_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_taiv_rec.svf_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_taiv_rec.amount);
    p6_a23 := ddx_taiv_rec.date_invoiced;
    p6_a24 := rosetta_g_miss_num_map(ddx_taiv_rec.amount_applied);
    p6_a25 := ddx_taiv_rec.description;
    p6_a26 := ddx_taiv_rec.trx_number;
    p6_a27 := rosetta_g_miss_num_map(ddx_taiv_rec.clg_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_taiv_rec.pox_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_taiv_rec.cpy_id);
    p6_a30 := ddx_taiv_rec.attribute_category;
    p6_a31 := ddx_taiv_rec.attribute1;
    p6_a32 := ddx_taiv_rec.attribute2;
    p6_a33 := ddx_taiv_rec.attribute3;
    p6_a34 := ddx_taiv_rec.attribute4;
    p6_a35 := ddx_taiv_rec.attribute5;
    p6_a36 := ddx_taiv_rec.attribute6;
    p6_a37 := ddx_taiv_rec.attribute7;
    p6_a38 := ddx_taiv_rec.attribute8;
    p6_a39 := ddx_taiv_rec.attribute9;
    p6_a40 := ddx_taiv_rec.attribute10;
    p6_a41 := ddx_taiv_rec.attribute11;
    p6_a42 := ddx_taiv_rec.attribute12;
    p6_a43 := ddx_taiv_rec.attribute13;
    p6_a44 := ddx_taiv_rec.attribute14;
    p6_a45 := ddx_taiv_rec.attribute15;
    p6_a46 := ddx_taiv_rec.date_entered;
    p6_a47 := rosetta_g_miss_num_map(ddx_taiv_rec.request_id);
    p6_a48 := rosetta_g_miss_num_map(ddx_taiv_rec.program_application_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_taiv_rec.program_id);
    p6_a50 := ddx_taiv_rec.program_update_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_taiv_rec.org_id);
    p6_a52 := rosetta_g_miss_num_map(ddx_taiv_rec.created_by);
    p6_a53 := ddx_taiv_rec.creation_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_taiv_rec.last_updated_by);
    p6_a55 := ddx_taiv_rec.last_update_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_taiv_rec.last_update_login);
    p6_a57 := rosetta_g_miss_num_map(ddx_taiv_rec.legal_entity_id);
    p6_a58 := ddx_taiv_rec.investor_agreement_number;
    p6_a59 := ddx_taiv_rec.investor_name;
    p6_a60 := ddx_taiv_rec.okl_source_billing_trx;
    p6_a61 := rosetta_g_miss_num_map(ddx_taiv_rec.inf_id);
    p6_a62 := ddx_taiv_rec.invoice_pull_yn;
    p6_a63 := ddx_taiv_rec.due_date;
    p6_a64 := ddx_taiv_rec.consolidated_invoice_number;
    p6_a65 := rosetta_g_miss_num_map(ddx_taiv_rec.isi_id);
    p6_a66 := rosetta_g_miss_num_map(ddx_taiv_rec.receivables_invoice_id);
    p6_a67 := rosetta_g_miss_num_map(ddx_taiv_rec.cust_trx_type_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_taiv_rec.customer_bank_account_id);
    p6_a69 := ddx_taiv_rec.tax_exempt_flag;
    p6_a70 := ddx_taiv_rec.tax_exempt_reason_code;
    p6_a71 := rosetta_g_miss_num_map(ddx_taiv_rec.reference_line_id);
    p6_a72 := ddx_taiv_rec.private_label;
    p6_a73 := ddx_taiv_rec.transaction_date;
  end;

  procedure lock_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_400
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_VARCHAR2_TABLE_4000
    , p5_a73 JTF_DATE_TABLE
  )

  as
    ddp_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tai_pvt_w.rosetta_table_copy_in_p8(ddp_taiv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.lock_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
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
    ddp_taiv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.lock_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_400
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_VARCHAR2_TABLE_4000
    , p5_a73 JTF_DATE_TABLE
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
  )

  as
    ddp_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddx_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tai_pvt_w.rosetta_table_copy_in_p8(ddp_taiv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.update_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_tbl,
      ddx_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p6_a0
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
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      );
  end;

  procedure update_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  DATE
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
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
    ddx_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
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
    ddp_taiv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.update_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec,
      ddx_taiv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_taiv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_taiv_rec.object_version_number);
    p6_a2 := ddx_taiv_rec.sfwt_flag;
    p6_a3 := ddx_taiv_rec.currency_code;
    p6_a4 := ddx_taiv_rec.currency_conversion_type;
    p6_a5 := rosetta_g_miss_num_map(ddx_taiv_rec.currency_conversion_rate);
    p6_a6 := ddx_taiv_rec.currency_conversion_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_taiv_rec.khr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_taiv_rec.cra_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_taiv_rec.tap_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_taiv_rec.qte_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_taiv_rec.tcn_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_taiv_rec.tai_id_reverses);
    p6_a13 := rosetta_g_miss_num_map(ddx_taiv_rec.ipy_id);
    p6_a14 := ddx_taiv_rec.trx_status_code;
    p6_a15 := rosetta_g_miss_num_map(ddx_taiv_rec.set_of_books_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_taiv_rec.try_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_taiv_rec.ibt_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_taiv_rec.ixx_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_taiv_rec.irm_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_taiv_rec.irt_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_taiv_rec.svf_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_taiv_rec.amount);
    p6_a23 := ddx_taiv_rec.date_invoiced;
    p6_a24 := rosetta_g_miss_num_map(ddx_taiv_rec.amount_applied);
    p6_a25 := ddx_taiv_rec.description;
    p6_a26 := ddx_taiv_rec.trx_number;
    p6_a27 := rosetta_g_miss_num_map(ddx_taiv_rec.clg_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_taiv_rec.pox_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_taiv_rec.cpy_id);
    p6_a30 := ddx_taiv_rec.attribute_category;
    p6_a31 := ddx_taiv_rec.attribute1;
    p6_a32 := ddx_taiv_rec.attribute2;
    p6_a33 := ddx_taiv_rec.attribute3;
    p6_a34 := ddx_taiv_rec.attribute4;
    p6_a35 := ddx_taiv_rec.attribute5;
    p6_a36 := ddx_taiv_rec.attribute6;
    p6_a37 := ddx_taiv_rec.attribute7;
    p6_a38 := ddx_taiv_rec.attribute8;
    p6_a39 := ddx_taiv_rec.attribute9;
    p6_a40 := ddx_taiv_rec.attribute10;
    p6_a41 := ddx_taiv_rec.attribute11;
    p6_a42 := ddx_taiv_rec.attribute12;
    p6_a43 := ddx_taiv_rec.attribute13;
    p6_a44 := ddx_taiv_rec.attribute14;
    p6_a45 := ddx_taiv_rec.attribute15;
    p6_a46 := ddx_taiv_rec.date_entered;
    p6_a47 := rosetta_g_miss_num_map(ddx_taiv_rec.request_id);
    p6_a48 := rosetta_g_miss_num_map(ddx_taiv_rec.program_application_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_taiv_rec.program_id);
    p6_a50 := ddx_taiv_rec.program_update_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_taiv_rec.org_id);
    p6_a52 := rosetta_g_miss_num_map(ddx_taiv_rec.created_by);
    p6_a53 := ddx_taiv_rec.creation_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_taiv_rec.last_updated_by);
    p6_a55 := ddx_taiv_rec.last_update_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_taiv_rec.last_update_login);
    p6_a57 := rosetta_g_miss_num_map(ddx_taiv_rec.legal_entity_id);
    p6_a58 := ddx_taiv_rec.investor_agreement_number;
    p6_a59 := ddx_taiv_rec.investor_name;
    p6_a60 := ddx_taiv_rec.okl_source_billing_trx;
    p6_a61 := rosetta_g_miss_num_map(ddx_taiv_rec.inf_id);
    p6_a62 := ddx_taiv_rec.invoice_pull_yn;
    p6_a63 := ddx_taiv_rec.due_date;
    p6_a64 := ddx_taiv_rec.consolidated_invoice_number;
    p6_a65 := rosetta_g_miss_num_map(ddx_taiv_rec.isi_id);
    p6_a66 := rosetta_g_miss_num_map(ddx_taiv_rec.receivables_invoice_id);
    p6_a67 := rosetta_g_miss_num_map(ddx_taiv_rec.cust_trx_type_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_taiv_rec.customer_bank_account_id);
    p6_a69 := ddx_taiv_rec.tax_exempt_flag;
    p6_a70 := ddx_taiv_rec.tax_exempt_reason_code;
    p6_a71 := rosetta_g_miss_num_map(ddx_taiv_rec.reference_line_id);
    p6_a72 := ddx_taiv_rec.private_label;
    p6_a73 := ddx_taiv_rec.transaction_date;
  end;

  procedure delete_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_400
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_VARCHAR2_TABLE_4000
    , p5_a73 JTF_DATE_TABLE
  )

  as
    ddp_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tai_pvt_w.rosetta_table_copy_in_p8(ddp_taiv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.delete_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
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
    ddp_taiv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.delete_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_400
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_VARCHAR2_TABLE_4000
    , p5_a73 JTF_DATE_TABLE
  )

  as
    ddp_taiv_tbl okl_trx_ar_invoices_pub.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tai_pvt_w.rosetta_table_copy_in_p8(ddp_taiv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.validate_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_trx_ar_invoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_taiv_rec okl_trx_ar_invoices_pub.taiv_rec_type;
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
    ddp_taiv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_ar_invoices_pub.validate_trx_ar_invoices(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taiv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_trx_ar_invoices_pub_w;

/
