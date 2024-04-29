--------------------------------------------------------
--  DDL for Package Body CN_WKSHT_CT_UP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_WKSHT_CT_UP_PUB_W" as
  /* $Header: cnwwkcdb.pls 120.0 2005/09/26 15:09:28 fmburu noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure apply_payment_plan_upd(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_srp_pmt_asgn_id  NUMBER
    , p_payrun_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  DATE
    , p10_a4  DATE
    , p10_a5  NUMBER
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , p11_a0  VARCHAR2
    , p11_a1  VARCHAR2
    , p11_a2  VARCHAR2
    , p11_a3  DATE
    , p11_a4  DATE
    , p11_a5  NUMBER
    , p11_a6  NUMBER
    , p11_a7  NUMBER
    , p11_a8  VARCHAR2
    , p11_a9  VARCHAR2
    , p11_a10  VARCHAR2
    , p11_a11  VARCHAR2
    , p11_a12  VARCHAR2
    , p11_a13  VARCHAR2
    , p11_a14  VARCHAR2
    , p11_a15  VARCHAR2
    , p11_a16  VARCHAR2
    , p11_a17  VARCHAR2
    , p11_a18  VARCHAR2
    , p11_a19  VARCHAR2
    , p11_a20  VARCHAR2
    , p11_a21  VARCHAR2
    , p11_a22  VARCHAR2
    , p11_a23  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_old_srp_pmt_plans_rec cn_wksht_ct_up_pub.srp_pmt_plans_rec_type;
    ddp_srp_pmt_plans_rec cn_wksht_ct_up_pub.srp_pmt_plans_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_old_srp_pmt_plans_rec.pmt_plan_name := p10_a0;
    ddp_old_srp_pmt_plans_rec.salesrep_type := p10_a1;
    ddp_old_srp_pmt_plans_rec.emp_num := p10_a2;
    ddp_old_srp_pmt_plans_rec.start_date := rosetta_g_miss_date_in_map(p10_a3);
    ddp_old_srp_pmt_plans_rec.end_date := rosetta_g_miss_date_in_map(p10_a4);
    ddp_old_srp_pmt_plans_rec.minimum_amount := p10_a5;
    ddp_old_srp_pmt_plans_rec.maximum_amount := p10_a6;
    ddp_old_srp_pmt_plans_rec.max_recovery_amount := p10_a7;
    ddp_old_srp_pmt_plans_rec.attribute_category := p10_a8;
    ddp_old_srp_pmt_plans_rec.attribute1 := p10_a9;
    ddp_old_srp_pmt_plans_rec.attribute2 := p10_a10;
    ddp_old_srp_pmt_plans_rec.attribute3 := p10_a11;
    ddp_old_srp_pmt_plans_rec.attribute4 := p10_a12;
    ddp_old_srp_pmt_plans_rec.attribute5 := p10_a13;
    ddp_old_srp_pmt_plans_rec.attribute6 := p10_a14;
    ddp_old_srp_pmt_plans_rec.attribute7 := p10_a15;
    ddp_old_srp_pmt_plans_rec.attribute8 := p10_a16;
    ddp_old_srp_pmt_plans_rec.attribute9 := p10_a17;
    ddp_old_srp_pmt_plans_rec.attribute10 := p10_a18;
    ddp_old_srp_pmt_plans_rec.attribute11 := p10_a19;
    ddp_old_srp_pmt_plans_rec.attribute12 := p10_a20;
    ddp_old_srp_pmt_plans_rec.attribute13 := p10_a21;
    ddp_old_srp_pmt_plans_rec.attribute14 := p10_a22;
    ddp_old_srp_pmt_plans_rec.attribute15 := p10_a23;

    ddp_srp_pmt_plans_rec.pmt_plan_name := p11_a0;
    ddp_srp_pmt_plans_rec.salesrep_type := p11_a1;
    ddp_srp_pmt_plans_rec.emp_num := p11_a2;
    ddp_srp_pmt_plans_rec.start_date := rosetta_g_miss_date_in_map(p11_a3);
    ddp_srp_pmt_plans_rec.end_date := rosetta_g_miss_date_in_map(p11_a4);
    ddp_srp_pmt_plans_rec.minimum_amount := p11_a5;
    ddp_srp_pmt_plans_rec.maximum_amount := p11_a6;
    ddp_srp_pmt_plans_rec.max_recovery_amount := p11_a7;
    ddp_srp_pmt_plans_rec.attribute_category := p11_a8;
    ddp_srp_pmt_plans_rec.attribute1 := p11_a9;
    ddp_srp_pmt_plans_rec.attribute2 := p11_a10;
    ddp_srp_pmt_plans_rec.attribute3 := p11_a11;
    ddp_srp_pmt_plans_rec.attribute4 := p11_a12;
    ddp_srp_pmt_plans_rec.attribute5 := p11_a13;
    ddp_srp_pmt_plans_rec.attribute6 := p11_a14;
    ddp_srp_pmt_plans_rec.attribute7 := p11_a15;
    ddp_srp_pmt_plans_rec.attribute8 := p11_a16;
    ddp_srp_pmt_plans_rec.attribute9 := p11_a17;
    ddp_srp_pmt_plans_rec.attribute10 := p11_a18;
    ddp_srp_pmt_plans_rec.attribute11 := p11_a19;
    ddp_srp_pmt_plans_rec.attribute12 := p11_a20;
    ddp_srp_pmt_plans_rec.attribute13 := p11_a21;
    ddp_srp_pmt_plans_rec.attribute14 := p11_a22;
    ddp_srp_pmt_plans_rec.attribute15 := p11_a23;



    -- here's the delegated call to the old PL/SQL routine
    cn_wksht_ct_up_pub.apply_payment_plan_upd(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_salesrep_id,
      p_srp_pmt_asgn_id,
      p_payrun_id,
      ddp_old_srp_pmt_plans_rec,
      ddp_srp_pmt_plans_rec,
      x_status,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure apply_payment_plan_cre(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_srp_pmt_asgn_id  NUMBER
    , p_payrun_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  DATE
    , p10_a4  DATE
    , p10_a5  NUMBER
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_srp_pmt_plans_rec cn_wksht_ct_up_pub.srp_pmt_plans_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_srp_pmt_plans_rec.pmt_plan_name := p10_a0;
    ddp_srp_pmt_plans_rec.salesrep_type := p10_a1;
    ddp_srp_pmt_plans_rec.emp_num := p10_a2;
    ddp_srp_pmt_plans_rec.start_date := rosetta_g_miss_date_in_map(p10_a3);
    ddp_srp_pmt_plans_rec.end_date := rosetta_g_miss_date_in_map(p10_a4);
    ddp_srp_pmt_plans_rec.minimum_amount := p10_a5;
    ddp_srp_pmt_plans_rec.maximum_amount := p10_a6;
    ddp_srp_pmt_plans_rec.max_recovery_amount := p10_a7;
    ddp_srp_pmt_plans_rec.attribute_category := p10_a8;
    ddp_srp_pmt_plans_rec.attribute1 := p10_a9;
    ddp_srp_pmt_plans_rec.attribute2 := p10_a10;
    ddp_srp_pmt_plans_rec.attribute3 := p10_a11;
    ddp_srp_pmt_plans_rec.attribute4 := p10_a12;
    ddp_srp_pmt_plans_rec.attribute5 := p10_a13;
    ddp_srp_pmt_plans_rec.attribute6 := p10_a14;
    ddp_srp_pmt_plans_rec.attribute7 := p10_a15;
    ddp_srp_pmt_plans_rec.attribute8 := p10_a16;
    ddp_srp_pmt_plans_rec.attribute9 := p10_a17;
    ddp_srp_pmt_plans_rec.attribute10 := p10_a18;
    ddp_srp_pmt_plans_rec.attribute11 := p10_a19;
    ddp_srp_pmt_plans_rec.attribute12 := p10_a20;
    ddp_srp_pmt_plans_rec.attribute13 := p10_a21;
    ddp_srp_pmt_plans_rec.attribute14 := p10_a22;
    ddp_srp_pmt_plans_rec.attribute15 := p10_a23;



    -- here's the delegated call to the old PL/SQL routine
    cn_wksht_ct_up_pub.apply_payment_plan_cre(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_salesrep_id,
      p_srp_pmt_asgn_id,
      p_payrun_id,
      ddp_srp_pmt_plans_rec,
      x_status,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure apply_payment_plan_del(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_srp_pmt_asgn_id  NUMBER
    , p_payrun_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  DATE
    , p10_a4  DATE
    , p10_a5  NUMBER
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_srp_pmt_plans_rec cn_wksht_ct_up_pub.srp_pmt_plans_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_srp_pmt_plans_rec.pmt_plan_name := p10_a0;
    ddp_srp_pmt_plans_rec.salesrep_type := p10_a1;
    ddp_srp_pmt_plans_rec.emp_num := p10_a2;
    ddp_srp_pmt_plans_rec.start_date := rosetta_g_miss_date_in_map(p10_a3);
    ddp_srp_pmt_plans_rec.end_date := rosetta_g_miss_date_in_map(p10_a4);
    ddp_srp_pmt_plans_rec.minimum_amount := p10_a5;
    ddp_srp_pmt_plans_rec.maximum_amount := p10_a6;
    ddp_srp_pmt_plans_rec.max_recovery_amount := p10_a7;
    ddp_srp_pmt_plans_rec.attribute_category := p10_a8;
    ddp_srp_pmt_plans_rec.attribute1 := p10_a9;
    ddp_srp_pmt_plans_rec.attribute2 := p10_a10;
    ddp_srp_pmt_plans_rec.attribute3 := p10_a11;
    ddp_srp_pmt_plans_rec.attribute4 := p10_a12;
    ddp_srp_pmt_plans_rec.attribute5 := p10_a13;
    ddp_srp_pmt_plans_rec.attribute6 := p10_a14;
    ddp_srp_pmt_plans_rec.attribute7 := p10_a15;
    ddp_srp_pmt_plans_rec.attribute8 := p10_a16;
    ddp_srp_pmt_plans_rec.attribute9 := p10_a17;
    ddp_srp_pmt_plans_rec.attribute10 := p10_a18;
    ddp_srp_pmt_plans_rec.attribute11 := p10_a19;
    ddp_srp_pmt_plans_rec.attribute12 := p10_a20;
    ddp_srp_pmt_plans_rec.attribute13 := p10_a21;
    ddp_srp_pmt_plans_rec.attribute14 := p10_a22;
    ddp_srp_pmt_plans_rec.attribute15 := p10_a23;



    -- here's the delegated call to the old PL/SQL routine
    cn_wksht_ct_up_pub.apply_payment_plan_del(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_salesrep_id,
      p_srp_pmt_asgn_id,
      p_payrun_id,
      ddp_srp_pmt_plans_rec,
      x_status,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end cn_wksht_ct_up_pub_w;

/
