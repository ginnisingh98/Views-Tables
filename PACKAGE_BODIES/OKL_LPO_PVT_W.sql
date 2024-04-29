--------------------------------------------------------
--  DDL for Package Body OKL_LPO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LPO_PVT_W" as
  /* $Header: OKLILPOB.pls 115.5 2003/11/06 01:31:24 pjgomes noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return okl_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := okl_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy okl_lpo_pvt.lpov_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
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
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).ise_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).tdf_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).idx_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).late_policy_type_code := a7(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).late_chrg_allowed_yn := a9(indx);
          t(ddindx).late_chrg_fixed_yn := a10(indx);
          t(ddindx).late_chrg_amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).late_chrg_rate := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).late_chrg_grace_period := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).late_chrg_minimum_balance := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).minimum_late_charge := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).maximum_late_charge := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).late_int_allowed_yn := a17(indx);
          t(ddindx).late_int_fixed_yn := a18(indx);
          t(ddindx).late_int_rate := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).adder_rate := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).late_int_grace_period := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).late_int_minimum_balance := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).minimum_late_interest := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).maximum_late_interest := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).attribute_category := a25(indx);
          t(ddindx).attribute1 := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute3 := a28(indx);
          t(ddindx).attribute4 := a29(indx);
          t(ddindx).attribute5 := a30(indx);
          t(ddindx).attribute6 := a31(indx);
          t(ddindx).attribute7 := a32(indx);
          t(ddindx).attribute8 := a33(indx);
          t(ddindx).attribute9 := a34(indx);
          t(ddindx).attribute10 := a35(indx);
          t(ddindx).attribute11 := a36(indx);
          t(ddindx).attribute12 := a37(indx);
          t(ddindx).attribute13 := a38(indx);
          t(ddindx).attribute14 := a39(indx);
          t(ddindx).attribute15 := a40(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).days_in_year := a46(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_lpo_pvt.lpov_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
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
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
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
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).ise_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).tdf_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).idx_id);
          a7(indx) := t(ddindx).late_policy_type_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a9(indx) := t(ddindx).late_chrg_allowed_yn;
          a10(indx) := t(ddindx).late_chrg_fixed_yn;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_rate);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_grace_period);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_minimum_balance);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).minimum_late_charge);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_late_charge);
          a17(indx) := t(ddindx).late_int_allowed_yn;
          a18(indx) := t(ddindx).late_int_fixed_yn;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).late_int_rate);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).adder_rate);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).late_int_grace_period);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).late_int_minimum_balance);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).minimum_late_interest);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_late_interest);
          a25(indx) := t(ddindx).attribute_category;
          a26(indx) := t(ddindx).attribute1;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := t(ddindx).attribute3;
          a29(indx) := t(ddindx).attribute4;
          a30(indx) := t(ddindx).attribute5;
          a31(indx) := t(ddindx).attribute6;
          a32(indx) := t(ddindx).attribute7;
          a33(indx) := t(ddindx).attribute8;
          a34(indx) := t(ddindx).attribute9;
          a35(indx) := t(ddindx).attribute10;
          a36(indx) := t(ddindx).attribute11;
          a37(indx) := t(ddindx).attribute12;
          a38(indx) := t(ddindx).attribute13;
          a39(indx) := t(ddindx).attribute14;
          a40(indx) := t(ddindx).attribute15;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a42(indx) := t(ddindx).creation_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a44(indx) := t(ddindx).last_update_date;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a46(indx) := t(ddindx).days_in_year;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_lpo_pvt.lpo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
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
    , a37 JTF_VARCHAR2_TABLE_500
    , a38 JTF_VARCHAR2_TABLE_500
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).ise_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).tdf_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).idx_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).late_policy_type_code := a5(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).late_chrg_allowed_yn := a7(indx);
          t(ddindx).late_chrg_fixed_yn := a8(indx);
          t(ddindx).late_chrg_amount := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).late_chrg_rate := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).late_chrg_grace_period := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).late_chrg_minimum_balance := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).minimum_late_charge := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).maximum_late_charge := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).late_int_allowed_yn := a15(indx);
          t(ddindx).late_int_fixed_yn := a16(indx);
          t(ddindx).late_int_rate := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).adder_rate := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).late_int_grace_period := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).late_int_minimum_balance := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).minimum_late_interest := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).maximum_late_interest := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).attribute_category := a23(indx);
          t(ddindx).attribute1 := a24(indx);
          t(ddindx).attribute2 := a25(indx);
          t(ddindx).attribute3 := a26(indx);
          t(ddindx).attribute4 := a27(indx);
          t(ddindx).attribute5 := a28(indx);
          t(ddindx).attribute6 := a29(indx);
          t(ddindx).attribute7 := a30(indx);
          t(ddindx).attribute8 := a31(indx);
          t(ddindx).attribute9 := a32(indx);
          t(ddindx).attribute10 := a33(indx);
          t(ddindx).attribute11 := a34(indx);
          t(ddindx).attribute12 := a35(indx);
          t(ddindx).attribute13 := a36(indx);
          t(ddindx).attribute14 := a37(indx);
          t(ddindx).attribute15 := a38(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).days_in_year := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_lpo_pvt.lpo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a37 out nocopy JTF_VARCHAR2_TABLE_500
    , a38 out nocopy JTF_VARCHAR2_TABLE_500
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
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
    a37 := JTF_VARCHAR2_TABLE_500();
    a38 := JTF_VARCHAR2_TABLE_500();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
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
      a37 := JTF_VARCHAR2_TABLE_500();
      a38 := JTF_VARCHAR2_TABLE_500();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).ise_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).tdf_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).idx_id);
          a5(indx) := t(ddindx).late_policy_type_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).late_chrg_allowed_yn;
          a8(indx) := t(ddindx).late_chrg_fixed_yn;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_amount);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_rate);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_grace_period);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).late_chrg_minimum_balance);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).minimum_late_charge);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_late_charge);
          a15(indx) := t(ddindx).late_int_allowed_yn;
          a16(indx) := t(ddindx).late_int_fixed_yn;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).late_int_rate);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).adder_rate);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).late_int_grace_period);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).late_int_minimum_balance);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).minimum_late_interest);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_late_interest);
          a23(indx) := t(ddindx).attribute_category;
          a24(indx) := t(ddindx).attribute1;
          a25(indx) := t(ddindx).attribute2;
          a26(indx) := t(ddindx).attribute3;
          a27(indx) := t(ddindx).attribute4;
          a28(indx) := t(ddindx).attribute5;
          a29(indx) := t(ddindx).attribute6;
          a30(indx) := t(ddindx).attribute7;
          a31(indx) := t(ddindx).attribute8;
          a32(indx) := t(ddindx).attribute9;
          a33(indx) := t(ddindx).attribute10;
          a34(indx) := t(ddindx).attribute11;
          a35(indx) := t(ddindx).attribute12;
          a36(indx) := t(ddindx).attribute13;
          a37(indx) := t(ddindx).attribute14;
          a38(indx) := t(ddindx).attribute15;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a40(indx) := t(ddindx).creation_date;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a42(indx) := t(ddindx).last_update_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a44(indx) := t(ddindx).days_in_year;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_lpo_pvt.okl_late_policies_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
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
          t(ddindx).name := a3(indx);
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
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_lpo_pvt.okl_late_policies_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a3 := JTF_VARCHAR2_TABLE_2000();
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
      a3 := JTF_VARCHAR2_TABLE_2000();
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
          a3(indx) := t(ddindx).name;
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
  end rosetta_table_copy_out_p8;

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
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
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
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := okl_api.g_miss_char
    , p5_a3  VARCHAR2 := okl_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := okl_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := okl_api.g_miss_char
    , p5_a10  VARCHAR2 := okl_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := okl_api.g_miss_char
    , p5_a18  VARCHAR2 := okl_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := okl_api.g_miss_char
    , p5_a26  VARCHAR2 := okl_api.g_miss_char
    , p5_a27  VARCHAR2 := okl_api.g_miss_char
    , p5_a28  VARCHAR2 := okl_api.g_miss_char
    , p5_a29  VARCHAR2 := okl_api.g_miss_char
    , p5_a30  VARCHAR2 := okl_api.g_miss_char
    , p5_a31  VARCHAR2 := okl_api.g_miss_char
    , p5_a32  VARCHAR2 := okl_api.g_miss_char
    , p5_a33  VARCHAR2 := okl_api.g_miss_char
    , p5_a34  VARCHAR2 := okl_api.g_miss_char
    , p5_a35  VARCHAR2 := okl_api.g_miss_char
    , p5_a36  VARCHAR2 := okl_api.g_miss_char
    , p5_a37  VARCHAR2 := okl_api.g_miss_char
    , p5_a38  VARCHAR2 := okl_api.g_miss_char
    , p5_a39  VARCHAR2 := okl_api.g_miss_char
    , p5_a40  VARCHAR2 := okl_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := okl_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := okl_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := okl_api.g_miss_char
  )

  as
    ddp_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddx_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lpov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_lpov_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_lpov_rec.name := p5_a2;
    ddp_lpov_rec.description := p5_a3;
    ddp_lpov_rec.ise_id := rosetta_g_miss_num_map(p5_a4);
    ddp_lpov_rec.tdf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_lpov_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_lpov_rec.late_policy_type_code := p5_a7;
    ddp_lpov_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_lpov_rec.late_chrg_allowed_yn := p5_a9;
    ddp_lpov_rec.late_chrg_fixed_yn := p5_a10;
    ddp_lpov_rec.late_chrg_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_lpov_rec.late_chrg_rate := rosetta_g_miss_num_map(p5_a12);
    ddp_lpov_rec.late_chrg_grace_period := rosetta_g_miss_num_map(p5_a13);
    ddp_lpov_rec.late_chrg_minimum_balance := rosetta_g_miss_num_map(p5_a14);
    ddp_lpov_rec.minimum_late_charge := rosetta_g_miss_num_map(p5_a15);
    ddp_lpov_rec.maximum_late_charge := rosetta_g_miss_num_map(p5_a16);
    ddp_lpov_rec.late_int_allowed_yn := p5_a17;
    ddp_lpov_rec.late_int_fixed_yn := p5_a18;
    ddp_lpov_rec.late_int_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_lpov_rec.adder_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_lpov_rec.late_int_grace_period := rosetta_g_miss_num_map(p5_a21);
    ddp_lpov_rec.late_int_minimum_balance := rosetta_g_miss_num_map(p5_a22);
    ddp_lpov_rec.minimum_late_interest := rosetta_g_miss_num_map(p5_a23);
    ddp_lpov_rec.maximum_late_interest := rosetta_g_miss_num_map(p5_a24);
    ddp_lpov_rec.attribute_category := p5_a25;
    ddp_lpov_rec.attribute1 := p5_a26;
    ddp_lpov_rec.attribute2 := p5_a27;
    ddp_lpov_rec.attribute3 := p5_a28;
    ddp_lpov_rec.attribute4 := p5_a29;
    ddp_lpov_rec.attribute5 := p5_a30;
    ddp_lpov_rec.attribute6 := p5_a31;
    ddp_lpov_rec.attribute7 := p5_a32;
    ddp_lpov_rec.attribute8 := p5_a33;
    ddp_lpov_rec.attribute9 := p5_a34;
    ddp_lpov_rec.attribute10 := p5_a35;
    ddp_lpov_rec.attribute11 := p5_a36;
    ddp_lpov_rec.attribute12 := p5_a37;
    ddp_lpov_rec.attribute13 := p5_a38;
    ddp_lpov_rec.attribute14 := p5_a39;
    ddp_lpov_rec.attribute15 := p5_a40;
    ddp_lpov_rec.created_by := rosetta_g_miss_num_map(p5_a41);
    ddp_lpov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_lpov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a43);
    ddp_lpov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_lpov_rec.last_update_login := rosetta_g_miss_num_map(p5_a45);
    ddp_lpov_rec.days_in_year := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lpo_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_rec,
      ddx_lpov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_lpov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_lpov_rec.org_id);
    p6_a2 := ddx_lpov_rec.name;
    p6_a3 := ddx_lpov_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_lpov_rec.ise_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_lpov_rec.tdf_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_lpov_rec.idx_id);
    p6_a7 := ddx_lpov_rec.late_policy_type_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_lpov_rec.object_version_number);
    p6_a9 := ddx_lpov_rec.late_chrg_allowed_yn;
    p6_a10 := ddx_lpov_rec.late_chrg_fixed_yn;
    p6_a11 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_rate);
    p6_a13 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_grace_period);
    p6_a14 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_minimum_balance);
    p6_a15 := rosetta_g_miss_num_map(ddx_lpov_rec.minimum_late_charge);
    p6_a16 := rosetta_g_miss_num_map(ddx_lpov_rec.maximum_late_charge);
    p6_a17 := ddx_lpov_rec.late_int_allowed_yn;
    p6_a18 := ddx_lpov_rec.late_int_fixed_yn;
    p6_a19 := rosetta_g_miss_num_map(ddx_lpov_rec.late_int_rate);
    p6_a20 := rosetta_g_miss_num_map(ddx_lpov_rec.adder_rate);
    p6_a21 := rosetta_g_miss_num_map(ddx_lpov_rec.late_int_grace_period);
    p6_a22 := rosetta_g_miss_num_map(ddx_lpov_rec.late_int_minimum_balance);
    p6_a23 := rosetta_g_miss_num_map(ddx_lpov_rec.minimum_late_interest);
    p6_a24 := rosetta_g_miss_num_map(ddx_lpov_rec.maximum_late_interest);
    p6_a25 := ddx_lpov_rec.attribute_category;
    p6_a26 := ddx_lpov_rec.attribute1;
    p6_a27 := ddx_lpov_rec.attribute2;
    p6_a28 := ddx_lpov_rec.attribute3;
    p6_a29 := ddx_lpov_rec.attribute4;
    p6_a30 := ddx_lpov_rec.attribute5;
    p6_a31 := ddx_lpov_rec.attribute6;
    p6_a32 := ddx_lpov_rec.attribute7;
    p6_a33 := ddx_lpov_rec.attribute8;
    p6_a34 := ddx_lpov_rec.attribute9;
    p6_a35 := ddx_lpov_rec.attribute10;
    p6_a36 := ddx_lpov_rec.attribute11;
    p6_a37 := ddx_lpov_rec.attribute12;
    p6_a38 := ddx_lpov_rec.attribute13;
    p6_a39 := ddx_lpov_rec.attribute14;
    p6_a40 := ddx_lpov_rec.attribute15;
    p6_a41 := rosetta_g_miss_num_map(ddx_lpov_rec.created_by);
    p6_a42 := ddx_lpov_rec.creation_date;
    p6_a43 := rosetta_g_miss_num_map(ddx_lpov_rec.last_updated_by);
    p6_a44 := ddx_lpov_rec.last_update_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_lpov_rec.last_update_login);
    p6_a46 := ddx_lpov_rec.days_in_year;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddx_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lpo_pvt_w.rosetta_table_copy_in_p2(ddp_lpov_tbl, p5_a0
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
    okl_lpo_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_tbl,
      ddx_lpov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lpo_pvt_w.rosetta_table_copy_out_p2(ddx_lpov_tbl, p6_a0
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
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := okl_api.g_miss_char
    , p5_a3  VARCHAR2 := okl_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := okl_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := okl_api.g_miss_char
    , p5_a10  VARCHAR2 := okl_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := okl_api.g_miss_char
    , p5_a18  VARCHAR2 := okl_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := okl_api.g_miss_char
    , p5_a26  VARCHAR2 := okl_api.g_miss_char
    , p5_a27  VARCHAR2 := okl_api.g_miss_char
    , p5_a28  VARCHAR2 := okl_api.g_miss_char
    , p5_a29  VARCHAR2 := okl_api.g_miss_char
    , p5_a30  VARCHAR2 := okl_api.g_miss_char
    , p5_a31  VARCHAR2 := okl_api.g_miss_char
    , p5_a32  VARCHAR2 := okl_api.g_miss_char
    , p5_a33  VARCHAR2 := okl_api.g_miss_char
    , p5_a34  VARCHAR2 := okl_api.g_miss_char
    , p5_a35  VARCHAR2 := okl_api.g_miss_char
    , p5_a36  VARCHAR2 := okl_api.g_miss_char
    , p5_a37  VARCHAR2 := okl_api.g_miss_char
    , p5_a38  VARCHAR2 := okl_api.g_miss_char
    , p5_a39  VARCHAR2 := okl_api.g_miss_char
    , p5_a40  VARCHAR2 := okl_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := okl_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := okl_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := okl_api.g_miss_char
  )

  as
    ddp_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lpov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_lpov_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_lpov_rec.name := p5_a2;
    ddp_lpov_rec.description := p5_a3;
    ddp_lpov_rec.ise_id := rosetta_g_miss_num_map(p5_a4);
    ddp_lpov_rec.tdf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_lpov_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_lpov_rec.late_policy_type_code := p5_a7;
    ddp_lpov_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_lpov_rec.late_chrg_allowed_yn := p5_a9;
    ddp_lpov_rec.late_chrg_fixed_yn := p5_a10;
    ddp_lpov_rec.late_chrg_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_lpov_rec.late_chrg_rate := rosetta_g_miss_num_map(p5_a12);
    ddp_lpov_rec.late_chrg_grace_period := rosetta_g_miss_num_map(p5_a13);
    ddp_lpov_rec.late_chrg_minimum_balance := rosetta_g_miss_num_map(p5_a14);
    ddp_lpov_rec.minimum_late_charge := rosetta_g_miss_num_map(p5_a15);
    ddp_lpov_rec.maximum_late_charge := rosetta_g_miss_num_map(p5_a16);
    ddp_lpov_rec.late_int_allowed_yn := p5_a17;
    ddp_lpov_rec.late_int_fixed_yn := p5_a18;
    ddp_lpov_rec.late_int_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_lpov_rec.adder_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_lpov_rec.late_int_grace_period := rosetta_g_miss_num_map(p5_a21);
    ddp_lpov_rec.late_int_minimum_balance := rosetta_g_miss_num_map(p5_a22);
    ddp_lpov_rec.minimum_late_interest := rosetta_g_miss_num_map(p5_a23);
    ddp_lpov_rec.maximum_late_interest := rosetta_g_miss_num_map(p5_a24);
    ddp_lpov_rec.attribute_category := p5_a25;
    ddp_lpov_rec.attribute1 := p5_a26;
    ddp_lpov_rec.attribute2 := p5_a27;
    ddp_lpov_rec.attribute3 := p5_a28;
    ddp_lpov_rec.attribute4 := p5_a29;
    ddp_lpov_rec.attribute5 := p5_a30;
    ddp_lpov_rec.attribute6 := p5_a31;
    ddp_lpov_rec.attribute7 := p5_a32;
    ddp_lpov_rec.attribute8 := p5_a33;
    ddp_lpov_rec.attribute9 := p5_a34;
    ddp_lpov_rec.attribute10 := p5_a35;
    ddp_lpov_rec.attribute11 := p5_a36;
    ddp_lpov_rec.attribute12 := p5_a37;
    ddp_lpov_rec.attribute13 := p5_a38;
    ddp_lpov_rec.attribute14 := p5_a39;
    ddp_lpov_rec.attribute15 := p5_a40;
    ddp_lpov_rec.created_by := rosetta_g_miss_num_map(p5_a41);
    ddp_lpov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_lpov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a43);
    ddp_lpov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_lpov_rec.last_update_login := rosetta_g_miss_num_map(p5_a45);
    ddp_lpov_rec.days_in_year := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_lpo_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lpo_pvt_w.rosetta_table_copy_in_p2(ddp_lpov_tbl, p5_a0
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
    okl_lpo_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_tbl);

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
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
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
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := okl_api.g_miss_char
    , p5_a3  VARCHAR2 := okl_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := okl_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := okl_api.g_miss_char
    , p5_a10  VARCHAR2 := okl_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := okl_api.g_miss_char
    , p5_a18  VARCHAR2 := okl_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := okl_api.g_miss_char
    , p5_a26  VARCHAR2 := okl_api.g_miss_char
    , p5_a27  VARCHAR2 := okl_api.g_miss_char
    , p5_a28  VARCHAR2 := okl_api.g_miss_char
    , p5_a29  VARCHAR2 := okl_api.g_miss_char
    , p5_a30  VARCHAR2 := okl_api.g_miss_char
    , p5_a31  VARCHAR2 := okl_api.g_miss_char
    , p5_a32  VARCHAR2 := okl_api.g_miss_char
    , p5_a33  VARCHAR2 := okl_api.g_miss_char
    , p5_a34  VARCHAR2 := okl_api.g_miss_char
    , p5_a35  VARCHAR2 := okl_api.g_miss_char
    , p5_a36  VARCHAR2 := okl_api.g_miss_char
    , p5_a37  VARCHAR2 := okl_api.g_miss_char
    , p5_a38  VARCHAR2 := okl_api.g_miss_char
    , p5_a39  VARCHAR2 := okl_api.g_miss_char
    , p5_a40  VARCHAR2 := okl_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := okl_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := okl_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := okl_api.g_miss_char
  )

  as
    ddp_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddx_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lpov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_lpov_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_lpov_rec.name := p5_a2;
    ddp_lpov_rec.description := p5_a3;
    ddp_lpov_rec.ise_id := rosetta_g_miss_num_map(p5_a4);
    ddp_lpov_rec.tdf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_lpov_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_lpov_rec.late_policy_type_code := p5_a7;
    ddp_lpov_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_lpov_rec.late_chrg_allowed_yn := p5_a9;
    ddp_lpov_rec.late_chrg_fixed_yn := p5_a10;
    ddp_lpov_rec.late_chrg_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_lpov_rec.late_chrg_rate := rosetta_g_miss_num_map(p5_a12);
    ddp_lpov_rec.late_chrg_grace_period := rosetta_g_miss_num_map(p5_a13);
    ddp_lpov_rec.late_chrg_minimum_balance := rosetta_g_miss_num_map(p5_a14);
    ddp_lpov_rec.minimum_late_charge := rosetta_g_miss_num_map(p5_a15);
    ddp_lpov_rec.maximum_late_charge := rosetta_g_miss_num_map(p5_a16);
    ddp_lpov_rec.late_int_allowed_yn := p5_a17;
    ddp_lpov_rec.late_int_fixed_yn := p5_a18;
    ddp_lpov_rec.late_int_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_lpov_rec.adder_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_lpov_rec.late_int_grace_period := rosetta_g_miss_num_map(p5_a21);
    ddp_lpov_rec.late_int_minimum_balance := rosetta_g_miss_num_map(p5_a22);
    ddp_lpov_rec.minimum_late_interest := rosetta_g_miss_num_map(p5_a23);
    ddp_lpov_rec.maximum_late_interest := rosetta_g_miss_num_map(p5_a24);
    ddp_lpov_rec.attribute_category := p5_a25;
    ddp_lpov_rec.attribute1 := p5_a26;
    ddp_lpov_rec.attribute2 := p5_a27;
    ddp_lpov_rec.attribute3 := p5_a28;
    ddp_lpov_rec.attribute4 := p5_a29;
    ddp_lpov_rec.attribute5 := p5_a30;
    ddp_lpov_rec.attribute6 := p5_a31;
    ddp_lpov_rec.attribute7 := p5_a32;
    ddp_lpov_rec.attribute8 := p5_a33;
    ddp_lpov_rec.attribute9 := p5_a34;
    ddp_lpov_rec.attribute10 := p5_a35;
    ddp_lpov_rec.attribute11 := p5_a36;
    ddp_lpov_rec.attribute12 := p5_a37;
    ddp_lpov_rec.attribute13 := p5_a38;
    ddp_lpov_rec.attribute14 := p5_a39;
    ddp_lpov_rec.attribute15 := p5_a40;
    ddp_lpov_rec.created_by := rosetta_g_miss_num_map(p5_a41);
    ddp_lpov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_lpov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a43);
    ddp_lpov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_lpov_rec.last_update_login := rosetta_g_miss_num_map(p5_a45);
    ddp_lpov_rec.days_in_year := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lpo_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_rec,
      ddx_lpov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_lpov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_lpov_rec.org_id);
    p6_a2 := ddx_lpov_rec.name;
    p6_a3 := ddx_lpov_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_lpov_rec.ise_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_lpov_rec.tdf_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_lpov_rec.idx_id);
    p6_a7 := ddx_lpov_rec.late_policy_type_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_lpov_rec.object_version_number);
    p6_a9 := ddx_lpov_rec.late_chrg_allowed_yn;
    p6_a10 := ddx_lpov_rec.late_chrg_fixed_yn;
    p6_a11 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_rate);
    p6_a13 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_grace_period);
    p6_a14 := rosetta_g_miss_num_map(ddx_lpov_rec.late_chrg_minimum_balance);
    p6_a15 := rosetta_g_miss_num_map(ddx_lpov_rec.minimum_late_charge);
    p6_a16 := rosetta_g_miss_num_map(ddx_lpov_rec.maximum_late_charge);
    p6_a17 := ddx_lpov_rec.late_int_allowed_yn;
    p6_a18 := ddx_lpov_rec.late_int_fixed_yn;
    p6_a19 := rosetta_g_miss_num_map(ddx_lpov_rec.late_int_rate);
    p6_a20 := rosetta_g_miss_num_map(ddx_lpov_rec.adder_rate);
    p6_a21 := rosetta_g_miss_num_map(ddx_lpov_rec.late_int_grace_period);
    p6_a22 := rosetta_g_miss_num_map(ddx_lpov_rec.late_int_minimum_balance);
    p6_a23 := rosetta_g_miss_num_map(ddx_lpov_rec.minimum_late_interest);
    p6_a24 := rosetta_g_miss_num_map(ddx_lpov_rec.maximum_late_interest);
    p6_a25 := ddx_lpov_rec.attribute_category;
    p6_a26 := ddx_lpov_rec.attribute1;
    p6_a27 := ddx_lpov_rec.attribute2;
    p6_a28 := ddx_lpov_rec.attribute3;
    p6_a29 := ddx_lpov_rec.attribute4;
    p6_a30 := ddx_lpov_rec.attribute5;
    p6_a31 := ddx_lpov_rec.attribute6;
    p6_a32 := ddx_lpov_rec.attribute7;
    p6_a33 := ddx_lpov_rec.attribute8;
    p6_a34 := ddx_lpov_rec.attribute9;
    p6_a35 := ddx_lpov_rec.attribute10;
    p6_a36 := ddx_lpov_rec.attribute11;
    p6_a37 := ddx_lpov_rec.attribute12;
    p6_a38 := ddx_lpov_rec.attribute13;
    p6_a39 := ddx_lpov_rec.attribute14;
    p6_a40 := ddx_lpov_rec.attribute15;
    p6_a41 := rosetta_g_miss_num_map(ddx_lpov_rec.created_by);
    p6_a42 := ddx_lpov_rec.creation_date;
    p6_a43 := rosetta_g_miss_num_map(ddx_lpov_rec.last_updated_by);
    p6_a44 := ddx_lpov_rec.last_update_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_lpov_rec.last_update_login);
    p6_a46 := ddx_lpov_rec.days_in_year;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddx_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lpo_pvt_w.rosetta_table_copy_in_p2(ddp_lpov_tbl, p5_a0
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
    okl_lpo_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_tbl,
      ddx_lpov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lpo_pvt_w.rosetta_table_copy_out_p2(ddx_lpov_tbl, p6_a0
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
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := okl_api.g_miss_char
    , p5_a3  VARCHAR2 := okl_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := okl_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := okl_api.g_miss_char
    , p5_a10  VARCHAR2 := okl_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := okl_api.g_miss_char
    , p5_a18  VARCHAR2 := okl_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := okl_api.g_miss_char
    , p5_a26  VARCHAR2 := okl_api.g_miss_char
    , p5_a27  VARCHAR2 := okl_api.g_miss_char
    , p5_a28  VARCHAR2 := okl_api.g_miss_char
    , p5_a29  VARCHAR2 := okl_api.g_miss_char
    , p5_a30  VARCHAR2 := okl_api.g_miss_char
    , p5_a31  VARCHAR2 := okl_api.g_miss_char
    , p5_a32  VARCHAR2 := okl_api.g_miss_char
    , p5_a33  VARCHAR2 := okl_api.g_miss_char
    , p5_a34  VARCHAR2 := okl_api.g_miss_char
    , p5_a35  VARCHAR2 := okl_api.g_miss_char
    , p5_a36  VARCHAR2 := okl_api.g_miss_char
    , p5_a37  VARCHAR2 := okl_api.g_miss_char
    , p5_a38  VARCHAR2 := okl_api.g_miss_char
    , p5_a39  VARCHAR2 := okl_api.g_miss_char
    , p5_a40  VARCHAR2 := okl_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := okl_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := okl_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := okl_api.g_miss_char
  )

  as
    ddp_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lpov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_lpov_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_lpov_rec.name := p5_a2;
    ddp_lpov_rec.description := p5_a3;
    ddp_lpov_rec.ise_id := rosetta_g_miss_num_map(p5_a4);
    ddp_lpov_rec.tdf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_lpov_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_lpov_rec.late_policy_type_code := p5_a7;
    ddp_lpov_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_lpov_rec.late_chrg_allowed_yn := p5_a9;
    ddp_lpov_rec.late_chrg_fixed_yn := p5_a10;
    ddp_lpov_rec.late_chrg_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_lpov_rec.late_chrg_rate := rosetta_g_miss_num_map(p5_a12);
    ddp_lpov_rec.late_chrg_grace_period := rosetta_g_miss_num_map(p5_a13);
    ddp_lpov_rec.late_chrg_minimum_balance := rosetta_g_miss_num_map(p5_a14);
    ddp_lpov_rec.minimum_late_charge := rosetta_g_miss_num_map(p5_a15);
    ddp_lpov_rec.maximum_late_charge := rosetta_g_miss_num_map(p5_a16);
    ddp_lpov_rec.late_int_allowed_yn := p5_a17;
    ddp_lpov_rec.late_int_fixed_yn := p5_a18;
    ddp_lpov_rec.late_int_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_lpov_rec.adder_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_lpov_rec.late_int_grace_period := rosetta_g_miss_num_map(p5_a21);
    ddp_lpov_rec.late_int_minimum_balance := rosetta_g_miss_num_map(p5_a22);
    ddp_lpov_rec.minimum_late_interest := rosetta_g_miss_num_map(p5_a23);
    ddp_lpov_rec.maximum_late_interest := rosetta_g_miss_num_map(p5_a24);
    ddp_lpov_rec.attribute_category := p5_a25;
    ddp_lpov_rec.attribute1 := p5_a26;
    ddp_lpov_rec.attribute2 := p5_a27;
    ddp_lpov_rec.attribute3 := p5_a28;
    ddp_lpov_rec.attribute4 := p5_a29;
    ddp_lpov_rec.attribute5 := p5_a30;
    ddp_lpov_rec.attribute6 := p5_a31;
    ddp_lpov_rec.attribute7 := p5_a32;
    ddp_lpov_rec.attribute8 := p5_a33;
    ddp_lpov_rec.attribute9 := p5_a34;
    ddp_lpov_rec.attribute10 := p5_a35;
    ddp_lpov_rec.attribute11 := p5_a36;
    ddp_lpov_rec.attribute12 := p5_a37;
    ddp_lpov_rec.attribute13 := p5_a38;
    ddp_lpov_rec.attribute14 := p5_a39;
    ddp_lpov_rec.attribute15 := p5_a40;
    ddp_lpov_rec.created_by := rosetta_g_miss_num_map(p5_a41);
    ddp_lpov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_lpov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a43);
    ddp_lpov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_lpov_rec.last_update_login := rosetta_g_miss_num_map(p5_a45);
    ddp_lpov_rec.days_in_year := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_lpo_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lpo_pvt_w.rosetta_table_copy_in_p2(ddp_lpov_tbl, p5_a0
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
    okl_lpo_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := okl_api.g_miss_char
    , p5_a3  VARCHAR2 := okl_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := okl_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := okl_api.g_miss_char
    , p5_a10  VARCHAR2 := okl_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := okl_api.g_miss_char
    , p5_a18  VARCHAR2 := okl_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := okl_api.g_miss_char
    , p5_a26  VARCHAR2 := okl_api.g_miss_char
    , p5_a27  VARCHAR2 := okl_api.g_miss_char
    , p5_a28  VARCHAR2 := okl_api.g_miss_char
    , p5_a29  VARCHAR2 := okl_api.g_miss_char
    , p5_a30  VARCHAR2 := okl_api.g_miss_char
    , p5_a31  VARCHAR2 := okl_api.g_miss_char
    , p5_a32  VARCHAR2 := okl_api.g_miss_char
    , p5_a33  VARCHAR2 := okl_api.g_miss_char
    , p5_a34  VARCHAR2 := okl_api.g_miss_char
    , p5_a35  VARCHAR2 := okl_api.g_miss_char
    , p5_a36  VARCHAR2 := okl_api.g_miss_char
    , p5_a37  VARCHAR2 := okl_api.g_miss_char
    , p5_a38  VARCHAR2 := okl_api.g_miss_char
    , p5_a39  VARCHAR2 := okl_api.g_miss_char
    , p5_a40  VARCHAR2 := okl_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := okl_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := okl_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := okl_api.g_miss_char
  )

  as
    ddp_lpov_rec okl_lpo_pvt.lpov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lpov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_lpov_rec.org_id := rosetta_g_miss_num_map(p5_a1);
    ddp_lpov_rec.name := p5_a2;
    ddp_lpov_rec.description := p5_a3;
    ddp_lpov_rec.ise_id := rosetta_g_miss_num_map(p5_a4);
    ddp_lpov_rec.tdf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_lpov_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_lpov_rec.late_policy_type_code := p5_a7;
    ddp_lpov_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_lpov_rec.late_chrg_allowed_yn := p5_a9;
    ddp_lpov_rec.late_chrg_fixed_yn := p5_a10;
    ddp_lpov_rec.late_chrg_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_lpov_rec.late_chrg_rate := rosetta_g_miss_num_map(p5_a12);
    ddp_lpov_rec.late_chrg_grace_period := rosetta_g_miss_num_map(p5_a13);
    ddp_lpov_rec.late_chrg_minimum_balance := rosetta_g_miss_num_map(p5_a14);
    ddp_lpov_rec.minimum_late_charge := rosetta_g_miss_num_map(p5_a15);
    ddp_lpov_rec.maximum_late_charge := rosetta_g_miss_num_map(p5_a16);
    ddp_lpov_rec.late_int_allowed_yn := p5_a17;
    ddp_lpov_rec.late_int_fixed_yn := p5_a18;
    ddp_lpov_rec.late_int_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_lpov_rec.adder_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_lpov_rec.late_int_grace_period := rosetta_g_miss_num_map(p5_a21);
    ddp_lpov_rec.late_int_minimum_balance := rosetta_g_miss_num_map(p5_a22);
    ddp_lpov_rec.minimum_late_interest := rosetta_g_miss_num_map(p5_a23);
    ddp_lpov_rec.maximum_late_interest := rosetta_g_miss_num_map(p5_a24);
    ddp_lpov_rec.attribute_category := p5_a25;
    ddp_lpov_rec.attribute1 := p5_a26;
    ddp_lpov_rec.attribute2 := p5_a27;
    ddp_lpov_rec.attribute3 := p5_a28;
    ddp_lpov_rec.attribute4 := p5_a29;
    ddp_lpov_rec.attribute5 := p5_a30;
    ddp_lpov_rec.attribute6 := p5_a31;
    ddp_lpov_rec.attribute7 := p5_a32;
    ddp_lpov_rec.attribute8 := p5_a33;
    ddp_lpov_rec.attribute9 := p5_a34;
    ddp_lpov_rec.attribute10 := p5_a35;
    ddp_lpov_rec.attribute11 := p5_a36;
    ddp_lpov_rec.attribute12 := p5_a37;
    ddp_lpov_rec.attribute13 := p5_a38;
    ddp_lpov_rec.attribute14 := p5_a39;
    ddp_lpov_rec.attribute15 := p5_a40;
    ddp_lpov_rec.created_by := rosetta_g_miss_num_map(p5_a41);
    ddp_lpov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_lpov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a43);
    ddp_lpov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_lpov_rec.last_update_login := rosetta_g_miss_num_map(p5_a45);
    ddp_lpov_rec.days_in_year := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_lpo_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lpov_tbl okl_lpo_pvt.lpov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lpo_pvt_w.rosetta_table_copy_in_p2(ddp_lpov_tbl, p5_a0
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
    okl_lpo_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lpov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_lpo_pvt_w;

/
