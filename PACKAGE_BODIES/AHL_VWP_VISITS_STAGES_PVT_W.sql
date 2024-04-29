--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISITS_STAGES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISITS_STAGES_PVT_W" as
  /* $Header: AHLWSTGB.pls 120.0 2005/05/25 23:53:15 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_vwp_visits_stages_pvt.visit_stages_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).stage_id := a0(indx);
          t(ddindx).stage_num := a1(indx);
          t(ddindx).stage_name := a2(indx);
          t(ddindx).duration := a3(indx);
          t(ddindx).stage_planned_start_time := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).stage_planned_end_time := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).stage_actual_end_time := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).attribute_category := a8(indx);
          t(ddindx).attribute1 := a9(indx);
          t(ddindx).attribute2 := a10(indx);
          t(ddindx).attribute3 := a11(indx);
          t(ddindx).attribute4 := a12(indx);
          t(ddindx).attribute5 := a13(indx);
          t(ddindx).attribute6 := a14(indx);
          t(ddindx).attribute7 := a15(indx);
          t(ddindx).attribute8 := a16(indx);
          t(ddindx).attribute9 := a17(indx);
          t(ddindx).attribute10 := a18(indx);
          t(ddindx).attribute11 := a19(indx);
          t(ddindx).attribute12 := a20(indx);
          t(ddindx).attribute13 := a21(indx);
          t(ddindx).attribute14 := a22(indx);
          t(ddindx).attribute15 := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_vwp_visits_stages_pvt.visit_stages_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).stage_id;
          a1(indx) := t(ddindx).stage_num;
          a2(indx) := t(ddindx).stage_name;
          a3(indx) := t(ddindx).duration;
          a4(indx) := t(ddindx).stage_planned_start_time;
          a5(indx) := t(ddindx).stage_planned_end_time;
          a6(indx) := t(ddindx).stage_actual_end_time;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).attribute_category;
          a9(indx) := t(ddindx).attribute1;
          a10(indx) := t(ddindx).attribute2;
          a11(indx) := t(ddindx).attribute3;
          a12(indx) := t(ddindx).attribute4;
          a13(indx) := t(ddindx).attribute5;
          a14(indx) := t(ddindx).attribute6;
          a15(indx) := t(ddindx).attribute7;
          a16(indx) := t(ddindx).attribute8;
          a17(indx) := t(ddindx).attribute9;
          a18(indx) := t(ddindx).attribute10;
          a19(indx) := t(ddindx).attribute11;
          a20(indx) := t(ddindx).attribute12;
          a21(indx) := t(ddindx).attribute13;
          a22(indx) := t(ddindx).attribute14;
          a23(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_vwp_visits_stages_pvt.visit_stages_times_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).stage_id := a0(indx);
          t(ddindx).stage_num := a1(indx);
          t(ddindx).stage_name := a2(indx);
          t(ddindx).duration := a3(indx);
          t(ddindx).stage_start_hour := a4(indx);
          t(ddindx).stage_end_hour := a5(indx);
          t(ddindx).planned_start_time := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).planned_end_time := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).actual_end_time := rosetta_g_miss_date_in_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_vwp_visits_stages_pvt.visit_stages_times_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).stage_id;
          a1(indx) := t(ddindx).stage_num;
          a2(indx) := t(ddindx).stage_name;
          a3(indx) := t(ddindx).duration;
          a4(indx) := t(ddindx).stage_start_hour;
          a5(indx) := t(ddindx).stage_end_hour;
          a6(indx) := t(ddindx).planned_start_time;
          a7(indx) := t(ddindx).planned_end_time;
          a8(indx) := t(ddindx).actual_end_time;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure update_stages(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_DATE_TABLE
    , p6_a5 in out nocopy JTF_DATE_TABLE
    , p6_a6 in out nocopy JTF_DATE_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_stages_tbl ahl_vwp_visits_stages_pvt.visit_stages_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ahl_vwp_visits_stages_pvt_w.rosetta_table_copy_in_p2(ddp_x_stages_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visits_stages_pvt.update_stages(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddp_x_stages_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_vwp_visits_stages_pvt_w.rosetta_table_copy_out_p2(ddp_x_stages_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      );



  end;

  procedure get_stages_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p_start_row  NUMBER
    , p_rows_per_page  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_DATE_TABLE
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , x_row_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_stages_tbl ahl_vwp_visits_stages_pvt.visit_stages_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visits_stages_pvt.get_stages_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      p_start_row,
      p_rows_per_page,
      ddx_stages_tbl,
      x_row_count,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_vwp_visits_stages_pvt_w.rosetta_table_copy_out_p2(ddx_stages_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      );




  end;

end ahl_vwp_visits_stages_pvt_w;

/
