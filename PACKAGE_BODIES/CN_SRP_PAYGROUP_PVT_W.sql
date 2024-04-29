--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYGROUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYGROUP_PVT_W" as
  /* $Header: cnwsdpgb.pls 120.1 2005/09/14 03:43:19 vensrini noship $ */
  procedure create_srp_pay_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  DATE
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  VARCHAR2
    , p8_a12 in out nocopy  VARCHAR2
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
  )

  as
    ddp_paygroup_assign_rec cn_srp_paygroup_pvt.paygroup_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_paygroup_assign_rec.srp_pay_group_id := p8_a0;
    ddp_paygroup_assign_rec.pay_group_id := p8_a1;
    ddp_paygroup_assign_rec.salesrep_id := p8_a2;
    ddp_paygroup_assign_rec.assignment_start_date := p8_a3;
    ddp_paygroup_assign_rec.assignment_end_date := p8_a4;
    ddp_paygroup_assign_rec.lock_flag := p8_a5;
    ddp_paygroup_assign_rec.role_pay_group_id := p8_a6;
    ddp_paygroup_assign_rec.org_id := p8_a7;
    ddp_paygroup_assign_rec.object_version_number := p8_a8;
    ddp_paygroup_assign_rec.attribute_category := p8_a9;
    ddp_paygroup_assign_rec.attribute1 := p8_a10;
    ddp_paygroup_assign_rec.attribute2 := p8_a11;
    ddp_paygroup_assign_rec.attribute3 := p8_a12;
    ddp_paygroup_assign_rec.attribute4 := p8_a13;
    ddp_paygroup_assign_rec.attribute5 := p8_a14;
    ddp_paygroup_assign_rec.attribute6 := p8_a15;
    ddp_paygroup_assign_rec.attribute7 := p8_a16;
    ddp_paygroup_assign_rec.attribute8 := p8_a17;
    ddp_paygroup_assign_rec.attribute9 := p8_a18;
    ddp_paygroup_assign_rec.attribute10 := p8_a19;
    ddp_paygroup_assign_rec.attribute11 := p8_a20;
    ddp_paygroup_assign_rec.attribute12 := p8_a21;
    ddp_paygroup_assign_rec.attribute13 := p8_a22;
    ddp_paygroup_assign_rec.attribute14 := p8_a23;
    ddp_paygroup_assign_rec.attribute15 := p8_a24;

    -- here's the delegated call to the old PL/SQL routine
    cn_srp_paygroup_pvt.create_srp_pay_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_paygroup_assign_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_paygroup_assign_rec.srp_pay_group_id;
    p8_a1 := ddp_paygroup_assign_rec.pay_group_id;
    p8_a2 := ddp_paygroup_assign_rec.salesrep_id;
    p8_a3 := ddp_paygroup_assign_rec.assignment_start_date;
    p8_a4 := ddp_paygroup_assign_rec.assignment_end_date;
    p8_a5 := ddp_paygroup_assign_rec.lock_flag;
    p8_a6 := ddp_paygroup_assign_rec.role_pay_group_id;
    p8_a7 := ddp_paygroup_assign_rec.org_id;
    p8_a8 := ddp_paygroup_assign_rec.object_version_number;
    p8_a9 := ddp_paygroup_assign_rec.attribute_category;
    p8_a10 := ddp_paygroup_assign_rec.attribute1;
    p8_a11 := ddp_paygroup_assign_rec.attribute2;
    p8_a12 := ddp_paygroup_assign_rec.attribute3;
    p8_a13 := ddp_paygroup_assign_rec.attribute4;
    p8_a14 := ddp_paygroup_assign_rec.attribute5;
    p8_a15 := ddp_paygroup_assign_rec.attribute6;
    p8_a16 := ddp_paygroup_assign_rec.attribute7;
    p8_a17 := ddp_paygroup_assign_rec.attribute8;
    p8_a18 := ddp_paygroup_assign_rec.attribute9;
    p8_a19 := ddp_paygroup_assign_rec.attribute10;
    p8_a20 := ddp_paygroup_assign_rec.attribute11;
    p8_a21 := ddp_paygroup_assign_rec.attribute12;
    p8_a22 := ddp_paygroup_assign_rec.attribute13;
    p8_a23 := ddp_paygroup_assign_rec.attribute14;
    p8_a24 := ddp_paygroup_assign_rec.attribute15;
  end;

  procedure update_srp_pay_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  DATE
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  VARCHAR2
    , p8_a12 in out nocopy  VARCHAR2
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
  )

  as
    ddp_paygroup_assign_rec cn_srp_paygroup_pvt.paygroup_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_paygroup_assign_rec.srp_pay_group_id := p8_a0;
    ddp_paygroup_assign_rec.pay_group_id := p8_a1;
    ddp_paygroup_assign_rec.salesrep_id := p8_a2;
    ddp_paygroup_assign_rec.assignment_start_date := p8_a3;
    ddp_paygroup_assign_rec.assignment_end_date := p8_a4;
    ddp_paygroup_assign_rec.lock_flag := p8_a5;
    ddp_paygroup_assign_rec.role_pay_group_id := p8_a6;
    ddp_paygroup_assign_rec.org_id := p8_a7;
    ddp_paygroup_assign_rec.object_version_number := p8_a8;
    ddp_paygroup_assign_rec.attribute_category := p8_a9;
    ddp_paygroup_assign_rec.attribute1 := p8_a10;
    ddp_paygroup_assign_rec.attribute2 := p8_a11;
    ddp_paygroup_assign_rec.attribute3 := p8_a12;
    ddp_paygroup_assign_rec.attribute4 := p8_a13;
    ddp_paygroup_assign_rec.attribute5 := p8_a14;
    ddp_paygroup_assign_rec.attribute6 := p8_a15;
    ddp_paygroup_assign_rec.attribute7 := p8_a16;
    ddp_paygroup_assign_rec.attribute8 := p8_a17;
    ddp_paygroup_assign_rec.attribute9 := p8_a18;
    ddp_paygroup_assign_rec.attribute10 := p8_a19;
    ddp_paygroup_assign_rec.attribute11 := p8_a20;
    ddp_paygroup_assign_rec.attribute12 := p8_a21;
    ddp_paygroup_assign_rec.attribute13 := p8_a22;
    ddp_paygroup_assign_rec.attribute14 := p8_a23;
    ddp_paygroup_assign_rec.attribute15 := p8_a24;

    -- here's the delegated call to the old PL/SQL routine
    cn_srp_paygroup_pvt.update_srp_pay_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_paygroup_assign_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_paygroup_assign_rec.srp_pay_group_id;
    p8_a1 := ddp_paygroup_assign_rec.pay_group_id;
    p8_a2 := ddp_paygroup_assign_rec.salesrep_id;
    p8_a3 := ddp_paygroup_assign_rec.assignment_start_date;
    p8_a4 := ddp_paygroup_assign_rec.assignment_end_date;
    p8_a5 := ddp_paygroup_assign_rec.lock_flag;
    p8_a6 := ddp_paygroup_assign_rec.role_pay_group_id;
    p8_a7 := ddp_paygroup_assign_rec.org_id;
    p8_a8 := ddp_paygroup_assign_rec.object_version_number;
    p8_a9 := ddp_paygroup_assign_rec.attribute_category;
    p8_a10 := ddp_paygroup_assign_rec.attribute1;
    p8_a11 := ddp_paygroup_assign_rec.attribute2;
    p8_a12 := ddp_paygroup_assign_rec.attribute3;
    p8_a13 := ddp_paygroup_assign_rec.attribute4;
    p8_a14 := ddp_paygroup_assign_rec.attribute5;
    p8_a15 := ddp_paygroup_assign_rec.attribute6;
    p8_a16 := ddp_paygroup_assign_rec.attribute7;
    p8_a17 := ddp_paygroup_assign_rec.attribute8;
    p8_a18 := ddp_paygroup_assign_rec.attribute9;
    p8_a19 := ddp_paygroup_assign_rec.attribute10;
    p8_a20 := ddp_paygroup_assign_rec.attribute11;
    p8_a21 := ddp_paygroup_assign_rec.attribute12;
    p8_a22 := ddp_paygroup_assign_rec.attribute13;
    p8_a23 := ddp_paygroup_assign_rec.attribute14;
    p8_a24 := ddp_paygroup_assign_rec.attribute15;
  end;

  procedure delete_srp_pay_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  DATE
    , p8_a4  DATE
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
  )

  as
    ddp_paygroup_assign_rec cn_srp_paygroup_pvt.paygroup_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_paygroup_assign_rec.srp_pay_group_id := p8_a0;
    ddp_paygroup_assign_rec.pay_group_id := p8_a1;
    ddp_paygroup_assign_rec.salesrep_id := p8_a2;
    ddp_paygroup_assign_rec.assignment_start_date := p8_a3;
    ddp_paygroup_assign_rec.assignment_end_date := p8_a4;
    ddp_paygroup_assign_rec.lock_flag := p8_a5;
    ddp_paygroup_assign_rec.role_pay_group_id := p8_a6;
    ddp_paygroup_assign_rec.org_id := p8_a7;
    ddp_paygroup_assign_rec.object_version_number := p8_a8;
    ddp_paygroup_assign_rec.attribute_category := p8_a9;
    ddp_paygroup_assign_rec.attribute1 := p8_a10;
    ddp_paygroup_assign_rec.attribute2 := p8_a11;
    ddp_paygroup_assign_rec.attribute3 := p8_a12;
    ddp_paygroup_assign_rec.attribute4 := p8_a13;
    ddp_paygroup_assign_rec.attribute5 := p8_a14;
    ddp_paygroup_assign_rec.attribute6 := p8_a15;
    ddp_paygroup_assign_rec.attribute7 := p8_a16;
    ddp_paygroup_assign_rec.attribute8 := p8_a17;
    ddp_paygroup_assign_rec.attribute9 := p8_a18;
    ddp_paygroup_assign_rec.attribute10 := p8_a19;
    ddp_paygroup_assign_rec.attribute11 := p8_a20;
    ddp_paygroup_assign_rec.attribute12 := p8_a21;
    ddp_paygroup_assign_rec.attribute13 := p8_a22;
    ddp_paygroup_assign_rec.attribute14 := p8_a23;
    ddp_paygroup_assign_rec.attribute15 := p8_a24;

    -- here's the delegated call to the old PL/SQL routine
    cn_srp_paygroup_pvt.delete_srp_pay_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_paygroup_assign_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure valid_delete_srp_pay_group(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_paygroup_assign_rec cn_srp_paygroup_pvt.paygroup_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_paygroup_assign_rec.srp_pay_group_id := p0_a0;
    ddp_paygroup_assign_rec.pay_group_id := p0_a1;
    ddp_paygroup_assign_rec.salesrep_id := p0_a2;
    ddp_paygroup_assign_rec.assignment_start_date := p0_a3;
    ddp_paygroup_assign_rec.assignment_end_date := p0_a4;
    ddp_paygroup_assign_rec.lock_flag := p0_a5;
    ddp_paygroup_assign_rec.role_pay_group_id := p0_a6;
    ddp_paygroup_assign_rec.org_id := p0_a7;
    ddp_paygroup_assign_rec.object_version_number := p0_a8;
    ddp_paygroup_assign_rec.attribute_category := p0_a9;
    ddp_paygroup_assign_rec.attribute1 := p0_a10;
    ddp_paygroup_assign_rec.attribute2 := p0_a11;
    ddp_paygroup_assign_rec.attribute3 := p0_a12;
    ddp_paygroup_assign_rec.attribute4 := p0_a13;
    ddp_paygroup_assign_rec.attribute5 := p0_a14;
    ddp_paygroup_assign_rec.attribute6 := p0_a15;
    ddp_paygroup_assign_rec.attribute7 := p0_a16;
    ddp_paygroup_assign_rec.attribute8 := p0_a17;
    ddp_paygroup_assign_rec.attribute9 := p0_a18;
    ddp_paygroup_assign_rec.attribute10 := p0_a19;
    ddp_paygroup_assign_rec.attribute11 := p0_a20;
    ddp_paygroup_assign_rec.attribute12 := p0_a21;
    ddp_paygroup_assign_rec.attribute13 := p0_a22;
    ddp_paygroup_assign_rec.attribute14 := p0_a23;
    ddp_paygroup_assign_rec.attribute15 := p0_a24;






    -- here's the delegated call to the old PL/SQL routine
    cn_srp_paygroup_pvt.valid_delete_srp_pay_group(ddp_paygroup_assign_rec,
      p_init_msg_list,
      x_loading_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end cn_srp_paygroup_pvt_w;

/
