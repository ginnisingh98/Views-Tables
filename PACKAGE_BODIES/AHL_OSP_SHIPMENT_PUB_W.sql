--------------------------------------------------------
--  DDL for Package Body AHL_OSP_SHIPMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_SHIPMENT_PUB_W" as
  /* $Header: AHLWOSHB.pls 120.1 2007/07/30 10:43:57 mpothuku ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_osp_shipment_pub.sernum_change_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_number := a0(indx);
          t(ddindx).new_item_number := a1(indx);
          t(ddindx).new_lot_number := a2(indx);
          t(ddindx).new_item_rev_number := a3(indx);
          t(ddindx).osp_line_id := a4(indx);
          t(ddindx).instance_id := a5(indx);
          t(ddindx).current_serial_number := a6(indx);
          t(ddindx).current_serail_tag := a7(indx);
          t(ddindx).new_serial_number := a8(indx);
          t(ddindx).new_serial_tag_code := a9(indx);
          t(ddindx).new_serial_tag_mean := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_osp_shipment_pub.sernum_change_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).item_number;
          a1(indx) := t(ddindx).new_item_number;
          a2(indx) := t(ddindx).new_lot_number;
          a3(indx) := t(ddindx).new_item_rev_number;
          a4(indx) := t(ddindx).osp_line_id;
          a5(indx) := t(ddindx).instance_id;
          a6(indx) := t(ddindx).current_serial_number;
          a7(indx) := t(ddindx).current_serail_tag;
          a8(indx) := t(ddindx).new_serial_number;
          a9(indx) := t(ddindx).new_serial_tag_code;
          a10(indx) := t(ddindx).new_serial_tag_mean;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_osp_shipment_pub.ship_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_DATE_TABLE
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_id := a0(indx);
          t(ddindx).line_number := a1(indx);
          t(ddindx).header_id := a2(indx);
          t(ddindx).order_type := a3(indx);
          t(ddindx).line_type_id := a4(indx);
          t(ddindx).line_type := a5(indx);
          t(ddindx).job_number := a6(indx);
          t(ddindx).project_id := a7(indx);
          t(ddindx).project := a8(indx);
          t(ddindx).task_id := a9(indx);
          t(ddindx).task := a10(indx);
          t(ddindx).operation := a11(indx);
          t(ddindx).inventory_item_id := a12(indx);
          t(ddindx).inventory_org_id := a13(indx);
          t(ddindx).inventory_item := a14(indx);
          t(ddindx).lot_number := a15(indx);
          t(ddindx).inventory_item_uom := a16(indx);
          t(ddindx).inventory_item_quantity := a17(indx);
          t(ddindx).serial_number := a18(indx);
          t(ddindx).csi_item_instance_id := a19(indx);
          t(ddindx).ordered_quantity := a20(indx);
          t(ddindx).order_quantity_uom := a21(indx);
          t(ddindx).return_reason_code := a22(indx);
          t(ddindx).return_reason := a23(indx);
          t(ddindx).schedule_ship_date := a24(indx);
          t(ddindx).packing_instructions := a25(indx);
          t(ddindx).ship_from_org := a26(indx);
          t(ddindx).ship_from_org_id := a27(indx);
          t(ddindx).fob_point := a28(indx);
          t(ddindx).fob_point_code := a29(indx);
          t(ddindx).freight_carrier := a30(indx);
          t(ddindx).freight_carrier_code := a31(indx);
          t(ddindx).freight_terms := a32(indx);
          t(ddindx).freight_terms_code := a33(indx);
          t(ddindx).shipment_priority_code := a34(indx);
          t(ddindx).shipment_priority := a35(indx);
          t(ddindx).shipping_method_code := a36(indx);
          t(ddindx).shipping_method := a37(indx);
          t(ddindx).subinventory := a38(indx);
          t(ddindx).osp_order_id := a39(indx);
          t(ddindx).osp_order_number := a40(indx);
          t(ddindx).osp_line_id := a41(indx);
          t(ddindx).osp_line_number := a42(indx);
          t(ddindx).instance_id := a43(indx);
          t(ddindx).osp_line_flag := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_osp_shipment_pub.ship_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_VARCHAR2_TABLE_2000();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_VARCHAR2_TABLE_2000();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_id;
          a1(indx) := t(ddindx).line_number;
          a2(indx) := t(ddindx).header_id;
          a3(indx) := t(ddindx).order_type;
          a4(indx) := t(ddindx).line_type_id;
          a5(indx) := t(ddindx).line_type;
          a6(indx) := t(ddindx).job_number;
          a7(indx) := t(ddindx).project_id;
          a8(indx) := t(ddindx).project;
          a9(indx) := t(ddindx).task_id;
          a10(indx) := t(ddindx).task;
          a11(indx) := t(ddindx).operation;
          a12(indx) := t(ddindx).inventory_item_id;
          a13(indx) := t(ddindx).inventory_org_id;
          a14(indx) := t(ddindx).inventory_item;
          a15(indx) := t(ddindx).lot_number;
          a16(indx) := t(ddindx).inventory_item_uom;
          a17(indx) := t(ddindx).inventory_item_quantity;
          a18(indx) := t(ddindx).serial_number;
          a19(indx) := t(ddindx).csi_item_instance_id;
          a20(indx) := t(ddindx).ordered_quantity;
          a21(indx) := t(ddindx).order_quantity_uom;
          a22(indx) := t(ddindx).return_reason_code;
          a23(indx) := t(ddindx).return_reason;
          a24(indx) := t(ddindx).schedule_ship_date;
          a25(indx) := t(ddindx).packing_instructions;
          a26(indx) := t(ddindx).ship_from_org;
          a27(indx) := t(ddindx).ship_from_org_id;
          a28(indx) := t(ddindx).fob_point;
          a29(indx) := t(ddindx).fob_point_code;
          a30(indx) := t(ddindx).freight_carrier;
          a31(indx) := t(ddindx).freight_carrier_code;
          a32(indx) := t(ddindx).freight_terms;
          a33(indx) := t(ddindx).freight_terms_code;
          a34(indx) := t(ddindx).shipment_priority_code;
          a35(indx) := t(ddindx).shipment_priority;
          a36(indx) := t(ddindx).shipping_method_code;
          a37(indx) := t(ddindx).shipping_method;
          a38(indx) := t(ddindx).subinventory;
          a39(indx) := t(ddindx).osp_order_id;
          a40(indx) := t(ddindx).osp_order_number;
          a41(indx) := t(ddindx).osp_line_id;
          a42(indx) := t(ddindx).osp_line_number;
          a43(indx) := t(ddindx).instance_id;
          a44(indx) := t(ddindx).osp_line_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_osp_shipment_pub.ship_id_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_osp_shipment_pub.ship_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p5;

  procedure process_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  NUMBER
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 in out nocopy JTF_NUMBER_TABLE
    , p6_a13 in out nocopy JTF_NUMBER_TABLE
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 in out nocopy JTF_NUMBER_TABLE
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 in out nocopy JTF_NUMBER_TABLE
    , p6_a20 in out nocopy JTF_NUMBER_TABLE
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 in out nocopy JTF_DATE_TABLE
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 in out nocopy JTF_NUMBER_TABLE
    , p6_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 in out nocopy JTF_NUMBER_TABLE
    , p6_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 in out nocopy JTF_NUMBER_TABLE
    , p6_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_header_rec ahl_osp_shipment_pub.ship_header_rec_type;
    ddp_x_lines_tbl ahl_osp_shipment_pub.ship_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_header_rec.header_id := p5_a0;
    ddp_x_header_rec.order_number := p5_a1;
    ddp_x_header_rec.booked_flag := p5_a2;
    ddp_x_header_rec.cancelled_flag := p5_a3;
    ddp_x_header_rec.open_flag := p5_a4;
    ddp_x_header_rec.price_list := p5_a5;
    ddp_x_header_rec.price_list_id := p5_a6;
    ddp_x_header_rec.ship_from_org := p5_a7;
    ddp_x_header_rec.ship_from_org_id := p5_a8;
    ddp_x_header_rec.ship_to_contact := p5_a9;
    ddp_x_header_rec.ship_to_contact_id := p5_a10;
    ddp_x_header_rec.ship_to_org := p5_a11;
    ddp_x_header_rec.ship_to_org_id := p5_a12;
    ddp_x_header_rec.sold_to_custom_number := p5_a13;
    ddp_x_header_rec.sold_to_org_id := p5_a14;
    ddp_x_header_rec.fob_point := p5_a15;
    ddp_x_header_rec.fob_point_code := p5_a16;
    ddp_x_header_rec.freight_carrier := p5_a17;
    ddp_x_header_rec.freight_carrier_code := p5_a18;
    ddp_x_header_rec.freight_terms := p5_a19;
    ddp_x_header_rec.freight_terms_code := p5_a20;
    ddp_x_header_rec.shipment_priority_code := p5_a21;
    ddp_x_header_rec.shipment_priority := p5_a22;
    ddp_x_header_rec.shipping_method_code := p5_a23;
    ddp_x_header_rec.shipping_method := p5_a24;
    ddp_x_header_rec.osp_order_id := p5_a25;
    ddp_x_header_rec.osp_order_number := p5_a26;
    ddp_x_header_rec.payment_term_id := p5_a27;
    ddp_x_header_rec.payment_term := p5_a28;
    ddp_x_header_rec.tax_exempt_flag := p5_a29;
    ddp_x_header_rec.tax_exempt_number := p5_a30;
    ddp_x_header_rec.tax_exempt_reason_code := p5_a31;
    ddp_x_header_rec.tax_exempt_reason := p5_a32;
    ddp_x_header_rec.shipping_instructions := p5_a33;
    ddp_x_header_rec.packing_instructions := p5_a34;
    ddp_x_header_rec.operation := p5_a35;

    ahl_osp_shipment_pub_w.rosetta_table_copy_in_p4(ddp_x_lines_tbl, p6_a0
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
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_shipment_pub.process_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_header_rec,
      ddp_x_lines_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_header_rec.header_id;
    p5_a1 := ddp_x_header_rec.order_number;
    p5_a2 := ddp_x_header_rec.booked_flag;
    p5_a3 := ddp_x_header_rec.cancelled_flag;
    p5_a4 := ddp_x_header_rec.open_flag;
    p5_a5 := ddp_x_header_rec.price_list;
    p5_a6 := ddp_x_header_rec.price_list_id;
    p5_a7 := ddp_x_header_rec.ship_from_org;
    p5_a8 := ddp_x_header_rec.ship_from_org_id;
    p5_a9 := ddp_x_header_rec.ship_to_contact;
    p5_a10 := ddp_x_header_rec.ship_to_contact_id;
    p5_a11 := ddp_x_header_rec.ship_to_org;
    p5_a12 := ddp_x_header_rec.ship_to_org_id;
    p5_a13 := ddp_x_header_rec.sold_to_custom_number;
    p5_a14 := ddp_x_header_rec.sold_to_org_id;
    p5_a15 := ddp_x_header_rec.fob_point;
    p5_a16 := ddp_x_header_rec.fob_point_code;
    p5_a17 := ddp_x_header_rec.freight_carrier;
    p5_a18 := ddp_x_header_rec.freight_carrier_code;
    p5_a19 := ddp_x_header_rec.freight_terms;
    p5_a20 := ddp_x_header_rec.freight_terms_code;
    p5_a21 := ddp_x_header_rec.shipment_priority_code;
    p5_a22 := ddp_x_header_rec.shipment_priority;
    p5_a23 := ddp_x_header_rec.shipping_method_code;
    p5_a24 := ddp_x_header_rec.shipping_method;
    p5_a25 := ddp_x_header_rec.osp_order_id;
    p5_a26 := ddp_x_header_rec.osp_order_number;
    p5_a27 := ddp_x_header_rec.payment_term_id;
    p5_a28 := ddp_x_header_rec.payment_term;
    p5_a29 := ddp_x_header_rec.tax_exempt_flag;
    p5_a30 := ddp_x_header_rec.tax_exempt_number;
    p5_a31 := ddp_x_header_rec.tax_exempt_reason_code;
    p5_a32 := ddp_x_header_rec.tax_exempt_reason;
    p5_a33 := ddp_x_header_rec.shipping_instructions;
    p5_a34 := ddp_x_header_rec.packing_instructions;
    p5_a35 := ddp_x_header_rec.operation;

    ahl_osp_shipment_pub_w.rosetta_table_copy_out_p4(ddp_x_lines_tbl, p6_a0
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
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      );



  end;

  procedure book_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_oe_header_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_oe_header_tbl ahl_osp_shipment_pub.ship_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ahl_osp_shipment_pub_w.rosetta_table_copy_in_p5(ddp_oe_header_tbl, p_oe_header_tbl);




    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_shipment_pub.book_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_oe_header_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_cancel_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_oe_header_id  NUMBER
    , p_oe_lines_tbl JTF_NUMBER_TABLE
    , p_cancel_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_oe_lines_tbl ahl_osp_shipment_pub.ship_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_osp_shipment_pub_w.rosetta_table_copy_in_p5(ddp_oe_lines_tbl, p_oe_lines_tbl);





    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_shipment_pub.delete_cancel_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_oe_header_id,
      ddp_oe_lines_tbl,
      p_cancel_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure process_osp_serialnum_change(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_serialnum_change_rec ahl_osp_shipment_pub.sernum_change_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_serialnum_change_rec.item_number := p5_a0;
    ddp_serialnum_change_rec.new_item_number := p5_a1;
    ddp_serialnum_change_rec.new_lot_number := p5_a2;
    ddp_serialnum_change_rec.new_item_rev_number := p5_a3;
    ddp_serialnum_change_rec.osp_line_id := p5_a4;
    ddp_serialnum_change_rec.instance_id := p5_a5;
    ddp_serialnum_change_rec.current_serial_number := p5_a6;
    ddp_serialnum_change_rec.current_serail_tag := p5_a7;
    ddp_serialnum_change_rec.new_serial_number := p5_a8;
    ddp_serialnum_change_rec.new_serial_tag_code := p5_a9;
    ddp_serialnum_change_rec.new_serial_tag_mean := p5_a10;




    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_shipment_pub.process_osp_serialnum_change(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_serialnum_change_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ahl_osp_shipment_pub_w;

/
