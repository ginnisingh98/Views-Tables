--------------------------------------------------------
--  DDL for Package Body OKL_LOP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOP_PVT_W" as
  /* $Header: OKLILOPB.pls 120.1 2007/03/20 23:13:46 rravikir noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_lop_pvt.lopv_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_2000
    , a52 JTF_VARCHAR2_TABLE_2000
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
          t(ddindx).valid_from := a20(indx);
          t(ddindx).expected_start_date := a21(indx);
          t(ddindx).org_id := a22(indx);
          t(ddindx).inv_org_id := a23(indx);
          t(ddindx).prospect_id := a24(indx);
          t(ddindx).prospect_address_id := a25(indx);
          t(ddindx).cust_acct_id := a26(indx);
          t(ddindx).currency_code := a27(indx);
          t(ddindx).currency_conversion_type := a28(indx);
          t(ddindx).currency_conversion_rate := a29(indx);
          t(ddindx).currency_conversion_date := a30(indx);
          t(ddindx).program_agreement_id := a31(indx);
          t(ddindx).master_lease_id := a32(indx);
          t(ddindx).sales_rep_id := a33(indx);
          t(ddindx).sales_territory_id := a34(indx);
          t(ddindx).supplier_id := a35(indx);
          t(ddindx).delivery_date := a36(indx);
          t(ddindx).funding_date := a37(indx);
          t(ddindx).property_tax_applicable := a38(indx);
          t(ddindx).property_tax_billing_type := a39(indx);
          t(ddindx).upfront_tax_treatment := a40(indx);
          t(ddindx).install_site_id := a41(indx);
          t(ddindx).usage_category := a42(indx);
          t(ddindx).usage_industry_class := a43(indx);
          t(ddindx).usage_industry_code := a44(indx);
          t(ddindx).usage_amount := a45(indx);
          t(ddindx).usage_location_id := a46(indx);
          t(ddindx).originating_vendor_id := a47(indx);
          t(ddindx).legal_entity_id := a48(indx);
          t(ddindx).line_intended_use := a49(indx);
          t(ddindx).short_description := a50(indx);
          t(ddindx).description := a51(indx);
          t(ddindx).comments := a52(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_lop_pvt.lopv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_2000();
    a52 := JTF_VARCHAR2_TABLE_2000();
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
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_2000();
      a52 := JTF_VARCHAR2_TABLE_2000();
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
          a20(indx) := t(ddindx).valid_from;
          a21(indx) := t(ddindx).expected_start_date;
          a22(indx) := t(ddindx).org_id;
          a23(indx) := t(ddindx).inv_org_id;
          a24(indx) := t(ddindx).prospect_id;
          a25(indx) := t(ddindx).prospect_address_id;
          a26(indx) := t(ddindx).cust_acct_id;
          a27(indx) := t(ddindx).currency_code;
          a28(indx) := t(ddindx).currency_conversion_type;
          a29(indx) := t(ddindx).currency_conversion_rate;
          a30(indx) := t(ddindx).currency_conversion_date;
          a31(indx) := t(ddindx).program_agreement_id;
          a32(indx) := t(ddindx).master_lease_id;
          a33(indx) := t(ddindx).sales_rep_id;
          a34(indx) := t(ddindx).sales_territory_id;
          a35(indx) := t(ddindx).supplier_id;
          a36(indx) := t(ddindx).delivery_date;
          a37(indx) := t(ddindx).funding_date;
          a38(indx) := t(ddindx).property_tax_applicable;
          a39(indx) := t(ddindx).property_tax_billing_type;
          a40(indx) := t(ddindx).upfront_tax_treatment;
          a41(indx) := t(ddindx).install_site_id;
          a42(indx) := t(ddindx).usage_category;
          a43(indx) := t(ddindx).usage_industry_class;
          a44(indx) := t(ddindx).usage_industry_code;
          a45(indx) := t(ddindx).usage_amount;
          a46(indx) := t(ddindx).usage_location_id;
          a47(indx) := t(ddindx).originating_vendor_id;
          a48(indx) := t(ddindx).legal_entity_id;
          a49(indx) := t(ddindx).line_intended_use;
          a50(indx) := t(ddindx).short_description;
          a51(indx) := t(ddindx).description;
          a52(indx) := t(ddindx).comments;
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
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_300
    , p5_a50 JTF_VARCHAR2_TABLE_300
    , p5_a51 JTF_VARCHAR2_TABLE_2000
    , p5_a52 JTF_VARCHAR2_TABLE_2000
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
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_lopv_tbl okl_lop_pvt.lopv_tbl_type;
    ddx_lopv_tbl okl_lop_pvt.lopv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lop_pvt_w.rosetta_table_copy_in_p23(ddp_lopv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lop_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lopv_tbl,
      ddx_lopv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lop_pvt_w.rosetta_table_copy_out_p23(ddx_lopv_tbl, p6_a0
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
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_300
    , p5_a50 JTF_VARCHAR2_TABLE_300
    , p5_a51 JTF_VARCHAR2_TABLE_2000
    , p5_a52 JTF_VARCHAR2_TABLE_2000
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
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_lopv_tbl okl_lop_pvt.lopv_tbl_type;
    ddx_lopv_tbl okl_lop_pvt.lopv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lop_pvt_w.rosetta_table_copy_in_p23(ddp_lopv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lop_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lopv_tbl,
      ddx_lopv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lop_pvt_w.rosetta_table_copy_out_p23(ddx_lopv_tbl, p6_a0
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
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_300
    , p5_a50 JTF_VARCHAR2_TABLE_300
    , p5_a51 JTF_VARCHAR2_TABLE_2000
    , p5_a52 JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_lopv_tbl okl_lop_pvt.lopv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lop_pvt_w.rosetta_table_copy_in_p23(ddp_lopv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_lop_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lopv_tbl);

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
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  DATE
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
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
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
  )

  as
    ddp_lopv_rec okl_lop_pvt.lopv_rec_type;
    ddx_lopv_rec okl_lop_pvt.lopv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lopv_rec.id := p5_a0;
    ddp_lopv_rec.object_version_number := p5_a1;
    ddp_lopv_rec.attribute_category := p5_a2;
    ddp_lopv_rec.attribute1 := p5_a3;
    ddp_lopv_rec.attribute2 := p5_a4;
    ddp_lopv_rec.attribute3 := p5_a5;
    ddp_lopv_rec.attribute4 := p5_a6;
    ddp_lopv_rec.attribute5 := p5_a7;
    ddp_lopv_rec.attribute6 := p5_a8;
    ddp_lopv_rec.attribute7 := p5_a9;
    ddp_lopv_rec.attribute8 := p5_a10;
    ddp_lopv_rec.attribute9 := p5_a11;
    ddp_lopv_rec.attribute10 := p5_a12;
    ddp_lopv_rec.attribute11 := p5_a13;
    ddp_lopv_rec.attribute12 := p5_a14;
    ddp_lopv_rec.attribute13 := p5_a15;
    ddp_lopv_rec.attribute14 := p5_a16;
    ddp_lopv_rec.attribute15 := p5_a17;
    ddp_lopv_rec.reference_number := p5_a18;
    ddp_lopv_rec.status := p5_a19;
    ddp_lopv_rec.valid_from := p5_a20;
    ddp_lopv_rec.expected_start_date := p5_a21;
    ddp_lopv_rec.org_id := p5_a22;
    ddp_lopv_rec.inv_org_id := p5_a23;
    ddp_lopv_rec.prospect_id := p5_a24;
    ddp_lopv_rec.prospect_address_id := p5_a25;
    ddp_lopv_rec.cust_acct_id := p5_a26;
    ddp_lopv_rec.currency_code := p5_a27;
    ddp_lopv_rec.currency_conversion_type := p5_a28;
    ddp_lopv_rec.currency_conversion_rate := p5_a29;
    ddp_lopv_rec.currency_conversion_date := p5_a30;
    ddp_lopv_rec.program_agreement_id := p5_a31;
    ddp_lopv_rec.master_lease_id := p5_a32;
    ddp_lopv_rec.sales_rep_id := p5_a33;
    ddp_lopv_rec.sales_territory_id := p5_a34;
    ddp_lopv_rec.supplier_id := p5_a35;
    ddp_lopv_rec.delivery_date := p5_a36;
    ddp_lopv_rec.funding_date := p5_a37;
    ddp_lopv_rec.property_tax_applicable := p5_a38;
    ddp_lopv_rec.property_tax_billing_type := p5_a39;
    ddp_lopv_rec.upfront_tax_treatment := p5_a40;
    ddp_lopv_rec.install_site_id := p5_a41;
    ddp_lopv_rec.usage_category := p5_a42;
    ddp_lopv_rec.usage_industry_class := p5_a43;
    ddp_lopv_rec.usage_industry_code := p5_a44;
    ddp_lopv_rec.usage_amount := p5_a45;
    ddp_lopv_rec.usage_location_id := p5_a46;
    ddp_lopv_rec.originating_vendor_id := p5_a47;
    ddp_lopv_rec.legal_entity_id := p5_a48;
    ddp_lopv_rec.line_intended_use := p5_a49;
    ddp_lopv_rec.short_description := p5_a50;
    ddp_lopv_rec.description := p5_a51;
    ddp_lopv_rec.comments := p5_a52;


    -- here's the delegated call to the old PL/SQL routine
    okl_lop_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lopv_rec,
      ddx_lopv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lopv_rec.id;
    p6_a1 := ddx_lopv_rec.object_version_number;
    p6_a2 := ddx_lopv_rec.attribute_category;
    p6_a3 := ddx_lopv_rec.attribute1;
    p6_a4 := ddx_lopv_rec.attribute2;
    p6_a5 := ddx_lopv_rec.attribute3;
    p6_a6 := ddx_lopv_rec.attribute4;
    p6_a7 := ddx_lopv_rec.attribute5;
    p6_a8 := ddx_lopv_rec.attribute6;
    p6_a9 := ddx_lopv_rec.attribute7;
    p6_a10 := ddx_lopv_rec.attribute8;
    p6_a11 := ddx_lopv_rec.attribute9;
    p6_a12 := ddx_lopv_rec.attribute10;
    p6_a13 := ddx_lopv_rec.attribute11;
    p6_a14 := ddx_lopv_rec.attribute12;
    p6_a15 := ddx_lopv_rec.attribute13;
    p6_a16 := ddx_lopv_rec.attribute14;
    p6_a17 := ddx_lopv_rec.attribute15;
    p6_a18 := ddx_lopv_rec.reference_number;
    p6_a19 := ddx_lopv_rec.status;
    p6_a20 := ddx_lopv_rec.valid_from;
    p6_a21 := ddx_lopv_rec.expected_start_date;
    p6_a22 := ddx_lopv_rec.org_id;
    p6_a23 := ddx_lopv_rec.inv_org_id;
    p6_a24 := ddx_lopv_rec.prospect_id;
    p6_a25 := ddx_lopv_rec.prospect_address_id;
    p6_a26 := ddx_lopv_rec.cust_acct_id;
    p6_a27 := ddx_lopv_rec.currency_code;
    p6_a28 := ddx_lopv_rec.currency_conversion_type;
    p6_a29 := ddx_lopv_rec.currency_conversion_rate;
    p6_a30 := ddx_lopv_rec.currency_conversion_date;
    p6_a31 := ddx_lopv_rec.program_agreement_id;
    p6_a32 := ddx_lopv_rec.master_lease_id;
    p6_a33 := ddx_lopv_rec.sales_rep_id;
    p6_a34 := ddx_lopv_rec.sales_territory_id;
    p6_a35 := ddx_lopv_rec.supplier_id;
    p6_a36 := ddx_lopv_rec.delivery_date;
    p6_a37 := ddx_lopv_rec.funding_date;
    p6_a38 := ddx_lopv_rec.property_tax_applicable;
    p6_a39 := ddx_lopv_rec.property_tax_billing_type;
    p6_a40 := ddx_lopv_rec.upfront_tax_treatment;
    p6_a41 := ddx_lopv_rec.install_site_id;
    p6_a42 := ddx_lopv_rec.usage_category;
    p6_a43 := ddx_lopv_rec.usage_industry_class;
    p6_a44 := ddx_lopv_rec.usage_industry_code;
    p6_a45 := ddx_lopv_rec.usage_amount;
    p6_a46 := ddx_lopv_rec.usage_location_id;
    p6_a47 := ddx_lopv_rec.originating_vendor_id;
    p6_a48 := ddx_lopv_rec.legal_entity_id;
    p6_a49 := ddx_lopv_rec.line_intended_use;
    p6_a50 := ddx_lopv_rec.short_description;
    p6_a51 := ddx_lopv_rec.description;
    p6_a52 := ddx_lopv_rec.comments;
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
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  DATE
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
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
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
  )

  as
    ddp_lopv_rec okl_lop_pvt.lopv_rec_type;
    ddx_lopv_rec okl_lop_pvt.lopv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lopv_rec.id := p5_a0;
    ddp_lopv_rec.object_version_number := p5_a1;
    ddp_lopv_rec.attribute_category := p5_a2;
    ddp_lopv_rec.attribute1 := p5_a3;
    ddp_lopv_rec.attribute2 := p5_a4;
    ddp_lopv_rec.attribute3 := p5_a5;
    ddp_lopv_rec.attribute4 := p5_a6;
    ddp_lopv_rec.attribute5 := p5_a7;
    ddp_lopv_rec.attribute6 := p5_a8;
    ddp_lopv_rec.attribute7 := p5_a9;
    ddp_lopv_rec.attribute8 := p5_a10;
    ddp_lopv_rec.attribute9 := p5_a11;
    ddp_lopv_rec.attribute10 := p5_a12;
    ddp_lopv_rec.attribute11 := p5_a13;
    ddp_lopv_rec.attribute12 := p5_a14;
    ddp_lopv_rec.attribute13 := p5_a15;
    ddp_lopv_rec.attribute14 := p5_a16;
    ddp_lopv_rec.attribute15 := p5_a17;
    ddp_lopv_rec.reference_number := p5_a18;
    ddp_lopv_rec.status := p5_a19;
    ddp_lopv_rec.valid_from := p5_a20;
    ddp_lopv_rec.expected_start_date := p5_a21;
    ddp_lopv_rec.org_id := p5_a22;
    ddp_lopv_rec.inv_org_id := p5_a23;
    ddp_lopv_rec.prospect_id := p5_a24;
    ddp_lopv_rec.prospect_address_id := p5_a25;
    ddp_lopv_rec.cust_acct_id := p5_a26;
    ddp_lopv_rec.currency_code := p5_a27;
    ddp_lopv_rec.currency_conversion_type := p5_a28;
    ddp_lopv_rec.currency_conversion_rate := p5_a29;
    ddp_lopv_rec.currency_conversion_date := p5_a30;
    ddp_lopv_rec.program_agreement_id := p5_a31;
    ddp_lopv_rec.master_lease_id := p5_a32;
    ddp_lopv_rec.sales_rep_id := p5_a33;
    ddp_lopv_rec.sales_territory_id := p5_a34;
    ddp_lopv_rec.supplier_id := p5_a35;
    ddp_lopv_rec.delivery_date := p5_a36;
    ddp_lopv_rec.funding_date := p5_a37;
    ddp_lopv_rec.property_tax_applicable := p5_a38;
    ddp_lopv_rec.property_tax_billing_type := p5_a39;
    ddp_lopv_rec.upfront_tax_treatment := p5_a40;
    ddp_lopv_rec.install_site_id := p5_a41;
    ddp_lopv_rec.usage_category := p5_a42;
    ddp_lopv_rec.usage_industry_class := p5_a43;
    ddp_lopv_rec.usage_industry_code := p5_a44;
    ddp_lopv_rec.usage_amount := p5_a45;
    ddp_lopv_rec.usage_location_id := p5_a46;
    ddp_lopv_rec.originating_vendor_id := p5_a47;
    ddp_lopv_rec.legal_entity_id := p5_a48;
    ddp_lopv_rec.line_intended_use := p5_a49;
    ddp_lopv_rec.short_description := p5_a50;
    ddp_lopv_rec.description := p5_a51;
    ddp_lopv_rec.comments := p5_a52;


    -- here's the delegated call to the old PL/SQL routine
    okl_lop_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lopv_rec,
      ddx_lopv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lopv_rec.id;
    p6_a1 := ddx_lopv_rec.object_version_number;
    p6_a2 := ddx_lopv_rec.attribute_category;
    p6_a3 := ddx_lopv_rec.attribute1;
    p6_a4 := ddx_lopv_rec.attribute2;
    p6_a5 := ddx_lopv_rec.attribute3;
    p6_a6 := ddx_lopv_rec.attribute4;
    p6_a7 := ddx_lopv_rec.attribute5;
    p6_a8 := ddx_lopv_rec.attribute6;
    p6_a9 := ddx_lopv_rec.attribute7;
    p6_a10 := ddx_lopv_rec.attribute8;
    p6_a11 := ddx_lopv_rec.attribute9;
    p6_a12 := ddx_lopv_rec.attribute10;
    p6_a13 := ddx_lopv_rec.attribute11;
    p6_a14 := ddx_lopv_rec.attribute12;
    p6_a15 := ddx_lopv_rec.attribute13;
    p6_a16 := ddx_lopv_rec.attribute14;
    p6_a17 := ddx_lopv_rec.attribute15;
    p6_a18 := ddx_lopv_rec.reference_number;
    p6_a19 := ddx_lopv_rec.status;
    p6_a20 := ddx_lopv_rec.valid_from;
    p6_a21 := ddx_lopv_rec.expected_start_date;
    p6_a22 := ddx_lopv_rec.org_id;
    p6_a23 := ddx_lopv_rec.inv_org_id;
    p6_a24 := ddx_lopv_rec.prospect_id;
    p6_a25 := ddx_lopv_rec.prospect_address_id;
    p6_a26 := ddx_lopv_rec.cust_acct_id;
    p6_a27 := ddx_lopv_rec.currency_code;
    p6_a28 := ddx_lopv_rec.currency_conversion_type;
    p6_a29 := ddx_lopv_rec.currency_conversion_rate;
    p6_a30 := ddx_lopv_rec.currency_conversion_date;
    p6_a31 := ddx_lopv_rec.program_agreement_id;
    p6_a32 := ddx_lopv_rec.master_lease_id;
    p6_a33 := ddx_lopv_rec.sales_rep_id;
    p6_a34 := ddx_lopv_rec.sales_territory_id;
    p6_a35 := ddx_lopv_rec.supplier_id;
    p6_a36 := ddx_lopv_rec.delivery_date;
    p6_a37 := ddx_lopv_rec.funding_date;
    p6_a38 := ddx_lopv_rec.property_tax_applicable;
    p6_a39 := ddx_lopv_rec.property_tax_billing_type;
    p6_a40 := ddx_lopv_rec.upfront_tax_treatment;
    p6_a41 := ddx_lopv_rec.install_site_id;
    p6_a42 := ddx_lopv_rec.usage_category;
    p6_a43 := ddx_lopv_rec.usage_industry_class;
    p6_a44 := ddx_lopv_rec.usage_industry_code;
    p6_a45 := ddx_lopv_rec.usage_amount;
    p6_a46 := ddx_lopv_rec.usage_location_id;
    p6_a47 := ddx_lopv_rec.originating_vendor_id;
    p6_a48 := ddx_lopv_rec.legal_entity_id;
    p6_a49 := ddx_lopv_rec.line_intended_use;
    p6_a50 := ddx_lopv_rec.short_description;
    p6_a51 := ddx_lopv_rec.description;
    p6_a52 := ddx_lopv_rec.comments;
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
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  DATE
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
  )

  as
    ddp_lopv_rec okl_lop_pvt.lopv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lopv_rec.id := p5_a0;
    ddp_lopv_rec.object_version_number := p5_a1;
    ddp_lopv_rec.attribute_category := p5_a2;
    ddp_lopv_rec.attribute1 := p5_a3;
    ddp_lopv_rec.attribute2 := p5_a4;
    ddp_lopv_rec.attribute3 := p5_a5;
    ddp_lopv_rec.attribute4 := p5_a6;
    ddp_lopv_rec.attribute5 := p5_a7;
    ddp_lopv_rec.attribute6 := p5_a8;
    ddp_lopv_rec.attribute7 := p5_a9;
    ddp_lopv_rec.attribute8 := p5_a10;
    ddp_lopv_rec.attribute9 := p5_a11;
    ddp_lopv_rec.attribute10 := p5_a12;
    ddp_lopv_rec.attribute11 := p5_a13;
    ddp_lopv_rec.attribute12 := p5_a14;
    ddp_lopv_rec.attribute13 := p5_a15;
    ddp_lopv_rec.attribute14 := p5_a16;
    ddp_lopv_rec.attribute15 := p5_a17;
    ddp_lopv_rec.reference_number := p5_a18;
    ddp_lopv_rec.status := p5_a19;
    ddp_lopv_rec.valid_from := p5_a20;
    ddp_lopv_rec.expected_start_date := p5_a21;
    ddp_lopv_rec.org_id := p5_a22;
    ddp_lopv_rec.inv_org_id := p5_a23;
    ddp_lopv_rec.prospect_id := p5_a24;
    ddp_lopv_rec.prospect_address_id := p5_a25;
    ddp_lopv_rec.cust_acct_id := p5_a26;
    ddp_lopv_rec.currency_code := p5_a27;
    ddp_lopv_rec.currency_conversion_type := p5_a28;
    ddp_lopv_rec.currency_conversion_rate := p5_a29;
    ddp_lopv_rec.currency_conversion_date := p5_a30;
    ddp_lopv_rec.program_agreement_id := p5_a31;
    ddp_lopv_rec.master_lease_id := p5_a32;
    ddp_lopv_rec.sales_rep_id := p5_a33;
    ddp_lopv_rec.sales_territory_id := p5_a34;
    ddp_lopv_rec.supplier_id := p5_a35;
    ddp_lopv_rec.delivery_date := p5_a36;
    ddp_lopv_rec.funding_date := p5_a37;
    ddp_lopv_rec.property_tax_applicable := p5_a38;
    ddp_lopv_rec.property_tax_billing_type := p5_a39;
    ddp_lopv_rec.upfront_tax_treatment := p5_a40;
    ddp_lopv_rec.install_site_id := p5_a41;
    ddp_lopv_rec.usage_category := p5_a42;
    ddp_lopv_rec.usage_industry_class := p5_a43;
    ddp_lopv_rec.usage_industry_code := p5_a44;
    ddp_lopv_rec.usage_amount := p5_a45;
    ddp_lopv_rec.usage_location_id := p5_a46;
    ddp_lopv_rec.originating_vendor_id := p5_a47;
    ddp_lopv_rec.legal_entity_id := p5_a48;
    ddp_lopv_rec.line_intended_use := p5_a49;
    ddp_lopv_rec.short_description := p5_a50;
    ddp_lopv_rec.description := p5_a51;
    ddp_lopv_rec.comments := p5_a52;

    -- here's the delegated call to the old PL/SQL routine
    okl_lop_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lopv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_lop_pvt_w;

/
