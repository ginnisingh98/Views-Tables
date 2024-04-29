--------------------------------------------------------
--  DDL for Package Body OKL_GENERATE_ACCRUALS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GENERATE_ACCRUALS_PUB_W" as
  /* $Header: OKLUACRB.pls 120.13.12010000.6 2008/11/12 23:54:19 apaul ship $ */
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

  function submit_accruals(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_accrual_date  date
    , p_batch_name  VARCHAR2
  ) return number

  as
    ddp_accrual_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_accrual_date := rosetta_g_miss_date_in_map(p_accrual_date);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_generate_accruals_pub.submit_accruals(x_return_status,
      x_msg_count,
      x_msg_data,
      p_api_version,
      ddp_accrual_date,
      p_batch_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    return ddrosetta_retval;
  end;

  procedure catchup_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_DATE_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_NUMBER_TABLE
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_NUMBER_TABLE
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 out nocopy JTF_NUMBER_TABLE
    , p7_a52 out nocopy JTF_DATE_TABLE
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  NUMBER := 0-1962.0724
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  DATE := fnd_api.g_miss_date
  )

  as
    ddp_catchup_rec okl_generate_accruals_pub.accrual_rec_type;
    ddx_tcnv_tbl okl_trx_contracts_pub.tcnv_tbl_type;
    ddx_tclv_tbl okl_trx_contracts_pub.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_catchup_rec.contract_id := rosetta_g_miss_num_map(p2_a0);
    ddp_catchup_rec.sty_id := rosetta_g_miss_num_map(p2_a1);
    ddp_catchup_rec.set_of_books_id := rosetta_g_miss_num_map(p2_a2);
    ddp_catchup_rec.reverse_date_to := rosetta_g_miss_date_in_map(p2_a3);
    ddp_catchup_rec.accrual_date := rosetta_g_miss_date_in_map(p2_a4);
    ddp_catchup_rec.trx_date := rosetta_g_miss_date_in_map(p2_a5);
    ddp_catchup_rec.contract_number := p2_a6;
    ddp_catchup_rec.rule_result := p2_a7;
    ddp_catchup_rec.override_status := p2_a8;
    ddp_catchup_rec.description := p2_a9;
    ddp_catchup_rec.amount := rosetta_g_miss_num_map(p2_a10);
    ddp_catchup_rec.currency_code := p2_a11;
    ddp_catchup_rec.currency_conversion_type := p2_a12;
    ddp_catchup_rec.currency_conversion_rate := rosetta_g_miss_num_map(p2_a13);
    ddp_catchup_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p2_a14);
    ddp_catchup_rec.product_id := rosetta_g_miss_num_map(p2_a15);
    ddp_catchup_rec.trx_type_id := rosetta_g_miss_num_map(p2_a16);
    ddp_catchup_rec.advance_arrears := p2_a17;
    ddp_catchup_rec.factoring_synd_flag := p2_a18;
    ddp_catchup_rec.post_to_gl := p2_a19;
    ddp_catchup_rec.gl_reversal_flag := p2_a20;
    ddp_catchup_rec.memo_yn := p2_a21;
    ddp_catchup_rec.accrual_activity := p2_a22;
    ddp_catchup_rec.accrual_rule_yn := p2_a23;
    ddp_catchup_rec.source_trx_id := rosetta_g_miss_num_map(p2_a24);
    ddp_catchup_rec.source_trx_type := p2_a25;
    ddp_catchup_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p2_a26);






    -- here's the delegated call to the old PL/SQL routine
    okl_generate_accruals_pub.catchup_accruals(p_api_version,
      p_init_msg_list,
      ddp_catchup_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_tcnv_tbl,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcn_pvt_w.rosetta_table_copy_out_p5(ddx_tcnv_tbl, p6_a0
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
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      );

    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p7_a0
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
      );
  end;

  procedure reverse_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_DATE_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_NUMBER_TABLE
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_NUMBER_TABLE
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 out nocopy JTF_NUMBER_TABLE
    , p7_a52 out nocopy JTF_DATE_TABLE
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  NUMBER := 0-1962.0724
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  DATE := fnd_api.g_miss_date
  )

  as
    ddp_reverse_rec okl_generate_accruals_pub.accrual_rec_type;
    ddx_tcnv_tbl okl_trx_contracts_pub.tcnv_tbl_type;
    ddx_tclv_tbl okl_trx_contracts_pub.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_reverse_rec.contract_id := rosetta_g_miss_num_map(p2_a0);
    ddp_reverse_rec.sty_id := rosetta_g_miss_num_map(p2_a1);
    ddp_reverse_rec.set_of_books_id := rosetta_g_miss_num_map(p2_a2);
    ddp_reverse_rec.reverse_date_to := rosetta_g_miss_date_in_map(p2_a3);
    ddp_reverse_rec.accrual_date := rosetta_g_miss_date_in_map(p2_a4);
    ddp_reverse_rec.trx_date := rosetta_g_miss_date_in_map(p2_a5);
    ddp_reverse_rec.contract_number := p2_a6;
    ddp_reverse_rec.rule_result := p2_a7;
    ddp_reverse_rec.override_status := p2_a8;
    ddp_reverse_rec.description := p2_a9;
    ddp_reverse_rec.amount := rosetta_g_miss_num_map(p2_a10);
    ddp_reverse_rec.currency_code := p2_a11;
    ddp_reverse_rec.currency_conversion_type := p2_a12;
    ddp_reverse_rec.currency_conversion_rate := rosetta_g_miss_num_map(p2_a13);
    ddp_reverse_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p2_a14);
    ddp_reverse_rec.product_id := rosetta_g_miss_num_map(p2_a15);
    ddp_reverse_rec.trx_type_id := rosetta_g_miss_num_map(p2_a16);
    ddp_reverse_rec.advance_arrears := p2_a17;
    ddp_reverse_rec.factoring_synd_flag := p2_a18;
    ddp_reverse_rec.post_to_gl := p2_a19;
    ddp_reverse_rec.gl_reversal_flag := p2_a20;
    ddp_reverse_rec.memo_yn := p2_a21;
    ddp_reverse_rec.accrual_activity := p2_a22;
    ddp_reverse_rec.accrual_rule_yn := p2_a23;
    ddp_reverse_rec.source_trx_id := rosetta_g_miss_num_map(p2_a24);
    ddp_reverse_rec.source_trx_type := p2_a25;
    ddp_reverse_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p2_a26);






    -- here's the delegated call to the old PL/SQL routine
    okl_generate_accruals_pub.reverse_accruals(p_api_version,
      p_init_msg_list,
      ddp_reverse_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_tcnv_tbl,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcn_pvt_w.rosetta_table_copy_out_p5(ddx_tcnv_tbl, p6_a0
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
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      );

    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p7_a0
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
      );
  end;

  procedure reverse_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_reversal_date  date
    , p_accounting_date  date
    , p_reverse_from  date
    , p_reverse_to  date
    , p_tcn_type  VARCHAR2
  )

  as
    ddp_reversal_date date;
    ddp_accounting_date date;
    ddp_reverse_from date;
    ddp_reverse_to date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_reversal_date := rosetta_g_miss_date_in_map(p_reversal_date);

    ddp_accounting_date := rosetta_g_miss_date_in_map(p_accounting_date);

    ddp_reverse_from := rosetta_g_miss_date_in_map(p_reverse_from);

    ddp_reverse_to := rosetta_g_miss_date_in_map(p_reverse_to);


    -- here's the delegated call to the old PL/SQL routine
    okl_generate_accruals_pub.reverse_accruals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddp_reversal_date,
      ddp_accounting_date,
      ddp_reverse_from,
      ddp_reverse_to,
      p_tcn_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure reverse_all_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_khr_id  NUMBER
    , p_reverse_date  date
    , p_description  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_reverse_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_reverse_date := rosetta_g_miss_date_in_map(p_reverse_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_generate_accruals_pub.reverse_all_accruals(p_api_version,
      p_init_msg_list,
      p_khr_id,
      ddp_reverse_date,
      p_description,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure accelerate_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2
    , p_representation_type  VARCHAR2
    , x_trx_number out nocopy  VARCHAR2
  )

  as
    ddp_acceleration_rec okl_generate_accruals_pub.acceleration_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_acceleration_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_acceleration_rec.kle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_acceleration_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_acceleration_rec.acceleration_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_acceleration_rec.accelerate_till_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_acceleration_rec.description := p5_a5;
    ddp_acceleration_rec.accrual_rule_yn := p5_a6;
    ddp_acceleration_rec.accelerate_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_acceleration_rec.trx_number := p5_a8;

    -- here's the delegated call to the old PL/SQL routine
    okl_generate_accruals_pub.accelerate_accruals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_acceleration_rec,
      p_representation_type,
      x_trx_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_generate_accruals_pub_w;

/
