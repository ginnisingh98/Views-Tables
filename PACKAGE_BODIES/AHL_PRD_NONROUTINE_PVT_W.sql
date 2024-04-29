--------------------------------------------------------
--  DDL for Package Body AHL_PRD_NONROUTINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_NONROUTINE_PVT_W" as
  /* $Header: AHLWPNRB.pls 120.3.12010000.3 2010/03/23 10:31:08 manesing ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_prd_nonroutine_pvt.sr_task_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_400
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_400
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_DATE_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
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
    , a63 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).request_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).type_id := a1(indx);
          t(ddindx).type_name := a2(indx);
          t(ddindx).status_id := a3(indx);
          t(ddindx).status_name := a4(indx);
          t(ddindx).severity_id := a5(indx);
          t(ddindx).severity_name := a6(indx);
          t(ddindx).urgency_id := a7(indx);
          t(ddindx).urgency_name := a8(indx);
          t(ddindx).summary := a9(indx);
          t(ddindx).customer_type := a10(indx);
          t(ddindx).customer_id := a11(indx);
          t(ddindx).customer_number := a12(indx);
          t(ddindx).customer_name := a13(indx);
          t(ddindx).contact_type := a14(indx);
          t(ddindx).contact_id := a15(indx);
          t(ddindx).contact_number := a16(indx);
          t(ddindx).contact_name := a17(indx);
          t(ddindx).instance_id := a18(indx);
          t(ddindx).instance_number := a19(indx);
          t(ddindx).problem_code := a20(indx);
          t(ddindx).problem_meaning := a21(indx);
          t(ddindx).resolution_code := a22(indx);
          t(ddindx).resolution_meaning := a23(indx);
          t(ddindx).incident_id := a24(indx);
          t(ddindx).incident_number := a25(indx);
          t(ddindx).incident_object_version_number := a26(indx);
          t(ddindx).visit_id := a27(indx);
          t(ddindx).visit_number := a28(indx);
          t(ddindx).duration := a29(indx);
          t(ddindx).task_type_code := a30(indx);
          t(ddindx).visit_task_id := a31(indx);
          t(ddindx).visit_task_number := a32(indx);
          t(ddindx).visit_task_name := a33(indx);
          t(ddindx).operation_type := a34(indx);
          t(ddindx).workflow_process_id := a35(indx);
          t(ddindx).interaction_id := a36(indx);
          t(ddindx).originating_wo_id := a37(indx);
          t(ddindx).nonroutine_wo_id := a38(indx);
          t(ddindx).source_program_code := a39(indx);
          t(ddindx).object_id := a40(indx);
          t(ddindx).object_type := a41(indx);
          t(ddindx).link_id := a42(indx);
          t(ddindx).wo_create_flag := a43(indx);
          t(ddindx).wo_release_flag := a44(indx);
          t(ddindx).instance_quantity := a45(indx);
          t(ddindx).move_qty_to_nr_workorder := a46(indx);
          t(ddindx).workorder_start_time := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).attribute_category := a48(indx);
          t(ddindx).attribute1 := a49(indx);
          t(ddindx).attribute2 := a50(indx);
          t(ddindx).attribute3 := a51(indx);
          t(ddindx).attribute4 := a52(indx);
          t(ddindx).attribute5 := a53(indx);
          t(ddindx).attribute6 := a54(indx);
          t(ddindx).attribute7 := a55(indx);
          t(ddindx).attribute8 := a56(indx);
          t(ddindx).attribute9 := a57(indx);
          t(ddindx).attribute10 := a58(indx);
          t(ddindx).attribute11 := a59(indx);
          t(ddindx).attribute12 := a60(indx);
          t(ddindx).attribute13 := a61(indx);
          t(ddindx).attribute14 := a62(indx);
          t(ddindx).attribute15 := a63(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_prd_nonroutine_pvt.sr_task_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_400
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_400
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_400();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_400();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
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
    a63 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_400();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_400();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
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
      a63 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).request_date;
          a1(indx) := t(ddindx).type_id;
          a2(indx) := t(ddindx).type_name;
          a3(indx) := t(ddindx).status_id;
          a4(indx) := t(ddindx).status_name;
          a5(indx) := t(ddindx).severity_id;
          a6(indx) := t(ddindx).severity_name;
          a7(indx) := t(ddindx).urgency_id;
          a8(indx) := t(ddindx).urgency_name;
          a9(indx) := t(ddindx).summary;
          a10(indx) := t(ddindx).customer_type;
          a11(indx) := t(ddindx).customer_id;
          a12(indx) := t(ddindx).customer_number;
          a13(indx) := t(ddindx).customer_name;
          a14(indx) := t(ddindx).contact_type;
          a15(indx) := t(ddindx).contact_id;
          a16(indx) := t(ddindx).contact_number;
          a17(indx) := t(ddindx).contact_name;
          a18(indx) := t(ddindx).instance_id;
          a19(indx) := t(ddindx).instance_number;
          a20(indx) := t(ddindx).problem_code;
          a21(indx) := t(ddindx).problem_meaning;
          a22(indx) := t(ddindx).resolution_code;
          a23(indx) := t(ddindx).resolution_meaning;
          a24(indx) := t(ddindx).incident_id;
          a25(indx) := t(ddindx).incident_number;
          a26(indx) := t(ddindx).incident_object_version_number;
          a27(indx) := t(ddindx).visit_id;
          a28(indx) := t(ddindx).visit_number;
          a29(indx) := t(ddindx).duration;
          a30(indx) := t(ddindx).task_type_code;
          a31(indx) := t(ddindx).visit_task_id;
          a32(indx) := t(ddindx).visit_task_number;
          a33(indx) := t(ddindx).visit_task_name;
          a34(indx) := t(ddindx).operation_type;
          a35(indx) := t(ddindx).workflow_process_id;
          a36(indx) := t(ddindx).interaction_id;
          a37(indx) := t(ddindx).originating_wo_id;
          a38(indx) := t(ddindx).nonroutine_wo_id;
          a39(indx) := t(ddindx).source_program_code;
          a40(indx) := t(ddindx).object_id;
          a41(indx) := t(ddindx).object_type;
          a42(indx) := t(ddindx).link_id;
          a43(indx) := t(ddindx).wo_create_flag;
          a44(indx) := t(ddindx).wo_release_flag;
          a45(indx) := t(ddindx).instance_quantity;
          a46(indx) := t(ddindx).move_qty_to_nr_workorder;
          a47(indx) := t(ddindx).workorder_start_time;
          a48(indx) := t(ddindx).attribute_category;
          a49(indx) := t(ddindx).attribute1;
          a50(indx) := t(ddindx).attribute2;
          a51(indx) := t(ddindx).attribute3;
          a52(indx) := t(ddindx).attribute4;
          a53(indx) := t(ddindx).attribute5;
          a54(indx) := t(ddindx).attribute6;
          a55(indx) := t(ddindx).attribute7;
          a56(indx) := t(ddindx).attribute8;
          a57(indx) := t(ddindx).attribute9;
          a58(indx) := t(ddindx).attribute10;
          a59(indx) := t(ddindx).attribute11;
          a60(indx) := t(ddindx).attribute12;
          a61(indx) := t(ddindx).attribute13;
          a62(indx) := t(ddindx).attribute14;
          a63(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_prd_nonroutine_pvt.mr_association_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mr_header_id := a0(indx);
          t(ddindx).mr_title := a1(indx);
          t(ddindx).mr_version := a2(indx);
          t(ddindx).ue_relationship_id := a3(indx);
          t(ddindx).unit_effectivity_id := a4(indx);
          t(ddindx).object_version_number := a5(indx);
          t(ddindx).relationship_code := a6(indx);
          t(ddindx).csi_instance_id := a7(indx);
          t(ddindx).csi_instance_number := a8(indx);
          t(ddindx).sr_tbl_index := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_prd_nonroutine_pvt.mr_association_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).mr_header_id;
          a1(indx) := t(ddindx).mr_title;
          a2(indx) := t(ddindx).mr_version;
          a3(indx) := t(ddindx).ue_relationship_id;
          a4(indx) := t(ddindx).unit_effectivity_id;
          a5(indx) := t(ddindx).object_version_number;
          a6(indx) := t(ddindx).relationship_code;
          a7(indx) := t(ddindx).csi_instance_id;
          a8(indx) := t(ddindx).csi_instance_number;
          a9(indx) := t(ddindx).sr_tbl_index;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure process_nonroutine_job(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_DATE_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_NUMBER_TABLE
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_NUMBER_TABLE
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a18 in out nocopy JTF_NUMBER_TABLE
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a24 in out nocopy JTF_NUMBER_TABLE
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a26 in out nocopy JTF_NUMBER_TABLE
    , p8_a27 in out nocopy JTF_NUMBER_TABLE
    , p8_a28 in out nocopy JTF_NUMBER_TABLE
    , p8_a29 in out nocopy JTF_NUMBER_TABLE
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 in out nocopy JTF_NUMBER_TABLE
    , p8_a32 in out nocopy JTF_NUMBER_TABLE
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 in out nocopy JTF_NUMBER_TABLE
    , p8_a36 in out nocopy JTF_NUMBER_TABLE
    , p8_a37 in out nocopy JTF_NUMBER_TABLE
    , p8_a38 in out nocopy JTF_NUMBER_TABLE
    , p8_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a40 in out nocopy JTF_NUMBER_TABLE
    , p8_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 in out nocopy JTF_NUMBER_TABLE
    , p8_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a45 in out nocopy JTF_NUMBER_TABLE
    , p8_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a47 in out nocopy JTF_DATE_TABLE
    , p8_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_x_sr_task_tbl ahl_prd_nonroutine_pvt.sr_task_tbl_type;
    ddp_x_mr_asso_tbl ahl_prd_nonroutine_pvt.mr_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ahl_prd_nonroutine_pvt_w.rosetta_table_copy_in_p2(ddp_x_sr_task_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      );

    ahl_prd_nonroutine_pvt_w.rosetta_table_copy_in_p4(ddp_x_mr_asso_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_nonroutine_pvt.process_nonroutine_job(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_sr_task_tbl,
      ddp_x_mr_asso_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_prd_nonroutine_pvt_w.rosetta_table_copy_out_p2(ddp_x_sr_task_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      );

    ahl_prd_nonroutine_pvt_w.rosetta_table_copy_out_p4(ddp_x_mr_asso_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      );
  end;

end ahl_prd_nonroutine_pvt_w;

/
