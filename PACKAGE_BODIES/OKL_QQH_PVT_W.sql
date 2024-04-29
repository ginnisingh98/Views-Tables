--------------------------------------------------------
--  DDL for Package Body OKL_QQH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QQH_PVT_W" as
  /* $Header: OKLIQQHB.pls 120.1 2005/12/28 13:38:57 abhsaxen noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_qqh_pvt.qqhv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_2000
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).attribute_category := a2(indx);
          t(ddindx).attribute1 := a3(indx);
          t(ddindx).attribute2 := a4(indx);
          t(ddindx).attribute3 := a5(indx);
          t(ddindx).attribute4 := a6(indx);
          t(ddindx).attribute5 := a7(indx);
          t(ddindx).attribute6 := a8(indx);
          t(ddindx).attribute7 := a9(indx);
          t(ddindx).attribute8 := a10(indx);
          t(ddindx).attribute9 := a11(indx);
          t(ddindx).attribute10 := a12(indx);
          t(ddindx).attribute11 := a13(indx);
          t(ddindx).attribute12 := a14(indx);
          t(ddindx).attribute13 := a15(indx);
          t(ddindx).attribute14 := a16(indx);
          t(ddindx).attribute15 := a17(indx);
          t(ddindx).reference_number := a18(indx);
          t(ddindx).expected_start_date := a19(indx);
          t(ddindx).org_id := a20(indx);
          t(ddindx).inv_org_id := a21(indx);
          t(ddindx).currency_code := a22(indx);
          t(ddindx).term := a23(indx);
          t(ddindx).end_of_term_option_id := a24(indx);
          t(ddindx).pricing_method := a25(indx);
          t(ddindx).lease_opportunity_id := a26(indx);
          t(ddindx).originating_vendor_id := a27(indx);
          t(ddindx).program_agreement_id := a28(indx);
          t(ddindx).sales_rep_id := a29(indx);
          t(ddindx).sales_territory_id := a30(indx);
          t(ddindx).structured_pricing := a31(indx);
          t(ddindx).line_level_pricing := a32(indx);
          t(ddindx).rate_template_id := a33(indx);
          t(ddindx).rate_card_id := a34(indx);
          t(ddindx).lease_rate_factor := a35(indx);
          t(ddindx).target_rate_type := a36(indx);
          t(ddindx).target_rate := a37(indx);
          t(ddindx).target_amount := a38(indx);
          t(ddindx).target_frequency := a39(indx);
          t(ddindx).target_arrears := a40(indx);
          t(ddindx).target_periods := a41(indx);
          t(ddindx).iir := a42(indx);
          t(ddindx).sub_iir := a43(indx);
          t(ddindx).booking_yield := a44(indx);
          t(ddindx).sub_booking_yield := a45(indx);
          t(ddindx).pirr := a46(indx);
          t(ddindx).sub_pirr := a47(indx);
          t(ddindx).airr := a48(indx);
          t(ddindx).sub_airr := a49(indx);
          t(ddindx).short_description := a50(indx);
          t(ddindx).description := a51(indx);
          t(ddindx).comments := a52(indx);
          t(ddindx).sts_code := a53(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_qqh_pvt.qqhv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_2000();
    a52 := JTF_VARCHAR2_TABLE_2000();
    a53 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_2000();
      a52 := JTF_VARCHAR2_TABLE_2000();
      a53 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).attribute_category;
          a3(indx) := t(ddindx).attribute1;
          a4(indx) := t(ddindx).attribute2;
          a5(indx) := t(ddindx).attribute3;
          a6(indx) := t(ddindx).attribute4;
          a7(indx) := t(ddindx).attribute5;
          a8(indx) := t(ddindx).attribute6;
          a9(indx) := t(ddindx).attribute7;
          a10(indx) := t(ddindx).attribute8;
          a11(indx) := t(ddindx).attribute9;
          a12(indx) := t(ddindx).attribute10;
          a13(indx) := t(ddindx).attribute11;
          a14(indx) := t(ddindx).attribute12;
          a15(indx) := t(ddindx).attribute13;
          a16(indx) := t(ddindx).attribute14;
          a17(indx) := t(ddindx).attribute15;
          a18(indx) := t(ddindx).reference_number;
          a19(indx) := t(ddindx).expected_start_date;
          a20(indx) := t(ddindx).org_id;
          a21(indx) := t(ddindx).inv_org_id;
          a22(indx) := t(ddindx).currency_code;
          a23(indx) := t(ddindx).term;
          a24(indx) := t(ddindx).end_of_term_option_id;
          a25(indx) := t(ddindx).pricing_method;
          a26(indx) := t(ddindx).lease_opportunity_id;
          a27(indx) := t(ddindx).originating_vendor_id;
          a28(indx) := t(ddindx).program_agreement_id;
          a29(indx) := t(ddindx).sales_rep_id;
          a30(indx) := t(ddindx).sales_territory_id;
          a31(indx) := t(ddindx).structured_pricing;
          a32(indx) := t(ddindx).line_level_pricing;
          a33(indx) := t(ddindx).rate_template_id;
          a34(indx) := t(ddindx).rate_card_id;
          a35(indx) := t(ddindx).lease_rate_factor;
          a36(indx) := t(ddindx).target_rate_type;
          a37(indx) := t(ddindx).target_rate;
          a38(indx) := t(ddindx).target_amount;
          a39(indx) := t(ddindx).target_frequency;
          a40(indx) := t(ddindx).target_arrears;
          a41(indx) := t(ddindx).target_periods;
          a42(indx) := t(ddindx).iir;
          a43(indx) := t(ddindx).sub_iir;
          a44(indx) := t(ddindx).booking_yield;
          a45(indx) := t(ddindx).sub_booking_yield;
          a46(indx) := t(ddindx).pirr;
          a47(indx) := t(ddindx).sub_pirr;
          a48(indx) := t(ddindx).airr;
          a49(indx) := t(ddindx).sub_airr;
          a50(indx) := t(ddindx).short_description;
          a51(indx) := t(ddindx).description;
          a52(indx) := t(ddindx).comments;
          a53(indx) := t(ddindx).sts_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_300
    , p5_a51 JTF_VARCHAR2_TABLE_2000
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qqhv_tbl okl_qqh_pvt.qqhv_tbl_type;
    ddx_qqhv_tbl okl_qqh_pvt.qqhv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qqh_pvt_w.rosetta_table_copy_in_p23(ddp_qqhv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qqh_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_tbl,
      ddx_qqhv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qqh_pvt_w.rosetta_table_copy_out_p23(ddx_qqhv_tbl, p6_a0
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
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_300
    , p5_a51 JTF_VARCHAR2_TABLE_2000
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qqhv_tbl okl_qqh_pvt.qqhv_tbl_type;
    ddx_qqhv_tbl okl_qqh_pvt.qqhv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qqh_pvt_w.rosetta_table_copy_in_p23(ddp_qqhv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qqh_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_tbl,
      ddx_qqhv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qqh_pvt_w.rosetta_table_copy_out_p23(ddx_qqhv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_300
    , p5_a51 JTF_VARCHAR2_TABLE_2000
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qqhv_tbl okl_qqh_pvt.qqhv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qqh_pvt_w.rosetta_table_copy_in_p23(ddp_qqhv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qqh_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
  )

  as
    ddp_qqhv_rec okl_qqh_pvt.qqhv_rec_type;
    ddx_qqhv_rec okl_qqh_pvt.qqhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec.id := p5_a0;
    ddp_qqhv_rec.object_version_number := p5_a1;
    ddp_qqhv_rec.attribute_category := p5_a2;
    ddp_qqhv_rec.attribute1 := p5_a3;
    ddp_qqhv_rec.attribute2 := p5_a4;
    ddp_qqhv_rec.attribute3 := p5_a5;
    ddp_qqhv_rec.attribute4 := p5_a6;
    ddp_qqhv_rec.attribute5 := p5_a7;
    ddp_qqhv_rec.attribute6 := p5_a8;
    ddp_qqhv_rec.attribute7 := p5_a9;
    ddp_qqhv_rec.attribute8 := p5_a10;
    ddp_qqhv_rec.attribute9 := p5_a11;
    ddp_qqhv_rec.attribute10 := p5_a12;
    ddp_qqhv_rec.attribute11 := p5_a13;
    ddp_qqhv_rec.attribute12 := p5_a14;
    ddp_qqhv_rec.attribute13 := p5_a15;
    ddp_qqhv_rec.attribute14 := p5_a16;
    ddp_qqhv_rec.attribute15 := p5_a17;
    ddp_qqhv_rec.reference_number := p5_a18;
    ddp_qqhv_rec.expected_start_date := p5_a19;
    ddp_qqhv_rec.org_id := p5_a20;
    ddp_qqhv_rec.inv_org_id := p5_a21;
    ddp_qqhv_rec.currency_code := p5_a22;
    ddp_qqhv_rec.term := p5_a23;
    ddp_qqhv_rec.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec.pricing_method := p5_a25;
    ddp_qqhv_rec.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec.originating_vendor_id := p5_a27;
    ddp_qqhv_rec.program_agreement_id := p5_a28;
    ddp_qqhv_rec.sales_rep_id := p5_a29;
    ddp_qqhv_rec.sales_territory_id := p5_a30;
    ddp_qqhv_rec.structured_pricing := p5_a31;
    ddp_qqhv_rec.line_level_pricing := p5_a32;
    ddp_qqhv_rec.rate_template_id := p5_a33;
    ddp_qqhv_rec.rate_card_id := p5_a34;
    ddp_qqhv_rec.lease_rate_factor := p5_a35;
    ddp_qqhv_rec.target_rate_type := p5_a36;
    ddp_qqhv_rec.target_rate := p5_a37;
    ddp_qqhv_rec.target_amount := p5_a38;
    ddp_qqhv_rec.target_frequency := p5_a39;
    ddp_qqhv_rec.target_arrears := p5_a40;
    ddp_qqhv_rec.target_periods := p5_a41;
    ddp_qqhv_rec.iir := p5_a42;
    ddp_qqhv_rec.sub_iir := p5_a43;
    ddp_qqhv_rec.booking_yield := p5_a44;
    ddp_qqhv_rec.sub_booking_yield := p5_a45;
    ddp_qqhv_rec.pirr := p5_a46;
    ddp_qqhv_rec.sub_pirr := p5_a47;
    ddp_qqhv_rec.airr := p5_a48;
    ddp_qqhv_rec.sub_airr := p5_a49;
    ddp_qqhv_rec.short_description := p5_a50;
    ddp_qqhv_rec.description := p5_a51;
    ddp_qqhv_rec.comments := p5_a52;
    ddp_qqhv_rec.sts_code := p5_a53;


    -- here's the delegated call to the old PL/SQL routine
    okl_qqh_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec,
      ddx_qqhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqhv_rec.id;
    p6_a1 := ddx_qqhv_rec.object_version_number;
    p6_a2 := ddx_qqhv_rec.attribute_category;
    p6_a3 := ddx_qqhv_rec.attribute1;
    p6_a4 := ddx_qqhv_rec.attribute2;
    p6_a5 := ddx_qqhv_rec.attribute3;
    p6_a6 := ddx_qqhv_rec.attribute4;
    p6_a7 := ddx_qqhv_rec.attribute5;
    p6_a8 := ddx_qqhv_rec.attribute6;
    p6_a9 := ddx_qqhv_rec.attribute7;
    p6_a10 := ddx_qqhv_rec.attribute8;
    p6_a11 := ddx_qqhv_rec.attribute9;
    p6_a12 := ddx_qqhv_rec.attribute10;
    p6_a13 := ddx_qqhv_rec.attribute11;
    p6_a14 := ddx_qqhv_rec.attribute12;
    p6_a15 := ddx_qqhv_rec.attribute13;
    p6_a16 := ddx_qqhv_rec.attribute14;
    p6_a17 := ddx_qqhv_rec.attribute15;
    p6_a18 := ddx_qqhv_rec.reference_number;
    p6_a19 := ddx_qqhv_rec.expected_start_date;
    p6_a20 := ddx_qqhv_rec.org_id;
    p6_a21 := ddx_qqhv_rec.inv_org_id;
    p6_a22 := ddx_qqhv_rec.currency_code;
    p6_a23 := ddx_qqhv_rec.term;
    p6_a24 := ddx_qqhv_rec.end_of_term_option_id;
    p6_a25 := ddx_qqhv_rec.pricing_method;
    p6_a26 := ddx_qqhv_rec.lease_opportunity_id;
    p6_a27 := ddx_qqhv_rec.originating_vendor_id;
    p6_a28 := ddx_qqhv_rec.program_agreement_id;
    p6_a29 := ddx_qqhv_rec.sales_rep_id;
    p6_a30 := ddx_qqhv_rec.sales_territory_id;
    p6_a31 := ddx_qqhv_rec.structured_pricing;
    p6_a32 := ddx_qqhv_rec.line_level_pricing;
    p6_a33 := ddx_qqhv_rec.rate_template_id;
    p6_a34 := ddx_qqhv_rec.rate_card_id;
    p6_a35 := ddx_qqhv_rec.lease_rate_factor;
    p6_a36 := ddx_qqhv_rec.target_rate_type;
    p6_a37 := ddx_qqhv_rec.target_rate;
    p6_a38 := ddx_qqhv_rec.target_amount;
    p6_a39 := ddx_qqhv_rec.target_frequency;
    p6_a40 := ddx_qqhv_rec.target_arrears;
    p6_a41 := ddx_qqhv_rec.target_periods;
    p6_a42 := ddx_qqhv_rec.iir;
    p6_a43 := ddx_qqhv_rec.sub_iir;
    p6_a44 := ddx_qqhv_rec.booking_yield;
    p6_a45 := ddx_qqhv_rec.sub_booking_yield;
    p6_a46 := ddx_qqhv_rec.pirr;
    p6_a47 := ddx_qqhv_rec.sub_pirr;
    p6_a48 := ddx_qqhv_rec.airr;
    p6_a49 := ddx_qqhv_rec.sub_airr;
    p6_a50 := ddx_qqhv_rec.short_description;
    p6_a51 := ddx_qqhv_rec.description;
    p6_a52 := ddx_qqhv_rec.comments;
    p6_a53 := ddx_qqhv_rec.sts_code;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
  )

  as
    ddp_qqhv_rec okl_qqh_pvt.qqhv_rec_type;
    ddx_qqhv_rec okl_qqh_pvt.qqhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec.id := p5_a0;
    ddp_qqhv_rec.object_version_number := p5_a1;
    ddp_qqhv_rec.attribute_category := p5_a2;
    ddp_qqhv_rec.attribute1 := p5_a3;
    ddp_qqhv_rec.attribute2 := p5_a4;
    ddp_qqhv_rec.attribute3 := p5_a5;
    ddp_qqhv_rec.attribute4 := p5_a6;
    ddp_qqhv_rec.attribute5 := p5_a7;
    ddp_qqhv_rec.attribute6 := p5_a8;
    ddp_qqhv_rec.attribute7 := p5_a9;
    ddp_qqhv_rec.attribute8 := p5_a10;
    ddp_qqhv_rec.attribute9 := p5_a11;
    ddp_qqhv_rec.attribute10 := p5_a12;
    ddp_qqhv_rec.attribute11 := p5_a13;
    ddp_qqhv_rec.attribute12 := p5_a14;
    ddp_qqhv_rec.attribute13 := p5_a15;
    ddp_qqhv_rec.attribute14 := p5_a16;
    ddp_qqhv_rec.attribute15 := p5_a17;
    ddp_qqhv_rec.reference_number := p5_a18;
    ddp_qqhv_rec.expected_start_date := p5_a19;
    ddp_qqhv_rec.org_id := p5_a20;
    ddp_qqhv_rec.inv_org_id := p5_a21;
    ddp_qqhv_rec.currency_code := p5_a22;
    ddp_qqhv_rec.term := p5_a23;
    ddp_qqhv_rec.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec.pricing_method := p5_a25;
    ddp_qqhv_rec.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec.originating_vendor_id := p5_a27;
    ddp_qqhv_rec.program_agreement_id := p5_a28;
    ddp_qqhv_rec.sales_rep_id := p5_a29;
    ddp_qqhv_rec.sales_territory_id := p5_a30;
    ddp_qqhv_rec.structured_pricing := p5_a31;
    ddp_qqhv_rec.line_level_pricing := p5_a32;
    ddp_qqhv_rec.rate_template_id := p5_a33;
    ddp_qqhv_rec.rate_card_id := p5_a34;
    ddp_qqhv_rec.lease_rate_factor := p5_a35;
    ddp_qqhv_rec.target_rate_type := p5_a36;
    ddp_qqhv_rec.target_rate := p5_a37;
    ddp_qqhv_rec.target_amount := p5_a38;
    ddp_qqhv_rec.target_frequency := p5_a39;
    ddp_qqhv_rec.target_arrears := p5_a40;
    ddp_qqhv_rec.target_periods := p5_a41;
    ddp_qqhv_rec.iir := p5_a42;
    ddp_qqhv_rec.sub_iir := p5_a43;
    ddp_qqhv_rec.booking_yield := p5_a44;
    ddp_qqhv_rec.sub_booking_yield := p5_a45;
    ddp_qqhv_rec.pirr := p5_a46;
    ddp_qqhv_rec.sub_pirr := p5_a47;
    ddp_qqhv_rec.airr := p5_a48;
    ddp_qqhv_rec.sub_airr := p5_a49;
    ddp_qqhv_rec.short_description := p5_a50;
    ddp_qqhv_rec.description := p5_a51;
    ddp_qqhv_rec.comments := p5_a52;
    ddp_qqhv_rec.sts_code := p5_a53;


    -- here's the delegated call to the old PL/SQL routine
    okl_qqh_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec,
      ddx_qqhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqhv_rec.id;
    p6_a1 := ddx_qqhv_rec.object_version_number;
    p6_a2 := ddx_qqhv_rec.attribute_category;
    p6_a3 := ddx_qqhv_rec.attribute1;
    p6_a4 := ddx_qqhv_rec.attribute2;
    p6_a5 := ddx_qqhv_rec.attribute3;
    p6_a6 := ddx_qqhv_rec.attribute4;
    p6_a7 := ddx_qqhv_rec.attribute5;
    p6_a8 := ddx_qqhv_rec.attribute6;
    p6_a9 := ddx_qqhv_rec.attribute7;
    p6_a10 := ddx_qqhv_rec.attribute8;
    p6_a11 := ddx_qqhv_rec.attribute9;
    p6_a12 := ddx_qqhv_rec.attribute10;
    p6_a13 := ddx_qqhv_rec.attribute11;
    p6_a14 := ddx_qqhv_rec.attribute12;
    p6_a15 := ddx_qqhv_rec.attribute13;
    p6_a16 := ddx_qqhv_rec.attribute14;
    p6_a17 := ddx_qqhv_rec.attribute15;
    p6_a18 := ddx_qqhv_rec.reference_number;
    p6_a19 := ddx_qqhv_rec.expected_start_date;
    p6_a20 := ddx_qqhv_rec.org_id;
    p6_a21 := ddx_qqhv_rec.inv_org_id;
    p6_a22 := ddx_qqhv_rec.currency_code;
    p6_a23 := ddx_qqhv_rec.term;
    p6_a24 := ddx_qqhv_rec.end_of_term_option_id;
    p6_a25 := ddx_qqhv_rec.pricing_method;
    p6_a26 := ddx_qqhv_rec.lease_opportunity_id;
    p6_a27 := ddx_qqhv_rec.originating_vendor_id;
    p6_a28 := ddx_qqhv_rec.program_agreement_id;
    p6_a29 := ddx_qqhv_rec.sales_rep_id;
    p6_a30 := ddx_qqhv_rec.sales_territory_id;
    p6_a31 := ddx_qqhv_rec.structured_pricing;
    p6_a32 := ddx_qqhv_rec.line_level_pricing;
    p6_a33 := ddx_qqhv_rec.rate_template_id;
    p6_a34 := ddx_qqhv_rec.rate_card_id;
    p6_a35 := ddx_qqhv_rec.lease_rate_factor;
    p6_a36 := ddx_qqhv_rec.target_rate_type;
    p6_a37 := ddx_qqhv_rec.target_rate;
    p6_a38 := ddx_qqhv_rec.target_amount;
    p6_a39 := ddx_qqhv_rec.target_frequency;
    p6_a40 := ddx_qqhv_rec.target_arrears;
    p6_a41 := ddx_qqhv_rec.target_periods;
    p6_a42 := ddx_qqhv_rec.iir;
    p6_a43 := ddx_qqhv_rec.sub_iir;
    p6_a44 := ddx_qqhv_rec.booking_yield;
    p6_a45 := ddx_qqhv_rec.sub_booking_yield;
    p6_a46 := ddx_qqhv_rec.pirr;
    p6_a47 := ddx_qqhv_rec.sub_pirr;
    p6_a48 := ddx_qqhv_rec.airr;
    p6_a49 := ddx_qqhv_rec.sub_airr;
    p6_a50 := ddx_qqhv_rec.short_description;
    p6_a51 := ddx_qqhv_rec.description;
    p6_a52 := ddx_qqhv_rec.comments;
    p6_a53 := ddx_qqhv_rec.sts_code;
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
  )

  as
    ddp_qqhv_rec okl_qqh_pvt.qqhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec.id := p5_a0;
    ddp_qqhv_rec.object_version_number := p5_a1;
    ddp_qqhv_rec.attribute_category := p5_a2;
    ddp_qqhv_rec.attribute1 := p5_a3;
    ddp_qqhv_rec.attribute2 := p5_a4;
    ddp_qqhv_rec.attribute3 := p5_a5;
    ddp_qqhv_rec.attribute4 := p5_a6;
    ddp_qqhv_rec.attribute5 := p5_a7;
    ddp_qqhv_rec.attribute6 := p5_a8;
    ddp_qqhv_rec.attribute7 := p5_a9;
    ddp_qqhv_rec.attribute8 := p5_a10;
    ddp_qqhv_rec.attribute9 := p5_a11;
    ddp_qqhv_rec.attribute10 := p5_a12;
    ddp_qqhv_rec.attribute11 := p5_a13;
    ddp_qqhv_rec.attribute12 := p5_a14;
    ddp_qqhv_rec.attribute13 := p5_a15;
    ddp_qqhv_rec.attribute14 := p5_a16;
    ddp_qqhv_rec.attribute15 := p5_a17;
    ddp_qqhv_rec.reference_number := p5_a18;
    ddp_qqhv_rec.expected_start_date := p5_a19;
    ddp_qqhv_rec.org_id := p5_a20;
    ddp_qqhv_rec.inv_org_id := p5_a21;
    ddp_qqhv_rec.currency_code := p5_a22;
    ddp_qqhv_rec.term := p5_a23;
    ddp_qqhv_rec.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec.pricing_method := p5_a25;
    ddp_qqhv_rec.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec.originating_vendor_id := p5_a27;
    ddp_qqhv_rec.program_agreement_id := p5_a28;
    ddp_qqhv_rec.sales_rep_id := p5_a29;
    ddp_qqhv_rec.sales_territory_id := p5_a30;
    ddp_qqhv_rec.structured_pricing := p5_a31;
    ddp_qqhv_rec.line_level_pricing := p5_a32;
    ddp_qqhv_rec.rate_template_id := p5_a33;
    ddp_qqhv_rec.rate_card_id := p5_a34;
    ddp_qqhv_rec.lease_rate_factor := p5_a35;
    ddp_qqhv_rec.target_rate_type := p5_a36;
    ddp_qqhv_rec.target_rate := p5_a37;
    ddp_qqhv_rec.target_amount := p5_a38;
    ddp_qqhv_rec.target_frequency := p5_a39;
    ddp_qqhv_rec.target_arrears := p5_a40;
    ddp_qqhv_rec.target_periods := p5_a41;
    ddp_qqhv_rec.iir := p5_a42;
    ddp_qqhv_rec.sub_iir := p5_a43;
    ddp_qqhv_rec.booking_yield := p5_a44;
    ddp_qqhv_rec.sub_booking_yield := p5_a45;
    ddp_qqhv_rec.pirr := p5_a46;
    ddp_qqhv_rec.sub_pirr := p5_a47;
    ddp_qqhv_rec.airr := p5_a48;
    ddp_qqhv_rec.sub_airr := p5_a49;
    ddp_qqhv_rec.short_description := p5_a50;
    ddp_qqhv_rec.description := p5_a51;
    ddp_qqhv_rec.comments := p5_a52;
    ddp_qqhv_rec.sts_code := p5_a53;

    -- here's the delegated call to the old PL/SQL routine
    okl_qqh_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_qqh_pvt_w;

/
