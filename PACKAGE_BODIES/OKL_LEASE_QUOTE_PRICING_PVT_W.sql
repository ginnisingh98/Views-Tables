--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_PRICING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_PRICING_PVT_W" as
  /* $Header: OKLIQUPB.pls 120.5 2006/03/16 10:10:00 asawanka noship $ */
  procedure create_update_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  NUMBER
    , p2_a22  DATE
    , p2_a23  DATE
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  DATE
    , p2_a27  DATE
    , p2_a28  DATE
    , p2_a29  VARCHAR2
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  NUMBER
    , p2_a37  NUMBER
    , p2_a38  VARCHAR2
    , p2_a39  NUMBER
    , p2_a40  NUMBER
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  NUMBER
    , p2_a44  NUMBER
    , p2_a45  NUMBER
    , p2_a46  NUMBER
    , p2_a47  NUMBER
    , p2_a48  NUMBER
    , p2_a49  NUMBER
    , p2_a50  NUMBER
    , p2_a51  NUMBER
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  NUMBER
    , p2_a56  NUMBER
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  VARCHAR2
    , p2_a60  NUMBER
    , p2_a61  VARCHAR2
    , p2_a62  NUMBER
    , p2_a63  VARCHAR2
    , p2_a64  VARCHAR2
    , p2_a65  VARCHAR2
    , p2_a66  VARCHAR2
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_DATE_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_rec okl_lease_quote_pricing_pvt.lease_qte_rec_type;
    ddp_payment_header_rec okl_lease_quote_pricing_pvt.cashflow_hdr_rec_type;
    ddp_payment_level_tbl okl_lease_quote_pricing_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_lease_qte_rec.id := p2_a0;
    ddp_lease_qte_rec.object_version_number := p2_a1;
    ddp_lease_qte_rec.attribute_category := p2_a2;
    ddp_lease_qte_rec.attribute1 := p2_a3;
    ddp_lease_qte_rec.attribute2 := p2_a4;
    ddp_lease_qte_rec.attribute3 := p2_a5;
    ddp_lease_qte_rec.attribute4 := p2_a6;
    ddp_lease_qte_rec.attribute5 := p2_a7;
    ddp_lease_qte_rec.attribute6 := p2_a8;
    ddp_lease_qte_rec.attribute7 := p2_a9;
    ddp_lease_qte_rec.attribute8 := p2_a10;
    ddp_lease_qte_rec.attribute9 := p2_a11;
    ddp_lease_qte_rec.attribute10 := p2_a12;
    ddp_lease_qte_rec.attribute11 := p2_a13;
    ddp_lease_qte_rec.attribute12 := p2_a14;
    ddp_lease_qte_rec.attribute13 := p2_a15;
    ddp_lease_qte_rec.attribute14 := p2_a16;
    ddp_lease_qte_rec.attribute15 := p2_a17;
    ddp_lease_qte_rec.reference_number := p2_a18;
    ddp_lease_qte_rec.status := p2_a19;
    ddp_lease_qte_rec.parent_object_code := p2_a20;
    ddp_lease_qte_rec.parent_object_id := p2_a21;
    ddp_lease_qte_rec.valid_from := p2_a22;
    ddp_lease_qte_rec.valid_to := p2_a23;
    ddp_lease_qte_rec.customer_bookclass := p2_a24;
    ddp_lease_qte_rec.customer_taxowner := p2_a25;
    ddp_lease_qte_rec.expected_start_date := p2_a26;
    ddp_lease_qte_rec.expected_funding_date := p2_a27;
    ddp_lease_qte_rec.expected_delivery_date := p2_a28;
    ddp_lease_qte_rec.pricing_method := p2_a29;
    ddp_lease_qte_rec.term := p2_a30;
    ddp_lease_qte_rec.product_id := p2_a31;
    ddp_lease_qte_rec.end_of_term_option_id := p2_a32;
    ddp_lease_qte_rec.structured_pricing := p2_a33;
    ddp_lease_qte_rec.line_level_pricing := p2_a34;
    ddp_lease_qte_rec.rate_template_id := p2_a35;
    ddp_lease_qte_rec.rate_card_id := p2_a36;
    ddp_lease_qte_rec.lease_rate_factor := p2_a37;
    ddp_lease_qte_rec.target_rate_type := p2_a38;
    ddp_lease_qte_rec.target_rate := p2_a39;
    ddp_lease_qte_rec.target_amount := p2_a40;
    ddp_lease_qte_rec.target_frequency := p2_a41;
    ddp_lease_qte_rec.target_arrears_yn := p2_a42;
    ddp_lease_qte_rec.target_periods := p2_a43;
    ddp_lease_qte_rec.iir := p2_a44;
    ddp_lease_qte_rec.booking_yield := p2_a45;
    ddp_lease_qte_rec.pirr := p2_a46;
    ddp_lease_qte_rec.airr := p2_a47;
    ddp_lease_qte_rec.sub_iir := p2_a48;
    ddp_lease_qte_rec.sub_booking_yield := p2_a49;
    ddp_lease_qte_rec.sub_pirr := p2_a50;
    ddp_lease_qte_rec.sub_airr := p2_a51;
    ddp_lease_qte_rec.usage_category := p2_a52;
    ddp_lease_qte_rec.usage_industry_class := p2_a53;
    ddp_lease_qte_rec.usage_industry_code := p2_a54;
    ddp_lease_qte_rec.usage_amount := p2_a55;
    ddp_lease_qte_rec.usage_location_id := p2_a56;
    ddp_lease_qte_rec.property_tax_applicable := p2_a57;
    ddp_lease_qte_rec.property_tax_billing_type := p2_a58;
    ddp_lease_qte_rec.upfront_tax_treatment := p2_a59;
    ddp_lease_qte_rec.upfront_tax_stream_type := p2_a60;
    ddp_lease_qte_rec.transfer_of_title := p2_a61;
    ddp_lease_qte_rec.age_of_equipment := p2_a62;
    ddp_lease_qte_rec.purchase_of_lease := p2_a63;
    ddp_lease_qte_rec.sale_and_lease_back := p2_a64;
    ddp_lease_qte_rec.interest_disclosed := p2_a65;
    ddp_lease_qte_rec.primary_quote := p2_a66;
    ddp_lease_qte_rec.short_description := p2_a67;
    ddp_lease_qte_rec.description := p2_a68;
    ddp_lease_qte_rec.comments := p2_a69;

    ddp_payment_header_rec.type_code := p3_a0;
    ddp_payment_header_rec.stream_type_id := p3_a1;
    ddp_payment_header_rec.status_code := p3_a2;
    ddp_payment_header_rec.arrears_flag := p3_a3;
    ddp_payment_header_rec.frequency_code := p3_a4;
    ddp_payment_header_rec.dnz_periods := p3_a5;
    ddp_payment_header_rec.dnz_periodic_amount := p3_a6;
    ddp_payment_header_rec.parent_object_code := p3_a7;
    ddp_payment_header_rec.parent_object_id := p3_a8;
    ddp_payment_header_rec.quote_type_code := p3_a9;
    ddp_payment_header_rec.quote_id := p3_a10;
    ddp_payment_header_rec.cashflow_header_id := p3_a11;
    ddp_payment_header_rec.cashflow_object_id := p3_a12;
    ddp_payment_header_rec.cashflow_header_ovn := p3_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_payment_level_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pricing_pvt.create_update_payment(p_api_version,
      p_init_msg_list,
      ddp_lease_qte_rec,
      ddp_payment_header_rec,
      ddp_payment_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_update_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  NUMBER
    , p2_a22  DATE
    , p2_a23  DATE
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  DATE
    , p2_a27  DATE
    , p2_a28  DATE
    , p2_a29  VARCHAR2
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  NUMBER
    , p2_a37  NUMBER
    , p2_a38  VARCHAR2
    , p2_a39  NUMBER
    , p2_a40  NUMBER
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  NUMBER
    , p2_a44  NUMBER
    , p2_a45  NUMBER
    , p2_a46  NUMBER
    , p2_a47  NUMBER
    , p2_a48  NUMBER
    , p2_a49  NUMBER
    , p2_a50  NUMBER
    , p2_a51  NUMBER
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  NUMBER
    , p2_a56  NUMBER
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  VARCHAR2
    , p2_a60  NUMBER
    , p2_a61  VARCHAR2
    , p2_a62  NUMBER
    , p2_a63  VARCHAR2
    , p2_a64  VARCHAR2
    , p2_a65  VARCHAR2
    , p2_a66  VARCHAR2
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lease_qte_rec okl_lease_quote_pricing_pvt.lease_qte_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_lease_qte_rec.id := p2_a0;
    ddp_lease_qte_rec.object_version_number := p2_a1;
    ddp_lease_qte_rec.attribute_category := p2_a2;
    ddp_lease_qte_rec.attribute1 := p2_a3;
    ddp_lease_qte_rec.attribute2 := p2_a4;
    ddp_lease_qte_rec.attribute3 := p2_a5;
    ddp_lease_qte_rec.attribute4 := p2_a6;
    ddp_lease_qte_rec.attribute5 := p2_a7;
    ddp_lease_qte_rec.attribute6 := p2_a8;
    ddp_lease_qte_rec.attribute7 := p2_a9;
    ddp_lease_qte_rec.attribute8 := p2_a10;
    ddp_lease_qte_rec.attribute9 := p2_a11;
    ddp_lease_qte_rec.attribute10 := p2_a12;
    ddp_lease_qte_rec.attribute11 := p2_a13;
    ddp_lease_qte_rec.attribute12 := p2_a14;
    ddp_lease_qte_rec.attribute13 := p2_a15;
    ddp_lease_qte_rec.attribute14 := p2_a16;
    ddp_lease_qte_rec.attribute15 := p2_a17;
    ddp_lease_qte_rec.reference_number := p2_a18;
    ddp_lease_qte_rec.status := p2_a19;
    ddp_lease_qte_rec.parent_object_code := p2_a20;
    ddp_lease_qte_rec.parent_object_id := p2_a21;
    ddp_lease_qte_rec.valid_from := p2_a22;
    ddp_lease_qte_rec.valid_to := p2_a23;
    ddp_lease_qte_rec.customer_bookclass := p2_a24;
    ddp_lease_qte_rec.customer_taxowner := p2_a25;
    ddp_lease_qte_rec.expected_start_date := p2_a26;
    ddp_lease_qte_rec.expected_funding_date := p2_a27;
    ddp_lease_qte_rec.expected_delivery_date := p2_a28;
    ddp_lease_qte_rec.pricing_method := p2_a29;
    ddp_lease_qte_rec.term := p2_a30;
    ddp_lease_qte_rec.product_id := p2_a31;
    ddp_lease_qte_rec.end_of_term_option_id := p2_a32;
    ddp_lease_qte_rec.structured_pricing := p2_a33;
    ddp_lease_qte_rec.line_level_pricing := p2_a34;
    ddp_lease_qte_rec.rate_template_id := p2_a35;
    ddp_lease_qte_rec.rate_card_id := p2_a36;
    ddp_lease_qte_rec.lease_rate_factor := p2_a37;
    ddp_lease_qte_rec.target_rate_type := p2_a38;
    ddp_lease_qte_rec.target_rate := p2_a39;
    ddp_lease_qte_rec.target_amount := p2_a40;
    ddp_lease_qte_rec.target_frequency := p2_a41;
    ddp_lease_qte_rec.target_arrears_yn := p2_a42;
    ddp_lease_qte_rec.target_periods := p2_a43;
    ddp_lease_qte_rec.iir := p2_a44;
    ddp_lease_qte_rec.booking_yield := p2_a45;
    ddp_lease_qte_rec.pirr := p2_a46;
    ddp_lease_qte_rec.airr := p2_a47;
    ddp_lease_qte_rec.sub_iir := p2_a48;
    ddp_lease_qte_rec.sub_booking_yield := p2_a49;
    ddp_lease_qte_rec.sub_pirr := p2_a50;
    ddp_lease_qte_rec.sub_airr := p2_a51;
    ddp_lease_qte_rec.usage_category := p2_a52;
    ddp_lease_qte_rec.usage_industry_class := p2_a53;
    ddp_lease_qte_rec.usage_industry_code := p2_a54;
    ddp_lease_qte_rec.usage_amount := p2_a55;
    ddp_lease_qte_rec.usage_location_id := p2_a56;
    ddp_lease_qte_rec.property_tax_applicable := p2_a57;
    ddp_lease_qte_rec.property_tax_billing_type := p2_a58;
    ddp_lease_qte_rec.upfront_tax_treatment := p2_a59;
    ddp_lease_qte_rec.upfront_tax_stream_type := p2_a60;
    ddp_lease_qte_rec.transfer_of_title := p2_a61;
    ddp_lease_qte_rec.age_of_equipment := p2_a62;
    ddp_lease_qte_rec.purchase_of_lease := p2_a63;
    ddp_lease_qte_rec.sale_and_lease_back := p2_a64;
    ddp_lease_qte_rec.interest_disclosed := p2_a65;
    ddp_lease_qte_rec.primary_quote := p2_a66;
    ddp_lease_qte_rec.short_description := p2_a67;
    ddp_lease_qte_rec.description := p2_a68;
    ddp_lease_qte_rec.comments := p2_a69;




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pricing_pvt.create_update_payment(p_api_version,
      p_init_msg_list,
      ddp_lease_qte_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_update_line_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  NUMBER
    , p2_a25  NUMBER
    , p2_a26  VARCHAR2
    , p2_a27  DATE
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  NUMBER
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
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  VARCHAR2
    , p3_a27  NUMBER
    , p3_a28  NUMBER
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_rec okl_lease_quote_pricing_pvt.fee_rec_type;
    ddp_asset_rec okl_lease_quote_pricing_pvt.asset_rec_type;
    ddp_payment_header_rec okl_lease_quote_pricing_pvt.cashflow_hdr_rec_type;
    ddp_payment_level_tbl okl_lease_quote_pricing_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_fee_rec.id := p2_a0;
    ddp_fee_rec.object_version_number := p2_a1;
    ddp_fee_rec.attribute_category := p2_a2;
    ddp_fee_rec.attribute1 := p2_a3;
    ddp_fee_rec.attribute2 := p2_a4;
    ddp_fee_rec.attribute3 := p2_a5;
    ddp_fee_rec.attribute4 := p2_a6;
    ddp_fee_rec.attribute5 := p2_a7;
    ddp_fee_rec.attribute6 := p2_a8;
    ddp_fee_rec.attribute7 := p2_a9;
    ddp_fee_rec.attribute8 := p2_a10;
    ddp_fee_rec.attribute9 := p2_a11;
    ddp_fee_rec.attribute10 := p2_a12;
    ddp_fee_rec.attribute11 := p2_a13;
    ddp_fee_rec.attribute12 := p2_a14;
    ddp_fee_rec.attribute13 := p2_a15;
    ddp_fee_rec.attribute14 := p2_a16;
    ddp_fee_rec.attribute15 := p2_a17;
    ddp_fee_rec.parent_object_code := p2_a18;
    ddp_fee_rec.parent_object_id := p2_a19;
    ddp_fee_rec.stream_type_id := p2_a20;
    ddp_fee_rec.fee_type := p2_a21;
    ddp_fee_rec.structured_pricing := p2_a22;
    ddp_fee_rec.rate_template_id := p2_a23;
    ddp_fee_rec.rate_card_id := p2_a24;
    ddp_fee_rec.lease_rate_factor := p2_a25;
    ddp_fee_rec.target_arrears := p2_a26;
    ddp_fee_rec.effective_from := p2_a27;
    ddp_fee_rec.effective_to := p2_a28;
    ddp_fee_rec.supplier_id := p2_a29;
    ddp_fee_rec.rollover_quote_id := p2_a30;
    ddp_fee_rec.initial_direct_cost := p2_a31;
    ddp_fee_rec.fee_amount := p2_a32;
    ddp_fee_rec.target_amount := p2_a33;
    ddp_fee_rec.target_frequency := p2_a34;
    ddp_fee_rec.short_description := p2_a35;
    ddp_fee_rec.description := p2_a36;
    ddp_fee_rec.comments := p2_a37;
    ddp_fee_rec.payment_type_id := p2_a38;

    ddp_asset_rec.id := p3_a0;
    ddp_asset_rec.object_version_number := p3_a1;
    ddp_asset_rec.attribute_category := p3_a2;
    ddp_asset_rec.attribute1 := p3_a3;
    ddp_asset_rec.attribute2 := p3_a4;
    ddp_asset_rec.attribute3 := p3_a5;
    ddp_asset_rec.attribute4 := p3_a6;
    ddp_asset_rec.attribute5 := p3_a7;
    ddp_asset_rec.attribute6 := p3_a8;
    ddp_asset_rec.attribute7 := p3_a9;
    ddp_asset_rec.attribute8 := p3_a10;
    ddp_asset_rec.attribute9 := p3_a11;
    ddp_asset_rec.attribute10 := p3_a12;
    ddp_asset_rec.attribute11 := p3_a13;
    ddp_asset_rec.attribute12 := p3_a14;
    ddp_asset_rec.attribute13 := p3_a15;
    ddp_asset_rec.attribute14 := p3_a16;
    ddp_asset_rec.attribute15 := p3_a17;
    ddp_asset_rec.parent_object_code := p3_a18;
    ddp_asset_rec.parent_object_id := p3_a19;
    ddp_asset_rec.asset_number := p3_a20;
    ddp_asset_rec.install_site_id := p3_a21;
    ddp_asset_rec.structured_pricing := p3_a22;
    ddp_asset_rec.rate_template_id := p3_a23;
    ddp_asset_rec.rate_card_id := p3_a24;
    ddp_asset_rec.lease_rate_factor := p3_a25;
    ddp_asset_rec.target_arrears := p3_a26;
    ddp_asset_rec.oec := p3_a27;
    ddp_asset_rec.oec_percentage := p3_a28;
    ddp_asset_rec.end_of_term_value_default := p3_a29;
    ddp_asset_rec.end_of_term_value := p3_a30;
    ddp_asset_rec.orig_asset_id := p3_a31;
    ddp_asset_rec.target_amount := p3_a32;
    ddp_asset_rec.target_frequency := p3_a33;
    ddp_asset_rec.short_description := p3_a34;
    ddp_asset_rec.description := p3_a35;
    ddp_asset_rec.comments := p3_a36;

    ddp_payment_header_rec.type_code := p4_a0;
    ddp_payment_header_rec.stream_type_id := p4_a1;
    ddp_payment_header_rec.status_code := p4_a2;
    ddp_payment_header_rec.arrears_flag := p4_a3;
    ddp_payment_header_rec.frequency_code := p4_a4;
    ddp_payment_header_rec.dnz_periods := p4_a5;
    ddp_payment_header_rec.dnz_periodic_amount := p4_a6;
    ddp_payment_header_rec.parent_object_code := p4_a7;
    ddp_payment_header_rec.parent_object_id := p4_a8;
    ddp_payment_header_rec.quote_type_code := p4_a9;
    ddp_payment_header_rec.quote_id := p4_a10;
    ddp_payment_header_rec.cashflow_header_id := p4_a11;
    ddp_payment_header_rec.cashflow_object_id := p4_a12;
    ddp_payment_header_rec.cashflow_header_ovn := p4_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_payment_level_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pricing_pvt.create_update_line_payment(p_api_version,
      p_init_msg_list,
      ddp_fee_rec,
      ddp_asset_rec,
      ddp_payment_header_rec,
      ddp_payment_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_update_line_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  NUMBER
    , p2_a25  NUMBER
    , p2_a26  VARCHAR2
    , p2_a27  DATE
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_rec okl_lease_quote_pricing_pvt.fee_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_fee_rec.id := p2_a0;
    ddp_fee_rec.object_version_number := p2_a1;
    ddp_fee_rec.attribute_category := p2_a2;
    ddp_fee_rec.attribute1 := p2_a3;
    ddp_fee_rec.attribute2 := p2_a4;
    ddp_fee_rec.attribute3 := p2_a5;
    ddp_fee_rec.attribute4 := p2_a6;
    ddp_fee_rec.attribute5 := p2_a7;
    ddp_fee_rec.attribute6 := p2_a8;
    ddp_fee_rec.attribute7 := p2_a9;
    ddp_fee_rec.attribute8 := p2_a10;
    ddp_fee_rec.attribute9 := p2_a11;
    ddp_fee_rec.attribute10 := p2_a12;
    ddp_fee_rec.attribute11 := p2_a13;
    ddp_fee_rec.attribute12 := p2_a14;
    ddp_fee_rec.attribute13 := p2_a15;
    ddp_fee_rec.attribute14 := p2_a16;
    ddp_fee_rec.attribute15 := p2_a17;
    ddp_fee_rec.parent_object_code := p2_a18;
    ddp_fee_rec.parent_object_id := p2_a19;
    ddp_fee_rec.stream_type_id := p2_a20;
    ddp_fee_rec.fee_type := p2_a21;
    ddp_fee_rec.structured_pricing := p2_a22;
    ddp_fee_rec.rate_template_id := p2_a23;
    ddp_fee_rec.rate_card_id := p2_a24;
    ddp_fee_rec.lease_rate_factor := p2_a25;
    ddp_fee_rec.target_arrears := p2_a26;
    ddp_fee_rec.effective_from := p2_a27;
    ddp_fee_rec.effective_to := p2_a28;
    ddp_fee_rec.supplier_id := p2_a29;
    ddp_fee_rec.rollover_quote_id := p2_a30;
    ddp_fee_rec.initial_direct_cost := p2_a31;
    ddp_fee_rec.fee_amount := p2_a32;
    ddp_fee_rec.target_amount := p2_a33;
    ddp_fee_rec.target_frequency := p2_a34;
    ddp_fee_rec.short_description := p2_a35;
    ddp_fee_rec.description := p2_a36;
    ddp_fee_rec.comments := p2_a37;
    ddp_fee_rec.payment_type_id := p2_a38;




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pricing_pvt.create_update_line_payment(p_api_version,
      p_init_msg_list,
      ddp_fee_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_update_line_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  NUMBER
    , p2_a20  VARCHAR2
    , p2_a21  NUMBER
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  NUMBER
    , p2_a25  NUMBER
    , p2_a26  VARCHAR2
    , p2_a27  NUMBER
    , p2_a28  NUMBER
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_rec okl_lease_quote_pricing_pvt.asset_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_asset_rec.id := p2_a0;
    ddp_asset_rec.object_version_number := p2_a1;
    ddp_asset_rec.attribute_category := p2_a2;
    ddp_asset_rec.attribute1 := p2_a3;
    ddp_asset_rec.attribute2 := p2_a4;
    ddp_asset_rec.attribute3 := p2_a5;
    ddp_asset_rec.attribute4 := p2_a6;
    ddp_asset_rec.attribute5 := p2_a7;
    ddp_asset_rec.attribute6 := p2_a8;
    ddp_asset_rec.attribute7 := p2_a9;
    ddp_asset_rec.attribute8 := p2_a10;
    ddp_asset_rec.attribute9 := p2_a11;
    ddp_asset_rec.attribute10 := p2_a12;
    ddp_asset_rec.attribute11 := p2_a13;
    ddp_asset_rec.attribute12 := p2_a14;
    ddp_asset_rec.attribute13 := p2_a15;
    ddp_asset_rec.attribute14 := p2_a16;
    ddp_asset_rec.attribute15 := p2_a17;
    ddp_asset_rec.parent_object_code := p2_a18;
    ddp_asset_rec.parent_object_id := p2_a19;
    ddp_asset_rec.asset_number := p2_a20;
    ddp_asset_rec.install_site_id := p2_a21;
    ddp_asset_rec.structured_pricing := p2_a22;
    ddp_asset_rec.rate_template_id := p2_a23;
    ddp_asset_rec.rate_card_id := p2_a24;
    ddp_asset_rec.lease_rate_factor := p2_a25;
    ddp_asset_rec.target_arrears := p2_a26;
    ddp_asset_rec.oec := p2_a27;
    ddp_asset_rec.oec_percentage := p2_a28;
    ddp_asset_rec.end_of_term_value_default := p2_a29;
    ddp_asset_rec.end_of_term_value := p2_a30;
    ddp_asset_rec.orig_asset_id := p2_a31;
    ddp_asset_rec.target_amount := p2_a32;
    ddp_asset_rec.target_frequency := p2_a33;
    ddp_asset_rec.short_description := p2_a34;
    ddp_asset_rec.description := p2_a35;
    ddp_asset_rec.comments := p2_a36;




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_pricing_pvt.create_update_line_payment(p_api_version,
      p_init_msg_list,
      ddp_asset_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_lease_quote_pricing_pvt_w;

/
