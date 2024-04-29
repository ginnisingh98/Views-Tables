--------------------------------------------------------
--  DDL for Package Body CN_PRD_QUOTA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PRD_QUOTA_PVT_W" as
  /* $Header: cnwpedqb.pls 120.3 2005/09/14 04:28 rarajara ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_prd_quota_pvt.prd_quota_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).period_quota_id := a0(indx);
          t(ddindx).period_id := a1(indx);
          t(ddindx).period_name := a2(indx);
          t(ddindx).quota_id := a3(indx);
          t(ddindx).period_target := a4(indx);
          t(ddindx).itd_target := a5(indx);
          t(ddindx).period_payment := a6(indx);
          t(ddindx).itd_payment := a7(indx);
          t(ddindx).quarter_num := a8(indx);
          t(ddindx).period_year := a9(indx);
          t(ddindx).org_id := a10(indx);
          t(ddindx).performance_goal := a11(indx);
          t(ddindx).performance_goal_itd := a12(indx);
          t(ddindx).period_target_tot := a13(indx);
          t(ddindx).period_payment_tot := a14(indx);
          t(ddindx).performance_goal_tot := a15(indx);
          t(ddindx).period_target_pct := a16(indx);
          t(ddindx).period_payment_pct := a17(indx);
          t(ddindx).performance_goal_pct := a18(indx);
          t(ddindx).created_by := a19(indx);
          t(ddindx).creation_date := a20(indx);
          t(ddindx).last_update_login := a21(indx);
          t(ddindx).last_update_date := a22(indx);
          t(ddindx).last_updated_by := a23(indx);
          t(ddindx).object_version_number := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_prd_quota_pvt.prd_quota_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).period_quota_id;
          a1(indx) := t(ddindx).period_id;
          a2(indx) := t(ddindx).period_name;
          a3(indx) := t(ddindx).quota_id;
          a4(indx) := t(ddindx).period_target;
          a5(indx) := t(ddindx).itd_target;
          a6(indx) := t(ddindx).period_payment;
          a7(indx) := t(ddindx).itd_payment;
          a8(indx) := t(ddindx).quarter_num;
          a9(indx) := t(ddindx).period_year;
          a10(indx) := t(ddindx).org_id;
          a11(indx) := t(ddindx).performance_goal;
          a12(indx) := t(ddindx).performance_goal_itd;
          a13(indx) := t(ddindx).period_target_tot;
          a14(indx) := t(ddindx).period_payment_tot;
          a15(indx) := t(ddindx).performance_goal_tot;
          a16(indx) := t(ddindx).period_target_pct;
          a17(indx) := t(ddindx).period_payment_pct;
          a18(indx) := t(ddindx).performance_goal_pct;
          a19(indx) := t(ddindx).created_by;
          a20(indx) := t(ddindx).creation_date;
          a21(indx) := t(ddindx).last_update_login;
          a22(indx) := t(ddindx).last_update_date;
          a23(indx) := t(ddindx).last_updated_by;
          a24(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_prd_quota_pvt.prd_quota_q_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_id := a0(indx);
          t(ddindx).period_target := a1(indx);
          t(ddindx).period_payment := a2(indx);
          t(ddindx).quarter_num := a3(indx);
          t(ddindx).period_year := a4(indx);
          t(ddindx).performance_goal := a5(indx);
          t(ddindx).period_target_tot := a6(indx);
          t(ddindx).period_payment_tot := a7(indx);
          t(ddindx).performance_goal_tot := a8(indx);
          t(ddindx).period_target_pct := a9(indx);
          t(ddindx).period_payment_pct := a10(indx);
          t(ddindx).performance_goal_pct := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_prd_quota_pvt.prd_quota_q_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_id;
          a1(indx) := t(ddindx).period_target;
          a2(indx) := t(ddindx).period_payment;
          a3(indx) := t(ddindx).quarter_num;
          a4(indx) := t(ddindx).period_year;
          a5(indx) := t(ddindx).performance_goal;
          a6(indx) := t(ddindx).period_target_tot;
          a7(indx) := t(ddindx).period_payment_tot;
          a8(indx) := t(ddindx).performance_goal_tot;
          a9(indx) := t(ddindx).period_target_pct;
          a10(indx) := t(ddindx).period_payment_pct;
          a11(indx) := t(ddindx).performance_goal_pct;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_prd_quota_pvt.prd_quota_year_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_id := a0(indx);
          t(ddindx).period_target := a1(indx);
          t(ddindx).period_payment := a2(indx);
          t(ddindx).performance_goal := a3(indx);
          t(ddindx).period_year := a4(indx);
          t(ddindx).period_target_tot := a5(indx);
          t(ddindx).period_payment_tot := a6(indx);
          t(ddindx).performance_goal_tot := a7(indx);
          t(ddindx).period_target_pct := a8(indx);
          t(ddindx).period_payment_pct := a9(indx);
          t(ddindx).performance_goal_pct := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_prd_quota_pvt.prd_quota_year_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_id;
          a1(indx) := t(ddindx).period_target;
          a2(indx) := t(ddindx).period_payment;
          a3(indx) := t(ddindx).performance_goal;
          a4(indx) := t(ddindx).period_year;
          a5(indx) := t(ddindx).period_target_tot;
          a6(indx) := t(ddindx).period_payment_tot;
          a7(indx) := t(ddindx).performance_goal_tot;
          a8(indx) := t(ddindx).period_target_pct;
          a9(indx) := t(ddindx).period_payment_pct;
          a10(indx) := t(ddindx).performance_goal_pct;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure update_period_quota(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  NUMBER
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  NUMBER
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  NUMBER
    , p4_a22 in out nocopy  DATE
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_prd_quota cn_prd_quota_pvt.prd_quota_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_prd_quota.period_quota_id := p4_a0;
    ddp_prd_quota.period_id := p4_a1;
    ddp_prd_quota.period_name := p4_a2;
    ddp_prd_quota.quota_id := p4_a3;
    ddp_prd_quota.period_target := p4_a4;
    ddp_prd_quota.itd_target := p4_a5;
    ddp_prd_quota.period_payment := p4_a6;
    ddp_prd_quota.itd_payment := p4_a7;
    ddp_prd_quota.quarter_num := p4_a8;
    ddp_prd_quota.period_year := p4_a9;
    ddp_prd_quota.org_id := p4_a10;
    ddp_prd_quota.performance_goal := p4_a11;
    ddp_prd_quota.performance_goal_itd := p4_a12;
    ddp_prd_quota.period_target_tot := p4_a13;
    ddp_prd_quota.period_payment_tot := p4_a14;
    ddp_prd_quota.performance_goal_tot := p4_a15;
    ddp_prd_quota.period_target_pct := p4_a16;
    ddp_prd_quota.period_payment_pct := p4_a17;
    ddp_prd_quota.performance_goal_pct := p4_a18;
    ddp_prd_quota.created_by := p4_a19;
    ddp_prd_quota.creation_date := p4_a20;
    ddp_prd_quota.last_update_login := p4_a21;
    ddp_prd_quota.last_update_date := p4_a22;
    ddp_prd_quota.last_updated_by := p4_a23;
    ddp_prd_quota.object_version_number := p4_a24;




    -- here's the delegated call to the old PL/SQL routine
    cn_prd_quota_pvt.update_period_quota(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_prd_quota,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_prd_quota.period_quota_id;
    p4_a1 := ddp_prd_quota.period_id;
    p4_a2 := ddp_prd_quota.period_name;
    p4_a3 := ddp_prd_quota.quota_id;
    p4_a4 := ddp_prd_quota.period_target;
    p4_a5 := ddp_prd_quota.itd_target;
    p4_a6 := ddp_prd_quota.period_payment;
    p4_a7 := ddp_prd_quota.itd_payment;
    p4_a8 := ddp_prd_quota.quarter_num;
    p4_a9 := ddp_prd_quota.period_year;
    p4_a10 := ddp_prd_quota.org_id;
    p4_a11 := ddp_prd_quota.performance_goal;
    p4_a12 := ddp_prd_quota.performance_goal_itd;
    p4_a13 := ddp_prd_quota.period_target_tot;
    p4_a14 := ddp_prd_quota.period_payment_tot;
    p4_a15 := ddp_prd_quota.performance_goal_tot;
    p4_a16 := ddp_prd_quota.period_target_pct;
    p4_a17 := ddp_prd_quota.period_payment_pct;
    p4_a18 := ddp_prd_quota.performance_goal_pct;
    p4_a19 := ddp_prd_quota.created_by;
    p4_a20 := ddp_prd_quota.creation_date;
    p4_a21 := ddp_prd_quota.last_update_login;
    p4_a22 := ddp_prd_quota.last_update_date;
    p4_a23 := ddp_prd_quota.last_updated_by;
    p4_a24 := ddp_prd_quota.object_version_number;



  end;

end cn_prd_quota_pvt_w;

/
