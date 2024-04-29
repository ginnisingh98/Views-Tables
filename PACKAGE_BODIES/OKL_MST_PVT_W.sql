--------------------------------------------------------
--  DDL for Package Body OKL_MST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MST_PVT_W" as
  /* $Header: OKLEMSTB.pls 115.2 2004/02/24 22:46:11 dedey noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_mst_pvt.mstv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_600
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
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
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).request_name := a1(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).contract_number := a3(indx);
          t(ddindx).contract_description := a4(indx);
          t(ddindx).kle_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).selected_flag := a7(indx);
          t(ddindx).status := a8(indx);
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a30(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_mst_pvt.mstv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_600
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_600();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
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
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_600();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
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
          a1(indx) := t(ddindx).request_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a3(indx) := t(ddindx).contract_number;
          a4(indx) := t(ddindx).contract_description;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a7(indx) := t(ddindx).selected_flag;
          a8(indx) := t(ddindx).status;
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
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a26(indx) := t(ddindx).creation_date;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a28(indx) := t(ddindx).last_update_date;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a30(indx) := t(ddindx).transaction_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_mst_pvt.mst_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_600
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
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
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).request_name := a1(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).contract_number := a3(indx);
          t(ddindx).contract_description := a4(indx);
          t(ddindx).kle_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).selected_flag := a7(indx);
          t(ddindx).status := a8(indx);
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a30(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_mst_pvt.mst_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_600
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_600();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
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
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_600();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
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
          a1(indx) := t(ddindx).request_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a3(indx) := t(ddindx).contract_number;
          a4(indx) := t(ddindx).contract_description;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a7(indx) := t(ddindx).selected_flag;
          a8(indx) := t(ddindx).status;
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
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a26(indx) := t(ddindx).creation_date;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a28(indx) := t(ddindx).last_update_date;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a30(indx) := t(ddindx).transaction_date;
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
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
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
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
  )

  as
    ddp_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddx_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_mstv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_mstv_rec.request_name := p5_a1;
    ddp_mstv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_mstv_rec.contract_number := p5_a3;
    ddp_mstv_rec.contract_description := p5_a4;
    ddp_mstv_rec.kle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_mstv_rec.transaction_id := rosetta_g_miss_num_map(p5_a6);
    ddp_mstv_rec.selected_flag := p5_a7;
    ddp_mstv_rec.status := p5_a8;
    ddp_mstv_rec.attribute_category := p5_a9;
    ddp_mstv_rec.attribute1 := p5_a10;
    ddp_mstv_rec.attribute2 := p5_a11;
    ddp_mstv_rec.attribute3 := p5_a12;
    ddp_mstv_rec.attribute4 := p5_a13;
    ddp_mstv_rec.attribute5 := p5_a14;
    ddp_mstv_rec.attribute6 := p5_a15;
    ddp_mstv_rec.attribute7 := p5_a16;
    ddp_mstv_rec.attribute8 := p5_a17;
    ddp_mstv_rec.attribute9 := p5_a18;
    ddp_mstv_rec.attribute10 := p5_a19;
    ddp_mstv_rec.attribute11 := p5_a20;
    ddp_mstv_rec.attribute12 := p5_a21;
    ddp_mstv_rec.attribute13 := p5_a22;
    ddp_mstv_rec.attribute14 := p5_a23;
    ddp_mstv_rec.attribute15 := p5_a24;
    ddp_mstv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_mstv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_mstv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_mstv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_mstv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_mstv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a30);


    -- here's the delegated call to the old PL/SQL routine
    okl_mst_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_rec,
      ddx_mstv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_mstv_rec.id);
    p6_a1 := ddx_mstv_rec.request_name;
    p6_a2 := rosetta_g_miss_num_map(ddx_mstv_rec.khr_id);
    p6_a3 := ddx_mstv_rec.contract_number;
    p6_a4 := ddx_mstv_rec.contract_description;
    p6_a5 := rosetta_g_miss_num_map(ddx_mstv_rec.kle_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_mstv_rec.transaction_id);
    p6_a7 := ddx_mstv_rec.selected_flag;
    p6_a8 := ddx_mstv_rec.status;
    p6_a9 := ddx_mstv_rec.attribute_category;
    p6_a10 := ddx_mstv_rec.attribute1;
    p6_a11 := ddx_mstv_rec.attribute2;
    p6_a12 := ddx_mstv_rec.attribute3;
    p6_a13 := ddx_mstv_rec.attribute4;
    p6_a14 := ddx_mstv_rec.attribute5;
    p6_a15 := ddx_mstv_rec.attribute6;
    p6_a16 := ddx_mstv_rec.attribute7;
    p6_a17 := ddx_mstv_rec.attribute8;
    p6_a18 := ddx_mstv_rec.attribute9;
    p6_a19 := ddx_mstv_rec.attribute10;
    p6_a20 := ddx_mstv_rec.attribute11;
    p6_a21 := ddx_mstv_rec.attribute12;
    p6_a22 := ddx_mstv_rec.attribute13;
    p6_a23 := ddx_mstv_rec.attribute14;
    p6_a24 := ddx_mstv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_mstv_rec.created_by);
    p6_a26 := ddx_mstv_rec.creation_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_mstv_rec.last_updated_by);
    p6_a28 := ddx_mstv_rec.last_update_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_mstv_rec.last_update_login);
    p6_a30 := ddx_mstv_rec.transaction_date;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddx_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mst_pvt_w.rosetta_table_copy_in_p2(ddp_mstv_tbl, p5_a0
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
    okl_mst_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_tbl,
      ddx_mstv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_mst_pvt_w.rosetta_table_copy_out_p2(ddx_mstv_tbl, p6_a0
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
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
  )

  as
    ddp_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_mstv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_mstv_rec.request_name := p5_a1;
    ddp_mstv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_mstv_rec.contract_number := p5_a3;
    ddp_mstv_rec.contract_description := p5_a4;
    ddp_mstv_rec.kle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_mstv_rec.transaction_id := rosetta_g_miss_num_map(p5_a6);
    ddp_mstv_rec.selected_flag := p5_a7;
    ddp_mstv_rec.status := p5_a8;
    ddp_mstv_rec.attribute_category := p5_a9;
    ddp_mstv_rec.attribute1 := p5_a10;
    ddp_mstv_rec.attribute2 := p5_a11;
    ddp_mstv_rec.attribute3 := p5_a12;
    ddp_mstv_rec.attribute4 := p5_a13;
    ddp_mstv_rec.attribute5 := p5_a14;
    ddp_mstv_rec.attribute6 := p5_a15;
    ddp_mstv_rec.attribute7 := p5_a16;
    ddp_mstv_rec.attribute8 := p5_a17;
    ddp_mstv_rec.attribute9 := p5_a18;
    ddp_mstv_rec.attribute10 := p5_a19;
    ddp_mstv_rec.attribute11 := p5_a20;
    ddp_mstv_rec.attribute12 := p5_a21;
    ddp_mstv_rec.attribute13 := p5_a22;
    ddp_mstv_rec.attribute14 := p5_a23;
    ddp_mstv_rec.attribute15 := p5_a24;
    ddp_mstv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_mstv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_mstv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_mstv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_mstv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_mstv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_mst_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
  )

  as
    ddp_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mst_pvt_w.rosetta_table_copy_in_p2(ddp_mstv_tbl, p5_a0
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
    okl_mst_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
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
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
  )

  as
    ddp_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddx_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_mstv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_mstv_rec.request_name := p5_a1;
    ddp_mstv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_mstv_rec.contract_number := p5_a3;
    ddp_mstv_rec.contract_description := p5_a4;
    ddp_mstv_rec.kle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_mstv_rec.transaction_id := rosetta_g_miss_num_map(p5_a6);
    ddp_mstv_rec.selected_flag := p5_a7;
    ddp_mstv_rec.status := p5_a8;
    ddp_mstv_rec.attribute_category := p5_a9;
    ddp_mstv_rec.attribute1 := p5_a10;
    ddp_mstv_rec.attribute2 := p5_a11;
    ddp_mstv_rec.attribute3 := p5_a12;
    ddp_mstv_rec.attribute4 := p5_a13;
    ddp_mstv_rec.attribute5 := p5_a14;
    ddp_mstv_rec.attribute6 := p5_a15;
    ddp_mstv_rec.attribute7 := p5_a16;
    ddp_mstv_rec.attribute8 := p5_a17;
    ddp_mstv_rec.attribute9 := p5_a18;
    ddp_mstv_rec.attribute10 := p5_a19;
    ddp_mstv_rec.attribute11 := p5_a20;
    ddp_mstv_rec.attribute12 := p5_a21;
    ddp_mstv_rec.attribute13 := p5_a22;
    ddp_mstv_rec.attribute14 := p5_a23;
    ddp_mstv_rec.attribute15 := p5_a24;
    ddp_mstv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_mstv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_mstv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_mstv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_mstv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_mstv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a30);


    -- here's the delegated call to the old PL/SQL routine
    okl_mst_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_rec,
      ddx_mstv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_mstv_rec.id);
    p6_a1 := ddx_mstv_rec.request_name;
    p6_a2 := rosetta_g_miss_num_map(ddx_mstv_rec.khr_id);
    p6_a3 := ddx_mstv_rec.contract_number;
    p6_a4 := ddx_mstv_rec.contract_description;
    p6_a5 := rosetta_g_miss_num_map(ddx_mstv_rec.kle_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_mstv_rec.transaction_id);
    p6_a7 := ddx_mstv_rec.selected_flag;
    p6_a8 := ddx_mstv_rec.status;
    p6_a9 := ddx_mstv_rec.attribute_category;
    p6_a10 := ddx_mstv_rec.attribute1;
    p6_a11 := ddx_mstv_rec.attribute2;
    p6_a12 := ddx_mstv_rec.attribute3;
    p6_a13 := ddx_mstv_rec.attribute4;
    p6_a14 := ddx_mstv_rec.attribute5;
    p6_a15 := ddx_mstv_rec.attribute6;
    p6_a16 := ddx_mstv_rec.attribute7;
    p6_a17 := ddx_mstv_rec.attribute8;
    p6_a18 := ddx_mstv_rec.attribute9;
    p6_a19 := ddx_mstv_rec.attribute10;
    p6_a20 := ddx_mstv_rec.attribute11;
    p6_a21 := ddx_mstv_rec.attribute12;
    p6_a22 := ddx_mstv_rec.attribute13;
    p6_a23 := ddx_mstv_rec.attribute14;
    p6_a24 := ddx_mstv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_mstv_rec.created_by);
    p6_a26 := ddx_mstv_rec.creation_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_mstv_rec.last_updated_by);
    p6_a28 := ddx_mstv_rec.last_update_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_mstv_rec.last_update_login);
    p6_a30 := ddx_mstv_rec.transaction_date;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddx_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mst_pvt_w.rosetta_table_copy_in_p2(ddp_mstv_tbl, p5_a0
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
    okl_mst_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_tbl,
      ddx_mstv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_mst_pvt_w.rosetta_table_copy_out_p2(ddx_mstv_tbl, p6_a0
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
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
  )

  as
    ddp_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_mstv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_mstv_rec.request_name := p5_a1;
    ddp_mstv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_mstv_rec.contract_number := p5_a3;
    ddp_mstv_rec.contract_description := p5_a4;
    ddp_mstv_rec.kle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_mstv_rec.transaction_id := rosetta_g_miss_num_map(p5_a6);
    ddp_mstv_rec.selected_flag := p5_a7;
    ddp_mstv_rec.status := p5_a8;
    ddp_mstv_rec.attribute_category := p5_a9;
    ddp_mstv_rec.attribute1 := p5_a10;
    ddp_mstv_rec.attribute2 := p5_a11;
    ddp_mstv_rec.attribute3 := p5_a12;
    ddp_mstv_rec.attribute4 := p5_a13;
    ddp_mstv_rec.attribute5 := p5_a14;
    ddp_mstv_rec.attribute6 := p5_a15;
    ddp_mstv_rec.attribute7 := p5_a16;
    ddp_mstv_rec.attribute8 := p5_a17;
    ddp_mstv_rec.attribute9 := p5_a18;
    ddp_mstv_rec.attribute10 := p5_a19;
    ddp_mstv_rec.attribute11 := p5_a20;
    ddp_mstv_rec.attribute12 := p5_a21;
    ddp_mstv_rec.attribute13 := p5_a22;
    ddp_mstv_rec.attribute14 := p5_a23;
    ddp_mstv_rec.attribute15 := p5_a24;
    ddp_mstv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_mstv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_mstv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_mstv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_mstv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_mstv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_mst_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
  )

  as
    ddp_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mst_pvt_w.rosetta_table_copy_in_p2(ddp_mstv_tbl, p5_a0
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
    okl_mst_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
  )

  as
    ddp_mstv_rec okl_mst_pvt.mstv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_mstv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_mstv_rec.request_name := p5_a1;
    ddp_mstv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_mstv_rec.contract_number := p5_a3;
    ddp_mstv_rec.contract_description := p5_a4;
    ddp_mstv_rec.kle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_mstv_rec.transaction_id := rosetta_g_miss_num_map(p5_a6);
    ddp_mstv_rec.selected_flag := p5_a7;
    ddp_mstv_rec.status := p5_a8;
    ddp_mstv_rec.attribute_category := p5_a9;
    ddp_mstv_rec.attribute1 := p5_a10;
    ddp_mstv_rec.attribute2 := p5_a11;
    ddp_mstv_rec.attribute3 := p5_a12;
    ddp_mstv_rec.attribute4 := p5_a13;
    ddp_mstv_rec.attribute5 := p5_a14;
    ddp_mstv_rec.attribute6 := p5_a15;
    ddp_mstv_rec.attribute7 := p5_a16;
    ddp_mstv_rec.attribute8 := p5_a17;
    ddp_mstv_rec.attribute9 := p5_a18;
    ddp_mstv_rec.attribute10 := p5_a19;
    ddp_mstv_rec.attribute11 := p5_a20;
    ddp_mstv_rec.attribute12 := p5_a21;
    ddp_mstv_rec.attribute13 := p5_a22;
    ddp_mstv_rec.attribute14 := p5_a23;
    ddp_mstv_rec.attribute15 := p5_a24;
    ddp_mstv_rec.created_by := rosetta_g_miss_num_map(p5_a25);
    ddp_mstv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_mstv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a27);
    ddp_mstv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_mstv_rec.last_update_login := rosetta_g_miss_num_map(p5_a29);
    ddp_mstv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_mst_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
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
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
  )

  as
    ddp_mstv_tbl okl_mst_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mst_pvt_w.rosetta_table_copy_in_p2(ddp_mstv_tbl, p5_a0
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
    okl_mst_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_mst_pvt_w;

/
