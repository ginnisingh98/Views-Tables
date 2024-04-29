--------------------------------------------------------
--  DDL for Package Body OKL_POOL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POOL_PVT_W" as
  /* $Header: OKLESZPB.pls 120.5 2007/12/14 11:10:17 ssdeshpa noship $ */
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

  procedure rosetta_table_copy_in_p46(t out nocopy okl_pool_pvt.polsrch_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_DATE_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cust_object1_id1 := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).lessee := a1(indx);
          t(ddindx).sic_code := a2(indx);
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).contract_number := a4(indx);
          t(ddindx).pre_tax_yield_from := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).pre_tax_yield_to := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).book_classification := a7(indx);
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).start_from_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).start_to_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).end_from_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).end_to_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).operating_unit := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).currency_code := a14(indx);
          t(ddindx).tax_owner := a15(indx);
          t(ddindx).kle_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).asset_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).asset_number := a18(indx);
          t(ddindx).model_number := a19(indx);
          t(ddindx).manufacturer_name := a20(indx);
          t(ddindx).location_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).item_id1 := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).vendor_id1 := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).oec_from := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).oec_to := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).residual_percentage := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).stream_type_code := a28(indx);
          t(ddindx).stream_type_name := a29(indx);
          t(ddindx).stream_say_code := a30(indx);
          t(ddindx).stream_active_yn := a31(indx);
          t(ddindx).stream_element_from_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).stream_element_to_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).stream_element_amount := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).pol_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).streams_from_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).streams_to_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).stream_element_payment_freq := a38(indx);
          t(ddindx).cust_crd_clf_code := a39(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p46;
  procedure rosetta_table_copy_out_p46(t okl_pool_pvt.polsrch_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cust_object1_id1);
          a1(indx) := t(ddindx).lessee;
          a2(indx) := t(ddindx).sic_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a4(indx) := t(ddindx).contract_number;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_yield_from);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_yield_to);
          a7(indx) := t(ddindx).book_classification;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a9(indx) := t(ddindx).start_from_date;
          a10(indx) := t(ddindx).start_to_date;
          a11(indx) := t(ddindx).end_from_date;
          a12(indx) := t(ddindx).end_to_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).operating_unit);
          a14(indx) := t(ddindx).currency_code;
          a15(indx) := t(ddindx).tax_owner;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).asset_id);
          a18(indx) := t(ddindx).asset_number;
          a19(indx) := t(ddindx).model_number;
          a20(indx) := t(ddindx).manufacturer_name;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).item_id1);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id1);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).oec_from);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).oec_to);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).residual_percentage);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a28(indx) := t(ddindx).stream_type_code;
          a29(indx) := t(ddindx).stream_type_name;
          a30(indx) := t(ddindx).stream_say_code;
          a31(indx) := t(ddindx).stream_active_yn;
          a32(indx) := t(ddindx).stream_element_from_date;
          a33(indx) := t(ddindx).stream_element_to_date;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).stream_element_amount);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).pol_id);
          a36(indx) := t(ddindx).streams_from_date;
          a37(indx) := t(ddindx).streams_to_date;
          a38(indx) := t(ddindx).stream_element_payment_freq;
          a39(indx) := t(ddindx).cust_crd_clf_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p46;

  procedure rosetta_table_copy_in_p48(t out nocopy okl_pool_pvt.poc_uv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).poc_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).contract_number := a1(indx);
          t(ddindx).asset_number := a2(indx);
          t(ddindx).lessee := a3(indx);
          t(ddindx).stream_type_name := a4(indx);
          t(ddindx).pool_amount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).sty_subclass_code := a6(indx);
          t(ddindx).sty_subclass := a7(indx);
          t(ddindx).stream_type_purpose := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p48;
  procedure rosetta_table_copy_out_p48(t okl_pool_pvt.poc_uv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_400();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_400();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).poc_id);
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).asset_number;
          a3(indx) := t(ddindx).lessee;
          a4(indx) := t(ddindx).stream_type_name;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).pool_amount);
          a6(indx) := t(ddindx).sty_subclass_code;
          a7(indx) := t(ddindx).sty_subclass;
          a8(indx) := t(ddindx).stream_type_purpose;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p48;

  procedure create_pool(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
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
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
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
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_polv_rec okl_pool_pvt.polv_rec_type;
    ddx_polv_rec okl_pool_pvt.polv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_polv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_polv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_polv_rec.pot_id := rosetta_g_miss_num_map(p5_a2);
    ddp_polv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_polv_rec.pool_number := p5_a4;
    ddp_polv_rec.description := p5_a5;
    ddp_polv_rec.short_description := p5_a6;
    ddp_polv_rec.currency_code := p5_a7;
    ddp_polv_rec.total_principal_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_polv_rec.total_receivable_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_polv_rec.securities_credit_rating := p5_a10;
    ddp_polv_rec.date_created := rosetta_g_miss_date_in_map(p5_a11);
    ddp_polv_rec.date_last_updated := rosetta_g_miss_date_in_map(p5_a12);
    ddp_polv_rec.date_last_reconciled := rosetta_g_miss_date_in_map(p5_a13);
    ddp_polv_rec.date_total_principal_calc := rosetta_g_miss_date_in_map(p5_a14);
    ddp_polv_rec.status_code := p5_a15;
    ddp_polv_rec.display_in_lease_center := p5_a16;
    ddp_polv_rec.attribute_category := p5_a17;
    ddp_polv_rec.attribute1 := p5_a18;
    ddp_polv_rec.attribute2 := p5_a19;
    ddp_polv_rec.attribute3 := p5_a20;
    ddp_polv_rec.attribute4 := p5_a21;
    ddp_polv_rec.attribute5 := p5_a22;
    ddp_polv_rec.attribute6 := p5_a23;
    ddp_polv_rec.attribute7 := p5_a24;
    ddp_polv_rec.attribute8 := p5_a25;
    ddp_polv_rec.attribute9 := p5_a26;
    ddp_polv_rec.attribute10 := p5_a27;
    ddp_polv_rec.attribute11 := p5_a28;
    ddp_polv_rec.attribute12 := p5_a29;
    ddp_polv_rec.attribute13 := p5_a30;
    ddp_polv_rec.attribute14 := p5_a31;
    ddp_polv_rec.attribute15 := p5_a32;
    ddp_polv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_polv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_polv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_polv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_polv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_polv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_polv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_polv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a40);
    ddp_polv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_polv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_polv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a43);


    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.create_pool(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_polv_rec,
      ddx_polv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_polv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_polv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_polv_rec.pot_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_polv_rec.khr_id);
    p6_a4 := ddx_polv_rec.pool_number;
    p6_a5 := ddx_polv_rec.description;
    p6_a6 := ddx_polv_rec.short_description;
    p6_a7 := ddx_polv_rec.currency_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_polv_rec.total_principal_amount);
    p6_a9 := rosetta_g_miss_num_map(ddx_polv_rec.total_receivable_amount);
    p6_a10 := ddx_polv_rec.securities_credit_rating;
    p6_a11 := ddx_polv_rec.date_created;
    p6_a12 := ddx_polv_rec.date_last_updated;
    p6_a13 := ddx_polv_rec.date_last_reconciled;
    p6_a14 := ddx_polv_rec.date_total_principal_calc;
    p6_a15 := ddx_polv_rec.status_code;
    p6_a16 := ddx_polv_rec.display_in_lease_center;
    p6_a17 := ddx_polv_rec.attribute_category;
    p6_a18 := ddx_polv_rec.attribute1;
    p6_a19 := ddx_polv_rec.attribute2;
    p6_a20 := ddx_polv_rec.attribute3;
    p6_a21 := ddx_polv_rec.attribute4;
    p6_a22 := ddx_polv_rec.attribute5;
    p6_a23 := ddx_polv_rec.attribute6;
    p6_a24 := ddx_polv_rec.attribute7;
    p6_a25 := ddx_polv_rec.attribute8;
    p6_a26 := ddx_polv_rec.attribute9;
    p6_a27 := ddx_polv_rec.attribute10;
    p6_a28 := ddx_polv_rec.attribute11;
    p6_a29 := ddx_polv_rec.attribute12;
    p6_a30 := ddx_polv_rec.attribute13;
    p6_a31 := ddx_polv_rec.attribute14;
    p6_a32 := ddx_polv_rec.attribute15;
    p6_a33 := rosetta_g_miss_num_map(ddx_polv_rec.org_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_polv_rec.request_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_polv_rec.program_application_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_polv_rec.program_id);
    p6_a37 := ddx_polv_rec.program_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_polv_rec.created_by);
    p6_a39 := ddx_polv_rec.creation_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_polv_rec.last_updated_by);
    p6_a41 := ddx_polv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_polv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_polv_rec.legal_entity_id);
  end;

  procedure update_pool(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
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
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
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
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_polv_rec okl_pool_pvt.polv_rec_type;
    ddx_polv_rec okl_pool_pvt.polv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_polv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_polv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_polv_rec.pot_id := rosetta_g_miss_num_map(p5_a2);
    ddp_polv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_polv_rec.pool_number := p5_a4;
    ddp_polv_rec.description := p5_a5;
    ddp_polv_rec.short_description := p5_a6;
    ddp_polv_rec.currency_code := p5_a7;
    ddp_polv_rec.total_principal_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_polv_rec.total_receivable_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_polv_rec.securities_credit_rating := p5_a10;
    ddp_polv_rec.date_created := rosetta_g_miss_date_in_map(p5_a11);
    ddp_polv_rec.date_last_updated := rosetta_g_miss_date_in_map(p5_a12);
    ddp_polv_rec.date_last_reconciled := rosetta_g_miss_date_in_map(p5_a13);
    ddp_polv_rec.date_total_principal_calc := rosetta_g_miss_date_in_map(p5_a14);
    ddp_polv_rec.status_code := p5_a15;
    ddp_polv_rec.display_in_lease_center := p5_a16;
    ddp_polv_rec.attribute_category := p5_a17;
    ddp_polv_rec.attribute1 := p5_a18;
    ddp_polv_rec.attribute2 := p5_a19;
    ddp_polv_rec.attribute3 := p5_a20;
    ddp_polv_rec.attribute4 := p5_a21;
    ddp_polv_rec.attribute5 := p5_a22;
    ddp_polv_rec.attribute6 := p5_a23;
    ddp_polv_rec.attribute7 := p5_a24;
    ddp_polv_rec.attribute8 := p5_a25;
    ddp_polv_rec.attribute9 := p5_a26;
    ddp_polv_rec.attribute10 := p5_a27;
    ddp_polv_rec.attribute11 := p5_a28;
    ddp_polv_rec.attribute12 := p5_a29;
    ddp_polv_rec.attribute13 := p5_a30;
    ddp_polv_rec.attribute14 := p5_a31;
    ddp_polv_rec.attribute15 := p5_a32;
    ddp_polv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_polv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_polv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_polv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_polv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_polv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_polv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_polv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a40);
    ddp_polv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_polv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_polv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a43);


    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.update_pool(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_polv_rec,
      ddx_polv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_polv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_polv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_polv_rec.pot_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_polv_rec.khr_id);
    p6_a4 := ddx_polv_rec.pool_number;
    p6_a5 := ddx_polv_rec.description;
    p6_a6 := ddx_polv_rec.short_description;
    p6_a7 := ddx_polv_rec.currency_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_polv_rec.total_principal_amount);
    p6_a9 := rosetta_g_miss_num_map(ddx_polv_rec.total_receivable_amount);
    p6_a10 := ddx_polv_rec.securities_credit_rating;
    p6_a11 := ddx_polv_rec.date_created;
    p6_a12 := ddx_polv_rec.date_last_updated;
    p6_a13 := ddx_polv_rec.date_last_reconciled;
    p6_a14 := ddx_polv_rec.date_total_principal_calc;
    p6_a15 := ddx_polv_rec.status_code;
    p6_a16 := ddx_polv_rec.display_in_lease_center;
    p6_a17 := ddx_polv_rec.attribute_category;
    p6_a18 := ddx_polv_rec.attribute1;
    p6_a19 := ddx_polv_rec.attribute2;
    p6_a20 := ddx_polv_rec.attribute3;
    p6_a21 := ddx_polv_rec.attribute4;
    p6_a22 := ddx_polv_rec.attribute5;
    p6_a23 := ddx_polv_rec.attribute6;
    p6_a24 := ddx_polv_rec.attribute7;
    p6_a25 := ddx_polv_rec.attribute8;
    p6_a26 := ddx_polv_rec.attribute9;
    p6_a27 := ddx_polv_rec.attribute10;
    p6_a28 := ddx_polv_rec.attribute11;
    p6_a29 := ddx_polv_rec.attribute12;
    p6_a30 := ddx_polv_rec.attribute13;
    p6_a31 := ddx_polv_rec.attribute14;
    p6_a32 := ddx_polv_rec.attribute15;
    p6_a33 := rosetta_g_miss_num_map(ddx_polv_rec.org_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_polv_rec.request_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_polv_rec.program_application_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_polv_rec.program_id);
    p6_a37 := ddx_polv_rec.program_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_polv_rec.created_by);
    p6_a39 := ddx_polv_rec.creation_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_polv_rec.last_updated_by);
    p6_a41 := ddx_polv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_polv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_polv_rec.legal_entity_id);
  end;

  procedure delete_pool(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
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
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_polv_rec okl_pool_pvt.polv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_polv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_polv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_polv_rec.pot_id := rosetta_g_miss_num_map(p5_a2);
    ddp_polv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_polv_rec.pool_number := p5_a4;
    ddp_polv_rec.description := p5_a5;
    ddp_polv_rec.short_description := p5_a6;
    ddp_polv_rec.currency_code := p5_a7;
    ddp_polv_rec.total_principal_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_polv_rec.total_receivable_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_polv_rec.securities_credit_rating := p5_a10;
    ddp_polv_rec.date_created := rosetta_g_miss_date_in_map(p5_a11);
    ddp_polv_rec.date_last_updated := rosetta_g_miss_date_in_map(p5_a12);
    ddp_polv_rec.date_last_reconciled := rosetta_g_miss_date_in_map(p5_a13);
    ddp_polv_rec.date_total_principal_calc := rosetta_g_miss_date_in_map(p5_a14);
    ddp_polv_rec.status_code := p5_a15;
    ddp_polv_rec.display_in_lease_center := p5_a16;
    ddp_polv_rec.attribute_category := p5_a17;
    ddp_polv_rec.attribute1 := p5_a18;
    ddp_polv_rec.attribute2 := p5_a19;
    ddp_polv_rec.attribute3 := p5_a20;
    ddp_polv_rec.attribute4 := p5_a21;
    ddp_polv_rec.attribute5 := p5_a22;
    ddp_polv_rec.attribute6 := p5_a23;
    ddp_polv_rec.attribute7 := p5_a24;
    ddp_polv_rec.attribute8 := p5_a25;
    ddp_polv_rec.attribute9 := p5_a26;
    ddp_polv_rec.attribute10 := p5_a27;
    ddp_polv_rec.attribute11 := p5_a28;
    ddp_polv_rec.attribute12 := p5_a29;
    ddp_polv_rec.attribute13 := p5_a30;
    ddp_polv_rec.attribute14 := p5_a31;
    ddp_polv_rec.attribute15 := p5_a32;
    ddp_polv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_polv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_polv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_polv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_polv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_polv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_polv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_polv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a40);
    ddp_polv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_polv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_polv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a43);

    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.delete_pool(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_polv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_pool_contents(p_api_version  NUMBER
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
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
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
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
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
    ddp_pocv_rec okl_pool_pvt.pocv_rec_type;
    ddx_pocv_rec okl_pool_pvt.pocv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pocv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pocv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pocv_rec.pol_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pocv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pocv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pocv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pocv_rec.stm_id := rosetta_g_miss_num_map(p5_a6);
    ddp_pocv_rec.sty_code := p5_a7;
    ddp_pocv_rec.pox_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pocv_rec.streams_from_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_pocv_rec.streams_to_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pocv_rec.transaction_number_in := rosetta_g_miss_num_map(p5_a11);
    ddp_pocv_rec.transaction_number_out := rosetta_g_miss_num_map(p5_a12);
    ddp_pocv_rec.date_inactive := rosetta_g_miss_date_in_map(p5_a13);
    ddp_pocv_rec.attribute_category := p5_a14;
    ddp_pocv_rec.status_code := p5_a15;
    ddp_pocv_rec.attribute1 := p5_a16;
    ddp_pocv_rec.attribute2 := p5_a17;
    ddp_pocv_rec.attribute3 := p5_a18;
    ddp_pocv_rec.attribute4 := p5_a19;
    ddp_pocv_rec.attribute5 := p5_a20;
    ddp_pocv_rec.attribute6 := p5_a21;
    ddp_pocv_rec.attribute7 := p5_a22;
    ddp_pocv_rec.attribute8 := p5_a23;
    ddp_pocv_rec.attribute9 := p5_a24;
    ddp_pocv_rec.attribute10 := p5_a25;
    ddp_pocv_rec.attribute11 := p5_a26;
    ddp_pocv_rec.attribute12 := p5_a27;
    ddp_pocv_rec.attribute13 := p5_a28;
    ddp_pocv_rec.attribute14 := p5_a29;
    ddp_pocv_rec.attribute15 := p5_a30;
    ddp_pocv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_pocv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_pocv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_pocv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_pocv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_pocv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_pocv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_pocv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_pocv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.create_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pocv_rec,
      ddx_pocv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pocv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pocv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pocv_rec.pol_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_pocv_rec.khr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_pocv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_pocv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_pocv_rec.stm_id);
    p6_a7 := ddx_pocv_rec.sty_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_pocv_rec.pox_id);
    p6_a9 := ddx_pocv_rec.streams_from_date;
    p6_a10 := ddx_pocv_rec.streams_to_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_pocv_rec.transaction_number_in);
    p6_a12 := rosetta_g_miss_num_map(ddx_pocv_rec.transaction_number_out);
    p6_a13 := ddx_pocv_rec.date_inactive;
    p6_a14 := ddx_pocv_rec.attribute_category;
    p6_a15 := ddx_pocv_rec.status_code;
    p6_a16 := ddx_pocv_rec.attribute1;
    p6_a17 := ddx_pocv_rec.attribute2;
    p6_a18 := ddx_pocv_rec.attribute3;
    p6_a19 := ddx_pocv_rec.attribute4;
    p6_a20 := ddx_pocv_rec.attribute5;
    p6_a21 := ddx_pocv_rec.attribute6;
    p6_a22 := ddx_pocv_rec.attribute7;
    p6_a23 := ddx_pocv_rec.attribute8;
    p6_a24 := ddx_pocv_rec.attribute9;
    p6_a25 := ddx_pocv_rec.attribute10;
    p6_a26 := ddx_pocv_rec.attribute11;
    p6_a27 := ddx_pocv_rec.attribute12;
    p6_a28 := ddx_pocv_rec.attribute13;
    p6_a29 := ddx_pocv_rec.attribute14;
    p6_a30 := ddx_pocv_rec.attribute15;
    p6_a31 := rosetta_g_miss_num_map(ddx_pocv_rec.request_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_pocv_rec.program_application_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_pocv_rec.program_id);
    p6_a34 := ddx_pocv_rec.program_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_pocv_rec.created_by);
    p6_a36 := ddx_pocv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_pocv_rec.last_updated_by);
    p6_a38 := ddx_pocv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_pocv_rec.last_update_login);
  end;

  procedure create_pool_contents(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
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
    , p5_a30 JTF_VARCHAR2_TABLE_500
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
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
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
    ddp_pocv_tbl okl_pool_pvt.pocv_tbl_type;
    ddx_pocv_tbl okl_pool_pvt.pocv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_poc_pvt_w.rosetta_table_copy_in_p2(ddp_pocv_tbl, p5_a0
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
    okl_pool_pvt.create_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pocv_tbl,
      ddx_pocv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_poc_pvt_w.rosetta_table_copy_out_p2(ddx_pocv_tbl, p6_a0
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

  procedure update_pool_contents(p_api_version  NUMBER
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
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
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
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
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
    ddp_pocv_rec okl_pool_pvt.pocv_rec_type;
    ddx_pocv_rec okl_pool_pvt.pocv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pocv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pocv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pocv_rec.pol_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pocv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pocv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pocv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pocv_rec.stm_id := rosetta_g_miss_num_map(p5_a6);
    ddp_pocv_rec.sty_code := p5_a7;
    ddp_pocv_rec.pox_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pocv_rec.streams_from_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_pocv_rec.streams_to_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pocv_rec.transaction_number_in := rosetta_g_miss_num_map(p5_a11);
    ddp_pocv_rec.transaction_number_out := rosetta_g_miss_num_map(p5_a12);
    ddp_pocv_rec.date_inactive := rosetta_g_miss_date_in_map(p5_a13);
    ddp_pocv_rec.attribute_category := p5_a14;
    ddp_pocv_rec.status_code := p5_a15;
    ddp_pocv_rec.attribute1 := p5_a16;
    ddp_pocv_rec.attribute2 := p5_a17;
    ddp_pocv_rec.attribute3 := p5_a18;
    ddp_pocv_rec.attribute4 := p5_a19;
    ddp_pocv_rec.attribute5 := p5_a20;
    ddp_pocv_rec.attribute6 := p5_a21;
    ddp_pocv_rec.attribute7 := p5_a22;
    ddp_pocv_rec.attribute8 := p5_a23;
    ddp_pocv_rec.attribute9 := p5_a24;
    ddp_pocv_rec.attribute10 := p5_a25;
    ddp_pocv_rec.attribute11 := p5_a26;
    ddp_pocv_rec.attribute12 := p5_a27;
    ddp_pocv_rec.attribute13 := p5_a28;
    ddp_pocv_rec.attribute14 := p5_a29;
    ddp_pocv_rec.attribute15 := p5_a30;
    ddp_pocv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_pocv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_pocv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_pocv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_pocv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_pocv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_pocv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_pocv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_pocv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.update_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pocv_rec,
      ddx_pocv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pocv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pocv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pocv_rec.pol_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_pocv_rec.khr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_pocv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_pocv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_pocv_rec.stm_id);
    p6_a7 := ddx_pocv_rec.sty_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_pocv_rec.pox_id);
    p6_a9 := ddx_pocv_rec.streams_from_date;
    p6_a10 := ddx_pocv_rec.streams_to_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_pocv_rec.transaction_number_in);
    p6_a12 := rosetta_g_miss_num_map(ddx_pocv_rec.transaction_number_out);
    p6_a13 := ddx_pocv_rec.date_inactive;
    p6_a14 := ddx_pocv_rec.attribute_category;
    p6_a15 := ddx_pocv_rec.status_code;
    p6_a16 := ddx_pocv_rec.attribute1;
    p6_a17 := ddx_pocv_rec.attribute2;
    p6_a18 := ddx_pocv_rec.attribute3;
    p6_a19 := ddx_pocv_rec.attribute4;
    p6_a20 := ddx_pocv_rec.attribute5;
    p6_a21 := ddx_pocv_rec.attribute6;
    p6_a22 := ddx_pocv_rec.attribute7;
    p6_a23 := ddx_pocv_rec.attribute8;
    p6_a24 := ddx_pocv_rec.attribute9;
    p6_a25 := ddx_pocv_rec.attribute10;
    p6_a26 := ddx_pocv_rec.attribute11;
    p6_a27 := ddx_pocv_rec.attribute12;
    p6_a28 := ddx_pocv_rec.attribute13;
    p6_a29 := ddx_pocv_rec.attribute14;
    p6_a30 := ddx_pocv_rec.attribute15;
    p6_a31 := rosetta_g_miss_num_map(ddx_pocv_rec.request_id);
    p6_a32 := rosetta_g_miss_num_map(ddx_pocv_rec.program_application_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_pocv_rec.program_id);
    p6_a34 := ddx_pocv_rec.program_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_pocv_rec.created_by);
    p6_a36 := ddx_pocv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_pocv_rec.last_updated_by);
    p6_a38 := ddx_pocv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_pocv_rec.last_update_login);
  end;

  procedure update_pool_contents(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
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
    , p5_a30 JTF_VARCHAR2_TABLE_500
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
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
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
    ddp_pocv_tbl okl_pool_pvt.pocv_tbl_type;
    ddx_pocv_tbl okl_pool_pvt.pocv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_poc_pvt_w.rosetta_table_copy_in_p2(ddp_pocv_tbl, p5_a0
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
    okl_pool_pvt.update_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pocv_tbl,
      ddx_pocv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_poc_pvt_w.rosetta_table_copy_out_p2(ddx_pocv_tbl, p6_a0
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

  procedure delete_pool_contents(p_api_version  NUMBER
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
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
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
    ddp_pocv_rec okl_pool_pvt.pocv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pocv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pocv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pocv_rec.pol_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pocv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pocv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pocv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pocv_rec.stm_id := rosetta_g_miss_num_map(p5_a6);
    ddp_pocv_rec.sty_code := p5_a7;
    ddp_pocv_rec.pox_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pocv_rec.streams_from_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_pocv_rec.streams_to_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pocv_rec.transaction_number_in := rosetta_g_miss_num_map(p5_a11);
    ddp_pocv_rec.transaction_number_out := rosetta_g_miss_num_map(p5_a12);
    ddp_pocv_rec.date_inactive := rosetta_g_miss_date_in_map(p5_a13);
    ddp_pocv_rec.attribute_category := p5_a14;
    ddp_pocv_rec.status_code := p5_a15;
    ddp_pocv_rec.attribute1 := p5_a16;
    ddp_pocv_rec.attribute2 := p5_a17;
    ddp_pocv_rec.attribute3 := p5_a18;
    ddp_pocv_rec.attribute4 := p5_a19;
    ddp_pocv_rec.attribute5 := p5_a20;
    ddp_pocv_rec.attribute6 := p5_a21;
    ddp_pocv_rec.attribute7 := p5_a22;
    ddp_pocv_rec.attribute8 := p5_a23;
    ddp_pocv_rec.attribute9 := p5_a24;
    ddp_pocv_rec.attribute10 := p5_a25;
    ddp_pocv_rec.attribute11 := p5_a26;
    ddp_pocv_rec.attribute12 := p5_a27;
    ddp_pocv_rec.attribute13 := p5_a28;
    ddp_pocv_rec.attribute14 := p5_a29;
    ddp_pocv_rec.attribute15 := p5_a30;
    ddp_pocv_rec.request_id := rosetta_g_miss_num_map(p5_a31);
    ddp_pocv_rec.program_application_id := rosetta_g_miss_num_map(p5_a32);
    ddp_pocv_rec.program_id := rosetta_g_miss_num_map(p5_a33);
    ddp_pocv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_pocv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_pocv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_pocv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_pocv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_pocv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.delete_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pocv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_pool_contents(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
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
    , p5_a30 JTF_VARCHAR2_TABLE_500
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
    ddp_pocv_tbl okl_pool_pvt.pocv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_poc_pvt_w.rosetta_table_copy_in_p2(ddp_pocv_tbl, p5_a0
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
    okl_pool_pvt.delete_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pocv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_pool_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
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
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_poxv_rec okl_pool_pvt.poxv_rec_type;
    ddx_poxv_rec okl_pool_pvt.poxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_poxv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_poxv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_poxv_rec.pol_id := rosetta_g_miss_num_map(p5_a2);
    ddp_poxv_rec.transaction_number := rosetta_g_miss_num_map(p5_a3);
    ddp_poxv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_poxv_rec.transaction_type := p5_a5;
    ddp_poxv_rec.transaction_sub_type := p5_a6;
    ddp_poxv_rec.date_effective := rosetta_g_miss_date_in_map(p5_a7);
    ddp_poxv_rec.currency_code := p5_a8;
    ddp_poxv_rec.currency_conversion_type := p5_a9;
    ddp_poxv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_poxv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a11);
    ddp_poxv_rec.transaction_reason := p5_a12;
    ddp_poxv_rec.attribute_category := p5_a13;
    ddp_poxv_rec.attribute1 := p5_a14;
    ddp_poxv_rec.attribute2 := p5_a15;
    ddp_poxv_rec.attribute3 := p5_a16;
    ddp_poxv_rec.attribute4 := p5_a17;
    ddp_poxv_rec.attribute5 := p5_a18;
    ddp_poxv_rec.attribute6 := p5_a19;
    ddp_poxv_rec.attribute7 := p5_a20;
    ddp_poxv_rec.attribute8 := p5_a21;
    ddp_poxv_rec.attribute9 := p5_a22;
    ddp_poxv_rec.attribute10 := p5_a23;
    ddp_poxv_rec.attribute11 := p5_a24;
    ddp_poxv_rec.attribute12 := p5_a25;
    ddp_poxv_rec.attribute13 := p5_a26;
    ddp_poxv_rec.attribute14 := p5_a27;
    ddp_poxv_rec.attribute15 := p5_a28;
    ddp_poxv_rec.request_id := rosetta_g_miss_num_map(p5_a29);
    ddp_poxv_rec.program_application_id := rosetta_g_miss_num_map(p5_a30);
    ddp_poxv_rec.program_id := rosetta_g_miss_num_map(p5_a31);
    ddp_poxv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_poxv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_poxv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_poxv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_poxv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_poxv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_poxv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a38);
    ddp_poxv_rec.transaction_status := p5_a39;


    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.create_pool_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_poxv_rec,
      ddx_poxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_poxv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_poxv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_poxv_rec.pol_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_poxv_rec.transaction_number);
    p6_a4 := ddx_poxv_rec.transaction_date;
    p6_a5 := ddx_poxv_rec.transaction_type;
    p6_a6 := ddx_poxv_rec.transaction_sub_type;
    p6_a7 := ddx_poxv_rec.date_effective;
    p6_a8 := ddx_poxv_rec.currency_code;
    p6_a9 := ddx_poxv_rec.currency_conversion_type;
    p6_a10 := ddx_poxv_rec.currency_conversion_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_poxv_rec.currency_conversion_rate);
    p6_a12 := ddx_poxv_rec.transaction_reason;
    p6_a13 := ddx_poxv_rec.attribute_category;
    p6_a14 := ddx_poxv_rec.attribute1;
    p6_a15 := ddx_poxv_rec.attribute2;
    p6_a16 := ddx_poxv_rec.attribute3;
    p6_a17 := ddx_poxv_rec.attribute4;
    p6_a18 := ddx_poxv_rec.attribute5;
    p6_a19 := ddx_poxv_rec.attribute6;
    p6_a20 := ddx_poxv_rec.attribute7;
    p6_a21 := ddx_poxv_rec.attribute8;
    p6_a22 := ddx_poxv_rec.attribute9;
    p6_a23 := ddx_poxv_rec.attribute10;
    p6_a24 := ddx_poxv_rec.attribute11;
    p6_a25 := ddx_poxv_rec.attribute12;
    p6_a26 := ddx_poxv_rec.attribute13;
    p6_a27 := ddx_poxv_rec.attribute14;
    p6_a28 := ddx_poxv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_poxv_rec.request_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_poxv_rec.program_application_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_poxv_rec.program_id);
    p6_a32 := ddx_poxv_rec.program_update_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_poxv_rec.created_by);
    p6_a34 := ddx_poxv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_poxv_rec.last_updated_by);
    p6_a36 := ddx_poxv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_poxv_rec.last_update_login);
    p6_a38 := rosetta_g_miss_num_map(ddx_poxv_rec.legal_entity_id);
    p6_a39 := ddx_poxv_rec.transaction_status;
  end;

  procedure update_pool_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
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
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_poxv_rec okl_pool_pvt.poxv_rec_type;
    ddx_poxv_rec okl_pool_pvt.poxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_poxv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_poxv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_poxv_rec.pol_id := rosetta_g_miss_num_map(p5_a2);
    ddp_poxv_rec.transaction_number := rosetta_g_miss_num_map(p5_a3);
    ddp_poxv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_poxv_rec.transaction_type := p5_a5;
    ddp_poxv_rec.transaction_sub_type := p5_a6;
    ddp_poxv_rec.date_effective := rosetta_g_miss_date_in_map(p5_a7);
    ddp_poxv_rec.currency_code := p5_a8;
    ddp_poxv_rec.currency_conversion_type := p5_a9;
    ddp_poxv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_poxv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a11);
    ddp_poxv_rec.transaction_reason := p5_a12;
    ddp_poxv_rec.attribute_category := p5_a13;
    ddp_poxv_rec.attribute1 := p5_a14;
    ddp_poxv_rec.attribute2 := p5_a15;
    ddp_poxv_rec.attribute3 := p5_a16;
    ddp_poxv_rec.attribute4 := p5_a17;
    ddp_poxv_rec.attribute5 := p5_a18;
    ddp_poxv_rec.attribute6 := p5_a19;
    ddp_poxv_rec.attribute7 := p5_a20;
    ddp_poxv_rec.attribute8 := p5_a21;
    ddp_poxv_rec.attribute9 := p5_a22;
    ddp_poxv_rec.attribute10 := p5_a23;
    ddp_poxv_rec.attribute11 := p5_a24;
    ddp_poxv_rec.attribute12 := p5_a25;
    ddp_poxv_rec.attribute13 := p5_a26;
    ddp_poxv_rec.attribute14 := p5_a27;
    ddp_poxv_rec.attribute15 := p5_a28;
    ddp_poxv_rec.request_id := rosetta_g_miss_num_map(p5_a29);
    ddp_poxv_rec.program_application_id := rosetta_g_miss_num_map(p5_a30);
    ddp_poxv_rec.program_id := rosetta_g_miss_num_map(p5_a31);
    ddp_poxv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_poxv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_poxv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_poxv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_poxv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_poxv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_poxv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a38);
    ddp_poxv_rec.transaction_status := p5_a39;


    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.update_pool_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_poxv_rec,
      ddx_poxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_poxv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_poxv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_poxv_rec.pol_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_poxv_rec.transaction_number);
    p6_a4 := ddx_poxv_rec.transaction_date;
    p6_a5 := ddx_poxv_rec.transaction_type;
    p6_a6 := ddx_poxv_rec.transaction_sub_type;
    p6_a7 := ddx_poxv_rec.date_effective;
    p6_a8 := ddx_poxv_rec.currency_code;
    p6_a9 := ddx_poxv_rec.currency_conversion_type;
    p6_a10 := ddx_poxv_rec.currency_conversion_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_poxv_rec.currency_conversion_rate);
    p6_a12 := ddx_poxv_rec.transaction_reason;
    p6_a13 := ddx_poxv_rec.attribute_category;
    p6_a14 := ddx_poxv_rec.attribute1;
    p6_a15 := ddx_poxv_rec.attribute2;
    p6_a16 := ddx_poxv_rec.attribute3;
    p6_a17 := ddx_poxv_rec.attribute4;
    p6_a18 := ddx_poxv_rec.attribute5;
    p6_a19 := ddx_poxv_rec.attribute6;
    p6_a20 := ddx_poxv_rec.attribute7;
    p6_a21 := ddx_poxv_rec.attribute8;
    p6_a22 := ddx_poxv_rec.attribute9;
    p6_a23 := ddx_poxv_rec.attribute10;
    p6_a24 := ddx_poxv_rec.attribute11;
    p6_a25 := ddx_poxv_rec.attribute12;
    p6_a26 := ddx_poxv_rec.attribute13;
    p6_a27 := ddx_poxv_rec.attribute14;
    p6_a28 := ddx_poxv_rec.attribute15;
    p6_a29 := rosetta_g_miss_num_map(ddx_poxv_rec.request_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_poxv_rec.program_application_id);
    p6_a31 := rosetta_g_miss_num_map(ddx_poxv_rec.program_id);
    p6_a32 := ddx_poxv_rec.program_update_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_poxv_rec.created_by);
    p6_a34 := ddx_poxv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_poxv_rec.last_updated_by);
    p6_a36 := ddx_poxv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_poxv_rec.last_update_login);
    p6_a38 := rosetta_g_miss_num_map(ddx_poxv_rec.legal_entity_id);
    p6_a39 := ddx_poxv_rec.transaction_status;
  end;

  procedure delete_pool_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
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
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_poxv_rec okl_pool_pvt.poxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_poxv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_poxv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_poxv_rec.pol_id := rosetta_g_miss_num_map(p5_a2);
    ddp_poxv_rec.transaction_number := rosetta_g_miss_num_map(p5_a3);
    ddp_poxv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_poxv_rec.transaction_type := p5_a5;
    ddp_poxv_rec.transaction_sub_type := p5_a6;
    ddp_poxv_rec.date_effective := rosetta_g_miss_date_in_map(p5_a7);
    ddp_poxv_rec.currency_code := p5_a8;
    ddp_poxv_rec.currency_conversion_type := p5_a9;
    ddp_poxv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_poxv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a11);
    ddp_poxv_rec.transaction_reason := p5_a12;
    ddp_poxv_rec.attribute_category := p5_a13;
    ddp_poxv_rec.attribute1 := p5_a14;
    ddp_poxv_rec.attribute2 := p5_a15;
    ddp_poxv_rec.attribute3 := p5_a16;
    ddp_poxv_rec.attribute4 := p5_a17;
    ddp_poxv_rec.attribute5 := p5_a18;
    ddp_poxv_rec.attribute6 := p5_a19;
    ddp_poxv_rec.attribute7 := p5_a20;
    ddp_poxv_rec.attribute8 := p5_a21;
    ddp_poxv_rec.attribute9 := p5_a22;
    ddp_poxv_rec.attribute10 := p5_a23;
    ddp_poxv_rec.attribute11 := p5_a24;
    ddp_poxv_rec.attribute12 := p5_a25;
    ddp_poxv_rec.attribute13 := p5_a26;
    ddp_poxv_rec.attribute14 := p5_a27;
    ddp_poxv_rec.attribute15 := p5_a28;
    ddp_poxv_rec.request_id := rosetta_g_miss_num_map(p5_a29);
    ddp_poxv_rec.program_application_id := rosetta_g_miss_num_map(p5_a30);
    ddp_poxv_rec.program_id := rosetta_g_miss_num_map(p5_a31);
    ddp_poxv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_poxv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_poxv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_poxv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_poxv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_poxv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_poxv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a38);
    ddp_poxv_rec.transaction_status := p5_a39;

    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.delete_pool_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_poxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure add_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_row_count out nocopy  NUMBER
    , p_currency_code  VARCHAR2
    , p_pol_id  NUMBER
    , p_multi_org  VARCHAR2
    , p_cust_object1_id1  NUMBER
    , p_sic_code  VARCHAR2
    , p_khr_id  NUMBER
    , p_pre_tax_yield_from  NUMBER
    , p_pre_tax_yield_to  NUMBER
    , p_book_classification  VARCHAR2
    , p_tax_owner  VARCHAR2
    , p_pdt_id  NUMBER
    , p_start_date_from  date
    , p_start_date_to  date
    , p_end_date_from  date
    , p_end_date_to  date
    , p_asset_id  NUMBER
    , p_item_id1  NUMBER
    , p_model_number  VARCHAR2
    , p_manufacturer_name  VARCHAR2
    , p_vendor_id1  NUMBER
    , p_oec_from  NUMBER
    , p_oec_to  NUMBER
    , p_residual_percentage  NUMBER
    , p_sty_id1  NUMBER
    , p_sty_id2  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_stream_element_from_date  date
    , p_stream_element_to_date  date
    , p_stream_element_payment_freq  VARCHAR2
    , p_log_message  VARCHAR2
  )

  as
    ddp_start_date_from date;
    ddp_start_date_to date;
    ddp_end_date_from date;
    ddp_end_date_to date;
    ddp_stream_element_from_date date;
    ddp_stream_element_to_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_start_date_from := rosetta_g_miss_date_in_map(p_start_date_from);

    ddp_start_date_to := rosetta_g_miss_date_in_map(p_start_date_to);

    ddp_end_date_from := rosetta_g_miss_date_in_map(p_end_date_from);

    ddp_end_date_to := rosetta_g_miss_date_in_map(p_end_date_to);












    ddp_stream_element_from_date := rosetta_g_miss_date_in_map(p_stream_element_from_date);

    ddp_stream_element_to_date := rosetta_g_miss_date_in_map(p_stream_element_to_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.add_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_row_count,
      p_currency_code,
      p_pol_id,
      p_multi_org,
      p_cust_object1_id1,
      p_sic_code,
      p_khr_id,
      p_pre_tax_yield_from,
      p_pre_tax_yield_to,
      p_book_classification,
      p_tax_owner,
      p_pdt_id,
      ddp_start_date_from,
      ddp_start_date_to,
      ddp_end_date_from,
      ddp_end_date_to,
      p_asset_id,
      p_item_id1,
      p_model_number,
      p_manufacturer_name,
      p_vendor_id1,
      p_oec_from,
      p_oec_to,
      p_residual_percentage,
      p_sty_id1,
      p_sty_id2,
      p_stream_type_subclass,
      ddp_stream_element_from_date,
      ddp_stream_element_to_date,
      p_stream_element_payment_freq,
      p_log_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



































  end;

  procedure cleanup_pool_contents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_pol_id  NUMBER
    , p_multi_org  VARCHAR2
    , p_cust_object1_id1  NUMBER
    , p_sic_code  VARCHAR2
    , p_dnz_chr_id  NUMBER
    , p_pre_tax_yield_from  NUMBER
    , p_pre_tax_yield_to  NUMBER
    , p_book_classification  VARCHAR2
    , p_tax_owner  VARCHAR2
    , p_pdt_id  NUMBER
    , p_start_from_date  date
    , p_start_to_date  date
    , p_end_from_date  date
    , p_end_to_date  date
    , p_asset_id  NUMBER
    , p_item_id1  NUMBER
    , p_model_number  VARCHAR2
    , p_manufacturer_name  VARCHAR2
    , p_vendor_id1  NUMBER
    , p_oec_from  NUMBER
    , p_oec_to  NUMBER
    , p_residual_percentage  NUMBER
    , p_sty_id  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_streams_from_date  date
    , p_streams_to_date  date
    , p_action_code  VARCHAR2
    , p33_a0 out nocopy JTF_NUMBER_TABLE
    , p33_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p33_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p33_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p33_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p33_a5 out nocopy JTF_NUMBER_TABLE
    , p33_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p33_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p33_a8 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_start_from_date date;
    ddp_start_to_date date;
    ddp_end_from_date date;
    ddp_end_to_date date;
    ddp_streams_from_date date;
    ddp_streams_to_date date;
    ddx_poc_uv_tbl okl_pool_pvt.poc_uv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_start_from_date := rosetta_g_miss_date_in_map(p_start_from_date);

    ddp_start_to_date := rosetta_g_miss_date_in_map(p_start_to_date);

    ddp_end_from_date := rosetta_g_miss_date_in_map(p_end_from_date);

    ddp_end_to_date := rosetta_g_miss_date_in_map(p_end_to_date);











    ddp_streams_from_date := rosetta_g_miss_date_in_map(p_streams_from_date);

    ddp_streams_to_date := rosetta_g_miss_date_in_map(p_streams_to_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.cleanup_pool_contents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_currency_code,
      p_pol_id,
      p_multi_org,
      p_cust_object1_id1,
      p_sic_code,
      p_dnz_chr_id,
      p_pre_tax_yield_from,
      p_pre_tax_yield_to,
      p_book_classification,
      p_tax_owner,
      p_pdt_id,
      ddp_start_from_date,
      ddp_start_to_date,
      ddp_end_from_date,
      ddp_end_to_date,
      p_asset_id,
      p_item_id1,
      p_model_number,
      p_manufacturer_name,
      p_vendor_id1,
      p_oec_from,
      p_oec_to,
      p_residual_percentage,
      p_sty_id,
      p_stream_type_subclass,
      ddp_streams_from_date,
      ddp_streams_to_date,
      p_action_code,
      ddx_poc_uv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

































    okl_pool_pvt_w.rosetta_table_copy_out_p48(ddx_poc_uv_tbl, p33_a0
      , p33_a1
      , p33_a2
      , p33_a3
      , p33_a4
      , p33_a5
      , p33_a6
      , p33_a7
      , p33_a8
      );
  end;

  procedure validate_pool(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_api_name  VARCHAR2
    , p_action  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  DATE := fnd_api.g_miss_date
    , p3_a13  DATE := fnd_api.g_miss_date
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
    , p3_a33  NUMBER := 0-1962.0724
    , p3_a34  NUMBER := 0-1962.0724
    , p3_a35  NUMBER := 0-1962.0724
    , p3_a36  NUMBER := 0-1962.0724
    , p3_a37  DATE := fnd_api.g_miss_date
    , p3_a38  NUMBER := 0-1962.0724
    , p3_a39  DATE := fnd_api.g_miss_date
    , p3_a40  NUMBER := 0-1962.0724
    , p3_a41  DATE := fnd_api.g_miss_date
    , p3_a42  NUMBER := 0-1962.0724
    , p3_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_polv_rec okl_pool_pvt.polv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_polv_rec.id := rosetta_g_miss_num_map(p3_a0);
    ddp_polv_rec.object_version_number := rosetta_g_miss_num_map(p3_a1);
    ddp_polv_rec.pot_id := rosetta_g_miss_num_map(p3_a2);
    ddp_polv_rec.khr_id := rosetta_g_miss_num_map(p3_a3);
    ddp_polv_rec.pool_number := p3_a4;
    ddp_polv_rec.description := p3_a5;
    ddp_polv_rec.short_description := p3_a6;
    ddp_polv_rec.currency_code := p3_a7;
    ddp_polv_rec.total_principal_amount := rosetta_g_miss_num_map(p3_a8);
    ddp_polv_rec.total_receivable_amount := rosetta_g_miss_num_map(p3_a9);
    ddp_polv_rec.securities_credit_rating := p3_a10;
    ddp_polv_rec.date_created := rosetta_g_miss_date_in_map(p3_a11);
    ddp_polv_rec.date_last_updated := rosetta_g_miss_date_in_map(p3_a12);
    ddp_polv_rec.date_last_reconciled := rosetta_g_miss_date_in_map(p3_a13);
    ddp_polv_rec.date_total_principal_calc := rosetta_g_miss_date_in_map(p3_a14);
    ddp_polv_rec.status_code := p3_a15;
    ddp_polv_rec.display_in_lease_center := p3_a16;
    ddp_polv_rec.attribute_category := p3_a17;
    ddp_polv_rec.attribute1 := p3_a18;
    ddp_polv_rec.attribute2 := p3_a19;
    ddp_polv_rec.attribute3 := p3_a20;
    ddp_polv_rec.attribute4 := p3_a21;
    ddp_polv_rec.attribute5 := p3_a22;
    ddp_polv_rec.attribute6 := p3_a23;
    ddp_polv_rec.attribute7 := p3_a24;
    ddp_polv_rec.attribute8 := p3_a25;
    ddp_polv_rec.attribute9 := p3_a26;
    ddp_polv_rec.attribute10 := p3_a27;
    ddp_polv_rec.attribute11 := p3_a28;
    ddp_polv_rec.attribute12 := p3_a29;
    ddp_polv_rec.attribute13 := p3_a30;
    ddp_polv_rec.attribute14 := p3_a31;
    ddp_polv_rec.attribute15 := p3_a32;
    ddp_polv_rec.org_id := rosetta_g_miss_num_map(p3_a33);
    ddp_polv_rec.request_id := rosetta_g_miss_num_map(p3_a34);
    ddp_polv_rec.program_application_id := rosetta_g_miss_num_map(p3_a35);
    ddp_polv_rec.program_id := rosetta_g_miss_num_map(p3_a36);
    ddp_polv_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a37);
    ddp_polv_rec.created_by := rosetta_g_miss_num_map(p3_a38);
    ddp_polv_rec.creation_date := rosetta_g_miss_date_in_map(p3_a39);
    ddp_polv_rec.last_updated_by := rosetta_g_miss_num_map(p3_a40);
    ddp_polv_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a41);
    ddp_polv_rec.last_update_login := rosetta_g_miss_num_map(p3_a42);
    ddp_polv_rec.legal_entity_id := rosetta_g_miss_num_map(p3_a43);





    -- here's the delegated call to the old PL/SQL routine
    okl_pool_pvt.validate_pool(p_api_version,
      p_init_msg_list,
      p_api_name,
      ddp_polv_rec,
      p_action,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_pool_pvt_w;

/
