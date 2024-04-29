--------------------------------------------------------
--  DDL for Package Body CSE_DATASTRUCTURES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_DATASTRUCTURES_PUB_W" as
  /* $Header: CSEDATWB.pls 120.1 2008/01/16 21:31:52 devijay ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p24(t out nocopy cse_datastructures_pub.mtl_item_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).subinventory_code := a2(indx);
          t(ddindx).revision := a3(indx);
          t(ddindx).transaction_quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).transaction_uom := a5(indx);
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).transaction_action_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).transaction_source_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).transaction_source_type_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transfer_locator_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).transfer_organization_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).transfer_subinventory := a12(indx);
          t(ddindx).locator_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).source_project_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).source_task_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).from_project_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).from_task_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).to_project_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).to_task_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).serial_number := a22(indx);
          t(ddindx).lot_number := a23(indx);
          t(ddindx).hr_location_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).po_distribution_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).subinv_location_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).shipment_number := a27(indx);
          t(ddindx).trx_source_line_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).move_order_line_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).serial_number_control_code := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).ship_to_location_id := rosetta_g_miss_num_map(a31(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t cse_datastructures_pub.mtl_item_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a2(indx) := t(ddindx).subinventory_code;
          a3(indx) := t(ddindx).revision;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_quantity);
          a5(indx) := t(ddindx).transaction_uom;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_action_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_source_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_source_type_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).transfer_locator_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transfer_organization_id);
          a12(indx) := t(ddindx).transfer_subinventory;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).locator_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).source_project_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).source_task_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).from_project_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).from_task_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).to_project_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).to_task_id);
          a20(indx) := t(ddindx).transaction_date;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a22(indx) := t(ddindx).serial_number;
          a23(indx) := t(ddindx).lot_number;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).hr_location_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).po_distribution_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).subinv_location_id);
          a27(indx) := t(ddindx).shipment_number;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).trx_source_line_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).move_order_line_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).serial_number_control_code);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_location_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p26(t out nocopy cse_datastructures_pub.mtl_instance_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_number := a1(indx);
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).inventory_revision := a3(indx);
          t(ddindx).inv_master_organization_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).serial_number := a5(indx);
          t(ddindx).mfg_serial_number_flag := a6(indx);
          t(ddindx).lot_number := a7(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).unit_of_measure := a9(indx);
          t(ddindx).instance_status_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).customer_view_flag := a11(indx);
          t(ddindx).merchant_view_flag := a12(indx);
          t(ddindx).instance_type_code := a13(indx);
          t(ddindx).location_type_code := a14(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).inv_organization_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).inv_subinventory_name := a17(indx);
          t(ddindx).inv_locator_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).pa_project_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).pa_project_task_id := rosetta_g_miss_num_map(a20(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t cse_datastructures_pub.mtl_instance_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).instance_number;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a3(indx) := t(ddindx).inventory_revision;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).inv_master_organization_id);
          a5(indx) := t(ddindx).serial_number;
          a6(indx) := t(ddindx).mfg_serial_number_flag;
          a7(indx) := t(ddindx).lot_number;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a9(indx) := t(ddindx).unit_of_measure;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).instance_status_id);
          a11(indx) := t(ddindx).customer_view_flag;
          a12(indx) := t(ddindx).merchant_view_flag;
          a13(indx) := t(ddindx).instance_type_code;
          a14(indx) := t(ddindx).location_type_code;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).inv_organization_id);
          a17(indx) := t(ddindx).inv_subinventory_name;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).inv_locator_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_task_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p29(t out nocopy cse_datastructures_pub.proj_item_uninst_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).work_order_number := a7(indx);
          t(ddindx).project_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t cse_datastructures_pub.proj_item_uninst_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a7(indx) := t(ddindx).work_order_number;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a10(indx) := t(ddindx).transaction_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p31(t out nocopy cse_datastructures_pub.proj_item_inst_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).work_order_number := a7(indx);
          t(ddindx).project_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t cse_datastructures_pub.proj_item_inst_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a7(indx) := t(ddindx).work_order_number;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a10(indx) := t(ddindx).transaction_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p33(t out nocopy cse_datastructures_pub.out_of_service_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
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
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).work_order_number := a7(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t cse_datastructures_pub.out_of_service_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a7(indx) := t(ddindx).work_order_number;
          a8(indx) := t(ddindx).transaction_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p35(t out nocopy cse_datastructures_pub.in_service_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
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
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).work_order_number := a7(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t cse_datastructures_pub.in_service_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a7(indx) := t(ddindx).work_order_number;
          a8(indx) := t(ddindx).transaction_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure rosetta_table_copy_in_p37(t out nocopy cse_datastructures_pub.item_move_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).from_network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).to_network_location_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).from_party_site_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).to_party_site_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).work_order_number := a9(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p37;
  procedure rosetta_table_copy_out_p37(t cse_datastructures_pub.item_move_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).from_network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).to_network_location_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).from_party_site_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).to_party_site_id);
          a9(indx) := t(ddindx).work_order_number;
          a10(indx) := t(ddindx).transaction_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p37;

  procedure rosetta_table_copy_in_p39(t out nocopy cse_datastructures_pub.proj_itm_insv_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).work_order_number := a7(indx);
          t(ddindx).project_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a13(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t cse_datastructures_pub.proj_itm_insv_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a7(indx) := t(ddindx).work_order_number;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a10(indx) := t(ddindx).effective_date;
          a11(indx) := t(ddindx).transaction_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure rosetta_table_copy_in_p41(t out nocopy cse_datastructures_pub.proj_itm_insv_pa_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inv_master_org_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).serial_number := a2(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).location_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).location_type := a5(indx);
          t(ddindx).project_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).message_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a14(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t cse_datastructures_pub.proj_itm_insv_pa_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).inv_master_org_id);
          a2(indx) := t(ddindx).serial_number;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a5(indx) := t(ddindx).location_type;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a11(indx) := t(ddindx).transaction_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).message_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p43(t out nocopy cse_datastructures_pub.rcv_txn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rcv_transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).temp_txn_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).txn_organization_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).po_header_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).po_line_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).po_distribution_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).project_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).revision_id := a12(indx);
          t(ddindx).lot_number := a13(indx);
          t(ddindx).serial_number := a14(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).uom := a16(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).csi_transaction_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).po_number := a19(indx);
          t(ddindx).po_line_number := a20(indx);
          t(ddindx).po_vendor_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).transaction_type := a22(indx);
          t(ddindx).destination_type_code := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p43;
  procedure rosetta_table_copy_out_p43(t cse_datastructures_pub.rcv_txn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
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
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
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
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rcv_transaction_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).temp_txn_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).txn_organization_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).po_header_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).po_line_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).po_distribution_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a10(indx) := t(ddindx).transaction_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a12(indx) := t(ddindx).revision_id;
          a13(indx) := t(ddindx).lot_number;
          a14(indx) := t(ddindx).serial_number;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a16(indx) := t(ddindx).uom;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).csi_transaction_id);
          a19(indx) := t(ddindx).po_number;
          a20(indx) := t(ddindx).po_line_number;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).po_vendor_id);
          a22(indx) := t(ddindx).transaction_type;
          a23(indx) := t(ddindx).destination_type_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p43;

  procedure rosetta_table_copy_in_p45(t out nocopy cse_datastructures_pub.ipv_txn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).project_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).item_name := a3(indx);
          t(ddindx).serial_number := a4(indx);
          t(ddindx).invoice_distribution_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).accounting_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).invoice_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).ipv := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).invoice_quantity := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).price_var_cc_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).po_header_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).po_line_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).po_distribution_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).cr_cc_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).vendor_number := a18(indx);
          t(ddindx).uom := a19(indx);
          t(ddindx).csi_transaction_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).invoice_number := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p45;
  procedure rosetta_table_copy_out_p45(t cse_datastructures_pub.ipv_txn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a3(indx) := t(ddindx).item_name;
          a4(indx) := t(ddindx).serial_number;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_distribution_id);
          a6(indx) := t(ddindx).accounting_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).ipv);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a10(indx) := t(ddindx).transaction_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_quantity);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).price_var_cc_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).po_header_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).po_line_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).po_distribution_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).cr_cc_id);
          a18(indx) := t(ddindx).vendor_number;
          a19(indx) := t(ddindx).uom;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).csi_transaction_id);
          a21(indx) := t(ddindx).invoice_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p45;

  procedure rosetta_table_copy_in_p47(t out nocopy cse_datastructures_pub.asset_query_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parent_mass_addition_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mass_addition_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).asset_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).search_method := a3(indx);
          t(ddindx).asset_number := a4(indx);
          t(ddindx).category_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).book_type_code := a6(indx);
          t(ddindx).date_placed_in_service := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).asset_key_ccid := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tag_number := a9(indx);
          t(ddindx).description := a10(indx);
          t(ddindx).manufacturer_name := a11(indx);
          t(ddindx).serial_number := a12(indx);
          t(ddindx).model_number := a13(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).employee_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).deprn_employee_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).deprn_expense_ccid := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).distribution_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).current_mtl_cost := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).current_non_mtl_cost := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).current_units := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).pending_adj_mtl_cost := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).pending_adj_non_mtl_cost := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).pending_ret_mtl_cost := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).pending_ret_non_mtl_cost := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).pending_ret_units := rosetta_g_miss_num_map(a27(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p47;
  procedure rosetta_table_copy_out_p47(t cse_datastructures_pub.asset_query_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).parent_mass_addition_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).mass_addition_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).asset_id);
          a3(indx) := t(ddindx).search_method;
          a4(indx) := t(ddindx).asset_number;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a6(indx) := t(ddindx).book_type_code;
          a7(indx) := t(ddindx).date_placed_in_service;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).asset_key_ccid);
          a9(indx) := t(ddindx).tag_number;
          a10(indx) := t(ddindx).description;
          a11(indx) := t(ddindx).manufacturer_name;
          a12(indx) := t(ddindx).serial_number;
          a13(indx) := t(ddindx).model_number;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).employee_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).deprn_employee_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).deprn_expense_ccid);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).distribution_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).current_mtl_cost);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).current_non_mtl_cost);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).current_units);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).pending_adj_mtl_cost);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).pending_adj_non_mtl_cost);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).pending_ret_mtl_cost);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).pending_ret_non_mtl_cost);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).pending_ret_units);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p47;

  procedure rosetta_table_copy_in_p49(t out nocopy cse_datastructures_pub.asset_attrib_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).serial_number := a2(indx);
          t(ddindx).organization_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).inv_master_organization_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).subinventory_name := a5(indx);
          t(ddindx).transaction_quantity := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).source_transaction_type := a9(indx);
          t(ddindx).depreciable_flag := a10(indx);
          t(ddindx).location_type_code := a11(indx);
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).source_header_ref_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).rcv_transaction_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).po_distribution_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).inv_material_transaction_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).location_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).asset_category_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).book_type_code := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p49;
  procedure rosetta_table_copy_out_p49(t cse_datastructures_pub.asset_attrib_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a2(indx) := t(ddindx).serial_number;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).inv_master_organization_id);
          a5(indx) := t(ddindx).subinventory_name;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_quantity);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a8(indx) := t(ddindx).transaction_date;
          a9(indx) := t(ddindx).source_transaction_type;
          a10(indx) := t(ddindx).depreciable_flag;
          a11(indx) := t(ddindx).location_type_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).source_header_ref_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).rcv_transaction_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).po_distribution_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).inv_material_transaction_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).asset_category_id);
          a19(indx) := t(ddindx).book_type_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p49;

  procedure rosetta_table_copy_in_p51(t out nocopy cse_datastructures_pub.distribution_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).book_type_code := a1(indx);
          t(ddindx).distribution_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).location_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).employee_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).deprn_expense_ccid := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).current_units := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).pending_ret_units := rosetta_g_miss_num_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p51;
  procedure rosetta_table_copy_out_p51(t cse_datastructures_pub.distribution_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).asset_id);
          a1(indx) := t(ddindx).book_type_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).distribution_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).employee_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).deprn_expense_ccid);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).current_units);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).pending_ret_units);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p51;

  procedure rosetta_table_copy_in_p56(t out nocopy cse_datastructures_pub.wfm_trx_values_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inventory_revision := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).network_location_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).from_network_location_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).to_network_location_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).from_party_site_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).to_party_site_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).work_order_number := a11(indx);
          t(ddindx).source_transaction_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).source_transaction_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).project_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).return_status := a19(indx);
          t(ddindx).error_message := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p56;
  procedure rosetta_table_copy_out_p56(t cse_datastructures_pub.wfm_trx_values_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a1(indx) := t(ddindx).inventory_revision;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).network_location_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).from_network_location_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).to_network_location_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).from_party_site_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).to_party_site_id);
          a11(indx) := t(ddindx).work_order_number;
          a12(indx) := t(ddindx).source_transaction_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).source_transaction_by);
          a14(indx) := t(ddindx).transaction_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a16(indx) := t(ddindx).effective_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a19(indx) := t(ddindx).return_status;
          a20(indx) := t(ddindx).error_message;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p56;

end cse_datastructures_pub_w;

/
