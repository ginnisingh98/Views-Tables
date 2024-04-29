--------------------------------------------------------
--  DDL for Package Body OKL_LSQ_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LSQ_PVT_W" as
  /* $Header: OKLILSQB.pls 120.2 2007/03/20 23:14:39 rravikir noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_lsq_pvt.lsqv_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_2000
    , a71 JTF_VARCHAR2_TABLE_2000
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
          t(ddindx).status := a19(indx);
          t(ddindx).parent_object_code := a20(indx);
          t(ddindx).parent_object_id := a21(indx);
          t(ddindx).valid_from := a22(indx);
          t(ddindx).valid_to := a23(indx);
          t(ddindx).customer_bookclass := a24(indx);
          t(ddindx).customer_taxowner := a25(indx);
          t(ddindx).expected_start_date := a26(indx);
          t(ddindx).expected_funding_date := a27(indx);
          t(ddindx).expected_delivery_date := a28(indx);
          t(ddindx).pricing_method := a29(indx);
          t(ddindx).term := a30(indx);
          t(ddindx).product_id := a31(indx);
          t(ddindx).end_of_term_option_id := a32(indx);
          t(ddindx).structured_pricing := a33(indx);
          t(ddindx).line_level_pricing := a34(indx);
          t(ddindx).rate_template_id := a35(indx);
          t(ddindx).rate_card_id := a36(indx);
          t(ddindx).lease_rate_factor := a37(indx);
          t(ddindx).target_rate_type := a38(indx);
          t(ddindx).target_rate := a39(indx);
          t(ddindx).target_amount := a40(indx);
          t(ddindx).target_frequency := a41(indx);
          t(ddindx).target_arrears_yn := a42(indx);
          t(ddindx).target_periods := a43(indx);
          t(ddindx).iir := a44(indx);
          t(ddindx).booking_yield := a45(indx);
          t(ddindx).pirr := a46(indx);
          t(ddindx).airr := a47(indx);
          t(ddindx).sub_iir := a48(indx);
          t(ddindx).sub_booking_yield := a49(indx);
          t(ddindx).sub_pirr := a50(indx);
          t(ddindx).sub_airr := a51(indx);
          t(ddindx).usage_category := a52(indx);
          t(ddindx).usage_industry_class := a53(indx);
          t(ddindx).usage_industry_code := a54(indx);
          t(ddindx).usage_amount := a55(indx);
          t(ddindx).usage_location_id := a56(indx);
          t(ddindx).property_tax_applicable := a57(indx);
          t(ddindx).property_tax_billing_type := a58(indx);
          t(ddindx).upfront_tax_treatment := a59(indx);
          t(ddindx).upfront_tax_stream_type := a60(indx);
          t(ddindx).transfer_of_title := a61(indx);
          t(ddindx).age_of_equipment := a62(indx);
          t(ddindx).purchase_of_lease := a63(indx);
          t(ddindx).sale_and_lease_back := a64(indx);
          t(ddindx).interest_disclosed := a65(indx);
          t(ddindx).primary_quote := a66(indx);
          t(ddindx).legal_entity_id := a67(indx);
          t(ddindx).line_intended_use := a68(indx);
          t(ddindx).short_description := a69(indx);
          t(ddindx).description := a70(indx);
          t(ddindx).comments := a71(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_lsq_pvt.lsqv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , a71 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_2000();
    a71 := JTF_VARCHAR2_TABLE_2000();
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
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_2000();
      a71 := JTF_VARCHAR2_TABLE_2000();
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
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
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
          a19(indx) := t(ddindx).status;
          a20(indx) := t(ddindx).parent_object_code;
          a21(indx) := t(ddindx).parent_object_id;
          a22(indx) := t(ddindx).valid_from;
          a23(indx) := t(ddindx).valid_to;
          a24(indx) := t(ddindx).customer_bookclass;
          a25(indx) := t(ddindx).customer_taxowner;
          a26(indx) := t(ddindx).expected_start_date;
          a27(indx) := t(ddindx).expected_funding_date;
          a28(indx) := t(ddindx).expected_delivery_date;
          a29(indx) := t(ddindx).pricing_method;
          a30(indx) := t(ddindx).term;
          a31(indx) := t(ddindx).product_id;
          a32(indx) := t(ddindx).end_of_term_option_id;
          a33(indx) := t(ddindx).structured_pricing;
          a34(indx) := t(ddindx).line_level_pricing;
          a35(indx) := t(ddindx).rate_template_id;
          a36(indx) := t(ddindx).rate_card_id;
          a37(indx) := t(ddindx).lease_rate_factor;
          a38(indx) := t(ddindx).target_rate_type;
          a39(indx) := t(ddindx).target_rate;
          a40(indx) := t(ddindx).target_amount;
          a41(indx) := t(ddindx).target_frequency;
          a42(indx) := t(ddindx).target_arrears_yn;
          a43(indx) := t(ddindx).target_periods;
          a44(indx) := t(ddindx).iir;
          a45(indx) := t(ddindx).booking_yield;
          a46(indx) := t(ddindx).pirr;
          a47(indx) := t(ddindx).airr;
          a48(indx) := t(ddindx).sub_iir;
          a49(indx) := t(ddindx).sub_booking_yield;
          a50(indx) := t(ddindx).sub_pirr;
          a51(indx) := t(ddindx).sub_airr;
          a52(indx) := t(ddindx).usage_category;
          a53(indx) := t(ddindx).usage_industry_class;
          a54(indx) := t(ddindx).usage_industry_code;
          a55(indx) := t(ddindx).usage_amount;
          a56(indx) := t(ddindx).usage_location_id;
          a57(indx) := t(ddindx).property_tax_applicable;
          a58(indx) := t(ddindx).property_tax_billing_type;
          a59(indx) := t(ddindx).upfront_tax_treatment;
          a60(indx) := t(ddindx).upfront_tax_stream_type;
          a61(indx) := t(ddindx).transfer_of_title;
          a62(indx) := t(ddindx).age_of_equipment;
          a63(indx) := t(ddindx).purchase_of_lease;
          a64(indx) := t(ddindx).sale_and_lease_back;
          a65(indx) := t(ddindx).interest_disclosed;
          a66(indx) := t(ddindx).primary_quote;
          a67(indx) := t(ddindx).legal_entity_id;
          a68(indx) := t(ddindx).line_intended_use;
          a69(indx) := t(ddindx).short_description;
          a70(indx) := t(ddindx).description;
          a71(indx) := t(ddindx).comments;
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
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_VARCHAR2_TABLE_300
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_2000
    , p5_a71 JTF_VARCHAR2_TABLE_2000
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
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_lsqv_tbl okl_lsq_pvt.lsqv_tbl_type;
    ddx_lsqv_tbl okl_lsq_pvt.lsqv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lsq_pvt_w.rosetta_table_copy_in_p23(ddp_lsqv_tbl, p5_a0
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
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lsq_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsqv_tbl,
      ddx_lsqv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lsq_pvt_w.rosetta_table_copy_out_p23(ddx_lsqv_tbl, p6_a0
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
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
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
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_VARCHAR2_TABLE_300
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_2000
    , p5_a71 JTF_VARCHAR2_TABLE_2000
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
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_lsqv_tbl okl_lsq_pvt.lsqv_tbl_type;
    ddx_lsqv_tbl okl_lsq_pvt.lsqv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lsq_pvt_w.rosetta_table_copy_in_p23(ddp_lsqv_tbl, p5_a0
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
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lsq_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsqv_tbl,
      ddx_lsqv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lsq_pvt_w.rosetta_table_copy_out_p23(ddx_lsqv_tbl, p6_a0
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
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
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
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_VARCHAR2_TABLE_300
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_2000
    , p5_a71 JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_lsqv_tbl okl_lsq_pvt.lsqv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lsq_pvt_w.rosetta_table_copy_in_p23(ddp_lsqv_tbl, p5_a0
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
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_lsq_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsqv_tbl);

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
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  DATE
    , p5_a23  DATE
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  DATE
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  VARCHAR2
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  NUMBER
    , p5_a51  NUMBER
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  NUMBER
    , p5_a57  VARCHAR2
    , p5_a58  VARCHAR2
    , p5_a59  VARCHAR2
    , p5_a60  NUMBER
    , p5_a61  VARCHAR2
    , p5_a62  NUMBER
    , p5_a63  VARCHAR2
    , p5_a64  VARCHAR2
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  VARCHAR2
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  VARCHAR2
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
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
  )

  as
    ddp_lsqv_rec okl_lsq_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lsq_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lsqv_rec.id := p5_a0;
    ddp_lsqv_rec.object_version_number := p5_a1;
    ddp_lsqv_rec.attribute_category := p5_a2;
    ddp_lsqv_rec.attribute1 := p5_a3;
    ddp_lsqv_rec.attribute2 := p5_a4;
    ddp_lsqv_rec.attribute3 := p5_a5;
    ddp_lsqv_rec.attribute4 := p5_a6;
    ddp_lsqv_rec.attribute5 := p5_a7;
    ddp_lsqv_rec.attribute6 := p5_a8;
    ddp_lsqv_rec.attribute7 := p5_a9;
    ddp_lsqv_rec.attribute8 := p5_a10;
    ddp_lsqv_rec.attribute9 := p5_a11;
    ddp_lsqv_rec.attribute10 := p5_a12;
    ddp_lsqv_rec.attribute11 := p5_a13;
    ddp_lsqv_rec.attribute12 := p5_a14;
    ddp_lsqv_rec.attribute13 := p5_a15;
    ddp_lsqv_rec.attribute14 := p5_a16;
    ddp_lsqv_rec.attribute15 := p5_a17;
    ddp_lsqv_rec.reference_number := p5_a18;
    ddp_lsqv_rec.status := p5_a19;
    ddp_lsqv_rec.parent_object_code := p5_a20;
    ddp_lsqv_rec.parent_object_id := p5_a21;
    ddp_lsqv_rec.valid_from := p5_a22;
    ddp_lsqv_rec.valid_to := p5_a23;
    ddp_lsqv_rec.customer_bookclass := p5_a24;
    ddp_lsqv_rec.customer_taxowner := p5_a25;
    ddp_lsqv_rec.expected_start_date := p5_a26;
    ddp_lsqv_rec.expected_funding_date := p5_a27;
    ddp_lsqv_rec.expected_delivery_date := p5_a28;
    ddp_lsqv_rec.pricing_method := p5_a29;
    ddp_lsqv_rec.term := p5_a30;
    ddp_lsqv_rec.product_id := p5_a31;
    ddp_lsqv_rec.end_of_term_option_id := p5_a32;
    ddp_lsqv_rec.structured_pricing := p5_a33;
    ddp_lsqv_rec.line_level_pricing := p5_a34;
    ddp_lsqv_rec.rate_template_id := p5_a35;
    ddp_lsqv_rec.rate_card_id := p5_a36;
    ddp_lsqv_rec.lease_rate_factor := p5_a37;
    ddp_lsqv_rec.target_rate_type := p5_a38;
    ddp_lsqv_rec.target_rate := p5_a39;
    ddp_lsqv_rec.target_amount := p5_a40;
    ddp_lsqv_rec.target_frequency := p5_a41;
    ddp_lsqv_rec.target_arrears_yn := p5_a42;
    ddp_lsqv_rec.target_periods := p5_a43;
    ddp_lsqv_rec.iir := p5_a44;
    ddp_lsqv_rec.booking_yield := p5_a45;
    ddp_lsqv_rec.pirr := p5_a46;
    ddp_lsqv_rec.airr := p5_a47;
    ddp_lsqv_rec.sub_iir := p5_a48;
    ddp_lsqv_rec.sub_booking_yield := p5_a49;
    ddp_lsqv_rec.sub_pirr := p5_a50;
    ddp_lsqv_rec.sub_airr := p5_a51;
    ddp_lsqv_rec.usage_category := p5_a52;
    ddp_lsqv_rec.usage_industry_class := p5_a53;
    ddp_lsqv_rec.usage_industry_code := p5_a54;
    ddp_lsqv_rec.usage_amount := p5_a55;
    ddp_lsqv_rec.usage_location_id := p5_a56;
    ddp_lsqv_rec.property_tax_applicable := p5_a57;
    ddp_lsqv_rec.property_tax_billing_type := p5_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p5_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p5_a60;
    ddp_lsqv_rec.transfer_of_title := p5_a61;
    ddp_lsqv_rec.age_of_equipment := p5_a62;
    ddp_lsqv_rec.purchase_of_lease := p5_a63;
    ddp_lsqv_rec.sale_and_lease_back := p5_a64;
    ddp_lsqv_rec.interest_disclosed := p5_a65;
    ddp_lsqv_rec.primary_quote := p5_a66;
    ddp_lsqv_rec.legal_entity_id := p5_a67;
    ddp_lsqv_rec.line_intended_use := p5_a68;
    ddp_lsqv_rec.short_description := p5_a69;
    ddp_lsqv_rec.description := p5_a70;
    ddp_lsqv_rec.comments := p5_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lsq_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsqv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lsqv_rec.id;
    p6_a1 := ddx_lsqv_rec.object_version_number;
    p6_a2 := ddx_lsqv_rec.attribute_category;
    p6_a3 := ddx_lsqv_rec.attribute1;
    p6_a4 := ddx_lsqv_rec.attribute2;
    p6_a5 := ddx_lsqv_rec.attribute3;
    p6_a6 := ddx_lsqv_rec.attribute4;
    p6_a7 := ddx_lsqv_rec.attribute5;
    p6_a8 := ddx_lsqv_rec.attribute6;
    p6_a9 := ddx_lsqv_rec.attribute7;
    p6_a10 := ddx_lsqv_rec.attribute8;
    p6_a11 := ddx_lsqv_rec.attribute9;
    p6_a12 := ddx_lsqv_rec.attribute10;
    p6_a13 := ddx_lsqv_rec.attribute11;
    p6_a14 := ddx_lsqv_rec.attribute12;
    p6_a15 := ddx_lsqv_rec.attribute13;
    p6_a16 := ddx_lsqv_rec.attribute14;
    p6_a17 := ddx_lsqv_rec.attribute15;
    p6_a18 := ddx_lsqv_rec.reference_number;
    p6_a19 := ddx_lsqv_rec.status;
    p6_a20 := ddx_lsqv_rec.parent_object_code;
    p6_a21 := ddx_lsqv_rec.parent_object_id;
    p6_a22 := ddx_lsqv_rec.valid_from;
    p6_a23 := ddx_lsqv_rec.valid_to;
    p6_a24 := ddx_lsqv_rec.customer_bookclass;
    p6_a25 := ddx_lsqv_rec.customer_taxowner;
    p6_a26 := ddx_lsqv_rec.expected_start_date;
    p6_a27 := ddx_lsqv_rec.expected_funding_date;
    p6_a28 := ddx_lsqv_rec.expected_delivery_date;
    p6_a29 := ddx_lsqv_rec.pricing_method;
    p6_a30 := ddx_lsqv_rec.term;
    p6_a31 := ddx_lsqv_rec.product_id;
    p6_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p6_a33 := ddx_lsqv_rec.structured_pricing;
    p6_a34 := ddx_lsqv_rec.line_level_pricing;
    p6_a35 := ddx_lsqv_rec.rate_template_id;
    p6_a36 := ddx_lsqv_rec.rate_card_id;
    p6_a37 := ddx_lsqv_rec.lease_rate_factor;
    p6_a38 := ddx_lsqv_rec.target_rate_type;
    p6_a39 := ddx_lsqv_rec.target_rate;
    p6_a40 := ddx_lsqv_rec.target_amount;
    p6_a41 := ddx_lsqv_rec.target_frequency;
    p6_a42 := ddx_lsqv_rec.target_arrears_yn;
    p6_a43 := ddx_lsqv_rec.target_periods;
    p6_a44 := ddx_lsqv_rec.iir;
    p6_a45 := ddx_lsqv_rec.booking_yield;
    p6_a46 := ddx_lsqv_rec.pirr;
    p6_a47 := ddx_lsqv_rec.airr;
    p6_a48 := ddx_lsqv_rec.sub_iir;
    p6_a49 := ddx_lsqv_rec.sub_booking_yield;
    p6_a50 := ddx_lsqv_rec.sub_pirr;
    p6_a51 := ddx_lsqv_rec.sub_airr;
    p6_a52 := ddx_lsqv_rec.usage_category;
    p6_a53 := ddx_lsqv_rec.usage_industry_class;
    p6_a54 := ddx_lsqv_rec.usage_industry_code;
    p6_a55 := ddx_lsqv_rec.usage_amount;
    p6_a56 := ddx_lsqv_rec.usage_location_id;
    p6_a57 := ddx_lsqv_rec.property_tax_applicable;
    p6_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p6_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p6_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p6_a61 := ddx_lsqv_rec.transfer_of_title;
    p6_a62 := ddx_lsqv_rec.age_of_equipment;
    p6_a63 := ddx_lsqv_rec.purchase_of_lease;
    p6_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p6_a65 := ddx_lsqv_rec.interest_disclosed;
    p6_a66 := ddx_lsqv_rec.primary_quote;
    p6_a67 := ddx_lsqv_rec.legal_entity_id;
    p6_a68 := ddx_lsqv_rec.line_intended_use;
    p6_a69 := ddx_lsqv_rec.short_description;
    p6_a70 := ddx_lsqv_rec.description;
    p6_a71 := ddx_lsqv_rec.comments;
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
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  DATE
    , p5_a23  DATE
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  DATE
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  VARCHAR2
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  NUMBER
    , p5_a51  NUMBER
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  NUMBER
    , p5_a57  VARCHAR2
    , p5_a58  VARCHAR2
    , p5_a59  VARCHAR2
    , p5_a60  NUMBER
    , p5_a61  VARCHAR2
    , p5_a62  NUMBER
    , p5_a63  VARCHAR2
    , p5_a64  VARCHAR2
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  VARCHAR2
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  VARCHAR2
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
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
  )

  as
    ddp_lsqv_rec okl_lsq_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lsq_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lsqv_rec.id := p5_a0;
    ddp_lsqv_rec.object_version_number := p5_a1;
    ddp_lsqv_rec.attribute_category := p5_a2;
    ddp_lsqv_rec.attribute1 := p5_a3;
    ddp_lsqv_rec.attribute2 := p5_a4;
    ddp_lsqv_rec.attribute3 := p5_a5;
    ddp_lsqv_rec.attribute4 := p5_a6;
    ddp_lsqv_rec.attribute5 := p5_a7;
    ddp_lsqv_rec.attribute6 := p5_a8;
    ddp_lsqv_rec.attribute7 := p5_a9;
    ddp_lsqv_rec.attribute8 := p5_a10;
    ddp_lsqv_rec.attribute9 := p5_a11;
    ddp_lsqv_rec.attribute10 := p5_a12;
    ddp_lsqv_rec.attribute11 := p5_a13;
    ddp_lsqv_rec.attribute12 := p5_a14;
    ddp_lsqv_rec.attribute13 := p5_a15;
    ddp_lsqv_rec.attribute14 := p5_a16;
    ddp_lsqv_rec.attribute15 := p5_a17;
    ddp_lsqv_rec.reference_number := p5_a18;
    ddp_lsqv_rec.status := p5_a19;
    ddp_lsqv_rec.parent_object_code := p5_a20;
    ddp_lsqv_rec.parent_object_id := p5_a21;
    ddp_lsqv_rec.valid_from := p5_a22;
    ddp_lsqv_rec.valid_to := p5_a23;
    ddp_lsqv_rec.customer_bookclass := p5_a24;
    ddp_lsqv_rec.customer_taxowner := p5_a25;
    ddp_lsqv_rec.expected_start_date := p5_a26;
    ddp_lsqv_rec.expected_funding_date := p5_a27;
    ddp_lsqv_rec.expected_delivery_date := p5_a28;
    ddp_lsqv_rec.pricing_method := p5_a29;
    ddp_lsqv_rec.term := p5_a30;
    ddp_lsqv_rec.product_id := p5_a31;
    ddp_lsqv_rec.end_of_term_option_id := p5_a32;
    ddp_lsqv_rec.structured_pricing := p5_a33;
    ddp_lsqv_rec.line_level_pricing := p5_a34;
    ddp_lsqv_rec.rate_template_id := p5_a35;
    ddp_lsqv_rec.rate_card_id := p5_a36;
    ddp_lsqv_rec.lease_rate_factor := p5_a37;
    ddp_lsqv_rec.target_rate_type := p5_a38;
    ddp_lsqv_rec.target_rate := p5_a39;
    ddp_lsqv_rec.target_amount := p5_a40;
    ddp_lsqv_rec.target_frequency := p5_a41;
    ddp_lsqv_rec.target_arrears_yn := p5_a42;
    ddp_lsqv_rec.target_periods := p5_a43;
    ddp_lsqv_rec.iir := p5_a44;
    ddp_lsqv_rec.booking_yield := p5_a45;
    ddp_lsqv_rec.pirr := p5_a46;
    ddp_lsqv_rec.airr := p5_a47;
    ddp_lsqv_rec.sub_iir := p5_a48;
    ddp_lsqv_rec.sub_booking_yield := p5_a49;
    ddp_lsqv_rec.sub_pirr := p5_a50;
    ddp_lsqv_rec.sub_airr := p5_a51;
    ddp_lsqv_rec.usage_category := p5_a52;
    ddp_lsqv_rec.usage_industry_class := p5_a53;
    ddp_lsqv_rec.usage_industry_code := p5_a54;
    ddp_lsqv_rec.usage_amount := p5_a55;
    ddp_lsqv_rec.usage_location_id := p5_a56;
    ddp_lsqv_rec.property_tax_applicable := p5_a57;
    ddp_lsqv_rec.property_tax_billing_type := p5_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p5_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p5_a60;
    ddp_lsqv_rec.transfer_of_title := p5_a61;
    ddp_lsqv_rec.age_of_equipment := p5_a62;
    ddp_lsqv_rec.purchase_of_lease := p5_a63;
    ddp_lsqv_rec.sale_and_lease_back := p5_a64;
    ddp_lsqv_rec.interest_disclosed := p5_a65;
    ddp_lsqv_rec.primary_quote := p5_a66;
    ddp_lsqv_rec.legal_entity_id := p5_a67;
    ddp_lsqv_rec.line_intended_use := p5_a68;
    ddp_lsqv_rec.short_description := p5_a69;
    ddp_lsqv_rec.description := p5_a70;
    ddp_lsqv_rec.comments := p5_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lsq_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsqv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lsqv_rec.id;
    p6_a1 := ddx_lsqv_rec.object_version_number;
    p6_a2 := ddx_lsqv_rec.attribute_category;
    p6_a3 := ddx_lsqv_rec.attribute1;
    p6_a4 := ddx_lsqv_rec.attribute2;
    p6_a5 := ddx_lsqv_rec.attribute3;
    p6_a6 := ddx_lsqv_rec.attribute4;
    p6_a7 := ddx_lsqv_rec.attribute5;
    p6_a8 := ddx_lsqv_rec.attribute6;
    p6_a9 := ddx_lsqv_rec.attribute7;
    p6_a10 := ddx_lsqv_rec.attribute8;
    p6_a11 := ddx_lsqv_rec.attribute9;
    p6_a12 := ddx_lsqv_rec.attribute10;
    p6_a13 := ddx_lsqv_rec.attribute11;
    p6_a14 := ddx_lsqv_rec.attribute12;
    p6_a15 := ddx_lsqv_rec.attribute13;
    p6_a16 := ddx_lsqv_rec.attribute14;
    p6_a17 := ddx_lsqv_rec.attribute15;
    p6_a18 := ddx_lsqv_rec.reference_number;
    p6_a19 := ddx_lsqv_rec.status;
    p6_a20 := ddx_lsqv_rec.parent_object_code;
    p6_a21 := ddx_lsqv_rec.parent_object_id;
    p6_a22 := ddx_lsqv_rec.valid_from;
    p6_a23 := ddx_lsqv_rec.valid_to;
    p6_a24 := ddx_lsqv_rec.customer_bookclass;
    p6_a25 := ddx_lsqv_rec.customer_taxowner;
    p6_a26 := ddx_lsqv_rec.expected_start_date;
    p6_a27 := ddx_lsqv_rec.expected_funding_date;
    p6_a28 := ddx_lsqv_rec.expected_delivery_date;
    p6_a29 := ddx_lsqv_rec.pricing_method;
    p6_a30 := ddx_lsqv_rec.term;
    p6_a31 := ddx_lsqv_rec.product_id;
    p6_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p6_a33 := ddx_lsqv_rec.structured_pricing;
    p6_a34 := ddx_lsqv_rec.line_level_pricing;
    p6_a35 := ddx_lsqv_rec.rate_template_id;
    p6_a36 := ddx_lsqv_rec.rate_card_id;
    p6_a37 := ddx_lsqv_rec.lease_rate_factor;
    p6_a38 := ddx_lsqv_rec.target_rate_type;
    p6_a39 := ddx_lsqv_rec.target_rate;
    p6_a40 := ddx_lsqv_rec.target_amount;
    p6_a41 := ddx_lsqv_rec.target_frequency;
    p6_a42 := ddx_lsqv_rec.target_arrears_yn;
    p6_a43 := ddx_lsqv_rec.target_periods;
    p6_a44 := ddx_lsqv_rec.iir;
    p6_a45 := ddx_lsqv_rec.booking_yield;
    p6_a46 := ddx_lsqv_rec.pirr;
    p6_a47 := ddx_lsqv_rec.airr;
    p6_a48 := ddx_lsqv_rec.sub_iir;
    p6_a49 := ddx_lsqv_rec.sub_booking_yield;
    p6_a50 := ddx_lsqv_rec.sub_pirr;
    p6_a51 := ddx_lsqv_rec.sub_airr;
    p6_a52 := ddx_lsqv_rec.usage_category;
    p6_a53 := ddx_lsqv_rec.usage_industry_class;
    p6_a54 := ddx_lsqv_rec.usage_industry_code;
    p6_a55 := ddx_lsqv_rec.usage_amount;
    p6_a56 := ddx_lsqv_rec.usage_location_id;
    p6_a57 := ddx_lsqv_rec.property_tax_applicable;
    p6_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p6_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p6_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p6_a61 := ddx_lsqv_rec.transfer_of_title;
    p6_a62 := ddx_lsqv_rec.age_of_equipment;
    p6_a63 := ddx_lsqv_rec.purchase_of_lease;
    p6_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p6_a65 := ddx_lsqv_rec.interest_disclosed;
    p6_a66 := ddx_lsqv_rec.primary_quote;
    p6_a67 := ddx_lsqv_rec.legal_entity_id;
    p6_a68 := ddx_lsqv_rec.line_intended_use;
    p6_a69 := ddx_lsqv_rec.short_description;
    p6_a70 := ddx_lsqv_rec.description;
    p6_a71 := ddx_lsqv_rec.comments;
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
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  DATE
    , p5_a23  DATE
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  DATE
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  VARCHAR2
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  VARCHAR2
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  NUMBER
    , p5_a51  NUMBER
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  NUMBER
    , p5_a57  VARCHAR2
    , p5_a58  VARCHAR2
    , p5_a59  VARCHAR2
    , p5_a60  NUMBER
    , p5_a61  VARCHAR2
    , p5_a62  NUMBER
    , p5_a63  VARCHAR2
    , p5_a64  VARCHAR2
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  NUMBER
    , p5_a68  VARCHAR2
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  VARCHAR2
  )

  as
    ddp_lsqv_rec okl_lsq_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lsqv_rec.id := p5_a0;
    ddp_lsqv_rec.object_version_number := p5_a1;
    ddp_lsqv_rec.attribute_category := p5_a2;
    ddp_lsqv_rec.attribute1 := p5_a3;
    ddp_lsqv_rec.attribute2 := p5_a4;
    ddp_lsqv_rec.attribute3 := p5_a5;
    ddp_lsqv_rec.attribute4 := p5_a6;
    ddp_lsqv_rec.attribute5 := p5_a7;
    ddp_lsqv_rec.attribute6 := p5_a8;
    ddp_lsqv_rec.attribute7 := p5_a9;
    ddp_lsqv_rec.attribute8 := p5_a10;
    ddp_lsqv_rec.attribute9 := p5_a11;
    ddp_lsqv_rec.attribute10 := p5_a12;
    ddp_lsqv_rec.attribute11 := p5_a13;
    ddp_lsqv_rec.attribute12 := p5_a14;
    ddp_lsqv_rec.attribute13 := p5_a15;
    ddp_lsqv_rec.attribute14 := p5_a16;
    ddp_lsqv_rec.attribute15 := p5_a17;
    ddp_lsqv_rec.reference_number := p5_a18;
    ddp_lsqv_rec.status := p5_a19;
    ddp_lsqv_rec.parent_object_code := p5_a20;
    ddp_lsqv_rec.parent_object_id := p5_a21;
    ddp_lsqv_rec.valid_from := p5_a22;
    ddp_lsqv_rec.valid_to := p5_a23;
    ddp_lsqv_rec.customer_bookclass := p5_a24;
    ddp_lsqv_rec.customer_taxowner := p5_a25;
    ddp_lsqv_rec.expected_start_date := p5_a26;
    ddp_lsqv_rec.expected_funding_date := p5_a27;
    ddp_lsqv_rec.expected_delivery_date := p5_a28;
    ddp_lsqv_rec.pricing_method := p5_a29;
    ddp_lsqv_rec.term := p5_a30;
    ddp_lsqv_rec.product_id := p5_a31;
    ddp_lsqv_rec.end_of_term_option_id := p5_a32;
    ddp_lsqv_rec.structured_pricing := p5_a33;
    ddp_lsqv_rec.line_level_pricing := p5_a34;
    ddp_lsqv_rec.rate_template_id := p5_a35;
    ddp_lsqv_rec.rate_card_id := p5_a36;
    ddp_lsqv_rec.lease_rate_factor := p5_a37;
    ddp_lsqv_rec.target_rate_type := p5_a38;
    ddp_lsqv_rec.target_rate := p5_a39;
    ddp_lsqv_rec.target_amount := p5_a40;
    ddp_lsqv_rec.target_frequency := p5_a41;
    ddp_lsqv_rec.target_arrears_yn := p5_a42;
    ddp_lsqv_rec.target_periods := p5_a43;
    ddp_lsqv_rec.iir := p5_a44;
    ddp_lsqv_rec.booking_yield := p5_a45;
    ddp_lsqv_rec.pirr := p5_a46;
    ddp_lsqv_rec.airr := p5_a47;
    ddp_lsqv_rec.sub_iir := p5_a48;
    ddp_lsqv_rec.sub_booking_yield := p5_a49;
    ddp_lsqv_rec.sub_pirr := p5_a50;
    ddp_lsqv_rec.sub_airr := p5_a51;
    ddp_lsqv_rec.usage_category := p5_a52;
    ddp_lsqv_rec.usage_industry_class := p5_a53;
    ddp_lsqv_rec.usage_industry_code := p5_a54;
    ddp_lsqv_rec.usage_amount := p5_a55;
    ddp_lsqv_rec.usage_location_id := p5_a56;
    ddp_lsqv_rec.property_tax_applicable := p5_a57;
    ddp_lsqv_rec.property_tax_billing_type := p5_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p5_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p5_a60;
    ddp_lsqv_rec.transfer_of_title := p5_a61;
    ddp_lsqv_rec.age_of_equipment := p5_a62;
    ddp_lsqv_rec.purchase_of_lease := p5_a63;
    ddp_lsqv_rec.sale_and_lease_back := p5_a64;
    ddp_lsqv_rec.interest_disclosed := p5_a65;
    ddp_lsqv_rec.primary_quote := p5_a66;
    ddp_lsqv_rec.legal_entity_id := p5_a67;
    ddp_lsqv_rec.line_intended_use := p5_a68;
    ddp_lsqv_rec.short_description := p5_a69;
    ddp_lsqv_rec.description := p5_a70;
    ddp_lsqv_rec.comments := p5_a71;

    -- here's the delegated call to the old PL/SQL routine
    okl_lsq_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_lsq_pvt_w;

/
