--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALUE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALUE_PVT_W" as
  /* $Header: pvxweavb.pls 120.1 2005/11/11 15:27 amaram noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_enty_attr_value_pvt.enty_attr_value_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).enty_attr_val_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).entity := a7(indx);
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).party_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).attr_value := a10(indx);
          t(ddindx).score := a11(indx);
          t(ddindx).enabled_flag := a12(indx);
          t(ddindx).entity_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).version := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).latest_flag := a15(indx);
          t(ddindx).attr_value_extn := a16(indx);
          t(ddindx).validation_id := rosetta_g_miss_num_map(a17(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_enty_attr_value_pvt.enty_attr_value_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).enty_attr_val_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).entity;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a10(indx) := t(ddindx).attr_value;
          a11(indx) := t(ddindx).score;
          a12(indx) := t(ddindx).enabled_flag;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).entity_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).version);
          a15(indx) := t(ddindx).latest_flag;
          a16(indx) := t(ddindx).attr_value_extn;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).validation_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_attr_value(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_enty_attr_val_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_enty_attr_val_rec pv_enty_attr_value_pvt.enty_attr_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enty_attr_val_rec.enty_attr_val_id := rosetta_g_miss_num_map(p7_a0);
    ddp_enty_attr_val_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_enty_attr_val_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_enty_attr_val_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_enty_attr_val_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_enty_attr_val_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_enty_attr_val_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_enty_attr_val_rec.entity := p7_a7;
    ddp_enty_attr_val_rec.attribute_id := rosetta_g_miss_num_map(p7_a8);
    ddp_enty_attr_val_rec.party_id := rosetta_g_miss_num_map(p7_a9);
    ddp_enty_attr_val_rec.attr_value := p7_a10;
    ddp_enty_attr_val_rec.score := p7_a11;
    ddp_enty_attr_val_rec.enabled_flag := p7_a12;
    ddp_enty_attr_val_rec.entity_id := rosetta_g_miss_num_map(p7_a13);
    ddp_enty_attr_val_rec.version := rosetta_g_miss_num_map(p7_a14);
    ddp_enty_attr_val_rec.latest_flag := p7_a15;
    ddp_enty_attr_val_rec.attr_value_extn := p7_a16;
    ddp_enty_attr_val_rec.validation_id := rosetta_g_miss_num_map(p7_a17);


    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pvt.create_attr_value(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_val_rec,
      x_enty_attr_val_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_attr_value(p_api_version_number  NUMBER
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
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_enty_attr_val_rec pv_enty_attr_value_pvt.enty_attr_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enty_attr_val_rec.enty_attr_val_id := rosetta_g_miss_num_map(p7_a0);
    ddp_enty_attr_val_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_enty_attr_val_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_enty_attr_val_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_enty_attr_val_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_enty_attr_val_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_enty_attr_val_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_enty_attr_val_rec.entity := p7_a7;
    ddp_enty_attr_val_rec.attribute_id := rosetta_g_miss_num_map(p7_a8);
    ddp_enty_attr_val_rec.party_id := rosetta_g_miss_num_map(p7_a9);
    ddp_enty_attr_val_rec.attr_value := p7_a10;
    ddp_enty_attr_val_rec.score := p7_a11;
    ddp_enty_attr_val_rec.enabled_flag := p7_a12;
    ddp_enty_attr_val_rec.entity_id := rosetta_g_miss_num_map(p7_a13);
    ddp_enty_attr_val_rec.version := rosetta_g_miss_num_map(p7_a14);
    ddp_enty_attr_val_rec.latest_flag := p7_a15;
    ddp_enty_attr_val_rec.attr_value_extn := p7_a16;
    ddp_enty_attr_val_rec.validation_id := rosetta_g_miss_num_map(p7_a17);


    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pvt.update_attr_value(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_val_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_attr_value(p_api_version_number  NUMBER
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
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_enty_attr_val_rec pv_enty_attr_value_pvt.enty_attr_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_enty_attr_val_rec.enty_attr_val_id := rosetta_g_miss_num_map(p4_a0);
    ddp_enty_attr_val_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_enty_attr_val_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_enty_attr_val_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_enty_attr_val_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_enty_attr_val_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_enty_attr_val_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_enty_attr_val_rec.entity := p4_a7;
    ddp_enty_attr_val_rec.attribute_id := rosetta_g_miss_num_map(p4_a8);
    ddp_enty_attr_val_rec.party_id := rosetta_g_miss_num_map(p4_a9);
    ddp_enty_attr_val_rec.attr_value := p4_a10;
    ddp_enty_attr_val_rec.score := p4_a11;
    ddp_enty_attr_val_rec.enabled_flag := p4_a12;
    ddp_enty_attr_val_rec.entity_id := rosetta_g_miss_num_map(p4_a13);
    ddp_enty_attr_val_rec.version := rosetta_g_miss_num_map(p4_a14);
    ddp_enty_attr_val_rec.latest_flag := p4_a15;
    ddp_enty_attr_val_rec.attr_value_extn := p4_a16;
    ddp_enty_attr_val_rec.validation_id := rosetta_g_miss_num_map(p4_a17);




    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pvt.validate_attr_value(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_enty_attr_val_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_attr_value_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_enty_attr_val_rec pv_enty_attr_value_pvt.enty_attr_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_enty_attr_val_rec.enty_attr_val_id := rosetta_g_miss_num_map(p0_a0);
    ddp_enty_attr_val_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_enty_attr_val_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_enty_attr_val_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_enty_attr_val_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_enty_attr_val_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_enty_attr_val_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_enty_attr_val_rec.entity := p0_a7;
    ddp_enty_attr_val_rec.attribute_id := rosetta_g_miss_num_map(p0_a8);
    ddp_enty_attr_val_rec.party_id := rosetta_g_miss_num_map(p0_a9);
    ddp_enty_attr_val_rec.attr_value := p0_a10;
    ddp_enty_attr_val_rec.score := p0_a11;
    ddp_enty_attr_val_rec.enabled_flag := p0_a12;
    ddp_enty_attr_val_rec.entity_id := rosetta_g_miss_num_map(p0_a13);
    ddp_enty_attr_val_rec.version := rosetta_g_miss_num_map(p0_a14);
    ddp_enty_attr_val_rec.latest_flag := p0_a15;
    ddp_enty_attr_val_rec.attr_value_extn := p0_a16;
    ddp_enty_attr_val_rec.validation_id := rosetta_g_miss_num_map(p0_a17);



    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pvt.check_attr_value_items(ddp_enty_attr_val_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_attr_val_rec(p_api_version_number  NUMBER
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
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_enty_attr_val_rec pv_enty_attr_value_pvt.enty_attr_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_enty_attr_val_rec.enty_attr_val_id := rosetta_g_miss_num_map(p5_a0);
    ddp_enty_attr_val_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_enty_attr_val_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_enty_attr_val_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_enty_attr_val_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_enty_attr_val_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_enty_attr_val_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_enty_attr_val_rec.entity := p5_a7;
    ddp_enty_attr_val_rec.attribute_id := rosetta_g_miss_num_map(p5_a8);
    ddp_enty_attr_val_rec.party_id := rosetta_g_miss_num_map(p5_a9);
    ddp_enty_attr_val_rec.attr_value := p5_a10;
    ddp_enty_attr_val_rec.score := p5_a11;
    ddp_enty_attr_val_rec.enabled_flag := p5_a12;
    ddp_enty_attr_val_rec.entity_id := rosetta_g_miss_num_map(p5_a13);
    ddp_enty_attr_val_rec.version := rosetta_g_miss_num_map(p5_a14);
    ddp_enty_attr_val_rec.latest_flag := p5_a15;
    ddp_enty_attr_val_rec.attr_value_extn := p5_a16;
    ddp_enty_attr_val_rec.validation_id := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pvt.validate_attr_val_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_val_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end pv_enty_attr_value_pvt_w;

/
