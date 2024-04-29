--------------------------------------------------------
--  DDL for Package Body AHL_PRD_MRSHL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_MRSHL_PVT_W" as
  /* $Header: AHLWPMLB.pls 120.1 2008/02/20 05:05:17 sikumar noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_prd_mrshl_pvt.unavailable_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).scheduled_material_id := a0(indx);
          t(ddindx).inventory_item_id := a1(indx);
          t(ddindx).item_name := a2(indx);
          t(ddindx).item_desc := a3(indx);
          t(ddindx).workorder_id := a4(indx);
          t(ddindx).workorder_name := a5(indx);
          t(ddindx).wip_entity_id := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).visit_id := a8(indx);
          t(ddindx).wo_status_code := a9(indx);
          t(ddindx).wo_status := a10(indx);
          t(ddindx).wo_operation_id := a11(indx);
          t(ddindx).op_seq := a12(indx);
          t(ddindx).quantity := a13(indx);
          t(ddindx).uom := a14(indx);
          t(ddindx).uom_desc := a15(indx);
          t(ddindx).required_date := a16(indx);
          t(ddindx).required_quantity := a17(indx);
          t(ddindx).issued_quantity := a18(indx);
          t(ddindx).scheduled_date := a19(indx);
          t(ddindx).scheduled_quantity := a20(indx);
          t(ddindx).exception_date := a21(indx);
          t(ddindx).reserved_quantity := a22(indx);
          t(ddindx).onhand_quantity := a23(indx);
          t(ddindx).qty_per_assembly := a24(indx);
          t(ddindx).subinventory := a25(indx);
          t(ddindx).locator_id := a26(indx);
          t(ddindx).locator_segments := a27(indx);
          t(ddindx).serial_number := a28(indx);
          t(ddindx).lot := a29(indx);
          t(ddindx).revision := a30(indx);
          t(ddindx).is_serialized := a31(indx);
          t(ddindx).is_lot_controlled := a32(indx);
          t(ddindx).is_revision_controlled := a33(indx);
          t(ddindx).diposition_id := a34(indx);
          t(ddindx).diposition_name := a35(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_prd_mrshl_pvt.unavailable_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).scheduled_material_id;
          a1(indx) := t(ddindx).inventory_item_id;
          a2(indx) := t(ddindx).item_name;
          a3(indx) := t(ddindx).item_desc;
          a4(indx) := t(ddindx).workorder_id;
          a5(indx) := t(ddindx).workorder_name;
          a6(indx) := t(ddindx).wip_entity_id;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).visit_id;
          a9(indx) := t(ddindx).wo_status_code;
          a10(indx) := t(ddindx).wo_status;
          a11(indx) := t(ddindx).wo_operation_id;
          a12(indx) := t(ddindx).op_seq;
          a13(indx) := t(ddindx).quantity;
          a14(indx) := t(ddindx).uom;
          a15(indx) := t(ddindx).uom_desc;
          a16(indx) := t(ddindx).required_date;
          a17(indx) := t(ddindx).required_quantity;
          a18(indx) := t(ddindx).issued_quantity;
          a19(indx) := t(ddindx).scheduled_date;
          a20(indx) := t(ddindx).scheduled_quantity;
          a21(indx) := t(ddindx).exception_date;
          a22(indx) := t(ddindx).reserved_quantity;
          a23(indx) := t(ddindx).onhand_quantity;
          a24(indx) := t(ddindx).qty_per_assembly;
          a25(indx) := t(ddindx).subinventory;
          a26(indx) := t(ddindx).locator_id;
          a27(indx) := t(ddindx).locator_segments;
          a28(indx) := t(ddindx).serial_number;
          a29(indx) := t(ddindx).lot;
          a30(indx) := t(ddindx).revision;
          a31(indx) := t(ddindx).is_serialized;
          a32(indx) := t(ddindx).is_lot_controlled;
          a33(indx) := t(ddindx).is_revision_controlled;
          a34(indx) := t(ddindx).diposition_id;
          a35(indx) := t(ddindx).diposition_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_prd_mrshl_pvt.available_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).scheduled_material_id := a0(indx);
          t(ddindx).inventory_item_id := a1(indx);
          t(ddindx).item_name := a2(indx);
          t(ddindx).item_desc := a3(indx);
          t(ddindx).workorder_id := a4(indx);
          t(ddindx).workorder_name := a5(indx);
          t(ddindx).wip_entity_id := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).visit_id := a8(indx);
          t(ddindx).wo_status_code := a9(indx);
          t(ddindx).wo_status := a10(indx);
          t(ddindx).wo_operation_id := a11(indx);
          t(ddindx).op_seq := a12(indx);
          t(ddindx).quantity := a13(indx);
          t(ddindx).uom := a14(indx);
          t(ddindx).uom_desc := a15(indx);
          t(ddindx).required_date := a16(indx);
          t(ddindx).required_quantity := a17(indx);
          t(ddindx).scheduled_date := a18(indx);
          t(ddindx).scheduled_quantity := a19(indx);
          t(ddindx).issued_quantity := a20(indx);
          t(ddindx).exception_date := a21(indx);
          t(ddindx).reserved_quantity := a22(indx);
          t(ddindx).onhand_quantity := a23(indx);
          t(ddindx).qty_per_assembly := a24(indx);
          t(ddindx).subinventory := a25(indx);
          t(ddindx).locator_id := a26(indx);
          t(ddindx).locator_segments := a27(indx);
          t(ddindx).serial_number := a28(indx);
          t(ddindx).lot := a29(indx);
          t(ddindx).revision := a30(indx);
          t(ddindx).item_source_wo_id := a31(indx);
          t(ddindx).item_source_wo_name := a32(indx);
          t(ddindx).item_source_wop_id := a33(indx);
          t(ddindx).item_source_wop_seq := a34(indx);
          t(ddindx).is_serialized := a35(indx);
          t(ddindx).is_lot_controlled := a36(indx);
          t(ddindx).is_revision_controlled := a37(indx);
          t(ddindx).diposition_id := a38(indx);
          t(ddindx).diposition_name := a39(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_prd_mrshl_pvt.available_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).scheduled_material_id;
          a1(indx) := t(ddindx).inventory_item_id;
          a2(indx) := t(ddindx).item_name;
          a3(indx) := t(ddindx).item_desc;
          a4(indx) := t(ddindx).workorder_id;
          a5(indx) := t(ddindx).workorder_name;
          a6(indx) := t(ddindx).wip_entity_id;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).visit_id;
          a9(indx) := t(ddindx).wo_status_code;
          a10(indx) := t(ddindx).wo_status;
          a11(indx) := t(ddindx).wo_operation_id;
          a12(indx) := t(ddindx).op_seq;
          a13(indx) := t(ddindx).quantity;
          a14(indx) := t(ddindx).uom;
          a15(indx) := t(ddindx).uom_desc;
          a16(indx) := t(ddindx).required_date;
          a17(indx) := t(ddindx).required_quantity;
          a18(indx) := t(ddindx).scheduled_date;
          a19(indx) := t(ddindx).scheduled_quantity;
          a20(indx) := t(ddindx).issued_quantity;
          a21(indx) := t(ddindx).exception_date;
          a22(indx) := t(ddindx).reserved_quantity;
          a23(indx) := t(ddindx).onhand_quantity;
          a24(indx) := t(ddindx).qty_per_assembly;
          a25(indx) := t(ddindx).subinventory;
          a26(indx) := t(ddindx).locator_id;
          a27(indx) := t(ddindx).locator_segments;
          a28(indx) := t(ddindx).serial_number;
          a29(indx) := t(ddindx).lot;
          a30(indx) := t(ddindx).revision;
          a31(indx) := t(ddindx).item_source_wo_id;
          a32(indx) := t(ddindx).item_source_wo_name;
          a33(indx) := t(ddindx).item_source_wop_id;
          a34(indx) := t(ddindx).item_source_wop_seq;
          a35(indx) := t(ddindx).is_serialized;
          a36(indx) := t(ddindx).is_lot_controlled;
          a37(indx) := t(ddindx).is_revision_controlled;
          a38(indx) := t(ddindx).diposition_id;
          a39(indx) := t(ddindx).diposition_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_prd_mrshl_pvt.mrshl_details_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).unit_header_id := a0(indx);
          t(ddindx).unit_name := a1(indx);
          t(ddindx).relationship_id := a2(indx);
          t(ddindx).parent_rel_id := a3(indx);
          t(ddindx).root_instance_id := a4(indx);
          t(ddindx).position := a5(indx);
          t(ddindx).is_position_ser_ctrld := a6(indx);
          t(ddindx).curr_item_id := a7(indx);
          t(ddindx).curr_instance_id := a8(indx);
          t(ddindx).parent_instance_id := a9(indx);
          t(ddindx).allowed_qty := a10(indx);
          t(ddindx).curr_item_number := a11(indx);
          t(ddindx).curr_serial_number := a12(indx);
          t(ddindx).curr_instld_qty := a13(indx);
          t(ddindx).req_qty := a14(indx);
          t(ddindx).issued_qty := a15(indx);
          t(ddindx).available_qty := a16(indx);
          t(ddindx).not_available_qty := a17(indx);
          t(ddindx).compl_wo_count := a18(indx);
          t(ddindx).total_wo_count := a19(indx);
          t(ddindx).cumm_req_qty := a20(indx);
          t(ddindx).cumm_issued_qty := a21(indx);
          t(ddindx).cumm_available_qty := a22(indx);
          t(ddindx).cumm_not_available_qty := a23(indx);
          t(ddindx).cumm_compl_wo_count := a24(indx);
          t(ddindx).cumm_total_wo_count := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_prd_mrshl_pvt.mrshl_details_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).unit_header_id;
          a1(indx) := t(ddindx).unit_name;
          a2(indx) := t(ddindx).relationship_id;
          a3(indx) := t(ddindx).parent_rel_id;
          a4(indx) := t(ddindx).root_instance_id;
          a5(indx) := t(ddindx).position;
          a6(indx) := t(ddindx).is_position_ser_ctrld;
          a7(indx) := t(ddindx).curr_item_id;
          a8(indx) := t(ddindx).curr_instance_id;
          a9(indx) := t(ddindx).parent_instance_id;
          a10(indx) := t(ddindx).allowed_qty;
          a11(indx) := t(ddindx).curr_item_number;
          a12(indx) := t(ddindx).curr_serial_number;
          a13(indx) := t(ddindx).curr_instld_qty;
          a14(indx) := t(ddindx).req_qty;
          a15(indx) := t(ddindx).issued_qty;
          a16(indx) := t(ddindx).available_qty;
          a17(indx) := t(ddindx).not_available_qty;
          a18(indx) := t(ddindx).compl_wo_count;
          a19(indx) := t(ddindx).total_wo_count;
          a20(indx) := t(ddindx).cumm_req_qty;
          a21(indx) := t(ddindx).cumm_issued_qty;
          a22(indx) := t(ddindx).cumm_available_qty;
          a23(indx) := t(ddindx).cumm_not_available_qty;
          a24(indx) := t(ddindx).cumm_compl_wo_count;
          a25(indx) := t(ddindx).cumm_total_wo_count;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure get_unavailable_items(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_DATE_TABLE
    , p7_a17 out nocopy JTF_NUMBER_TABLE
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_DATE_TABLE
    , p7_a20 out nocopy JTF_NUMBER_TABLE
    , p7_a21 out nocopy JTF_DATE_TABLE
    , p7_a22 out nocopy JTF_NUMBER_TABLE
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_mrshl_search_rec ahl_prd_mrshl_pvt.mrshl_search_rec_type;
    ddx_unavailable_items_tbl ahl_prd_mrshl_pvt.unavailable_items_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_mrshl_search_rec.visit_id := p6_a0;
    ddp_mrshl_search_rec.item_instance_id := p6_a1;
    ddp_mrshl_search_rec.workorder_id := p6_a2;
    ddp_mrshl_search_rec.workorder_name := p6_a3;
    ddp_mrshl_search_rec.item_name := p6_a4;
    ddp_mrshl_search_rec.item_desc := p6_a5;
    ddp_mrshl_search_rec.search_mode := p6_a6;





    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_mrshl_pvt.get_unavailable_items(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      ddp_mrshl_search_rec,
      ddx_unavailable_items_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ahl_prd_mrshl_pvt_w.rosetta_table_copy_out_p2(ddx_unavailable_items_tbl, p7_a0
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
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      );



  end;

  procedure get_available_items(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_DATE_TABLE
    , p7_a17 out nocopy JTF_NUMBER_TABLE
    , p7_a18 out nocopy JTF_DATE_TABLE
    , p7_a19 out nocopy JTF_NUMBER_TABLE
    , p7_a20 out nocopy JTF_NUMBER_TABLE
    , p7_a21 out nocopy JTF_DATE_TABLE
    , p7_a22 out nocopy JTF_NUMBER_TABLE
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_mrshl_search_rec ahl_prd_mrshl_pvt.mrshl_search_rec_type;
    ddx_available_items_tbl ahl_prd_mrshl_pvt.available_items_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_mrshl_search_rec.visit_id := p6_a0;
    ddp_mrshl_search_rec.item_instance_id := p6_a1;
    ddp_mrshl_search_rec.workorder_id := p6_a2;
    ddp_mrshl_search_rec.workorder_name := p6_a3;
    ddp_mrshl_search_rec.item_name := p6_a4;
    ddp_mrshl_search_rec.item_desc := p6_a5;
    ddp_mrshl_search_rec.search_mode := p6_a6;





    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_mrshl_pvt.get_available_items(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      ddp_mrshl_search_rec,
      ddx_available_items_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ahl_prd_mrshl_pvt_w.rosetta_table_copy_out_p4(ddx_available_items_tbl, p7_a0
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
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      );



  end;

  procedure get_mrshl_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_unit_header_id  NUMBER
    , p_item_instance_id  NUMBER
    , p_visit_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_mrshl_details_tbl ahl_prd_mrshl_pvt.mrshl_details_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_mrshl_pvt.get_mrshl_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      p_unit_header_id,
      p_item_instance_id,
      p_visit_id,
      ddx_mrshl_details_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_prd_mrshl_pvt_w.rosetta_table_copy_out_p6(ddx_mrshl_details_tbl, p9_a0
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
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      );



  end;

end ahl_prd_mrshl_pvt_w;

/
