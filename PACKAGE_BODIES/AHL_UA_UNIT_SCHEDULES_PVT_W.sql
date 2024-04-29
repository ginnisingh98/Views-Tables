--------------------------------------------------------
--  DDL for Package Body AHL_UA_UNIT_SCHEDULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UA_UNIT_SCHEDULES_PVT_W" as
  /* $Header: AHLWUUSB.pls 120.1 2006/05/02 04:36 amsriniv noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_ua_unit_schedules_pvt.unit_schedules_result_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).result_row_num := a0(indx);
          t(ddindx).result_col_num := a1(indx);
          t(ddindx).unit_config_header_id := a2(indx);
          t(ddindx).unit_name := a3(indx);
          t(ddindx).schedule_id := a4(indx);
          t(ddindx).schedule_type := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_ua_unit_schedules_pvt.unit_schedules_result_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).result_row_num;
          a1(indx) := t(ddindx).result_col_num;
          a2(indx) := t(ddindx).unit_config_header_id;
          a3(indx) := t(ddindx).unit_name;
          a4(indx) := t(ddindx).schedule_id;
          a5(indx) := t(ddindx).schedule_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_ua_unit_schedules_pvt.unit_schedule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).event_seq := a0(indx);
          t(ddindx).unit_schedule_id := a1(indx);
          t(ddindx).flight_number := a2(indx);
          t(ddindx).segment := a3(indx);
          t(ddindx).departure_org_id := a4(indx);
          t(ddindx).departure_org_name := a5(indx);
          t(ddindx).departure_dep_id := a6(indx);
          t(ddindx).departure_dep_name := a7(indx);
          t(ddindx).arrival_org_id := a8(indx);
          t(ddindx).arrival_org_name := a9(indx);
          t(ddindx).arrival_dep_id := a10(indx);
          t(ddindx).arrival_dep_name := a11(indx);
          t(ddindx).departure_time := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).arrival_time := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).prev_event_type := a14(indx);
          t(ddindx).prev_event_id := a15(indx);
          t(ddindx).prev_event_org_id := a16(indx);
          t(ddindx).is_prev_org_valid := a17(indx);
          t(ddindx).prev_event_org_name := a18(indx);
          t(ddindx).prev_event_dep_id := a19(indx);
          t(ddindx).prve_event_dep_name := a20(indx);
          t(ddindx).prev_event_end_time := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).prev_unit_schedule_id := a22(indx);
          t(ddindx).prev_flight_number := a23(indx);
          t(ddindx).has_mopportunity := a24(indx);
          t(ddindx).has_conflict := a25(indx);
          t(ddindx).conflict_message := a26(indx);
          t(ddindx).is_org_valid := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_ua_unit_schedules_pvt.unit_schedule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_2000();
    a27 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).event_seq;
          a1(indx) := t(ddindx).unit_schedule_id;
          a2(indx) := t(ddindx).flight_number;
          a3(indx) := t(ddindx).segment;
          a4(indx) := t(ddindx).departure_org_id;
          a5(indx) := t(ddindx).departure_org_name;
          a6(indx) := t(ddindx).departure_dep_id;
          a7(indx) := t(ddindx).departure_dep_name;
          a8(indx) := t(ddindx).arrival_org_id;
          a9(indx) := t(ddindx).arrival_org_name;
          a10(indx) := t(ddindx).arrival_dep_id;
          a11(indx) := t(ddindx).arrival_dep_name;
          a12(indx) := t(ddindx).departure_time;
          a13(indx) := t(ddindx).arrival_time;
          a14(indx) := t(ddindx).prev_event_type;
          a15(indx) := t(ddindx).prev_event_id;
          a16(indx) := t(ddindx).prev_event_org_id;
          a17(indx) := t(ddindx).is_prev_org_valid;
          a18(indx) := t(ddindx).prev_event_org_name;
          a19(indx) := t(ddindx).prev_event_dep_id;
          a20(indx) := t(ddindx).prve_event_dep_name;
          a21(indx) := t(ddindx).prev_event_end_time;
          a22(indx) := t(ddindx).prev_unit_schedule_id;
          a23(indx) := t(ddindx).prev_flight_number;
          a24(indx) := t(ddindx).has_mopportunity;
          a25(indx) := t(ddindx).has_conflict;
          a26(indx) := t(ddindx).conflict_message;
          a27(indx) := t(ddindx).is_org_valid;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy ahl_ua_unit_schedules_pvt.visit_schedule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).event_seq := a0(indx);
          t(ddindx).visit_id := a1(indx);
          t(ddindx).visit_number := a2(indx);
          t(ddindx).visit_type := a3(indx);
          t(ddindx).visit_name := a4(indx);
          t(ddindx).visit_status_code := a5(indx);
          t(ddindx).visit_status := a6(indx);
          t(ddindx).visit_org_id := a7(indx);
          t(ddindx).visit_org_name := a8(indx);
          t(ddindx).visit_dep_id := a9(indx);
          t(ddindx).visit_dep_name := a10(indx);
          t(ddindx).start_time := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).end_time := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).prev_event_type := a13(indx);
          t(ddindx).prev_event_id := a14(indx);
          t(ddindx).prev_event_org_id := a15(indx);
          t(ddindx).is_prev_org_valid := a16(indx);
          t(ddindx).prev_event_org_name := a17(indx);
          t(ddindx).prev_event_dep_id := a18(indx);
          t(ddindx).prve_event_dep_name := a19(indx);
          t(ddindx).prev_event_end_time := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).prev_unit_schedule_id := a21(indx);
          t(ddindx).prev_flight_number := a22(indx);
          t(ddindx).has_mopportunity := a23(indx);
          t(ddindx).has_conflict := a24(indx);
          t(ddindx).conflict_message := a25(indx);
          t(ddindx).can_cancel := a26(indx);
          t(ddindx).is_org_valid := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ahl_ua_unit_schedules_pvt.visit_schedule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_2000();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_2000();
      a26 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).event_seq;
          a1(indx) := t(ddindx).visit_id;
          a2(indx) := t(ddindx).visit_number;
          a3(indx) := t(ddindx).visit_type;
          a4(indx) := t(ddindx).visit_name;
          a5(indx) := t(ddindx).visit_status_code;
          a6(indx) := t(ddindx).visit_status;
          a7(indx) := t(ddindx).visit_org_id;
          a8(indx) := t(ddindx).visit_org_name;
          a9(indx) := t(ddindx).visit_dep_id;
          a10(indx) := t(ddindx).visit_dep_name;
          a11(indx) := t(ddindx).start_time;
          a12(indx) := t(ddindx).end_time;
          a13(indx) := t(ddindx).prev_event_type;
          a14(indx) := t(ddindx).prev_event_id;
          a15(indx) := t(ddindx).prev_event_org_id;
          a16(indx) := t(ddindx).is_prev_org_valid;
          a17(indx) := t(ddindx).prev_event_org_name;
          a18(indx) := t(ddindx).prev_event_dep_id;
          a19(indx) := t(ddindx).prve_event_dep_name;
          a20(indx) := t(ddindx).prev_event_end_time;
          a21(indx) := t(ddindx).prev_unit_schedule_id;
          a22(indx) := t(ddindx).prev_flight_number;
          a23(indx) := t(ddindx).has_mopportunity;
          a24(indx) := t(ddindx).has_conflict;
          a25(indx) := t(ddindx).conflict_message;
          a26(indx) := t(ddindx).can_cancel;
          a27(indx) := t(ddindx).is_org_valid;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure search_unit_schedules(p_api_version  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_unit_schedules_search ahl_ua_unit_schedules_pvt.unit_schedules_search_rec_type;
    ddx_unit_schedules_results ahl_ua_unit_schedules_pvt.unit_schedules_result_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_unit_schedules_search.unit_name := p4_a0;
    ddp_unit_schedules_search.item_number := p4_a1;
    ddp_unit_schedules_search.serial_number := p4_a2;
    ddp_unit_schedules_search.start_date_time := rosetta_g_miss_date_in_map(p4_a3);
    ddp_unit_schedules_search.time_increment := p4_a4;
    ddp_unit_schedules_search.time_uom := p4_a5;


    -- here's the delegated call to the old PL/SQL routine
    ahl_ua_unit_schedules_pvt.search_unit_schedules(p_api_version,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_unit_schedules_search,
      ddx_unit_schedules_results);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_ua_unit_schedules_pvt_w.rosetta_table_copy_out_p3(ddx_unit_schedules_results, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      );
  end;

  procedure get_mevent_details(p_api_version  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_DATE_TABLE
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_NUMBER_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a20 out nocopy JTF_DATE_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_mevent_header_rec ahl_ua_unit_schedules_pvt.mevent_header_rec_type;
    ddx_unit_schedule_tbl ahl_ua_unit_schedules_pvt.unit_schedule_tbl_type;
    ddx_visit_schedule_tbl ahl_ua_unit_schedules_pvt.visit_schedule_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_mevent_header_rec.unit_config_header_id := p5_a0;
    ddp_x_mevent_header_rec.unit_name := p5_a1;
    ddp_x_mevent_header_rec.start_time := rosetta_g_miss_date_in_map(p5_a2);
    ddp_x_mevent_header_rec.end_time := rosetta_g_miss_date_in_map(p5_a3);
    ddp_x_mevent_header_rec.item_number := p5_a4;
    ddp_x_mevent_header_rec.serial_number := p5_a5;
    ddp_x_mevent_header_rec.event_count := p5_a6;
    ddp_x_mevent_header_rec.has_conflict := p5_a7;
    ddp_x_mevent_header_rec.has_mopportunity := p5_a8;



    -- here's the delegated call to the old PL/SQL routine
    ahl_ua_unit_schedules_pvt.get_mevent_details(p_api_version,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mevent_header_rec,
      ddx_unit_schedule_tbl,
      ddx_visit_schedule_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_mevent_header_rec.unit_config_header_id;
    p5_a1 := ddp_x_mevent_header_rec.unit_name;
    p5_a2 := ddp_x_mevent_header_rec.start_time;
    p5_a3 := ddp_x_mevent_header_rec.end_time;
    p5_a4 := ddp_x_mevent_header_rec.item_number;
    p5_a5 := ddp_x_mevent_header_rec.serial_number;
    p5_a6 := ddp_x_mevent_header_rec.event_count;
    p5_a7 := ddp_x_mevent_header_rec.has_conflict;
    p5_a8 := ddp_x_mevent_header_rec.has_mopportunity;

    ahl_ua_unit_schedules_pvt_w.rosetta_table_copy_out_p6(ddx_unit_schedule_tbl, p6_a0
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
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      );

    ahl_ua_unit_schedules_pvt_w.rosetta_table_copy_out_p8(ddx_visit_schedule_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      );
  end;

  procedure get_prec_succ_event_info(p_api_version  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_unit_config_id  NUMBER
    , p_start_date_time  date
    , p_end_date_time  date
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  NUMBER
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  DATE
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , x_is_prec_conflict out nocopy  VARCHAR2
    , x_is_prec_org_in_ou out nocopy  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  VARCHAR2
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  DATE
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  DATE
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  DATE
    , p11_a21 out nocopy  NUMBER
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  DATE
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  VARCHAR2
    , p11_a28 out nocopy  VARCHAR2
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  NUMBER
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  NUMBER
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  NUMBER
    , p11_a36 out nocopy  NUMBER
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  NUMBER
    , p11_a44 out nocopy  NUMBER
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  NUMBER
    , p11_a47 out nocopy  VARCHAR2
    , p11_a48 out nocopy  VARCHAR2
    , p11_a49 out nocopy  VARCHAR2
    , p11_a50 out nocopy  VARCHAR2
    , p11_a51 out nocopy  VARCHAR2
    , p11_a52 out nocopy  VARCHAR2
    , p11_a53 out nocopy  VARCHAR2
    , p11_a54 out nocopy  VARCHAR2
    , p11_a55 out nocopy  VARCHAR2
    , p11_a56 out nocopy  VARCHAR2
    , p11_a57 out nocopy  VARCHAR2
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  VARCHAR2
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  VARCHAR2
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  VARCHAR2
    , p11_a66 out nocopy  VARCHAR2
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  VARCHAR2
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  NUMBER
    , p11_a71 out nocopy  VARCHAR2
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  NUMBER
    , p11_a74 out nocopy  VARCHAR2
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  VARCHAR2
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  DATE
    , p12_a4 out nocopy  DATE
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  VARCHAR2
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  DATE
    , p12_a10 out nocopy  DATE
    , p12_a11 out nocopy  NUMBER
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  NUMBER
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  NUMBER
    , p12_a16 out nocopy  NUMBER
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  NUMBER
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  VARCHAR2
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  NUMBER
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  VARCHAR2
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  VARCHAR2
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  VARCHAR2
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  VARCHAR2
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  VARCHAR2
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , x_is_succ_conflict out nocopy  VARCHAR2
    , x_is_succ_org_in_ou out nocopy  VARCHAR2
  )

  as
    ddp_start_date_time date;
    ddp_end_date_time date;
    ddx_prec_visit ahl_vwp_visits_pvt.visit_rec_type;
    ddx_prec_flight_schedule ahl_ua_flight_schedules_pvt.flight_schedule_rec_type;
    ddx_succ_visit ahl_vwp_visits_pvt.visit_rec_type;
    ddx_succ_flight_schedule ahl_ua_flight_schedules_pvt.flight_schedule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_start_date_time := rosetta_g_miss_date_in_map(p_start_date_time);

    ddp_end_date_time := rosetta_g_miss_date_in_map(p_end_date_time);









    -- here's the delegated call to the old PL/SQL routine
    ahl_ua_unit_schedules_pvt.get_prec_succ_event_info(p_api_version,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_unit_config_id,
      ddp_start_date_time,
      ddp_end_date_time,
      ddx_prec_visit,
      ddx_prec_flight_schedule,
      x_is_prec_conflict,
      x_is_prec_org_in_ou,
      ddx_succ_visit,
      ddx_succ_flight_schedule,
      x_is_succ_conflict,
      x_is_succ_org_in_ou);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_prec_visit.visit_id;
    p7_a1 := ddx_prec_visit.visit_name;
    p7_a2 := ddx_prec_visit.visit_number;
    p7_a3 := ddx_prec_visit.object_version_number;
    p7_a4 := ddx_prec_visit.last_update_date;
    p7_a5 := ddx_prec_visit.last_updated_by;
    p7_a6 := ddx_prec_visit.creation_date;
    p7_a7 := ddx_prec_visit.created_by;
    p7_a8 := ddx_prec_visit.last_update_login;
    p7_a9 := ddx_prec_visit.organization_id;
    p7_a10 := ddx_prec_visit.org_name;
    p7_a11 := ddx_prec_visit.department_id;
    p7_a12 := ddx_prec_visit.dept_name;
    p7_a13 := ddx_prec_visit.service_request_id;
    p7_a14 := ddx_prec_visit.service_request_number;
    p7_a15 := ddx_prec_visit.space_category_code;
    p7_a16 := ddx_prec_visit.space_category_name;
    p7_a17 := ddx_prec_visit.start_date;
    p7_a18 := ddx_prec_visit.start_hour;
    p7_a19 := ddx_prec_visit.start_min;
    p7_a20 := ddx_prec_visit.plan_end_date;
    p7_a21 := ddx_prec_visit.plan_end_hour;
    p7_a22 := ddx_prec_visit.plan_end_min;
    p7_a23 := ddx_prec_visit.end_date;
    p7_a24 := ddx_prec_visit.due_by_date;
    p7_a25 := ddx_prec_visit.visit_type_code;
    p7_a26 := ddx_prec_visit.visit_type_name;
    p7_a27 := ddx_prec_visit.status_code;
    p7_a28 := ddx_prec_visit.status_name;
    p7_a29 := ddx_prec_visit.simulation_plan_id;
    p7_a30 := ddx_prec_visit.simulation_plan_name;
    p7_a31 := ddx_prec_visit.asso_primary_visit_id;
    p7_a32 := ddx_prec_visit.unit_name;
    p7_a33 := ddx_prec_visit.item_instance_id;
    p7_a34 := ddx_prec_visit.serial_number;
    p7_a35 := ddx_prec_visit.inventory_item_id;
    p7_a36 := ddx_prec_visit.item_organization_id;
    p7_a37 := ddx_prec_visit.item_name;
    p7_a38 := ddx_prec_visit.simulation_delete_flag;
    p7_a39 := ddx_prec_visit.template_flag;
    p7_a40 := ddx_prec_visit.out_of_sync_flag;
    p7_a41 := ddx_prec_visit.project_flag;
    p7_a42 := ddx_prec_visit.project_flag_code;
    p7_a43 := ddx_prec_visit.project_id;
    p7_a44 := ddx_prec_visit.project_number;
    p7_a45 := ddx_prec_visit.description;
    p7_a46 := ddx_prec_visit.duration;
    p7_a47 := ddx_prec_visit.attribute_category;
    p7_a48 := ddx_prec_visit.attribute1;
    p7_a49 := ddx_prec_visit.attribute2;
    p7_a50 := ddx_prec_visit.attribute3;
    p7_a51 := ddx_prec_visit.attribute4;
    p7_a52 := ddx_prec_visit.attribute5;
    p7_a53 := ddx_prec_visit.attribute6;
    p7_a54 := ddx_prec_visit.attribute7;
    p7_a55 := ddx_prec_visit.attribute8;
    p7_a56 := ddx_prec_visit.attribute9;
    p7_a57 := ddx_prec_visit.attribute10;
    p7_a58 := ddx_prec_visit.attribute11;
    p7_a59 := ddx_prec_visit.attribute12;
    p7_a60 := ddx_prec_visit.attribute13;
    p7_a61 := ddx_prec_visit.attribute14;
    p7_a62 := ddx_prec_visit.attribute15;
    p7_a63 := ddx_prec_visit.operation_flag;
    p7_a64 := ddx_prec_visit.outside_party_flag;
    p7_a65 := ddx_prec_visit.job_number;
    p7_a66 := ddx_prec_visit.proj_template_name;
    p7_a67 := ddx_prec_visit.proj_template_id;
    p7_a68 := ddx_prec_visit.priority_value;
    p7_a69 := ddx_prec_visit.priority_code;
    p7_a70 := ddx_prec_visit.unit_schedule_id;
    p7_a71 := ddx_prec_visit.visit_create_type;
    p7_a72 := ddx_prec_visit.visit_create_meaning;
    p7_a73 := ddx_prec_visit.unit_header_id;
    p7_a74 := ddx_prec_visit.flight_number;

    p8_a0 := ddx_prec_flight_schedule.unit_schedule_id;
    p8_a1 := ddx_prec_flight_schedule.flight_number;
    p8_a2 := ddx_prec_flight_schedule.segment;
    p8_a3 := ddx_prec_flight_schedule.est_departure_time;
    p8_a4 := ddx_prec_flight_schedule.actual_departure_time;
    p8_a5 := ddx_prec_flight_schedule.departure_dept_id;
    p8_a6 := ddx_prec_flight_schedule.departure_dept_code;
    p8_a7 := ddx_prec_flight_schedule.departure_org_id;
    p8_a8 := ddx_prec_flight_schedule.departure_org_code;
    p8_a9 := ddx_prec_flight_schedule.est_arrival_time;
    p8_a10 := ddx_prec_flight_schedule.actual_arrival_time;
    p8_a11 := ddx_prec_flight_schedule.arrival_dept_id;
    p8_a12 := ddx_prec_flight_schedule.arrival_dept_code;
    p8_a13 := ddx_prec_flight_schedule.arrival_org_id;
    p8_a14 := ddx_prec_flight_schedule.arrival_org_code;
    p8_a15 := ddx_prec_flight_schedule.preceding_us_id;
    p8_a16 := ddx_prec_flight_schedule.unit_config_header_id;
    p8_a17 := ddx_prec_flight_schedule.unit_config_name;
    p8_a18 := ddx_prec_flight_schedule.csi_instance_id;
    p8_a19 := ddx_prec_flight_schedule.instance_number;
    p8_a20 := ddx_prec_flight_schedule.item_number;
    p8_a21 := ddx_prec_flight_schedule.serial_number;
    p8_a22 := ddx_prec_flight_schedule.visit_reschedule_mode;
    p8_a23 := ddx_prec_flight_schedule.visit_reschedule_meaning;
    p8_a24 := ddx_prec_flight_schedule.object_version_number;
    p8_a25 := ddx_prec_flight_schedule.is_update_allowed;
    p8_a26 := ddx_prec_flight_schedule.is_delete_allowed;
    p8_a27 := ddx_prec_flight_schedule.conflict_message;
    p8_a28 := ddx_prec_flight_schedule.attribute_category;
    p8_a29 := ddx_prec_flight_schedule.attribute1;
    p8_a30 := ddx_prec_flight_schedule.attribute2;
    p8_a31 := ddx_prec_flight_schedule.attribute3;
    p8_a32 := ddx_prec_flight_schedule.attribute4;
    p8_a33 := ddx_prec_flight_schedule.attribute5;
    p8_a34 := ddx_prec_flight_schedule.attribute6;
    p8_a35 := ddx_prec_flight_schedule.attribute7;
    p8_a36 := ddx_prec_flight_schedule.attribute8;
    p8_a37 := ddx_prec_flight_schedule.attribute9;
    p8_a38 := ddx_prec_flight_schedule.attribute10;
    p8_a39 := ddx_prec_flight_schedule.attribute11;
    p8_a40 := ddx_prec_flight_schedule.attribute12;
    p8_a41 := ddx_prec_flight_schedule.attribute13;
    p8_a42 := ddx_prec_flight_schedule.attribute14;
    p8_a43 := ddx_prec_flight_schedule.attribute15;
    p8_a44 := ddx_prec_flight_schedule.dml_operation;



    p11_a0 := ddx_succ_visit.visit_id;
    p11_a1 := ddx_succ_visit.visit_name;
    p11_a2 := ddx_succ_visit.visit_number;
    p11_a3 := ddx_succ_visit.object_version_number;
    p11_a4 := ddx_succ_visit.last_update_date;
    p11_a5 := ddx_succ_visit.last_updated_by;
    p11_a6 := ddx_succ_visit.creation_date;
    p11_a7 := ddx_succ_visit.created_by;
    p11_a8 := ddx_succ_visit.last_update_login;
    p11_a9 := ddx_succ_visit.organization_id;
    p11_a10 := ddx_succ_visit.org_name;
    p11_a11 := ddx_succ_visit.department_id;
    p11_a12 := ddx_succ_visit.dept_name;
    p11_a13 := ddx_succ_visit.service_request_id;
    p11_a14 := ddx_succ_visit.service_request_number;
    p11_a15 := ddx_succ_visit.space_category_code;
    p11_a16 := ddx_succ_visit.space_category_name;
    p11_a17 := ddx_succ_visit.start_date;
    p11_a18 := ddx_succ_visit.start_hour;
    p11_a19 := ddx_succ_visit.start_min;
    p11_a20 := ddx_succ_visit.plan_end_date;
    p11_a21 := ddx_succ_visit.plan_end_hour;
    p11_a22 := ddx_succ_visit.plan_end_min;
    p11_a23 := ddx_succ_visit.end_date;
    p11_a24 := ddx_succ_visit.due_by_date;
    p11_a25 := ddx_succ_visit.visit_type_code;
    p11_a26 := ddx_succ_visit.visit_type_name;
    p11_a27 := ddx_succ_visit.status_code;
    p11_a28 := ddx_succ_visit.status_name;
    p11_a29 := ddx_succ_visit.simulation_plan_id;
    p11_a30 := ddx_succ_visit.simulation_plan_name;
    p11_a31 := ddx_succ_visit.asso_primary_visit_id;
    p11_a32 := ddx_succ_visit.unit_name;
    p11_a33 := ddx_succ_visit.item_instance_id;
    p11_a34 := ddx_succ_visit.serial_number;
    p11_a35 := ddx_succ_visit.inventory_item_id;
    p11_a36 := ddx_succ_visit.item_organization_id;
    p11_a37 := ddx_succ_visit.item_name;
    p11_a38 := ddx_succ_visit.simulation_delete_flag;
    p11_a39 := ddx_succ_visit.template_flag;
    p11_a40 := ddx_succ_visit.out_of_sync_flag;
    p11_a41 := ddx_succ_visit.project_flag;
    p11_a42 := ddx_succ_visit.project_flag_code;
    p11_a43 := ddx_succ_visit.project_id;
    p11_a44 := ddx_succ_visit.project_number;
    p11_a45 := ddx_succ_visit.description;
    p11_a46 := ddx_succ_visit.duration;
    p11_a47 := ddx_succ_visit.attribute_category;
    p11_a48 := ddx_succ_visit.attribute1;
    p11_a49 := ddx_succ_visit.attribute2;
    p11_a50 := ddx_succ_visit.attribute3;
    p11_a51 := ddx_succ_visit.attribute4;
    p11_a52 := ddx_succ_visit.attribute5;
    p11_a53 := ddx_succ_visit.attribute6;
    p11_a54 := ddx_succ_visit.attribute7;
    p11_a55 := ddx_succ_visit.attribute8;
    p11_a56 := ddx_succ_visit.attribute9;
    p11_a57 := ddx_succ_visit.attribute10;
    p11_a58 := ddx_succ_visit.attribute11;
    p11_a59 := ddx_succ_visit.attribute12;
    p11_a60 := ddx_succ_visit.attribute13;
    p11_a61 := ddx_succ_visit.attribute14;
    p11_a62 := ddx_succ_visit.attribute15;
    p11_a63 := ddx_succ_visit.operation_flag;
    p11_a64 := ddx_succ_visit.outside_party_flag;
    p11_a65 := ddx_succ_visit.job_number;
    p11_a66 := ddx_succ_visit.proj_template_name;
    p11_a67 := ddx_succ_visit.proj_template_id;
    p11_a68 := ddx_succ_visit.priority_value;
    p11_a69 := ddx_succ_visit.priority_code;
    p11_a70 := ddx_succ_visit.unit_schedule_id;
    p11_a71 := ddx_succ_visit.visit_create_type;
    p11_a72 := ddx_succ_visit.visit_create_meaning;
    p11_a73 := ddx_succ_visit.unit_header_id;
    p11_a74 := ddx_succ_visit.flight_number;

    p12_a0 := ddx_succ_flight_schedule.unit_schedule_id;
    p12_a1 := ddx_succ_flight_schedule.flight_number;
    p12_a2 := ddx_succ_flight_schedule.segment;
    p12_a3 := ddx_succ_flight_schedule.est_departure_time;
    p12_a4 := ddx_succ_flight_schedule.actual_departure_time;
    p12_a5 := ddx_succ_flight_schedule.departure_dept_id;
    p12_a6 := ddx_succ_flight_schedule.departure_dept_code;
    p12_a7 := ddx_succ_flight_schedule.departure_org_id;
    p12_a8 := ddx_succ_flight_schedule.departure_org_code;
    p12_a9 := ddx_succ_flight_schedule.est_arrival_time;
    p12_a10 := ddx_succ_flight_schedule.actual_arrival_time;
    p12_a11 := ddx_succ_flight_schedule.arrival_dept_id;
    p12_a12 := ddx_succ_flight_schedule.arrival_dept_code;
    p12_a13 := ddx_succ_flight_schedule.arrival_org_id;
    p12_a14 := ddx_succ_flight_schedule.arrival_org_code;
    p12_a15 := ddx_succ_flight_schedule.preceding_us_id;
    p12_a16 := ddx_succ_flight_schedule.unit_config_header_id;
    p12_a17 := ddx_succ_flight_schedule.unit_config_name;
    p12_a18 := ddx_succ_flight_schedule.csi_instance_id;
    p12_a19 := ddx_succ_flight_schedule.instance_number;
    p12_a20 := ddx_succ_flight_schedule.item_number;
    p12_a21 := ddx_succ_flight_schedule.serial_number;
    p12_a22 := ddx_succ_flight_schedule.visit_reschedule_mode;
    p12_a23 := ddx_succ_flight_schedule.visit_reschedule_meaning;
    p12_a24 := ddx_succ_flight_schedule.object_version_number;
    p12_a25 := ddx_succ_flight_schedule.is_update_allowed;
    p12_a26 := ddx_succ_flight_schedule.is_delete_allowed;
    p12_a27 := ddx_succ_flight_schedule.conflict_message;
    p12_a28 := ddx_succ_flight_schedule.attribute_category;
    p12_a29 := ddx_succ_flight_schedule.attribute1;
    p12_a30 := ddx_succ_flight_schedule.attribute2;
    p12_a31 := ddx_succ_flight_schedule.attribute3;
    p12_a32 := ddx_succ_flight_schedule.attribute4;
    p12_a33 := ddx_succ_flight_schedule.attribute5;
    p12_a34 := ddx_succ_flight_schedule.attribute6;
    p12_a35 := ddx_succ_flight_schedule.attribute7;
    p12_a36 := ddx_succ_flight_schedule.attribute8;
    p12_a37 := ddx_succ_flight_schedule.attribute9;
    p12_a38 := ddx_succ_flight_schedule.attribute10;
    p12_a39 := ddx_succ_flight_schedule.attribute11;
    p12_a40 := ddx_succ_flight_schedule.attribute12;
    p12_a41 := ddx_succ_flight_schedule.attribute13;
    p12_a42 := ddx_succ_flight_schedule.attribute14;
    p12_a43 := ddx_succ_flight_schedule.attribute15;
    p12_a44 := ddx_succ_flight_schedule.dml_operation;


  end;

end ahl_ua_unit_schedules_pvt_w;

/
