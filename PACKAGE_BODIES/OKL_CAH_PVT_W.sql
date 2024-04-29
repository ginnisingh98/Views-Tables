--------------------------------------------------------
--  DDL for Package Body OKL_CAH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CAH_PVT_W" as
  /* $Header: OKLICAHB.pls 120.3 2005/09/20 13:41:15 dkagrawa noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_cah_pvt.cah_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_500
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
    , a22 JTF_NUMBER_TABLE
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
          t(ddindx).name := a1(indx);
          t(ddindx).sequence_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cash_search_type := a3(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).description := a5(indx);
          t(ddindx).attribute_category := a6(indx);
          t(ddindx).attribute1 := a7(indx);
          t(ddindx).attribute2 := a8(indx);
          t(ddindx).attribute3 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute6 := a12(indx);
          t(ddindx).attribute7 := a13(indx);
          t(ddindx).attribute8 := a14(indx);
          t(ddindx).attribute9 := a15(indx);
          t(ddindx).attribute10 := a16(indx);
          t(ddindx).attribute11 := a17(indx);
          t(ddindx).attribute12 := a18(indx);
          t(ddindx).attribute13 := a19(indx);
          t(ddindx).attribute14 := a20(indx);
          t(ddindx).attribute15 := a21(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a22(indx));
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
  procedure rosetta_table_copy_out_p2(t okl_cah_pvt.cah_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a22 out nocopy JTF_NUMBER_TABLE
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
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_500();
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
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_500();
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
      a22 := JTF_NUMBER_TABLE();
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
          a1(indx) := t(ddindx).name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).sequence_number);
          a3(indx) := t(ddindx).cash_search_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).description;
          a6(indx) := t(ddindx).attribute_category;
          a7(indx) := t(ddindx).attribute1;
          a8(indx) := t(ddindx).attribute2;
          a9(indx) := t(ddindx).attribute3;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute6;
          a13(indx) := t(ddindx).attribute7;
          a14(indx) := t(ddindx).attribute8;
          a15(indx) := t(ddindx).attribute9;
          a16(indx) := t(ddindx).attribute10;
          a17(indx) := t(ddindx).attribute11;
          a18(indx) := t(ddindx).attribute12;
          a19(indx) := t(ddindx).attribute13;
          a20(indx) := t(ddindx).attribute14;
          a21(indx) := t(ddindx).attribute15;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
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

  procedure rosetta_table_copy_in_p5(t out nocopy okl_cah_pvt.cahv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
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
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).sequence_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).attribute_category := a5(indx);
          t(ddindx).attribute1 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).attribute10 := a15(indx);
          t(ddindx).attribute11 := a16(indx);
          t(ddindx).attribute12 := a17(indx);
          t(ddindx).attribute13 := a18(indx);
          t(ddindx).attribute14 := a19(indx);
          t(ddindx).attribute15 := a20(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).cash_search_type := a22(indx);
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_cah_pvt.cahv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
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
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
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
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
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
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
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
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).sequence_number);
          a5(indx) := t(ddindx).attribute_category;
          a6(indx) := t(ddindx).attribute1;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).attribute10;
          a16(indx) := t(ddindx).attribute11;
          a17(indx) := t(ddindx).attribute12;
          a18(indx) := t(ddindx).attribute13;
          a19(indx) := t(ddindx).attribute14;
          a20(indx) := t(ddindx).attribute15;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a22(indx) := t(ddindx).cash_search_type;
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
  end rosetta_table_copy_out_p5;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
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
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddx_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cahv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cahv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cahv_rec.name := p5_a2;
    ddp_cahv_rec.description := p5_a3;
    ddp_cahv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_cahv_rec.attribute_category := p5_a5;
    ddp_cahv_rec.attribute1 := p5_a6;
    ddp_cahv_rec.attribute2 := p5_a7;
    ddp_cahv_rec.attribute3 := p5_a8;
    ddp_cahv_rec.attribute4 := p5_a9;
    ddp_cahv_rec.attribute5 := p5_a10;
    ddp_cahv_rec.attribute6 := p5_a11;
    ddp_cahv_rec.attribute7 := p5_a12;
    ddp_cahv_rec.attribute8 := p5_a13;
    ddp_cahv_rec.attribute9 := p5_a14;
    ddp_cahv_rec.attribute10 := p5_a15;
    ddp_cahv_rec.attribute11 := p5_a16;
    ddp_cahv_rec.attribute12 := p5_a17;
    ddp_cahv_rec.attribute13 := p5_a18;
    ddp_cahv_rec.attribute14 := p5_a19;
    ddp_cahv_rec.attribute15 := p5_a20;
    ddp_cahv_rec.org_id := rosetta_g_miss_num_map(p5_a21);
    ddp_cahv_rec.cash_search_type := p5_a22;
    ddp_cahv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_cahv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_cahv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_cahv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cahv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);


    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_rec,
      ddx_cahv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cahv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cahv_rec.object_version_number);
    p6_a2 := ddx_cahv_rec.name;
    p6_a3 := ddx_cahv_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_cahv_rec.sequence_number);
    p6_a5 := ddx_cahv_rec.attribute_category;
    p6_a6 := ddx_cahv_rec.attribute1;
    p6_a7 := ddx_cahv_rec.attribute2;
    p6_a8 := ddx_cahv_rec.attribute3;
    p6_a9 := ddx_cahv_rec.attribute4;
    p6_a10 := ddx_cahv_rec.attribute5;
    p6_a11 := ddx_cahv_rec.attribute6;
    p6_a12 := ddx_cahv_rec.attribute7;
    p6_a13 := ddx_cahv_rec.attribute8;
    p6_a14 := ddx_cahv_rec.attribute9;
    p6_a15 := ddx_cahv_rec.attribute10;
    p6_a16 := ddx_cahv_rec.attribute11;
    p6_a17 := ddx_cahv_rec.attribute12;
    p6_a18 := ddx_cahv_rec.attribute13;
    p6_a19 := ddx_cahv_rec.attribute14;
    p6_a20 := ddx_cahv_rec.attribute15;
    p6_a21 := rosetta_g_miss_num_map(ddx_cahv_rec.org_id);
    p6_a22 := ddx_cahv_rec.cash_search_type;
    p6_a23 := rosetta_g_miss_num_map(ddx_cahv_rec.created_by);
    p6_a24 := ddx_cahv_rec.creation_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_cahv_rec.last_updated_by);
    p6_a26 := ddx_cahv_rec.last_update_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_cahv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddx_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cah_pvt_w.rosetta_table_copy_in_p5(ddp_cahv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_tbl,
      ddx_cahv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cah_pvt_w.rosetta_table_copy_out_p5(ddx_cahv_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cahv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cahv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cahv_rec.name := p5_a2;
    ddp_cahv_rec.description := p5_a3;
    ddp_cahv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_cahv_rec.attribute_category := p5_a5;
    ddp_cahv_rec.attribute1 := p5_a6;
    ddp_cahv_rec.attribute2 := p5_a7;
    ddp_cahv_rec.attribute3 := p5_a8;
    ddp_cahv_rec.attribute4 := p5_a9;
    ddp_cahv_rec.attribute5 := p5_a10;
    ddp_cahv_rec.attribute6 := p5_a11;
    ddp_cahv_rec.attribute7 := p5_a12;
    ddp_cahv_rec.attribute8 := p5_a13;
    ddp_cahv_rec.attribute9 := p5_a14;
    ddp_cahv_rec.attribute10 := p5_a15;
    ddp_cahv_rec.attribute11 := p5_a16;
    ddp_cahv_rec.attribute12 := p5_a17;
    ddp_cahv_rec.attribute13 := p5_a18;
    ddp_cahv_rec.attribute14 := p5_a19;
    ddp_cahv_rec.attribute15 := p5_a20;
    ddp_cahv_rec.org_id := rosetta_g_miss_num_map(p5_a21);
    ddp_cahv_rec.cash_search_type := p5_a22;
    ddp_cahv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_cahv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_cahv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_cahv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cahv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cah_pvt_w.rosetta_table_copy_in_p5(ddp_cahv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_tbl);

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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
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
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddx_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cahv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cahv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cahv_rec.name := p5_a2;
    ddp_cahv_rec.description := p5_a3;
    ddp_cahv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_cahv_rec.attribute_category := p5_a5;
    ddp_cahv_rec.attribute1 := p5_a6;
    ddp_cahv_rec.attribute2 := p5_a7;
    ddp_cahv_rec.attribute3 := p5_a8;
    ddp_cahv_rec.attribute4 := p5_a9;
    ddp_cahv_rec.attribute5 := p5_a10;
    ddp_cahv_rec.attribute6 := p5_a11;
    ddp_cahv_rec.attribute7 := p5_a12;
    ddp_cahv_rec.attribute8 := p5_a13;
    ddp_cahv_rec.attribute9 := p5_a14;
    ddp_cahv_rec.attribute10 := p5_a15;
    ddp_cahv_rec.attribute11 := p5_a16;
    ddp_cahv_rec.attribute12 := p5_a17;
    ddp_cahv_rec.attribute13 := p5_a18;
    ddp_cahv_rec.attribute14 := p5_a19;
    ddp_cahv_rec.attribute15 := p5_a20;
    ddp_cahv_rec.org_id := rosetta_g_miss_num_map(p5_a21);
    ddp_cahv_rec.cash_search_type := p5_a22;
    ddp_cahv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_cahv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_cahv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_cahv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cahv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);


    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_rec,
      ddx_cahv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cahv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cahv_rec.object_version_number);
    p6_a2 := ddx_cahv_rec.name;
    p6_a3 := ddx_cahv_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_cahv_rec.sequence_number);
    p6_a5 := ddx_cahv_rec.attribute_category;
    p6_a6 := ddx_cahv_rec.attribute1;
    p6_a7 := ddx_cahv_rec.attribute2;
    p6_a8 := ddx_cahv_rec.attribute3;
    p6_a9 := ddx_cahv_rec.attribute4;
    p6_a10 := ddx_cahv_rec.attribute5;
    p6_a11 := ddx_cahv_rec.attribute6;
    p6_a12 := ddx_cahv_rec.attribute7;
    p6_a13 := ddx_cahv_rec.attribute8;
    p6_a14 := ddx_cahv_rec.attribute9;
    p6_a15 := ddx_cahv_rec.attribute10;
    p6_a16 := ddx_cahv_rec.attribute11;
    p6_a17 := ddx_cahv_rec.attribute12;
    p6_a18 := ddx_cahv_rec.attribute13;
    p6_a19 := ddx_cahv_rec.attribute14;
    p6_a20 := ddx_cahv_rec.attribute15;
    p6_a21 := rosetta_g_miss_num_map(ddx_cahv_rec.org_id);
    p6_a22 := ddx_cahv_rec.cash_search_type;
    p6_a23 := rosetta_g_miss_num_map(ddx_cahv_rec.created_by);
    p6_a24 := ddx_cahv_rec.creation_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_cahv_rec.last_updated_by);
    p6_a26 := ddx_cahv_rec.last_update_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_cahv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddx_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cah_pvt_w.rosetta_table_copy_in_p5(ddp_cahv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_tbl,
      ddx_cahv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cah_pvt_w.rosetta_table_copy_out_p5(ddx_cahv_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cahv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cahv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cahv_rec.name := p5_a2;
    ddp_cahv_rec.description := p5_a3;
    ddp_cahv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_cahv_rec.attribute_category := p5_a5;
    ddp_cahv_rec.attribute1 := p5_a6;
    ddp_cahv_rec.attribute2 := p5_a7;
    ddp_cahv_rec.attribute3 := p5_a8;
    ddp_cahv_rec.attribute4 := p5_a9;
    ddp_cahv_rec.attribute5 := p5_a10;
    ddp_cahv_rec.attribute6 := p5_a11;
    ddp_cahv_rec.attribute7 := p5_a12;
    ddp_cahv_rec.attribute8 := p5_a13;
    ddp_cahv_rec.attribute9 := p5_a14;
    ddp_cahv_rec.attribute10 := p5_a15;
    ddp_cahv_rec.attribute11 := p5_a16;
    ddp_cahv_rec.attribute12 := p5_a17;
    ddp_cahv_rec.attribute13 := p5_a18;
    ddp_cahv_rec.attribute14 := p5_a19;
    ddp_cahv_rec.attribute15 := p5_a20;
    ddp_cahv_rec.org_id := rosetta_g_miss_num_map(p5_a21);
    ddp_cahv_rec.cash_search_type := p5_a22;
    ddp_cahv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_cahv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_cahv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_cahv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cahv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cah_pvt_w.rosetta_table_copy_in_p5(ddp_cahv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_tbl);

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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_cahv_rec okl_cah_pvt.cahv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cahv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cahv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cahv_rec.name := p5_a2;
    ddp_cahv_rec.description := p5_a3;
    ddp_cahv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_cahv_rec.attribute_category := p5_a5;
    ddp_cahv_rec.attribute1 := p5_a6;
    ddp_cahv_rec.attribute2 := p5_a7;
    ddp_cahv_rec.attribute3 := p5_a8;
    ddp_cahv_rec.attribute4 := p5_a9;
    ddp_cahv_rec.attribute5 := p5_a10;
    ddp_cahv_rec.attribute6 := p5_a11;
    ddp_cahv_rec.attribute7 := p5_a12;
    ddp_cahv_rec.attribute8 := p5_a13;
    ddp_cahv_rec.attribute9 := p5_a14;
    ddp_cahv_rec.attribute10 := p5_a15;
    ddp_cahv_rec.attribute11 := p5_a16;
    ddp_cahv_rec.attribute12 := p5_a17;
    ddp_cahv_rec.attribute13 := p5_a18;
    ddp_cahv_rec.attribute14 := p5_a19;
    ddp_cahv_rec.attribute15 := p5_a20;
    ddp_cahv_rec.org_id := rosetta_g_miss_num_map(p5_a21);
    ddp_cahv_rec.cash_search_type := p5_a22;
    ddp_cahv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_cahv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_cahv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_cahv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cahv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_cahv_tbl okl_cah_pvt.cahv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cah_pvt_w.rosetta_table_copy_in_p5(ddp_cahv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cah_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_cah_pvt_w;

/
