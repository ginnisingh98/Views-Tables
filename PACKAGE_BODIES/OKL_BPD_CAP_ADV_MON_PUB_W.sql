--------------------------------------------------------
--  DDL for Package Body OKL_BPD_CAP_ADV_MON_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_CAP_ADV_MON_PUB_W" as
  /* $Header: OKLUAMSB.pls 120.1 2005/10/30 04:02:50 appldev noship $ */
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

  procedure handle_advanced_manual_pay(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_adv_rcpt_rec okl_bpd_cap_adv_mon_pub.adv_rcpt_rec;
    ddx_adv_rcpt_rec okl_bpd_cap_adv_mon_pub.adv_rcpt_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_adv_rcpt_rec.currency_code := p5_a0;
    ddp_adv_rcpt_rec.currency_conv_type := p5_a1;
    ddp_adv_rcpt_rec.currency_conv_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_adv_rcpt_rec.currency_conv_rate := rosetta_g_miss_num_map(p5_a3);
    ddp_adv_rcpt_rec.irm_id := rosetta_g_miss_num_map(p5_a4);
    ddp_adv_rcpt_rec.check_number := p5_a5;
    ddp_adv_rcpt_rec.rcpt_amount := rosetta_g_miss_num_map(p5_a6);
    ddp_adv_rcpt_rec.contract_id := rosetta_g_miss_num_map(p5_a7);
    ddp_adv_rcpt_rec.contract_num := p5_a8;
    ddp_adv_rcpt_rec.customer_id := rosetta_g_miss_num_map(p5_a9);
    ddp_adv_rcpt_rec.customer_num := p5_a10;
    ddp_adv_rcpt_rec.gl_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_adv_rcpt_rec.receipt_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_adv_rcpt_rec.comments := p5_a13;
    ddp_adv_rcpt_rec.rct_id := rosetta_g_miss_num_map(p5_a14);
    ddp_adv_rcpt_rec.xcr_id := rosetta_g_miss_num_map(p5_a15);
    ddp_adv_rcpt_rec.icr_id := rosetta_g_miss_num_map(p5_a16);
    ddp_adv_rcpt_rec.receipt_type := p5_a17;
    ddp_adv_rcpt_rec.fully_applied_flag := p5_a18;
    ddp_adv_rcpt_rec.expired_flag := p5_a19;


    -- here's the delegated call to the old PL/SQL routine
    okl_bpd_cap_adv_mon_pub.handle_advanced_manual_pay(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adv_rcpt_rec,
      ddx_adv_rcpt_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_adv_rcpt_rec.currency_code;
    p6_a1 := ddx_adv_rcpt_rec.currency_conv_type;
    p6_a2 := ddx_adv_rcpt_rec.currency_conv_date;
    p6_a3 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.currency_conv_rate);
    p6_a4 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.irm_id);
    p6_a5 := ddx_adv_rcpt_rec.check_number;
    p6_a6 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.rcpt_amount);
    p6_a7 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.contract_id);
    p6_a8 := ddx_adv_rcpt_rec.contract_num;
    p6_a9 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.customer_id);
    p6_a10 := ddx_adv_rcpt_rec.customer_num;
    p6_a11 := ddx_adv_rcpt_rec.gl_date;
    p6_a12 := ddx_adv_rcpt_rec.receipt_date;
    p6_a13 := ddx_adv_rcpt_rec.comments;
    p6_a14 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.rct_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.xcr_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_adv_rcpt_rec.icr_id);
    p6_a17 := ddx_adv_rcpt_rec.receipt_type;
    p6_a18 := ddx_adv_rcpt_rec.fully_applied_flag;
    p6_a19 := ddx_adv_rcpt_rec.expired_flag;
  end;

end okl_bpd_cap_adv_mon_pub_w;

/
