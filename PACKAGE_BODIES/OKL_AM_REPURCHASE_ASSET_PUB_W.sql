--------------------------------------------------------
--  DDL for Package Body OKL_AM_REPURCHASE_ASSET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_REPURCHASE_ASSET_PUB_W" as
  /* $Header: OKLURQUB.pls 120.2 2005/08/19 01:37:16 rmunjulu noship $ */
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

  procedure create_repurchase_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_2000
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
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
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_DATE_TABLE
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_DATE_TABLE
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_DATE_TABLE
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_DATE_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p6_a43 JTF_VARCHAR2_TABLE_100
    , p6_a44 JTF_VARCHAR2_TABLE_200
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_NUMBER_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_NUMBER_TABLE
    , p6_a53 JTF_VARCHAR2_TABLE_200
    , p6_a54 JTF_VARCHAR2_TABLE_100
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_DATE_TABLE
    , p6_a60 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  DATE
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  DATE
    , p7_a19 out nocopy  DATE
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  DATE
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  DATE
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  DATE
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  DATE
    , p7_a58 out nocopy  NUMBER
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  NUMBER
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  NUMBER
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  NUMBER
    , p7_a65 out nocopy  DATE
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  DATE
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  NUMBER
    , p7_a72 out nocopy  NUMBER
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  NUMBER
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  NUMBER
    , p7_a79 out nocopy  DATE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_DATE_TABLE
    , p8_a34 out nocopy JTF_NUMBER_TABLE
    , p8_a35 out nocopy JTF_DATE_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_DATE_TABLE
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_DATE_TABLE
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a41 out nocopy JTF_NUMBER_TABLE
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_NUMBER_TABLE
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_DATE_TABLE
    , p8_a60 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_qtev_rec okl_am_repurchase_asset_pub.qtev_rec_type;
    ddp_tqlv_tbl okl_am_repurchase_asset_pub.tqlv_tbl_type;
    ddx_qtev_rec okl_am_repurchase_asset_pub.qtev_rec_type;
    ddx_tqlv_tbl okl_am_repurchase_asset_pub.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.currency_code := p5_a75;
    ddp_qtev_rec.currency_conversion_code := p5_a76;
    ddp_qtev_rec.currency_conversion_type := p5_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a79);

    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_am_repurchase_asset_pub.create_repurchase_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec,
      ddp_tqlv_tbl,
      ddx_qtev_rec,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p7_a2 := ddx_qtev_rec.sfwt_flag;
    p7_a3 := ddx_qtev_rec.qrs_code;
    p7_a4 := ddx_qtev_rec.qst_code;
    p7_a5 := ddx_qtev_rec.qtp_code;
    p7_a6 := ddx_qtev_rec.trn_code;
    p7_a7 := ddx_qtev_rec.pop_code_end;
    p7_a8 := ddx_qtev_rec.pop_code_early;
    p7_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p7_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p7_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p7_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p7_a13 := ddx_qtev_rec.early_termination_yn;
    p7_a14 := ddx_qtev_rec.partial_yn;
    p7_a15 := ddx_qtev_rec.preproceeds_yn;
    p7_a16 := ddx_qtev_rec.date_requested;
    p7_a17 := ddx_qtev_rec.date_proposal;
    p7_a18 := ddx_qtev_rec.date_effective_to;
    p7_a19 := ddx_qtev_rec.date_accepted;
    p7_a20 := ddx_qtev_rec.summary_format_yn;
    p7_a21 := ddx_qtev_rec.consolidated_yn;
    p7_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p7_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p7_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p7_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p7_a26 := ddx_qtev_rec.date_restructure_end;
    p7_a27 := ddx_qtev_rec.date_restructure_start;
    p7_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p7_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p7_a30 := ddx_qtev_rec.comments;
    p7_a31 := ddx_qtev_rec.date_due;
    p7_a32 := ddx_qtev_rec.payment_frequency;
    p7_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p7_a34 := ddx_qtev_rec.date_effective_from;
    p7_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p7_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p7_a37 := ddx_qtev_rec.approved_yn;
    p7_a38 := ddx_qtev_rec.accepted_yn;
    p7_a39 := ddx_qtev_rec.payment_received_yn;
    p7_a40 := ddx_qtev_rec.date_payment_received;
    p7_a41 := ddx_qtev_rec.attribute_category;
    p7_a42 := ddx_qtev_rec.attribute1;
    p7_a43 := ddx_qtev_rec.attribute2;
    p7_a44 := ddx_qtev_rec.attribute3;
    p7_a45 := ddx_qtev_rec.attribute4;
    p7_a46 := ddx_qtev_rec.attribute5;
    p7_a47 := ddx_qtev_rec.attribute6;
    p7_a48 := ddx_qtev_rec.attribute7;
    p7_a49 := ddx_qtev_rec.attribute8;
    p7_a50 := ddx_qtev_rec.attribute9;
    p7_a51 := ddx_qtev_rec.attribute10;
    p7_a52 := ddx_qtev_rec.attribute11;
    p7_a53 := ddx_qtev_rec.attribute12;
    p7_a54 := ddx_qtev_rec.attribute13;
    p7_a55 := ddx_qtev_rec.attribute14;
    p7_a56 := ddx_qtev_rec.attribute15;
    p7_a57 := ddx_qtev_rec.date_approved;
    p7_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p7_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p7_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p7_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p7_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p7_a63 := ddx_qtev_rec.program_update_date;
    p7_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p7_a65 := ddx_qtev_rec.creation_date;
    p7_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p7_a67 := ddx_qtev_rec.last_update_date;
    p7_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p7_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p7_a70 := ddx_qtev_rec.purchase_formula;
    p7_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p7_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p7_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p7_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p7_a75 := ddx_qtev_rec.currency_code;
    p7_a76 := ddx_qtev_rec.currency_conversion_code;
    p7_a77 := ddx_qtev_rec.currency_conversion_type;
    p7_a78 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p7_a79 := ddx_qtev_rec.currency_conversion_date;

    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p8_a0
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
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      );
  end;

  procedure update_repurchase_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_2000
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
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
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_DATE_TABLE
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_DATE_TABLE
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_DATE_TABLE
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_DATE_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p6_a43 JTF_VARCHAR2_TABLE_100
    , p6_a44 JTF_VARCHAR2_TABLE_200
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_NUMBER_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_NUMBER_TABLE
    , p6_a53 JTF_VARCHAR2_TABLE_200
    , p6_a54 JTF_VARCHAR2_TABLE_100
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_DATE_TABLE
    , p6_a60 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  DATE
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  DATE
    , p7_a19 out nocopy  DATE
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  DATE
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  DATE
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  DATE
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  DATE
    , p7_a58 out nocopy  NUMBER
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  NUMBER
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  NUMBER
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  NUMBER
    , p7_a65 out nocopy  DATE
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  DATE
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  NUMBER
    , p7_a72 out nocopy  NUMBER
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  NUMBER
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  NUMBER
    , p7_a79 out nocopy  DATE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_DATE_TABLE
    , p8_a34 out nocopy JTF_NUMBER_TABLE
    , p8_a35 out nocopy JTF_DATE_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_DATE_TABLE
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_DATE_TABLE
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a41 out nocopy JTF_NUMBER_TABLE
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_NUMBER_TABLE
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_DATE_TABLE
    , p8_a60 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_qtev_rec okl_am_repurchase_asset_pub.qtev_rec_type;
    ddp_tqlv_tbl okl_am_repurchase_asset_pub.tqlv_tbl_type;
    ddx_qtev_rec okl_am_repurchase_asset_pub.qtev_rec_type;
    ddx_tqlv_tbl okl_am_repurchase_asset_pub.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.currency_code := p5_a75;
    ddp_qtev_rec.currency_conversion_code := p5_a76;
    ddp_qtev_rec.currency_conversion_type := p5_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a79);

    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_am_repurchase_asset_pub.update_repurchase_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec,
      ddp_tqlv_tbl,
      ddx_qtev_rec,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p7_a2 := ddx_qtev_rec.sfwt_flag;
    p7_a3 := ddx_qtev_rec.qrs_code;
    p7_a4 := ddx_qtev_rec.qst_code;
    p7_a5 := ddx_qtev_rec.qtp_code;
    p7_a6 := ddx_qtev_rec.trn_code;
    p7_a7 := ddx_qtev_rec.pop_code_end;
    p7_a8 := ddx_qtev_rec.pop_code_early;
    p7_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p7_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p7_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p7_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p7_a13 := ddx_qtev_rec.early_termination_yn;
    p7_a14 := ddx_qtev_rec.partial_yn;
    p7_a15 := ddx_qtev_rec.preproceeds_yn;
    p7_a16 := ddx_qtev_rec.date_requested;
    p7_a17 := ddx_qtev_rec.date_proposal;
    p7_a18 := ddx_qtev_rec.date_effective_to;
    p7_a19 := ddx_qtev_rec.date_accepted;
    p7_a20 := ddx_qtev_rec.summary_format_yn;
    p7_a21 := ddx_qtev_rec.consolidated_yn;
    p7_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p7_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p7_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p7_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p7_a26 := ddx_qtev_rec.date_restructure_end;
    p7_a27 := ddx_qtev_rec.date_restructure_start;
    p7_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p7_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p7_a30 := ddx_qtev_rec.comments;
    p7_a31 := ddx_qtev_rec.date_due;
    p7_a32 := ddx_qtev_rec.payment_frequency;
    p7_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p7_a34 := ddx_qtev_rec.date_effective_from;
    p7_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p7_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p7_a37 := ddx_qtev_rec.approved_yn;
    p7_a38 := ddx_qtev_rec.accepted_yn;
    p7_a39 := ddx_qtev_rec.payment_received_yn;
    p7_a40 := ddx_qtev_rec.date_payment_received;
    p7_a41 := ddx_qtev_rec.attribute_category;
    p7_a42 := ddx_qtev_rec.attribute1;
    p7_a43 := ddx_qtev_rec.attribute2;
    p7_a44 := ddx_qtev_rec.attribute3;
    p7_a45 := ddx_qtev_rec.attribute4;
    p7_a46 := ddx_qtev_rec.attribute5;
    p7_a47 := ddx_qtev_rec.attribute6;
    p7_a48 := ddx_qtev_rec.attribute7;
    p7_a49 := ddx_qtev_rec.attribute8;
    p7_a50 := ddx_qtev_rec.attribute9;
    p7_a51 := ddx_qtev_rec.attribute10;
    p7_a52 := ddx_qtev_rec.attribute11;
    p7_a53 := ddx_qtev_rec.attribute12;
    p7_a54 := ddx_qtev_rec.attribute13;
    p7_a55 := ddx_qtev_rec.attribute14;
    p7_a56 := ddx_qtev_rec.attribute15;
    p7_a57 := ddx_qtev_rec.date_approved;
    p7_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p7_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p7_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p7_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p7_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p7_a63 := ddx_qtev_rec.program_update_date;
    p7_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p7_a65 := ddx_qtev_rec.creation_date;
    p7_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p7_a67 := ddx_qtev_rec.last_update_date;
    p7_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p7_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p7_a70 := ddx_qtev_rec.purchase_formula;
    p7_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p7_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p7_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p7_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p7_a75 := ddx_qtev_rec.currency_code;
    p7_a76 := ddx_qtev_rec.currency_conversion_code;
    p7_a77 := ddx_qtev_rec.currency_conversion_type;
    p7_a78 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p7_a79 := ddx_qtev_rec.currency_conversion_date;

    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p8_a0
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
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      );
  end;

end okl_am_repurchase_asset_pub_w;

/
