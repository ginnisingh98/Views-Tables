--------------------------------------------------------
--  DDL for Package Body OKL_SFE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SFE_PVT_W" as
  /* $Header: OKLISFEB.pls 120.3 2005/10/11 06:38:53 rgooty noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_sfe_pvt.sfe_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
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
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_VARCHAR2_TABLE_500
    , a44 JTF_VARCHAR2_TABLE_500
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_VARCHAR2_TABLE_500
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_500
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_DATE_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).sfe_type := a1(indx);
          t(ddindx).date_start := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).date_paid := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).idc_accounting_flag := a5(indx);
          t(ddindx).income_or_expense := a6(indx);
          t(ddindx).description := a7(indx);
          t(ddindx).fee_index_number := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).level_index_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).advance_or_arrears := a10(indx);
          t(ddindx).level_type := a11(indx);
          t(ddindx).lock_level_step := a12(indx);
          t(ddindx).period := a13(indx);
          t(ddindx).number_of_periods := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).level_line_number := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).sif_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).sil_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).rate := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).query_level_yn := a20(indx);
          t(ddindx).structure := a21(indx);
          t(ddindx).days_in_period := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).cash_effect_yn := a24(indx);
          t(ddindx).tax_effect_yn := a25(indx);
          t(ddindx).days_in_month := a26(indx);
          t(ddindx).days_in_year := a27(indx);
          t(ddindx).balance_type_code := a28(indx);
          t(ddindx).stream_interface_attribute01 := a29(indx);
          t(ddindx).stream_interface_attribute02 := a30(indx);
          t(ddindx).stream_interface_attribute03 := a31(indx);
          t(ddindx).stream_interface_attribute04 := a32(indx);
          t(ddindx).stream_interface_attribute05 := a33(indx);
          t(ddindx).stream_interface_attribute06 := a34(indx);
          t(ddindx).stream_interface_attribute07 := a35(indx);
          t(ddindx).stream_interface_attribute08 := a36(indx);
          t(ddindx).stream_interface_attribute09 := a37(indx);
          t(ddindx).stream_interface_attribute10 := a38(indx);
          t(ddindx).stream_interface_attribute11 := a39(indx);
          t(ddindx).stream_interface_attribute12 := a40(indx);
          t(ddindx).stream_interface_attribute13 := a41(indx);
          t(ddindx).stream_interface_attribute14 := a42(indx);
          t(ddindx).stream_interface_attribute15 := a43(indx);
          t(ddindx).stream_interface_attribute16 := a44(indx);
          t(ddindx).stream_interface_attribute17 := a45(indx);
          t(ddindx).stream_interface_attribute18 := a46(indx);
          t(ddindx).stream_interface_attribute19 := a47(indx);
          t(ddindx).stream_interface_attribute20 := a48(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a51(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).down_payment_amount := rosetta_g_miss_num_map(a54(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_sfe_pvt.sfe_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_VARCHAR2_TABLE_500
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_VARCHAR2_TABLE_500
    , a47 out nocopy JTF_VARCHAR2_TABLE_500
    , a48 out nocopy JTF_VARCHAR2_TABLE_500
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_DATE_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
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
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_VARCHAR2_TABLE_500();
    a44 := JTF_VARCHAR2_TABLE_500();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_VARCHAR2_TABLE_500();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_500();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_DATE_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
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
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_VARCHAR2_TABLE_500();
      a44 := JTF_VARCHAR2_TABLE_500();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_VARCHAR2_TABLE_500();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_500();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_DATE_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).sfe_type;
          a2(indx) := t(ddindx).date_start;
          a3(indx) := t(ddindx).date_paid;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a5(indx) := t(ddindx).idc_accounting_flag;
          a6(indx) := t(ddindx).income_or_expense;
          a7(indx) := t(ddindx).description;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).fee_index_number);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).level_index_number);
          a10(indx) := t(ddindx).advance_or_arrears;
          a11(indx) := t(ddindx).level_type;
          a12(indx) := t(ddindx).lock_level_step;
          a13(indx) := t(ddindx).period;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_periods);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).level_line_number);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).sif_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).sil_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).rate);
          a20(indx) := t(ddindx).query_level_yn;
          a21(indx) := t(ddindx).structure;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).days_in_period);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a24(indx) := t(ddindx).cash_effect_yn;
          a25(indx) := t(ddindx).tax_effect_yn;
          a26(indx) := t(ddindx).days_in_month;
          a27(indx) := t(ddindx).days_in_year;
          a28(indx) := t(ddindx).balance_type_code;
          a29(indx) := t(ddindx).stream_interface_attribute01;
          a30(indx) := t(ddindx).stream_interface_attribute02;
          a31(indx) := t(ddindx).stream_interface_attribute03;
          a32(indx) := t(ddindx).stream_interface_attribute04;
          a33(indx) := t(ddindx).stream_interface_attribute05;
          a34(indx) := t(ddindx).stream_interface_attribute06;
          a35(indx) := t(ddindx).stream_interface_attribute07;
          a36(indx) := t(ddindx).stream_interface_attribute08;
          a37(indx) := t(ddindx).stream_interface_attribute09;
          a38(indx) := t(ddindx).stream_interface_attribute10;
          a39(indx) := t(ddindx).stream_interface_attribute11;
          a40(indx) := t(ddindx).stream_interface_attribute12;
          a41(indx) := t(ddindx).stream_interface_attribute13;
          a42(indx) := t(ddindx).stream_interface_attribute14;
          a43(indx) := t(ddindx).stream_interface_attribute15;
          a44(indx) := t(ddindx).stream_interface_attribute16;
          a45(indx) := t(ddindx).stream_interface_attribute17;
          a46(indx) := t(ddindx).stream_interface_attribute18;
          a47(indx) := t(ddindx).stream_interface_attribute19;
          a48(indx) := t(ddindx).stream_interface_attribute20;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a51(indx) := t(ddindx).creation_date;
          a52(indx) := t(ddindx).last_update_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).down_payment_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_sfe_pvt.sfev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
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
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_VARCHAR2_TABLE_500
    , a44 JTF_VARCHAR2_TABLE_500
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_VARCHAR2_TABLE_500
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_500
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_DATE_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).sfe_type := a1(indx);
          t(ddindx).date_start := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).date_paid := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).idc_accounting_flag := a5(indx);
          t(ddindx).income_or_expense := a6(indx);
          t(ddindx).description := a7(indx);
          t(ddindx).fee_index_number := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).level_index_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).advance_or_arrears := a10(indx);
          t(ddindx).level_type := a11(indx);
          t(ddindx).lock_level_step := a12(indx);
          t(ddindx).period := a13(indx);
          t(ddindx).number_of_periods := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).level_line_number := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).sif_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).sil_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).rate := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).query_level_yn := a20(indx);
          t(ddindx).structure := a21(indx);
          t(ddindx).days_in_period := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).cash_effect_yn := a24(indx);
          t(ddindx).tax_effect_yn := a25(indx);
          t(ddindx).days_in_month := a26(indx);
          t(ddindx).days_in_year := a27(indx);
          t(ddindx).balance_type_code := a28(indx);
          t(ddindx).stream_interface_attribute01 := a29(indx);
          t(ddindx).stream_interface_attribute02 := a30(indx);
          t(ddindx).stream_interface_attribute03 := a31(indx);
          t(ddindx).stream_interface_attribute04 := a32(indx);
          t(ddindx).stream_interface_attribute05 := a33(indx);
          t(ddindx).stream_interface_attribute06 := a34(indx);
          t(ddindx).stream_interface_attribute07 := a35(indx);
          t(ddindx).stream_interface_attribute08 := a36(indx);
          t(ddindx).stream_interface_attribute09 := a37(indx);
          t(ddindx).stream_interface_attribute10 := a38(indx);
          t(ddindx).stream_interface_attribute11 := a39(indx);
          t(ddindx).stream_interface_attribute12 := a40(indx);
          t(ddindx).stream_interface_attribute13 := a41(indx);
          t(ddindx).stream_interface_attribute14 := a42(indx);
          t(ddindx).stream_interface_attribute15 := a43(indx);
          t(ddindx).stream_interface_attribute16 := a44(indx);
          t(ddindx).stream_interface_attribute17 := a45(indx);
          t(ddindx).stream_interface_attribute18 := a46(indx);
          t(ddindx).stream_interface_attribute19 := a47(indx);
          t(ddindx).stream_interface_attribute20 := a48(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a51(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).down_payment_amount := rosetta_g_miss_num_map(a54(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_sfe_pvt.sfev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_VARCHAR2_TABLE_500
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_VARCHAR2_TABLE_500
    , a47 out nocopy JTF_VARCHAR2_TABLE_500
    , a48 out nocopy JTF_VARCHAR2_TABLE_500
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_DATE_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
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
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_VARCHAR2_TABLE_500();
    a44 := JTF_VARCHAR2_TABLE_500();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_VARCHAR2_TABLE_500();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_500();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_DATE_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
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
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_VARCHAR2_TABLE_500();
      a44 := JTF_VARCHAR2_TABLE_500();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_VARCHAR2_TABLE_500();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_500();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_DATE_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).sfe_type;
          a2(indx) := t(ddindx).date_start;
          a3(indx) := t(ddindx).date_paid;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a5(indx) := t(ddindx).idc_accounting_flag;
          a6(indx) := t(ddindx).income_or_expense;
          a7(indx) := t(ddindx).description;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).fee_index_number);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).level_index_number);
          a10(indx) := t(ddindx).advance_or_arrears;
          a11(indx) := t(ddindx).level_type;
          a12(indx) := t(ddindx).lock_level_step;
          a13(indx) := t(ddindx).period;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).number_of_periods);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).level_line_number);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).sif_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).sil_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).rate);
          a20(indx) := t(ddindx).query_level_yn;
          a21(indx) := t(ddindx).structure;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).days_in_period);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a24(indx) := t(ddindx).cash_effect_yn;
          a25(indx) := t(ddindx).tax_effect_yn;
          a26(indx) := t(ddindx).days_in_month;
          a27(indx) := t(ddindx).days_in_year;
          a28(indx) := t(ddindx).balance_type_code;
          a29(indx) := t(ddindx).stream_interface_attribute01;
          a30(indx) := t(ddindx).stream_interface_attribute02;
          a31(indx) := t(ddindx).stream_interface_attribute03;
          a32(indx) := t(ddindx).stream_interface_attribute04;
          a33(indx) := t(ddindx).stream_interface_attribute05;
          a34(indx) := t(ddindx).stream_interface_attribute06;
          a35(indx) := t(ddindx).stream_interface_attribute07;
          a36(indx) := t(ddindx).stream_interface_attribute08;
          a37(indx) := t(ddindx).stream_interface_attribute09;
          a38(indx) := t(ddindx).stream_interface_attribute10;
          a39(indx) := t(ddindx).stream_interface_attribute11;
          a40(indx) := t(ddindx).stream_interface_attribute12;
          a41(indx) := t(ddindx).stream_interface_attribute13;
          a42(indx) := t(ddindx).stream_interface_attribute14;
          a43(indx) := t(ddindx).stream_interface_attribute15;
          a44(indx) := t(ddindx).stream_interface_attribute16;
          a45(indx) := t(ddindx).stream_interface_attribute17;
          a46(indx) := t(ddindx).stream_interface_attribute18;
          a47(indx) := t(ddindx).stream_interface_attribute19;
          a48(indx) := t(ddindx).stream_interface_attribute20;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a51(indx) := t(ddindx).creation_date;
          a52(indx) := t(ddindx).last_update_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).down_payment_amount);
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
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
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
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
  )

  as
    ddp_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddx_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sfev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sfev_rec.sfe_type := p5_a1;
    ddp_sfev_rec.date_start := rosetta_g_miss_date_in_map(p5_a2);
    ddp_sfev_rec.date_paid := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sfev_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_sfev_rec.idc_accounting_flag := p5_a5;
    ddp_sfev_rec.income_or_expense := p5_a6;
    ddp_sfev_rec.description := p5_a7;
    ddp_sfev_rec.fee_index_number := rosetta_g_miss_num_map(p5_a8);
    ddp_sfev_rec.level_index_number := rosetta_g_miss_num_map(p5_a9);
    ddp_sfev_rec.advance_or_arrears := p5_a10;
    ddp_sfev_rec.level_type := p5_a11;
    ddp_sfev_rec.lock_level_step := p5_a12;
    ddp_sfev_rec.period := p5_a13;
    ddp_sfev_rec.number_of_periods := rosetta_g_miss_num_map(p5_a14);
    ddp_sfev_rec.level_line_number := rosetta_g_miss_num_map(p5_a15);
    ddp_sfev_rec.sif_id := rosetta_g_miss_num_map(p5_a16);
    ddp_sfev_rec.kle_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sfev_rec.sil_id := rosetta_g_miss_num_map(p5_a18);
    ddp_sfev_rec.rate := rosetta_g_miss_num_map(p5_a19);
    ddp_sfev_rec.query_level_yn := p5_a20;
    ddp_sfev_rec.structure := p5_a21;
    ddp_sfev_rec.days_in_period := rosetta_g_miss_num_map(p5_a22);
    ddp_sfev_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_sfev_rec.cash_effect_yn := p5_a24;
    ddp_sfev_rec.tax_effect_yn := p5_a25;
    ddp_sfev_rec.days_in_month := p5_a26;
    ddp_sfev_rec.days_in_year := p5_a27;
    ddp_sfev_rec.balance_type_code := p5_a28;
    ddp_sfev_rec.stream_interface_attribute01 := p5_a29;
    ddp_sfev_rec.stream_interface_attribute02 := p5_a30;
    ddp_sfev_rec.stream_interface_attribute03 := p5_a31;
    ddp_sfev_rec.stream_interface_attribute04 := p5_a32;
    ddp_sfev_rec.stream_interface_attribute05 := p5_a33;
    ddp_sfev_rec.stream_interface_attribute06 := p5_a34;
    ddp_sfev_rec.stream_interface_attribute07 := p5_a35;
    ddp_sfev_rec.stream_interface_attribute08 := p5_a36;
    ddp_sfev_rec.stream_interface_attribute09 := p5_a37;
    ddp_sfev_rec.stream_interface_attribute10 := p5_a38;
    ddp_sfev_rec.stream_interface_attribute11 := p5_a39;
    ddp_sfev_rec.stream_interface_attribute12 := p5_a40;
    ddp_sfev_rec.stream_interface_attribute13 := p5_a41;
    ddp_sfev_rec.stream_interface_attribute14 := p5_a42;
    ddp_sfev_rec.stream_interface_attribute15 := p5_a43;
    ddp_sfev_rec.stream_interface_attribute16 := p5_a44;
    ddp_sfev_rec.stream_interface_attribute17 := p5_a45;
    ddp_sfev_rec.stream_interface_attribute18 := p5_a46;
    ddp_sfev_rec.stream_interface_attribute19 := p5_a47;
    ddp_sfev_rec.stream_interface_attribute20 := p5_a48;
    ddp_sfev_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_sfev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a50);
    ddp_sfev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_sfev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_sfev_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_sfev_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a54);


    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_rec,
      ddx_sfev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sfev_rec.id);
    p6_a1 := ddx_sfev_rec.sfe_type;
    p6_a2 := ddx_sfev_rec.date_start;
    p6_a3 := ddx_sfev_rec.date_paid;
    p6_a4 := rosetta_g_miss_num_map(ddx_sfev_rec.amount);
    p6_a5 := ddx_sfev_rec.idc_accounting_flag;
    p6_a6 := ddx_sfev_rec.income_or_expense;
    p6_a7 := ddx_sfev_rec.description;
    p6_a8 := rosetta_g_miss_num_map(ddx_sfev_rec.fee_index_number);
    p6_a9 := rosetta_g_miss_num_map(ddx_sfev_rec.level_index_number);
    p6_a10 := ddx_sfev_rec.advance_or_arrears;
    p6_a11 := ddx_sfev_rec.level_type;
    p6_a12 := ddx_sfev_rec.lock_level_step;
    p6_a13 := ddx_sfev_rec.period;
    p6_a14 := rosetta_g_miss_num_map(ddx_sfev_rec.number_of_periods);
    p6_a15 := rosetta_g_miss_num_map(ddx_sfev_rec.level_line_number);
    p6_a16 := rosetta_g_miss_num_map(ddx_sfev_rec.sif_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_sfev_rec.kle_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_sfev_rec.sil_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_sfev_rec.rate);
    p6_a20 := ddx_sfev_rec.query_level_yn;
    p6_a21 := ddx_sfev_rec.structure;
    p6_a22 := rosetta_g_miss_num_map(ddx_sfev_rec.days_in_period);
    p6_a23 := rosetta_g_miss_num_map(ddx_sfev_rec.object_version_number);
    p6_a24 := ddx_sfev_rec.cash_effect_yn;
    p6_a25 := ddx_sfev_rec.tax_effect_yn;
    p6_a26 := ddx_sfev_rec.days_in_month;
    p6_a27 := ddx_sfev_rec.days_in_year;
    p6_a28 := ddx_sfev_rec.balance_type_code;
    p6_a29 := ddx_sfev_rec.stream_interface_attribute01;
    p6_a30 := ddx_sfev_rec.stream_interface_attribute02;
    p6_a31 := ddx_sfev_rec.stream_interface_attribute03;
    p6_a32 := ddx_sfev_rec.stream_interface_attribute04;
    p6_a33 := ddx_sfev_rec.stream_interface_attribute05;
    p6_a34 := ddx_sfev_rec.stream_interface_attribute06;
    p6_a35 := ddx_sfev_rec.stream_interface_attribute07;
    p6_a36 := ddx_sfev_rec.stream_interface_attribute08;
    p6_a37 := ddx_sfev_rec.stream_interface_attribute09;
    p6_a38 := ddx_sfev_rec.stream_interface_attribute10;
    p6_a39 := ddx_sfev_rec.stream_interface_attribute11;
    p6_a40 := ddx_sfev_rec.stream_interface_attribute12;
    p6_a41 := ddx_sfev_rec.stream_interface_attribute13;
    p6_a42 := ddx_sfev_rec.stream_interface_attribute14;
    p6_a43 := ddx_sfev_rec.stream_interface_attribute15;
    p6_a44 := ddx_sfev_rec.stream_interface_attribute16;
    p6_a45 := ddx_sfev_rec.stream_interface_attribute17;
    p6_a46 := ddx_sfev_rec.stream_interface_attribute18;
    p6_a47 := ddx_sfev_rec.stream_interface_attribute19;
    p6_a48 := ddx_sfev_rec.stream_interface_attribute20;
    p6_a49 := rosetta_g_miss_num_map(ddx_sfev_rec.created_by);
    p6_a50 := rosetta_g_miss_num_map(ddx_sfev_rec.last_updated_by);
    p6_a51 := ddx_sfev_rec.creation_date;
    p6_a52 := ddx_sfev_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_sfev_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_sfev_rec.down_payment_amount);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddx_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sfe_pvt_w.rosetta_table_copy_in_p5(ddp_sfev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_tbl,
      ddx_sfev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sfe_pvt_w.rosetta_table_copy_out_p5(ddx_sfev_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
  )

  as
    ddp_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sfev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sfev_rec.sfe_type := p5_a1;
    ddp_sfev_rec.date_start := rosetta_g_miss_date_in_map(p5_a2);
    ddp_sfev_rec.date_paid := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sfev_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_sfev_rec.idc_accounting_flag := p5_a5;
    ddp_sfev_rec.income_or_expense := p5_a6;
    ddp_sfev_rec.description := p5_a7;
    ddp_sfev_rec.fee_index_number := rosetta_g_miss_num_map(p5_a8);
    ddp_sfev_rec.level_index_number := rosetta_g_miss_num_map(p5_a9);
    ddp_sfev_rec.advance_or_arrears := p5_a10;
    ddp_sfev_rec.level_type := p5_a11;
    ddp_sfev_rec.lock_level_step := p5_a12;
    ddp_sfev_rec.period := p5_a13;
    ddp_sfev_rec.number_of_periods := rosetta_g_miss_num_map(p5_a14);
    ddp_sfev_rec.level_line_number := rosetta_g_miss_num_map(p5_a15);
    ddp_sfev_rec.sif_id := rosetta_g_miss_num_map(p5_a16);
    ddp_sfev_rec.kle_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sfev_rec.sil_id := rosetta_g_miss_num_map(p5_a18);
    ddp_sfev_rec.rate := rosetta_g_miss_num_map(p5_a19);
    ddp_sfev_rec.query_level_yn := p5_a20;
    ddp_sfev_rec.structure := p5_a21;
    ddp_sfev_rec.days_in_period := rosetta_g_miss_num_map(p5_a22);
    ddp_sfev_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_sfev_rec.cash_effect_yn := p5_a24;
    ddp_sfev_rec.tax_effect_yn := p5_a25;
    ddp_sfev_rec.days_in_month := p5_a26;
    ddp_sfev_rec.days_in_year := p5_a27;
    ddp_sfev_rec.balance_type_code := p5_a28;
    ddp_sfev_rec.stream_interface_attribute01 := p5_a29;
    ddp_sfev_rec.stream_interface_attribute02 := p5_a30;
    ddp_sfev_rec.stream_interface_attribute03 := p5_a31;
    ddp_sfev_rec.stream_interface_attribute04 := p5_a32;
    ddp_sfev_rec.stream_interface_attribute05 := p5_a33;
    ddp_sfev_rec.stream_interface_attribute06 := p5_a34;
    ddp_sfev_rec.stream_interface_attribute07 := p5_a35;
    ddp_sfev_rec.stream_interface_attribute08 := p5_a36;
    ddp_sfev_rec.stream_interface_attribute09 := p5_a37;
    ddp_sfev_rec.stream_interface_attribute10 := p5_a38;
    ddp_sfev_rec.stream_interface_attribute11 := p5_a39;
    ddp_sfev_rec.stream_interface_attribute12 := p5_a40;
    ddp_sfev_rec.stream_interface_attribute13 := p5_a41;
    ddp_sfev_rec.stream_interface_attribute14 := p5_a42;
    ddp_sfev_rec.stream_interface_attribute15 := p5_a43;
    ddp_sfev_rec.stream_interface_attribute16 := p5_a44;
    ddp_sfev_rec.stream_interface_attribute17 := p5_a45;
    ddp_sfev_rec.stream_interface_attribute18 := p5_a46;
    ddp_sfev_rec.stream_interface_attribute19 := p5_a47;
    ddp_sfev_rec.stream_interface_attribute20 := p5_a48;
    ddp_sfev_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_sfev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a50);
    ddp_sfev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_sfev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_sfev_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_sfev_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a54);

    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
  )

  as
    ddp_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sfe_pvt_w.rosetta_table_copy_in_p5(ddp_sfev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
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
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
  )

  as
    ddp_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddx_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sfev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sfev_rec.sfe_type := p5_a1;
    ddp_sfev_rec.date_start := rosetta_g_miss_date_in_map(p5_a2);
    ddp_sfev_rec.date_paid := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sfev_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_sfev_rec.idc_accounting_flag := p5_a5;
    ddp_sfev_rec.income_or_expense := p5_a6;
    ddp_sfev_rec.description := p5_a7;
    ddp_sfev_rec.fee_index_number := rosetta_g_miss_num_map(p5_a8);
    ddp_sfev_rec.level_index_number := rosetta_g_miss_num_map(p5_a9);
    ddp_sfev_rec.advance_or_arrears := p5_a10;
    ddp_sfev_rec.level_type := p5_a11;
    ddp_sfev_rec.lock_level_step := p5_a12;
    ddp_sfev_rec.period := p5_a13;
    ddp_sfev_rec.number_of_periods := rosetta_g_miss_num_map(p5_a14);
    ddp_sfev_rec.level_line_number := rosetta_g_miss_num_map(p5_a15);
    ddp_sfev_rec.sif_id := rosetta_g_miss_num_map(p5_a16);
    ddp_sfev_rec.kle_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sfev_rec.sil_id := rosetta_g_miss_num_map(p5_a18);
    ddp_sfev_rec.rate := rosetta_g_miss_num_map(p5_a19);
    ddp_sfev_rec.query_level_yn := p5_a20;
    ddp_sfev_rec.structure := p5_a21;
    ddp_sfev_rec.days_in_period := rosetta_g_miss_num_map(p5_a22);
    ddp_sfev_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_sfev_rec.cash_effect_yn := p5_a24;
    ddp_sfev_rec.tax_effect_yn := p5_a25;
    ddp_sfev_rec.days_in_month := p5_a26;
    ddp_sfev_rec.days_in_year := p5_a27;
    ddp_sfev_rec.balance_type_code := p5_a28;
    ddp_sfev_rec.stream_interface_attribute01 := p5_a29;
    ddp_sfev_rec.stream_interface_attribute02 := p5_a30;
    ddp_sfev_rec.stream_interface_attribute03 := p5_a31;
    ddp_sfev_rec.stream_interface_attribute04 := p5_a32;
    ddp_sfev_rec.stream_interface_attribute05 := p5_a33;
    ddp_sfev_rec.stream_interface_attribute06 := p5_a34;
    ddp_sfev_rec.stream_interface_attribute07 := p5_a35;
    ddp_sfev_rec.stream_interface_attribute08 := p5_a36;
    ddp_sfev_rec.stream_interface_attribute09 := p5_a37;
    ddp_sfev_rec.stream_interface_attribute10 := p5_a38;
    ddp_sfev_rec.stream_interface_attribute11 := p5_a39;
    ddp_sfev_rec.stream_interface_attribute12 := p5_a40;
    ddp_sfev_rec.stream_interface_attribute13 := p5_a41;
    ddp_sfev_rec.stream_interface_attribute14 := p5_a42;
    ddp_sfev_rec.stream_interface_attribute15 := p5_a43;
    ddp_sfev_rec.stream_interface_attribute16 := p5_a44;
    ddp_sfev_rec.stream_interface_attribute17 := p5_a45;
    ddp_sfev_rec.stream_interface_attribute18 := p5_a46;
    ddp_sfev_rec.stream_interface_attribute19 := p5_a47;
    ddp_sfev_rec.stream_interface_attribute20 := p5_a48;
    ddp_sfev_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_sfev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a50);
    ddp_sfev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_sfev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_sfev_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_sfev_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a54);


    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_rec,
      ddx_sfev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sfev_rec.id);
    p6_a1 := ddx_sfev_rec.sfe_type;
    p6_a2 := ddx_sfev_rec.date_start;
    p6_a3 := ddx_sfev_rec.date_paid;
    p6_a4 := rosetta_g_miss_num_map(ddx_sfev_rec.amount);
    p6_a5 := ddx_sfev_rec.idc_accounting_flag;
    p6_a6 := ddx_sfev_rec.income_or_expense;
    p6_a7 := ddx_sfev_rec.description;
    p6_a8 := rosetta_g_miss_num_map(ddx_sfev_rec.fee_index_number);
    p6_a9 := rosetta_g_miss_num_map(ddx_sfev_rec.level_index_number);
    p6_a10 := ddx_sfev_rec.advance_or_arrears;
    p6_a11 := ddx_sfev_rec.level_type;
    p6_a12 := ddx_sfev_rec.lock_level_step;
    p6_a13 := ddx_sfev_rec.period;
    p6_a14 := rosetta_g_miss_num_map(ddx_sfev_rec.number_of_periods);
    p6_a15 := rosetta_g_miss_num_map(ddx_sfev_rec.level_line_number);
    p6_a16 := rosetta_g_miss_num_map(ddx_sfev_rec.sif_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_sfev_rec.kle_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_sfev_rec.sil_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_sfev_rec.rate);
    p6_a20 := ddx_sfev_rec.query_level_yn;
    p6_a21 := ddx_sfev_rec.structure;
    p6_a22 := rosetta_g_miss_num_map(ddx_sfev_rec.days_in_period);
    p6_a23 := rosetta_g_miss_num_map(ddx_sfev_rec.object_version_number);
    p6_a24 := ddx_sfev_rec.cash_effect_yn;
    p6_a25 := ddx_sfev_rec.tax_effect_yn;
    p6_a26 := ddx_sfev_rec.days_in_month;
    p6_a27 := ddx_sfev_rec.days_in_year;
    p6_a28 := ddx_sfev_rec.balance_type_code;
    p6_a29 := ddx_sfev_rec.stream_interface_attribute01;
    p6_a30 := ddx_sfev_rec.stream_interface_attribute02;
    p6_a31 := ddx_sfev_rec.stream_interface_attribute03;
    p6_a32 := ddx_sfev_rec.stream_interface_attribute04;
    p6_a33 := ddx_sfev_rec.stream_interface_attribute05;
    p6_a34 := ddx_sfev_rec.stream_interface_attribute06;
    p6_a35 := ddx_sfev_rec.stream_interface_attribute07;
    p6_a36 := ddx_sfev_rec.stream_interface_attribute08;
    p6_a37 := ddx_sfev_rec.stream_interface_attribute09;
    p6_a38 := ddx_sfev_rec.stream_interface_attribute10;
    p6_a39 := ddx_sfev_rec.stream_interface_attribute11;
    p6_a40 := ddx_sfev_rec.stream_interface_attribute12;
    p6_a41 := ddx_sfev_rec.stream_interface_attribute13;
    p6_a42 := ddx_sfev_rec.stream_interface_attribute14;
    p6_a43 := ddx_sfev_rec.stream_interface_attribute15;
    p6_a44 := ddx_sfev_rec.stream_interface_attribute16;
    p6_a45 := ddx_sfev_rec.stream_interface_attribute17;
    p6_a46 := ddx_sfev_rec.stream_interface_attribute18;
    p6_a47 := ddx_sfev_rec.stream_interface_attribute19;
    p6_a48 := ddx_sfev_rec.stream_interface_attribute20;
    p6_a49 := rosetta_g_miss_num_map(ddx_sfev_rec.created_by);
    p6_a50 := rosetta_g_miss_num_map(ddx_sfev_rec.last_updated_by);
    p6_a51 := ddx_sfev_rec.creation_date;
    p6_a52 := ddx_sfev_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_sfev_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_sfev_rec.down_payment_amount);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddx_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sfe_pvt_w.rosetta_table_copy_in_p5(ddp_sfev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_tbl,
      ddx_sfev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sfe_pvt_w.rosetta_table_copy_out_p5(ddx_sfev_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
  )

  as
    ddp_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sfev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sfev_rec.sfe_type := p5_a1;
    ddp_sfev_rec.date_start := rosetta_g_miss_date_in_map(p5_a2);
    ddp_sfev_rec.date_paid := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sfev_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_sfev_rec.idc_accounting_flag := p5_a5;
    ddp_sfev_rec.income_or_expense := p5_a6;
    ddp_sfev_rec.description := p5_a7;
    ddp_sfev_rec.fee_index_number := rosetta_g_miss_num_map(p5_a8);
    ddp_sfev_rec.level_index_number := rosetta_g_miss_num_map(p5_a9);
    ddp_sfev_rec.advance_or_arrears := p5_a10;
    ddp_sfev_rec.level_type := p5_a11;
    ddp_sfev_rec.lock_level_step := p5_a12;
    ddp_sfev_rec.period := p5_a13;
    ddp_sfev_rec.number_of_periods := rosetta_g_miss_num_map(p5_a14);
    ddp_sfev_rec.level_line_number := rosetta_g_miss_num_map(p5_a15);
    ddp_sfev_rec.sif_id := rosetta_g_miss_num_map(p5_a16);
    ddp_sfev_rec.kle_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sfev_rec.sil_id := rosetta_g_miss_num_map(p5_a18);
    ddp_sfev_rec.rate := rosetta_g_miss_num_map(p5_a19);
    ddp_sfev_rec.query_level_yn := p5_a20;
    ddp_sfev_rec.structure := p5_a21;
    ddp_sfev_rec.days_in_period := rosetta_g_miss_num_map(p5_a22);
    ddp_sfev_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_sfev_rec.cash_effect_yn := p5_a24;
    ddp_sfev_rec.tax_effect_yn := p5_a25;
    ddp_sfev_rec.days_in_month := p5_a26;
    ddp_sfev_rec.days_in_year := p5_a27;
    ddp_sfev_rec.balance_type_code := p5_a28;
    ddp_sfev_rec.stream_interface_attribute01 := p5_a29;
    ddp_sfev_rec.stream_interface_attribute02 := p5_a30;
    ddp_sfev_rec.stream_interface_attribute03 := p5_a31;
    ddp_sfev_rec.stream_interface_attribute04 := p5_a32;
    ddp_sfev_rec.stream_interface_attribute05 := p5_a33;
    ddp_sfev_rec.stream_interface_attribute06 := p5_a34;
    ddp_sfev_rec.stream_interface_attribute07 := p5_a35;
    ddp_sfev_rec.stream_interface_attribute08 := p5_a36;
    ddp_sfev_rec.stream_interface_attribute09 := p5_a37;
    ddp_sfev_rec.stream_interface_attribute10 := p5_a38;
    ddp_sfev_rec.stream_interface_attribute11 := p5_a39;
    ddp_sfev_rec.stream_interface_attribute12 := p5_a40;
    ddp_sfev_rec.stream_interface_attribute13 := p5_a41;
    ddp_sfev_rec.stream_interface_attribute14 := p5_a42;
    ddp_sfev_rec.stream_interface_attribute15 := p5_a43;
    ddp_sfev_rec.stream_interface_attribute16 := p5_a44;
    ddp_sfev_rec.stream_interface_attribute17 := p5_a45;
    ddp_sfev_rec.stream_interface_attribute18 := p5_a46;
    ddp_sfev_rec.stream_interface_attribute19 := p5_a47;
    ddp_sfev_rec.stream_interface_attribute20 := p5_a48;
    ddp_sfev_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_sfev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a50);
    ddp_sfev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_sfev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_sfev_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_sfev_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a54);

    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
  )

  as
    ddp_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sfe_pvt_w.rosetta_table_copy_in_p5(ddp_sfev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
  )

  as
    ddp_sfev_rec okl_sfe_pvt.sfev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sfev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sfev_rec.sfe_type := p5_a1;
    ddp_sfev_rec.date_start := rosetta_g_miss_date_in_map(p5_a2);
    ddp_sfev_rec.date_paid := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sfev_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_sfev_rec.idc_accounting_flag := p5_a5;
    ddp_sfev_rec.income_or_expense := p5_a6;
    ddp_sfev_rec.description := p5_a7;
    ddp_sfev_rec.fee_index_number := rosetta_g_miss_num_map(p5_a8);
    ddp_sfev_rec.level_index_number := rosetta_g_miss_num_map(p5_a9);
    ddp_sfev_rec.advance_or_arrears := p5_a10;
    ddp_sfev_rec.level_type := p5_a11;
    ddp_sfev_rec.lock_level_step := p5_a12;
    ddp_sfev_rec.period := p5_a13;
    ddp_sfev_rec.number_of_periods := rosetta_g_miss_num_map(p5_a14);
    ddp_sfev_rec.level_line_number := rosetta_g_miss_num_map(p5_a15);
    ddp_sfev_rec.sif_id := rosetta_g_miss_num_map(p5_a16);
    ddp_sfev_rec.kle_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sfev_rec.sil_id := rosetta_g_miss_num_map(p5_a18);
    ddp_sfev_rec.rate := rosetta_g_miss_num_map(p5_a19);
    ddp_sfev_rec.query_level_yn := p5_a20;
    ddp_sfev_rec.structure := p5_a21;
    ddp_sfev_rec.days_in_period := rosetta_g_miss_num_map(p5_a22);
    ddp_sfev_rec.object_version_number := rosetta_g_miss_num_map(p5_a23);
    ddp_sfev_rec.cash_effect_yn := p5_a24;
    ddp_sfev_rec.tax_effect_yn := p5_a25;
    ddp_sfev_rec.days_in_month := p5_a26;
    ddp_sfev_rec.days_in_year := p5_a27;
    ddp_sfev_rec.balance_type_code := p5_a28;
    ddp_sfev_rec.stream_interface_attribute01 := p5_a29;
    ddp_sfev_rec.stream_interface_attribute02 := p5_a30;
    ddp_sfev_rec.stream_interface_attribute03 := p5_a31;
    ddp_sfev_rec.stream_interface_attribute04 := p5_a32;
    ddp_sfev_rec.stream_interface_attribute05 := p5_a33;
    ddp_sfev_rec.stream_interface_attribute06 := p5_a34;
    ddp_sfev_rec.stream_interface_attribute07 := p5_a35;
    ddp_sfev_rec.stream_interface_attribute08 := p5_a36;
    ddp_sfev_rec.stream_interface_attribute09 := p5_a37;
    ddp_sfev_rec.stream_interface_attribute10 := p5_a38;
    ddp_sfev_rec.stream_interface_attribute11 := p5_a39;
    ddp_sfev_rec.stream_interface_attribute12 := p5_a40;
    ddp_sfev_rec.stream_interface_attribute13 := p5_a41;
    ddp_sfev_rec.stream_interface_attribute14 := p5_a42;
    ddp_sfev_rec.stream_interface_attribute15 := p5_a43;
    ddp_sfev_rec.stream_interface_attribute16 := p5_a44;
    ddp_sfev_rec.stream_interface_attribute17 := p5_a45;
    ddp_sfev_rec.stream_interface_attribute18 := p5_a46;
    ddp_sfev_rec.stream_interface_attribute19 := p5_a47;
    ddp_sfev_rec.stream_interface_attribute20 := p5_a48;
    ddp_sfev_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_sfev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a50);
    ddp_sfev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_sfev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_sfev_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_sfev_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a54);

    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
  )

  as
    ddp_sfev_tbl okl_sfe_pvt.sfev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sfe_pvt_w.rosetta_table_copy_in_p5(ddp_sfev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sfe_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sfev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sfe_pvt_w;

/
