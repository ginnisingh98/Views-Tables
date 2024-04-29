--------------------------------------------------------
--  DDL for Package Body AHL_PRD_VISITS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_VISITS_PVT_W" as
  /* $Header: AHLWPSVB.pls 120.1 2006/05/03 00:45 bachandr noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_visits_pvt.visit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_4000
    , a44 JTF_NUMBER_TABLE
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
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_id := a0(indx);
          t(ddindx).visit_name := a1(indx);
          t(ddindx).visit_number := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := a7(indx);
          t(ddindx).last_update_login := a8(indx);
          t(ddindx).organization_id := a9(indx);
          t(ddindx).org_name := a10(indx);
          t(ddindx).department_id := a11(indx);
          t(ddindx).dept_name := a12(indx);
          t(ddindx).service_request_id := a13(indx);
          t(ddindx).service_request_number := a14(indx);
          t(ddindx).space_category_code := a15(indx);
          t(ddindx).space_category_name := a16(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).start_hour := a18(indx);
          t(ddindx).plan_end_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).plan_end_hour := a20(indx);
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).due_by_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).visit_type_code := a23(indx);
          t(ddindx).visit_type_name := a24(indx);
          t(ddindx).status_code := a25(indx);
          t(ddindx).status_name := a26(indx);
          t(ddindx).simulation_plan_id := a27(indx);
          t(ddindx).simulation_plan_name := a28(indx);
          t(ddindx).asso_primary_visit_id := a29(indx);
          t(ddindx).unit_name := a30(indx);
          t(ddindx).item_instance_id := a31(indx);
          t(ddindx).serial_number := a32(indx);
          t(ddindx).inventory_item_id := a33(indx);
          t(ddindx).item_organization_id := a34(indx);
          t(ddindx).item_name := a35(indx);
          t(ddindx).simulation_delete_flag := a36(indx);
          t(ddindx).template_flag := a37(indx);
          t(ddindx).out_of_sync_flag := a38(indx);
          t(ddindx).project_flag := a39(indx);
          t(ddindx).project_flag_code := a40(indx);
          t(ddindx).project_id := a41(indx);
          t(ddindx).project_number := a42(indx);
          t(ddindx).description := a43(indx);
          t(ddindx).duration := a44(indx);
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
          t(ddindx).operation_flag := a61(indx);
          t(ddindx).outside_party_flag := a62(indx);
          t(ddindx).job_number := a63(indx);
          t(ddindx).proj_template_name := a64(indx);
          t(ddindx).proj_template_id := a65(indx);
          t(ddindx).priority_value := a66(indx);
          t(ddindx).priority_code := a67(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_visits_pvt.visit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_4000
    , a44 out nocopy JTF_NUMBER_TABLE
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
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_4000();
    a44 := JTF_NUMBER_TABLE();
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
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_4000();
      a44 := JTF_NUMBER_TABLE();
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
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).visit_id;
          a1(indx) := t(ddindx).visit_name;
          a2(indx) := t(ddindx).visit_number;
          a3(indx) := t(ddindx).object_version_number;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).created_by;
          a8(indx) := t(ddindx).last_update_login;
          a9(indx) := t(ddindx).organization_id;
          a10(indx) := t(ddindx).org_name;
          a11(indx) := t(ddindx).department_id;
          a12(indx) := t(ddindx).dept_name;
          a13(indx) := t(ddindx).service_request_id;
          a14(indx) := t(ddindx).service_request_number;
          a15(indx) := t(ddindx).space_category_code;
          a16(indx) := t(ddindx).space_category_name;
          a17(indx) := t(ddindx).start_date;
          a18(indx) := t(ddindx).start_hour;
          a19(indx) := t(ddindx).plan_end_date;
          a20(indx) := t(ddindx).plan_end_hour;
          a21(indx) := t(ddindx).end_date;
          a22(indx) := t(ddindx).due_by_date;
          a23(indx) := t(ddindx).visit_type_code;
          a24(indx) := t(ddindx).visit_type_name;
          a25(indx) := t(ddindx).status_code;
          a26(indx) := t(ddindx).status_name;
          a27(indx) := t(ddindx).simulation_plan_id;
          a28(indx) := t(ddindx).simulation_plan_name;
          a29(indx) := t(ddindx).asso_primary_visit_id;
          a30(indx) := t(ddindx).unit_name;
          a31(indx) := t(ddindx).item_instance_id;
          a32(indx) := t(ddindx).serial_number;
          a33(indx) := t(ddindx).inventory_item_id;
          a34(indx) := t(ddindx).item_organization_id;
          a35(indx) := t(ddindx).item_name;
          a36(indx) := t(ddindx).simulation_delete_flag;
          a37(indx) := t(ddindx).template_flag;
          a38(indx) := t(ddindx).out_of_sync_flag;
          a39(indx) := t(ddindx).project_flag;
          a40(indx) := t(ddindx).project_flag_code;
          a41(indx) := t(ddindx).project_id;
          a42(indx) := t(ddindx).project_number;
          a43(indx) := t(ddindx).description;
          a44(indx) := t(ddindx).duration;
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
          a61(indx) := t(ddindx).operation_flag;
          a62(indx) := t(ddindx).outside_party_flag;
          a63(indx) := t(ddindx).job_number;
          a64(indx) := t(ddindx).proj_template_name;
          a65(indx) := t(ddindx).proj_template_id;
          a66(indx) := t(ddindx).priority_value;
          a67(indx) := t(ddindx).priority_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_visit_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_visit_rec ahl_prd_visits_pvt.visit_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_visits_pvt.get_visit_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddx_visit_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_visit_rec.visit_id;
    p6_a1 := ddx_visit_rec.visit_name;
    p6_a2 := ddx_visit_rec.visit_number;
    p6_a3 := ddx_visit_rec.object_version_number;
    p6_a4 := ddx_visit_rec.last_update_date;
    p6_a5 := ddx_visit_rec.last_updated_by;
    p6_a6 := ddx_visit_rec.creation_date;
    p6_a7 := ddx_visit_rec.created_by;
    p6_a8 := ddx_visit_rec.last_update_login;
    p6_a9 := ddx_visit_rec.organization_id;
    p6_a10 := ddx_visit_rec.org_name;
    p6_a11 := ddx_visit_rec.department_id;
    p6_a12 := ddx_visit_rec.dept_name;
    p6_a13 := ddx_visit_rec.service_request_id;
    p6_a14 := ddx_visit_rec.service_request_number;
    p6_a15 := ddx_visit_rec.space_category_code;
    p6_a16 := ddx_visit_rec.space_category_name;
    p6_a17 := ddx_visit_rec.start_date;
    p6_a18 := ddx_visit_rec.start_hour;
    p6_a19 := ddx_visit_rec.plan_end_date;
    p6_a20 := ddx_visit_rec.plan_end_hour;
    p6_a21 := ddx_visit_rec.end_date;
    p6_a22 := ddx_visit_rec.due_by_date;
    p6_a23 := ddx_visit_rec.visit_type_code;
    p6_a24 := ddx_visit_rec.visit_type_name;
    p6_a25 := ddx_visit_rec.status_code;
    p6_a26 := ddx_visit_rec.status_name;
    p6_a27 := ddx_visit_rec.simulation_plan_id;
    p6_a28 := ddx_visit_rec.simulation_plan_name;
    p6_a29 := ddx_visit_rec.asso_primary_visit_id;
    p6_a30 := ddx_visit_rec.unit_name;
    p6_a31 := ddx_visit_rec.item_instance_id;
    p6_a32 := ddx_visit_rec.serial_number;
    p6_a33 := ddx_visit_rec.inventory_item_id;
    p6_a34 := ddx_visit_rec.item_organization_id;
    p6_a35 := ddx_visit_rec.item_name;
    p6_a36 := ddx_visit_rec.simulation_delete_flag;
    p6_a37 := ddx_visit_rec.template_flag;
    p6_a38 := ddx_visit_rec.out_of_sync_flag;
    p6_a39 := ddx_visit_rec.project_flag;
    p6_a40 := ddx_visit_rec.project_flag_code;
    p6_a41 := ddx_visit_rec.project_id;
    p6_a42 := ddx_visit_rec.project_number;
    p6_a43 := ddx_visit_rec.description;
    p6_a44 := ddx_visit_rec.duration;
    p6_a45 := ddx_visit_rec.attribute_category;
    p6_a46 := ddx_visit_rec.attribute1;
    p6_a47 := ddx_visit_rec.attribute2;
    p6_a48 := ddx_visit_rec.attribute3;
    p6_a49 := ddx_visit_rec.attribute4;
    p6_a50 := ddx_visit_rec.attribute5;
    p6_a51 := ddx_visit_rec.attribute6;
    p6_a52 := ddx_visit_rec.attribute7;
    p6_a53 := ddx_visit_rec.attribute8;
    p6_a54 := ddx_visit_rec.attribute9;
    p6_a55 := ddx_visit_rec.attribute10;
    p6_a56 := ddx_visit_rec.attribute11;
    p6_a57 := ddx_visit_rec.attribute12;
    p6_a58 := ddx_visit_rec.attribute13;
    p6_a59 := ddx_visit_rec.attribute14;
    p6_a60 := ddx_visit_rec.attribute15;
    p6_a61 := ddx_visit_rec.operation_flag;
    p6_a62 := ddx_visit_rec.outside_party_flag;
    p6_a63 := ddx_visit_rec.job_number;
    p6_a64 := ddx_visit_rec.proj_template_name;
    p6_a65 := ddx_visit_rec.proj_template_id;
    p6_a66 := ddx_visit_rec.priority_value;
    p6_a67 := ddx_visit_rec.priority_code;



  end;

end ahl_prd_visits_pvt_w;

/
