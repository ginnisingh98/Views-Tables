--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SPACE_SCHEDULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SPACE_SCHEDULE_PVT_W" as
  /* $Header: AHLWSPSB.pls 120.1 2006/05/04 07:59 anraj noship $ */
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

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_ltp_space_schedule_pvt.search_visits_tbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).org_name := a0(indx);
          t(ddindx).org_id := a1(indx);
          t(ddindx).department_name := a2(indx);
          t(ddindx).department_id := a3(indx);
          t(ddindx).department_code := a4(indx);
          t(ddindx).space_name := a5(indx);
          t(ddindx).space_id := a6(indx);
          t(ddindx).space_category := a7(indx);
          t(ddindx).space_category_mean := a8(indx);
          t(ddindx).visit_type_code := a9(indx);
          t(ddindx).visit_type_mean := a10(indx);
          t(ddindx).item_id := a11(indx);
          t(ddindx).item_description := a12(indx);
          t(ddindx).plan_id := a13(indx);
          t(ddindx).plan_name := a14(indx);
          t(ddindx).display_period_code := a15(indx);
          t(ddindx).display_period_mean := a16(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).start_period := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).end_period := rosetta_g_miss_date_in_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_ltp_space_schedule_pvt.search_visits_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).org_name;
          a1(indx) := t(ddindx).org_id;
          a2(indx) := t(ddindx).department_name;
          a3(indx) := t(ddindx).department_id;
          a4(indx) := t(ddindx).department_code;
          a5(indx) := t(ddindx).space_name;
          a6(indx) := t(ddindx).space_id;
          a7(indx) := t(ddindx).space_category;
          a8(indx) := t(ddindx).space_category_mean;
          a9(indx) := t(ddindx).visit_type_code;
          a10(indx) := t(ddindx).visit_type_mean;
          a11(indx) := t(ddindx).item_id;
          a12(indx) := t(ddindx).item_description;
          a13(indx) := t(ddindx).plan_id;
          a14(indx) := t(ddindx).plan_name;
          a15(indx) := t(ddindx).display_period_code;
          a16(indx) := t(ddindx).display_period_mean;
          a17(indx) := t(ddindx).start_date;
          a18(indx) := t(ddindx).start_period;
          a19(indx) := t(ddindx).end_period;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_ltp_space_schedule_pvt.scheduled_visits_tbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).org_name := a0(indx);
          t(ddindx).department_name := a1(indx);
          t(ddindx).department_id := a2(indx);
          t(ddindx).department_code := a3(indx);
          t(ddindx).space_name := a4(indx);
          t(ddindx).space_id := a5(indx);
          t(ddindx).space_category := a6(indx);
          t(ddindx).space_category_mean := a7(indx);
          t(ddindx).value_1 := a8(indx);
          t(ddindx).value_2 := a9(indx);
          t(ddindx).value_3 := a10(indx);
          t(ddindx).value_4 := a11(indx);
          t(ddindx).value_5 := a12(indx);
          t(ddindx).value_6 := a13(indx);
          t(ddindx).value_7 := a14(indx);
          t(ddindx).value_8 := a15(indx);
          t(ddindx).value_9 := a16(indx);
          t(ddindx).value_10 := a17(indx);
          t(ddindx).value_11 := a18(indx);
          t(ddindx).value_12 := a19(indx);
          t(ddindx).value_13 := a20(indx);
          t(ddindx).value_14 := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_ltp_space_schedule_pvt.scheduled_visits_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).org_name;
          a1(indx) := t(ddindx).department_name;
          a2(indx) := t(ddindx).department_id;
          a3(indx) := t(ddindx).department_code;
          a4(indx) := t(ddindx).space_name;
          a5(indx) := t(ddindx).space_id;
          a6(indx) := t(ddindx).space_category;
          a7(indx) := t(ddindx).space_category_mean;
          a8(indx) := t(ddindx).value_1;
          a9(indx) := t(ddindx).value_2;
          a10(indx) := t(ddindx).value_3;
          a11(indx) := t(ddindx).value_4;
          a12(indx) := t(ddindx).value_5;
          a13(indx) := t(ddindx).value_6;
          a14(indx) := t(ddindx).value_7;
          a15(indx) := t(ddindx).value_8;
          a16(indx) := t(ddindx).value_9;
          a17(indx) := t(ddindx).value_10;
          a18(indx) := t(ddindx).value_11;
          a19(indx) := t(ddindx).value_12;
          a20(indx) := t(ddindx).value_13;
          a21(indx) := t(ddindx).value_14;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_ltp_space_schedule_pvt.visits_end_date_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_id := a0(indx);
          t(ddindx).visit_end_date := rosetta_g_miss_date_in_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ahl_ltp_space_schedule_pvt.visits_end_date_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).visit_id;
          a1(indx) := t(ddindx).visit_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy ahl_ltp_space_schedule_pvt.visit_details_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_number := a0(indx);
          t(ddindx).visit_type := a1(indx);
          t(ddindx).visit_name := a2(indx);
          t(ddindx).visit_id := a3(indx);
          t(ddindx).visit_status := a4(indx);
          t(ddindx).item_description := a5(indx);
          t(ddindx).serial_number := a6(indx);
          t(ddindx).unit_name := a7(indx);
          t(ddindx).yes_no_type := a8(indx);
          t(ddindx).plan_flag := a9(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).due_by := rosetta_g_miss_date_in_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ahl_ltp_space_schedule_pvt.visit_details_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).visit_number;
          a1(indx) := t(ddindx).visit_type;
          a2(indx) := t(ddindx).visit_name;
          a3(indx) := t(ddindx).visit_id;
          a4(indx) := t(ddindx).visit_status;
          a5(indx) := t(ddindx).item_description;
          a6(indx) := t(ddindx).serial_number;
          a7(indx) := t(ddindx).unit_name;
          a8(indx) := t(ddindx).yes_no_type;
          a9(indx) := t(ddindx).plan_flag;
          a10(indx) := t(ddindx).start_date;
          a11(indx) := t(ddindx).end_date;
          a12(indx) := t(ddindx).due_by;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure derive_visit_end_date(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_visits_end_date_tbl ahl_ltp_space_schedule_pvt.visits_end_date_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ahl_ltp_space_schedule_pvt_w.rosetta_table_copy_in_p7(ddp_visits_end_date_tbl, p0_a0
      , p0_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_space_schedule_pvt.derive_visit_end_date(ddp_visits_end_date_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    ahl_ltp_space_schedule_pvt_w.rosetta_table_copy_out_p7(ddp_visits_end_date_tbl, p0_a0
      , p0_a1
      );



  end;

  procedure search_scheduled_visits(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  DATE
    , p5_a18  DATE
    , p5_a19  DATE
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  DATE
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  DATE
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  DATE
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  DATE
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  DATE
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  DATE
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  DATE
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  DATE
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  DATE
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  DATE
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  DATE
    , p7_a38 out nocopy  DATE
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  DATE
    , p7_a41 out nocopy  DATE
    , p7_a42 out nocopy  DATE
    , p7_a43 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_search_visits_rec ahl_ltp_space_schedule_pvt.search_visits_rec_type;
    ddx_scheduled_visit_tbl ahl_ltp_space_schedule_pvt.scheduled_visits_tbl;
    ddx_display_rec ahl_ltp_space_schedule_pvt.display_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_search_visits_rec.org_name := p5_a0;
    ddp_search_visits_rec.org_id := p5_a1;
    ddp_search_visits_rec.department_name := p5_a2;
    ddp_search_visits_rec.department_id := p5_a3;
    ddp_search_visits_rec.department_code := p5_a4;
    ddp_search_visits_rec.space_name := p5_a5;
    ddp_search_visits_rec.space_id := p5_a6;
    ddp_search_visits_rec.space_category := p5_a7;
    ddp_search_visits_rec.space_category_mean := p5_a8;
    ddp_search_visits_rec.visit_type_code := p5_a9;
    ddp_search_visits_rec.visit_type_mean := p5_a10;
    ddp_search_visits_rec.item_id := p5_a11;
    ddp_search_visits_rec.item_description := p5_a12;
    ddp_search_visits_rec.plan_id := p5_a13;
    ddp_search_visits_rec.plan_name := p5_a14;
    ddp_search_visits_rec.display_period_code := p5_a15;
    ddp_search_visits_rec.display_period_mean := p5_a16;
    ddp_search_visits_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_search_visits_rec.start_period := rosetta_g_miss_date_in_map(p5_a18);
    ddp_search_visits_rec.end_period := rosetta_g_miss_date_in_map(p5_a19);






    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_space_schedule_pvt.search_scheduled_visits(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_search_visits_rec,
      ddx_scheduled_visit_tbl,
      ddx_display_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_space_schedule_pvt_w.rosetta_table_copy_out_p6(ddx_scheduled_visit_tbl, p6_a0
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
      );

    p7_a0 := ddx_display_rec.field_1;
    p7_a1 := ddx_display_rec.start_period_1;
    p7_a2 := ddx_display_rec.end_period_1;
    p7_a3 := ddx_display_rec.field_2;
    p7_a4 := ddx_display_rec.start_period_2;
    p7_a5 := ddx_display_rec.end_period_2;
    p7_a6 := ddx_display_rec.field_3;
    p7_a7 := ddx_display_rec.start_period_3;
    p7_a8 := ddx_display_rec.end_period_3;
    p7_a9 := ddx_display_rec.field_4;
    p7_a10 := ddx_display_rec.start_period_4;
    p7_a11 := ddx_display_rec.end_period_4;
    p7_a12 := ddx_display_rec.field_5;
    p7_a13 := ddx_display_rec.start_period_5;
    p7_a14 := ddx_display_rec.end_period_5;
    p7_a15 := ddx_display_rec.field_6;
    p7_a16 := ddx_display_rec.start_period_6;
    p7_a17 := ddx_display_rec.end_period_6;
    p7_a18 := ddx_display_rec.field_7;
    p7_a19 := ddx_display_rec.start_period_7;
    p7_a20 := ddx_display_rec.end_period_7;
    p7_a21 := ddx_display_rec.field_8;
    p7_a22 := ddx_display_rec.start_period_8;
    p7_a23 := ddx_display_rec.end_period_8;
    p7_a24 := ddx_display_rec.field_9;
    p7_a25 := ddx_display_rec.start_period_9;
    p7_a26 := ddx_display_rec.end_period_9;
    p7_a27 := ddx_display_rec.field_10;
    p7_a28 := ddx_display_rec.start_period_10;
    p7_a29 := ddx_display_rec.end_period_10;
    p7_a30 := ddx_display_rec.field_11;
    p7_a31 := ddx_display_rec.start_period_11;
    p7_a32 := ddx_display_rec.end_period_11;
    p7_a33 := ddx_display_rec.field_12;
    p7_a34 := ddx_display_rec.start_period_12;
    p7_a35 := ddx_display_rec.end_period_12;
    p7_a36 := ddx_display_rec.field_13;
    p7_a37 := ddx_display_rec.start_period_13;
    p7_a38 := ddx_display_rec.end_period_13;
    p7_a39 := ddx_display_rec.field_14;
    p7_a40 := ddx_display_rec.start_period_14;
    p7_a41 := ddx_display_rec.end_period_14;
    p7_a42 := ddx_display_rec.start_period;
    p7_a43 := ddx_display_rec.end_period;



  end;

  procedure get_visit_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  DATE
    , p5_a18  DATE
    , p5_a19  DATE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_search_visits_rec ahl_ltp_space_schedule_pvt.search_visits_rec_type;
    ddx_visit_details_tbl ahl_ltp_space_schedule_pvt.visit_details_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_search_visits_rec.org_name := p5_a0;
    ddp_search_visits_rec.org_id := p5_a1;
    ddp_search_visits_rec.department_name := p5_a2;
    ddp_search_visits_rec.department_id := p5_a3;
    ddp_search_visits_rec.department_code := p5_a4;
    ddp_search_visits_rec.space_name := p5_a5;
    ddp_search_visits_rec.space_id := p5_a6;
    ddp_search_visits_rec.space_category := p5_a7;
    ddp_search_visits_rec.space_category_mean := p5_a8;
    ddp_search_visits_rec.visit_type_code := p5_a9;
    ddp_search_visits_rec.visit_type_mean := p5_a10;
    ddp_search_visits_rec.item_id := p5_a11;
    ddp_search_visits_rec.item_description := p5_a12;
    ddp_search_visits_rec.plan_id := p5_a13;
    ddp_search_visits_rec.plan_name := p5_a14;
    ddp_search_visits_rec.display_period_code := p5_a15;
    ddp_search_visits_rec.display_period_mean := p5_a16;
    ddp_search_visits_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_search_visits_rec.start_period := rosetta_g_miss_date_in_map(p5_a18);
    ddp_search_visits_rec.end_period := rosetta_g_miss_date_in_map(p5_a19);





    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_space_schedule_pvt.get_visit_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_search_visits_rec,
      ddx_visit_details_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_space_schedule_pvt_w.rosetta_table_copy_out_p8(ddx_visit_details_tbl, p6_a0
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
      );



  end;

end ahl_ltp_space_schedule_pvt_w;

/
