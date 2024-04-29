--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISITS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISITS_PVT_W" as
  /* $Header: AHLWVSTB.pls 120.2.12010000.2 2009/12/10 11:38:36 tchimira ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_vwp_visits_pvt.visit_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_4000
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
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
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_DATE_TABLE
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
          t(ddindx).start_min := a19(indx);
          t(ddindx).plan_end_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).plan_end_hour := a21(indx);
          t(ddindx).plan_end_min := a22(indx);
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).due_by_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).visit_type_code := a25(indx);
          t(ddindx).visit_type_name := a26(indx);
          t(ddindx).status_code := a27(indx);
          t(ddindx).status_name := a28(indx);
          t(ddindx).simulation_plan_id := a29(indx);
          t(ddindx).simulation_plan_name := a30(indx);
          t(ddindx).asso_primary_visit_id := a31(indx);
          t(ddindx).unit_name := a32(indx);
          t(ddindx).item_instance_id := a33(indx);
          t(ddindx).serial_number := a34(indx);
          t(ddindx).inventory_item_id := a35(indx);
          t(ddindx).item_organization_id := a36(indx);
          t(ddindx).item_name := a37(indx);
          t(ddindx).simulation_delete_flag := a38(indx);
          t(ddindx).template_flag := a39(indx);
          t(ddindx).out_of_sync_flag := a40(indx);
          t(ddindx).project_flag := a41(indx);
          t(ddindx).project_flag_code := a42(indx);
          t(ddindx).project_id := a43(indx);
          t(ddindx).project_number := a44(indx);
          t(ddindx).description := a45(indx);
          t(ddindx).duration := a46(indx);
          t(ddindx).attribute_category := a47(indx);
          t(ddindx).attribute1 := a48(indx);
          t(ddindx).attribute2 := a49(indx);
          t(ddindx).attribute3 := a50(indx);
          t(ddindx).attribute4 := a51(indx);
          t(ddindx).attribute5 := a52(indx);
          t(ddindx).attribute6 := a53(indx);
          t(ddindx).attribute7 := a54(indx);
          t(ddindx).attribute8 := a55(indx);
          t(ddindx).attribute9 := a56(indx);
          t(ddindx).attribute10 := a57(indx);
          t(ddindx).attribute11 := a58(indx);
          t(ddindx).attribute12 := a59(indx);
          t(ddindx).attribute13 := a60(indx);
          t(ddindx).attribute14 := a61(indx);
          t(ddindx).attribute15 := a62(indx);
          t(ddindx).operation_flag := a63(indx);
          t(ddindx).outside_party_flag := a64(indx);
          t(ddindx).job_number := a65(indx);
          t(ddindx).proj_template_name := a66(indx);
          t(ddindx).proj_template_id := a67(indx);
          t(ddindx).priority_value := a68(indx);
          t(ddindx).priority_code := a69(indx);
          t(ddindx).unit_schedule_id := a70(indx);
          t(ddindx).visit_create_type := a71(indx);
          t(ddindx).visit_create_meaning := a72(indx);
          t(ddindx).unit_header_id := a73(indx);
          t(ddindx).flight_number := a74(indx);
          t(ddindx).subinventory := a75(indx);
          t(ddindx).locator_segment := a76(indx);
          t(ddindx).inv_locator_id := a77(indx);
          t(ddindx).cp_request_id := a78(indx);
          t(ddindx).cp_phase_code := a79(indx);
          t(ddindx).cp_status_code := a80(indx);
          t(ddindx).cp_request_date := rosetta_g_miss_date_in_map(a81(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_vwp_visits_pvt.visit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_4000
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_DATE_TABLE
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
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_4000();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
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
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_DATE_TABLE();
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
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_4000();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
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
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_DATE_TABLE();
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
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
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
          a19(indx) := t(ddindx).start_min;
          a20(indx) := t(ddindx).plan_end_date;
          a21(indx) := t(ddindx).plan_end_hour;
          a22(indx) := t(ddindx).plan_end_min;
          a23(indx) := t(ddindx).end_date;
          a24(indx) := t(ddindx).due_by_date;
          a25(indx) := t(ddindx).visit_type_code;
          a26(indx) := t(ddindx).visit_type_name;
          a27(indx) := t(ddindx).status_code;
          a28(indx) := t(ddindx).status_name;
          a29(indx) := t(ddindx).simulation_plan_id;
          a30(indx) := t(ddindx).simulation_plan_name;
          a31(indx) := t(ddindx).asso_primary_visit_id;
          a32(indx) := t(ddindx).unit_name;
          a33(indx) := t(ddindx).item_instance_id;
          a34(indx) := t(ddindx).serial_number;
          a35(indx) := t(ddindx).inventory_item_id;
          a36(indx) := t(ddindx).item_organization_id;
          a37(indx) := t(ddindx).item_name;
          a38(indx) := t(ddindx).simulation_delete_flag;
          a39(indx) := t(ddindx).template_flag;
          a40(indx) := t(ddindx).out_of_sync_flag;
          a41(indx) := t(ddindx).project_flag;
          a42(indx) := t(ddindx).project_flag_code;
          a43(indx) := t(ddindx).project_id;
          a44(indx) := t(ddindx).project_number;
          a45(indx) := t(ddindx).description;
          a46(indx) := t(ddindx).duration;
          a47(indx) := t(ddindx).attribute_category;
          a48(indx) := t(ddindx).attribute1;
          a49(indx) := t(ddindx).attribute2;
          a50(indx) := t(ddindx).attribute3;
          a51(indx) := t(ddindx).attribute4;
          a52(indx) := t(ddindx).attribute5;
          a53(indx) := t(ddindx).attribute6;
          a54(indx) := t(ddindx).attribute7;
          a55(indx) := t(ddindx).attribute8;
          a56(indx) := t(ddindx).attribute9;
          a57(indx) := t(ddindx).attribute10;
          a58(indx) := t(ddindx).attribute11;
          a59(indx) := t(ddindx).attribute12;
          a60(indx) := t(ddindx).attribute13;
          a61(indx) := t(ddindx).attribute14;
          a62(indx) := t(ddindx).attribute15;
          a63(indx) := t(ddindx).operation_flag;
          a64(indx) := t(ddindx).outside_party_flag;
          a65(indx) := t(ddindx).job_number;
          a66(indx) := t(ddindx).proj_template_name;
          a67(indx) := t(ddindx).proj_template_id;
          a68(indx) := t(ddindx).priority_value;
          a69(indx) := t(ddindx).priority_code;
          a70(indx) := t(ddindx).unit_schedule_id;
          a71(indx) := t(ddindx).visit_create_type;
          a72(indx) := t(ddindx).visit_create_meaning;
          a73(indx) := t(ddindx).unit_header_id;
          a74(indx) := t(ddindx).flight_number;
          a75(indx) := t(ddindx).subinventory;
          a76(indx) := t(ddindx).locator_segment;
          a77(indx) := t(ddindx).inv_locator_id;
          a78(indx) := t(ddindx).cp_request_id;
          a79(indx) := t(ddindx).cp_phase_code;
          a80(indx) := t(ddindx).cp_status_code;
          a81(indx) := t(ddindx).cp_request_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_vwp_visits_pvt.error_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).job_id := a0(indx);
          t(ddindx).job_number := a1(indx);
          t(ddindx).service_request := a2(indx);
          t(ddindx).task_number := a3(indx);
          t(ddindx).priority := a4(indx);
          t(ddindx).scheduled_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).scheduled_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).job_status := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_vwp_visits_pvt.error_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).job_id;
          a1(indx) := t(ddindx).job_number;
          a2(indx) := t(ddindx).service_request;
          a3(indx) := t(ddindx).task_number;
          a4(indx) := t(ddindx).priority;
          a5(indx) := t(ddindx).scheduled_start_date;
          a6(indx) := t(ddindx).scheduled_end_date;
          a7(indx) := t(ddindx).job_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure process_visit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_DATE_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 in out nocopy JTF_DATE_TABLE
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_NUMBER_TABLE
    , p5_a20 in out nocopy JTF_DATE_TABLE
    , p5_a21 in out nocopy JTF_NUMBER_TABLE
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_DATE_TABLE
    , p5_a24 in out nocopy JTF_DATE_TABLE
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 in out nocopy JTF_NUMBER_TABLE
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_NUMBER_TABLE
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 in out nocopy JTF_NUMBER_TABLE
    , p5_a44 in out nocopy JTF_NUMBER_TABLE
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a46 in out nocopy JTF_NUMBER_TABLE
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a63 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a64 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a65 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a66 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a67 in out nocopy JTF_NUMBER_TABLE
    , p5_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 in out nocopy JTF_NUMBER_TABLE
    , p5_a71 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a72 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a73 in out nocopy JTF_NUMBER_TABLE
    , p5_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a75 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a76 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a77 in out nocopy JTF_NUMBER_TABLE
    , p5_a78 in out nocopy JTF_NUMBER_TABLE
    , p5_a79 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a80 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a81 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_visit_tbl ahl_vwp_visits_pvt.visit_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_vwp_visits_pvt_w.rosetta_table_copy_in_p3(ddp_x_visit_tbl, p5_a0
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
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visits_pvt.process_visit(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_visit_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_vwp_visits_pvt_w.rosetta_table_copy_out_p3(ddp_x_visit_tbl, p5_a0
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
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );



  end;

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
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  NUMBER
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
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  VARCHAR2
    , p6_a81 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_visit_rec ahl_vwp_visits_pvt.visit_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visits_pvt.get_visit_details(p_api_version,
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
    p6_a19 := ddx_visit_rec.start_min;
    p6_a20 := ddx_visit_rec.plan_end_date;
    p6_a21 := ddx_visit_rec.plan_end_hour;
    p6_a22 := ddx_visit_rec.plan_end_min;
    p6_a23 := ddx_visit_rec.end_date;
    p6_a24 := ddx_visit_rec.due_by_date;
    p6_a25 := ddx_visit_rec.visit_type_code;
    p6_a26 := ddx_visit_rec.visit_type_name;
    p6_a27 := ddx_visit_rec.status_code;
    p6_a28 := ddx_visit_rec.status_name;
    p6_a29 := ddx_visit_rec.simulation_plan_id;
    p6_a30 := ddx_visit_rec.simulation_plan_name;
    p6_a31 := ddx_visit_rec.asso_primary_visit_id;
    p6_a32 := ddx_visit_rec.unit_name;
    p6_a33 := ddx_visit_rec.item_instance_id;
    p6_a34 := ddx_visit_rec.serial_number;
    p6_a35 := ddx_visit_rec.inventory_item_id;
    p6_a36 := ddx_visit_rec.item_organization_id;
    p6_a37 := ddx_visit_rec.item_name;
    p6_a38 := ddx_visit_rec.simulation_delete_flag;
    p6_a39 := ddx_visit_rec.template_flag;
    p6_a40 := ddx_visit_rec.out_of_sync_flag;
    p6_a41 := ddx_visit_rec.project_flag;
    p6_a42 := ddx_visit_rec.project_flag_code;
    p6_a43 := ddx_visit_rec.project_id;
    p6_a44 := ddx_visit_rec.project_number;
    p6_a45 := ddx_visit_rec.description;
    p6_a46 := ddx_visit_rec.duration;
    p6_a47 := ddx_visit_rec.attribute_category;
    p6_a48 := ddx_visit_rec.attribute1;
    p6_a49 := ddx_visit_rec.attribute2;
    p6_a50 := ddx_visit_rec.attribute3;
    p6_a51 := ddx_visit_rec.attribute4;
    p6_a52 := ddx_visit_rec.attribute5;
    p6_a53 := ddx_visit_rec.attribute6;
    p6_a54 := ddx_visit_rec.attribute7;
    p6_a55 := ddx_visit_rec.attribute8;
    p6_a56 := ddx_visit_rec.attribute9;
    p6_a57 := ddx_visit_rec.attribute10;
    p6_a58 := ddx_visit_rec.attribute11;
    p6_a59 := ddx_visit_rec.attribute12;
    p6_a60 := ddx_visit_rec.attribute13;
    p6_a61 := ddx_visit_rec.attribute14;
    p6_a62 := ddx_visit_rec.attribute15;
    p6_a63 := ddx_visit_rec.operation_flag;
    p6_a64 := ddx_visit_rec.outside_party_flag;
    p6_a65 := ddx_visit_rec.job_number;
    p6_a66 := ddx_visit_rec.proj_template_name;
    p6_a67 := ddx_visit_rec.proj_template_id;
    p6_a68 := ddx_visit_rec.priority_value;
    p6_a69 := ddx_visit_rec.priority_code;
    p6_a70 := ddx_visit_rec.unit_schedule_id;
    p6_a71 := ddx_visit_rec.visit_create_type;
    p6_a72 := ddx_visit_rec.visit_create_meaning;
    p6_a73 := ddx_visit_rec.unit_header_id;
    p6_a74 := ddx_visit_rec.flight_number;
    p6_a75 := ddx_visit_rec.subinventory;
    p6_a76 := ddx_visit_rec.locator_segment;
    p6_a77 := ddx_visit_rec.inv_locator_id;
    p6_a78 := ddx_visit_rec.cp_request_id;
    p6_a79 := ddx_visit_rec.cp_phase_code;
    p6_a80 := ddx_visit_rec.cp_status_code;
    p6_a81 := ddx_visit_rec.cp_request_date;



  end;

end ahl_vwp_visits_pvt_w;

/
