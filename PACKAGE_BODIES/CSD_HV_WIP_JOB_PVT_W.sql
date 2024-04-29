--------------------------------------------------------
--  DDL for Package Body CSD_HV_WIP_JOB_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_HV_WIP_JOB_PVT_W" as
  /* $Header: csdwhvjb.pls 120.9.12010000.3 2010/06/07 19:59:48 swai ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy csd_hv_wip_job_pvt.mv_txn_dtls_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_name := a0(indx);
          t(ddindx).organization_id := a1(indx);
          t(ddindx).fm_operation_seq_num := a2(indx);
          t(ddindx).to_operation_seq_num := a3(indx);
          t(ddindx).transaction_quantity := a4(indx);
          t(ddindx).transaction_uom := a5(indx);
          t(ddindx).wip_entity_id := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t csd_hv_wip_job_pvt.mv_txn_dtls_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).wip_entity_name;
          a1(indx) := t(ddindx).organization_id;
          a2(indx) := t(ddindx).fm_operation_seq_num;
          a3(indx) := t(ddindx).to_operation_seq_num;
          a4(indx) := t(ddindx).transaction_quantity;
          a5(indx) := t(ddindx).transaction_uom;
          a6(indx) := t(ddindx).wip_entity_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy csd_hv_wip_job_pvt.mtl_txn_dtls_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
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
          t(ddindx).wip_transaction_detail_id := a0(indx);
          t(ddindx).required_quantity := a1(indx);
          t(ddindx).issued_quantity := a2(indx);
          t(ddindx).job_quantity := a3(indx);
          t(ddindx).op_scheduled_quantity := a4(indx);
          t(ddindx).inventory_item_id := a5(indx);
          t(ddindx).wip_entity_id := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).operation_seq_num := a8(indx);
          t(ddindx).transaction_quantity := a9(indx);
          t(ddindx).transaction_uom := a10(indx);
          t(ddindx).uom_code := a11(indx);
          t(ddindx).serial_number := a12(indx);
          t(ddindx).lot_number := a13(indx);
          t(ddindx).revision := a14(indx);
          t(ddindx).revision_qty_control_code := a15(indx);
          t(ddindx).serial_number_control_code := a16(indx);
          t(ddindx).lot_control_code := a17(indx);
          t(ddindx).supply_subinventory := a18(indx);
          t(ddindx).supply_locator_id := a19(indx);
          t(ddindx).transaction_interface_id := a20(indx);
          t(ddindx).object_version_number := a21(indx);
          t(ddindx).new_row := a22(indx);
          t(ddindx).reason_id := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t csd_hv_wip_job_pvt.mtl_txn_dtls_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
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
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).wip_transaction_detail_id;
          a1(indx) := t(ddindx).required_quantity;
          a2(indx) := t(ddindx).issued_quantity;
          a3(indx) := t(ddindx).job_quantity;
          a4(indx) := t(ddindx).op_scheduled_quantity;
          a5(indx) := t(ddindx).inventory_item_id;
          a6(indx) := t(ddindx).wip_entity_id;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).operation_seq_num;
          a9(indx) := t(ddindx).transaction_quantity;
          a10(indx) := t(ddindx).transaction_uom;
          a11(indx) := t(ddindx).uom_code;
          a12(indx) := t(ddindx).serial_number;
          a13(indx) := t(ddindx).lot_number;
          a14(indx) := t(ddindx).revision;
          a15(indx) := t(ddindx).revision_qty_control_code;
          a16(indx) := t(ddindx).serial_number_control_code;
          a17(indx) := t(ddindx).lot_control_code;
          a18(indx) := t(ddindx).supply_subinventory;
          a19(indx) := t(ddindx).supply_locator_id;
          a20(indx) := t(ddindx).transaction_interface_id;
          a21(indx) := t(ddindx).object_version_number;
          a22(indx) := t(ddindx).new_row;
          a23(indx) := t(ddindx).reason_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy csd_hv_wip_job_pvt.res_txn_dtls_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_transaction_detail_id := a0(indx);
          t(ddindx).required_quantity := a1(indx);
          t(ddindx).applied_quantity := a2(indx);
          t(ddindx).pending_quantity := a3(indx);
          t(ddindx).job_quantity := a4(indx);
          t(ddindx).op_scheduled_quantity := a5(indx);
          t(ddindx).basis_type := a6(indx);
          t(ddindx).resource_id := a7(indx);
          t(ddindx).resource_seq_num := a8(indx);
          t(ddindx).wip_entity_id := a9(indx);
          t(ddindx).organization_id := a10(indx);
          t(ddindx).organization_code := a11(indx);
          t(ddindx).operation_seq_num := a12(indx);
          t(ddindx).transaction_quantity := a13(indx);
          t(ddindx).transaction_uom := a14(indx);
          t(ddindx).uom_code := a15(indx);
          t(ddindx).wip_entity_name := a16(indx);
          t(ddindx).employee_id := a17(indx);
          t(ddindx).employee_num := a18(indx);
          t(ddindx).object_version_number := a19(indx);
          t(ddindx).new_row := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t csd_hv_wip_job_pvt.res_txn_dtls_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
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
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wip_transaction_detail_id;
          a1(indx) := t(ddindx).required_quantity;
          a2(indx) := t(ddindx).applied_quantity;
          a3(indx) := t(ddindx).pending_quantity;
          a4(indx) := t(ddindx).job_quantity;
          a5(indx) := t(ddindx).op_scheduled_quantity;
          a6(indx) := t(ddindx).basis_type;
          a7(indx) := t(ddindx).resource_id;
          a8(indx) := t(ddindx).resource_seq_num;
          a9(indx) := t(ddindx).wip_entity_id;
          a10(indx) := t(ddindx).organization_id;
          a11(indx) := t(ddindx).organization_code;
          a12(indx) := t(ddindx).operation_seq_num;
          a13(indx) := t(ddindx).transaction_quantity;
          a14(indx) := t(ddindx).transaction_uom;
          a15(indx) := t(ddindx).uom_code;
          a16(indx) := t(ddindx).wip_entity_name;
          a17(indx) := t(ddindx).employee_id;
          a18(indx) := t(ddindx).employee_num;
          a19(indx) := t(ddindx).object_version_number;
          a20(indx) := t(ddindx).new_row;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy csd_hv_wip_job_pvt.op_dtls_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_transaction_detail_id := a0(indx);
          t(ddindx).backflush_flag := a1(indx);
          t(ddindx).count_point_type := a2(indx);
          t(ddindx).department_id := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).first_unit_completion_date := a5(indx);
          t(ddindx).first_unit_start_date := a6(indx);
          t(ddindx).last_unit_completion_date := a7(indx);
          t(ddindx).last_unit_start_date := a8(indx);
          t(ddindx).minimum_transfer_quantity := a9(indx);
          t(ddindx).operation_seq_num := a10(indx);
          t(ddindx).standard_operation_id := a11(indx);
          t(ddindx).wip_entity_id := a12(indx);
          t(ddindx).organization_id := a13(indx);
          t(ddindx).organization_code := a14(indx);
          t(ddindx).wip_entity_name := a15(indx);
          t(ddindx).object_version_number := a16(indx);
          t(ddindx).new_row := a17(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t csd_hv_wip_job_pvt.op_dtls_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).wip_transaction_detail_id;
          a1(indx) := t(ddindx).backflush_flag;
          a2(indx) := t(ddindx).count_point_type;
          a3(indx) := t(ddindx).department_id;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).first_unit_completion_date;
          a6(indx) := t(ddindx).first_unit_start_date;
          a7(indx) := t(ddindx).last_unit_completion_date;
          a8(indx) := t(ddindx).last_unit_start_date;
          a9(indx) := t(ddindx).minimum_transfer_quantity;
          a10(indx) := t(ddindx).operation_seq_num;
          a11(indx) := t(ddindx).standard_operation_id;
          a12(indx) := t(ddindx).wip_entity_id;
          a13(indx) := t(ddindx).organization_id;
          a14(indx) := t(ddindx).organization_code;
          a15(indx) := t(ddindx).wip_entity_name;
          a16(indx) := t(ddindx).object_version_number;
          a17(indx) := t(ddindx).new_row;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy csd_hv_wip_job_pvt.service_code_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ro_service_code_id := a0(indx);
          t(ddindx).inventory_item_id := a1(indx);
          t(ddindx).service_code_id := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t csd_hv_wip_job_pvt.service_code_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).ro_service_code_id;
          a1(indx) := t(ddindx).inventory_item_id;
          a2(indx) := t(ddindx).service_code_id;
          a3(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure process_oper_comp_txn(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_VARCHAR2_TABLE_300
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
  )

  as
    ddp_mv_txn_dtls_tbl csd_hv_wip_job_pvt.mv_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p3(ddp_mv_txn_dtls_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_oper_comp_txn(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mv_txn_dtls_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure process_job_comp_txn(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , x_transaction_header_id out nocopy  NUMBER
  )

  as
    ddp_comp_job_dtls_rec csd_hv_wip_job_pvt.job_dtls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_comp_job_dtls_rec.wip_entity_id := p7_a0;
    ddp_comp_job_dtls_rec.inventory_item_id := p7_a1;
    ddp_comp_job_dtls_rec.organization_id := p7_a2;
    ddp_comp_job_dtls_rec.transaction_quantity := p7_a3;
    ddp_comp_job_dtls_rec.completion_subinventory := p7_a4;
    ddp_comp_job_dtls_rec.completion_locator_id := p7_a5;
    ddp_comp_job_dtls_rec.transaction_uom := p7_a6;
    ddp_comp_job_dtls_rec.revision_qty_control_code := p7_a7;
    ddp_comp_job_dtls_rec.serial_number_control_code := p7_a8;
    ddp_comp_job_dtls_rec.lot_control_code := p7_a9;


    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_job_comp_txn(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_comp_job_dtls_rec,
      x_transaction_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure insert_job_comp_txn(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , x_need_details_flag out nocopy  VARCHAR2
    , x_transaction_header_id out nocopy  NUMBER
  )

  as
    ddp_comp_job_dtls_rec csd_hv_wip_job_pvt.job_dtls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_comp_job_dtls_rec.wip_entity_id := p7_a0;
    ddp_comp_job_dtls_rec.inventory_item_id := p7_a1;
    ddp_comp_job_dtls_rec.organization_id := p7_a2;
    ddp_comp_job_dtls_rec.transaction_quantity := p7_a3;
    ddp_comp_job_dtls_rec.completion_subinventory := p7_a4;
    ddp_comp_job_dtls_rec.completion_locator_id := p7_a5;
    ddp_comp_job_dtls_rec.transaction_uom := p7_a6;
    ddp_comp_job_dtls_rec.revision_qty_control_code := p7_a7;
    ddp_comp_job_dtls_rec.serial_number_control_code := p7_a8;
    ddp_comp_job_dtls_rec.lot_control_code := p7_a9;



    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.insert_job_comp_txn(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_comp_job_dtls_rec,
      x_need_details_flag,
      x_transaction_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure process_issue_mtl_txn(p_api_version_number  NUMBER
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
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_NUMBER_TABLE
    , x_transaction_header_id out nocopy  NUMBER
  )

  as
    ddp_mtl_txn_dtls_tbl csd_hv_wip_job_pvt.mtl_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p5(ddp_mtl_txn_dtls_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_issue_mtl_txn(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mtl_txn_dtls_tbl,
      x_transaction_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure process_issue_mtl_txns_lot_srl(p_api_version_number  NUMBER
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
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_NUMBER_TABLE
    , p_transaction_header_id  NUMBER
  )

  as
    ddp_mtl_txn_dtls_tbl csd_hv_wip_job_pvt.mtl_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p5(ddp_mtl_txn_dtls_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_issue_mtl_txns_lot_srl(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mtl_txn_dtls_tbl,
      p_transaction_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_mtl_txns_lot_srl(p_api_version_number  NUMBER
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
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_NUMBER_TABLE
    , p_transaction_header_id  NUMBER
  )

  as
    ddp_mtl_txn_dtls_tbl csd_hv_wip_job_pvt.mtl_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p5(ddp_mtl_txn_dtls_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.update_mtl_txns_lot_srl(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mtl_txn_dtls_tbl,
      p_transaction_header_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure process_transact_res_txn(p_api_version_number  NUMBER
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
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_100
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_res_txn_dtls_tbl csd_hv_wip_job_pvt.res_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p7(ddp_res_txn_dtls_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_transact_res_txn(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_txn_dtls_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure process_save_mtl_txn_dtls(p_api_version_number  NUMBER
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
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_NUMBER_TABLE
    , x_op_created out nocopy  VARCHAR
  )

  as
    ddp_mtl_txn_dtls_tbl csd_hv_wip_job_pvt.mtl_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p5(ddp_mtl_txn_dtls_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_save_mtl_txn_dtls(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mtl_txn_dtls_tbl,
      x_op_created);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure process_save_res_txn_dtls(p_api_version_number  NUMBER
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
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_100
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_res_txn_dtls_tbl csd_hv_wip_job_pvt.res_txn_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p7(ddp_res_txn_dtls_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_save_res_txn_dtls(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_txn_dtls_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure process_save_op_dtls(p_api_version_number  NUMBER
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
    , p7_a4 JTF_VARCHAR2_TABLE_300
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_op_dtls_tbl csd_hv_wip_job_pvt.op_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p9(ddp_op_dtls_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_save_op_dtls(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_op_dtls_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure generate_wip_jobs_from_scs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_repair_line_id  NUMBER
    , p_repair_quantity  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
  )

  as
    ddp_service_code_tbl csd_hv_wip_job_pvt.service_code_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    csd_hv_wip_job_pvt_w.rosetta_table_copy_in_p11(ddp_service_code_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      );

    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.generate_wip_jobs_from_scs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_repair_line_id,
      p_repair_quantity,
      ddp_service_code_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure process_delete_mtl_txn_dtl(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
  )

  as
    ddp_mtl_txn_dtls csd_hv_wip_job_pvt.mtl_txn_dtls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mtl_txn_dtls.wip_transaction_detail_id := p7_a0;
    ddp_mtl_txn_dtls.required_quantity := p7_a1;
    ddp_mtl_txn_dtls.issued_quantity := p7_a2;
    ddp_mtl_txn_dtls.job_quantity := p7_a3;
    ddp_mtl_txn_dtls.op_scheduled_quantity := p7_a4;
    ddp_mtl_txn_dtls.inventory_item_id := p7_a5;
    ddp_mtl_txn_dtls.wip_entity_id := p7_a6;
    ddp_mtl_txn_dtls.organization_id := p7_a7;
    ddp_mtl_txn_dtls.operation_seq_num := p7_a8;
    ddp_mtl_txn_dtls.transaction_quantity := p7_a9;
    ddp_mtl_txn_dtls.transaction_uom := p7_a10;
    ddp_mtl_txn_dtls.uom_code := p7_a11;
    ddp_mtl_txn_dtls.serial_number := p7_a12;
    ddp_mtl_txn_dtls.lot_number := p7_a13;
    ddp_mtl_txn_dtls.revision := p7_a14;
    ddp_mtl_txn_dtls.revision_qty_control_code := p7_a15;
    ddp_mtl_txn_dtls.serial_number_control_code := p7_a16;
    ddp_mtl_txn_dtls.lot_control_code := p7_a17;
    ddp_mtl_txn_dtls.supply_subinventory := p7_a18;
    ddp_mtl_txn_dtls.supply_locator_id := p7_a19;
    ddp_mtl_txn_dtls.transaction_interface_id := p7_a20;
    ddp_mtl_txn_dtls.object_version_number := p7_a21;
    ddp_mtl_txn_dtls.new_row := p7_a22;
    ddp_mtl_txn_dtls.reason_id := p7_a23;

    -- here's the delegated call to the old PL/SQL routine
    csd_hv_wip_job_pvt.process_delete_mtl_txn_dtl(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mtl_txn_dtls);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end csd_hv_wip_job_pvt_w;

/
