--------------------------------------------------------
--  DDL for Package Body AHL_PRD_MTLTXN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_MTLTXN_PVT_W" as
  /* $Header: AHLWMTXB.pls 120.4.12010000.3 2008/11/19 06:09:46 jkjain ship $ */
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

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_prd_mtltxn_pvt.ahl_mtltxn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ahl_mtltxn_id := a0(indx);
          t(ddindx).workorder_id := a1(indx);
          t(ddindx).workorder_name := a2(indx);
          t(ddindx).workorder_status := a3(indx);
          t(ddindx).workorder_status_code := a4(indx);
          t(ddindx).inventory_item_id := a5(indx);
          t(ddindx).inventory_item_segments := a6(indx);
          t(ddindx).inventory_item_description := a7(indx);
          t(ddindx).item_instance_number := a8(indx);
          t(ddindx).item_instance_id := a9(indx);
          t(ddindx).revision := a10(indx);
          t(ddindx).organization_id := a11(indx);
          t(ddindx).condition := a12(indx);
          t(ddindx).condition_desc := a13(indx);
          t(ddindx).subinventory_name := a14(indx);
          t(ddindx).locator_id := a15(indx);
          t(ddindx).locator_segments := a16(indx);
          t(ddindx).quantity := a17(indx);
          t(ddindx).net_total_qty := a18(indx);
          t(ddindx).net_quantity := a19(indx);
          t(ddindx).uom := a20(indx);
          t(ddindx).uom_desc := a21(indx);
          t(ddindx).transaction_type_id := a22(indx);
          t(ddindx).transaction_type_name := a23(indx);
          t(ddindx).transaction_reference := a24(indx);
          t(ddindx).wip_entity_id := a25(indx);
          t(ddindx).operation_seq_num := a26(indx);
          t(ddindx).serial_number := a27(indx);
          t(ddindx).lot_number := a28(indx);
          t(ddindx).reason_id := a29(indx);
          t(ddindx).reason_name := a30(indx);
          t(ddindx).problem_code := a31(indx);
          t(ddindx).problem_code_meaning := a32(indx);
          t(ddindx).target_visit_id := a33(indx);
          t(ddindx).sr_summary := a34(indx);
          t(ddindx).qa_collection_id := a35(indx);
          t(ddindx).workorder_operation_id := a36(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).recepient_id := a38(indx);
          t(ddindx).recepient_name := a39(indx);
          t(ddindx).disposition_id := a40(indx);
          t(ddindx).disposition_name := a41(indx);
          t(ddindx).move_to_project_flag := a42(indx);
          t(ddindx).visit_locator_flag := a43(indx);
          t(ddindx).create_wo_option := a44(indx);
          t(ddindx).attribute_category := a45(indx);
          t(ddindx).attribute1 := a46(indx);
          t(ddindx).attribute2 := a47(indx);
          t(ddindx).attribute3 := a48(indx);
          t(ddindx).attribute4 := a49(indx);
          t(ddindx).attribute5 := a50(indx);
          t(ddindx).attribute6 := a51(indx);
          t(ddindx).attribute7 := a52(indx);
          t(ddindx).attribute8 := a53(indx);
          t(ddindx).attribute9 := a54(indx);
          t(ddindx).attribute10 := a55(indx);
          t(ddindx).attribute11 := a56(indx);
          t(ddindx).attribute12 := a57(indx);
          t(ddindx).attribute13 := a58(indx);
          t(ddindx).attribute14 := a59(indx);
          t(ddindx).attribute15 := a60(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_prd_mtltxn_pvt.ahl_mtltxn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
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
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).ahl_mtltxn_id;
          a1(indx) := t(ddindx).workorder_id;
          a2(indx) := t(ddindx).workorder_name;
          a3(indx) := t(ddindx).workorder_status;
          a4(indx) := t(ddindx).workorder_status_code;
          a5(indx) := t(ddindx).inventory_item_id;
          a6(indx) := t(ddindx).inventory_item_segments;
          a7(indx) := t(ddindx).inventory_item_description;
          a8(indx) := t(ddindx).item_instance_number;
          a9(indx) := t(ddindx).item_instance_id;
          a10(indx) := t(ddindx).revision;
          a11(indx) := t(ddindx).organization_id;
          a12(indx) := t(ddindx).condition;
          a13(indx) := t(ddindx).condition_desc;
          a14(indx) := t(ddindx).subinventory_name;
          a15(indx) := t(ddindx).locator_id;
          a16(indx) := t(ddindx).locator_segments;
          a17(indx) := t(ddindx).quantity;
          a18(indx) := t(ddindx).net_total_qty;
          a19(indx) := t(ddindx).net_quantity;
          a20(indx) := t(ddindx).uom;
          a21(indx) := t(ddindx).uom_desc;
          a22(indx) := t(ddindx).transaction_type_id;
          a23(indx) := t(ddindx).transaction_type_name;
          a24(indx) := t(ddindx).transaction_reference;
          a25(indx) := t(ddindx).wip_entity_id;
          a26(indx) := t(ddindx).operation_seq_num;
          a27(indx) := t(ddindx).serial_number;
          a28(indx) := t(ddindx).lot_number;
          a29(indx) := t(ddindx).reason_id;
          a30(indx) := t(ddindx).reason_name;
          a31(indx) := t(ddindx).problem_code;
          a32(indx) := t(ddindx).problem_code_meaning;
          a33(indx) := t(ddindx).target_visit_id;
          a34(indx) := t(ddindx).sr_summary;
          a35(indx) := t(ddindx).qa_collection_id;
          a36(indx) := t(ddindx).workorder_operation_id;
          a37(indx) := t(ddindx).transaction_date;
          a38(indx) := t(ddindx).recepient_id;
          a39(indx) := t(ddindx).recepient_name;
          a40(indx) := t(ddindx).disposition_id;
          a41(indx) := t(ddindx).disposition_name;
          a42(indx) := t(ddindx).move_to_project_flag;
          a43(indx) := t(ddindx).visit_locator_flag;
          a44(indx) := t(ddindx).create_wo_option;
          a45(indx) := t(ddindx).attribute_category;
          a46(indx) := t(ddindx).attribute1;
          a47(indx) := t(ddindx).attribute2;
          a48(indx) := t(ddindx).attribute3;
          a49(indx) := t(ddindx).attribute4;
          a50(indx) := t(ddindx).attribute5;
          a51(indx) := t(ddindx).attribute6;
          a52(indx) := t(ddindx).attribute7;
          a53(indx) := t(ddindx).attribute8;
          a54(indx) := t(ddindx).attribute9;
          a55(indx) := t(ddindx).attribute10;
          a56(indx) := t(ddindx).attribute11;
          a57(indx) := t(ddindx).attribute12;
          a58(indx) := t(ddindx).attribute13;
          a59(indx) := t(ddindx).attribute14;
          a60(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_prd_mtltxn_pvt.ahl_mtl_txn_id_tbl, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_prd_mtltxn_pvt.ahl_mtl_txn_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p6;

  procedure perform_mtl_txn(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_create_sr  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a17 in out nocopy JTF_NUMBER_TABLE
    , p7_a18 in out nocopy JTF_NUMBER_TABLE
    , p7_a19 in out nocopy JTF_NUMBER_TABLE
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 in out nocopy JTF_NUMBER_TABLE
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a25 in out nocopy JTF_NUMBER_TABLE
    , p7_a26 in out nocopy JTF_NUMBER_TABLE
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 in out nocopy JTF_NUMBER_TABLE
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a33 in out nocopy JTF_NUMBER_TABLE
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a35 in out nocopy JTF_NUMBER_TABLE
    , p7_a36 in out nocopy JTF_NUMBER_TABLE
    , p7_a37 in out nocopy JTF_DATE_TABLE
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_ahl_mtltxn_tbl ahl_prd_mtltxn_pvt.ahl_mtltxn_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ahl_prd_mtltxn_pvt_w.rosetta_table_copy_in_p5(ddp_x_ahl_mtltxn_tbl, p7_a0
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
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_mtltxn_pvt.perform_mtl_txn(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      p_create_sr,
      ddp_x_ahl_mtltxn_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ahl_prd_mtltxn_pvt_w.rosetta_table_copy_out_p5(ddp_x_ahl_mtltxn_tbl, p7_a0
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
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      );



  end;

  procedure validate_txn_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  NUMBER
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  NUMBER
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  VARCHAR2
    , p0_a22 in out nocopy  NUMBER
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  VARCHAR2
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  VARCHAR2
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  VARCHAR2
    , p0_a32 in out nocopy  VARCHAR2
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  NUMBER
    , p0_a37 in out nocopy  DATE
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  NUMBER
    , p0_a41 in out nocopy  VARCHAR2
    , p0_a42 in out nocopy  VARCHAR2
    , p0_a43 in out nocopy  VARCHAR2
    , p0_a44 in out nocopy  VARCHAR2
    , p0_a45 in out nocopy  VARCHAR2
    , p0_a46 in out nocopy  VARCHAR2
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  VARCHAR2
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  VARCHAR2
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  VARCHAR2
    , x_item_instance_id out nocopy  NUMBER
    , x_eam_item_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_ahl_mtltxn_rec ahl_prd_mtltxn_pvt.ahl_mtltxn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_x_ahl_mtltxn_rec.ahl_mtltxn_id := p0_a0;
    ddp_x_ahl_mtltxn_rec.workorder_id := p0_a1;
    ddp_x_ahl_mtltxn_rec.workorder_name := p0_a2;
    ddp_x_ahl_mtltxn_rec.workorder_status := p0_a3;
    ddp_x_ahl_mtltxn_rec.workorder_status_code := p0_a4;
    ddp_x_ahl_mtltxn_rec.inventory_item_id := p0_a5;
    ddp_x_ahl_mtltxn_rec.inventory_item_segments := p0_a6;
    ddp_x_ahl_mtltxn_rec.inventory_item_description := p0_a7;
    ddp_x_ahl_mtltxn_rec.item_instance_number := p0_a8;
    ddp_x_ahl_mtltxn_rec.item_instance_id := p0_a9;
    ddp_x_ahl_mtltxn_rec.revision := p0_a10;
    ddp_x_ahl_mtltxn_rec.organization_id := p0_a11;
    ddp_x_ahl_mtltxn_rec.condition := p0_a12;
    ddp_x_ahl_mtltxn_rec.condition_desc := p0_a13;
    ddp_x_ahl_mtltxn_rec.subinventory_name := p0_a14;
    ddp_x_ahl_mtltxn_rec.locator_id := p0_a15;
    ddp_x_ahl_mtltxn_rec.locator_segments := p0_a16;
    ddp_x_ahl_mtltxn_rec.quantity := p0_a17;
    ddp_x_ahl_mtltxn_rec.net_total_qty := p0_a18;
    ddp_x_ahl_mtltxn_rec.net_quantity := p0_a19;
    ddp_x_ahl_mtltxn_rec.uom := p0_a20;
    ddp_x_ahl_mtltxn_rec.uom_desc := p0_a21;
    ddp_x_ahl_mtltxn_rec.transaction_type_id := p0_a22;
    ddp_x_ahl_mtltxn_rec.transaction_type_name := p0_a23;
    ddp_x_ahl_mtltxn_rec.transaction_reference := p0_a24;
    ddp_x_ahl_mtltxn_rec.wip_entity_id := p0_a25;
    ddp_x_ahl_mtltxn_rec.operation_seq_num := p0_a26;
    ddp_x_ahl_mtltxn_rec.serial_number := p0_a27;
    ddp_x_ahl_mtltxn_rec.lot_number := p0_a28;
    ddp_x_ahl_mtltxn_rec.reason_id := p0_a29;
    ddp_x_ahl_mtltxn_rec.reason_name := p0_a30;
    ddp_x_ahl_mtltxn_rec.problem_code := p0_a31;
    ddp_x_ahl_mtltxn_rec.problem_code_meaning := p0_a32;
    ddp_x_ahl_mtltxn_rec.target_visit_id := p0_a33;
    ddp_x_ahl_mtltxn_rec.sr_summary := p0_a34;
    ddp_x_ahl_mtltxn_rec.qa_collection_id := p0_a35;
    ddp_x_ahl_mtltxn_rec.workorder_operation_id := p0_a36;
    ddp_x_ahl_mtltxn_rec.transaction_date := rosetta_g_miss_date_in_map(p0_a37);
    ddp_x_ahl_mtltxn_rec.recepient_id := p0_a38;
    ddp_x_ahl_mtltxn_rec.recepient_name := p0_a39;
    ddp_x_ahl_mtltxn_rec.disposition_id := p0_a40;
    ddp_x_ahl_mtltxn_rec.disposition_name := p0_a41;
    ddp_x_ahl_mtltxn_rec.move_to_project_flag := p0_a42;
    ddp_x_ahl_mtltxn_rec.visit_locator_flag := p0_a43;
    ddp_x_ahl_mtltxn_rec.create_wo_option := p0_a44;
    ddp_x_ahl_mtltxn_rec.attribute_category := p0_a45;
    ddp_x_ahl_mtltxn_rec.attribute1 := p0_a46;
    ddp_x_ahl_mtltxn_rec.attribute2 := p0_a47;
    ddp_x_ahl_mtltxn_rec.attribute3 := p0_a48;
    ddp_x_ahl_mtltxn_rec.attribute4 := p0_a49;
    ddp_x_ahl_mtltxn_rec.attribute5 := p0_a50;
    ddp_x_ahl_mtltxn_rec.attribute6 := p0_a51;
    ddp_x_ahl_mtltxn_rec.attribute7 := p0_a52;
    ddp_x_ahl_mtltxn_rec.attribute8 := p0_a53;
    ddp_x_ahl_mtltxn_rec.attribute9 := p0_a54;
    ddp_x_ahl_mtltxn_rec.attribute10 := p0_a55;
    ddp_x_ahl_mtltxn_rec.attribute11 := p0_a56;
    ddp_x_ahl_mtltxn_rec.attribute12 := p0_a57;
    ddp_x_ahl_mtltxn_rec.attribute13 := p0_a58;
    ddp_x_ahl_mtltxn_rec.attribute14 := p0_a59;
    ddp_x_ahl_mtltxn_rec.attribute15 := p0_a60;






    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_mtltxn_pvt.validate_txn_rec(ddp_x_ahl_mtltxn_rec,
      x_item_instance_id,
      x_eam_item_type_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_x_ahl_mtltxn_rec.ahl_mtltxn_id;
    p0_a1 := ddp_x_ahl_mtltxn_rec.workorder_id;
    p0_a2 := ddp_x_ahl_mtltxn_rec.workorder_name;
    p0_a3 := ddp_x_ahl_mtltxn_rec.workorder_status;
    p0_a4 := ddp_x_ahl_mtltxn_rec.workorder_status_code;
    p0_a5 := ddp_x_ahl_mtltxn_rec.inventory_item_id;
    p0_a6 := ddp_x_ahl_mtltxn_rec.inventory_item_segments;
    p0_a7 := ddp_x_ahl_mtltxn_rec.inventory_item_description;
    p0_a8 := ddp_x_ahl_mtltxn_rec.item_instance_number;
    p0_a9 := ddp_x_ahl_mtltxn_rec.item_instance_id;
    p0_a10 := ddp_x_ahl_mtltxn_rec.revision;
    p0_a11 := ddp_x_ahl_mtltxn_rec.organization_id;
    p0_a12 := ddp_x_ahl_mtltxn_rec.condition;
    p0_a13 := ddp_x_ahl_mtltxn_rec.condition_desc;
    p0_a14 := ddp_x_ahl_mtltxn_rec.subinventory_name;
    p0_a15 := ddp_x_ahl_mtltxn_rec.locator_id;
    p0_a16 := ddp_x_ahl_mtltxn_rec.locator_segments;
    p0_a17 := ddp_x_ahl_mtltxn_rec.quantity;
    p0_a18 := ddp_x_ahl_mtltxn_rec.net_total_qty;
    p0_a19 := ddp_x_ahl_mtltxn_rec.net_quantity;
    p0_a20 := ddp_x_ahl_mtltxn_rec.uom;
    p0_a21 := ddp_x_ahl_mtltxn_rec.uom_desc;
    p0_a22 := ddp_x_ahl_mtltxn_rec.transaction_type_id;
    p0_a23 := ddp_x_ahl_mtltxn_rec.transaction_type_name;
    p0_a24 := ddp_x_ahl_mtltxn_rec.transaction_reference;
    p0_a25 := ddp_x_ahl_mtltxn_rec.wip_entity_id;
    p0_a26 := ddp_x_ahl_mtltxn_rec.operation_seq_num;
    p0_a27 := ddp_x_ahl_mtltxn_rec.serial_number;
    p0_a28 := ddp_x_ahl_mtltxn_rec.lot_number;
    p0_a29 := ddp_x_ahl_mtltxn_rec.reason_id;
    p0_a30 := ddp_x_ahl_mtltxn_rec.reason_name;
    p0_a31 := ddp_x_ahl_mtltxn_rec.problem_code;
    p0_a32 := ddp_x_ahl_mtltxn_rec.problem_code_meaning;
    p0_a33 := ddp_x_ahl_mtltxn_rec.target_visit_id;
    p0_a34 := ddp_x_ahl_mtltxn_rec.sr_summary;
    p0_a35 := ddp_x_ahl_mtltxn_rec.qa_collection_id;
    p0_a36 := ddp_x_ahl_mtltxn_rec.workorder_operation_id;
    p0_a37 := ddp_x_ahl_mtltxn_rec.transaction_date;
    p0_a38 := ddp_x_ahl_mtltxn_rec.recepient_id;
    p0_a39 := ddp_x_ahl_mtltxn_rec.recepient_name;
    p0_a40 := ddp_x_ahl_mtltxn_rec.disposition_id;
    p0_a41 := ddp_x_ahl_mtltxn_rec.disposition_name;
    p0_a42 := ddp_x_ahl_mtltxn_rec.move_to_project_flag;
    p0_a43 := ddp_x_ahl_mtltxn_rec.visit_locator_flag;
    p0_a44 := ddp_x_ahl_mtltxn_rec.create_wo_option;
    p0_a45 := ddp_x_ahl_mtltxn_rec.attribute_category;
    p0_a46 := ddp_x_ahl_mtltxn_rec.attribute1;
    p0_a47 := ddp_x_ahl_mtltxn_rec.attribute2;
    p0_a48 := ddp_x_ahl_mtltxn_rec.attribute3;
    p0_a49 := ddp_x_ahl_mtltxn_rec.attribute4;
    p0_a50 := ddp_x_ahl_mtltxn_rec.attribute5;
    p0_a51 := ddp_x_ahl_mtltxn_rec.attribute6;
    p0_a52 := ddp_x_ahl_mtltxn_rec.attribute7;
    p0_a53 := ddp_x_ahl_mtltxn_rec.attribute8;
    p0_a54 := ddp_x_ahl_mtltxn_rec.attribute9;
    p0_a55 := ddp_x_ahl_mtltxn_rec.attribute10;
    p0_a56 := ddp_x_ahl_mtltxn_rec.attribute11;
    p0_a57 := ddp_x_ahl_mtltxn_rec.attribute12;
    p0_a58 := ddp_x_ahl_mtltxn_rec.attribute13;
    p0_a59 := ddp_x_ahl_mtltxn_rec.attribute14;
    p0_a60 := ddp_x_ahl_mtltxn_rec.attribute15;





  end;

  procedure get_mtl_trans_returns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  DATE
    , p9_a5  DATE
    , p9_a6  VARCHAR2
    , p9_a7  NUMBER
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  NUMBER
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_NUMBER_TABLE
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_NUMBER_TABLE
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 in out nocopy JTF_NUMBER_TABLE
    , p10_a18 in out nocopy JTF_NUMBER_TABLE
    , p10_a19 in out nocopy JTF_NUMBER_TABLE
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 in out nocopy JTF_NUMBER_TABLE
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a25 in out nocopy JTF_NUMBER_TABLE
    , p10_a26 in out nocopy JTF_NUMBER_TABLE
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p10_a30 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a33 in out nocopy JTF_NUMBER_TABLE
    , p10_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a35 in out nocopy JTF_NUMBER_TABLE
    , p10_a36 in out nocopy JTF_NUMBER_TABLE
    , p10_a37 in out nocopy JTF_DATE_TABLE
    , p10_a38 in out nocopy JTF_NUMBER_TABLE
    , p10_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 in out nocopy JTF_NUMBER_TABLE
    , p10_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a60 in out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_prd_mtltxn_criteria_rec ahl_prd_mtltxn_pvt.prd_mtltxn_criteria_rec;
    ddx_ahl_mtltxn_tbl ahl_prd_mtltxn_pvt.ahl_mtltxn_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_prd_mtltxn_criteria_rec.job_number := p9_a0;
    ddp_prd_mtltxn_criteria_rec.priority := p9_a1;
    ddp_prd_mtltxn_criteria_rec.organization_name := p9_a2;
    ddp_prd_mtltxn_criteria_rec.concatenated_segments := p9_a3;
    ddp_prd_mtltxn_criteria_rec.requested_date_from := rosetta_g_miss_date_in_map(p9_a4);
    ddp_prd_mtltxn_criteria_rec.requested_date_to := rosetta_g_miss_date_in_map(p9_a5);
    ddp_prd_mtltxn_criteria_rec.incident_number := p9_a6;
    ddp_prd_mtltxn_criteria_rec.visit_number := p9_a7;
    ddp_prd_mtltxn_criteria_rec.department_name := p9_a8;
    ddp_prd_mtltxn_criteria_rec.disposition_name := p9_a9;
    ddp_prd_mtltxn_criteria_rec.transaction_type := p9_a10;

    ahl_prd_mtltxn_pvt_w.rosetta_table_copy_in_p5(ddx_ahl_mtltxn_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      , p10_a56
      , p10_a57
      , p10_a58
      , p10_a59
      , p10_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_mtltxn_pvt.get_mtl_trans_returns(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prd_mtltxn_criteria_rec,
      ddx_ahl_mtltxn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ahl_prd_mtltxn_pvt_w.rosetta_table_copy_out_p5(ddx_ahl_mtltxn_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      , p10_a56
      , p10_a57
      , p10_a58
      , p10_a59
      , p10_a60
      );
  end;

end ahl_prd_mtltxn_pvt_w;

/
