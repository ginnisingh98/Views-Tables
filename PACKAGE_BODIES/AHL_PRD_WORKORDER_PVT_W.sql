--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WORKORDER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WORKORDER_PVT_W" as
  /* $Header: AHLWPRJB.pls 120.4.12010000.2 2008/12/15 01:47:22 sracha ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_workorder_pvt.prd_workoper_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
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
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_operation_id := a0(indx);
          t(ddindx).organization_id := a1(indx);
          t(ddindx).operation_sequence_num := a2(indx);
          t(ddindx).operation_description := a3(indx);
          t(ddindx).workorder_id := a4(indx);
          t(ddindx).wip_entity_id := a5(indx);
          t(ddindx).route_id := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).last_update_date := a8(indx);
          t(ddindx).last_updated_by := a9(indx);
          t(ddindx).creation_date := a10(indx);
          t(ddindx).created_by := a11(indx);
          t(ddindx).last_update_login := a12(indx);
          t(ddindx).department_id := a13(indx);
          t(ddindx).department_name := a14(indx);
          t(ddindx).status_code := a15(indx);
          t(ddindx).status_meaning := a16(indx);
          t(ddindx).operation_id := a17(indx);
          t(ddindx).operation_code := a18(indx);
          t(ddindx).operation_type_code := a19(indx);
          t(ddindx).operation_type := a20(indx);
          t(ddindx).replenish := a21(indx);
          t(ddindx).minimum_transfer_quantity := a22(indx);
          t(ddindx).count_point_type := a23(indx);
          t(ddindx).scheduled_start_date := a24(indx);
          t(ddindx).scheduled_start_hr := a25(indx);
          t(ddindx).scheduled_start_mi := a26(indx);
          t(ddindx).scheduled_end_date := a27(indx);
          t(ddindx).scheduled_end_hr := a28(indx);
          t(ddindx).scheduled_end_mi := a29(indx);
          t(ddindx).actual_start_date := a30(indx);
          t(ddindx).actual_start_hr := a31(indx);
          t(ddindx).actual_start_mi := a32(indx);
          t(ddindx).actual_end_date := a33(indx);
          t(ddindx).actual_end_hr := a34(indx);
          t(ddindx).actual_end_mi := a35(indx);
          t(ddindx).plan_id := a36(indx);
          t(ddindx).collection_id := a37(indx);
          t(ddindx).propagate_flag := a38(indx);
          t(ddindx).security_group_id := a39(indx);
          t(ddindx).attribute_category := a40(indx);
          t(ddindx).attribute1 := a41(indx);
          t(ddindx).attribute2 := a42(indx);
          t(ddindx).attribute3 := a43(indx);
          t(ddindx).attribute4 := a44(indx);
          t(ddindx).attribute5 := a45(indx);
          t(ddindx).attribute6 := a46(indx);
          t(ddindx).attribute7 := a47(indx);
          t(ddindx).attribute8 := a48(indx);
          t(ddindx).attribute9 := a49(indx);
          t(ddindx).attribute10 := a50(indx);
          t(ddindx).attribute11 := a51(indx);
          t(ddindx).attribute12 := a52(indx);
          t(ddindx).attribute13 := a53(indx);
          t(ddindx).attribute14 := a54(indx);
          t(ddindx).attribute15 := a55(indx);
          t(ddindx).dml_operation := a56(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_workorder_pvt.prd_workoper_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
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
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
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
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_operation_id;
          a1(indx) := t(ddindx).organization_id;
          a2(indx) := t(ddindx).operation_sequence_num;
          a3(indx) := t(ddindx).operation_description;
          a4(indx) := t(ddindx).workorder_id;
          a5(indx) := t(ddindx).wip_entity_id;
          a6(indx) := t(ddindx).route_id;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_updated_by;
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := t(ddindx).created_by;
          a12(indx) := t(ddindx).last_update_login;
          a13(indx) := t(ddindx).department_id;
          a14(indx) := t(ddindx).department_name;
          a15(indx) := t(ddindx).status_code;
          a16(indx) := t(ddindx).status_meaning;
          a17(indx) := t(ddindx).operation_id;
          a18(indx) := t(ddindx).operation_code;
          a19(indx) := t(ddindx).operation_type_code;
          a20(indx) := t(ddindx).operation_type;
          a21(indx) := t(ddindx).replenish;
          a22(indx) := t(ddindx).minimum_transfer_quantity;
          a23(indx) := t(ddindx).count_point_type;
          a24(indx) := t(ddindx).scheduled_start_date;
          a25(indx) := t(ddindx).scheduled_start_hr;
          a26(indx) := t(ddindx).scheduled_start_mi;
          a27(indx) := t(ddindx).scheduled_end_date;
          a28(indx) := t(ddindx).scheduled_end_hr;
          a29(indx) := t(ddindx).scheduled_end_mi;
          a30(indx) := t(ddindx).actual_start_date;
          a31(indx) := t(ddindx).actual_start_hr;
          a32(indx) := t(ddindx).actual_start_mi;
          a33(indx) := t(ddindx).actual_end_date;
          a34(indx) := t(ddindx).actual_end_hr;
          a35(indx) := t(ddindx).actual_end_mi;
          a36(indx) := t(ddindx).plan_id;
          a37(indx) := t(ddindx).collection_id;
          a38(indx) := t(ddindx).propagate_flag;
          a39(indx) := t(ddindx).security_group_id;
          a40(indx) := t(ddindx).attribute_category;
          a41(indx) := t(ddindx).attribute1;
          a42(indx) := t(ddindx).attribute2;
          a43(indx) := t(ddindx).attribute3;
          a44(indx) := t(ddindx).attribute4;
          a45(indx) := t(ddindx).attribute5;
          a46(indx) := t(ddindx).attribute6;
          a47(indx) := t(ddindx).attribute7;
          a48(indx) := t(ddindx).attribute8;
          a49(indx) := t(ddindx).attribute9;
          a50(indx) := t(ddindx).attribute10;
          a51(indx) := t(ddindx).attribute11;
          a52(indx) := t(ddindx).attribute12;
          a53(indx) := t(ddindx).attribute13;
          a54(indx) := t(ddindx).attribute14;
          a55(indx) := t(ddindx).attribute15;
          a56(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_prd_workorder_pvt.prd_workorder_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_200
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    , a81 JTF_VARCHAR2_TABLE_200
    , a82 JTF_VARCHAR2_TABLE_200
    , a83 JTF_VARCHAR2_TABLE_200
    , a84 JTF_VARCHAR2_TABLE_200
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_200
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_200
    , a90 JTF_VARCHAR2_TABLE_200
    , a91 JTF_VARCHAR2_TABLE_200
    , a92 JTF_VARCHAR2_TABLE_200
    , a93 JTF_DATE_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).batch_id := a0(indx);
          t(ddindx).header_id := a1(indx);
          t(ddindx).workorder_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).object_version_number := a4(indx);
          t(ddindx).job_number := a5(indx);
          t(ddindx).job_description := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).organization_name := a8(indx);
          t(ddindx).organization_code := a9(indx);
          t(ddindx).department_name := a10(indx);
          t(ddindx).department_id := a11(indx);
          t(ddindx).department_class_code := a12(indx);
          t(ddindx).status_code := a13(indx);
          t(ddindx).status_meaning := a14(indx);
          t(ddindx).scheduled_start_date := a15(indx);
          t(ddindx).scheduled_start_hr := a16(indx);
          t(ddindx).scheduled_start_mi := a17(indx);
          t(ddindx).scheduled_end_date := a18(indx);
          t(ddindx).scheduled_end_hr := a19(indx);
          t(ddindx).scheduled_end_mi := a20(indx);
          t(ddindx).actual_start_date := a21(indx);
          t(ddindx).actual_start_hr := a22(indx);
          t(ddindx).actual_start_mi := a23(indx);
          t(ddindx).actual_end_date := a24(indx);
          t(ddindx).actual_end_hr := a25(indx);
          t(ddindx).actual_end_mi := a26(indx);
          t(ddindx).inventory_item_id := a27(indx);
          t(ddindx).item_instance_id := a28(indx);
          t(ddindx).unit_name := a29(indx);
          t(ddindx).item_instance_number := a30(indx);
          t(ddindx).wo_part_number := a31(indx);
          t(ddindx).item_description := a32(indx);
          t(ddindx).serial_number := a33(indx);
          t(ddindx).item_instance_uom := a34(indx);
          t(ddindx).completion_subinventory := a35(indx);
          t(ddindx).completion_locator_id := a36(indx);
          t(ddindx).completion_locator_name := a37(indx);
          t(ddindx).wip_supply_type := a38(indx);
          t(ddindx).wip_supply_meaning := a39(indx);
          t(ddindx).firm_planned_flag := a40(indx);
          t(ddindx).master_workorder_flag := a41(indx);
          t(ddindx).visit_id := a42(indx);
          t(ddindx).visit_number := a43(indx);
          t(ddindx).visit_name := a44(indx);
          t(ddindx).visit_task_id := a45(indx);
          t(ddindx).mr_header_id := a46(indx);
          t(ddindx).visit_task_number := a47(indx);
          t(ddindx).mr_title := a48(indx);
          t(ddindx).mr_route_id := a49(indx);
          t(ddindx).route_id := a50(indx);
          t(ddindx).confirm_failure_flag := a51(indx);
          t(ddindx).propagate_flag := a52(indx);
          t(ddindx).service_item_id := a53(indx);
          t(ddindx).service_item_org_id := a54(indx);
          t(ddindx).service_item_description := a55(indx);
          t(ddindx).service_item_number := a56(indx);
          t(ddindx).service_item_uom := a57(indx);
          t(ddindx).project_id := a58(indx);
          t(ddindx).project_task_id := a59(indx);
          t(ddindx).quantity := a60(indx);
          t(ddindx).mrp_quantity := a61(indx);
          t(ddindx).incident_id := a62(indx);
          t(ddindx).origination_task_id := a63(indx);
          t(ddindx).parent_id := a64(indx);
          t(ddindx).task_motive_status_id := a65(indx);
          t(ddindx).allow_explosion := a66(indx);
          t(ddindx).class_code := a67(indx);
          t(ddindx).job_priority := a68(indx);
          t(ddindx).job_priority_meaning := a69(indx);
          t(ddindx).confirmed_failure_flag := a70(indx);
          t(ddindx).unit_effectivity_id := a71(indx);
          t(ddindx).plan_id := a72(indx);
          t(ddindx).collection_id := a73(indx);
          t(ddindx).sub_inventory := a74(indx);
          t(ddindx).locator_id := a75(indx);
          t(ddindx).security_group_id := a76(indx);
          t(ddindx).attribute_category := a77(indx);
          t(ddindx).attribute1 := a78(indx);
          t(ddindx).attribute2 := a79(indx);
          t(ddindx).attribute3 := a80(indx);
          t(ddindx).attribute4 := a81(indx);
          t(ddindx).attribute5 := a82(indx);
          t(ddindx).attribute6 := a83(indx);
          t(ddindx).attribute7 := a84(indx);
          t(ddindx).attribute8 := a85(indx);
          t(ddindx).attribute9 := a86(indx);
          t(ddindx).attribute10 := a87(indx);
          t(ddindx).attribute11 := a88(indx);
          t(ddindx).attribute12 := a89(indx);
          t(ddindx).attribute13 := a90(indx);
          t(ddindx).attribute14 := a91(indx);
          t(ddindx).attribute15 := a92(indx);
          t(ddindx).last_update_date := a93(indx);
          t(ddindx).last_updated_by := a94(indx);
          t(ddindx).creation_date := a95(indx);
          t(ddindx).created_by := a96(indx);
          t(ddindx).last_update_login := a97(indx);
          t(ddindx).dml_operation := a98(indx);
          t(ddindx).hold_reason_code := a99(indx);
          t(ddindx).hold_reason := a100(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_prd_workorder_pvt.prd_workorder_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_200
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    , a81 out nocopy JTF_VARCHAR2_TABLE_200
    , a82 out nocopy JTF_VARCHAR2_TABLE_200
    , a83 out nocopy JTF_VARCHAR2_TABLE_200
    , a84 out nocopy JTF_VARCHAR2_TABLE_200
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_200
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_200
    , a90 out nocopy JTF_VARCHAR2_TABLE_200
    , a91 out nocopy JTF_VARCHAR2_TABLE_200
    , a92 out nocopy JTF_VARCHAR2_TABLE_200
    , a93 out nocopy JTF_DATE_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_NUMBER_TABLE
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_VARCHAR2_TABLE_100
    , a100 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_200();
    a79 := JTF_VARCHAR2_TABLE_200();
    a80 := JTF_VARCHAR2_TABLE_200();
    a81 := JTF_VARCHAR2_TABLE_200();
    a82 := JTF_VARCHAR2_TABLE_200();
    a83 := JTF_VARCHAR2_TABLE_200();
    a84 := JTF_VARCHAR2_TABLE_200();
    a85 := JTF_VARCHAR2_TABLE_200();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_200();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_200();
    a90 := JTF_VARCHAR2_TABLE_200();
    a91 := JTF_VARCHAR2_TABLE_200();
    a92 := JTF_VARCHAR2_TABLE_200();
    a93 := JTF_DATE_TABLE();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_VARCHAR2_TABLE_100();
    a99 := JTF_VARCHAR2_TABLE_100();
    a100 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_200();
      a79 := JTF_VARCHAR2_TABLE_200();
      a80 := JTF_VARCHAR2_TABLE_200();
      a81 := JTF_VARCHAR2_TABLE_200();
      a82 := JTF_VARCHAR2_TABLE_200();
      a83 := JTF_VARCHAR2_TABLE_200();
      a84 := JTF_VARCHAR2_TABLE_200();
      a85 := JTF_VARCHAR2_TABLE_200();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_200();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_200();
      a90 := JTF_VARCHAR2_TABLE_200();
      a91 := JTF_VARCHAR2_TABLE_200();
      a92 := JTF_VARCHAR2_TABLE_200();
      a93 := JTF_DATE_TABLE();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_VARCHAR2_TABLE_100();
      a99 := JTF_VARCHAR2_TABLE_100();
      a100 := JTF_VARCHAR2_TABLE_100();
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
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).batch_id;
          a1(indx) := t(ddindx).header_id;
          a2(indx) := t(ddindx).workorder_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).object_version_number;
          a5(indx) := t(ddindx).job_number;
          a6(indx) := t(ddindx).job_description;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).organization_name;
          a9(indx) := t(ddindx).organization_code;
          a10(indx) := t(ddindx).department_name;
          a11(indx) := t(ddindx).department_id;
          a12(indx) := t(ddindx).department_class_code;
          a13(indx) := t(ddindx).status_code;
          a14(indx) := t(ddindx).status_meaning;
          a15(indx) := t(ddindx).scheduled_start_date;
          a16(indx) := t(ddindx).scheduled_start_hr;
          a17(indx) := t(ddindx).scheduled_start_mi;
          a18(indx) := t(ddindx).scheduled_end_date;
          a19(indx) := t(ddindx).scheduled_end_hr;
          a20(indx) := t(ddindx).scheduled_end_mi;
          a21(indx) := t(ddindx).actual_start_date;
          a22(indx) := t(ddindx).actual_start_hr;
          a23(indx) := t(ddindx).actual_start_mi;
          a24(indx) := t(ddindx).actual_end_date;
          a25(indx) := t(ddindx).actual_end_hr;
          a26(indx) := t(ddindx).actual_end_mi;
          a27(indx) := t(ddindx).inventory_item_id;
          a28(indx) := t(ddindx).item_instance_id;
          a29(indx) := t(ddindx).unit_name;
          a30(indx) := t(ddindx).item_instance_number;
          a31(indx) := t(ddindx).wo_part_number;
          a32(indx) := t(ddindx).item_description;
          a33(indx) := t(ddindx).serial_number;
          a34(indx) := t(ddindx).item_instance_uom;
          a35(indx) := t(ddindx).completion_subinventory;
          a36(indx) := t(ddindx).completion_locator_id;
          a37(indx) := t(ddindx).completion_locator_name;
          a38(indx) := t(ddindx).wip_supply_type;
          a39(indx) := t(ddindx).wip_supply_meaning;
          a40(indx) := t(ddindx).firm_planned_flag;
          a41(indx) := t(ddindx).master_workorder_flag;
          a42(indx) := t(ddindx).visit_id;
          a43(indx) := t(ddindx).visit_number;
          a44(indx) := t(ddindx).visit_name;
          a45(indx) := t(ddindx).visit_task_id;
          a46(indx) := t(ddindx).mr_header_id;
          a47(indx) := t(ddindx).visit_task_number;
          a48(indx) := t(ddindx).mr_title;
          a49(indx) := t(ddindx).mr_route_id;
          a50(indx) := t(ddindx).route_id;
          a51(indx) := t(ddindx).confirm_failure_flag;
          a52(indx) := t(ddindx).propagate_flag;
          a53(indx) := t(ddindx).service_item_id;
          a54(indx) := t(ddindx).service_item_org_id;
          a55(indx) := t(ddindx).service_item_description;
          a56(indx) := t(ddindx).service_item_number;
          a57(indx) := t(ddindx).service_item_uom;
          a58(indx) := t(ddindx).project_id;
          a59(indx) := t(ddindx).project_task_id;
          a60(indx) := t(ddindx).quantity;
          a61(indx) := t(ddindx).mrp_quantity;
          a62(indx) := t(ddindx).incident_id;
          a63(indx) := t(ddindx).origination_task_id;
          a64(indx) := t(ddindx).parent_id;
          a65(indx) := t(ddindx).task_motive_status_id;
          a66(indx) := t(ddindx).allow_explosion;
          a67(indx) := t(ddindx).class_code;
          a68(indx) := t(ddindx).job_priority;
          a69(indx) := t(ddindx).job_priority_meaning;
          a70(indx) := t(ddindx).confirmed_failure_flag;
          a71(indx) := t(ddindx).unit_effectivity_id;
          a72(indx) := t(ddindx).plan_id;
          a73(indx) := t(ddindx).collection_id;
          a74(indx) := t(ddindx).sub_inventory;
          a75(indx) := t(ddindx).locator_id;
          a76(indx) := t(ddindx).security_group_id;
          a77(indx) := t(ddindx).attribute_category;
          a78(indx) := t(ddindx).attribute1;
          a79(indx) := t(ddindx).attribute2;
          a80(indx) := t(ddindx).attribute3;
          a81(indx) := t(ddindx).attribute4;
          a82(indx) := t(ddindx).attribute5;
          a83(indx) := t(ddindx).attribute6;
          a84(indx) := t(ddindx).attribute7;
          a85(indx) := t(ddindx).attribute8;
          a86(indx) := t(ddindx).attribute9;
          a87(indx) := t(ddindx).attribute10;
          a88(indx) := t(ddindx).attribute11;
          a89(indx) := t(ddindx).attribute12;
          a90(indx) := t(ddindx).attribute13;
          a91(indx) := t(ddindx).attribute14;
          a92(indx) := t(ddindx).attribute15;
          a93(indx) := t(ddindx).last_update_date;
          a94(indx) := t(ddindx).last_updated_by;
          a95(indx) := t(ddindx).creation_date;
          a96(indx) := t(ddindx).created_by;
          a97(indx) := t(ddindx).last_update_login;
          a98(indx) := t(ddindx).dml_operation;
          a99(indx) := t(ddindx).hold_reason_code;
          a100(indx) := t(ddindx).hold_reason;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_prd_workorder_pvt.prd_workorder_rel_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).batch_id := a0(indx);
          t(ddindx).wo_relationship_id := a1(indx);
          t(ddindx).parent_header_id := a2(indx);
          t(ddindx).parent_wip_entity_id := a3(indx);
          t(ddindx).child_header_id := a4(indx);
          t(ddindx).child_wip_entity_id := a5(indx);
          t(ddindx).relationship_type := a6(indx);
          t(ddindx).dml_operation := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_prd_workorder_pvt.prd_workorder_rel_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).batch_id;
          a1(indx) := t(ddindx).wo_relationship_id;
          a2(indx) := t(ddindx).parent_header_id;
          a3(indx) := t(ddindx).parent_wip_entity_id;
          a4(indx) := t(ddindx).child_header_id;
          a5(indx) := t(ddindx).child_wip_entity_id;
          a6(indx) := t(ddindx).relationship_type;
          a7(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p13(t out nocopy ahl_prd_workorder_pvt.turnover_notes_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).jtf_note_id := a0(indx);
          t(ddindx).source_object_id := a1(indx);
          t(ddindx).source_object_code := a2(indx);
          t(ddindx).notes := a3(indx);
          t(ddindx).employee_id := a4(indx);
          t(ddindx).employee_name := a5(indx);
          t(ddindx).entered_date := a6(indx);
          t(ddindx).org_id := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t ahl_prd_workorder_pvt.turnover_notes_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).jtf_note_id;
          a1(indx) := t(ddindx).source_object_id;
          a2(indx) := t(ddindx).source_object_code;
          a3(indx) := t(ddindx).notes;
          a4(indx) := t(ddindx).employee_id;
          a5(indx) := t(ddindx).employee_name;
          a6(indx) := t(ddindx).entered_date;
          a7(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure process_jobs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_DATE_TABLE
    , p9_a16 in out nocopy JTF_NUMBER_TABLE
    , p9_a17 in out nocopy JTF_NUMBER_TABLE
    , p9_a18 in out nocopy JTF_DATE_TABLE
    , p9_a19 in out nocopy JTF_NUMBER_TABLE
    , p9_a20 in out nocopy JTF_NUMBER_TABLE
    , p9_a21 in out nocopy JTF_DATE_TABLE
    , p9_a22 in out nocopy JTF_NUMBER_TABLE
    , p9_a23 in out nocopy JTF_NUMBER_TABLE
    , p9_a24 in out nocopy JTF_DATE_TABLE
    , p9_a25 in out nocopy JTF_NUMBER_TABLE
    , p9_a26 in out nocopy JTF_NUMBER_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p9_a28 in out nocopy JTF_NUMBER_TABLE
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 in out nocopy JTF_NUMBER_TABLE
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a38 in out nocopy JTF_NUMBER_TABLE
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a40 in out nocopy JTF_NUMBER_TABLE
    , p9_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a42 in out nocopy JTF_NUMBER_TABLE
    , p9_a43 in out nocopy JTF_NUMBER_TABLE
    , p9_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a45 in out nocopy JTF_NUMBER_TABLE
    , p9_a46 in out nocopy JTF_NUMBER_TABLE
    , p9_a47 in out nocopy JTF_NUMBER_TABLE
    , p9_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a49 in out nocopy JTF_NUMBER_TABLE
    , p9_a50 in out nocopy JTF_NUMBER_TABLE
    , p9_a51 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a52 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a53 in out nocopy JTF_NUMBER_TABLE
    , p9_a54 in out nocopy JTF_NUMBER_TABLE
    , p9_a55 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a56 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a58 in out nocopy JTF_NUMBER_TABLE
    , p9_a59 in out nocopy JTF_NUMBER_TABLE
    , p9_a60 in out nocopy JTF_NUMBER_TABLE
    , p9_a61 in out nocopy JTF_NUMBER_TABLE
    , p9_a62 in out nocopy JTF_NUMBER_TABLE
    , p9_a63 in out nocopy JTF_NUMBER_TABLE
    , p9_a64 in out nocopy JTF_NUMBER_TABLE
    , p9_a65 in out nocopy JTF_NUMBER_TABLE
    , p9_a66 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a67 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a68 in out nocopy JTF_NUMBER_TABLE
    , p9_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a70 in out nocopy JTF_NUMBER_TABLE
    , p9_a71 in out nocopy JTF_NUMBER_TABLE
    , p9_a72 in out nocopy JTF_NUMBER_TABLE
    , p9_a73 in out nocopy JTF_NUMBER_TABLE
    , p9_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a75 in out nocopy JTF_NUMBER_TABLE
    , p9_a76 in out nocopy JTF_NUMBER_TABLE
    , p9_a77 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a93 in out nocopy JTF_DATE_TABLE
    , p9_a94 in out nocopy JTF_NUMBER_TABLE
    , p9_a95 in out nocopy JTF_DATE_TABLE
    , p9_a96 in out nocopy JTF_NUMBER_TABLE
    , p9_a97 in out nocopy JTF_NUMBER_TABLE
    , p9_a98 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a99 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a100 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_prd_workorder_tbl ahl_prd_workorder_pvt.prd_workorder_tbl;
    ddp_prd_workorder_rel_tbl ahl_prd_workorder_pvt.prd_workorder_rel_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_prd_workorder_pvt_w.rosetta_table_copy_in_p3(ddp_x_prd_workorder_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      , p9_a66
      , p9_a67
      , p9_a68
      , p9_a69
      , p9_a70
      , p9_a71
      , p9_a72
      , p9_a73
      , p9_a74
      , p9_a75
      , p9_a76
      , p9_a77
      , p9_a78
      , p9_a79
      , p9_a80
      , p9_a81
      , p9_a82
      , p9_a83
      , p9_a84
      , p9_a85
      , p9_a86
      , p9_a87
      , p9_a88
      , p9_a89
      , p9_a90
      , p9_a91
      , p9_a92
      , p9_a93
      , p9_a94
      , p9_a95
      , p9_a96
      , p9_a97
      , p9_a98
      , p9_a99
      , p9_a100
      );

    ahl_prd_workorder_pvt_w.rosetta_table_copy_in_p5(ddp_prd_workorder_rel_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_workorder_pvt.process_jobs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_prd_workorder_tbl,
      ddp_prd_workorder_rel_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_prd_workorder_pvt_w.rosetta_table_copy_out_p3(ddp_x_prd_workorder_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      , p9_a66
      , p9_a67
      , p9_a68
      , p9_a69
      , p9_a70
      , p9_a71
      , p9_a72
      , p9_a73
      , p9_a74
      , p9_a75
      , p9_a76
      , p9_a77
      , p9_a78
      , p9_a79
      , p9_a80
      , p9_a81
      , p9_a82
      , p9_a83
      , p9_a84
      , p9_a85
      , p9_a86
      , p9_a87
      , p9_a88
      , p9_a89
      , p9_a90
      , p9_a91
      , p9_a92
      , p9_a93
      , p9_a94
      , p9_a95
      , p9_a96
      , p9_a97
      , p9_a98
      , p9_a99
      , p9_a100
      );

  end;

  procedure update_job(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_wip_load_flag  VARCHAR2
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  NUMBER
    , p10_a3 in out nocopy  NUMBER
    , p10_a4 in out nocopy  NUMBER
    , p10_a5 in out nocopy  VARCHAR2
    , p10_a6 in out nocopy  VARCHAR2
    , p10_a7 in out nocopy  NUMBER
    , p10_a8 in out nocopy  VARCHAR2
    , p10_a9 in out nocopy  VARCHAR2
    , p10_a10 in out nocopy  VARCHAR2
    , p10_a11 in out nocopy  NUMBER
    , p10_a12 in out nocopy  VARCHAR2
    , p10_a13 in out nocopy  VARCHAR2
    , p10_a14 in out nocopy  VARCHAR2
    , p10_a15 in out nocopy  DATE
    , p10_a16 in out nocopy  NUMBER
    , p10_a17 in out nocopy  NUMBER
    , p10_a18 in out nocopy  DATE
    , p10_a19 in out nocopy  NUMBER
    , p10_a20 in out nocopy  NUMBER
    , p10_a21 in out nocopy  DATE
    , p10_a22 in out nocopy  NUMBER
    , p10_a23 in out nocopy  NUMBER
    , p10_a24 in out nocopy  DATE
    , p10_a25 in out nocopy  NUMBER
    , p10_a26 in out nocopy  NUMBER
    , p10_a27 in out nocopy  NUMBER
    , p10_a28 in out nocopy  NUMBER
    , p10_a29 in out nocopy  VARCHAR2
    , p10_a30 in out nocopy  VARCHAR2
    , p10_a31 in out nocopy  VARCHAR2
    , p10_a32 in out nocopy  VARCHAR2
    , p10_a33 in out nocopy  VARCHAR2
    , p10_a34 in out nocopy  VARCHAR2
    , p10_a35 in out nocopy  VARCHAR2
    , p10_a36 in out nocopy  NUMBER
    , p10_a37 in out nocopy  VARCHAR2
    , p10_a38 in out nocopy  NUMBER
    , p10_a39 in out nocopy  VARCHAR2
    , p10_a40 in out nocopy  NUMBER
    , p10_a41 in out nocopy  VARCHAR2
    , p10_a42 in out nocopy  NUMBER
    , p10_a43 in out nocopy  NUMBER
    , p10_a44 in out nocopy  VARCHAR2
    , p10_a45 in out nocopy  NUMBER
    , p10_a46 in out nocopy  NUMBER
    , p10_a47 in out nocopy  NUMBER
    , p10_a48 in out nocopy  VARCHAR2
    , p10_a49 in out nocopy  NUMBER
    , p10_a50 in out nocopy  NUMBER
    , p10_a51 in out nocopy  VARCHAR2
    , p10_a52 in out nocopy  VARCHAR2
    , p10_a53 in out nocopy  NUMBER
    , p10_a54 in out nocopy  NUMBER
    , p10_a55 in out nocopy  VARCHAR2
    , p10_a56 in out nocopy  VARCHAR2
    , p10_a57 in out nocopy  VARCHAR2
    , p10_a58 in out nocopy  NUMBER
    , p10_a59 in out nocopy  NUMBER
    , p10_a60 in out nocopy  NUMBER
    , p10_a61 in out nocopy  NUMBER
    , p10_a62 in out nocopy  NUMBER
    , p10_a63 in out nocopy  NUMBER
    , p10_a64 in out nocopy  NUMBER
    , p10_a65 in out nocopy  NUMBER
    , p10_a66 in out nocopy  VARCHAR2
    , p10_a67 in out nocopy  VARCHAR2
    , p10_a68 in out nocopy  NUMBER
    , p10_a69 in out nocopy  VARCHAR2
    , p10_a70 in out nocopy  NUMBER
    , p10_a71 in out nocopy  NUMBER
    , p10_a72 in out nocopy  NUMBER
    , p10_a73 in out nocopy  NUMBER
    , p10_a74 in out nocopy  VARCHAR2
    , p10_a75 in out nocopy  NUMBER
    , p10_a76 in out nocopy  NUMBER
    , p10_a77 in out nocopy  VARCHAR2
    , p10_a78 in out nocopy  VARCHAR2
    , p10_a79 in out nocopy  VARCHAR2
    , p10_a80 in out nocopy  VARCHAR2
    , p10_a81 in out nocopy  VARCHAR2
    , p10_a82 in out nocopy  VARCHAR2
    , p10_a83 in out nocopy  VARCHAR2
    , p10_a84 in out nocopy  VARCHAR2
    , p10_a85 in out nocopy  VARCHAR2
    , p10_a86 in out nocopy  VARCHAR2
    , p10_a87 in out nocopy  VARCHAR2
    , p10_a88 in out nocopy  VARCHAR2
    , p10_a89 in out nocopy  VARCHAR2
    , p10_a90 in out nocopy  VARCHAR2
    , p10_a91 in out nocopy  VARCHAR2
    , p10_a92 in out nocopy  VARCHAR2
    , p10_a93 in out nocopy  DATE
    , p10_a94 in out nocopy  NUMBER
    , p10_a95 in out nocopy  DATE
    , p10_a96 in out nocopy  NUMBER
    , p10_a97 in out nocopy  NUMBER
    , p10_a98 in out nocopy  VARCHAR2
    , p10_a99 in out nocopy  VARCHAR2
    , p10_a100 in out nocopy  VARCHAR2
    , p11_a0 in out nocopy JTF_NUMBER_TABLE
    , p11_a1 in out nocopy JTF_NUMBER_TABLE
    , p11_a2 in out nocopy JTF_NUMBER_TABLE
    , p11_a3 in out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a4 in out nocopy JTF_NUMBER_TABLE
    , p11_a5 in out nocopy JTF_NUMBER_TABLE
    , p11_a6 in out nocopy JTF_NUMBER_TABLE
    , p11_a7 in out nocopy JTF_NUMBER_TABLE
    , p11_a8 in out nocopy JTF_DATE_TABLE
    , p11_a9 in out nocopy JTF_NUMBER_TABLE
    , p11_a10 in out nocopy JTF_DATE_TABLE
    , p11_a11 in out nocopy JTF_NUMBER_TABLE
    , p11_a12 in out nocopy JTF_NUMBER_TABLE
    , p11_a13 in out nocopy JTF_NUMBER_TABLE
    , p11_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 in out nocopy JTF_NUMBER_TABLE
    , p11_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a22 in out nocopy JTF_NUMBER_TABLE
    , p11_a23 in out nocopy JTF_NUMBER_TABLE
    , p11_a24 in out nocopy JTF_DATE_TABLE
    , p11_a25 in out nocopy JTF_NUMBER_TABLE
    , p11_a26 in out nocopy JTF_NUMBER_TABLE
    , p11_a27 in out nocopy JTF_DATE_TABLE
    , p11_a28 in out nocopy JTF_NUMBER_TABLE
    , p11_a29 in out nocopy JTF_NUMBER_TABLE
    , p11_a30 in out nocopy JTF_DATE_TABLE
    , p11_a31 in out nocopy JTF_NUMBER_TABLE
    , p11_a32 in out nocopy JTF_NUMBER_TABLE
    , p11_a33 in out nocopy JTF_DATE_TABLE
    , p11_a34 in out nocopy JTF_NUMBER_TABLE
    , p11_a35 in out nocopy JTF_NUMBER_TABLE
    , p11_a36 in out nocopy JTF_NUMBER_TABLE
    , p11_a37 in out nocopy JTF_NUMBER_TABLE
    , p11_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a39 in out nocopy JTF_NUMBER_TABLE
    , p11_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a56 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_prd_workorder_rec ahl_prd_workorder_pvt.prd_workorder_rec;
    ddp_x_prd_workoper_tbl ahl_prd_workorder_pvt.prd_workoper_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_x_prd_workorder_rec.batch_id := p10_a0;
    ddp_x_prd_workorder_rec.header_id := p10_a1;
    ddp_x_prd_workorder_rec.workorder_id := p10_a2;
    ddp_x_prd_workorder_rec.wip_entity_id := p10_a3;
    ddp_x_prd_workorder_rec.object_version_number := p10_a4;
    ddp_x_prd_workorder_rec.job_number := p10_a5;
    ddp_x_prd_workorder_rec.job_description := p10_a6;
    ddp_x_prd_workorder_rec.organization_id := p10_a7;
    ddp_x_prd_workorder_rec.organization_name := p10_a8;
    ddp_x_prd_workorder_rec.organization_code := p10_a9;
    ddp_x_prd_workorder_rec.department_name := p10_a10;
    ddp_x_prd_workorder_rec.department_id := p10_a11;
    ddp_x_prd_workorder_rec.department_class_code := p10_a12;
    ddp_x_prd_workorder_rec.status_code := p10_a13;
    ddp_x_prd_workorder_rec.status_meaning := p10_a14;
    ddp_x_prd_workorder_rec.scheduled_start_date := p10_a15;
    ddp_x_prd_workorder_rec.scheduled_start_hr := p10_a16;
    ddp_x_prd_workorder_rec.scheduled_start_mi := p10_a17;
    ddp_x_prd_workorder_rec.scheduled_end_date := p10_a18;
    ddp_x_prd_workorder_rec.scheduled_end_hr := p10_a19;
    ddp_x_prd_workorder_rec.scheduled_end_mi := p10_a20;
    ddp_x_prd_workorder_rec.actual_start_date := p10_a21;
    ddp_x_prd_workorder_rec.actual_start_hr := p10_a22;
    ddp_x_prd_workorder_rec.actual_start_mi := p10_a23;
    ddp_x_prd_workorder_rec.actual_end_date := p10_a24;
    ddp_x_prd_workorder_rec.actual_end_hr := p10_a25;
    ddp_x_prd_workorder_rec.actual_end_mi := p10_a26;
    ddp_x_prd_workorder_rec.inventory_item_id := p10_a27;
    ddp_x_prd_workorder_rec.item_instance_id := p10_a28;
    ddp_x_prd_workorder_rec.unit_name := p10_a29;
    ddp_x_prd_workorder_rec.item_instance_number := p10_a30;
    ddp_x_prd_workorder_rec.wo_part_number := p10_a31;
    ddp_x_prd_workorder_rec.item_description := p10_a32;
    ddp_x_prd_workorder_rec.serial_number := p10_a33;
    ddp_x_prd_workorder_rec.item_instance_uom := p10_a34;
    ddp_x_prd_workorder_rec.completion_subinventory := p10_a35;
    ddp_x_prd_workorder_rec.completion_locator_id := p10_a36;
    ddp_x_prd_workorder_rec.completion_locator_name := p10_a37;
    ddp_x_prd_workorder_rec.wip_supply_type := p10_a38;
    ddp_x_prd_workorder_rec.wip_supply_meaning := p10_a39;
    ddp_x_prd_workorder_rec.firm_planned_flag := p10_a40;
    ddp_x_prd_workorder_rec.master_workorder_flag := p10_a41;
    ddp_x_prd_workorder_rec.visit_id := p10_a42;
    ddp_x_prd_workorder_rec.visit_number := p10_a43;
    ddp_x_prd_workorder_rec.visit_name := p10_a44;
    ddp_x_prd_workorder_rec.visit_task_id := p10_a45;
    ddp_x_prd_workorder_rec.mr_header_id := p10_a46;
    ddp_x_prd_workorder_rec.visit_task_number := p10_a47;
    ddp_x_prd_workorder_rec.mr_title := p10_a48;
    ddp_x_prd_workorder_rec.mr_route_id := p10_a49;
    ddp_x_prd_workorder_rec.route_id := p10_a50;
    ddp_x_prd_workorder_rec.confirm_failure_flag := p10_a51;
    ddp_x_prd_workorder_rec.propagate_flag := p10_a52;
    ddp_x_prd_workorder_rec.service_item_id := p10_a53;
    ddp_x_prd_workorder_rec.service_item_org_id := p10_a54;
    ddp_x_prd_workorder_rec.service_item_description := p10_a55;
    ddp_x_prd_workorder_rec.service_item_number := p10_a56;
    ddp_x_prd_workorder_rec.service_item_uom := p10_a57;
    ddp_x_prd_workorder_rec.project_id := p10_a58;
    ddp_x_prd_workorder_rec.project_task_id := p10_a59;
    ddp_x_prd_workorder_rec.quantity := p10_a60;
    ddp_x_prd_workorder_rec.mrp_quantity := p10_a61;
    ddp_x_prd_workorder_rec.incident_id := p10_a62;
    ddp_x_prd_workorder_rec.origination_task_id := p10_a63;
    ddp_x_prd_workorder_rec.parent_id := p10_a64;
    ddp_x_prd_workorder_rec.task_motive_status_id := p10_a65;
    ddp_x_prd_workorder_rec.allow_explosion := p10_a66;
    ddp_x_prd_workorder_rec.class_code := p10_a67;
    ddp_x_prd_workorder_rec.job_priority := p10_a68;
    ddp_x_prd_workorder_rec.job_priority_meaning := p10_a69;
    ddp_x_prd_workorder_rec.confirmed_failure_flag := p10_a70;
    ddp_x_prd_workorder_rec.unit_effectivity_id := p10_a71;
    ddp_x_prd_workorder_rec.plan_id := p10_a72;
    ddp_x_prd_workorder_rec.collection_id := p10_a73;
    ddp_x_prd_workorder_rec.sub_inventory := p10_a74;
    ddp_x_prd_workorder_rec.locator_id := p10_a75;
    ddp_x_prd_workorder_rec.security_group_id := p10_a76;
    ddp_x_prd_workorder_rec.attribute_category := p10_a77;
    ddp_x_prd_workorder_rec.attribute1 := p10_a78;
    ddp_x_prd_workorder_rec.attribute2 := p10_a79;
    ddp_x_prd_workorder_rec.attribute3 := p10_a80;
    ddp_x_prd_workorder_rec.attribute4 := p10_a81;
    ddp_x_prd_workorder_rec.attribute5 := p10_a82;
    ddp_x_prd_workorder_rec.attribute6 := p10_a83;
    ddp_x_prd_workorder_rec.attribute7 := p10_a84;
    ddp_x_prd_workorder_rec.attribute8 := p10_a85;
    ddp_x_prd_workorder_rec.attribute9 := p10_a86;
    ddp_x_prd_workorder_rec.attribute10 := p10_a87;
    ddp_x_prd_workorder_rec.attribute11 := p10_a88;
    ddp_x_prd_workorder_rec.attribute12 := p10_a89;
    ddp_x_prd_workorder_rec.attribute13 := p10_a90;
    ddp_x_prd_workorder_rec.attribute14 := p10_a91;
    ddp_x_prd_workorder_rec.attribute15 := p10_a92;
    ddp_x_prd_workorder_rec.last_update_date := p10_a93;
    ddp_x_prd_workorder_rec.last_updated_by := p10_a94;
    ddp_x_prd_workorder_rec.creation_date := p10_a95;
    ddp_x_prd_workorder_rec.created_by := p10_a96;
    ddp_x_prd_workorder_rec.last_update_login := p10_a97;
    ddp_x_prd_workorder_rec.dml_operation := p10_a98;
    ddp_x_prd_workorder_rec.hold_reason_code := p10_a99;
    ddp_x_prd_workorder_rec.hold_reason := p10_a100;

    ahl_prd_workorder_pvt_w.rosetta_table_copy_in_p1(ddp_x_prd_workoper_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      , p11_a48
      , p11_a49
      , p11_a50
      , p11_a51
      , p11_a52
      , p11_a53
      , p11_a54
      , p11_a55
      , p11_a56
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_workorder_pvt.update_job(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_wip_load_flag,
      ddp_x_prd_workorder_rec,
      ddp_x_prd_workoper_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddp_x_prd_workorder_rec.batch_id;
    p10_a1 := ddp_x_prd_workorder_rec.header_id;
    p10_a2 := ddp_x_prd_workorder_rec.workorder_id;
    p10_a3 := ddp_x_prd_workorder_rec.wip_entity_id;
    p10_a4 := ddp_x_prd_workorder_rec.object_version_number;
    p10_a5 := ddp_x_prd_workorder_rec.job_number;
    p10_a6 := ddp_x_prd_workorder_rec.job_description;
    p10_a7 := ddp_x_prd_workorder_rec.organization_id;
    p10_a8 := ddp_x_prd_workorder_rec.organization_name;
    p10_a9 := ddp_x_prd_workorder_rec.organization_code;
    p10_a10 := ddp_x_prd_workorder_rec.department_name;
    p10_a11 := ddp_x_prd_workorder_rec.department_id;
    p10_a12 := ddp_x_prd_workorder_rec.department_class_code;
    p10_a13 := ddp_x_prd_workorder_rec.status_code;
    p10_a14 := ddp_x_prd_workorder_rec.status_meaning;
    p10_a15 := ddp_x_prd_workorder_rec.scheduled_start_date;
    p10_a16 := ddp_x_prd_workorder_rec.scheduled_start_hr;
    p10_a17 := ddp_x_prd_workorder_rec.scheduled_start_mi;
    p10_a18 := ddp_x_prd_workorder_rec.scheduled_end_date;
    p10_a19 := ddp_x_prd_workorder_rec.scheduled_end_hr;
    p10_a20 := ddp_x_prd_workorder_rec.scheduled_end_mi;
    p10_a21 := ddp_x_prd_workorder_rec.actual_start_date;
    p10_a22 := ddp_x_prd_workorder_rec.actual_start_hr;
    p10_a23 := ddp_x_prd_workorder_rec.actual_start_mi;
    p10_a24 := ddp_x_prd_workorder_rec.actual_end_date;
    p10_a25 := ddp_x_prd_workorder_rec.actual_end_hr;
    p10_a26 := ddp_x_prd_workorder_rec.actual_end_mi;
    p10_a27 := ddp_x_prd_workorder_rec.inventory_item_id;
    p10_a28 := ddp_x_prd_workorder_rec.item_instance_id;
    p10_a29 := ddp_x_prd_workorder_rec.unit_name;
    p10_a30 := ddp_x_prd_workorder_rec.item_instance_number;
    p10_a31 := ddp_x_prd_workorder_rec.wo_part_number;
    p10_a32 := ddp_x_prd_workorder_rec.item_description;
    p10_a33 := ddp_x_prd_workorder_rec.serial_number;
    p10_a34 := ddp_x_prd_workorder_rec.item_instance_uom;
    p10_a35 := ddp_x_prd_workorder_rec.completion_subinventory;
    p10_a36 := ddp_x_prd_workorder_rec.completion_locator_id;
    p10_a37 := ddp_x_prd_workorder_rec.completion_locator_name;
    p10_a38 := ddp_x_prd_workorder_rec.wip_supply_type;
    p10_a39 := ddp_x_prd_workorder_rec.wip_supply_meaning;
    p10_a40 := ddp_x_prd_workorder_rec.firm_planned_flag;
    p10_a41 := ddp_x_prd_workorder_rec.master_workorder_flag;
    p10_a42 := ddp_x_prd_workorder_rec.visit_id;
    p10_a43 := ddp_x_prd_workorder_rec.visit_number;
    p10_a44 := ddp_x_prd_workorder_rec.visit_name;
    p10_a45 := ddp_x_prd_workorder_rec.visit_task_id;
    p10_a46 := ddp_x_prd_workorder_rec.mr_header_id;
    p10_a47 := ddp_x_prd_workorder_rec.visit_task_number;
    p10_a48 := ddp_x_prd_workorder_rec.mr_title;
    p10_a49 := ddp_x_prd_workorder_rec.mr_route_id;
    p10_a50 := ddp_x_prd_workorder_rec.route_id;
    p10_a51 := ddp_x_prd_workorder_rec.confirm_failure_flag;
    p10_a52 := ddp_x_prd_workorder_rec.propagate_flag;
    p10_a53 := ddp_x_prd_workorder_rec.service_item_id;
    p10_a54 := ddp_x_prd_workorder_rec.service_item_org_id;
    p10_a55 := ddp_x_prd_workorder_rec.service_item_description;
    p10_a56 := ddp_x_prd_workorder_rec.service_item_number;
    p10_a57 := ddp_x_prd_workorder_rec.service_item_uom;
    p10_a58 := ddp_x_prd_workorder_rec.project_id;
    p10_a59 := ddp_x_prd_workorder_rec.project_task_id;
    p10_a60 := ddp_x_prd_workorder_rec.quantity;
    p10_a61 := ddp_x_prd_workorder_rec.mrp_quantity;
    p10_a62 := ddp_x_prd_workorder_rec.incident_id;
    p10_a63 := ddp_x_prd_workorder_rec.origination_task_id;
    p10_a64 := ddp_x_prd_workorder_rec.parent_id;
    p10_a65 := ddp_x_prd_workorder_rec.task_motive_status_id;
    p10_a66 := ddp_x_prd_workorder_rec.allow_explosion;
    p10_a67 := ddp_x_prd_workorder_rec.class_code;
    p10_a68 := ddp_x_prd_workorder_rec.job_priority;
    p10_a69 := ddp_x_prd_workorder_rec.job_priority_meaning;
    p10_a70 := ddp_x_prd_workorder_rec.confirmed_failure_flag;
    p10_a71 := ddp_x_prd_workorder_rec.unit_effectivity_id;
    p10_a72 := ddp_x_prd_workorder_rec.plan_id;
    p10_a73 := ddp_x_prd_workorder_rec.collection_id;
    p10_a74 := ddp_x_prd_workorder_rec.sub_inventory;
    p10_a75 := ddp_x_prd_workorder_rec.locator_id;
    p10_a76 := ddp_x_prd_workorder_rec.security_group_id;
    p10_a77 := ddp_x_prd_workorder_rec.attribute_category;
    p10_a78 := ddp_x_prd_workorder_rec.attribute1;
    p10_a79 := ddp_x_prd_workorder_rec.attribute2;
    p10_a80 := ddp_x_prd_workorder_rec.attribute3;
    p10_a81 := ddp_x_prd_workorder_rec.attribute4;
    p10_a82 := ddp_x_prd_workorder_rec.attribute5;
    p10_a83 := ddp_x_prd_workorder_rec.attribute6;
    p10_a84 := ddp_x_prd_workorder_rec.attribute7;
    p10_a85 := ddp_x_prd_workorder_rec.attribute8;
    p10_a86 := ddp_x_prd_workorder_rec.attribute9;
    p10_a87 := ddp_x_prd_workorder_rec.attribute10;
    p10_a88 := ddp_x_prd_workorder_rec.attribute11;
    p10_a89 := ddp_x_prd_workorder_rec.attribute12;
    p10_a90 := ddp_x_prd_workorder_rec.attribute13;
    p10_a91 := ddp_x_prd_workorder_rec.attribute14;
    p10_a92 := ddp_x_prd_workorder_rec.attribute15;
    p10_a93 := ddp_x_prd_workorder_rec.last_update_date;
    p10_a94 := ddp_x_prd_workorder_rec.last_updated_by;
    p10_a95 := ddp_x_prd_workorder_rec.creation_date;
    p10_a96 := ddp_x_prd_workorder_rec.created_by;
    p10_a97 := ddp_x_prd_workorder_rec.last_update_login;
    p10_a98 := ddp_x_prd_workorder_rec.dml_operation;
    p10_a99 := ddp_x_prd_workorder_rec.hold_reason_code;
    p10_a100 := ddp_x_prd_workorder_rec.hold_reason;

    ahl_prd_workorder_pvt_w.rosetta_table_copy_out_p1(ddp_x_prd_workoper_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      , p11_a48
      , p11_a49
      , p11_a50
      , p11_a51
      , p11_a52
      , p11_a53
      , p11_a54
      , p11_a55
      , p11_a56
      );
  end;

  procedure insert_turnover_notes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 in out nocopy JTF_DATE_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_trunover_notes_tbl ahl_prd_workorder_pvt.turnover_notes_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_prd_workorder_pvt_w.rosetta_table_copy_in_p13(ddp_trunover_notes_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_workorder_pvt.insert_turnover_notes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trunover_notes_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_prd_workorder_pvt_w.rosetta_table_copy_out_p13(ddp_trunover_notes_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      );
  end;

end ahl_prd_workorder_pvt_w;

/
