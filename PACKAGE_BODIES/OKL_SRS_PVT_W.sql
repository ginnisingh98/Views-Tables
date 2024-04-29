--------------------------------------------------------
--  DDL for Package Body OKL_SRS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SRS_PVT_W" as
  /* $Header: OKLISRSB.pls 120.1 2005/07/15 07:39:14 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_srs_pvt.srs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
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
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).stream_type_name := a1(indx);
          t(ddindx).index_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).activity_type := a3(indx);
          t(ddindx).sequence_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).sre_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).sir_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).stream_interface_attribute01 := a8(indx);
          t(ddindx).stream_interface_attribute02 := a9(indx);
          t(ddindx).stream_interface_attribute03 := a10(indx);
          t(ddindx).stream_interface_attribute04 := a11(indx);
          t(ddindx).stream_interface_attribute05 := a12(indx);
          t(ddindx).stream_interface_attribute06 := a13(indx);
          t(ddindx).stream_interface_attribute07 := a14(indx);
          t(ddindx).stream_interface_attribute08 := a15(indx);
          t(ddindx).stream_interface_attribute09 := a16(indx);
          t(ddindx).stream_interface_attribute10 := a17(indx);
          t(ddindx).stream_interface_attribute11 := a18(indx);
          t(ddindx).stream_interface_attribute12 := a19(indx);
          t(ddindx).stream_interface_attribute13 := a20(indx);
          t(ddindx).stream_interface_attribute14 := a21(indx);
          t(ddindx).stream_interface_attribute15 := a22(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a28(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_srs_pvt.srs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
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
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
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
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
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
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).stream_type_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).index_number);
          a3(indx) := t(ddindx).activity_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).sequence_number);
          a5(indx) := t(ddindx).sre_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).sir_id);
          a8(indx) := t(ddindx).stream_interface_attribute01;
          a9(indx) := t(ddindx).stream_interface_attribute02;
          a10(indx) := t(ddindx).stream_interface_attribute03;
          a11(indx) := t(ddindx).stream_interface_attribute04;
          a12(indx) := t(ddindx).stream_interface_attribute05;
          a13(indx) := t(ddindx).stream_interface_attribute06;
          a14(indx) := t(ddindx).stream_interface_attribute07;
          a15(indx) := t(ddindx).stream_interface_attribute08;
          a16(indx) := t(ddindx).stream_interface_attribute09;
          a17(indx) := t(ddindx).stream_interface_attribute10;
          a18(indx) := t(ddindx).stream_interface_attribute11;
          a19(indx) := t(ddindx).stream_interface_attribute12;
          a20(indx) := t(ddindx).stream_interface_attribute13;
          a21(indx) := t(ddindx).stream_interface_attribute14;
          a22(indx) := t(ddindx).stream_interface_attribute15;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := t(ddindx).creation_date;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_srs_pvt.srsv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
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
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).stream_type_name := a1(indx);
          t(ddindx).index_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).activity_type := a3(indx);
          t(ddindx).sequence_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).sre_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).sir_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).stream_interface_attribute01 := a8(indx);
          t(ddindx).stream_interface_attribute02 := a9(indx);
          t(ddindx).stream_interface_attribute03 := a10(indx);
          t(ddindx).stream_interface_attribute04 := a11(indx);
          t(ddindx).stream_interface_attribute05 := a12(indx);
          t(ddindx).stream_interface_attribute06 := a13(indx);
          t(ddindx).stream_interface_attribute07 := a14(indx);
          t(ddindx).stream_interface_attribute08 := a15(indx);
          t(ddindx).stream_interface_attribute09 := a16(indx);
          t(ddindx).stream_interface_attribute10 := a17(indx);
          t(ddindx).stream_interface_attribute11 := a18(indx);
          t(ddindx).stream_interface_attribute12 := a19(indx);
          t(ddindx).stream_interface_attribute13 := a20(indx);
          t(ddindx).stream_interface_attribute14 := a21(indx);
          t(ddindx).stream_interface_attribute15 := a22(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a28(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_srs_pvt.srsv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
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
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
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
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
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
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).stream_type_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).index_number);
          a3(indx) := t(ddindx).activity_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).sequence_number);
          a5(indx) := t(ddindx).sre_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).sir_id);
          a8(indx) := t(ddindx).stream_interface_attribute01;
          a9(indx) := t(ddindx).stream_interface_attribute02;
          a10(indx) := t(ddindx).stream_interface_attribute03;
          a11(indx) := t(ddindx).stream_interface_attribute04;
          a12(indx) := t(ddindx).stream_interface_attribute05;
          a13(indx) := t(ddindx).stream_interface_attribute06;
          a14(indx) := t(ddindx).stream_interface_attribute07;
          a15(indx) := t(ddindx).stream_interface_attribute08;
          a16(indx) := t(ddindx).stream_interface_attribute09;
          a17(indx) := t(ddindx).stream_interface_attribute10;
          a18(indx) := t(ddindx).stream_interface_attribute11;
          a19(indx) := t(ddindx).stream_interface_attribute12;
          a20(indx) := t(ddindx).stream_interface_attribute13;
          a21(indx) := t(ddindx).stream_interface_attribute14;
          a22(indx) := t(ddindx).stream_interface_attribute15;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := t(ddindx).creation_date;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
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
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddx_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_srsv_rec.stream_type_name := p5_a1;
    ddp_srsv_rec.index_number := rosetta_g_miss_num_map(p5_a2);
    ddp_srsv_rec.activity_type := p5_a3;
    ddp_srsv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_srsv_rec.sre_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_srsv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_srsv_rec.sir_id := rosetta_g_miss_num_map(p5_a7);
    ddp_srsv_rec.stream_interface_attribute01 := p5_a8;
    ddp_srsv_rec.stream_interface_attribute02 := p5_a9;
    ddp_srsv_rec.stream_interface_attribute03 := p5_a10;
    ddp_srsv_rec.stream_interface_attribute04 := p5_a11;
    ddp_srsv_rec.stream_interface_attribute05 := p5_a12;
    ddp_srsv_rec.stream_interface_attribute06 := p5_a13;
    ddp_srsv_rec.stream_interface_attribute07 := p5_a14;
    ddp_srsv_rec.stream_interface_attribute08 := p5_a15;
    ddp_srsv_rec.stream_interface_attribute09 := p5_a16;
    ddp_srsv_rec.stream_interface_attribute10 := p5_a17;
    ddp_srsv_rec.stream_interface_attribute11 := p5_a18;
    ddp_srsv_rec.stream_interface_attribute12 := p5_a19;
    ddp_srsv_rec.stream_interface_attribute13 := p5_a20;
    ddp_srsv_rec.stream_interface_attribute14 := p5_a21;
    ddp_srsv_rec.stream_interface_attribute15 := p5_a22;
    ddp_srsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_srsv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_srsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_srsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_srsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_srsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);


    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_rec,
      ddx_srsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_srsv_rec.id);
    p6_a1 := ddx_srsv_rec.stream_type_name;
    p6_a2 := rosetta_g_miss_num_map(ddx_srsv_rec.index_number);
    p6_a3 := ddx_srsv_rec.activity_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_srsv_rec.sequence_number);
    p6_a5 := ddx_srsv_rec.sre_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_srsv_rec.amount);
    p6_a7 := rosetta_g_miss_num_map(ddx_srsv_rec.sir_id);
    p6_a8 := ddx_srsv_rec.stream_interface_attribute01;
    p6_a9 := ddx_srsv_rec.stream_interface_attribute02;
    p6_a10 := ddx_srsv_rec.stream_interface_attribute03;
    p6_a11 := ddx_srsv_rec.stream_interface_attribute04;
    p6_a12 := ddx_srsv_rec.stream_interface_attribute05;
    p6_a13 := ddx_srsv_rec.stream_interface_attribute06;
    p6_a14 := ddx_srsv_rec.stream_interface_attribute07;
    p6_a15 := ddx_srsv_rec.stream_interface_attribute08;
    p6_a16 := ddx_srsv_rec.stream_interface_attribute09;
    p6_a17 := ddx_srsv_rec.stream_interface_attribute10;
    p6_a18 := ddx_srsv_rec.stream_interface_attribute11;
    p6_a19 := ddx_srsv_rec.stream_interface_attribute12;
    p6_a20 := ddx_srsv_rec.stream_interface_attribute13;
    p6_a21 := ddx_srsv_rec.stream_interface_attribute14;
    p6_a22 := ddx_srsv_rec.stream_interface_attribute15;
    p6_a23 := rosetta_g_miss_num_map(ddx_srsv_rec.object_version_number);
    p6_a24 := rosetta_g_miss_num_map(ddx_srsv_rec.created_by);
    p6_a25 := rosetta_g_miss_num_map(ddx_srsv_rec.last_updated_by);
    p6_a26 := ddx_srsv_rec.creation_date;
    p6_a27 := ddx_srsv_rec.last_update_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_srsv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
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
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddx_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_srs_pvt_w.rosetta_table_copy_in_p5(ddp_srsv_tbl, p5_a0
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
    okl_srs_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_tbl,
      ddx_srsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_srs_pvt_w.rosetta_table_copy_out_p5(ddx_srsv_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_srsv_rec.stream_type_name := p5_a1;
    ddp_srsv_rec.index_number := rosetta_g_miss_num_map(p5_a2);
    ddp_srsv_rec.activity_type := p5_a3;
    ddp_srsv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_srsv_rec.sre_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_srsv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_srsv_rec.sir_id := rosetta_g_miss_num_map(p5_a7);
    ddp_srsv_rec.stream_interface_attribute01 := p5_a8;
    ddp_srsv_rec.stream_interface_attribute02 := p5_a9;
    ddp_srsv_rec.stream_interface_attribute03 := p5_a10;
    ddp_srsv_rec.stream_interface_attribute04 := p5_a11;
    ddp_srsv_rec.stream_interface_attribute05 := p5_a12;
    ddp_srsv_rec.stream_interface_attribute06 := p5_a13;
    ddp_srsv_rec.stream_interface_attribute07 := p5_a14;
    ddp_srsv_rec.stream_interface_attribute08 := p5_a15;
    ddp_srsv_rec.stream_interface_attribute09 := p5_a16;
    ddp_srsv_rec.stream_interface_attribute10 := p5_a17;
    ddp_srsv_rec.stream_interface_attribute11 := p5_a18;
    ddp_srsv_rec.stream_interface_attribute12 := p5_a19;
    ddp_srsv_rec.stream_interface_attribute13 := p5_a20;
    ddp_srsv_rec.stream_interface_attribute14 := p5_a21;
    ddp_srsv_rec.stream_interface_attribute15 := p5_a22;
    ddp_srsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_srsv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_srsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_srsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_srsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_srsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);

    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
  )

  as
    ddp_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_srs_pvt_w.rosetta_table_copy_in_p5(ddp_srsv_tbl, p5_a0
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
    okl_srs_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_tbl);

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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
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
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddx_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_srsv_rec.stream_type_name := p5_a1;
    ddp_srsv_rec.index_number := rosetta_g_miss_num_map(p5_a2);
    ddp_srsv_rec.activity_type := p5_a3;
    ddp_srsv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_srsv_rec.sre_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_srsv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_srsv_rec.sir_id := rosetta_g_miss_num_map(p5_a7);
    ddp_srsv_rec.stream_interface_attribute01 := p5_a8;
    ddp_srsv_rec.stream_interface_attribute02 := p5_a9;
    ddp_srsv_rec.stream_interface_attribute03 := p5_a10;
    ddp_srsv_rec.stream_interface_attribute04 := p5_a11;
    ddp_srsv_rec.stream_interface_attribute05 := p5_a12;
    ddp_srsv_rec.stream_interface_attribute06 := p5_a13;
    ddp_srsv_rec.stream_interface_attribute07 := p5_a14;
    ddp_srsv_rec.stream_interface_attribute08 := p5_a15;
    ddp_srsv_rec.stream_interface_attribute09 := p5_a16;
    ddp_srsv_rec.stream_interface_attribute10 := p5_a17;
    ddp_srsv_rec.stream_interface_attribute11 := p5_a18;
    ddp_srsv_rec.stream_interface_attribute12 := p5_a19;
    ddp_srsv_rec.stream_interface_attribute13 := p5_a20;
    ddp_srsv_rec.stream_interface_attribute14 := p5_a21;
    ddp_srsv_rec.stream_interface_attribute15 := p5_a22;
    ddp_srsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_srsv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_srsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_srsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_srsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_srsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);


    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_rec,
      ddx_srsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_srsv_rec.id);
    p6_a1 := ddx_srsv_rec.stream_type_name;
    p6_a2 := rosetta_g_miss_num_map(ddx_srsv_rec.index_number);
    p6_a3 := ddx_srsv_rec.activity_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_srsv_rec.sequence_number);
    p6_a5 := ddx_srsv_rec.sre_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_srsv_rec.amount);
    p6_a7 := rosetta_g_miss_num_map(ddx_srsv_rec.sir_id);
    p6_a8 := ddx_srsv_rec.stream_interface_attribute01;
    p6_a9 := ddx_srsv_rec.stream_interface_attribute02;
    p6_a10 := ddx_srsv_rec.stream_interface_attribute03;
    p6_a11 := ddx_srsv_rec.stream_interface_attribute04;
    p6_a12 := ddx_srsv_rec.stream_interface_attribute05;
    p6_a13 := ddx_srsv_rec.stream_interface_attribute06;
    p6_a14 := ddx_srsv_rec.stream_interface_attribute07;
    p6_a15 := ddx_srsv_rec.stream_interface_attribute08;
    p6_a16 := ddx_srsv_rec.stream_interface_attribute09;
    p6_a17 := ddx_srsv_rec.stream_interface_attribute10;
    p6_a18 := ddx_srsv_rec.stream_interface_attribute11;
    p6_a19 := ddx_srsv_rec.stream_interface_attribute12;
    p6_a20 := ddx_srsv_rec.stream_interface_attribute13;
    p6_a21 := ddx_srsv_rec.stream_interface_attribute14;
    p6_a22 := ddx_srsv_rec.stream_interface_attribute15;
    p6_a23 := rosetta_g_miss_num_map(ddx_srsv_rec.object_version_number);
    p6_a24 := rosetta_g_miss_num_map(ddx_srsv_rec.created_by);
    p6_a25 := rosetta_g_miss_num_map(ddx_srsv_rec.last_updated_by);
    p6_a26 := ddx_srsv_rec.creation_date;
    p6_a27 := ddx_srsv_rec.last_update_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_srsv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
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
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddx_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_srs_pvt_w.rosetta_table_copy_in_p5(ddp_srsv_tbl, p5_a0
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
    okl_srs_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_tbl,
      ddx_srsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_srs_pvt_w.rosetta_table_copy_out_p5(ddx_srsv_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_srsv_rec.stream_type_name := p5_a1;
    ddp_srsv_rec.index_number := rosetta_g_miss_num_map(p5_a2);
    ddp_srsv_rec.activity_type := p5_a3;
    ddp_srsv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_srsv_rec.sre_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_srsv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_srsv_rec.sir_id := rosetta_g_miss_num_map(p5_a7);
    ddp_srsv_rec.stream_interface_attribute01 := p5_a8;
    ddp_srsv_rec.stream_interface_attribute02 := p5_a9;
    ddp_srsv_rec.stream_interface_attribute03 := p5_a10;
    ddp_srsv_rec.stream_interface_attribute04 := p5_a11;
    ddp_srsv_rec.stream_interface_attribute05 := p5_a12;
    ddp_srsv_rec.stream_interface_attribute06 := p5_a13;
    ddp_srsv_rec.stream_interface_attribute07 := p5_a14;
    ddp_srsv_rec.stream_interface_attribute08 := p5_a15;
    ddp_srsv_rec.stream_interface_attribute09 := p5_a16;
    ddp_srsv_rec.stream_interface_attribute10 := p5_a17;
    ddp_srsv_rec.stream_interface_attribute11 := p5_a18;
    ddp_srsv_rec.stream_interface_attribute12 := p5_a19;
    ddp_srsv_rec.stream_interface_attribute13 := p5_a20;
    ddp_srsv_rec.stream_interface_attribute14 := p5_a21;
    ddp_srsv_rec.stream_interface_attribute15 := p5_a22;
    ddp_srsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_srsv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_srsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_srsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_srsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_srsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);

    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
  )

  as
    ddp_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_srs_pvt_w.rosetta_table_copy_in_p5(ddp_srsv_tbl, p5_a0
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
    okl_srs_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_tbl);

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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_srsv_rec.stream_type_name := p5_a1;
    ddp_srsv_rec.index_number := rosetta_g_miss_num_map(p5_a2);
    ddp_srsv_rec.activity_type := p5_a3;
    ddp_srsv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_srsv_rec.sre_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_srsv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_srsv_rec.sir_id := rosetta_g_miss_num_map(p5_a7);
    ddp_srsv_rec.stream_interface_attribute01 := p5_a8;
    ddp_srsv_rec.stream_interface_attribute02 := p5_a9;
    ddp_srsv_rec.stream_interface_attribute03 := p5_a10;
    ddp_srsv_rec.stream_interface_attribute04 := p5_a11;
    ddp_srsv_rec.stream_interface_attribute05 := p5_a12;
    ddp_srsv_rec.stream_interface_attribute06 := p5_a13;
    ddp_srsv_rec.stream_interface_attribute07 := p5_a14;
    ddp_srsv_rec.stream_interface_attribute08 := p5_a15;
    ddp_srsv_rec.stream_interface_attribute09 := p5_a16;
    ddp_srsv_rec.stream_interface_attribute10 := p5_a17;
    ddp_srsv_rec.stream_interface_attribute11 := p5_a18;
    ddp_srsv_rec.stream_interface_attribute12 := p5_a19;
    ddp_srsv_rec.stream_interface_attribute13 := p5_a20;
    ddp_srsv_rec.stream_interface_attribute14 := p5_a21;
    ddp_srsv_rec.stream_interface_attribute15 := p5_a22;
    ddp_srsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_srsv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_srsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_srsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_srsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_srsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);

    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
  )

  as
    ddp_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_srs_pvt_w.rosetta_table_copy_in_p5(ddp_srsv_tbl, p5_a0
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
    okl_srs_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_row_upg(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_200
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_VARCHAR2_TABLE_500
    , p0_a9 JTF_VARCHAR2_TABLE_500
    , p0_a10 JTF_VARCHAR2_TABLE_500
    , p0_a11 JTF_VARCHAR2_TABLE_500
    , p0_a12 JTF_VARCHAR2_TABLE_500
    , p0_a13 JTF_VARCHAR2_TABLE_500
    , p0_a14 JTF_VARCHAR2_TABLE_500
    , p0_a15 JTF_VARCHAR2_TABLE_500
    , p0_a16 JTF_VARCHAR2_TABLE_500
    , p0_a17 JTF_VARCHAR2_TABLE_500
    , p0_a18 JTF_VARCHAR2_TABLE_500
    , p0_a19 JTF_VARCHAR2_TABLE_500
    , p0_a20 JTF_VARCHAR2_TABLE_500
    , p0_a21 JTF_VARCHAR2_TABLE_500
    , p0_a22 JTF_VARCHAR2_TABLE_500
    , p0_a23 JTF_NUMBER_TABLE
    , p0_a24 JTF_NUMBER_TABLE
    , p0_a25 JTF_NUMBER_TABLE
    , p0_a26 JTF_DATE_TABLE
    , p0_a27 JTF_DATE_TABLE
    , p0_a28 JTF_NUMBER_TABLE
  )

  as
    ddp_srsv_tbl okl_srs_pvt.srsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    okl_srs_pvt_w.rosetta_table_copy_in_p5(ddp_srsv_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.insert_row_upg(ddp_srsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
  end;

  procedure insert_row_per(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
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
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddx_srsv_rec okl_srs_pvt.srsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_srsv_rec.stream_type_name := p5_a1;
    ddp_srsv_rec.index_number := rosetta_g_miss_num_map(p5_a2);
    ddp_srsv_rec.activity_type := p5_a3;
    ddp_srsv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_srsv_rec.sre_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_srsv_rec.amount := rosetta_g_miss_num_map(p5_a6);
    ddp_srsv_rec.sir_id := rosetta_g_miss_num_map(p5_a7);
    ddp_srsv_rec.stream_interface_attribute01 := p5_a8;
    ddp_srsv_rec.stream_interface_attribute02 := p5_a9;
    ddp_srsv_rec.stream_interface_attribute03 := p5_a10;
    ddp_srsv_rec.stream_interface_attribute04 := p5_a11;
    ddp_srsv_rec.stream_interface_attribute05 := p5_a12;
    ddp_srsv_rec.stream_interface_attribute06 := p5_a13;
    ddp_srsv_rec.stream_interface_attribute07 := p5_a14;
    ddp_srsv_rec.stream_interface_attribute08 := p5_a15;
    ddp_srsv_rec.stream_interface_attribute09 := p5_a16;
    ddp_srsv_rec.stream_interface_attribute10 := p5_a17;
    ddp_srsv_rec.stream_interface_attribute11 := p5_a18;
    ddp_srsv_rec.stream_interface_attribute12 := p5_a19;
    ddp_srsv_rec.stream_interface_attribute13 := p5_a20;
    ddp_srsv_rec.stream_interface_attribute14 := p5_a21;
    ddp_srsv_rec.stream_interface_attribute15 := p5_a22;
    ddp_srsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_srsv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_srsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_srsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_srsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_srsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);


    -- here's the delegated call to the old PL/SQL routine
    okl_srs_pvt.insert_row_per(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srsv_rec,
      ddx_srsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_srsv_rec.id);
    p6_a1 := ddx_srsv_rec.stream_type_name;
    p6_a2 := rosetta_g_miss_num_map(ddx_srsv_rec.index_number);
    p6_a3 := ddx_srsv_rec.activity_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_srsv_rec.sequence_number);
    p6_a5 := ddx_srsv_rec.sre_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_srsv_rec.amount);
    p6_a7 := rosetta_g_miss_num_map(ddx_srsv_rec.sir_id);
    p6_a8 := ddx_srsv_rec.stream_interface_attribute01;
    p6_a9 := ddx_srsv_rec.stream_interface_attribute02;
    p6_a10 := ddx_srsv_rec.stream_interface_attribute03;
    p6_a11 := ddx_srsv_rec.stream_interface_attribute04;
    p6_a12 := ddx_srsv_rec.stream_interface_attribute05;
    p6_a13 := ddx_srsv_rec.stream_interface_attribute06;
    p6_a14 := ddx_srsv_rec.stream_interface_attribute07;
    p6_a15 := ddx_srsv_rec.stream_interface_attribute08;
    p6_a16 := ddx_srsv_rec.stream_interface_attribute09;
    p6_a17 := ddx_srsv_rec.stream_interface_attribute10;
    p6_a18 := ddx_srsv_rec.stream_interface_attribute11;
    p6_a19 := ddx_srsv_rec.stream_interface_attribute12;
    p6_a20 := ddx_srsv_rec.stream_interface_attribute13;
    p6_a21 := ddx_srsv_rec.stream_interface_attribute14;
    p6_a22 := ddx_srsv_rec.stream_interface_attribute15;
    p6_a23 := rosetta_g_miss_num_map(ddx_srsv_rec.object_version_number);
    p6_a24 := rosetta_g_miss_num_map(ddx_srsv_rec.created_by);
    p6_a25 := rosetta_g_miss_num_map(ddx_srsv_rec.last_updated_by);
    p6_a26 := ddx_srsv_rec.creation_date;
    p6_a27 := ddx_srsv_rec.last_update_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_srsv_rec.last_update_login);
  end;

end okl_srs_pvt_w;

/
