--------------------------------------------------------
--  DDL for Package Body CSE_DEPLOYMENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_DEPLOYMENT_GRP_W" as
/* $Header: CSEDPLWB.pls 120.5 2006/07/24 17:08:19 sguthiva noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy cse_deployment_grp.txn_instances_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).serial_number := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).inventory_revision := a3(indx);
          t(ddindx).last_pa_project_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_pa_project_task_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).unit_of_measure := a7(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).instance_status_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).operational_status_code := a11(indx);
          t(ddindx).asset_id := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cse_deployment_grp.txn_instances_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
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
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).serial_number;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).inventory_revision;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_project_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_project_task_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a7(indx) := t(ddindx).unit_of_measure;
          a8(indx) := t(ddindx).active_start_date;
          a9(indx) := t(ddindx).active_end_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).instance_status_id);
          a11(indx) := t(ddindx).operational_status_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).asset_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cse_deployment_grp.dest_location_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).location_type_code := a1(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).instance_usage_code := a3(indx);
          t(ddindx).last_pa_project_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_pa_project_task_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).external_reference := a6(indx);
          t(ddindx).operational_status_code := a7(indx);
          t(ddindx).pa_project_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).pa_project_task_id := rosetta_g_miss_num_map(a9(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cse_deployment_grp.dest_location_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          a1(indx) := t(ddindx).location_type_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a3(indx) := t(ddindx).instance_usage_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_project_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_pa_project_task_id);
          a6(indx) := t(ddindx).external_reference;
          a7(indx) := t(ddindx).operational_status_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).pa_project_task_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy cse_deployment_grp.txn_ext_attrib_values_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_tbl_index := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).attribute_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).attribute_code := a4(indx);
          t(ddindx).attribute_value := a5(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cse_deployment_grp.txn_ext_attrib_values_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_value_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_tbl_index);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).attribute_id);
          a4(indx) := t(ddindx).attribute_code;
          a5(indx) := t(ddindx).attribute_value;
          a6(indx) := t(ddindx).active_start_date;
          a7(indx) := t(ddindx).active_end_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy cse_deployment_grp.transaction_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).source_transaction_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).transaction_type_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).txn_sub_type_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).source_group_ref_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).source_group_ref := a6(indx);
          t(ddindx).source_header_ref_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).source_header_ref := a8(indx);
          t(ddindx).transacted_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).transaction_quantity := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).proceeds_of_sale := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).cost_of_removal := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).operational_flag := a13(indx);
          t(ddindx).financial_flag := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t cse_deployment_grp.transaction_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a1(indx) := t(ddindx).transaction_date;
          a2(indx) := t(ddindx).source_transaction_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_type_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).txn_sub_type_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).source_group_ref_id);
          a6(indx) := t(ddindx).source_group_ref;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).source_header_ref_id);
          a8(indx) := t(ddindx).source_header_ref;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).transacted_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_quantity);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).proceeds_of_sale);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).cost_of_removal);
          a13(indx) := t(ddindx).operational_flag;
          a14(indx) := t(ddindx).financial_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure process_transaction(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_VARCHAR2_TABLE_100
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_VARCHAR2_TABLE_100
    , p0_a12 JTF_NUMBER_TABLE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_VARCHAR2_TABLE_100
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_NUMBER_TABLE
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_NUMBER_TABLE
    , p2_a2 in out nocopy JTF_NUMBER_TABLE
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , p2_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a6 in out nocopy JTF_DATE_TABLE
    , p2_a7 in out nocopy JTF_DATE_TABLE
    , p2_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_DATE_TABLE
    , p3_a2 in out nocopy JTF_DATE_TABLE
    , p3_a3 in out nocopy JTF_NUMBER_TABLE
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a7 in out nocopy JTF_NUMBER_TABLE
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_NUMBER_TABLE
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_NUMBER_TABLE
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_msg out nocopy  VARCHAR2
  )

  as
    ddp_instance_tbl cse_deployment_grp.txn_instances_tbl;
    ddp_dest_location_tbl cse_deployment_grp.dest_location_tbl;
    ddp_ext_attrib_values_tbl cse_deployment_grp.txn_ext_attrib_values_tbl;
    ddp_txn_tbl cse_deployment_grp.transaction_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    cse_deployment_grp_w.rosetta_table_copy_in_p1(ddp_instance_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      );

    cse_deployment_grp_w.rosetta_table_copy_in_p3(ddp_dest_location_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      );

    cse_deployment_grp_w.rosetta_table_copy_in_p5(ddp_ext_attrib_values_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      );

    cse_deployment_grp_w.rosetta_table_copy_in_p7(ddp_txn_tbl, p3_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    cse_deployment_grp.process_transaction(ddp_instance_tbl,
      ddp_dest_location_tbl,
      ddp_ext_attrib_values_tbl,
      ddp_txn_tbl,
      x_return_status,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    cse_deployment_grp_w.rosetta_table_copy_out_p5(ddp_ext_attrib_values_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      );

    cse_deployment_grp_w.rosetta_table_copy_out_p7(ddp_txn_tbl, p3_a0
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
      );


  end;

end cse_deployment_grp_w;

/
