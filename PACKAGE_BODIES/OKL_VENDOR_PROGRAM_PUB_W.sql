--------------------------------------------------------
--  DDL for Package Body OKL_VENDOR_PROGRAM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDOR_PROGRAM_PUB_W" as
  /* $Header: OKLUPRMB.pls 120.8 2005/12/29 08:42:57 abindal noship $ */
  procedure create_program(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  DATE
    , p5_a3  DATE
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p_parent_agreement_number  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
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
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  DATE
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  DATE
    , p7_a39 out nocopy  DATE
    , p7_a40 out nocopy  DATE
    , p7_a41 out nocopy  DATE
    , p7_a42 out nocopy  DATE
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  DATE
    , p7_a45 out nocopy  DATE
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  NUMBER
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  NUMBER
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  NUMBER
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  NUMBER
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  DATE
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  DATE
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  VARCHAR2
    , p7_a74 out nocopy  VARCHAR2
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  VARCHAR2
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  VARCHAR2
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  VARCHAR2
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  DATE
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  DATE
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  VARCHAR2
    , p7_a90 out nocopy  VARCHAR2
    , p7_a91 out nocopy  VARCHAR2
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  VARCHAR2
    , p7_a94 out nocopy  NUMBER
    , p7_a95 out nocopy  DATE
    , p7_a96 out nocopy  NUMBER
    , p7_a97 out nocopy  NUMBER
    , p7_a98 out nocopy  NUMBER
    , p7_a99 out nocopy  NUMBER
    , p7_a100 out nocopy  VARCHAR2
    , p7_a101 out nocopy  NUMBER
    , p7_a102 out nocopy  DATE
    , p7_a103 out nocopy  NUMBER
    , p7_a104 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  DATE
    , p8_a38 out nocopy  NUMBER
    , p8_a39 out nocopy  DATE
    , p8_a40 out nocopy  NUMBER
    , p8_a41 out nocopy  NUMBER
    , p8_a42 out nocopy  NUMBER
    , p8_a43 out nocopy  NUMBER
    , p8_a44 out nocopy  NUMBER
    , p8_a45 out nocopy  NUMBER
    , p8_a46 out nocopy  NUMBER
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  DATE
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  NUMBER
    , p8_a53 out nocopy  DATE
    , p8_a54 out nocopy  DATE
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  VARCHAR2
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  DATE
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  VARCHAR2
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  NUMBER
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  NUMBER
    , p8_a76 out nocopy  NUMBER
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  DATE
    , p8_a79 out nocopy  DATE
    , p8_a80 out nocopy  NUMBER
    , p8_a81 out nocopy  VARCHAR2
    , p8_a82 out nocopy  VARCHAR
  )

  as
    ddp_hdr_rec okl_vendor_program_pub.program_header_rec_type;
    ddx_header_rec okl_vendor_program_pub.chrv_rec_type;
    ddx_k_header_rec okl_vendor_program_pub.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_hdr_rec.p_agreement_number := p5_a0;
    ddp_hdr_rec.p_contract_category := p5_a1;
    ddp_hdr_rec.p_start_date := p5_a2;
    ddp_hdr_rec.p_end_date := p5_a3;
    ddp_hdr_rec.p_short_description := p5_a4;
    ddp_hdr_rec.p_description := p5_a5;
    ddp_hdr_rec.p_comments := p5_a6;
    ddp_hdr_rec.p_template_yn := p5_a7;
    ddp_hdr_rec.p_qcl_id := p5_a8;
    ddp_hdr_rec.p_issue_or_receive := p5_a9;
    ddp_hdr_rec.p_workflow_process := p5_a10;
    ddp_hdr_rec.p_referred_id := p5_a11;
    ddp_hdr_rec.p_object1_id1 := p5_a12;
    ddp_hdr_rec.p_object1_id2 := p5_a13;
    ddp_hdr_rec.p_attribute_category := p5_a14;
    ddp_hdr_rec.p_attribute1 := p5_a15;
    ddp_hdr_rec.p_attribute2 := p5_a16;
    ddp_hdr_rec.p_attribute3 := p5_a17;
    ddp_hdr_rec.p_attribute4 := p5_a18;
    ddp_hdr_rec.p_attribute5 := p5_a19;
    ddp_hdr_rec.p_attribute6 := p5_a20;
    ddp_hdr_rec.p_attribute7 := p5_a21;
    ddp_hdr_rec.p_attribute8 := p5_a22;
    ddp_hdr_rec.p_attribute9 := p5_a23;
    ddp_hdr_rec.p_attribute10 := p5_a24;
    ddp_hdr_rec.p_attribute11 := p5_a25;
    ddp_hdr_rec.p_attribute12 := p5_a26;
    ddp_hdr_rec.p_attribute13 := p5_a27;
    ddp_hdr_rec.p_attribute14 := p5_a28;
    ddp_hdr_rec.p_attribute15 := p5_a29;




    -- here's the delegated call to the old PL/SQL routine
    okl_vendor_program_pub.create_program(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_hdr_rec,
      p_parent_agreement_number,
      ddx_header_rec,
      ddx_k_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_header_rec.id;
    p7_a1 := ddx_header_rec.object_version_number;
    p7_a2 := ddx_header_rec.sfwt_flag;
    p7_a3 := ddx_header_rec.chr_id_response;
    p7_a4 := ddx_header_rec.chr_id_award;
    p7_a5 := ddx_header_rec.chr_id_renewed;
    p7_a6 := ddx_header_rec.inv_organization_id;
    p7_a7 := ddx_header_rec.sts_code;
    p7_a8 := ddx_header_rec.qcl_id;
    p7_a9 := ddx_header_rec.scs_code;
    p7_a10 := ddx_header_rec.contract_number;
    p7_a11 := ddx_header_rec.currency_code;
    p7_a12 := ddx_header_rec.contract_number_modifier;
    p7_a13 := ddx_header_rec.archived_yn;
    p7_a14 := ddx_header_rec.deleted_yn;
    p7_a15 := ddx_header_rec.cust_po_number_req_yn;
    p7_a16 := ddx_header_rec.pre_pay_req_yn;
    p7_a17 := ddx_header_rec.cust_po_number;
    p7_a18 := ddx_header_rec.short_description;
    p7_a19 := ddx_header_rec.comments;
    p7_a20 := ddx_header_rec.description;
    p7_a21 := ddx_header_rec.dpas_rating;
    p7_a22 := ddx_header_rec.cognomen;
    p7_a23 := ddx_header_rec.template_yn;
    p7_a24 := ddx_header_rec.template_used;
    p7_a25 := ddx_header_rec.date_approved;
    p7_a26 := ddx_header_rec.datetime_cancelled;
    p7_a27 := ddx_header_rec.auto_renew_days;
    p7_a28 := ddx_header_rec.date_issued;
    p7_a29 := ddx_header_rec.datetime_responded;
    p7_a30 := ddx_header_rec.non_response_reason;
    p7_a31 := ddx_header_rec.non_response_explain;
    p7_a32 := ddx_header_rec.rfp_type;
    p7_a33 := ddx_header_rec.chr_type;
    p7_a34 := ddx_header_rec.keep_on_mail_list;
    p7_a35 := ddx_header_rec.set_aside_reason;
    p7_a36 := ddx_header_rec.set_aside_percent;
    p7_a37 := ddx_header_rec.response_copies_req;
    p7_a38 := ddx_header_rec.date_close_projected;
    p7_a39 := ddx_header_rec.datetime_proposed;
    p7_a40 := ddx_header_rec.date_signed;
    p7_a41 := ddx_header_rec.date_terminated;
    p7_a42 := ddx_header_rec.date_renewed;
    p7_a43 := ddx_header_rec.trn_code;
    p7_a44 := ddx_header_rec.start_date;
    p7_a45 := ddx_header_rec.end_date;
    p7_a46 := ddx_header_rec.authoring_org_id;
    p7_a47 := ddx_header_rec.buy_or_sell;
    p7_a48 := ddx_header_rec.issue_or_receive;
    p7_a49 := ddx_header_rec.estimated_amount;
    p7_a50 := ddx_header_rec.chr_id_renewed_to;
    p7_a51 := ddx_header_rec.estimated_amount_renewed;
    p7_a52 := ddx_header_rec.currency_code_renewed;
    p7_a53 := ddx_header_rec.upg_orig_system_ref;
    p7_a54 := ddx_header_rec.upg_orig_system_ref_id;
    p7_a55 := ddx_header_rec.application_id;
    p7_a56 := ddx_header_rec.orig_system_source_code;
    p7_a57 := ddx_header_rec.orig_system_id1;
    p7_a58 := ddx_header_rec.orig_system_reference1;
    p7_a59 := ddx_header_rec.program_id;
    p7_a60 := ddx_header_rec.request_id;
    p7_a61 := ddx_header_rec.price_list_id;
    p7_a62 := ddx_header_rec.pricing_date;
    p7_a63 := ddx_header_rec.sign_by_date;
    p7_a64 := ddx_header_rec.program_update_date;
    p7_a65 := ddx_header_rec.total_line_list_price;
    p7_a66 := ddx_header_rec.program_application_id;
    p7_a67 := ddx_header_rec.user_estimated_amount;
    p7_a68 := ddx_header_rec.attribute_category;
    p7_a69 := ddx_header_rec.attribute1;
    p7_a70 := ddx_header_rec.attribute2;
    p7_a71 := ddx_header_rec.attribute3;
    p7_a72 := ddx_header_rec.attribute4;
    p7_a73 := ddx_header_rec.attribute5;
    p7_a74 := ddx_header_rec.attribute6;
    p7_a75 := ddx_header_rec.attribute7;
    p7_a76 := ddx_header_rec.attribute8;
    p7_a77 := ddx_header_rec.attribute9;
    p7_a78 := ddx_header_rec.attribute10;
    p7_a79 := ddx_header_rec.attribute11;
    p7_a80 := ddx_header_rec.attribute12;
    p7_a81 := ddx_header_rec.attribute13;
    p7_a82 := ddx_header_rec.attribute14;
    p7_a83 := ddx_header_rec.attribute15;
    p7_a84 := ddx_header_rec.created_by;
    p7_a85 := ddx_header_rec.creation_date;
    p7_a86 := ddx_header_rec.last_updated_by;
    p7_a87 := ddx_header_rec.last_update_date;
    p7_a88 := ddx_header_rec.last_update_login;
    p7_a89 := ddx_header_rec.old_sts_code;
    p7_a90 := ddx_header_rec.new_sts_code;
    p7_a91 := ddx_header_rec.old_ste_code;
    p7_a92 := ddx_header_rec.new_ste_code;
    p7_a93 := ddx_header_rec.conversion_type;
    p7_a94 := ddx_header_rec.conversion_rate;
    p7_a95 := ddx_header_rec.conversion_rate_date;
    p7_a96 := ddx_header_rec.conversion_euro_rate;
    p7_a97 := ddx_header_rec.cust_acct_id;
    p7_a98 := ddx_header_rec.bill_to_site_use_id;
    p7_a99 := ddx_header_rec.inv_rule_id;
    p7_a100 := ddx_header_rec.renewal_type_code;
    p7_a101 := ddx_header_rec.renewal_notify_to;
    p7_a102 := ddx_header_rec.renewal_end_date;
    p7_a103 := ddx_header_rec.ship_to_site_use_id;
    p7_a104 := ddx_header_rec.payment_term_id;

    p8_a0 := ddx_k_header_rec.id;
    p8_a1 := ddx_k_header_rec.object_version_number;
    p8_a2 := ddx_k_header_rec.isg_id;
    p8_a3 := ddx_k_header_rec.khr_id;
    p8_a4 := ddx_k_header_rec.pdt_id;
    p8_a5 := ddx_k_header_rec.amd_code;
    p8_a6 := ddx_k_header_rec.date_first_activity;
    p8_a7 := ddx_k_header_rec.generate_accrual_yn;
    p8_a8 := ddx_k_header_rec.generate_accrual_override_yn;
    p8_a9 := ddx_k_header_rec.date_refinanced;
    p8_a10 := ddx_k_header_rec.credit_act_yn;
    p8_a11 := ddx_k_header_rec.term_duration;
    p8_a12 := ddx_k_header_rec.converted_account_yn;
    p8_a13 := ddx_k_header_rec.date_conversion_effective;
    p8_a14 := ddx_k_header_rec.syndicatable_yn;
    p8_a15 := ddx_k_header_rec.salestype_yn;
    p8_a16 := ddx_k_header_rec.date_deal_transferred;
    p8_a17 := ddx_k_header_rec.datetime_proposal_effective;
    p8_a18 := ddx_k_header_rec.datetime_proposal_ineffective;
    p8_a19 := ddx_k_header_rec.date_proposal_accepted;
    p8_a20 := ddx_k_header_rec.attribute_category;
    p8_a21 := ddx_k_header_rec.attribute1;
    p8_a22 := ddx_k_header_rec.attribute2;
    p8_a23 := ddx_k_header_rec.attribute3;
    p8_a24 := ddx_k_header_rec.attribute4;
    p8_a25 := ddx_k_header_rec.attribute5;
    p8_a26 := ddx_k_header_rec.attribute6;
    p8_a27 := ddx_k_header_rec.attribute7;
    p8_a28 := ddx_k_header_rec.attribute8;
    p8_a29 := ddx_k_header_rec.attribute9;
    p8_a30 := ddx_k_header_rec.attribute10;
    p8_a31 := ddx_k_header_rec.attribute11;
    p8_a32 := ddx_k_header_rec.attribute12;
    p8_a33 := ddx_k_header_rec.attribute13;
    p8_a34 := ddx_k_header_rec.attribute14;
    p8_a35 := ddx_k_header_rec.attribute15;
    p8_a36 := ddx_k_header_rec.created_by;
    p8_a37 := ddx_k_header_rec.creation_date;
    p8_a38 := ddx_k_header_rec.last_updated_by;
    p8_a39 := ddx_k_header_rec.last_update_date;
    p8_a40 := ddx_k_header_rec.last_update_login;
    p8_a41 := ddx_k_header_rec.pre_tax_yield;
    p8_a42 := ddx_k_header_rec.after_tax_yield;
    p8_a43 := ddx_k_header_rec.implicit_interest_rate;
    p8_a44 := ddx_k_header_rec.implicit_non_idc_interest_rate;
    p8_a45 := ddx_k_header_rec.target_pre_tax_yield;
    p8_a46 := ddx_k_header_rec.target_after_tax_yield;
    p8_a47 := ddx_k_header_rec.target_implicit_interest_rate;
    p8_a48 := ddx_k_header_rec.target_implicit_nonidc_intrate;
    p8_a49 := ddx_k_header_rec.date_last_interim_interest_cal;
    p8_a50 := ddx_k_header_rec.deal_type;
    p8_a51 := ddx_k_header_rec.pre_tax_irr;
    p8_a52 := ddx_k_header_rec.after_tax_irr;
    p8_a53 := ddx_k_header_rec.expected_delivery_date;
    p8_a54 := ddx_k_header_rec.accepted_date;
    p8_a55 := ddx_k_header_rec.prefunding_eligible_yn;
    p8_a56 := ddx_k_header_rec.revolving_credit_yn;
    p8_a57 := ddx_k_header_rec.currency_conversion_type;
    p8_a58 := ddx_k_header_rec.currency_conversion_rate;
    p8_a59 := ddx_k_header_rec.currency_conversion_date;
    p8_a60 := ddx_k_header_rec.multi_gaap_yn;
    p8_a61 := ddx_k_header_rec.recourse_code;
    p8_a62 := ddx_k_header_rec.lessor_serv_org_code;
    p8_a63 := ddx_k_header_rec.assignable_yn;
    p8_a64 := ddx_k_header_rec.securitized_code;
    p8_a65 := ddx_k_header_rec.securitization_type;
    p8_a66 := ddx_k_header_rec.sub_pre_tax_yield;
    p8_a67 := ddx_k_header_rec.sub_after_tax_yield;
    p8_a68 := ddx_k_header_rec.sub_impl_interest_rate;
    p8_a69 := ddx_k_header_rec.sub_impl_non_idc_int_rate;
    p8_a70 := ddx_k_header_rec.sub_pre_tax_irr;
    p8_a71 := ddx_k_header_rec.sub_after_tax_irr;
    p8_a72 := ddx_k_header_rec.tot_cl_transfer_amt;
    p8_a73 := ddx_k_header_rec.tot_cl_net_transfer_amt;
    p8_a74 := ddx_k_header_rec.tot_cl_limit;
    p8_a75 := ddx_k_header_rec.tot_cl_funding_amt;
    p8_a76 := ddx_k_header_rec.crs_id;
    p8_a77 := ddx_k_header_rec.template_type_code;
    p8_a78 := ddx_k_header_rec.date_funding_expected;
    p8_a79 := ddx_k_header_rec.date_tradein;
    p8_a80 := ddx_k_header_rec.tradein_amount;
    p8_a81 := ddx_k_header_rec.tradein_description;
    p8_a82 := ddx_k_header_rec.validate_dff_yn;
  end;

  procedure update_program(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  DATE
    , p5_a3  DATE
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p_program_id  NUMBER
    , p_parent_agreement_id  NUMBER
  )

  as
    ddp_hdr_rec okl_vendor_program_pub.program_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_hdr_rec.p_agreement_number := p5_a0;
    ddp_hdr_rec.p_contract_category := p5_a1;
    ddp_hdr_rec.p_start_date := p5_a2;
    ddp_hdr_rec.p_end_date := p5_a3;
    ddp_hdr_rec.p_short_description := p5_a4;
    ddp_hdr_rec.p_description := p5_a5;
    ddp_hdr_rec.p_comments := p5_a6;
    ddp_hdr_rec.p_template_yn := p5_a7;
    ddp_hdr_rec.p_qcl_id := p5_a8;
    ddp_hdr_rec.p_issue_or_receive := p5_a9;
    ddp_hdr_rec.p_workflow_process := p5_a10;
    ddp_hdr_rec.p_referred_id := p5_a11;
    ddp_hdr_rec.p_object1_id1 := p5_a12;
    ddp_hdr_rec.p_object1_id2 := p5_a13;
    ddp_hdr_rec.p_attribute_category := p5_a14;
    ddp_hdr_rec.p_attribute1 := p5_a15;
    ddp_hdr_rec.p_attribute2 := p5_a16;
    ddp_hdr_rec.p_attribute3 := p5_a17;
    ddp_hdr_rec.p_attribute4 := p5_a18;
    ddp_hdr_rec.p_attribute5 := p5_a19;
    ddp_hdr_rec.p_attribute6 := p5_a20;
    ddp_hdr_rec.p_attribute7 := p5_a21;
    ddp_hdr_rec.p_attribute8 := p5_a22;
    ddp_hdr_rec.p_attribute9 := p5_a23;
    ddp_hdr_rec.p_attribute10 := p5_a24;
    ddp_hdr_rec.p_attribute11 := p5_a25;
    ddp_hdr_rec.p_attribute12 := p5_a26;
    ddp_hdr_rec.p_attribute13 := p5_a27;
    ddp_hdr_rec.p_attribute14 := p5_a28;
    ddp_hdr_rec.p_attribute15 := p5_a29;



    -- here's the delegated call to the old PL/SQL routine
    okl_vendor_program_pub.update_program(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_hdr_rec,
      p_program_id,
      p_parent_agreement_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_vendor_program_pub_w;

/
