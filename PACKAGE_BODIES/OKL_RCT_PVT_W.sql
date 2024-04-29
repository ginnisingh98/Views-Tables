--------------------------------------------------------
--  DDL for Package Body OKL_RCT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RCT_PVT_W" as
  /* $Header: OKLIRCTB.pls 120.0 2007/11/19 10:32:58 rviriyal noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_rct_pvt.rct_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_500
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
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).currency_code := a1(indx);
          t(ddindx).exchange_rate_type := a2(indx);
          t(ddindx).exchange_rate_date := a3(indx);
          t(ddindx).exchange_rate := a4(indx);
          t(ddindx).btc_id := a5(indx);
          t(ddindx).iba_id := a6(indx);
          t(ddindx).gl_date := a7(indx);
          t(ddindx).ile_id := a8(indx);
          t(ddindx).irm_id := a9(indx);
          t(ddindx).object_version_number := a10(indx);
          t(ddindx).check_number := a11(indx);
          t(ddindx).amount := a12(indx);
          t(ddindx).date_effective := a13(indx);
          t(ddindx).rcpt_status_code := a14(indx);
          t(ddindx).request_id := a15(indx);
          t(ddindx).program_application_id := a16(indx);
          t(ddindx).program_id := a17(indx);
          t(ddindx).program_update_date := a18(indx);
          t(ddindx).org_id := a19(indx);
          t(ddindx).attribute_category := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).created_by := a36(indx);
          t(ddindx).creation_date := a37(indx);
          t(ddindx).last_updated_by := a38(indx);
          t(ddindx).last_update_date := a39(indx);
          t(ddindx).last_update_login := a40(indx);
          t(ddindx).receipt_type := a41(indx);
          t(ddindx).cash_receipt_id := a42(indx);
          t(ddindx).fully_applied_flag := a43(indx);
          t(ddindx).expired_flag := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_rct_pvt.rct_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_500();
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
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_500();
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
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).currency_code;
          a2(indx) := t(ddindx).exchange_rate_type;
          a3(indx) := t(ddindx).exchange_rate_date;
          a4(indx) := t(ddindx).exchange_rate;
          a5(indx) := t(ddindx).btc_id;
          a6(indx) := t(ddindx).iba_id;
          a7(indx) := t(ddindx).gl_date;
          a8(indx) := t(ddindx).ile_id;
          a9(indx) := t(ddindx).irm_id;
          a10(indx) := t(ddindx).object_version_number;
          a11(indx) := t(ddindx).check_number;
          a12(indx) := t(ddindx).amount;
          a13(indx) := t(ddindx).date_effective;
          a14(indx) := t(ddindx).rcpt_status_code;
          a15(indx) := t(ddindx).request_id;
          a16(indx) := t(ddindx).program_application_id;
          a17(indx) := t(ddindx).program_id;
          a18(indx) := t(ddindx).program_update_date;
          a19(indx) := t(ddindx).org_id;
          a20(indx) := t(ddindx).attribute_category;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := t(ddindx).created_by;
          a37(indx) := t(ddindx).creation_date;
          a38(indx) := t(ddindx).last_updated_by;
          a39(indx) := t(ddindx).last_update_date;
          a40(indx) := t(ddindx).last_update_login;
          a41(indx) := t(ddindx).receipt_type;
          a42(indx) := t(ddindx).cash_receipt_id;
          a43(indx) := t(ddindx).fully_applied_flag;
          a44(indx) := t(ddindx).expired_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_rct_pvt.okltrxcshreceipttltbltype, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := a6(indx);
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := a8(indx);
          t(ddindx).last_update_login := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_rct_pvt.okltrxcshreceipttltbltype, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_rct_pvt.rctv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_100
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
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).btc_id := a3(indx);
          t(ddindx).iba_id := a4(indx);
          t(ddindx).gl_date := a5(indx);
          t(ddindx).ile_id := a6(indx);
          t(ddindx).irm_id := a7(indx);
          t(ddindx).check_number := a8(indx);
          t(ddindx).currency_code := a9(indx);
          t(ddindx).exchange_rate_type := a10(indx);
          t(ddindx).exchange_rate_date := a11(indx);
          t(ddindx).exchange_rate := a12(indx);
          t(ddindx).amount := a13(indx);
          t(ddindx).date_effective := a14(indx);
          t(ddindx).rcpt_status_code := a15(indx);
          t(ddindx).description := a16(indx);
          t(ddindx).attribute_category := a17(indx);
          t(ddindx).attribute1 := a18(indx);
          t(ddindx).attribute2 := a19(indx);
          t(ddindx).attribute3 := a20(indx);
          t(ddindx).attribute4 := a21(indx);
          t(ddindx).attribute5 := a22(indx);
          t(ddindx).attribute6 := a23(indx);
          t(ddindx).attribute7 := a24(indx);
          t(ddindx).attribute8 := a25(indx);
          t(ddindx).attribute9 := a26(indx);
          t(ddindx).attribute10 := a27(indx);
          t(ddindx).attribute11 := a28(indx);
          t(ddindx).attribute12 := a29(indx);
          t(ddindx).attribute13 := a30(indx);
          t(ddindx).attribute14 := a31(indx);
          t(ddindx).attribute15 := a32(indx);
          t(ddindx).request_id := a33(indx);
          t(ddindx).program_application_id := a34(indx);
          t(ddindx).program_id := a35(indx);
          t(ddindx).program_update_date := a36(indx);
          t(ddindx).org_id := a37(indx);
          t(ddindx).created_by := a38(indx);
          t(ddindx).creation_date := a39(indx);
          t(ddindx).last_updated_by := a40(indx);
          t(ddindx).last_update_date := a41(indx);
          t(ddindx).last_update_login := a42(indx);
          t(ddindx).receipt_type := a43(indx);
          t(ddindx).cash_receipt_id := a44(indx);
          t(ddindx).fully_applied_flag := a45(indx);
          t(ddindx).expired_flag := a46(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_rct_pvt.rctv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_VARCHAR2_TABLE_100();
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
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_VARCHAR2_TABLE_100();
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
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).btc_id;
          a4(indx) := t(ddindx).iba_id;
          a5(indx) := t(ddindx).gl_date;
          a6(indx) := t(ddindx).ile_id;
          a7(indx) := t(ddindx).irm_id;
          a8(indx) := t(ddindx).check_number;
          a9(indx) := t(ddindx).currency_code;
          a10(indx) := t(ddindx).exchange_rate_type;
          a11(indx) := t(ddindx).exchange_rate_date;
          a12(indx) := t(ddindx).exchange_rate;
          a13(indx) := t(ddindx).amount;
          a14(indx) := t(ddindx).date_effective;
          a15(indx) := t(ddindx).rcpt_status_code;
          a16(indx) := t(ddindx).description;
          a17(indx) := t(ddindx).attribute_category;
          a18(indx) := t(ddindx).attribute1;
          a19(indx) := t(ddindx).attribute2;
          a20(indx) := t(ddindx).attribute3;
          a21(indx) := t(ddindx).attribute4;
          a22(indx) := t(ddindx).attribute5;
          a23(indx) := t(ddindx).attribute6;
          a24(indx) := t(ddindx).attribute7;
          a25(indx) := t(ddindx).attribute8;
          a26(indx) := t(ddindx).attribute9;
          a27(indx) := t(ddindx).attribute10;
          a28(indx) := t(ddindx).attribute11;
          a29(indx) := t(ddindx).attribute12;
          a30(indx) := t(ddindx).attribute13;
          a31(indx) := t(ddindx).attribute14;
          a32(indx) := t(ddindx).attribute15;
          a33(indx) := t(ddindx).request_id;
          a34(indx) := t(ddindx).program_application_id;
          a35(indx) := t(ddindx).program_id;
          a36(indx) := t(ddindx).program_update_date;
          a37(indx) := t(ddindx).org_id;
          a38(indx) := t(ddindx).created_by;
          a39(indx) := t(ddindx).creation_date;
          a40(indx) := t(ddindx).last_updated_by;
          a41(indx) := t(ddindx).last_update_date;
          a42(indx) := t(ddindx).last_update_login;
          a43(indx) := t(ddindx).receipt_type;
          a44(indx) := t(ddindx).cash_receipt_id;
          a45(indx) := t(ddindx).fully_applied_flag;
          a46(indx) := t(ddindx).expired_flag;
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
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  DATE
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
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
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  DATE
    , p5_a40  NUMBER
    , p5_a41  DATE
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddx_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rctv_rec.id := p5_a0;
    ddp_rctv_rec.object_version_number := p5_a1;
    ddp_rctv_rec.sfwt_flag := p5_a2;
    ddp_rctv_rec.btc_id := p5_a3;
    ddp_rctv_rec.iba_id := p5_a4;
    ddp_rctv_rec.gl_date := p5_a5;
    ddp_rctv_rec.ile_id := p5_a6;
    ddp_rctv_rec.irm_id := p5_a7;
    ddp_rctv_rec.check_number := p5_a8;
    ddp_rctv_rec.currency_code := p5_a9;
    ddp_rctv_rec.exchange_rate_type := p5_a10;
    ddp_rctv_rec.exchange_rate_date := p5_a11;
    ddp_rctv_rec.exchange_rate := p5_a12;
    ddp_rctv_rec.amount := p5_a13;
    ddp_rctv_rec.date_effective := p5_a14;
    ddp_rctv_rec.rcpt_status_code := p5_a15;
    ddp_rctv_rec.description := p5_a16;
    ddp_rctv_rec.attribute_category := p5_a17;
    ddp_rctv_rec.attribute1 := p5_a18;
    ddp_rctv_rec.attribute2 := p5_a19;
    ddp_rctv_rec.attribute3 := p5_a20;
    ddp_rctv_rec.attribute4 := p5_a21;
    ddp_rctv_rec.attribute5 := p5_a22;
    ddp_rctv_rec.attribute6 := p5_a23;
    ddp_rctv_rec.attribute7 := p5_a24;
    ddp_rctv_rec.attribute8 := p5_a25;
    ddp_rctv_rec.attribute9 := p5_a26;
    ddp_rctv_rec.attribute10 := p5_a27;
    ddp_rctv_rec.attribute11 := p5_a28;
    ddp_rctv_rec.attribute12 := p5_a29;
    ddp_rctv_rec.attribute13 := p5_a30;
    ddp_rctv_rec.attribute14 := p5_a31;
    ddp_rctv_rec.attribute15 := p5_a32;
    ddp_rctv_rec.request_id := p5_a33;
    ddp_rctv_rec.program_application_id := p5_a34;
    ddp_rctv_rec.program_id := p5_a35;
    ddp_rctv_rec.program_update_date := p5_a36;
    ddp_rctv_rec.org_id := p5_a37;
    ddp_rctv_rec.created_by := p5_a38;
    ddp_rctv_rec.creation_date := p5_a39;
    ddp_rctv_rec.last_updated_by := p5_a40;
    ddp_rctv_rec.last_update_date := p5_a41;
    ddp_rctv_rec.last_update_login := p5_a42;
    ddp_rctv_rec.receipt_type := p5_a43;
    ddp_rctv_rec.cash_receipt_id := p5_a44;
    ddp_rctv_rec.fully_applied_flag := p5_a45;
    ddp_rctv_rec.expired_flag := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_rec,
      ddx_rctv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rctv_rec.id;
    p6_a1 := ddx_rctv_rec.object_version_number;
    p6_a2 := ddx_rctv_rec.sfwt_flag;
    p6_a3 := ddx_rctv_rec.btc_id;
    p6_a4 := ddx_rctv_rec.iba_id;
    p6_a5 := ddx_rctv_rec.gl_date;
    p6_a6 := ddx_rctv_rec.ile_id;
    p6_a7 := ddx_rctv_rec.irm_id;
    p6_a8 := ddx_rctv_rec.check_number;
    p6_a9 := ddx_rctv_rec.currency_code;
    p6_a10 := ddx_rctv_rec.exchange_rate_type;
    p6_a11 := ddx_rctv_rec.exchange_rate_date;
    p6_a12 := ddx_rctv_rec.exchange_rate;
    p6_a13 := ddx_rctv_rec.amount;
    p6_a14 := ddx_rctv_rec.date_effective;
    p6_a15 := ddx_rctv_rec.rcpt_status_code;
    p6_a16 := ddx_rctv_rec.description;
    p6_a17 := ddx_rctv_rec.attribute_category;
    p6_a18 := ddx_rctv_rec.attribute1;
    p6_a19 := ddx_rctv_rec.attribute2;
    p6_a20 := ddx_rctv_rec.attribute3;
    p6_a21 := ddx_rctv_rec.attribute4;
    p6_a22 := ddx_rctv_rec.attribute5;
    p6_a23 := ddx_rctv_rec.attribute6;
    p6_a24 := ddx_rctv_rec.attribute7;
    p6_a25 := ddx_rctv_rec.attribute8;
    p6_a26 := ddx_rctv_rec.attribute9;
    p6_a27 := ddx_rctv_rec.attribute10;
    p6_a28 := ddx_rctv_rec.attribute11;
    p6_a29 := ddx_rctv_rec.attribute12;
    p6_a30 := ddx_rctv_rec.attribute13;
    p6_a31 := ddx_rctv_rec.attribute14;
    p6_a32 := ddx_rctv_rec.attribute15;
    p6_a33 := ddx_rctv_rec.request_id;
    p6_a34 := ddx_rctv_rec.program_application_id;
    p6_a35 := ddx_rctv_rec.program_id;
    p6_a36 := ddx_rctv_rec.program_update_date;
    p6_a37 := ddx_rctv_rec.org_id;
    p6_a38 := ddx_rctv_rec.created_by;
    p6_a39 := ddx_rctv_rec.creation_date;
    p6_a40 := ddx_rctv_rec.last_updated_by;
    p6_a41 := ddx_rctv_rec.last_update_date;
    p6_a42 := ddx_rctv_rec.last_update_login;
    p6_a43 := ddx_rctv_rec.receipt_type;
    p6_a44 := ddx_rctv_rec.cash_receipt_id;
    p6_a45 := ddx_rctv_rec.fully_applied_flag;
    p6_a46 := ddx_rctv_rec.expired_flag;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddx_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rct_pvt_w.rosetta_table_copy_in_p8(ddp_rctv_tbl, p5_a0
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
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_tbl,
      ddx_rctv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rct_pvt_w.rosetta_table_copy_out_p8(ddx_rctv_tbl, p6_a0
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
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  DATE
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
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
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  DATE
    , p5_a40  NUMBER
    , p5_a41  DATE
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
  )

  as
    ddp_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rctv_rec.id := p5_a0;
    ddp_rctv_rec.object_version_number := p5_a1;
    ddp_rctv_rec.sfwt_flag := p5_a2;
    ddp_rctv_rec.btc_id := p5_a3;
    ddp_rctv_rec.iba_id := p5_a4;
    ddp_rctv_rec.gl_date := p5_a5;
    ddp_rctv_rec.ile_id := p5_a6;
    ddp_rctv_rec.irm_id := p5_a7;
    ddp_rctv_rec.check_number := p5_a8;
    ddp_rctv_rec.currency_code := p5_a9;
    ddp_rctv_rec.exchange_rate_type := p5_a10;
    ddp_rctv_rec.exchange_rate_date := p5_a11;
    ddp_rctv_rec.exchange_rate := p5_a12;
    ddp_rctv_rec.amount := p5_a13;
    ddp_rctv_rec.date_effective := p5_a14;
    ddp_rctv_rec.rcpt_status_code := p5_a15;
    ddp_rctv_rec.description := p5_a16;
    ddp_rctv_rec.attribute_category := p5_a17;
    ddp_rctv_rec.attribute1 := p5_a18;
    ddp_rctv_rec.attribute2 := p5_a19;
    ddp_rctv_rec.attribute3 := p5_a20;
    ddp_rctv_rec.attribute4 := p5_a21;
    ddp_rctv_rec.attribute5 := p5_a22;
    ddp_rctv_rec.attribute6 := p5_a23;
    ddp_rctv_rec.attribute7 := p5_a24;
    ddp_rctv_rec.attribute8 := p5_a25;
    ddp_rctv_rec.attribute9 := p5_a26;
    ddp_rctv_rec.attribute10 := p5_a27;
    ddp_rctv_rec.attribute11 := p5_a28;
    ddp_rctv_rec.attribute12 := p5_a29;
    ddp_rctv_rec.attribute13 := p5_a30;
    ddp_rctv_rec.attribute14 := p5_a31;
    ddp_rctv_rec.attribute15 := p5_a32;
    ddp_rctv_rec.request_id := p5_a33;
    ddp_rctv_rec.program_application_id := p5_a34;
    ddp_rctv_rec.program_id := p5_a35;
    ddp_rctv_rec.program_update_date := p5_a36;
    ddp_rctv_rec.org_id := p5_a37;
    ddp_rctv_rec.created_by := p5_a38;
    ddp_rctv_rec.creation_date := p5_a39;
    ddp_rctv_rec.last_updated_by := p5_a40;
    ddp_rctv_rec.last_update_date := p5_a41;
    ddp_rctv_rec.last_update_login := p5_a42;
    ddp_rctv_rec.receipt_type := p5_a43;
    ddp_rctv_rec.cash_receipt_id := p5_a44;
    ddp_rctv_rec.fully_applied_flag := p5_a45;
    ddp_rctv_rec.expired_flag := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_rec);

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
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rct_pvt_w.rosetta_table_copy_in_p8(ddp_rctv_tbl, p5_a0
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
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  DATE
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
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
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  DATE
    , p5_a40  NUMBER
    , p5_a41  DATE
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddx_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rctv_rec.id := p5_a0;
    ddp_rctv_rec.object_version_number := p5_a1;
    ddp_rctv_rec.sfwt_flag := p5_a2;
    ddp_rctv_rec.btc_id := p5_a3;
    ddp_rctv_rec.iba_id := p5_a4;
    ddp_rctv_rec.gl_date := p5_a5;
    ddp_rctv_rec.ile_id := p5_a6;
    ddp_rctv_rec.irm_id := p5_a7;
    ddp_rctv_rec.check_number := p5_a8;
    ddp_rctv_rec.currency_code := p5_a9;
    ddp_rctv_rec.exchange_rate_type := p5_a10;
    ddp_rctv_rec.exchange_rate_date := p5_a11;
    ddp_rctv_rec.exchange_rate := p5_a12;
    ddp_rctv_rec.amount := p5_a13;
    ddp_rctv_rec.date_effective := p5_a14;
    ddp_rctv_rec.rcpt_status_code := p5_a15;
    ddp_rctv_rec.description := p5_a16;
    ddp_rctv_rec.attribute_category := p5_a17;
    ddp_rctv_rec.attribute1 := p5_a18;
    ddp_rctv_rec.attribute2 := p5_a19;
    ddp_rctv_rec.attribute3 := p5_a20;
    ddp_rctv_rec.attribute4 := p5_a21;
    ddp_rctv_rec.attribute5 := p5_a22;
    ddp_rctv_rec.attribute6 := p5_a23;
    ddp_rctv_rec.attribute7 := p5_a24;
    ddp_rctv_rec.attribute8 := p5_a25;
    ddp_rctv_rec.attribute9 := p5_a26;
    ddp_rctv_rec.attribute10 := p5_a27;
    ddp_rctv_rec.attribute11 := p5_a28;
    ddp_rctv_rec.attribute12 := p5_a29;
    ddp_rctv_rec.attribute13 := p5_a30;
    ddp_rctv_rec.attribute14 := p5_a31;
    ddp_rctv_rec.attribute15 := p5_a32;
    ddp_rctv_rec.request_id := p5_a33;
    ddp_rctv_rec.program_application_id := p5_a34;
    ddp_rctv_rec.program_id := p5_a35;
    ddp_rctv_rec.program_update_date := p5_a36;
    ddp_rctv_rec.org_id := p5_a37;
    ddp_rctv_rec.created_by := p5_a38;
    ddp_rctv_rec.creation_date := p5_a39;
    ddp_rctv_rec.last_updated_by := p5_a40;
    ddp_rctv_rec.last_update_date := p5_a41;
    ddp_rctv_rec.last_update_login := p5_a42;
    ddp_rctv_rec.receipt_type := p5_a43;
    ddp_rctv_rec.cash_receipt_id := p5_a44;
    ddp_rctv_rec.fully_applied_flag := p5_a45;
    ddp_rctv_rec.expired_flag := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_rec,
      ddx_rctv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rctv_rec.id;
    p6_a1 := ddx_rctv_rec.object_version_number;
    p6_a2 := ddx_rctv_rec.sfwt_flag;
    p6_a3 := ddx_rctv_rec.btc_id;
    p6_a4 := ddx_rctv_rec.iba_id;
    p6_a5 := ddx_rctv_rec.gl_date;
    p6_a6 := ddx_rctv_rec.ile_id;
    p6_a7 := ddx_rctv_rec.irm_id;
    p6_a8 := ddx_rctv_rec.check_number;
    p6_a9 := ddx_rctv_rec.currency_code;
    p6_a10 := ddx_rctv_rec.exchange_rate_type;
    p6_a11 := ddx_rctv_rec.exchange_rate_date;
    p6_a12 := ddx_rctv_rec.exchange_rate;
    p6_a13 := ddx_rctv_rec.amount;
    p6_a14 := ddx_rctv_rec.date_effective;
    p6_a15 := ddx_rctv_rec.rcpt_status_code;
    p6_a16 := ddx_rctv_rec.description;
    p6_a17 := ddx_rctv_rec.attribute_category;
    p6_a18 := ddx_rctv_rec.attribute1;
    p6_a19 := ddx_rctv_rec.attribute2;
    p6_a20 := ddx_rctv_rec.attribute3;
    p6_a21 := ddx_rctv_rec.attribute4;
    p6_a22 := ddx_rctv_rec.attribute5;
    p6_a23 := ddx_rctv_rec.attribute6;
    p6_a24 := ddx_rctv_rec.attribute7;
    p6_a25 := ddx_rctv_rec.attribute8;
    p6_a26 := ddx_rctv_rec.attribute9;
    p6_a27 := ddx_rctv_rec.attribute10;
    p6_a28 := ddx_rctv_rec.attribute11;
    p6_a29 := ddx_rctv_rec.attribute12;
    p6_a30 := ddx_rctv_rec.attribute13;
    p6_a31 := ddx_rctv_rec.attribute14;
    p6_a32 := ddx_rctv_rec.attribute15;
    p6_a33 := ddx_rctv_rec.request_id;
    p6_a34 := ddx_rctv_rec.program_application_id;
    p6_a35 := ddx_rctv_rec.program_id;
    p6_a36 := ddx_rctv_rec.program_update_date;
    p6_a37 := ddx_rctv_rec.org_id;
    p6_a38 := ddx_rctv_rec.created_by;
    p6_a39 := ddx_rctv_rec.creation_date;
    p6_a40 := ddx_rctv_rec.last_updated_by;
    p6_a41 := ddx_rctv_rec.last_update_date;
    p6_a42 := ddx_rctv_rec.last_update_login;
    p6_a43 := ddx_rctv_rec.receipt_type;
    p6_a44 := ddx_rctv_rec.cash_receipt_id;
    p6_a45 := ddx_rctv_rec.fully_applied_flag;
    p6_a46 := ddx_rctv_rec.expired_flag;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddx_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rct_pvt_w.rosetta_table_copy_in_p8(ddp_rctv_tbl, p5_a0
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
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_tbl,
      ddx_rctv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rct_pvt_w.rosetta_table_copy_out_p8(ddx_rctv_tbl, p6_a0
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
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
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
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  DATE
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
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
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  DATE
    , p5_a40  NUMBER
    , p5_a41  DATE
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
  )

  as
    ddp_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rctv_rec.id := p5_a0;
    ddp_rctv_rec.object_version_number := p5_a1;
    ddp_rctv_rec.sfwt_flag := p5_a2;
    ddp_rctv_rec.btc_id := p5_a3;
    ddp_rctv_rec.iba_id := p5_a4;
    ddp_rctv_rec.gl_date := p5_a5;
    ddp_rctv_rec.ile_id := p5_a6;
    ddp_rctv_rec.irm_id := p5_a7;
    ddp_rctv_rec.check_number := p5_a8;
    ddp_rctv_rec.currency_code := p5_a9;
    ddp_rctv_rec.exchange_rate_type := p5_a10;
    ddp_rctv_rec.exchange_rate_date := p5_a11;
    ddp_rctv_rec.exchange_rate := p5_a12;
    ddp_rctv_rec.amount := p5_a13;
    ddp_rctv_rec.date_effective := p5_a14;
    ddp_rctv_rec.rcpt_status_code := p5_a15;
    ddp_rctv_rec.description := p5_a16;
    ddp_rctv_rec.attribute_category := p5_a17;
    ddp_rctv_rec.attribute1 := p5_a18;
    ddp_rctv_rec.attribute2 := p5_a19;
    ddp_rctv_rec.attribute3 := p5_a20;
    ddp_rctv_rec.attribute4 := p5_a21;
    ddp_rctv_rec.attribute5 := p5_a22;
    ddp_rctv_rec.attribute6 := p5_a23;
    ddp_rctv_rec.attribute7 := p5_a24;
    ddp_rctv_rec.attribute8 := p5_a25;
    ddp_rctv_rec.attribute9 := p5_a26;
    ddp_rctv_rec.attribute10 := p5_a27;
    ddp_rctv_rec.attribute11 := p5_a28;
    ddp_rctv_rec.attribute12 := p5_a29;
    ddp_rctv_rec.attribute13 := p5_a30;
    ddp_rctv_rec.attribute14 := p5_a31;
    ddp_rctv_rec.attribute15 := p5_a32;
    ddp_rctv_rec.request_id := p5_a33;
    ddp_rctv_rec.program_application_id := p5_a34;
    ddp_rctv_rec.program_id := p5_a35;
    ddp_rctv_rec.program_update_date := p5_a36;
    ddp_rctv_rec.org_id := p5_a37;
    ddp_rctv_rec.created_by := p5_a38;
    ddp_rctv_rec.creation_date := p5_a39;
    ddp_rctv_rec.last_updated_by := p5_a40;
    ddp_rctv_rec.last_update_date := p5_a41;
    ddp_rctv_rec.last_update_login := p5_a42;
    ddp_rctv_rec.receipt_type := p5_a43;
    ddp_rctv_rec.cash_receipt_id := p5_a44;
    ddp_rctv_rec.fully_applied_flag := p5_a45;
    ddp_rctv_rec.expired_flag := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_rec);

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
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rct_pvt_w.rosetta_table_copy_in_p8(ddp_rctv_tbl, p5_a0
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
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  DATE
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
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
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  DATE
    , p5_a40  NUMBER
    , p5_a41  DATE
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
  )

  as
    ddp_rctv_rec okl_rct_pvt.rctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rctv_rec.id := p5_a0;
    ddp_rctv_rec.object_version_number := p5_a1;
    ddp_rctv_rec.sfwt_flag := p5_a2;
    ddp_rctv_rec.btc_id := p5_a3;
    ddp_rctv_rec.iba_id := p5_a4;
    ddp_rctv_rec.gl_date := p5_a5;
    ddp_rctv_rec.ile_id := p5_a6;
    ddp_rctv_rec.irm_id := p5_a7;
    ddp_rctv_rec.check_number := p5_a8;
    ddp_rctv_rec.currency_code := p5_a9;
    ddp_rctv_rec.exchange_rate_type := p5_a10;
    ddp_rctv_rec.exchange_rate_date := p5_a11;
    ddp_rctv_rec.exchange_rate := p5_a12;
    ddp_rctv_rec.amount := p5_a13;
    ddp_rctv_rec.date_effective := p5_a14;
    ddp_rctv_rec.rcpt_status_code := p5_a15;
    ddp_rctv_rec.description := p5_a16;
    ddp_rctv_rec.attribute_category := p5_a17;
    ddp_rctv_rec.attribute1 := p5_a18;
    ddp_rctv_rec.attribute2 := p5_a19;
    ddp_rctv_rec.attribute3 := p5_a20;
    ddp_rctv_rec.attribute4 := p5_a21;
    ddp_rctv_rec.attribute5 := p5_a22;
    ddp_rctv_rec.attribute6 := p5_a23;
    ddp_rctv_rec.attribute7 := p5_a24;
    ddp_rctv_rec.attribute8 := p5_a25;
    ddp_rctv_rec.attribute9 := p5_a26;
    ddp_rctv_rec.attribute10 := p5_a27;
    ddp_rctv_rec.attribute11 := p5_a28;
    ddp_rctv_rec.attribute12 := p5_a29;
    ddp_rctv_rec.attribute13 := p5_a30;
    ddp_rctv_rec.attribute14 := p5_a31;
    ddp_rctv_rec.attribute15 := p5_a32;
    ddp_rctv_rec.request_id := p5_a33;
    ddp_rctv_rec.program_application_id := p5_a34;
    ddp_rctv_rec.program_id := p5_a35;
    ddp_rctv_rec.program_update_date := p5_a36;
    ddp_rctv_rec.org_id := p5_a37;
    ddp_rctv_rec.created_by := p5_a38;
    ddp_rctv_rec.creation_date := p5_a39;
    ddp_rctv_rec.last_updated_by := p5_a40;
    ddp_rctv_rec.last_update_date := p5_a41;
    ddp_rctv_rec.last_update_login := p5_a42;
    ddp_rctv_rec.receipt_type := p5_a43;
    ddp_rctv_rec.cash_receipt_id := p5_a44;
    ddp_rctv_rec.fully_applied_flag := p5_a45;
    ddp_rctv_rec.expired_flag := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_rec);

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
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rct_pvt_w.rosetta_table_copy_in_p8(ddp_rctv_tbl, p5_a0
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
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rct_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rctv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_rct_pvt_w;

/
