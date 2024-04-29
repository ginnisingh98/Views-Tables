--------------------------------------------------------
--  DDL for Package Body OKL_TQL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TQL_PVT_W" as
  /* $Header: OKLITQLB.pls 120.2 2005/08/19 01:33:35 rmunjulu noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_tql_pvt.tql_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
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
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_DATE_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).qlt_code := a3(indx);
          t(ddindx).qte_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).modified_yn := a8(indx);
          t(ddindx).taxed_yn := a9(indx);
          t(ddindx).defaulted_yn := a10(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).attribute_category := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).period := a38(indx);
          t(ddindx).number_of_periods := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).lock_level_step := a40(indx);
          t(ddindx).advance_or_arrears := a41(indx);
          t(ddindx).yield_name := a42(indx);
          t(ddindx).yield_value := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).asset_value := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).unbilled_receivables := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).asset_quantity := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).quote_quantity := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).split_kle_id := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).split_kle_name := a51(indx);
          t(ddindx).currency_code := a52(indx);
          t(ddindx).currency_conversion_code := a53(indx);
          t(ddindx).currency_conversion_type := a54(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a56(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a58(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_tql_pvt.tql_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_DATE_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
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
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_DATE_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
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
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_DATE_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_NUMBER_TABLE();
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
        a58.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a3(indx) := t(ddindx).qlt_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).modified_yn;
          a9(indx) := t(ddindx).taxed_yn;
          a10(indx) := t(ddindx).defaulted_yn;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a15(indx) := t(ddindx).program_update_date;
          a16(indx) := t(ddindx).attribute_category;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a33(indx) := t(ddindx).creation_date;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a35(indx) := t(ddindx).last_update_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a37(indx) := t(ddindx).start_date;
          a38(indx) := t(ddindx).period;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_periods);
          a40(indx) := t(ddindx).lock_level_step;
          a41(indx) := t(ddindx).advance_or_arrears;
          a42(indx) := t(ddindx).yield_name;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).yield_value);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).asset_value);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).unbilled_receivables);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).asset_quantity);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).quote_quantity);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).split_kle_id);
          a51(indx) := t(ddindx).split_kle_name;
          a52(indx) := t(ddindx).currency_code;
          a53(indx) := t(ddindx).currency_conversion_code;
          a54(indx) := t(ddindx).currency_conversion_type;
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a56(indx) := t(ddindx).currency_conversion_date;
          a57(indx) := t(ddindx).due_date;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_tql_pvt.okltxlquotelinestltbltype, a0 JTF_NUMBER_TABLE
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
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_tql_pvt.okltxlquotelinestltbltype, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).description;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_tql_pvt.tqlv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
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
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_DATE_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_NUMBER_TABLE
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
          t(ddindx).qlt_code := a3(indx);
          t(ddindx).kle_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).qte_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).description := a8(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).modified_yn := a10(indx);
          t(ddindx).taxed_yn := a11(indx);
          t(ddindx).defaulted_yn := a12(indx);
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
          t(ddindx).org_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).period := a40(indx);
          t(ddindx).number_of_periods := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).lock_level_step := a42(indx);
          t(ddindx).advance_or_arrears := a43(indx);
          t(ddindx).yield_name := a44(indx);
          t(ddindx).yield_value := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).asset_value := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).unbilled_receivables := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).asset_quantity := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).quote_quantity := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).split_kle_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).split_kle_name := a53(indx);
          t(ddindx).currency_code := a54(indx);
          t(ddindx).currency_conversion_code := a55(indx);
          t(ddindx).currency_conversion_type := a56(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a58(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a59(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a60(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_tql_pvt.tqlv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
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
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
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
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_NUMBER_TABLE();
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
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).qlt_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a8(indx) := t(ddindx).description;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a10(indx) := t(ddindx).modified_yn;
          a11(indx) := t(ddindx).taxed_yn;
          a12(indx) := t(ddindx).defaulted_yn;
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
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a33(indx) := t(ddindx).program_update_date;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a35(indx) := t(ddindx).creation_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a37(indx) := t(ddindx).last_update_date;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a39(indx) := t(ddindx).start_date;
          a40(indx) := t(ddindx).period;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_periods);
          a42(indx) := t(ddindx).lock_level_step;
          a43(indx) := t(ddindx).advance_or_arrears;
          a44(indx) := t(ddindx).yield_name;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).yield_value);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).asset_value);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).unbilled_receivables);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).asset_quantity);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).quote_quantity);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).split_kle_id);
          a53(indx) := t(ddindx).split_kle_name;
          a54(indx) := t(ddindx).currency_code;
          a55(indx) := t(ddindx).currency_conversion_code;
          a56(indx) := t(ddindx).currency_conversion_type;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a58(indx) := t(ddindx).currency_conversion_date;
          a59(indx) := t(ddindx).due_date;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy okl_tql_pvt.numbertabtyp, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_tql_pvt.numbertabtyp, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy okl_tql_pvt.number4tabtyp, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t okl_tql_pvt.number4tabtyp, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_tql_pvt.number9tabtyp, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_tql_pvt.number9tabtyp, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p12(t out nocopy okl_tql_pvt.number14p3tabtyp, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t okl_tql_pvt.number14p3tabtyp, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p13(t out nocopy okl_tql_pvt.number15tabtyp, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t okl_tql_pvt.number15tabtyp, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p14(t out nocopy okl_tql_pvt.number18p15tabtyp, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t okl_tql_pvt.number18p15tabtyp, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p15(t out nocopy okl_tql_pvt.datetabtyp, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_date_in_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t okl_tql_pvt.datetabtyp, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_date_in_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p16(t out nocopy okl_tql_pvt.var3tabtyp, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t okl_tql_pvt.var3tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p16;

  procedure rosetta_table_copy_in_p17(t out nocopy okl_tql_pvt.var10tabtyp, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t okl_tql_pvt.var10tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p18(t out nocopy okl_tql_pvt.var12tabtyp, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t okl_tql_pvt.var12tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p19(t out nocopy okl_tql_pvt.var15tabtyp, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t okl_tql_pvt.var15tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p20(t out nocopy okl_tql_pvt.var30tabtyp, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t okl_tql_pvt.var30tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p21(t out nocopy okl_tql_pvt.var90tabtyp, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t okl_tql_pvt.var90tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p22(t out nocopy okl_tql_pvt.var150tabtyp, a0 JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t okl_tql_pvt.var150tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p23(t out nocopy okl_tql_pvt.var450tabtyp, a0 JTF_VARCHAR2_TABLE_500) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_tql_pvt.var450tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_500) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_VARCHAR2_TABLE_500();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p24(t out nocopy okl_tql_pvt.var1995tabtyp, a0 JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t okl_tql_pvt.var1995tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

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
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddx_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);


    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec,
      ddx_tqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tqlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tqlv_rec.object_version_number);
    p6_a2 := ddx_tqlv_rec.sfwt_flag;
    p6_a3 := ddx_tqlv_rec.qlt_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_tqlv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tqlv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tqlv_rec.qte_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tqlv_rec.line_number);
    p6_a8 := ddx_tqlv_rec.description;
    p6_a9 := rosetta_g_miss_num_map(ddx_tqlv_rec.amount);
    p6_a10 := ddx_tqlv_rec.modified_yn;
    p6_a11 := ddx_tqlv_rec.taxed_yn;
    p6_a12 := ddx_tqlv_rec.defaulted_yn;
    p6_a13 := ddx_tqlv_rec.attribute_category;
    p6_a14 := ddx_tqlv_rec.attribute1;
    p6_a15 := ddx_tqlv_rec.attribute2;
    p6_a16 := ddx_tqlv_rec.attribute3;
    p6_a17 := ddx_tqlv_rec.attribute4;
    p6_a18 := ddx_tqlv_rec.attribute5;
    p6_a19 := ddx_tqlv_rec.attribute6;
    p6_a20 := ddx_tqlv_rec.attribute7;
    p6_a21 := ddx_tqlv_rec.attribute8;
    p6_a22 := ddx_tqlv_rec.attribute9;
    p6_a23 := ddx_tqlv_rec.attribute10;
    p6_a24 := ddx_tqlv_rec.attribute11;
    p6_a25 := ddx_tqlv_rec.attribute12;
    p6_a26 := ddx_tqlv_rec.attribute13;
    p6_a27 := ddx_tqlv_rec.attribute14;
    p6_a28 := ddx_tqlv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_tqlv_rec.org_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_tqlv_rec.request_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_application_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_id);
    p6_a33 := ddx_tqlv_rec.program_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_tqlv_rec.created_by);
    p6_a35 := ddx_tqlv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_updated_by);
    p6_a37 := ddx_tqlv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_update_login);
    p6_a39 := ddx_tqlv_rec.start_date;
    p6_a40 := ddx_tqlv_rec.period;
    p6_a41 := rosetta_g_miss_num_map(ddx_tqlv_rec.number_of_periods);
    p6_a42 := ddx_tqlv_rec.lock_level_step;
    p6_a43 := ddx_tqlv_rec.advance_or_arrears;
    p6_a44 := ddx_tqlv_rec.yield_name;
    p6_a45 := rosetta_g_miss_num_map(ddx_tqlv_rec.yield_value);
    p6_a46 := rosetta_g_miss_num_map(ddx_tqlv_rec.implicit_interest_rate);
    p6_a47 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_value);
    p6_a48 := rosetta_g_miss_num_map(ddx_tqlv_rec.residual_value);
    p6_a49 := rosetta_g_miss_num_map(ddx_tqlv_rec.unbilled_receivables);
    p6_a50 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_quantity);
    p6_a51 := rosetta_g_miss_num_map(ddx_tqlv_rec.quote_quantity);
    p6_a52 := rosetta_g_miss_num_map(ddx_tqlv_rec.split_kle_id);
    p6_a53 := ddx_tqlv_rec.split_kle_name;
    p6_a54 := ddx_tqlv_rec.currency_code;
    p6_a55 := ddx_tqlv_rec.currency_conversion_code;
    p6_a56 := ddx_tqlv_rec.currency_conversion_type;
    p6_a57 := rosetta_g_miss_num_map(ddx_tqlv_rec.currency_conversion_rate);
    p6_a58 := ddx_tqlv_rec.currency_conversion_date;
    p6_a59 := ddx_tqlv_rec.due_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_tqlv_rec.try_id);
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddx_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p6_a0
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
      , p6_a58
      , p6_a59
      , p6_a60
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
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);

    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl);

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
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddx_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);


    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec,
      ddx_tqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tqlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tqlv_rec.object_version_number);
    p6_a2 := ddx_tqlv_rec.sfwt_flag;
    p6_a3 := ddx_tqlv_rec.qlt_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_tqlv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tqlv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tqlv_rec.qte_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tqlv_rec.line_number);
    p6_a8 := ddx_tqlv_rec.description;
    p6_a9 := rosetta_g_miss_num_map(ddx_tqlv_rec.amount);
    p6_a10 := ddx_tqlv_rec.modified_yn;
    p6_a11 := ddx_tqlv_rec.taxed_yn;
    p6_a12 := ddx_tqlv_rec.defaulted_yn;
    p6_a13 := ddx_tqlv_rec.attribute_category;
    p6_a14 := ddx_tqlv_rec.attribute1;
    p6_a15 := ddx_tqlv_rec.attribute2;
    p6_a16 := ddx_tqlv_rec.attribute3;
    p6_a17 := ddx_tqlv_rec.attribute4;
    p6_a18 := ddx_tqlv_rec.attribute5;
    p6_a19 := ddx_tqlv_rec.attribute6;
    p6_a20 := ddx_tqlv_rec.attribute7;
    p6_a21 := ddx_tqlv_rec.attribute8;
    p6_a22 := ddx_tqlv_rec.attribute9;
    p6_a23 := ddx_tqlv_rec.attribute10;
    p6_a24 := ddx_tqlv_rec.attribute11;
    p6_a25 := ddx_tqlv_rec.attribute12;
    p6_a26 := ddx_tqlv_rec.attribute13;
    p6_a27 := ddx_tqlv_rec.attribute14;
    p6_a28 := ddx_tqlv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_tqlv_rec.org_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_tqlv_rec.request_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_application_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_tqlv_rec.program_id);
    p6_a33 := ddx_tqlv_rec.program_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_tqlv_rec.created_by);
    p6_a35 := ddx_tqlv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_updated_by);
    p6_a37 := ddx_tqlv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_tqlv_rec.last_update_login);
    p6_a39 := ddx_tqlv_rec.start_date;
    p6_a40 := ddx_tqlv_rec.period;
    p6_a41 := rosetta_g_miss_num_map(ddx_tqlv_rec.number_of_periods);
    p6_a42 := ddx_tqlv_rec.lock_level_step;
    p6_a43 := ddx_tqlv_rec.advance_or_arrears;
    p6_a44 := ddx_tqlv_rec.yield_name;
    p6_a45 := rosetta_g_miss_num_map(ddx_tqlv_rec.yield_value);
    p6_a46 := rosetta_g_miss_num_map(ddx_tqlv_rec.implicit_interest_rate);
    p6_a47 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_value);
    p6_a48 := rosetta_g_miss_num_map(ddx_tqlv_rec.residual_value);
    p6_a49 := rosetta_g_miss_num_map(ddx_tqlv_rec.unbilled_receivables);
    p6_a50 := rosetta_g_miss_num_map(ddx_tqlv_rec.asset_quantity);
    p6_a51 := rosetta_g_miss_num_map(ddx_tqlv_rec.quote_quantity);
    p6_a52 := rosetta_g_miss_num_map(ddx_tqlv_rec.split_kle_id);
    p6_a53 := ddx_tqlv_rec.split_kle_name;
    p6_a54 := ddx_tqlv_rec.currency_code;
    p6_a55 := ddx_tqlv_rec.currency_conversion_code;
    p6_a56 := ddx_tqlv_rec.currency_conversion_type;
    p6_a57 := rosetta_g_miss_num_map(ddx_tqlv_rec.currency_conversion_rate);
    p6_a58 := ddx_tqlv_rec.currency_conversion_date;
    p6_a59 := ddx_tqlv_rec.due_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_tqlv_rec.try_id);
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddx_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p6_a0
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
      , p6_a58
      , p6_a59
      , p6_a60
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
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);

    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl);

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
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_tqlv_rec okl_tql_pvt.tqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tqlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tqlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tqlv_rec.sfwt_flag := p5_a2;
    ddp_tqlv_rec.qlt_code := p5_a3;
    ddp_tqlv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tqlv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tqlv_rec.qte_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tqlv_rec.line_number := rosetta_g_miss_num_map(p5_a7);
    ddp_tqlv_rec.description := p5_a8;
    ddp_tqlv_rec.amount := rosetta_g_miss_num_map(p5_a9);
    ddp_tqlv_rec.modified_yn := p5_a10;
    ddp_tqlv_rec.taxed_yn := p5_a11;
    ddp_tqlv_rec.defaulted_yn := p5_a12;
    ddp_tqlv_rec.attribute_category := p5_a13;
    ddp_tqlv_rec.attribute1 := p5_a14;
    ddp_tqlv_rec.attribute2 := p5_a15;
    ddp_tqlv_rec.attribute3 := p5_a16;
    ddp_tqlv_rec.attribute4 := p5_a17;
    ddp_tqlv_rec.attribute5 := p5_a18;
    ddp_tqlv_rec.attribute6 := p5_a19;
    ddp_tqlv_rec.attribute7 := p5_a20;
    ddp_tqlv_rec.attribute8 := p5_a21;
    ddp_tqlv_rec.attribute9 := p5_a22;
    ddp_tqlv_rec.attribute10 := p5_a23;
    ddp_tqlv_rec.attribute11 := p5_a24;
    ddp_tqlv_rec.attribute12 := p5_a25;
    ddp_tqlv_rec.attribute13 := p5_a26;
    ddp_tqlv_rec.attribute14 := p5_a27;
    ddp_tqlv_rec.attribute15 := p5_a28;
    ddp_tqlv_rec.org_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tqlv_rec.request_id := rosetta_g_miss_num_map(p5_a30);
    ddp_tqlv_rec.program_application_id := rosetta_g_miss_num_map(p5_a31);
    ddp_tqlv_rec.program_id := rosetta_g_miss_num_map(p5_a32);
    ddp_tqlv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tqlv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_tqlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tqlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_tqlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_tqlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_tqlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tqlv_rec.period := p5_a40;
    ddp_tqlv_rec.number_of_periods := rosetta_g_miss_num_map(p5_a41);
    ddp_tqlv_rec.lock_level_step := p5_a42;
    ddp_tqlv_rec.advance_or_arrears := p5_a43;
    ddp_tqlv_rec.yield_name := p5_a44;
    ddp_tqlv_rec.yield_value := rosetta_g_miss_num_map(p5_a45);
    ddp_tqlv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a46);
    ddp_tqlv_rec.asset_value := rosetta_g_miss_num_map(p5_a47);
    ddp_tqlv_rec.residual_value := rosetta_g_miss_num_map(p5_a48);
    ddp_tqlv_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a49);
    ddp_tqlv_rec.asset_quantity := rosetta_g_miss_num_map(p5_a50);
    ddp_tqlv_rec.quote_quantity := rosetta_g_miss_num_map(p5_a51);
    ddp_tqlv_rec.split_kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tqlv_rec.split_kle_name := p5_a53;
    ddp_tqlv_rec.currency_code := p5_a54;
    ddp_tqlv_rec.currency_conversion_code := p5_a55;
    ddp_tqlv_rec.currency_conversion_type := p5_a56;
    ddp_tqlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a57);
    ddp_tqlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tqlv_rec.due_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_tqlv_rec.try_id := rosetta_g_miss_num_map(p5_a60);

    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_row_bulk(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddx_tqlv_tbl okl_tql_pvt.tqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tql_pvt_w.rosetta_table_copy_in_p8(ddp_tqlv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tql_pvt.insert_row_bulk(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tqlv_tbl,
      ddx_tqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tql_pvt_w.rosetta_table_copy_out_p8(ddx_tqlv_tbl, p6_a0
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
      , p6_a58
      , p6_a59
      , p6_a60
      );
  end;

end okl_tql_pvt_w;

/
