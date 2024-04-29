--------------------------------------------------------
--  DDL for Package Body AHL_FMP_EFFECTIVITY_DTL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_EFFECTIVITY_DTL_PVT_W" as
  /* $Header: AHLWMEDB.pls 120.1.12010000.4 2009/09/22 21:28:32 sikumar ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_fmp_effectivity_dtl_pvt.effectivity_detail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mr_effectivity_detail_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).exclude_flag := a2(indx);
          t(ddindx).serial_number_from := a3(indx);
          t(ddindx).serial_number_to := a4(indx);
          t(ddindx).manufacturer_id := a5(indx);
          t(ddindx).manufacturer := a6(indx);
          t(ddindx).manufacture_date_from := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).manufacture_date_to := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).country_code := a9(indx);
          t(ddindx).country := a10(indx);
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).attribute1 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute3 := a14(indx);
          t(ddindx).attribute4 := a15(indx);
          t(ddindx).attribute5 := a16(indx);
          t(ddindx).attribute6 := a17(indx);
          t(ddindx).attribute7 := a18(indx);
          t(ddindx).attribute8 := a19(indx);
          t(ddindx).attribute9 := a20(indx);
          t(ddindx).attribute10 := a21(indx);
          t(ddindx).attribute11 := a22(indx);
          t(ddindx).attribute12 := a23(indx);
          t(ddindx).attribute13 := a24(indx);
          t(ddindx).attribute14 := a25(indx);
          t(ddindx).attribute15 := a26(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_updated_by := a28(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).created_by := a30(indx);
          t(ddindx).last_update_login := a31(indx);
          t(ddindx).dml_operation := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_fmp_effectivity_dtl_pvt.effectivity_detail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).mr_effectivity_detail_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).exclude_flag;
          a3(indx) := t(ddindx).serial_number_from;
          a4(indx) := t(ddindx).serial_number_to;
          a5(indx) := t(ddindx).manufacturer_id;
          a6(indx) := t(ddindx).manufacturer;
          a7(indx) := t(ddindx).manufacture_date_from;
          a8(indx) := t(ddindx).manufacture_date_to;
          a9(indx) := t(ddindx).country_code;
          a10(indx) := t(ddindx).country;
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).attribute1;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute3;
          a15(indx) := t(ddindx).attribute4;
          a16(indx) := t(ddindx).attribute5;
          a17(indx) := t(ddindx).attribute6;
          a18(indx) := t(ddindx).attribute7;
          a19(indx) := t(ddindx).attribute8;
          a20(indx) := t(ddindx).attribute9;
          a21(indx) := t(ddindx).attribute10;
          a22(indx) := t(ddindx).attribute11;
          a23(indx) := t(ddindx).attribute12;
          a24(indx) := t(ddindx).attribute13;
          a25(indx) := t(ddindx).attribute14;
          a26(indx) := t(ddindx).attribute15;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := t(ddindx).last_updated_by;
          a29(indx) := t(ddindx).creation_date;
          a30(indx) := t(ddindx).created_by;
          a31(indx) := t(ddindx).last_update_login;
          a32(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_fmp_effectivity_dtl_pvt.effty_ext_detail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mr_effectivity_ext_dtl_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).effect_ext_dtl_rec_type := a2(indx);
          t(ddindx).exclude_flag := a3(indx);
          t(ddindx).owner_id := a4(indx);
          t(ddindx).owner := a5(indx);
          t(ddindx).location := a6(indx);
          t(ddindx).location_type_code := a7(indx);
          t(ddindx).csi_ext_attribute_code := a8(indx);
          t(ddindx).csi_ext_attribute_name := a9(indx);
          t(ddindx).csi_ext_attribute_value := a10(indx);
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).attribute1 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute3 := a14(indx);
          t(ddindx).attribute4 := a15(indx);
          t(ddindx).attribute5 := a16(indx);
          t(ddindx).attribute6 := a17(indx);
          t(ddindx).attribute7 := a18(indx);
          t(ddindx).attribute8 := a19(indx);
          t(ddindx).attribute9 := a20(indx);
          t(ddindx).attribute10 := a21(indx);
          t(ddindx).attribute11 := a22(indx);
          t(ddindx).attribute12 := a23(indx);
          t(ddindx).attribute13 := a24(indx);
          t(ddindx).attribute14 := a25(indx);
          t(ddindx).attribute15 := a26(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_updated_by := a28(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).created_by := a30(indx);
          t(ddindx).last_update_login := a31(indx);
          t(ddindx).dml_operation := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_fmp_effectivity_dtl_pvt.effty_ext_detail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_400();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_400();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).mr_effectivity_ext_dtl_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).effect_ext_dtl_rec_type;
          a3(indx) := t(ddindx).exclude_flag;
          a4(indx) := t(ddindx).owner_id;
          a5(indx) := t(ddindx).owner;
          a6(indx) := t(ddindx).location;
          a7(indx) := t(ddindx).location_type_code;
          a8(indx) := t(ddindx).csi_ext_attribute_code;
          a9(indx) := t(ddindx).csi_ext_attribute_name;
          a10(indx) := t(ddindx).csi_ext_attribute_value;
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).attribute1;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute3;
          a15(indx) := t(ddindx).attribute4;
          a16(indx) := t(ddindx).attribute5;
          a17(indx) := t(ddindx).attribute6;
          a18(indx) := t(ddindx).attribute7;
          a19(indx) := t(ddindx).attribute8;
          a20(indx) := t(ddindx).attribute9;
          a21(indx) := t(ddindx).attribute10;
          a22(indx) := t(ddindx).attribute11;
          a23(indx) := t(ddindx).attribute12;
          a24(indx) := t(ddindx).attribute13;
          a25(indx) := t(ddindx).attribute14;
          a26(indx) := t(ddindx).attribute15;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := t(ddindx).last_updated_by;
          a29(indx) := t(ddindx).creation_date;
          a30(indx) := t(ddindx).created_by;
          a31(indx) := t(ddindx).last_update_login;
          a32(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure process_effectivity_detail(p_api_version  NUMBER
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
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_DATE_TABLE
    , p9_a8 in out nocopy JTF_DATE_TABLE
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 in out nocopy JTF_DATE_TABLE
    , p9_a28 in out nocopy JTF_NUMBER_TABLE
    , p9_a29 in out nocopy JTF_DATE_TABLE
    , p9_a30 in out nocopy JTF_NUMBER_TABLE
    , p9_a31 in out nocopy JTF_NUMBER_TABLE
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_DATE_TABLE
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_DATE_TABLE
    , p10_a30 in out nocopy JTF_NUMBER_TABLE
    , p10_a31 in out nocopy JTF_NUMBER_TABLE
    , p10_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_mr_header_id  NUMBER
    , p_mr_effectivity_id  NUMBER
  )

  as
    ddp_x_effectivity_detail_tbl ahl_fmp_effectivity_dtl_pvt.effectivity_detail_tbl_type;
    ddp_x_effty_ext_detail_tbl ahl_fmp_effectivity_dtl_pvt.effty_ext_detail_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_fmp_effectivity_dtl_pvt_w.rosetta_table_copy_in_p1(ddp_x_effectivity_detail_tbl, p9_a0
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
      );

    ahl_fmp_effectivity_dtl_pvt_w.rosetta_table_copy_in_p3(ddp_x_effty_ext_detail_tbl, p10_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    ahl_fmp_effectivity_dtl_pvt.process_effectivity_detail(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_effectivity_detail_tbl,
      ddp_x_effty_ext_detail_tbl,
      p_mr_header_id,
      p_mr_effectivity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_fmp_effectivity_dtl_pvt_w.rosetta_table_copy_out_p1(ddp_x_effectivity_detail_tbl, p9_a0
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
      );

    ahl_fmp_effectivity_dtl_pvt_w.rosetta_table_copy_out_p3(ddp_x_effty_ext_detail_tbl, p10_a0
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
      );


  end;

end ahl_fmp_effectivity_dtl_pvt_w;

/
