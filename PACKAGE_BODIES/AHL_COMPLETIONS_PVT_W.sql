--------------------------------------------------------
--  DDL for Package Body AHL_COMPLETIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_COMPLETIONS_PVT_W" as
  /* $Header: AHLWPRCB.pls 120.1 2005/07/04 10:48 rroy noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_completions_pvt.workorder_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).workorder_name := a2(indx);
          t(ddindx).master_workorder_flag := a3(indx);
          t(ddindx).wip_entity_id := a4(indx);
          t(ddindx).organization_id := a5(indx);
          t(ddindx).plan_id := a6(indx);
          t(ddindx).collection_id := a7(indx);
          t(ddindx).scheduled_start_date := a8(indx);
          t(ddindx).scheduled_end_date := a9(indx);
          t(ddindx).actual_start_date := a10(indx);
          t(ddindx).actual_end_date := a11(indx);
          t(ddindx).status_code := a12(indx);
          t(ddindx).status := a13(indx);
          t(ddindx).route_id := a14(indx);
          t(ddindx).unit_effectivity_id := a15(indx);
          t(ddindx).ue_object_version_number := a16(indx);
          t(ddindx).automatic_signoff_flag := a17(indx);
          t(ddindx).item_instance_id := a18(indx);
          t(ddindx).completion_subinventory := a19(indx);
          t(ddindx).completion_locator_id := a20(indx);
          t(ddindx).lot_number := a21(indx);
          t(ddindx).serial_number := a22(indx);
          t(ddindx).txn_quantity := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_completions_pvt.workorder_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).workorder_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).workorder_name;
          a3(indx) := t(ddindx).master_workorder_flag;
          a4(indx) := t(ddindx).wip_entity_id;
          a5(indx) := t(ddindx).organization_id;
          a6(indx) := t(ddindx).plan_id;
          a7(indx) := t(ddindx).collection_id;
          a8(indx) := t(ddindx).scheduled_start_date;
          a9(indx) := t(ddindx).scheduled_end_date;
          a10(indx) := t(ddindx).actual_start_date;
          a11(indx) := t(ddindx).actual_end_date;
          a12(indx) := t(ddindx).status_code;
          a13(indx) := t(ddindx).status;
          a14(indx) := t(ddindx).route_id;
          a15(indx) := t(ddindx).unit_effectivity_id;
          a16(indx) := t(ddindx).ue_object_version_number;
          a17(indx) := t(ddindx).automatic_signoff_flag;
          a18(indx) := t(ddindx).item_instance_id;
          a19(indx) := t(ddindx).completion_subinventory;
          a20(indx) := t(ddindx).completion_locator_id;
          a21(indx) := t(ddindx).lot_number;
          a22(indx) := t(ddindx).serial_number;
          a23(indx) := t(ddindx).txn_quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_completions_pvt.operation_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_operation_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).workorder_id := a2(indx);
          t(ddindx).workorder_name := a3(indx);
          t(ddindx).wip_entity_id := a4(indx);
          t(ddindx).operation_sequence_num := a5(indx);
          t(ddindx).organization_id := a6(indx);
          t(ddindx).description := a7(indx);
          t(ddindx).plan_id := a8(indx);
          t(ddindx).collection_id := a9(indx);
          t(ddindx).scheduled_start_date := a10(indx);
          t(ddindx).scheduled_end_date := a11(indx);
          t(ddindx).actual_start_date := a12(indx);
          t(ddindx).actual_end_date := a13(indx);
          t(ddindx).status_code := a14(indx);
          t(ddindx).status := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_completions_pvt.operation_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_operation_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).workorder_id;
          a3(indx) := t(ddindx).workorder_name;
          a4(indx) := t(ddindx).wip_entity_id;
          a5(indx) := t(ddindx).operation_sequence_num;
          a6(indx) := t(ddindx).organization_id;
          a7(indx) := t(ddindx).description;
          a8(indx) := t(ddindx).plan_id;
          a9(indx) := t(ddindx).collection_id;
          a10(indx) := t(ddindx).scheduled_start_date;
          a11(indx) := t(ddindx).scheduled_end_date;
          a12(indx) := t(ddindx).actual_start_date;
          a13(indx) := t(ddindx).actual_end_date;
          a14(indx) := t(ddindx).status_code;
          a15(indx) := t(ddindx).status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_completions_pvt.mr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).unit_effectivity_id := a0(indx);
          t(ddindx).ue_object_version_no := a1(indx);
          t(ddindx).ue_status := a2(indx);
          t(ddindx).ue_status_code := a3(indx);
          t(ddindx).mr_header_id := a4(indx);
          t(ddindx).incident_id := a5(indx);
          t(ddindx).mr_title := a6(indx);
          t(ddindx).qa_inspection_type := a7(indx);
          t(ddindx).qa_plan_id := a8(indx);
          t(ddindx).qa_collection_id := a9(indx);
          t(ddindx).item_instance_id := a10(indx);
          t(ddindx).actual_end_date := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ahl_completions_pvt.mr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).unit_effectivity_id;
          a1(indx) := t(ddindx).ue_object_version_no;
          a2(indx) := t(ddindx).ue_status;
          a3(indx) := t(ddindx).ue_status_code;
          a4(indx) := t(ddindx).mr_header_id;
          a5(indx) := t(ddindx).incident_id;
          a6(indx) := t(ddindx).mr_title;
          a7(indx) := t(ddindx).qa_inspection_type;
          a8(indx) := t(ddindx).qa_plan_id;
          a9(indx) := t(ddindx).qa_collection_id;
          a10(indx) := t(ddindx).item_instance_id;
          a11(indx) := t(ddindx).actual_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy ahl_completions_pvt.counter_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_instance_id := a0(indx);
          t(ddindx).counter_id := a1(indx);
          t(ddindx).counter_group_id := a2(indx);
          t(ddindx).counter_value_id := a3(indx);
          t(ddindx).counter_reading := a4(indx);
          t(ddindx).prev_net_curr_diff := a5(indx);
          t(ddindx).counter_type := a6(indx);
          t(ddindx).reset_value := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t ahl_completions_pvt.counter_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_instance_id;
          a1(indx) := t(ddindx).counter_id;
          a2(indx) := t(ddindx).counter_group_id;
          a3(indx) := t(ddindx).counter_value_id;
          a4(indx) := t(ddindx).counter_reading;
          a5(indx) := t(ddindx).prev_net_curr_diff;
          a6(indx) := t(ddindx).counter_type;
          a7(indx) := t(ddindx).reset_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy ahl_completions_pvt.route_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t ahl_completions_pvt.route_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p18(t out nocopy ahl_completions_pvt.resource_req_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_id := a0(indx);
          t(ddindx).workorder_name := a1(indx);
          t(ddindx).operation_seq_num := a2(indx);
          t(ddindx).resource_seq_num := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).department_id := a5(indx);
          t(ddindx).resource_id := a6(indx);
          t(ddindx).resource_type := a7(indx);
          t(ddindx).uom_code := a8(indx);
          t(ddindx).usage_rate_or_amount := a9(indx);
          t(ddindx).transaction_quantity := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t ahl_completions_pvt.resource_req_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wip_entity_id;
          a1(indx) := t(ddindx).workorder_name;
          a2(indx) := t(ddindx).operation_seq_num;
          a3(indx) := t(ddindx).resource_seq_num;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).department_id;
          a6(indx) := t(ddindx).resource_id;
          a7(indx) := t(ddindx).resource_type;
          a8(indx) := t(ddindx).uom_code;
          a9(indx) := t(ddindx).usage_rate_or_amount;
          a10(indx) := t(ddindx).transaction_quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure complete_mr_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  DATE
  )

  as
    ddp_x_mr_rec ahl_completions_pvt.mr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_mr_rec.unit_effectivity_id := p9_a0;
    ddp_x_mr_rec.ue_object_version_no := p9_a1;
    ddp_x_mr_rec.ue_status := p9_a2;
    ddp_x_mr_rec.ue_status_code := p9_a3;
    ddp_x_mr_rec.mr_header_id := p9_a4;
    ddp_x_mr_rec.incident_id := p9_a5;
    ddp_x_mr_rec.mr_title := p9_a6;
    ddp_x_mr_rec.qa_inspection_type := p9_a7;
    ddp_x_mr_rec.qa_plan_id := p9_a8;
    ddp_x_mr_rec.qa_collection_id := p9_a9;
    ddp_x_mr_rec.item_instance_id := p9_a10;
    ddp_x_mr_rec.actual_end_date := p9_a11;

    -- here's the delegated call to the old PL/SQL routine
    ahl_completions_pvt.complete_mr_instance(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_mr_rec.unit_effectivity_id;
    p9_a1 := ddp_x_mr_rec.ue_object_version_no;
    p9_a2 := ddp_x_mr_rec.ue_status;
    p9_a3 := ddp_x_mr_rec.ue_status_code;
    p9_a4 := ddp_x_mr_rec.mr_header_id;
    p9_a5 := ddp_x_mr_rec.incident_id;
    p9_a6 := ddp_x_mr_rec.mr_title;
    p9_a7 := ddp_x_mr_rec.qa_inspection_type;
    p9_a8 := ddp_x_mr_rec.qa_plan_id;
    p9_a9 := ddp_x_mr_rec.qa_collection_id;
    p9_a10 := ddp_x_mr_rec.item_instance_id;
    p9_a11 := ddp_x_mr_rec.actual_end_date;
  end;

  procedure signoff_mr_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  DATE
    , p9_a6  DATE
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
  )

  as
    ddp_signoff_mr_rec ahl_completions_pvt.signoff_mr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_signoff_mr_rec.unit_effectivity_id := p9_a0;
    ddp_signoff_mr_rec.object_version_number := p9_a1;
    ddp_signoff_mr_rec.signoff_child_mrs_flag := p9_a2;
    ddp_signoff_mr_rec.complete_job_ops_flag := p9_a3;
    ddp_signoff_mr_rec.default_actual_dates_flag := p9_a4;
    ddp_signoff_mr_rec.actual_start_date := p9_a5;
    ddp_signoff_mr_rec.actual_end_date := p9_a6;
    ddp_signoff_mr_rec.transact_resource_flag := p9_a7;
    ddp_signoff_mr_rec.employee_number := p9_a8;
    ddp_signoff_mr_rec.serial_number := p9_a9;

    -- here's the delegated call to the old PL/SQL routine
    ahl_completions_pvt.signoff_mr_instance(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_signoff_mr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure close_visit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  DATE
    , p9_a6  DATE
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
  )

  as
    ddp_close_visit_rec ahl_completions_pvt.close_visit_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_close_visit_rec.visit_id := p9_a0;
    ddp_close_visit_rec.object_version_number := p9_a1;
    ddp_close_visit_rec.signoff_mrs_flag := p9_a2;
    ddp_close_visit_rec.complete_job_ops_flag := p9_a3;
    ddp_close_visit_rec.default_actual_dates_flag := p9_a4;
    ddp_close_visit_rec.actual_start_date := p9_a5;
    ddp_close_visit_rec.actual_end_date := p9_a6;
    ddp_close_visit_rec.transact_resource_flag := p9_a7;
    ddp_close_visit_rec.employee_number := p9_a8;
    ddp_close_visit_rec.serial_number := p9_a9;

    -- here's the delegated call to the old PL/SQL routine
    ahl_completions_pvt.close_visit(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_close_visit_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure get_default_op_actual_dates(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_DATE_TABLE
    , p3_a11 in out nocopy JTF_DATE_TABLE
    , p3_a12 in out nocopy JTF_DATE_TABLE
    , p3_a13 in out nocopy JTF_DATE_TABLE
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_operation_tbl ahl_completions_pvt.operation_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ahl_completions_pvt_w.rosetta_table_copy_in_p3(ddp_x_operation_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_completions_pvt.get_default_op_actual_dates(x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_operation_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    ahl_completions_pvt_w.rosetta_table_copy_out_p3(ddp_x_operation_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      );
  end;

  procedure get_op_actual_dates(x_return_status out nocopy  VARCHAR2
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p1_a5 in out nocopy JTF_NUMBER_TABLE
    , p1_a6 in out nocopy JTF_NUMBER_TABLE
    , p1_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a8 in out nocopy JTF_NUMBER_TABLE
    , p1_a9 in out nocopy JTF_NUMBER_TABLE
    , p1_a10 in out nocopy JTF_DATE_TABLE
    , p1_a11 in out nocopy JTF_DATE_TABLE
    , p1_a12 in out nocopy JTF_DATE_TABLE
    , p1_a13 in out nocopy JTF_DATE_TABLE
    , p1_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a15 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_operation_tbl ahl_completions_pvt.operation_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ahl_completions_pvt_w.rosetta_table_copy_in_p3(ddp_x_operation_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_completions_pvt.get_op_actual_dates(x_return_status,
      ddp_x_operation_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    ahl_completions_pvt_w.rosetta_table_copy_out_p3(ddp_x_operation_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      );
  end;

end ahl_completions_pvt_w;

/
