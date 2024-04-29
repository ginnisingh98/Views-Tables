--------------------------------------------------------
--  DDL for Package Body OKL_TCL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TCL_PVT_W" as
  /* $Header: OKLITCLB.pls 120.7.12010000.3 2008/11/07 10:26:57 sosharma ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_tcl_pvt.tcl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
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
    , a37 JTF_VARCHAR2_TABLE_500
    , a38 JTF_VARCHAR2_TABLE_500
    , a39 JTF_VARCHAR2_TABLE_500
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).before_transfer_yn := a3(indx);
          t(ddindx).tcn_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).rct_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).btc_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tcl_type := a9(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).description := a16(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).gl_reversal_yn := a18(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).currency_code := a21(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).attribute_category := a24(indx);
          t(ddindx).attribute1 := a25(indx);
          t(ddindx).attribute2 := a26(indx);
          t(ddindx).attribute3 := a27(indx);
          t(ddindx).attribute4 := a28(indx);
          t(ddindx).attribute5 := a29(indx);
          t(ddindx).attribute6 := a30(indx);
          t(ddindx).attribute7 := a31(indx);
          t(ddindx).attribute8 := a32(indx);
          t(ddindx).attribute9 := a33(indx);
          t(ddindx).attribute10 := a34(indx);
          t(ddindx).attribute11 := a35(indx);
          t(ddindx).attribute12 := a36(indx);
          t(ddindx).attribute13 := a37(indx);
          t(ddindx).attribute14 := a38(indx);
          t(ddindx).attribute15 := a39(indx);
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).avl_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).bkt_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).kle_id_new := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).percentage := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).accrual_rule_yn := a45(indx);
          t(ddindx).source_column_1 := a46(indx);
          t(ddindx).source_value_1 := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).source_column_2 := a48(indx);
          t(ddindx).source_value_2 := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).source_column_3 := a50(indx);
          t(ddindx).source_value_3 := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).canceled_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).tax_line_id := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).stream_type_code := a54(indx);
          t(ddindx).stream_type_purpose := a55(indx);
          t(ddindx).asset_book_type_name := a56(indx);
          t(ddindx).upgrade_status_flag := a57(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_tcl_pvt.tcl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a37 out nocopy JTF_VARCHAR2_TABLE_500
    , a38 out nocopy JTF_VARCHAR2_TABLE_500
    , a39 out nocopy JTF_VARCHAR2_TABLE_500
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
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
    a37 := JTF_VARCHAR2_TABLE_500();
    a38 := JTF_VARCHAR2_TABLE_500();
    a39 := JTF_VARCHAR2_TABLE_500();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
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
      a37 := JTF_VARCHAR2_TABLE_500();
      a38 := JTF_VARCHAR2_TABLE_500();
      a39 := JTF_VARCHAR2_TABLE_500();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
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
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a3(indx) := t(ddindx).before_transfer_yn;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).tcn_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).rct_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).btc_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a9(indx) := t(ddindx).tcl_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a12(indx) := t(ddindx).creation_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a14(indx) := t(ddindx).last_update_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a16(indx) := t(ddindx).description;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a18(indx) := t(ddindx).gl_reversal_yn;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a21(indx) := t(ddindx).currency_code;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a23(indx) := t(ddindx).program_update_date;
          a24(indx) := t(ddindx).attribute_category;
          a25(indx) := t(ddindx).attribute1;
          a26(indx) := t(ddindx).attribute2;
          a27(indx) := t(ddindx).attribute3;
          a28(indx) := t(ddindx).attribute4;
          a29(indx) := t(ddindx).attribute5;
          a30(indx) := t(ddindx).attribute6;
          a31(indx) := t(ddindx).attribute7;
          a32(indx) := t(ddindx).attribute8;
          a33(indx) := t(ddindx).attribute9;
          a34(indx) := t(ddindx).attribute10;
          a35(indx) := t(ddindx).attribute11;
          a36(indx) := t(ddindx).attribute12;
          a37(indx) := t(ddindx).attribute13;
          a38(indx) := t(ddindx).attribute14;
          a39(indx) := t(ddindx).attribute15;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).avl_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).bkt_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id_new);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).percentage);
          a45(indx) := t(ddindx).accrual_rule_yn;
          a46(indx) := t(ddindx).source_column_1;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).source_value_1);
          a48(indx) := t(ddindx).source_column_2;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).source_value_2);
          a50(indx) := t(ddindx).source_column_3;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).source_value_3);
          a52(indx) := t(ddindx).canceled_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).tax_line_id);
          a54(indx) := t(ddindx).stream_type_code;
          a55(indx) := t(ddindx).stream_type_purpose;
          a56(indx) := t(ddindx).asset_book_type_name;
          a57(indx) := t(ddindx).upgrade_status_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_tcl_pvt.tclv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_100
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
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).sty_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).rct_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).btc_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).tcn_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).before_transfer_yn := a8(indx);
          t(ddindx).line_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).description := a10(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).currency_code := a12(indx);
          t(ddindx).gl_reversal_yn := a13(indx);
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
          t(ddindx).tcl_type := a30(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).avl_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).bkt_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).kle_id_new := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).percentage := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).accrual_rule_yn := a45(indx);
          t(ddindx).source_column_1 := a46(indx);
          t(ddindx).source_value_1 := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).source_column_2 := a48(indx);
          t(ddindx).source_value_2 := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).source_column_3 := a50(indx);
          t(ddindx).source_value_3 := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).canceled_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).tax_line_id := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).stream_type_code := a54(indx);
          t(ddindx).stream_type_purpose := a55(indx);
          t(ddindx).asset_book_type_name := a56(indx);
          t(ddindx).upgrade_status_flag := a57(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_tcl_pvt.tclv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_100();
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
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_100();
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
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
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
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).rct_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).btc_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).tcn_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a8(indx) := t(ddindx).before_transfer_yn;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a10(indx) := t(ddindx).description;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a12(indx) := t(ddindx).currency_code;
          a13(indx) := t(ddindx).gl_reversal_yn;
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
          a30(indx) := t(ddindx).tcl_type;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a32(indx) := t(ddindx).creation_date;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a34(indx) := t(ddindx).last_update_date;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a39(indx) := t(ddindx).program_update_date;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).avl_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).bkt_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id_new);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).percentage);
          a45(indx) := t(ddindx).accrual_rule_yn;
          a46(indx) := t(ddindx).source_column_1;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).source_value_1);
          a48(indx) := t(ddindx).source_column_2;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).source_value_2);
          a50(indx) := t(ddindx).source_column_3;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).source_value_3);
          a52(indx) := t(ddindx).canceled_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).tax_line_id);
          a54(indx) := t(ddindx).stream_type_code;
          a55(indx) := t(ddindx).stream_type_purpose;
          a56(indx) := t(ddindx).asset_book_type_name;
          a57(indx) := t(ddindx).upgrade_status_flag;
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddx_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec,
      ddx_tclv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tclv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tclv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tclv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tclv_rec.rct_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tclv_rec.btc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tclv_rec.tcn_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tclv_rec.khr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id);
    p6_a8 := ddx_tclv_rec.before_transfer_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_tclv_rec.line_number);
    p6_a10 := ddx_tclv_rec.description;
    p6_a11 := rosetta_g_miss_num_map(ddx_tclv_rec.amount);
    p6_a12 := ddx_tclv_rec.currency_code;
    p6_a13 := ddx_tclv_rec.gl_reversal_yn;
    p6_a14 := ddx_tclv_rec.attribute_category;
    p6_a15 := ddx_tclv_rec.attribute1;
    p6_a16 := ddx_tclv_rec.attribute2;
    p6_a17 := ddx_tclv_rec.attribute3;
    p6_a18 := ddx_tclv_rec.attribute4;
    p6_a19 := ddx_tclv_rec.attribute5;
    p6_a20 := ddx_tclv_rec.attribute6;
    p6_a21 := ddx_tclv_rec.attribute7;
    p6_a22 := ddx_tclv_rec.attribute8;
    p6_a23 := ddx_tclv_rec.attribute9;
    p6_a24 := ddx_tclv_rec.attribute10;
    p6_a25 := ddx_tclv_rec.attribute11;
    p6_a26 := ddx_tclv_rec.attribute12;
    p6_a27 := ddx_tclv_rec.attribute13;
    p6_a28 := ddx_tclv_rec.attribute14;
    p6_a29 := ddx_tclv_rec.attribute15;
    p6_a30 := ddx_tclv_rec.tcl_type;
    p6_a31 := rosetta_g_miss_num_map(ddx_tclv_rec.created_by);
    p6_a32 := ddx_tclv_rec.creation_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_tclv_rec.last_updated_by);
    p6_a34 := ddx_tclv_rec.last_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_tclv_rec.org_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_tclv_rec.program_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tclv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tclv_rec.request_id);
    p6_a39 := ddx_tclv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tclv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_tclv_rec.avl_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_tclv_rec.bkt_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id_new);
    p6_a44 := rosetta_g_miss_num_map(ddx_tclv_rec.percentage);
    p6_a45 := ddx_tclv_rec.accrual_rule_yn;
    p6_a46 := ddx_tclv_rec.source_column_1;
    p6_a47 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_1);
    p6_a48 := ddx_tclv_rec.source_column_2;
    p6_a49 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_2);
    p6_a50 := ddx_tclv_rec.source_column_3;
    p6_a51 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_3);
    p6_a52 := ddx_tclv_rec.canceled_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tclv_rec.tax_line_id);
    p6_a54 := ddx_tclv_rec.stream_type_code;
    p6_a55 := ddx_tclv_rec.stream_type_purpose;
    p6_a56 := ddx_tclv_rec.asset_book_type_name;
    p6_a57 := ddx_tclv_rec.upgrade_status_flag;
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddx_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p6_a0
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
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec);

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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl);

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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddx_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec,
      ddx_tclv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tclv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tclv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tclv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tclv_rec.rct_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tclv_rec.btc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tclv_rec.tcn_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tclv_rec.khr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id);
    p6_a8 := ddx_tclv_rec.before_transfer_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_tclv_rec.line_number);
    p6_a10 := ddx_tclv_rec.description;
    p6_a11 := rosetta_g_miss_num_map(ddx_tclv_rec.amount);
    p6_a12 := ddx_tclv_rec.currency_code;
    p6_a13 := ddx_tclv_rec.gl_reversal_yn;
    p6_a14 := ddx_tclv_rec.attribute_category;
    p6_a15 := ddx_tclv_rec.attribute1;
    p6_a16 := ddx_tclv_rec.attribute2;
    p6_a17 := ddx_tclv_rec.attribute3;
    p6_a18 := ddx_tclv_rec.attribute4;
    p6_a19 := ddx_tclv_rec.attribute5;
    p6_a20 := ddx_tclv_rec.attribute6;
    p6_a21 := ddx_tclv_rec.attribute7;
    p6_a22 := ddx_tclv_rec.attribute8;
    p6_a23 := ddx_tclv_rec.attribute9;
    p6_a24 := ddx_tclv_rec.attribute10;
    p6_a25 := ddx_tclv_rec.attribute11;
    p6_a26 := ddx_tclv_rec.attribute12;
    p6_a27 := ddx_tclv_rec.attribute13;
    p6_a28 := ddx_tclv_rec.attribute14;
    p6_a29 := ddx_tclv_rec.attribute15;
    p6_a30 := ddx_tclv_rec.tcl_type;
    p6_a31 := rosetta_g_miss_num_map(ddx_tclv_rec.created_by);
    p6_a32 := ddx_tclv_rec.creation_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_tclv_rec.last_updated_by);
    p6_a34 := ddx_tclv_rec.last_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_tclv_rec.org_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_tclv_rec.program_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tclv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tclv_rec.request_id);
    p6_a39 := ddx_tclv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tclv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_tclv_rec.avl_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_tclv_rec.bkt_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id_new);
    p6_a44 := rosetta_g_miss_num_map(ddx_tclv_rec.percentage);
    p6_a45 := ddx_tclv_rec.accrual_rule_yn;
    p6_a46 := ddx_tclv_rec.source_column_1;
    p6_a47 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_1);
    p6_a48 := ddx_tclv_rec.source_column_2;
    p6_a49 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_2);
    p6_a50 := ddx_tclv_rec.source_column_3;
    p6_a51 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_3);
    p6_a52 := ddx_tclv_rec.canceled_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tclv_rec.tax_line_id);
    p6_a54 := ddx_tclv_rec.stream_type_code;
    p6_a55 := ddx_tclv_rec.stream_type_purpose;
    p6_a56 := ddx_tclv_rec.asset_book_type_name;
    p6_a57 := ddx_tclv_rec.upgrade_status_flag;
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddx_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p6_a0
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
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec);

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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl);

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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_tcl_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec);

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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_tcl_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tcl_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tcl_pvt_w;

/
