--------------------------------------------------------
--  DDL for Package Body OKL_KRP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KRP_PVT_W" as
  /* $Header: OKLEKRPB.pls 120.2 2005/11/22 23:40:01 ramurt noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_krp_pvt.krpv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_DATE_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
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
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).khr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parameter_type_code := a1(indx);
          t(ddindx).effective_from_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).effective_to_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).interest_index_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).base_rate := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).interest_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).adder_rate := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).maximum_rate := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).minimum_rate := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).principal_basis_code := a10(indx);
          t(ddindx).days_in_a_month_code := a11(indx);
          t(ddindx).days_in_a_year_code := a12(indx);
          t(ddindx).interest_basis_code := a13(indx);
          t(ddindx).rate_delay_code := a14(indx);
          t(ddindx).rate_delay_frequency := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).compounding_frequency_code := a16(indx);
          t(ddindx).calculation_formula_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).catchup_basis_code := a18(indx);
          t(ddindx).catchup_start_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).catchup_settlement_code := a20(indx);
          t(ddindx).rate_change_start_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).rate_change_frequency_code := a22(indx);
          t(ddindx).rate_change_value := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).conversion_option_code := a24(indx);
          t(ddindx).next_conversion_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).conversion_type_code := a26(indx);
          t(ddindx).attribute_category := a27(indx);
          t(ddindx).attribute1 := a28(indx);
          t(ddindx).attribute2 := a29(indx);
          t(ddindx).attribute3 := a30(indx);
          t(ddindx).attribute4 := a31(indx);
          t(ddindx).attribute5 := a32(indx);
          t(ddindx).attribute6 := a33(indx);
          t(ddindx).attribute7 := a34(indx);
          t(ddindx).attribute8 := a35(indx);
          t(ddindx).attribute9 := a36(indx);
          t(ddindx).attribute10 := a37(indx);
          t(ddindx).attribute11 := a38(indx);
          t(ddindx).attribute12 := a39(indx);
          t(ddindx).attribute13 := a40(indx);
          t(ddindx).attribute14 := a41(indx);
          t(ddindx).attribute15 := a42(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).catchup_frequency_code := a48(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_krp_pvt.krpv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
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
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
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
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a1(indx) := t(ddindx).parameter_type_code;
          a2(indx) := t(ddindx).effective_from_date;
          a3(indx) := t(ddindx).effective_to_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).interest_index_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).base_rate);
          a6(indx) := t(ddindx).interest_start_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).adder_rate);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_rate);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).minimum_rate);
          a10(indx) := t(ddindx).principal_basis_code;
          a11(indx) := t(ddindx).days_in_a_month_code;
          a12(indx) := t(ddindx).days_in_a_year_code;
          a13(indx) := t(ddindx).interest_basis_code;
          a14(indx) := t(ddindx).rate_delay_code;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).rate_delay_frequency);
          a16(indx) := t(ddindx).compounding_frequency_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).calculation_formula_id);
          a18(indx) := t(ddindx).catchup_basis_code;
          a19(indx) := t(ddindx).catchup_start_date;
          a20(indx) := t(ddindx).catchup_settlement_code;
          a21(indx) := t(ddindx).rate_change_start_date;
          a22(indx) := t(ddindx).rate_change_frequency_code;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).rate_change_value);
          a24(indx) := t(ddindx).conversion_option_code;
          a25(indx) := t(ddindx).next_conversion_date;
          a26(indx) := t(ddindx).conversion_type_code;
          a27(indx) := t(ddindx).attribute_category;
          a28(indx) := t(ddindx).attribute1;
          a29(indx) := t(ddindx).attribute2;
          a30(indx) := t(ddindx).attribute3;
          a31(indx) := t(ddindx).attribute4;
          a32(indx) := t(ddindx).attribute5;
          a33(indx) := t(ddindx).attribute6;
          a34(indx) := t(ddindx).attribute7;
          a35(indx) := t(ddindx).attribute8;
          a36(indx) := t(ddindx).attribute9;
          a37(indx) := t(ddindx).attribute10;
          a38(indx) := t(ddindx).attribute11;
          a39(indx) := t(ddindx).attribute12;
          a40(indx) := t(ddindx).attribute13;
          a41(indx) := t(ddindx).attribute14;
          a42(indx) := t(ddindx).attribute15;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a44(indx) := t(ddindx).creation_date;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a46(indx) := t(ddindx).last_update_date;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a48(indx) := t(ddindx).catchup_frequency_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_krp_pvt.krp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_DATE_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
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
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).khr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parameter_type_code := a1(indx);
          t(ddindx).effective_from_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).effective_to_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).interest_index_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).base_rate := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).interest_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).adder_rate := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).maximum_rate := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).minimum_rate := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).principal_basis_code := a10(indx);
          t(ddindx).days_in_a_month_code := a11(indx);
          t(ddindx).days_in_a_year_code := a12(indx);
          t(ddindx).interest_basis_code := a13(indx);
          t(ddindx).rate_delay_code := a14(indx);
          t(ddindx).rate_delay_frequency := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).compounding_frequency_code := a16(indx);
          t(ddindx).calculation_formula_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).catchup_basis_code := a18(indx);
          t(ddindx).catchup_start_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).catchup_settlement_code := a20(indx);
          t(ddindx).rate_change_start_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).rate_change_frequency_code := a22(indx);
          t(ddindx).rate_change_value := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).conversion_option_code := a24(indx);
          t(ddindx).next_conversion_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).conversion_type_code := a26(indx);
          t(ddindx).attribute_category := a27(indx);
          t(ddindx).attribute1 := a28(indx);
          t(ddindx).attribute2 := a29(indx);
          t(ddindx).attribute3 := a30(indx);
          t(ddindx).attribute4 := a31(indx);
          t(ddindx).attribute5 := a32(indx);
          t(ddindx).attribute6 := a33(indx);
          t(ddindx).attribute7 := a34(indx);
          t(ddindx).attribute8 := a35(indx);
          t(ddindx).attribute9 := a36(indx);
          t(ddindx).attribute10 := a37(indx);
          t(ddindx).attribute11 := a38(indx);
          t(ddindx).attribute12 := a39(indx);
          t(ddindx).attribute13 := a40(indx);
          t(ddindx).attribute14 := a41(indx);
          t(ddindx).attribute15 := a42(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).catchup_frequency_code := a48(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_krp_pvt.krp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
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
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
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
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a1(indx) := t(ddindx).parameter_type_code;
          a2(indx) := t(ddindx).effective_from_date;
          a3(indx) := t(ddindx).effective_to_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).interest_index_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).base_rate);
          a6(indx) := t(ddindx).interest_start_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).adder_rate);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_rate);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).minimum_rate);
          a10(indx) := t(ddindx).principal_basis_code;
          a11(indx) := t(ddindx).days_in_a_month_code;
          a12(indx) := t(ddindx).days_in_a_year_code;
          a13(indx) := t(ddindx).interest_basis_code;
          a14(indx) := t(ddindx).rate_delay_code;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).rate_delay_frequency);
          a16(indx) := t(ddindx).compounding_frequency_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).calculation_formula_id);
          a18(indx) := t(ddindx).catchup_basis_code;
          a19(indx) := t(ddindx).catchup_start_date;
          a20(indx) := t(ddindx).catchup_settlement_code;
          a21(indx) := t(ddindx).rate_change_start_date;
          a22(indx) := t(ddindx).rate_change_frequency_code;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).rate_change_value);
          a24(indx) := t(ddindx).conversion_option_code;
          a25(indx) := t(ddindx).next_conversion_date;
          a26(indx) := t(ddindx).conversion_type_code;
          a27(indx) := t(ddindx).attribute_category;
          a28(indx) := t(ddindx).attribute1;
          a29(indx) := t(ddindx).attribute2;
          a30(indx) := t(ddindx).attribute3;
          a31(indx) := t(ddindx).attribute4;
          a32(indx) := t(ddindx).attribute5;
          a33(indx) := t(ddindx).attribute6;
          a34(indx) := t(ddindx).attribute7;
          a35(indx) := t(ddindx).attribute8;
          a36(indx) := t(ddindx).attribute9;
          a37(indx) := t(ddindx).attribute10;
          a38(indx) := t(ddindx).attribute11;
          a39(indx) := t(ddindx).attribute12;
          a40(indx) := t(ddindx).attribute13;
          a41(indx) := t(ddindx).attribute14;
          a42(indx) := t(ddindx).attribute15;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a44(indx) := t(ddindx).creation_date;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a46(indx) := t(ddindx).last_update_date;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a48(indx) := t(ddindx).catchup_frequency_code;
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
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
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
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddx_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;


    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec,
      ddx_krpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpv_rec.khr_id);
    p6_a1 := ddx_krpv_rec.parameter_type_code;
    p6_a2 := ddx_krpv_rec.effective_from_date;
    p6_a3 := ddx_krpv_rec.effective_to_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_krpv_rec.interest_index_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_krpv_rec.base_rate);
    p6_a6 := ddx_krpv_rec.interest_start_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpv_rec.adder_rate);
    p6_a8 := rosetta_g_miss_num_map(ddx_krpv_rec.maximum_rate);
    p6_a9 := rosetta_g_miss_num_map(ddx_krpv_rec.minimum_rate);
    p6_a10 := ddx_krpv_rec.principal_basis_code;
    p6_a11 := ddx_krpv_rec.days_in_a_month_code;
    p6_a12 := ddx_krpv_rec.days_in_a_year_code;
    p6_a13 := ddx_krpv_rec.interest_basis_code;
    p6_a14 := ddx_krpv_rec.rate_delay_code;
    p6_a15 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_delay_frequency);
    p6_a16 := ddx_krpv_rec.compounding_frequency_code;
    p6_a17 := rosetta_g_miss_num_map(ddx_krpv_rec.calculation_formula_id);
    p6_a18 := ddx_krpv_rec.catchup_basis_code;
    p6_a19 := ddx_krpv_rec.catchup_start_date;
    p6_a20 := ddx_krpv_rec.catchup_settlement_code;
    p6_a21 := ddx_krpv_rec.rate_change_start_date;
    p6_a22 := ddx_krpv_rec.rate_change_frequency_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_change_value);
    p6_a24 := ddx_krpv_rec.conversion_option_code;
    p6_a25 := ddx_krpv_rec.next_conversion_date;
    p6_a26 := ddx_krpv_rec.conversion_type_code;
    p6_a27 := ddx_krpv_rec.attribute_category;
    p6_a28 := ddx_krpv_rec.attribute1;
    p6_a29 := ddx_krpv_rec.attribute2;
    p6_a30 := ddx_krpv_rec.attribute3;
    p6_a31 := ddx_krpv_rec.attribute4;
    p6_a32 := ddx_krpv_rec.attribute5;
    p6_a33 := ddx_krpv_rec.attribute6;
    p6_a34 := ddx_krpv_rec.attribute7;
    p6_a35 := ddx_krpv_rec.attribute8;
    p6_a36 := ddx_krpv_rec.attribute9;
    p6_a37 := ddx_krpv_rec.attribute10;
    p6_a38 := ddx_krpv_rec.attribute11;
    p6_a39 := ddx_krpv_rec.attribute12;
    p6_a40 := ddx_krpv_rec.attribute13;
    p6_a41 := ddx_krpv_rec.attribute14;
    p6_a42 := ddx_krpv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_krpv_rec.created_by);
    p6_a44 := ddx_krpv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_krpv_rec.last_updated_by);
    p6_a46 := ddx_krpv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_krpv_rec.last_update_login);
    p6_a48 := ddx_krpv_rec.catchup_frequency_code;
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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
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
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddx_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_krpv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_tbl,
      ddx_krpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_krp_pvt_w.rosetta_table_copy_out_p2(ddx_krpv_tbl, p6_a0
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
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;

    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec);

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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
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
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_krpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_tbl);

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
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
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
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddx_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;


    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec,
      ddx_krpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpv_rec.khr_id);
    p6_a1 := ddx_krpv_rec.parameter_type_code;
    p6_a2 := ddx_krpv_rec.effective_from_date;
    p6_a3 := ddx_krpv_rec.effective_to_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_krpv_rec.interest_index_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_krpv_rec.base_rate);
    p6_a6 := ddx_krpv_rec.interest_start_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpv_rec.adder_rate);
    p6_a8 := rosetta_g_miss_num_map(ddx_krpv_rec.maximum_rate);
    p6_a9 := rosetta_g_miss_num_map(ddx_krpv_rec.minimum_rate);
    p6_a10 := ddx_krpv_rec.principal_basis_code;
    p6_a11 := ddx_krpv_rec.days_in_a_month_code;
    p6_a12 := ddx_krpv_rec.days_in_a_year_code;
    p6_a13 := ddx_krpv_rec.interest_basis_code;
    p6_a14 := ddx_krpv_rec.rate_delay_code;
    p6_a15 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_delay_frequency);
    p6_a16 := ddx_krpv_rec.compounding_frequency_code;
    p6_a17 := rosetta_g_miss_num_map(ddx_krpv_rec.calculation_formula_id);
    p6_a18 := ddx_krpv_rec.catchup_basis_code;
    p6_a19 := ddx_krpv_rec.catchup_start_date;
    p6_a20 := ddx_krpv_rec.catchup_settlement_code;
    p6_a21 := ddx_krpv_rec.rate_change_start_date;
    p6_a22 := ddx_krpv_rec.rate_change_frequency_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_change_value);
    p6_a24 := ddx_krpv_rec.conversion_option_code;
    p6_a25 := ddx_krpv_rec.next_conversion_date;
    p6_a26 := ddx_krpv_rec.conversion_type_code;
    p6_a27 := ddx_krpv_rec.attribute_category;
    p6_a28 := ddx_krpv_rec.attribute1;
    p6_a29 := ddx_krpv_rec.attribute2;
    p6_a30 := ddx_krpv_rec.attribute3;
    p6_a31 := ddx_krpv_rec.attribute4;
    p6_a32 := ddx_krpv_rec.attribute5;
    p6_a33 := ddx_krpv_rec.attribute6;
    p6_a34 := ddx_krpv_rec.attribute7;
    p6_a35 := ddx_krpv_rec.attribute8;
    p6_a36 := ddx_krpv_rec.attribute9;
    p6_a37 := ddx_krpv_rec.attribute10;
    p6_a38 := ddx_krpv_rec.attribute11;
    p6_a39 := ddx_krpv_rec.attribute12;
    p6_a40 := ddx_krpv_rec.attribute13;
    p6_a41 := ddx_krpv_rec.attribute14;
    p6_a42 := ddx_krpv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_krpv_rec.created_by);
    p6_a44 := ddx_krpv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_krpv_rec.last_updated_by);
    p6_a46 := ddx_krpv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_krpv_rec.last_update_login);
    p6_a48 := ddx_krpv_rec.catchup_frequency_code;
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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
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
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddx_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_krpv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_tbl,
      ddx_krpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_krp_pvt_w.rosetta_table_copy_out_p2(ddx_krpv_tbl, p6_a0
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
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;

    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec);

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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
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
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_krpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_tbl);

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
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_krp_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;

    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec);

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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
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
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_krpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_deal_type  VARCHAR2
    , p_rev_rec_method  VARCHAR2
    , p_int_calc_basis  VARCHAR2
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_DATE_TABLE
    , p8_a3 JTF_DATE_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_VARCHAR2_TABLE_100
    , p8_a19 JTF_DATE_TABLE
    , p8_a20 JTF_VARCHAR2_TABLE_100
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_VARCHAR2_TABLE_100
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_VARCHAR2_TABLE_100
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_VARCHAR2_TABLE_100
    , p8_a27 JTF_VARCHAR2_TABLE_100
    , p8_a28 JTF_VARCHAR2_TABLE_500
    , p8_a29 JTF_VARCHAR2_TABLE_500
    , p8_a30 JTF_VARCHAR2_TABLE_500
    , p8_a31 JTF_VARCHAR2_TABLE_500
    , p8_a32 JTF_VARCHAR2_TABLE_500
    , p8_a33 JTF_VARCHAR2_TABLE_500
    , p8_a34 JTF_VARCHAR2_TABLE_500
    , p8_a35 JTF_VARCHAR2_TABLE_500
    , p8_a36 JTF_VARCHAR2_TABLE_500
    , p8_a37 JTF_VARCHAR2_TABLE_500
    , p8_a38 JTF_VARCHAR2_TABLE_500
    , p8_a39 JTF_VARCHAR2_TABLE_500
    , p8_a40 JTF_VARCHAR2_TABLE_500
    , p8_a41 JTF_VARCHAR2_TABLE_500
    , p8_a42 JTF_VARCHAR2_TABLE_500
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_DATE_TABLE
    , p8_a45 JTF_NUMBER_TABLE
    , p8_a46 JTF_DATE_TABLE
    , p8_a47 JTF_NUMBER_TABLE
    , p8_a48 JTF_VARCHAR2_TABLE_100
    , p_stack_messages  VARCHAR2
    , p_validate_flag  VARCHAR2
  )

  as
    ddp_krpv_tbl okl_krp_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_krpv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_krp_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_deal_type,
      p_rev_rec_method,
      p_int_calc_basis,
      ddp_krpv_tbl,
      p_stack_messages,
      p_validate_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end okl_krp_pvt_w;

/
