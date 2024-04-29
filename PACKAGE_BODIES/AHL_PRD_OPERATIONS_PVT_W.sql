--------------------------------------------------------
--  DDL for Package Body AHL_PRD_OPERATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_OPERATIONS_PVT_W" as
  /* $Header: AHLWPROB.pls 120.1 2006/02/08 06:05 bachandr noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_operations_pvt.prd_operation_tbl, a0 JTF_NUMBER_TABLE
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
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := a9(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
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
          t(ddindx).scheduled_start_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).scheduled_start_hr := a25(indx);
          t(ddindx).scheduled_start_mi := a26(indx);
          t(ddindx).scheduled_end_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).scheduled_end_hr := a28(indx);
          t(ddindx).scheduled_end_mi := a29(indx);
          t(ddindx).actual_start_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).actual_start_hr := a31(indx);
          t(ddindx).actual_start_mi := a32(indx);
          t(ddindx).actual_end_date := rosetta_g_miss_date_in_map(a33(indx));
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
  procedure rosetta_table_copy_out_p1(t ahl_prd_operations_pvt.prd_operation_tbl, a0 out nocopy JTF_NUMBER_TABLE
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

  procedure process_operations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_wip_mass_load_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_NUMBER_TABLE
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_DATE_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_DATE_TABLE
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_NUMBER_TABLE
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 in out nocopy JTF_NUMBER_TABLE
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 in out nocopy JTF_NUMBER_TABLE
    , p10_a23 in out nocopy JTF_NUMBER_TABLE
    , p10_a24 in out nocopy JTF_DATE_TABLE
    , p10_a25 in out nocopy JTF_NUMBER_TABLE
    , p10_a26 in out nocopy JTF_NUMBER_TABLE
    , p10_a27 in out nocopy JTF_DATE_TABLE
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p10_a30 in out nocopy JTF_DATE_TABLE
    , p10_a31 in out nocopy JTF_NUMBER_TABLE
    , p10_a32 in out nocopy JTF_NUMBER_TABLE
    , p10_a33 in out nocopy JTF_DATE_TABLE
    , p10_a34 in out nocopy JTF_NUMBER_TABLE
    , p10_a35 in out nocopy JTF_NUMBER_TABLE
    , p10_a36 in out nocopy JTF_NUMBER_TABLE
    , p10_a37 in out nocopy JTF_NUMBER_TABLE
    , p10_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 in out nocopy JTF_NUMBER_TABLE
    , p10_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a45 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p10_a56 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_prd_operation_tbl ahl_prd_operations_pvt.prd_operation_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ahl_prd_operations_pvt_w.rosetta_table_copy_in_p1(ddp_x_prd_operation_tbl, p10_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_operations_pvt.process_operations(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      p_wip_mass_load_flag,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_prd_operation_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ahl_prd_operations_pvt_w.rosetta_table_copy_out_p1(ddp_x_prd_operation_tbl, p10_a0
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
      );
  end;

end ahl_prd_operations_pvt_w;

/
