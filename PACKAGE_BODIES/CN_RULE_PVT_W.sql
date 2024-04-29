--------------------------------------------------------
--  DDL for Package Body CN_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULE_PVT_W" as
  /* $Header: cnwrruleb.pls 120.2 2005/06/17 04:10 appldev  $ */
  procedure rosetta_table_copy_in_p2(t out nocopy cn_rule_pvt.rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ruleset_id := a0(indx);
          t(ddindx).ruleset_name := a1(indx);
          t(ddindx).rule_id := a2(indx);
          t(ddindx).rule_name := a3(indx);
          t(ddindx).expense_desc := a4(indx);
          t(ddindx).liability_desc := a5(indx);
          t(ddindx).revenue_class_name := a6(indx);
          t(ddindx).parent_rule_id := a7(indx);
          t(ddindx).revenue_class_id := a8(indx);
          t(ddindx).expense_ccid := a9(indx);
          t(ddindx).liability_ccid := a10(indx);
          t(ddindx).sequence_number := a11(indx);
          t(ddindx).org_id := a12(indx);
          t(ddindx).object_version_no := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_rule_pvt.rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).ruleset_id;
          a1(indx) := t(ddindx).ruleset_name;
          a2(indx) := t(ddindx).rule_id;
          a3(indx) := t(ddindx).rule_name;
          a4(indx) := t(ddindx).expense_desc;
          a5(indx) := t(ddindx).liability_desc;
          a6(indx) := t(ddindx).revenue_class_name;
          a7(indx) := t(ddindx).parent_rule_id;
          a8(indx) := t(ddindx).revenue_class_id;
          a9(indx) := t(ddindx).expense_ccid;
          a10(indx) := t(ddindx).liability_ccid;
          a11(indx) := t(ddindx).sequence_number;
          a12(indx) := t(ddindx).org_id;
          a13(indx) := t(ddindx).object_version_no;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , x_rule_id out nocopy  NUMBER
  )

  as
    ddp_rule_rec cn_rule_pvt.rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_rule_rec.ruleset_id := p8_a0;
    ddp_rule_rec.rule_id := p8_a1;
    ddp_rule_rec.rule_name := p8_a2;
    ddp_rule_rec.parent_rule_id := p8_a3;
    ddp_rule_rec.revenue_class_id := p8_a4;
    ddp_rule_rec.expense_ccid := p8_a5;
    ddp_rule_rec.liability_ccid := p8_a6;
    ddp_rule_rec.sequence_number := p8_a7;
    ddp_rule_rec.org_id := p8_a8;
    ddp_rule_rec.object_version_no := p8_a9;


    -- here's the delegated call to the old PL/SQL routine
    cn_rule_pvt.create_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddp_rule_rec,
      x_rule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  VARCHAR2
    , p9_a3  NUMBER
    , p9_a4  NUMBER
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  NUMBER
  )

  as
    ddp_old_rule_rec cn_rule_pvt.rule_rec_type;
    ddp_rule_rec cn_rule_pvt.rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_old_rule_rec.ruleset_id := p8_a0;
    ddp_old_rule_rec.rule_id := p8_a1;
    ddp_old_rule_rec.rule_name := p8_a2;
    ddp_old_rule_rec.parent_rule_id := p8_a3;
    ddp_old_rule_rec.revenue_class_id := p8_a4;
    ddp_old_rule_rec.expense_ccid := p8_a5;
    ddp_old_rule_rec.liability_ccid := p8_a6;
    ddp_old_rule_rec.sequence_number := p8_a7;
    ddp_old_rule_rec.org_id := p8_a8;
    ddp_old_rule_rec.object_version_no := p8_a9;

    ddp_rule_rec.ruleset_id := p9_a0;
    ddp_rule_rec.rule_id := p9_a1;
    ddp_rule_rec.rule_name := p9_a2;
    ddp_rule_rec.parent_rule_id := p9_a3;
    ddp_rule_rec.revenue_class_id := p9_a4;
    ddp_rule_rec.expense_ccid := p9_a5;
    ddp_rule_rec.liability_ccid := p9_a6;
    ddp_rule_rec.sequence_number := p9_a7;
    ddp_rule_rec.org_id := p9_a8;
    ddp_rule_rec.object_version_no := p9_a9;

    -- here's the delegated call to the old PL/SQL routine
    cn_rule_pvt.update_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddp_old_rule_rec,
      ddp_rule_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure get_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_ruleset_name  VARCHAR2
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_order_by  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_NUMBER_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , x_total_records out nocopy  NUMBER
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p_org_id  NUMBER
  )

  as
    ddx_rule_tbl cn_rule_pvt.rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    -- here's the delegated call to the old PL/SQL routine
    cn_rule_pvt.get_rules(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_ruleset_name,
      p_start_record,
      p_increment_count,
      p_order_by,
      ddx_rule_tbl,
      x_total_records,
      x_status,
      x_loading_status,
      p_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    cn_rule_pvt_w.rosetta_table_copy_out_p2(ddx_rule_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      );




  end;

end cn_rule_pvt_w;

/
