--------------------------------------------------------
--  DDL for Package Body OKL_CLM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CLM_PVT_W" as
  /* $Header: OKLICLMB.pls 115.2 2003/05/26 07:45:50 arajagop noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_clm_pvt.clmv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
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
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_NUMBER_TABLE
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
          t(ddindx).ipy_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).ltp_code := a4(indx);
          t(ddindx).csu_code := a5(indx);
          t(ddindx).claim_number := a6(indx);
          t(ddindx).claim_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).loss_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).description := a9(indx);
          t(ddindx).police_contact := a10(indx);
          t(ddindx).police_report := a11(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a12(indx));
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
          t(ddindx).hold_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a39(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_clm_pvt.clmv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
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
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
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
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).ipy_id);
          a4(indx) := t(ddindx).ltp_code;
          a5(indx) := t(ddindx).csu_code;
          a6(indx) := t(ddindx).claim_number;
          a7(indx) := t(ddindx).claim_date;
          a8(indx) := t(ddindx).loss_date;
          a9(indx) := t(ddindx).description;
          a10(indx) := t(ddindx).police_contact;
          a11(indx) := t(ddindx).police_report;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
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
          a29(indx) := t(ddindx).hold_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a34(indx) := t(ddindx).program_update_date;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a36(indx) := t(ddindx).creation_date;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a38(indx) := t(ddindx).last_update_date;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_clm_pvt.clm_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).claim_number := a1(indx);
          t(ddindx).csu_code := a2(indx);
          t(ddindx).ipy_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).ltp_code := a4(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).claim_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).loss_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).police_contact := a9(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).attribute_category := a14(indx);
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
          t(ddindx).hold_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a36(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_clm_pvt.clm_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
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
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
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
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).claim_number;
          a2(indx) := t(ddindx).csu_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).ipy_id);
          a4(indx) := t(ddindx).ltp_code;
          a5(indx) := t(ddindx).program_update_date;
          a6(indx) := t(ddindx).claim_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).loss_date;
          a9(indx) := t(ddindx).police_contact;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a14(indx) := t(ddindx).attribute_category;
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
          a30(indx) := t(ddindx).hold_date;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a33(indx) := t(ddindx).creation_date;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a35(indx) := t(ddindx).last_update_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_clm_pvt.okl_ins_claims_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
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
          t(ddindx).description := a2(indx);
          t(ddindx).police_report := a3(indx);
          t(ddindx).comments := a4(indx);
          t(ddindx).source_lang := a5(indx);
          t(ddindx).sfwt_flag := a6(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_clm_pvt.okl_ins_claims_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).police_report;
          a4(indx) := t(ddindx).comments;
          a5(indx) := t(ddindx).source_lang;
          a6(indx) := t(ddindx).sfwt_flag;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := t(ddindx).last_update_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
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
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddx_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clmv_rec.sfwt_flag := p5_a2;
    ddp_clmv_rec.ipy_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clmv_rec.ltp_code := p5_a4;
    ddp_clmv_rec.csu_code := p5_a5;
    ddp_clmv_rec.claim_number := p5_a6;
    ddp_clmv_rec.claim_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clmv_rec.loss_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_clmv_rec.description := p5_a9;
    ddp_clmv_rec.police_contact := p5_a10;
    ddp_clmv_rec.police_report := p5_a11;
    ddp_clmv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_clmv_rec.attribute_category := p5_a13;
    ddp_clmv_rec.attribute1 := p5_a14;
    ddp_clmv_rec.attribute2 := p5_a15;
    ddp_clmv_rec.attribute3 := p5_a16;
    ddp_clmv_rec.attribute4 := p5_a17;
    ddp_clmv_rec.attribute5 := p5_a18;
    ddp_clmv_rec.attribute6 := p5_a19;
    ddp_clmv_rec.attribute7 := p5_a20;
    ddp_clmv_rec.attribute8 := p5_a21;
    ddp_clmv_rec.attribute9 := p5_a22;
    ddp_clmv_rec.attribute10 := p5_a23;
    ddp_clmv_rec.attribute11 := p5_a24;
    ddp_clmv_rec.attribute12 := p5_a25;
    ddp_clmv_rec.attribute13 := p5_a26;
    ddp_clmv_rec.attribute14 := p5_a27;
    ddp_clmv_rec.attribute15 := p5_a28;
    ddp_clmv_rec.hold_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clmv_rec.org_id := rosetta_g_miss_num_map(p5_a30);
    ddp_clmv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_clmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_clmv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_clmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_clmv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_clmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_clmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_clmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_rec,
      ddx_clmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_clmv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_clmv_rec.object_version_number);
    p6_a2 := ddx_clmv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_clmv_rec.ipy_id);
    p6_a4 := ddx_clmv_rec.ltp_code;
    p6_a5 := ddx_clmv_rec.csu_code;
    p6_a6 := ddx_clmv_rec.claim_number;
    p6_a7 := ddx_clmv_rec.claim_date;
    p6_a8 := ddx_clmv_rec.loss_date;
    p6_a9 := ddx_clmv_rec.description;
    p6_a10 := ddx_clmv_rec.police_contact;
    p6_a11 := ddx_clmv_rec.police_report;
    p6_a12 := rosetta_g_miss_num_map(ddx_clmv_rec.amount);
    p6_a13 := ddx_clmv_rec.attribute_category;
    p6_a14 := ddx_clmv_rec.attribute1;
    p6_a15 := ddx_clmv_rec.attribute2;
    p6_a16 := ddx_clmv_rec.attribute3;
    p6_a17 := ddx_clmv_rec.attribute4;
    p6_a18 := ddx_clmv_rec.attribute5;
    p6_a19 := ddx_clmv_rec.attribute6;
    p6_a20 := ddx_clmv_rec.attribute7;
    p6_a21 := ddx_clmv_rec.attribute8;
    p6_a22 := ddx_clmv_rec.attribute9;
    p6_a23 := ddx_clmv_rec.attribute10;
    p6_a24 := ddx_clmv_rec.attribute11;
    p6_a25 := ddx_clmv_rec.attribute12;
    p6_a26 := ddx_clmv_rec.attribute13;
    p6_a27 := ddx_clmv_rec.attribute14;
    p6_a28 := ddx_clmv_rec.attribute15;
    p6_a29 := ddx_clmv_rec.hold_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_clmv_rec.org_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_clmv_rec.request_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_clmv_rec.program_application_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_clmv_rec.program_id);
    p6_a34 := ddx_clmv_rec.program_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_clmv_rec.created_by);
    p6_a36 := ddx_clmv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_clmv_rec.last_updated_by);
    p6_a38 := ddx_clmv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_clmv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddx_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_in_p2(ddp_clmv_tbl, p5_a0
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
      , p5_a38
      , p5_a39
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_tbl,
      ddx_clmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_clm_pvt_w.rosetta_table_copy_out_p2(ddx_clmv_tbl, p6_a0
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
      , p6_a38
      , p6_a39
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
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clmv_rec.sfwt_flag := p5_a2;
    ddp_clmv_rec.ipy_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clmv_rec.ltp_code := p5_a4;
    ddp_clmv_rec.csu_code := p5_a5;
    ddp_clmv_rec.claim_number := p5_a6;
    ddp_clmv_rec.claim_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clmv_rec.loss_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_clmv_rec.description := p5_a9;
    ddp_clmv_rec.police_contact := p5_a10;
    ddp_clmv_rec.police_report := p5_a11;
    ddp_clmv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_clmv_rec.attribute_category := p5_a13;
    ddp_clmv_rec.attribute1 := p5_a14;
    ddp_clmv_rec.attribute2 := p5_a15;
    ddp_clmv_rec.attribute3 := p5_a16;
    ddp_clmv_rec.attribute4 := p5_a17;
    ddp_clmv_rec.attribute5 := p5_a18;
    ddp_clmv_rec.attribute6 := p5_a19;
    ddp_clmv_rec.attribute7 := p5_a20;
    ddp_clmv_rec.attribute8 := p5_a21;
    ddp_clmv_rec.attribute9 := p5_a22;
    ddp_clmv_rec.attribute10 := p5_a23;
    ddp_clmv_rec.attribute11 := p5_a24;
    ddp_clmv_rec.attribute12 := p5_a25;
    ddp_clmv_rec.attribute13 := p5_a26;
    ddp_clmv_rec.attribute14 := p5_a27;
    ddp_clmv_rec.attribute15 := p5_a28;
    ddp_clmv_rec.hold_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clmv_rec.org_id := rosetta_g_miss_num_map(p5_a30);
    ddp_clmv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_clmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_clmv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_clmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_clmv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_clmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_clmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_clmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_in_p2(ddp_clmv_tbl, p5_a0
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
      , p5_a38
      , p5_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_tbl);

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
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddx_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clmv_rec.sfwt_flag := p5_a2;
    ddp_clmv_rec.ipy_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clmv_rec.ltp_code := p5_a4;
    ddp_clmv_rec.csu_code := p5_a5;
    ddp_clmv_rec.claim_number := p5_a6;
    ddp_clmv_rec.claim_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clmv_rec.loss_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_clmv_rec.description := p5_a9;
    ddp_clmv_rec.police_contact := p5_a10;
    ddp_clmv_rec.police_report := p5_a11;
    ddp_clmv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_clmv_rec.attribute_category := p5_a13;
    ddp_clmv_rec.attribute1 := p5_a14;
    ddp_clmv_rec.attribute2 := p5_a15;
    ddp_clmv_rec.attribute3 := p5_a16;
    ddp_clmv_rec.attribute4 := p5_a17;
    ddp_clmv_rec.attribute5 := p5_a18;
    ddp_clmv_rec.attribute6 := p5_a19;
    ddp_clmv_rec.attribute7 := p5_a20;
    ddp_clmv_rec.attribute8 := p5_a21;
    ddp_clmv_rec.attribute9 := p5_a22;
    ddp_clmv_rec.attribute10 := p5_a23;
    ddp_clmv_rec.attribute11 := p5_a24;
    ddp_clmv_rec.attribute12 := p5_a25;
    ddp_clmv_rec.attribute13 := p5_a26;
    ddp_clmv_rec.attribute14 := p5_a27;
    ddp_clmv_rec.attribute15 := p5_a28;
    ddp_clmv_rec.hold_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clmv_rec.org_id := rosetta_g_miss_num_map(p5_a30);
    ddp_clmv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_clmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_clmv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_clmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_clmv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_clmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_clmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_clmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_rec,
      ddx_clmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_clmv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_clmv_rec.object_version_number);
    p6_a2 := ddx_clmv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_clmv_rec.ipy_id);
    p6_a4 := ddx_clmv_rec.ltp_code;
    p6_a5 := ddx_clmv_rec.csu_code;
    p6_a6 := ddx_clmv_rec.claim_number;
    p6_a7 := ddx_clmv_rec.claim_date;
    p6_a8 := ddx_clmv_rec.loss_date;
    p6_a9 := ddx_clmv_rec.description;
    p6_a10 := ddx_clmv_rec.police_contact;
    p6_a11 := ddx_clmv_rec.police_report;
    p6_a12 := rosetta_g_miss_num_map(ddx_clmv_rec.amount);
    p6_a13 := ddx_clmv_rec.attribute_category;
    p6_a14 := ddx_clmv_rec.attribute1;
    p6_a15 := ddx_clmv_rec.attribute2;
    p6_a16 := ddx_clmv_rec.attribute3;
    p6_a17 := ddx_clmv_rec.attribute4;
    p6_a18 := ddx_clmv_rec.attribute5;
    p6_a19 := ddx_clmv_rec.attribute6;
    p6_a20 := ddx_clmv_rec.attribute7;
    p6_a21 := ddx_clmv_rec.attribute8;
    p6_a22 := ddx_clmv_rec.attribute9;
    p6_a23 := ddx_clmv_rec.attribute10;
    p6_a24 := ddx_clmv_rec.attribute11;
    p6_a25 := ddx_clmv_rec.attribute12;
    p6_a26 := ddx_clmv_rec.attribute13;
    p6_a27 := ddx_clmv_rec.attribute14;
    p6_a28 := ddx_clmv_rec.attribute15;
    p6_a29 := ddx_clmv_rec.hold_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_clmv_rec.org_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_clmv_rec.request_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_clmv_rec.program_application_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_clmv_rec.program_id);
    p6_a34 := ddx_clmv_rec.program_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_clmv_rec.created_by);
    p6_a36 := ddx_clmv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_clmv_rec.last_updated_by);
    p6_a38 := ddx_clmv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_clmv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddx_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_in_p2(ddp_clmv_tbl, p5_a0
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
      , p5_a38
      , p5_a39
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_tbl,
      ddx_clmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_clm_pvt_w.rosetta_table_copy_out_p2(ddx_clmv_tbl, p6_a0
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
      , p6_a38
      , p6_a39
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
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clmv_rec.sfwt_flag := p5_a2;
    ddp_clmv_rec.ipy_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clmv_rec.ltp_code := p5_a4;
    ddp_clmv_rec.csu_code := p5_a5;
    ddp_clmv_rec.claim_number := p5_a6;
    ddp_clmv_rec.claim_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clmv_rec.loss_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_clmv_rec.description := p5_a9;
    ddp_clmv_rec.police_contact := p5_a10;
    ddp_clmv_rec.police_report := p5_a11;
    ddp_clmv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_clmv_rec.attribute_category := p5_a13;
    ddp_clmv_rec.attribute1 := p5_a14;
    ddp_clmv_rec.attribute2 := p5_a15;
    ddp_clmv_rec.attribute3 := p5_a16;
    ddp_clmv_rec.attribute4 := p5_a17;
    ddp_clmv_rec.attribute5 := p5_a18;
    ddp_clmv_rec.attribute6 := p5_a19;
    ddp_clmv_rec.attribute7 := p5_a20;
    ddp_clmv_rec.attribute8 := p5_a21;
    ddp_clmv_rec.attribute9 := p5_a22;
    ddp_clmv_rec.attribute10 := p5_a23;
    ddp_clmv_rec.attribute11 := p5_a24;
    ddp_clmv_rec.attribute12 := p5_a25;
    ddp_clmv_rec.attribute13 := p5_a26;
    ddp_clmv_rec.attribute14 := p5_a27;
    ddp_clmv_rec.attribute15 := p5_a28;
    ddp_clmv_rec.hold_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clmv_rec.org_id := rosetta_g_miss_num_map(p5_a30);
    ddp_clmv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_clmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_clmv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_clmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_clmv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_clmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_clmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_clmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_in_p2(ddp_clmv_tbl, p5_a0
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
      , p5_a38
      , p5_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_tbl);

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
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clmv_rec okl_clm_pvt.clmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clmv_rec.sfwt_flag := p5_a2;
    ddp_clmv_rec.ipy_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clmv_rec.ltp_code := p5_a4;
    ddp_clmv_rec.csu_code := p5_a5;
    ddp_clmv_rec.claim_number := p5_a6;
    ddp_clmv_rec.claim_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clmv_rec.loss_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_clmv_rec.description := p5_a9;
    ddp_clmv_rec.police_contact := p5_a10;
    ddp_clmv_rec.police_report := p5_a11;
    ddp_clmv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_clmv_rec.attribute_category := p5_a13;
    ddp_clmv_rec.attribute1 := p5_a14;
    ddp_clmv_rec.attribute2 := p5_a15;
    ddp_clmv_rec.attribute3 := p5_a16;
    ddp_clmv_rec.attribute4 := p5_a17;
    ddp_clmv_rec.attribute5 := p5_a18;
    ddp_clmv_rec.attribute6 := p5_a19;
    ddp_clmv_rec.attribute7 := p5_a20;
    ddp_clmv_rec.attribute8 := p5_a21;
    ddp_clmv_rec.attribute9 := p5_a22;
    ddp_clmv_rec.attribute10 := p5_a23;
    ddp_clmv_rec.attribute11 := p5_a24;
    ddp_clmv_rec.attribute12 := p5_a25;
    ddp_clmv_rec.attribute13 := p5_a26;
    ddp_clmv_rec.attribute14 := p5_a27;
    ddp_clmv_rec.attribute15 := p5_a28;
    ddp_clmv_rec.hold_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clmv_rec.org_id := rosetta_g_miss_num_map(p5_a30);
    ddp_clmv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_clmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_clmv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_clmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_clmv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_clmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_clmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_clmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_clmv_tbl okl_clm_pvt.clmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_in_p2(ddp_clmv_tbl, p5_a0
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
      , p5_a38
      , p5_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_clm_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_clm_pvt_w;

/
