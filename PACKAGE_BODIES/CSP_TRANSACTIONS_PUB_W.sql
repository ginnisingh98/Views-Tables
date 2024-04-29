--------------------------------------------------------
--  DDL for Package Body CSP_TRANSACTIONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TRANSACTIONS_PUB_W" as
  /* $Header: csptppwb.pls 120.1.12010000.6 2012/02/08 07:38:32 htank ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy csp_transactions_pub.trans_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_2000
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
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).revision := a1(indx);
          t(ddindx).quantity := a2(indx);
          t(ddindx).uom_code := a3(indx);
          t(ddindx).lot_number := a4(indx);
          t(ddindx).serial_number := a5(indx);
          t(ddindx).frm_organization_id := a6(indx);
          t(ddindx).frm_subinventory_code := a7(indx);
          t(ddindx).frm_locator_id := a8(indx);
          t(ddindx).to_organization_id := a9(indx);
          t(ddindx).to_subinventory_code := a10(indx);
          t(ddindx).to_locator_id := a11(indx);
          t(ddindx).to_serial_number := a12(indx);
          t(ddindx).waybill_airbill := a13(indx);
          t(ddindx).freight_code := a14(indx);
          t(ddindx).shipment_number := a15(indx);
          t(ddindx).packlist_line_id := a16(indx);
          t(ddindx).temp_transaction_id := a17(indx);
          t(ddindx).error_msg := a18(indx);
          t(ddindx).shipment_line_id := a19(indx);
          t(ddindx).reason_id := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t csp_transactions_pub.trans_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_2000();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).quantity;
          a3(indx) := t(ddindx).uom_code;
          a4(indx) := t(ddindx).lot_number;
          a5(indx) := t(ddindx).serial_number;
          a6(indx) := t(ddindx).frm_organization_id;
          a7(indx) := t(ddindx).frm_subinventory_code;
          a8(indx) := t(ddindx).frm_locator_id;
          a9(indx) := t(ddindx).to_organization_id;
          a10(indx) := t(ddindx).to_subinventory_code;
          a11(indx) := t(ddindx).to_locator_id;
          a12(indx) := t(ddindx).to_serial_number;
          a13(indx) := t(ddindx).waybill_airbill;
          a14(indx) := t(ddindx).freight_code;
          a15(indx) := t(ddindx).shipment_number;
          a16(indx) := t(ddindx).packlist_line_id;
          a17(indx) := t(ddindx).temp_transaction_id;
          a18(indx) := t(ddindx).error_msg;
          a19(indx) := t(ddindx).shipment_line_id;
          a20(indx) := t(ddindx).reason_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p17(t out nocopy csp_transactions_pub.csparray, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := csp_transactions_pub.csparray();
  else
      if a0.count > 0 then
      t := csp_transactions_pub.csparray();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t csp_transactions_pub.csparray, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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
  end rosetta_table_copy_out_p17;

  procedure create_move_order_header(px_header_id in out nocopy  NUMBER
    , p_request_number  VARCHAR2
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_date_required  date
    , p_organization_id  NUMBER
    , p_from_subinventory_code  VARCHAR2
    , p_to_subinventory_code  VARCHAR2
    , p_address1  VARCHAR2
    , p_address2  VARCHAR2
    , p_address3  VARCHAR2
    , p_address4  VARCHAR2
    , p_city  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_state  VARCHAR2
    , p_province  VARCHAR2
    , p_country  VARCHAR2
    , p_freight_carrier  VARCHAR2
    , p_shipment_method  VARCHAR2
    , p_autoreceipt_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_date_required date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_date_required := rosetta_g_miss_date_in_map(p_date_required);



















    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.create_move_order_header(px_header_id,
      p_request_number,
      p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_date_required,
      p_organization_id,
      p_from_subinventory_code,
      p_to_subinventory_code,
      p_address1,
      p_address2,
      p_address3,
      p_address4,
      p_city,
      p_postal_code,
      p_state,
      p_province,
      p_country,
      p_freight_carrier,
      p_shipment_method,
      p_autoreceipt_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any























  end;

  procedure create_move_order_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , px_line_id in out nocopy  NUMBER
    , p_header_id  NUMBER
    , p_organization_id  NUMBER
    , p_from_subinventory_code  VARCHAR2
    , p_from_locator_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_revision  VARCHAR2
    , p_lot_number  VARCHAR2
    , p_serial_number_start  VARCHAR2
    , p_serial_number_end  VARCHAR2
    , p_quantity  NUMBER
    , p_uom_code  VARCHAR2
    , p_quantity_delivered  NUMBER
    , p_to_subinventory_code  VARCHAR2
    , p_to_locator_id  VARCHAR2
    , p_to_organization_id  NUMBER
    , p_service_request  VARCHAR2
    , p_task_id  NUMBER
    , p_task_assignment_id  NUMBER
    , p_customer_po  VARCHAR2
    , p_date_required  date
    , p_comments  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_date_required date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any























    ddp_date_required := rosetta_g_miss_date_in_map(p_date_required);





    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.create_move_order_line(p_api_version,
      p_init_msg_list,
      p_commit,
      px_line_id,
      p_header_id,
      p_organization_id,
      p_from_subinventory_code,
      p_from_locator_id,
      p_inventory_item_id,
      p_revision,
      p_lot_number,
      p_serial_number_start,
      p_serial_number_end,
      p_quantity,
      p_uom_code,
      p_quantity_delivered,
      p_to_subinventory_code,
      p_to_locator_id,
      p_to_organization_id,
      p_service_request,
      p_task_id,
      p_task_assignment_id,
      p_customer_po,
      ddp_date_required,
      p_comments,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



























  end;

  procedure transact_material(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , px_transaction_id in out nocopy  NUMBER
    , px_transaction_header_id in out nocopy  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_locator_id  NUMBER
    , p_lot_number  VARCHAR2
    , p_lot_expiration_date  date
    , p_revision  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_to_serial_number  VARCHAR2
    , p_quantity  NUMBER
    , p_uom  VARCHAR2
    , p_source_id  VARCHAR2
    , p_source_line_id  NUMBER
    , p_transaction_type_id  NUMBER
    , p_account_id  NUMBER
    , p_transfer_to_subinventory  VARCHAR2
    , p_transfer_to_locator  NUMBER
    , p_transfer_to_organization  NUMBER
    , p_online_process_flag  number
    , p_transaction_source_id  NUMBER
    , p_trx_source_line_id  NUMBER
    , p_transaction_source_name  VARCHAR2
    , p_waybill_airbill  VARCHAR2
    , p_shipment_number  VARCHAR2
    , p_freight_code  VARCHAR2
    , p_reason_id  NUMBER
    , p_transaction_reference  VARCHAR2
    , p_transaction_date  date
    , p_expected_delivery_date  date
    , p_final_completion_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lot_expiration_date date;
    ddp_online_process_flag boolean;
    ddp_transaction_date date;
    ddp_expected_delivery_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_lot_expiration_date := rosetta_g_miss_date_in_map(p_lot_expiration_date);













    if p_online_process_flag is null
      then ddp_online_process_flag := null;
    elsif p_online_process_flag = 0
      then ddp_online_process_flag := false;
    else ddp_online_process_flag := true;
    end if;









    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);

    ddp_expected_delivery_date := rosetta_g_miss_date_in_map(p_expected_delivery_date);





    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.transact_material(p_api_version,
      p_init_msg_list,
      p_commit,
      px_transaction_id,
      px_transaction_header_id,
      p_inventory_item_id,
      p_organization_id,
      p_subinventory_code,
      p_locator_id,
      p_lot_number,
      ddp_lot_expiration_date,
      p_revision,
      p_serial_number,
      p_to_serial_number,
      p_quantity,
      p_uom,
      p_source_id,
      p_source_line_id,
      p_transaction_type_id,
      p_account_id,
      p_transfer_to_subinventory,
      p_transfer_to_locator,
      p_transfer_to_organization,
      ddp_online_process_flag,
      p_transaction_source_id,
      p_trx_source_line_id,
      p_transaction_source_name,
      p_waybill_airbill,
      p_shipment_number,
      p_freight_code,
      p_reason_id,
      p_transaction_reference,
      ddp_transaction_date,
      ddp_expected_delivery_date,
      p_final_completion_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





































  end;

  procedure transact_temp_record(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_temp_id  NUMBER
    , px_transaction_header_id in out nocopy  NUMBER
    , p_online_process_flag  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_online_process_flag boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    if p_online_process_flag is null
      then ddp_online_process_flag := null;
    elsif p_online_process_flag = 0
      then ddp_online_process_flag := false;
    else ddp_online_process_flag := true;
    end if;




    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.transact_temp_record(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_transaction_temp_id,
      px_transaction_header_id,
      ddp_online_process_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure transact_items_transfer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_NUMBER_TABLE
    , p3_a17 in out nocopy JTF_NUMBER_TABLE
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a19 in out nocopy JTF_NUMBER_TABLE
    , p3_a20 in out nocopy JTF_NUMBER_TABLE
    , p_trans_type_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trans_items csp_transactions_pub.trans_items_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    csp_transactions_pub_w.rosetta_table_copy_in_p2(ddp_trans_items, p3_a0
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
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      );





    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.transact_items_transfer(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_trans_items,
      p_trans_type_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csp_transactions_pub_w.rosetta_table_copy_out_p2(ddp_trans_items, p3_a0
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
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      );




  end;

  procedure transact_subinv_transfer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_NUMBER_TABLE
    , p3_a17 in out nocopy JTF_NUMBER_TABLE
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a19 in out nocopy JTF_NUMBER_TABLE
    , p3_a20 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trans_items csp_transactions_pub.trans_items_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    csp_transactions_pub_w.rosetta_table_copy_in_p2(ddp_trans_items, p3_a0
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
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.transact_subinv_transfer(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_trans_items,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csp_transactions_pub_w.rosetta_table_copy_out_p2(ddp_trans_items, p3_a0
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
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      );



  end;

  procedure transact_intorg_transfer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_NUMBER_TABLE
    , p3_a17 in out nocopy JTF_NUMBER_TABLE
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a19 in out nocopy JTF_NUMBER_TABLE
    , p3_a20 in out nocopy JTF_NUMBER_TABLE
    , p_if_intransit  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trans_items csp_transactions_pub.trans_items_tbl_type;
    ddp_if_intransit boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    csp_transactions_pub_w.rosetta_table_copy_in_p2(ddp_trans_items, p3_a0
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
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      );

    if p_if_intransit is null
      then ddp_if_intransit := null;
    elsif p_if_intransit = 0
      then ddp_if_intransit := false;
    else ddp_if_intransit := true;
    end if;




    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.transact_intorg_transfer(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_trans_items,
      ddp_if_intransit,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csp_transactions_pub_w.rosetta_table_copy_out_p2(ddp_trans_items, p3_a0
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
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      );




  end;

  procedure create_move_order(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_NUMBER_TABLE
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a19 in out nocopy JTF_NUMBER_TABLE
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_date_required  date
    , p_comments  VARCHAR2
    , x_move_order_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trans_items csp_transactions_pub.trans_items_tbl_type;
    ddp_date_required date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csp_transactions_pub_w.rosetta_table_copy_in_p2(ddp_trans_items, p0_a0
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
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      );

    ddp_date_required := rosetta_g_miss_date_in_map(p_date_required);






    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.create_move_order(ddp_trans_items,
      ddp_date_required,
      p_comments,
      x_move_order_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csp_transactions_pub_w.rosetta_table_copy_out_p2(ddp_trans_items, p0_a0
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
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      );






  end;

  procedure receive_requirement_trans(p_trans_header_id  NUMBER
    , p_trans_line_id  NUMBER
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  VARCHAR2
    , p2_a11  NUMBER
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
    , p2_a17  NUMBER
    , p2_a18  VARCHAR2
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p_trans_type  VARCHAR2
    , p_req_line_detail_id  NUMBER
    , p_close_short  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trans_record csp_transactions_pub.trans_items_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_trans_record.inventory_item_id := p2_a0;
    ddp_trans_record.revision := p2_a1;
    ddp_trans_record.quantity := p2_a2;
    ddp_trans_record.uom_code := p2_a3;
    ddp_trans_record.lot_number := p2_a4;
    ddp_trans_record.serial_number := p2_a5;
    ddp_trans_record.frm_organization_id := p2_a6;
    ddp_trans_record.frm_subinventory_code := p2_a7;
    ddp_trans_record.frm_locator_id := p2_a8;
    ddp_trans_record.to_organization_id := p2_a9;
    ddp_trans_record.to_subinventory_code := p2_a10;
    ddp_trans_record.to_locator_id := p2_a11;
    ddp_trans_record.to_serial_number := p2_a12;
    ddp_trans_record.waybill_airbill := p2_a13;
    ddp_trans_record.freight_code := p2_a14;
    ddp_trans_record.shipment_number := p2_a15;
    ddp_trans_record.packlist_line_id := p2_a16;
    ddp_trans_record.temp_transaction_id := p2_a17;
    ddp_trans_record.error_msg := p2_a18;
    ddp_trans_record.shipment_line_id := p2_a19;
    ddp_trans_record.reason_id := p2_a20;







    -- here's the delegated call to the old PL/SQL routine
    csp_transactions_pub.receive_requirement_trans(p_trans_header_id,
      p_trans_line_id,
      ddp_trans_record,
      p_trans_type,
      p_req_line_detail_id,
      p_close_short,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end csp_transactions_pub_w;

/
