--------------------------------------------------------
--  DDL for Package Body OKL_LRV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LRV_PVT_W" as
  /* $Header: OKLILRVB.pls 120.1 2005/09/30 11:00:31 asawanka noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_lrv_pvt.okl_lrvv_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_500
    , a37 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate_set_version_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).arrears_yn := a2(indx);
          t(ddindx).effective_from_date := a3(indx);
          t(ddindx).effective_to_date := a4(indx);
          t(ddindx).rate_set_id := a5(indx);
          t(ddindx).end_of_term_ver_id := a6(indx);
          t(ddindx).std_rate_tmpl_ver_id := a7(indx);
          t(ddindx).adj_mat_version_id := a8(indx);
          t(ddindx).version_number := a9(indx);
          t(ddindx).lrs_rate := a10(indx);
          t(ddindx).rate_tolerance := a11(indx);
          t(ddindx).residual_tolerance := a12(indx);
          t(ddindx).deferred_pmts := a13(indx);
          t(ddindx).advance_pmts := a14(indx);
          t(ddindx).sts_code := a15(indx);
          t(ddindx).created_by := a16(indx);
          t(ddindx).creation_date := a17(indx);
          t(ddindx).last_updated_by := a18(indx);
          t(ddindx).last_update_date := a19(indx);
          t(ddindx).last_update_login := a20(indx);
          t(ddindx).attribute_category := a21(indx);
          t(ddindx).attribute1 := a22(indx);
          t(ddindx).attribute2 := a23(indx);
          t(ddindx).attribute3 := a24(indx);
          t(ddindx).attribute4 := a25(indx);
          t(ddindx).attribute5 := a26(indx);
          t(ddindx).attribute6 := a27(indx);
          t(ddindx).attribute7 := a28(indx);
          t(ddindx).attribute8 := a29(indx);
          t(ddindx).attribute9 := a30(indx);
          t(ddindx).attribute10 := a31(indx);
          t(ddindx).attribute11 := a32(indx);
          t(ddindx).attribute12 := a33(indx);
          t(ddindx).attribute13 := a34(indx);
          t(ddindx).attribute14 := a35(indx);
          t(ddindx).attribute15 := a36(indx);
          t(ddindx).standard_rate := a37(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_lrv_pvt.okl_lrvv_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_500
    , a37 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_500();
    a37 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_500();
      a37 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rate_set_version_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).arrears_yn;
          a3(indx) := t(ddindx).effective_from_date;
          a4(indx) := t(ddindx).effective_to_date;
          a5(indx) := t(ddindx).rate_set_id;
          a6(indx) := t(ddindx).end_of_term_ver_id;
          a7(indx) := t(ddindx).std_rate_tmpl_ver_id;
          a8(indx) := t(ddindx).adj_mat_version_id;
          a9(indx) := t(ddindx).version_number;
          a10(indx) := t(ddindx).lrs_rate;
          a11(indx) := t(ddindx).rate_tolerance;
          a12(indx) := t(ddindx).residual_tolerance;
          a13(indx) := t(ddindx).deferred_pmts;
          a14(indx) := t(ddindx).advance_pmts;
          a15(indx) := t(ddindx).sts_code;
          a16(indx) := t(ddindx).created_by;
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).last_updated_by;
          a19(indx) := t(ddindx).last_update_date;
          a20(indx) := t(ddindx).last_update_login;
          a21(indx) := t(ddindx).attribute_category;
          a22(indx) := t(ddindx).attribute1;
          a23(indx) := t(ddindx).attribute2;
          a24(indx) := t(ddindx).attribute3;
          a25(indx) := t(ddindx).attribute4;
          a26(indx) := t(ddindx).attribute5;
          a27(indx) := t(ddindx).attribute6;
          a28(indx) := t(ddindx).attribute7;
          a29(indx) := t(ddindx).attribute8;
          a30(indx) := t(ddindx).attribute9;
          a31(indx) := t(ddindx).attribute10;
          a32(indx) := t(ddindx).attribute11;
          a33(indx) := t(ddindx).attribute12;
          a34(indx) := t(ddindx).attribute13;
          a35(indx) := t(ddindx).attribute14;
          a36(indx) := t(ddindx).attribute15;
          a37(indx) := t(ddindx).standard_rate;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_lrv_pvt.okl_lrv_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_500
    , a37 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate_set_version_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).arrears_yn := a2(indx);
          t(ddindx).effective_from_date := a3(indx);
          t(ddindx).effective_to_date := a4(indx);
          t(ddindx).rate_set_id := a5(indx);
          t(ddindx).end_of_term_ver_id := a6(indx);
          t(ddindx).std_rate_tmpl_ver_id := a7(indx);
          t(ddindx).adj_mat_version_id := a8(indx);
          t(ddindx).version_number := a9(indx);
          t(ddindx).lrs_rate := a10(indx);
          t(ddindx).rate_tolerance := a11(indx);
          t(ddindx).residual_tolerance := a12(indx);
          t(ddindx).deferred_pmts := a13(indx);
          t(ddindx).advance_pmts := a14(indx);
          t(ddindx).sts_code := a15(indx);
          t(ddindx).created_by := a16(indx);
          t(ddindx).creation_date := a17(indx);
          t(ddindx).last_updated_by := a18(indx);
          t(ddindx).last_update_date := a19(indx);
          t(ddindx).last_update_login := a20(indx);
          t(ddindx).attribute_category := a21(indx);
          t(ddindx).attribute1 := a22(indx);
          t(ddindx).attribute2 := a23(indx);
          t(ddindx).attribute3 := a24(indx);
          t(ddindx).attribute4 := a25(indx);
          t(ddindx).attribute5 := a26(indx);
          t(ddindx).attribute6 := a27(indx);
          t(ddindx).attribute7 := a28(indx);
          t(ddindx).attribute8 := a29(indx);
          t(ddindx).attribute9 := a30(indx);
          t(ddindx).attribute10 := a31(indx);
          t(ddindx).attribute11 := a32(indx);
          t(ddindx).attribute12 := a33(indx);
          t(ddindx).attribute13 := a34(indx);
          t(ddindx).attribute14 := a35(indx);
          t(ddindx).attribute15 := a36(indx);
          t(ddindx).standard_rate := a37(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_lrv_pvt.okl_lrv_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_500
    , a37 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_500();
    a37 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_500();
      a37 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rate_set_version_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).arrears_yn;
          a3(indx) := t(ddindx).effective_from_date;
          a4(indx) := t(ddindx).effective_to_date;
          a5(indx) := t(ddindx).rate_set_id;
          a6(indx) := t(ddindx).end_of_term_ver_id;
          a7(indx) := t(ddindx).std_rate_tmpl_ver_id;
          a8(indx) := t(ddindx).adj_mat_version_id;
          a9(indx) := t(ddindx).version_number;
          a10(indx) := t(ddindx).lrs_rate;
          a11(indx) := t(ddindx).rate_tolerance;
          a12(indx) := t(ddindx).residual_tolerance;
          a13(indx) := t(ddindx).deferred_pmts;
          a14(indx) := t(ddindx).advance_pmts;
          a15(indx) := t(ddindx).sts_code;
          a16(indx) := t(ddindx).created_by;
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).last_updated_by;
          a19(indx) := t(ddindx).last_update_date;
          a20(indx) := t(ddindx).last_update_login;
          a21(indx) := t(ddindx).attribute_category;
          a22(indx) := t(ddindx).attribute1;
          a23(indx) := t(ddindx).attribute2;
          a24(indx) := t(ddindx).attribute3;
          a25(indx) := t(ddindx).attribute4;
          a26(indx) := t(ddindx).attribute5;
          a27(indx) := t(ddindx).attribute6;
          a28(indx) := t(ddindx).attribute7;
          a29(indx) := t(ddindx).attribute8;
          a30(indx) := t(ddindx).attribute9;
          a31(indx) := t(ddindx).attribute10;
          a32(indx) := t(ddindx).attribute11;
          a33(indx) := t(ddindx).attribute12;
          a34(indx) := t(ddindx).attribute13;
          a35(indx) := t(ddindx).attribute14;
          a36(indx) := t(ddindx).attribute15;
          a37(indx) := t(ddindx).standard_rate;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
  )

  as
    ddp_lrvv_rec okl_lrv_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lrv_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrvv_rec.rate_set_version_id := p5_a0;
    ddp_lrvv_rec.object_version_number := p5_a1;
    ddp_lrvv_rec.arrears_yn := p5_a2;
    ddp_lrvv_rec.effective_from_date := p5_a3;
    ddp_lrvv_rec.effective_to_date := p5_a4;
    ddp_lrvv_rec.rate_set_id := p5_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p5_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p5_a7;
    ddp_lrvv_rec.adj_mat_version_id := p5_a8;
    ddp_lrvv_rec.version_number := p5_a9;
    ddp_lrvv_rec.lrs_rate := p5_a10;
    ddp_lrvv_rec.rate_tolerance := p5_a11;
    ddp_lrvv_rec.residual_tolerance := p5_a12;
    ddp_lrvv_rec.deferred_pmts := p5_a13;
    ddp_lrvv_rec.advance_pmts := p5_a14;
    ddp_lrvv_rec.sts_code := p5_a15;
    ddp_lrvv_rec.created_by := p5_a16;
    ddp_lrvv_rec.creation_date := p5_a17;
    ddp_lrvv_rec.last_updated_by := p5_a18;
    ddp_lrvv_rec.last_update_date := p5_a19;
    ddp_lrvv_rec.last_update_login := p5_a20;
    ddp_lrvv_rec.attribute_category := p5_a21;
    ddp_lrvv_rec.attribute1 := p5_a22;
    ddp_lrvv_rec.attribute2 := p5_a23;
    ddp_lrvv_rec.attribute3 := p5_a24;
    ddp_lrvv_rec.attribute4 := p5_a25;
    ddp_lrvv_rec.attribute5 := p5_a26;
    ddp_lrvv_rec.attribute6 := p5_a27;
    ddp_lrvv_rec.attribute7 := p5_a28;
    ddp_lrvv_rec.attribute8 := p5_a29;
    ddp_lrvv_rec.attribute9 := p5_a30;
    ddp_lrvv_rec.attribute10 := p5_a31;
    ddp_lrvv_rec.attribute11 := p5_a32;
    ddp_lrvv_rec.attribute12 := p5_a33;
    ddp_lrvv_rec.attribute13 := p5_a34;
    ddp_lrvv_rec.attribute14 := p5_a35;
    ddp_lrvv_rec.attribute15 := p5_a36;
    ddp_lrvv_rec.standard_rate := p5_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lrv_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrvv_rec.rate_set_version_id;
    p6_a1 := ddx_lrvv_rec.object_version_number;
    p6_a2 := ddx_lrvv_rec.arrears_yn;
    p6_a3 := ddx_lrvv_rec.effective_from_date;
    p6_a4 := ddx_lrvv_rec.effective_to_date;
    p6_a5 := ddx_lrvv_rec.rate_set_id;
    p6_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p6_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p6_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p6_a9 := ddx_lrvv_rec.version_number;
    p6_a10 := ddx_lrvv_rec.lrs_rate;
    p6_a11 := ddx_lrvv_rec.rate_tolerance;
    p6_a12 := ddx_lrvv_rec.residual_tolerance;
    p6_a13 := ddx_lrvv_rec.deferred_pmts;
    p6_a14 := ddx_lrvv_rec.advance_pmts;
    p6_a15 := ddx_lrvv_rec.sts_code;
    p6_a16 := ddx_lrvv_rec.created_by;
    p6_a17 := ddx_lrvv_rec.creation_date;
    p6_a18 := ddx_lrvv_rec.last_updated_by;
    p6_a19 := ddx_lrvv_rec.last_update_date;
    p6_a20 := ddx_lrvv_rec.last_update_login;
    p6_a21 := ddx_lrvv_rec.attribute_category;
    p6_a22 := ddx_lrvv_rec.attribute1;
    p6_a23 := ddx_lrvv_rec.attribute2;
    p6_a24 := ddx_lrvv_rec.attribute3;
    p6_a25 := ddx_lrvv_rec.attribute4;
    p6_a26 := ddx_lrvv_rec.attribute5;
    p6_a27 := ddx_lrvv_rec.attribute6;
    p6_a28 := ddx_lrvv_rec.attribute7;
    p6_a29 := ddx_lrvv_rec.attribute8;
    p6_a30 := ddx_lrvv_rec.attribute9;
    p6_a31 := ddx_lrvv_rec.attribute10;
    p6_a32 := ddx_lrvv_rec.attribute11;
    p6_a33 := ddx_lrvv_rec.attribute12;
    p6_a34 := ddx_lrvv_rec.attribute13;
    p6_a35 := ddx_lrvv_rec.attribute14;
    p6_a36 := ddx_lrvv_rec.attribute15;
    p6_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_lrvv_tbl okl_lrv_pvt.okl_lrvv_tbl;
    ddx_lrvv_tbl okl_lrv_pvt.okl_lrvv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lrv_pvt_w.rosetta_table_copy_in_p1(ddp_lrvv_tbl, p5_a0
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
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lrv_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrvv_tbl,
      ddx_lrvv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lrv_pvt_w.rosetta_table_copy_out_p1(ddx_lrvv_tbl, p6_a0
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
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
  )

  as
    ddp_lrvv_rec okl_lrv_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lrv_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrvv_rec.rate_set_version_id := p5_a0;
    ddp_lrvv_rec.object_version_number := p5_a1;
    ddp_lrvv_rec.arrears_yn := p5_a2;
    ddp_lrvv_rec.effective_from_date := p5_a3;
    ddp_lrvv_rec.effective_to_date := p5_a4;
    ddp_lrvv_rec.rate_set_id := p5_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p5_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p5_a7;
    ddp_lrvv_rec.adj_mat_version_id := p5_a8;
    ddp_lrvv_rec.version_number := p5_a9;
    ddp_lrvv_rec.lrs_rate := p5_a10;
    ddp_lrvv_rec.rate_tolerance := p5_a11;
    ddp_lrvv_rec.residual_tolerance := p5_a12;
    ddp_lrvv_rec.deferred_pmts := p5_a13;
    ddp_lrvv_rec.advance_pmts := p5_a14;
    ddp_lrvv_rec.sts_code := p5_a15;
    ddp_lrvv_rec.created_by := p5_a16;
    ddp_lrvv_rec.creation_date := p5_a17;
    ddp_lrvv_rec.last_updated_by := p5_a18;
    ddp_lrvv_rec.last_update_date := p5_a19;
    ddp_lrvv_rec.last_update_login := p5_a20;
    ddp_lrvv_rec.attribute_category := p5_a21;
    ddp_lrvv_rec.attribute1 := p5_a22;
    ddp_lrvv_rec.attribute2 := p5_a23;
    ddp_lrvv_rec.attribute3 := p5_a24;
    ddp_lrvv_rec.attribute4 := p5_a25;
    ddp_lrvv_rec.attribute5 := p5_a26;
    ddp_lrvv_rec.attribute6 := p5_a27;
    ddp_lrvv_rec.attribute7 := p5_a28;
    ddp_lrvv_rec.attribute8 := p5_a29;
    ddp_lrvv_rec.attribute9 := p5_a30;
    ddp_lrvv_rec.attribute10 := p5_a31;
    ddp_lrvv_rec.attribute11 := p5_a32;
    ddp_lrvv_rec.attribute12 := p5_a33;
    ddp_lrvv_rec.attribute13 := p5_a34;
    ddp_lrvv_rec.attribute14 := p5_a35;
    ddp_lrvv_rec.attribute15 := p5_a36;
    ddp_lrvv_rec.standard_rate := p5_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lrv_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrvv_rec.rate_set_version_id;
    p6_a1 := ddx_lrvv_rec.object_version_number;
    p6_a2 := ddx_lrvv_rec.arrears_yn;
    p6_a3 := ddx_lrvv_rec.effective_from_date;
    p6_a4 := ddx_lrvv_rec.effective_to_date;
    p6_a5 := ddx_lrvv_rec.rate_set_id;
    p6_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p6_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p6_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p6_a9 := ddx_lrvv_rec.version_number;
    p6_a10 := ddx_lrvv_rec.lrs_rate;
    p6_a11 := ddx_lrvv_rec.rate_tolerance;
    p6_a12 := ddx_lrvv_rec.residual_tolerance;
    p6_a13 := ddx_lrvv_rec.deferred_pmts;
    p6_a14 := ddx_lrvv_rec.advance_pmts;
    p6_a15 := ddx_lrvv_rec.sts_code;
    p6_a16 := ddx_lrvv_rec.created_by;
    p6_a17 := ddx_lrvv_rec.creation_date;
    p6_a18 := ddx_lrvv_rec.last_updated_by;
    p6_a19 := ddx_lrvv_rec.last_update_date;
    p6_a20 := ddx_lrvv_rec.last_update_login;
    p6_a21 := ddx_lrvv_rec.attribute_category;
    p6_a22 := ddx_lrvv_rec.attribute1;
    p6_a23 := ddx_lrvv_rec.attribute2;
    p6_a24 := ddx_lrvv_rec.attribute3;
    p6_a25 := ddx_lrvv_rec.attribute4;
    p6_a26 := ddx_lrvv_rec.attribute5;
    p6_a27 := ddx_lrvv_rec.attribute6;
    p6_a28 := ddx_lrvv_rec.attribute7;
    p6_a29 := ddx_lrvv_rec.attribute8;
    p6_a30 := ddx_lrvv_rec.attribute9;
    p6_a31 := ddx_lrvv_rec.attribute10;
    p6_a32 := ddx_lrvv_rec.attribute11;
    p6_a33 := ddx_lrvv_rec.attribute12;
    p6_a34 := ddx_lrvv_rec.attribute13;
    p6_a35 := ddx_lrvv_rec.attribute14;
    p6_a36 := ddx_lrvv_rec.attribute15;
    p6_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_lrvv_tbl okl_lrv_pvt.okl_lrvv_tbl;
    ddx_lrvv_tbl okl_lrv_pvt.okl_lrvv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lrv_pvt_w.rosetta_table_copy_in_p1(ddp_lrvv_tbl, p5_a0
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
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lrv_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrvv_tbl,
      ddx_lrvv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lrv_pvt_w.rosetta_table_copy_out_p1(ddx_lrvv_tbl, p6_a0
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
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
  )

  as
    ddp_lrvv_rec okl_lrv_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrvv_rec.rate_set_version_id := p5_a0;
    ddp_lrvv_rec.object_version_number := p5_a1;
    ddp_lrvv_rec.arrears_yn := p5_a2;
    ddp_lrvv_rec.effective_from_date := p5_a3;
    ddp_lrvv_rec.effective_to_date := p5_a4;
    ddp_lrvv_rec.rate_set_id := p5_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p5_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p5_a7;
    ddp_lrvv_rec.adj_mat_version_id := p5_a8;
    ddp_lrvv_rec.version_number := p5_a9;
    ddp_lrvv_rec.lrs_rate := p5_a10;
    ddp_lrvv_rec.rate_tolerance := p5_a11;
    ddp_lrvv_rec.residual_tolerance := p5_a12;
    ddp_lrvv_rec.deferred_pmts := p5_a13;
    ddp_lrvv_rec.advance_pmts := p5_a14;
    ddp_lrvv_rec.sts_code := p5_a15;
    ddp_lrvv_rec.created_by := p5_a16;
    ddp_lrvv_rec.creation_date := p5_a17;
    ddp_lrvv_rec.last_updated_by := p5_a18;
    ddp_lrvv_rec.last_update_date := p5_a19;
    ddp_lrvv_rec.last_update_login := p5_a20;
    ddp_lrvv_rec.attribute_category := p5_a21;
    ddp_lrvv_rec.attribute1 := p5_a22;
    ddp_lrvv_rec.attribute2 := p5_a23;
    ddp_lrvv_rec.attribute3 := p5_a24;
    ddp_lrvv_rec.attribute4 := p5_a25;
    ddp_lrvv_rec.attribute5 := p5_a26;
    ddp_lrvv_rec.attribute6 := p5_a27;
    ddp_lrvv_rec.attribute7 := p5_a28;
    ddp_lrvv_rec.attribute8 := p5_a29;
    ddp_lrvv_rec.attribute9 := p5_a30;
    ddp_lrvv_rec.attribute10 := p5_a31;
    ddp_lrvv_rec.attribute11 := p5_a32;
    ddp_lrvv_rec.attribute12 := p5_a33;
    ddp_lrvv_rec.attribute13 := p5_a34;
    ddp_lrvv_rec.attribute14 := p5_a35;
    ddp_lrvv_rec.attribute15 := p5_a36;
    ddp_lrvv_rec.standard_rate := p5_a37;

    -- here's the delegated call to the old PL/SQL routine
    okl_lrv_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrvv_rec);

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
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_NUMBER_TABLE
  )

  as
    ddp_lrvv_tbl okl_lrv_pvt.okl_lrvv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lrv_pvt_w.rosetta_table_copy_in_p1(ddp_lrvv_tbl, p5_a0
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
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_lrv_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrvv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_lrv_pvt_w;

/
