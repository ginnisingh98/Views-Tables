--------------------------------------------------------
--  DDL for Package Body CN_PMTPLAN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMTPLAN_PVT_W" as
  /* $Header: cnwpplnb.pls 120.3 2005/09/14 03:40:35 vensrini noship $ */
  procedure create_pmtplan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  DATE
    , p7_a11 in out nocopy  DATE
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  )

  as
    ddp_pmtplan_rec cn_pmtplan_pvt.pmtplan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pmtplan_rec.org_id := p7_a0;
    ddp_pmtplan_rec.pmt_plan_id := p7_a1;
    ddp_pmtplan_rec.name := p7_a2;
    ddp_pmtplan_rec.minimum_amount := p7_a3;
    ddp_pmtplan_rec.maximum_amount := p7_a4;
    ddp_pmtplan_rec.min_rec_flag := p7_a5;
    ddp_pmtplan_rec.max_rec_flag := p7_a6;
    ddp_pmtplan_rec.max_recovery_amount := p7_a7;
    ddp_pmtplan_rec.credit_type_name := p7_a8;
    ddp_pmtplan_rec.pay_interval_type_name := p7_a9;
    ddp_pmtplan_rec.start_date := p7_a10;
    ddp_pmtplan_rec.end_date := p7_a11;
    ddp_pmtplan_rec.object_version_number := p7_a12;
    ddp_pmtplan_rec.recoverable_interval_type := p7_a13;
    ddp_pmtplan_rec.pay_against_commission := p7_a14;
    ddp_pmtplan_rec.attribute_category := p7_a15;
    ddp_pmtplan_rec.attribute1 := p7_a16;
    ddp_pmtplan_rec.attribute2 := p7_a17;
    ddp_pmtplan_rec.attribute3 := p7_a18;
    ddp_pmtplan_rec.attribute4 := p7_a19;
    ddp_pmtplan_rec.attribute5 := p7_a20;
    ddp_pmtplan_rec.attribute6 := p7_a21;
    ddp_pmtplan_rec.attribute7 := p7_a22;
    ddp_pmtplan_rec.attribute8 := p7_a23;
    ddp_pmtplan_rec.attribute9 := p7_a24;
    ddp_pmtplan_rec.attribute10 := p7_a25;
    ddp_pmtplan_rec.attribute11 := p7_a26;
    ddp_pmtplan_rec.attribute12 := p7_a27;
    ddp_pmtplan_rec.attribute13 := p7_a28;
    ddp_pmtplan_rec.attribute14 := p7_a29;
    ddp_pmtplan_rec.attribute15 := p7_a30;
    ddp_pmtplan_rec.payment_group_code := p7_a31;
    ddp_pmtplan_rec.operation_mode := p7_a32;



    -- here's the delegated call to the old PL/SQL routine
    cn_pmtplan_pvt.create_pmtplan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pmtplan_rec,
      x_loading_status,
      x_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_pmtplan_rec.org_id;
    p7_a1 := ddp_pmtplan_rec.pmt_plan_id;
    p7_a2 := ddp_pmtplan_rec.name;
    p7_a3 := ddp_pmtplan_rec.minimum_amount;
    p7_a4 := ddp_pmtplan_rec.maximum_amount;
    p7_a5 := ddp_pmtplan_rec.min_rec_flag;
    p7_a6 := ddp_pmtplan_rec.max_rec_flag;
    p7_a7 := ddp_pmtplan_rec.max_recovery_amount;
    p7_a8 := ddp_pmtplan_rec.credit_type_name;
    p7_a9 := ddp_pmtplan_rec.pay_interval_type_name;
    p7_a10 := ddp_pmtplan_rec.start_date;
    p7_a11 := ddp_pmtplan_rec.end_date;
    p7_a12 := ddp_pmtplan_rec.object_version_number;
    p7_a13 := ddp_pmtplan_rec.recoverable_interval_type;
    p7_a14 := ddp_pmtplan_rec.pay_against_commission;
    p7_a15 := ddp_pmtplan_rec.attribute_category;
    p7_a16 := ddp_pmtplan_rec.attribute1;
    p7_a17 := ddp_pmtplan_rec.attribute2;
    p7_a18 := ddp_pmtplan_rec.attribute3;
    p7_a19 := ddp_pmtplan_rec.attribute4;
    p7_a20 := ddp_pmtplan_rec.attribute5;
    p7_a21 := ddp_pmtplan_rec.attribute6;
    p7_a22 := ddp_pmtplan_rec.attribute7;
    p7_a23 := ddp_pmtplan_rec.attribute8;
    p7_a24 := ddp_pmtplan_rec.attribute9;
    p7_a25 := ddp_pmtplan_rec.attribute10;
    p7_a26 := ddp_pmtplan_rec.attribute11;
    p7_a27 := ddp_pmtplan_rec.attribute12;
    p7_a28 := ddp_pmtplan_rec.attribute13;
    p7_a29 := ddp_pmtplan_rec.attribute14;
    p7_a30 := ddp_pmtplan_rec.attribute15;
    p7_a31 := ddp_pmtplan_rec.payment_group_code;
    p7_a32 := ddp_pmtplan_rec.operation_mode;


  end;

  procedure update_pmtplan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  DATE
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  DATE
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
    , p8_a30 in out nocopy  VARCHAR2
    , p8_a31 in out nocopy  VARCHAR2
    , p8_a32 in out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_old_pmtplan_rec cn_pmtplan_pvt.pmtplan_rec_type;
    ddp_pmtplan_rec cn_pmtplan_pvt.pmtplan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_old_pmtplan_rec.org_id := p7_a0;
    ddp_old_pmtplan_rec.pmt_plan_id := p7_a1;
    ddp_old_pmtplan_rec.name := p7_a2;
    ddp_old_pmtplan_rec.minimum_amount := p7_a3;
    ddp_old_pmtplan_rec.maximum_amount := p7_a4;
    ddp_old_pmtplan_rec.min_rec_flag := p7_a5;
    ddp_old_pmtplan_rec.max_rec_flag := p7_a6;
    ddp_old_pmtplan_rec.max_recovery_amount := p7_a7;
    ddp_old_pmtplan_rec.credit_type_name := p7_a8;
    ddp_old_pmtplan_rec.pay_interval_type_name := p7_a9;
    ddp_old_pmtplan_rec.start_date := p7_a10;
    ddp_old_pmtplan_rec.end_date := p7_a11;
    ddp_old_pmtplan_rec.object_version_number := p7_a12;
    ddp_old_pmtplan_rec.recoverable_interval_type := p7_a13;
    ddp_old_pmtplan_rec.pay_against_commission := p7_a14;
    ddp_old_pmtplan_rec.attribute_category := p7_a15;
    ddp_old_pmtplan_rec.attribute1 := p7_a16;
    ddp_old_pmtplan_rec.attribute2 := p7_a17;
    ddp_old_pmtplan_rec.attribute3 := p7_a18;
    ddp_old_pmtplan_rec.attribute4 := p7_a19;
    ddp_old_pmtplan_rec.attribute5 := p7_a20;
    ddp_old_pmtplan_rec.attribute6 := p7_a21;
    ddp_old_pmtplan_rec.attribute7 := p7_a22;
    ddp_old_pmtplan_rec.attribute8 := p7_a23;
    ddp_old_pmtplan_rec.attribute9 := p7_a24;
    ddp_old_pmtplan_rec.attribute10 := p7_a25;
    ddp_old_pmtplan_rec.attribute11 := p7_a26;
    ddp_old_pmtplan_rec.attribute12 := p7_a27;
    ddp_old_pmtplan_rec.attribute13 := p7_a28;
    ddp_old_pmtplan_rec.attribute14 := p7_a29;
    ddp_old_pmtplan_rec.attribute15 := p7_a30;
    ddp_old_pmtplan_rec.payment_group_code := p7_a31;
    ddp_old_pmtplan_rec.operation_mode := p7_a32;

    ddp_pmtplan_rec.org_id := p8_a0;
    ddp_pmtplan_rec.pmt_plan_id := p8_a1;
    ddp_pmtplan_rec.name := p8_a2;
    ddp_pmtplan_rec.minimum_amount := p8_a3;
    ddp_pmtplan_rec.maximum_amount := p8_a4;
    ddp_pmtplan_rec.min_rec_flag := p8_a5;
    ddp_pmtplan_rec.max_rec_flag := p8_a6;
    ddp_pmtplan_rec.max_recovery_amount := p8_a7;
    ddp_pmtplan_rec.credit_type_name := p8_a8;
    ddp_pmtplan_rec.pay_interval_type_name := p8_a9;
    ddp_pmtplan_rec.start_date := p8_a10;
    ddp_pmtplan_rec.end_date := p8_a11;
    ddp_pmtplan_rec.object_version_number := p8_a12;
    ddp_pmtplan_rec.recoverable_interval_type := p8_a13;
    ddp_pmtplan_rec.pay_against_commission := p8_a14;
    ddp_pmtplan_rec.attribute_category := p8_a15;
    ddp_pmtplan_rec.attribute1 := p8_a16;
    ddp_pmtplan_rec.attribute2 := p8_a17;
    ddp_pmtplan_rec.attribute3 := p8_a18;
    ddp_pmtplan_rec.attribute4 := p8_a19;
    ddp_pmtplan_rec.attribute5 := p8_a20;
    ddp_pmtplan_rec.attribute6 := p8_a21;
    ddp_pmtplan_rec.attribute7 := p8_a22;
    ddp_pmtplan_rec.attribute8 := p8_a23;
    ddp_pmtplan_rec.attribute9 := p8_a24;
    ddp_pmtplan_rec.attribute10 := p8_a25;
    ddp_pmtplan_rec.attribute11 := p8_a26;
    ddp_pmtplan_rec.attribute12 := p8_a27;
    ddp_pmtplan_rec.attribute13 := p8_a28;
    ddp_pmtplan_rec.attribute14 := p8_a29;
    ddp_pmtplan_rec.attribute15 := p8_a30;
    ddp_pmtplan_rec.payment_group_code := p8_a31;
    ddp_pmtplan_rec.operation_mode := p8_a32;



    -- here's the delegated call to the old PL/SQL routine
    cn_pmtplan_pvt.update_pmtplan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_old_pmtplan_rec,
      ddp_pmtplan_rec,
      x_status,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_pmtplan_rec.org_id;
    p8_a1 := ddp_pmtplan_rec.pmt_plan_id;
    p8_a2 := ddp_pmtplan_rec.name;
    p8_a3 := ddp_pmtplan_rec.minimum_amount;
    p8_a4 := ddp_pmtplan_rec.maximum_amount;
    p8_a5 := ddp_pmtplan_rec.min_rec_flag;
    p8_a6 := ddp_pmtplan_rec.max_rec_flag;
    p8_a7 := ddp_pmtplan_rec.max_recovery_amount;
    p8_a8 := ddp_pmtplan_rec.credit_type_name;
    p8_a9 := ddp_pmtplan_rec.pay_interval_type_name;
    p8_a10 := ddp_pmtplan_rec.start_date;
    p8_a11 := ddp_pmtplan_rec.end_date;
    p8_a12 := ddp_pmtplan_rec.object_version_number;
    p8_a13 := ddp_pmtplan_rec.recoverable_interval_type;
    p8_a14 := ddp_pmtplan_rec.pay_against_commission;
    p8_a15 := ddp_pmtplan_rec.attribute_category;
    p8_a16 := ddp_pmtplan_rec.attribute1;
    p8_a17 := ddp_pmtplan_rec.attribute2;
    p8_a18 := ddp_pmtplan_rec.attribute3;
    p8_a19 := ddp_pmtplan_rec.attribute4;
    p8_a20 := ddp_pmtplan_rec.attribute5;
    p8_a21 := ddp_pmtplan_rec.attribute6;
    p8_a22 := ddp_pmtplan_rec.attribute7;
    p8_a23 := ddp_pmtplan_rec.attribute8;
    p8_a24 := ddp_pmtplan_rec.attribute9;
    p8_a25 := ddp_pmtplan_rec.attribute10;
    p8_a26 := ddp_pmtplan_rec.attribute11;
    p8_a27 := ddp_pmtplan_rec.attribute12;
    p8_a28 := ddp_pmtplan_rec.attribute13;
    p8_a29 := ddp_pmtplan_rec.attribute14;
    p8_a30 := ddp_pmtplan_rec.attribute15;
    p8_a31 := ddp_pmtplan_rec.payment_group_code;
    p8_a32 := ddp_pmtplan_rec.operation_mode;


  end;

  procedure delete_pmtplan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  DATE
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_pmtplan_rec cn_pmtplan_pvt.pmtplan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pmtplan_rec.org_id := p7_a0;
    ddp_pmtplan_rec.pmt_plan_id := p7_a1;
    ddp_pmtplan_rec.name := p7_a2;
    ddp_pmtplan_rec.minimum_amount := p7_a3;
    ddp_pmtplan_rec.maximum_amount := p7_a4;
    ddp_pmtplan_rec.min_rec_flag := p7_a5;
    ddp_pmtplan_rec.max_rec_flag := p7_a6;
    ddp_pmtplan_rec.max_recovery_amount := p7_a7;
    ddp_pmtplan_rec.credit_type_name := p7_a8;
    ddp_pmtplan_rec.pay_interval_type_name := p7_a9;
    ddp_pmtplan_rec.start_date := p7_a10;
    ddp_pmtplan_rec.end_date := p7_a11;
    ddp_pmtplan_rec.object_version_number := p7_a12;
    ddp_pmtplan_rec.recoverable_interval_type := p7_a13;
    ddp_pmtplan_rec.pay_against_commission := p7_a14;
    ddp_pmtplan_rec.attribute_category := p7_a15;
    ddp_pmtplan_rec.attribute1 := p7_a16;
    ddp_pmtplan_rec.attribute2 := p7_a17;
    ddp_pmtplan_rec.attribute3 := p7_a18;
    ddp_pmtplan_rec.attribute4 := p7_a19;
    ddp_pmtplan_rec.attribute5 := p7_a20;
    ddp_pmtplan_rec.attribute6 := p7_a21;
    ddp_pmtplan_rec.attribute7 := p7_a22;
    ddp_pmtplan_rec.attribute8 := p7_a23;
    ddp_pmtplan_rec.attribute9 := p7_a24;
    ddp_pmtplan_rec.attribute10 := p7_a25;
    ddp_pmtplan_rec.attribute11 := p7_a26;
    ddp_pmtplan_rec.attribute12 := p7_a27;
    ddp_pmtplan_rec.attribute13 := p7_a28;
    ddp_pmtplan_rec.attribute14 := p7_a29;
    ddp_pmtplan_rec.attribute15 := p7_a30;
    ddp_pmtplan_rec.payment_group_code := p7_a31;
    ddp_pmtplan_rec.operation_mode := p7_a32;



    -- here's the delegated call to the old PL/SQL routine
    cn_pmtplan_pvt.delete_pmtplan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pmtplan_rec,
      x_status,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end cn_pmtplan_pvt_w;

/
