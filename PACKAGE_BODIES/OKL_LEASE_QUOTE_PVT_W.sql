--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_PVT_W" as
  /* $Header: OKLELSQB.pls 120.7 2007/08/08 21:09:32 rravikir noship $ */
  procedure create_lease_qte(p_api_version  NUMBER
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
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  DATE
    , p3_a23  DATE
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  DATE
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  VARCHAR2
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  NUMBER
    , p3_a38  VARCHAR2
    , p3_a39  NUMBER
    , p3_a40  NUMBER
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  NUMBER
    , p3_a44  NUMBER
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  NUMBER
    , p3_a56  NUMBER
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  NUMBER
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
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
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  NUMBER
    , p4_a22 out nocopy  DATE
    , p4_a23 out nocopy  DATE
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  DATE
    , p4_a27 out nocopy  DATE
    , p4_a28 out nocopy  DATE
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , p4_a34 out nocopy  VARCHAR2
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  NUMBER
    , p4_a37 out nocopy  NUMBER
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  NUMBER
    , p4_a40 out nocopy  NUMBER
    , p4_a41 out nocopy  VARCHAR2
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  NUMBER
    , p4_a44 out nocopy  NUMBER
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  NUMBER
    , p4_a50 out nocopy  NUMBER
    , p4_a51 out nocopy  NUMBER
    , p4_a52 out nocopy  VARCHAR2
    , p4_a53 out nocopy  VARCHAR2
    , p4_a54 out nocopy  VARCHAR2
    , p4_a55 out nocopy  NUMBER
    , p4_a56 out nocopy  NUMBER
    , p4_a57 out nocopy  VARCHAR2
    , p4_a58 out nocopy  VARCHAR2
    , p4_a59 out nocopy  VARCHAR2
    , p4_a60 out nocopy  NUMBER
    , p4_a61 out nocopy  VARCHAR2
    , p4_a62 out nocopy  NUMBER
    , p4_a63 out nocopy  VARCHAR2
    , p4_a64 out nocopy  VARCHAR2
    , p4_a65 out nocopy  VARCHAR2
    , p4_a66 out nocopy  VARCHAR2
    , p4_a67 out nocopy  NUMBER
    , p4_a68 out nocopy  VARCHAR2
    , p4_a69 out nocopy  VARCHAR2
    , p4_a70 out nocopy  VARCHAR2
    , p4_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddx_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_lease_qte_rec.id := p3_a0;
    ddp_lease_qte_rec.object_version_number := p3_a1;
    ddp_lease_qte_rec.attribute_category := p3_a2;
    ddp_lease_qte_rec.attribute1 := p3_a3;
    ddp_lease_qte_rec.attribute2 := p3_a4;
    ddp_lease_qte_rec.attribute3 := p3_a5;
    ddp_lease_qte_rec.attribute4 := p3_a6;
    ddp_lease_qte_rec.attribute5 := p3_a7;
    ddp_lease_qte_rec.attribute6 := p3_a8;
    ddp_lease_qte_rec.attribute7 := p3_a9;
    ddp_lease_qte_rec.attribute8 := p3_a10;
    ddp_lease_qte_rec.attribute9 := p3_a11;
    ddp_lease_qte_rec.attribute10 := p3_a12;
    ddp_lease_qte_rec.attribute11 := p3_a13;
    ddp_lease_qte_rec.attribute12 := p3_a14;
    ddp_lease_qte_rec.attribute13 := p3_a15;
    ddp_lease_qte_rec.attribute14 := p3_a16;
    ddp_lease_qte_rec.attribute15 := p3_a17;
    ddp_lease_qte_rec.reference_number := p3_a18;
    ddp_lease_qte_rec.status := p3_a19;
    ddp_lease_qte_rec.parent_object_code := p3_a20;
    ddp_lease_qte_rec.parent_object_id := p3_a21;
    ddp_lease_qte_rec.valid_from := p3_a22;
    ddp_lease_qte_rec.valid_to := p3_a23;
    ddp_lease_qte_rec.customer_bookclass := p3_a24;
    ddp_lease_qte_rec.customer_taxowner := p3_a25;
    ddp_lease_qte_rec.expected_start_date := p3_a26;
    ddp_lease_qte_rec.expected_funding_date := p3_a27;
    ddp_lease_qte_rec.expected_delivery_date := p3_a28;
    ddp_lease_qte_rec.pricing_method := p3_a29;
    ddp_lease_qte_rec.term := p3_a30;
    ddp_lease_qte_rec.product_id := p3_a31;
    ddp_lease_qte_rec.end_of_term_option_id := p3_a32;
    ddp_lease_qte_rec.structured_pricing := p3_a33;
    ddp_lease_qte_rec.line_level_pricing := p3_a34;
    ddp_lease_qte_rec.rate_template_id := p3_a35;
    ddp_lease_qte_rec.rate_card_id := p3_a36;
    ddp_lease_qte_rec.lease_rate_factor := p3_a37;
    ddp_lease_qte_rec.target_rate_type := p3_a38;
    ddp_lease_qte_rec.target_rate := p3_a39;
    ddp_lease_qte_rec.target_amount := p3_a40;
    ddp_lease_qte_rec.target_frequency := p3_a41;
    ddp_lease_qte_rec.target_arrears_yn := p3_a42;
    ddp_lease_qte_rec.target_periods := p3_a43;
    ddp_lease_qte_rec.iir := p3_a44;
    ddp_lease_qte_rec.booking_yield := p3_a45;
    ddp_lease_qte_rec.pirr := p3_a46;
    ddp_lease_qte_rec.airr := p3_a47;
    ddp_lease_qte_rec.sub_iir := p3_a48;
    ddp_lease_qte_rec.sub_booking_yield := p3_a49;
    ddp_lease_qte_rec.sub_pirr := p3_a50;
    ddp_lease_qte_rec.sub_airr := p3_a51;
    ddp_lease_qte_rec.usage_category := p3_a52;
    ddp_lease_qte_rec.usage_industry_class := p3_a53;
    ddp_lease_qte_rec.usage_industry_code := p3_a54;
    ddp_lease_qte_rec.usage_amount := p3_a55;
    ddp_lease_qte_rec.usage_location_id := p3_a56;
    ddp_lease_qte_rec.property_tax_applicable := p3_a57;
    ddp_lease_qte_rec.property_tax_billing_type := p3_a58;
    ddp_lease_qte_rec.upfront_tax_treatment := p3_a59;
    ddp_lease_qte_rec.upfront_tax_stream_type := p3_a60;
    ddp_lease_qte_rec.transfer_of_title := p3_a61;
    ddp_lease_qte_rec.age_of_equipment := p3_a62;
    ddp_lease_qte_rec.purchase_of_lease := p3_a63;
    ddp_lease_qte_rec.sale_and_lease_back := p3_a64;
    ddp_lease_qte_rec.interest_disclosed := p3_a65;
    ddp_lease_qte_rec.primary_quote := p3_a66;
    ddp_lease_qte_rec.legal_entity_id := p3_a67;
    ddp_lease_qte_rec.line_intended_use := p3_a68;
    ddp_lease_qte_rec.short_description := p3_a69;
    ddp_lease_qte_rec.description := p3_a70;
    ddp_lease_qte_rec.comments := p3_a71;





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pvt.create_lease_qte(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_lease_qte_rec,
      ddx_lease_qte_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddx_lease_qte_rec.id;
    p4_a1 := ddx_lease_qte_rec.object_version_number;
    p4_a2 := ddx_lease_qte_rec.attribute_category;
    p4_a3 := ddx_lease_qte_rec.attribute1;
    p4_a4 := ddx_lease_qte_rec.attribute2;
    p4_a5 := ddx_lease_qte_rec.attribute3;
    p4_a6 := ddx_lease_qte_rec.attribute4;
    p4_a7 := ddx_lease_qte_rec.attribute5;
    p4_a8 := ddx_lease_qte_rec.attribute6;
    p4_a9 := ddx_lease_qte_rec.attribute7;
    p4_a10 := ddx_lease_qte_rec.attribute8;
    p4_a11 := ddx_lease_qte_rec.attribute9;
    p4_a12 := ddx_lease_qte_rec.attribute10;
    p4_a13 := ddx_lease_qte_rec.attribute11;
    p4_a14 := ddx_lease_qte_rec.attribute12;
    p4_a15 := ddx_lease_qte_rec.attribute13;
    p4_a16 := ddx_lease_qte_rec.attribute14;
    p4_a17 := ddx_lease_qte_rec.attribute15;
    p4_a18 := ddx_lease_qte_rec.reference_number;
    p4_a19 := ddx_lease_qte_rec.status;
    p4_a20 := ddx_lease_qte_rec.parent_object_code;
    p4_a21 := ddx_lease_qte_rec.parent_object_id;
    p4_a22 := ddx_lease_qte_rec.valid_from;
    p4_a23 := ddx_lease_qte_rec.valid_to;
    p4_a24 := ddx_lease_qte_rec.customer_bookclass;
    p4_a25 := ddx_lease_qte_rec.customer_taxowner;
    p4_a26 := ddx_lease_qte_rec.expected_start_date;
    p4_a27 := ddx_lease_qte_rec.expected_funding_date;
    p4_a28 := ddx_lease_qte_rec.expected_delivery_date;
    p4_a29 := ddx_lease_qte_rec.pricing_method;
    p4_a30 := ddx_lease_qte_rec.term;
    p4_a31 := ddx_lease_qte_rec.product_id;
    p4_a32 := ddx_lease_qte_rec.end_of_term_option_id;
    p4_a33 := ddx_lease_qte_rec.structured_pricing;
    p4_a34 := ddx_lease_qte_rec.line_level_pricing;
    p4_a35 := ddx_lease_qte_rec.rate_template_id;
    p4_a36 := ddx_lease_qte_rec.rate_card_id;
    p4_a37 := ddx_lease_qte_rec.lease_rate_factor;
    p4_a38 := ddx_lease_qte_rec.target_rate_type;
    p4_a39 := ddx_lease_qte_rec.target_rate;
    p4_a40 := ddx_lease_qte_rec.target_amount;
    p4_a41 := ddx_lease_qte_rec.target_frequency;
    p4_a42 := ddx_lease_qte_rec.target_arrears_yn;
    p4_a43 := ddx_lease_qte_rec.target_periods;
    p4_a44 := ddx_lease_qte_rec.iir;
    p4_a45 := ddx_lease_qte_rec.booking_yield;
    p4_a46 := ddx_lease_qte_rec.pirr;
    p4_a47 := ddx_lease_qte_rec.airr;
    p4_a48 := ddx_lease_qte_rec.sub_iir;
    p4_a49 := ddx_lease_qte_rec.sub_booking_yield;
    p4_a50 := ddx_lease_qte_rec.sub_pirr;
    p4_a51 := ddx_lease_qte_rec.sub_airr;
    p4_a52 := ddx_lease_qte_rec.usage_category;
    p4_a53 := ddx_lease_qte_rec.usage_industry_class;
    p4_a54 := ddx_lease_qte_rec.usage_industry_code;
    p4_a55 := ddx_lease_qte_rec.usage_amount;
    p4_a56 := ddx_lease_qte_rec.usage_location_id;
    p4_a57 := ddx_lease_qte_rec.property_tax_applicable;
    p4_a58 := ddx_lease_qte_rec.property_tax_billing_type;
    p4_a59 := ddx_lease_qte_rec.upfront_tax_treatment;
    p4_a60 := ddx_lease_qte_rec.upfront_tax_stream_type;
    p4_a61 := ddx_lease_qte_rec.transfer_of_title;
    p4_a62 := ddx_lease_qte_rec.age_of_equipment;
    p4_a63 := ddx_lease_qte_rec.purchase_of_lease;
    p4_a64 := ddx_lease_qte_rec.sale_and_lease_back;
    p4_a65 := ddx_lease_qte_rec.interest_disclosed;
    p4_a66 := ddx_lease_qte_rec.primary_quote;
    p4_a67 := ddx_lease_qte_rec.legal_entity_id;
    p4_a68 := ddx_lease_qte_rec.line_intended_use;
    p4_a69 := ddx_lease_qte_rec.short_description;
    p4_a70 := ddx_lease_qte_rec.description;
    p4_a71 := ddx_lease_qte_rec.comments;



  end;

  procedure update_lease_qte(p_api_version  NUMBER
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
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  DATE
    , p3_a23  DATE
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  DATE
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  VARCHAR2
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  NUMBER
    , p3_a38  VARCHAR2
    , p3_a39  NUMBER
    , p3_a40  NUMBER
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  NUMBER
    , p3_a44  NUMBER
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  NUMBER
    , p3_a56  NUMBER
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  NUMBER
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
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
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  NUMBER
    , p4_a22 out nocopy  DATE
    , p4_a23 out nocopy  DATE
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  DATE
    , p4_a27 out nocopy  DATE
    , p4_a28 out nocopy  DATE
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , p4_a34 out nocopy  VARCHAR2
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  NUMBER
    , p4_a37 out nocopy  NUMBER
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  NUMBER
    , p4_a40 out nocopy  NUMBER
    , p4_a41 out nocopy  VARCHAR2
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  NUMBER
    , p4_a44 out nocopy  NUMBER
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  NUMBER
    , p4_a50 out nocopy  NUMBER
    , p4_a51 out nocopy  NUMBER
    , p4_a52 out nocopy  VARCHAR2
    , p4_a53 out nocopy  VARCHAR2
    , p4_a54 out nocopy  VARCHAR2
    , p4_a55 out nocopy  NUMBER
    , p4_a56 out nocopy  NUMBER
    , p4_a57 out nocopy  VARCHAR2
    , p4_a58 out nocopy  VARCHAR2
    , p4_a59 out nocopy  VARCHAR2
    , p4_a60 out nocopy  NUMBER
    , p4_a61 out nocopy  VARCHAR2
    , p4_a62 out nocopy  NUMBER
    , p4_a63 out nocopy  VARCHAR2
    , p4_a64 out nocopy  VARCHAR2
    , p4_a65 out nocopy  VARCHAR2
    , p4_a66 out nocopy  VARCHAR2
    , p4_a67 out nocopy  NUMBER
    , p4_a68 out nocopy  VARCHAR2
    , p4_a69 out nocopy  VARCHAR2
    , p4_a70 out nocopy  VARCHAR2
    , p4_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddx_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_lease_qte_rec.id := p3_a0;
    ddp_lease_qte_rec.object_version_number := p3_a1;
    ddp_lease_qte_rec.attribute_category := p3_a2;
    ddp_lease_qte_rec.attribute1 := p3_a3;
    ddp_lease_qte_rec.attribute2 := p3_a4;
    ddp_lease_qte_rec.attribute3 := p3_a5;
    ddp_lease_qte_rec.attribute4 := p3_a6;
    ddp_lease_qte_rec.attribute5 := p3_a7;
    ddp_lease_qte_rec.attribute6 := p3_a8;
    ddp_lease_qte_rec.attribute7 := p3_a9;
    ddp_lease_qte_rec.attribute8 := p3_a10;
    ddp_lease_qte_rec.attribute9 := p3_a11;
    ddp_lease_qte_rec.attribute10 := p3_a12;
    ddp_lease_qte_rec.attribute11 := p3_a13;
    ddp_lease_qte_rec.attribute12 := p3_a14;
    ddp_lease_qte_rec.attribute13 := p3_a15;
    ddp_lease_qte_rec.attribute14 := p3_a16;
    ddp_lease_qte_rec.attribute15 := p3_a17;
    ddp_lease_qte_rec.reference_number := p3_a18;
    ddp_lease_qte_rec.status := p3_a19;
    ddp_lease_qte_rec.parent_object_code := p3_a20;
    ddp_lease_qte_rec.parent_object_id := p3_a21;
    ddp_lease_qte_rec.valid_from := p3_a22;
    ddp_lease_qte_rec.valid_to := p3_a23;
    ddp_lease_qte_rec.customer_bookclass := p3_a24;
    ddp_lease_qte_rec.customer_taxowner := p3_a25;
    ddp_lease_qte_rec.expected_start_date := p3_a26;
    ddp_lease_qte_rec.expected_funding_date := p3_a27;
    ddp_lease_qte_rec.expected_delivery_date := p3_a28;
    ddp_lease_qte_rec.pricing_method := p3_a29;
    ddp_lease_qte_rec.term := p3_a30;
    ddp_lease_qte_rec.product_id := p3_a31;
    ddp_lease_qte_rec.end_of_term_option_id := p3_a32;
    ddp_lease_qte_rec.structured_pricing := p3_a33;
    ddp_lease_qte_rec.line_level_pricing := p3_a34;
    ddp_lease_qte_rec.rate_template_id := p3_a35;
    ddp_lease_qte_rec.rate_card_id := p3_a36;
    ddp_lease_qte_rec.lease_rate_factor := p3_a37;
    ddp_lease_qte_rec.target_rate_type := p3_a38;
    ddp_lease_qte_rec.target_rate := p3_a39;
    ddp_lease_qte_rec.target_amount := p3_a40;
    ddp_lease_qte_rec.target_frequency := p3_a41;
    ddp_lease_qte_rec.target_arrears_yn := p3_a42;
    ddp_lease_qte_rec.target_periods := p3_a43;
    ddp_lease_qte_rec.iir := p3_a44;
    ddp_lease_qte_rec.booking_yield := p3_a45;
    ddp_lease_qte_rec.pirr := p3_a46;
    ddp_lease_qte_rec.airr := p3_a47;
    ddp_lease_qte_rec.sub_iir := p3_a48;
    ddp_lease_qte_rec.sub_booking_yield := p3_a49;
    ddp_lease_qte_rec.sub_pirr := p3_a50;
    ddp_lease_qte_rec.sub_airr := p3_a51;
    ddp_lease_qte_rec.usage_category := p3_a52;
    ddp_lease_qte_rec.usage_industry_class := p3_a53;
    ddp_lease_qte_rec.usage_industry_code := p3_a54;
    ddp_lease_qte_rec.usage_amount := p3_a55;
    ddp_lease_qte_rec.usage_location_id := p3_a56;
    ddp_lease_qte_rec.property_tax_applicable := p3_a57;
    ddp_lease_qte_rec.property_tax_billing_type := p3_a58;
    ddp_lease_qte_rec.upfront_tax_treatment := p3_a59;
    ddp_lease_qte_rec.upfront_tax_stream_type := p3_a60;
    ddp_lease_qte_rec.transfer_of_title := p3_a61;
    ddp_lease_qte_rec.age_of_equipment := p3_a62;
    ddp_lease_qte_rec.purchase_of_lease := p3_a63;
    ddp_lease_qte_rec.sale_and_lease_back := p3_a64;
    ddp_lease_qte_rec.interest_disclosed := p3_a65;
    ddp_lease_qte_rec.primary_quote := p3_a66;
    ddp_lease_qte_rec.legal_entity_id := p3_a67;
    ddp_lease_qte_rec.line_intended_use := p3_a68;
    ddp_lease_qte_rec.short_description := p3_a69;
    ddp_lease_qte_rec.description := p3_a70;
    ddp_lease_qte_rec.comments := p3_a71;





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pvt.update_lease_qte(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_lease_qte_rec,
      ddx_lease_qte_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddx_lease_qte_rec.id;
    p4_a1 := ddx_lease_qte_rec.object_version_number;
    p4_a2 := ddx_lease_qte_rec.attribute_category;
    p4_a3 := ddx_lease_qte_rec.attribute1;
    p4_a4 := ddx_lease_qte_rec.attribute2;
    p4_a5 := ddx_lease_qte_rec.attribute3;
    p4_a6 := ddx_lease_qte_rec.attribute4;
    p4_a7 := ddx_lease_qte_rec.attribute5;
    p4_a8 := ddx_lease_qte_rec.attribute6;
    p4_a9 := ddx_lease_qte_rec.attribute7;
    p4_a10 := ddx_lease_qte_rec.attribute8;
    p4_a11 := ddx_lease_qte_rec.attribute9;
    p4_a12 := ddx_lease_qte_rec.attribute10;
    p4_a13 := ddx_lease_qte_rec.attribute11;
    p4_a14 := ddx_lease_qte_rec.attribute12;
    p4_a15 := ddx_lease_qte_rec.attribute13;
    p4_a16 := ddx_lease_qte_rec.attribute14;
    p4_a17 := ddx_lease_qte_rec.attribute15;
    p4_a18 := ddx_lease_qte_rec.reference_number;
    p4_a19 := ddx_lease_qte_rec.status;
    p4_a20 := ddx_lease_qte_rec.parent_object_code;
    p4_a21 := ddx_lease_qte_rec.parent_object_id;
    p4_a22 := ddx_lease_qte_rec.valid_from;
    p4_a23 := ddx_lease_qte_rec.valid_to;
    p4_a24 := ddx_lease_qte_rec.customer_bookclass;
    p4_a25 := ddx_lease_qte_rec.customer_taxowner;
    p4_a26 := ddx_lease_qte_rec.expected_start_date;
    p4_a27 := ddx_lease_qte_rec.expected_funding_date;
    p4_a28 := ddx_lease_qte_rec.expected_delivery_date;
    p4_a29 := ddx_lease_qte_rec.pricing_method;
    p4_a30 := ddx_lease_qte_rec.term;
    p4_a31 := ddx_lease_qte_rec.product_id;
    p4_a32 := ddx_lease_qte_rec.end_of_term_option_id;
    p4_a33 := ddx_lease_qte_rec.structured_pricing;
    p4_a34 := ddx_lease_qte_rec.line_level_pricing;
    p4_a35 := ddx_lease_qte_rec.rate_template_id;
    p4_a36 := ddx_lease_qte_rec.rate_card_id;
    p4_a37 := ddx_lease_qte_rec.lease_rate_factor;
    p4_a38 := ddx_lease_qte_rec.target_rate_type;
    p4_a39 := ddx_lease_qte_rec.target_rate;
    p4_a40 := ddx_lease_qte_rec.target_amount;
    p4_a41 := ddx_lease_qte_rec.target_frequency;
    p4_a42 := ddx_lease_qte_rec.target_arrears_yn;
    p4_a43 := ddx_lease_qte_rec.target_periods;
    p4_a44 := ddx_lease_qte_rec.iir;
    p4_a45 := ddx_lease_qte_rec.booking_yield;
    p4_a46 := ddx_lease_qte_rec.pirr;
    p4_a47 := ddx_lease_qte_rec.airr;
    p4_a48 := ddx_lease_qte_rec.sub_iir;
    p4_a49 := ddx_lease_qte_rec.sub_booking_yield;
    p4_a50 := ddx_lease_qte_rec.sub_pirr;
    p4_a51 := ddx_lease_qte_rec.sub_airr;
    p4_a52 := ddx_lease_qte_rec.usage_category;
    p4_a53 := ddx_lease_qte_rec.usage_industry_class;
    p4_a54 := ddx_lease_qte_rec.usage_industry_code;
    p4_a55 := ddx_lease_qte_rec.usage_amount;
    p4_a56 := ddx_lease_qte_rec.usage_location_id;
    p4_a57 := ddx_lease_qte_rec.property_tax_applicable;
    p4_a58 := ddx_lease_qte_rec.property_tax_billing_type;
    p4_a59 := ddx_lease_qte_rec.upfront_tax_treatment;
    p4_a60 := ddx_lease_qte_rec.upfront_tax_stream_type;
    p4_a61 := ddx_lease_qte_rec.transfer_of_title;
    p4_a62 := ddx_lease_qte_rec.age_of_equipment;
    p4_a63 := ddx_lease_qte_rec.purchase_of_lease;
    p4_a64 := ddx_lease_qte_rec.sale_and_lease_back;
    p4_a65 := ddx_lease_qte_rec.interest_disclosed;
    p4_a66 := ddx_lease_qte_rec.primary_quote;
    p4_a67 := ddx_lease_qte_rec.legal_entity_id;
    p4_a68 := ddx_lease_qte_rec.line_intended_use;
    p4_a69 := ddx_lease_qte_rec.short_description;
    p4_a70 := ddx_lease_qte_rec.description;
    p4_a71 := ddx_lease_qte_rec.comments;



  end;

  procedure duplicate_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_quote_id  NUMBER
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
    , p4_a20  VARCHAR2
    , p4_a21  NUMBER
    , p4_a22  DATE
    , p4_a23  DATE
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  DATE
    , p4_a27  DATE
    , p4_a28  DATE
    , p4_a29  VARCHAR2
    , p4_a30  NUMBER
    , p4_a31  NUMBER
    , p4_a32  NUMBER
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  NUMBER
    , p4_a37  NUMBER
    , p4_a38  VARCHAR2
    , p4_a39  NUMBER
    , p4_a40  NUMBER
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  NUMBER
    , p4_a44  NUMBER
    , p4_a45  NUMBER
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  NUMBER
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  NUMBER
    , p4_a56  NUMBER
    , p4_a57  VARCHAR2
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  NUMBER
    , p4_a61  VARCHAR2
    , p4_a62  NUMBER
    , p4_a63  VARCHAR2
    , p4_a64  VARCHAR2
    , p4_a65  VARCHAR2
    , p4_a66  VARCHAR2
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  VARCHAR2
    , p4_a70  VARCHAR2
    , p4_a71  VARCHAR2
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
    , p5_a20 out nocopy  VARCHAR2
    , p5_a21 out nocopy  NUMBER
    , p5_a22 out nocopy  DATE
    , p5_a23 out nocopy  DATE
    , p5_a24 out nocopy  VARCHAR2
    , p5_a25 out nocopy  VARCHAR2
    , p5_a26 out nocopy  DATE
    , p5_a27 out nocopy  DATE
    , p5_a28 out nocopy  DATE
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  NUMBER
    , p5_a31 out nocopy  NUMBER
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  VARCHAR2
    , p5_a34 out nocopy  VARCHAR2
    , p5_a35 out nocopy  NUMBER
    , p5_a36 out nocopy  NUMBER
    , p5_a37 out nocopy  NUMBER
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  NUMBER
    , p5_a40 out nocopy  NUMBER
    , p5_a41 out nocopy  VARCHAR2
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  NUMBER
    , p5_a44 out nocopy  NUMBER
    , p5_a45 out nocopy  NUMBER
    , p5_a46 out nocopy  NUMBER
    , p5_a47 out nocopy  NUMBER
    , p5_a48 out nocopy  NUMBER
    , p5_a49 out nocopy  NUMBER
    , p5_a50 out nocopy  NUMBER
    , p5_a51 out nocopy  NUMBER
    , p5_a52 out nocopy  VARCHAR2
    , p5_a53 out nocopy  VARCHAR2
    , p5_a54 out nocopy  VARCHAR2
    , p5_a55 out nocopy  NUMBER
    , p5_a56 out nocopy  NUMBER
    , p5_a57 out nocopy  VARCHAR2
    , p5_a58 out nocopy  VARCHAR2
    , p5_a59 out nocopy  VARCHAR2
    , p5_a60 out nocopy  NUMBER
    , p5_a61 out nocopy  VARCHAR2
    , p5_a62 out nocopy  NUMBER
    , p5_a63 out nocopy  VARCHAR2
    , p5_a64 out nocopy  VARCHAR2
    , p5_a65 out nocopy  VARCHAR2
    , p5_a66 out nocopy  VARCHAR2
    , p5_a67 out nocopy  NUMBER
    , p5_a68 out nocopy  VARCHAR2
    , p5_a69 out nocopy  VARCHAR2
    , p5_a70 out nocopy  VARCHAR2
    , p5_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddx_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_lease_qte_rec.id := p4_a0;
    ddp_lease_qte_rec.object_version_number := p4_a1;
    ddp_lease_qte_rec.attribute_category := p4_a2;
    ddp_lease_qte_rec.attribute1 := p4_a3;
    ddp_lease_qte_rec.attribute2 := p4_a4;
    ddp_lease_qte_rec.attribute3 := p4_a5;
    ddp_lease_qte_rec.attribute4 := p4_a6;
    ddp_lease_qte_rec.attribute5 := p4_a7;
    ddp_lease_qte_rec.attribute6 := p4_a8;
    ddp_lease_qte_rec.attribute7 := p4_a9;
    ddp_lease_qte_rec.attribute8 := p4_a10;
    ddp_lease_qte_rec.attribute9 := p4_a11;
    ddp_lease_qte_rec.attribute10 := p4_a12;
    ddp_lease_qte_rec.attribute11 := p4_a13;
    ddp_lease_qte_rec.attribute12 := p4_a14;
    ddp_lease_qte_rec.attribute13 := p4_a15;
    ddp_lease_qte_rec.attribute14 := p4_a16;
    ddp_lease_qte_rec.attribute15 := p4_a17;
    ddp_lease_qte_rec.reference_number := p4_a18;
    ddp_lease_qte_rec.status := p4_a19;
    ddp_lease_qte_rec.parent_object_code := p4_a20;
    ddp_lease_qte_rec.parent_object_id := p4_a21;
    ddp_lease_qte_rec.valid_from := p4_a22;
    ddp_lease_qte_rec.valid_to := p4_a23;
    ddp_lease_qte_rec.customer_bookclass := p4_a24;
    ddp_lease_qte_rec.customer_taxowner := p4_a25;
    ddp_lease_qte_rec.expected_start_date := p4_a26;
    ddp_lease_qte_rec.expected_funding_date := p4_a27;
    ddp_lease_qte_rec.expected_delivery_date := p4_a28;
    ddp_lease_qte_rec.pricing_method := p4_a29;
    ddp_lease_qte_rec.term := p4_a30;
    ddp_lease_qte_rec.product_id := p4_a31;
    ddp_lease_qte_rec.end_of_term_option_id := p4_a32;
    ddp_lease_qte_rec.structured_pricing := p4_a33;
    ddp_lease_qte_rec.line_level_pricing := p4_a34;
    ddp_lease_qte_rec.rate_template_id := p4_a35;
    ddp_lease_qte_rec.rate_card_id := p4_a36;
    ddp_lease_qte_rec.lease_rate_factor := p4_a37;
    ddp_lease_qte_rec.target_rate_type := p4_a38;
    ddp_lease_qte_rec.target_rate := p4_a39;
    ddp_lease_qte_rec.target_amount := p4_a40;
    ddp_lease_qte_rec.target_frequency := p4_a41;
    ddp_lease_qte_rec.target_arrears_yn := p4_a42;
    ddp_lease_qte_rec.target_periods := p4_a43;
    ddp_lease_qte_rec.iir := p4_a44;
    ddp_lease_qte_rec.booking_yield := p4_a45;
    ddp_lease_qte_rec.pirr := p4_a46;
    ddp_lease_qte_rec.airr := p4_a47;
    ddp_lease_qte_rec.sub_iir := p4_a48;
    ddp_lease_qte_rec.sub_booking_yield := p4_a49;
    ddp_lease_qte_rec.sub_pirr := p4_a50;
    ddp_lease_qte_rec.sub_airr := p4_a51;
    ddp_lease_qte_rec.usage_category := p4_a52;
    ddp_lease_qte_rec.usage_industry_class := p4_a53;
    ddp_lease_qte_rec.usage_industry_code := p4_a54;
    ddp_lease_qte_rec.usage_amount := p4_a55;
    ddp_lease_qte_rec.usage_location_id := p4_a56;
    ddp_lease_qte_rec.property_tax_applicable := p4_a57;
    ddp_lease_qte_rec.property_tax_billing_type := p4_a58;
    ddp_lease_qte_rec.upfront_tax_treatment := p4_a59;
    ddp_lease_qte_rec.upfront_tax_stream_type := p4_a60;
    ddp_lease_qte_rec.transfer_of_title := p4_a61;
    ddp_lease_qte_rec.age_of_equipment := p4_a62;
    ddp_lease_qte_rec.purchase_of_lease := p4_a63;
    ddp_lease_qte_rec.sale_and_lease_back := p4_a64;
    ddp_lease_qte_rec.interest_disclosed := p4_a65;
    ddp_lease_qte_rec.primary_quote := p4_a66;
    ddp_lease_qte_rec.legal_entity_id := p4_a67;
    ddp_lease_qte_rec.line_intended_use := p4_a68;
    ddp_lease_qte_rec.short_description := p4_a69;
    ddp_lease_qte_rec.description := p4_a70;
    ddp_lease_qte_rec.comments := p4_a71;





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pvt.duplicate_lease_qte(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      p_source_quote_id,
      ddp_lease_qte_rec,
      ddx_lease_qte_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_lease_qte_rec.id;
    p5_a1 := ddx_lease_qte_rec.object_version_number;
    p5_a2 := ddx_lease_qte_rec.attribute_category;
    p5_a3 := ddx_lease_qte_rec.attribute1;
    p5_a4 := ddx_lease_qte_rec.attribute2;
    p5_a5 := ddx_lease_qte_rec.attribute3;
    p5_a6 := ddx_lease_qte_rec.attribute4;
    p5_a7 := ddx_lease_qte_rec.attribute5;
    p5_a8 := ddx_lease_qte_rec.attribute6;
    p5_a9 := ddx_lease_qte_rec.attribute7;
    p5_a10 := ddx_lease_qte_rec.attribute8;
    p5_a11 := ddx_lease_qte_rec.attribute9;
    p5_a12 := ddx_lease_qte_rec.attribute10;
    p5_a13 := ddx_lease_qte_rec.attribute11;
    p5_a14 := ddx_lease_qte_rec.attribute12;
    p5_a15 := ddx_lease_qte_rec.attribute13;
    p5_a16 := ddx_lease_qte_rec.attribute14;
    p5_a17 := ddx_lease_qte_rec.attribute15;
    p5_a18 := ddx_lease_qte_rec.reference_number;
    p5_a19 := ddx_lease_qte_rec.status;
    p5_a20 := ddx_lease_qte_rec.parent_object_code;
    p5_a21 := ddx_lease_qte_rec.parent_object_id;
    p5_a22 := ddx_lease_qte_rec.valid_from;
    p5_a23 := ddx_lease_qte_rec.valid_to;
    p5_a24 := ddx_lease_qte_rec.customer_bookclass;
    p5_a25 := ddx_lease_qte_rec.customer_taxowner;
    p5_a26 := ddx_lease_qte_rec.expected_start_date;
    p5_a27 := ddx_lease_qte_rec.expected_funding_date;
    p5_a28 := ddx_lease_qte_rec.expected_delivery_date;
    p5_a29 := ddx_lease_qte_rec.pricing_method;
    p5_a30 := ddx_lease_qte_rec.term;
    p5_a31 := ddx_lease_qte_rec.product_id;
    p5_a32 := ddx_lease_qte_rec.end_of_term_option_id;
    p5_a33 := ddx_lease_qte_rec.structured_pricing;
    p5_a34 := ddx_lease_qte_rec.line_level_pricing;
    p5_a35 := ddx_lease_qte_rec.rate_template_id;
    p5_a36 := ddx_lease_qte_rec.rate_card_id;
    p5_a37 := ddx_lease_qte_rec.lease_rate_factor;
    p5_a38 := ddx_lease_qte_rec.target_rate_type;
    p5_a39 := ddx_lease_qte_rec.target_rate;
    p5_a40 := ddx_lease_qte_rec.target_amount;
    p5_a41 := ddx_lease_qte_rec.target_frequency;
    p5_a42 := ddx_lease_qte_rec.target_arrears_yn;
    p5_a43 := ddx_lease_qte_rec.target_periods;
    p5_a44 := ddx_lease_qte_rec.iir;
    p5_a45 := ddx_lease_qte_rec.booking_yield;
    p5_a46 := ddx_lease_qte_rec.pirr;
    p5_a47 := ddx_lease_qte_rec.airr;
    p5_a48 := ddx_lease_qte_rec.sub_iir;
    p5_a49 := ddx_lease_qte_rec.sub_booking_yield;
    p5_a50 := ddx_lease_qte_rec.sub_pirr;
    p5_a51 := ddx_lease_qte_rec.sub_airr;
    p5_a52 := ddx_lease_qte_rec.usage_category;
    p5_a53 := ddx_lease_qte_rec.usage_industry_class;
    p5_a54 := ddx_lease_qte_rec.usage_industry_code;
    p5_a55 := ddx_lease_qte_rec.usage_amount;
    p5_a56 := ddx_lease_qte_rec.usage_location_id;
    p5_a57 := ddx_lease_qte_rec.property_tax_applicable;
    p5_a58 := ddx_lease_qte_rec.property_tax_billing_type;
    p5_a59 := ddx_lease_qte_rec.upfront_tax_treatment;
    p5_a60 := ddx_lease_qte_rec.upfront_tax_stream_type;
    p5_a61 := ddx_lease_qte_rec.transfer_of_title;
    p5_a62 := ddx_lease_qte_rec.age_of_equipment;
    p5_a63 := ddx_lease_qte_rec.purchase_of_lease;
    p5_a64 := ddx_lease_qte_rec.sale_and_lease_back;
    p5_a65 := ddx_lease_qte_rec.interest_disclosed;
    p5_a66 := ddx_lease_qte_rec.primary_quote;
    p5_a67 := ddx_lease_qte_rec.legal_entity_id;
    p5_a68 := ddx_lease_qte_rec.line_intended_use;
    p5_a69 := ddx_lease_qte_rec.short_description;
    p5_a70 := ddx_lease_qte_rec.description;
    p5_a71 := ddx_lease_qte_rec.comments;



  end;

  procedure duplicate_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_quote_id  NUMBER
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
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  NUMBER
    , p4_a22 out nocopy  DATE
    , p4_a23 out nocopy  DATE
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  DATE
    , p4_a27 out nocopy  DATE
    , p4_a28 out nocopy  DATE
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , p4_a34 out nocopy  VARCHAR2
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  NUMBER
    , p4_a37 out nocopy  NUMBER
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  NUMBER
    , p4_a40 out nocopy  NUMBER
    , p4_a41 out nocopy  VARCHAR2
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  NUMBER
    , p4_a44 out nocopy  NUMBER
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  NUMBER
    , p4_a50 out nocopy  NUMBER
    , p4_a51 out nocopy  NUMBER
    , p4_a52 out nocopy  VARCHAR2
    , p4_a53 out nocopy  VARCHAR2
    , p4_a54 out nocopy  VARCHAR2
    , p4_a55 out nocopy  NUMBER
    , p4_a56 out nocopy  NUMBER
    , p4_a57 out nocopy  VARCHAR2
    , p4_a58 out nocopy  VARCHAR2
    , p4_a59 out nocopy  VARCHAR2
    , p4_a60 out nocopy  NUMBER
    , p4_a61 out nocopy  VARCHAR2
    , p4_a62 out nocopy  NUMBER
    , p4_a63 out nocopy  VARCHAR2
    , p4_a64 out nocopy  VARCHAR2
    , p4_a65 out nocopy  VARCHAR2
    , p4_a66 out nocopy  VARCHAR2
    , p4_a67 out nocopy  NUMBER
    , p4_a68 out nocopy  VARCHAR2
    , p4_a69 out nocopy  VARCHAR2
    , p4_a70 out nocopy  VARCHAR2
    , p4_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pvt.duplicate_lease_qte(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      p_quote_id,
      ddx_lease_qte_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddx_lease_qte_rec.id;
    p4_a1 := ddx_lease_qte_rec.object_version_number;
    p4_a2 := ddx_lease_qte_rec.attribute_category;
    p4_a3 := ddx_lease_qte_rec.attribute1;
    p4_a4 := ddx_lease_qte_rec.attribute2;
    p4_a5 := ddx_lease_qte_rec.attribute3;
    p4_a6 := ddx_lease_qte_rec.attribute4;
    p4_a7 := ddx_lease_qte_rec.attribute5;
    p4_a8 := ddx_lease_qte_rec.attribute6;
    p4_a9 := ddx_lease_qte_rec.attribute7;
    p4_a10 := ddx_lease_qte_rec.attribute8;
    p4_a11 := ddx_lease_qte_rec.attribute9;
    p4_a12 := ddx_lease_qte_rec.attribute10;
    p4_a13 := ddx_lease_qte_rec.attribute11;
    p4_a14 := ddx_lease_qte_rec.attribute12;
    p4_a15 := ddx_lease_qte_rec.attribute13;
    p4_a16 := ddx_lease_qte_rec.attribute14;
    p4_a17 := ddx_lease_qte_rec.attribute15;
    p4_a18 := ddx_lease_qte_rec.reference_number;
    p4_a19 := ddx_lease_qte_rec.status;
    p4_a20 := ddx_lease_qte_rec.parent_object_code;
    p4_a21 := ddx_lease_qte_rec.parent_object_id;
    p4_a22 := ddx_lease_qte_rec.valid_from;
    p4_a23 := ddx_lease_qte_rec.valid_to;
    p4_a24 := ddx_lease_qte_rec.customer_bookclass;
    p4_a25 := ddx_lease_qte_rec.customer_taxowner;
    p4_a26 := ddx_lease_qte_rec.expected_start_date;
    p4_a27 := ddx_lease_qte_rec.expected_funding_date;
    p4_a28 := ddx_lease_qte_rec.expected_delivery_date;
    p4_a29 := ddx_lease_qte_rec.pricing_method;
    p4_a30 := ddx_lease_qte_rec.term;
    p4_a31 := ddx_lease_qte_rec.product_id;
    p4_a32 := ddx_lease_qte_rec.end_of_term_option_id;
    p4_a33 := ddx_lease_qte_rec.structured_pricing;
    p4_a34 := ddx_lease_qte_rec.line_level_pricing;
    p4_a35 := ddx_lease_qte_rec.rate_template_id;
    p4_a36 := ddx_lease_qte_rec.rate_card_id;
    p4_a37 := ddx_lease_qte_rec.lease_rate_factor;
    p4_a38 := ddx_lease_qte_rec.target_rate_type;
    p4_a39 := ddx_lease_qte_rec.target_rate;
    p4_a40 := ddx_lease_qte_rec.target_amount;
    p4_a41 := ddx_lease_qte_rec.target_frequency;
    p4_a42 := ddx_lease_qte_rec.target_arrears_yn;
    p4_a43 := ddx_lease_qte_rec.target_periods;
    p4_a44 := ddx_lease_qte_rec.iir;
    p4_a45 := ddx_lease_qte_rec.booking_yield;
    p4_a46 := ddx_lease_qte_rec.pirr;
    p4_a47 := ddx_lease_qte_rec.airr;
    p4_a48 := ddx_lease_qte_rec.sub_iir;
    p4_a49 := ddx_lease_qte_rec.sub_booking_yield;
    p4_a50 := ddx_lease_qte_rec.sub_pirr;
    p4_a51 := ddx_lease_qte_rec.sub_airr;
    p4_a52 := ddx_lease_qte_rec.usage_category;
    p4_a53 := ddx_lease_qte_rec.usage_industry_class;
    p4_a54 := ddx_lease_qte_rec.usage_industry_code;
    p4_a55 := ddx_lease_qte_rec.usage_amount;
    p4_a56 := ddx_lease_qte_rec.usage_location_id;
    p4_a57 := ddx_lease_qte_rec.property_tax_applicable;
    p4_a58 := ddx_lease_qte_rec.property_tax_billing_type;
    p4_a59 := ddx_lease_qte_rec.upfront_tax_treatment;
    p4_a60 := ddx_lease_qte_rec.upfront_tax_stream_type;
    p4_a61 := ddx_lease_qte_rec.transfer_of_title;
    p4_a62 := ddx_lease_qte_rec.age_of_equipment;
    p4_a63 := ddx_lease_qte_rec.purchase_of_lease;
    p4_a64 := ddx_lease_qte_rec.sale_and_lease_back;
    p4_a65 := ddx_lease_qte_rec.interest_disclosed;
    p4_a66 := ddx_lease_qte_rec.primary_quote;
    p4_a67 := ddx_lease_qte_rec.legal_entity_id;
    p4_a68 := ddx_lease_qte_rec.line_intended_use;
    p4_a69 := ddx_lease_qte_rec.short_description;
    p4_a70 := ddx_lease_qte_rec.description;
    p4_a71 := ddx_lease_qte_rec.comments;



  end;

  procedure cancel_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_500
    , p3_a4 JTF_VARCHAR2_TABLE_500
    , p3_a5 JTF_VARCHAR2_TABLE_500
    , p3_a6 JTF_VARCHAR2_TABLE_500
    , p3_a7 JTF_VARCHAR2_TABLE_500
    , p3_a8 JTF_VARCHAR2_TABLE_500
    , p3_a9 JTF_VARCHAR2_TABLE_500
    , p3_a10 JTF_VARCHAR2_TABLE_500
    , p3_a11 JTF_VARCHAR2_TABLE_500
    , p3_a12 JTF_VARCHAR2_TABLE_500
    , p3_a13 JTF_VARCHAR2_TABLE_500
    , p3_a14 JTF_VARCHAR2_TABLE_500
    , p3_a15 JTF_VARCHAR2_TABLE_500
    , p3_a16 JTF_VARCHAR2_TABLE_500
    , p3_a17 JTF_VARCHAR2_TABLE_500
    , p3_a18 JTF_VARCHAR2_TABLE_200
    , p3_a19 JTF_VARCHAR2_TABLE_100
    , p3_a20 JTF_VARCHAR2_TABLE_100
    , p3_a21 JTF_NUMBER_TABLE
    , p3_a22 JTF_DATE_TABLE
    , p3_a23 JTF_DATE_TABLE
    , p3_a24 JTF_VARCHAR2_TABLE_100
    , p3_a25 JTF_VARCHAR2_TABLE_100
    , p3_a26 JTF_DATE_TABLE
    , p3_a27 JTF_DATE_TABLE
    , p3_a28 JTF_DATE_TABLE
    , p3_a29 JTF_VARCHAR2_TABLE_100
    , p3_a30 JTF_NUMBER_TABLE
    , p3_a31 JTF_NUMBER_TABLE
    , p3_a32 JTF_NUMBER_TABLE
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_100
    , p3_a35 JTF_NUMBER_TABLE
    , p3_a36 JTF_NUMBER_TABLE
    , p3_a37 JTF_NUMBER_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_100
    , p3_a39 JTF_NUMBER_TABLE
    , p3_a40 JTF_NUMBER_TABLE
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_NUMBER_TABLE
    , p3_a44 JTF_NUMBER_TABLE
    , p3_a45 JTF_NUMBER_TABLE
    , p3_a46 JTF_NUMBER_TABLE
    , p3_a47 JTF_NUMBER_TABLE
    , p3_a48 JTF_NUMBER_TABLE
    , p3_a49 JTF_NUMBER_TABLE
    , p3_a50 JTF_NUMBER_TABLE
    , p3_a51 JTF_NUMBER_TABLE
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_NUMBER_TABLE
    , p3_a56 JTF_NUMBER_TABLE
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_NUMBER_TABLE
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_NUMBER_TABLE
    , p3_a63 JTF_VARCHAR2_TABLE_100
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p3_a66 JTF_VARCHAR2_TABLE_100
    , p3_a67 JTF_NUMBER_TABLE
    , p3_a68 JTF_VARCHAR2_TABLE_300
    , p3_a69 JTF_VARCHAR2_TABLE_300
    , p3_a70 JTF_VARCHAR2_TABLE_2000
    , p3_a71 JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_tbl okl_lease_quote_pvt.lease_qte_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_lsq_pvt_w.rosetta_table_copy_in_p23(ddp_lease_qte_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      , p3_a40
      , p3_a41
      , p3_a42
      , p3_a43
      , p3_a44
      , p3_a45
      , p3_a46
      , p3_a47
      , p3_a48
      , p3_a49
      , p3_a50
      , p3_a51
      , p3_a52
      , p3_a53
      , p3_a54
      , p3_a55
      , p3_a56
      , p3_a57
      , p3_a58
      , p3_a59
      , p3_a60
      , p3_a61
      , p3_a62
      , p3_a63
      , p3_a64
      , p3_a65
      , p3_a66
      , p3_a67
      , p3_a68
      , p3_a69
      , p3_a70
      , p3_a71
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pvt.cancel_lease_qte(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_lease_qte_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_lease_qte(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  DATE
    , p0_a23  DATE
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  DATE
    , p0_a27  DATE
    , p0_a28  DATE
    , p0_a29  VARCHAR2
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  VARCHAR2
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_rec okl_lease_quote_pvt.lease_qte_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_lease_qte_rec.id := p0_a0;
    ddp_lease_qte_rec.object_version_number := p0_a1;
    ddp_lease_qte_rec.attribute_category := p0_a2;
    ddp_lease_qte_rec.attribute1 := p0_a3;
    ddp_lease_qte_rec.attribute2 := p0_a4;
    ddp_lease_qte_rec.attribute3 := p0_a5;
    ddp_lease_qte_rec.attribute4 := p0_a6;
    ddp_lease_qte_rec.attribute5 := p0_a7;
    ddp_lease_qte_rec.attribute6 := p0_a8;
    ddp_lease_qte_rec.attribute7 := p0_a9;
    ddp_lease_qte_rec.attribute8 := p0_a10;
    ddp_lease_qte_rec.attribute9 := p0_a11;
    ddp_lease_qte_rec.attribute10 := p0_a12;
    ddp_lease_qte_rec.attribute11 := p0_a13;
    ddp_lease_qte_rec.attribute12 := p0_a14;
    ddp_lease_qte_rec.attribute13 := p0_a15;
    ddp_lease_qte_rec.attribute14 := p0_a16;
    ddp_lease_qte_rec.attribute15 := p0_a17;
    ddp_lease_qte_rec.reference_number := p0_a18;
    ddp_lease_qte_rec.status := p0_a19;
    ddp_lease_qte_rec.parent_object_code := p0_a20;
    ddp_lease_qte_rec.parent_object_id := p0_a21;
    ddp_lease_qte_rec.valid_from := p0_a22;
    ddp_lease_qte_rec.valid_to := p0_a23;
    ddp_lease_qte_rec.customer_bookclass := p0_a24;
    ddp_lease_qte_rec.customer_taxowner := p0_a25;
    ddp_lease_qte_rec.expected_start_date := p0_a26;
    ddp_lease_qte_rec.expected_funding_date := p0_a27;
    ddp_lease_qte_rec.expected_delivery_date := p0_a28;
    ddp_lease_qte_rec.pricing_method := p0_a29;
    ddp_lease_qte_rec.term := p0_a30;
    ddp_lease_qte_rec.product_id := p0_a31;
    ddp_lease_qte_rec.end_of_term_option_id := p0_a32;
    ddp_lease_qte_rec.structured_pricing := p0_a33;
    ddp_lease_qte_rec.line_level_pricing := p0_a34;
    ddp_lease_qte_rec.rate_template_id := p0_a35;
    ddp_lease_qte_rec.rate_card_id := p0_a36;
    ddp_lease_qte_rec.lease_rate_factor := p0_a37;
    ddp_lease_qte_rec.target_rate_type := p0_a38;
    ddp_lease_qte_rec.target_rate := p0_a39;
    ddp_lease_qte_rec.target_amount := p0_a40;
    ddp_lease_qte_rec.target_frequency := p0_a41;
    ddp_lease_qte_rec.target_arrears_yn := p0_a42;
    ddp_lease_qte_rec.target_periods := p0_a43;
    ddp_lease_qte_rec.iir := p0_a44;
    ddp_lease_qte_rec.booking_yield := p0_a45;
    ddp_lease_qte_rec.pirr := p0_a46;
    ddp_lease_qte_rec.airr := p0_a47;
    ddp_lease_qte_rec.sub_iir := p0_a48;
    ddp_lease_qte_rec.sub_booking_yield := p0_a49;
    ddp_lease_qte_rec.sub_pirr := p0_a50;
    ddp_lease_qte_rec.sub_airr := p0_a51;
    ddp_lease_qte_rec.usage_category := p0_a52;
    ddp_lease_qte_rec.usage_industry_class := p0_a53;
    ddp_lease_qte_rec.usage_industry_code := p0_a54;
    ddp_lease_qte_rec.usage_amount := p0_a55;
    ddp_lease_qte_rec.usage_location_id := p0_a56;
    ddp_lease_qte_rec.property_tax_applicable := p0_a57;
    ddp_lease_qte_rec.property_tax_billing_type := p0_a58;
    ddp_lease_qte_rec.upfront_tax_treatment := p0_a59;
    ddp_lease_qte_rec.upfront_tax_stream_type := p0_a60;
    ddp_lease_qte_rec.transfer_of_title := p0_a61;
    ddp_lease_qte_rec.age_of_equipment := p0_a62;
    ddp_lease_qte_rec.purchase_of_lease := p0_a63;
    ddp_lease_qte_rec.sale_and_lease_back := p0_a64;
    ddp_lease_qte_rec.interest_disclosed := p0_a65;
    ddp_lease_qte_rec.primary_quote := p0_a66;
    ddp_lease_qte_rec.legal_entity_id := p0_a67;
    ddp_lease_qte_rec.line_intended_use := p0_a68;
    ddp_lease_qte_rec.short_description := p0_a69;
    ddp_lease_qte_rec.description := p0_a70;
    ddp_lease_qte_rec.comments := p0_a71;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pvt.validate_lease_qte(ddp_lease_qte_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

end okl_lease_quote_pvt_w;

/
