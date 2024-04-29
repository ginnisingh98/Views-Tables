--------------------------------------------------------
--  DDL for Package Body AHL_VWP_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_RULES_PVT_W" as
  /* $Header: AHLWRULB.pls 120.1.12010000.4 2010/03/28 10:23:15 manesing ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_vwp_rules_pvt.mr_serial_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mr_id := a0(indx);
          t(ddindx).serial_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_vwp_rules_pvt.mr_serial_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).mr_id;
          a1(indx) := t(ddindx).serial_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_vwp_rules_pvt.item_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := a0(indx);
          t(ddindx).visit_task_id := a1(indx);
          t(ddindx).quantity := a2(indx);
          t(ddindx).duration := a3(indx);
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).uom_code := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_vwp_rules_pvt.item_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_id;
          a1(indx) := t(ddindx).visit_task_id;
          a2(indx) := t(ddindx).quantity;
          a3(indx) := t(ddindx).duration;
          a4(indx) := t(ddindx).effective_date;
          a5(indx) := t(ddindx).uom_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_vwp_rules_pvt.task_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_4000
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
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
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_DATE_TABLE
    , a56 JTF_DATE_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_DATE_TABLE
    , a67 JTF_DATE_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_DATE_TABLE
    , a77 JTF_DATE_TABLE
    , a78 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_task_id := a0(indx);
          t(ddindx).visit_task_number := a1(indx);
          t(ddindx).visit_id := a2(indx);
          t(ddindx).template_flag := a3(indx);
          t(ddindx).inventory_item_id := a4(indx);
          t(ddindx).item_organization_id := a5(indx);
          t(ddindx).item_name := a6(indx);
          t(ddindx).cost_parent_id := a7(indx);
          t(ddindx).cost_parent_number := a8(indx);
          t(ddindx).mr_route_id := a9(indx);
          t(ddindx).route_number := a10(indx);
          t(ddindx).mr_id := a11(indx);
          t(ddindx).mr_title := a12(indx);
          t(ddindx).unit_effectivity_id := a13(indx);
          t(ddindx).department_id := a14(indx);
          t(ddindx).dept_name := a15(indx);
          t(ddindx).service_request_id := a16(indx);
          t(ddindx).service_request_number := a17(indx);
          t(ddindx).originating_task_id := a18(indx);
          t(ddindx).orginating_task_number := a19(indx);
          t(ddindx).instance_id := a20(indx);
          t(ddindx).serial_number := a21(indx);
          t(ddindx).project_task_id := a22(indx);
          t(ddindx).project_task_number := a23(indx);
          t(ddindx).primary_visit_task_id := a24(indx);
          t(ddindx).start_from_hour := a25(indx);
          t(ddindx).duration := a26(indx);
          t(ddindx).task_type_code := a27(indx);
          t(ddindx).task_type_value := a28(indx);
          t(ddindx).visit_task_name := a29(indx);
          t(ddindx).description := a30(indx);
          t(ddindx).task_status_code := a31(indx);
          t(ddindx).task_status_value := a32(indx);
          t(ddindx).object_version_number := a33(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).last_updated_by := a35(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).created_by := a37(indx);
          t(ddindx).last_update_login := a38(indx);
          t(ddindx).attribute_category := a39(indx);
          t(ddindx).attribute1 := a40(indx);
          t(ddindx).attribute2 := a41(indx);
          t(ddindx).attribute3 := a42(indx);
          t(ddindx).attribute4 := a43(indx);
          t(ddindx).attribute5 := a44(indx);
          t(ddindx).attribute6 := a45(indx);
          t(ddindx).attribute7 := a46(indx);
          t(ddindx).attribute8 := a47(indx);
          t(ddindx).attribute9 := a48(indx);
          t(ddindx).attribute10 := a49(indx);
          t(ddindx).attribute11 := a50(indx);
          t(ddindx).attribute12 := a51(indx);
          t(ddindx).attribute13 := a52(indx);
          t(ddindx).attribute14 := a53(indx);
          t(ddindx).attribute15 := a54(indx);
          t(ddindx).task_start_date := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).task_end_date := rosetta_g_miss_date_in_map(a56(indx));
          t(ddindx).due_by_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).zone_name := a58(indx);
          t(ddindx).sub_zone_name := a59(indx);
          t(ddindx).tolerance_after := a60(indx);
          t(ddindx).tolerance_before := a61(indx);
          t(ddindx).tolerance_uom := a62(indx);
          t(ddindx).workorder_id := a63(indx);
          t(ddindx).wo_name := a64(indx);
          t(ddindx).wo_status := a65(indx);
          t(ddindx).wo_start_date := rosetta_g_miss_date_in_map(a66(indx));
          t(ddindx).wo_end_date := rosetta_g_miss_date_in_map(a67(indx));
          t(ddindx).operation_flag := a68(indx);
          t(ddindx).is_production_flag := a69(indx);
          t(ddindx).create_job_flag := a70(indx);
          t(ddindx).stage_id := a71(indx);
          t(ddindx).stage_name := a72(indx);
          t(ddindx).quantity := a73(indx);
          t(ddindx).uom := a74(indx);
          t(ddindx).instance_number := a75(indx);
          t(ddindx).past_task_start_date := rosetta_g_miss_date_in_map(a76(indx));
          t(ddindx).past_task_end_date := rosetta_g_miss_date_in_map(a77(indx));
          t(ddindx).route_id := a78(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_vwp_rules_pvt.task_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_DATE_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_DATE_TABLE
    , a67 out nocopy JTF_DATE_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_DATE_TABLE
    , a77 out nocopy JTF_DATE_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_4000();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
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
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_DATE_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_DATE_TABLE();
    a67 := JTF_DATE_TABLE();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_DATE_TABLE();
    a77 := JTF_DATE_TABLE();
    a78 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_4000();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
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
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_DATE_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_DATE_TABLE();
      a67 := JTF_DATE_TABLE();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_DATE_TABLE();
      a77 := JTF_DATE_TABLE();
      a78 := JTF_NUMBER_TABLE();
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
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).visit_task_id;
          a1(indx) := t(ddindx).visit_task_number;
          a2(indx) := t(ddindx).visit_id;
          a3(indx) := t(ddindx).template_flag;
          a4(indx) := t(ddindx).inventory_item_id;
          a5(indx) := t(ddindx).item_organization_id;
          a6(indx) := t(ddindx).item_name;
          a7(indx) := t(ddindx).cost_parent_id;
          a8(indx) := t(ddindx).cost_parent_number;
          a9(indx) := t(ddindx).mr_route_id;
          a10(indx) := t(ddindx).route_number;
          a11(indx) := t(ddindx).mr_id;
          a12(indx) := t(ddindx).mr_title;
          a13(indx) := t(ddindx).unit_effectivity_id;
          a14(indx) := t(ddindx).department_id;
          a15(indx) := t(ddindx).dept_name;
          a16(indx) := t(ddindx).service_request_id;
          a17(indx) := t(ddindx).service_request_number;
          a18(indx) := t(ddindx).originating_task_id;
          a19(indx) := t(ddindx).orginating_task_number;
          a20(indx) := t(ddindx).instance_id;
          a21(indx) := t(ddindx).serial_number;
          a22(indx) := t(ddindx).project_task_id;
          a23(indx) := t(ddindx).project_task_number;
          a24(indx) := t(ddindx).primary_visit_task_id;
          a25(indx) := t(ddindx).start_from_hour;
          a26(indx) := t(ddindx).duration;
          a27(indx) := t(ddindx).task_type_code;
          a28(indx) := t(ddindx).task_type_value;
          a29(indx) := t(ddindx).visit_task_name;
          a30(indx) := t(ddindx).description;
          a31(indx) := t(ddindx).task_status_code;
          a32(indx) := t(ddindx).task_status_value;
          a33(indx) := t(ddindx).object_version_number;
          a34(indx) := t(ddindx).last_update_date;
          a35(indx) := t(ddindx).last_updated_by;
          a36(indx) := t(ddindx).creation_date;
          a37(indx) := t(ddindx).created_by;
          a38(indx) := t(ddindx).last_update_login;
          a39(indx) := t(ddindx).attribute_category;
          a40(indx) := t(ddindx).attribute1;
          a41(indx) := t(ddindx).attribute2;
          a42(indx) := t(ddindx).attribute3;
          a43(indx) := t(ddindx).attribute4;
          a44(indx) := t(ddindx).attribute5;
          a45(indx) := t(ddindx).attribute6;
          a46(indx) := t(ddindx).attribute7;
          a47(indx) := t(ddindx).attribute8;
          a48(indx) := t(ddindx).attribute9;
          a49(indx) := t(ddindx).attribute10;
          a50(indx) := t(ddindx).attribute11;
          a51(indx) := t(ddindx).attribute12;
          a52(indx) := t(ddindx).attribute13;
          a53(indx) := t(ddindx).attribute14;
          a54(indx) := t(ddindx).attribute15;
          a55(indx) := t(ddindx).task_start_date;
          a56(indx) := t(ddindx).task_end_date;
          a57(indx) := t(ddindx).due_by_date;
          a58(indx) := t(ddindx).zone_name;
          a59(indx) := t(ddindx).sub_zone_name;
          a60(indx) := t(ddindx).tolerance_after;
          a61(indx) := t(ddindx).tolerance_before;
          a62(indx) := t(ddindx).tolerance_uom;
          a63(indx) := t(ddindx).workorder_id;
          a64(indx) := t(ddindx).wo_name;
          a65(indx) := t(ddindx).wo_status;
          a66(indx) := t(ddindx).wo_start_date;
          a67(indx) := t(ddindx).wo_end_date;
          a68(indx) := t(ddindx).operation_flag;
          a69(indx) := t(ddindx).is_production_flag;
          a70(indx) := t(ddindx).create_job_flag;
          a71(indx) := t(ddindx).stage_id;
          a72(indx) := t(ddindx).stage_name;
          a73(indx) := t(ddindx).quantity;
          a74(indx) := t(ddindx).uom;
          a75(indx) := t(ddindx).instance_number;
          a76(indx) := t(ddindx).past_task_start_date;
          a77(indx) := t(ddindx).past_task_end_date;
          a78(indx) := t(ddindx).route_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure insert_tasks(p_visit_id  NUMBER
    , p_unit_id  NUMBER
    , p_serial_id  NUMBER
    , p_service_id  NUMBER
    , p_dept_id  NUMBER
    , p_item_id  NUMBER
    , p_item_org_id  NUMBER
    , p_mr_id  NUMBER
    , p_mr_route_id  NUMBER
    , p_parent_id  NUMBER
    , p_flag  VARCHAR2
    , p_stage_id  NUMBER
    , p_past_task_start_date  date
    , p_past_task_end_date  date
    , p_quantity  NUMBER
    , p_task_start_date  date
    , x_task_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_past_task_start_date date;
    ddp_past_task_end_date date;
    ddp_task_start_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_past_task_start_date := rosetta_g_miss_date_in_map(p_past_task_start_date);

    ddp_past_task_end_date := rosetta_g_miss_date_in_map(p_past_task_end_date);


    ddp_task_start_date := rosetta_g_miss_date_in_map(p_task_start_date);





    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_rules_pvt.insert_tasks(p_visit_id,
      p_unit_id,
      p_serial_id,
      p_service_id,
      p_dept_id,
      p_item_id,
      p_item_org_id,
      p_mr_id,
      p_mr_route_id,
      p_parent_id,
      p_flag,
      p_stage_id,
      ddp_past_task_start_date,
      ddp_past_task_end_date,
      p_quantity,
      ddp_task_start_date,
      x_task_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















  end;

  procedure tech_dependency(p_visit_id  NUMBER
    , p_task_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_mr_serial_tbl ahl_vwp_rules_pvt.mr_serial_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ahl_vwp_rules_pvt_w.rosetta_table_copy_in_p3(ddp_mr_serial_tbl, p2_a0
      , p2_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_rules_pvt.tech_dependency(p_visit_id,
      p_task_type,
      ddp_mr_serial_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure create_tasks_for_mr(p_visit_id  NUMBER
    , p_unit_id  NUMBER
    , p_item_id  NUMBER
    , p_org_id  NUMBER
    , p_serial_id  NUMBER
    , p_mr_id  NUMBER
    , p_department_id  NUMBER
    , p_service_req_id  NUMBER
    , p_past_task_start_date  date
    , p_past_task_end_date  date
    , p_quantity  NUMBER
    , p_task_start_date  date
    , p_x_parent_mr_id in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_past_task_start_date date;
    ddp_past_task_end_date date;
    ddp_task_start_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_past_task_start_date := rosetta_g_miss_date_in_map(p_past_task_start_date);

    ddp_past_task_end_date := rosetta_g_miss_date_in_map(p_past_task_end_date);


    ddp_task_start_date := rosetta_g_miss_date_in_map(p_task_start_date);



    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_rules_pvt.create_tasks_for_mr(p_visit_id,
      p_unit_id,
      p_item_id,
      p_org_id,
      p_serial_id,
      p_mr_id,
      p_department_id,
      p_service_req_id,
      ddp_past_task_start_date,
      ddp_past_task_end_date,
      p_quantity,
      ddp_task_start_date,
      p_x_parent_mr_id,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure merge_for_unique_items(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_DATE_TABLE
    , p1_a5 JTF_VARCHAR2_TABLE_100
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_DATE_TABLE
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_item_tbl1 ahl_vwp_rules_pvt.item_tbl_type;
    ddp_item_tbl2 ahl_vwp_rules_pvt.item_tbl_type;
    ddx_item_tbl ahl_vwp_rules_pvt.item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ahl_vwp_rules_pvt_w.rosetta_table_copy_in_p4(ddp_item_tbl1, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      );

    ahl_vwp_rules_pvt_w.rosetta_table_copy_in_p4(ddp_item_tbl2, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      );


    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_rules_pvt.merge_for_unique_items(ddp_item_tbl1,
      ddp_item_tbl2,
      ddx_item_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    ahl_vwp_rules_pvt_w.rosetta_table_copy_out_p4(ddx_item_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      );
  end;

  procedure validate_past_task_dates(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  NUMBER
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  NUMBER
    , p0_a15 in out nocopy  VARCHAR2
    , p0_a16 in out nocopy  NUMBER
    , p0_a17 in out nocopy  VARCHAR2
    , p0_a18 in out nocopy  NUMBER
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  NUMBER
    , p0_a21 in out nocopy  VARCHAR2
    , p0_a22 in out nocopy  NUMBER
    , p0_a23 in out nocopy  NUMBER
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  VARCHAR2
    , p0_a29 in out nocopy  VARCHAR2
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  VARCHAR2
    , p0_a32 in out nocopy  VARCHAR2
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  DATE
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  DATE
    , p0_a37 in out nocopy  NUMBER
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  VARCHAR2
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
    , p0_a55 in out nocopy  DATE
    , p0_a56 in out nocopy  DATE
    , p0_a57 in out nocopy  DATE
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  NUMBER
    , p0_a61 in out nocopy  NUMBER
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  NUMBER
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  DATE
    , p0_a67 in out nocopy  DATE
    , p0_a68 in out nocopy  VARCHAR2
    , p0_a69 in out nocopy  VARCHAR2
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  NUMBER
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  NUMBER
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  DATE
    , p0_a77 in out nocopy  DATE
    , p0_a78 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_task_rec ahl_vwp_rules_pvt.task_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_task_rec.visit_task_id := p0_a0;
    ddp_task_rec.visit_task_number := p0_a1;
    ddp_task_rec.visit_id := p0_a2;
    ddp_task_rec.template_flag := p0_a3;
    ddp_task_rec.inventory_item_id := p0_a4;
    ddp_task_rec.item_organization_id := p0_a5;
    ddp_task_rec.item_name := p0_a6;
    ddp_task_rec.cost_parent_id := p0_a7;
    ddp_task_rec.cost_parent_number := p0_a8;
    ddp_task_rec.mr_route_id := p0_a9;
    ddp_task_rec.route_number := p0_a10;
    ddp_task_rec.mr_id := p0_a11;
    ddp_task_rec.mr_title := p0_a12;
    ddp_task_rec.unit_effectivity_id := p0_a13;
    ddp_task_rec.department_id := p0_a14;
    ddp_task_rec.dept_name := p0_a15;
    ddp_task_rec.service_request_id := p0_a16;
    ddp_task_rec.service_request_number := p0_a17;
    ddp_task_rec.originating_task_id := p0_a18;
    ddp_task_rec.orginating_task_number := p0_a19;
    ddp_task_rec.instance_id := p0_a20;
    ddp_task_rec.serial_number := p0_a21;
    ddp_task_rec.project_task_id := p0_a22;
    ddp_task_rec.project_task_number := p0_a23;
    ddp_task_rec.primary_visit_task_id := p0_a24;
    ddp_task_rec.start_from_hour := p0_a25;
    ddp_task_rec.duration := p0_a26;
    ddp_task_rec.task_type_code := p0_a27;
    ddp_task_rec.task_type_value := p0_a28;
    ddp_task_rec.visit_task_name := p0_a29;
    ddp_task_rec.description := p0_a30;
    ddp_task_rec.task_status_code := p0_a31;
    ddp_task_rec.task_status_value := p0_a32;
    ddp_task_rec.object_version_number := p0_a33;
    ddp_task_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_task_rec.last_updated_by := p0_a35;
    ddp_task_rec.creation_date := rosetta_g_miss_date_in_map(p0_a36);
    ddp_task_rec.created_by := p0_a37;
    ddp_task_rec.last_update_login := p0_a38;
    ddp_task_rec.attribute_category := p0_a39;
    ddp_task_rec.attribute1 := p0_a40;
    ddp_task_rec.attribute2 := p0_a41;
    ddp_task_rec.attribute3 := p0_a42;
    ddp_task_rec.attribute4 := p0_a43;
    ddp_task_rec.attribute5 := p0_a44;
    ddp_task_rec.attribute6 := p0_a45;
    ddp_task_rec.attribute7 := p0_a46;
    ddp_task_rec.attribute8 := p0_a47;
    ddp_task_rec.attribute9 := p0_a48;
    ddp_task_rec.attribute10 := p0_a49;
    ddp_task_rec.attribute11 := p0_a50;
    ddp_task_rec.attribute12 := p0_a51;
    ddp_task_rec.attribute13 := p0_a52;
    ddp_task_rec.attribute14 := p0_a53;
    ddp_task_rec.attribute15 := p0_a54;
    ddp_task_rec.task_start_date := rosetta_g_miss_date_in_map(p0_a55);
    ddp_task_rec.task_end_date := rosetta_g_miss_date_in_map(p0_a56);
    ddp_task_rec.due_by_date := rosetta_g_miss_date_in_map(p0_a57);
    ddp_task_rec.zone_name := p0_a58;
    ddp_task_rec.sub_zone_name := p0_a59;
    ddp_task_rec.tolerance_after := p0_a60;
    ddp_task_rec.tolerance_before := p0_a61;
    ddp_task_rec.tolerance_uom := p0_a62;
    ddp_task_rec.workorder_id := p0_a63;
    ddp_task_rec.wo_name := p0_a64;
    ddp_task_rec.wo_status := p0_a65;
    ddp_task_rec.wo_start_date := rosetta_g_miss_date_in_map(p0_a66);
    ddp_task_rec.wo_end_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_task_rec.operation_flag := p0_a68;
    ddp_task_rec.is_production_flag := p0_a69;
    ddp_task_rec.create_job_flag := p0_a70;
    ddp_task_rec.stage_id := p0_a71;
    ddp_task_rec.stage_name := p0_a72;
    ddp_task_rec.quantity := p0_a73;
    ddp_task_rec.uom := p0_a74;
    ddp_task_rec.instance_number := p0_a75;
    ddp_task_rec.past_task_start_date := rosetta_g_miss_date_in_map(p0_a76);
    ddp_task_rec.past_task_end_date := rosetta_g_miss_date_in_map(p0_a77);
    ddp_task_rec.route_id := p0_a78;


    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_rules_pvt.validate_past_task_dates(ddp_task_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_task_rec.visit_task_id;
    p0_a1 := ddp_task_rec.visit_task_number;
    p0_a2 := ddp_task_rec.visit_id;
    p0_a3 := ddp_task_rec.template_flag;
    p0_a4 := ddp_task_rec.inventory_item_id;
    p0_a5 := ddp_task_rec.item_organization_id;
    p0_a6 := ddp_task_rec.item_name;
    p0_a7 := ddp_task_rec.cost_parent_id;
    p0_a8 := ddp_task_rec.cost_parent_number;
    p0_a9 := ddp_task_rec.mr_route_id;
    p0_a10 := ddp_task_rec.route_number;
    p0_a11 := ddp_task_rec.mr_id;
    p0_a12 := ddp_task_rec.mr_title;
    p0_a13 := ddp_task_rec.unit_effectivity_id;
    p0_a14 := ddp_task_rec.department_id;
    p0_a15 := ddp_task_rec.dept_name;
    p0_a16 := ddp_task_rec.service_request_id;
    p0_a17 := ddp_task_rec.service_request_number;
    p0_a18 := ddp_task_rec.originating_task_id;
    p0_a19 := ddp_task_rec.orginating_task_number;
    p0_a20 := ddp_task_rec.instance_id;
    p0_a21 := ddp_task_rec.serial_number;
    p0_a22 := ddp_task_rec.project_task_id;
    p0_a23 := ddp_task_rec.project_task_number;
    p0_a24 := ddp_task_rec.primary_visit_task_id;
    p0_a25 := ddp_task_rec.start_from_hour;
    p0_a26 := ddp_task_rec.duration;
    p0_a27 := ddp_task_rec.task_type_code;
    p0_a28 := ddp_task_rec.task_type_value;
    p0_a29 := ddp_task_rec.visit_task_name;
    p0_a30 := ddp_task_rec.description;
    p0_a31 := ddp_task_rec.task_status_code;
    p0_a32 := ddp_task_rec.task_status_value;
    p0_a33 := ddp_task_rec.object_version_number;
    p0_a34 := ddp_task_rec.last_update_date;
    p0_a35 := ddp_task_rec.last_updated_by;
    p0_a36 := ddp_task_rec.creation_date;
    p0_a37 := ddp_task_rec.created_by;
    p0_a38 := ddp_task_rec.last_update_login;
    p0_a39 := ddp_task_rec.attribute_category;
    p0_a40 := ddp_task_rec.attribute1;
    p0_a41 := ddp_task_rec.attribute2;
    p0_a42 := ddp_task_rec.attribute3;
    p0_a43 := ddp_task_rec.attribute4;
    p0_a44 := ddp_task_rec.attribute5;
    p0_a45 := ddp_task_rec.attribute6;
    p0_a46 := ddp_task_rec.attribute7;
    p0_a47 := ddp_task_rec.attribute8;
    p0_a48 := ddp_task_rec.attribute9;
    p0_a49 := ddp_task_rec.attribute10;
    p0_a50 := ddp_task_rec.attribute11;
    p0_a51 := ddp_task_rec.attribute12;
    p0_a52 := ddp_task_rec.attribute13;
    p0_a53 := ddp_task_rec.attribute14;
    p0_a54 := ddp_task_rec.attribute15;
    p0_a55 := ddp_task_rec.task_start_date;
    p0_a56 := ddp_task_rec.task_end_date;
    p0_a57 := ddp_task_rec.due_by_date;
    p0_a58 := ddp_task_rec.zone_name;
    p0_a59 := ddp_task_rec.sub_zone_name;
    p0_a60 := ddp_task_rec.tolerance_after;
    p0_a61 := ddp_task_rec.tolerance_before;
    p0_a62 := ddp_task_rec.tolerance_uom;
    p0_a63 := ddp_task_rec.workorder_id;
    p0_a64 := ddp_task_rec.wo_name;
    p0_a65 := ddp_task_rec.wo_status;
    p0_a66 := ddp_task_rec.wo_start_date;
    p0_a67 := ddp_task_rec.wo_end_date;
    p0_a68 := ddp_task_rec.operation_flag;
    p0_a69 := ddp_task_rec.is_production_flag;
    p0_a70 := ddp_task_rec.create_job_flag;
    p0_a71 := ddp_task_rec.stage_id;
    p0_a72 := ddp_task_rec.stage_name;
    p0_a73 := ddp_task_rec.quantity;
    p0_a74 := ddp_task_rec.uom;
    p0_a75 := ddp_task_rec.instance_number;
    p0_a76 := ddp_task_rec.past_task_start_date;
    p0_a77 := ddp_task_rec.past_task_end_date;
    p0_a78 := ddp_task_rec.route_id;

  end;

end ahl_vwp_rules_pvt_w;

/
