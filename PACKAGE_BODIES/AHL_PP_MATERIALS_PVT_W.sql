--------------------------------------------------------
--  DDL for Package Body AHL_PP_MATERIALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PP_MATERIALS_PVT_W" as
  /* $Header: AHLWPPMB.pls 120.2 2008/01/31 09:08:39 bachandr ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_pp_materials_pvt.req_material_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
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
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_3000
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).schedule_designator := a3(indx);
          t(ddindx).visit_id := a4(indx);
          t(ddindx).visit_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).visit_task_id := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).request_id := a9(indx);
          t(ddindx).process_status := a10(indx);
          t(ddindx).error_message := a11(indx);
          t(ddindx).transaction_id := a12(indx);
          t(ddindx).concatenated_segments := a13(indx);
          t(ddindx).item_description := a14(indx);
          t(ddindx).rt_oper_material_id := a15(indx);
          t(ddindx).requested_quantity := a16(indx);
          t(ddindx).requested_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).uom_code := a18(indx);
          t(ddindx).uom_meaning := a19(indx);
          t(ddindx).scheduled_quantity := a20(indx);
          t(ddindx).job_number := a21(indx);
          t(ddindx).required_quantity := a22(indx);
          t(ddindx).quantity_per_assembly := a23(indx);
          t(ddindx).workorder_id := a24(indx);
          t(ddindx).wip_entity_id := a25(indx);
          t(ddindx).operation_sequence := a26(indx);
          t(ddindx).operation_code := a27(indx);
          t(ddindx).item_group_id := a28(indx);
          t(ddindx).serial_number := a29(indx);
          t(ddindx).instance_id := a30(indx);
          t(ddindx).supply_type := a31(indx);
          t(ddindx).sub_inventory := a32(indx);
          t(ddindx).location := a33(indx);
          t(ddindx).program_id := a34(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_updated_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).description := a37(indx);
          t(ddindx).department_id := a38(indx);
          t(ddindx).project_task_id := a39(indx);
          t(ddindx).project_id := a40(indx);
          t(ddindx).workorder_operation_id := a41(indx);
          t(ddindx).status := a42(indx);
          t(ddindx).attribute_category := a43(indx);
          t(ddindx).attribute1 := a44(indx);
          t(ddindx).attribute2 := a45(indx);
          t(ddindx).attribute3 := a46(indx);
          t(ddindx).attribute4 := a47(indx);
          t(ddindx).attribute5 := a48(indx);
          t(ddindx).attribute6 := a49(indx);
          t(ddindx).attribute7 := a50(indx);
          t(ddindx).attribute8 := a51(indx);
          t(ddindx).attribute9 := a52(indx);
          t(ddindx).attribute10 := a53(indx);
          t(ddindx).attribute11 := a54(indx);
          t(ddindx).attribute12 := a55(indx);
          t(ddindx).attribute13 := a56(indx);
          t(ddindx).attribute14 := a57(indx);
          t(ddindx).attribute15 := a58(indx);
          t(ddindx).mrp_net_flag := a59(indx);
          t(ddindx).notify_text := a60(indx);
          t(ddindx).operation_flag := a61(indx);
          t(ddindx).repair_item := a62(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_pp_materials_pvt.req_material_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_3000
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
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
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_3000();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
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
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_3000();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
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
        a61.extend(t.count);
        a62.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).schedule_material_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).schedule_designator;
          a4(indx) := t(ddindx).visit_id;
          a5(indx) := t(ddindx).visit_start_date;
          a6(indx) := t(ddindx).visit_task_id;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).scheduled_date;
          a9(indx) := t(ddindx).request_id;
          a10(indx) := t(ddindx).process_status;
          a11(indx) := t(ddindx).error_message;
          a12(indx) := t(ddindx).transaction_id;
          a13(indx) := t(ddindx).concatenated_segments;
          a14(indx) := t(ddindx).item_description;
          a15(indx) := t(ddindx).rt_oper_material_id;
          a16(indx) := t(ddindx).requested_quantity;
          a17(indx) := t(ddindx).requested_date;
          a18(indx) := t(ddindx).uom_code;
          a19(indx) := t(ddindx).uom_meaning;
          a20(indx) := t(ddindx).scheduled_quantity;
          a21(indx) := t(ddindx).job_number;
          a22(indx) := t(ddindx).required_quantity;
          a23(indx) := t(ddindx).quantity_per_assembly;
          a24(indx) := t(ddindx).workorder_id;
          a25(indx) := t(ddindx).wip_entity_id;
          a26(indx) := t(ddindx).operation_sequence;
          a27(indx) := t(ddindx).operation_code;
          a28(indx) := t(ddindx).item_group_id;
          a29(indx) := t(ddindx).serial_number;
          a30(indx) := t(ddindx).instance_id;
          a31(indx) := t(ddindx).supply_type;
          a32(indx) := t(ddindx).sub_inventory;
          a33(indx) := t(ddindx).location;
          a34(indx) := t(ddindx).program_id;
          a35(indx) := t(ddindx).program_update_date;
          a36(indx) := t(ddindx).last_updated_date;
          a37(indx) := t(ddindx).description;
          a38(indx) := t(ddindx).department_id;
          a39(indx) := t(ddindx).project_task_id;
          a40(indx) := t(ddindx).project_id;
          a41(indx) := t(ddindx).workorder_operation_id;
          a42(indx) := t(ddindx).status;
          a43(indx) := t(ddindx).attribute_category;
          a44(indx) := t(ddindx).attribute1;
          a45(indx) := t(ddindx).attribute2;
          a46(indx) := t(ddindx).attribute3;
          a47(indx) := t(ddindx).attribute4;
          a48(indx) := t(ddindx).attribute5;
          a49(indx) := t(ddindx).attribute6;
          a50(indx) := t(ddindx).attribute7;
          a51(indx) := t(ddindx).attribute8;
          a52(indx) := t(ddindx).attribute9;
          a53(indx) := t(ddindx).attribute10;
          a54(indx) := t(ddindx).attribute11;
          a55(indx) := t(ddindx).attribute12;
          a56(indx) := t(ddindx).attribute13;
          a57(indx) := t(ddindx).attribute14;
          a58(indx) := t(ddindx).attribute15;
          a59(indx) := t(ddindx).mrp_net_flag;
          a60(indx) := t(ddindx).notify_text;
          a61(indx) := t(ddindx).operation_flag;
          a62(indx) := t(ddindx).repair_item;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_pp_materials_pvt.sch_material_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).concatenated_segments := a3(indx);
          t(ddindx).item_description := a4(indx);
          t(ddindx).rt_oper_material_id := a5(indx);
          t(ddindx).requested_quantity := a6(indx);
          t(ddindx).request_id := a7(indx);
          t(ddindx).visit_id := a8(indx);
          t(ddindx).visit_task_id := a9(indx);
          t(ddindx).organization_id := a10(indx);
          t(ddindx).requested_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).uom := a12(indx);
          t(ddindx).scheduled_quantity := a13(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).process_status := a15(indx);
          t(ddindx).job_number := a16(indx);
          t(ddindx).workorder_id := a17(indx);
          t(ddindx).operation_sequence := a18(indx);
          t(ddindx).item_group_id := a19(indx);
          t(ddindx).serial_number := a20(indx);
          t(ddindx).sub_inventory := a21(indx);
          t(ddindx).location := a22(indx);
          t(ddindx).location_desc := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_pp_materials_pvt.sch_material_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).schedule_material_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).concatenated_segments;
          a4(indx) := t(ddindx).item_description;
          a5(indx) := t(ddindx).rt_oper_material_id;
          a6(indx) := t(ddindx).requested_quantity;
          a7(indx) := t(ddindx).request_id;
          a8(indx) := t(ddindx).visit_id;
          a9(indx) := t(ddindx).visit_task_id;
          a10(indx) := t(ddindx).organization_id;
          a11(indx) := t(ddindx).requested_date;
          a12(indx) := t(ddindx).uom;
          a13(indx) := t(ddindx).scheduled_quantity;
          a14(indx) := t(ddindx).scheduled_date;
          a15(indx) := t(ddindx).process_status;
          a16(indx) := t(ddindx).job_number;
          a17(indx) := t(ddindx).workorder_id;
          a18(indx) := t(ddindx).operation_sequence;
          a19(indx) := t(ddindx).item_group_id;
          a20(indx) := t(ddindx).serial_number;
          a21(indx) := t(ddindx).sub_inventory;
          a22(indx) := t(ddindx).location;
          a23(indx) := t(ddindx).location_desc;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_material_reqst(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_interface_flag  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a15 in out nocopy JTF_NUMBER_TABLE
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_DATE_TABLE
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_NUMBER_TABLE
    , p5_a29 in out nocopy JTF_NUMBER_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_NUMBER_TABLE
    , p5_a35 in out nocopy JTF_DATE_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_NUMBER_TABLE
    , p5_a40 in out nocopy JTF_NUMBER_TABLE
    , p5_a41 in out nocopy JTF_NUMBER_TABLE
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 in out nocopy JTF_NUMBER_TABLE
    , p5_a60 in out nocopy JTF_VARCHAR2_TABLE_3000
    , p5_a61 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_job_return_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_req_material_tbl ahl_pp_materials_pvt.req_material_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_pp_materials_pvt_w.rosetta_table_copy_in_p2(ddp_x_req_material_tbl, p5_a0
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
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );





    -- here's the delegated call to the old PL/SQL routine
    ahl_pp_materials_pvt.create_material_reqst(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_interface_flag,
      ddp_x_req_material_tbl,
      x_job_return_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_pp_materials_pvt_w.rosetta_table_copy_out_p2(ddp_x_req_material_tbl, p5_a0
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
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );




  end;

  procedure process_material_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a15 in out nocopy JTF_NUMBER_TABLE
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_DATE_TABLE
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_NUMBER_TABLE
    , p5_a29 in out nocopy JTF_NUMBER_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_NUMBER_TABLE
    , p5_a35 in out nocopy JTF_DATE_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_NUMBER_TABLE
    , p5_a40 in out nocopy JTF_NUMBER_TABLE
    , p5_a41 in out nocopy JTF_NUMBER_TABLE
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 in out nocopy JTF_NUMBER_TABLE
    , p5_a60 in out nocopy JTF_VARCHAR2_TABLE_3000
    , p5_a61 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_req_material_tbl ahl_pp_materials_pvt.req_material_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_pp_materials_pvt_w.rosetta_table_copy_in_p2(ddp_x_req_material_tbl, p5_a0
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
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_pp_materials_pvt.process_material_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_req_material_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_pp_materials_pvt_w.rosetta_table_copy_out_p2(ddp_x_req_material_tbl, p5_a0
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
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );



  end;

  procedure log_transaction_record(p_wo_operation_txn_id  NUMBER
    , p_object_version_number  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
    , p_load_type_code  NUMBER
    , p_transaction_type_code  NUMBER
    , p_workorder_operation_id  NUMBER
    , p_operation_resource_id  NUMBER
    , p_schedule_material_id  NUMBER
    , p_bom_resource_id  NUMBER
    , p_cost_basis_code  NUMBER
    , p_total_required  NUMBER
    , p_assigned_units  NUMBER
    , p_autocharge_type_code  NUMBER
    , p_standard_rate_flag_code  NUMBER
    , p_applied_resource_units  NUMBER
    , p_applied_resource_value  NUMBER
    , p_inventory_item_id  NUMBER
    , p_scheduled_quantity  NUMBER
    , p_scheduled_date  date
    , p_mrp_net_flag  NUMBER
    , p_quantity_per_assembly  NUMBER
    , p_required_quantity  NUMBER
    , p_supply_locator_id  NUMBER
    , p_supply_subinventory  NUMBER
    , p_date_required  date
    , p_operation_type_code  VARCHAR2
    , p_res_sched_start_date  date
    , p_res_sched_end_date  date
    , p_op_scheduled_start_date  date
    , p_op_scheduled_end_date  date
    , p_op_actual_start_date  date
    , p_op_actual_end_date  date
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  )

  as
    ddp_last_update_date date;
    ddp_creation_date date;
    ddp_scheduled_date date;
    ddp_date_required date;
    ddp_res_sched_start_date date;
    ddp_res_sched_end_date date;
    ddp_op_scheduled_start_date date;
    ddp_op_scheduled_end_date date;
    ddp_op_actual_start_date date;
    ddp_op_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);


















    ddp_scheduled_date := rosetta_g_miss_date_in_map(p_scheduled_date);






    ddp_date_required := rosetta_g_miss_date_in_map(p_date_required);


    ddp_res_sched_start_date := rosetta_g_miss_date_in_map(p_res_sched_start_date);

    ddp_res_sched_end_date := rosetta_g_miss_date_in_map(p_res_sched_end_date);

    ddp_op_scheduled_start_date := rosetta_g_miss_date_in_map(p_op_scheduled_start_date);

    ddp_op_scheduled_end_date := rosetta_g_miss_date_in_map(p_op_scheduled_end_date);

    ddp_op_actual_start_date := rosetta_g_miss_date_in_map(p_op_actual_start_date);

    ddp_op_actual_end_date := rosetta_g_miss_date_in_map(p_op_actual_end_date);

















    -- here's the delegated call to the old PL/SQL routine
    ahl_pp_materials_pvt.log_transaction_record(p_wo_operation_txn_id,
      p_object_version_number,
      ddp_last_update_date,
      p_last_updated_by,
      ddp_creation_date,
      p_created_by,
      p_last_update_login,
      p_load_type_code,
      p_transaction_type_code,
      p_workorder_operation_id,
      p_operation_resource_id,
      p_schedule_material_id,
      p_bom_resource_id,
      p_cost_basis_code,
      p_total_required,
      p_assigned_units,
      p_autocharge_type_code,
      p_standard_rate_flag_code,
      p_applied_resource_units,
      p_applied_resource_value,
      p_inventory_item_id,
      p_scheduled_quantity,
      ddp_scheduled_date,
      p_mrp_net_flag,
      p_quantity_per_assembly,
      p_required_quantity,
      p_supply_locator_id,
      p_supply_subinventory,
      ddp_date_required,
      p_operation_type_code,
      ddp_res_sched_start_date,
      ddp_res_sched_end_date,
      ddp_op_scheduled_start_date,
      ddp_op_scheduled_end_date,
      ddp_op_actual_start_date,
      ddp_op_actual_end_date,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















































  end;

  procedure material_notification(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_300
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_DATE_TABLE
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_NUMBER_TABLE
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_NUMBER_TABLE
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_NUMBER_TABLE
    , p4_a35 JTF_DATE_TABLE
    , p4_a36 JTF_DATE_TABLE
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_NUMBER_TABLE
    , p4_a40 JTF_NUMBER_TABLE
    , p4_a41 JTF_NUMBER_TABLE
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_NUMBER_TABLE
    , p4_a60 JTF_VARCHAR2_TABLE_3000
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_req_material_tbl ahl_pp_materials_pvt.req_material_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ahl_pp_materials_pvt_w.rosetta_table_copy_in_p2(ddp_req_material_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_pp_materials_pvt.material_notification(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_req_material_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ahl_pp_materials_pvt_w;

/
