--------------------------------------------------------
--  DDL for Package Body OZF_DISC_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DISC_LINE_PVT_W" as
  /* $Header: ozfwodlb.pls 120.3 2006/05/04 15:26 julou ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_disc_line_pvt.ozf_offer_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_operator := a4(indx);
          t(ddindx).volume_type := a5(indx);
          t(ddindx).volume_break_type := a6(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).discount_type := a8(indx);
          t(ddindx).tier_type := a9(indx);
          t(ddindx).tier_level := a10(indx);
          t(ddindx).incompatibility_group := a11(indx);
          t(ddindx).precedence := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).bucket := a13(indx);
          t(ddindx).scan_value := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).scan_data_quantity := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).scan_unit_forecast := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).channel_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).adjustment_flag := a18(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).uom_code := a21(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).context := a28(indx);
          t(ddindx).attribute1 := a29(indx);
          t(ddindx).attribute2 := a30(indx);
          t(ddindx).attribute3 := a31(indx);
          t(ddindx).attribute4 := a32(indx);
          t(ddindx).attribute5 := a33(indx);
          t(ddindx).attribute6 := a34(indx);
          t(ddindx).attribute7 := a35(indx);
          t(ddindx).attribute8 := a36(indx);
          t(ddindx).attribute9 := a37(indx);
          t(ddindx).attribute10 := a38(indx);
          t(ddindx).attribute11 := a39(indx);
          t(ddindx).attribute12 := a40(indx);
          t(ddindx).attribute13 := a41(indx);
          t(ddindx).attribute14 := a42(indx);
          t(ddindx).attribute15 := a43(indx);
          t(ddindx).offer_id := rosetta_g_miss_num_map(a44(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_disc_line_pvt.ozf_offer_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a4(indx) := t(ddindx).volume_operator;
          a5(indx) := t(ddindx).volume_type;
          a6(indx) := t(ddindx).volume_break_type;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a8(indx) := t(ddindx).discount_type;
          a9(indx) := t(ddindx).tier_type;
          a10(indx) := t(ddindx).tier_level;
          a11(indx) := t(ddindx).incompatibility_group;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).precedence);
          a13(indx) := t(ddindx).bucket;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).scan_value);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).scan_data_quantity);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).scan_unit_forecast);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).channel_id);
          a18(indx) := t(ddindx).adjustment_flag;
          a19(indx) := t(ddindx).start_date_active;
          a20(indx) := t(ddindx).end_date_active;
          a21(indx) := t(ddindx).uom_code;
          a22(indx) := t(ddindx).creation_date;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a24(indx) := t(ddindx).last_update_date;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a28(indx) := t(ddindx).context;
          a29(indx) := t(ddindx).attribute1;
          a30(indx) := t(ddindx).attribute2;
          a31(indx) := t(ddindx).attribute3;
          a32(indx) := t(ddindx).attribute4;
          a33(indx) := t(ddindx).attribute5;
          a34(indx) := t(ddindx).attribute6;
          a35(indx) := t(ddindx).attribute7;
          a36(indx) := t(ddindx).attribute8;
          a37(indx) := t(ddindx).attribute9;
          a38(indx) := t(ddindx).attribute10;
          a39(indx) := t(ddindx).attribute11;
          a40(indx) := t(ddindx).attribute12;
          a41(indx) := t(ddindx).attribute13;
          a42(indx) := t(ddindx).attribute14;
          a43(indx) := t(ddindx).attribute15;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_disc_line_pvt.ozf_offer_tier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).volume_operator := a5(indx);
          t(ddindx).volume_type := a6(indx);
          t(ddindx).volume_break_type := a7(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).discount_type := a9(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).uom_code := a12(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).context := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ozf_disc_line_pvt.ozf_offer_tier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
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
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a5(indx) := t(ddindx).volume_operator;
          a6(indx) := t(ddindx).volume_type;
          a7(indx) := t(ddindx).volume_break_type;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a9(indx) := t(ddindx).discount_type;
          a10(indx) := t(ddindx).start_date_active;
          a11(indx) := t(ddindx).end_date_active;
          a12(indx) := t(ddindx).uom_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a14(indx) := t(ddindx).context;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p9(t out nocopy ozf_disc_line_pvt.ozf_discount_line_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_operator := a4(indx);
          t(ddindx).volume_type := a5(indx);
          t(ddindx).volume_break_type := a6(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).discount_type := a8(indx);
          t(ddindx).tier_type := a9(indx);
          t(ddindx).tier_level := a10(indx);
          t(ddindx).incompatibility_group := a11(indx);
          t(ddindx).precedence := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).bucket := a13(indx);
          t(ddindx).scan_value := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).scan_data_quantity := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).scan_unit_forecast := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).channel_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).adjustment_flag := a18(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).uom_code := a21(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).parent_off_disc_prod_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).product_level := a31(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).excluder_flag := a33(indx);
          t(ddindx).context := a34(indx);
          t(ddindx).attribute1 := a35(indx);
          t(ddindx).attribute2 := a36(indx);
          t(ddindx).attribute3 := a37(indx);
          t(ddindx).attribute4 := a38(indx);
          t(ddindx).attribute5 := a39(indx);
          t(ddindx).attribute6 := a40(indx);
          t(ddindx).attribute7 := a41(indx);
          t(ddindx).attribute8 := a42(indx);
          t(ddindx).attribute9 := a43(indx);
          t(ddindx).attribute10 := a44(indx);
          t(ddindx).attribute11 := a45(indx);
          t(ddindx).attribute12 := a46(indx);
          t(ddindx).attribute13 := a47(indx);
          t(ddindx).attribute14 := a48(indx);
          t(ddindx).attribute15 := a49(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t ozf_disc_line_pvt.ozf_discount_line_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_300();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_300();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a4(indx) := t(ddindx).volume_operator;
          a5(indx) := t(ddindx).volume_type;
          a6(indx) := t(ddindx).volume_break_type;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a8(indx) := t(ddindx).discount_type;
          a9(indx) := t(ddindx).tier_type;
          a10(indx) := t(ddindx).tier_level;
          a11(indx) := t(ddindx).incompatibility_group;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).precedence);
          a13(indx) := t(ddindx).bucket;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).scan_value);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).scan_data_quantity);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).scan_unit_forecast);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).channel_id);
          a18(indx) := t(ddindx).adjustment_flag;
          a19(indx) := t(ddindx).start_date_active;
          a20(indx) := t(ddindx).end_date_active;
          a21(indx) := t(ddindx).uom_code;
          a22(indx) := t(ddindx).creation_date;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a24(indx) := t(ddindx).last_update_date;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).parent_off_disc_prod_id);
          a31(indx) := t(ddindx).product_level;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a33(indx) := t(ddindx).excluder_flag;
          a34(indx) := t(ddindx).context;
          a35(indx) := t(ddindx).attribute1;
          a36(indx) := t(ddindx).attribute2;
          a37(indx) := t(ddindx).attribute3;
          a38(indx) := t(ddindx).attribute4;
          a39(indx) := t(ddindx).attribute5;
          a40(indx) := t(ddindx).attribute6;
          a41(indx) := t(ddindx).attribute7;
          a42(indx) := t(ddindx).attribute8;
          a43(indx) := t(ddindx).attribute9;
          a44(indx) := t(ddindx).attribute10;
          a45(indx) := t(ddindx).attribute11;
          a46(indx) := t(ddindx).attribute12;
          a47(indx) := t(ddindx).attribute13;
          a48(indx) := t(ddindx).attribute14;
          a49(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p12(t out nocopy ozf_disc_line_pvt.prod_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_off_disc_prod_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).product_level := a2(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).excluder_flag := a4(indx);
          t(ddindx).uom_code := a5(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a15(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t ozf_disc_line_pvt.prod_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_off_disc_prod_id);
          a2(indx) := t(ddindx).product_level;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a4(indx) := t(ddindx).excluder_flag;
          a5(indx) := t(ddindx).uom_code;
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).end_date_active;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p15(t out nocopy ozf_disc_line_pvt.excl_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_off_disc_prod_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).product_level := a2(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t ozf_disc_line_pvt.excl_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_off_disc_prod_id);
          a2(indx) := t(ddindx).product_level;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).start_date_active;
          a6(indx) := t(ddindx).end_date_active;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p18(t out nocopy ozf_disc_line_pvt.prod_reln_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).discount_product_reln_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t ozf_disc_line_pvt.prod_reln_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).discount_product_reln_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure create_discount_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offer_discount_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  DATE := fnd_api.g_miss_date
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  DATE := fnd_api.g_miss_date
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ozf_discount_line_rec ozf_disc_line_pvt.ozf_discount_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ozf_discount_line_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ozf_discount_line_rec.parent_discount_line_id := rosetta_g_miss_num_map(p7_a1);
    ddp_ozf_discount_line_rec.volume_from := rosetta_g_miss_num_map(p7_a2);
    ddp_ozf_discount_line_rec.volume_to := rosetta_g_miss_num_map(p7_a3);
    ddp_ozf_discount_line_rec.volume_operator := p7_a4;
    ddp_ozf_discount_line_rec.volume_type := p7_a5;
    ddp_ozf_discount_line_rec.volume_break_type := p7_a6;
    ddp_ozf_discount_line_rec.discount := rosetta_g_miss_num_map(p7_a7);
    ddp_ozf_discount_line_rec.discount_type := p7_a8;
    ddp_ozf_discount_line_rec.tier_type := p7_a9;
    ddp_ozf_discount_line_rec.tier_level := p7_a10;
    ddp_ozf_discount_line_rec.incompatibility_group := p7_a11;
    ddp_ozf_discount_line_rec.precedence := rosetta_g_miss_num_map(p7_a12);
    ddp_ozf_discount_line_rec.bucket := p7_a13;
    ddp_ozf_discount_line_rec.scan_value := rosetta_g_miss_num_map(p7_a14);
    ddp_ozf_discount_line_rec.scan_data_quantity := rosetta_g_miss_num_map(p7_a15);
    ddp_ozf_discount_line_rec.scan_unit_forecast := rosetta_g_miss_num_map(p7_a16);
    ddp_ozf_discount_line_rec.channel_id := rosetta_g_miss_num_map(p7_a17);
    ddp_ozf_discount_line_rec.adjustment_flag := p7_a18;
    ddp_ozf_discount_line_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a19);
    ddp_ozf_discount_line_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_ozf_discount_line_rec.uom_code := p7_a21;
    ddp_ozf_discount_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a22);
    ddp_ozf_discount_line_rec.created_by := rosetta_g_miss_num_map(p7_a23);
    ddp_ozf_discount_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a24);
    ddp_ozf_discount_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a25);
    ddp_ozf_discount_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a26);
    ddp_ozf_discount_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a27);
    ddp_ozf_discount_line_rec.offer_id := rosetta_g_miss_num_map(p7_a28);
    ddp_ozf_discount_line_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a29);
    ddp_ozf_discount_line_rec.parent_off_disc_prod_id := rosetta_g_miss_num_map(p7_a30);
    ddp_ozf_discount_line_rec.product_level := p7_a31;
    ddp_ozf_discount_line_rec.product_id := rosetta_g_miss_num_map(p7_a32);
    ddp_ozf_discount_line_rec.excluder_flag := p7_a33;
    ddp_ozf_discount_line_rec.context := p7_a34;
    ddp_ozf_discount_line_rec.attribute1 := p7_a35;
    ddp_ozf_discount_line_rec.attribute2 := p7_a36;
    ddp_ozf_discount_line_rec.attribute3 := p7_a37;
    ddp_ozf_discount_line_rec.attribute4 := p7_a38;
    ddp_ozf_discount_line_rec.attribute5 := p7_a39;
    ddp_ozf_discount_line_rec.attribute6 := p7_a40;
    ddp_ozf_discount_line_rec.attribute7 := p7_a41;
    ddp_ozf_discount_line_rec.attribute8 := p7_a42;
    ddp_ozf_discount_line_rec.attribute9 := p7_a43;
    ddp_ozf_discount_line_rec.attribute10 := p7_a44;
    ddp_ozf_discount_line_rec.attribute11 := p7_a45;
    ddp_ozf_discount_line_rec.attribute12 := p7_a46;
    ddp_ozf_discount_line_rec.attribute13 := p7_a47;
    ddp_ozf_discount_line_rec.attribute14 := p7_a48;
    ddp_ozf_discount_line_rec.attribute15 := p7_a49;


    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.create_discount_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ozf_discount_line_rec,
      x_offer_discount_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_discount_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  DATE := fnd_api.g_miss_date
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  DATE := fnd_api.g_miss_date
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ozf_discount_line_rec ozf_disc_line_pvt.ozf_discount_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ozf_discount_line_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ozf_discount_line_rec.parent_discount_line_id := rosetta_g_miss_num_map(p7_a1);
    ddp_ozf_discount_line_rec.volume_from := rosetta_g_miss_num_map(p7_a2);
    ddp_ozf_discount_line_rec.volume_to := rosetta_g_miss_num_map(p7_a3);
    ddp_ozf_discount_line_rec.volume_operator := p7_a4;
    ddp_ozf_discount_line_rec.volume_type := p7_a5;
    ddp_ozf_discount_line_rec.volume_break_type := p7_a6;
    ddp_ozf_discount_line_rec.discount := rosetta_g_miss_num_map(p7_a7);
    ddp_ozf_discount_line_rec.discount_type := p7_a8;
    ddp_ozf_discount_line_rec.tier_type := p7_a9;
    ddp_ozf_discount_line_rec.tier_level := p7_a10;
    ddp_ozf_discount_line_rec.incompatibility_group := p7_a11;
    ddp_ozf_discount_line_rec.precedence := rosetta_g_miss_num_map(p7_a12);
    ddp_ozf_discount_line_rec.bucket := p7_a13;
    ddp_ozf_discount_line_rec.scan_value := rosetta_g_miss_num_map(p7_a14);
    ddp_ozf_discount_line_rec.scan_data_quantity := rosetta_g_miss_num_map(p7_a15);
    ddp_ozf_discount_line_rec.scan_unit_forecast := rosetta_g_miss_num_map(p7_a16);
    ddp_ozf_discount_line_rec.channel_id := rosetta_g_miss_num_map(p7_a17);
    ddp_ozf_discount_line_rec.adjustment_flag := p7_a18;
    ddp_ozf_discount_line_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a19);
    ddp_ozf_discount_line_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_ozf_discount_line_rec.uom_code := p7_a21;
    ddp_ozf_discount_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a22);
    ddp_ozf_discount_line_rec.created_by := rosetta_g_miss_num_map(p7_a23);
    ddp_ozf_discount_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a24);
    ddp_ozf_discount_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a25);
    ddp_ozf_discount_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a26);
    ddp_ozf_discount_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a27);
    ddp_ozf_discount_line_rec.offer_id := rosetta_g_miss_num_map(p7_a28);
    ddp_ozf_discount_line_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a29);
    ddp_ozf_discount_line_rec.parent_off_disc_prod_id := rosetta_g_miss_num_map(p7_a30);
    ddp_ozf_discount_line_rec.product_level := p7_a31;
    ddp_ozf_discount_line_rec.product_id := rosetta_g_miss_num_map(p7_a32);
    ddp_ozf_discount_line_rec.excluder_flag := p7_a33;
    ddp_ozf_discount_line_rec.context := p7_a34;
    ddp_ozf_discount_line_rec.attribute1 := p7_a35;
    ddp_ozf_discount_line_rec.attribute2 := p7_a36;
    ddp_ozf_discount_line_rec.attribute3 := p7_a37;
    ddp_ozf_discount_line_rec.attribute4 := p7_a38;
    ddp_ozf_discount_line_rec.attribute5 := p7_a39;
    ddp_ozf_discount_line_rec.attribute6 := p7_a40;
    ddp_ozf_discount_line_rec.attribute7 := p7_a41;
    ddp_ozf_discount_line_rec.attribute8 := p7_a42;
    ddp_ozf_discount_line_rec.attribute9 := p7_a43;
    ddp_ozf_discount_line_rec.attribute10 := p7_a44;
    ddp_ozf_discount_line_rec.attribute11 := p7_a45;
    ddp_ozf_discount_line_rec.attribute12 := p7_a46;
    ddp_ozf_discount_line_rec.attribute13 := p7_a47;
    ddp_ozf_discount_line_rec.attribute14 := p7_a48;
    ddp_ozf_discount_line_rec.attribute15 := p7_a49;

    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.update_discount_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ozf_discount_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_product_exclusion(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_off_discount_product_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
  )

  as
    ddp_ozf_excl_rec ozf_disc_line_pvt.ozf_excl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ozf_excl_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ozf_excl_rec.parent_off_disc_prod_id := rosetta_g_miss_num_map(p7_a1);
    ddp_ozf_excl_rec.product_level := p7_a2;
    ddp_ozf_excl_rec.product_id := rosetta_g_miss_num_map(p7_a3);
    ddp_ozf_excl_rec.object_version_number := rosetta_g_miss_num_map(p7_a4);
    ddp_ozf_excl_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a5);
    ddp_ozf_excl_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a6);


    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.create_product_exclusion(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ozf_excl_rec,
      x_off_discount_product_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_product_exclusion(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
  )

  as
    ddp_ozf_excl_rec ozf_disc_line_pvt.ozf_excl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ozf_excl_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ozf_excl_rec.parent_off_disc_prod_id := rosetta_g_miss_num_map(p7_a1);
    ddp_ozf_excl_rec.product_level := p7_a2;
    ddp_ozf_excl_rec.product_id := rosetta_g_miss_num_map(p7_a3);
    ddp_ozf_excl_rec.object_version_number := rosetta_g_miss_num_map(p7_a4);
    ddp_ozf_excl_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a5);
    ddp_ozf_excl_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a6);

    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.update_product_exclusion(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ozf_excl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_disc_tiers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offer_discount_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
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
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tier_rec ozf_disc_line_pvt.ozf_offer_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_tier_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_tier_rec.parent_discount_line_id := rosetta_g_miss_num_map(p7_a1);
    ddp_tier_rec.offer_id := rosetta_g_miss_num_map(p7_a2);
    ddp_tier_rec.volume_from := rosetta_g_miss_num_map(p7_a3);
    ddp_tier_rec.volume_to := rosetta_g_miss_num_map(p7_a4);
    ddp_tier_rec.volume_operator := p7_a5;
    ddp_tier_rec.volume_type := p7_a6;
    ddp_tier_rec.volume_break_type := p7_a7;
    ddp_tier_rec.discount := rosetta_g_miss_num_map(p7_a8);
    ddp_tier_rec.discount_type := p7_a9;
    ddp_tier_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a10);
    ddp_tier_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a11);
    ddp_tier_rec.uom_code := p7_a12;
    ddp_tier_rec.object_version_number := rosetta_g_miss_num_map(p7_a13);
    ddp_tier_rec.context := p7_a14;
    ddp_tier_rec.attribute1 := p7_a15;
    ddp_tier_rec.attribute2 := p7_a16;
    ddp_tier_rec.attribute3 := p7_a17;
    ddp_tier_rec.attribute4 := p7_a18;
    ddp_tier_rec.attribute5 := p7_a19;
    ddp_tier_rec.attribute6 := p7_a20;
    ddp_tier_rec.attribute7 := p7_a21;
    ddp_tier_rec.attribute8 := p7_a22;
    ddp_tier_rec.attribute9 := p7_a23;
    ddp_tier_rec.attribute10 := p7_a24;
    ddp_tier_rec.attribute11 := p7_a25;
    ddp_tier_rec.attribute12 := p7_a26;
    ddp_tier_rec.attribute13 := p7_a27;
    ddp_tier_rec.attribute14 := p7_a28;
    ddp_tier_rec.attribute15 := p7_a29;


    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.create_disc_tiers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tier_rec,
      x_offer_discount_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_disc_tiers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
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
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tier_rec ozf_disc_line_pvt.ozf_offer_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_tier_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_tier_rec.parent_discount_line_id := rosetta_g_miss_num_map(p7_a1);
    ddp_tier_rec.offer_id := rosetta_g_miss_num_map(p7_a2);
    ddp_tier_rec.volume_from := rosetta_g_miss_num_map(p7_a3);
    ddp_tier_rec.volume_to := rosetta_g_miss_num_map(p7_a4);
    ddp_tier_rec.volume_operator := p7_a5;
    ddp_tier_rec.volume_type := p7_a6;
    ddp_tier_rec.volume_break_type := p7_a7;
    ddp_tier_rec.discount := rosetta_g_miss_num_map(p7_a8);
    ddp_tier_rec.discount_type := p7_a9;
    ddp_tier_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a10);
    ddp_tier_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a11);
    ddp_tier_rec.uom_code := p7_a12;
    ddp_tier_rec.object_version_number := rosetta_g_miss_num_map(p7_a13);
    ddp_tier_rec.context := p7_a14;
    ddp_tier_rec.attribute1 := p7_a15;
    ddp_tier_rec.attribute2 := p7_a16;
    ddp_tier_rec.attribute3 := p7_a17;
    ddp_tier_rec.attribute4 := p7_a18;
    ddp_tier_rec.attribute5 := p7_a19;
    ddp_tier_rec.attribute6 := p7_a20;
    ddp_tier_rec.attribute7 := p7_a21;
    ddp_tier_rec.attribute8 := p7_a22;
    ddp_tier_rec.attribute9 := p7_a23;
    ddp_tier_rec.attribute10 := p7_a24;
    ddp_tier_rec.attribute11 := p7_a25;
    ddp_tier_rec.attribute12 := p7_a26;
    ddp_tier_rec.attribute13 := p7_a27;
    ddp_tier_rec.attribute14 := p7_a28;
    ddp_tier_rec.attribute15 := p7_a29;

    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.update_disc_tiers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tier_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_ozf_prod_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_off_discount_product_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
  )

  as
    ddp_ozf_prod_rec ozf_disc_line_pvt.ozf_prod_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ozf_prod_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ozf_prod_rec.parent_off_disc_prod_id := rosetta_g_miss_num_map(p7_a1);
    ddp_ozf_prod_rec.product_level := p7_a2;
    ddp_ozf_prod_rec.product_id := rosetta_g_miss_num_map(p7_a3);
    ddp_ozf_prod_rec.excluder_flag := p7_a4;
    ddp_ozf_prod_rec.uom_code := p7_a5;
    ddp_ozf_prod_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ozf_prod_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ozf_prod_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ozf_prod_rec.offer_id := rosetta_g_miss_num_map(p7_a9);
    ddp_ozf_prod_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_ozf_prod_rec.created_by := rosetta_g_miss_num_map(p7_a11);
    ddp_ozf_prod_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_ozf_prod_rec.last_updated_by := rosetta_g_miss_num_map(p7_a13);
    ddp_ozf_prod_rec.last_update_login := rosetta_g_miss_num_map(p7_a14);
    ddp_ozf_prod_rec.object_version_number := rosetta_g_miss_num_map(p7_a15);


    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.create_ozf_prod_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ozf_prod_rec,
      x_off_discount_product_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ozf_prod_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
  )

  as
    ddp_ozf_prod_rec ozf_disc_line_pvt.ozf_prod_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ozf_prod_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ozf_prod_rec.parent_off_disc_prod_id := rosetta_g_miss_num_map(p7_a1);
    ddp_ozf_prod_rec.product_level := p7_a2;
    ddp_ozf_prod_rec.product_id := rosetta_g_miss_num_map(p7_a3);
    ddp_ozf_prod_rec.excluder_flag := p7_a4;
    ddp_ozf_prod_rec.uom_code := p7_a5;
    ddp_ozf_prod_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ozf_prod_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ozf_prod_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a8);
    ddp_ozf_prod_rec.offer_id := rosetta_g_miss_num_map(p7_a9);
    ddp_ozf_prod_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_ozf_prod_rec.created_by := rosetta_g_miss_num_map(p7_a11);
    ddp_ozf_prod_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_ozf_prod_rec.last_updated_by := rosetta_g_miss_num_map(p7_a13);
    ddp_ozf_prod_rec.last_update_login := rosetta_g_miss_num_map(p7_a14);
    ddp_ozf_prod_rec.object_version_number := rosetta_g_miss_num_map(p7_a15);

    -- here's the delegated call to the old PL/SQL routine
    ozf_disc_line_pvt.update_ozf_prod_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ozf_prod_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ozf_disc_line_pvt_w;

/
