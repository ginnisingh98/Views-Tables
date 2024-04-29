--------------------------------------------------------
--  DDL for Package Body JTF_TASKS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASKS_PUB_W" as
  /* $Header: jtfbtktb.pls 120.7 2006/04/26 04:26 knayyar ship $ */
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

  procedure rosetta_table_copy_in_p6(t out nocopy jtf_tasks_pub.task_assign_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_type_code := a0(indx);
          t(ddindx).resource_id := a1(indx);
          t(ddindx).actual_start_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).actual_end_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).actual_effort := a4(indx);
          t(ddindx).actual_effort_uom := a5(indx);
          t(ddindx).sched_travel_distance := a6(indx);
          t(ddindx).sched_travel_duration := a7(indx);
          t(ddindx).sched_travel_duration_uom := a8(indx);
          t(ddindx).actual_travel_distance := a9(indx);
          t(ddindx).actual_travel_duration := a10(indx);
          t(ddindx).actual_travel_duration_uom := a11(indx);
          t(ddindx).schedule_flag := a12(indx);
          t(ddindx).alarm_type_code := a13(indx);
          t(ddindx).alarm_contact := a14(indx);
          t(ddindx).palm_flag := a15(indx);
          t(ddindx).wince_flag := a16(indx);
          t(ddindx).laptop_flag := a17(indx);
          t(ddindx).device1_flag := a18(indx);
          t(ddindx).device2_flag := a19(indx);
          t(ddindx).device3_flag := a20(indx);
          t(ddindx).resource_territory_id := a21(indx);
          t(ddindx).assignment_status_id := a22(indx);
          t(ddindx).shift_construct_id := a23(indx);
          t(ddindx).show_on_calendar := a24(indx);
          t(ddindx).category_id := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t jtf_tasks_pub.task_assign_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_type_code;
          a1(indx) := t(ddindx).resource_id;
          a2(indx) := t(ddindx).actual_start_date;
          a3(indx) := t(ddindx).actual_end_date;
          a4(indx) := t(ddindx).actual_effort;
          a5(indx) := t(ddindx).actual_effort_uom;
          a6(indx) := t(ddindx).sched_travel_distance;
          a7(indx) := t(ddindx).sched_travel_duration;
          a8(indx) := t(ddindx).sched_travel_duration_uom;
          a9(indx) := t(ddindx).actual_travel_distance;
          a10(indx) := t(ddindx).actual_travel_duration;
          a11(indx) := t(ddindx).actual_travel_duration_uom;
          a12(indx) := t(ddindx).schedule_flag;
          a13(indx) := t(ddindx).alarm_type_code;
          a14(indx) := t(ddindx).alarm_contact;
          a15(indx) := t(ddindx).palm_flag;
          a16(indx) := t(ddindx).wince_flag;
          a17(indx) := t(ddindx).laptop_flag;
          a18(indx) := t(ddindx).device1_flag;
          a19(indx) := t(ddindx).device2_flag;
          a20(indx) := t(ddindx).device3_flag;
          a21(indx) := t(ddindx).resource_territory_id;
          a22(indx) := t(ddindx).assignment_status_id;
          a23(indx) := t(ddindx).shift_construct_id;
          a24(indx) := t(ddindx).show_on_calendar;
          a25(indx) := t(ddindx).category_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p9(t out nocopy jtf_tasks_pub.task_depends_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).dependent_on_task_id := a0(indx);
          t(ddindx).dependent_on_task_number := a1(indx);
          t(ddindx).dependency_type_code := a2(indx);
          t(ddindx).adjustment_time := a3(indx);
          t(ddindx).adjustment_time_uom := a4(indx);
          t(ddindx).validated_flag := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t jtf_tasks_pub.task_depends_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).dependent_on_task_id;
          a1(indx) := t(ddindx).dependent_on_task_number;
          a2(indx) := t(ddindx).dependency_type_code;
          a3(indx) := t(ddindx).adjustment_time;
          a4(indx) := t(ddindx).adjustment_time_uom;
          a5(indx) := t(ddindx).validated_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p12(t out nocopy jtf_tasks_pub.task_rsrc_req_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_type_code := a0(indx);
          t(ddindx).required_units := a1(indx);
          t(ddindx).enabled_flag := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t jtf_tasks_pub.task_rsrc_req_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_type_code;
          a1(indx) := t(ddindx).required_units;
          a2(indx) := t(ddindx).enabled_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p15(t out nocopy jtf_tasks_pub.task_refer_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).object_type_code := a0(indx);
          t(ddindx).object_type_name := a1(indx);
          t(ddindx).object_name := a2(indx);
          t(ddindx).object_id := a3(indx);
          t(ddindx).object_details := a4(indx);
          t(ddindx).reference_code := a5(indx);
          t(ddindx).usage := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t jtf_tasks_pub.task_refer_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).object_type_code;
          a1(indx) := t(ddindx).object_type_name;
          a2(indx) := t(ddindx).object_name;
          a3(indx) := t(ddindx).object_id;
          a4(indx) := t(ddindx).object_details;
          a5(indx) := t(ddindx).reference_code;
          a6(indx) := t(ddindx).usage;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p20(t out nocopy jtf_tasks_pub.task_dates_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).date_type_id := a0(indx);
          t(ddindx).date_type_name := a1(indx);
          t(ddindx).date_type := a2(indx);
          t(ddindx).date_value := rosetta_g_miss_date_in_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t jtf_tasks_pub.task_dates_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).date_type_id;
          a1(indx) := t(ddindx).date_type_name;
          a2(indx) := t(ddindx).date_type;
          a3(indx) := t(ddindx).date_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p23(t out nocopy jtf_tasks_pub.task_notes_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_32767
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
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
    , a24 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parent_note_id := a0(indx);
          t(ddindx).org_id := a1(indx);
          t(ddindx).notes := a2(indx);
          t(ddindx).notes_detail := a3(indx);
          t(ddindx).note_status := a4(indx);
          t(ddindx).entered_by := a5(indx);
          t(ddindx).entered_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).note_type := a7(indx);
          t(ddindx).jtf_note_id := a8(indx);
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
          t(ddindx).context := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t jtf_tasks_pub.task_notes_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_VARCHAR2_TABLE_32767
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
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
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_32767();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
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
    a24 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_32767();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
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
      a24 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).parent_note_id;
          a1(indx) := t(ddindx).org_id;
          a2(indx) := t(ddindx).notes;
          a3(indx) := t(ddindx).notes_detail;
          a4(indx) := t(ddindx).note_status;
          a5(indx) := t(ddindx).entered_by;
          a6(indx) := t(ddindx).entered_date;
          a7(indx) := t(ddindx).note_type;
          a8(indx) := t(ddindx).jtf_note_id;
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
          a24(indx) := t(ddindx).context;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p26(t out nocopy jtf_tasks_pub.task_contacts_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contact_id := a0(indx);
          t(ddindx).contact_type_code := a1(indx);
          t(ddindx).escalation_notify_flag := a2(indx);
          t(ddindx).escalation_requester_flag := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t jtf_tasks_pub.task_contacts_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contact_id;
          a1(indx) := t(ddindx).contact_type_code;
          a2(indx) := t(ddindx).escalation_notify_flag;
          a3(indx) := t(ddindx).escalation_requester_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p31(t out nocopy jtf_tasks_pub.task_table_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_4000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_4000
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_4000
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_400
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_DATE_TABLE
    , a73 JTF_VARCHAR2_TABLE_4000
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_DATE_TABLE
    , a76 JTF_DATE_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_id := a0(indx);
          t(ddindx).task_number := a1(indx);
          t(ddindx).task_name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).task_type_id := a4(indx);
          t(ddindx).task_type := a5(indx);
          t(ddindx).task_status_id := a6(indx);
          t(ddindx).task_status := a7(indx);
          t(ddindx).task_priority_id := a8(indx);
          t(ddindx).task_priority := a9(indx);
          t(ddindx).owner_type_code := a10(indx);
          t(ddindx).owner_id := a11(indx);
          t(ddindx).owner := a12(indx);
          t(ddindx).assigned_by_id := a13(indx);
          t(ddindx).assigned_by_name := a14(indx);
          t(ddindx).customer_id := a15(indx);
          t(ddindx).customer_name := a16(indx);
          t(ddindx).customer_number := a17(indx);
          t(ddindx).cust_account_number := a18(indx);
          t(ddindx).cust_account_id := a19(indx);
          t(ddindx).address_id := a20(indx);
          t(ddindx).planned_start_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).planned_end_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).scheduled_start_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).scheduled_end_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).actual_start_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).actual_end_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).object_type_code := a27(indx);
          t(ddindx).object_id := a28(indx);
          t(ddindx).obect_name := a29(indx);
          t(ddindx).duration := a30(indx);
          t(ddindx).duration_uom := a31(indx);
          t(ddindx).planned_effort := a32(indx);
          t(ddindx).planned_effort_uom := a33(indx);
          t(ddindx).actual_effort := a34(indx);
          t(ddindx).actual_effort_uom := a35(indx);
          t(ddindx).percentage_complete := a36(indx);
          t(ddindx).reason_code := a37(indx);
          t(ddindx).private_flag := a38(indx);
          t(ddindx).publish_flag := a39(indx);
          t(ddindx).multi_booked_flag := a40(indx);
          t(ddindx).milestone_flag := a41(indx);
          t(ddindx).holiday_flag := a42(indx);
          t(ddindx).workflow_process_id := a43(indx);
          t(ddindx).notification_flag := a44(indx);
          t(ddindx).notification_period := a45(indx);
          t(ddindx).notification_period_uom := a46(indx);
          t(ddindx).parent_task_id := a47(indx);
          t(ddindx).alarm_start := a48(indx);
          t(ddindx).alarm_start_uom := a49(indx);
          t(ddindx).alarm_on := a50(indx);
          t(ddindx).alarm_count := a51(indx);
          t(ddindx).alarm_fired_count := a52(indx);
          t(ddindx).alarm_interval := a53(indx);
          t(ddindx).alarm_interval_uom := a54(indx);
          t(ddindx).attribute1 := a55(indx);
          t(ddindx).attribute2 := a56(indx);
          t(ddindx).attribute3 := a57(indx);
          t(ddindx).attribute4 := a58(indx);
          t(ddindx).attribute5 := a59(indx);
          t(ddindx).attribute6 := a60(indx);
          t(ddindx).attribute7 := a61(indx);
          t(ddindx).attribute8 := a62(indx);
          t(ddindx).attribute9 := a63(indx);
          t(ddindx).attribute10 := a64(indx);
          t(ddindx).attribute11 := a65(indx);
          t(ddindx).attribute12 := a66(indx);
          t(ddindx).attribute13 := a67(indx);
          t(ddindx).attribute14 := a68(indx);
          t(ddindx).attribute15 := a69(indx);
          t(ddindx).attribute_category := a70(indx);
          t(ddindx).owner_territory_id := a71(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a72(indx));
          t(ddindx).escalation_level := a73(indx);
          t(ddindx).object_version_number := a74(indx);
          t(ddindx).calendar_start_date := rosetta_g_miss_date_in_map(a75(indx));
          t(ddindx).calendar_end_date := rosetta_g_miss_date_in_map(a76(indx));
          t(ddindx).date_selected := a77(indx);
          t(ddindx).task_split_flag := a78(indx);
          t(ddindx).child_position := a79(indx);
          t(ddindx).child_sequence_num := a80(indx);
          t(ddindx).location_id := a81(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t jtf_tasks_pub.task_table_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_400
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_DATE_TABLE
    , a76 out nocopy JTF_DATE_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_4000();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_4000();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_4000();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_400();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_200();
    a65 := JTF_VARCHAR2_TABLE_200();
    a66 := JTF_VARCHAR2_TABLE_200();
    a67 := JTF_VARCHAR2_TABLE_200();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_VARCHAR2_TABLE_200();
    a70 := JTF_VARCHAR2_TABLE_200();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_DATE_TABLE();
    a73 := JTF_VARCHAR2_TABLE_4000();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_DATE_TABLE();
    a76 := JTF_DATE_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_4000();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_4000();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_4000();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_400();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_200();
      a65 := JTF_VARCHAR2_TABLE_200();
      a66 := JTF_VARCHAR2_TABLE_200();
      a67 := JTF_VARCHAR2_TABLE_200();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_VARCHAR2_TABLE_200();
      a70 := JTF_VARCHAR2_TABLE_200();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_DATE_TABLE();
      a73 := JTF_VARCHAR2_TABLE_4000();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_DATE_TABLE();
      a76 := JTF_DATE_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
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
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_id;
          a1(indx) := t(ddindx).task_number;
          a2(indx) := t(ddindx).task_name;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).task_type_id;
          a5(indx) := t(ddindx).task_type;
          a6(indx) := t(ddindx).task_status_id;
          a7(indx) := t(ddindx).task_status;
          a8(indx) := t(ddindx).task_priority_id;
          a9(indx) := t(ddindx).task_priority;
          a10(indx) := t(ddindx).owner_type_code;
          a11(indx) := t(ddindx).owner_id;
          a12(indx) := t(ddindx).owner;
          a13(indx) := t(ddindx).assigned_by_id;
          a14(indx) := t(ddindx).assigned_by_name;
          a15(indx) := t(ddindx).customer_id;
          a16(indx) := t(ddindx).customer_name;
          a17(indx) := t(ddindx).customer_number;
          a18(indx) := t(ddindx).cust_account_number;
          a19(indx) := t(ddindx).cust_account_id;
          a20(indx) := t(ddindx).address_id;
          a21(indx) := t(ddindx).planned_start_date;
          a22(indx) := t(ddindx).planned_end_date;
          a23(indx) := t(ddindx).scheduled_start_date;
          a24(indx) := t(ddindx).scheduled_end_date;
          a25(indx) := t(ddindx).actual_start_date;
          a26(indx) := t(ddindx).actual_end_date;
          a27(indx) := t(ddindx).object_type_code;
          a28(indx) := t(ddindx).object_id;
          a29(indx) := t(ddindx).obect_name;
          a30(indx) := t(ddindx).duration;
          a31(indx) := t(ddindx).duration_uom;
          a32(indx) := t(ddindx).planned_effort;
          a33(indx) := t(ddindx).planned_effort_uom;
          a34(indx) := t(ddindx).actual_effort;
          a35(indx) := t(ddindx).actual_effort_uom;
          a36(indx) := t(ddindx).percentage_complete;
          a37(indx) := t(ddindx).reason_code;
          a38(indx) := t(ddindx).private_flag;
          a39(indx) := t(ddindx).publish_flag;
          a40(indx) := t(ddindx).multi_booked_flag;
          a41(indx) := t(ddindx).milestone_flag;
          a42(indx) := t(ddindx).holiday_flag;
          a43(indx) := t(ddindx).workflow_process_id;
          a44(indx) := t(ddindx).notification_flag;
          a45(indx) := t(ddindx).notification_period;
          a46(indx) := t(ddindx).notification_period_uom;
          a47(indx) := t(ddindx).parent_task_id;
          a48(indx) := t(ddindx).alarm_start;
          a49(indx) := t(ddindx).alarm_start_uom;
          a50(indx) := t(ddindx).alarm_on;
          a51(indx) := t(ddindx).alarm_count;
          a52(indx) := t(ddindx).alarm_fired_count;
          a53(indx) := t(ddindx).alarm_interval;
          a54(indx) := t(ddindx).alarm_interval_uom;
          a55(indx) := t(ddindx).attribute1;
          a56(indx) := t(ddindx).attribute2;
          a57(indx) := t(ddindx).attribute3;
          a58(indx) := t(ddindx).attribute4;
          a59(indx) := t(ddindx).attribute5;
          a60(indx) := t(ddindx).attribute6;
          a61(indx) := t(ddindx).attribute7;
          a62(indx) := t(ddindx).attribute8;
          a63(indx) := t(ddindx).attribute9;
          a64(indx) := t(ddindx).attribute10;
          a65(indx) := t(ddindx).attribute11;
          a66(indx) := t(ddindx).attribute12;
          a67(indx) := t(ddindx).attribute13;
          a68(indx) := t(ddindx).attribute14;
          a69(indx) := t(ddindx).attribute15;
          a70(indx) := t(ddindx).attribute_category;
          a71(indx) := t(ddindx).owner_territory_id;
          a72(indx) := t(ddindx).creation_date;
          a73(indx) := t(ddindx).escalation_level;
          a74(indx) := t(ddindx).object_version_number;
          a75(indx) := t(ddindx).calendar_start_date;
          a76(indx) := t(ddindx).calendar_end_date;
          a77(indx) := t(ddindx).date_selected;
          a78(indx) := t(ddindx).task_split_flag;
          a79(indx) := t(ddindx).child_position;
          a80(indx) := t(ddindx).child_sequence_num;
          a81(indx) := t(ddindx).location_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p34(t out nocopy jtf_tasks_pub.sort_data, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).field_name := a0(indx);
          t(ddindx).asc_dsc_flag := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p34;
  procedure rosetta_table_copy_out_p34(t jtf_tasks_pub.sort_data, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).field_name;
          a1(indx) := t(ddindx).asc_dsc_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p34;

  procedure rosetta_table_copy_in_p53(t out nocopy jtf_tasks_pub.task_details_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_id := a0(indx);
          t(ddindx).task_template_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p53;
  procedure rosetta_table_copy_out_p53(t jtf_tasks_pub.task_details_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_id;
          a1(indx) := t(ddindx).task_template_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p53;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_number  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , p73_a0 JTF_VARCHAR2_TABLE_100
    , p73_a1 JTF_NUMBER_TABLE
    , p73_a2 JTF_DATE_TABLE
    , p73_a3 JTF_DATE_TABLE
    , p73_a4 JTF_NUMBER_TABLE
    , p73_a5 JTF_VARCHAR2_TABLE_100
    , p73_a6 JTF_NUMBER_TABLE
    , p73_a7 JTF_NUMBER_TABLE
    , p73_a8 JTF_VARCHAR2_TABLE_100
    , p73_a9 JTF_NUMBER_TABLE
    , p73_a10 JTF_NUMBER_TABLE
    , p73_a11 JTF_VARCHAR2_TABLE_100
    , p73_a12 JTF_VARCHAR2_TABLE_100
    , p73_a13 JTF_VARCHAR2_TABLE_100
    , p73_a14 JTF_VARCHAR2_TABLE_200
    , p73_a15 JTF_VARCHAR2_TABLE_100
    , p73_a16 JTF_VARCHAR2_TABLE_100
    , p73_a17 JTF_VARCHAR2_TABLE_100
    , p73_a18 JTF_VARCHAR2_TABLE_100
    , p73_a19 JTF_VARCHAR2_TABLE_100
    , p73_a20 JTF_VARCHAR2_TABLE_100
    , p73_a21 JTF_NUMBER_TABLE
    , p73_a22 JTF_NUMBER_TABLE
    , p73_a23 JTF_NUMBER_TABLE
    , p73_a24 JTF_VARCHAR2_TABLE_100
    , p73_a25 JTF_NUMBER_TABLE
    , p74_a0 JTF_NUMBER_TABLE
    , p74_a1 JTF_NUMBER_TABLE
    , p74_a2 JTF_VARCHAR2_TABLE_100
    , p74_a3 JTF_NUMBER_TABLE
    , p74_a4 JTF_VARCHAR2_TABLE_100
    , p74_a5 JTF_VARCHAR2_TABLE_100
    , p75_a0 JTF_VARCHAR2_TABLE_100
    , p75_a1 JTF_NUMBER_TABLE
    , p75_a2 JTF_VARCHAR2_TABLE_100
    , p76_a0 JTF_VARCHAR2_TABLE_100
    , p76_a1 JTF_VARCHAR2_TABLE_100
    , p76_a2 JTF_VARCHAR2_TABLE_100
    , p76_a3 JTF_NUMBER_TABLE
    , p76_a4 JTF_VARCHAR2_TABLE_2000
    , p76_a5 JTF_VARCHAR2_TABLE_100
    , p76_a6 JTF_VARCHAR2_TABLE_2000
    , p77_a0 JTF_NUMBER_TABLE
    , p77_a1 JTF_VARCHAR2_TABLE_100
    , p77_a2 JTF_VARCHAR2_TABLE_100
    , p77_a3 JTF_DATE_TABLE
    , p78_a0 JTF_NUMBER_TABLE
    , p78_a1 JTF_NUMBER_TABLE
    , p78_a2 JTF_VARCHAR2_TABLE_4000
    , p78_a3 JTF_VARCHAR2_TABLE_32767
    , p78_a4 JTF_VARCHAR2_TABLE_100
    , p78_a5 JTF_NUMBER_TABLE
    , p78_a6 JTF_DATE_TABLE
    , p78_a7 JTF_VARCHAR2_TABLE_100
    , p78_a8 JTF_NUMBER_TABLE
    , p78_a9 JTF_VARCHAR2_TABLE_200
    , p78_a10 JTF_VARCHAR2_TABLE_200
    , p78_a11 JTF_VARCHAR2_TABLE_200
    , p78_a12 JTF_VARCHAR2_TABLE_200
    , p78_a13 JTF_VARCHAR2_TABLE_200
    , p78_a14 JTF_VARCHAR2_TABLE_200
    , p78_a15 JTF_VARCHAR2_TABLE_200
    , p78_a16 JTF_VARCHAR2_TABLE_200
    , p78_a17 JTF_VARCHAR2_TABLE_200
    , p78_a18 JTF_VARCHAR2_TABLE_200
    , p78_a19 JTF_VARCHAR2_TABLE_200
    , p78_a20 JTF_VARCHAR2_TABLE_200
    , p78_a21 JTF_VARCHAR2_TABLE_200
    , p78_a22 JTF_VARCHAR2_TABLE_200
    , p78_a23 JTF_VARCHAR2_TABLE_200
    , p78_a24 JTF_VARCHAR2_TABLE_100
    , p79_a0  NUMBER
    , p79_a1  NUMBER
    , p79_a2  NUMBER
    , p79_a3  NUMBER
    , p79_a4  VARCHAR2
    , p79_a5  NUMBER
    , p79_a6  NUMBER
    , p79_a7  DATE
    , p79_a8  DATE
    , p80_a0 JTF_NUMBER_TABLE
    , p80_a1 JTF_VARCHAR2_TABLE_100
    , p80_a2 JTF_VARCHAR2_TABLE_100
    , p80_a3 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_task_split_flag  VARCHAR2
    , p_reference_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
    , p_location_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_task_assign_tbl jtf_tasks_pub.task_assign_tbl;
    ddp_task_depends_tbl jtf_tasks_pub.task_depends_tbl;
    ddp_task_rsrc_req_tbl jtf_tasks_pub.task_rsrc_req_tbl;
    ddp_task_refer_tbl jtf_tasks_pub.task_refer_tbl;
    ddp_task_dates_tbl jtf_tasks_pub.task_dates_tbl;
    ddp_task_notes_tbl jtf_tasks_pub.task_notes_tbl;
    ddp_task_recur_rec jtf_tasks_pub.task_recur_rec;
    ddp_task_contacts_tbl jtf_tasks_pub.task_contacts_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);












































    jtf_tasks_pub_w.rosetta_table_copy_in_p6(ddp_task_assign_tbl, p73_a0
      , p73_a1
      , p73_a2
      , p73_a3
      , p73_a4
      , p73_a5
      , p73_a6
      , p73_a7
      , p73_a8
      , p73_a9
      , p73_a10
      , p73_a11
      , p73_a12
      , p73_a13
      , p73_a14
      , p73_a15
      , p73_a16
      , p73_a17
      , p73_a18
      , p73_a19
      , p73_a20
      , p73_a21
      , p73_a22
      , p73_a23
      , p73_a24
      , p73_a25
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p9(ddp_task_depends_tbl, p74_a0
      , p74_a1
      , p74_a2
      , p74_a3
      , p74_a4
      , p74_a5
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p12(ddp_task_rsrc_req_tbl, p75_a0
      , p75_a1
      , p75_a2
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p15(ddp_task_refer_tbl, p76_a0
      , p76_a1
      , p76_a2
      , p76_a3
      , p76_a4
      , p76_a5
      , p76_a6
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p20(ddp_task_dates_tbl, p77_a0
      , p77_a1
      , p77_a2
      , p77_a3
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p23(ddp_task_notes_tbl, p78_a0
      , p78_a1
      , p78_a2
      , p78_a3
      , p78_a4
      , p78_a5
      , p78_a6
      , p78_a7
      , p78_a8
      , p78_a9
      , p78_a10
      , p78_a11
      , p78_a12
      , p78_a13
      , p78_a14
      , p78_a15
      , p78_a16
      , p78_a17
      , p78_a18
      , p78_a19
      , p78_a20
      , p78_a21
      , p78_a22
      , p78_a23
      , p78_a24
      );

    ddp_task_recur_rec.occurs_which := p79_a0;
    ddp_task_recur_rec.day_of_week := p79_a1;
    ddp_task_recur_rec.date_of_month := p79_a2;
    ddp_task_recur_rec.occurs_month := p79_a3;
    ddp_task_recur_rec.occurs_uom := p79_a4;
    ddp_task_recur_rec.occurs_every := p79_a5;
    ddp_task_recur_rec.occurs_number := p79_a6;
    ddp_task_recur_rec.start_date_active := rosetta_g_miss_date_in_map(p79_a7);
    ddp_task_recur_rec.end_date_active := rosetta_g_miss_date_in_map(p79_a8);

    jtf_tasks_pub_w.rosetta_table_copy_in_p26(ddp_task_contacts_tbl, p80_a0
      , p80_a1
      , p80_a2
      , p80_a3
      );


































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_number,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      ddp_task_assign_tbl,
      ddp_task_depends_tbl,
      ddp_task_rsrc_req_tbl,
      ddp_task_refer_tbl,
      ddp_task_dates_tbl,
      ddp_task_notes_tbl,
      ddp_task_recur_rec,
      ddp_task_contacts_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow,
      p_task_split_flag,
      p_reference_flag,
      p_child_position,
      p_child_sequence_num,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

















































































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_number  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_task_split_flag  VARCHAR2
    , p_reference_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);












































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_number,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow,
      p_task_split_flag,
      p_reference_flag,
      p_child_position,
      p_child_sequence_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








































































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_number  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);








































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_number,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




































































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_number  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , p73_a0 JTF_VARCHAR2_TABLE_100
    , p73_a1 JTF_NUMBER_TABLE
    , p73_a2 JTF_DATE_TABLE
    , p73_a3 JTF_DATE_TABLE
    , p73_a4 JTF_NUMBER_TABLE
    , p73_a5 JTF_VARCHAR2_TABLE_100
    , p73_a6 JTF_NUMBER_TABLE
    , p73_a7 JTF_NUMBER_TABLE
    , p73_a8 JTF_VARCHAR2_TABLE_100
    , p73_a9 JTF_NUMBER_TABLE
    , p73_a10 JTF_NUMBER_TABLE
    , p73_a11 JTF_VARCHAR2_TABLE_100
    , p73_a12 JTF_VARCHAR2_TABLE_100
    , p73_a13 JTF_VARCHAR2_TABLE_100
    , p73_a14 JTF_VARCHAR2_TABLE_200
    , p73_a15 JTF_VARCHAR2_TABLE_100
    , p73_a16 JTF_VARCHAR2_TABLE_100
    , p73_a17 JTF_VARCHAR2_TABLE_100
    , p73_a18 JTF_VARCHAR2_TABLE_100
    , p73_a19 JTF_VARCHAR2_TABLE_100
    , p73_a20 JTF_VARCHAR2_TABLE_100
    , p73_a21 JTF_NUMBER_TABLE
    , p73_a22 JTF_NUMBER_TABLE
    , p73_a23 JTF_NUMBER_TABLE
    , p73_a24 JTF_VARCHAR2_TABLE_100
    , p73_a25 JTF_NUMBER_TABLE
    , p74_a0 JTF_NUMBER_TABLE
    , p74_a1 JTF_NUMBER_TABLE
    , p74_a2 JTF_VARCHAR2_TABLE_100
    , p74_a3 JTF_NUMBER_TABLE
    , p74_a4 JTF_VARCHAR2_TABLE_100
    , p74_a5 JTF_VARCHAR2_TABLE_100
    , p75_a0 JTF_VARCHAR2_TABLE_100
    , p75_a1 JTF_NUMBER_TABLE
    , p75_a2 JTF_VARCHAR2_TABLE_100
    , p76_a0 JTF_VARCHAR2_TABLE_100
    , p76_a1 JTF_VARCHAR2_TABLE_100
    , p76_a2 JTF_VARCHAR2_TABLE_100
    , p76_a3 JTF_NUMBER_TABLE
    , p76_a4 JTF_VARCHAR2_TABLE_2000
    , p76_a5 JTF_VARCHAR2_TABLE_100
    , p76_a6 JTF_VARCHAR2_TABLE_2000
    , p77_a0 JTF_NUMBER_TABLE
    , p77_a1 JTF_VARCHAR2_TABLE_100
    , p77_a2 JTF_VARCHAR2_TABLE_100
    , p77_a3 JTF_DATE_TABLE
    , p78_a0 JTF_NUMBER_TABLE
    , p78_a1 JTF_NUMBER_TABLE
    , p78_a2 JTF_VARCHAR2_TABLE_4000
    , p78_a3 JTF_VARCHAR2_TABLE_32767
    , p78_a4 JTF_VARCHAR2_TABLE_100
    , p78_a5 JTF_NUMBER_TABLE
    , p78_a6 JTF_DATE_TABLE
    , p78_a7 JTF_VARCHAR2_TABLE_100
    , p78_a8 JTF_NUMBER_TABLE
    , p78_a9 JTF_VARCHAR2_TABLE_200
    , p78_a10 JTF_VARCHAR2_TABLE_200
    , p78_a11 JTF_VARCHAR2_TABLE_200
    , p78_a12 JTF_VARCHAR2_TABLE_200
    , p78_a13 JTF_VARCHAR2_TABLE_200
    , p78_a14 JTF_VARCHAR2_TABLE_200
    , p78_a15 JTF_VARCHAR2_TABLE_200
    , p78_a16 JTF_VARCHAR2_TABLE_200
    , p78_a17 JTF_VARCHAR2_TABLE_200
    , p78_a18 JTF_VARCHAR2_TABLE_200
    , p78_a19 JTF_VARCHAR2_TABLE_200
    , p78_a20 JTF_VARCHAR2_TABLE_200
    , p78_a21 JTF_VARCHAR2_TABLE_200
    , p78_a22 JTF_VARCHAR2_TABLE_200
    , p78_a23 JTF_VARCHAR2_TABLE_200
    , p78_a24 JTF_VARCHAR2_TABLE_100
    , p79_a0  NUMBER
    , p79_a1  NUMBER
    , p79_a2  NUMBER
    , p79_a3  NUMBER
    , p79_a4  VARCHAR2
    , p79_a5  NUMBER
    , p79_a6  NUMBER
    , p79_a7  DATE
    , p79_a8  DATE
    , p80_a0 JTF_NUMBER_TABLE
    , p80_a1 JTF_VARCHAR2_TABLE_100
    , p80_a2 JTF_VARCHAR2_TABLE_100
    , p80_a3 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_task_assign_tbl jtf_tasks_pub.task_assign_tbl;
    ddp_task_depends_tbl jtf_tasks_pub.task_depends_tbl;
    ddp_task_rsrc_req_tbl jtf_tasks_pub.task_rsrc_req_tbl;
    ddp_task_refer_tbl jtf_tasks_pub.task_refer_tbl;
    ddp_task_dates_tbl jtf_tasks_pub.task_dates_tbl;
    ddp_task_notes_tbl jtf_tasks_pub.task_notes_tbl;
    ddp_task_recur_rec jtf_tasks_pub.task_recur_rec;
    ddp_task_contacts_tbl jtf_tasks_pub.task_contacts_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);












































    jtf_tasks_pub_w.rosetta_table_copy_in_p6(ddp_task_assign_tbl, p73_a0
      , p73_a1
      , p73_a2
      , p73_a3
      , p73_a4
      , p73_a5
      , p73_a6
      , p73_a7
      , p73_a8
      , p73_a9
      , p73_a10
      , p73_a11
      , p73_a12
      , p73_a13
      , p73_a14
      , p73_a15
      , p73_a16
      , p73_a17
      , p73_a18
      , p73_a19
      , p73_a20
      , p73_a21
      , p73_a22
      , p73_a23
      , p73_a24
      , p73_a25
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p9(ddp_task_depends_tbl, p74_a0
      , p74_a1
      , p74_a2
      , p74_a3
      , p74_a4
      , p74_a5
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p12(ddp_task_rsrc_req_tbl, p75_a0
      , p75_a1
      , p75_a2
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p15(ddp_task_refer_tbl, p76_a0
      , p76_a1
      , p76_a2
      , p76_a3
      , p76_a4
      , p76_a5
      , p76_a6
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p20(ddp_task_dates_tbl, p77_a0
      , p77_a1
      , p77_a2
      , p77_a3
      );

    jtf_tasks_pub_w.rosetta_table_copy_in_p23(ddp_task_notes_tbl, p78_a0
      , p78_a1
      , p78_a2
      , p78_a3
      , p78_a4
      , p78_a5
      , p78_a6
      , p78_a7
      , p78_a8
      , p78_a9
      , p78_a10
      , p78_a11
      , p78_a12
      , p78_a13
      , p78_a14
      , p78_a15
      , p78_a16
      , p78_a17
      , p78_a18
      , p78_a19
      , p78_a20
      , p78_a21
      , p78_a22
      , p78_a23
      , p78_a24
      );

    ddp_task_recur_rec.occurs_which := p79_a0;
    ddp_task_recur_rec.day_of_week := p79_a1;
    ddp_task_recur_rec.date_of_month := p79_a2;
    ddp_task_recur_rec.occurs_month := p79_a3;
    ddp_task_recur_rec.occurs_uom := p79_a4;
    ddp_task_recur_rec.occurs_every := p79_a5;
    ddp_task_recur_rec.occurs_number := p79_a6;
    ddp_task_recur_rec.start_date_active := rosetta_g_miss_date_in_map(p79_a7);
    ddp_task_recur_rec.end_date_active := rosetta_g_miss_date_in_map(p79_a8);

    jtf_tasks_pub_w.rosetta_table_copy_in_p26(ddp_task_contacts_tbl, p80_a0
      , p80_a1
      , p80_a2
      , p80_a3
      );



























    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_number,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      ddp_task_assign_tbl,
      ddp_task_depends_tbl,
      ddp_task_rsrc_req_tbl,
      ddp_task_refer_tbl,
      ddp_task_dates_tbl,
      ddp_task_notes_tbl,
      ddp_task_recur_rec,
      ddp_task_contacts_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










































































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_task_split_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
    , p_location_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);










































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_number,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_parent_task_id,
      p_parent_task_number,
      p_enable_workflow,
      p_abort_workflow,
      p_task_split_flag,
      p_child_position,
      p_child_sequence_num,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








































































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_task_split_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);









































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_number,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_parent_task_id,
      p_parent_task_number,
      p_enable_workflow,
      p_abort_workflow,
      p_task_split_flag,
      p_child_position,
      p_child_sequence_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







































































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);






































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_number,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_parent_task_id,
      p_parent_task_number,
      p_enable_workflow,
      p_abort_workflow);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




































































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);




































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_number,
      p_task_name,
      p_task_type_name,
      p_task_type_id,
      p_description,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_name,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_name,
      p_assigned_by_id,
      p_customer_number,
      p_customer_id,
      p_cust_account_number,
      p_cust_account_id,
      p_address_id,
      p_address_number,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_timezone_name,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_parent_task_id,
      p_parent_task_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


































































































  end;

  procedure export_query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_file_name  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p49_a0 JTF_VARCHAR2_TABLE_100
    , p49_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p54_a0 out nocopy JTF_NUMBER_TABLE
    , p54_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a4 out nocopy JTF_NUMBER_TABLE
    , p54_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a6 out nocopy JTF_NUMBER_TABLE
    , p54_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a8 out nocopy JTF_NUMBER_TABLE
    , p54_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a11 out nocopy JTF_NUMBER_TABLE
    , p54_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a13 out nocopy JTF_NUMBER_TABLE
    , p54_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a15 out nocopy JTF_NUMBER_TABLE
    , p54_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p54_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a19 out nocopy JTF_NUMBER_TABLE
    , p54_a20 out nocopy JTF_NUMBER_TABLE
    , p54_a21 out nocopy JTF_DATE_TABLE
    , p54_a22 out nocopy JTF_DATE_TABLE
    , p54_a23 out nocopy JTF_DATE_TABLE
    , p54_a24 out nocopy JTF_DATE_TABLE
    , p54_a25 out nocopy JTF_DATE_TABLE
    , p54_a26 out nocopy JTF_DATE_TABLE
    , p54_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a28 out nocopy JTF_NUMBER_TABLE
    , p54_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a30 out nocopy JTF_NUMBER_TABLE
    , p54_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a32 out nocopy JTF_NUMBER_TABLE
    , p54_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a34 out nocopy JTF_NUMBER_TABLE
    , p54_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a36 out nocopy JTF_NUMBER_TABLE
    , p54_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a43 out nocopy JTF_NUMBER_TABLE
    , p54_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a45 out nocopy JTF_NUMBER_TABLE
    , p54_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a47 out nocopy JTF_NUMBER_TABLE
    , p54_a48 out nocopy JTF_NUMBER_TABLE
    , p54_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a51 out nocopy JTF_NUMBER_TABLE
    , p54_a52 out nocopy JTF_NUMBER_TABLE
    , p54_a53 out nocopy JTF_NUMBER_TABLE
    , p54_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a71 out nocopy JTF_NUMBER_TABLE
    , p54_a72 out nocopy JTF_DATE_TABLE
    , p54_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a74 out nocopy JTF_NUMBER_TABLE
    , p54_a75 out nocopy JTF_DATE_TABLE
    , p54_a76 out nocopy JTF_DATE_TABLE
    , p54_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a80 out nocopy JTF_NUMBER_TABLE
    , p54_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , p_location_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_sort_data jtf_tasks_pub.sort_data;
    ddx_task_table jtf_tasks_pub.task_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);



















    jtf_tasks_pub_w.rosetta_table_copy_in_p34(ddp_sort_data, p49_a0
      , p49_a1
      );













    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.export_query_task(p_api_version,
      p_init_msg_list,
      p_validate_level,
      p_file_name,
      p_task_number,
      p_task_id,
      p_task_name,
      p_description,
      p_task_type_name,
      p_task_type_id,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_assigned_name,
      p_assigned_by_id,
      p_address_id,
      p_owner_territory_id,
      p_customer_id,
      p_customer_name,
      p_customer_number,
      p_cust_account_number,
      p_cust_account_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_object_type_code,
      p_object_name,
      p_source_object_id,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_parent_task_id,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_ref_object_id,
      p_ref_object_type_code,
      ddp_sort_data,
      p_start_pointer,
      p_rec_wanted,
      p_show_all,
      p_query_or_next_code,
      ddx_task_table,
      x_total_retrieved,
      x_total_returned,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















































    jtf_tasks_pub_w.rosetta_table_copy_out_p31(ddx_task_table, p54_a0
      , p54_a1
      , p54_a2
      , p54_a3
      , p54_a4
      , p54_a5
      , p54_a6
      , p54_a7
      , p54_a8
      , p54_a9
      , p54_a10
      , p54_a11
      , p54_a12
      , p54_a13
      , p54_a14
      , p54_a15
      , p54_a16
      , p54_a17
      , p54_a18
      , p54_a19
      , p54_a20
      , p54_a21
      , p54_a22
      , p54_a23
      , p54_a24
      , p54_a25
      , p54_a26
      , p54_a27
      , p54_a28
      , p54_a29
      , p54_a30
      , p54_a31
      , p54_a32
      , p54_a33
      , p54_a34
      , p54_a35
      , p54_a36
      , p54_a37
      , p54_a38
      , p54_a39
      , p54_a40
      , p54_a41
      , p54_a42
      , p54_a43
      , p54_a44
      , p54_a45
      , p54_a46
      , p54_a47
      , p54_a48
      , p54_a49
      , p54_a50
      , p54_a51
      , p54_a52
      , p54_a53
      , p54_a54
      , p54_a55
      , p54_a56
      , p54_a57
      , p54_a58
      , p54_a59
      , p54_a60
      , p54_a61
      , p54_a62
      , p54_a63
      , p54_a64
      , p54_a65
      , p54_a66
      , p54_a67
      , p54_a68
      , p54_a69
      , p54_a70
      , p54_a71
      , p54_a72
      , p54_a73
      , p54_a74
      , p54_a75
      , p54_a76
      , p54_a77
      , p54_a78
      , p54_a79
      , p54_a80
      , p54_a81
      );







  end;

  procedure export_query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_file_name  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p49_a0 JTF_VARCHAR2_TABLE_100
    , p49_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p54_a0 out nocopy JTF_NUMBER_TABLE
    , p54_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a4 out nocopy JTF_NUMBER_TABLE
    , p54_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a6 out nocopy JTF_NUMBER_TABLE
    , p54_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a8 out nocopy JTF_NUMBER_TABLE
    , p54_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a11 out nocopy JTF_NUMBER_TABLE
    , p54_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a13 out nocopy JTF_NUMBER_TABLE
    , p54_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a15 out nocopy JTF_NUMBER_TABLE
    , p54_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p54_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a19 out nocopy JTF_NUMBER_TABLE
    , p54_a20 out nocopy JTF_NUMBER_TABLE
    , p54_a21 out nocopy JTF_DATE_TABLE
    , p54_a22 out nocopy JTF_DATE_TABLE
    , p54_a23 out nocopy JTF_DATE_TABLE
    , p54_a24 out nocopy JTF_DATE_TABLE
    , p54_a25 out nocopy JTF_DATE_TABLE
    , p54_a26 out nocopy JTF_DATE_TABLE
    , p54_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a28 out nocopy JTF_NUMBER_TABLE
    , p54_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a30 out nocopy JTF_NUMBER_TABLE
    , p54_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a32 out nocopy JTF_NUMBER_TABLE
    , p54_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a34 out nocopy JTF_NUMBER_TABLE
    , p54_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a36 out nocopy JTF_NUMBER_TABLE
    , p54_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a43 out nocopy JTF_NUMBER_TABLE
    , p54_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a45 out nocopy JTF_NUMBER_TABLE
    , p54_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a47 out nocopy JTF_NUMBER_TABLE
    , p54_a48 out nocopy JTF_NUMBER_TABLE
    , p54_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a51 out nocopy JTF_NUMBER_TABLE
    , p54_a52 out nocopy JTF_NUMBER_TABLE
    , p54_a53 out nocopy JTF_NUMBER_TABLE
    , p54_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a71 out nocopy JTF_NUMBER_TABLE
    , p54_a72 out nocopy JTF_DATE_TABLE
    , p54_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a74 out nocopy JTF_NUMBER_TABLE
    , p54_a75 out nocopy JTF_DATE_TABLE
    , p54_a76 out nocopy JTF_DATE_TABLE
    , p54_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a80 out nocopy JTF_NUMBER_TABLE
    , p54_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_sort_data jtf_tasks_pub.sort_data;
    ddx_task_table jtf_tasks_pub.task_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);



















    jtf_tasks_pub_w.rosetta_table_copy_in_p34(ddp_sort_data, p49_a0
      , p49_a1
      );












    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.export_query_task(p_api_version,
      p_init_msg_list,
      p_validate_level,
      p_file_name,
      p_task_number,
      p_task_id,
      p_task_name,
      p_description,
      p_task_type_name,
      p_task_type_id,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_assigned_name,
      p_assigned_by_id,
      p_address_id,
      p_owner_territory_id,
      p_customer_id,
      p_customer_name,
      p_customer_number,
      p_cust_account_number,
      p_cust_account_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_object_type_code,
      p_object_name,
      p_source_object_id,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_parent_task_id,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_ref_object_id,
      p_ref_object_type_code,
      ddp_sort_data,
      p_start_pointer,
      p_rec_wanted,
      p_show_all,
      p_query_or_next_code,
      ddx_task_table,
      x_total_retrieved,
      x_total_returned,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















































    jtf_tasks_pub_w.rosetta_table_copy_out_p31(ddx_task_table, p54_a0
      , p54_a1
      , p54_a2
      , p54_a3
      , p54_a4
      , p54_a5
      , p54_a6
      , p54_a7
      , p54_a8
      , p54_a9
      , p54_a10
      , p54_a11
      , p54_a12
      , p54_a13
      , p54_a14
      , p54_a15
      , p54_a16
      , p54_a17
      , p54_a18
      , p54_a19
      , p54_a20
      , p54_a21
      , p54_a22
      , p54_a23
      , p54_a24
      , p54_a25
      , p54_a26
      , p54_a27
      , p54_a28
      , p54_a29
      , p54_a30
      , p54_a31
      , p54_a32
      , p54_a33
      , p54_a34
      , p54_a35
      , p54_a36
      , p54_a37
      , p54_a38
      , p54_a39
      , p54_a40
      , p54_a41
      , p54_a42
      , p54_a43
      , p54_a44
      , p54_a45
      , p54_a46
      , p54_a47
      , p54_a48
      , p54_a49
      , p54_a50
      , p54_a51
      , p54_a52
      , p54_a53
      , p54_a54
      , p54_a55
      , p54_a56
      , p54_a57
      , p54_a58
      , p54_a59
      , p54_a60
      , p54_a61
      , p54_a62
      , p54_a63
      , p54_a64
      , p54_a65
      , p54_a66
      , p54_a67
      , p54_a68
      , p54_a69
      , p54_a70
      , p54_a71
      , p54_a72
      , p54_a73
      , p54_a74
      , p54_a75
      , p54_a76
      , p54_a77
      , p54_a78
      , p54_a79
      , p54_a80
      , p54_a81
      );






  end;

  procedure query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p48_a0 JTF_VARCHAR2_TABLE_100
    , p48_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p53_a0 out nocopy JTF_NUMBER_TABLE
    , p53_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a4 out nocopy JTF_NUMBER_TABLE
    , p53_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a6 out nocopy JTF_NUMBER_TABLE
    , p53_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a8 out nocopy JTF_NUMBER_TABLE
    , p53_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a11 out nocopy JTF_NUMBER_TABLE
    , p53_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a13 out nocopy JTF_NUMBER_TABLE
    , p53_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a15 out nocopy JTF_NUMBER_TABLE
    , p53_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p53_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a19 out nocopy JTF_NUMBER_TABLE
    , p53_a20 out nocopy JTF_NUMBER_TABLE
    , p53_a21 out nocopy JTF_DATE_TABLE
    , p53_a22 out nocopy JTF_DATE_TABLE
    , p53_a23 out nocopy JTF_DATE_TABLE
    , p53_a24 out nocopy JTF_DATE_TABLE
    , p53_a25 out nocopy JTF_DATE_TABLE
    , p53_a26 out nocopy JTF_DATE_TABLE
    , p53_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a28 out nocopy JTF_NUMBER_TABLE
    , p53_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a30 out nocopy JTF_NUMBER_TABLE
    , p53_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a32 out nocopy JTF_NUMBER_TABLE
    , p53_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a34 out nocopy JTF_NUMBER_TABLE
    , p53_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a36 out nocopy JTF_NUMBER_TABLE
    , p53_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a43 out nocopy JTF_NUMBER_TABLE
    , p53_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a45 out nocopy JTF_NUMBER_TABLE
    , p53_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a47 out nocopy JTF_NUMBER_TABLE
    , p53_a48 out nocopy JTF_NUMBER_TABLE
    , p53_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a51 out nocopy JTF_NUMBER_TABLE
    , p53_a52 out nocopy JTF_NUMBER_TABLE
    , p53_a53 out nocopy JTF_NUMBER_TABLE
    , p53_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a71 out nocopy JTF_NUMBER_TABLE
    , p53_a72 out nocopy JTF_DATE_TABLE
    , p53_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a74 out nocopy JTF_NUMBER_TABLE
    , p53_a75 out nocopy JTF_DATE_TABLE
    , p53_a76 out nocopy JTF_DATE_TABLE
    , p53_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a80 out nocopy JTF_NUMBER_TABLE
    , p53_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , p_location_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_sort_data jtf_tasks_pub.sort_data;
    ddx_task_table jtf_tasks_pub.task_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);



















    jtf_tasks_pub_w.rosetta_table_copy_in_p34(ddp_sort_data, p48_a0
      , p48_a1
      );













    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.query_task(p_api_version,
      p_init_msg_list,
      p_validate_level,
      p_task_number,
      p_task_id,
      p_task_name,
      p_description,
      p_task_type_name,
      p_task_type_id,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_assigned_name,
      p_assigned_by_id,
      p_address_id,
      p_owner_territory_id,
      p_customer_id,
      p_customer_name,
      p_customer_number,
      p_cust_account_number,
      p_cust_account_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_object_type_code,
      p_object_name,
      p_source_object_id,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_parent_task_id,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_ref_object_id,
      p_ref_object_type_code,
      ddp_sort_data,
      p_start_pointer,
      p_rec_wanted,
      p_show_all,
      p_query_or_next_code,
      ddx_task_table,
      x_total_retrieved,
      x_total_returned,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















































    jtf_tasks_pub_w.rosetta_table_copy_out_p31(ddx_task_table, p53_a0
      , p53_a1
      , p53_a2
      , p53_a3
      , p53_a4
      , p53_a5
      , p53_a6
      , p53_a7
      , p53_a8
      , p53_a9
      , p53_a10
      , p53_a11
      , p53_a12
      , p53_a13
      , p53_a14
      , p53_a15
      , p53_a16
      , p53_a17
      , p53_a18
      , p53_a19
      , p53_a20
      , p53_a21
      , p53_a22
      , p53_a23
      , p53_a24
      , p53_a25
      , p53_a26
      , p53_a27
      , p53_a28
      , p53_a29
      , p53_a30
      , p53_a31
      , p53_a32
      , p53_a33
      , p53_a34
      , p53_a35
      , p53_a36
      , p53_a37
      , p53_a38
      , p53_a39
      , p53_a40
      , p53_a41
      , p53_a42
      , p53_a43
      , p53_a44
      , p53_a45
      , p53_a46
      , p53_a47
      , p53_a48
      , p53_a49
      , p53_a50
      , p53_a51
      , p53_a52
      , p53_a53
      , p53_a54
      , p53_a55
      , p53_a56
      , p53_a57
      , p53_a58
      , p53_a59
      , p53_a60
      , p53_a61
      , p53_a62
      , p53_a63
      , p53_a64
      , p53_a65
      , p53_a66
      , p53_a67
      , p53_a68
      , p53_a69
      , p53_a70
      , p53_a71
      , p53_a72
      , p53_a73
      , p53_a74
      , p53_a75
      , p53_a76
      , p53_a77
      , p53_a78
      , p53_a79
      , p53_a80
      , p53_a81
      );







  end;

  procedure query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p48_a0 JTF_VARCHAR2_TABLE_100
    , p48_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p53_a0 out nocopy JTF_NUMBER_TABLE
    , p53_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a4 out nocopy JTF_NUMBER_TABLE
    , p53_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a6 out nocopy JTF_NUMBER_TABLE
    , p53_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a8 out nocopy JTF_NUMBER_TABLE
    , p53_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a11 out nocopy JTF_NUMBER_TABLE
    , p53_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a13 out nocopy JTF_NUMBER_TABLE
    , p53_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a15 out nocopy JTF_NUMBER_TABLE
    , p53_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p53_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a19 out nocopy JTF_NUMBER_TABLE
    , p53_a20 out nocopy JTF_NUMBER_TABLE
    , p53_a21 out nocopy JTF_DATE_TABLE
    , p53_a22 out nocopy JTF_DATE_TABLE
    , p53_a23 out nocopy JTF_DATE_TABLE
    , p53_a24 out nocopy JTF_DATE_TABLE
    , p53_a25 out nocopy JTF_DATE_TABLE
    , p53_a26 out nocopy JTF_DATE_TABLE
    , p53_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a28 out nocopy JTF_NUMBER_TABLE
    , p53_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a30 out nocopy JTF_NUMBER_TABLE
    , p53_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a32 out nocopy JTF_NUMBER_TABLE
    , p53_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a34 out nocopy JTF_NUMBER_TABLE
    , p53_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a36 out nocopy JTF_NUMBER_TABLE
    , p53_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a43 out nocopy JTF_NUMBER_TABLE
    , p53_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a45 out nocopy JTF_NUMBER_TABLE
    , p53_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a47 out nocopy JTF_NUMBER_TABLE
    , p53_a48 out nocopy JTF_NUMBER_TABLE
    , p53_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a51 out nocopy JTF_NUMBER_TABLE
    , p53_a52 out nocopy JTF_NUMBER_TABLE
    , p53_a53 out nocopy JTF_NUMBER_TABLE
    , p53_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a71 out nocopy JTF_NUMBER_TABLE
    , p53_a72 out nocopy JTF_DATE_TABLE
    , p53_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a74 out nocopy JTF_NUMBER_TABLE
    , p53_a75 out nocopy JTF_DATE_TABLE
    , p53_a76 out nocopy JTF_DATE_TABLE
    , p53_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a80 out nocopy JTF_NUMBER_TABLE
    , p53_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_sort_data jtf_tasks_pub.sort_data;
    ddx_task_table jtf_tasks_pub.task_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);



















    jtf_tasks_pub_w.rosetta_table_copy_in_p34(ddp_sort_data, p48_a0
      , p48_a1
      );












    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.query_task(p_api_version,
      p_init_msg_list,
      p_validate_level,
      p_task_number,
      p_task_id,
      p_task_name,
      p_description,
      p_task_type_name,
      p_task_type_id,
      p_task_status_name,
      p_task_status_id,
      p_task_priority_name,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_assigned_name,
      p_assigned_by_id,
      p_address_id,
      p_owner_territory_id,
      p_customer_id,
      p_customer_name,
      p_customer_number,
      p_cust_account_number,
      p_cust_account_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_object_type_code,
      p_object_name,
      p_source_object_id,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_parent_task_id,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_ref_object_id,
      p_ref_object_type_code,
      ddp_sort_data,
      p_start_pointer,
      p_rec_wanted,
      p_show_all,
      p_query_or_next_code,
      ddx_task_table,
      x_total_retrieved,
      x_total_returned,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















































    jtf_tasks_pub_w.rosetta_table_copy_out_p31(ddx_task_table, p53_a0
      , p53_a1
      , p53_a2
      , p53_a3
      , p53_a4
      , p53_a5
      , p53_a6
      , p53_a7
      , p53_a8
      , p53_a9
      , p53_a10
      , p53_a11
      , p53_a12
      , p53_a13
      , p53_a14
      , p53_a15
      , p53_a16
      , p53_a17
      , p53_a18
      , p53_a19
      , p53_a20
      , p53_a21
      , p53_a22
      , p53_a23
      , p53_a24
      , p53_a25
      , p53_a26
      , p53_a27
      , p53_a28
      , p53_a29
      , p53_a30
      , p53_a31
      , p53_a32
      , p53_a33
      , p53_a34
      , p53_a35
      , p53_a36
      , p53_a37
      , p53_a38
      , p53_a39
      , p53_a40
      , p53_a41
      , p53_a42
      , p53_a43
      , p53_a44
      , p53_a45
      , p53_a46
      , p53_a47
      , p53_a48
      , p53_a49
      , p53_a50
      , p53_a51
      , p53_a52
      , p53_a53
      , p53_a54
      , p53_a55
      , p53_a56
      , p53_a57
      , p53_a58
      , p53_a59
      , p53_a60
      , p53_a61
      , p53_a62
      , p53_a63
      , p53_a64
      , p53_a65
      , p53_a66
      , p53_a67
      , p53_a68
      , p53_a69
      , p53_a70
      , p53_a71
      , p53_a72
      , p53_a73
      , p53_a74
      , p53_a75
      , p53_a76
      , p53_a77
      , p53_a78
      , p53_a79
      , p53_a80
      , p53_a81
      );






  end;

  procedure query_next_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_task_id  NUMBER
    , p_query_type  VARCHAR2
    , p_date_type  VARCHAR2
    , p_date_start_or_end  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_assigned_by  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a4 out nocopy JTF_NUMBER_TABLE
    , p15_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a8 out nocopy JTF_NUMBER_TABLE
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a11 out nocopy JTF_NUMBER_TABLE
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a13 out nocopy JTF_NUMBER_TABLE
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p15_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_NUMBER_TABLE
    , p15_a20 out nocopy JTF_NUMBER_TABLE
    , p15_a21 out nocopy JTF_DATE_TABLE
    , p15_a22 out nocopy JTF_DATE_TABLE
    , p15_a23 out nocopy JTF_DATE_TABLE
    , p15_a24 out nocopy JTF_DATE_TABLE
    , p15_a25 out nocopy JTF_DATE_TABLE
    , p15_a26 out nocopy JTF_DATE_TABLE
    , p15_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a28 out nocopy JTF_NUMBER_TABLE
    , p15_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a30 out nocopy JTF_NUMBER_TABLE
    , p15_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a32 out nocopy JTF_NUMBER_TABLE
    , p15_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a34 out nocopy JTF_NUMBER_TABLE
    , p15_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a36 out nocopy JTF_NUMBER_TABLE
    , p15_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a43 out nocopy JTF_NUMBER_TABLE
    , p15_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a45 out nocopy JTF_NUMBER_TABLE
    , p15_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a47 out nocopy JTF_NUMBER_TABLE
    , p15_a48 out nocopy JTF_NUMBER_TABLE
    , p15_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a51 out nocopy JTF_NUMBER_TABLE
    , p15_a52 out nocopy JTF_NUMBER_TABLE
    , p15_a53 out nocopy JTF_NUMBER_TABLE
    , p15_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a71 out nocopy JTF_NUMBER_TABLE
    , p15_a72 out nocopy JTF_DATE_TABLE
    , p15_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a74 out nocopy JTF_NUMBER_TABLE
    , p15_a75 out nocopy JTF_DATE_TABLE
    , p15_a76 out nocopy JTF_DATE_TABLE
    , p15_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a80 out nocopy JTF_NUMBER_TABLE
    , p15_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  )

  as
    ddp_sort_data jtf_tasks_pub.sort_data;
    ddx_task_table jtf_tasks_pub.task_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    jtf_tasks_pub_w.rosetta_table_copy_in_p34(ddp_sort_data, p10_a0
      , p10_a1
      );












    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.query_next_task(p_api_version,
      p_init_msg_list,
      p_validate_level,
      p_task_id,
      p_query_type,
      p_date_type,
      p_date_start_or_end,
      p_owner_id,
      p_owner_type_code,
      p_assigned_by,
      ddp_sort_data,
      p_start_pointer,
      p_rec_wanted,
      p_show_all,
      p_query_or_next_code,
      ddx_task_table,
      x_total_retrieved,
      x_total_returned,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    jtf_tasks_pub_w.rosetta_table_copy_out_p31(ddx_task_table, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      , p15_a23
      , p15_a24
      , p15_a25
      , p15_a26
      , p15_a27
      , p15_a28
      , p15_a29
      , p15_a30
      , p15_a31
      , p15_a32
      , p15_a33
      , p15_a34
      , p15_a35
      , p15_a36
      , p15_a37
      , p15_a38
      , p15_a39
      , p15_a40
      , p15_a41
      , p15_a42
      , p15_a43
      , p15_a44
      , p15_a45
      , p15_a46
      , p15_a47
      , p15_a48
      , p15_a49
      , p15_a50
      , p15_a51
      , p15_a52
      , p15_a53
      , p15_a54
      , p15_a55
      , p15_a56
      , p15_a57
      , p15_a58
      , p15_a59
      , p15_a60
      , p15_a61
      , p15_a62
      , p15_a63
      , p15_a64
      , p15_a65
      , p15_a66
      , p15_a67
      , p15_a68
      , p15_a69
      , p15_a70
      , p15_a71
      , p15_a72
      , p15_a73
      , p15_a74
      , p15_a75
      , p15_a76
      , p15_a77
      , p15_a78
      , p15_a79
      , p15_a80
      , p15_a81
      );






  end;

  procedure export_file(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_file_name  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_VARCHAR2_TABLE_400
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_DATE_TABLE
    , p4_a22 JTF_DATE_TABLE
    , p4_a23 JTF_DATE_TABLE
    , p4_a24 JTF_DATE_TABLE
    , p4_a25 JTF_DATE_TABLE
    , p4_a26 JTF_DATE_TABLE
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_NUMBER_TABLE
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_NUMBER_TABLE
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_NUMBER_TABLE
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_NUMBER_TABLE
    , p4_a44 JTF_VARCHAR2_TABLE_100
    , p4_a45 JTF_NUMBER_TABLE
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_NUMBER_TABLE
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_NUMBER_TABLE
    , p4_a52 JTF_NUMBER_TABLE
    , p4_a53 JTF_NUMBER_TABLE
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_VARCHAR2_TABLE_200
    , p4_a67 JTF_VARCHAR2_TABLE_200
    , p4_a68 JTF_VARCHAR2_TABLE_200
    , p4_a69 JTF_VARCHAR2_TABLE_200
    , p4_a70 JTF_VARCHAR2_TABLE_200
    , p4_a71 JTF_NUMBER_TABLE
    , p4_a72 JTF_DATE_TABLE
    , p4_a73 JTF_VARCHAR2_TABLE_4000
    , p4_a74 JTF_NUMBER_TABLE
    , p4_a75 JTF_DATE_TABLE
    , p4_a76 JTF_DATE_TABLE
    , p4_a77 JTF_VARCHAR2_TABLE_100
    , p4_a78 JTF_VARCHAR2_TABLE_100
    , p4_a79 JTF_VARCHAR2_TABLE_100
    , p4_a80 JTF_NUMBER_TABLE
    , p4_a81 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  )

  as
    ddp_task_table jtf_tasks_pub.task_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    jtf_tasks_pub_w.rosetta_table_copy_in_p31(ddp_task_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      , p4_a71
      , p4_a72
      , p4_a73
      , p4_a74
      , p4_a75
      , p4_a76
      , p4_a77
      , p4_a78
      , p4_a79
      , p4_a80
      , p4_a81
      );





    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.export_file(p_api_version,
      p_init_msg_list,
      p_validate_level,
      p_file_name,
      ddp_task_table,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_task_from_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_template_group_id  NUMBER
    , p_task_template_group_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p_assigned_by_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_customer_id  NUMBER
    , p_address_id  NUMBER
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_timezone_id  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_reason_code  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_location_id  NUMBER
  )

  as
    ddx_task_details_tbl jtf_tasks_pub.task_details_tbl;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);

    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);





































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.create_task_from_template(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_template_group_id,
      p_task_template_group_name,
      p_owner_type_code,
      p_owner_id,
      p_source_object_id,
      p_source_object_name,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_task_details_tbl,
      p_assigned_by_id,
      p_cust_account_id,
      p_customer_id,
      p_address_id,
      ddp_actual_start_date,
      ddp_actual_end_date,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_parent_task_id,
      p_percentage_complete,
      p_timezone_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_reason_code,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_owner_territory_id,
      p_costs,
      p_currency_code,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    jtf_tasks_pub_w.rosetta_table_copy_out_p53(ddx_task_details_tbl, p12_a0
      , p12_a1
      );














































  end;

  procedure create_task_from_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_template_group_id  NUMBER
    , p_task_template_group_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p_assigned_by_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_customer_id  NUMBER
    , p_address_id  NUMBER
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_timezone_id  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_reason_code  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
  )

  as
    ddx_task_details_tbl jtf_tasks_pub.task_details_tbl;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);

    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);




































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pub.create_task_from_template(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_template_group_id,
      p_task_template_group_name,
      p_owner_type_code,
      p_owner_id,
      p_source_object_id,
      p_source_object_name,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_task_details_tbl,
      p_assigned_by_id,
      p_cust_account_id,
      p_customer_id,
      p_address_id,
      ddp_actual_start_date,
      ddp_actual_end_date,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_parent_task_id,
      p_percentage_complete,
      p_timezone_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_reason_code,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_owner_territory_id,
      p_costs,
      p_currency_code,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    jtf_tasks_pub_w.rosetta_table_copy_out_p53(ddx_task_details_tbl, p12_a0
      , p12_a1
      );













































  end;

end jtf_tasks_pub_w;

/
