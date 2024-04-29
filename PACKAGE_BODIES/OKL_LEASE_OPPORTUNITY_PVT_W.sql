--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_OPPORTUNITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_OPPORTUNITY_PVT_W" as
  /* $Header: OKLELOPB.pls 120.5 2007/03/20 22:38:36 rravikir noship $ */
  procedure create_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  DATE
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p_quick_quote_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  DATE
    , p5_a21 out nocopy  DATE
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  NUMBER
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  VARCHAR2
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  NUMBER
    , p5_a30 out nocopy  DATE
    , p5_a31 out nocopy  NUMBER
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  NUMBER
    , p5_a34 out nocopy  NUMBER
    , p5_a35 out nocopy  NUMBER
    , p5_a36 out nocopy  DATE
    , p5_a37 out nocopy  DATE
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  VARCHAR2
    , p5_a40 out nocopy  VARCHAR2
    , p5_a41 out nocopy  NUMBER
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  VARCHAR2
    , p5_a44 out nocopy  VARCHAR2
    , p5_a45 out nocopy  NUMBER
    , p5_a46 out nocopy  NUMBER
    , p5_a47 out nocopy  NUMBER
    , p5_a48 out nocopy  NUMBER
    , p5_a49 out nocopy  VARCHAR2
    , p5_a50 out nocopy  VARCHAR2
    , p5_a51 out nocopy  VARCHAR2
    , p5_a52 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddx_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_lease_opp_rec.id := p3_a0;
    ddp_lease_opp_rec.object_version_number := p3_a1;
    ddp_lease_opp_rec.attribute_category := p3_a2;
    ddp_lease_opp_rec.attribute1 := p3_a3;
    ddp_lease_opp_rec.attribute2 := p3_a4;
    ddp_lease_opp_rec.attribute3 := p3_a5;
    ddp_lease_opp_rec.attribute4 := p3_a6;
    ddp_lease_opp_rec.attribute5 := p3_a7;
    ddp_lease_opp_rec.attribute6 := p3_a8;
    ddp_lease_opp_rec.attribute7 := p3_a9;
    ddp_lease_opp_rec.attribute8 := p3_a10;
    ddp_lease_opp_rec.attribute9 := p3_a11;
    ddp_lease_opp_rec.attribute10 := p3_a12;
    ddp_lease_opp_rec.attribute11 := p3_a13;
    ddp_lease_opp_rec.attribute12 := p3_a14;
    ddp_lease_opp_rec.attribute13 := p3_a15;
    ddp_lease_opp_rec.attribute14 := p3_a16;
    ddp_lease_opp_rec.attribute15 := p3_a17;
    ddp_lease_opp_rec.reference_number := p3_a18;
    ddp_lease_opp_rec.status := p3_a19;
    ddp_lease_opp_rec.valid_from := p3_a20;
    ddp_lease_opp_rec.expected_start_date := p3_a21;
    ddp_lease_opp_rec.org_id := p3_a22;
    ddp_lease_opp_rec.inv_org_id := p3_a23;
    ddp_lease_opp_rec.prospect_id := p3_a24;
    ddp_lease_opp_rec.prospect_address_id := p3_a25;
    ddp_lease_opp_rec.cust_acct_id := p3_a26;
    ddp_lease_opp_rec.currency_code := p3_a27;
    ddp_lease_opp_rec.currency_conversion_type := p3_a28;
    ddp_lease_opp_rec.currency_conversion_rate := p3_a29;
    ddp_lease_opp_rec.currency_conversion_date := p3_a30;
    ddp_lease_opp_rec.program_agreement_id := p3_a31;
    ddp_lease_opp_rec.master_lease_id := p3_a32;
    ddp_lease_opp_rec.sales_rep_id := p3_a33;
    ddp_lease_opp_rec.sales_territory_id := p3_a34;
    ddp_lease_opp_rec.supplier_id := p3_a35;
    ddp_lease_opp_rec.delivery_date := p3_a36;
    ddp_lease_opp_rec.funding_date := p3_a37;
    ddp_lease_opp_rec.property_tax_applicable := p3_a38;
    ddp_lease_opp_rec.property_tax_billing_type := p3_a39;
    ddp_lease_opp_rec.upfront_tax_treatment := p3_a40;
    ddp_lease_opp_rec.install_site_id := p3_a41;
    ddp_lease_opp_rec.usage_category := p3_a42;
    ddp_lease_opp_rec.usage_industry_class := p3_a43;
    ddp_lease_opp_rec.usage_industry_code := p3_a44;
    ddp_lease_opp_rec.usage_amount := p3_a45;
    ddp_lease_opp_rec.usage_location_id := p3_a46;
    ddp_lease_opp_rec.originating_vendor_id := p3_a47;
    ddp_lease_opp_rec.legal_entity_id := p3_a48;
    ddp_lease_opp_rec.line_intended_use := p3_a49;
    ddp_lease_opp_rec.short_description := p3_a50;
    ddp_lease_opp_rec.description := p3_a51;
    ddp_lease_opp_rec.comments := p3_a52;






    -- here's the delegated call to the old PL/SQL routine
    okl_lease_opportunity_pvt.create_lease_opp(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_lease_opp_rec,
      p_quick_quote_id,
      ddx_lease_opp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_lease_opp_rec.id;
    p5_a1 := ddx_lease_opp_rec.object_version_number;
    p5_a2 := ddx_lease_opp_rec.attribute_category;
    p5_a3 := ddx_lease_opp_rec.attribute1;
    p5_a4 := ddx_lease_opp_rec.attribute2;
    p5_a5 := ddx_lease_opp_rec.attribute3;
    p5_a6 := ddx_lease_opp_rec.attribute4;
    p5_a7 := ddx_lease_opp_rec.attribute5;
    p5_a8 := ddx_lease_opp_rec.attribute6;
    p5_a9 := ddx_lease_opp_rec.attribute7;
    p5_a10 := ddx_lease_opp_rec.attribute8;
    p5_a11 := ddx_lease_opp_rec.attribute9;
    p5_a12 := ddx_lease_opp_rec.attribute10;
    p5_a13 := ddx_lease_opp_rec.attribute11;
    p5_a14 := ddx_lease_opp_rec.attribute12;
    p5_a15 := ddx_lease_opp_rec.attribute13;
    p5_a16 := ddx_lease_opp_rec.attribute14;
    p5_a17 := ddx_lease_opp_rec.attribute15;
    p5_a18 := ddx_lease_opp_rec.reference_number;
    p5_a19 := ddx_lease_opp_rec.status;
    p5_a20 := ddx_lease_opp_rec.valid_from;
    p5_a21 := ddx_lease_opp_rec.expected_start_date;
    p5_a22 := ddx_lease_opp_rec.org_id;
    p5_a23 := ddx_lease_opp_rec.inv_org_id;
    p5_a24 := ddx_lease_opp_rec.prospect_id;
    p5_a25 := ddx_lease_opp_rec.prospect_address_id;
    p5_a26 := ddx_lease_opp_rec.cust_acct_id;
    p5_a27 := ddx_lease_opp_rec.currency_code;
    p5_a28 := ddx_lease_opp_rec.currency_conversion_type;
    p5_a29 := ddx_lease_opp_rec.currency_conversion_rate;
    p5_a30 := ddx_lease_opp_rec.currency_conversion_date;
    p5_a31 := ddx_lease_opp_rec.program_agreement_id;
    p5_a32 := ddx_lease_opp_rec.master_lease_id;
    p5_a33 := ddx_lease_opp_rec.sales_rep_id;
    p5_a34 := ddx_lease_opp_rec.sales_territory_id;
    p5_a35 := ddx_lease_opp_rec.supplier_id;
    p5_a36 := ddx_lease_opp_rec.delivery_date;
    p5_a37 := ddx_lease_opp_rec.funding_date;
    p5_a38 := ddx_lease_opp_rec.property_tax_applicable;
    p5_a39 := ddx_lease_opp_rec.property_tax_billing_type;
    p5_a40 := ddx_lease_opp_rec.upfront_tax_treatment;
    p5_a41 := ddx_lease_opp_rec.install_site_id;
    p5_a42 := ddx_lease_opp_rec.usage_category;
    p5_a43 := ddx_lease_opp_rec.usage_industry_class;
    p5_a44 := ddx_lease_opp_rec.usage_industry_code;
    p5_a45 := ddx_lease_opp_rec.usage_amount;
    p5_a46 := ddx_lease_opp_rec.usage_location_id;
    p5_a47 := ddx_lease_opp_rec.originating_vendor_id;
    p5_a48 := ddx_lease_opp_rec.legal_entity_id;
    p5_a49 := ddx_lease_opp_rec.line_intended_use;
    p5_a50 := ddx_lease_opp_rec.short_description;
    p5_a51 := ddx_lease_opp_rec.description;
    p5_a52 := ddx_lease_opp_rec.comments;



  end;

  procedure update_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  DATE
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p4_a11 out nocopy  VARCHAR2
    , p4_a12 out nocopy  VARCHAR2
    , p4_a13 out nocopy  VARCHAR2
    , p4_a14 out nocopy  VARCHAR2
    , p4_a15 out nocopy  VARCHAR2
    , p4_a16 out nocopy  VARCHAR2
    , p4_a17 out nocopy  VARCHAR2
    , p4_a18 out nocopy  VARCHAR2
    , p4_a19 out nocopy  VARCHAR2
    , p4_a20 out nocopy  DATE
    , p4_a21 out nocopy  DATE
    , p4_a22 out nocopy  NUMBER
    , p4_a23 out nocopy  NUMBER
    , p4_a24 out nocopy  NUMBER
    , p4_a25 out nocopy  NUMBER
    , p4_a26 out nocopy  NUMBER
    , p4_a27 out nocopy  VARCHAR2
    , p4_a28 out nocopy  VARCHAR2
    , p4_a29 out nocopy  NUMBER
    , p4_a30 out nocopy  DATE
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  NUMBER
    , p4_a34 out nocopy  NUMBER
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  DATE
    , p4_a37 out nocopy  DATE
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  VARCHAR2
    , p4_a40 out nocopy  VARCHAR2
    , p4_a41 out nocopy  NUMBER
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  VARCHAR2
    , p4_a44 out nocopy  VARCHAR2
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  VARCHAR2
    , p4_a50 out nocopy  VARCHAR2
    , p4_a51 out nocopy  VARCHAR2
    , p4_a52 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddx_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_lease_opp_rec.id := p3_a0;
    ddp_lease_opp_rec.object_version_number := p3_a1;
    ddp_lease_opp_rec.attribute_category := p3_a2;
    ddp_lease_opp_rec.attribute1 := p3_a3;
    ddp_lease_opp_rec.attribute2 := p3_a4;
    ddp_lease_opp_rec.attribute3 := p3_a5;
    ddp_lease_opp_rec.attribute4 := p3_a6;
    ddp_lease_opp_rec.attribute5 := p3_a7;
    ddp_lease_opp_rec.attribute6 := p3_a8;
    ddp_lease_opp_rec.attribute7 := p3_a9;
    ddp_lease_opp_rec.attribute8 := p3_a10;
    ddp_lease_opp_rec.attribute9 := p3_a11;
    ddp_lease_opp_rec.attribute10 := p3_a12;
    ddp_lease_opp_rec.attribute11 := p3_a13;
    ddp_lease_opp_rec.attribute12 := p3_a14;
    ddp_lease_opp_rec.attribute13 := p3_a15;
    ddp_lease_opp_rec.attribute14 := p3_a16;
    ddp_lease_opp_rec.attribute15 := p3_a17;
    ddp_lease_opp_rec.reference_number := p3_a18;
    ddp_lease_opp_rec.status := p3_a19;
    ddp_lease_opp_rec.valid_from := p3_a20;
    ddp_lease_opp_rec.expected_start_date := p3_a21;
    ddp_lease_opp_rec.org_id := p3_a22;
    ddp_lease_opp_rec.inv_org_id := p3_a23;
    ddp_lease_opp_rec.prospect_id := p3_a24;
    ddp_lease_opp_rec.prospect_address_id := p3_a25;
    ddp_lease_opp_rec.cust_acct_id := p3_a26;
    ddp_lease_opp_rec.currency_code := p3_a27;
    ddp_lease_opp_rec.currency_conversion_type := p3_a28;
    ddp_lease_opp_rec.currency_conversion_rate := p3_a29;
    ddp_lease_opp_rec.currency_conversion_date := p3_a30;
    ddp_lease_opp_rec.program_agreement_id := p3_a31;
    ddp_lease_opp_rec.master_lease_id := p3_a32;
    ddp_lease_opp_rec.sales_rep_id := p3_a33;
    ddp_lease_opp_rec.sales_territory_id := p3_a34;
    ddp_lease_opp_rec.supplier_id := p3_a35;
    ddp_lease_opp_rec.delivery_date := p3_a36;
    ddp_lease_opp_rec.funding_date := p3_a37;
    ddp_lease_opp_rec.property_tax_applicable := p3_a38;
    ddp_lease_opp_rec.property_tax_billing_type := p3_a39;
    ddp_lease_opp_rec.upfront_tax_treatment := p3_a40;
    ddp_lease_opp_rec.install_site_id := p3_a41;
    ddp_lease_opp_rec.usage_category := p3_a42;
    ddp_lease_opp_rec.usage_industry_class := p3_a43;
    ddp_lease_opp_rec.usage_industry_code := p3_a44;
    ddp_lease_opp_rec.usage_amount := p3_a45;
    ddp_lease_opp_rec.usage_location_id := p3_a46;
    ddp_lease_opp_rec.originating_vendor_id := p3_a47;
    ddp_lease_opp_rec.legal_entity_id := p3_a48;
    ddp_lease_opp_rec.line_intended_use := p3_a49;
    ddp_lease_opp_rec.short_description := p3_a50;
    ddp_lease_opp_rec.description := p3_a51;
    ddp_lease_opp_rec.comments := p3_a52;





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_opportunity_pvt.update_lease_opp(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_lease_opp_rec,
      ddx_lease_opp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddx_lease_opp_rec.id;
    p4_a1 := ddx_lease_opp_rec.object_version_number;
    p4_a2 := ddx_lease_opp_rec.attribute_category;
    p4_a3 := ddx_lease_opp_rec.attribute1;
    p4_a4 := ddx_lease_opp_rec.attribute2;
    p4_a5 := ddx_lease_opp_rec.attribute3;
    p4_a6 := ddx_lease_opp_rec.attribute4;
    p4_a7 := ddx_lease_opp_rec.attribute5;
    p4_a8 := ddx_lease_opp_rec.attribute6;
    p4_a9 := ddx_lease_opp_rec.attribute7;
    p4_a10 := ddx_lease_opp_rec.attribute8;
    p4_a11 := ddx_lease_opp_rec.attribute9;
    p4_a12 := ddx_lease_opp_rec.attribute10;
    p4_a13 := ddx_lease_opp_rec.attribute11;
    p4_a14 := ddx_lease_opp_rec.attribute12;
    p4_a15 := ddx_lease_opp_rec.attribute13;
    p4_a16 := ddx_lease_opp_rec.attribute14;
    p4_a17 := ddx_lease_opp_rec.attribute15;
    p4_a18 := ddx_lease_opp_rec.reference_number;
    p4_a19 := ddx_lease_opp_rec.status;
    p4_a20 := ddx_lease_opp_rec.valid_from;
    p4_a21 := ddx_lease_opp_rec.expected_start_date;
    p4_a22 := ddx_lease_opp_rec.org_id;
    p4_a23 := ddx_lease_opp_rec.inv_org_id;
    p4_a24 := ddx_lease_opp_rec.prospect_id;
    p4_a25 := ddx_lease_opp_rec.prospect_address_id;
    p4_a26 := ddx_lease_opp_rec.cust_acct_id;
    p4_a27 := ddx_lease_opp_rec.currency_code;
    p4_a28 := ddx_lease_opp_rec.currency_conversion_type;
    p4_a29 := ddx_lease_opp_rec.currency_conversion_rate;
    p4_a30 := ddx_lease_opp_rec.currency_conversion_date;
    p4_a31 := ddx_lease_opp_rec.program_agreement_id;
    p4_a32 := ddx_lease_opp_rec.master_lease_id;
    p4_a33 := ddx_lease_opp_rec.sales_rep_id;
    p4_a34 := ddx_lease_opp_rec.sales_territory_id;
    p4_a35 := ddx_lease_opp_rec.supplier_id;
    p4_a36 := ddx_lease_opp_rec.delivery_date;
    p4_a37 := ddx_lease_opp_rec.funding_date;
    p4_a38 := ddx_lease_opp_rec.property_tax_applicable;
    p4_a39 := ddx_lease_opp_rec.property_tax_billing_type;
    p4_a40 := ddx_lease_opp_rec.upfront_tax_treatment;
    p4_a41 := ddx_lease_opp_rec.install_site_id;
    p4_a42 := ddx_lease_opp_rec.usage_category;
    p4_a43 := ddx_lease_opp_rec.usage_industry_class;
    p4_a44 := ddx_lease_opp_rec.usage_industry_code;
    p4_a45 := ddx_lease_opp_rec.usage_amount;
    p4_a46 := ddx_lease_opp_rec.usage_location_id;
    p4_a47 := ddx_lease_opp_rec.originating_vendor_id;
    p4_a48 := ddx_lease_opp_rec.legal_entity_id;
    p4_a49 := ddx_lease_opp_rec.line_intended_use;
    p4_a50 := ddx_lease_opp_rec.short_description;
    p4_a51 := ddx_lease_opp_rec.description;
    p4_a52 := ddx_lease_opp_rec.comments;



  end;

  procedure defaults_for_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  DATE
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p_user_id  VARCHAR2
    , x_sales_rep_name out nocopy  VARCHAR2
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
    , x_dff_name out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddx_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_lease_opp_rec.id := p3_a0;
    ddp_lease_opp_rec.object_version_number := p3_a1;
    ddp_lease_opp_rec.attribute_category := p3_a2;
    ddp_lease_opp_rec.attribute1 := p3_a3;
    ddp_lease_opp_rec.attribute2 := p3_a4;
    ddp_lease_opp_rec.attribute3 := p3_a5;
    ddp_lease_opp_rec.attribute4 := p3_a6;
    ddp_lease_opp_rec.attribute5 := p3_a7;
    ddp_lease_opp_rec.attribute6 := p3_a8;
    ddp_lease_opp_rec.attribute7 := p3_a9;
    ddp_lease_opp_rec.attribute8 := p3_a10;
    ddp_lease_opp_rec.attribute9 := p3_a11;
    ddp_lease_opp_rec.attribute10 := p3_a12;
    ddp_lease_opp_rec.attribute11 := p3_a13;
    ddp_lease_opp_rec.attribute12 := p3_a14;
    ddp_lease_opp_rec.attribute13 := p3_a15;
    ddp_lease_opp_rec.attribute14 := p3_a16;
    ddp_lease_opp_rec.attribute15 := p3_a17;
    ddp_lease_opp_rec.reference_number := p3_a18;
    ddp_lease_opp_rec.status := p3_a19;
    ddp_lease_opp_rec.valid_from := p3_a20;
    ddp_lease_opp_rec.expected_start_date := p3_a21;
    ddp_lease_opp_rec.org_id := p3_a22;
    ddp_lease_opp_rec.inv_org_id := p3_a23;
    ddp_lease_opp_rec.prospect_id := p3_a24;
    ddp_lease_opp_rec.prospect_address_id := p3_a25;
    ddp_lease_opp_rec.cust_acct_id := p3_a26;
    ddp_lease_opp_rec.currency_code := p3_a27;
    ddp_lease_opp_rec.currency_conversion_type := p3_a28;
    ddp_lease_opp_rec.currency_conversion_rate := p3_a29;
    ddp_lease_opp_rec.currency_conversion_date := p3_a30;
    ddp_lease_opp_rec.program_agreement_id := p3_a31;
    ddp_lease_opp_rec.master_lease_id := p3_a32;
    ddp_lease_opp_rec.sales_rep_id := p3_a33;
    ddp_lease_opp_rec.sales_territory_id := p3_a34;
    ddp_lease_opp_rec.supplier_id := p3_a35;
    ddp_lease_opp_rec.delivery_date := p3_a36;
    ddp_lease_opp_rec.funding_date := p3_a37;
    ddp_lease_opp_rec.property_tax_applicable := p3_a38;
    ddp_lease_opp_rec.property_tax_billing_type := p3_a39;
    ddp_lease_opp_rec.upfront_tax_treatment := p3_a40;
    ddp_lease_opp_rec.install_site_id := p3_a41;
    ddp_lease_opp_rec.usage_category := p3_a42;
    ddp_lease_opp_rec.usage_industry_class := p3_a43;
    ddp_lease_opp_rec.usage_industry_code := p3_a44;
    ddp_lease_opp_rec.usage_amount := p3_a45;
    ddp_lease_opp_rec.usage_location_id := p3_a46;
    ddp_lease_opp_rec.originating_vendor_id := p3_a47;
    ddp_lease_opp_rec.legal_entity_id := p3_a48;
    ddp_lease_opp_rec.line_intended_use := p3_a49;
    ddp_lease_opp_rec.short_description := p3_a50;
    ddp_lease_opp_rec.description := p3_a51;
    ddp_lease_opp_rec.comments := p3_a52;








    -- here's the delegated call to the old PL/SQL routine
    okl_lease_opportunity_pvt.defaults_for_lease_opp(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_lease_opp_rec,
      p_user_id,
      x_sales_rep_name,
      ddx_lease_opp_rec,
      x_dff_name,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lease_opp_rec.id;
    p6_a1 := ddx_lease_opp_rec.object_version_number;
    p6_a2 := ddx_lease_opp_rec.attribute_category;
    p6_a3 := ddx_lease_opp_rec.attribute1;
    p6_a4 := ddx_lease_opp_rec.attribute2;
    p6_a5 := ddx_lease_opp_rec.attribute3;
    p6_a6 := ddx_lease_opp_rec.attribute4;
    p6_a7 := ddx_lease_opp_rec.attribute5;
    p6_a8 := ddx_lease_opp_rec.attribute6;
    p6_a9 := ddx_lease_opp_rec.attribute7;
    p6_a10 := ddx_lease_opp_rec.attribute8;
    p6_a11 := ddx_lease_opp_rec.attribute9;
    p6_a12 := ddx_lease_opp_rec.attribute10;
    p6_a13 := ddx_lease_opp_rec.attribute11;
    p6_a14 := ddx_lease_opp_rec.attribute12;
    p6_a15 := ddx_lease_opp_rec.attribute13;
    p6_a16 := ddx_lease_opp_rec.attribute14;
    p6_a17 := ddx_lease_opp_rec.attribute15;
    p6_a18 := ddx_lease_opp_rec.reference_number;
    p6_a19 := ddx_lease_opp_rec.status;
    p6_a20 := ddx_lease_opp_rec.valid_from;
    p6_a21 := ddx_lease_opp_rec.expected_start_date;
    p6_a22 := ddx_lease_opp_rec.org_id;
    p6_a23 := ddx_lease_opp_rec.inv_org_id;
    p6_a24 := ddx_lease_opp_rec.prospect_id;
    p6_a25 := ddx_lease_opp_rec.prospect_address_id;
    p6_a26 := ddx_lease_opp_rec.cust_acct_id;
    p6_a27 := ddx_lease_opp_rec.currency_code;
    p6_a28 := ddx_lease_opp_rec.currency_conversion_type;
    p6_a29 := ddx_lease_opp_rec.currency_conversion_rate;
    p6_a30 := ddx_lease_opp_rec.currency_conversion_date;
    p6_a31 := ddx_lease_opp_rec.program_agreement_id;
    p6_a32 := ddx_lease_opp_rec.master_lease_id;
    p6_a33 := ddx_lease_opp_rec.sales_rep_id;
    p6_a34 := ddx_lease_opp_rec.sales_territory_id;
    p6_a35 := ddx_lease_opp_rec.supplier_id;
    p6_a36 := ddx_lease_opp_rec.delivery_date;
    p6_a37 := ddx_lease_opp_rec.funding_date;
    p6_a38 := ddx_lease_opp_rec.property_tax_applicable;
    p6_a39 := ddx_lease_opp_rec.property_tax_billing_type;
    p6_a40 := ddx_lease_opp_rec.upfront_tax_treatment;
    p6_a41 := ddx_lease_opp_rec.install_site_id;
    p6_a42 := ddx_lease_opp_rec.usage_category;
    p6_a43 := ddx_lease_opp_rec.usage_industry_class;
    p6_a44 := ddx_lease_opp_rec.usage_industry_code;
    p6_a45 := ddx_lease_opp_rec.usage_amount;
    p6_a46 := ddx_lease_opp_rec.usage_location_id;
    p6_a47 := ddx_lease_opp_rec.originating_vendor_id;
    p6_a48 := ddx_lease_opp_rec.legal_entity_id;
    p6_a49 := ddx_lease_opp_rec.line_intended_use;
    p6_a50 := ddx_lease_opp_rec.short_description;
    p6_a51 := ddx_lease_opp_rec.description;
    p6_a52 := ddx_lease_opp_rec.comments;




  end;

  procedure duplicate_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_leaseopp_id  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  DATE
    , p4_a21  DATE
    , p4_a22  NUMBER
    , p4_a23  NUMBER
    , p4_a24  NUMBER
    , p4_a25  NUMBER
    , p4_a26  NUMBER
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  NUMBER
    , p4_a30  DATE
    , p4_a31  NUMBER
    , p4_a32  NUMBER
    , p4_a33  NUMBER
    , p4_a34  NUMBER
    , p4_a35  NUMBER
    , p4_a36  DATE
    , p4_a37  DATE
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  NUMBER
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  NUMBER
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  DATE
    , p5_a21 out nocopy  DATE
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  NUMBER
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  VARCHAR2
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  NUMBER
    , p5_a30 out nocopy  DATE
    , p5_a31 out nocopy  NUMBER
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  NUMBER
    , p5_a34 out nocopy  NUMBER
    , p5_a35 out nocopy  NUMBER
    , p5_a36 out nocopy  DATE
    , p5_a37 out nocopy  DATE
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  VARCHAR2
    , p5_a40 out nocopy  VARCHAR2
    , p5_a41 out nocopy  NUMBER
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  VARCHAR2
    , p5_a44 out nocopy  VARCHAR2
    , p5_a45 out nocopy  NUMBER
    , p5_a46 out nocopy  NUMBER
    , p5_a47 out nocopy  NUMBER
    , p5_a48 out nocopy  NUMBER
    , p5_a49 out nocopy  VARCHAR2
    , p5_a50 out nocopy  VARCHAR2
    , p5_a51 out nocopy  VARCHAR2
    , p5_a52 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddx_lease_opp_rec okl_lease_opportunity_pvt.lease_opp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_lease_opp_rec.id := p4_a0;
    ddp_lease_opp_rec.object_version_number := p4_a1;
    ddp_lease_opp_rec.attribute_category := p4_a2;
    ddp_lease_opp_rec.attribute1 := p4_a3;
    ddp_lease_opp_rec.attribute2 := p4_a4;
    ddp_lease_opp_rec.attribute3 := p4_a5;
    ddp_lease_opp_rec.attribute4 := p4_a6;
    ddp_lease_opp_rec.attribute5 := p4_a7;
    ddp_lease_opp_rec.attribute6 := p4_a8;
    ddp_lease_opp_rec.attribute7 := p4_a9;
    ddp_lease_opp_rec.attribute8 := p4_a10;
    ddp_lease_opp_rec.attribute9 := p4_a11;
    ddp_lease_opp_rec.attribute10 := p4_a12;
    ddp_lease_opp_rec.attribute11 := p4_a13;
    ddp_lease_opp_rec.attribute12 := p4_a14;
    ddp_lease_opp_rec.attribute13 := p4_a15;
    ddp_lease_opp_rec.attribute14 := p4_a16;
    ddp_lease_opp_rec.attribute15 := p4_a17;
    ddp_lease_opp_rec.reference_number := p4_a18;
    ddp_lease_opp_rec.status := p4_a19;
    ddp_lease_opp_rec.valid_from := p4_a20;
    ddp_lease_opp_rec.expected_start_date := p4_a21;
    ddp_lease_opp_rec.org_id := p4_a22;
    ddp_lease_opp_rec.inv_org_id := p4_a23;
    ddp_lease_opp_rec.prospect_id := p4_a24;
    ddp_lease_opp_rec.prospect_address_id := p4_a25;
    ddp_lease_opp_rec.cust_acct_id := p4_a26;
    ddp_lease_opp_rec.currency_code := p4_a27;
    ddp_lease_opp_rec.currency_conversion_type := p4_a28;
    ddp_lease_opp_rec.currency_conversion_rate := p4_a29;
    ddp_lease_opp_rec.currency_conversion_date := p4_a30;
    ddp_lease_opp_rec.program_agreement_id := p4_a31;
    ddp_lease_opp_rec.master_lease_id := p4_a32;
    ddp_lease_opp_rec.sales_rep_id := p4_a33;
    ddp_lease_opp_rec.sales_territory_id := p4_a34;
    ddp_lease_opp_rec.supplier_id := p4_a35;
    ddp_lease_opp_rec.delivery_date := p4_a36;
    ddp_lease_opp_rec.funding_date := p4_a37;
    ddp_lease_opp_rec.property_tax_applicable := p4_a38;
    ddp_lease_opp_rec.property_tax_billing_type := p4_a39;
    ddp_lease_opp_rec.upfront_tax_treatment := p4_a40;
    ddp_lease_opp_rec.install_site_id := p4_a41;
    ddp_lease_opp_rec.usage_category := p4_a42;
    ddp_lease_opp_rec.usage_industry_class := p4_a43;
    ddp_lease_opp_rec.usage_industry_code := p4_a44;
    ddp_lease_opp_rec.usage_amount := p4_a45;
    ddp_lease_opp_rec.usage_location_id := p4_a46;
    ddp_lease_opp_rec.originating_vendor_id := p4_a47;
    ddp_lease_opp_rec.legal_entity_id := p4_a48;
    ddp_lease_opp_rec.line_intended_use := p4_a49;
    ddp_lease_opp_rec.short_description := p4_a50;
    ddp_lease_opp_rec.description := p4_a51;
    ddp_lease_opp_rec.comments := p4_a52;





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_opportunity_pvt.duplicate_lease_opp(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      p_source_leaseopp_id,
      ddp_lease_opp_rec,
      ddx_lease_opp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_lease_opp_rec.id;
    p5_a1 := ddx_lease_opp_rec.object_version_number;
    p5_a2 := ddx_lease_opp_rec.attribute_category;
    p5_a3 := ddx_lease_opp_rec.attribute1;
    p5_a4 := ddx_lease_opp_rec.attribute2;
    p5_a5 := ddx_lease_opp_rec.attribute3;
    p5_a6 := ddx_lease_opp_rec.attribute4;
    p5_a7 := ddx_lease_opp_rec.attribute5;
    p5_a8 := ddx_lease_opp_rec.attribute6;
    p5_a9 := ddx_lease_opp_rec.attribute7;
    p5_a10 := ddx_lease_opp_rec.attribute8;
    p5_a11 := ddx_lease_opp_rec.attribute9;
    p5_a12 := ddx_lease_opp_rec.attribute10;
    p5_a13 := ddx_lease_opp_rec.attribute11;
    p5_a14 := ddx_lease_opp_rec.attribute12;
    p5_a15 := ddx_lease_opp_rec.attribute13;
    p5_a16 := ddx_lease_opp_rec.attribute14;
    p5_a17 := ddx_lease_opp_rec.attribute15;
    p5_a18 := ddx_lease_opp_rec.reference_number;
    p5_a19 := ddx_lease_opp_rec.status;
    p5_a20 := ddx_lease_opp_rec.valid_from;
    p5_a21 := ddx_lease_opp_rec.expected_start_date;
    p5_a22 := ddx_lease_opp_rec.org_id;
    p5_a23 := ddx_lease_opp_rec.inv_org_id;
    p5_a24 := ddx_lease_opp_rec.prospect_id;
    p5_a25 := ddx_lease_opp_rec.prospect_address_id;
    p5_a26 := ddx_lease_opp_rec.cust_acct_id;
    p5_a27 := ddx_lease_opp_rec.currency_code;
    p5_a28 := ddx_lease_opp_rec.currency_conversion_type;
    p5_a29 := ddx_lease_opp_rec.currency_conversion_rate;
    p5_a30 := ddx_lease_opp_rec.currency_conversion_date;
    p5_a31 := ddx_lease_opp_rec.program_agreement_id;
    p5_a32 := ddx_lease_opp_rec.master_lease_id;
    p5_a33 := ddx_lease_opp_rec.sales_rep_id;
    p5_a34 := ddx_lease_opp_rec.sales_territory_id;
    p5_a35 := ddx_lease_opp_rec.supplier_id;
    p5_a36 := ddx_lease_opp_rec.delivery_date;
    p5_a37 := ddx_lease_opp_rec.funding_date;
    p5_a38 := ddx_lease_opp_rec.property_tax_applicable;
    p5_a39 := ddx_lease_opp_rec.property_tax_billing_type;
    p5_a40 := ddx_lease_opp_rec.upfront_tax_treatment;
    p5_a41 := ddx_lease_opp_rec.install_site_id;
    p5_a42 := ddx_lease_opp_rec.usage_category;
    p5_a43 := ddx_lease_opp_rec.usage_industry_class;
    p5_a44 := ddx_lease_opp_rec.usage_industry_code;
    p5_a45 := ddx_lease_opp_rec.usage_amount;
    p5_a46 := ddx_lease_opp_rec.usage_location_id;
    p5_a47 := ddx_lease_opp_rec.originating_vendor_id;
    p5_a48 := ddx_lease_opp_rec.legal_entity_id;
    p5_a49 := ddx_lease_opp_rec.line_intended_use;
    p5_a50 := ddx_lease_opp_rec.short_description;
    p5_a51 := ddx_lease_opp_rec.description;
    p5_a52 := ddx_lease_opp_rec.comments;



  end;

end okl_lease_opportunity_pvt_w;

/
