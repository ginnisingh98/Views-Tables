--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYGROUP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYGROUP_PUB_W" as
  /* $Header: cnwspgpb.pls 115.7 2002/12/08 09:28:03 pramadas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure assign_salesreps(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
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
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  )

  as
    ddp_paygroup_assign_rec cn_srp_paygroup_pub.paygroup_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_paygroup_assign_rec.pay_group_name := p7_a0;
    ddp_paygroup_assign_rec.employee_type := p7_a1;
    ddp_paygroup_assign_rec.employee_number := p7_a2;
    ddp_paygroup_assign_rec.source_id := p7_a3;
    ddp_paygroup_assign_rec.assignment_start_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_paygroup_assign_rec.assignment_end_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_paygroup_assign_rec.lock_flag := p7_a6;
    ddp_paygroup_assign_rec.role_pay_group_id := p7_a7;
    ddp_paygroup_assign_rec.attribute_category := p7_a8;
    ddp_paygroup_assign_rec.attribute1 := p7_a9;
    ddp_paygroup_assign_rec.attribute2 := p7_a10;
    ddp_paygroup_assign_rec.attribute3 := p7_a11;
    ddp_paygroup_assign_rec.attribute4 := p7_a12;
    ddp_paygroup_assign_rec.attribute5 := p7_a13;
    ddp_paygroup_assign_rec.attribute6 := p7_a14;
    ddp_paygroup_assign_rec.attribute7 := p7_a15;
    ddp_paygroup_assign_rec.attribute8 := p7_a16;
    ddp_paygroup_assign_rec.attribute9 := p7_a17;
    ddp_paygroup_assign_rec.attribute10 := p7_a18;
    ddp_paygroup_assign_rec.attribute11 := p7_a19;
    ddp_paygroup_assign_rec.attribute12 := p7_a20;
    ddp_paygroup_assign_rec.attribute13 := p7_a21;
    ddp_paygroup_assign_rec.attribute14 := p7_a22;
    ddp_paygroup_assign_rec.attribute15 := p7_a23;



    -- here's the delegated call to the old PL/SQL routine
    cn_srp_paygroup_pub.assign_salesreps(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_paygroup_assign_rec,
      x_loading_status,
      x_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_srp_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
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
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  DATE
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  VARCHAR2
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
    , p_ovn  NUMBER
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  )

  as
    ddp_old_paygroup_assign_rec cn_srp_paygroup_pub.paygroup_assign_rec;
    ddp_paygroup_assign_rec cn_srp_paygroup_pub.paygroup_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_old_paygroup_assign_rec.pay_group_name := p7_a0;
    ddp_old_paygroup_assign_rec.employee_type := p7_a1;
    ddp_old_paygroup_assign_rec.employee_number := p7_a2;
    ddp_old_paygroup_assign_rec.source_id := p7_a3;
    ddp_old_paygroup_assign_rec.assignment_start_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_old_paygroup_assign_rec.assignment_end_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_old_paygroup_assign_rec.lock_flag := p7_a6;
    ddp_old_paygroup_assign_rec.role_pay_group_id := p7_a7;
    ddp_old_paygroup_assign_rec.attribute_category := p7_a8;
    ddp_old_paygroup_assign_rec.attribute1 := p7_a9;
    ddp_old_paygroup_assign_rec.attribute2 := p7_a10;
    ddp_old_paygroup_assign_rec.attribute3 := p7_a11;
    ddp_old_paygroup_assign_rec.attribute4 := p7_a12;
    ddp_old_paygroup_assign_rec.attribute5 := p7_a13;
    ddp_old_paygroup_assign_rec.attribute6 := p7_a14;
    ddp_old_paygroup_assign_rec.attribute7 := p7_a15;
    ddp_old_paygroup_assign_rec.attribute8 := p7_a16;
    ddp_old_paygroup_assign_rec.attribute9 := p7_a17;
    ddp_old_paygroup_assign_rec.attribute10 := p7_a18;
    ddp_old_paygroup_assign_rec.attribute11 := p7_a19;
    ddp_old_paygroup_assign_rec.attribute12 := p7_a20;
    ddp_old_paygroup_assign_rec.attribute13 := p7_a21;
    ddp_old_paygroup_assign_rec.attribute14 := p7_a22;
    ddp_old_paygroup_assign_rec.attribute15 := p7_a23;

    ddp_paygroup_assign_rec.pay_group_name := p8_a0;
    ddp_paygroup_assign_rec.employee_type := p8_a1;
    ddp_paygroup_assign_rec.employee_number := p8_a2;
    ddp_paygroup_assign_rec.source_id := p8_a3;
    ddp_paygroup_assign_rec.assignment_start_date := rosetta_g_miss_date_in_map(p8_a4);
    ddp_paygroup_assign_rec.assignment_end_date := rosetta_g_miss_date_in_map(p8_a5);
    ddp_paygroup_assign_rec.lock_flag := p8_a6;
    ddp_paygroup_assign_rec.role_pay_group_id := p8_a7;
    ddp_paygroup_assign_rec.attribute_category := p8_a8;
    ddp_paygroup_assign_rec.attribute1 := p8_a9;
    ddp_paygroup_assign_rec.attribute2 := p8_a10;
    ddp_paygroup_assign_rec.attribute3 := p8_a11;
    ddp_paygroup_assign_rec.attribute4 := p8_a12;
    ddp_paygroup_assign_rec.attribute5 := p8_a13;
    ddp_paygroup_assign_rec.attribute6 := p8_a14;
    ddp_paygroup_assign_rec.attribute7 := p8_a15;
    ddp_paygroup_assign_rec.attribute8 := p8_a16;
    ddp_paygroup_assign_rec.attribute9 := p8_a17;
    ddp_paygroup_assign_rec.attribute10 := p8_a18;
    ddp_paygroup_assign_rec.attribute11 := p8_a19;
    ddp_paygroup_assign_rec.attribute12 := p8_a20;
    ddp_paygroup_assign_rec.attribute13 := p8_a21;
    ddp_paygroup_assign_rec.attribute14 := p8_a22;
    ddp_paygroup_assign_rec.attribute15 := p8_a23;




    -- here's the delegated call to the old PL/SQL routine
    cn_srp_paygroup_pub.update_srp_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_old_paygroup_assign_rec,
      ddp_paygroup_assign_rec,
      p_ovn,
      x_loading_status,
      x_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end cn_srp_paygroup_pub_w;

/
