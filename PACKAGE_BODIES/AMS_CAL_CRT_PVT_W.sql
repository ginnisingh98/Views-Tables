--------------------------------------------------------
--  DDL for Package Body AMS_CAL_CRT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAL_CRT_PVT_W" as
  /* $Header: amswcctb.pls 115.2 2002/12/13 11:00:44 cgoyal noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := null;
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_cal_crt_pvt.cal_crt_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).criteria_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_type_code := a1(indx);
          t(ddindx).custom_setup_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).activity_type_code := a3(indx);
          t(ddindx).activity_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).status_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).priority_id := a6(indx);
          t(ddindx).object_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).criteria_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).criteria_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).criteria_deleted := a10(indx);
          t(ddindx).criteria_enabled := a11(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a17(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_cal_crt_pvt.cal_crt_rec_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_DATE_TABLE
    , a9 OUT NOCOPY JTF_DATE_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_DATE_TABLE
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_DATE_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).criteria_id);
          a1(indx) := t(ddindx).object_type_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).custom_setup_id);
          a3(indx) := t(ddindx).activity_type_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).activity_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).status_id);
          a6(indx) := t(ddindx).priority_id;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a8(indx) := t(ddindx).criteria_start_date;
          a9(indx) := t(ddindx).criteria_end_date;
          a10(indx) := t(ddindx).criteria_deleted;
          a11(indx) := t(ddindx).criteria_enabled;
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_cal_crt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_criteria_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_cal_crt_rec_rec ams_cal_crt_pvt.cal_crt_rec_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cal_crt_rec_rec.criteria_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cal_crt_rec_rec.object_type_code := p7_a1;
    ddp_cal_crt_rec_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cal_crt_rec_rec.activity_type_code := p7_a3;
    ddp_cal_crt_rec_rec.activity_id := rosetta_g_miss_num_map(p7_a4);
    ddp_cal_crt_rec_rec.status_id := rosetta_g_miss_num_map(p7_a5);
    ddp_cal_crt_rec_rec.priority_id := p7_a6;
    ddp_cal_crt_rec_rec.object_id := rosetta_g_miss_num_map(p7_a7);
    ddp_cal_crt_rec_rec.criteria_start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_cal_crt_rec_rec.criteria_end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_cal_crt_rec_rec.criteria_deleted := p7_a10;
    ddp_cal_crt_rec_rec.criteria_enabled := p7_a11;
    ddp_cal_crt_rec_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_cal_crt_rec_rec.last_updated_by := rosetta_g_miss_num_map(p7_a13);
    ddp_cal_crt_rec_rec.creation_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_cal_crt_rec_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_cal_crt_rec_rec.last_update_login := rosetta_g_miss_num_map(p7_a16);
    ddp_cal_crt_rec_rec.object_version_number := rosetta_g_miss_num_map(p7_a17);


    -- here's the delegated call to the old PL/SQL routine
    ams_cal_crt_pvt.create_cal_crt(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cal_crt_rec_rec,
      x_criteria_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_cal_crt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_cal_crt_rec_rec ams_cal_crt_pvt.cal_crt_rec_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cal_crt_rec_rec.criteria_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cal_crt_rec_rec.object_type_code := p7_a1;
    ddp_cal_crt_rec_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cal_crt_rec_rec.activity_type_code := p7_a3;
    ddp_cal_crt_rec_rec.activity_id := rosetta_g_miss_num_map(p7_a4);
    ddp_cal_crt_rec_rec.status_id := rosetta_g_miss_num_map(p7_a5);
    ddp_cal_crt_rec_rec.priority_id := p7_a6;
    ddp_cal_crt_rec_rec.object_id := rosetta_g_miss_num_map(p7_a7);
    ddp_cal_crt_rec_rec.criteria_start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_cal_crt_rec_rec.criteria_end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_cal_crt_rec_rec.criteria_deleted := p7_a10;
    ddp_cal_crt_rec_rec.criteria_enabled := p7_a11;
    ddp_cal_crt_rec_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_cal_crt_rec_rec.last_updated_by := rosetta_g_miss_num_map(p7_a13);
    ddp_cal_crt_rec_rec.creation_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_cal_crt_rec_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_cal_crt_rec_rec.last_update_login := rosetta_g_miss_num_map(p7_a16);
    ddp_cal_crt_rec_rec.object_version_number := rosetta_g_miss_num_map(p7_a17);

    -- here's the delegated call to the old PL/SQL routine
    ams_cal_crt_pvt.update_cal_crt(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cal_crt_rec_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_cal_crt(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  DATE
    , p3_a9  DATE
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  DATE
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
    , p3_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_cal_crt_rec_rec ams_cal_crt_pvt.cal_crt_rec_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_cal_crt_rec_rec.criteria_id := rosetta_g_miss_num_map(p3_a0);
    ddp_cal_crt_rec_rec.object_type_code := p3_a1;
    ddp_cal_crt_rec_rec.custom_setup_id := rosetta_g_miss_num_map(p3_a2);
    ddp_cal_crt_rec_rec.activity_type_code := p3_a3;
    ddp_cal_crt_rec_rec.activity_id := rosetta_g_miss_num_map(p3_a4);
    ddp_cal_crt_rec_rec.status_id := rosetta_g_miss_num_map(p3_a5);
    ddp_cal_crt_rec_rec.priority_id := p3_a6;
    ddp_cal_crt_rec_rec.object_id := rosetta_g_miss_num_map(p3_a7);
    ddp_cal_crt_rec_rec.criteria_start_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_cal_crt_rec_rec.criteria_end_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_cal_crt_rec_rec.criteria_deleted := p3_a10;
    ddp_cal_crt_rec_rec.criteria_enabled := p3_a11;
    ddp_cal_crt_rec_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a12);
    ddp_cal_crt_rec_rec.last_updated_by := rosetta_g_miss_num_map(p3_a13);
    ddp_cal_crt_rec_rec.creation_date := rosetta_g_miss_date_in_map(p3_a14);
    ddp_cal_crt_rec_rec.created_by := rosetta_g_miss_num_map(p3_a15);
    ddp_cal_crt_rec_rec.last_update_login := rosetta_g_miss_num_map(p3_a16);
    ddp_cal_crt_rec_rec.object_version_number := rosetta_g_miss_num_map(p3_a17);





    -- here's the delegated call to the old PL/SQL routine
    ams_cal_crt_pvt.validate_cal_crt(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_cal_crt_rec_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_cal_crt_rec_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE
    , p0_a9  DATE
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  DATE
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_cal_crt_rec_rec ams_cal_crt_pvt.cal_crt_rec_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cal_crt_rec_rec.criteria_id := rosetta_g_miss_num_map(p0_a0);
    ddp_cal_crt_rec_rec.object_type_code := p0_a1;
    ddp_cal_crt_rec_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a2);
    ddp_cal_crt_rec_rec.activity_type_code := p0_a3;
    ddp_cal_crt_rec_rec.activity_id := rosetta_g_miss_num_map(p0_a4);
    ddp_cal_crt_rec_rec.status_id := rosetta_g_miss_num_map(p0_a5);
    ddp_cal_crt_rec_rec.priority_id := p0_a6;
    ddp_cal_crt_rec_rec.object_id := rosetta_g_miss_num_map(p0_a7);
    ddp_cal_crt_rec_rec.criteria_start_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_cal_crt_rec_rec.criteria_end_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_cal_crt_rec_rec.criteria_deleted := p0_a10;
    ddp_cal_crt_rec_rec.criteria_enabled := p0_a11;
    ddp_cal_crt_rec_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_cal_crt_rec_rec.last_updated_by := rosetta_g_miss_num_map(p0_a13);
    ddp_cal_crt_rec_rec.creation_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_cal_crt_rec_rec.created_by := rosetta_g_miss_num_map(p0_a15);
    ddp_cal_crt_rec_rec.last_update_login := rosetta_g_miss_num_map(p0_a16);
    ddp_cal_crt_rec_rec.object_version_number := rosetta_g_miss_num_map(p0_a17);



    -- here's the delegated call to the old PL/SQL routine
    ams_cal_crt_pvt.check_cal_crt_rec_items(ddp_cal_crt_rec_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_cal_crt_rec_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  DATE
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_cal_crt_rec_rec ams_cal_crt_pvt.cal_crt_rec_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cal_crt_rec_rec.criteria_id := rosetta_g_miss_num_map(p5_a0);
    ddp_cal_crt_rec_rec.object_type_code := p5_a1;
    ddp_cal_crt_rec_rec.custom_setup_id := rosetta_g_miss_num_map(p5_a2);
    ddp_cal_crt_rec_rec.activity_type_code := p5_a3;
    ddp_cal_crt_rec_rec.activity_id := rosetta_g_miss_num_map(p5_a4);
    ddp_cal_crt_rec_rec.status_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cal_crt_rec_rec.priority_id := p5_a6;
    ddp_cal_crt_rec_rec.object_id := rosetta_g_miss_num_map(p5_a7);
    ddp_cal_crt_rec_rec.criteria_start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_cal_crt_rec_rec.criteria_end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_cal_crt_rec_rec.criteria_deleted := p5_a10;
    ddp_cal_crt_rec_rec.criteria_enabled := p5_a11;
    ddp_cal_crt_rec_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_cal_crt_rec_rec.last_updated_by := rosetta_g_miss_num_map(p5_a13);
    ddp_cal_crt_rec_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_cal_crt_rec_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_cal_crt_rec_rec.last_update_login := rosetta_g_miss_num_map(p5_a16);
    ddp_cal_crt_rec_rec.object_version_number := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    ams_cal_crt_pvt.validate_cal_crt_rec_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cal_crt_rec_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_cal_crt_pvt_w;

/
