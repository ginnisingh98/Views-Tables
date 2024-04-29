--------------------------------------------------------
--  DDL for Package Body AMS_PS_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_RULE_PVT_W" as
  /* $Header: amswrulb.pls 120.0 2005/06/01 02:58:02 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_ps_rule_pvt.ps_rules_tuple_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_ps_rule_pvt.ps_rules_tuple_tbl_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p8(t OUT NOCOPY ams_ps_rule_pvt.ps_rules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).created_by := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).rule_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).rulegroup_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).posting_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).strategy_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).exec_priority := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).bus_priority_code := a11(indx);
          t(ddindx).bus_priority_disp_order := a12(indx);
          t(ddindx).clausevalue1 := a13(indx);
          t(ddindx).clausevalue2 := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).clausevalue3 := a15(indx);
          t(ddindx).clausevalue4 := a16(indx);
          t(ddindx).clausevalue5 := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).clausevalue6 := a18(indx);
          t(ddindx).clausevalue7 := a19(indx);
          t(ddindx).clausevalue8 := a20(indx);
          t(ddindx).clausevalue9 := a21(indx);
          t(ddindx).clausevalue10 := a22(indx);
          t(ddindx).use_clause6 := a23(indx);
          t(ddindx).use_clause7 := a24(indx);
          t(ddindx).use_clause8 := a25(indx);
          t(ddindx).use_clause9 := a26(indx);
          t(ddindx).use_clause10 := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ams_ps_rule_pvt.ps_rules_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_NUMBER_TABLE
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a27 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
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
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a1(indx) := t(ddindx).creation_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).rulegroup_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).posting_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).strategy_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).exec_priority);
          a11(indx) := t(ddindx).bus_priority_code;
          a12(indx) := t(ddindx).bus_priority_disp_order;
          a13(indx) := t(ddindx).clausevalue1;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).clausevalue2);
          a15(indx) := t(ddindx).clausevalue3;
          a16(indx) := t(ddindx).clausevalue4;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).clausevalue5);
          a18(indx) := t(ddindx).clausevalue6;
          a19(indx) := t(ddindx).clausevalue7;
          a20(indx) := t(ddindx).clausevalue8;
          a21(indx) := t(ddindx).clausevalue9;
          a22(indx) := t(ddindx).clausevalue10;
          a23(indx) := t(ddindx).use_clause6;
          a24(indx) := t(ddindx).use_clause7;
          a25(indx) := t(ddindx).use_clause8;
          a26(indx) := t(ddindx).use_clause9;
          a27(indx) := t(ddindx).use_clause10;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure create_ps_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , x_rule_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddp_visitor_rec ams_ps_rule_pvt.visitor_type_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p7_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p7_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p7_a10);
    ddp_ps_rules_rec.bus_priority_code := p7_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p7_a12;
    ddp_ps_rules_rec.clausevalue1 := p7_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p7_a14);
    ddp_ps_rules_rec.clausevalue3 := p7_a15;
    ddp_ps_rules_rec.clausevalue4 := p7_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p7_a17);
    ddp_ps_rules_rec.clausevalue6 := p7_a18;
    ddp_ps_rules_rec.clausevalue7 := p7_a19;
    ddp_ps_rules_rec.clausevalue8 := p7_a20;
    ddp_ps_rules_rec.clausevalue9 := p7_a21;
    ddp_ps_rules_rec.clausevalue10 := p7_a22;
    ddp_ps_rules_rec.use_clause6 := p7_a23;
    ddp_ps_rules_rec.use_clause7 := p7_a24;
    ddp_ps_rules_rec.use_clause8 := p7_a25;
    ddp_ps_rules_rec.use_clause9 := p7_a26;
    ddp_ps_rules_rec.use_clause10 := p7_a27;

    if p8_a0 is null
      then ddp_visitor_rec.anon := null;
    elsif p8_a0 = 0
      then ddp_visitor_rec.anon := false;
    else ddp_visitor_rec.anon := true;
    end if;
    if p8_a1 is null
      then ddp_visitor_rec.rgoh := null;
    elsif p8_a1 = 0
      then ddp_visitor_rec.rgoh := false;
    else ddp_visitor_rec.rgoh := true;
    end if;
    if p8_a2 is null
      then ddp_visitor_rec.rgnoh := null;
    elsif p8_a2 = 0
      then ddp_visitor_rec.rgnoh := false;
    else ddp_visitor_rec.rgnoh := true;
    end if;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.create_ps_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_rules_rec,
      ddp_visitor_rec,
      x_rule_id);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_ps_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddp_visitor_rec ams_ps_rule_pvt.visitor_type_rec;
    ddp_ps_filter_tbl ams_ps_rule_pvt.ps_rules_tuple_tbl_type;
    ddp_ps_strategy_tbl ams_ps_rule_pvt.ps_rules_tuple_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p7_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p7_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p7_a10);
    ddp_ps_rules_rec.bus_priority_code := p7_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p7_a12;
    ddp_ps_rules_rec.clausevalue1 := p7_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p7_a14);
    ddp_ps_rules_rec.clausevalue3 := p7_a15;
    ddp_ps_rules_rec.clausevalue4 := p7_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p7_a17);
    ddp_ps_rules_rec.clausevalue6 := p7_a18;
    ddp_ps_rules_rec.clausevalue7 := p7_a19;
    ddp_ps_rules_rec.clausevalue8 := p7_a20;
    ddp_ps_rules_rec.clausevalue9 := p7_a21;
    ddp_ps_rules_rec.clausevalue10 := p7_a22;
    ddp_ps_rules_rec.use_clause6 := p7_a23;
    ddp_ps_rules_rec.use_clause7 := p7_a24;
    ddp_ps_rules_rec.use_clause8 := p7_a25;
    ddp_ps_rules_rec.use_clause9 := p7_a26;
    ddp_ps_rules_rec.use_clause10 := p7_a27;

    if p8_a0 is null
      then ddp_visitor_rec.anon := null;
    elsif p8_a0 = 0
      then ddp_visitor_rec.anon := false;
    else ddp_visitor_rec.anon := true;
    end if;
    if p8_a1 is null
      then ddp_visitor_rec.rgoh := null;
    elsif p8_a1 = 0
      then ddp_visitor_rec.rgoh := false;
    else ddp_visitor_rec.rgoh := true;
    end if;
    if p8_a2 is null
      then ddp_visitor_rec.rgnoh := null;
    elsif p8_a2 = 0
      then ddp_visitor_rec.rgnoh := false;
    else ddp_visitor_rec.rgnoh := true;
    end if;

    ams_ps_rule_pvt_w.rosetta_table_copy_in_p3(ddp_ps_filter_tbl, p9_a0
      , p9_a1
      );

    ams_ps_rule_pvt_w.rosetta_table_copy_in_p3(ddp_ps_strategy_tbl, p10_a0
      , p10_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.update_ps_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_rules_rec,
      ddp_visitor_rec,
      ddp_ps_filter_tbl,
      ddp_ps_strategy_tbl,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

  procedure update_ps_rule_alt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p_vistype_change  number
    , p_rem_change  number
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddp_visitor_rec ams_ps_rule_pvt.visitor_type_rec;
    ddp_ps_filter_tbl ams_ps_rule_pvt.ps_rules_tuple_tbl_type;
    ddp_ps_strategy_tbl ams_ps_rule_pvt.ps_rules_tuple_tbl_type;
    ddp_vistype_change boolean;
    ddp_rem_change boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p7_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p7_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p7_a10);
    ddp_ps_rules_rec.bus_priority_code := p7_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p7_a12;
    ddp_ps_rules_rec.clausevalue1 := p7_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p7_a14);
    ddp_ps_rules_rec.clausevalue3 := p7_a15;
    ddp_ps_rules_rec.clausevalue4 := p7_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p7_a17);
    ddp_ps_rules_rec.clausevalue6 := p7_a18;
    ddp_ps_rules_rec.clausevalue7 := p7_a19;
    ddp_ps_rules_rec.clausevalue8 := p7_a20;
    ddp_ps_rules_rec.clausevalue9 := p7_a21;
    ddp_ps_rules_rec.clausevalue10 := p7_a22;
    ddp_ps_rules_rec.use_clause6 := p7_a23;
    ddp_ps_rules_rec.use_clause7 := p7_a24;
    ddp_ps_rules_rec.use_clause8 := p7_a25;
    ddp_ps_rules_rec.use_clause9 := p7_a26;
    ddp_ps_rules_rec.use_clause10 := p7_a27;

    if p8_a0 is null
      then ddp_visitor_rec.anon := null;
    elsif p8_a0 = 0
      then ddp_visitor_rec.anon := false;
    else ddp_visitor_rec.anon := true;
    end if;
    if p8_a1 is null
      then ddp_visitor_rec.rgoh := null;
    elsif p8_a1 = 0
      then ddp_visitor_rec.rgoh := false;
    else ddp_visitor_rec.rgoh := true;
    end if;
    if p8_a2 is null
      then ddp_visitor_rec.rgnoh := null;
    elsif p8_a2 = 0
      then ddp_visitor_rec.rgnoh := false;
    else ddp_visitor_rec.rgnoh := true;
    end if;

    ams_ps_rule_pvt_w.rosetta_table_copy_in_p3(ddp_ps_filter_tbl, p9_a0
      , p9_a1
      );

    ams_ps_rule_pvt_w.rosetta_table_copy_in_p3(ddp_ps_strategy_tbl, p10_a0
      , p10_a1
      );

    if p_vistype_change is null
      then ddp_vistype_change := null;
    elsif p_vistype_change = 0
      then ddp_vistype_change := false;
    else ddp_vistype_change := true;
    end if;

    if p_rem_change is null
      then ddp_rem_change := null;
    elsif p_rem_change = 0
      then ddp_rem_change := false;
    else ddp_rem_change := true;
    end if;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.update_ps_rule_alt(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_rules_rec,
      ddp_visitor_rec,
      ddp_ps_filter_tbl,
      ddp_ps_strategy_tbl,
      ddp_vistype_change,
      ddp_rem_change,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any













  end;

  procedure delete_ps_rule_alt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_object_version_number  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p7_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p7_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p7_a10);
    ddp_ps_rules_rec.bus_priority_code := p7_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p7_a12;
    ddp_ps_rules_rec.clausevalue1 := p7_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p7_a14);
    ddp_ps_rules_rec.clausevalue3 := p7_a15;
    ddp_ps_rules_rec.clausevalue4 := p7_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p7_a17);
    ddp_ps_rules_rec.clausevalue6 := p7_a18;
    ddp_ps_rules_rec.clausevalue7 := p7_a19;
    ddp_ps_rules_rec.clausevalue8 := p7_a20;
    ddp_ps_rules_rec.clausevalue9 := p7_a21;
    ddp_ps_rules_rec.clausevalue10 := p7_a22;
    ddp_ps_rules_rec.use_clause6 := p7_a23;
    ddp_ps_rules_rec.use_clause7 := p7_a24;
    ddp_ps_rules_rec.use_clause8 := p7_a25;
    ddp_ps_rules_rec.use_clause9 := p7_a26;
    ddp_ps_rules_rec.use_clause10 := p7_a27;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.delete_ps_rule_alt(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_rules_rec,
      p_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_ps_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p3_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p3_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p3_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p3_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p3_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p3_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p3_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p3_a10);
    ddp_ps_rules_rec.bus_priority_code := p3_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p3_a12;
    ddp_ps_rules_rec.clausevalue1 := p3_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p3_a14);
    ddp_ps_rules_rec.clausevalue3 := p3_a15;
    ddp_ps_rules_rec.clausevalue4 := p3_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p3_a17);
    ddp_ps_rules_rec.clausevalue6 := p3_a18;
    ddp_ps_rules_rec.clausevalue7 := p3_a19;
    ddp_ps_rules_rec.clausevalue8 := p3_a20;
    ddp_ps_rules_rec.clausevalue9 := p3_a21;
    ddp_ps_rules_rec.clausevalue10 := p3_a22;
    ddp_ps_rules_rec.use_clause6 := p3_a23;
    ddp_ps_rules_rec.use_clause7 := p3_a24;
    ddp_ps_rules_rec.use_clause8 := p3_a25;
    ddp_ps_rules_rec.use_clause9 := p3_a26;
    ddp_ps_rules_rec.use_clause10 := p3_a27;




    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.validate_ps_rule(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ps_rules_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_ps_rules_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p0_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p0_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p0_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p0_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p0_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p0_a10);
    ddp_ps_rules_rec.bus_priority_code := p0_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p0_a12;
    ddp_ps_rules_rec.clausevalue1 := p0_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p0_a14);
    ddp_ps_rules_rec.clausevalue3 := p0_a15;
    ddp_ps_rules_rec.clausevalue4 := p0_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p0_a17);
    ddp_ps_rules_rec.clausevalue6 := p0_a18;
    ddp_ps_rules_rec.clausevalue7 := p0_a19;
    ddp_ps_rules_rec.clausevalue8 := p0_a20;
    ddp_ps_rules_rec.clausevalue9 := p0_a21;
    ddp_ps_rules_rec.clausevalue10 := p0_a22;
    ddp_ps_rules_rec.use_clause6 := p0_a23;
    ddp_ps_rules_rec.use_clause7 := p0_a24;
    ddp_ps_rules_rec.use_clause8 := p0_a25;
    ddp_ps_rules_rec.use_clause9 := p0_a26;
    ddp_ps_rules_rec.use_clause10 := p0_a27;



    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.check_ps_rules_items(ddp_ps_rules_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure update_filters(p_rulegroup_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY  VARCHAR2
  )
  as
    ddp_ps_filter_tbl ams_ps_rule_pvt.ps_rules_tuple_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ams_ps_rule_pvt_w.rosetta_table_copy_in_p3(ddp_ps_filter_tbl, p1_a0
      , p1_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.update_filters(p_rulegroup_id,
      ddp_ps_filter_tbl,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure update_strategy_params(p_rulegroup_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY  VARCHAR2
  )
  as
    ddp_ps_strategy_tbl ams_ps_rule_pvt.ps_rules_tuple_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ams_ps_rule_pvt_w.rosetta_table_copy_in_p3(ddp_ps_strategy_tbl, p1_a0
      , p1_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.update_strategy_params(p_rulegroup_id,
      ddp_ps_strategy_tbl,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_ps_rules_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_rules_rec ams_ps_rule_pvt.ps_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ps_rules_rec.created_by := rosetta_g_miss_num_map(p5_a0);
    ddp_ps_rules_rec.creation_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_ps_rules_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_ps_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_ps_rules_rec.last_update_login := rosetta_g_miss_num_map(p5_a4);
    ddp_ps_rules_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_ps_rules_rec.rule_id := rosetta_g_miss_num_map(p5_a6);
    ddp_ps_rules_rec.rulegroup_id := rosetta_g_miss_num_map(p5_a7);
    ddp_ps_rules_rec.posting_id := rosetta_g_miss_num_map(p5_a8);
    ddp_ps_rules_rec.strategy_id := rosetta_g_miss_num_map(p5_a9);
    ddp_ps_rules_rec.exec_priority := rosetta_g_miss_num_map(p5_a10);
    ddp_ps_rules_rec.bus_priority_code := p5_a11;
    ddp_ps_rules_rec.bus_priority_disp_order := p5_a12;
    ddp_ps_rules_rec.clausevalue1 := p5_a13;
    ddp_ps_rules_rec.clausevalue2 := rosetta_g_miss_num_map(p5_a14);
    ddp_ps_rules_rec.clausevalue3 := p5_a15;
    ddp_ps_rules_rec.clausevalue4 := p5_a16;
    ddp_ps_rules_rec.clausevalue5 := rosetta_g_miss_num_map(p5_a17);
    ddp_ps_rules_rec.clausevalue6 := p5_a18;
    ddp_ps_rules_rec.clausevalue7 := p5_a19;
    ddp_ps_rules_rec.clausevalue8 := p5_a20;
    ddp_ps_rules_rec.clausevalue9 := p5_a21;
    ddp_ps_rules_rec.clausevalue10 := p5_a22;
    ddp_ps_rules_rec.use_clause6 := p5_a23;
    ddp_ps_rules_rec.use_clause7 := p5_a24;
    ddp_ps_rules_rec.use_clause8 := p5_a25;
    ddp_ps_rules_rec.use_clause9 := p5_a26;
    ddp_ps_rules_rec.use_clause10 := p5_a27;

    -- here's the delegated call to the old PL/SQL routine
    ams_ps_rule_pvt.validate_ps_rules_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_rules_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_ps_rule_pvt_w;

/
