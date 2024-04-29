--------------------------------------------------------
--  DDL for Package Body OKL_SYSTEM_ACCT_OPT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYSTEM_ACCT_OPT_PUB_W" as
  /* $Header: OKLUSYOB.pls 120.5.12010000.3 2009/06/02 10:59:33 racheruv ship $ */
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

  procedure get_system_acct_opt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_set_of_books_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
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
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  DATE
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
  )

  as
    ddx_saov_rec okl_system_acct_opt_pub.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_system_acct_opt_pub.get_system_acct_opt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_set_of_books_id,
      ddx_saov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_saov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_saov_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_saov_rec.set_of_books_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_saov_rec.code_combination_id);
    p6_a4 := ddx_saov_rec.cc_rep_currency_code;
    p6_a5 := ddx_saov_rec.ael_rep_currency_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_saov_rec.rec_ccid);
    p6_a7 := rosetta_g_miss_num_map(ddx_saov_rec.realized_gain_ccid);
    p6_a8 := rosetta_g_miss_num_map(ddx_saov_rec.realized_loss_ccid);
    p6_a9 := rosetta_g_miss_num_map(ddx_saov_rec.tax_ccid);
    p6_a10 := rosetta_g_miss_num_map(ddx_saov_rec.cross_currency_ccid);
    p6_a11 := rosetta_g_miss_num_map(ddx_saov_rec.rounding_ccid);
    p6_a12 := rosetta_g_miss_num_map(ddx_saov_rec.ar_clearing_ccid);
    p6_a13 := rosetta_g_miss_num_map(ddx_saov_rec.payables_ccid);
    p6_a14 := rosetta_g_miss_num_map(ddx_saov_rec.liablity_ccid);
    p6_a15 := rosetta_g_miss_num_map(ddx_saov_rec.pre_payment_ccid);
    p6_a16 := rosetta_g_miss_num_map(ddx_saov_rec.fut_date_pay_ccid);
    p6_a17 := rosetta_g_miss_num_map(ddx_saov_rec.dis_taken_ccid);
    p6_a18 := rosetta_g_miss_num_map(ddx_saov_rec.ap_clearing_ccid);
    p6_a19 := ddx_saov_rec.ael_rounding_rule;
    p6_a20 := rosetta_g_miss_num_map(ddx_saov_rec.ael_precision);
    p6_a21 := rosetta_g_miss_num_map(ddx_saov_rec.ael_min_acct_unit);
    p6_a22 := ddx_saov_rec.cc_rounding_rule;
    p6_a23 := rosetta_g_miss_num_map(ddx_saov_rec.cc_precision);
    p6_a24 := rosetta_g_miss_num_map(ddx_saov_rec.cc_min_acct_unit);
    p6_a25 := ddx_saov_rec.attribute_category;
    p6_a26 := ddx_saov_rec.attribute1;
    p6_a27 := ddx_saov_rec.attribute2;
    p6_a28 := ddx_saov_rec.attribute3;
    p6_a29 := ddx_saov_rec.attribute4;
    p6_a30 := ddx_saov_rec.attribute5;
    p6_a31 := ddx_saov_rec.attribute6;
    p6_a32 := ddx_saov_rec.attribute7;
    p6_a33 := ddx_saov_rec.attribute8;
    p6_a34 := ddx_saov_rec.attribute9;
    p6_a35 := ddx_saov_rec.attribute10;
    p6_a36 := ddx_saov_rec.attribute11;
    p6_a37 := ddx_saov_rec.attribute12;
    p6_a38 := ddx_saov_rec.attribute13;
    p6_a39 := ddx_saov_rec.attribute14;
    p6_a40 := ddx_saov_rec.attribute15;
    p6_a41 := rosetta_g_miss_num_map(ddx_saov_rec.org_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_saov_rec.created_by);
    p6_a43 := ddx_saov_rec.creation_date;
    p6_a44 := rosetta_g_miss_num_map(ddx_saov_rec.last_updated_by);
    p6_a45 := ddx_saov_rec.last_update_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_saov_rec.last_update_login);
    p6_a47 := ddx_saov_rec.cc_apply_rounding_difference;
    p6_a48 := ddx_saov_rec.ael_apply_rounding_difference;
    p6_a49 := rosetta_g_miss_num_map(ddx_saov_rec.accrual_reversal_days);
    p6_a50 := rosetta_g_miss_num_map(ddx_saov_rec.lke_hold_days);
    p6_a51 := ddx_saov_rec.stm_apply_rounding_difference;
    p6_a52 := ddx_saov_rec.stm_rounding_rule;
    p6_a53 := ddx_saov_rec.validate_khr_start_date;
    p6_a54 := ddx_saov_rec.account_derivation;
    p6_a55 := ddx_saov_rec.isg_arrears_pay_dates_option;
    p6_a56 := rosetta_g_miss_num_map(ddx_saov_rec.pay_dist_set_id);
    p6_a57 := ddx_saov_rec.secondary_rep_method;
    p6_a58 := ddx_saov_rec.amort_inc_adj_rev_dt_yn;
  end;

  procedure updt_system_acct_opt(p_api_version  NUMBER
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
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
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
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  DATE
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_saov_rec okl_system_acct_opt_pub.saov_rec_type;
    ddx_saov_rec okl_system_acct_opt_pub.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_saov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_saov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_saov_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a2);
    ddp_saov_rec.code_combination_id := rosetta_g_miss_num_map(p5_a3);
    ddp_saov_rec.cc_rep_currency_code := p5_a4;
    ddp_saov_rec.ael_rep_currency_code := p5_a5;
    ddp_saov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_saov_rec.realized_gain_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_saov_rec.realized_loss_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_saov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_saov_rec.cross_currency_ccid := rosetta_g_miss_num_map(p5_a10);
    ddp_saov_rec.rounding_ccid := rosetta_g_miss_num_map(p5_a11);
    ddp_saov_rec.ar_clearing_ccid := rosetta_g_miss_num_map(p5_a12);
    ddp_saov_rec.payables_ccid := rosetta_g_miss_num_map(p5_a13);
    ddp_saov_rec.liablity_ccid := rosetta_g_miss_num_map(p5_a14);
    ddp_saov_rec.pre_payment_ccid := rosetta_g_miss_num_map(p5_a15);
    ddp_saov_rec.fut_date_pay_ccid := rosetta_g_miss_num_map(p5_a16);
    ddp_saov_rec.dis_taken_ccid := rosetta_g_miss_num_map(p5_a17);
    ddp_saov_rec.ap_clearing_ccid := rosetta_g_miss_num_map(p5_a18);
    ddp_saov_rec.ael_rounding_rule := p5_a19;
    ddp_saov_rec.ael_precision := rosetta_g_miss_num_map(p5_a20);
    ddp_saov_rec.ael_min_acct_unit := rosetta_g_miss_num_map(p5_a21);
    ddp_saov_rec.cc_rounding_rule := p5_a22;
    ddp_saov_rec.cc_precision := rosetta_g_miss_num_map(p5_a23);
    ddp_saov_rec.cc_min_acct_unit := rosetta_g_miss_num_map(p5_a24);
    ddp_saov_rec.attribute_category := p5_a25;
    ddp_saov_rec.attribute1 := p5_a26;
    ddp_saov_rec.attribute2 := p5_a27;
    ddp_saov_rec.attribute3 := p5_a28;
    ddp_saov_rec.attribute4 := p5_a29;
    ddp_saov_rec.attribute5 := p5_a30;
    ddp_saov_rec.attribute6 := p5_a31;
    ddp_saov_rec.attribute7 := p5_a32;
    ddp_saov_rec.attribute8 := p5_a33;
    ddp_saov_rec.attribute9 := p5_a34;
    ddp_saov_rec.attribute10 := p5_a35;
    ddp_saov_rec.attribute11 := p5_a36;
    ddp_saov_rec.attribute12 := p5_a37;
    ddp_saov_rec.attribute13 := p5_a38;
    ddp_saov_rec.attribute14 := p5_a39;
    ddp_saov_rec.attribute15 := p5_a40;
    ddp_saov_rec.org_id := rosetta_g_miss_num_map(p5_a41);
    ddp_saov_rec.created_by := rosetta_g_miss_num_map(p5_a42);
    ddp_saov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_saov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a44);
    ddp_saov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_saov_rec.last_update_login := rosetta_g_miss_num_map(p5_a46);
    ddp_saov_rec.cc_apply_rounding_difference := p5_a47;
    ddp_saov_rec.ael_apply_rounding_difference := p5_a48;
    ddp_saov_rec.accrual_reversal_days := rosetta_g_miss_num_map(p5_a49);
    ddp_saov_rec.lke_hold_days := rosetta_g_miss_num_map(p5_a50);
    ddp_saov_rec.stm_apply_rounding_difference := p5_a51;
    ddp_saov_rec.stm_rounding_rule := p5_a52;
    ddp_saov_rec.validate_khr_start_date := p5_a53;
    ddp_saov_rec.account_derivation := p5_a54;
    ddp_saov_rec.isg_arrears_pay_dates_option := p5_a55;
    ddp_saov_rec.pay_dist_set_id := rosetta_g_miss_num_map(p5_a56);
    ddp_saov_rec.secondary_rep_method := p5_a57;
    ddp_saov_rec.amort_inc_adj_rev_dt_yn := p5_a58;


    -- here's the delegated call to the old PL/SQL routine
    okl_system_acct_opt_pub.updt_system_acct_opt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_rec,
      ddx_saov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_saov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_saov_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_saov_rec.set_of_books_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_saov_rec.code_combination_id);
    p6_a4 := ddx_saov_rec.cc_rep_currency_code;
    p6_a5 := ddx_saov_rec.ael_rep_currency_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_saov_rec.rec_ccid);
    p6_a7 := rosetta_g_miss_num_map(ddx_saov_rec.realized_gain_ccid);
    p6_a8 := rosetta_g_miss_num_map(ddx_saov_rec.realized_loss_ccid);
    p6_a9 := rosetta_g_miss_num_map(ddx_saov_rec.tax_ccid);
    p6_a10 := rosetta_g_miss_num_map(ddx_saov_rec.cross_currency_ccid);
    p6_a11 := rosetta_g_miss_num_map(ddx_saov_rec.rounding_ccid);
    p6_a12 := rosetta_g_miss_num_map(ddx_saov_rec.ar_clearing_ccid);
    p6_a13 := rosetta_g_miss_num_map(ddx_saov_rec.payables_ccid);
    p6_a14 := rosetta_g_miss_num_map(ddx_saov_rec.liablity_ccid);
    p6_a15 := rosetta_g_miss_num_map(ddx_saov_rec.pre_payment_ccid);
    p6_a16 := rosetta_g_miss_num_map(ddx_saov_rec.fut_date_pay_ccid);
    p6_a17 := rosetta_g_miss_num_map(ddx_saov_rec.dis_taken_ccid);
    p6_a18 := rosetta_g_miss_num_map(ddx_saov_rec.ap_clearing_ccid);
    p6_a19 := ddx_saov_rec.ael_rounding_rule;
    p6_a20 := rosetta_g_miss_num_map(ddx_saov_rec.ael_precision);
    p6_a21 := rosetta_g_miss_num_map(ddx_saov_rec.ael_min_acct_unit);
    p6_a22 := ddx_saov_rec.cc_rounding_rule;
    p6_a23 := rosetta_g_miss_num_map(ddx_saov_rec.cc_precision);
    p6_a24 := rosetta_g_miss_num_map(ddx_saov_rec.cc_min_acct_unit);
    p6_a25 := ddx_saov_rec.attribute_category;
    p6_a26 := ddx_saov_rec.attribute1;
    p6_a27 := ddx_saov_rec.attribute2;
    p6_a28 := ddx_saov_rec.attribute3;
    p6_a29 := ddx_saov_rec.attribute4;
    p6_a30 := ddx_saov_rec.attribute5;
    p6_a31 := ddx_saov_rec.attribute6;
    p6_a32 := ddx_saov_rec.attribute7;
    p6_a33 := ddx_saov_rec.attribute8;
    p6_a34 := ddx_saov_rec.attribute9;
    p6_a35 := ddx_saov_rec.attribute10;
    p6_a36 := ddx_saov_rec.attribute11;
    p6_a37 := ddx_saov_rec.attribute12;
    p6_a38 := ddx_saov_rec.attribute13;
    p6_a39 := ddx_saov_rec.attribute14;
    p6_a40 := ddx_saov_rec.attribute15;
    p6_a41 := rosetta_g_miss_num_map(ddx_saov_rec.org_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_saov_rec.created_by);
    p6_a43 := ddx_saov_rec.creation_date;
    p6_a44 := rosetta_g_miss_num_map(ddx_saov_rec.last_updated_by);
    p6_a45 := ddx_saov_rec.last_update_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_saov_rec.last_update_login);
    p6_a47 := ddx_saov_rec.cc_apply_rounding_difference;
    p6_a48 := ddx_saov_rec.ael_apply_rounding_difference;
    p6_a49 := rosetta_g_miss_num_map(ddx_saov_rec.accrual_reversal_days);
    p6_a50 := rosetta_g_miss_num_map(ddx_saov_rec.lke_hold_days);
    p6_a51 := ddx_saov_rec.stm_apply_rounding_difference;
    p6_a52 := ddx_saov_rec.stm_rounding_rule;
    p6_a53 := ddx_saov_rec.validate_khr_start_date;
    p6_a54 := ddx_saov_rec.account_derivation;
    p6_a55 := ddx_saov_rec.isg_arrears_pay_dates_option;
    p6_a56 := rosetta_g_miss_num_map(ddx_saov_rec.pay_dist_set_id);
    p6_a57 := ddx_saov_rec.secondary_rep_method;
    p6_a58 := ddx_saov_rec.amort_inc_adj_rev_dt_yn;
  end;

end okl_system_acct_opt_pub_w;

/
