--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_APP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_APP_PVT_W" as
  /* $Header: OKLELAPB.pls 120.13 2007/03/20 22:36:42 rravikir noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_lease_app_pvt.name_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).itm_name := a0(indx);
          t(ddindx).itm_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_lease_app_pvt.name_val_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).itm_name;
          a1(indx) := t(ddindx).itm_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure lease_app_cre(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  DATE
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  DATE
    , p7_a27  DATE
    , p7_a28  DATE
    , p7_a29  VARCHAR2
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  DATE
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  NUMBER
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  NUMBER
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  NUMBER
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  NUMBER
    , p8_a40 out nocopy  NUMBER
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  NUMBER
    , p8_a44 out nocopy  NUMBER
    , p8_a45 out nocopy  NUMBER
    , p8_a46 out nocopy  NUMBER
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  NUMBER
    , p8_a50 out nocopy  NUMBER
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  NUMBER
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  VARCHAR2
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  VARCHAR2
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  VARCHAR2
    , p8_a69 out nocopy  VARCHAR2
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    ddp_lsqv_rec.id := p7_a0;
    ddp_lsqv_rec.object_version_number := p7_a1;
    ddp_lsqv_rec.attribute_category := p7_a2;
    ddp_lsqv_rec.attribute1 := p7_a3;
    ddp_lsqv_rec.attribute2 := p7_a4;
    ddp_lsqv_rec.attribute3 := p7_a5;
    ddp_lsqv_rec.attribute4 := p7_a6;
    ddp_lsqv_rec.attribute5 := p7_a7;
    ddp_lsqv_rec.attribute6 := p7_a8;
    ddp_lsqv_rec.attribute7 := p7_a9;
    ddp_lsqv_rec.attribute8 := p7_a10;
    ddp_lsqv_rec.attribute9 := p7_a11;
    ddp_lsqv_rec.attribute10 := p7_a12;
    ddp_lsqv_rec.attribute11 := p7_a13;
    ddp_lsqv_rec.attribute12 := p7_a14;
    ddp_lsqv_rec.attribute13 := p7_a15;
    ddp_lsqv_rec.attribute14 := p7_a16;
    ddp_lsqv_rec.attribute15 := p7_a17;
    ddp_lsqv_rec.reference_number := p7_a18;
    ddp_lsqv_rec.status := p7_a19;
    ddp_lsqv_rec.parent_object_code := p7_a20;
    ddp_lsqv_rec.parent_object_id := p7_a21;
    ddp_lsqv_rec.valid_from := p7_a22;
    ddp_lsqv_rec.valid_to := p7_a23;
    ddp_lsqv_rec.customer_bookclass := p7_a24;
    ddp_lsqv_rec.customer_taxowner := p7_a25;
    ddp_lsqv_rec.expected_start_date := p7_a26;
    ddp_lsqv_rec.expected_funding_date := p7_a27;
    ddp_lsqv_rec.expected_delivery_date := p7_a28;
    ddp_lsqv_rec.pricing_method := p7_a29;
    ddp_lsqv_rec.term := p7_a30;
    ddp_lsqv_rec.product_id := p7_a31;
    ddp_lsqv_rec.end_of_term_option_id := p7_a32;
    ddp_lsqv_rec.structured_pricing := p7_a33;
    ddp_lsqv_rec.line_level_pricing := p7_a34;
    ddp_lsqv_rec.rate_template_id := p7_a35;
    ddp_lsqv_rec.rate_card_id := p7_a36;
    ddp_lsqv_rec.lease_rate_factor := p7_a37;
    ddp_lsqv_rec.target_rate_type := p7_a38;
    ddp_lsqv_rec.target_rate := p7_a39;
    ddp_lsqv_rec.target_amount := p7_a40;
    ddp_lsqv_rec.target_frequency := p7_a41;
    ddp_lsqv_rec.target_arrears_yn := p7_a42;
    ddp_lsqv_rec.target_periods := p7_a43;
    ddp_lsqv_rec.iir := p7_a44;
    ddp_lsqv_rec.booking_yield := p7_a45;
    ddp_lsqv_rec.pirr := p7_a46;
    ddp_lsqv_rec.airr := p7_a47;
    ddp_lsqv_rec.sub_iir := p7_a48;
    ddp_lsqv_rec.sub_booking_yield := p7_a49;
    ddp_lsqv_rec.sub_pirr := p7_a50;
    ddp_lsqv_rec.sub_airr := p7_a51;
    ddp_lsqv_rec.usage_category := p7_a52;
    ddp_lsqv_rec.usage_industry_class := p7_a53;
    ddp_lsqv_rec.usage_industry_code := p7_a54;
    ddp_lsqv_rec.usage_amount := p7_a55;
    ddp_lsqv_rec.usage_location_id := p7_a56;
    ddp_lsqv_rec.property_tax_applicable := p7_a57;
    ddp_lsqv_rec.property_tax_billing_type := p7_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p7_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p7_a60;
    ddp_lsqv_rec.transfer_of_title := p7_a61;
    ddp_lsqv_rec.age_of_equipment := p7_a62;
    ddp_lsqv_rec.purchase_of_lease := p7_a63;
    ddp_lsqv_rec.sale_and_lease_back := p7_a64;
    ddp_lsqv_rec.interest_disclosed := p7_a65;
    ddp_lsqv_rec.primary_quote := p7_a66;
    ddp_lsqv_rec.legal_entity_id := p7_a67;
    ddp_lsqv_rec.line_intended_use := p7_a68;
    ddp_lsqv_rec.short_description := p7_a69;
    ddp_lsqv_rec.description := p7_a70;
    ddp_lsqv_rec.comments := p7_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_cre(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec,
      ddp_lsqv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;


    p8_a0 := ddx_lsqv_rec.id;
    p8_a1 := ddx_lsqv_rec.object_version_number;
    p8_a2 := ddx_lsqv_rec.attribute_category;
    p8_a3 := ddx_lsqv_rec.attribute1;
    p8_a4 := ddx_lsqv_rec.attribute2;
    p8_a5 := ddx_lsqv_rec.attribute3;
    p8_a6 := ddx_lsqv_rec.attribute4;
    p8_a7 := ddx_lsqv_rec.attribute5;
    p8_a8 := ddx_lsqv_rec.attribute6;
    p8_a9 := ddx_lsqv_rec.attribute7;
    p8_a10 := ddx_lsqv_rec.attribute8;
    p8_a11 := ddx_lsqv_rec.attribute9;
    p8_a12 := ddx_lsqv_rec.attribute10;
    p8_a13 := ddx_lsqv_rec.attribute11;
    p8_a14 := ddx_lsqv_rec.attribute12;
    p8_a15 := ddx_lsqv_rec.attribute13;
    p8_a16 := ddx_lsqv_rec.attribute14;
    p8_a17 := ddx_lsqv_rec.attribute15;
    p8_a18 := ddx_lsqv_rec.reference_number;
    p8_a19 := ddx_lsqv_rec.status;
    p8_a20 := ddx_lsqv_rec.parent_object_code;
    p8_a21 := ddx_lsqv_rec.parent_object_id;
    p8_a22 := ddx_lsqv_rec.valid_from;
    p8_a23 := ddx_lsqv_rec.valid_to;
    p8_a24 := ddx_lsqv_rec.customer_bookclass;
    p8_a25 := ddx_lsqv_rec.customer_taxowner;
    p8_a26 := ddx_lsqv_rec.expected_start_date;
    p8_a27 := ddx_lsqv_rec.expected_funding_date;
    p8_a28 := ddx_lsqv_rec.expected_delivery_date;
    p8_a29 := ddx_lsqv_rec.pricing_method;
    p8_a30 := ddx_lsqv_rec.term;
    p8_a31 := ddx_lsqv_rec.product_id;
    p8_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p8_a33 := ddx_lsqv_rec.structured_pricing;
    p8_a34 := ddx_lsqv_rec.line_level_pricing;
    p8_a35 := ddx_lsqv_rec.rate_template_id;
    p8_a36 := ddx_lsqv_rec.rate_card_id;
    p8_a37 := ddx_lsqv_rec.lease_rate_factor;
    p8_a38 := ddx_lsqv_rec.target_rate_type;
    p8_a39 := ddx_lsqv_rec.target_rate;
    p8_a40 := ddx_lsqv_rec.target_amount;
    p8_a41 := ddx_lsqv_rec.target_frequency;
    p8_a42 := ddx_lsqv_rec.target_arrears_yn;
    p8_a43 := ddx_lsqv_rec.target_periods;
    p8_a44 := ddx_lsqv_rec.iir;
    p8_a45 := ddx_lsqv_rec.booking_yield;
    p8_a46 := ddx_lsqv_rec.pirr;
    p8_a47 := ddx_lsqv_rec.airr;
    p8_a48 := ddx_lsqv_rec.sub_iir;
    p8_a49 := ddx_lsqv_rec.sub_booking_yield;
    p8_a50 := ddx_lsqv_rec.sub_pirr;
    p8_a51 := ddx_lsqv_rec.sub_airr;
    p8_a52 := ddx_lsqv_rec.usage_category;
    p8_a53 := ddx_lsqv_rec.usage_industry_class;
    p8_a54 := ddx_lsqv_rec.usage_industry_code;
    p8_a55 := ddx_lsqv_rec.usage_amount;
    p8_a56 := ddx_lsqv_rec.usage_location_id;
    p8_a57 := ddx_lsqv_rec.property_tax_applicable;
    p8_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p8_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p8_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p8_a61 := ddx_lsqv_rec.transfer_of_title;
    p8_a62 := ddx_lsqv_rec.age_of_equipment;
    p8_a63 := ddx_lsqv_rec.purchase_of_lease;
    p8_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p8_a65 := ddx_lsqv_rec.interest_disclosed;
    p8_a66 := ddx_lsqv_rec.primary_quote;
    p8_a67 := ddx_lsqv_rec.legal_entity_id;
    p8_a68 := ddx_lsqv_rec.line_intended_use;
    p8_a69 := ddx_lsqv_rec.short_description;
    p8_a70 := ddx_lsqv_rec.description;
    p8_a71 := ddx_lsqv_rec.comments;
  end;

  procedure lease_app_upd(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  DATE
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  DATE
    , p7_a27  DATE
    , p7_a28  DATE
    , p7_a29  VARCHAR2
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  DATE
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  NUMBER
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  NUMBER
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  NUMBER
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  NUMBER
    , p8_a40 out nocopy  NUMBER
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  NUMBER
    , p8_a44 out nocopy  NUMBER
    , p8_a45 out nocopy  NUMBER
    , p8_a46 out nocopy  NUMBER
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  NUMBER
    , p8_a50 out nocopy  NUMBER
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  NUMBER
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  VARCHAR2
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  VARCHAR2
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  VARCHAR2
    , p8_a69 out nocopy  VARCHAR2
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    ddp_lsqv_rec.id := p7_a0;
    ddp_lsqv_rec.object_version_number := p7_a1;
    ddp_lsqv_rec.attribute_category := p7_a2;
    ddp_lsqv_rec.attribute1 := p7_a3;
    ddp_lsqv_rec.attribute2 := p7_a4;
    ddp_lsqv_rec.attribute3 := p7_a5;
    ddp_lsqv_rec.attribute4 := p7_a6;
    ddp_lsqv_rec.attribute5 := p7_a7;
    ddp_lsqv_rec.attribute6 := p7_a8;
    ddp_lsqv_rec.attribute7 := p7_a9;
    ddp_lsqv_rec.attribute8 := p7_a10;
    ddp_lsqv_rec.attribute9 := p7_a11;
    ddp_lsqv_rec.attribute10 := p7_a12;
    ddp_lsqv_rec.attribute11 := p7_a13;
    ddp_lsqv_rec.attribute12 := p7_a14;
    ddp_lsqv_rec.attribute13 := p7_a15;
    ddp_lsqv_rec.attribute14 := p7_a16;
    ddp_lsqv_rec.attribute15 := p7_a17;
    ddp_lsqv_rec.reference_number := p7_a18;
    ddp_lsqv_rec.status := p7_a19;
    ddp_lsqv_rec.parent_object_code := p7_a20;
    ddp_lsqv_rec.parent_object_id := p7_a21;
    ddp_lsqv_rec.valid_from := p7_a22;
    ddp_lsqv_rec.valid_to := p7_a23;
    ddp_lsqv_rec.customer_bookclass := p7_a24;
    ddp_lsqv_rec.customer_taxowner := p7_a25;
    ddp_lsqv_rec.expected_start_date := p7_a26;
    ddp_lsqv_rec.expected_funding_date := p7_a27;
    ddp_lsqv_rec.expected_delivery_date := p7_a28;
    ddp_lsqv_rec.pricing_method := p7_a29;
    ddp_lsqv_rec.term := p7_a30;
    ddp_lsqv_rec.product_id := p7_a31;
    ddp_lsqv_rec.end_of_term_option_id := p7_a32;
    ddp_lsqv_rec.structured_pricing := p7_a33;
    ddp_lsqv_rec.line_level_pricing := p7_a34;
    ddp_lsqv_rec.rate_template_id := p7_a35;
    ddp_lsqv_rec.rate_card_id := p7_a36;
    ddp_lsqv_rec.lease_rate_factor := p7_a37;
    ddp_lsqv_rec.target_rate_type := p7_a38;
    ddp_lsqv_rec.target_rate := p7_a39;
    ddp_lsqv_rec.target_amount := p7_a40;
    ddp_lsqv_rec.target_frequency := p7_a41;
    ddp_lsqv_rec.target_arrears_yn := p7_a42;
    ddp_lsqv_rec.target_periods := p7_a43;
    ddp_lsqv_rec.iir := p7_a44;
    ddp_lsqv_rec.booking_yield := p7_a45;
    ddp_lsqv_rec.pirr := p7_a46;
    ddp_lsqv_rec.airr := p7_a47;
    ddp_lsqv_rec.sub_iir := p7_a48;
    ddp_lsqv_rec.sub_booking_yield := p7_a49;
    ddp_lsqv_rec.sub_pirr := p7_a50;
    ddp_lsqv_rec.sub_airr := p7_a51;
    ddp_lsqv_rec.usage_category := p7_a52;
    ddp_lsqv_rec.usage_industry_class := p7_a53;
    ddp_lsqv_rec.usage_industry_code := p7_a54;
    ddp_lsqv_rec.usage_amount := p7_a55;
    ddp_lsqv_rec.usage_location_id := p7_a56;
    ddp_lsqv_rec.property_tax_applicable := p7_a57;
    ddp_lsqv_rec.property_tax_billing_type := p7_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p7_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p7_a60;
    ddp_lsqv_rec.transfer_of_title := p7_a61;
    ddp_lsqv_rec.age_of_equipment := p7_a62;
    ddp_lsqv_rec.purchase_of_lease := p7_a63;
    ddp_lsqv_rec.sale_and_lease_back := p7_a64;
    ddp_lsqv_rec.interest_disclosed := p7_a65;
    ddp_lsqv_rec.primary_quote := p7_a66;
    ddp_lsqv_rec.legal_entity_id := p7_a67;
    ddp_lsqv_rec.line_intended_use := p7_a68;
    ddp_lsqv_rec.short_description := p7_a69;
    ddp_lsqv_rec.description := p7_a70;
    ddp_lsqv_rec.comments := p7_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_upd(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec,
      ddp_lsqv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;


    p8_a0 := ddx_lsqv_rec.id;
    p8_a1 := ddx_lsqv_rec.object_version_number;
    p8_a2 := ddx_lsqv_rec.attribute_category;
    p8_a3 := ddx_lsqv_rec.attribute1;
    p8_a4 := ddx_lsqv_rec.attribute2;
    p8_a5 := ddx_lsqv_rec.attribute3;
    p8_a6 := ddx_lsqv_rec.attribute4;
    p8_a7 := ddx_lsqv_rec.attribute5;
    p8_a8 := ddx_lsqv_rec.attribute6;
    p8_a9 := ddx_lsqv_rec.attribute7;
    p8_a10 := ddx_lsqv_rec.attribute8;
    p8_a11 := ddx_lsqv_rec.attribute9;
    p8_a12 := ddx_lsqv_rec.attribute10;
    p8_a13 := ddx_lsqv_rec.attribute11;
    p8_a14 := ddx_lsqv_rec.attribute12;
    p8_a15 := ddx_lsqv_rec.attribute13;
    p8_a16 := ddx_lsqv_rec.attribute14;
    p8_a17 := ddx_lsqv_rec.attribute15;
    p8_a18 := ddx_lsqv_rec.reference_number;
    p8_a19 := ddx_lsqv_rec.status;
    p8_a20 := ddx_lsqv_rec.parent_object_code;
    p8_a21 := ddx_lsqv_rec.parent_object_id;
    p8_a22 := ddx_lsqv_rec.valid_from;
    p8_a23 := ddx_lsqv_rec.valid_to;
    p8_a24 := ddx_lsqv_rec.customer_bookclass;
    p8_a25 := ddx_lsqv_rec.customer_taxowner;
    p8_a26 := ddx_lsqv_rec.expected_start_date;
    p8_a27 := ddx_lsqv_rec.expected_funding_date;
    p8_a28 := ddx_lsqv_rec.expected_delivery_date;
    p8_a29 := ddx_lsqv_rec.pricing_method;
    p8_a30 := ddx_lsqv_rec.term;
    p8_a31 := ddx_lsqv_rec.product_id;
    p8_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p8_a33 := ddx_lsqv_rec.structured_pricing;
    p8_a34 := ddx_lsqv_rec.line_level_pricing;
    p8_a35 := ddx_lsqv_rec.rate_template_id;
    p8_a36 := ddx_lsqv_rec.rate_card_id;
    p8_a37 := ddx_lsqv_rec.lease_rate_factor;
    p8_a38 := ddx_lsqv_rec.target_rate_type;
    p8_a39 := ddx_lsqv_rec.target_rate;
    p8_a40 := ddx_lsqv_rec.target_amount;
    p8_a41 := ddx_lsqv_rec.target_frequency;
    p8_a42 := ddx_lsqv_rec.target_arrears_yn;
    p8_a43 := ddx_lsqv_rec.target_periods;
    p8_a44 := ddx_lsqv_rec.iir;
    p8_a45 := ddx_lsqv_rec.booking_yield;
    p8_a46 := ddx_lsqv_rec.pirr;
    p8_a47 := ddx_lsqv_rec.airr;
    p8_a48 := ddx_lsqv_rec.sub_iir;
    p8_a49 := ddx_lsqv_rec.sub_booking_yield;
    p8_a50 := ddx_lsqv_rec.sub_pirr;
    p8_a51 := ddx_lsqv_rec.sub_airr;
    p8_a52 := ddx_lsqv_rec.usage_category;
    p8_a53 := ddx_lsqv_rec.usage_industry_class;
    p8_a54 := ddx_lsqv_rec.usage_industry_code;
    p8_a55 := ddx_lsqv_rec.usage_amount;
    p8_a56 := ddx_lsqv_rec.usage_location_id;
    p8_a57 := ddx_lsqv_rec.property_tax_applicable;
    p8_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p8_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p8_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p8_a61 := ddx_lsqv_rec.transfer_of_title;
    p8_a62 := ddx_lsqv_rec.age_of_equipment;
    p8_a63 := ddx_lsqv_rec.purchase_of_lease;
    p8_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p8_a65 := ddx_lsqv_rec.interest_disclosed;
    p8_a66 := ddx_lsqv_rec.primary_quote;
    p8_a67 := ddx_lsqv_rec.legal_entity_id;
    p8_a68 := ddx_lsqv_rec.line_intended_use;
    p8_a69 := ddx_lsqv_rec.short_description;
    p8_a70 := ddx_lsqv_rec.description;
    p8_a71 := ddx_lsqv_rec.comments;
  end;

  procedure lease_app_val(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  NUMBER
    , p6_a22  DATE
    , p6_a23  DATE
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  DATE
    , p6_a27  DATE
    , p6_a28  DATE
    , p6_a29  VARCHAR2
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  VARCHAR2
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  NUMBER
    , p6_a44  NUMBER
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  NUMBER
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  NUMBER
    , p6_a61  VARCHAR2
    , p6_a62  NUMBER
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  NUMBER
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;

    ddp_lsqv_rec.id := p6_a0;
    ddp_lsqv_rec.object_version_number := p6_a1;
    ddp_lsqv_rec.attribute_category := p6_a2;
    ddp_lsqv_rec.attribute1 := p6_a3;
    ddp_lsqv_rec.attribute2 := p6_a4;
    ddp_lsqv_rec.attribute3 := p6_a5;
    ddp_lsqv_rec.attribute4 := p6_a6;
    ddp_lsqv_rec.attribute5 := p6_a7;
    ddp_lsqv_rec.attribute6 := p6_a8;
    ddp_lsqv_rec.attribute7 := p6_a9;
    ddp_lsqv_rec.attribute8 := p6_a10;
    ddp_lsqv_rec.attribute9 := p6_a11;
    ddp_lsqv_rec.attribute10 := p6_a12;
    ddp_lsqv_rec.attribute11 := p6_a13;
    ddp_lsqv_rec.attribute12 := p6_a14;
    ddp_lsqv_rec.attribute13 := p6_a15;
    ddp_lsqv_rec.attribute14 := p6_a16;
    ddp_lsqv_rec.attribute15 := p6_a17;
    ddp_lsqv_rec.reference_number := p6_a18;
    ddp_lsqv_rec.status := p6_a19;
    ddp_lsqv_rec.parent_object_code := p6_a20;
    ddp_lsqv_rec.parent_object_id := p6_a21;
    ddp_lsqv_rec.valid_from := p6_a22;
    ddp_lsqv_rec.valid_to := p6_a23;
    ddp_lsqv_rec.customer_bookclass := p6_a24;
    ddp_lsqv_rec.customer_taxowner := p6_a25;
    ddp_lsqv_rec.expected_start_date := p6_a26;
    ddp_lsqv_rec.expected_funding_date := p6_a27;
    ddp_lsqv_rec.expected_delivery_date := p6_a28;
    ddp_lsqv_rec.pricing_method := p6_a29;
    ddp_lsqv_rec.term := p6_a30;
    ddp_lsqv_rec.product_id := p6_a31;
    ddp_lsqv_rec.end_of_term_option_id := p6_a32;
    ddp_lsqv_rec.structured_pricing := p6_a33;
    ddp_lsqv_rec.line_level_pricing := p6_a34;
    ddp_lsqv_rec.rate_template_id := p6_a35;
    ddp_lsqv_rec.rate_card_id := p6_a36;
    ddp_lsqv_rec.lease_rate_factor := p6_a37;
    ddp_lsqv_rec.target_rate_type := p6_a38;
    ddp_lsqv_rec.target_rate := p6_a39;
    ddp_lsqv_rec.target_amount := p6_a40;
    ddp_lsqv_rec.target_frequency := p6_a41;
    ddp_lsqv_rec.target_arrears_yn := p6_a42;
    ddp_lsqv_rec.target_periods := p6_a43;
    ddp_lsqv_rec.iir := p6_a44;
    ddp_lsqv_rec.booking_yield := p6_a45;
    ddp_lsqv_rec.pirr := p6_a46;
    ddp_lsqv_rec.airr := p6_a47;
    ddp_lsqv_rec.sub_iir := p6_a48;
    ddp_lsqv_rec.sub_booking_yield := p6_a49;
    ddp_lsqv_rec.sub_pirr := p6_a50;
    ddp_lsqv_rec.sub_airr := p6_a51;
    ddp_lsqv_rec.usage_category := p6_a52;
    ddp_lsqv_rec.usage_industry_class := p6_a53;
    ddp_lsqv_rec.usage_industry_code := p6_a54;
    ddp_lsqv_rec.usage_amount := p6_a55;
    ddp_lsqv_rec.usage_location_id := p6_a56;
    ddp_lsqv_rec.property_tax_applicable := p6_a57;
    ddp_lsqv_rec.property_tax_billing_type := p6_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p6_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p6_a60;
    ddp_lsqv_rec.transfer_of_title := p6_a61;
    ddp_lsqv_rec.age_of_equipment := p6_a62;
    ddp_lsqv_rec.purchase_of_lease := p6_a63;
    ddp_lsqv_rec.sale_and_lease_back := p6_a64;
    ddp_lsqv_rec.interest_disclosed := p6_a65;
    ddp_lsqv_rec.primary_quote := p6_a66;
    ddp_lsqv_rec.legal_entity_id := p6_a67;
    ddp_lsqv_rec.line_intended_use := p6_a68;
    ddp_lsqv_rec.short_description := p6_a69;
    ddp_lsqv_rec.description := p6_a70;
    ddp_lsqv_rec.comments := p6_a71;

    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_val(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddp_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure lease_app_accept(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_accept(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure lease_app_withdraw(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_withdraw(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure lease_app_dup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_lap_id  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  DATE
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  DATE
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  NUMBER
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  DATE
    , p8_a23  DATE
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  DATE
    , p8_a27  DATE
    , p8_a28  DATE
    , p8_a29  VARCHAR2
    , p8_a30  NUMBER
    , p8_a31  NUMBER
    , p8_a32  NUMBER
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p8_a39  NUMBER
    , p8_a40  NUMBER
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  NUMBER
    , p8_a44  NUMBER
    , p8_a45  NUMBER
    , p8_a46  NUMBER
    , p8_a47  NUMBER
    , p8_a48  NUMBER
    , p8_a49  NUMBER
    , p8_a50  NUMBER
    , p8_a51  NUMBER
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  NUMBER
    , p8_a56  NUMBER
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p8_a60  NUMBER
    , p8_a61  VARCHAR2
    , p8_a62  NUMBER
    , p8_a63  VARCHAR2
    , p8_a64  VARCHAR2
    , p8_a65  VARCHAR2
    , p8_a66  VARCHAR2
    , p8_a67  NUMBER
    , p8_a68  VARCHAR2
    , p8_a69  VARCHAR2
    , p8_a70  VARCHAR2
    , p8_a71  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  DATE
    , p9_a23 out nocopy  DATE
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  DATE
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  NUMBER
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  VARCHAR2
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  NUMBER
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  NUMBER
    , p9_a48 out nocopy  NUMBER
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  VARCHAR2
    , p9_a55 out nocopy  NUMBER
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  VARCHAR2
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  NUMBER
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  NUMBER
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p_origin  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_lapv_rec.id := p6_a0;
    ddp_lapv_rec.object_version_number := p6_a1;
    ddp_lapv_rec.attribute_category := p6_a2;
    ddp_lapv_rec.attribute1 := p6_a3;
    ddp_lapv_rec.attribute2 := p6_a4;
    ddp_lapv_rec.attribute3 := p6_a5;
    ddp_lapv_rec.attribute4 := p6_a6;
    ddp_lapv_rec.attribute5 := p6_a7;
    ddp_lapv_rec.attribute6 := p6_a8;
    ddp_lapv_rec.attribute7 := p6_a9;
    ddp_lapv_rec.attribute8 := p6_a10;
    ddp_lapv_rec.attribute9 := p6_a11;
    ddp_lapv_rec.attribute10 := p6_a12;
    ddp_lapv_rec.attribute11 := p6_a13;
    ddp_lapv_rec.attribute12 := p6_a14;
    ddp_lapv_rec.attribute13 := p6_a15;
    ddp_lapv_rec.attribute14 := p6_a16;
    ddp_lapv_rec.attribute15 := p6_a17;
    ddp_lapv_rec.reference_number := p6_a18;
    ddp_lapv_rec.application_status := p6_a19;
    ddp_lapv_rec.valid_from := p6_a20;
    ddp_lapv_rec.valid_to := p6_a21;
    ddp_lapv_rec.org_id := p6_a22;
    ddp_lapv_rec.inv_org_id := p6_a23;
    ddp_lapv_rec.prospect_id := p6_a24;
    ddp_lapv_rec.prospect_address_id := p6_a25;
    ddp_lapv_rec.cust_acct_id := p6_a26;
    ddp_lapv_rec.industry_class := p6_a27;
    ddp_lapv_rec.industry_code := p6_a28;
    ddp_lapv_rec.currency_code := p6_a29;
    ddp_lapv_rec.currency_conversion_type := p6_a30;
    ddp_lapv_rec.currency_conversion_rate := p6_a31;
    ddp_lapv_rec.currency_conversion_date := p6_a32;
    ddp_lapv_rec.leaseapp_template_id := p6_a33;
    ddp_lapv_rec.parent_leaseapp_id := p6_a34;
    ddp_lapv_rec.credit_line_id := p6_a35;
    ddp_lapv_rec.program_agreement_id := p6_a36;
    ddp_lapv_rec.master_lease_id := p6_a37;
    ddp_lapv_rec.sales_rep_id := p6_a38;
    ddp_lapv_rec.sales_territory_id := p6_a39;
    ddp_lapv_rec.originating_vendor_id := p6_a40;
    ddp_lapv_rec.lease_opportunity_id := p6_a41;
    ddp_lapv_rec.short_description := p6_a42;
    ddp_lapv_rec.comments := p6_a43;
    ddp_lapv_rec.cr_exp_days := p6_a44;
    ddp_lapv_rec.action := p6_a45;
    ddp_lapv_rec.orig_status := p6_a46;


    ddp_lsqv_rec.id := p8_a0;
    ddp_lsqv_rec.object_version_number := p8_a1;
    ddp_lsqv_rec.attribute_category := p8_a2;
    ddp_lsqv_rec.attribute1 := p8_a3;
    ddp_lsqv_rec.attribute2 := p8_a4;
    ddp_lsqv_rec.attribute3 := p8_a5;
    ddp_lsqv_rec.attribute4 := p8_a6;
    ddp_lsqv_rec.attribute5 := p8_a7;
    ddp_lsqv_rec.attribute6 := p8_a8;
    ddp_lsqv_rec.attribute7 := p8_a9;
    ddp_lsqv_rec.attribute8 := p8_a10;
    ddp_lsqv_rec.attribute9 := p8_a11;
    ddp_lsqv_rec.attribute10 := p8_a12;
    ddp_lsqv_rec.attribute11 := p8_a13;
    ddp_lsqv_rec.attribute12 := p8_a14;
    ddp_lsqv_rec.attribute13 := p8_a15;
    ddp_lsqv_rec.attribute14 := p8_a16;
    ddp_lsqv_rec.attribute15 := p8_a17;
    ddp_lsqv_rec.reference_number := p8_a18;
    ddp_lsqv_rec.status := p8_a19;
    ddp_lsqv_rec.parent_object_code := p8_a20;
    ddp_lsqv_rec.parent_object_id := p8_a21;
    ddp_lsqv_rec.valid_from := p8_a22;
    ddp_lsqv_rec.valid_to := p8_a23;
    ddp_lsqv_rec.customer_bookclass := p8_a24;
    ddp_lsqv_rec.customer_taxowner := p8_a25;
    ddp_lsqv_rec.expected_start_date := p8_a26;
    ddp_lsqv_rec.expected_funding_date := p8_a27;
    ddp_lsqv_rec.expected_delivery_date := p8_a28;
    ddp_lsqv_rec.pricing_method := p8_a29;
    ddp_lsqv_rec.term := p8_a30;
    ddp_lsqv_rec.product_id := p8_a31;
    ddp_lsqv_rec.end_of_term_option_id := p8_a32;
    ddp_lsqv_rec.structured_pricing := p8_a33;
    ddp_lsqv_rec.line_level_pricing := p8_a34;
    ddp_lsqv_rec.rate_template_id := p8_a35;
    ddp_lsqv_rec.rate_card_id := p8_a36;
    ddp_lsqv_rec.lease_rate_factor := p8_a37;
    ddp_lsqv_rec.target_rate_type := p8_a38;
    ddp_lsqv_rec.target_rate := p8_a39;
    ddp_lsqv_rec.target_amount := p8_a40;
    ddp_lsqv_rec.target_frequency := p8_a41;
    ddp_lsqv_rec.target_arrears_yn := p8_a42;
    ddp_lsqv_rec.target_periods := p8_a43;
    ddp_lsqv_rec.iir := p8_a44;
    ddp_lsqv_rec.booking_yield := p8_a45;
    ddp_lsqv_rec.pirr := p8_a46;
    ddp_lsqv_rec.airr := p8_a47;
    ddp_lsqv_rec.sub_iir := p8_a48;
    ddp_lsqv_rec.sub_booking_yield := p8_a49;
    ddp_lsqv_rec.sub_pirr := p8_a50;
    ddp_lsqv_rec.sub_airr := p8_a51;
    ddp_lsqv_rec.usage_category := p8_a52;
    ddp_lsqv_rec.usage_industry_class := p8_a53;
    ddp_lsqv_rec.usage_industry_code := p8_a54;
    ddp_lsqv_rec.usage_amount := p8_a55;
    ddp_lsqv_rec.usage_location_id := p8_a56;
    ddp_lsqv_rec.property_tax_applicable := p8_a57;
    ddp_lsqv_rec.property_tax_billing_type := p8_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p8_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p8_a60;
    ddp_lsqv_rec.transfer_of_title := p8_a61;
    ddp_lsqv_rec.age_of_equipment := p8_a62;
    ddp_lsqv_rec.purchase_of_lease := p8_a63;
    ddp_lsqv_rec.sale_and_lease_back := p8_a64;
    ddp_lsqv_rec.interest_disclosed := p8_a65;
    ddp_lsqv_rec.primary_quote := p8_a66;
    ddp_lsqv_rec.legal_entity_id := p8_a67;
    ddp_lsqv_rec.line_intended_use := p8_a68;
    ddp_lsqv_rec.short_description := p8_a69;
    ddp_lsqv_rec.description := p8_a70;
    ddp_lsqv_rec.comments := p8_a71;



    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_dup(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_lap_id,
      ddp_lapv_rec,
      ddx_lapv_rec,
      ddp_lsqv_rec,
      ddx_lsqv_rec,
      p_origin);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_lapv_rec.id;
    p7_a1 := ddx_lapv_rec.object_version_number;
    p7_a2 := ddx_lapv_rec.attribute_category;
    p7_a3 := ddx_lapv_rec.attribute1;
    p7_a4 := ddx_lapv_rec.attribute2;
    p7_a5 := ddx_lapv_rec.attribute3;
    p7_a6 := ddx_lapv_rec.attribute4;
    p7_a7 := ddx_lapv_rec.attribute5;
    p7_a8 := ddx_lapv_rec.attribute6;
    p7_a9 := ddx_lapv_rec.attribute7;
    p7_a10 := ddx_lapv_rec.attribute8;
    p7_a11 := ddx_lapv_rec.attribute9;
    p7_a12 := ddx_lapv_rec.attribute10;
    p7_a13 := ddx_lapv_rec.attribute11;
    p7_a14 := ddx_lapv_rec.attribute12;
    p7_a15 := ddx_lapv_rec.attribute13;
    p7_a16 := ddx_lapv_rec.attribute14;
    p7_a17 := ddx_lapv_rec.attribute15;
    p7_a18 := ddx_lapv_rec.reference_number;
    p7_a19 := ddx_lapv_rec.application_status;
    p7_a20 := ddx_lapv_rec.valid_from;
    p7_a21 := ddx_lapv_rec.valid_to;
    p7_a22 := ddx_lapv_rec.org_id;
    p7_a23 := ddx_lapv_rec.inv_org_id;
    p7_a24 := ddx_lapv_rec.prospect_id;
    p7_a25 := ddx_lapv_rec.prospect_address_id;
    p7_a26 := ddx_lapv_rec.cust_acct_id;
    p7_a27 := ddx_lapv_rec.industry_class;
    p7_a28 := ddx_lapv_rec.industry_code;
    p7_a29 := ddx_lapv_rec.currency_code;
    p7_a30 := ddx_lapv_rec.currency_conversion_type;
    p7_a31 := ddx_lapv_rec.currency_conversion_rate;
    p7_a32 := ddx_lapv_rec.currency_conversion_date;
    p7_a33 := ddx_lapv_rec.leaseapp_template_id;
    p7_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p7_a35 := ddx_lapv_rec.credit_line_id;
    p7_a36 := ddx_lapv_rec.program_agreement_id;
    p7_a37 := ddx_lapv_rec.master_lease_id;
    p7_a38 := ddx_lapv_rec.sales_rep_id;
    p7_a39 := ddx_lapv_rec.sales_territory_id;
    p7_a40 := ddx_lapv_rec.originating_vendor_id;
    p7_a41 := ddx_lapv_rec.lease_opportunity_id;
    p7_a42 := ddx_lapv_rec.short_description;
    p7_a43 := ddx_lapv_rec.comments;
    p7_a44 := ddx_lapv_rec.cr_exp_days;
    p7_a45 := ddx_lapv_rec.action;
    p7_a46 := ddx_lapv_rec.orig_status;


    p9_a0 := ddx_lsqv_rec.id;
    p9_a1 := ddx_lsqv_rec.object_version_number;
    p9_a2 := ddx_lsqv_rec.attribute_category;
    p9_a3 := ddx_lsqv_rec.attribute1;
    p9_a4 := ddx_lsqv_rec.attribute2;
    p9_a5 := ddx_lsqv_rec.attribute3;
    p9_a6 := ddx_lsqv_rec.attribute4;
    p9_a7 := ddx_lsqv_rec.attribute5;
    p9_a8 := ddx_lsqv_rec.attribute6;
    p9_a9 := ddx_lsqv_rec.attribute7;
    p9_a10 := ddx_lsqv_rec.attribute8;
    p9_a11 := ddx_lsqv_rec.attribute9;
    p9_a12 := ddx_lsqv_rec.attribute10;
    p9_a13 := ddx_lsqv_rec.attribute11;
    p9_a14 := ddx_lsqv_rec.attribute12;
    p9_a15 := ddx_lsqv_rec.attribute13;
    p9_a16 := ddx_lsqv_rec.attribute14;
    p9_a17 := ddx_lsqv_rec.attribute15;
    p9_a18 := ddx_lsqv_rec.reference_number;
    p9_a19 := ddx_lsqv_rec.status;
    p9_a20 := ddx_lsqv_rec.parent_object_code;
    p9_a21 := ddx_lsqv_rec.parent_object_id;
    p9_a22 := ddx_lsqv_rec.valid_from;
    p9_a23 := ddx_lsqv_rec.valid_to;
    p9_a24 := ddx_lsqv_rec.customer_bookclass;
    p9_a25 := ddx_lsqv_rec.customer_taxowner;
    p9_a26 := ddx_lsqv_rec.expected_start_date;
    p9_a27 := ddx_lsqv_rec.expected_funding_date;
    p9_a28 := ddx_lsqv_rec.expected_delivery_date;
    p9_a29 := ddx_lsqv_rec.pricing_method;
    p9_a30 := ddx_lsqv_rec.term;
    p9_a31 := ddx_lsqv_rec.product_id;
    p9_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p9_a33 := ddx_lsqv_rec.structured_pricing;
    p9_a34 := ddx_lsqv_rec.line_level_pricing;
    p9_a35 := ddx_lsqv_rec.rate_template_id;
    p9_a36 := ddx_lsqv_rec.rate_card_id;
    p9_a37 := ddx_lsqv_rec.lease_rate_factor;
    p9_a38 := ddx_lsqv_rec.target_rate_type;
    p9_a39 := ddx_lsqv_rec.target_rate;
    p9_a40 := ddx_lsqv_rec.target_amount;
    p9_a41 := ddx_lsqv_rec.target_frequency;
    p9_a42 := ddx_lsqv_rec.target_arrears_yn;
    p9_a43 := ddx_lsqv_rec.target_periods;
    p9_a44 := ddx_lsqv_rec.iir;
    p9_a45 := ddx_lsqv_rec.booking_yield;
    p9_a46 := ddx_lsqv_rec.pirr;
    p9_a47 := ddx_lsqv_rec.airr;
    p9_a48 := ddx_lsqv_rec.sub_iir;
    p9_a49 := ddx_lsqv_rec.sub_booking_yield;
    p9_a50 := ddx_lsqv_rec.sub_pirr;
    p9_a51 := ddx_lsqv_rec.sub_airr;
    p9_a52 := ddx_lsqv_rec.usage_category;
    p9_a53 := ddx_lsqv_rec.usage_industry_class;
    p9_a54 := ddx_lsqv_rec.usage_industry_code;
    p9_a55 := ddx_lsqv_rec.usage_amount;
    p9_a56 := ddx_lsqv_rec.usage_location_id;
    p9_a57 := ddx_lsqv_rec.property_tax_applicable;
    p9_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p9_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p9_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p9_a61 := ddx_lsqv_rec.transfer_of_title;
    p9_a62 := ddx_lsqv_rec.age_of_equipment;
    p9_a63 := ddx_lsqv_rec.purchase_of_lease;
    p9_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p9_a65 := ddx_lsqv_rec.interest_disclosed;
    p9_a66 := ddx_lsqv_rec.primary_quote;
    p9_a67 := ddx_lsqv_rec.legal_entity_id;
    p9_a68 := ddx_lsqv_rec.line_intended_use;
    p9_a69 := ddx_lsqv_rec.short_description;
    p9_a70 := ddx_lsqv_rec.description;
    p9_a71 := ddx_lsqv_rec.comments;

  end;

  procedure submit_for_pricing(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.submit_for_pricing(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure submit_for_credit(p_api_version  NUMBER
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
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.submit_for_credit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure accept_counter_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lap_id  NUMBER
    , p_cntr_offr  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  DATE
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  NUMBER
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  NUMBER
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  NUMBER
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  NUMBER
    , p8_a40 out nocopy  NUMBER
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  NUMBER
    , p8_a44 out nocopy  NUMBER
    , p8_a45 out nocopy  NUMBER
    , p8_a46 out nocopy  NUMBER
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  NUMBER
    , p8_a50 out nocopy  NUMBER
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  NUMBER
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  VARCHAR2
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  VARCHAR2
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  VARCHAR2
    , p8_a69 out nocopy  VARCHAR2
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  VARCHAR2
  )

  as
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.accept_counter_offer(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lap_id,
      p_cntr_offr,
      ddx_lapv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_lapv_rec.id;
    p7_a1 := ddx_lapv_rec.object_version_number;
    p7_a2 := ddx_lapv_rec.attribute_category;
    p7_a3 := ddx_lapv_rec.attribute1;
    p7_a4 := ddx_lapv_rec.attribute2;
    p7_a5 := ddx_lapv_rec.attribute3;
    p7_a6 := ddx_lapv_rec.attribute4;
    p7_a7 := ddx_lapv_rec.attribute5;
    p7_a8 := ddx_lapv_rec.attribute6;
    p7_a9 := ddx_lapv_rec.attribute7;
    p7_a10 := ddx_lapv_rec.attribute8;
    p7_a11 := ddx_lapv_rec.attribute9;
    p7_a12 := ddx_lapv_rec.attribute10;
    p7_a13 := ddx_lapv_rec.attribute11;
    p7_a14 := ddx_lapv_rec.attribute12;
    p7_a15 := ddx_lapv_rec.attribute13;
    p7_a16 := ddx_lapv_rec.attribute14;
    p7_a17 := ddx_lapv_rec.attribute15;
    p7_a18 := ddx_lapv_rec.reference_number;
    p7_a19 := ddx_lapv_rec.application_status;
    p7_a20 := ddx_lapv_rec.valid_from;
    p7_a21 := ddx_lapv_rec.valid_to;
    p7_a22 := ddx_lapv_rec.org_id;
    p7_a23 := ddx_lapv_rec.inv_org_id;
    p7_a24 := ddx_lapv_rec.prospect_id;
    p7_a25 := ddx_lapv_rec.prospect_address_id;
    p7_a26 := ddx_lapv_rec.cust_acct_id;
    p7_a27 := ddx_lapv_rec.industry_class;
    p7_a28 := ddx_lapv_rec.industry_code;
    p7_a29 := ddx_lapv_rec.currency_code;
    p7_a30 := ddx_lapv_rec.currency_conversion_type;
    p7_a31 := ddx_lapv_rec.currency_conversion_rate;
    p7_a32 := ddx_lapv_rec.currency_conversion_date;
    p7_a33 := ddx_lapv_rec.leaseapp_template_id;
    p7_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p7_a35 := ddx_lapv_rec.credit_line_id;
    p7_a36 := ddx_lapv_rec.program_agreement_id;
    p7_a37 := ddx_lapv_rec.master_lease_id;
    p7_a38 := ddx_lapv_rec.sales_rep_id;
    p7_a39 := ddx_lapv_rec.sales_territory_id;
    p7_a40 := ddx_lapv_rec.originating_vendor_id;
    p7_a41 := ddx_lapv_rec.lease_opportunity_id;
    p7_a42 := ddx_lapv_rec.short_description;
    p7_a43 := ddx_lapv_rec.comments;
    p7_a44 := ddx_lapv_rec.cr_exp_days;
    p7_a45 := ddx_lapv_rec.action;
    p7_a46 := ddx_lapv_rec.orig_status;

    p8_a0 := ddx_lsqv_rec.id;
    p8_a1 := ddx_lsqv_rec.object_version_number;
    p8_a2 := ddx_lsqv_rec.attribute_category;
    p8_a3 := ddx_lsqv_rec.attribute1;
    p8_a4 := ddx_lsqv_rec.attribute2;
    p8_a5 := ddx_lsqv_rec.attribute3;
    p8_a6 := ddx_lsqv_rec.attribute4;
    p8_a7 := ddx_lsqv_rec.attribute5;
    p8_a8 := ddx_lsqv_rec.attribute6;
    p8_a9 := ddx_lsqv_rec.attribute7;
    p8_a10 := ddx_lsqv_rec.attribute8;
    p8_a11 := ddx_lsqv_rec.attribute9;
    p8_a12 := ddx_lsqv_rec.attribute10;
    p8_a13 := ddx_lsqv_rec.attribute11;
    p8_a14 := ddx_lsqv_rec.attribute12;
    p8_a15 := ddx_lsqv_rec.attribute13;
    p8_a16 := ddx_lsqv_rec.attribute14;
    p8_a17 := ddx_lsqv_rec.attribute15;
    p8_a18 := ddx_lsqv_rec.reference_number;
    p8_a19 := ddx_lsqv_rec.status;
    p8_a20 := ddx_lsqv_rec.parent_object_code;
    p8_a21 := ddx_lsqv_rec.parent_object_id;
    p8_a22 := ddx_lsqv_rec.valid_from;
    p8_a23 := ddx_lsqv_rec.valid_to;
    p8_a24 := ddx_lsqv_rec.customer_bookclass;
    p8_a25 := ddx_lsqv_rec.customer_taxowner;
    p8_a26 := ddx_lsqv_rec.expected_start_date;
    p8_a27 := ddx_lsqv_rec.expected_funding_date;
    p8_a28 := ddx_lsqv_rec.expected_delivery_date;
    p8_a29 := ddx_lsqv_rec.pricing_method;
    p8_a30 := ddx_lsqv_rec.term;
    p8_a31 := ddx_lsqv_rec.product_id;
    p8_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p8_a33 := ddx_lsqv_rec.structured_pricing;
    p8_a34 := ddx_lsqv_rec.line_level_pricing;
    p8_a35 := ddx_lsqv_rec.rate_template_id;
    p8_a36 := ddx_lsqv_rec.rate_card_id;
    p8_a37 := ddx_lsqv_rec.lease_rate_factor;
    p8_a38 := ddx_lsqv_rec.target_rate_type;
    p8_a39 := ddx_lsqv_rec.target_rate;
    p8_a40 := ddx_lsqv_rec.target_amount;
    p8_a41 := ddx_lsqv_rec.target_frequency;
    p8_a42 := ddx_lsqv_rec.target_arrears_yn;
    p8_a43 := ddx_lsqv_rec.target_periods;
    p8_a44 := ddx_lsqv_rec.iir;
    p8_a45 := ddx_lsqv_rec.booking_yield;
    p8_a46 := ddx_lsqv_rec.pirr;
    p8_a47 := ddx_lsqv_rec.airr;
    p8_a48 := ddx_lsqv_rec.sub_iir;
    p8_a49 := ddx_lsqv_rec.sub_booking_yield;
    p8_a50 := ddx_lsqv_rec.sub_pirr;
    p8_a51 := ddx_lsqv_rec.sub_airr;
    p8_a52 := ddx_lsqv_rec.usage_category;
    p8_a53 := ddx_lsqv_rec.usage_industry_class;
    p8_a54 := ddx_lsqv_rec.usage_industry_code;
    p8_a55 := ddx_lsqv_rec.usage_amount;
    p8_a56 := ddx_lsqv_rec.usage_location_id;
    p8_a57 := ddx_lsqv_rec.property_tax_applicable;
    p8_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p8_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p8_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p8_a61 := ddx_lsqv_rec.transfer_of_title;
    p8_a62 := ddx_lsqv_rec.age_of_equipment;
    p8_a63 := ddx_lsqv_rec.purchase_of_lease;
    p8_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p8_a65 := ddx_lsqv_rec.interest_disclosed;
    p8_a66 := ddx_lsqv_rec.primary_quote;
    p8_a67 := ddx_lsqv_rec.legal_entity_id;
    p8_a68 := ddx_lsqv_rec.line_intended_use;
    p8_a69 := ddx_lsqv_rec.short_description;
    p8_a70 := ddx_lsqv_rec.description;
    p8_a71 := ddx_lsqv_rec.comments;
  end;

  procedure lease_app_cancel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lease_app_id  NUMBER
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_cancel(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lease_app_id,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure lease_app_resubmit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_lap_id  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  DATE
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  DATE
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  NUMBER
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  DATE
    , p8_a23  DATE
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  DATE
    , p8_a27  DATE
    , p8_a28  DATE
    , p8_a29  VARCHAR2
    , p8_a30  NUMBER
    , p8_a31  NUMBER
    , p8_a32  NUMBER
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p8_a39  NUMBER
    , p8_a40  NUMBER
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  NUMBER
    , p8_a44  NUMBER
    , p8_a45  NUMBER
    , p8_a46  NUMBER
    , p8_a47  NUMBER
    , p8_a48  NUMBER
    , p8_a49  NUMBER
    , p8_a50  NUMBER
    , p8_a51  NUMBER
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  NUMBER
    , p8_a56  NUMBER
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p8_a60  NUMBER
    , p8_a61  VARCHAR2
    , p8_a62  NUMBER
    , p8_a63  VARCHAR2
    , p8_a64  VARCHAR2
    , p8_a65  VARCHAR2
    , p8_a66  VARCHAR2
    , p8_a67  NUMBER
    , p8_a68  VARCHAR2
    , p8_a69  VARCHAR2
    , p8_a70  VARCHAR2
    , p8_a71  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  DATE
    , p9_a23 out nocopy  DATE
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  DATE
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  NUMBER
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  VARCHAR2
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  NUMBER
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  NUMBER
    , p9_a48 out nocopy  NUMBER
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  VARCHAR2
    , p9_a55 out nocopy  NUMBER
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  VARCHAR2
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  NUMBER
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  NUMBER
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_lapv_rec.id := p6_a0;
    ddp_lapv_rec.object_version_number := p6_a1;
    ddp_lapv_rec.attribute_category := p6_a2;
    ddp_lapv_rec.attribute1 := p6_a3;
    ddp_lapv_rec.attribute2 := p6_a4;
    ddp_lapv_rec.attribute3 := p6_a5;
    ddp_lapv_rec.attribute4 := p6_a6;
    ddp_lapv_rec.attribute5 := p6_a7;
    ddp_lapv_rec.attribute6 := p6_a8;
    ddp_lapv_rec.attribute7 := p6_a9;
    ddp_lapv_rec.attribute8 := p6_a10;
    ddp_lapv_rec.attribute9 := p6_a11;
    ddp_lapv_rec.attribute10 := p6_a12;
    ddp_lapv_rec.attribute11 := p6_a13;
    ddp_lapv_rec.attribute12 := p6_a14;
    ddp_lapv_rec.attribute13 := p6_a15;
    ddp_lapv_rec.attribute14 := p6_a16;
    ddp_lapv_rec.attribute15 := p6_a17;
    ddp_lapv_rec.reference_number := p6_a18;
    ddp_lapv_rec.application_status := p6_a19;
    ddp_lapv_rec.valid_from := p6_a20;
    ddp_lapv_rec.valid_to := p6_a21;
    ddp_lapv_rec.org_id := p6_a22;
    ddp_lapv_rec.inv_org_id := p6_a23;
    ddp_lapv_rec.prospect_id := p6_a24;
    ddp_lapv_rec.prospect_address_id := p6_a25;
    ddp_lapv_rec.cust_acct_id := p6_a26;
    ddp_lapv_rec.industry_class := p6_a27;
    ddp_lapv_rec.industry_code := p6_a28;
    ddp_lapv_rec.currency_code := p6_a29;
    ddp_lapv_rec.currency_conversion_type := p6_a30;
    ddp_lapv_rec.currency_conversion_rate := p6_a31;
    ddp_lapv_rec.currency_conversion_date := p6_a32;
    ddp_lapv_rec.leaseapp_template_id := p6_a33;
    ddp_lapv_rec.parent_leaseapp_id := p6_a34;
    ddp_lapv_rec.credit_line_id := p6_a35;
    ddp_lapv_rec.program_agreement_id := p6_a36;
    ddp_lapv_rec.master_lease_id := p6_a37;
    ddp_lapv_rec.sales_rep_id := p6_a38;
    ddp_lapv_rec.sales_territory_id := p6_a39;
    ddp_lapv_rec.originating_vendor_id := p6_a40;
    ddp_lapv_rec.lease_opportunity_id := p6_a41;
    ddp_lapv_rec.short_description := p6_a42;
    ddp_lapv_rec.comments := p6_a43;
    ddp_lapv_rec.cr_exp_days := p6_a44;
    ddp_lapv_rec.action := p6_a45;
    ddp_lapv_rec.orig_status := p6_a46;


    ddp_lsqv_rec.id := p8_a0;
    ddp_lsqv_rec.object_version_number := p8_a1;
    ddp_lsqv_rec.attribute_category := p8_a2;
    ddp_lsqv_rec.attribute1 := p8_a3;
    ddp_lsqv_rec.attribute2 := p8_a4;
    ddp_lsqv_rec.attribute3 := p8_a5;
    ddp_lsqv_rec.attribute4 := p8_a6;
    ddp_lsqv_rec.attribute5 := p8_a7;
    ddp_lsqv_rec.attribute6 := p8_a8;
    ddp_lsqv_rec.attribute7 := p8_a9;
    ddp_lsqv_rec.attribute8 := p8_a10;
    ddp_lsqv_rec.attribute9 := p8_a11;
    ddp_lsqv_rec.attribute10 := p8_a12;
    ddp_lsqv_rec.attribute11 := p8_a13;
    ddp_lsqv_rec.attribute12 := p8_a14;
    ddp_lsqv_rec.attribute13 := p8_a15;
    ddp_lsqv_rec.attribute14 := p8_a16;
    ddp_lsqv_rec.attribute15 := p8_a17;
    ddp_lsqv_rec.reference_number := p8_a18;
    ddp_lsqv_rec.status := p8_a19;
    ddp_lsqv_rec.parent_object_code := p8_a20;
    ddp_lsqv_rec.parent_object_id := p8_a21;
    ddp_lsqv_rec.valid_from := p8_a22;
    ddp_lsqv_rec.valid_to := p8_a23;
    ddp_lsqv_rec.customer_bookclass := p8_a24;
    ddp_lsqv_rec.customer_taxowner := p8_a25;
    ddp_lsqv_rec.expected_start_date := p8_a26;
    ddp_lsqv_rec.expected_funding_date := p8_a27;
    ddp_lsqv_rec.expected_delivery_date := p8_a28;
    ddp_lsqv_rec.pricing_method := p8_a29;
    ddp_lsqv_rec.term := p8_a30;
    ddp_lsqv_rec.product_id := p8_a31;
    ddp_lsqv_rec.end_of_term_option_id := p8_a32;
    ddp_lsqv_rec.structured_pricing := p8_a33;
    ddp_lsqv_rec.line_level_pricing := p8_a34;
    ddp_lsqv_rec.rate_template_id := p8_a35;
    ddp_lsqv_rec.rate_card_id := p8_a36;
    ddp_lsqv_rec.lease_rate_factor := p8_a37;
    ddp_lsqv_rec.target_rate_type := p8_a38;
    ddp_lsqv_rec.target_rate := p8_a39;
    ddp_lsqv_rec.target_amount := p8_a40;
    ddp_lsqv_rec.target_frequency := p8_a41;
    ddp_lsqv_rec.target_arrears_yn := p8_a42;
    ddp_lsqv_rec.target_periods := p8_a43;
    ddp_lsqv_rec.iir := p8_a44;
    ddp_lsqv_rec.booking_yield := p8_a45;
    ddp_lsqv_rec.pirr := p8_a46;
    ddp_lsqv_rec.airr := p8_a47;
    ddp_lsqv_rec.sub_iir := p8_a48;
    ddp_lsqv_rec.sub_booking_yield := p8_a49;
    ddp_lsqv_rec.sub_pirr := p8_a50;
    ddp_lsqv_rec.sub_airr := p8_a51;
    ddp_lsqv_rec.usage_category := p8_a52;
    ddp_lsqv_rec.usage_industry_class := p8_a53;
    ddp_lsqv_rec.usage_industry_code := p8_a54;
    ddp_lsqv_rec.usage_amount := p8_a55;
    ddp_lsqv_rec.usage_location_id := p8_a56;
    ddp_lsqv_rec.property_tax_applicable := p8_a57;
    ddp_lsqv_rec.property_tax_billing_type := p8_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p8_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p8_a60;
    ddp_lsqv_rec.transfer_of_title := p8_a61;
    ddp_lsqv_rec.age_of_equipment := p8_a62;
    ddp_lsqv_rec.purchase_of_lease := p8_a63;
    ddp_lsqv_rec.sale_and_lease_back := p8_a64;
    ddp_lsqv_rec.interest_disclosed := p8_a65;
    ddp_lsqv_rec.primary_quote := p8_a66;
    ddp_lsqv_rec.legal_entity_id := p8_a67;
    ddp_lsqv_rec.line_intended_use := p8_a68;
    ddp_lsqv_rec.short_description := p8_a69;
    ddp_lsqv_rec.description := p8_a70;
    ddp_lsqv_rec.comments := p8_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_resubmit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_lap_id,
      ddp_lapv_rec,
      ddx_lapv_rec,
      ddp_lsqv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_lapv_rec.id;
    p7_a1 := ddx_lapv_rec.object_version_number;
    p7_a2 := ddx_lapv_rec.attribute_category;
    p7_a3 := ddx_lapv_rec.attribute1;
    p7_a4 := ddx_lapv_rec.attribute2;
    p7_a5 := ddx_lapv_rec.attribute3;
    p7_a6 := ddx_lapv_rec.attribute4;
    p7_a7 := ddx_lapv_rec.attribute5;
    p7_a8 := ddx_lapv_rec.attribute6;
    p7_a9 := ddx_lapv_rec.attribute7;
    p7_a10 := ddx_lapv_rec.attribute8;
    p7_a11 := ddx_lapv_rec.attribute9;
    p7_a12 := ddx_lapv_rec.attribute10;
    p7_a13 := ddx_lapv_rec.attribute11;
    p7_a14 := ddx_lapv_rec.attribute12;
    p7_a15 := ddx_lapv_rec.attribute13;
    p7_a16 := ddx_lapv_rec.attribute14;
    p7_a17 := ddx_lapv_rec.attribute15;
    p7_a18 := ddx_lapv_rec.reference_number;
    p7_a19 := ddx_lapv_rec.application_status;
    p7_a20 := ddx_lapv_rec.valid_from;
    p7_a21 := ddx_lapv_rec.valid_to;
    p7_a22 := ddx_lapv_rec.org_id;
    p7_a23 := ddx_lapv_rec.inv_org_id;
    p7_a24 := ddx_lapv_rec.prospect_id;
    p7_a25 := ddx_lapv_rec.prospect_address_id;
    p7_a26 := ddx_lapv_rec.cust_acct_id;
    p7_a27 := ddx_lapv_rec.industry_class;
    p7_a28 := ddx_lapv_rec.industry_code;
    p7_a29 := ddx_lapv_rec.currency_code;
    p7_a30 := ddx_lapv_rec.currency_conversion_type;
    p7_a31 := ddx_lapv_rec.currency_conversion_rate;
    p7_a32 := ddx_lapv_rec.currency_conversion_date;
    p7_a33 := ddx_lapv_rec.leaseapp_template_id;
    p7_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p7_a35 := ddx_lapv_rec.credit_line_id;
    p7_a36 := ddx_lapv_rec.program_agreement_id;
    p7_a37 := ddx_lapv_rec.master_lease_id;
    p7_a38 := ddx_lapv_rec.sales_rep_id;
    p7_a39 := ddx_lapv_rec.sales_territory_id;
    p7_a40 := ddx_lapv_rec.originating_vendor_id;
    p7_a41 := ddx_lapv_rec.lease_opportunity_id;
    p7_a42 := ddx_lapv_rec.short_description;
    p7_a43 := ddx_lapv_rec.comments;
    p7_a44 := ddx_lapv_rec.cr_exp_days;
    p7_a45 := ddx_lapv_rec.action;
    p7_a46 := ddx_lapv_rec.orig_status;


    p9_a0 := ddx_lsqv_rec.id;
    p9_a1 := ddx_lsqv_rec.object_version_number;
    p9_a2 := ddx_lsqv_rec.attribute_category;
    p9_a3 := ddx_lsqv_rec.attribute1;
    p9_a4 := ddx_lsqv_rec.attribute2;
    p9_a5 := ddx_lsqv_rec.attribute3;
    p9_a6 := ddx_lsqv_rec.attribute4;
    p9_a7 := ddx_lsqv_rec.attribute5;
    p9_a8 := ddx_lsqv_rec.attribute6;
    p9_a9 := ddx_lsqv_rec.attribute7;
    p9_a10 := ddx_lsqv_rec.attribute8;
    p9_a11 := ddx_lsqv_rec.attribute9;
    p9_a12 := ddx_lsqv_rec.attribute10;
    p9_a13 := ddx_lsqv_rec.attribute11;
    p9_a14 := ddx_lsqv_rec.attribute12;
    p9_a15 := ddx_lsqv_rec.attribute13;
    p9_a16 := ddx_lsqv_rec.attribute14;
    p9_a17 := ddx_lsqv_rec.attribute15;
    p9_a18 := ddx_lsqv_rec.reference_number;
    p9_a19 := ddx_lsqv_rec.status;
    p9_a20 := ddx_lsqv_rec.parent_object_code;
    p9_a21 := ddx_lsqv_rec.parent_object_id;
    p9_a22 := ddx_lsqv_rec.valid_from;
    p9_a23 := ddx_lsqv_rec.valid_to;
    p9_a24 := ddx_lsqv_rec.customer_bookclass;
    p9_a25 := ddx_lsqv_rec.customer_taxowner;
    p9_a26 := ddx_lsqv_rec.expected_start_date;
    p9_a27 := ddx_lsqv_rec.expected_funding_date;
    p9_a28 := ddx_lsqv_rec.expected_delivery_date;
    p9_a29 := ddx_lsqv_rec.pricing_method;
    p9_a30 := ddx_lsqv_rec.term;
    p9_a31 := ddx_lsqv_rec.product_id;
    p9_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p9_a33 := ddx_lsqv_rec.structured_pricing;
    p9_a34 := ddx_lsqv_rec.line_level_pricing;
    p9_a35 := ddx_lsqv_rec.rate_template_id;
    p9_a36 := ddx_lsqv_rec.rate_card_id;
    p9_a37 := ddx_lsqv_rec.lease_rate_factor;
    p9_a38 := ddx_lsqv_rec.target_rate_type;
    p9_a39 := ddx_lsqv_rec.target_rate;
    p9_a40 := ddx_lsqv_rec.target_amount;
    p9_a41 := ddx_lsqv_rec.target_frequency;
    p9_a42 := ddx_lsqv_rec.target_arrears_yn;
    p9_a43 := ddx_lsqv_rec.target_periods;
    p9_a44 := ddx_lsqv_rec.iir;
    p9_a45 := ddx_lsqv_rec.booking_yield;
    p9_a46 := ddx_lsqv_rec.pirr;
    p9_a47 := ddx_lsqv_rec.airr;
    p9_a48 := ddx_lsqv_rec.sub_iir;
    p9_a49 := ddx_lsqv_rec.sub_booking_yield;
    p9_a50 := ddx_lsqv_rec.sub_pirr;
    p9_a51 := ddx_lsqv_rec.sub_airr;
    p9_a52 := ddx_lsqv_rec.usage_category;
    p9_a53 := ddx_lsqv_rec.usage_industry_class;
    p9_a54 := ddx_lsqv_rec.usage_industry_code;
    p9_a55 := ddx_lsqv_rec.usage_amount;
    p9_a56 := ddx_lsqv_rec.usage_location_id;
    p9_a57 := ddx_lsqv_rec.property_tax_applicable;
    p9_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p9_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p9_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p9_a61 := ddx_lsqv_rec.transfer_of_title;
    p9_a62 := ddx_lsqv_rec.age_of_equipment;
    p9_a63 := ddx_lsqv_rec.purchase_of_lease;
    p9_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p9_a65 := ddx_lsqv_rec.interest_disclosed;
    p9_a66 := ddx_lsqv_rec.primary_quote;
    p9_a67 := ddx_lsqv_rec.legal_entity_id;
    p9_a68 := ddx_lsqv_rec.line_intended_use;
    p9_a69 := ddx_lsqv_rec.short_description;
    p9_a70 := ddx_lsqv_rec.description;
    p9_a71 := ddx_lsqv_rec.comments;
  end;

  procedure lease_app_appeal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_lap_id  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  DATE
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  DATE
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  NUMBER
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  DATE
    , p8_a23  DATE
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  DATE
    , p8_a27  DATE
    , p8_a28  DATE
    , p8_a29  VARCHAR2
    , p8_a30  NUMBER
    , p8_a31  NUMBER
    , p8_a32  NUMBER
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p8_a39  NUMBER
    , p8_a40  NUMBER
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  NUMBER
    , p8_a44  NUMBER
    , p8_a45  NUMBER
    , p8_a46  NUMBER
    , p8_a47  NUMBER
    , p8_a48  NUMBER
    , p8_a49  NUMBER
    , p8_a50  NUMBER
    , p8_a51  NUMBER
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  NUMBER
    , p8_a56  NUMBER
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p8_a60  NUMBER
    , p8_a61  VARCHAR2
    , p8_a62  NUMBER
    , p8_a63  VARCHAR2
    , p8_a64  VARCHAR2
    , p8_a65  VARCHAR2
    , p8_a66  VARCHAR2
    , p8_a67  NUMBER
    , p8_a68  VARCHAR2
    , p8_a69  VARCHAR2
    , p8_a70  VARCHAR2
    , p8_a71  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  DATE
    , p9_a23 out nocopy  DATE
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  DATE
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  NUMBER
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  VARCHAR2
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  NUMBER
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  NUMBER
    , p9_a48 out nocopy  NUMBER
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  VARCHAR2
    , p9_a55 out nocopy  NUMBER
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  VARCHAR2
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  NUMBER
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  NUMBER
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_lapv_rec.id := p6_a0;
    ddp_lapv_rec.object_version_number := p6_a1;
    ddp_lapv_rec.attribute_category := p6_a2;
    ddp_lapv_rec.attribute1 := p6_a3;
    ddp_lapv_rec.attribute2 := p6_a4;
    ddp_lapv_rec.attribute3 := p6_a5;
    ddp_lapv_rec.attribute4 := p6_a6;
    ddp_lapv_rec.attribute5 := p6_a7;
    ddp_lapv_rec.attribute6 := p6_a8;
    ddp_lapv_rec.attribute7 := p6_a9;
    ddp_lapv_rec.attribute8 := p6_a10;
    ddp_lapv_rec.attribute9 := p6_a11;
    ddp_lapv_rec.attribute10 := p6_a12;
    ddp_lapv_rec.attribute11 := p6_a13;
    ddp_lapv_rec.attribute12 := p6_a14;
    ddp_lapv_rec.attribute13 := p6_a15;
    ddp_lapv_rec.attribute14 := p6_a16;
    ddp_lapv_rec.attribute15 := p6_a17;
    ddp_lapv_rec.reference_number := p6_a18;
    ddp_lapv_rec.application_status := p6_a19;
    ddp_lapv_rec.valid_from := p6_a20;
    ddp_lapv_rec.valid_to := p6_a21;
    ddp_lapv_rec.org_id := p6_a22;
    ddp_lapv_rec.inv_org_id := p6_a23;
    ddp_lapv_rec.prospect_id := p6_a24;
    ddp_lapv_rec.prospect_address_id := p6_a25;
    ddp_lapv_rec.cust_acct_id := p6_a26;
    ddp_lapv_rec.industry_class := p6_a27;
    ddp_lapv_rec.industry_code := p6_a28;
    ddp_lapv_rec.currency_code := p6_a29;
    ddp_lapv_rec.currency_conversion_type := p6_a30;
    ddp_lapv_rec.currency_conversion_rate := p6_a31;
    ddp_lapv_rec.currency_conversion_date := p6_a32;
    ddp_lapv_rec.leaseapp_template_id := p6_a33;
    ddp_lapv_rec.parent_leaseapp_id := p6_a34;
    ddp_lapv_rec.credit_line_id := p6_a35;
    ddp_lapv_rec.program_agreement_id := p6_a36;
    ddp_lapv_rec.master_lease_id := p6_a37;
    ddp_lapv_rec.sales_rep_id := p6_a38;
    ddp_lapv_rec.sales_territory_id := p6_a39;
    ddp_lapv_rec.originating_vendor_id := p6_a40;
    ddp_lapv_rec.lease_opportunity_id := p6_a41;
    ddp_lapv_rec.short_description := p6_a42;
    ddp_lapv_rec.comments := p6_a43;
    ddp_lapv_rec.cr_exp_days := p6_a44;
    ddp_lapv_rec.action := p6_a45;
    ddp_lapv_rec.orig_status := p6_a46;


    ddp_lsqv_rec.id := p8_a0;
    ddp_lsqv_rec.object_version_number := p8_a1;
    ddp_lsqv_rec.attribute_category := p8_a2;
    ddp_lsqv_rec.attribute1 := p8_a3;
    ddp_lsqv_rec.attribute2 := p8_a4;
    ddp_lsqv_rec.attribute3 := p8_a5;
    ddp_lsqv_rec.attribute4 := p8_a6;
    ddp_lsqv_rec.attribute5 := p8_a7;
    ddp_lsqv_rec.attribute6 := p8_a8;
    ddp_lsqv_rec.attribute7 := p8_a9;
    ddp_lsqv_rec.attribute8 := p8_a10;
    ddp_lsqv_rec.attribute9 := p8_a11;
    ddp_lsqv_rec.attribute10 := p8_a12;
    ddp_lsqv_rec.attribute11 := p8_a13;
    ddp_lsqv_rec.attribute12 := p8_a14;
    ddp_lsqv_rec.attribute13 := p8_a15;
    ddp_lsqv_rec.attribute14 := p8_a16;
    ddp_lsqv_rec.attribute15 := p8_a17;
    ddp_lsqv_rec.reference_number := p8_a18;
    ddp_lsqv_rec.status := p8_a19;
    ddp_lsqv_rec.parent_object_code := p8_a20;
    ddp_lsqv_rec.parent_object_id := p8_a21;
    ddp_lsqv_rec.valid_from := p8_a22;
    ddp_lsqv_rec.valid_to := p8_a23;
    ddp_lsqv_rec.customer_bookclass := p8_a24;
    ddp_lsqv_rec.customer_taxowner := p8_a25;
    ddp_lsqv_rec.expected_start_date := p8_a26;
    ddp_lsqv_rec.expected_funding_date := p8_a27;
    ddp_lsqv_rec.expected_delivery_date := p8_a28;
    ddp_lsqv_rec.pricing_method := p8_a29;
    ddp_lsqv_rec.term := p8_a30;
    ddp_lsqv_rec.product_id := p8_a31;
    ddp_lsqv_rec.end_of_term_option_id := p8_a32;
    ddp_lsqv_rec.structured_pricing := p8_a33;
    ddp_lsqv_rec.line_level_pricing := p8_a34;
    ddp_lsqv_rec.rate_template_id := p8_a35;
    ddp_lsqv_rec.rate_card_id := p8_a36;
    ddp_lsqv_rec.lease_rate_factor := p8_a37;
    ddp_lsqv_rec.target_rate_type := p8_a38;
    ddp_lsqv_rec.target_rate := p8_a39;
    ddp_lsqv_rec.target_amount := p8_a40;
    ddp_lsqv_rec.target_frequency := p8_a41;
    ddp_lsqv_rec.target_arrears_yn := p8_a42;
    ddp_lsqv_rec.target_periods := p8_a43;
    ddp_lsqv_rec.iir := p8_a44;
    ddp_lsqv_rec.booking_yield := p8_a45;
    ddp_lsqv_rec.pirr := p8_a46;
    ddp_lsqv_rec.airr := p8_a47;
    ddp_lsqv_rec.sub_iir := p8_a48;
    ddp_lsqv_rec.sub_booking_yield := p8_a49;
    ddp_lsqv_rec.sub_pirr := p8_a50;
    ddp_lsqv_rec.sub_airr := p8_a51;
    ddp_lsqv_rec.usage_category := p8_a52;
    ddp_lsqv_rec.usage_industry_class := p8_a53;
    ddp_lsqv_rec.usage_industry_code := p8_a54;
    ddp_lsqv_rec.usage_amount := p8_a55;
    ddp_lsqv_rec.usage_location_id := p8_a56;
    ddp_lsqv_rec.property_tax_applicable := p8_a57;
    ddp_lsqv_rec.property_tax_billing_type := p8_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p8_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p8_a60;
    ddp_lsqv_rec.transfer_of_title := p8_a61;
    ddp_lsqv_rec.age_of_equipment := p8_a62;
    ddp_lsqv_rec.purchase_of_lease := p8_a63;
    ddp_lsqv_rec.sale_and_lease_back := p8_a64;
    ddp_lsqv_rec.interest_disclosed := p8_a65;
    ddp_lsqv_rec.primary_quote := p8_a66;
    ddp_lsqv_rec.legal_entity_id := p8_a67;
    ddp_lsqv_rec.line_intended_use := p8_a68;
    ddp_lsqv_rec.short_description := p8_a69;
    ddp_lsqv_rec.description := p8_a70;
    ddp_lsqv_rec.comments := p8_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.lease_app_appeal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_lap_id,
      ddp_lapv_rec,
      ddx_lapv_rec,
      ddp_lsqv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_lapv_rec.id;
    p7_a1 := ddx_lapv_rec.object_version_number;
    p7_a2 := ddx_lapv_rec.attribute_category;
    p7_a3 := ddx_lapv_rec.attribute1;
    p7_a4 := ddx_lapv_rec.attribute2;
    p7_a5 := ddx_lapv_rec.attribute3;
    p7_a6 := ddx_lapv_rec.attribute4;
    p7_a7 := ddx_lapv_rec.attribute5;
    p7_a8 := ddx_lapv_rec.attribute6;
    p7_a9 := ddx_lapv_rec.attribute7;
    p7_a10 := ddx_lapv_rec.attribute8;
    p7_a11 := ddx_lapv_rec.attribute9;
    p7_a12 := ddx_lapv_rec.attribute10;
    p7_a13 := ddx_lapv_rec.attribute11;
    p7_a14 := ddx_lapv_rec.attribute12;
    p7_a15 := ddx_lapv_rec.attribute13;
    p7_a16 := ddx_lapv_rec.attribute14;
    p7_a17 := ddx_lapv_rec.attribute15;
    p7_a18 := ddx_lapv_rec.reference_number;
    p7_a19 := ddx_lapv_rec.application_status;
    p7_a20 := ddx_lapv_rec.valid_from;
    p7_a21 := ddx_lapv_rec.valid_to;
    p7_a22 := ddx_lapv_rec.org_id;
    p7_a23 := ddx_lapv_rec.inv_org_id;
    p7_a24 := ddx_lapv_rec.prospect_id;
    p7_a25 := ddx_lapv_rec.prospect_address_id;
    p7_a26 := ddx_lapv_rec.cust_acct_id;
    p7_a27 := ddx_lapv_rec.industry_class;
    p7_a28 := ddx_lapv_rec.industry_code;
    p7_a29 := ddx_lapv_rec.currency_code;
    p7_a30 := ddx_lapv_rec.currency_conversion_type;
    p7_a31 := ddx_lapv_rec.currency_conversion_rate;
    p7_a32 := ddx_lapv_rec.currency_conversion_date;
    p7_a33 := ddx_lapv_rec.leaseapp_template_id;
    p7_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p7_a35 := ddx_lapv_rec.credit_line_id;
    p7_a36 := ddx_lapv_rec.program_agreement_id;
    p7_a37 := ddx_lapv_rec.master_lease_id;
    p7_a38 := ddx_lapv_rec.sales_rep_id;
    p7_a39 := ddx_lapv_rec.sales_territory_id;
    p7_a40 := ddx_lapv_rec.originating_vendor_id;
    p7_a41 := ddx_lapv_rec.lease_opportunity_id;
    p7_a42 := ddx_lapv_rec.short_description;
    p7_a43 := ddx_lapv_rec.comments;
    p7_a44 := ddx_lapv_rec.cr_exp_days;
    p7_a45 := ddx_lapv_rec.action;
    p7_a46 := ddx_lapv_rec.orig_status;


    p9_a0 := ddx_lsqv_rec.id;
    p9_a1 := ddx_lsqv_rec.object_version_number;
    p9_a2 := ddx_lsqv_rec.attribute_category;
    p9_a3 := ddx_lsqv_rec.attribute1;
    p9_a4 := ddx_lsqv_rec.attribute2;
    p9_a5 := ddx_lsqv_rec.attribute3;
    p9_a6 := ddx_lsqv_rec.attribute4;
    p9_a7 := ddx_lsqv_rec.attribute5;
    p9_a8 := ddx_lsqv_rec.attribute6;
    p9_a9 := ddx_lsqv_rec.attribute7;
    p9_a10 := ddx_lsqv_rec.attribute8;
    p9_a11 := ddx_lsqv_rec.attribute9;
    p9_a12 := ddx_lsqv_rec.attribute10;
    p9_a13 := ddx_lsqv_rec.attribute11;
    p9_a14 := ddx_lsqv_rec.attribute12;
    p9_a15 := ddx_lsqv_rec.attribute13;
    p9_a16 := ddx_lsqv_rec.attribute14;
    p9_a17 := ddx_lsqv_rec.attribute15;
    p9_a18 := ddx_lsqv_rec.reference_number;
    p9_a19 := ddx_lsqv_rec.status;
    p9_a20 := ddx_lsqv_rec.parent_object_code;
    p9_a21 := ddx_lsqv_rec.parent_object_id;
    p9_a22 := ddx_lsqv_rec.valid_from;
    p9_a23 := ddx_lsqv_rec.valid_to;
    p9_a24 := ddx_lsqv_rec.customer_bookclass;
    p9_a25 := ddx_lsqv_rec.customer_taxowner;
    p9_a26 := ddx_lsqv_rec.expected_start_date;
    p9_a27 := ddx_lsqv_rec.expected_funding_date;
    p9_a28 := ddx_lsqv_rec.expected_delivery_date;
    p9_a29 := ddx_lsqv_rec.pricing_method;
    p9_a30 := ddx_lsqv_rec.term;
    p9_a31 := ddx_lsqv_rec.product_id;
    p9_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p9_a33 := ddx_lsqv_rec.structured_pricing;
    p9_a34 := ddx_lsqv_rec.line_level_pricing;
    p9_a35 := ddx_lsqv_rec.rate_template_id;
    p9_a36 := ddx_lsqv_rec.rate_card_id;
    p9_a37 := ddx_lsqv_rec.lease_rate_factor;
    p9_a38 := ddx_lsqv_rec.target_rate_type;
    p9_a39 := ddx_lsqv_rec.target_rate;
    p9_a40 := ddx_lsqv_rec.target_amount;
    p9_a41 := ddx_lsqv_rec.target_frequency;
    p9_a42 := ddx_lsqv_rec.target_arrears_yn;
    p9_a43 := ddx_lsqv_rec.target_periods;
    p9_a44 := ddx_lsqv_rec.iir;
    p9_a45 := ddx_lsqv_rec.booking_yield;
    p9_a46 := ddx_lsqv_rec.pirr;
    p9_a47 := ddx_lsqv_rec.airr;
    p9_a48 := ddx_lsqv_rec.sub_iir;
    p9_a49 := ddx_lsqv_rec.sub_booking_yield;
    p9_a50 := ddx_lsqv_rec.sub_pirr;
    p9_a51 := ddx_lsqv_rec.sub_airr;
    p9_a52 := ddx_lsqv_rec.usage_category;
    p9_a53 := ddx_lsqv_rec.usage_industry_class;
    p9_a54 := ddx_lsqv_rec.usage_industry_code;
    p9_a55 := ddx_lsqv_rec.usage_amount;
    p9_a56 := ddx_lsqv_rec.usage_location_id;
    p9_a57 := ddx_lsqv_rec.property_tax_applicable;
    p9_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p9_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p9_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p9_a61 := ddx_lsqv_rec.transfer_of_title;
    p9_a62 := ddx_lsqv_rec.age_of_equipment;
    p9_a63 := ddx_lsqv_rec.purchase_of_lease;
    p9_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p9_a65 := ddx_lsqv_rec.interest_disclosed;
    p9_a66 := ddx_lsqv_rec.primary_quote;
    p9_a67 := ddx_lsqv_rec.legal_entity_id;
    p9_a68 := ddx_lsqv_rec.line_intended_use;
    p9_a69 := ddx_lsqv_rec.short_description;
    p9_a70 := ddx_lsqv_rec.description;
    p9_a71 := ddx_lsqv_rec.comments;
  end;

  procedure populate_lease_app(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lap_id  NUMBER
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
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  DATE
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  DATE
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  NUMBER
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  NUMBER
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  NUMBER
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  NUMBER
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  NUMBER
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  NUMBER
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  NUMBER
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
  )

  as
    ddx_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddx_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.populate_lease_app(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lap_id,
      ddx_lapv_rec,
      ddx_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;

    p7_a0 := ddx_lsqv_rec.id;
    p7_a1 := ddx_lsqv_rec.object_version_number;
    p7_a2 := ddx_lsqv_rec.attribute_category;
    p7_a3 := ddx_lsqv_rec.attribute1;
    p7_a4 := ddx_lsqv_rec.attribute2;
    p7_a5 := ddx_lsqv_rec.attribute3;
    p7_a6 := ddx_lsqv_rec.attribute4;
    p7_a7 := ddx_lsqv_rec.attribute5;
    p7_a8 := ddx_lsqv_rec.attribute6;
    p7_a9 := ddx_lsqv_rec.attribute7;
    p7_a10 := ddx_lsqv_rec.attribute8;
    p7_a11 := ddx_lsqv_rec.attribute9;
    p7_a12 := ddx_lsqv_rec.attribute10;
    p7_a13 := ddx_lsqv_rec.attribute11;
    p7_a14 := ddx_lsqv_rec.attribute12;
    p7_a15 := ddx_lsqv_rec.attribute13;
    p7_a16 := ddx_lsqv_rec.attribute14;
    p7_a17 := ddx_lsqv_rec.attribute15;
    p7_a18 := ddx_lsqv_rec.reference_number;
    p7_a19 := ddx_lsqv_rec.status;
    p7_a20 := ddx_lsqv_rec.parent_object_code;
    p7_a21 := ddx_lsqv_rec.parent_object_id;
    p7_a22 := ddx_lsqv_rec.valid_from;
    p7_a23 := ddx_lsqv_rec.valid_to;
    p7_a24 := ddx_lsqv_rec.customer_bookclass;
    p7_a25 := ddx_lsqv_rec.customer_taxowner;
    p7_a26 := ddx_lsqv_rec.expected_start_date;
    p7_a27 := ddx_lsqv_rec.expected_funding_date;
    p7_a28 := ddx_lsqv_rec.expected_delivery_date;
    p7_a29 := ddx_lsqv_rec.pricing_method;
    p7_a30 := ddx_lsqv_rec.term;
    p7_a31 := ddx_lsqv_rec.product_id;
    p7_a32 := ddx_lsqv_rec.end_of_term_option_id;
    p7_a33 := ddx_lsqv_rec.structured_pricing;
    p7_a34 := ddx_lsqv_rec.line_level_pricing;
    p7_a35 := ddx_lsqv_rec.rate_template_id;
    p7_a36 := ddx_lsqv_rec.rate_card_id;
    p7_a37 := ddx_lsqv_rec.lease_rate_factor;
    p7_a38 := ddx_lsqv_rec.target_rate_type;
    p7_a39 := ddx_lsqv_rec.target_rate;
    p7_a40 := ddx_lsqv_rec.target_amount;
    p7_a41 := ddx_lsqv_rec.target_frequency;
    p7_a42 := ddx_lsqv_rec.target_arrears_yn;
    p7_a43 := ddx_lsqv_rec.target_periods;
    p7_a44 := ddx_lsqv_rec.iir;
    p7_a45 := ddx_lsqv_rec.booking_yield;
    p7_a46 := ddx_lsqv_rec.pirr;
    p7_a47 := ddx_lsqv_rec.airr;
    p7_a48 := ddx_lsqv_rec.sub_iir;
    p7_a49 := ddx_lsqv_rec.sub_booking_yield;
    p7_a50 := ddx_lsqv_rec.sub_pirr;
    p7_a51 := ddx_lsqv_rec.sub_airr;
    p7_a52 := ddx_lsqv_rec.usage_category;
    p7_a53 := ddx_lsqv_rec.usage_industry_class;
    p7_a54 := ddx_lsqv_rec.usage_industry_code;
    p7_a55 := ddx_lsqv_rec.usage_amount;
    p7_a56 := ddx_lsqv_rec.usage_location_id;
    p7_a57 := ddx_lsqv_rec.property_tax_applicable;
    p7_a58 := ddx_lsqv_rec.property_tax_billing_type;
    p7_a59 := ddx_lsqv_rec.upfront_tax_treatment;
    p7_a60 := ddx_lsqv_rec.upfront_tax_stream_type;
    p7_a61 := ddx_lsqv_rec.transfer_of_title;
    p7_a62 := ddx_lsqv_rec.age_of_equipment;
    p7_a63 := ddx_lsqv_rec.purchase_of_lease;
    p7_a64 := ddx_lsqv_rec.sale_and_lease_back;
    p7_a65 := ddx_lsqv_rec.interest_disclosed;
    p7_a66 := ddx_lsqv_rec.primary_quote;
    p7_a67 := ddx_lsqv_rec.legal_entity_id;
    p7_a68 := ddx_lsqv_rec.line_intended_use;
    p7_a69 := ddx_lsqv_rec.short_description;
    p7_a70 := ddx_lsqv_rec.description;
    p7_a71 := ddx_lsqv_rec.comments;
  end;

  procedure check_lease_quote_defaults(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_lsq_id  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  DATE
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  DATE
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  NUMBER
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  DATE
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  DATE
    , p7_a27  DATE
    , p7_a28  DATE
    , p7_a29  VARCHAR2
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lease_app_pvt.lapv_rec_type;
    ddp_lsqv_rec okl_lease_app_pvt.lsqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_lapv_rec.id := p6_a0;
    ddp_lapv_rec.object_version_number := p6_a1;
    ddp_lapv_rec.attribute_category := p6_a2;
    ddp_lapv_rec.attribute1 := p6_a3;
    ddp_lapv_rec.attribute2 := p6_a4;
    ddp_lapv_rec.attribute3 := p6_a5;
    ddp_lapv_rec.attribute4 := p6_a6;
    ddp_lapv_rec.attribute5 := p6_a7;
    ddp_lapv_rec.attribute6 := p6_a8;
    ddp_lapv_rec.attribute7 := p6_a9;
    ddp_lapv_rec.attribute8 := p6_a10;
    ddp_lapv_rec.attribute9 := p6_a11;
    ddp_lapv_rec.attribute10 := p6_a12;
    ddp_lapv_rec.attribute11 := p6_a13;
    ddp_lapv_rec.attribute12 := p6_a14;
    ddp_lapv_rec.attribute13 := p6_a15;
    ddp_lapv_rec.attribute14 := p6_a16;
    ddp_lapv_rec.attribute15 := p6_a17;
    ddp_lapv_rec.reference_number := p6_a18;
    ddp_lapv_rec.application_status := p6_a19;
    ddp_lapv_rec.valid_from := p6_a20;
    ddp_lapv_rec.valid_to := p6_a21;
    ddp_lapv_rec.org_id := p6_a22;
    ddp_lapv_rec.inv_org_id := p6_a23;
    ddp_lapv_rec.prospect_id := p6_a24;
    ddp_lapv_rec.prospect_address_id := p6_a25;
    ddp_lapv_rec.cust_acct_id := p6_a26;
    ddp_lapv_rec.industry_class := p6_a27;
    ddp_lapv_rec.industry_code := p6_a28;
    ddp_lapv_rec.currency_code := p6_a29;
    ddp_lapv_rec.currency_conversion_type := p6_a30;
    ddp_lapv_rec.currency_conversion_rate := p6_a31;
    ddp_lapv_rec.currency_conversion_date := p6_a32;
    ddp_lapv_rec.leaseapp_template_id := p6_a33;
    ddp_lapv_rec.parent_leaseapp_id := p6_a34;
    ddp_lapv_rec.credit_line_id := p6_a35;
    ddp_lapv_rec.program_agreement_id := p6_a36;
    ddp_lapv_rec.master_lease_id := p6_a37;
    ddp_lapv_rec.sales_rep_id := p6_a38;
    ddp_lapv_rec.sales_territory_id := p6_a39;
    ddp_lapv_rec.originating_vendor_id := p6_a40;
    ddp_lapv_rec.lease_opportunity_id := p6_a41;
    ddp_lapv_rec.short_description := p6_a42;
    ddp_lapv_rec.comments := p6_a43;
    ddp_lapv_rec.cr_exp_days := p6_a44;
    ddp_lapv_rec.action := p6_a45;
    ddp_lapv_rec.orig_status := p6_a46;

    ddp_lsqv_rec.id := p7_a0;
    ddp_lsqv_rec.object_version_number := p7_a1;
    ddp_lsqv_rec.attribute_category := p7_a2;
    ddp_lsqv_rec.attribute1 := p7_a3;
    ddp_lsqv_rec.attribute2 := p7_a4;
    ddp_lsqv_rec.attribute3 := p7_a5;
    ddp_lsqv_rec.attribute4 := p7_a6;
    ddp_lsqv_rec.attribute5 := p7_a7;
    ddp_lsqv_rec.attribute6 := p7_a8;
    ddp_lsqv_rec.attribute7 := p7_a9;
    ddp_lsqv_rec.attribute8 := p7_a10;
    ddp_lsqv_rec.attribute9 := p7_a11;
    ddp_lsqv_rec.attribute10 := p7_a12;
    ddp_lsqv_rec.attribute11 := p7_a13;
    ddp_lsqv_rec.attribute12 := p7_a14;
    ddp_lsqv_rec.attribute13 := p7_a15;
    ddp_lsqv_rec.attribute14 := p7_a16;
    ddp_lsqv_rec.attribute15 := p7_a17;
    ddp_lsqv_rec.reference_number := p7_a18;
    ddp_lsqv_rec.status := p7_a19;
    ddp_lsqv_rec.parent_object_code := p7_a20;
    ddp_lsqv_rec.parent_object_id := p7_a21;
    ddp_lsqv_rec.valid_from := p7_a22;
    ddp_lsqv_rec.valid_to := p7_a23;
    ddp_lsqv_rec.customer_bookclass := p7_a24;
    ddp_lsqv_rec.customer_taxowner := p7_a25;
    ddp_lsqv_rec.expected_start_date := p7_a26;
    ddp_lsqv_rec.expected_funding_date := p7_a27;
    ddp_lsqv_rec.expected_delivery_date := p7_a28;
    ddp_lsqv_rec.pricing_method := p7_a29;
    ddp_lsqv_rec.term := p7_a30;
    ddp_lsqv_rec.product_id := p7_a31;
    ddp_lsqv_rec.end_of_term_option_id := p7_a32;
    ddp_lsqv_rec.structured_pricing := p7_a33;
    ddp_lsqv_rec.line_level_pricing := p7_a34;
    ddp_lsqv_rec.rate_template_id := p7_a35;
    ddp_lsqv_rec.rate_card_id := p7_a36;
    ddp_lsqv_rec.lease_rate_factor := p7_a37;
    ddp_lsqv_rec.target_rate_type := p7_a38;
    ddp_lsqv_rec.target_rate := p7_a39;
    ddp_lsqv_rec.target_amount := p7_a40;
    ddp_lsqv_rec.target_frequency := p7_a41;
    ddp_lsqv_rec.target_arrears_yn := p7_a42;
    ddp_lsqv_rec.target_periods := p7_a43;
    ddp_lsqv_rec.iir := p7_a44;
    ddp_lsqv_rec.booking_yield := p7_a45;
    ddp_lsqv_rec.pirr := p7_a46;
    ddp_lsqv_rec.airr := p7_a47;
    ddp_lsqv_rec.sub_iir := p7_a48;
    ddp_lsqv_rec.sub_booking_yield := p7_a49;
    ddp_lsqv_rec.sub_pirr := p7_a50;
    ddp_lsqv_rec.sub_airr := p7_a51;
    ddp_lsqv_rec.usage_category := p7_a52;
    ddp_lsqv_rec.usage_industry_class := p7_a53;
    ddp_lsqv_rec.usage_industry_code := p7_a54;
    ddp_lsqv_rec.usage_amount := p7_a55;
    ddp_lsqv_rec.usage_location_id := p7_a56;
    ddp_lsqv_rec.property_tax_applicable := p7_a57;
    ddp_lsqv_rec.property_tax_billing_type := p7_a58;
    ddp_lsqv_rec.upfront_tax_treatment := p7_a59;
    ddp_lsqv_rec.upfront_tax_stream_type := p7_a60;
    ddp_lsqv_rec.transfer_of_title := p7_a61;
    ddp_lsqv_rec.age_of_equipment := p7_a62;
    ddp_lsqv_rec.purchase_of_lease := p7_a63;
    ddp_lsqv_rec.sale_and_lease_back := p7_a64;
    ddp_lsqv_rec.interest_disclosed := p7_a65;
    ddp_lsqv_rec.primary_quote := p7_a66;
    ddp_lsqv_rec.legal_entity_id := p7_a67;
    ddp_lsqv_rec.line_intended_use := p7_a68;
    ddp_lsqv_rec.short_description := p7_a69;
    ddp_lsqv_rec.description := p7_a70;
    ddp_lsqv_rec.comments := p7_a71;

    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.check_lease_quote_defaults(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_lsq_id,
      ddp_lapv_rec,
      ddp_lsqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure appeal_recommendations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_lap_id  NUMBER
    , p_cr_dec_apl_flag  VARCHAR2
    , p_exp_date_apl_flag  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cr_conds okl_lease_app_pvt.name_val_tbl_type;
    ddp_addl_rcmnds okl_lease_app_pvt.name_val_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lease_app_pvt_w.rosetta_table_copy_in_p3(ddp_cr_conds, p5_a0
      , p5_a1
      );

    okl_lease_app_pvt_w.rosetta_table_copy_in_p3(ddp_addl_rcmnds, p6_a0
      , p6_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_app_pvt.appeal_recommendations(p_api_version,
      p_init_msg_list,
      p_lap_id,
      p_cr_dec_apl_flag,
      p_exp_date_apl_flag,
      ddp_cr_conds,
      ddp_addl_rcmnds,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end okl_lease_app_pvt_w;

/
