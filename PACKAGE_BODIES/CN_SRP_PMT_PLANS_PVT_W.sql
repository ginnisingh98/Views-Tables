--------------------------------------------------------
--  DDL for Package Body CN_SRP_PMT_PLANS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PMT_PLANS_PVT_W" as
  /* $Header: cnwsppab.pls 120.3 2005/09/14 03:43 vensrini noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_srp_pmt_plans_pvt.payrun_tbl, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := cn_srp_pmt_plans_pvt.payrun_tbl();
  else
      if a0.count > 0 then
      t := cn_srp_pmt_plans_pvt.payrun_tbl();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_srp_pmt_plans_pvt.payrun_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_srp_pmt_plan(p_api_version  NUMBER
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
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  DATE
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  NUMBER
  )

  as
    ddp_pmt_plan_assign_rec cn_srp_pmt_plans_pvt.pmt_plan_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_pmt_plan_assign_rec.srp_pmt_plan_id := p8_a0;
    ddp_pmt_plan_assign_rec.salesrep_id := p8_a1;
    ddp_pmt_plan_assign_rec.org_id := p8_a2;
    ddp_pmt_plan_assign_rec.pmt_plan_id := p8_a3;
    ddp_pmt_plan_assign_rec.start_date := p8_a4;
    ddp_pmt_plan_assign_rec.end_date := p8_a5;
    ddp_pmt_plan_assign_rec.minimum_amount := p8_a6;
    ddp_pmt_plan_assign_rec.maximum_amount := p8_a7;
    ddp_pmt_plan_assign_rec.srp_role_id := p8_a8;
    ddp_pmt_plan_assign_rec.role_pmt_plan_id := p8_a9;
    ddp_pmt_plan_assign_rec.lock_flag := p8_a10;
    ddp_pmt_plan_assign_rec.object_version_number := p8_a11;

    -- here's the delegated call to the old PL/SQL routine
    cn_srp_pmt_plans_pvt.create_srp_pmt_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_pmt_plan_assign_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_pmt_plan_assign_rec.srp_pmt_plan_id;
    p8_a1 := ddp_pmt_plan_assign_rec.salesrep_id;
    p8_a2 := ddp_pmt_plan_assign_rec.org_id;
    p8_a3 := ddp_pmt_plan_assign_rec.pmt_plan_id;
    p8_a4 := ddp_pmt_plan_assign_rec.start_date;
    p8_a5 := ddp_pmt_plan_assign_rec.end_date;
    p8_a6 := ddp_pmt_plan_assign_rec.minimum_amount;
    p8_a7 := ddp_pmt_plan_assign_rec.maximum_amount;
    p8_a8 := ddp_pmt_plan_assign_rec.srp_role_id;
    p8_a9 := ddp_pmt_plan_assign_rec.role_pmt_plan_id;
    p8_a10 := ddp_pmt_plan_assign_rec.lock_flag;
    p8_a11 := ddp_pmt_plan_assign_rec.object_version_number;
  end;

  procedure update_srp_pmt_plan(p_api_version  NUMBER
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
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  DATE
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  NUMBER
  )

  as
    ddp_pmt_plan_assign_rec cn_srp_pmt_plans_pvt.pmt_plan_assign_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_pmt_plan_assign_rec.srp_pmt_plan_id := p8_a0;
    ddp_pmt_plan_assign_rec.salesrep_id := p8_a1;
    ddp_pmt_plan_assign_rec.org_id := p8_a2;
    ddp_pmt_plan_assign_rec.pmt_plan_id := p8_a3;
    ddp_pmt_plan_assign_rec.start_date := p8_a4;
    ddp_pmt_plan_assign_rec.end_date := p8_a5;
    ddp_pmt_plan_assign_rec.minimum_amount := p8_a6;
    ddp_pmt_plan_assign_rec.maximum_amount := p8_a7;
    ddp_pmt_plan_assign_rec.srp_role_id := p8_a8;
    ddp_pmt_plan_assign_rec.role_pmt_plan_id := p8_a9;
    ddp_pmt_plan_assign_rec.lock_flag := p8_a10;
    ddp_pmt_plan_assign_rec.object_version_number := p8_a11;

    -- here's the delegated call to the old PL/SQL routine
    cn_srp_pmt_plans_pvt.update_srp_pmt_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_pmt_plan_assign_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_pmt_plan_assign_rec.srp_pmt_plan_id;
    p8_a1 := ddp_pmt_plan_assign_rec.salesrep_id;
    p8_a2 := ddp_pmt_plan_assign_rec.org_id;
    p8_a3 := ddp_pmt_plan_assign_rec.pmt_plan_id;
    p8_a4 := ddp_pmt_plan_assign_rec.start_date;
    p8_a5 := ddp_pmt_plan_assign_rec.end_date;
    p8_a6 := ddp_pmt_plan_assign_rec.minimum_amount;
    p8_a7 := ddp_pmt_plan_assign_rec.maximum_amount;
    p8_a8 := ddp_pmt_plan_assign_rec.srp_role_id;
    p8_a9 := ddp_pmt_plan_assign_rec.role_pmt_plan_id;
    p8_a10 := ddp_pmt_plan_assign_rec.lock_flag;
    p8_a11 := ddp_pmt_plan_assign_rec.object_version_number;
  end;

  procedure check_payruns(p_operation  VARCHAR2
    , p_srp_pmt_plan_id  NUMBER
    , p_salesrep_id  NUMBER
    , p_start_date  DATE
    , p_end_date  DATE
    , x_payrun_tbl out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_payrun_tbl cn_srp_pmt_plans_pvt.payrun_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    cn_srp_pmt_plans_pvt.check_payruns(p_operation,
      p_srp_pmt_plan_id,
      p_salesrep_id,
      p_start_date,
      p_end_date,
      ddx_payrun_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_srp_pmt_plans_pvt_w.rosetta_table_copy_out_p1(ddx_payrun_tbl, x_payrun_tbl);
  end;

end cn_srp_pmt_plans_pvt_w;

/
