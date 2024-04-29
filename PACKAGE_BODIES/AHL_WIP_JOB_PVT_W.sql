--------------------------------------------------------
--  DDL for Package Body AHL_WIP_JOB_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_WIP_JOB_PVT_W" as
  /* $Header: AHLWWIPB.pls 120.1 2006/05/03 00:45 bachandr noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_wip_job_pvt.ahl_wo_op_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).organization_id := a0(indx);
          t(ddindx).operation_seq_num := a1(indx);
          t(ddindx).department_id := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).minimum_transfer_quantity := a4(indx);
          t(ddindx).count_point_type := a5(indx);
          t(ddindx).backflush_flag := a6(indx);
          t(ddindx).scheduled_start := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).scheduled_end := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).dml_type := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_wip_job_pvt.ahl_wo_op_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).organization_id;
          a1(indx) := t(ddindx).operation_seq_num;
          a2(indx) := t(ddindx).department_id;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).minimum_transfer_quantity;
          a5(indx) := t(ddindx).count_point_type;
          a6(indx) := t(ddindx).backflush_flag;
          a7(indx) := t(ddindx).scheduled_start;
          a8(indx) := t(ddindx).scheduled_end;
          a9(indx) := t(ddindx).dml_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_wip_job_pvt.ahl_wo_res_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_seq_num := a0(indx);
          t(ddindx).resource_seq_num := a1(indx);
          t(ddindx).organization_id := a2(indx);
          t(ddindx).department_id := a3(indx);
          t(ddindx).scheduled_sequence := a4(indx);
          t(ddindx).resource_id_old := a5(indx);
          t(ddindx).resource_id_new := a6(indx);
          t(ddindx).uom := a7(indx);
          t(ddindx).cost_basis := a8(indx);
          t(ddindx).quantity := a9(indx);
          t(ddindx).assigned_units := a10(indx);
          t(ddindx).scheduled_flag := a11(indx);
          t(ddindx).activity_id := a12(indx);
          t(ddindx).autocharge_type := a13(indx);
          t(ddindx).standard_rate_flag := a14(indx);
          t(ddindx).applied_resource_units := a15(indx);
          t(ddindx).applied_resource_value := a16(indx);
          t(ddindx).description := a17(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).setup_id := a20(indx);
          t(ddindx).dml_type := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_wip_job_pvt.ahl_wo_res_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).operation_seq_num;
          a1(indx) := t(ddindx).resource_seq_num;
          a2(indx) := t(ddindx).organization_id;
          a3(indx) := t(ddindx).department_id;
          a4(indx) := t(ddindx).scheduled_sequence;
          a5(indx) := t(ddindx).resource_id_old;
          a6(indx) := t(ddindx).resource_id_new;
          a7(indx) := t(ddindx).uom;
          a8(indx) := t(ddindx).cost_basis;
          a9(indx) := t(ddindx).quantity;
          a10(indx) := t(ddindx).assigned_units;
          a11(indx) := t(ddindx).scheduled_flag;
          a12(indx) := t(ddindx).activity_id;
          a13(indx) := t(ddindx).autocharge_type;
          a14(indx) := t(ddindx).standard_rate_flag;
          a15(indx) := t(ddindx).applied_resource_units;
          a16(indx) := t(ddindx).applied_resource_value;
          a17(indx) := t(ddindx).description;
          a18(indx) := t(ddindx).start_date;
          a19(indx) := t(ddindx).end_date;
          a20(indx) := t(ddindx).setup_id;
          a21(indx) := t(ddindx).dml_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_wip_job_pvt.ahl_wo_mtl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_seq_num := a0(indx);
          t(ddindx).inventory_item_id_old := a1(indx);
          t(ddindx).inventory_item_id_new := a2(indx);
          t(ddindx).organization_id := a3(indx);
          t(ddindx).mrp_net := a4(indx);
          t(ddindx).quantity_per_assembly := a5(indx);
          t(ddindx).required_quantity := a6(indx);
          t(ddindx).supply_type := a7(indx);
          t(ddindx).supply_locator_id := a8(indx);
          t(ddindx).supply_subinventory := a9(indx);
          t(ddindx).date_required := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).dml_type := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_wip_job_pvt.ahl_wo_mtl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).operation_seq_num;
          a1(indx) := t(ddindx).inventory_item_id_old;
          a2(indx) := t(ddindx).inventory_item_id_new;
          a3(indx) := t(ddindx).organization_id;
          a4(indx) := t(ddindx).mrp_net;
          a5(indx) := t(ddindx).quantity_per_assembly;
          a6(indx) := t(ddindx).required_quantity;
          a7(indx) := t(ddindx).supply_type;
          a8(indx) := t(ddindx).supply_locator_id;
          a9(indx) := t(ddindx).supply_subinventory;
          a10(indx) := t(ddindx).date_required;
          a11(indx) := t(ddindx).dml_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy ahl_wip_job_pvt.ahl_res_txn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_id := a0(indx);
          t(ddindx).operation_seq_num := a1(indx);
          t(ddindx).resource_seq_num := a2(indx);
          t(ddindx).resource_id := a3(indx);
          t(ddindx).transaction_type := a4(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).transaction_quantity := a6(indx);
          t(ddindx).transaction_uom := a7(indx);
          t(ddindx).department_id := a8(indx);
          t(ddindx).employee_id := a9(indx);
          t(ddindx).activity_id := a10(indx);
          t(ddindx).activity_meaning := a11(indx);
          t(ddindx).reason_id := a12(indx);
          t(ddindx).reason := a13(indx);
          t(ddindx).serial_number := a14(indx);
          t(ddindx).reference := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ahl_wip_job_pvt.ahl_res_txn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).wip_entity_id;
          a1(indx) := t(ddindx).operation_seq_num;
          a2(indx) := t(ddindx).resource_seq_num;
          a3(indx) := t(ddindx).resource_id;
          a4(indx) := t(ddindx).transaction_type;
          a5(indx) := t(ddindx).transaction_date;
          a6(indx) := t(ddindx).transaction_quantity;
          a7(indx) := t(ddindx).transaction_uom;
          a8(indx) := t(ddindx).department_id;
          a9(indx) := t(ddindx).employee_id;
          a10(indx) := t(ddindx).activity_id;
          a11(indx) := t(ddindx).activity_meaning;
          a12(indx) := t(ddindx).reason_id;
          a13(indx) := t(ddindx).reason;
          a14(indx) := t(ddindx).serial_number;
          a15(indx) := t(ddindx).reference;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy ahl_wip_job_pvt.ahl_wip_job_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_32767
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_id := a0(indx);
          t(ddindx).wip_entity_name := a1(indx);
          t(ddindx).organization_id := a2(indx);
          t(ddindx).error := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t ahl_wip_job_pvt.ahl_wip_job_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_32767
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_32767();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_32767();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wip_entity_id;
          a1(indx) := t(ddindx).wip_entity_name;
          a2(indx) := t(ddindx).organization_id;
          a3(indx) := t(ddindx).error;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure load_wip_job(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  NUMBER
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_300
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_VARCHAR2_TABLE_300
    , p8_a18 JTF_DATE_TABLE
    , p8_a19 JTF_DATE_TABLE
    , p8_a20 JTF_NUMBER_TABLE
    , p8_a21 JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , x_wip_entity_id out nocopy  NUMBER
  )

  as
    ddp_ahl_wo_rec ahl_wip_job_pvt.ahl_wo_rec_type;
    ddp_ahl_wo_op_tbl ahl_wip_job_pvt.ahl_wo_op_tbl_type;
    ddp_ahl_wo_res_tbl ahl_wip_job_pvt.ahl_wo_res_tbl_type;
    ddp_ahl_wo_mtl_tbl ahl_wip_job_pvt.ahl_wo_mtl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_ahl_wo_rec.wo_name := p6_a0;
    ddp_ahl_wo_rec.organization_id := p6_a1;
    ddp_ahl_wo_rec.status := p6_a2;
    ddp_ahl_wo_rec.scheduled_start := rosetta_g_miss_date_in_map(p6_a3);
    ddp_ahl_wo_rec.scheduled_end := rosetta_g_miss_date_in_map(p6_a4);
    ddp_ahl_wo_rec.inventory_item_id := p6_a5;
    ddp_ahl_wo_rec.item_instance_id := p6_a6;
    ddp_ahl_wo_rec.completion_subinventory := p6_a7;
    ddp_ahl_wo_rec.completion_locator_id := p6_a8;
    ddp_ahl_wo_rec.wip_supply_type := p6_a9;
    ddp_ahl_wo_rec.firm_planned_flag := p6_a10;
    ddp_ahl_wo_rec.project_id := p6_a11;
    ddp_ahl_wo_rec.prj_task_id := p6_a12;
    ddp_ahl_wo_rec.quantity := p6_a13;
    ddp_ahl_wo_rec.mrp_quantity := p6_a14;
    ddp_ahl_wo_rec.class_code := p6_a15;
    ddp_ahl_wo_rec.priority := p6_a16;
    ddp_ahl_wo_rec.department_id := p6_a17;
    ddp_ahl_wo_rec.allow_explosion := p6_a18;
    ddp_ahl_wo_rec.manual_rebuild_flag := p6_a19;
    ddp_ahl_wo_rec.rebuild_serial_number := p6_a20;
    ddp_ahl_wo_rec.scheduling_method := p6_a21;
    ddp_ahl_wo_rec.description := p6_a22;
    ddp_ahl_wo_rec.dml_type := p6_a23;

    ahl_wip_job_pvt_w.rosetta_table_copy_in_p2(ddp_ahl_wo_op_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );

    ahl_wip_job_pvt_w.rosetta_table_copy_in_p4(ddp_ahl_wo_res_tbl, p8_a0
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
      );

    ahl_wip_job_pvt_w.rosetta_table_copy_in_p6(ddp_ahl_wo_mtl_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      );


    -- here's the delegated call to the old PL/SQL routine
    ahl_wip_job_pvt.load_wip_job(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ahl_wo_rec,
      ddp_ahl_wo_op_tbl,
      ddp_ahl_wo_res_tbl,
      ddp_ahl_wo_mtl_tbl,
      x_wip_entity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure insert_resource_txn(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_ahl_res_txn_tbl ahl_wip_job_pvt.ahl_res_txn_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ahl_wip_job_pvt_w.rosetta_table_copy_in_p8(ddp_ahl_res_txn_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_wip_job_pvt.insert_resource_txn(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ahl_res_txn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure wip_massload_pending(p_wip_entity_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ahl_wip_job_pvt.wip_massload_pending(p_wip_entity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure load_wip_batch_jobs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_group_id  NUMBER
    , p_header_id  NUMBER
    , p_submit_flag  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  NUMBER
    , p9_a2  NUMBER
    , p9_a3  DATE
    , p9_a4  DATE
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  VARCHAR2
    , p9_a8  NUMBER
    , p9_a9  NUMBER
    , p9_a10  NUMBER
    , p9_a11  NUMBER
    , p9_a12  NUMBER
    , p9_a13  NUMBER
    , p9_a14  NUMBER
    , p9_a15  VARCHAR2
    , p9_a16  NUMBER
    , p9_a17  NUMBER
    , p9_a18  VARCHAR2
    , p9_a19  VARCHAR2
    , p9_a20  VARCHAR2
    , p9_a21  NUMBER
    , p9_a22  VARCHAR2
    , p9_a23  VARCHAR2
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_300
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_DATE_TABLE
    , p10_a8 JTF_DATE_TABLE
    , p10_a9 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_VARCHAR2_TABLE_100
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_NUMBER_TABLE
    , p11_a13 JTF_NUMBER_TABLE
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_300
    , p11_a18 JTF_DATE_TABLE
    , p11_a19 JTF_DATE_TABLE
    , p11_a20 JTF_NUMBER_TABLE
    , p11_a21 JTF_VARCHAR2_TABLE_100
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_NUMBER_TABLE
    , p12_a5 JTF_NUMBER_TABLE
    , p12_a6 JTF_NUMBER_TABLE
    , p12_a7 JTF_NUMBER_TABLE
    , p12_a8 JTF_NUMBER_TABLE
    , p12_a9 JTF_VARCHAR2_TABLE_100
    , p12_a10 JTF_DATE_TABLE
    , p12_a11 JTF_VARCHAR2_TABLE_100
    , x_group_id out nocopy  NUMBER
    , x_header_id out nocopy  NUMBER
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_32767
  )

  as
    ddp_ahl_wo_rec ahl_wip_job_pvt.ahl_wo_rec_type;
    ddp_ahl_wo_op_tbl ahl_wip_job_pvt.ahl_wo_op_tbl_type;
    ddp_ahl_wo_res_tbl ahl_wip_job_pvt.ahl_wo_res_tbl_type;
    ddp_ahl_wo_mtl_tbl ahl_wip_job_pvt.ahl_wo_mtl_tbl_type;
    ddx_ahl_wip_job_tbl ahl_wip_job_pvt.ahl_wip_job_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_ahl_wo_rec.wo_name := p9_a0;
    ddp_ahl_wo_rec.organization_id := p9_a1;
    ddp_ahl_wo_rec.status := p9_a2;
    ddp_ahl_wo_rec.scheduled_start := rosetta_g_miss_date_in_map(p9_a3);
    ddp_ahl_wo_rec.scheduled_end := rosetta_g_miss_date_in_map(p9_a4);
    ddp_ahl_wo_rec.inventory_item_id := p9_a5;
    ddp_ahl_wo_rec.item_instance_id := p9_a6;
    ddp_ahl_wo_rec.completion_subinventory := p9_a7;
    ddp_ahl_wo_rec.completion_locator_id := p9_a8;
    ddp_ahl_wo_rec.wip_supply_type := p9_a9;
    ddp_ahl_wo_rec.firm_planned_flag := p9_a10;
    ddp_ahl_wo_rec.project_id := p9_a11;
    ddp_ahl_wo_rec.prj_task_id := p9_a12;
    ddp_ahl_wo_rec.quantity := p9_a13;
    ddp_ahl_wo_rec.mrp_quantity := p9_a14;
    ddp_ahl_wo_rec.class_code := p9_a15;
    ddp_ahl_wo_rec.priority := p9_a16;
    ddp_ahl_wo_rec.department_id := p9_a17;
    ddp_ahl_wo_rec.allow_explosion := p9_a18;
    ddp_ahl_wo_rec.manual_rebuild_flag := p9_a19;
    ddp_ahl_wo_rec.rebuild_serial_number := p9_a20;
    ddp_ahl_wo_rec.scheduling_method := p9_a21;
    ddp_ahl_wo_rec.description := p9_a22;
    ddp_ahl_wo_rec.dml_type := p9_a23;

    ahl_wip_job_pvt_w.rosetta_table_copy_in_p2(ddp_ahl_wo_op_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      );

    ahl_wip_job_pvt_w.rosetta_table_copy_in_p4(ddp_ahl_wo_res_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      );

    ahl_wip_job_pvt_w.rosetta_table_copy_in_p6(ddp_ahl_wo_mtl_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_wip_job_pvt.load_wip_batch_jobs(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_group_id,
      p_header_id,
      p_submit_flag,
      ddp_ahl_wo_rec,
      ddp_ahl_wo_op_tbl,
      ddp_ahl_wo_res_tbl,
      ddp_ahl_wo_mtl_tbl,
      x_group_id,
      x_header_id,
      ddx_ahl_wip_job_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    ahl_wip_job_pvt_w.rosetta_table_copy_out_p10(ddx_ahl_wip_job_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      );
  end;

end ahl_wip_job_pvt_w;

/
