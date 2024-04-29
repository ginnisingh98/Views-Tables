--------------------------------------------------------
--  DDL for Package Body OKL_SVF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SVF_PVT_W" as
  /* $Header: OKLISVFB.pls 120.1 2005/07/15 07:39:31 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_svf_pvt.svf_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).srv_code := a1(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).attribute_category := a7(indx);
          t(ddindx).attribute1 := a8(indx);
          t(ddindx).attribute2 := a9(indx);
          t(ddindx).attribute3 := a10(indx);
          t(ddindx).attribute4 := a11(indx);
          t(ddindx).attribute5 := a12(indx);
          t(ddindx).attribute6 := a13(indx);
          t(ddindx).attribute7 := a14(indx);
          t(ddindx).attribute8 := a15(indx);
          t(ddindx).attribute9 := a16(indx);
          t(ddindx).attribute10 := a17(indx);
          t(ddindx).attribute11 := a18(indx);
          t(ddindx).attribute12 := a19(indx);
          t(ddindx).attribute13 := a20(indx);
          t(ddindx).attribute14 := a21(indx);
          t(ddindx).attribute15 := a22(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a27(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_svf_pvt.svf_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).srv_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a7(indx) := t(ddindx).attribute_category;
          a8(indx) := t(ddindx).attribute1;
          a9(indx) := t(ddindx).attribute2;
          a10(indx) := t(ddindx).attribute3;
          a11(indx) := t(ddindx).attribute4;
          a12(indx) := t(ddindx).attribute5;
          a13(indx) := t(ddindx).attribute6;
          a14(indx) := t(ddindx).attribute7;
          a15(indx) := t(ddindx).attribute8;
          a16(indx) := t(ddindx).attribute9;
          a17(indx) := t(ddindx).attribute10;
          a18(indx) := t(ddindx).attribute11;
          a19(indx) := t(ddindx).attribute12;
          a20(indx) := t(ddindx).attribute13;
          a21(indx) := t(ddindx).attribute14;
          a22(indx) := t(ddindx).attribute15;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a24(indx) := t(ddindx).creation_date;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := t(ddindx).last_update_date;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_svf_pvt.okl_service_fees_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).name := a4(indx);
          t(ddindx).description := a5(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_svf_pvt.okl_service_fees_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).name;
          a5(indx) := t(ddindx).description;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_svf_pvt.svfv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).srv_code := a3(indx);
          t(ddindx).name := a4(indx);
          t(ddindx).description := a5(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a9(indx));
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a30(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_svf_pvt.svfv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).srv_code;
          a4(indx) := t(ddindx).name;
          a5(indx) := t(ddindx).description;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a7(indx) := t(ddindx).start_date;
          a8(indx) := t(ddindx).end_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
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
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a27(indx) := t(ddindx).creation_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a29(indx) := t(ddindx).last_update_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddx_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_svfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_svfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_svfv_rec.sfwt_flag := p5_a2;
    ddp_svfv_rec.srv_code := p5_a3;
    ddp_svfv_rec.name := p5_a4;
    ddp_svfv_rec.description := p5_a5;
    ddp_svfv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_svfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_svfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_svfv_rec.organization_id := rosetta_g_miss_num_map(p5_a9);
    ddp_svfv_rec.attribute_category := p5_a10;
    ddp_svfv_rec.attribute1 := p5_a11;
    ddp_svfv_rec.attribute2 := p5_a12;
    ddp_svfv_rec.attribute3 := p5_a13;
    ddp_svfv_rec.attribute4 := p5_a14;
    ddp_svfv_rec.attribute5 := p5_a15;
    ddp_svfv_rec.attribute6 := p5_a16;
    ddp_svfv_rec.attribute7 := p5_a17;
    ddp_svfv_rec.attribute8 := p5_a18;
    ddp_svfv_rec.attribute9 := p5_a19;
    ddp_svfv_rec.attribute10 := p5_a20;
    ddp_svfv_rec.attribute11 := p5_a21;
    ddp_svfv_rec.attribute12 := p5_a22;
    ddp_svfv_rec.attribute13 := p5_a23;
    ddp_svfv_rec.attribute14 := p5_a24;
    ddp_svfv_rec.attribute15 := p5_a25;
    ddp_svfv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_svfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_svfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_svfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_svfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);


    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_rec,
      ddx_svfv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_svfv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_svfv_rec.object_version_number);
    p6_a2 := ddx_svfv_rec.sfwt_flag;
    p6_a3 := ddx_svfv_rec.srv_code;
    p6_a4 := ddx_svfv_rec.name;
    p6_a5 := ddx_svfv_rec.description;
    p6_a6 := rosetta_g_miss_num_map(ddx_svfv_rec.amount);
    p6_a7 := ddx_svfv_rec.start_date;
    p6_a8 := ddx_svfv_rec.end_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_svfv_rec.organization_id);
    p6_a10 := ddx_svfv_rec.attribute_category;
    p6_a11 := ddx_svfv_rec.attribute1;
    p6_a12 := ddx_svfv_rec.attribute2;
    p6_a13 := ddx_svfv_rec.attribute3;
    p6_a14 := ddx_svfv_rec.attribute4;
    p6_a15 := ddx_svfv_rec.attribute5;
    p6_a16 := ddx_svfv_rec.attribute6;
    p6_a17 := ddx_svfv_rec.attribute7;
    p6_a18 := ddx_svfv_rec.attribute8;
    p6_a19 := ddx_svfv_rec.attribute9;
    p6_a20 := ddx_svfv_rec.attribute10;
    p6_a21 := ddx_svfv_rec.attribute11;
    p6_a22 := ddx_svfv_rec.attribute12;
    p6_a23 := ddx_svfv_rec.attribute13;
    p6_a24 := ddx_svfv_rec.attribute14;
    p6_a25 := ddx_svfv_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_svfv_rec.created_by);
    p6_a27 := ddx_svfv_rec.creation_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_svfv_rec.last_updated_by);
    p6_a29 := ddx_svfv_rec.last_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_svfv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddx_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_svf_pvt_w.rosetta_table_copy_in_p8(ddp_svfv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_tbl,
      ddx_svfv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_svf_pvt_w.rosetta_table_copy_out_p8(ddx_svfv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_svfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_svfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_svfv_rec.sfwt_flag := p5_a2;
    ddp_svfv_rec.srv_code := p5_a3;
    ddp_svfv_rec.name := p5_a4;
    ddp_svfv_rec.description := p5_a5;
    ddp_svfv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_svfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_svfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_svfv_rec.organization_id := rosetta_g_miss_num_map(p5_a9);
    ddp_svfv_rec.attribute_category := p5_a10;
    ddp_svfv_rec.attribute1 := p5_a11;
    ddp_svfv_rec.attribute2 := p5_a12;
    ddp_svfv_rec.attribute3 := p5_a13;
    ddp_svfv_rec.attribute4 := p5_a14;
    ddp_svfv_rec.attribute5 := p5_a15;
    ddp_svfv_rec.attribute6 := p5_a16;
    ddp_svfv_rec.attribute7 := p5_a17;
    ddp_svfv_rec.attribute8 := p5_a18;
    ddp_svfv_rec.attribute9 := p5_a19;
    ddp_svfv_rec.attribute10 := p5_a20;
    ddp_svfv_rec.attribute11 := p5_a21;
    ddp_svfv_rec.attribute12 := p5_a22;
    ddp_svfv_rec.attribute13 := p5_a23;
    ddp_svfv_rec.attribute14 := p5_a24;
    ddp_svfv_rec.attribute15 := p5_a25;
    ddp_svfv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_svfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_svfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_svfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_svfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_svf_pvt_w.rosetta_table_copy_in_p8(ddp_svfv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddx_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_svfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_svfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_svfv_rec.sfwt_flag := p5_a2;
    ddp_svfv_rec.srv_code := p5_a3;
    ddp_svfv_rec.name := p5_a4;
    ddp_svfv_rec.description := p5_a5;
    ddp_svfv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_svfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_svfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_svfv_rec.organization_id := rosetta_g_miss_num_map(p5_a9);
    ddp_svfv_rec.attribute_category := p5_a10;
    ddp_svfv_rec.attribute1 := p5_a11;
    ddp_svfv_rec.attribute2 := p5_a12;
    ddp_svfv_rec.attribute3 := p5_a13;
    ddp_svfv_rec.attribute4 := p5_a14;
    ddp_svfv_rec.attribute5 := p5_a15;
    ddp_svfv_rec.attribute6 := p5_a16;
    ddp_svfv_rec.attribute7 := p5_a17;
    ddp_svfv_rec.attribute8 := p5_a18;
    ddp_svfv_rec.attribute9 := p5_a19;
    ddp_svfv_rec.attribute10 := p5_a20;
    ddp_svfv_rec.attribute11 := p5_a21;
    ddp_svfv_rec.attribute12 := p5_a22;
    ddp_svfv_rec.attribute13 := p5_a23;
    ddp_svfv_rec.attribute14 := p5_a24;
    ddp_svfv_rec.attribute15 := p5_a25;
    ddp_svfv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_svfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_svfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_svfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_svfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);


    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_rec,
      ddx_svfv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_svfv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_svfv_rec.object_version_number);
    p6_a2 := ddx_svfv_rec.sfwt_flag;
    p6_a3 := ddx_svfv_rec.srv_code;
    p6_a4 := ddx_svfv_rec.name;
    p6_a5 := ddx_svfv_rec.description;
    p6_a6 := rosetta_g_miss_num_map(ddx_svfv_rec.amount);
    p6_a7 := ddx_svfv_rec.start_date;
    p6_a8 := ddx_svfv_rec.end_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_svfv_rec.organization_id);
    p6_a10 := ddx_svfv_rec.attribute_category;
    p6_a11 := ddx_svfv_rec.attribute1;
    p6_a12 := ddx_svfv_rec.attribute2;
    p6_a13 := ddx_svfv_rec.attribute3;
    p6_a14 := ddx_svfv_rec.attribute4;
    p6_a15 := ddx_svfv_rec.attribute5;
    p6_a16 := ddx_svfv_rec.attribute6;
    p6_a17 := ddx_svfv_rec.attribute7;
    p6_a18 := ddx_svfv_rec.attribute8;
    p6_a19 := ddx_svfv_rec.attribute9;
    p6_a20 := ddx_svfv_rec.attribute10;
    p6_a21 := ddx_svfv_rec.attribute11;
    p6_a22 := ddx_svfv_rec.attribute12;
    p6_a23 := ddx_svfv_rec.attribute13;
    p6_a24 := ddx_svfv_rec.attribute14;
    p6_a25 := ddx_svfv_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_svfv_rec.created_by);
    p6_a27 := ddx_svfv_rec.creation_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_svfv_rec.last_updated_by);
    p6_a29 := ddx_svfv_rec.last_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_svfv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddx_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_svf_pvt_w.rosetta_table_copy_in_p8(ddp_svfv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_tbl,
      ddx_svfv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_svf_pvt_w.rosetta_table_copy_out_p8(ddx_svfv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_svfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_svfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_svfv_rec.sfwt_flag := p5_a2;
    ddp_svfv_rec.srv_code := p5_a3;
    ddp_svfv_rec.name := p5_a4;
    ddp_svfv_rec.description := p5_a5;
    ddp_svfv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_svfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_svfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_svfv_rec.organization_id := rosetta_g_miss_num_map(p5_a9);
    ddp_svfv_rec.attribute_category := p5_a10;
    ddp_svfv_rec.attribute1 := p5_a11;
    ddp_svfv_rec.attribute2 := p5_a12;
    ddp_svfv_rec.attribute3 := p5_a13;
    ddp_svfv_rec.attribute4 := p5_a14;
    ddp_svfv_rec.attribute5 := p5_a15;
    ddp_svfv_rec.attribute6 := p5_a16;
    ddp_svfv_rec.attribute7 := p5_a17;
    ddp_svfv_rec.attribute8 := p5_a18;
    ddp_svfv_rec.attribute9 := p5_a19;
    ddp_svfv_rec.attribute10 := p5_a20;
    ddp_svfv_rec.attribute11 := p5_a21;
    ddp_svfv_rec.attribute12 := p5_a22;
    ddp_svfv_rec.attribute13 := p5_a23;
    ddp_svfv_rec.attribute14 := p5_a24;
    ddp_svfv_rec.attribute15 := p5_a25;
    ddp_svfv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_svfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_svfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_svfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_svfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_svf_pvt_w.rosetta_table_copy_in_p8(ddp_svfv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_svfv_rec okl_svf_pvt.svfv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_svfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_svfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_svfv_rec.sfwt_flag := p5_a2;
    ddp_svfv_rec.srv_code := p5_a3;
    ddp_svfv_rec.name := p5_a4;
    ddp_svfv_rec.description := p5_a5;
    ddp_svfv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_svfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_svfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_svfv_rec.organization_id := rosetta_g_miss_num_map(p5_a9);
    ddp_svfv_rec.attribute_category := p5_a10;
    ddp_svfv_rec.attribute1 := p5_a11;
    ddp_svfv_rec.attribute2 := p5_a12;
    ddp_svfv_rec.attribute3 := p5_a13;
    ddp_svfv_rec.attribute4 := p5_a14;
    ddp_svfv_rec.attribute5 := p5_a15;
    ddp_svfv_rec.attribute6 := p5_a16;
    ddp_svfv_rec.attribute7 := p5_a17;
    ddp_svfv_rec.attribute8 := p5_a18;
    ddp_svfv_rec.attribute9 := p5_a19;
    ddp_svfv_rec.attribute10 := p5_a20;
    ddp_svfv_rec.attribute11 := p5_a21;
    ddp_svfv_rec.attribute12 := p5_a22;
    ddp_svfv_rec.attribute13 := p5_a23;
    ddp_svfv_rec.attribute14 := p5_a24;
    ddp_svfv_rec.attribute15 := p5_a25;
    ddp_svfv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_svfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_svfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_svfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_svfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_svfv_tbl okl_svf_pvt.svfv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_svf_pvt_w.rosetta_table_copy_in_p8(ddp_svfv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_svf_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_svfv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_svf_pvt_w;

/
