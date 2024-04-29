--------------------------------------------------------
--  DDL for Package Body OKL_SUB_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUB_PVT_W" as
  /* $Header: OKLISUBB.pls 120.4 2005/10/30 04:18:43 appldev noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_sub_pvt.subv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
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
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
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
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_500
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
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
          t(ddindx).org_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).name := a4(indx);
          t(ddindx).short_description := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).effective_from_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).effective_to_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).expire_after_days := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).currency_code := a10(indx);
          t(ddindx).exclusive_yn := a11(indx);
          t(ddindx).applicable_to_release_yn := a12(indx);
          t(ddindx).subsidy_calc_basis := a13(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).formula_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).rate_points := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).maximum_term := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).accounting_method_code := a20(indx);
          t(ddindx).recourse_yn := a21(indx);
          t(ddindx).termination_refund_basis := a22(indx);
          t(ddindx).refund_formula_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).stream_type_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).receipt_method_code := a25(indx);
          t(ddindx).customer_visible_yn := a26(indx);
          t(ddindx).maximum_financed_amount := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).maximum_subsidy_amount := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).transfer_basis_code := a29(indx);
          t(ddindx).attribute_category := a30(indx);
          t(ddindx).attribute1 := a31(indx);
          t(ddindx).attribute2 := a32(indx);
          t(ddindx).attribute3 := a33(indx);
          t(ddindx).attribute4 := a34(indx);
          t(ddindx).attribute5 := a35(indx);
          t(ddindx).attribute6 := a36(indx);
          t(ddindx).attribute7 := a37(indx);
          t(ddindx).attribute8 := a38(indx);
          t(ddindx).attribute9 := a39(indx);
          t(ddindx).attribute10 := a40(indx);
          t(ddindx).attribute11 := a41(indx);
          t(ddindx).attribute12 := a42(indx);
          t(ddindx).attribute13 := a43(indx);
          t(ddindx).attribute14 := a44(indx);
          t(ddindx).attribute15 := a45(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).subsidy_pool_id := rosetta_g_miss_num_map(a51(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_sub_pvt.subv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
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
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
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
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
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
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_500();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
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
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
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
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_500();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a4(indx) := t(ddindx).name;
          a5(indx) := t(ddindx).short_description;
          a6(indx) := t(ddindx).description;
          a7(indx) := t(ddindx).effective_from_date;
          a8(indx) := t(ddindx).effective_to_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).expire_after_days);
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := t(ddindx).exclusive_yn;
          a12(indx) := t(ddindx).applicable_to_release_yn;
          a13(indx) := t(ddindx).subsidy_calc_basis;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).formula_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).rate_points);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_term);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a20(indx) := t(ddindx).accounting_method_code;
          a21(indx) := t(ddindx).recourse_yn;
          a22(indx) := t(ddindx).termination_refund_basis;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).refund_formula_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).stream_type_id);
          a25(indx) := t(ddindx).receipt_method_code;
          a26(indx) := t(ddindx).customer_visible_yn;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_financed_amount);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_subsidy_amount);
          a29(indx) := t(ddindx).transfer_basis_code;
          a30(indx) := t(ddindx).attribute_category;
          a31(indx) := t(ddindx).attribute1;
          a32(indx) := t(ddindx).attribute2;
          a33(indx) := t(ddindx).attribute3;
          a34(indx) := t(ddindx).attribute4;
          a35(indx) := t(ddindx).attribute5;
          a36(indx) := t(ddindx).attribute6;
          a37(indx) := t(ddindx).attribute7;
          a38(indx) := t(ddindx).attribute8;
          a39(indx) := t(ddindx).attribute9;
          a40(indx) := t(ddindx).attribute10;
          a41(indx) := t(ddindx).attribute11;
          a42(indx) := t(ddindx).attribute12;
          a43(indx) := t(ddindx).attribute13;
          a44(indx) := t(ddindx).attribute14;
          a45(indx) := t(ddindx).attribute15;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a47(indx) := t(ddindx).creation_date;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a49(indx) := t(ddindx).last_update_date;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).subsidy_pool_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_sub_pvt.subt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).short_description := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).language := a3(indx);
          t(ddindx).source_lang := a4(indx);
          t(ddindx).sfwt_flag := a5(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_sub_pvt.subt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).short_description;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).language;
          a4(indx) := t(ddindx).source_lang;
          a5(indx) := t(ddindx).sfwt_flag;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_sub_pvt.subb_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
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
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
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
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
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
          t(ddindx).org_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).name := a3(indx);
          t(ddindx).effective_from_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).effective_to_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).expire_after_days := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).currency_code := a7(indx);
          t(ddindx).exclusive_yn := a8(indx);
          t(ddindx).applicable_to_release_yn := a9(indx);
          t(ddindx).subsidy_calc_basis := a10(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).formula_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).rate_points := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).maximum_term := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).accounting_method_code := a17(indx);
          t(ddindx).recourse_yn := a18(indx);
          t(ddindx).termination_refund_basis := a19(indx);
          t(ddindx).refund_formula_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).stream_type_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).receipt_method_code := a22(indx);
          t(ddindx).customer_visible_yn := a23(indx);
          t(ddindx).maximum_financed_amount := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).maximum_subsidy_amount := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).transfer_basis_code := a26(indx);
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
          t(ddindx).subsidy_pool_id := rosetta_g_miss_num_map(a48(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_sub_pvt.subb_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
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
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
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
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
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
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
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
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a3(indx) := t(ddindx).name;
          a4(indx) := t(ddindx).effective_from_date;
          a5(indx) := t(ddindx).effective_to_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).expire_after_days);
          a7(indx) := t(ddindx).currency_code;
          a8(indx) := t(ddindx).exclusive_yn;
          a9(indx) := t(ddindx).applicable_to_release_yn;
          a10(indx) := t(ddindx).subsidy_calc_basis;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).formula_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).rate_points);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_term);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a17(indx) := t(ddindx).accounting_method_code;
          a18(indx) := t(ddindx).recourse_yn;
          a19(indx) := t(ddindx).termination_refund_basis;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).refund_formula_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).stream_type_id);
          a22(indx) := t(ddindx).receipt_method_code;
          a23(indx) := t(ddindx).customer_visible_yn;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_financed_amount);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).maximum_subsidy_amount);
          a26(indx) := t(ddindx).transfer_basis_code;
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
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).subsidy_pool_id);
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
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
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
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
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
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_sub_pvt.subv_rec_type;
    ddx_subv_rec okl_sub_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);


    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec,
      ddx_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_subv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_subv_rec.object_version_number);
    p6_a2 := ddx_subv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_subv_rec.org_id);
    p6_a4 := ddx_subv_rec.name;
    p6_a5 := ddx_subv_rec.short_description;
    p6_a6 := ddx_subv_rec.description;
    p6_a7 := ddx_subv_rec.effective_from_date;
    p6_a8 := ddx_subv_rec.effective_to_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_subv_rec.expire_after_days);
    p6_a10 := ddx_subv_rec.currency_code;
    p6_a11 := ddx_subv_rec.exclusive_yn;
    p6_a12 := ddx_subv_rec.applicable_to_release_yn;
    p6_a13 := ddx_subv_rec.subsidy_calc_basis;
    p6_a14 := rosetta_g_miss_num_map(ddx_subv_rec.amount);
    p6_a15 := rosetta_g_miss_num_map(ddx_subv_rec.percent);
    p6_a16 := rosetta_g_miss_num_map(ddx_subv_rec.formula_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_subv_rec.rate_points);
    p6_a18 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_term);
    p6_a19 := rosetta_g_miss_num_map(ddx_subv_rec.vendor_id);
    p6_a20 := ddx_subv_rec.accounting_method_code;
    p6_a21 := ddx_subv_rec.recourse_yn;
    p6_a22 := ddx_subv_rec.termination_refund_basis;
    p6_a23 := rosetta_g_miss_num_map(ddx_subv_rec.refund_formula_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_subv_rec.stream_type_id);
    p6_a25 := ddx_subv_rec.receipt_method_code;
    p6_a26 := ddx_subv_rec.customer_visible_yn;
    p6_a27 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_financed_amount);
    p6_a28 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_subsidy_amount);
    p6_a29 := ddx_subv_rec.transfer_basis_code;
    p6_a30 := ddx_subv_rec.attribute_category;
    p6_a31 := ddx_subv_rec.attribute1;
    p6_a32 := ddx_subv_rec.attribute2;
    p6_a33 := ddx_subv_rec.attribute3;
    p6_a34 := ddx_subv_rec.attribute4;
    p6_a35 := ddx_subv_rec.attribute5;
    p6_a36 := ddx_subv_rec.attribute6;
    p6_a37 := ddx_subv_rec.attribute7;
    p6_a38 := ddx_subv_rec.attribute8;
    p6_a39 := ddx_subv_rec.attribute9;
    p6_a40 := ddx_subv_rec.attribute10;
    p6_a41 := ddx_subv_rec.attribute11;
    p6_a42 := ddx_subv_rec.attribute12;
    p6_a43 := ddx_subv_rec.attribute13;
    p6_a44 := ddx_subv_rec.attribute14;
    p6_a45 := ddx_subv_rec.attribute15;
    p6_a46 := rosetta_g_miss_num_map(ddx_subv_rec.created_by);
    p6_a47 := ddx_subv_rec.creation_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_subv_rec.last_updated_by);
    p6_a49 := ddx_subv_rec.last_update_date;
    p6_a50 := rosetta_g_miss_num_map(ddx_subv_rec.last_update_login);
    p6_a51 := rosetta_g_miss_num_map(ddx_subv_rec.subsidy_pool_id);
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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
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
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
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
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddx_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl,
      ddx_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sub_pvt_w.rosetta_table_copy_out_p2(ddx_subv_tbl, p6_a0
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
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
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_sub_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);

    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec);

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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
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
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl);

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
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
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
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
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
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_sub_pvt.subv_rec_type;
    ddx_subv_rec okl_sub_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);


    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec,
      ddx_subv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_subv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_subv_rec.object_version_number);
    p6_a2 := ddx_subv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_subv_rec.org_id);
    p6_a4 := ddx_subv_rec.name;
    p6_a5 := ddx_subv_rec.short_description;
    p6_a6 := ddx_subv_rec.description;
    p6_a7 := ddx_subv_rec.effective_from_date;
    p6_a8 := ddx_subv_rec.effective_to_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_subv_rec.expire_after_days);
    p6_a10 := ddx_subv_rec.currency_code;
    p6_a11 := ddx_subv_rec.exclusive_yn;
    p6_a12 := ddx_subv_rec.applicable_to_release_yn;
    p6_a13 := ddx_subv_rec.subsidy_calc_basis;
    p6_a14 := rosetta_g_miss_num_map(ddx_subv_rec.amount);
    p6_a15 := rosetta_g_miss_num_map(ddx_subv_rec.percent);
    p6_a16 := rosetta_g_miss_num_map(ddx_subv_rec.formula_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_subv_rec.rate_points);
    p6_a18 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_term);
    p6_a19 := rosetta_g_miss_num_map(ddx_subv_rec.vendor_id);
    p6_a20 := ddx_subv_rec.accounting_method_code;
    p6_a21 := ddx_subv_rec.recourse_yn;
    p6_a22 := ddx_subv_rec.termination_refund_basis;
    p6_a23 := rosetta_g_miss_num_map(ddx_subv_rec.refund_formula_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_subv_rec.stream_type_id);
    p6_a25 := ddx_subv_rec.receipt_method_code;
    p6_a26 := ddx_subv_rec.customer_visible_yn;
    p6_a27 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_financed_amount);
    p6_a28 := rosetta_g_miss_num_map(ddx_subv_rec.maximum_subsidy_amount);
    p6_a29 := ddx_subv_rec.transfer_basis_code;
    p6_a30 := ddx_subv_rec.attribute_category;
    p6_a31 := ddx_subv_rec.attribute1;
    p6_a32 := ddx_subv_rec.attribute2;
    p6_a33 := ddx_subv_rec.attribute3;
    p6_a34 := ddx_subv_rec.attribute4;
    p6_a35 := ddx_subv_rec.attribute5;
    p6_a36 := ddx_subv_rec.attribute6;
    p6_a37 := ddx_subv_rec.attribute7;
    p6_a38 := ddx_subv_rec.attribute8;
    p6_a39 := ddx_subv_rec.attribute9;
    p6_a40 := ddx_subv_rec.attribute10;
    p6_a41 := ddx_subv_rec.attribute11;
    p6_a42 := ddx_subv_rec.attribute12;
    p6_a43 := ddx_subv_rec.attribute13;
    p6_a44 := ddx_subv_rec.attribute14;
    p6_a45 := ddx_subv_rec.attribute15;
    p6_a46 := rosetta_g_miss_num_map(ddx_subv_rec.created_by);
    p6_a47 := ddx_subv_rec.creation_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_subv_rec.last_updated_by);
    p6_a49 := ddx_subv_rec.last_update_date;
    p6_a50 := rosetta_g_miss_num_map(ddx_subv_rec.last_update_login);
    p6_a51 := rosetta_g_miss_num_map(ddx_subv_rec.subsidy_pool_id);
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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
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
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
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
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddx_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl,
      ddx_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sub_pvt_w.rosetta_table_copy_out_p2(ddx_subv_tbl, p6_a0
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
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
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_sub_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);

    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec);

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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
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
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl);

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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
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
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
  )

  as
    ddp_subv_rec okl_sub_pvt.subv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_subv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_subv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_subv_rec.sfwt_flag := p5_a2;
    ddp_subv_rec.org_id := rosetta_g_miss_num_map(p5_a3);
    ddp_subv_rec.name := p5_a4;
    ddp_subv_rec.short_description := p5_a5;
    ddp_subv_rec.description := p5_a6;
    ddp_subv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_subv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_subv_rec.expire_after_days := rosetta_g_miss_num_map(p5_a9);
    ddp_subv_rec.currency_code := p5_a10;
    ddp_subv_rec.exclusive_yn := p5_a11;
    ddp_subv_rec.applicable_to_release_yn := p5_a12;
    ddp_subv_rec.subsidy_calc_basis := p5_a13;
    ddp_subv_rec.amount := rosetta_g_miss_num_map(p5_a14);
    ddp_subv_rec.percent := rosetta_g_miss_num_map(p5_a15);
    ddp_subv_rec.formula_id := rosetta_g_miss_num_map(p5_a16);
    ddp_subv_rec.rate_points := rosetta_g_miss_num_map(p5_a17);
    ddp_subv_rec.maximum_term := rosetta_g_miss_num_map(p5_a18);
    ddp_subv_rec.vendor_id := rosetta_g_miss_num_map(p5_a19);
    ddp_subv_rec.accounting_method_code := p5_a20;
    ddp_subv_rec.recourse_yn := p5_a21;
    ddp_subv_rec.termination_refund_basis := p5_a22;
    ddp_subv_rec.refund_formula_id := rosetta_g_miss_num_map(p5_a23);
    ddp_subv_rec.stream_type_id := rosetta_g_miss_num_map(p5_a24);
    ddp_subv_rec.receipt_method_code := p5_a25;
    ddp_subv_rec.customer_visible_yn := p5_a26;
    ddp_subv_rec.maximum_financed_amount := rosetta_g_miss_num_map(p5_a27);
    ddp_subv_rec.maximum_subsidy_amount := rosetta_g_miss_num_map(p5_a28);
    ddp_subv_rec.transfer_basis_code := p5_a29;
    ddp_subv_rec.attribute_category := p5_a30;
    ddp_subv_rec.attribute1 := p5_a31;
    ddp_subv_rec.attribute2 := p5_a32;
    ddp_subv_rec.attribute3 := p5_a33;
    ddp_subv_rec.attribute4 := p5_a34;
    ddp_subv_rec.attribute5 := p5_a35;
    ddp_subv_rec.attribute6 := p5_a36;
    ddp_subv_rec.attribute7 := p5_a37;
    ddp_subv_rec.attribute8 := p5_a38;
    ddp_subv_rec.attribute9 := p5_a39;
    ddp_subv_rec.attribute10 := p5_a40;
    ddp_subv_rec.attribute11 := p5_a41;
    ddp_subv_rec.attribute12 := p5_a42;
    ddp_subv_rec.attribute13 := p5_a43;
    ddp_subv_rec.attribute14 := p5_a44;
    ddp_subv_rec.attribute15 := p5_a45;
    ddp_subv_rec.created_by := rosetta_g_miss_num_map(p5_a46);
    ddp_subv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_subv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a48);
    ddp_subv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a49);
    ddp_subv_rec.last_update_login := rosetta_g_miss_num_map(p5_a50);
    ddp_subv_rec.subsidy_pool_id := rosetta_g_miss_num_map(p5_a51);

    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_rec);

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
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
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
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
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
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
  )

  as
    ddp_subv_tbl okl_sub_pvt.subv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sub_pvt_w.rosetta_table_copy_in_p2(ddp_subv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sub_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_subv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sub_pvt_w;

/
