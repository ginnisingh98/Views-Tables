--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_PVT_W" as
  /* $Header: pvxwatsb.pls 120.1 2005/06/16 11:29 appldev  $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy pv_attribute_pvt.attribute_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).enabled_flag := a7(indx);
          t(ddindx).attribute_type := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).seeded_flag := a10(indx);
          t(ddindx).lov_function_name := a11(indx);
          t(ddindx).return_type := a12(indx);
          t(ddindx).max_value_flag := a13(indx);
          t(ddindx).name := a14(indx);
          t(ddindx).description := a15(indx);
          t(ddindx).short_name := a16(indx);
          t(ddindx).display_style := a17(indx);
          t(ddindx).character_width := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).decimal_points := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).no_of_lines := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).expose_to_partner_flag := a21(indx);
          t(ddindx).value_extn_return_type := a22(indx);
          t(ddindx).enable_matching_flag := a23(indx);
          t(ddindx).performance_flag := a24(indx);
          t(ddindx).additive_flag := a25(indx);
          t(ddindx).sequence_number := rosetta_g_miss_num_map(a26(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t pv_attribute_pvt.attribute_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).enabled_flag;
          a8(indx) := t(ddindx).attribute_type;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).seeded_flag;
          a11(indx) := t(ddindx).lov_function_name;
          a12(indx) := t(ddindx).return_type;
          a13(indx) := t(ddindx).max_value_flag;
          a14(indx) := t(ddindx).name;
          a15(indx) := t(ddindx).description;
          a16(indx) := t(ddindx).short_name;
          a17(indx) := t(ddindx).display_style;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).character_width);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).decimal_points);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).no_of_lines);
          a21(indx) := t(ddindx).expose_to_partner_flag;
          a22(indx) := t(ddindx).value_extn_return_type;
          a23(indx) := t(ddindx).enable_matching_flag;
          a24(indx) := t(ddindx).performance_flag;
          a25(indx) := t(ddindx).additive_flag;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).sequence_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_attribute(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_attribute_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_attribute_rec pv_attribute_pvt.attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_attribute_rec.attribute_id := rosetta_g_miss_num_map(p7_a0);
    ddp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_attribute_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_attribute_rec.enabled_flag := p7_a7;
    ddp_attribute_rec.attribute_type := p7_a8;
    ddp_attribute_rec.attribute_category := p7_a9;
    ddp_attribute_rec.seeded_flag := p7_a10;
    ddp_attribute_rec.lov_function_name := p7_a11;
    ddp_attribute_rec.return_type := p7_a12;
    ddp_attribute_rec.max_value_flag := p7_a13;
    ddp_attribute_rec.name := p7_a14;
    ddp_attribute_rec.description := p7_a15;
    ddp_attribute_rec.short_name := p7_a16;
    ddp_attribute_rec.display_style := p7_a17;
    ddp_attribute_rec.character_width := rosetta_g_miss_num_map(p7_a18);
    ddp_attribute_rec.decimal_points := rosetta_g_miss_num_map(p7_a19);
    ddp_attribute_rec.no_of_lines := rosetta_g_miss_num_map(p7_a20);
    ddp_attribute_rec.expose_to_partner_flag := p7_a21;
    ddp_attribute_rec.value_extn_return_type := p7_a22;
    ddp_attribute_rec.enable_matching_flag := p7_a23;
    ddp_attribute_rec.performance_flag := p7_a24;
    ddp_attribute_rec.additive_flag := p7_a25;
    ddp_attribute_rec.sequence_number := rosetta_g_miss_num_map(p7_a26);


    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_pvt.create_attribute(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attribute_rec,
      x_attribute_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_attribute(p_api_version_number  NUMBER
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
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_attribute_rec pv_attribute_pvt.attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_attribute_rec.attribute_id := rosetta_g_miss_num_map(p7_a0);
    ddp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_attribute_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_attribute_rec.enabled_flag := p7_a7;
    ddp_attribute_rec.attribute_type := p7_a8;
    ddp_attribute_rec.attribute_category := p7_a9;
    ddp_attribute_rec.seeded_flag := p7_a10;
    ddp_attribute_rec.lov_function_name := p7_a11;
    ddp_attribute_rec.return_type := p7_a12;
    ddp_attribute_rec.max_value_flag := p7_a13;
    ddp_attribute_rec.name := p7_a14;
    ddp_attribute_rec.description := p7_a15;
    ddp_attribute_rec.short_name := p7_a16;
    ddp_attribute_rec.display_style := p7_a17;
    ddp_attribute_rec.character_width := rosetta_g_miss_num_map(p7_a18);
    ddp_attribute_rec.decimal_points := rosetta_g_miss_num_map(p7_a19);
    ddp_attribute_rec.no_of_lines := rosetta_g_miss_num_map(p7_a20);
    ddp_attribute_rec.expose_to_partner_flag := p7_a21;
    ddp_attribute_rec.value_extn_return_type := p7_a22;
    ddp_attribute_rec.enable_matching_flag := p7_a23;
    ddp_attribute_rec.performance_flag := p7_a24;
    ddp_attribute_rec.additive_flag := p7_a25;
    ddp_attribute_rec.sequence_number := rosetta_g_miss_num_map(p7_a26);


    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_pvt.update_attribute(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attribute_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_attribute(p_api_version_number  NUMBER
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
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_attribute_rec pv_attribute_pvt.attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_attribute_rec.attribute_id := rosetta_g_miss_num_map(p4_a0);
    ddp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_attribute_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_attribute_rec.enabled_flag := p4_a7;
    ddp_attribute_rec.attribute_type := p4_a8;
    ddp_attribute_rec.attribute_category := p4_a9;
    ddp_attribute_rec.seeded_flag := p4_a10;
    ddp_attribute_rec.lov_function_name := p4_a11;
    ddp_attribute_rec.return_type := p4_a12;
    ddp_attribute_rec.max_value_flag := p4_a13;
    ddp_attribute_rec.name := p4_a14;
    ddp_attribute_rec.description := p4_a15;
    ddp_attribute_rec.short_name := p4_a16;
    ddp_attribute_rec.display_style := p4_a17;
    ddp_attribute_rec.character_width := rosetta_g_miss_num_map(p4_a18);
    ddp_attribute_rec.decimal_points := rosetta_g_miss_num_map(p4_a19);
    ddp_attribute_rec.no_of_lines := rosetta_g_miss_num_map(p4_a20);
    ddp_attribute_rec.expose_to_partner_flag := p4_a21;
    ddp_attribute_rec.value_extn_return_type := p4_a22;
    ddp_attribute_rec.enable_matching_flag := p4_a23;
    ddp_attribute_rec.performance_flag := p4_a24;
    ddp_attribute_rec.additive_flag := p4_a25;
    ddp_attribute_rec.sequence_number := rosetta_g_miss_num_map(p4_a26);




    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_pvt.validate_attribute(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_attribute_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_attribute_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_attribute_rec pv_attribute_pvt.attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_attribute_rec.attribute_id := rosetta_g_miss_num_map(p0_a0);
    ddp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_attribute_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_attribute_rec.enabled_flag := p0_a7;
    ddp_attribute_rec.attribute_type := p0_a8;
    ddp_attribute_rec.attribute_category := p0_a9;
    ddp_attribute_rec.seeded_flag := p0_a10;
    ddp_attribute_rec.lov_function_name := p0_a11;
    ddp_attribute_rec.return_type := p0_a12;
    ddp_attribute_rec.max_value_flag := p0_a13;
    ddp_attribute_rec.name := p0_a14;
    ddp_attribute_rec.description := p0_a15;
    ddp_attribute_rec.short_name := p0_a16;
    ddp_attribute_rec.display_style := p0_a17;
    ddp_attribute_rec.character_width := rosetta_g_miss_num_map(p0_a18);
    ddp_attribute_rec.decimal_points := rosetta_g_miss_num_map(p0_a19);
    ddp_attribute_rec.no_of_lines := rosetta_g_miss_num_map(p0_a20);
    ddp_attribute_rec.expose_to_partner_flag := p0_a21;
    ddp_attribute_rec.value_extn_return_type := p0_a22;
    ddp_attribute_rec.enable_matching_flag := p0_a23;
    ddp_attribute_rec.performance_flag := p0_a24;
    ddp_attribute_rec.additive_flag := p0_a25;
    ddp_attribute_rec.sequence_number := rosetta_g_miss_num_map(p0_a26);



    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_pvt.check_attribute_items(ddp_attribute_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_attribute_rec(p_api_version_number  NUMBER
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
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_attribute_rec pv_attribute_pvt.attribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_attribute_rec.attribute_id := rosetta_g_miss_num_map(p5_a0);
    ddp_attribute_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_attribute_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_attribute_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_attribute_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_attribute_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_attribute_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_attribute_rec.enabled_flag := p5_a7;
    ddp_attribute_rec.attribute_type := p5_a8;
    ddp_attribute_rec.attribute_category := p5_a9;
    ddp_attribute_rec.seeded_flag := p5_a10;
    ddp_attribute_rec.lov_function_name := p5_a11;
    ddp_attribute_rec.return_type := p5_a12;
    ddp_attribute_rec.max_value_flag := p5_a13;
    ddp_attribute_rec.name := p5_a14;
    ddp_attribute_rec.description := p5_a15;
    ddp_attribute_rec.short_name := p5_a16;
    ddp_attribute_rec.display_style := p5_a17;
    ddp_attribute_rec.character_width := rosetta_g_miss_num_map(p5_a18);
    ddp_attribute_rec.decimal_points := rosetta_g_miss_num_map(p5_a19);
    ddp_attribute_rec.no_of_lines := rosetta_g_miss_num_map(p5_a20);
    ddp_attribute_rec.expose_to_partner_flag := p5_a21;
    ddp_attribute_rec.value_extn_return_type := p5_a22;
    ddp_attribute_rec.enable_matching_flag := p5_a23;
    ddp_attribute_rec.performance_flag := p5_a24;
    ddp_attribute_rec.additive_flag := p5_a25;
    ddp_attribute_rec.sequence_number := rosetta_g_miss_num_map(p5_a26);


    -- here's the delegated call to the old PL/SQL routine
    pv_attribute_pvt.validate_attribute_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attribute_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end pv_attribute_pvt_w;

/
