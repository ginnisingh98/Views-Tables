--------------------------------------------------------
--  DDL for Package Body CN_TRX_FACTOR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TRX_FACTOR_PVT_W" as
  /* $Header: cnwtxftb.pls 120.2 2005/09/14 04:30 rarajara ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_trx_factor_pvt.trx_factor_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).trx_factor_id := a0(indx);
          t(ddindx).revenue_class_id := a1(indx);
          t(ddindx).quota_id := a2(indx);
          t(ddindx).quota_rule_id := a3(indx);
          t(ddindx).event_factor := a4(indx);
          t(ddindx).trx_type := a5(indx);
          t(ddindx).object_version_number := a6(indx);
          t(ddindx).org_id := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_trx_factor_pvt.trx_factor_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).trx_factor_id;
          a1(indx) := t(ddindx).revenue_class_id;
          a2(indx) := t(ddindx).quota_id;
          a3(indx) := t(ddindx).quota_rule_id;
          a4(indx) := t(ddindx).event_factor;
          a5(indx) := t(ddindx).trx_type;
          a6(indx) := t(ddindx).object_version_number;
          a7(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure validate_trx_factor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_action  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trx_factor cn_trx_factor_pvt.trx_factor_rec_type;
    ddp_old_trx_factor cn_trx_factor_pvt.trx_factor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_trx_factor.trx_factor_id := p5_a0;
    ddp_trx_factor.revenue_class_id := p5_a1;
    ddp_trx_factor.quota_id := p5_a2;
    ddp_trx_factor.quota_rule_id := p5_a3;
    ddp_trx_factor.event_factor := p5_a4;
    ddp_trx_factor.trx_type := p5_a5;
    ddp_trx_factor.object_version_number := p5_a6;
    ddp_trx_factor.org_id := p5_a7;

    ddp_old_trx_factor.trx_factor_id := p6_a0;
    ddp_old_trx_factor.revenue_class_id := p6_a1;
    ddp_old_trx_factor.quota_id := p6_a2;
    ddp_old_trx_factor.quota_rule_id := p6_a3;
    ddp_old_trx_factor.event_factor := p6_a4;
    ddp_old_trx_factor.trx_type := p6_a5;
    ddp_old_trx_factor.object_version_number := p6_a6;
    ddp_old_trx_factor.org_id := p6_a7;




    -- here's the delegated call to the old PL/SQL routine
    cn_trx_factor_pvt.validate_trx_factor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_action,
      ddp_trx_factor,
      ddp_old_trx_factor,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_trx_factor.trx_factor_id;
    p5_a1 := ddp_trx_factor.revenue_class_id;
    p5_a2 := ddp_trx_factor.quota_id;
    p5_a3 := ddp_trx_factor.quota_rule_id;
    p5_a4 := ddp_trx_factor.event_factor;
    p5_a5 := ddp_trx_factor.trx_type;
    p5_a6 := ddp_trx_factor.object_version_number;
    p5_a7 := ddp_trx_factor.org_id;




  end;

  procedure create_trx_factor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trx_factor cn_trx_factor_pvt.trx_factor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_trx_factor.trx_factor_id := p4_a0;
    ddp_trx_factor.revenue_class_id := p4_a1;
    ddp_trx_factor.quota_id := p4_a2;
    ddp_trx_factor.quota_rule_id := p4_a3;
    ddp_trx_factor.event_factor := p4_a4;
    ddp_trx_factor.trx_type := p4_a5;
    ddp_trx_factor.object_version_number := p4_a6;
    ddp_trx_factor.org_id := p4_a7;




    -- here's the delegated call to the old PL/SQL routine
    cn_trx_factor_pvt.create_trx_factor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_trx_factor,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_trx_factor.trx_factor_id;
    p4_a1 := ddp_trx_factor.revenue_class_id;
    p4_a2 := ddp_trx_factor.quota_id;
    p4_a3 := ddp_trx_factor.quota_rule_id;
    p4_a4 := ddp_trx_factor.event_factor;
    p4_a5 := ddp_trx_factor.trx_type;
    p4_a6 := ddp_trx_factor.object_version_number;
    p4_a7 := ddp_trx_factor.org_id;



  end;

  procedure update_trx_factor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trx_factor cn_trx_factor_pvt.trx_factor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_trx_factor.trx_factor_id := p4_a0;
    ddp_trx_factor.revenue_class_id := p4_a1;
    ddp_trx_factor.quota_id := p4_a2;
    ddp_trx_factor.quota_rule_id := p4_a3;
    ddp_trx_factor.event_factor := p4_a4;
    ddp_trx_factor.trx_type := p4_a5;
    ddp_trx_factor.object_version_number := p4_a6;
    ddp_trx_factor.org_id := p4_a7;




    -- here's the delegated call to the old PL/SQL routine
    cn_trx_factor_pvt.update_trx_factor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_trx_factor,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_trx_factor.trx_factor_id;
    p4_a1 := ddp_trx_factor.revenue_class_id;
    p4_a2 := ddp_trx_factor.quota_id;
    p4_a3 := ddp_trx_factor.quota_rule_id;
    p4_a4 := ddp_trx_factor.event_factor;
    p4_a5 := ddp_trx_factor.trx_type;
    p4_a6 := ddp_trx_factor.object_version_number;
    p4_a7 := ddp_trx_factor.org_id;



  end;

  procedure delete_trx_factor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trx_factor cn_trx_factor_pvt.trx_factor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_trx_factor.trx_factor_id := p4_a0;
    ddp_trx_factor.revenue_class_id := p4_a1;
    ddp_trx_factor.quota_id := p4_a2;
    ddp_trx_factor.quota_rule_id := p4_a3;
    ddp_trx_factor.event_factor := p4_a4;
    ddp_trx_factor.trx_type := p4_a5;
    ddp_trx_factor.object_version_number := p4_a6;
    ddp_trx_factor.org_id := p4_a7;




    -- here's the delegated call to the old PL/SQL routine
    cn_trx_factor_pvt.delete_trx_factor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_trx_factor,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_trx_factor.trx_factor_id;
    p4_a1 := ddp_trx_factor.revenue_class_id;
    p4_a2 := ddp_trx_factor.quota_id;
    p4_a3 := ddp_trx_factor.quota_rule_id;
    p4_a4 := ddp_trx_factor.event_factor;
    p4_a5 := ddp_trx_factor.trx_type;
    p4_a6 := ddp_trx_factor.object_version_number;
    p4_a7 := ddp_trx_factor.org_id;



  end;

  procedure get_trx_factor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_quota_rule_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_trx_factor cn_trx_factor_pvt.trx_factor_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cn_trx_factor_pvt.get_trx_factor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_quota_rule_id,
      ddx_trx_factor,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_trx_factor_pvt_w.rosetta_table_copy_out_p1(ddx_trx_factor, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      );



  end;

end cn_trx_factor_pvt_w;

/
