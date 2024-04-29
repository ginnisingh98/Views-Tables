--------------------------------------------------------
--  DDL for Package Body AS_OPPORTUNITY_PUB_W4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPPORTUNITY_PUB_W4" as
  /* $Header: asxwop4b.pls 120.2 2005/08/04 03:06 appldev ship $ */
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

  procedure create_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_VARCHAR2_TABLE_200
    , p5_a31 JTF_VARCHAR2_TABLE_200
    , p5_a32 JTF_VARCHAR2_TABLE_200
    , p5_a33 JTF_VARCHAR2_TABLE_200
    , p5_a34 JTF_VARCHAR2_TABLE_200
    , p5_a35 JTF_VARCHAR2_TABLE_200
    , p5_a36 JTF_VARCHAR2_TABLE_200
    , p5_a37 JTF_VARCHAR2_TABLE_200
    , p5_a38 JTF_VARCHAR2_TABLE_200
    , p5_a39 JTF_VARCHAR2_TABLE_200
    , p5_a40 JTF_VARCHAR2_TABLE_200
    , p5_a41 JTF_VARCHAR2_TABLE_200
    , p5_a42 JTF_VARCHAR2_TABLE_200
    , p5_a43 JTF_VARCHAR2_TABLE_200
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_VARCHAR2_TABLE_300
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  DATE := fnd_api.g_miss_date
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  DATE := fnd_api.g_miss_date
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  NUMBER := 0-1962.0724
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  DATE := fnd_api.g_miss_date
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  VARCHAR2 := fnd_api.g_miss_char
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  VARCHAR2 := fnd_api.g_miss_char
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_contact_tbl as_opportunity_pub.contact_tbl_type;
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_contact_out_tbl as_opportunity_pub.contact_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p38(ddp_contact_tbl, p5_a0
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
      );

    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p6_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p6_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p6_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p6_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p6_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p6_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p6_a9);
    ddp_header_rec.lead_number := p6_a10;
    ddp_header_rec.orig_system_reference := p6_a11;
    ddp_header_rec.lead_source_code := p6_a12;
    ddp_header_rec.lead_source := p6_a13;
    ddp_header_rec.description := p6_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p6_a15);
    ddp_header_rec.source_promotion_code := p6_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p6_a17);
    ddp_header_rec.customer_name := p6_a18;
    ddp_header_rec.customer_name_phonetic := p6_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p6_a20);
    ddp_header_rec.address := p6_a21;
    ddp_header_rec.address2 := p6_a22;
    ddp_header_rec.address3 := p6_a23;
    ddp_header_rec.address4 := p6_a24;
    ddp_header_rec.city := p6_a25;
    ddp_header_rec.state := p6_a26;
    ddp_header_rec.country := p6_a27;
    ddp_header_rec.province := p6_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p6_a29);
    ddp_header_rec.sales_stage := p6_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p6_a31);
    ddp_header_rec.status_code := p6_a32;
    ddp_header_rec.status := p6_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p6_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p6_a35);
    ddp_header_rec.channel_code := p6_a36;
    ddp_header_rec.channel := p6_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p6_a38);
    ddp_header_rec.currency_code := p6_a39;
    ddp_header_rec.to_currency_code := p6_a40;
    ddp_header_rec.close_reason_code := p6_a41;
    ddp_header_rec.close_reason := p6_a42;
    ddp_header_rec.close_competitor_code := p6_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p6_a44);
    ddp_header_rec.close_competitor := p6_a45;
    ddp_header_rec.close_comment := p6_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p6_a47);
    ddp_header_rec.end_user_customer_name := p6_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p6_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p6_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p6_a51);
    ddp_header_rec.parent_project := p6_a52;
    ddp_header_rec.parent_project_code := p6_a53;
    ddp_header_rec.updateable_flag := p6_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p6_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p6_a56);
    ddp_header_rec.rank := p6_a57;
    ddp_header_rec.member_access := p6_a58;
    ddp_header_rec.member_role := p6_a59;
    ddp_header_rec.deleted_flag := p6_a60;
    ddp_header_rec.auto_assignment_type := p6_a61;
    ddp_header_rec.prm_assignment_type := p6_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p6_a63);
    ddp_header_rec.methodology_code := p6_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p6_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p6_a66);
    ddp_header_rec.decision_timeframe_code := p6_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p6_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p6_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p6_a70);
    ddp_header_rec.vehicle_response_code := p6_a71;
    ddp_header_rec.budget_status_code := p6_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p6_a73);
    ddp_header_rec.no_opp_allowed_flag := p6_a74;
    ddp_header_rec.delete_allowed_flag := p6_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p6_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p6_a77;
    ddp_header_rec.prm_ind_classification_code := p6_a78;
    ddp_header_rec.prm_lead_type := p6_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p6_a80);
    ddp_header_rec.freeze_flag := p6_a81;
    ddp_header_rec.attribute_category := p6_a82;
    ddp_header_rec.attribute1 := p6_a83;
    ddp_header_rec.attribute2 := p6_a84;
    ddp_header_rec.attribute3 := p6_a85;
    ddp_header_rec.attribute4 := p6_a86;
    ddp_header_rec.attribute5 := p6_a87;
    ddp_header_rec.attribute6 := p6_a88;
    ddp_header_rec.attribute7 := p6_a89;
    ddp_header_rec.attribute8 := p6_a90;
    ddp_header_rec.attribute9 := p6_a91;
    ddp_header_rec.attribute10 := p6_a92;
    ddp_header_rec.attribute11 := p6_a93;
    ddp_header_rec.attribute12 := p6_a94;
    ddp_header_rec.attribute13 := p6_a95;
    ddp_header_rec.attribute14 := p6_a96;
    ddp_header_rec.attribute15 := p6_a97;
    ddp_header_rec.prm_referral_code := p6_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p6_a99);





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p11_a0
      , p11_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.create_contacts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_contact_tbl,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_contact_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    as_opportunity_pub_w.rosetta_table_copy_out_p41(ddx_contact_out_tbl, p12_a0
      , p12_a1
      );



  end;

  procedure update_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_VARCHAR2_TABLE_200
    , p5_a31 JTF_VARCHAR2_TABLE_200
    , p5_a32 JTF_VARCHAR2_TABLE_200
    , p5_a33 JTF_VARCHAR2_TABLE_200
    , p5_a34 JTF_VARCHAR2_TABLE_200
    , p5_a35 JTF_VARCHAR2_TABLE_200
    , p5_a36 JTF_VARCHAR2_TABLE_200
    , p5_a37 JTF_VARCHAR2_TABLE_200
    , p5_a38 JTF_VARCHAR2_TABLE_200
    , p5_a39 JTF_VARCHAR2_TABLE_200
    , p5_a40 JTF_VARCHAR2_TABLE_200
    , p5_a41 JTF_VARCHAR2_TABLE_200
    , p5_a42 JTF_VARCHAR2_TABLE_200
    , p5_a43 JTF_VARCHAR2_TABLE_200
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_contact_tbl as_opportunity_pub.contact_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_contact_out_tbl as_opportunity_pub.contact_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p38(ddp_contact_tbl, p5_a0
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
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_contacts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_contact_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_contact_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p41(ddx_contact_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure delete_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_VARCHAR2_TABLE_200
    , p5_a31 JTF_VARCHAR2_TABLE_200
    , p5_a32 JTF_VARCHAR2_TABLE_200
    , p5_a33 JTF_VARCHAR2_TABLE_200
    , p5_a34 JTF_VARCHAR2_TABLE_200
    , p5_a35 JTF_VARCHAR2_TABLE_200
    , p5_a36 JTF_VARCHAR2_TABLE_200
    , p5_a37 JTF_VARCHAR2_TABLE_200
    , p5_a38 JTF_VARCHAR2_TABLE_200
    , p5_a39 JTF_VARCHAR2_TABLE_200
    , p5_a40 JTF_VARCHAR2_TABLE_200
    , p5_a41 JTF_VARCHAR2_TABLE_200
    , p5_a42 JTF_VARCHAR2_TABLE_200
    , p5_a43 JTF_VARCHAR2_TABLE_200
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_contact_tbl as_opportunity_pub.contact_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_contact_out_tbl as_opportunity_pub.contact_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p38(ddp_contact_tbl, p5_a0
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
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_contacts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_contact_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_contact_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p41(ddx_contact_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure delete_salesteams(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_DATE_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_VARCHAR2_TABLE_300
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_VARCHAR2_TABLE_100
    , p4_a16 JTF_VARCHAR2_TABLE_300
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_NUMBER_TABLE
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_DATE_TABLE
    , p4_a31 JTF_VARCHAR2_TABLE_300
    , p4_a32 JTF_DATE_TABLE
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_100
    , p4_a52 JTF_VARCHAR2_TABLE_100
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_NUMBER_TABLE
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_VARCHAR2_TABLE_100
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_100
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_team_tbl as_access_pub.sales_team_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    as_access_pub_w.rosetta_table_copy_in_p2(ddp_sales_team_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      );






    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_salesteams(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_sales_team_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure copy_opportunity(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_lead_id  NUMBER
    , p_description  VARCHAR2
    , p_copy_salesteam  VARCHAR2
    , p_copy_opp_lines  VARCHAR2
    , p_copy_lead_contacts  VARCHAR2
    , p_copy_lead_competitors  VARCHAR2
    , p_copy_sales_credits  VARCHAR2
    , p_copy_methodology  VARCHAR2
    , p_new_customer_id  NUMBER
    , p_new_address_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_salesgroup_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p20_a0 JTF_VARCHAR2_TABLE_100
    , p20_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_lead_id out nocopy  NUMBER
  )

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




















    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p20_a0
      , p20_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.copy_opportunity(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_lead_id,
      p_description,
      p_copy_salesteam,
      p_copy_opp_lines,
      p_copy_lead_contacts,
      p_copy_lead_competitors,
      p_copy_sales_credits,
      p_copy_methodology,
      p_new_customer_id,
      p_new_address_id,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_salesgroup_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_lead_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























  end;

  procedure get_access_profiles(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy  VARCHAR2
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  VARCHAR2
  )

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p0_a0
      , p0_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.get_access_profiles(ddp_profile_tbl,
      ddx_access_profile_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_access_profile_rec.cust_access_profile_value;
    p1_a1 := ddx_access_profile_rec.lead_access_profile_value;
    p1_a2 := ddx_access_profile_rec.opp_access_profile_value;
    p1_a3 := ddx_access_profile_rec.mgr_update_profile_value;
    p1_a4 := ddx_access_profile_rec.admin_update_profile_value;
  end;

  function get_profile(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p_profile_name  VARCHAR2
  ) return varchar2

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p0_a0
      , p0_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := as_opportunity_pub.get_profile(ddp_profile_tbl,
      p_profile_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

end as_opportunity_pub_w4;

/
