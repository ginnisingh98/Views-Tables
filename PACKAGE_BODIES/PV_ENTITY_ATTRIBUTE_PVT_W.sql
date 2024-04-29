--------------------------------------------------------
--  DDL for Package Body PV_ENTITY_ATTRIBUTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTITY_ATTRIBUTE_PVT_W" as
  /* $Header: pvxweatb.pls 120.2 2005/07/05 14:45 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_entity_attribute_pvt.pv_entity_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_2000
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entity_attr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).entity := a8(indx);
          t(ddindx).entity_type := a9(indx);
          t(ddindx).sql_text := a10(indx);
          t(ddindx).attr_data_type := a11(indx);
          t(ddindx).lov_string := a12(indx);
          t(ddindx).enabled_flag := a13(indx);
          t(ddindx).display_flag := a14(indx);
          t(ddindx).locator_flag := a15(indx);
          t(ddindx).require_validation_flag := a16(indx);
          t(ddindx).external_update_text := a17(indx);
          t(ddindx).refresh_frequency := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).refresh_frequency_uom := a19(indx);
          t(ddindx).batch_sql_text := a20(indx);
          t(ddindx).last_refresh_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).display_external_value_flag := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_entity_attribute_pvt.pv_entity_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_2000();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_2000();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).entity_attr_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a8(indx) := t(ddindx).entity;
          a9(indx) := t(ddindx).entity_type;
          a10(indx) := t(ddindx).sql_text;
          a11(indx) := t(ddindx).attr_data_type;
          a12(indx) := t(ddindx).lov_string;
          a13(indx) := t(ddindx).enabled_flag;
          a14(indx) := t(ddindx).display_flag;
          a15(indx) := t(ddindx).locator_flag;
          a16(indx) := t(ddindx).require_validation_flag;
          a17(indx) := t(ddindx).external_update_text;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).refresh_frequency);
          a19(indx) := t(ddindx).refresh_frequency_uom;
          a20(indx) := t(ddindx).batch_sql_text;
          a21(indx) := t(ddindx).last_refresh_date;
          a22(indx) := t(ddindx).display_external_value_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_entity_attr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_entity_attr_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entity_attr_rec pv_entity_attribute_pvt.entity_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_entity_attr_rec.entity_attr_id := rosetta_g_miss_num_map(p7_a0);
    ddp_entity_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_entity_attr_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_entity_attr_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_entity_attr_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_entity_attr_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_entity_attr_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_entity_attr_rec.attribute_id := rosetta_g_miss_num_map(p7_a7);
    ddp_entity_attr_rec.entity := p7_a8;
    ddp_entity_attr_rec.entity_type := p7_a9;
    ddp_entity_attr_rec.sql_text := p7_a10;
    ddp_entity_attr_rec.attr_data_type := p7_a11;
    ddp_entity_attr_rec.lov_string := p7_a12;
    ddp_entity_attr_rec.enabled_flag := p7_a13;
    ddp_entity_attr_rec.display_flag := p7_a14;
    ddp_entity_attr_rec.locator_flag := p7_a15;
    ddp_entity_attr_rec.require_validation_flag := p7_a16;
    ddp_entity_attr_rec.external_update_text := p7_a17;
    ddp_entity_attr_rec.refresh_frequency := rosetta_g_miss_num_map(p7_a18);
    ddp_entity_attr_rec.refresh_frequency_uom := p7_a19;
    ddp_entity_attr_rec.batch_sql_text := p7_a20;
    ddp_entity_attr_rec.last_refresh_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_entity_attr_rec.display_external_value_flag := p7_a22;


    -- here's the delegated call to the old PL/SQL routine
    pv_entity_attribute_pvt.create_entity_attr(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_entity_attr_rec,
      x_entity_attr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_entity_attr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entity_attr_rec pv_entity_attribute_pvt.entity_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_entity_attr_rec.entity_attr_id := rosetta_g_miss_num_map(p7_a0);
    ddp_entity_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_entity_attr_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_entity_attr_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_entity_attr_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_entity_attr_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_entity_attr_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_entity_attr_rec.attribute_id := rosetta_g_miss_num_map(p7_a7);
    ddp_entity_attr_rec.entity := p7_a8;
    ddp_entity_attr_rec.entity_type := p7_a9;
    ddp_entity_attr_rec.sql_text := p7_a10;
    ddp_entity_attr_rec.attr_data_type := p7_a11;
    ddp_entity_attr_rec.lov_string := p7_a12;
    ddp_entity_attr_rec.enabled_flag := p7_a13;
    ddp_entity_attr_rec.display_flag := p7_a14;
    ddp_entity_attr_rec.locator_flag := p7_a15;
    ddp_entity_attr_rec.require_validation_flag := p7_a16;
    ddp_entity_attr_rec.external_update_text := p7_a17;
    ddp_entity_attr_rec.refresh_frequency := rosetta_g_miss_num_map(p7_a18);
    ddp_entity_attr_rec.refresh_frequency_uom := p7_a19;
    ddp_entity_attr_rec.batch_sql_text := p7_a20;
    ddp_entity_attr_rec.last_refresh_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_entity_attr_rec.display_external_value_flag := p7_a22;


    -- here's the delegated call to the old PL/SQL routine
    pv_entity_attribute_pvt.update_entity_attr(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_entity_attr_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_entity_attr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entity_attr_rec pv_entity_attribute_pvt.entity_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_entity_attr_rec.entity_attr_id := rosetta_g_miss_num_map(p4_a0);
    ddp_entity_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_entity_attr_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_entity_attr_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_entity_attr_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_entity_attr_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_entity_attr_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_entity_attr_rec.attribute_id := rosetta_g_miss_num_map(p4_a7);
    ddp_entity_attr_rec.entity := p4_a8;
    ddp_entity_attr_rec.entity_type := p4_a9;
    ddp_entity_attr_rec.sql_text := p4_a10;
    ddp_entity_attr_rec.attr_data_type := p4_a11;
    ddp_entity_attr_rec.lov_string := p4_a12;
    ddp_entity_attr_rec.enabled_flag := p4_a13;
    ddp_entity_attr_rec.display_flag := p4_a14;
    ddp_entity_attr_rec.locator_flag := p4_a15;
    ddp_entity_attr_rec.require_validation_flag := p4_a16;
    ddp_entity_attr_rec.external_update_text := p4_a17;
    ddp_entity_attr_rec.refresh_frequency := rosetta_g_miss_num_map(p4_a18);
    ddp_entity_attr_rec.refresh_frequency_uom := p4_a19;
    ddp_entity_attr_rec.batch_sql_text := p4_a20;
    ddp_entity_attr_rec.last_refresh_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_entity_attr_rec.display_external_value_flag := p4_a22;




    -- here's the delegated call to the old PL/SQL routine
    pv_entity_attribute_pvt.validate_entity_attr(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_entity_attr_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_entity_attr_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  DATE := fnd_api.g_miss_date
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entity_attr_rec pv_entity_attribute_pvt.entity_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_entity_attr_rec.entity_attr_id := rosetta_g_miss_num_map(p0_a0);
    ddp_entity_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_entity_attr_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_entity_attr_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_entity_attr_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_entity_attr_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_entity_attr_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_entity_attr_rec.attribute_id := rosetta_g_miss_num_map(p0_a7);
    ddp_entity_attr_rec.entity := p0_a8;
    ddp_entity_attr_rec.entity_type := p0_a9;
    ddp_entity_attr_rec.sql_text := p0_a10;
    ddp_entity_attr_rec.attr_data_type := p0_a11;
    ddp_entity_attr_rec.lov_string := p0_a12;
    ddp_entity_attr_rec.enabled_flag := p0_a13;
    ddp_entity_attr_rec.display_flag := p0_a14;
    ddp_entity_attr_rec.locator_flag := p0_a15;
    ddp_entity_attr_rec.require_validation_flag := p0_a16;
    ddp_entity_attr_rec.external_update_text := p0_a17;
    ddp_entity_attr_rec.refresh_frequency := rosetta_g_miss_num_map(p0_a18);
    ddp_entity_attr_rec.refresh_frequency_uom := p0_a19;
    ddp_entity_attr_rec.batch_sql_text := p0_a20;
    ddp_entity_attr_rec.last_refresh_date := rosetta_g_miss_date_in_map(p0_a21);
    ddp_entity_attr_rec.display_external_value_flag := p0_a22;



    -- here's the delegated call to the old PL/SQL routine
    pv_entity_attribute_pvt.check_entity_attr_items(ddp_entity_attr_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_entity_attr_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_validation_mode  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entity_attr_rec pv_entity_attribute_pvt.entity_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_entity_attr_rec.entity_attr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_entity_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_entity_attr_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_entity_attr_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_entity_attr_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_entity_attr_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_entity_attr_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_entity_attr_rec.attribute_id := rosetta_g_miss_num_map(p5_a7);
    ddp_entity_attr_rec.entity := p5_a8;
    ddp_entity_attr_rec.entity_type := p5_a9;
    ddp_entity_attr_rec.sql_text := p5_a10;
    ddp_entity_attr_rec.attr_data_type := p5_a11;
    ddp_entity_attr_rec.lov_string := p5_a12;
    ddp_entity_attr_rec.enabled_flag := p5_a13;
    ddp_entity_attr_rec.display_flag := p5_a14;
    ddp_entity_attr_rec.locator_flag := p5_a15;
    ddp_entity_attr_rec.require_validation_flag := p5_a16;
    ddp_entity_attr_rec.external_update_text := p5_a17;
    ddp_entity_attr_rec.refresh_frequency := rosetta_g_miss_num_map(p5_a18);
    ddp_entity_attr_rec.refresh_frequency_uom := p5_a19;
    ddp_entity_attr_rec.batch_sql_text := p5_a20;
    ddp_entity_attr_rec.last_refresh_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_entity_attr_rec.display_external_value_flag := p5_a22;


    -- here's the delegated call to the old PL/SQL routine
    pv_entity_attribute_pvt.validate_entity_attr_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_entity_attr_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end pv_entity_attribute_pvt_w;

/
