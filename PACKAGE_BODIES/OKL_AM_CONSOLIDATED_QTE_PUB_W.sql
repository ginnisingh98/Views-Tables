--------------------------------------------------------
--  DDL for Package Body OKL_AM_CONSOLIDATED_QTE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CONSOLIDATED_QTE_PUB_W" as
  /* $Header: OKLUCNQB.pls 120.2 2007/11/02 21:05:49 rmunjulu ship $ */
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

  procedure create_consolidate_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  DATE
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
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  DATE
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
  )

  as
    ddp_qtev_tbl okl_am_consolidated_qte_pub.qtev_tbl_type;
    ddx_cons_rec okl_am_consolidated_qte_pub.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_qtev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_consolidated_qte_pub.create_consolidate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_tbl,
      ddx_cons_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cons_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cons_rec.object_version_number);
    p6_a2 := ddx_cons_rec.sfwt_flag;
    p6_a3 := ddx_cons_rec.qrs_code;
    p6_a4 := ddx_cons_rec.qst_code;
    p6_a5 := ddx_cons_rec.qtp_code;
    p6_a6 := ddx_cons_rec.trn_code;
    p6_a7 := ddx_cons_rec.pop_code_end;
    p6_a8 := ddx_cons_rec.pop_code_early;
    p6_a9 := rosetta_g_miss_num_map(ddx_cons_rec.consolidated_qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_cons_rec.khr_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_cons_rec.art_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_cons_rec.pdt_id);
    p6_a13 := ddx_cons_rec.early_termination_yn;
    p6_a14 := ddx_cons_rec.partial_yn;
    p6_a15 := ddx_cons_rec.preproceeds_yn;
    p6_a16 := ddx_cons_rec.date_requested;
    p6_a17 := ddx_cons_rec.date_proposal;
    p6_a18 := ddx_cons_rec.date_effective_to;
    p6_a19 := ddx_cons_rec.date_accepted;
    p6_a20 := ddx_cons_rec.summary_format_yn;
    p6_a21 := ddx_cons_rec.consolidated_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_cons_rec.principal_paydown_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_cons_rec.residual_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_cons_rec.yield);
    p6_a25 := rosetta_g_miss_num_map(ddx_cons_rec.rent_amount);
    p6_a26 := ddx_cons_rec.date_restructure_end;
    p6_a27 := ddx_cons_rec.date_restructure_start;
    p6_a28 := rosetta_g_miss_num_map(ddx_cons_rec.term);
    p6_a29 := rosetta_g_miss_num_map(ddx_cons_rec.purchase_percent);
    p6_a30 := ddx_cons_rec.comments;
    p6_a31 := ddx_cons_rec.date_due;
    p6_a32 := ddx_cons_rec.payment_frequency;
    p6_a33 := rosetta_g_miss_num_map(ddx_cons_rec.remaining_payments);
    p6_a34 := ddx_cons_rec.date_effective_from;
    p6_a35 := rosetta_g_miss_num_map(ddx_cons_rec.quote_number);
    p6_a36 := rosetta_g_miss_num_map(ddx_cons_rec.requested_by);
    p6_a37 := ddx_cons_rec.approved_yn;
    p6_a38 := ddx_cons_rec.accepted_yn;
    p6_a39 := ddx_cons_rec.payment_received_yn;
    p6_a40 := ddx_cons_rec.date_payment_received;
    p6_a41 := ddx_cons_rec.attribute_category;
    p6_a42 := ddx_cons_rec.attribute1;
    p6_a43 := ddx_cons_rec.attribute2;
    p6_a44 := ddx_cons_rec.attribute3;
    p6_a45 := ddx_cons_rec.attribute4;
    p6_a46 := ddx_cons_rec.attribute5;
    p6_a47 := ddx_cons_rec.attribute6;
    p6_a48 := ddx_cons_rec.attribute7;
    p6_a49 := ddx_cons_rec.attribute8;
    p6_a50 := ddx_cons_rec.attribute9;
    p6_a51 := ddx_cons_rec.attribute10;
    p6_a52 := ddx_cons_rec.attribute11;
    p6_a53 := ddx_cons_rec.attribute12;
    p6_a54 := ddx_cons_rec.attribute13;
    p6_a55 := ddx_cons_rec.attribute14;
    p6_a56 := ddx_cons_rec.attribute15;
    p6_a57 := ddx_cons_rec.date_approved;
    p6_a58 := rosetta_g_miss_num_map(ddx_cons_rec.approved_by);
    p6_a59 := rosetta_g_miss_num_map(ddx_cons_rec.org_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_cons_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_cons_rec.program_application_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_cons_rec.program_id);
    p6_a63 := ddx_cons_rec.program_update_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_cons_rec.created_by);
    p6_a65 := ddx_cons_rec.creation_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_cons_rec.last_updated_by);
    p6_a67 := ddx_cons_rec.last_update_date;
    p6_a68 := rosetta_g_miss_num_map(ddx_cons_rec.last_update_login);
    p6_a69 := rosetta_g_miss_num_map(ddx_cons_rec.purchase_amount);
    p6_a70 := ddx_cons_rec.purchase_formula;
    p6_a71 := rosetta_g_miss_num_map(ddx_cons_rec.asset_value);
    p6_a72 := rosetta_g_miss_num_map(ddx_cons_rec.residual_value);
    p6_a73 := rosetta_g_miss_num_map(ddx_cons_rec.unbilled_receivables);
    p6_a74 := rosetta_g_miss_num_map(ddx_cons_rec.gain_loss);
    p6_a75 := rosetta_g_miss_num_map(ddx_cons_rec.perdiem_amount);
    p6_a76 := ddx_cons_rec.currency_code;
    p6_a77 := ddx_cons_rec.currency_conversion_code;
    p6_a78 := ddx_cons_rec.currency_conversion_type;
    p6_a79 := rosetta_g_miss_num_map(ddx_cons_rec.currency_conversion_rate);
    p6_a80 := ddx_cons_rec.currency_conversion_date;
    p6_a81 := rosetta_g_miss_num_map(ddx_cons_rec.legal_entity_id);
    p6_a82 := ddx_cons_rec.repo_quote_indicator_yn;
  end;

  procedure update_consolidate_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  DATE
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
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  DATE
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_DATE_TABLE
    , p7_a17 out nocopy JTF_DATE_TABLE
    , p7_a18 out nocopy JTF_DATE_TABLE
    , p7_a19 out nocopy JTF_DATE_TABLE
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 out nocopy JTF_NUMBER_TABLE
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_DATE_TABLE
    , p7_a27 out nocopy JTF_DATE_TABLE
    , p7_a28 out nocopy JTF_NUMBER_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a31 out nocopy JTF_DATE_TABLE
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 out nocopy JTF_DATE_TABLE
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a57 out nocopy JTF_DATE_TABLE
    , p7_a58 out nocopy JTF_NUMBER_TABLE
    , p7_a59 out nocopy JTF_NUMBER_TABLE
    , p7_a60 out nocopy JTF_NUMBER_TABLE
    , p7_a61 out nocopy JTF_NUMBER_TABLE
    , p7_a62 out nocopy JTF_NUMBER_TABLE
    , p7_a63 out nocopy JTF_DATE_TABLE
    , p7_a64 out nocopy JTF_NUMBER_TABLE
    , p7_a65 out nocopy JTF_DATE_TABLE
    , p7_a66 out nocopy JTF_NUMBER_TABLE
    , p7_a67 out nocopy JTF_DATE_TABLE
    , p7_a68 out nocopy JTF_NUMBER_TABLE
    , p7_a69 out nocopy JTF_NUMBER_TABLE
    , p7_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a71 out nocopy JTF_NUMBER_TABLE
    , p7_a72 out nocopy JTF_NUMBER_TABLE
    , p7_a73 out nocopy JTF_NUMBER_TABLE
    , p7_a74 out nocopy JTF_NUMBER_TABLE
    , p7_a75 out nocopy JTF_NUMBER_TABLE
    , p7_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a79 out nocopy JTF_NUMBER_TABLE
    , p7_a80 out nocopy JTF_DATE_TABLE
    , p7_a81 out nocopy JTF_NUMBER_TABLE
    , p7_a82 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_cons_rec okl_am_consolidated_qte_pub.qtev_rec_type;
    ddx_cons_rec okl_am_consolidated_qte_pub.qtev_rec_type;
    ddx_qtev_tbl okl_am_consolidated_qte_pub.qtev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cons_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cons_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cons_rec.sfwt_flag := p5_a2;
    ddp_cons_rec.qrs_code := p5_a3;
    ddp_cons_rec.qst_code := p5_a4;
    ddp_cons_rec.qtp_code := p5_a5;
    ddp_cons_rec.trn_code := p5_a6;
    ddp_cons_rec.pop_code_end := p5_a7;
    ddp_cons_rec.pop_code_early := p5_a8;
    ddp_cons_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_cons_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_cons_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_cons_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_cons_rec.early_termination_yn := p5_a13;
    ddp_cons_rec.partial_yn := p5_a14;
    ddp_cons_rec.preproceeds_yn := p5_a15;
    ddp_cons_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_cons_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_cons_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_cons_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_cons_rec.summary_format_yn := p5_a20;
    ddp_cons_rec.consolidated_yn := p5_a21;
    ddp_cons_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_cons_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_cons_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_cons_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_cons_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cons_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_cons_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_cons_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_cons_rec.comments := p5_a30;
    ddp_cons_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_cons_rec.payment_frequency := p5_a32;
    ddp_cons_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_cons_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_cons_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_cons_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_cons_rec.approved_yn := p5_a37;
    ddp_cons_rec.accepted_yn := p5_a38;
    ddp_cons_rec.payment_received_yn := p5_a39;
    ddp_cons_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_cons_rec.attribute_category := p5_a41;
    ddp_cons_rec.attribute1 := p5_a42;
    ddp_cons_rec.attribute2 := p5_a43;
    ddp_cons_rec.attribute3 := p5_a44;
    ddp_cons_rec.attribute4 := p5_a45;
    ddp_cons_rec.attribute5 := p5_a46;
    ddp_cons_rec.attribute6 := p5_a47;
    ddp_cons_rec.attribute7 := p5_a48;
    ddp_cons_rec.attribute8 := p5_a49;
    ddp_cons_rec.attribute9 := p5_a50;
    ddp_cons_rec.attribute10 := p5_a51;
    ddp_cons_rec.attribute11 := p5_a52;
    ddp_cons_rec.attribute12 := p5_a53;
    ddp_cons_rec.attribute13 := p5_a54;
    ddp_cons_rec.attribute14 := p5_a55;
    ddp_cons_rec.attribute15 := p5_a56;
    ddp_cons_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_cons_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_cons_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_cons_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_cons_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_cons_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_cons_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_cons_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_cons_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_cons_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_cons_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_cons_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_cons_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_cons_rec.purchase_formula := p5_a70;
    ddp_cons_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_cons_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_cons_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_cons_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_cons_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_cons_rec.currency_code := p5_a76;
    ddp_cons_rec.currency_conversion_code := p5_a77;
    ddp_cons_rec.currency_conversion_type := p5_a78;
    ddp_cons_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_cons_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_cons_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_cons_rec.repo_quote_indicator_yn := p5_a82;



    -- here's the delegated call to the old PL/SQL routine
    okl_am_consolidated_qte_pub.update_consolidate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cons_rec,
      ddx_cons_rec,
      ddx_qtev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cons_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cons_rec.object_version_number);
    p6_a2 := ddx_cons_rec.sfwt_flag;
    p6_a3 := ddx_cons_rec.qrs_code;
    p6_a4 := ddx_cons_rec.qst_code;
    p6_a5 := ddx_cons_rec.qtp_code;
    p6_a6 := ddx_cons_rec.trn_code;
    p6_a7 := ddx_cons_rec.pop_code_end;
    p6_a8 := ddx_cons_rec.pop_code_early;
    p6_a9 := rosetta_g_miss_num_map(ddx_cons_rec.consolidated_qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_cons_rec.khr_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_cons_rec.art_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_cons_rec.pdt_id);
    p6_a13 := ddx_cons_rec.early_termination_yn;
    p6_a14 := ddx_cons_rec.partial_yn;
    p6_a15 := ddx_cons_rec.preproceeds_yn;
    p6_a16 := ddx_cons_rec.date_requested;
    p6_a17 := ddx_cons_rec.date_proposal;
    p6_a18 := ddx_cons_rec.date_effective_to;
    p6_a19 := ddx_cons_rec.date_accepted;
    p6_a20 := ddx_cons_rec.summary_format_yn;
    p6_a21 := ddx_cons_rec.consolidated_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_cons_rec.principal_paydown_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_cons_rec.residual_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_cons_rec.yield);
    p6_a25 := rosetta_g_miss_num_map(ddx_cons_rec.rent_amount);
    p6_a26 := ddx_cons_rec.date_restructure_end;
    p6_a27 := ddx_cons_rec.date_restructure_start;
    p6_a28 := rosetta_g_miss_num_map(ddx_cons_rec.term);
    p6_a29 := rosetta_g_miss_num_map(ddx_cons_rec.purchase_percent);
    p6_a30 := ddx_cons_rec.comments;
    p6_a31 := ddx_cons_rec.date_due;
    p6_a32 := ddx_cons_rec.payment_frequency;
    p6_a33 := rosetta_g_miss_num_map(ddx_cons_rec.remaining_payments);
    p6_a34 := ddx_cons_rec.date_effective_from;
    p6_a35 := rosetta_g_miss_num_map(ddx_cons_rec.quote_number);
    p6_a36 := rosetta_g_miss_num_map(ddx_cons_rec.requested_by);
    p6_a37 := ddx_cons_rec.approved_yn;
    p6_a38 := ddx_cons_rec.accepted_yn;
    p6_a39 := ddx_cons_rec.payment_received_yn;
    p6_a40 := ddx_cons_rec.date_payment_received;
    p6_a41 := ddx_cons_rec.attribute_category;
    p6_a42 := ddx_cons_rec.attribute1;
    p6_a43 := ddx_cons_rec.attribute2;
    p6_a44 := ddx_cons_rec.attribute3;
    p6_a45 := ddx_cons_rec.attribute4;
    p6_a46 := ddx_cons_rec.attribute5;
    p6_a47 := ddx_cons_rec.attribute6;
    p6_a48 := ddx_cons_rec.attribute7;
    p6_a49 := ddx_cons_rec.attribute8;
    p6_a50 := ddx_cons_rec.attribute9;
    p6_a51 := ddx_cons_rec.attribute10;
    p6_a52 := ddx_cons_rec.attribute11;
    p6_a53 := ddx_cons_rec.attribute12;
    p6_a54 := ddx_cons_rec.attribute13;
    p6_a55 := ddx_cons_rec.attribute14;
    p6_a56 := ddx_cons_rec.attribute15;
    p6_a57 := ddx_cons_rec.date_approved;
    p6_a58 := rosetta_g_miss_num_map(ddx_cons_rec.approved_by);
    p6_a59 := rosetta_g_miss_num_map(ddx_cons_rec.org_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_cons_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_cons_rec.program_application_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_cons_rec.program_id);
    p6_a63 := ddx_cons_rec.program_update_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_cons_rec.created_by);
    p6_a65 := ddx_cons_rec.creation_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_cons_rec.last_updated_by);
    p6_a67 := ddx_cons_rec.last_update_date;
    p6_a68 := rosetta_g_miss_num_map(ddx_cons_rec.last_update_login);
    p6_a69 := rosetta_g_miss_num_map(ddx_cons_rec.purchase_amount);
    p6_a70 := ddx_cons_rec.purchase_formula;
    p6_a71 := rosetta_g_miss_num_map(ddx_cons_rec.asset_value);
    p6_a72 := rosetta_g_miss_num_map(ddx_cons_rec.residual_value);
    p6_a73 := rosetta_g_miss_num_map(ddx_cons_rec.unbilled_receivables);
    p6_a74 := rosetta_g_miss_num_map(ddx_cons_rec.gain_loss);
    p6_a75 := rosetta_g_miss_num_map(ddx_cons_rec.perdiem_amount);
    p6_a76 := ddx_cons_rec.currency_code;
    p6_a77 := ddx_cons_rec.currency_conversion_code;
    p6_a78 := ddx_cons_rec.currency_conversion_type;
    p6_a79 := rosetta_g_miss_num_map(ddx_cons_rec.currency_conversion_rate);
    p6_a80 := ddx_cons_rec.currency_conversion_date;
    p6_a81 := rosetta_g_miss_num_map(ddx_cons_rec.legal_entity_id);
    p6_a82 := ddx_cons_rec.repo_quote_indicator_yn;

    okl_qte_pvt_w.rosetta_table_copy_out_p8(ddx_qtev_tbl, p7_a0
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
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      );
  end;

end okl_am_consolidated_qte_pub_w;

/
