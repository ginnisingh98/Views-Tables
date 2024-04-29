--------------------------------------------------------
--  DDL for Package Body OKL_PVN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PVN_PVT_W" as
  /* $Header: OKLIPVNB.pls 120.1 2005/07/14 11:58:48 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_pvn_pvt.pvn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          t(ddindx).app_debit_ccid := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).rev_credit_ccid := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).rev_debit_ccid := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).app_credit_ccid := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).version := a8(indx);
          t(ddindx).description := a9(indx);
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a11(indx));
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a32(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_pvn_pvt.pvn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).app_debit_ccid);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).rev_credit_ccid);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).rev_debit_ccid);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).app_credit_ccid);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).version;
          a9(indx) := t(ddindx).description;
          a10(indx) := t(ddindx).from_date;
          a11(indx) := t(ddindx).to_date;
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
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a29(indx) := t(ddindx).creation_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a31(indx) := t(ddindx).last_update_date;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_pvn_pvt.pvnv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_100
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
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_NUMBER_TABLE
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
          t(ddindx).app_debit_ccid := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).rev_credit_ccid := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).rev_debit_ccid := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).app_credit_ccid := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).name := a7(indx);
          t(ddindx).description := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).attribute1 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute4 := a13(indx);
          t(ddindx).attribute5 := a14(indx);
          t(ddindx).attribute6 := a15(indx);
          t(ddindx).attribute7 := a16(indx);
          t(ddindx).attribute8 := a17(indx);
          t(ddindx).attribute9 := a18(indx);
          t(ddindx).attribute10 := a19(indx);
          t(ddindx).attribute11 := a20(indx);
          t(ddindx).attribute12 := a21(indx);
          t(ddindx).attribute13 := a22(indx);
          t(ddindx).attribute14 := a23(indx);
          t(ddindx).attribute15 := a24(indx);
          t(ddindx).version := a25(indx);
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a32(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_pvn_pvt.pvnv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_VARCHAR2_TABLE_100();
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
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_VARCHAR2_TABLE_100();
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
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).app_debit_ccid);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).rev_credit_ccid);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).rev_debit_ccid);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).app_credit_ccid);
          a7(indx) := t(ddindx).name;
          a8(indx) := t(ddindx).description;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).attribute1;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute4;
          a14(indx) := t(ddindx).attribute5;
          a15(indx) := t(ddindx).attribute6;
          a16(indx) := t(ddindx).attribute7;
          a17(indx) := t(ddindx).attribute8;
          a18(indx) := t(ddindx).attribute9;
          a19(indx) := t(ddindx).attribute10;
          a20(indx) := t(ddindx).attribute11;
          a21(indx) := t(ddindx).attribute12;
          a22(indx) := t(ddindx).attribute13;
          a23(indx) := t(ddindx).attribute14;
          a24(indx) := t(ddindx).attribute15;
          a25(indx) := t(ddindx).version;
          a26(indx) := t(ddindx).from_date;
          a27(indx) := t(ddindx).to_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a29(indx) := t(ddindx).creation_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a31(indx) := t(ddindx).last_update_date;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddx_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pvnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pvnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pvnv_rec.app_debit_ccid := rosetta_g_miss_num_map(p5_a2);
    ddp_pvnv_rec.rev_credit_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_pvnv_rec.rev_debit_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_pvnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pvnv_rec.app_credit_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_pvnv_rec.name := p5_a7;
    ddp_pvnv_rec.description := p5_a8;
    ddp_pvnv_rec.attribute_category := p5_a9;
    ddp_pvnv_rec.attribute1 := p5_a10;
    ddp_pvnv_rec.attribute2 := p5_a11;
    ddp_pvnv_rec.attribute3 := p5_a12;
    ddp_pvnv_rec.attribute4 := p5_a13;
    ddp_pvnv_rec.attribute5 := p5_a14;
    ddp_pvnv_rec.attribute6 := p5_a15;
    ddp_pvnv_rec.attribute7 := p5_a16;
    ddp_pvnv_rec.attribute8 := p5_a17;
    ddp_pvnv_rec.attribute9 := p5_a18;
    ddp_pvnv_rec.attribute10 := p5_a19;
    ddp_pvnv_rec.attribute11 := p5_a20;
    ddp_pvnv_rec.attribute12 := p5_a21;
    ddp_pvnv_rec.attribute13 := p5_a22;
    ddp_pvnv_rec.attribute14 := p5_a23;
    ddp_pvnv_rec.attribute15 := p5_a24;
    ddp_pvnv_rec.version := p5_a25;
    ddp_pvnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_pvnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_pvnv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_pvnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_pvnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_pvnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_pvnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);


    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_rec,
      ddx_pvnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pvnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pvnv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pvnv_rec.app_debit_ccid);
    p6_a3 := rosetta_g_miss_num_map(ddx_pvnv_rec.rev_credit_ccid);
    p6_a4 := rosetta_g_miss_num_map(ddx_pvnv_rec.rev_debit_ccid);
    p6_a5 := rosetta_g_miss_num_map(ddx_pvnv_rec.set_of_books_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_pvnv_rec.app_credit_ccid);
    p6_a7 := ddx_pvnv_rec.name;
    p6_a8 := ddx_pvnv_rec.description;
    p6_a9 := ddx_pvnv_rec.attribute_category;
    p6_a10 := ddx_pvnv_rec.attribute1;
    p6_a11 := ddx_pvnv_rec.attribute2;
    p6_a12 := ddx_pvnv_rec.attribute3;
    p6_a13 := ddx_pvnv_rec.attribute4;
    p6_a14 := ddx_pvnv_rec.attribute5;
    p6_a15 := ddx_pvnv_rec.attribute6;
    p6_a16 := ddx_pvnv_rec.attribute7;
    p6_a17 := ddx_pvnv_rec.attribute8;
    p6_a18 := ddx_pvnv_rec.attribute9;
    p6_a19 := ddx_pvnv_rec.attribute10;
    p6_a20 := ddx_pvnv_rec.attribute11;
    p6_a21 := ddx_pvnv_rec.attribute12;
    p6_a22 := ddx_pvnv_rec.attribute13;
    p6_a23 := ddx_pvnv_rec.attribute14;
    p6_a24 := ddx_pvnv_rec.attribute15;
    p6_a25 := ddx_pvnv_rec.version;
    p6_a26 := ddx_pvnv_rec.from_date;
    p6_a27 := ddx_pvnv_rec.to_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_pvnv_rec.created_by);
    p6_a29 := ddx_pvnv_rec.creation_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_pvnv_rec.last_updated_by);
    p6_a31 := ddx_pvnv_rec.last_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_pvnv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddx_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pvn_pvt_w.rosetta_table_copy_in_p5(ddp_pvnv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_tbl,
      ddx_pvnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pvn_pvt_w.rosetta_table_copy_out_p5(ddx_pvnv_tbl, p6_a0
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
      , p6_a31
      , p6_a32
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pvnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pvnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pvnv_rec.app_debit_ccid := rosetta_g_miss_num_map(p5_a2);
    ddp_pvnv_rec.rev_credit_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_pvnv_rec.rev_debit_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_pvnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pvnv_rec.app_credit_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_pvnv_rec.name := p5_a7;
    ddp_pvnv_rec.description := p5_a8;
    ddp_pvnv_rec.attribute_category := p5_a9;
    ddp_pvnv_rec.attribute1 := p5_a10;
    ddp_pvnv_rec.attribute2 := p5_a11;
    ddp_pvnv_rec.attribute3 := p5_a12;
    ddp_pvnv_rec.attribute4 := p5_a13;
    ddp_pvnv_rec.attribute5 := p5_a14;
    ddp_pvnv_rec.attribute6 := p5_a15;
    ddp_pvnv_rec.attribute7 := p5_a16;
    ddp_pvnv_rec.attribute8 := p5_a17;
    ddp_pvnv_rec.attribute9 := p5_a18;
    ddp_pvnv_rec.attribute10 := p5_a19;
    ddp_pvnv_rec.attribute11 := p5_a20;
    ddp_pvnv_rec.attribute12 := p5_a21;
    ddp_pvnv_rec.attribute13 := p5_a22;
    ddp_pvnv_rec.attribute14 := p5_a23;
    ddp_pvnv_rec.attribute15 := p5_a24;
    ddp_pvnv_rec.version := p5_a25;
    ddp_pvnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_pvnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_pvnv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_pvnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_pvnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_pvnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_pvnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
  )

  as
    ddp_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pvn_pvt_w.rosetta_table_copy_in_p5(ddp_pvnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddx_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pvnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pvnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pvnv_rec.app_debit_ccid := rosetta_g_miss_num_map(p5_a2);
    ddp_pvnv_rec.rev_credit_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_pvnv_rec.rev_debit_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_pvnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pvnv_rec.app_credit_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_pvnv_rec.name := p5_a7;
    ddp_pvnv_rec.description := p5_a8;
    ddp_pvnv_rec.attribute_category := p5_a9;
    ddp_pvnv_rec.attribute1 := p5_a10;
    ddp_pvnv_rec.attribute2 := p5_a11;
    ddp_pvnv_rec.attribute3 := p5_a12;
    ddp_pvnv_rec.attribute4 := p5_a13;
    ddp_pvnv_rec.attribute5 := p5_a14;
    ddp_pvnv_rec.attribute6 := p5_a15;
    ddp_pvnv_rec.attribute7 := p5_a16;
    ddp_pvnv_rec.attribute8 := p5_a17;
    ddp_pvnv_rec.attribute9 := p5_a18;
    ddp_pvnv_rec.attribute10 := p5_a19;
    ddp_pvnv_rec.attribute11 := p5_a20;
    ddp_pvnv_rec.attribute12 := p5_a21;
    ddp_pvnv_rec.attribute13 := p5_a22;
    ddp_pvnv_rec.attribute14 := p5_a23;
    ddp_pvnv_rec.attribute15 := p5_a24;
    ddp_pvnv_rec.version := p5_a25;
    ddp_pvnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_pvnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_pvnv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_pvnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_pvnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_pvnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_pvnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);


    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_rec,
      ddx_pvnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pvnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pvnv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pvnv_rec.app_debit_ccid);
    p6_a3 := rosetta_g_miss_num_map(ddx_pvnv_rec.rev_credit_ccid);
    p6_a4 := rosetta_g_miss_num_map(ddx_pvnv_rec.rev_debit_ccid);
    p6_a5 := rosetta_g_miss_num_map(ddx_pvnv_rec.set_of_books_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_pvnv_rec.app_credit_ccid);
    p6_a7 := ddx_pvnv_rec.name;
    p6_a8 := ddx_pvnv_rec.description;
    p6_a9 := ddx_pvnv_rec.attribute_category;
    p6_a10 := ddx_pvnv_rec.attribute1;
    p6_a11 := ddx_pvnv_rec.attribute2;
    p6_a12 := ddx_pvnv_rec.attribute3;
    p6_a13 := ddx_pvnv_rec.attribute4;
    p6_a14 := ddx_pvnv_rec.attribute5;
    p6_a15 := ddx_pvnv_rec.attribute6;
    p6_a16 := ddx_pvnv_rec.attribute7;
    p6_a17 := ddx_pvnv_rec.attribute8;
    p6_a18 := ddx_pvnv_rec.attribute9;
    p6_a19 := ddx_pvnv_rec.attribute10;
    p6_a20 := ddx_pvnv_rec.attribute11;
    p6_a21 := ddx_pvnv_rec.attribute12;
    p6_a22 := ddx_pvnv_rec.attribute13;
    p6_a23 := ddx_pvnv_rec.attribute14;
    p6_a24 := ddx_pvnv_rec.attribute15;
    p6_a25 := ddx_pvnv_rec.version;
    p6_a26 := ddx_pvnv_rec.from_date;
    p6_a27 := ddx_pvnv_rec.to_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_pvnv_rec.created_by);
    p6_a29 := ddx_pvnv_rec.creation_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_pvnv_rec.last_updated_by);
    p6_a31 := ddx_pvnv_rec.last_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_pvnv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddx_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pvn_pvt_w.rosetta_table_copy_in_p5(ddp_pvnv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_tbl,
      ddx_pvnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pvn_pvt_w.rosetta_table_copy_out_p5(ddx_pvnv_tbl, p6_a0
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
      , p6_a31
      , p6_a32
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pvnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pvnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pvnv_rec.app_debit_ccid := rosetta_g_miss_num_map(p5_a2);
    ddp_pvnv_rec.rev_credit_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_pvnv_rec.rev_debit_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_pvnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pvnv_rec.app_credit_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_pvnv_rec.name := p5_a7;
    ddp_pvnv_rec.description := p5_a8;
    ddp_pvnv_rec.attribute_category := p5_a9;
    ddp_pvnv_rec.attribute1 := p5_a10;
    ddp_pvnv_rec.attribute2 := p5_a11;
    ddp_pvnv_rec.attribute3 := p5_a12;
    ddp_pvnv_rec.attribute4 := p5_a13;
    ddp_pvnv_rec.attribute5 := p5_a14;
    ddp_pvnv_rec.attribute6 := p5_a15;
    ddp_pvnv_rec.attribute7 := p5_a16;
    ddp_pvnv_rec.attribute8 := p5_a17;
    ddp_pvnv_rec.attribute9 := p5_a18;
    ddp_pvnv_rec.attribute10 := p5_a19;
    ddp_pvnv_rec.attribute11 := p5_a20;
    ddp_pvnv_rec.attribute12 := p5_a21;
    ddp_pvnv_rec.attribute13 := p5_a22;
    ddp_pvnv_rec.attribute14 := p5_a23;
    ddp_pvnv_rec.attribute15 := p5_a24;
    ddp_pvnv_rec.version := p5_a25;
    ddp_pvnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_pvnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_pvnv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_pvnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_pvnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_pvnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_pvnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
  )

  as
    ddp_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pvn_pvt_w.rosetta_table_copy_in_p5(ddp_pvnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pvnv_rec okl_pvn_pvt.pvnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pvnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pvnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pvnv_rec.app_debit_ccid := rosetta_g_miss_num_map(p5_a2);
    ddp_pvnv_rec.rev_credit_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_pvnv_rec.rev_debit_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_pvnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pvnv_rec.app_credit_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_pvnv_rec.name := p5_a7;
    ddp_pvnv_rec.description := p5_a8;
    ddp_pvnv_rec.attribute_category := p5_a9;
    ddp_pvnv_rec.attribute1 := p5_a10;
    ddp_pvnv_rec.attribute2 := p5_a11;
    ddp_pvnv_rec.attribute3 := p5_a12;
    ddp_pvnv_rec.attribute4 := p5_a13;
    ddp_pvnv_rec.attribute5 := p5_a14;
    ddp_pvnv_rec.attribute6 := p5_a15;
    ddp_pvnv_rec.attribute7 := p5_a16;
    ddp_pvnv_rec.attribute8 := p5_a17;
    ddp_pvnv_rec.attribute9 := p5_a18;
    ddp_pvnv_rec.attribute10 := p5_a19;
    ddp_pvnv_rec.attribute11 := p5_a20;
    ddp_pvnv_rec.attribute12 := p5_a21;
    ddp_pvnv_rec.attribute13 := p5_a22;
    ddp_pvnv_rec.attribute14 := p5_a23;
    ddp_pvnv_rec.attribute15 := p5_a24;
    ddp_pvnv_rec.version := p5_a25;
    ddp_pvnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_pvnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_pvnv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_pvnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_pvnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_pvnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_pvnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
  )

  as
    ddp_pvnv_tbl okl_pvn_pvt.pvnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pvn_pvt_w.rosetta_table_copy_in_p5(ddp_pvnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_pvn_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pvnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_pvn_pvt_w;

/
