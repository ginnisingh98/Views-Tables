--------------------------------------------------------
--  DDL for Package Body CN_PAYRUN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYRUN_PVT_W" as
  /* $Header: cnwprunb.pls 120.5 2005/09/29 19:49 rnagired ship $ */
  procedure create_payrun(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  DATE
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  DATE
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  )

  as
    ddp_payrun_rec cn_payrun_pvt.payrun_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_payrun_rec.payrun_id := p7_a0;
    ddp_payrun_rec.name := p7_a1;
    ddp_payrun_rec.pay_date := p7_a2;
    ddp_payrun_rec.accounting_period_id := p7_a3;
    ddp_payrun_rec.batch_id := p7_a4;
    ddp_payrun_rec.status := p7_a5;
    ddp_payrun_rec.pay_period_id := p7_a6;
    ddp_payrun_rec.pay_period_start_date := p7_a7;
    ddp_payrun_rec.pay_period_end_date := p7_a8;
    ddp_payrun_rec.incentive_type_code := p7_a9;
    ddp_payrun_rec.pay_group_id := p7_a10;
    ddp_payrun_rec.org_id := p7_a11;
    ddp_payrun_rec.object_version_number := p7_a12;



    -- here's the delegated call to the old PL/SQL routine
    cn_payrun_pvt.create_payrun(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_payrun_rec,
      x_loading_status,
      x_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_payrun_rec.payrun_id;
    p7_a1 := ddp_payrun_rec.name;
    p7_a2 := ddp_payrun_rec.pay_date;
    p7_a3 := ddp_payrun_rec.accounting_period_id;
    p7_a4 := ddp_payrun_rec.batch_id;
    p7_a5 := ddp_payrun_rec.status;
    p7_a6 := ddp_payrun_rec.pay_period_id;
    p7_a7 := ddp_payrun_rec.pay_period_start_date;
    p7_a8 := ddp_payrun_rec.pay_period_end_date;
    p7_a9 := ddp_payrun_rec.incentive_type_code;
    p7_a10 := ddp_payrun_rec.pay_group_id;
    p7_a11 := ddp_payrun_rec.org_id;
    p7_a12 := ddp_payrun_rec.object_version_number;


  end;

end cn_payrun_pvt_w;

/
