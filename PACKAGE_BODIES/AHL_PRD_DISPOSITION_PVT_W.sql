--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DISPOSITION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DISPOSITION_PVT_W" as
  /* $Header: AHLWDISB.pls 120.1.12010000.2 2008/12/09 01:48:52 jaramana ship $ */
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

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_prd_disposition_pvt.disposition_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_2000
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).disposition_id := a0(indx);
          t(ddindx).operation_flag := a1(indx);
          t(ddindx).object_version_number := a2(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_updated_by := a4(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).created_by := a6(indx);
          t(ddindx).last_update_login := a7(indx);
          t(ddindx).workorder_id := a8(indx);
          t(ddindx).part_change_id := a9(indx);
          t(ddindx).path_position_id := a10(indx);
          t(ddindx).inventory_item_id := a11(indx);
          t(ddindx).item_org_id := a12(indx);
          t(ddindx).item_group_id := a13(indx);
          t(ddindx).condition_id := a14(indx);
          t(ddindx).instance_id := a15(indx);
          t(ddindx).collection_id := a16(indx);
          t(ddindx).primary_service_request_id := a17(indx);
          t(ddindx).non_routine_workorder_id := a18(indx);
          t(ddindx).wo_operation_id := a19(indx);
          t(ddindx).item_revision := a20(indx);
          t(ddindx).serial_number := a21(indx);
          t(ddindx).lot_number := a22(indx);
          t(ddindx).immediate_disposition_code := a23(indx);
          t(ddindx).secondary_disposition_code := a24(indx);
          t(ddindx).status_code := a25(indx);
          t(ddindx).quantity := a26(indx);
          t(ddindx).uom := a27(indx);
          t(ddindx).comments := a28(indx);
          t(ddindx).severity_id := a29(indx);
          t(ddindx).problem_code := a30(indx);
          t(ddindx).summary := a31(indx);
          t(ddindx).duration := a32(indx);
          t(ddindx).create_work_order_option := a33(indx);
          t(ddindx).immediate_disposition := a34(indx);
          t(ddindx).secondary_disposition := a35(indx);
          t(ddindx).condition_meaning := a36(indx);
          t(ddindx).instance_number := a37(indx);
          t(ddindx).item_number := a38(indx);
          t(ddindx).item_group_name := a39(indx);
          t(ddindx).disposition_status := a40(indx);
          t(ddindx).severity_name := a41(indx);
          t(ddindx).problem_meaning := a42(indx);
          t(ddindx).operation_sequence := a43(indx);
          t(ddindx).resolution_code := a44(indx);
          t(ddindx).resolution_meaning := a45(indx);
          t(ddindx).security_group_id := a46(indx);
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
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_prd_disposition_pvt.disposition_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_2000();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_2000();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).disposition_id;
          a1(indx) := t(ddindx).operation_flag;
          a2(indx) := t(ddindx).object_version_number;
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := t(ddindx).last_updated_by;
          a5(indx) := t(ddindx).creation_date;
          a6(indx) := t(ddindx).created_by;
          a7(indx) := t(ddindx).last_update_login;
          a8(indx) := t(ddindx).workorder_id;
          a9(indx) := t(ddindx).part_change_id;
          a10(indx) := t(ddindx).path_position_id;
          a11(indx) := t(ddindx).inventory_item_id;
          a12(indx) := t(ddindx).item_org_id;
          a13(indx) := t(ddindx).item_group_id;
          a14(indx) := t(ddindx).condition_id;
          a15(indx) := t(ddindx).instance_id;
          a16(indx) := t(ddindx).collection_id;
          a17(indx) := t(ddindx).primary_service_request_id;
          a18(indx) := t(ddindx).non_routine_workorder_id;
          a19(indx) := t(ddindx).wo_operation_id;
          a20(indx) := t(ddindx).item_revision;
          a21(indx) := t(ddindx).serial_number;
          a22(indx) := t(ddindx).lot_number;
          a23(indx) := t(ddindx).immediate_disposition_code;
          a24(indx) := t(ddindx).secondary_disposition_code;
          a25(indx) := t(ddindx).status_code;
          a26(indx) := t(ddindx).quantity;
          a27(indx) := t(ddindx).uom;
          a28(indx) := t(ddindx).comments;
          a29(indx) := t(ddindx).severity_id;
          a30(indx) := t(ddindx).problem_code;
          a31(indx) := t(ddindx).summary;
          a32(indx) := t(ddindx).duration;
          a33(indx) := t(ddindx).create_work_order_option;
          a34(indx) := t(ddindx).immediate_disposition;
          a35(indx) := t(ddindx).secondary_disposition;
          a36(indx) := t(ddindx).condition_meaning;
          a37(indx) := t(ddindx).instance_number;
          a38(indx) := t(ddindx).item_number;
          a39(indx) := t(ddindx).item_group_name;
          a40(indx) := t(ddindx).disposition_status;
          a41(indx) := t(ddindx).severity_name;
          a42(indx) := t(ddindx).problem_meaning;
          a43(indx) := t(ddindx).operation_sequence;
          a44(indx) := t(ddindx).resolution_code;
          a45(indx) := t(ddindx).resolution_meaning;
          a46(indx) := t(ddindx).security_group_id;
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
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure process_disposition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  DATE
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  NUMBER
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  NUMBER
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  NUMBER
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  NUMBER
    , p5_a30 in out nocopy  VARCHAR
    , p5_a31 in out nocopy  VARCHAR
    , p5_a32 in out nocopy  NUMBER
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR
    , p5_a35 in out nocopy  VARCHAR
    , p5_a36 in out nocopy  VARCHAR
    , p5_a37 in out nocopy  VARCHAR
    , p5_a38 in out nocopy  VARCHAR
    , p5_a39 in out nocopy  VARCHAR
    , p5_a40 in out nocopy  VARCHAR
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  NUMBER
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  VARCHAR2
    , p5_a61 in out nocopy  VARCHAR2
    , p5_a62 in out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_disposition_rec ahl_prd_disposition_pvt.disposition_rec_type;
    ddp_mr_asso_tbl ahl_prd_nonroutine_pvt.mr_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_disposition_rec.disposition_id := p5_a0;
    ddp_x_disposition_rec.operation_flag := p5_a1;
    ddp_x_disposition_rec.object_version_number := p5_a2;
    ddp_x_disposition_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_x_disposition_rec.last_updated_by := p5_a4;
    ddp_x_disposition_rec.creation_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_x_disposition_rec.created_by := p5_a6;
    ddp_x_disposition_rec.last_update_login := p5_a7;
    ddp_x_disposition_rec.workorder_id := p5_a8;
    ddp_x_disposition_rec.part_change_id := p5_a9;
    ddp_x_disposition_rec.path_position_id := p5_a10;
    ddp_x_disposition_rec.inventory_item_id := p5_a11;
    ddp_x_disposition_rec.item_org_id := p5_a12;
    ddp_x_disposition_rec.item_group_id := p5_a13;
    ddp_x_disposition_rec.condition_id := p5_a14;
    ddp_x_disposition_rec.instance_id := p5_a15;
    ddp_x_disposition_rec.collection_id := p5_a16;
    ddp_x_disposition_rec.primary_service_request_id := p5_a17;
    ddp_x_disposition_rec.non_routine_workorder_id := p5_a18;
    ddp_x_disposition_rec.wo_operation_id := p5_a19;
    ddp_x_disposition_rec.item_revision := p5_a20;
    ddp_x_disposition_rec.serial_number := p5_a21;
    ddp_x_disposition_rec.lot_number := p5_a22;
    ddp_x_disposition_rec.immediate_disposition_code := p5_a23;
    ddp_x_disposition_rec.secondary_disposition_code := p5_a24;
    ddp_x_disposition_rec.status_code := p5_a25;
    ddp_x_disposition_rec.quantity := p5_a26;
    ddp_x_disposition_rec.uom := p5_a27;
    ddp_x_disposition_rec.comments := p5_a28;
    ddp_x_disposition_rec.severity_id := p5_a29;
    ddp_x_disposition_rec.problem_code := p5_a30;
    ddp_x_disposition_rec.summary := p5_a31;
    ddp_x_disposition_rec.duration := p5_a32;
    ddp_x_disposition_rec.create_work_order_option := p5_a33;
    ddp_x_disposition_rec.immediate_disposition := p5_a34;
    ddp_x_disposition_rec.secondary_disposition := p5_a35;
    ddp_x_disposition_rec.condition_meaning := p5_a36;
    ddp_x_disposition_rec.instance_number := p5_a37;
    ddp_x_disposition_rec.item_number := p5_a38;
    ddp_x_disposition_rec.item_group_name := p5_a39;
    ddp_x_disposition_rec.disposition_status := p5_a40;
    ddp_x_disposition_rec.severity_name := p5_a41;
    ddp_x_disposition_rec.problem_meaning := p5_a42;
    ddp_x_disposition_rec.operation_sequence := p5_a43;
    ddp_x_disposition_rec.resolution_code := p5_a44;
    ddp_x_disposition_rec.resolution_meaning := p5_a45;
    ddp_x_disposition_rec.security_group_id := p5_a46;
    ddp_x_disposition_rec.attribute_category := p5_a47;
    ddp_x_disposition_rec.attribute1 := p5_a48;
    ddp_x_disposition_rec.attribute2 := p5_a49;
    ddp_x_disposition_rec.attribute3 := p5_a50;
    ddp_x_disposition_rec.attribute4 := p5_a51;
    ddp_x_disposition_rec.attribute5 := p5_a52;
    ddp_x_disposition_rec.attribute6 := p5_a53;
    ddp_x_disposition_rec.attribute7 := p5_a54;
    ddp_x_disposition_rec.attribute8 := p5_a55;
    ddp_x_disposition_rec.attribute9 := p5_a56;
    ddp_x_disposition_rec.attribute10 := p5_a57;
    ddp_x_disposition_rec.attribute11 := p5_a58;
    ddp_x_disposition_rec.attribute12 := p5_a59;
    ddp_x_disposition_rec.attribute13 := p5_a60;
    ddp_x_disposition_rec.attribute14 := p5_a61;
    ddp_x_disposition_rec.attribute15 := p5_a62;

    ahl_prd_nonroutine_pvt_w.rosetta_table_copy_in_p4(ddp_mr_asso_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_disposition_pvt.process_disposition(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_disposition_rec,
      ddp_mr_asso_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_disposition_rec.disposition_id;
    p5_a1 := ddp_x_disposition_rec.operation_flag;
    p5_a2 := ddp_x_disposition_rec.object_version_number;
    p5_a3 := ddp_x_disposition_rec.last_update_date;
    p5_a4 := ddp_x_disposition_rec.last_updated_by;
    p5_a5 := ddp_x_disposition_rec.creation_date;
    p5_a6 := ddp_x_disposition_rec.created_by;
    p5_a7 := ddp_x_disposition_rec.last_update_login;
    p5_a8 := ddp_x_disposition_rec.workorder_id;
    p5_a9 := ddp_x_disposition_rec.part_change_id;
    p5_a10 := ddp_x_disposition_rec.path_position_id;
    p5_a11 := ddp_x_disposition_rec.inventory_item_id;
    p5_a12 := ddp_x_disposition_rec.item_org_id;
    p5_a13 := ddp_x_disposition_rec.item_group_id;
    p5_a14 := ddp_x_disposition_rec.condition_id;
    p5_a15 := ddp_x_disposition_rec.instance_id;
    p5_a16 := ddp_x_disposition_rec.collection_id;
    p5_a17 := ddp_x_disposition_rec.primary_service_request_id;
    p5_a18 := ddp_x_disposition_rec.non_routine_workorder_id;
    p5_a19 := ddp_x_disposition_rec.wo_operation_id;
    p5_a20 := ddp_x_disposition_rec.item_revision;
    p5_a21 := ddp_x_disposition_rec.serial_number;
    p5_a22 := ddp_x_disposition_rec.lot_number;
    p5_a23 := ddp_x_disposition_rec.immediate_disposition_code;
    p5_a24 := ddp_x_disposition_rec.secondary_disposition_code;
    p5_a25 := ddp_x_disposition_rec.status_code;
    p5_a26 := ddp_x_disposition_rec.quantity;
    p5_a27 := ddp_x_disposition_rec.uom;
    p5_a28 := ddp_x_disposition_rec.comments;
    p5_a29 := ddp_x_disposition_rec.severity_id;
    p5_a30 := ddp_x_disposition_rec.problem_code;
    p5_a31 := ddp_x_disposition_rec.summary;
    p5_a32 := ddp_x_disposition_rec.duration;
    p5_a33 := ddp_x_disposition_rec.create_work_order_option;
    p5_a34 := ddp_x_disposition_rec.immediate_disposition;
    p5_a35 := ddp_x_disposition_rec.secondary_disposition;
    p5_a36 := ddp_x_disposition_rec.condition_meaning;
    p5_a37 := ddp_x_disposition_rec.instance_number;
    p5_a38 := ddp_x_disposition_rec.item_number;
    p5_a39 := ddp_x_disposition_rec.item_group_name;
    p5_a40 := ddp_x_disposition_rec.disposition_status;
    p5_a41 := ddp_x_disposition_rec.severity_name;
    p5_a42 := ddp_x_disposition_rec.problem_meaning;
    p5_a43 := ddp_x_disposition_rec.operation_sequence;
    p5_a44 := ddp_x_disposition_rec.resolution_code;
    p5_a45 := ddp_x_disposition_rec.resolution_meaning;
    p5_a46 := ddp_x_disposition_rec.security_group_id;
    p5_a47 := ddp_x_disposition_rec.attribute_category;
    p5_a48 := ddp_x_disposition_rec.attribute1;
    p5_a49 := ddp_x_disposition_rec.attribute2;
    p5_a50 := ddp_x_disposition_rec.attribute3;
    p5_a51 := ddp_x_disposition_rec.attribute4;
    p5_a52 := ddp_x_disposition_rec.attribute5;
    p5_a53 := ddp_x_disposition_rec.attribute6;
    p5_a54 := ddp_x_disposition_rec.attribute7;
    p5_a55 := ddp_x_disposition_rec.attribute8;
    p5_a56 := ddp_x_disposition_rec.attribute9;
    p5_a57 := ddp_x_disposition_rec.attribute10;
    p5_a58 := ddp_x_disposition_rec.attribute11;
    p5_a59 := ddp_x_disposition_rec.attribute12;
    p5_a60 := ddp_x_disposition_rec.attribute13;
    p5_a61 := ddp_x_disposition_rec.attribute14;
    p5_a62 := ddp_x_disposition_rec.attribute15;




  end;

end ahl_prd_disposition_pvt_w;

/
