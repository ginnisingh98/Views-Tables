--------------------------------------------------------
--  DDL for Package Body AHL_VWP_PROJ_PROD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_PROJ_PROD_PVT_W" as
  /* $Header: AHLWPRDB.pls 120.2.12010000.4 2010/01/27 09:32:11 skpathak ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_vwp_proj_prod_pvt.error_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).msg_index := a0(indx);
          t(ddindx).msg_data := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_vwp_proj_prod_pvt.error_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).msg_index;
          a1(indx) := t(ddindx).msg_data;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_vwp_proj_prod_pvt.task_tbl_type, a0 JTF_NUMBER_TABLE
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
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_vwp_proj_prod_pvt.task_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure validate_before_production(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_error_tbl ahl_vwp_proj_prod_pvt.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_proj_prod_pvt.validate_before_production(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddx_error_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_vwp_proj_prod_pvt_w.rosetta_table_copy_out_p1(ddx_error_tbl, p6_a0
      , p6_a1
      );



  end;

  procedure create_job_tasks(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_NUMBER_TABLE
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_NUMBER_TABLE
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_DATE_TABLE
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_NUMBER_TABLE
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p5_a55 in out nocopy JTF_DATE_TABLE
    , p5_a56 in out nocopy JTF_DATE_TABLE
    , p5_a57 in out nocopy JTF_DATE_TABLE
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a60 in out nocopy JTF_NUMBER_TABLE
    , p5_a61 in out nocopy JTF_NUMBER_TABLE
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a63 in out nocopy JTF_NUMBER_TABLE
    , p5_a64 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a65 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a66 in out nocopy JTF_DATE_TABLE
    , p5_a67 in out nocopy JTF_DATE_TABLE
    , p5_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a71 in out nocopy JTF_NUMBER_TABLE
    , p5_a72 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a73 in out nocopy JTF_NUMBER_TABLE
    , p5_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a75 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a76 in out nocopy JTF_DATE_TABLE
    , p5_a77 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_task_tbl ahl_vwp_proj_prod_pvt.task_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_vwp_proj_prod_pvt_w.rosetta_table_copy_in_p2(ddp_x_task_tbl, p5_a0
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
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_proj_prod_pvt.create_job_tasks(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_task_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_vwp_proj_prod_pvt_w.rosetta_table_copy_out_p2(ddp_x_task_tbl, p5_a0
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
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      );



  end;

  procedure release_tasks(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_VARCHAR2_TABLE_300
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_100
    , p6_a29 JTF_VARCHAR2_TABLE_100
    , p6_a30 JTF_VARCHAR2_TABLE_4000
    , p6_a31 JTF_VARCHAR2_TABLE_100
    , p6_a32 JTF_VARCHAR2_TABLE_100
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_VARCHAR2_TABLE_100
    , p6_a40 JTF_VARCHAR2_TABLE_200
    , p6_a41 JTF_VARCHAR2_TABLE_200
    , p6_a42 JTF_VARCHAR2_TABLE_200
    , p6_a43 JTF_VARCHAR2_TABLE_200
    , p6_a44 JTF_VARCHAR2_TABLE_200
    , p6_a45 JTF_VARCHAR2_TABLE_200
    , p6_a46 JTF_VARCHAR2_TABLE_200
    , p6_a47 JTF_VARCHAR2_TABLE_200
    , p6_a48 JTF_VARCHAR2_TABLE_200
    , p6_a49 JTF_VARCHAR2_TABLE_200
    , p6_a50 JTF_VARCHAR2_TABLE_200
    , p6_a51 JTF_VARCHAR2_TABLE_200
    , p6_a52 JTF_VARCHAR2_TABLE_200
    , p6_a53 JTF_VARCHAR2_TABLE_200
    , p6_a54 JTF_VARCHAR2_TABLE_200
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_DATE_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_NUMBER_TABLE
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_NUMBER_TABLE
    , p6_a64 JTF_VARCHAR2_TABLE_300
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_DATE_TABLE
    , p6_a67 JTF_DATE_TABLE
    , p6_a68 JTF_VARCHAR2_TABLE_100
    , p6_a69 JTF_VARCHAR2_TABLE_100
    , p6_a70 JTF_VARCHAR2_TABLE_100
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_VARCHAR2_TABLE_100
    , p6_a73 JTF_NUMBER_TABLE
    , p6_a74 JTF_VARCHAR2_TABLE_100
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_DATE_TABLE
    , p6_a77 JTF_DATE_TABLE
    , p_release_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tasks_tbl ahl_vwp_proj_prod_pvt.task_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ahl_vwp_proj_prod_pvt_w.rosetta_table_copy_in_p2(ddp_tasks_tbl, p6_a0
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
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      );





    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_proj_prod_pvt.release_tasks(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddp_tasks_tbl,
      p_release_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end ahl_vwp_proj_prod_pvt_w;

/
