--------------------------------------------------------
--  DDL for Package Body PV_GE_NOTIF_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_NOTIF_RULES_PVT_W" as
  /* $Header: pvxwgnrb.pls 115.2 2002/11/21 08:55:26 anubhavk ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_ge_notif_rules_pvt.ge_notif_rules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_4000
    , a21 JTF_VARCHAR2_TABLE_4000
    , a22 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).notif_rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).arc_notif_for_entity_code := a2(indx);
          t(ddindx).notif_for_entity_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).wf_item_type_code := a4(indx);
          t(ddindx).notif_type_code := a5(indx);
          t(ddindx).active_flag := a6(indx);
          t(ddindx).repeat_freq_unit := a7(indx);
          t(ddindx).repeat_freq_value := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).send_notif_before_unit := a9(indx);
          t(ddindx).send_notif_before_value := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).send_notif_after_unit := a11(indx);
          t(ddindx).send_notif_after_value := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).repeat_until_unit := a13(indx);
          t(ddindx).repeat_until_value := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).notif_name := a20(indx);
          t(ddindx).notif_content := a21(indx);
          t(ddindx).notif_desc := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_ge_notif_rules_pvt.ge_notif_rules_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , a22 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_4000();
    a21 := JTF_VARCHAR2_TABLE_4000();
    a22 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_4000();
      a21 := JTF_VARCHAR2_TABLE_4000();
      a22 := JTF_VARCHAR2_TABLE_4000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).notif_rule_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).arc_notif_for_entity_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).notif_for_entity_id);
          a4(indx) := t(ddindx).wf_item_type_code;
          a5(indx) := t(ddindx).notif_type_code;
          a6(indx) := t(ddindx).active_flag;
          a7(indx) := t(ddindx).repeat_freq_unit;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).repeat_freq_value);
          a9(indx) := t(ddindx).send_notif_before_unit;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).send_notif_before_value);
          a11(indx) := t(ddindx).send_notif_after_unit;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).send_notif_after_value);
          a13(indx) := t(ddindx).repeat_until_unit;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).repeat_until_value);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a20(indx) := t(ddindx).notif_name;
          a21(indx) := t(ddindx).notif_content;
          a22(indx) := t(ddindx).notif_desc;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_ge_notif_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_notif_rule_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ge_notif_rules_rec pv_ge_notif_rules_pvt.ge_notif_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ge_notif_rules_rec.notif_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ge_notif_rules_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_ge_notif_rules_rec.arc_notif_for_entity_code := p7_a2;
    ddp_ge_notif_rules_rec.notif_for_entity_id := rosetta_g_miss_num_map(p7_a3);
    ddp_ge_notif_rules_rec.wf_item_type_code := p7_a4;
    ddp_ge_notif_rules_rec.notif_type_code := p7_a5;
    ddp_ge_notif_rules_rec.active_flag := p7_a6;
    ddp_ge_notif_rules_rec.repeat_freq_unit := p7_a7;
    ddp_ge_notif_rules_rec.repeat_freq_value := rosetta_g_miss_num_map(p7_a8);
    ddp_ge_notif_rules_rec.send_notif_before_unit := p7_a9;
    ddp_ge_notif_rules_rec.send_notif_before_value := rosetta_g_miss_num_map(p7_a10);
    ddp_ge_notif_rules_rec.send_notif_after_unit := p7_a11;
    ddp_ge_notif_rules_rec.send_notif_after_value := rosetta_g_miss_num_map(p7_a12);
    ddp_ge_notif_rules_rec.repeat_until_unit := p7_a13;
    ddp_ge_notif_rules_rec.repeat_until_value := rosetta_g_miss_num_map(p7_a14);
    ddp_ge_notif_rules_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_ge_notif_rules_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_ge_notif_rules_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_ge_notif_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_ge_notif_rules_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);
    ddp_ge_notif_rules_rec.notif_name := p7_a20;
    ddp_ge_notif_rules_rec.notif_content := p7_a21;
    ddp_ge_notif_rules_rec.notif_desc := p7_a22;


    -- here's the delegated call to the old PL/SQL routine
    pv_ge_notif_rules_pvt.create_ge_notif_rules(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_notif_rules_rec,
      x_notif_rule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ge_notif_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ge_notif_rules_rec pv_ge_notif_rules_pvt.ge_notif_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ge_notif_rules_rec.notif_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ge_notif_rules_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_ge_notif_rules_rec.arc_notif_for_entity_code := p7_a2;
    ddp_ge_notif_rules_rec.notif_for_entity_id := rosetta_g_miss_num_map(p7_a3);
    ddp_ge_notif_rules_rec.wf_item_type_code := p7_a4;
    ddp_ge_notif_rules_rec.notif_type_code := p7_a5;
    ddp_ge_notif_rules_rec.active_flag := p7_a6;
    ddp_ge_notif_rules_rec.repeat_freq_unit := p7_a7;
    ddp_ge_notif_rules_rec.repeat_freq_value := rosetta_g_miss_num_map(p7_a8);
    ddp_ge_notif_rules_rec.send_notif_before_unit := p7_a9;
    ddp_ge_notif_rules_rec.send_notif_before_value := rosetta_g_miss_num_map(p7_a10);
    ddp_ge_notif_rules_rec.send_notif_after_unit := p7_a11;
    ddp_ge_notif_rules_rec.send_notif_after_value := rosetta_g_miss_num_map(p7_a12);
    ddp_ge_notif_rules_rec.repeat_until_unit := p7_a13;
    ddp_ge_notif_rules_rec.repeat_until_value := rosetta_g_miss_num_map(p7_a14);
    ddp_ge_notif_rules_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_ge_notif_rules_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_ge_notif_rules_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_ge_notif_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_ge_notif_rules_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);
    ddp_ge_notif_rules_rec.notif_name := p7_a20;
    ddp_ge_notif_rules_rec.notif_content := p7_a21;
    ddp_ge_notif_rules_rec.notif_desc := p7_a22;

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_notif_rules_pvt.update_ge_notif_rules(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_notif_rules_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_ge_notif_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  DATE := fnd_api.g_miss_date
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  DATE := fnd_api.g_miss_date
    , p3_a19  NUMBER := 0-1962.0724
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ge_notif_rules_rec pv_ge_notif_rules_pvt.ge_notif_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ge_notif_rules_rec.notif_rule_id := rosetta_g_miss_num_map(p3_a0);
    ddp_ge_notif_rules_rec.object_version_number := rosetta_g_miss_num_map(p3_a1);
    ddp_ge_notif_rules_rec.arc_notif_for_entity_code := p3_a2;
    ddp_ge_notif_rules_rec.notif_for_entity_id := rosetta_g_miss_num_map(p3_a3);
    ddp_ge_notif_rules_rec.wf_item_type_code := p3_a4;
    ddp_ge_notif_rules_rec.notif_type_code := p3_a5;
    ddp_ge_notif_rules_rec.active_flag := p3_a6;
    ddp_ge_notif_rules_rec.repeat_freq_unit := p3_a7;
    ddp_ge_notif_rules_rec.repeat_freq_value := rosetta_g_miss_num_map(p3_a8);
    ddp_ge_notif_rules_rec.send_notif_before_unit := p3_a9;
    ddp_ge_notif_rules_rec.send_notif_before_value := rosetta_g_miss_num_map(p3_a10);
    ddp_ge_notif_rules_rec.send_notif_after_unit := p3_a11;
    ddp_ge_notif_rules_rec.send_notif_after_value := rosetta_g_miss_num_map(p3_a12);
    ddp_ge_notif_rules_rec.repeat_until_unit := p3_a13;
    ddp_ge_notif_rules_rec.repeat_until_value := rosetta_g_miss_num_map(p3_a14);
    ddp_ge_notif_rules_rec.created_by := rosetta_g_miss_num_map(p3_a15);
    ddp_ge_notif_rules_rec.creation_date := rosetta_g_miss_date_in_map(p3_a16);
    ddp_ge_notif_rules_rec.last_updated_by := rosetta_g_miss_num_map(p3_a17);
    ddp_ge_notif_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a18);
    ddp_ge_notif_rules_rec.last_update_login := rosetta_g_miss_num_map(p3_a19);
    ddp_ge_notif_rules_rec.notif_name := p3_a20;
    ddp_ge_notif_rules_rec.notif_content := p3_a21;
    ddp_ge_notif_rules_rec.notif_desc := p3_a22;





    -- here's the delegated call to the old PL/SQL routine
    pv_ge_notif_rules_pvt.validate_ge_notif_rules(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ge_notif_rules_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_ge_notif_rules_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ge_notif_rules_rec pv_ge_notif_rules_pvt.ge_notif_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ge_notif_rules_rec.notif_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_ge_notif_rules_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_ge_notif_rules_rec.arc_notif_for_entity_code := p0_a2;
    ddp_ge_notif_rules_rec.notif_for_entity_id := rosetta_g_miss_num_map(p0_a3);
    ddp_ge_notif_rules_rec.wf_item_type_code := p0_a4;
    ddp_ge_notif_rules_rec.notif_type_code := p0_a5;
    ddp_ge_notif_rules_rec.active_flag := p0_a6;
    ddp_ge_notif_rules_rec.repeat_freq_unit := p0_a7;
    ddp_ge_notif_rules_rec.repeat_freq_value := rosetta_g_miss_num_map(p0_a8);
    ddp_ge_notif_rules_rec.send_notif_before_unit := p0_a9;
    ddp_ge_notif_rules_rec.send_notif_before_value := rosetta_g_miss_num_map(p0_a10);
    ddp_ge_notif_rules_rec.send_notif_after_unit := p0_a11;
    ddp_ge_notif_rules_rec.send_notif_after_value := rosetta_g_miss_num_map(p0_a12);
    ddp_ge_notif_rules_rec.repeat_until_unit := p0_a13;
    ddp_ge_notif_rules_rec.repeat_until_value := rosetta_g_miss_num_map(p0_a14);
    ddp_ge_notif_rules_rec.created_by := rosetta_g_miss_num_map(p0_a15);
    ddp_ge_notif_rules_rec.creation_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_ge_notif_rules_rec.last_updated_by := rosetta_g_miss_num_map(p0_a17);
    ddp_ge_notif_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a18);
    ddp_ge_notif_rules_rec.last_update_login := rosetta_g_miss_num_map(p0_a19);
    ddp_ge_notif_rules_rec.notif_name := p0_a20;
    ddp_ge_notif_rules_rec.notif_content := p0_a21;
    ddp_ge_notif_rules_rec.notif_desc := p0_a22;



    -- here's the delegated call to the old PL/SQL routine
    pv_ge_notif_rules_pvt.check_ge_notif_rules_items(ddp_ge_notif_rules_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_ge_notif_rules_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ge_notif_rules_rec pv_ge_notif_rules_pvt.ge_notif_rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ge_notif_rules_rec.notif_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_ge_notif_rules_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ge_notif_rules_rec.arc_notif_for_entity_code := p5_a2;
    ddp_ge_notif_rules_rec.notif_for_entity_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ge_notif_rules_rec.wf_item_type_code := p5_a4;
    ddp_ge_notif_rules_rec.notif_type_code := p5_a5;
    ddp_ge_notif_rules_rec.active_flag := p5_a6;
    ddp_ge_notif_rules_rec.repeat_freq_unit := p5_a7;
    ddp_ge_notif_rules_rec.repeat_freq_value := rosetta_g_miss_num_map(p5_a8);
    ddp_ge_notif_rules_rec.send_notif_before_unit := p5_a9;
    ddp_ge_notif_rules_rec.send_notif_before_value := rosetta_g_miss_num_map(p5_a10);
    ddp_ge_notif_rules_rec.send_notif_after_unit := p5_a11;
    ddp_ge_notif_rules_rec.send_notif_after_value := rosetta_g_miss_num_map(p5_a12);
    ddp_ge_notif_rules_rec.repeat_until_unit := p5_a13;
    ddp_ge_notif_rules_rec.repeat_until_value := rosetta_g_miss_num_map(p5_a14);
    ddp_ge_notif_rules_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_ge_notif_rules_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_ge_notif_rules_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_ge_notif_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_ge_notif_rules_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);
    ddp_ge_notif_rules_rec.notif_name := p5_a20;
    ddp_ge_notif_rules_rec.notif_content := p5_a21;
    ddp_ge_notif_rules_rec.notif_desc := p5_a22;

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_notif_rules_pvt.validate_ge_notif_rules_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ge_notif_rules_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_ge_notif_rules_pvt_w;

/
