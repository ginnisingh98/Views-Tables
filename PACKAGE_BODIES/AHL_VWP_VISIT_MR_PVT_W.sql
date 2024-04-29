--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISIT_MR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISIT_MR_PVT_W" as
  /* $Header: AHLWVMRB.pls 120.0 2005/05/26 00:13:24 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_vwp_visit_mr_pvt.visit_mr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_task_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).attribute_category := a2(indx);
          t(ddindx).attribute1 := a3(indx);
          t(ddindx).attribute2 := a4(indx);
          t(ddindx).attribute3 := a5(indx);
          t(ddindx).attribute4 := a6(indx);
          t(ddindx).attribute5 := a7(indx);
          t(ddindx).attribute6 := a8(indx);
          t(ddindx).attribute7 := a9(indx);
          t(ddindx).attribute8 := a10(indx);
          t(ddindx).attribute9 := a11(indx);
          t(ddindx).attribute10 := a12(indx);
          t(ddindx).attribute11 := a13(indx);
          t(ddindx).attribute12 := a14(indx);
          t(ddindx).attribute13 := a15(indx);
          t(ddindx).attribute14 := a16(indx);
          t(ddindx).attribute15 := a17(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).created_by := a19(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_updated_by := a21(indx);
          t(ddindx).last_update_login := a22(indx);
          t(ddindx).operation_flag := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_vwp_visit_mr_pvt.visit_mr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).visit_task_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).attribute_category;
          a3(indx) := t(ddindx).attribute1;
          a4(indx) := t(ddindx).attribute2;
          a5(indx) := t(ddindx).attribute3;
          a6(indx) := t(ddindx).attribute4;
          a7(indx) := t(ddindx).attribute5;
          a8(indx) := t(ddindx).attribute6;
          a9(indx) := t(ddindx).attribute7;
          a10(indx) := t(ddindx).attribute8;
          a11(indx) := t(ddindx).attribute9;
          a12(indx) := t(ddindx).attribute10;
          a13(indx) := t(ddindx).attribute11;
          a14(indx) := t(ddindx).attribute12;
          a15(indx) := t(ddindx).attribute13;
          a16(indx) := t(ddindx).attribute14;
          a17(indx) := t(ddindx).attribute15;
          a18(indx) := t(ddindx).creation_date;
          a19(indx) := t(ddindx).created_by;
          a20(indx) := t(ddindx).last_update_date;
          a21(indx) := t(ddindx).last_updated_by;
          a22(indx) := t(ddindx).last_update_login;
          a23(indx) := t(ddindx).operation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_visit_mrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_200
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_visit_mr_tbl ahl_vwp_visit_mr_pvt.visit_mr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_vwp_visit_mr_pvt_w.rosetta_table_copy_in_p1(ddp_visit_mr_tbl, p5_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_mr_pvt.process_visit_mrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_visit_mr_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ahl_vwp_visit_mr_pvt_w;

/
