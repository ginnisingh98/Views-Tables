--------------------------------------------------------
--  DDL for Package Body AHL_LTP_MATRL_AVAL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_MATRL_AVAL_PUB_W" as
  /* $Header: AHLWMTAB.pls 120.2 2008/02/25 11:36:54 rnahata ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_ltp_matrl_aval_pub.material_availability_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).schedule_material_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).item := a3(indx);
          t(ddindx).mr_route_id := a4(indx);
          t(ddindx).visit_id := a5(indx);
          t(ddindx).visit_task_id := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).task_name := a8(indx);
          t(ddindx).task_status_code := a9(indx);
          t(ddindx).task_status_meaning := a10(indx);
          t(ddindx).req_arrival_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).quantity_available := a12(indx);
          t(ddindx).quantity := a13(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).uom := a15(indx);
          t(ddindx).error_code := a16(indx);
          t(ddindx).error_message := a17(indx);
          t(ddindx).plan_name := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_ltp_matrl_aval_pub.material_availability_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).schedule_material_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).item;
          a4(indx) := t(ddindx).mr_route_id;
          a5(indx) := t(ddindx).visit_id;
          a6(indx) := t(ddindx).visit_task_id;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).task_name;
          a9(indx) := t(ddindx).task_status_code;
          a10(indx) := t(ddindx).task_status_meaning;
          a11(indx) := t(ddindx).req_arrival_date;
          a12(indx) := t(ddindx).quantity_available;
          a13(indx) := t(ddindx).quantity;
          a14(indx) := t(ddindx).scheduled_date;
          a15(indx) := t(ddindx).uom;
          a16(indx) := t(ddindx).error_code;
          a17(indx) := t(ddindx).error_message;
          a18(indx) := t(ddindx).plan_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_ltp_matrl_aval_pub.task_req_matrl_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).schedule_material_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).visit_task_id := a2(indx);
          t(ddindx).task_name := a3(indx);
          t(ddindx).task_status_code := a4(indx);
          t(ddindx).task_status_meaning := a5(indx);
          t(ddindx).mr_route_id := a6(indx);
          t(ddindx).inventory_item_id := a7(indx);
          t(ddindx).item_group_id := a8(indx);
          t(ddindx).item := a9(indx);
          t(ddindx).req_arrival_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).uom_code := a11(indx);
          t(ddindx).quantity_available := a12(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).planned_order := a14(indx);
          t(ddindx).quantity := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_ltp_matrl_aval_pub.task_req_matrl_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).schedule_material_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).visit_task_id;
          a3(indx) := t(ddindx).task_name;
          a4(indx) := t(ddindx).task_status_code;
          a5(indx) := t(ddindx).task_status_meaning;
          a6(indx) := t(ddindx).mr_route_id;
          a7(indx) := t(ddindx).inventory_item_id;
          a8(indx) := t(ddindx).item_group_id;
          a9(indx) := t(ddindx).item;
          a10(indx) := t(ddindx).req_arrival_date;
          a11(indx) := t(ddindx).uom_code;
          a12(indx) := t(ddindx).quantity_available;
          a13(indx) := t(ddindx).scheduled_date;
          a14(indx) := t(ddindx).planned_order;
          a15(indx) := t(ddindx).quantity;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_ltp_matrl_aval_pub.planned_matrl_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).schedule_material_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).item_description := a3(indx);
          t(ddindx).visit_id := a4(indx);
          t(ddindx).visit_task_id := a5(indx);
          t(ddindx).organization_id := a6(indx);
          t(ddindx).planned_order := a7(indx);
          t(ddindx).task_name := a8(indx);
          t(ddindx).task_status_code := a9(indx);
          t(ddindx).task_status_meaning := a10(indx);
          t(ddindx).requested_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).required_quantity := a12(indx);
          t(ddindx).quantity_available := a13(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).primary_uom_code := a15(indx);
          t(ddindx).primary_uom := a16(indx);
          t(ddindx).mat_status := a17(indx);
          t(ddindx).error_code := a18(indx);
          t(ddindx).error_message := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_ltp_matrl_aval_pub.planned_matrl_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).schedule_material_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).item_description;
          a4(indx) := t(ddindx).visit_id;
          a5(indx) := t(ddindx).visit_task_id;
          a6(indx) := t(ddindx).organization_id;
          a7(indx) := t(ddindx).planned_order;
          a8(indx) := t(ddindx).task_name;
          a9(indx) := t(ddindx).task_status_code;
          a10(indx) := t(ddindx).task_status_meaning;
          a11(indx) := t(ddindx).requested_date;
          a12(indx) := t(ddindx).required_quantity;
          a13(indx) := t(ddindx).quantity_available;
          a14(indx) := t(ddindx).scheduled_date;
          a15(indx) := t(ddindx).primary_uom_code;
          a16(indx) := t(ddindx).primary_uom;
          a17(indx) := t(ddindx).mat_status;
          a18(indx) := t(ddindx).error_code;
          a19(indx) := t(ddindx).error_message;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure check_material_aval(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 in out nocopy JTF_DATE_TABLE
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_DATE_TABLE
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_material_avl_tbl ahl_ltp_matrl_aval_pub.material_availability_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_in_p3(ddp_x_material_avl_tbl, p5_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_matrl_aval_pub.check_material_aval(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_material_avl_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_out_p3(ddp_x_material_avl_tbl, p5_a0
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
      );



  end;

  procedure get_visit_task_materials(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_task_req_matrl_tbl ahl_ltp_matrl_aval_pub.task_req_matrl_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_matrl_aval_pub.get_visit_task_materials(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddx_task_req_matrl_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_out_p4(ddx_task_req_matrl_tbl, p6_a0
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
      );



  end;

  procedure check_materials_for_all(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_task_matrl_aval_tbl ahl_ltp_matrl_aval_pub.material_availability_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_matrl_aval_pub.check_materials_for_all(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddx_task_matrl_aval_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_out_p3(ddx_task_matrl_aval_tbl, p6_a0
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
      );



  end;

  procedure schedule_planned_matrls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 in out nocopy JTF_DATE_TABLE
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_DATE_TABLE
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_planned_matrl_tbl ahl_ltp_matrl_aval_pub.planned_matrl_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_in_p5(ddp_x_planned_matrl_tbl, p5_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_matrl_aval_pub.schedule_planned_matrls(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_planned_matrl_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_out_p5(ddp_x_planned_matrl_tbl, p5_a0
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
      );



  end;

  procedure schedule_all_materials(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_planned_matrl_tbl ahl_ltp_matrl_aval_pub.planned_matrl_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_matrl_aval_pub.schedule_all_materials(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddx_planned_matrl_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_matrl_aval_pub_w.rosetta_table_copy_out_p5(ddx_planned_matrl_tbl, p6_a0
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
      );



  end;

end ahl_ltp_matrl_aval_pub_w;

/
