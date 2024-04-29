--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PLCMNT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PLCMNT_PVT_W" as
  /* $Header: amswplcb.pls 115.5 2003/05/09 10:52:38 sikalyan ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_iba_plcmnt_pvt.iba_plcmnt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).placement_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).site_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).site_ref_code := a2(indx);
          t(ddindx).page_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).page_ref_code := a4(indx);
          t(ddindx).location_code := a5(indx);
          t(ddindx).param1 := a6(indx);
          t(ddindx).param2 := a7(indx);
          t(ddindx).param3 := a8(indx);
          t(ddindx).param4 := a9(indx);
          t(ddindx).param5 := a10(indx);
          t(ddindx).stylesheet_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).posting_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).status_code := a13(indx);
          t(ddindx).track_events_flag := a14(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).name := a21(indx);
          t(ddindx).description := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_iba_plcmnt_pvt.iba_plcmnt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
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
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_300();
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
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).placement_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).site_id);
          a2(indx) := t(ddindx).site_ref_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).page_id);
          a4(indx) := t(ddindx).page_ref_code;
          a5(indx) := t(ddindx).location_code;
          a6(indx) := t(ddindx).param1;
          a7(indx) := t(ddindx).param2;
          a8(indx) := t(ddindx).param3;
          a9(indx) := t(ddindx).param4;
          a10(indx) := t(ddindx).param5;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).stylesheet_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).posting_id);
          a13(indx) := t(ddindx).status_code;
          a14(indx) := t(ddindx).track_events_flag;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a21(indx) := t(ddindx).name;
          a22(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_iba_plcmnt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_placement_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_iba_plcmnt_rec ams_iba_plcmnt_pvt.iba_plcmnt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_iba_plcmnt_rec.placement_id := rosetta_g_miss_num_map(p7_a0);
    ddp_iba_plcmnt_rec.site_id := rosetta_g_miss_num_map(p7_a1);
    ddp_iba_plcmnt_rec.site_ref_code := p7_a2;
    ddp_iba_plcmnt_rec.page_id := rosetta_g_miss_num_map(p7_a3);
    ddp_iba_plcmnt_rec.page_ref_code := p7_a4;
    ddp_iba_plcmnt_rec.location_code := p7_a5;
    ddp_iba_plcmnt_rec.param1 := p7_a6;
    ddp_iba_plcmnt_rec.param2 := p7_a7;
    ddp_iba_plcmnt_rec.param3 := p7_a8;
    ddp_iba_plcmnt_rec.param4 := p7_a9;
    ddp_iba_plcmnt_rec.param5 := p7_a10;
    ddp_iba_plcmnt_rec.stylesheet_id := rosetta_g_miss_num_map(p7_a11);
    ddp_iba_plcmnt_rec.posting_id := rosetta_g_miss_num_map(p7_a12);
    ddp_iba_plcmnt_rec.status_code := p7_a13;
    ddp_iba_plcmnt_rec.track_events_flag := p7_a14;
    ddp_iba_plcmnt_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_iba_plcmnt_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_iba_plcmnt_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_iba_plcmnt_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_iba_plcmnt_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);
    ddp_iba_plcmnt_rec.object_version_number := rosetta_g_miss_num_map(p7_a20);
    ddp_iba_plcmnt_rec.name := p7_a21;
    ddp_iba_plcmnt_rec.description := p7_a22;


    -- here's the delegated call to the old PL/SQL routine
    ams_iba_plcmnt_pvt.create_iba_plcmnt(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iba_plcmnt_rec,
      x_placement_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_iba_plcmnt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_iba_plcmnt_rec ams_iba_plcmnt_pvt.iba_plcmnt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_iba_plcmnt_rec.placement_id := rosetta_g_miss_num_map(p7_a0);
    ddp_iba_plcmnt_rec.site_id := rosetta_g_miss_num_map(p7_a1);
    ddp_iba_plcmnt_rec.site_ref_code := p7_a2;
    ddp_iba_plcmnt_rec.page_id := rosetta_g_miss_num_map(p7_a3);
    ddp_iba_plcmnt_rec.page_ref_code := p7_a4;
    ddp_iba_plcmnt_rec.location_code := p7_a5;
    ddp_iba_plcmnt_rec.param1 := p7_a6;
    ddp_iba_plcmnt_rec.param2 := p7_a7;
    ddp_iba_plcmnt_rec.param3 := p7_a8;
    ddp_iba_plcmnt_rec.param4 := p7_a9;
    ddp_iba_plcmnt_rec.param5 := p7_a10;
    ddp_iba_plcmnt_rec.stylesheet_id := rosetta_g_miss_num_map(p7_a11);
    ddp_iba_plcmnt_rec.posting_id := rosetta_g_miss_num_map(p7_a12);
    ddp_iba_plcmnt_rec.status_code := p7_a13;
    ddp_iba_plcmnt_rec.track_events_flag := p7_a14;
    ddp_iba_plcmnt_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_iba_plcmnt_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_iba_plcmnt_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_iba_plcmnt_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_iba_plcmnt_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);
    ddp_iba_plcmnt_rec.object_version_number := rosetta_g_miss_num_map(p7_a20);
    ddp_iba_plcmnt_rec.name := p7_a21;
    ddp_iba_plcmnt_rec.description := p7_a22;


    -- here's the delegated call to the old PL/SQL routine
    ams_iba_plcmnt_pvt.update_iba_plcmnt(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iba_plcmnt_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_iba_plcmnt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_validation_mode  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  DATE := fnd_api.g_miss_date
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  DATE := fnd_api.g_miss_date
    , p3_a19  NUMBER := 0-1962.0724
    , p3_a20  NUMBER := 0-1962.0724
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_iba_plcmnt_rec ams_iba_plcmnt_pvt.iba_plcmnt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_iba_plcmnt_rec.placement_id := rosetta_g_miss_num_map(p3_a0);
    ddp_iba_plcmnt_rec.site_id := rosetta_g_miss_num_map(p3_a1);
    ddp_iba_plcmnt_rec.site_ref_code := p3_a2;
    ddp_iba_plcmnt_rec.page_id := rosetta_g_miss_num_map(p3_a3);
    ddp_iba_plcmnt_rec.page_ref_code := p3_a4;
    ddp_iba_plcmnt_rec.location_code := p3_a5;
    ddp_iba_plcmnt_rec.param1 := p3_a6;
    ddp_iba_plcmnt_rec.param2 := p3_a7;
    ddp_iba_plcmnt_rec.param3 := p3_a8;
    ddp_iba_plcmnt_rec.param4 := p3_a9;
    ddp_iba_plcmnt_rec.param5 := p3_a10;
    ddp_iba_plcmnt_rec.stylesheet_id := rosetta_g_miss_num_map(p3_a11);
    ddp_iba_plcmnt_rec.posting_id := rosetta_g_miss_num_map(p3_a12);
    ddp_iba_plcmnt_rec.status_code := p3_a13;
    ddp_iba_plcmnt_rec.track_events_flag := p3_a14;
    ddp_iba_plcmnt_rec.created_by := rosetta_g_miss_num_map(p3_a15);
    ddp_iba_plcmnt_rec.creation_date := rosetta_g_miss_date_in_map(p3_a16);
    ddp_iba_plcmnt_rec.last_updated_by := rosetta_g_miss_num_map(p3_a17);
    ddp_iba_plcmnt_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a18);
    ddp_iba_plcmnt_rec.last_update_login := rosetta_g_miss_num_map(p3_a19);
    ddp_iba_plcmnt_rec.object_version_number := rosetta_g_miss_num_map(p3_a20);
    ddp_iba_plcmnt_rec.name := p3_a21;
    ddp_iba_plcmnt_rec.description := p3_a22;





    -- here's the delegated call to the old PL/SQL routine
    ams_iba_plcmnt_pvt.validate_iba_plcmnt(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_iba_plcmnt_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_iba_plcmnt_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_iba_plcmnt_rec ams_iba_plcmnt_pvt.iba_plcmnt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_iba_plcmnt_rec.placement_id := rosetta_g_miss_num_map(p0_a0);
    ddp_iba_plcmnt_rec.site_id := rosetta_g_miss_num_map(p0_a1);
    ddp_iba_plcmnt_rec.site_ref_code := p0_a2;
    ddp_iba_plcmnt_rec.page_id := rosetta_g_miss_num_map(p0_a3);
    ddp_iba_plcmnt_rec.page_ref_code := p0_a4;
    ddp_iba_plcmnt_rec.location_code := p0_a5;
    ddp_iba_plcmnt_rec.param1 := p0_a6;
    ddp_iba_plcmnt_rec.param2 := p0_a7;
    ddp_iba_plcmnt_rec.param3 := p0_a8;
    ddp_iba_plcmnt_rec.param4 := p0_a9;
    ddp_iba_plcmnt_rec.param5 := p0_a10;
    ddp_iba_plcmnt_rec.stylesheet_id := rosetta_g_miss_num_map(p0_a11);
    ddp_iba_plcmnt_rec.posting_id := rosetta_g_miss_num_map(p0_a12);
    ddp_iba_plcmnt_rec.status_code := p0_a13;
    ddp_iba_plcmnt_rec.track_events_flag := p0_a14;
    ddp_iba_plcmnt_rec.created_by := rosetta_g_miss_num_map(p0_a15);
    ddp_iba_plcmnt_rec.creation_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_iba_plcmnt_rec.last_updated_by := rosetta_g_miss_num_map(p0_a17);
    ddp_iba_plcmnt_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a18);
    ddp_iba_plcmnt_rec.last_update_login := rosetta_g_miss_num_map(p0_a19);
    ddp_iba_plcmnt_rec.object_version_number := rosetta_g_miss_num_map(p0_a20);
    ddp_iba_plcmnt_rec.name := p0_a21;
    ddp_iba_plcmnt_rec.description := p0_a22;



    -- here's the delegated call to the old PL/SQL routine
    ams_iba_plcmnt_pvt.check_iba_plcmnt_items(ddp_iba_plcmnt_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_iba_plcmnt_rec(p_api_version_number  NUMBER
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
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_iba_plcmnt_rec ams_iba_plcmnt_pvt.iba_plcmnt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iba_plcmnt_rec.placement_id := rosetta_g_miss_num_map(p5_a0);
    ddp_iba_plcmnt_rec.site_id := rosetta_g_miss_num_map(p5_a1);
    ddp_iba_plcmnt_rec.site_ref_code := p5_a2;
    ddp_iba_plcmnt_rec.page_id := rosetta_g_miss_num_map(p5_a3);
    ddp_iba_plcmnt_rec.page_ref_code := p5_a4;
    ddp_iba_plcmnt_rec.location_code := p5_a5;
    ddp_iba_plcmnt_rec.param1 := p5_a6;
    ddp_iba_plcmnt_rec.param2 := p5_a7;
    ddp_iba_plcmnt_rec.param3 := p5_a8;
    ddp_iba_plcmnt_rec.param4 := p5_a9;
    ddp_iba_plcmnt_rec.param5 := p5_a10;
    ddp_iba_plcmnt_rec.stylesheet_id := rosetta_g_miss_num_map(p5_a11);
    ddp_iba_plcmnt_rec.posting_id := rosetta_g_miss_num_map(p5_a12);
    ddp_iba_plcmnt_rec.status_code := p5_a13;
    ddp_iba_plcmnt_rec.track_events_flag := p5_a14;
    ddp_iba_plcmnt_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_iba_plcmnt_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_iba_plcmnt_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_iba_plcmnt_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_iba_plcmnt_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);
    ddp_iba_plcmnt_rec.object_version_number := rosetta_g_miss_num_map(p5_a20);
    ddp_iba_plcmnt_rec.name := p5_a21;
    ddp_iba_plcmnt_rec.description := p5_a22;

    -- here's the delegated call to the old PL/SQL routine
    ams_iba_plcmnt_pvt.validate_iba_plcmnt_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iba_plcmnt_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_iba_plcmnt_pvt_w;

/
