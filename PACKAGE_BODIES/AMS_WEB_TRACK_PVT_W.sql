--------------------------------------------------------
--  DDL for Package Body AMS_WEB_TRACK_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WEB_TRACK_PVT_W" as
  /* $Header: amswwtgb.pls 120.1 2005/06/27 05:43:44 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_web_track_pvt.web_track_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a27 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).web_tracking_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).schedule_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).schedule_type := a2(indx);
          t(ddindx).party_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).placement_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).content_item_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).attribute_category := a12(indx);
          t(ddindx).attribute1 := a13(indx);
          t(ddindx).attribute2 := a14(indx);
          t(ddindx).attribute3 := a15(indx);
          t(ddindx).attribute4 := a16(indx);
          t(ddindx).attribute5 := a17(indx);
          t(ddindx).attribute6 := a18(indx);
          t(ddindx).attribute7 := a19(indx);
          t(ddindx).attribute8 := a20(indx);
          t(ddindx).attribute9 := a21(indx);
          t(ddindx).attribute10 := a22(indx);
          t(ddindx).attribute11 := a23(indx);
          t(ddindx).attribute12 := a24(indx);
          t(ddindx).attribute13 := a25(indx);
          t(ddindx).attribute14 := a26(indx);
          t(ddindx).attribute15 := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_web_track_pvt.web_track_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_DATE_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_NUMBER_TABLE
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a27 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a27 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a27 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).web_tracking_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).schedule_id);
          a2(indx) := t(ddindx).schedule_type;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).placement_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).content_item_id);
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a12(indx) := t(ddindx).attribute_category;
          a13(indx) := t(ddindx).attribute1;
          a14(indx) := t(ddindx).attribute2;
          a15(indx) := t(ddindx).attribute3;
          a16(indx) := t(ddindx).attribute4;
          a17(indx) := t(ddindx).attribute5;
          a18(indx) := t(ddindx).attribute6;
          a19(indx) := t(ddindx).attribute7;
          a20(indx) := t(ddindx).attribute8;
          a21(indx) := t(ddindx).attribute9;
          a22(indx) := t(ddindx).attribute10;
          a23(indx) := t(ddindx).attribute11;
          a24(indx) := t(ddindx).attribute12;
          a25(indx) := t(ddindx).attribute13;
          a26(indx) := t(ddindx).attribute14;
          a27(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p13(t OUT NOCOPY ams_web_track_pvt.web_recomms_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
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
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).web_recomm_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).web_tracking_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).recomm_object_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).recomm_type := a3(indx);
          t(ddindx).rule_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).offer_src_code := a6(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).attribute_category := a13(indx);
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute2 := a15(indx);
          t(ddindx).attribute3 := a16(indx);
          t(ddindx).attribute4 := a17(indx);
          t(ddindx).attribute5 := a18(indx);
          t(ddindx).attribute6 := a19(indx);
          t(ddindx).attribute7 := a20(indx);
          t(ddindx).attribute8 := a21(indx);
          t(ddindx).attribute9 := a22(indx);
          t(ddindx).attribute10 := a23(indx);
          t(ddindx).attribute11 := a24(indx);
          t(ddindx).attribute12 := a25(indx);
          t(ddindx).attribute13 := a26(indx);
          t(ddindx).attribute14 := a27(indx);
          t(ddindx).attribute15 := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t ams_web_track_pvt.web_recomms_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_DATE_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_DATE_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_NUMBER_TABLE
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a27 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a28 OUT NOCOPY JTF_VARCHAR2_TABLE_200
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
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
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
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
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).web_recomm_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).web_tracking_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).recomm_object_id);
          a3(indx) := t(ddindx).recomm_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a6(indx) := t(ddindx).offer_src_code;
          a7(indx) := t(ddindx).last_update_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a13(indx) := t(ddindx).attribute_category;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute2;
          a16(indx) := t(ddindx).attribute3;
          a17(indx) := t(ddindx).attribute4;
          a18(indx) := t(ddindx).attribute5;
          a19(indx) := t(ddindx).attribute6;
          a20(indx) := t(ddindx).attribute7;
          a21(indx) := t(ddindx).attribute8;
          a22(indx) := t(ddindx).attribute9;
          a23(indx) := t(ddindx).attribute10;
          a24(indx) := t(ddindx).attribute11;
          a25(indx) := t(ddindx).attribute12;
          a26(indx) := t(ddindx).attribute13;
          a27(indx) := t(ddindx).attribute14;
          a28(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p23(t OUT NOCOPY ams_web_track_pvt.impr_obj_id_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).obj_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).impr_track_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t ams_web_track_pvt.impr_obj_id_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).obj_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).impr_track_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure create_web_track(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_web_tracking_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_track_rec ams_web_track_pvt.web_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_web_track_rec.web_tracking_id := rosetta_g_miss_num_map(p7_a0);
    ddp_web_track_rec.schedule_id := rosetta_g_miss_num_map(p7_a1);
    ddp_web_track_rec.schedule_type := p7_a2;
    ddp_web_track_rec.party_id := rosetta_g_miss_num_map(p7_a3);
    ddp_web_track_rec.placement_id := rosetta_g_miss_num_map(p7_a4);
    ddp_web_track_rec.content_item_id := rosetta_g_miss_num_map(p7_a5);
    ddp_web_track_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_web_track_rec.last_updated_by := rosetta_g_miss_num_map(p7_a7);
    ddp_web_track_rec.creation_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_web_track_rec.created_by := rosetta_g_miss_num_map(p7_a9);
    ddp_web_track_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);
    ddp_web_track_rec.object_version_number := rosetta_g_miss_num_map(p7_a11);
    ddp_web_track_rec.attribute_category := p7_a12;
    ddp_web_track_rec.attribute1 := p7_a13;
    ddp_web_track_rec.attribute2 := p7_a14;
    ddp_web_track_rec.attribute3 := p7_a15;
    ddp_web_track_rec.attribute4 := p7_a16;
    ddp_web_track_rec.attribute5 := p7_a17;
    ddp_web_track_rec.attribute6 := p7_a18;
    ddp_web_track_rec.attribute7 := p7_a19;
    ddp_web_track_rec.attribute8 := p7_a20;
    ddp_web_track_rec.attribute9 := p7_a21;
    ddp_web_track_rec.attribute10 := p7_a22;
    ddp_web_track_rec.attribute11 := p7_a23;
    ddp_web_track_rec.attribute12 := p7_a24;
    ddp_web_track_rec.attribute13 := p7_a25;
    ddp_web_track_rec.attribute14 := p7_a26;
    ddp_web_track_rec.attribute15 := p7_a27;


    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.create_web_track(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_web_track_rec,
      x_web_tracking_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_web_track(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_track_rec ams_web_track_pvt.web_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_web_track_rec.web_tracking_id := rosetta_g_miss_num_map(p7_a0);
    ddp_web_track_rec.schedule_id := rosetta_g_miss_num_map(p7_a1);
    ddp_web_track_rec.schedule_type := p7_a2;
    ddp_web_track_rec.party_id := rosetta_g_miss_num_map(p7_a3);
    ddp_web_track_rec.placement_id := rosetta_g_miss_num_map(p7_a4);
    ddp_web_track_rec.content_item_id := rosetta_g_miss_num_map(p7_a5);
    ddp_web_track_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_web_track_rec.last_updated_by := rosetta_g_miss_num_map(p7_a7);
    ddp_web_track_rec.creation_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_web_track_rec.created_by := rosetta_g_miss_num_map(p7_a9);
    ddp_web_track_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);
    ddp_web_track_rec.object_version_number := rosetta_g_miss_num_map(p7_a11);
    ddp_web_track_rec.attribute_category := p7_a12;
    ddp_web_track_rec.attribute1 := p7_a13;
    ddp_web_track_rec.attribute2 := p7_a14;
    ddp_web_track_rec.attribute3 := p7_a15;
    ddp_web_track_rec.attribute4 := p7_a16;
    ddp_web_track_rec.attribute5 := p7_a17;
    ddp_web_track_rec.attribute6 := p7_a18;
    ddp_web_track_rec.attribute7 := p7_a19;
    ddp_web_track_rec.attribute8 := p7_a20;
    ddp_web_track_rec.attribute9 := p7_a21;
    ddp_web_track_rec.attribute10 := p7_a22;
    ddp_web_track_rec.attribute11 := p7_a23;
    ddp_web_track_rec.attribute12 := p7_a24;
    ddp_web_track_rec.attribute13 := p7_a25;
    ddp_web_track_rec.attribute14 := p7_a26;
    ddp_web_track_rec.attribute15 := p7_a27;

    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.update_web_track(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_web_track_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_web_track(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  DATE := fnd_api.g_miss_date
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  DATE := fnd_api.g_miss_date
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_track_rec ams_web_track_pvt.web_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_web_track_rec.web_tracking_id := rosetta_g_miss_num_map(p3_a0);
    ddp_web_track_rec.schedule_id := rosetta_g_miss_num_map(p3_a1);
    ddp_web_track_rec.schedule_type := p3_a2;
    ddp_web_track_rec.party_id := rosetta_g_miss_num_map(p3_a3);
    ddp_web_track_rec.placement_id := rosetta_g_miss_num_map(p3_a4);
    ddp_web_track_rec.content_item_id := rosetta_g_miss_num_map(p3_a5);
    ddp_web_track_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_web_track_rec.last_updated_by := rosetta_g_miss_num_map(p3_a7);
    ddp_web_track_rec.creation_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_web_track_rec.created_by := rosetta_g_miss_num_map(p3_a9);
    ddp_web_track_rec.last_update_login := rosetta_g_miss_num_map(p3_a10);
    ddp_web_track_rec.object_version_number := rosetta_g_miss_num_map(p3_a11);
    ddp_web_track_rec.attribute_category := p3_a12;
    ddp_web_track_rec.attribute1 := p3_a13;
    ddp_web_track_rec.attribute2 := p3_a14;
    ddp_web_track_rec.attribute3 := p3_a15;
    ddp_web_track_rec.attribute4 := p3_a16;
    ddp_web_track_rec.attribute5 := p3_a17;
    ddp_web_track_rec.attribute6 := p3_a18;
    ddp_web_track_rec.attribute7 := p3_a19;
    ddp_web_track_rec.attribute8 := p3_a20;
    ddp_web_track_rec.attribute9 := p3_a21;
    ddp_web_track_rec.attribute10 := p3_a22;
    ddp_web_track_rec.attribute11 := p3_a23;
    ddp_web_track_rec.attribute12 := p3_a24;
    ddp_web_track_rec.attribute13 := p3_a25;
    ddp_web_track_rec.attribute14 := p3_a26;
    ddp_web_track_rec.attribute15 := p3_a27;





    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.validate_web_track(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_web_track_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_web_track_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_track_rec ams_web_track_pvt.web_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_web_track_rec.web_tracking_id := rosetta_g_miss_num_map(p0_a0);
    ddp_web_track_rec.schedule_id := rosetta_g_miss_num_map(p0_a1);
    ddp_web_track_rec.schedule_type := p0_a2;
    ddp_web_track_rec.party_id := rosetta_g_miss_num_map(p0_a3);
    ddp_web_track_rec.placement_id := rosetta_g_miss_num_map(p0_a4);
    ddp_web_track_rec.content_item_id := rosetta_g_miss_num_map(p0_a5);
    ddp_web_track_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_web_track_rec.last_updated_by := rosetta_g_miss_num_map(p0_a7);
    ddp_web_track_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_web_track_rec.created_by := rosetta_g_miss_num_map(p0_a9);
    ddp_web_track_rec.last_update_login := rosetta_g_miss_num_map(p0_a10);
    ddp_web_track_rec.object_version_number := rosetta_g_miss_num_map(p0_a11);
    ddp_web_track_rec.attribute_category := p0_a12;
    ddp_web_track_rec.attribute1 := p0_a13;
    ddp_web_track_rec.attribute2 := p0_a14;
    ddp_web_track_rec.attribute3 := p0_a15;
    ddp_web_track_rec.attribute4 := p0_a16;
    ddp_web_track_rec.attribute5 := p0_a17;
    ddp_web_track_rec.attribute6 := p0_a18;
    ddp_web_track_rec.attribute7 := p0_a19;
    ddp_web_track_rec.attribute8 := p0_a20;
    ddp_web_track_rec.attribute9 := p0_a21;
    ddp_web_track_rec.attribute10 := p0_a22;
    ddp_web_track_rec.attribute11 := p0_a23;
    ddp_web_track_rec.attribute12 := p0_a24;
    ddp_web_track_rec.attribute13 := p0_a25;
    ddp_web_track_rec.attribute14 := p0_a26;
    ddp_web_track_rec.attribute15 := p0_a27;



    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.check_web_track_items(ddp_web_track_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_web_track_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_track_rec ams_web_track_pvt.web_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_web_track_rec.web_tracking_id := rosetta_g_miss_num_map(p5_a0);
    ddp_web_track_rec.schedule_id := rosetta_g_miss_num_map(p5_a1);
    ddp_web_track_rec.schedule_type := p5_a2;
    ddp_web_track_rec.party_id := rosetta_g_miss_num_map(p5_a3);
    ddp_web_track_rec.placement_id := rosetta_g_miss_num_map(p5_a4);
    ddp_web_track_rec.content_item_id := rosetta_g_miss_num_map(p5_a5);
    ddp_web_track_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_web_track_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_web_track_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_web_track_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_web_track_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);
    ddp_web_track_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_web_track_rec.attribute_category := p5_a12;
    ddp_web_track_rec.attribute1 := p5_a13;
    ddp_web_track_rec.attribute2 := p5_a14;
    ddp_web_track_rec.attribute3 := p5_a15;
    ddp_web_track_rec.attribute4 := p5_a16;
    ddp_web_track_rec.attribute5 := p5_a17;
    ddp_web_track_rec.attribute6 := p5_a18;
    ddp_web_track_rec.attribute7 := p5_a19;
    ddp_web_track_rec.attribute8 := p5_a20;
    ddp_web_track_rec.attribute9 := p5_a21;
    ddp_web_track_rec.attribute10 := p5_a22;
    ddp_web_track_rec.attribute11 := p5_a23;
    ddp_web_track_rec.attribute12 := p5_a24;
    ddp_web_track_rec.attribute13 := p5_a25;
    ddp_web_track_rec.attribute14 := p5_a26;
    ddp_web_track_rec.attribute15 := p5_a27;

    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.validate_web_track_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_web_track_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_web_recomms(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_web_recomm_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_recomms_rec ams_web_track_pvt.web_recomms_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_web_recomms_rec.web_recomm_id := rosetta_g_miss_num_map(p7_a0);
    ddp_web_recomms_rec.web_tracking_id := rosetta_g_miss_num_map(p7_a1);
    ddp_web_recomms_rec.recomm_object_id := rosetta_g_miss_num_map(p7_a2);
    ddp_web_recomms_rec.recomm_type := p7_a3;
    ddp_web_recomms_rec.rule_id := rosetta_g_miss_num_map(p7_a4);
    ddp_web_recomms_rec.offer_id := rosetta_g_miss_num_map(p7_a5);
    ddp_web_recomms_rec.offer_src_code := p7_a6;
    ddp_web_recomms_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_web_recomms_rec.last_updated_by := rosetta_g_miss_num_map(p7_a8);
    ddp_web_recomms_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_web_recomms_rec.created_by := rosetta_g_miss_num_map(p7_a10);
    ddp_web_recomms_rec.last_update_login := rosetta_g_miss_num_map(p7_a11);
    ddp_web_recomms_rec.object_version_number := rosetta_g_miss_num_map(p7_a12);
    ddp_web_recomms_rec.attribute_category := p7_a13;
    ddp_web_recomms_rec.attribute1 := p7_a14;
    ddp_web_recomms_rec.attribute2 := p7_a15;
    ddp_web_recomms_rec.attribute3 := p7_a16;
    ddp_web_recomms_rec.attribute4 := p7_a17;
    ddp_web_recomms_rec.attribute5 := p7_a18;
    ddp_web_recomms_rec.attribute6 := p7_a19;
    ddp_web_recomms_rec.attribute7 := p7_a20;
    ddp_web_recomms_rec.attribute8 := p7_a21;
    ddp_web_recomms_rec.attribute9 := p7_a22;
    ddp_web_recomms_rec.attribute10 := p7_a23;
    ddp_web_recomms_rec.attribute11 := p7_a24;
    ddp_web_recomms_rec.attribute12 := p7_a25;
    ddp_web_recomms_rec.attribute13 := p7_a26;
    ddp_web_recomms_rec.attribute14 := p7_a27;
    ddp_web_recomms_rec.attribute15 := p7_a28;


    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.create_web_recomms(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_web_recomms_rec,
      x_web_recomm_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_web_recomms(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_recomms_rec ams_web_track_pvt.web_recomms_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_web_recomms_rec.web_recomm_id := rosetta_g_miss_num_map(p7_a0);
    ddp_web_recomms_rec.web_tracking_id := rosetta_g_miss_num_map(p7_a1);
    ddp_web_recomms_rec.recomm_object_id := rosetta_g_miss_num_map(p7_a2);
    ddp_web_recomms_rec.recomm_type := p7_a3;
    ddp_web_recomms_rec.rule_id := rosetta_g_miss_num_map(p7_a4);
    ddp_web_recomms_rec.offer_id := rosetta_g_miss_num_map(p7_a5);
    ddp_web_recomms_rec.offer_src_code := p7_a6;
    ddp_web_recomms_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_web_recomms_rec.last_updated_by := rosetta_g_miss_num_map(p7_a8);
    ddp_web_recomms_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_web_recomms_rec.created_by := rosetta_g_miss_num_map(p7_a10);
    ddp_web_recomms_rec.last_update_login := rosetta_g_miss_num_map(p7_a11);
    ddp_web_recomms_rec.object_version_number := rosetta_g_miss_num_map(p7_a12);
    ddp_web_recomms_rec.attribute_category := p7_a13;
    ddp_web_recomms_rec.attribute1 := p7_a14;
    ddp_web_recomms_rec.attribute2 := p7_a15;
    ddp_web_recomms_rec.attribute3 := p7_a16;
    ddp_web_recomms_rec.attribute4 := p7_a17;
    ddp_web_recomms_rec.attribute5 := p7_a18;
    ddp_web_recomms_rec.attribute6 := p7_a19;
    ddp_web_recomms_rec.attribute7 := p7_a20;
    ddp_web_recomms_rec.attribute8 := p7_a21;
    ddp_web_recomms_rec.attribute9 := p7_a22;
    ddp_web_recomms_rec.attribute10 := p7_a23;
    ddp_web_recomms_rec.attribute11 := p7_a24;
    ddp_web_recomms_rec.attribute12 := p7_a25;
    ddp_web_recomms_rec.attribute13 := p7_a26;
    ddp_web_recomms_rec.attribute14 := p7_a27;
    ddp_web_recomms_rec.attribute15 := p7_a28;

    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.update_web_recomms(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_web_recomms_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_web_recomms(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  DATE := fnd_api.g_miss_date
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_recomms_rec ams_web_track_pvt.web_recomms_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_web_recomms_rec.web_recomm_id := rosetta_g_miss_num_map(p3_a0);
    ddp_web_recomms_rec.web_tracking_id := rosetta_g_miss_num_map(p3_a1);
    ddp_web_recomms_rec.recomm_object_id := rosetta_g_miss_num_map(p3_a2);
    ddp_web_recomms_rec.recomm_type := p3_a3;
    ddp_web_recomms_rec.rule_id := rosetta_g_miss_num_map(p3_a4);
    ddp_web_recomms_rec.offer_id := rosetta_g_miss_num_map(p3_a5);
    ddp_web_recomms_rec.offer_src_code := p3_a6;
    ddp_web_recomms_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_web_recomms_rec.last_updated_by := rosetta_g_miss_num_map(p3_a8);
    ddp_web_recomms_rec.creation_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_web_recomms_rec.created_by := rosetta_g_miss_num_map(p3_a10);
    ddp_web_recomms_rec.last_update_login := rosetta_g_miss_num_map(p3_a11);
    ddp_web_recomms_rec.object_version_number := rosetta_g_miss_num_map(p3_a12);
    ddp_web_recomms_rec.attribute_category := p3_a13;
    ddp_web_recomms_rec.attribute1 := p3_a14;
    ddp_web_recomms_rec.attribute2 := p3_a15;
    ddp_web_recomms_rec.attribute3 := p3_a16;
    ddp_web_recomms_rec.attribute4 := p3_a17;
    ddp_web_recomms_rec.attribute5 := p3_a18;
    ddp_web_recomms_rec.attribute6 := p3_a19;
    ddp_web_recomms_rec.attribute7 := p3_a20;
    ddp_web_recomms_rec.attribute8 := p3_a21;
    ddp_web_recomms_rec.attribute9 := p3_a22;
    ddp_web_recomms_rec.attribute10 := p3_a23;
    ddp_web_recomms_rec.attribute11 := p3_a24;
    ddp_web_recomms_rec.attribute12 := p3_a25;
    ddp_web_recomms_rec.attribute13 := p3_a26;
    ddp_web_recomms_rec.attribute14 := p3_a27;
    ddp_web_recomms_rec.attribute15 := p3_a28;





    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.validate_web_recomms(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_web_recomms_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_web_recomms_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_recomms_rec ams_web_track_pvt.web_recomms_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_web_recomms_rec.web_recomm_id := rosetta_g_miss_num_map(p0_a0);
    ddp_web_recomms_rec.web_tracking_id := rosetta_g_miss_num_map(p0_a1);
    ddp_web_recomms_rec.recomm_object_id := rosetta_g_miss_num_map(p0_a2);
    ddp_web_recomms_rec.recomm_type := p0_a3;
    ddp_web_recomms_rec.rule_id := rosetta_g_miss_num_map(p0_a4);
    ddp_web_recomms_rec.offer_id := rosetta_g_miss_num_map(p0_a5);
    ddp_web_recomms_rec.offer_src_code := p0_a6;
    ddp_web_recomms_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_web_recomms_rec.last_updated_by := rosetta_g_miss_num_map(p0_a8);
    ddp_web_recomms_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_web_recomms_rec.created_by := rosetta_g_miss_num_map(p0_a10);
    ddp_web_recomms_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);
    ddp_web_recomms_rec.object_version_number := rosetta_g_miss_num_map(p0_a12);
    ddp_web_recomms_rec.attribute_category := p0_a13;
    ddp_web_recomms_rec.attribute1 := p0_a14;
    ddp_web_recomms_rec.attribute2 := p0_a15;
    ddp_web_recomms_rec.attribute3 := p0_a16;
    ddp_web_recomms_rec.attribute4 := p0_a17;
    ddp_web_recomms_rec.attribute5 := p0_a18;
    ddp_web_recomms_rec.attribute6 := p0_a19;
    ddp_web_recomms_rec.attribute7 := p0_a20;
    ddp_web_recomms_rec.attribute8 := p0_a21;
    ddp_web_recomms_rec.attribute9 := p0_a22;
    ddp_web_recomms_rec.attribute10 := p0_a23;
    ddp_web_recomms_rec.attribute11 := p0_a24;
    ddp_web_recomms_rec.attribute12 := p0_a25;
    ddp_web_recomms_rec.attribute13 := p0_a26;
    ddp_web_recomms_rec.attribute14 := p0_a27;
    ddp_web_recomms_rec.attribute15 := p0_a28;



    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.check_web_recomms_items(ddp_web_recomms_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_web_recomms_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_recomms_rec ams_web_track_pvt.web_recomms_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_web_recomms_rec.web_recomm_id := rosetta_g_miss_num_map(p5_a0);
    ddp_web_recomms_rec.web_tracking_id := rosetta_g_miss_num_map(p5_a1);
    ddp_web_recomms_rec.recomm_object_id := rosetta_g_miss_num_map(p5_a2);
    ddp_web_recomms_rec.recomm_type := p5_a3;
    ddp_web_recomms_rec.rule_id := rosetta_g_miss_num_map(p5_a4);
    ddp_web_recomms_rec.offer_id := rosetta_g_miss_num_map(p5_a5);
    ddp_web_recomms_rec.offer_src_code := p5_a6;
    ddp_web_recomms_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_web_recomms_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_web_recomms_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_web_recomms_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_web_recomms_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);
    ddp_web_recomms_rec.object_version_number := rosetta_g_miss_num_map(p5_a12);
    ddp_web_recomms_rec.attribute_category := p5_a13;
    ddp_web_recomms_rec.attribute1 := p5_a14;
    ddp_web_recomms_rec.attribute2 := p5_a15;
    ddp_web_recomms_rec.attribute3 := p5_a16;
    ddp_web_recomms_rec.attribute4 := p5_a17;
    ddp_web_recomms_rec.attribute5 := p5_a18;
    ddp_web_recomms_rec.attribute6 := p5_a19;
    ddp_web_recomms_rec.attribute7 := p5_a20;
    ddp_web_recomms_rec.attribute8 := p5_a21;
    ddp_web_recomms_rec.attribute9 := p5_a22;
    ddp_web_recomms_rec.attribute10 := p5_a23;
    ddp_web_recomms_rec.attribute11 := p5_a24;
    ddp_web_recomms_rec.attribute12 := p5_a25;
    ddp_web_recomms_rec.attribute13 := p5_a26;
    ddp_web_recomms_rec.attribute14 := p5_a27;
    ddp_web_recomms_rec.attribute15 := p5_a28;

    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.validate_web_recomms_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_web_recomms_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_web_imp_track(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_200
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_VARCHAR2_TABLE_200
    , p5_a23 JTF_VARCHAR2_TABLE_200
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_VARCHAR2_TABLE_200
    , p5_a26 JTF_VARCHAR2_TABLE_200
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_VARCHAR2_TABLE_200
    , p6_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p6_a1 OUT NOCOPY JTF_NUMBER_TABLE
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_web_track_rec ams_web_track_pvt.web_track_rec_type;
    ddp_web_recomms_tbl ams_web_track_pvt.web_recomms_tbl_type;
    ddx_impr_obj_id_rec ams_web_track_pvt.impr_obj_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_web_track_rec.web_tracking_id := rosetta_g_miss_num_map(p4_a0);
    ddp_web_track_rec.schedule_id := rosetta_g_miss_num_map(p4_a1);
    ddp_web_track_rec.schedule_type := p4_a2;
    ddp_web_track_rec.party_id := rosetta_g_miss_num_map(p4_a3);
    ddp_web_track_rec.placement_id := rosetta_g_miss_num_map(p4_a4);
    ddp_web_track_rec.content_item_id := rosetta_g_miss_num_map(p4_a5);
    ddp_web_track_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_web_track_rec.last_updated_by := rosetta_g_miss_num_map(p4_a7);
    ddp_web_track_rec.creation_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_web_track_rec.created_by := rosetta_g_miss_num_map(p4_a9);
    ddp_web_track_rec.last_update_login := rosetta_g_miss_num_map(p4_a10);
    ddp_web_track_rec.object_version_number := rosetta_g_miss_num_map(p4_a11);
    ddp_web_track_rec.attribute_category := p4_a12;
    ddp_web_track_rec.attribute1 := p4_a13;
    ddp_web_track_rec.attribute2 := p4_a14;
    ddp_web_track_rec.attribute3 := p4_a15;
    ddp_web_track_rec.attribute4 := p4_a16;
    ddp_web_track_rec.attribute5 := p4_a17;
    ddp_web_track_rec.attribute6 := p4_a18;
    ddp_web_track_rec.attribute7 := p4_a19;
    ddp_web_track_rec.attribute8 := p4_a20;
    ddp_web_track_rec.attribute9 := p4_a21;
    ddp_web_track_rec.attribute10 := p4_a22;
    ddp_web_track_rec.attribute11 := p4_a23;
    ddp_web_track_rec.attribute12 := p4_a24;
    ddp_web_track_rec.attribute13 := p4_a25;
    ddp_web_track_rec.attribute14 := p4_a26;
    ddp_web_track_rec.attribute15 := p4_a27;

    ams_web_track_pvt_w.rosetta_table_copy_in_p13(ddp_web_recomms_tbl, p5_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    ams_web_track_pvt.create_web_imp_track(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_web_track_rec,
      ddp_web_recomms_tbl,
      ddx_impr_obj_id_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






    ams_web_track_pvt_w.rosetta_table_copy_out_p23(ddx_impr_obj_id_rec, p6_a0
      , p6_a1
      );



  end;

end ams_web_track_pvt_w;

/
