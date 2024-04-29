--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_UTIL_PVT_W" as
  /* $Header: pvxwputb.pls 120.2 2005/11/14 21:04 pinagara ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_partner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  NUMBER
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
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  DATE
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  NUMBER
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  NUMBER
    , p7_a80  NUMBER
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  NUMBER
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  NUMBER
    , p7_a96  NUMBER
    , p7_a97  NUMBER
    , p7_a98  DATE
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  NUMBER
    , p7_a109  VARCHAR2
    , p7_a110  NUMBER
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p7_a138  NUMBER
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  VARCHAR2
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p7_a148  VARCHAR2
    , p7_a149  VARCHAR2
    , p7_a150  VARCHAR2
    , p7_a151  VARCHAR2
    , p7_a152  VARCHAR2
    , p7_a153  VARCHAR2
    , p7_a154  VARCHAR2
    , p7_a155  VARCHAR2
    , p7_a156  VARCHAR2
    , p7_a157  VARCHAR2
    , p7_a158  VARCHAR2
    , p7_a159  VARCHAR2
    , p7_a160  VARCHAR2
    , p7_a161  VARCHAR2
    , p7_a162  VARCHAR2
    , p7_a163  VARCHAR2
    , p7_a164  VARCHAR2
    , p7_a165  VARCHAR2
    , p7_a166  VARCHAR2
    , p7_a167  VARCHAR2
    , p7_a168  VARCHAR2
    , p7_a169  VARCHAR2
    , p7_a170  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
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
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  DATE
    , p8_a28  DATE
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  NUMBER
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  VARCHAR2
    , p8_a56  VARCHAR2
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p8_a60  NUMBER
    , p8_a61  VARCHAR2
    , p8_a62  NUMBER
    , p8_a63  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  NUMBER
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  VARCHAR2
    , p9_a14  VARCHAR2
    , p9_a15  VARCHAR2
    , p9_a16  VARCHAR2
    , p9_a17  VARCHAR2
    , p9_a18  VARCHAR2
    , p9_a19  VARCHAR2
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  VARCHAR2
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  VARCHAR2
    , p9_a27  VARCHAR2
    , p9_a28  VARCHAR2
    , p9_a29  VARCHAR2
    , p9_a30  VARCHAR2
    , p9_a31  VARCHAR2
    , p9_a32  VARCHAR2
    , p9_a33  VARCHAR2
    , p9_a34  NUMBER
    , p9_a35  VARCHAR2
    , p10_a0 JTF_VARCHAR2_TABLE_2000
    , p10_a1 JTF_VARCHAR2_TABLE_4000
    , p_vad_partner_id  NUMBER
    , p_member_type  VARCHAR2
    , p_global_partner_id  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_default_resp_id out nocopy  NUMBER
    , x_resp_map_rule_id out nocopy  NUMBER
    , x_group_id out nocopy  NUMBER
  )

  as
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_location_rec pv_partner_util_pvt.location_rec_type;
    ddp_party_site_rec hz_party_site_v2pub.party_site_rec_type;
    ddp_partner_types_tbl pv_enty_attr_value_pub.attr_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_organization_rec.organization_name := p7_a0;
    ddp_organization_rec.duns_number_c := p7_a1;
    ddp_organization_rec.enquiry_duns := p7_a2;
    ddp_organization_rec.ceo_name := p7_a3;
    ddp_organization_rec.ceo_title := p7_a4;
    ddp_organization_rec.principal_name := p7_a5;
    ddp_organization_rec.principal_title := p7_a6;
    ddp_organization_rec.legal_status := p7_a7;
    ddp_organization_rec.control_yr := p7_a8;
    ddp_organization_rec.employees_total := p7_a9;
    ddp_organization_rec.hq_branch_ind := p7_a10;
    ddp_organization_rec.branch_flag := p7_a11;
    ddp_organization_rec.oob_ind := p7_a12;
    ddp_organization_rec.line_of_business := p7_a13;
    ddp_organization_rec.cong_dist_code := p7_a14;
    ddp_organization_rec.sic_code := p7_a15;
    ddp_organization_rec.import_ind := p7_a16;
    ddp_organization_rec.export_ind := p7_a17;
    ddp_organization_rec.labor_surplus_ind := p7_a18;
    ddp_organization_rec.debarment_ind := p7_a19;
    ddp_organization_rec.minority_owned_ind := p7_a20;
    ddp_organization_rec.minority_owned_type := p7_a21;
    ddp_organization_rec.woman_owned_ind := p7_a22;
    ddp_organization_rec.disadv_8a_ind := p7_a23;
    ddp_organization_rec.small_bus_ind := p7_a24;
    ddp_organization_rec.rent_own_ind := p7_a25;
    ddp_organization_rec.debarments_count := p7_a26;
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_organization_rec.failure_score := p7_a28;
    ddp_organization_rec.failure_score_natnl_percentile := p7_a29;
    ddp_organization_rec.failure_score_override_code := p7_a30;
    ddp_organization_rec.failure_score_commentary := p7_a31;
    ddp_organization_rec.global_failure_score := p7_a32;
    ddp_organization_rec.db_rating := p7_a33;
    ddp_organization_rec.credit_score := p7_a34;
    ddp_organization_rec.credit_score_commentary := p7_a35;
    ddp_organization_rec.paydex_score := p7_a36;
    ddp_organization_rec.paydex_three_months_ago := p7_a37;
    ddp_organization_rec.paydex_norm := p7_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p7_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p7_a40);
    ddp_organization_rec.organization_name_phonetic := p7_a41;
    ddp_organization_rec.tax_reference := p7_a42;
    ddp_organization_rec.gsa_indicator_flag := p7_a43;
    ddp_organization_rec.jgzz_fiscal_code := p7_a44;
    ddp_organization_rec.analysis_fy := p7_a45;
    ddp_organization_rec.fiscal_yearend_month := p7_a46;
    ddp_organization_rec.curr_fy_potential_revenue := p7_a47;
    ddp_organization_rec.next_fy_potential_revenue := p7_a48;
    ddp_organization_rec.year_established := p7_a49;
    ddp_organization_rec.mission_statement := p7_a50;
    ddp_organization_rec.organization_type := p7_a51;
    ddp_organization_rec.business_scope := p7_a52;
    ddp_organization_rec.corporation_class := p7_a53;
    ddp_organization_rec.known_as := p7_a54;
    ddp_organization_rec.known_as2 := p7_a55;
    ddp_organization_rec.known_as3 := p7_a56;
    ddp_organization_rec.known_as4 := p7_a57;
    ddp_organization_rec.known_as5 := p7_a58;
    ddp_organization_rec.local_bus_iden_type := p7_a59;
    ddp_organization_rec.local_bus_identifier := p7_a60;
    ddp_organization_rec.pref_functional_currency := p7_a61;
    ddp_organization_rec.registration_type := p7_a62;
    ddp_organization_rec.total_employees_text := p7_a63;
    ddp_organization_rec.total_employees_ind := p7_a64;
    ddp_organization_rec.total_emp_est_ind := p7_a65;
    ddp_organization_rec.total_emp_min_ind := p7_a66;
    ddp_organization_rec.parent_sub_ind := p7_a67;
    ddp_organization_rec.incorp_year := p7_a68;
    ddp_organization_rec.sic_code_type := p7_a69;
    ddp_organization_rec.public_private_ownership_flag := p7_a70;
    ddp_organization_rec.internal_flag := p7_a71;
    ddp_organization_rec.local_activity_code_type := p7_a72;
    ddp_organization_rec.local_activity_code := p7_a73;
    ddp_organization_rec.emp_at_primary_adr := p7_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p7_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p7_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p7_a77;
    ddp_organization_rec.high_credit := p7_a78;
    ddp_organization_rec.avg_high_credit := p7_a79;
    ddp_organization_rec.total_payments := p7_a80;
    ddp_organization_rec.credit_score_class := p7_a81;
    ddp_organization_rec.credit_score_natl_percentile := p7_a82;
    ddp_organization_rec.credit_score_incd_default := p7_a83;
    ddp_organization_rec.credit_score_age := p7_a84;
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p7_a85);
    ddp_organization_rec.credit_score_commentary2 := p7_a86;
    ddp_organization_rec.credit_score_commentary3 := p7_a87;
    ddp_organization_rec.credit_score_commentary4 := p7_a88;
    ddp_organization_rec.credit_score_commentary5 := p7_a89;
    ddp_organization_rec.credit_score_commentary6 := p7_a90;
    ddp_organization_rec.credit_score_commentary7 := p7_a91;
    ddp_organization_rec.credit_score_commentary8 := p7_a92;
    ddp_organization_rec.credit_score_commentary9 := p7_a93;
    ddp_organization_rec.credit_score_commentary10 := p7_a94;
    ddp_organization_rec.failure_score_class := p7_a95;
    ddp_organization_rec.failure_score_incd_default := p7_a96;
    ddp_organization_rec.failure_score_age := p7_a97;
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p7_a98);
    ddp_organization_rec.failure_score_commentary2 := p7_a99;
    ddp_organization_rec.failure_score_commentary3 := p7_a100;
    ddp_organization_rec.failure_score_commentary4 := p7_a101;
    ddp_organization_rec.failure_score_commentary5 := p7_a102;
    ddp_organization_rec.failure_score_commentary6 := p7_a103;
    ddp_organization_rec.failure_score_commentary7 := p7_a104;
    ddp_organization_rec.failure_score_commentary8 := p7_a105;
    ddp_organization_rec.failure_score_commentary9 := p7_a106;
    ddp_organization_rec.failure_score_commentary10 := p7_a107;
    ddp_organization_rec.maximum_credit_recommendation := p7_a108;
    ddp_organization_rec.maximum_credit_currency_code := p7_a109;
    ddp_organization_rec.displayed_duns_party_id := p7_a110;
    ddp_organization_rec.content_source_type := p7_a111;
    ddp_organization_rec.content_source_number := p7_a112;
    ddp_organization_rec.attribute_category := p7_a113;
    ddp_organization_rec.attribute1 := p7_a114;
    ddp_organization_rec.attribute2 := p7_a115;
    ddp_organization_rec.attribute3 := p7_a116;
    ddp_organization_rec.attribute4 := p7_a117;
    ddp_organization_rec.attribute5 := p7_a118;
    ddp_organization_rec.attribute6 := p7_a119;
    ddp_organization_rec.attribute7 := p7_a120;
    ddp_organization_rec.attribute8 := p7_a121;
    ddp_organization_rec.attribute9 := p7_a122;
    ddp_organization_rec.attribute10 := p7_a123;
    ddp_organization_rec.attribute11 := p7_a124;
    ddp_organization_rec.attribute12 := p7_a125;
    ddp_organization_rec.attribute13 := p7_a126;
    ddp_organization_rec.attribute14 := p7_a127;
    ddp_organization_rec.attribute15 := p7_a128;
    ddp_organization_rec.attribute16 := p7_a129;
    ddp_organization_rec.attribute17 := p7_a130;
    ddp_organization_rec.attribute18 := p7_a131;
    ddp_organization_rec.attribute19 := p7_a132;
    ddp_organization_rec.attribute20 := p7_a133;
    ddp_organization_rec.created_by_module := p7_a134;
    ddp_organization_rec.application_id := p7_a135;
    ddp_organization_rec.do_not_confuse_with := p7_a136;
    ddp_organization_rec.actual_content_source := p7_a137;
    ddp_organization_rec.party_rec.party_id := p7_a138;
    ddp_organization_rec.party_rec.party_number := p7_a139;
    ddp_organization_rec.party_rec.validated_flag := p7_a140;
    ddp_organization_rec.party_rec.orig_system_reference := p7_a141;
    ddp_organization_rec.party_rec.orig_system := p7_a142;
    ddp_organization_rec.party_rec.status := p7_a143;
    ddp_organization_rec.party_rec.category_code := p7_a144;
    ddp_organization_rec.party_rec.salutation := p7_a145;
    ddp_organization_rec.party_rec.attribute_category := p7_a146;
    ddp_organization_rec.party_rec.attribute1 := p7_a147;
    ddp_organization_rec.party_rec.attribute2 := p7_a148;
    ddp_organization_rec.party_rec.attribute3 := p7_a149;
    ddp_organization_rec.party_rec.attribute4 := p7_a150;
    ddp_organization_rec.party_rec.attribute5 := p7_a151;
    ddp_organization_rec.party_rec.attribute6 := p7_a152;
    ddp_organization_rec.party_rec.attribute7 := p7_a153;
    ddp_organization_rec.party_rec.attribute8 := p7_a154;
    ddp_organization_rec.party_rec.attribute9 := p7_a155;
    ddp_organization_rec.party_rec.attribute10 := p7_a156;
    ddp_organization_rec.party_rec.attribute11 := p7_a157;
    ddp_organization_rec.party_rec.attribute12 := p7_a158;
    ddp_organization_rec.party_rec.attribute13 := p7_a159;
    ddp_organization_rec.party_rec.attribute14 := p7_a160;
    ddp_organization_rec.party_rec.attribute15 := p7_a161;
    ddp_organization_rec.party_rec.attribute16 := p7_a162;
    ddp_organization_rec.party_rec.attribute17 := p7_a163;
    ddp_organization_rec.party_rec.attribute18 := p7_a164;
    ddp_organization_rec.party_rec.attribute19 := p7_a165;
    ddp_organization_rec.party_rec.attribute20 := p7_a166;
    ddp_organization_rec.party_rec.attribute21 := p7_a167;
    ddp_organization_rec.party_rec.attribute22 := p7_a168;
    ddp_organization_rec.party_rec.attribute23 := p7_a169;
    ddp_organization_rec.party_rec.attribute24 := p7_a170;

    ddp_location_rec.location_id := p8_a0;
    ddp_location_rec.orig_system_reference := p8_a1;
    ddp_location_rec.orig_system := p8_a2;
    ddp_location_rec.country := p8_a3;
    ddp_location_rec.address1 := p8_a4;
    ddp_location_rec.address2 := p8_a5;
    ddp_location_rec.address3 := p8_a6;
    ddp_location_rec.address4 := p8_a7;
    ddp_location_rec.city := p8_a8;
    ddp_location_rec.postal_code := p8_a9;
    ddp_location_rec.state := p8_a10;
    ddp_location_rec.province := p8_a11;
    ddp_location_rec.county := p8_a12;
    ddp_location_rec.address_key := p8_a13;
    ddp_location_rec.address_style := p8_a14;
    ddp_location_rec.validated_flag := p8_a15;
    ddp_location_rec.address_lines_phonetic := p8_a16;
    ddp_location_rec.po_box_number := p8_a17;
    ddp_location_rec.house_number := p8_a18;
    ddp_location_rec.street_suffix := p8_a19;
    ddp_location_rec.street := p8_a20;
    ddp_location_rec.street_number := p8_a21;
    ddp_location_rec.floor := p8_a22;
    ddp_location_rec.suite := p8_a23;
    ddp_location_rec.postal_plus4_code := p8_a24;
    ddp_location_rec.position := p8_a25;
    ddp_location_rec.location_directions := p8_a26;
    ddp_location_rec.address_effective_date := rosetta_g_miss_date_in_map(p8_a27);
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p8_a28);
    ddp_location_rec.clli_code := p8_a29;
    ddp_location_rec.language := p8_a30;
    ddp_location_rec.short_description := p8_a31;
    ddp_location_rec.description := p8_a32;
    ddp_location_rec.geometry_status_code := p8_a33;
    ddp_location_rec.loc_hierarchy_id := p8_a34;
    ddp_location_rec.sales_tax_geocode := p8_a35;
    ddp_location_rec.sales_tax_inside_city_limits := p8_a36;
    ddp_location_rec.fa_location_id := p8_a37;
    ddp_location_rec.content_source_type := p8_a38;
    ddp_location_rec.attribute_category := p8_a39;
    ddp_location_rec.attribute1 := p8_a40;
    ddp_location_rec.attribute2 := p8_a41;
    ddp_location_rec.attribute3 := p8_a42;
    ddp_location_rec.attribute4 := p8_a43;
    ddp_location_rec.attribute5 := p8_a44;
    ddp_location_rec.attribute6 := p8_a45;
    ddp_location_rec.attribute7 := p8_a46;
    ddp_location_rec.attribute8 := p8_a47;
    ddp_location_rec.attribute9 := p8_a48;
    ddp_location_rec.attribute10 := p8_a49;
    ddp_location_rec.attribute11 := p8_a50;
    ddp_location_rec.attribute12 := p8_a51;
    ddp_location_rec.attribute13 := p8_a52;
    ddp_location_rec.attribute14 := p8_a53;
    ddp_location_rec.attribute15 := p8_a54;
    ddp_location_rec.attribute16 := p8_a55;
    ddp_location_rec.attribute17 := p8_a56;
    ddp_location_rec.attribute18 := p8_a57;
    ddp_location_rec.attribute19 := p8_a58;
    ddp_location_rec.attribute20 := p8_a59;
    ddp_location_rec.timezone_id := p8_a60;
    ddp_location_rec.created_by_module := p8_a61;
    ddp_location_rec.application_id := p8_a62;
    ddp_location_rec.actual_content_source := p8_a63;

    ddp_party_site_rec.party_site_id := p9_a0;
    ddp_party_site_rec.party_id := p9_a1;
    ddp_party_site_rec.location_id := p9_a2;
    ddp_party_site_rec.party_site_number := p9_a3;
    ddp_party_site_rec.orig_system_reference := p9_a4;
    ddp_party_site_rec.orig_system := p9_a5;
    ddp_party_site_rec.mailstop := p9_a6;
    ddp_party_site_rec.identifying_address_flag := p9_a7;
    ddp_party_site_rec.status := p9_a8;
    ddp_party_site_rec.party_site_name := p9_a9;
    ddp_party_site_rec.attribute_category := p9_a10;
    ddp_party_site_rec.attribute1 := p9_a11;
    ddp_party_site_rec.attribute2 := p9_a12;
    ddp_party_site_rec.attribute3 := p9_a13;
    ddp_party_site_rec.attribute4 := p9_a14;
    ddp_party_site_rec.attribute5 := p9_a15;
    ddp_party_site_rec.attribute6 := p9_a16;
    ddp_party_site_rec.attribute7 := p9_a17;
    ddp_party_site_rec.attribute8 := p9_a18;
    ddp_party_site_rec.attribute9 := p9_a19;
    ddp_party_site_rec.attribute10 := p9_a20;
    ddp_party_site_rec.attribute11 := p9_a21;
    ddp_party_site_rec.attribute12 := p9_a22;
    ddp_party_site_rec.attribute13 := p9_a23;
    ddp_party_site_rec.attribute14 := p9_a24;
    ddp_party_site_rec.attribute15 := p9_a25;
    ddp_party_site_rec.attribute16 := p9_a26;
    ddp_party_site_rec.attribute17 := p9_a27;
    ddp_party_site_rec.attribute18 := p9_a28;
    ddp_party_site_rec.attribute19 := p9_a29;
    ddp_party_site_rec.attribute20 := p9_a30;
    ddp_party_site_rec.language := p9_a31;
    ddp_party_site_rec.addressee := p9_a32;
    ddp_party_site_rec.created_by_module := p9_a33;
    ddp_party_site_rec.application_id := p9_a34;
    ddp_party_site_rec.global_location_number := p9_a35;

    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p2(ddp_partner_types_tbl, p10_a0
      , p10_a1
      );








    -- here's the delegated call to the old PL/SQL routine
    pv_partner_util_pvt.create_partner(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_organization_rec,
      ddp_location_rec,
      ddp_party_site_rec,
      ddp_partner_types_tbl,
      p_vad_partner_id,
      p_member_type,
      p_global_partner_id,
      x_party_id,
      x_default_resp_id,
      x_resp_map_rule_id,
      x_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

















  end;

  procedure create_relationship(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_party_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_2000
    , p8_a1 JTF_VARCHAR2_TABLE_4000
    , p_vad_partner_id  NUMBER
    , p_member_type  VARCHAR2
    , p_global_partner_id  NUMBER
    , x_partner_id out nocopy  NUMBER
    , x_default_resp_id out nocopy  NUMBER
    , x_resp_map_rule_id out nocopy  NUMBER
    , x_group_id out nocopy  NUMBER
  )

  as
    ddp_partner_types_tbl pv_enty_attr_value_pub.attr_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p2(ddp_partner_types_tbl, p8_a0
      , p8_a1
      );








    -- here's the delegated call to the old PL/SQL routine
    pv_partner_util_pvt.create_relationship(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_party_id,
      ddp_partner_types_tbl,
      p_vad_partner_id,
      p_member_type,
      p_global_partner_id,
      x_partner_id,
      x_default_resp_id,
      x_resp_map_rule_id,
      x_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure do_create_relationship(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_party_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_2000
    , p8_a1 JTF_VARCHAR2_TABLE_4000
    , p_vad_partner_id  NUMBER
    , p_member_type  VARCHAR2
    , p_global_partner_id  NUMBER
    , p12_a0 JTF_VARCHAR2_TABLE_400
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , p12_a4 JTF_VARCHAR2_TABLE_100
    , p12_a5 JTF_VARCHAR2_TABLE_100
    , p12_a6 JTF_VARCHAR2_TABLE_100
    , p12_a7 JTF_VARCHAR2_TABLE_100
    , p12_a8 JTF_VARCHAR2_TABLE_100
    , p12_a9 JTF_VARCHAR2_TABLE_100
    , p12_a10 JTF_NUMBER_TABLE
    , p12_a11 JTF_NUMBER_TABLE
    , p12_a12 JTF_VARCHAR2_TABLE_100
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_100
    , x_partner_id out nocopy  NUMBER
    , x_default_resp_id out nocopy  NUMBER
    , x_resp_map_rule_id out nocopy  NUMBER
    , x_group_id out nocopy  NUMBER
  )

  as
    ddp_partner_types_tbl pv_enty_attr_value_pub.attr_value_tbl_type;
    ddp_partner_qualifiers_tbl pv_terr_assign_pub.partner_qualifiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p2(ddp_partner_types_tbl, p8_a0
      , p8_a1
      );




    pv_terr_assign_pub_w.rosetta_table_copy_in_p15(ddp_partner_qualifiers_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      );





    -- here's the delegated call to the old PL/SQL routine
    pv_partner_util_pvt.do_create_relationship(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_party_id,
      ddp_partner_types_tbl,
      p_vad_partner_id,
      p_member_type,
      p_global_partner_id,
      ddp_partner_qualifiers_tbl,
      x_partner_id,
      x_default_resp_id,
      x_resp_map_rule_id,
      x_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure invite_partner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_party_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_400
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_500
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_2000
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , p_vad_partner_id  NUMBER
    , p11_a0  VARCHAR2
    , p11_a1  VARCHAR2
    , p11_a2  VARCHAR2
    , p11_a3  VARCHAR2
    , p11_a4  VARCHAR2
    , p11_a5  VARCHAR2
    , p11_a6  VARCHAR2
    , p11_a7  VARCHAR2
    , p11_a8  VARCHAR2
    , p11_a9  VARCHAR2
    , p11_a10  VARCHAR2
    , p11_a11  VARCHAR2
    , p11_a12  VARCHAR2
    , p11_a13  VARCHAR2
    , p11_a14  VARCHAR2
    , p11_a15  VARCHAR2
    , p11_a16  VARCHAR2
    , p11_a17  VARCHAR2
    , p11_a18  VARCHAR2
    , p11_a19  VARCHAR2
    , p11_a20  VARCHAR2
    , p11_a21  VARCHAR2
    , p11_a22  DATE
    , p11_a23  VARCHAR2
    , p11_a24  DATE
    , p11_a25  VARCHAR2
    , p11_a26  VARCHAR2
    , p11_a27  VARCHAR2
    , p11_a28  VARCHAR2
    , p11_a29  DATE
    , p11_a30  NUMBER
    , p11_a31  VARCHAR2
    , p11_a32  NUMBER
    , p11_a33  NUMBER
    , p11_a34  VARCHAR2
    , p11_a35  VARCHAR2
    , p11_a36  VARCHAR2
    , p11_a37  VARCHAR2
    , p11_a38  VARCHAR2
    , p11_a39  VARCHAR2
    , p11_a40  VARCHAR2
    , p11_a41  VARCHAR2
    , p11_a42  VARCHAR2
    , p11_a43  VARCHAR2
    , p11_a44  VARCHAR2
    , p11_a45  VARCHAR2
    , p11_a46  VARCHAR2
    , p11_a47  VARCHAR2
    , p11_a48  VARCHAR2
    , p11_a49  VARCHAR2
    , p11_a50  VARCHAR2
    , p11_a51  VARCHAR2
    , p11_a52  VARCHAR2
    , p11_a53  VARCHAR2
    , p11_a54  VARCHAR2
    , p11_a55  VARCHAR2
    , p11_a56  VARCHAR2
    , p11_a57  VARCHAR2
    , p11_a58  VARCHAR2
    , p11_a59  VARCHAR2
    , p11_a60  NUMBER
    , p11_a61  VARCHAR2
    , p11_a62  NUMBER
    , p11_a63  VARCHAR2
    , p11_a64  VARCHAR2
    , p11_a65  VARCHAR2
    , p11_a66  VARCHAR2
    , p11_a67  VARCHAR2
    , p11_a68  VARCHAR2
    , p11_a69  VARCHAR2
    , p11_a70  VARCHAR2
    , p11_a71  VARCHAR2
    , p11_a72  VARCHAR2
    , p11_a73  VARCHAR2
    , p11_a74  VARCHAR2
    , p11_a75  VARCHAR2
    , p11_a76  VARCHAR2
    , p11_a77  VARCHAR2
    , p11_a78  VARCHAR2
    , p11_a79  VARCHAR2
    , p11_a80  VARCHAR2
    , p11_a81  VARCHAR2
    , p11_a82  VARCHAR2
    , p11_a83  VARCHAR2
    , p11_a84  VARCHAR2
    , p11_a85  VARCHAR2
    , p11_a86  VARCHAR2
    , p11_a87  VARCHAR2
    , p11_a88  VARCHAR2
    , p11_a89  VARCHAR2
    , p11_a90  VARCHAR2
    , p11_a91  VARCHAR2
    , p11_a92  VARCHAR2
    , p11_a93  VARCHAR2
    , p11_a94  VARCHAR2
    , p12_a0  VARCHAR2
    , p12_a1  DATE
    , p12_a2  NUMBER
    , p12_a3  VARCHAR2
    , p12_a4  VARCHAR2
    , p12_a5  VARCHAR2
    , p12_a6  VARCHAR2
    , p12_a7  VARCHAR2
    , p12_a8  VARCHAR2
    , p13_a0  VARCHAR2
    , p13_a1  VARCHAR2
    , p_member_type  VARCHAR2
    , p_global_partner_id  NUMBER
    , x_partner_party_id out nocopy  NUMBER
    , x_partner_id out nocopy  NUMBER
    , x_cnt_party_id out nocopy  NUMBER
    , x_cnt_partner_id out nocopy  NUMBER
    , x_cnt_rel_start_date out nocopy  DATE
    , x_default_resp_id out nocopy  NUMBER
    , x_resp_map_rule_id out nocopy  NUMBER
    , x_group_id out nocopy  NUMBER
  )

  as
    ddp_partner_qualifiers_tbl pv_terr_assign_pub.partner_qualifiers_tbl_type;
    ddp_partner_types_tbl pv_enty_attr_value_pub.attr_value_tbl_type;
    ddp_person_rec pv_partner_util_pvt.person_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    pv_terr_assign_pub_w.rosetta_table_copy_in_p15(ddp_partner_qualifiers_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      );

    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p2(ddp_partner_types_tbl, p9_a0
      , p9_a1
      );


    ddp_person_rec.person_pre_name_adjunct := p11_a0;
    ddp_person_rec.person_first_name := p11_a1;
    ddp_person_rec.person_middle_name := p11_a2;
    ddp_person_rec.person_last_name := p11_a3;
    ddp_person_rec.person_name_suffix := p11_a4;
    ddp_person_rec.person_title := p11_a5;
    ddp_person_rec.person_academic_title := p11_a6;
    ddp_person_rec.person_previous_last_name := p11_a7;
    ddp_person_rec.person_initials := p11_a8;
    ddp_person_rec.known_as := p11_a9;
    ddp_person_rec.known_as2 := p11_a10;
    ddp_person_rec.known_as3 := p11_a11;
    ddp_person_rec.known_as4 := p11_a12;
    ddp_person_rec.known_as5 := p11_a13;
    ddp_person_rec.person_name_phonetic := p11_a14;
    ddp_person_rec.person_first_name_phonetic := p11_a15;
    ddp_person_rec.person_last_name_phonetic := p11_a16;
    ddp_person_rec.middle_name_phonetic := p11_a17;
    ddp_person_rec.tax_reference := p11_a18;
    ddp_person_rec.jgzz_fiscal_code := p11_a19;
    ddp_person_rec.person_iden_type := p11_a20;
    ddp_person_rec.person_identifier := p11_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p11_a22);
    ddp_person_rec.place_of_birth := p11_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p11_a24);
    ddp_person_rec.deceased_flag := p11_a25;
    ddp_person_rec.gender := p11_a26;
    ddp_person_rec.declared_ethnicity := p11_a27;
    ddp_person_rec.marital_status := p11_a28;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p11_a29);
    ddp_person_rec.personal_income := p11_a30;
    ddp_person_rec.head_of_household_flag := p11_a31;
    ddp_person_rec.household_income := p11_a32;
    ddp_person_rec.household_size := p11_a33;
    ddp_person_rec.rent_own_ind := p11_a34;
    ddp_person_rec.last_known_gps := p11_a35;
    ddp_person_rec.content_source_type := p11_a36;
    ddp_person_rec.internal_flag := p11_a37;
    ddp_person_rec.attribute_category := p11_a38;
    ddp_person_rec.attribute1 := p11_a39;
    ddp_person_rec.attribute2 := p11_a40;
    ddp_person_rec.attribute3 := p11_a41;
    ddp_person_rec.attribute4 := p11_a42;
    ddp_person_rec.attribute5 := p11_a43;
    ddp_person_rec.attribute6 := p11_a44;
    ddp_person_rec.attribute7 := p11_a45;
    ddp_person_rec.attribute8 := p11_a46;
    ddp_person_rec.attribute9 := p11_a47;
    ddp_person_rec.attribute10 := p11_a48;
    ddp_person_rec.attribute11 := p11_a49;
    ddp_person_rec.attribute12 := p11_a50;
    ddp_person_rec.attribute13 := p11_a51;
    ddp_person_rec.attribute14 := p11_a52;
    ddp_person_rec.attribute15 := p11_a53;
    ddp_person_rec.attribute16 := p11_a54;
    ddp_person_rec.attribute17 := p11_a55;
    ddp_person_rec.attribute18 := p11_a56;
    ddp_person_rec.attribute19 := p11_a57;
    ddp_person_rec.attribute20 := p11_a58;
    ddp_person_rec.created_by_module := p11_a59;
    ddp_person_rec.application_id := p11_a60;
    ddp_person_rec.actual_content_source := p11_a61;
    ddp_person_rec.party_rec.party_id := p11_a62;
    ddp_person_rec.party_rec.party_number := p11_a63;
    ddp_person_rec.party_rec.validated_flag := p11_a64;
    ddp_person_rec.party_rec.orig_system_reference := p11_a65;
    ddp_person_rec.party_rec.orig_system := p11_a66;
    ddp_person_rec.party_rec.status := p11_a67;
    ddp_person_rec.party_rec.category_code := p11_a68;
    ddp_person_rec.party_rec.salutation := p11_a69;
    ddp_person_rec.party_rec.attribute_category := p11_a70;
    ddp_person_rec.party_rec.attribute1 := p11_a71;
    ddp_person_rec.party_rec.attribute2 := p11_a72;
    ddp_person_rec.party_rec.attribute3 := p11_a73;
    ddp_person_rec.party_rec.attribute4 := p11_a74;
    ddp_person_rec.party_rec.attribute5 := p11_a75;
    ddp_person_rec.party_rec.attribute6 := p11_a76;
    ddp_person_rec.party_rec.attribute7 := p11_a77;
    ddp_person_rec.party_rec.attribute8 := p11_a78;
    ddp_person_rec.party_rec.attribute9 := p11_a79;
    ddp_person_rec.party_rec.attribute10 := p11_a80;
    ddp_person_rec.party_rec.attribute11 := p11_a81;
    ddp_person_rec.party_rec.attribute12 := p11_a82;
    ddp_person_rec.party_rec.attribute13 := p11_a83;
    ddp_person_rec.party_rec.attribute14 := p11_a84;
    ddp_person_rec.party_rec.attribute15 := p11_a85;
    ddp_person_rec.party_rec.attribute16 := p11_a86;
    ddp_person_rec.party_rec.attribute17 := p11_a87;
    ddp_person_rec.party_rec.attribute18 := p11_a88;
    ddp_person_rec.party_rec.attribute19 := p11_a89;
    ddp_person_rec.party_rec.attribute20 := p11_a90;
    ddp_person_rec.party_rec.attribute21 := p11_a91;
    ddp_person_rec.party_rec.attribute22 := p11_a92;
    ddp_person_rec.party_rec.attribute23 := p11_a93;
    ddp_person_rec.party_rec.attribute24 := p11_a94;

    ddp_phone_rec.phone_calling_calendar := p12_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p12_a1);
    ddp_phone_rec.timezone_id := p12_a2;
    ddp_phone_rec.phone_area_code := p12_a3;
    ddp_phone_rec.phone_country_code := p12_a4;
    ddp_phone_rec.phone_number := p12_a5;
    ddp_phone_rec.phone_extension := p12_a6;
    ddp_phone_rec.phone_line_type := p12_a7;
    ddp_phone_rec.raw_phone_number := p12_a8;

    ddp_email_rec.email_format := p13_a0;
    ddp_email_rec.email_address := p13_a1;











    -- here's the delegated call to the old PL/SQL routine
    pv_partner_util_pvt.invite_partner(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_party_id,
      ddp_partner_qualifiers_tbl,
      ddp_partner_types_tbl,
      p_vad_partner_id,
      ddp_person_rec,
      ddp_phone_rec,
      ddp_email_rec,
      p_member_type,
      p_global_partner_id,
      x_partner_party_id,
      x_partner_id,
      x_cnt_party_id,
      x_cnt_partner_id,
      x_cnt_rel_start_date,
      x_default_resp_id,
      x_resp_map_rule_id,
      x_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any























  end;

end pv_partner_util_pvt_w;

/
