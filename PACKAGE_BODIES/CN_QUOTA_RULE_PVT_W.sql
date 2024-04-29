--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULE_PVT_W" as
  /* $Header: cnwqtrlb.pls 120.2 2005/09/14 04:28 rarajara ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_quota_rule_pvt.quota_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_1900
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
          t(ddindx).org_id := a0(indx);
          t(ddindx).quota_rule_id := a1(indx);
          t(ddindx).plan_element_name := a2(indx);
          t(ddindx).revenue_class_name := a3(indx);
          t(ddindx).revenue_class_id := a4(indx);
          t(ddindx).quota_id := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).target := a7(indx);
          t(ddindx).payment_amount := a8(indx);
          t(ddindx).performance_goal := a9(indx);
          t(ddindx).object_version_number := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_quota_rule_pvt.quota_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_1900
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
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_1900();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_1900();
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
          a0(indx) := t(ddindx).org_id;
          a1(indx) := t(ddindx).quota_rule_id;
          a2(indx) := t(ddindx).plan_element_name;
          a3(indx) := t(ddindx).revenue_class_name;
          a4(indx) := t(ddindx).revenue_class_id;
          a5(indx) := t(ddindx).quota_id;
          a6(indx) := t(ddindx).description;
          a7(indx) := t(ddindx).target;
          a8(indx) := t(ddindx).payment_amount;
          a9(indx) := t(ddindx).performance_goal;
          a10(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure validate_quota_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_action  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule cn_quota_rule_pvt.quota_rule_rec_type;
    ddp_old_quota_rule cn_quota_rule_pvt.quota_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_quota_rule.org_id := p5_a0;
    ddp_quota_rule.quota_rule_id := p5_a1;
    ddp_quota_rule.plan_element_name := p5_a2;
    ddp_quota_rule.revenue_class_name := p5_a3;
    ddp_quota_rule.revenue_class_id := p5_a4;
    ddp_quota_rule.quota_id := p5_a5;
    ddp_quota_rule.description := p5_a6;
    ddp_quota_rule.target := p5_a7;
    ddp_quota_rule.payment_amount := p5_a8;
    ddp_quota_rule.performance_goal := p5_a9;
    ddp_quota_rule.object_version_number := p5_a10;

    ddp_old_quota_rule.org_id := p6_a0;
    ddp_old_quota_rule.quota_rule_id := p6_a1;
    ddp_old_quota_rule.plan_element_name := p6_a2;
    ddp_old_quota_rule.revenue_class_name := p6_a3;
    ddp_old_quota_rule.revenue_class_id := p6_a4;
    ddp_old_quota_rule.quota_id := p6_a5;
    ddp_old_quota_rule.description := p6_a6;
    ddp_old_quota_rule.target := p6_a7;
    ddp_old_quota_rule.payment_amount := p6_a8;
    ddp_old_quota_rule.performance_goal := p6_a9;
    ddp_old_quota_rule.object_version_number := p6_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_pvt.validate_quota_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_action,
      ddp_quota_rule,
      ddp_old_quota_rule,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_quota_rule.org_id;
    p5_a1 := ddp_quota_rule.quota_rule_id;
    p5_a2 := ddp_quota_rule.plan_element_name;
    p5_a3 := ddp_quota_rule.revenue_class_name;
    p5_a4 := ddp_quota_rule.revenue_class_id;
    p5_a5 := ddp_quota_rule.quota_id;
    p5_a6 := ddp_quota_rule.description;
    p5_a7 := ddp_quota_rule.target;
    p5_a8 := ddp_quota_rule.payment_amount;
    p5_a9 := ddp_quota_rule.performance_goal;
    p5_a10 := ddp_quota_rule.object_version_number;




  end;

  procedure create_quota_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule cn_quota_rule_pvt.quota_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_rule.org_id := p4_a0;
    ddp_quota_rule.quota_rule_id := p4_a1;
    ddp_quota_rule.plan_element_name := p4_a2;
    ddp_quota_rule.revenue_class_name := p4_a3;
    ddp_quota_rule.revenue_class_id := p4_a4;
    ddp_quota_rule.quota_id := p4_a5;
    ddp_quota_rule.description := p4_a6;
    ddp_quota_rule.target := p4_a7;
    ddp_quota_rule.payment_amount := p4_a8;
    ddp_quota_rule.performance_goal := p4_a9;
    ddp_quota_rule.object_version_number := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_pvt.create_quota_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_rule,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_rule.org_id;
    p4_a1 := ddp_quota_rule.quota_rule_id;
    p4_a2 := ddp_quota_rule.plan_element_name;
    p4_a3 := ddp_quota_rule.revenue_class_name;
    p4_a4 := ddp_quota_rule.revenue_class_id;
    p4_a5 := ddp_quota_rule.quota_id;
    p4_a6 := ddp_quota_rule.description;
    p4_a7 := ddp_quota_rule.target;
    p4_a8 := ddp_quota_rule.payment_amount;
    p4_a9 := ddp_quota_rule.performance_goal;
    p4_a10 := ddp_quota_rule.object_version_number;



  end;

  procedure update_quota_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule cn_quota_rule_pvt.quota_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_rule.org_id := p4_a0;
    ddp_quota_rule.quota_rule_id := p4_a1;
    ddp_quota_rule.plan_element_name := p4_a2;
    ddp_quota_rule.revenue_class_name := p4_a3;
    ddp_quota_rule.revenue_class_id := p4_a4;
    ddp_quota_rule.quota_id := p4_a5;
    ddp_quota_rule.description := p4_a6;
    ddp_quota_rule.target := p4_a7;
    ddp_quota_rule.payment_amount := p4_a8;
    ddp_quota_rule.performance_goal := p4_a9;
    ddp_quota_rule.object_version_number := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_pvt.update_quota_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_rule,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_rule.org_id;
    p4_a1 := ddp_quota_rule.quota_rule_id;
    p4_a2 := ddp_quota_rule.plan_element_name;
    p4_a3 := ddp_quota_rule.revenue_class_name;
    p4_a4 := ddp_quota_rule.revenue_class_id;
    p4_a5 := ddp_quota_rule.quota_id;
    p4_a6 := ddp_quota_rule.description;
    p4_a7 := ddp_quota_rule.target;
    p4_a8 := ddp_quota_rule.payment_amount;
    p4_a9 := ddp_quota_rule.performance_goal;
    p4_a10 := ddp_quota_rule.object_version_number;



  end;

  procedure delete_quota_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule cn_quota_rule_pvt.quota_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_rule.org_id := p4_a0;
    ddp_quota_rule.quota_rule_id := p4_a1;
    ddp_quota_rule.plan_element_name := p4_a2;
    ddp_quota_rule.revenue_class_name := p4_a3;
    ddp_quota_rule.revenue_class_id := p4_a4;
    ddp_quota_rule.quota_id := p4_a5;
    ddp_quota_rule.description := p4_a6;
    ddp_quota_rule.target := p4_a7;
    ddp_quota_rule.payment_amount := p4_a8;
    ddp_quota_rule.performance_goal := p4_a9;
    ddp_quota_rule.object_version_number := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_pvt.delete_quota_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_rule,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_rule.org_id;
    p4_a1 := ddp_quota_rule.quota_rule_id;
    p4_a2 := ddp_quota_rule.plan_element_name;
    p4_a3 := ddp_quota_rule.revenue_class_name;
    p4_a4 := ddp_quota_rule.revenue_class_id;
    p4_a5 := ddp_quota_rule.quota_id;
    p4_a6 := ddp_quota_rule.description;
    p4_a7 := ddp_quota_rule.target;
    p4_a8 := ddp_quota_rule.payment_amount;
    p4_a9 := ddp_quota_rule.performance_goal;
    p4_a10 := ddp_quota_rule.object_version_number;



  end;

end cn_quota_rule_pvt_w;

/
