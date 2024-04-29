--------------------------------------------------------
--  DDL for Package Body AHL_RM_MATERIAL_AS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_MATERIAL_AS_PVT_W" as
  /* $Header: AHLWMTLB.pls 120.1 2008/01/30 05:20:53 pdoki ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_rm_material_as_pvt.material_req_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_4000
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rt_oper_material_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).item_group_id := a2(indx);
          t(ddindx).item_group_name := a3(indx);
          t(ddindx).item_number := a4(indx);
          t(ddindx).inventory_item_id := a5(indx);
          t(ddindx).inventory_org_id := a6(indx);
          t(ddindx).uom := a7(indx);
          t(ddindx).uom_code := a8(indx);
          t(ddindx).quantity := a9(indx);
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_updated_by := a27(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).created_by := a29(indx);
          t(ddindx).last_update_login := a30(indx);
          t(ddindx).dml_operation := a31(indx);
          t(ddindx).position_path := a32(indx);
          t(ddindx).position_path_id := a33(indx);
          t(ddindx).item_comp_detail_id := a34(indx);
          t(ddindx).exclude_flag := a35(indx);
          t(ddindx).rework_percent := a36(indx);
          t(ddindx).replace_percent := a37(indx);
          t(ddindx).comp_material_flag := a38(indx);
          t(ddindx).in_service := a39(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_rm_material_as_pvt.material_req_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_4000
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_4000();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_4000();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rt_oper_material_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).item_group_id;
          a3(indx) := t(ddindx).item_group_name;
          a4(indx) := t(ddindx).item_number;
          a5(indx) := t(ddindx).inventory_item_id;
          a6(indx) := t(ddindx).inventory_org_id;
          a7(indx) := t(ddindx).uom;
          a8(indx) := t(ddindx).uom_code;
          a9(indx) := t(ddindx).quantity;
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := t(ddindx).last_update_date;
          a27(indx) := t(ddindx).last_updated_by;
          a28(indx) := t(ddindx).creation_date;
          a29(indx) := t(ddindx).created_by;
          a30(indx) := t(ddindx).last_update_login;
          a31(indx) := t(ddindx).dml_operation;
          a32(indx) := t(ddindx).position_path;
          a33(indx) := t(ddindx).position_path_id;
          a34(indx) := t(ddindx).item_comp_detail_id;
          a35(indx) := t(ddindx).exclude_flag;
          a36(indx) := t(ddindx).rework_percent;
          a37(indx) := t(ddindx).replace_percent;
          a38(indx) := t(ddindx).comp_material_flag;
          a39(indx) := t(ddindx).in_service;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_rm_material_as_pvt.route_efct_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).route_effectivity_id := a0(indx);
          t(ddindx).route_no := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).inventory_master_org_id := a3(indx);
          t(ddindx).item_number := a4(indx);
          t(ddindx).description := a5(indx);
          t(ddindx).organization_code := a6(indx);
          t(ddindx).mc_id := a7(indx);
          t(ddindx).mc_name := a8(indx);
          t(ddindx).mc_version_number := a9(indx);
          t(ddindx).mc_revision := a10(indx);
          t(ddindx).mc_description := a11(indx);
          t(ddindx).mc_header_id := a12(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).last_updated_by := a14(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).created_by := a16(indx);
          t(ddindx).last_update_login := a17(indx);
          t(ddindx).object_version_number := a18(indx);
          t(ddindx).security_group_id := a19(indx);
          t(ddindx).attribute_category := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).dml_operation := a36(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_rm_material_as_pvt.route_efct_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).route_effectivity_id;
          a1(indx) := t(ddindx).route_no;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).inventory_master_org_id;
          a4(indx) := t(ddindx).item_number;
          a5(indx) := t(ddindx).description;
          a6(indx) := t(ddindx).organization_code;
          a7(indx) := t(ddindx).mc_id;
          a8(indx) := t(ddindx).mc_name;
          a9(indx) := t(ddindx).mc_version_number;
          a10(indx) := t(ddindx).mc_revision;
          a11(indx) := t(ddindx).mc_description;
          a12(indx) := t(ddindx).mc_header_id;
          a13(indx) := t(ddindx).last_update_date;
          a14(indx) := t(ddindx).last_updated_by;
          a15(indx) := t(ddindx).creation_date;
          a16(indx) := t(ddindx).created_by;
          a17(indx) := t(ddindx).last_update_login;
          a18(indx) := t(ddindx).object_version_number;
          a19(indx) := t(ddindx).security_group_id;
          a20(indx) := t(ddindx).attribute_category;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure process_material_req(p_api_version  NUMBER
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
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_DATE_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p9_a28 in out nocopy JTF_DATE_TABLE
    , p9_a29 in out nocopy JTF_NUMBER_TABLE
    , p9_a30 in out nocopy JTF_NUMBER_TABLE
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a33 in out nocopy JTF_NUMBER_TABLE
    , p9_a34 in out nocopy JTF_NUMBER_TABLE
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 in out nocopy JTF_NUMBER_TABLE
    , p9_a37 in out nocopy JTF_NUMBER_TABLE
    , p9_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_object_id  NUMBER
    , p_association_type  VARCHAR2
  )

  as
    ddp_x_material_req_tbl ahl_rm_material_as_pvt.material_req_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_rm_material_as_pvt_w.rosetta_table_copy_in_p1(ddp_x_material_req_tbl, p9_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    ahl_rm_material_as_pvt.process_material_req(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_material_req_tbl,
      p_object_id,
      p_association_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_rm_material_as_pvt_w.rosetta_table_copy_out_p1(ddp_x_material_req_tbl, p9_a0
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
      );


  end;

  procedure process_route_efcts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_object_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a12 in out nocopy JTF_NUMBER_TABLE
    , p10_a13 in out nocopy JTF_DATE_TABLE
    , p10_a14 in out nocopy JTF_NUMBER_TABLE
    , p10_a15 in out nocopy JTF_DATE_TABLE
    , p10_a16 in out nocopy JTF_NUMBER_TABLE
    , p10_a17 in out nocopy JTF_NUMBER_TABLE
    , p10_a18 in out nocopy JTF_NUMBER_TABLE
    , p10_a19 in out nocopy JTF_NUMBER_TABLE
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a36 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_route_efct_tbl ahl_rm_material_as_pvt.route_efct_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ahl_rm_material_as_pvt_w.rosetta_table_copy_in_p3(ddp_x_route_efct_tbl, p10_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_rm_material_as_pvt.process_route_efcts(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      p_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_route_efct_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ahl_rm_material_as_pvt_w.rosetta_table_copy_out_p3(ddp_x_route_efct_tbl, p10_a0
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
      );
  end;

end ahl_rm_material_as_pvt_w;

/
