--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SPACE_ASSIGN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SPACE_ASSIGN_PUB_W" as
  /* $Header: AHLWSANB.pls 120.2 2006/05/04 07:49 anraj noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_ltp_space_assign_pub.space_assignment_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).space_assignment_id := a0(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := a2(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := a4(indx);
          t(ddindx).last_update_login := a5(indx);
          t(ddindx).visit_id := a6(indx);
          t(ddindx).visit_number := a7(indx);
          t(ddindx).space_name := a8(indx);
          t(ddindx).space_id := a9(indx);
          t(ddindx).object_version_number := a10(indx);
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).attribute1 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute3 := a14(indx);
          t(ddindx).attribute4 := a15(indx);
          t(ddindx).attribute5 := a16(indx);
          t(ddindx).attribute6 := a17(indx);
          t(ddindx).attribute7 := a18(indx);
          t(ddindx).attribute8 := a19(indx);
          t(ddindx).attribute9 := a20(indx);
          t(ddindx).attribute10 := a21(indx);
          t(ddindx).attribute11 := a22(indx);
          t(ddindx).attribute12 := a23(indx);
          t(ddindx).attribute13 := a24(indx);
          t(ddindx).attribute14 := a25(indx);
          t(ddindx).attribute15 := a26(indx);
          t(ddindx).operation_flag := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_ltp_space_assign_pub.space_assignment_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
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
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
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
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := t(ddindx).space_assignment_id;
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := t(ddindx).last_updated_by;
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := t(ddindx).created_by;
          a5(indx) := t(ddindx).last_update_login;
          a6(indx) := t(ddindx).visit_id;
          a7(indx) := t(ddindx).visit_number;
          a8(indx) := t(ddindx).space_name;
          a9(indx) := t(ddindx).space_id;
          a10(indx) := t(ddindx).object_version_number;
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).attribute1;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute3;
          a15(indx) := t(ddindx).attribute4;
          a16(indx) := t(ddindx).attribute5;
          a17(indx) := t(ddindx).attribute6;
          a18(indx) := t(ddindx).attribute7;
          a19(indx) := t(ddindx).attribute8;
          a20(indx) := t(ddindx).attribute9;
          a21(indx) := t(ddindx).attribute10;
          a22(indx) := t(ddindx).attribute11;
          a23(indx) := t(ddindx).attribute12;
          a24(indx) := t(ddindx).attribute13;
          a25(indx) := t(ddindx).attribute14;
          a26(indx) := t(ddindx).attribute15;
          a27(indx) := t(ddindx).operation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure assign_sch_visit_spaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_DATE_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_DATE_TABLE
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  DATE
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  DATE
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  NUMBER
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  NUMBER
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  DATE
    , p6_a12 in out nocopy  NUMBER
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  NUMBER
    , p6_a15 in out nocopy  VARCHAR2
    , p6_a16 in out nocopy  VARCHAR2
    , p6_a17 in out nocopy  VARCHAR2
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  VARCHAR2
    , p6_a20 in out nocopy  NUMBER
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
    , p6_a23 in out nocopy  VARCHAR2
    , p6_a24 in out nocopy  VARCHAR2
    , p6_a25 in out nocopy  VARCHAR2
    , p6_a26 in out nocopy  VARCHAR2
    , p6_a27 in out nocopy  VARCHAR2
    , p6_a28 in out nocopy  VARCHAR2
    , p6_a29 in out nocopy  VARCHAR2
    , p6_a30 in out nocopy  VARCHAR2
    , p6_a31 in out nocopy  VARCHAR2
    , p6_a32 in out nocopy  VARCHAR2
    , p6_a33 in out nocopy  VARCHAR2
    , p6_a34 in out nocopy  VARCHAR2
    , p6_a35 in out nocopy  VARCHAR2
    , p6_a36 in out nocopy  VARCHAR2
    , p6_a37 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_space_assignment_tbl ahl_ltp_space_assign_pub.space_assignment_tbl;
    ddp_x_schedule_visit_rec ahl_ltp_space_assign_pub.schedule_visit_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_ltp_space_assign_pub_w.rosetta_table_copy_in_p2(ddp_x_space_assignment_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      );

    ddp_x_schedule_visit_rec.visit_id := p6_a0;
    ddp_x_schedule_visit_rec.visit_number := p6_a1;
    ddp_x_schedule_visit_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_x_schedule_visit_rec.last_updated_by := p6_a3;
    ddp_x_schedule_visit_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_x_schedule_visit_rec.created_by := p6_a5;
    ddp_x_schedule_visit_rec.last_update_login := p6_a6;
    ddp_x_schedule_visit_rec.org_id := p6_a7;
    ddp_x_schedule_visit_rec.org_name := p6_a8;
    ddp_x_schedule_visit_rec.dept_id := p6_a9;
    ddp_x_schedule_visit_rec.dept_name := p6_a10;
    ddp_x_schedule_visit_rec.start_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_x_schedule_visit_rec.start_hour := p6_a12;
    ddp_x_schedule_visit_rec.planned_end_date := rosetta_g_miss_date_in_map(p6_a13);
    ddp_x_schedule_visit_rec.planned_end_hour := p6_a14;
    ddp_x_schedule_visit_rec.visit_type_code := p6_a15;
    ddp_x_schedule_visit_rec.visit_type_mean := p6_a16;
    ddp_x_schedule_visit_rec.space_category_code := p6_a17;
    ddp_x_schedule_visit_rec.space_category_mean := p6_a18;
    ddp_x_schedule_visit_rec.schedule_designator := p6_a19;
    ddp_x_schedule_visit_rec.object_version_number := p6_a20;
    ddp_x_schedule_visit_rec.attribute_category := p6_a21;
    ddp_x_schedule_visit_rec.attribute1 := p6_a22;
    ddp_x_schedule_visit_rec.attribute2 := p6_a23;
    ddp_x_schedule_visit_rec.attribute3 := p6_a24;
    ddp_x_schedule_visit_rec.attribute4 := p6_a25;
    ddp_x_schedule_visit_rec.attribute5 := p6_a26;
    ddp_x_schedule_visit_rec.attribute6 := p6_a27;
    ddp_x_schedule_visit_rec.attribute7 := p6_a28;
    ddp_x_schedule_visit_rec.attribute8 := p6_a29;
    ddp_x_schedule_visit_rec.attribute9 := p6_a30;
    ddp_x_schedule_visit_rec.attribute10 := p6_a31;
    ddp_x_schedule_visit_rec.attribute11 := p6_a32;
    ddp_x_schedule_visit_rec.attribute12 := p6_a33;
    ddp_x_schedule_visit_rec.attribute13 := p6_a34;
    ddp_x_schedule_visit_rec.attribute14 := p6_a35;
    ddp_x_schedule_visit_rec.attribute15 := p6_a36;
    ddp_x_schedule_visit_rec.schedule_flag := p6_a37;




    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_space_assign_pub.assign_sch_visit_spaces(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_space_assignment_tbl,
      ddp_x_schedule_visit_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_ltp_space_assign_pub_w.rosetta_table_copy_out_p2(ddp_x_space_assignment_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      );

    p6_a0 := ddp_x_schedule_visit_rec.visit_id;
    p6_a1 := ddp_x_schedule_visit_rec.visit_number;
    p6_a2 := ddp_x_schedule_visit_rec.last_update_date;
    p6_a3 := ddp_x_schedule_visit_rec.last_updated_by;
    p6_a4 := ddp_x_schedule_visit_rec.creation_date;
    p6_a5 := ddp_x_schedule_visit_rec.created_by;
    p6_a6 := ddp_x_schedule_visit_rec.last_update_login;
    p6_a7 := ddp_x_schedule_visit_rec.org_id;
    p6_a8 := ddp_x_schedule_visit_rec.org_name;
    p6_a9 := ddp_x_schedule_visit_rec.dept_id;
    p6_a10 := ddp_x_schedule_visit_rec.dept_name;
    p6_a11 := ddp_x_schedule_visit_rec.start_date;
    p6_a12 := ddp_x_schedule_visit_rec.start_hour;
    p6_a13 := ddp_x_schedule_visit_rec.planned_end_date;
    p6_a14 := ddp_x_schedule_visit_rec.planned_end_hour;
    p6_a15 := ddp_x_schedule_visit_rec.visit_type_code;
    p6_a16 := ddp_x_schedule_visit_rec.visit_type_mean;
    p6_a17 := ddp_x_schedule_visit_rec.space_category_code;
    p6_a18 := ddp_x_schedule_visit_rec.space_category_mean;
    p6_a19 := ddp_x_schedule_visit_rec.schedule_designator;
    p6_a20 := ddp_x_schedule_visit_rec.object_version_number;
    p6_a21 := ddp_x_schedule_visit_rec.attribute_category;
    p6_a22 := ddp_x_schedule_visit_rec.attribute1;
    p6_a23 := ddp_x_schedule_visit_rec.attribute2;
    p6_a24 := ddp_x_schedule_visit_rec.attribute3;
    p6_a25 := ddp_x_schedule_visit_rec.attribute4;
    p6_a26 := ddp_x_schedule_visit_rec.attribute5;
    p6_a27 := ddp_x_schedule_visit_rec.attribute6;
    p6_a28 := ddp_x_schedule_visit_rec.attribute7;
    p6_a29 := ddp_x_schedule_visit_rec.attribute8;
    p6_a30 := ddp_x_schedule_visit_rec.attribute9;
    p6_a31 := ddp_x_schedule_visit_rec.attribute10;
    p6_a32 := ddp_x_schedule_visit_rec.attribute11;
    p6_a33 := ddp_x_schedule_visit_rec.attribute12;
    p6_a34 := ddp_x_schedule_visit_rec.attribute13;
    p6_a35 := ddp_x_schedule_visit_rec.attribute14;
    p6_a36 := ddp_x_schedule_visit_rec.attribute15;
    p6_a37 := ddp_x_schedule_visit_rec.schedule_flag;



  end;

  procedure schedule_visit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  DATE
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  DATE
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  DATE
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_schedule_visit_rec ahl_ltp_space_assign_pub.schedule_visit_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_schedule_visit_rec.visit_id := p5_a0;
    ddp_x_schedule_visit_rec.visit_number := p5_a1;
    ddp_x_schedule_visit_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_x_schedule_visit_rec.last_updated_by := p5_a3;
    ddp_x_schedule_visit_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_x_schedule_visit_rec.created_by := p5_a5;
    ddp_x_schedule_visit_rec.last_update_login := p5_a6;
    ddp_x_schedule_visit_rec.org_id := p5_a7;
    ddp_x_schedule_visit_rec.org_name := p5_a8;
    ddp_x_schedule_visit_rec.dept_id := p5_a9;
    ddp_x_schedule_visit_rec.dept_name := p5_a10;
    ddp_x_schedule_visit_rec.start_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_x_schedule_visit_rec.start_hour := p5_a12;
    ddp_x_schedule_visit_rec.planned_end_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_x_schedule_visit_rec.planned_end_hour := p5_a14;
    ddp_x_schedule_visit_rec.visit_type_code := p5_a15;
    ddp_x_schedule_visit_rec.visit_type_mean := p5_a16;
    ddp_x_schedule_visit_rec.space_category_code := p5_a17;
    ddp_x_schedule_visit_rec.space_category_mean := p5_a18;
    ddp_x_schedule_visit_rec.schedule_designator := p5_a19;
    ddp_x_schedule_visit_rec.object_version_number := p5_a20;
    ddp_x_schedule_visit_rec.attribute_category := p5_a21;
    ddp_x_schedule_visit_rec.attribute1 := p5_a22;
    ddp_x_schedule_visit_rec.attribute2 := p5_a23;
    ddp_x_schedule_visit_rec.attribute3 := p5_a24;
    ddp_x_schedule_visit_rec.attribute4 := p5_a25;
    ddp_x_schedule_visit_rec.attribute5 := p5_a26;
    ddp_x_schedule_visit_rec.attribute6 := p5_a27;
    ddp_x_schedule_visit_rec.attribute7 := p5_a28;
    ddp_x_schedule_visit_rec.attribute8 := p5_a29;
    ddp_x_schedule_visit_rec.attribute9 := p5_a30;
    ddp_x_schedule_visit_rec.attribute10 := p5_a31;
    ddp_x_schedule_visit_rec.attribute11 := p5_a32;
    ddp_x_schedule_visit_rec.attribute12 := p5_a33;
    ddp_x_schedule_visit_rec.attribute13 := p5_a34;
    ddp_x_schedule_visit_rec.attribute14 := p5_a35;
    ddp_x_schedule_visit_rec.attribute15 := p5_a36;
    ddp_x_schedule_visit_rec.schedule_flag := p5_a37;




    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_space_assign_pub.schedule_visit(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_schedule_visit_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_schedule_visit_rec.visit_id;
    p5_a1 := ddp_x_schedule_visit_rec.visit_number;
    p5_a2 := ddp_x_schedule_visit_rec.last_update_date;
    p5_a3 := ddp_x_schedule_visit_rec.last_updated_by;
    p5_a4 := ddp_x_schedule_visit_rec.creation_date;
    p5_a5 := ddp_x_schedule_visit_rec.created_by;
    p5_a6 := ddp_x_schedule_visit_rec.last_update_login;
    p5_a7 := ddp_x_schedule_visit_rec.org_id;
    p5_a8 := ddp_x_schedule_visit_rec.org_name;
    p5_a9 := ddp_x_schedule_visit_rec.dept_id;
    p5_a10 := ddp_x_schedule_visit_rec.dept_name;
    p5_a11 := ddp_x_schedule_visit_rec.start_date;
    p5_a12 := ddp_x_schedule_visit_rec.start_hour;
    p5_a13 := ddp_x_schedule_visit_rec.planned_end_date;
    p5_a14 := ddp_x_schedule_visit_rec.planned_end_hour;
    p5_a15 := ddp_x_schedule_visit_rec.visit_type_code;
    p5_a16 := ddp_x_schedule_visit_rec.visit_type_mean;
    p5_a17 := ddp_x_schedule_visit_rec.space_category_code;
    p5_a18 := ddp_x_schedule_visit_rec.space_category_mean;
    p5_a19 := ddp_x_schedule_visit_rec.schedule_designator;
    p5_a20 := ddp_x_schedule_visit_rec.object_version_number;
    p5_a21 := ddp_x_schedule_visit_rec.attribute_category;
    p5_a22 := ddp_x_schedule_visit_rec.attribute1;
    p5_a23 := ddp_x_schedule_visit_rec.attribute2;
    p5_a24 := ddp_x_schedule_visit_rec.attribute3;
    p5_a25 := ddp_x_schedule_visit_rec.attribute4;
    p5_a26 := ddp_x_schedule_visit_rec.attribute5;
    p5_a27 := ddp_x_schedule_visit_rec.attribute6;
    p5_a28 := ddp_x_schedule_visit_rec.attribute7;
    p5_a29 := ddp_x_schedule_visit_rec.attribute8;
    p5_a30 := ddp_x_schedule_visit_rec.attribute9;
    p5_a31 := ddp_x_schedule_visit_rec.attribute10;
    p5_a32 := ddp_x_schedule_visit_rec.attribute11;
    p5_a33 := ddp_x_schedule_visit_rec.attribute12;
    p5_a34 := ddp_x_schedule_visit_rec.attribute13;
    p5_a35 := ddp_x_schedule_visit_rec.attribute14;
    p5_a36 := ddp_x_schedule_visit_rec.attribute15;
    p5_a37 := ddp_x_schedule_visit_rec.schedule_flag;



  end;

  procedure unschedule_visit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  DATE
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  DATE
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  DATE
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_schedule_visit_rec ahl_ltp_space_assign_pub.schedule_visit_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_schedule_visit_rec.visit_id := p5_a0;
    ddp_x_schedule_visit_rec.visit_number := p5_a1;
    ddp_x_schedule_visit_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_x_schedule_visit_rec.last_updated_by := p5_a3;
    ddp_x_schedule_visit_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_x_schedule_visit_rec.created_by := p5_a5;
    ddp_x_schedule_visit_rec.last_update_login := p5_a6;
    ddp_x_schedule_visit_rec.org_id := p5_a7;
    ddp_x_schedule_visit_rec.org_name := p5_a8;
    ddp_x_schedule_visit_rec.dept_id := p5_a9;
    ddp_x_schedule_visit_rec.dept_name := p5_a10;
    ddp_x_schedule_visit_rec.start_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_x_schedule_visit_rec.start_hour := p5_a12;
    ddp_x_schedule_visit_rec.planned_end_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_x_schedule_visit_rec.planned_end_hour := p5_a14;
    ddp_x_schedule_visit_rec.visit_type_code := p5_a15;
    ddp_x_schedule_visit_rec.visit_type_mean := p5_a16;
    ddp_x_schedule_visit_rec.space_category_code := p5_a17;
    ddp_x_schedule_visit_rec.space_category_mean := p5_a18;
    ddp_x_schedule_visit_rec.schedule_designator := p5_a19;
    ddp_x_schedule_visit_rec.object_version_number := p5_a20;
    ddp_x_schedule_visit_rec.attribute_category := p5_a21;
    ddp_x_schedule_visit_rec.attribute1 := p5_a22;
    ddp_x_schedule_visit_rec.attribute2 := p5_a23;
    ddp_x_schedule_visit_rec.attribute3 := p5_a24;
    ddp_x_schedule_visit_rec.attribute4 := p5_a25;
    ddp_x_schedule_visit_rec.attribute5 := p5_a26;
    ddp_x_schedule_visit_rec.attribute6 := p5_a27;
    ddp_x_schedule_visit_rec.attribute7 := p5_a28;
    ddp_x_schedule_visit_rec.attribute8 := p5_a29;
    ddp_x_schedule_visit_rec.attribute9 := p5_a30;
    ddp_x_schedule_visit_rec.attribute10 := p5_a31;
    ddp_x_schedule_visit_rec.attribute11 := p5_a32;
    ddp_x_schedule_visit_rec.attribute12 := p5_a33;
    ddp_x_schedule_visit_rec.attribute13 := p5_a34;
    ddp_x_schedule_visit_rec.attribute14 := p5_a35;
    ddp_x_schedule_visit_rec.attribute15 := p5_a36;
    ddp_x_schedule_visit_rec.schedule_flag := p5_a37;




    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_space_assign_pub.unschedule_visit(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_schedule_visit_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_schedule_visit_rec.visit_id;
    p5_a1 := ddp_x_schedule_visit_rec.visit_number;
    p5_a2 := ddp_x_schedule_visit_rec.last_update_date;
    p5_a3 := ddp_x_schedule_visit_rec.last_updated_by;
    p5_a4 := ddp_x_schedule_visit_rec.creation_date;
    p5_a5 := ddp_x_schedule_visit_rec.created_by;
    p5_a6 := ddp_x_schedule_visit_rec.last_update_login;
    p5_a7 := ddp_x_schedule_visit_rec.org_id;
    p5_a8 := ddp_x_schedule_visit_rec.org_name;
    p5_a9 := ddp_x_schedule_visit_rec.dept_id;
    p5_a10 := ddp_x_schedule_visit_rec.dept_name;
    p5_a11 := ddp_x_schedule_visit_rec.start_date;
    p5_a12 := ddp_x_schedule_visit_rec.start_hour;
    p5_a13 := ddp_x_schedule_visit_rec.planned_end_date;
    p5_a14 := ddp_x_schedule_visit_rec.planned_end_hour;
    p5_a15 := ddp_x_schedule_visit_rec.visit_type_code;
    p5_a16 := ddp_x_schedule_visit_rec.visit_type_mean;
    p5_a17 := ddp_x_schedule_visit_rec.space_category_code;
    p5_a18 := ddp_x_schedule_visit_rec.space_category_mean;
    p5_a19 := ddp_x_schedule_visit_rec.schedule_designator;
    p5_a20 := ddp_x_schedule_visit_rec.object_version_number;
    p5_a21 := ddp_x_schedule_visit_rec.attribute_category;
    p5_a22 := ddp_x_schedule_visit_rec.attribute1;
    p5_a23 := ddp_x_schedule_visit_rec.attribute2;
    p5_a24 := ddp_x_schedule_visit_rec.attribute3;
    p5_a25 := ddp_x_schedule_visit_rec.attribute4;
    p5_a26 := ddp_x_schedule_visit_rec.attribute5;
    p5_a27 := ddp_x_schedule_visit_rec.attribute6;
    p5_a28 := ddp_x_schedule_visit_rec.attribute7;
    p5_a29 := ddp_x_schedule_visit_rec.attribute8;
    p5_a30 := ddp_x_schedule_visit_rec.attribute9;
    p5_a31 := ddp_x_schedule_visit_rec.attribute10;
    p5_a32 := ddp_x_schedule_visit_rec.attribute11;
    p5_a33 := ddp_x_schedule_visit_rec.attribute12;
    p5_a34 := ddp_x_schedule_visit_rec.attribute13;
    p5_a35 := ddp_x_schedule_visit_rec.attribute14;
    p5_a36 := ddp_x_schedule_visit_rec.attribute15;
    p5_a37 := ddp_x_schedule_visit_rec.schedule_flag;



  end;

end ahl_ltp_space_assign_pub_w;

/
