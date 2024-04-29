--------------------------------------------------------
--  DDL for Package Body AHL_OSP_ORDERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_ORDERS_PVT_W" as
  /* $Header: AHLVOSWB.pls 120.2 2008/02/05 23:32:17 jaramana ship $ */
  procedure rosetta_table_copy_in_p27(t out nocopy ahl_osp_orders_pvt.osp_order_lines_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_2000
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_flag := a0(indx);
          t(ddindx).shipment_creation_flag := a1(indx);
          t(ddindx).osp_order_line_id := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          t(ddindx).last_update_date := a4(indx);
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).creation_date := a6(indx);
          t(ddindx).created_by := a7(indx);
          t(ddindx).last_update_login := a8(indx);
          t(ddindx).osp_order_id := a9(indx);
          t(ddindx).osp_line_number := a10(indx);
          t(ddindx).status_code := a11(indx);
          t(ddindx).need_by_date := a12(indx);
          t(ddindx).ship_by_date := a13(indx);
          t(ddindx).po_line_type_id := a14(indx);
          t(ddindx).po_line_type := a15(indx);
          t(ddindx).po_line_id := a16(indx);
          t(ddindx).oe_ship_line_id := a17(indx);
          t(ddindx).oe_return_line_id := a18(indx);
          t(ddindx).service_item_id := a19(indx);
          t(ddindx).service_item_number := a20(indx);
          t(ddindx).service_item_description := a21(indx);
          t(ddindx).service_item_uom_code := a22(indx);
          t(ddindx).quantity := a23(indx);
          t(ddindx).workorder_id := a24(indx);
          t(ddindx).job_number := a25(indx);
          t(ddindx).operation_id := a26(indx);
          t(ddindx).inventory_item_id := a27(indx);
          t(ddindx).inventory_org_id := a28(indx);
          t(ddindx).item_number := a29(indx);
          t(ddindx).inventory_item_uom := a30(indx);
          t(ddindx).inventory_item_quantity := a31(indx);
          t(ddindx).sub_inventory := a32(indx);
          t(ddindx).lot_number := a33(indx);
          t(ddindx).serial_number := a34(indx);
          t(ddindx).exchange_instance_number := a35(indx);
          t(ddindx).exchange_instance_id := a36(indx);
          t(ddindx).attribute_category := a37(indx);
          t(ddindx).attribute1 := a38(indx);
          t(ddindx).attribute2 := a39(indx);
          t(ddindx).attribute3 := a40(indx);
          t(ddindx).attribute4 := a41(indx);
          t(ddindx).attribute5 := a42(indx);
          t(ddindx).attribute6 := a43(indx);
          t(ddindx).attribute7 := a44(indx);
          t(ddindx).attribute8 := a45(indx);
          t(ddindx).attribute9 := a46(indx);
          t(ddindx).attribute10 := a47(indx);
          t(ddindx).attribute11 := a48(indx);
          t(ddindx).attribute12 := a49(indx);
          t(ddindx).attribute13 := a50(indx);
          t(ddindx).attribute14 := a51(indx);
          t(ddindx).attribute15 := a52(indx);
          t(ddindx).po_req_line_id := a53(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p27;
  procedure rosetta_table_copy_out_p27(t ahl_osp_orders_pvt.osp_order_lines_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_2000();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_2000();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).operation_flag;
          a1(indx) := t(ddindx).shipment_creation_flag;
          a2(indx) := t(ddindx).osp_order_line_id;
          a3(indx) := t(ddindx).object_version_number;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).created_by;
          a8(indx) := t(ddindx).last_update_login;
          a9(indx) := t(ddindx).osp_order_id;
          a10(indx) := t(ddindx).osp_line_number;
          a11(indx) := t(ddindx).status_code;
          a12(indx) := t(ddindx).need_by_date;
          a13(indx) := t(ddindx).ship_by_date;
          a14(indx) := t(ddindx).po_line_type_id;
          a15(indx) := t(ddindx).po_line_type;
          a16(indx) := t(ddindx).po_line_id;
          a17(indx) := t(ddindx).oe_ship_line_id;
          a18(indx) := t(ddindx).oe_return_line_id;
          a19(indx) := t(ddindx).service_item_id;
          a20(indx) := t(ddindx).service_item_number;
          a21(indx) := t(ddindx).service_item_description;
          a22(indx) := t(ddindx).service_item_uom_code;
          a23(indx) := t(ddindx).quantity;
          a24(indx) := t(ddindx).workorder_id;
          a25(indx) := t(ddindx).job_number;
          a26(indx) := t(ddindx).operation_id;
          a27(indx) := t(ddindx).inventory_item_id;
          a28(indx) := t(ddindx).inventory_org_id;
          a29(indx) := t(ddindx).item_number;
          a30(indx) := t(ddindx).inventory_item_uom;
          a31(indx) := t(ddindx).inventory_item_quantity;
          a32(indx) := t(ddindx).sub_inventory;
          a33(indx) := t(ddindx).lot_number;
          a34(indx) := t(ddindx).serial_number;
          a35(indx) := t(ddindx).exchange_instance_number;
          a36(indx) := t(ddindx).exchange_instance_id;
          a37(indx) := t(ddindx).attribute_category;
          a38(indx) := t(ddindx).attribute1;
          a39(indx) := t(ddindx).attribute2;
          a40(indx) := t(ddindx).attribute3;
          a41(indx) := t(ddindx).attribute4;
          a42(indx) := t(ddindx).attribute5;
          a43(indx) := t(ddindx).attribute6;
          a44(indx) := t(ddindx).attribute7;
          a45(indx) := t(ddindx).attribute8;
          a46(indx) := t(ddindx).attribute9;
          a47(indx) := t(ddindx).attribute10;
          a48(indx) := t(ddindx).attribute11;
          a49(indx) := t(ddindx).attribute12;
          a50(indx) := t(ddindx).attribute13;
          a51(indx) := t(ddindx).attribute14;
          a52(indx) := t(ddindx).attribute15;
          a53(indx) := t(ddindx).po_req_line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p27;

  procedure process_osp_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  VARCHAR2
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  DATE
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  DATE
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  NUMBER
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  NUMBER
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  NUMBER
    , p5_a23 in out nocopy  NUMBER
    , p5_a24 in out nocopy  NUMBER
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  NUMBER
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  NUMBER
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  VARCHAR2
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_DATE_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_DATE_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 in out nocopy JTF_DATE_TABLE
    , p6_a13 in out nocopy JTF_DATE_TABLE
    , p6_a14 in out nocopy JTF_NUMBER_TABLE
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 in out nocopy JTF_NUMBER_TABLE
    , p6_a17 in out nocopy JTF_NUMBER_TABLE
    , p6_a18 in out nocopy JTF_NUMBER_TABLE
    , p6_a19 in out nocopy JTF_NUMBER_TABLE
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 in out nocopy JTF_NUMBER_TABLE
    , p6_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 in out nocopy JTF_NUMBER_TABLE
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 in out nocopy JTF_NUMBER_TABLE
    , p6_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_osp_order_rec ahl_osp_orders_pvt.osp_order_rec_type;
    ddp_x_osp_order_lines_tbl ahl_osp_orders_pvt.osp_order_lines_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_osp_order_rec.operation_flag := p5_a0;
    ddp_x_osp_order_rec.osp_order_id := p5_a1;
    ddp_x_osp_order_rec.object_version_number := p5_a2;
    ddp_x_osp_order_rec.last_update_date := p5_a3;
    ddp_x_osp_order_rec.last_updated_by := p5_a4;
    ddp_x_osp_order_rec.creation_date := p5_a5;
    ddp_x_osp_order_rec.created_by := p5_a6;
    ddp_x_osp_order_rec.last_update_login := p5_a7;
    ddp_x_osp_order_rec.osp_order_number := p5_a8;
    ddp_x_osp_order_rec.order_type_code := p5_a9;
    ddp_x_osp_order_rec.status_code := p5_a10;
    ddp_x_osp_order_rec.order_date := p5_a11;
    ddp_x_osp_order_rec.description := p5_a12;
    ddp_x_osp_order_rec.operating_unit_id := p5_a13;
    ddp_x_osp_order_rec.single_instance_flag := p5_a14;
    ddp_x_osp_order_rec.vendor_id := p5_a15;
    ddp_x_osp_order_rec.vendor_name := p5_a16;
    ddp_x_osp_order_rec.vendor_site_id := p5_a17;
    ddp_x_osp_order_rec.vendor_site_code := p5_a18;
    ddp_x_osp_order_rec.vendor_contact_id := p5_a19;
    ddp_x_osp_order_rec.vendor_contact := p5_a20;
    ddp_x_osp_order_rec.po_synch_flag := p5_a21;
    ddp_x_osp_order_rec.po_header_id := p5_a22;
    ddp_x_osp_order_rec.po_batch_id := p5_a23;
    ddp_x_osp_order_rec.po_request_id := p5_a24;
    ddp_x_osp_order_rec.po_agent_id := p5_a25;
    ddp_x_osp_order_rec.buyer_name := p5_a26;
    ddp_x_osp_order_rec.po_interface_header_id := p5_a27;
    ddp_x_osp_order_rec.oe_header_id := p5_a28;
    ddp_x_osp_order_rec.customer_id := p5_a29;
    ddp_x_osp_order_rec.customer_name := p5_a30;
    ddp_x_osp_order_rec.contract_id := p5_a31;
    ddp_x_osp_order_rec.contract_number := p5_a32;
    ddp_x_osp_order_rec.contract_terms := p5_a33;
    ddp_x_osp_order_rec.attribute_category := p5_a34;
    ddp_x_osp_order_rec.attribute1 := p5_a35;
    ddp_x_osp_order_rec.attribute2 := p5_a36;
    ddp_x_osp_order_rec.attribute3 := p5_a37;
    ddp_x_osp_order_rec.attribute4 := p5_a38;
    ddp_x_osp_order_rec.attribute5 := p5_a39;
    ddp_x_osp_order_rec.attribute6 := p5_a40;
    ddp_x_osp_order_rec.attribute7 := p5_a41;
    ddp_x_osp_order_rec.attribute8 := p5_a42;
    ddp_x_osp_order_rec.attribute9 := p5_a43;
    ddp_x_osp_order_rec.attribute10 := p5_a44;
    ddp_x_osp_order_rec.attribute11 := p5_a45;
    ddp_x_osp_order_rec.attribute12 := p5_a46;
    ddp_x_osp_order_rec.attribute13 := p5_a47;
    ddp_x_osp_order_rec.attribute14 := p5_a48;
    ddp_x_osp_order_rec.attribute15 := p5_a49;
    ddp_x_osp_order_rec.po_req_header_id := p5_a50;

    ahl_osp_orders_pvt_w.rosetta_table_copy_in_p27(ddp_x_osp_order_lines_tbl, p6_a0
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
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_osp_orders_pvt.process_osp_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_osp_order_rec,
      ddp_x_osp_order_lines_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_osp_order_rec.operation_flag;
    p5_a1 := ddp_x_osp_order_rec.osp_order_id;
    p5_a2 := ddp_x_osp_order_rec.object_version_number;
    p5_a3 := ddp_x_osp_order_rec.last_update_date;
    p5_a4 := ddp_x_osp_order_rec.last_updated_by;
    p5_a5 := ddp_x_osp_order_rec.creation_date;
    p5_a6 := ddp_x_osp_order_rec.created_by;
    p5_a7 := ddp_x_osp_order_rec.last_update_login;
    p5_a8 := ddp_x_osp_order_rec.osp_order_number;
    p5_a9 := ddp_x_osp_order_rec.order_type_code;
    p5_a10 := ddp_x_osp_order_rec.status_code;
    p5_a11 := ddp_x_osp_order_rec.order_date;
    p5_a12 := ddp_x_osp_order_rec.description;
    p5_a13 := ddp_x_osp_order_rec.operating_unit_id;
    p5_a14 := ddp_x_osp_order_rec.single_instance_flag;
    p5_a15 := ddp_x_osp_order_rec.vendor_id;
    p5_a16 := ddp_x_osp_order_rec.vendor_name;
    p5_a17 := ddp_x_osp_order_rec.vendor_site_id;
    p5_a18 := ddp_x_osp_order_rec.vendor_site_code;
    p5_a19 := ddp_x_osp_order_rec.vendor_contact_id;
    p5_a20 := ddp_x_osp_order_rec.vendor_contact;
    p5_a21 := ddp_x_osp_order_rec.po_synch_flag;
    p5_a22 := ddp_x_osp_order_rec.po_header_id;
    p5_a23 := ddp_x_osp_order_rec.po_batch_id;
    p5_a24 := ddp_x_osp_order_rec.po_request_id;
    p5_a25 := ddp_x_osp_order_rec.po_agent_id;
    p5_a26 := ddp_x_osp_order_rec.buyer_name;
    p5_a27 := ddp_x_osp_order_rec.po_interface_header_id;
    p5_a28 := ddp_x_osp_order_rec.oe_header_id;
    p5_a29 := ddp_x_osp_order_rec.customer_id;
    p5_a30 := ddp_x_osp_order_rec.customer_name;
    p5_a31 := ddp_x_osp_order_rec.contract_id;
    p5_a32 := ddp_x_osp_order_rec.contract_number;
    p5_a33 := ddp_x_osp_order_rec.contract_terms;
    p5_a34 := ddp_x_osp_order_rec.attribute_category;
    p5_a35 := ddp_x_osp_order_rec.attribute1;
    p5_a36 := ddp_x_osp_order_rec.attribute2;
    p5_a37 := ddp_x_osp_order_rec.attribute3;
    p5_a38 := ddp_x_osp_order_rec.attribute4;
    p5_a39 := ddp_x_osp_order_rec.attribute5;
    p5_a40 := ddp_x_osp_order_rec.attribute6;
    p5_a41 := ddp_x_osp_order_rec.attribute7;
    p5_a42 := ddp_x_osp_order_rec.attribute8;
    p5_a43 := ddp_x_osp_order_rec.attribute9;
    p5_a44 := ddp_x_osp_order_rec.attribute10;
    p5_a45 := ddp_x_osp_order_rec.attribute11;
    p5_a46 := ddp_x_osp_order_rec.attribute12;
    p5_a47 := ddp_x_osp_order_rec.attribute13;
    p5_a48 := ddp_x_osp_order_rec.attribute14;
    p5_a49 := ddp_x_osp_order_rec.attribute15;
    p5_a50 := ddp_x_osp_order_rec.po_req_header_id;

    ahl_osp_orders_pvt_w.rosetta_table_copy_out_p27(ddp_x_osp_order_lines_tbl, p6_a0
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
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      );



  end;

end ahl_osp_orders_pvt_w;

/
