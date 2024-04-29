--------------------------------------------------------
--  DDL for Package Body HZ_BANK_PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BANK_PUB_JW" as
  /* $Header: ARHBKAJB.pls 120.6 2006/02/15 00:19:01 jhuang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_bank_1(p_init_msg_list  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_profile_id out nocopy  NUMBER
    , x_code_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  DATE := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  DATE := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  NUMBER := null
    , p1_a56  NUMBER := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  NUMBER := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  NUMBER := null
    , p1_a89  NUMBER := null
    , p1_a90  NUMBER := null
    , p1_a91  NUMBER := null
    , p1_a92  NUMBER := null
    , p1_a93  DATE := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  NUMBER := null
    , p1_a104  NUMBER := null
    , p1_a105  NUMBER := null
    , p1_a106  DATE := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  NUMBER := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  NUMBER := null
    , p1_a119  VARCHAR2 := null
    , p1_a120  VARCHAR2 := null
    , p1_a121  VARCHAR2 := null
    , p1_a122  VARCHAR2 := null
    , p1_a123  VARCHAR2 := null
    , p1_a124  VARCHAR2 := null
    , p1_a125  VARCHAR2 := null
    , p1_a126  VARCHAR2 := null
    , p1_a127  VARCHAR2 := null
    , p1_a128  VARCHAR2 := null
    , p1_a129  VARCHAR2 := null
    , p1_a130  VARCHAR2 := null
    , p1_a131  VARCHAR2 := null
    , p1_a132  VARCHAR2 := null
    , p1_a133  VARCHAR2 := null
    , p1_a134  VARCHAR2 := null
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  NUMBER := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  NUMBER := null
    , p1_a148  VARCHAR2 := null
    , p1_a149  VARCHAR2 := null
    , p1_a150  VARCHAR2 := null
    , p1_a151  VARCHAR2 := null
    , p1_a152  VARCHAR2 := null
    , p1_a153  VARCHAR2 := null
    , p1_a154  VARCHAR2 := null
    , p1_a155  VARCHAR2 := null
    , p1_a156  VARCHAR2 := null
    , p1_a157  VARCHAR2 := null
    , p1_a158  VARCHAR2 := null
    , p1_a159  VARCHAR2 := null
    , p1_a160  VARCHAR2 := null
    , p1_a161  VARCHAR2 := null
    , p1_a162  VARCHAR2 := null
    , p1_a163  VARCHAR2 := null
    , p1_a164  VARCHAR2 := null
    , p1_a165  VARCHAR2 := null
    , p1_a166  VARCHAR2 := null
    , p1_a167  VARCHAR2 := null
    , p1_a168  VARCHAR2 := null
    , p1_a169  VARCHAR2 := null
    , p1_a170  VARCHAR2 := null
    , p1_a171  VARCHAR2 := null
    , p1_a172  VARCHAR2 := null
    , p1_a173  VARCHAR2 := null
    , p1_a174  VARCHAR2 := null
    , p1_a175  VARCHAR2 := null
    , p1_a176  VARCHAR2 := null
    , p1_a177  VARCHAR2 := null
    , p1_a178  VARCHAR2 := null
    , p1_a179  VARCHAR2 := null
  )
  as
    ddp_bank_rec hz_bank_pub.bank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_bank_rec.bank_or_branch_number := p1_a0;
    ddp_bank_rec.bank_code := p1_a1;
    ddp_bank_rec.branch_code := p1_a2;
    ddp_bank_rec.institution_type := p1_a3;
    ddp_bank_rec.branch_type := p1_a4;
    ddp_bank_rec.country := p1_a5;
    ddp_bank_rec.rfc_code := p1_a6;
    ddp_bank_rec.inactive_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_bank_rec.organization_rec.organization_name := p1_a8;
    ddp_bank_rec.organization_rec.duns_number_c := p1_a9;
    ddp_bank_rec.organization_rec.enquiry_duns := p1_a10;
    ddp_bank_rec.organization_rec.ceo_name := p1_a11;
    ddp_bank_rec.organization_rec.ceo_title := p1_a12;
    ddp_bank_rec.organization_rec.principal_name := p1_a13;
    ddp_bank_rec.organization_rec.principal_title := p1_a14;
    ddp_bank_rec.organization_rec.legal_status := p1_a15;
    ddp_bank_rec.organization_rec.control_yr := rosetta_g_miss_num_map(p1_a16);
    ddp_bank_rec.organization_rec.employees_total := rosetta_g_miss_num_map(p1_a17);
    ddp_bank_rec.organization_rec.hq_branch_ind := p1_a18;
    ddp_bank_rec.organization_rec.branch_flag := p1_a19;
    ddp_bank_rec.organization_rec.oob_ind := p1_a20;
    ddp_bank_rec.organization_rec.line_of_business := p1_a21;
    ddp_bank_rec.organization_rec.cong_dist_code := p1_a22;
    ddp_bank_rec.organization_rec.sic_code := p1_a23;
    ddp_bank_rec.organization_rec.import_ind := p1_a24;
    ddp_bank_rec.organization_rec.export_ind := p1_a25;
    ddp_bank_rec.organization_rec.labor_surplus_ind := p1_a26;
    ddp_bank_rec.organization_rec.debarment_ind := p1_a27;
    ddp_bank_rec.organization_rec.minority_owned_ind := p1_a28;
    ddp_bank_rec.organization_rec.minority_owned_type := p1_a29;
    ddp_bank_rec.organization_rec.woman_owned_ind := p1_a30;
    ddp_bank_rec.organization_rec.disadv_8a_ind := p1_a31;
    ddp_bank_rec.organization_rec.small_bus_ind := p1_a32;
    ddp_bank_rec.organization_rec.rent_own_ind := p1_a33;
    ddp_bank_rec.organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a34);
    ddp_bank_rec.organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a35);
    ddp_bank_rec.organization_rec.failure_score := p1_a36;
    ddp_bank_rec.organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a37);
    ddp_bank_rec.organization_rec.failure_score_override_code := p1_a38;
    ddp_bank_rec.organization_rec.failure_score_commentary := p1_a39;
    ddp_bank_rec.organization_rec.global_failure_score := p1_a40;
    ddp_bank_rec.organization_rec.db_rating := p1_a41;
    ddp_bank_rec.organization_rec.credit_score := p1_a42;
    ddp_bank_rec.organization_rec.credit_score_commentary := p1_a43;
    ddp_bank_rec.organization_rec.paydex_score := p1_a44;
    ddp_bank_rec.organization_rec.paydex_three_months_ago := p1_a45;
    ddp_bank_rec.organization_rec.paydex_norm := p1_a46;
    ddp_bank_rec.organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a47);
    ddp_bank_rec.organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a48);
    ddp_bank_rec.organization_rec.organization_name_phonetic := p1_a49;
    ddp_bank_rec.organization_rec.tax_reference := p1_a50;
    ddp_bank_rec.organization_rec.gsa_indicator_flag := p1_a51;
    ddp_bank_rec.organization_rec.jgzz_fiscal_code := p1_a52;
    ddp_bank_rec.organization_rec.analysis_fy := p1_a53;
    ddp_bank_rec.organization_rec.fiscal_yearend_month := p1_a54;
    ddp_bank_rec.organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a55);
    ddp_bank_rec.organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a56);
    ddp_bank_rec.organization_rec.year_established := rosetta_g_miss_num_map(p1_a57);
    ddp_bank_rec.organization_rec.mission_statement := p1_a58;
    ddp_bank_rec.organization_rec.organization_type := p1_a59;
    ddp_bank_rec.organization_rec.business_scope := p1_a60;
    ddp_bank_rec.organization_rec.corporation_class := p1_a61;
    ddp_bank_rec.organization_rec.known_as := p1_a62;
    ddp_bank_rec.organization_rec.known_as2 := p1_a63;
    ddp_bank_rec.organization_rec.known_as3 := p1_a64;
    ddp_bank_rec.organization_rec.known_as4 := p1_a65;
    ddp_bank_rec.organization_rec.known_as5 := p1_a66;
    ddp_bank_rec.organization_rec.local_bus_iden_type := p1_a67;
    ddp_bank_rec.organization_rec.local_bus_identifier := p1_a68;
    ddp_bank_rec.organization_rec.pref_functional_currency := p1_a69;
    ddp_bank_rec.organization_rec.registration_type := p1_a70;
    ddp_bank_rec.organization_rec.total_employees_text := p1_a71;
    ddp_bank_rec.organization_rec.total_employees_ind := p1_a72;
    ddp_bank_rec.organization_rec.total_emp_est_ind := p1_a73;
    ddp_bank_rec.organization_rec.total_emp_min_ind := p1_a74;
    ddp_bank_rec.organization_rec.parent_sub_ind := p1_a75;
    ddp_bank_rec.organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a76);
    ddp_bank_rec.organization_rec.sic_code_type := p1_a77;
    ddp_bank_rec.organization_rec.public_private_ownership_flag := p1_a78;
    ddp_bank_rec.organization_rec.internal_flag := p1_a79;
    ddp_bank_rec.organization_rec.local_activity_code_type := p1_a80;
    ddp_bank_rec.organization_rec.local_activity_code := p1_a81;
    ddp_bank_rec.organization_rec.emp_at_primary_adr := p1_a82;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_text := p1_a83;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_est_ind := p1_a84;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_min_ind := p1_a85;
    ddp_bank_rec.organization_rec.high_credit := rosetta_g_miss_num_map(p1_a86);
    ddp_bank_rec.organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a87);
    ddp_bank_rec.organization_rec.total_payments := rosetta_g_miss_num_map(p1_a88);
    ddp_bank_rec.organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a89);
    ddp_bank_rec.organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a90);
    ddp_bank_rec.organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a91);
    ddp_bank_rec.organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a92);
    ddp_bank_rec.organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_bank_rec.organization_rec.credit_score_commentary2 := p1_a94;
    ddp_bank_rec.organization_rec.credit_score_commentary3 := p1_a95;
    ddp_bank_rec.organization_rec.credit_score_commentary4 := p1_a96;
    ddp_bank_rec.organization_rec.credit_score_commentary5 := p1_a97;
    ddp_bank_rec.organization_rec.credit_score_commentary6 := p1_a98;
    ddp_bank_rec.organization_rec.credit_score_commentary7 := p1_a99;
    ddp_bank_rec.organization_rec.credit_score_commentary8 := p1_a100;
    ddp_bank_rec.organization_rec.credit_score_commentary9 := p1_a101;
    ddp_bank_rec.organization_rec.credit_score_commentary10 := p1_a102;
    ddp_bank_rec.organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a103);
    ddp_bank_rec.organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a104);
    ddp_bank_rec.organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a105);
    ddp_bank_rec.organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_bank_rec.organization_rec.failure_score_commentary2 := p1_a107;
    ddp_bank_rec.organization_rec.failure_score_commentary3 := p1_a108;
    ddp_bank_rec.organization_rec.failure_score_commentary4 := p1_a109;
    ddp_bank_rec.organization_rec.failure_score_commentary5 := p1_a110;
    ddp_bank_rec.organization_rec.failure_score_commentary6 := p1_a111;
    ddp_bank_rec.organization_rec.failure_score_commentary7 := p1_a112;
    ddp_bank_rec.organization_rec.failure_score_commentary8 := p1_a113;
    ddp_bank_rec.organization_rec.failure_score_commentary9 := p1_a114;
    ddp_bank_rec.organization_rec.failure_score_commentary10 := p1_a115;
    ddp_bank_rec.organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a116);
    ddp_bank_rec.organization_rec.maximum_credit_currency_code := p1_a117;
    ddp_bank_rec.organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a118);
    ddp_bank_rec.organization_rec.content_source_type := p1_a119;
    ddp_bank_rec.organization_rec.content_source_number := p1_a120;
    ddp_bank_rec.organization_rec.attribute_category := p1_a121;
    ddp_bank_rec.organization_rec.attribute1 := p1_a122;
    ddp_bank_rec.organization_rec.attribute2 := p1_a123;
    ddp_bank_rec.organization_rec.attribute3 := p1_a124;
    ddp_bank_rec.organization_rec.attribute4 := p1_a125;
    ddp_bank_rec.organization_rec.attribute5 := p1_a126;
    ddp_bank_rec.organization_rec.attribute6 := p1_a127;
    ddp_bank_rec.organization_rec.attribute7 := p1_a128;
    ddp_bank_rec.organization_rec.attribute8 := p1_a129;
    ddp_bank_rec.organization_rec.attribute9 := p1_a130;
    ddp_bank_rec.organization_rec.attribute10 := p1_a131;
    ddp_bank_rec.organization_rec.attribute11 := p1_a132;
    ddp_bank_rec.organization_rec.attribute12 := p1_a133;
    ddp_bank_rec.organization_rec.attribute13 := p1_a134;
    ddp_bank_rec.organization_rec.attribute14 := p1_a135;
    ddp_bank_rec.organization_rec.attribute15 := p1_a136;
    ddp_bank_rec.organization_rec.attribute16 := p1_a137;
    ddp_bank_rec.organization_rec.attribute17 := p1_a138;
    ddp_bank_rec.organization_rec.attribute18 := p1_a139;
    ddp_bank_rec.organization_rec.attribute19 := p1_a140;
    ddp_bank_rec.organization_rec.attribute20 := p1_a141;
    ddp_bank_rec.organization_rec.created_by_module := p1_a142;
    ddp_bank_rec.organization_rec.application_id := rosetta_g_miss_num_map(p1_a143);
    ddp_bank_rec.organization_rec.do_not_confuse_with := p1_a144;
    ddp_bank_rec.organization_rec.actual_content_source := p1_a145;
    ddp_bank_rec.organization_rec.home_country := p1_a146;
    ddp_bank_rec.organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a147);
    ddp_bank_rec.organization_rec.party_rec.party_number := p1_a148;
    ddp_bank_rec.organization_rec.party_rec.validated_flag := p1_a149;
    ddp_bank_rec.organization_rec.party_rec.orig_system_reference := p1_a150;
    ddp_bank_rec.organization_rec.party_rec.orig_system := p1_a151;
    ddp_bank_rec.organization_rec.party_rec.status := p1_a152;
    ddp_bank_rec.organization_rec.party_rec.category_code := p1_a153;
    ddp_bank_rec.organization_rec.party_rec.salutation := p1_a154;
    ddp_bank_rec.organization_rec.party_rec.attribute_category := p1_a155;
    ddp_bank_rec.organization_rec.party_rec.attribute1 := p1_a156;
    ddp_bank_rec.organization_rec.party_rec.attribute2 := p1_a157;
    ddp_bank_rec.organization_rec.party_rec.attribute3 := p1_a158;
    ddp_bank_rec.organization_rec.party_rec.attribute4 := p1_a159;
    ddp_bank_rec.organization_rec.party_rec.attribute5 := p1_a160;
    ddp_bank_rec.organization_rec.party_rec.attribute6 := p1_a161;
    ddp_bank_rec.organization_rec.party_rec.attribute7 := p1_a162;
    ddp_bank_rec.organization_rec.party_rec.attribute8 := p1_a163;
    ddp_bank_rec.organization_rec.party_rec.attribute9 := p1_a164;
    ddp_bank_rec.organization_rec.party_rec.attribute10 := p1_a165;
    ddp_bank_rec.organization_rec.party_rec.attribute11 := p1_a166;
    ddp_bank_rec.organization_rec.party_rec.attribute12 := p1_a167;
    ddp_bank_rec.organization_rec.party_rec.attribute13 := p1_a168;
    ddp_bank_rec.organization_rec.party_rec.attribute14 := p1_a169;
    ddp_bank_rec.organization_rec.party_rec.attribute15 := p1_a170;
    ddp_bank_rec.organization_rec.party_rec.attribute16 := p1_a171;
    ddp_bank_rec.organization_rec.party_rec.attribute17 := p1_a172;
    ddp_bank_rec.organization_rec.party_rec.attribute18 := p1_a173;
    ddp_bank_rec.organization_rec.party_rec.attribute19 := p1_a174;
    ddp_bank_rec.organization_rec.party_rec.attribute20 := p1_a175;
    ddp_bank_rec.organization_rec.party_rec.attribute21 := p1_a176;
    ddp_bank_rec.organization_rec.party_rec.attribute22 := p1_a177;
    ddp_bank_rec.organization_rec.party_rec.attribute23 := p1_a178;
    ddp_bank_rec.organization_rec.party_rec.attribute24 := p1_a179;








    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_bank(p_init_msg_list,
      ddp_bank_rec,
      x_party_id,
      x_party_number,
      x_profile_id,
      x_code_assignment_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_bank_2(p_init_msg_list  VARCHAR2
    , p_pobject_version_number in out nocopy  NUMBER
    , p_bitobject_version_number in out nocopy  NUMBER
    , x_profile_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  DATE := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  DATE := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  NUMBER := null
    , p1_a56  NUMBER := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  NUMBER := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  NUMBER := null
    , p1_a89  NUMBER := null
    , p1_a90  NUMBER := null
    , p1_a91  NUMBER := null
    , p1_a92  NUMBER := null
    , p1_a93  DATE := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  NUMBER := null
    , p1_a104  NUMBER := null
    , p1_a105  NUMBER := null
    , p1_a106  DATE := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  NUMBER := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  NUMBER := null
    , p1_a119  VARCHAR2 := null
    , p1_a120  VARCHAR2 := null
    , p1_a121  VARCHAR2 := null
    , p1_a122  VARCHAR2 := null
    , p1_a123  VARCHAR2 := null
    , p1_a124  VARCHAR2 := null
    , p1_a125  VARCHAR2 := null
    , p1_a126  VARCHAR2 := null
    , p1_a127  VARCHAR2 := null
    , p1_a128  VARCHAR2 := null
    , p1_a129  VARCHAR2 := null
    , p1_a130  VARCHAR2 := null
    , p1_a131  VARCHAR2 := null
    , p1_a132  VARCHAR2 := null
    , p1_a133  VARCHAR2 := null
    , p1_a134  VARCHAR2 := null
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  NUMBER := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  NUMBER := null
    , p1_a148  VARCHAR2 := null
    , p1_a149  VARCHAR2 := null
    , p1_a150  VARCHAR2 := null
    , p1_a151  VARCHAR2 := null
    , p1_a152  VARCHAR2 := null
    , p1_a153  VARCHAR2 := null
    , p1_a154  VARCHAR2 := null
    , p1_a155  VARCHAR2 := null
    , p1_a156  VARCHAR2 := null
    , p1_a157  VARCHAR2 := null
    , p1_a158  VARCHAR2 := null
    , p1_a159  VARCHAR2 := null
    , p1_a160  VARCHAR2 := null
    , p1_a161  VARCHAR2 := null
    , p1_a162  VARCHAR2 := null
    , p1_a163  VARCHAR2 := null
    , p1_a164  VARCHAR2 := null
    , p1_a165  VARCHAR2 := null
    , p1_a166  VARCHAR2 := null
    , p1_a167  VARCHAR2 := null
    , p1_a168  VARCHAR2 := null
    , p1_a169  VARCHAR2 := null
    , p1_a170  VARCHAR2 := null
    , p1_a171  VARCHAR2 := null
    , p1_a172  VARCHAR2 := null
    , p1_a173  VARCHAR2 := null
    , p1_a174  VARCHAR2 := null
    , p1_a175  VARCHAR2 := null
    , p1_a176  VARCHAR2 := null
    , p1_a177  VARCHAR2 := null
    , p1_a178  VARCHAR2 := null
    , p1_a179  VARCHAR2 := null
  )
  as
    ddp_bank_rec hz_bank_pub.bank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_bank_rec.bank_or_branch_number := p1_a0;
    ddp_bank_rec.bank_code := p1_a1;
    ddp_bank_rec.branch_code := p1_a2;
    ddp_bank_rec.institution_type := p1_a3;
    ddp_bank_rec.branch_type := p1_a4;
    ddp_bank_rec.country := p1_a5;
    ddp_bank_rec.rfc_code := p1_a6;
    ddp_bank_rec.inactive_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_bank_rec.organization_rec.organization_name := p1_a8;
    ddp_bank_rec.organization_rec.duns_number_c := p1_a9;
    ddp_bank_rec.organization_rec.enquiry_duns := p1_a10;
    ddp_bank_rec.organization_rec.ceo_name := p1_a11;
    ddp_bank_rec.organization_rec.ceo_title := p1_a12;
    ddp_bank_rec.organization_rec.principal_name := p1_a13;
    ddp_bank_rec.organization_rec.principal_title := p1_a14;
    ddp_bank_rec.organization_rec.legal_status := p1_a15;
    ddp_bank_rec.organization_rec.control_yr := rosetta_g_miss_num_map(p1_a16);
    ddp_bank_rec.organization_rec.employees_total := rosetta_g_miss_num_map(p1_a17);
    ddp_bank_rec.organization_rec.hq_branch_ind := p1_a18;
    ddp_bank_rec.organization_rec.branch_flag := p1_a19;
    ddp_bank_rec.organization_rec.oob_ind := p1_a20;
    ddp_bank_rec.organization_rec.line_of_business := p1_a21;
    ddp_bank_rec.organization_rec.cong_dist_code := p1_a22;
    ddp_bank_rec.organization_rec.sic_code := p1_a23;
    ddp_bank_rec.organization_rec.import_ind := p1_a24;
    ddp_bank_rec.organization_rec.export_ind := p1_a25;
    ddp_bank_rec.organization_rec.labor_surplus_ind := p1_a26;
    ddp_bank_rec.organization_rec.debarment_ind := p1_a27;
    ddp_bank_rec.organization_rec.minority_owned_ind := p1_a28;
    ddp_bank_rec.organization_rec.minority_owned_type := p1_a29;
    ddp_bank_rec.organization_rec.woman_owned_ind := p1_a30;
    ddp_bank_rec.organization_rec.disadv_8a_ind := p1_a31;
    ddp_bank_rec.organization_rec.small_bus_ind := p1_a32;
    ddp_bank_rec.organization_rec.rent_own_ind := p1_a33;
    ddp_bank_rec.organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a34);
    ddp_bank_rec.organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a35);
    ddp_bank_rec.organization_rec.failure_score := p1_a36;
    ddp_bank_rec.organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a37);
    ddp_bank_rec.organization_rec.failure_score_override_code := p1_a38;
    ddp_bank_rec.organization_rec.failure_score_commentary := p1_a39;
    ddp_bank_rec.organization_rec.global_failure_score := p1_a40;
    ddp_bank_rec.organization_rec.db_rating := p1_a41;
    ddp_bank_rec.organization_rec.credit_score := p1_a42;
    ddp_bank_rec.organization_rec.credit_score_commentary := p1_a43;
    ddp_bank_rec.organization_rec.paydex_score := p1_a44;
    ddp_bank_rec.organization_rec.paydex_three_months_ago := p1_a45;
    ddp_bank_rec.organization_rec.paydex_norm := p1_a46;
    ddp_bank_rec.organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a47);
    ddp_bank_rec.organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a48);
    ddp_bank_rec.organization_rec.organization_name_phonetic := p1_a49;
    ddp_bank_rec.organization_rec.tax_reference := p1_a50;
    ddp_bank_rec.organization_rec.gsa_indicator_flag := p1_a51;
    ddp_bank_rec.organization_rec.jgzz_fiscal_code := p1_a52;
    ddp_bank_rec.organization_rec.analysis_fy := p1_a53;
    ddp_bank_rec.organization_rec.fiscal_yearend_month := p1_a54;
    ddp_bank_rec.organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a55);
    ddp_bank_rec.organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a56);
    ddp_bank_rec.organization_rec.year_established := rosetta_g_miss_num_map(p1_a57);
    ddp_bank_rec.organization_rec.mission_statement := p1_a58;
    ddp_bank_rec.organization_rec.organization_type := p1_a59;
    ddp_bank_rec.organization_rec.business_scope := p1_a60;
    ddp_bank_rec.organization_rec.corporation_class := p1_a61;
    ddp_bank_rec.organization_rec.known_as := p1_a62;
    ddp_bank_rec.organization_rec.known_as2 := p1_a63;
    ddp_bank_rec.organization_rec.known_as3 := p1_a64;
    ddp_bank_rec.organization_rec.known_as4 := p1_a65;
    ddp_bank_rec.organization_rec.known_as5 := p1_a66;
    ddp_bank_rec.organization_rec.local_bus_iden_type := p1_a67;
    ddp_bank_rec.organization_rec.local_bus_identifier := p1_a68;
    ddp_bank_rec.organization_rec.pref_functional_currency := p1_a69;
    ddp_bank_rec.organization_rec.registration_type := p1_a70;
    ddp_bank_rec.organization_rec.total_employees_text := p1_a71;
    ddp_bank_rec.organization_rec.total_employees_ind := p1_a72;
    ddp_bank_rec.organization_rec.total_emp_est_ind := p1_a73;
    ddp_bank_rec.organization_rec.total_emp_min_ind := p1_a74;
    ddp_bank_rec.organization_rec.parent_sub_ind := p1_a75;
    ddp_bank_rec.organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a76);
    ddp_bank_rec.organization_rec.sic_code_type := p1_a77;
    ddp_bank_rec.organization_rec.public_private_ownership_flag := p1_a78;
    ddp_bank_rec.organization_rec.internal_flag := p1_a79;
    ddp_bank_rec.organization_rec.local_activity_code_type := p1_a80;
    ddp_bank_rec.organization_rec.local_activity_code := p1_a81;
    ddp_bank_rec.organization_rec.emp_at_primary_adr := p1_a82;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_text := p1_a83;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_est_ind := p1_a84;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_min_ind := p1_a85;
    ddp_bank_rec.organization_rec.high_credit := rosetta_g_miss_num_map(p1_a86);
    ddp_bank_rec.organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a87);
    ddp_bank_rec.organization_rec.total_payments := rosetta_g_miss_num_map(p1_a88);
    ddp_bank_rec.organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a89);
    ddp_bank_rec.organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a90);
    ddp_bank_rec.organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a91);
    ddp_bank_rec.organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a92);
    ddp_bank_rec.organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_bank_rec.organization_rec.credit_score_commentary2 := p1_a94;
    ddp_bank_rec.organization_rec.credit_score_commentary3 := p1_a95;
    ddp_bank_rec.organization_rec.credit_score_commentary4 := p1_a96;
    ddp_bank_rec.organization_rec.credit_score_commentary5 := p1_a97;
    ddp_bank_rec.organization_rec.credit_score_commentary6 := p1_a98;
    ddp_bank_rec.organization_rec.credit_score_commentary7 := p1_a99;
    ddp_bank_rec.organization_rec.credit_score_commentary8 := p1_a100;
    ddp_bank_rec.organization_rec.credit_score_commentary9 := p1_a101;
    ddp_bank_rec.organization_rec.credit_score_commentary10 := p1_a102;
    ddp_bank_rec.organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a103);
    ddp_bank_rec.organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a104);
    ddp_bank_rec.organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a105);
    ddp_bank_rec.organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_bank_rec.organization_rec.failure_score_commentary2 := p1_a107;
    ddp_bank_rec.organization_rec.failure_score_commentary3 := p1_a108;
    ddp_bank_rec.organization_rec.failure_score_commentary4 := p1_a109;
    ddp_bank_rec.organization_rec.failure_score_commentary5 := p1_a110;
    ddp_bank_rec.organization_rec.failure_score_commentary6 := p1_a111;
    ddp_bank_rec.organization_rec.failure_score_commentary7 := p1_a112;
    ddp_bank_rec.organization_rec.failure_score_commentary8 := p1_a113;
    ddp_bank_rec.organization_rec.failure_score_commentary9 := p1_a114;
    ddp_bank_rec.organization_rec.failure_score_commentary10 := p1_a115;
    ddp_bank_rec.organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a116);
    ddp_bank_rec.organization_rec.maximum_credit_currency_code := p1_a117;
    ddp_bank_rec.organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a118);
    ddp_bank_rec.organization_rec.content_source_type := p1_a119;
    ddp_bank_rec.organization_rec.content_source_number := p1_a120;
    ddp_bank_rec.organization_rec.attribute_category := p1_a121;
    ddp_bank_rec.organization_rec.attribute1 := p1_a122;
    ddp_bank_rec.organization_rec.attribute2 := p1_a123;
    ddp_bank_rec.organization_rec.attribute3 := p1_a124;
    ddp_bank_rec.organization_rec.attribute4 := p1_a125;
    ddp_bank_rec.organization_rec.attribute5 := p1_a126;
    ddp_bank_rec.organization_rec.attribute6 := p1_a127;
    ddp_bank_rec.organization_rec.attribute7 := p1_a128;
    ddp_bank_rec.organization_rec.attribute8 := p1_a129;
    ddp_bank_rec.organization_rec.attribute9 := p1_a130;
    ddp_bank_rec.organization_rec.attribute10 := p1_a131;
    ddp_bank_rec.organization_rec.attribute11 := p1_a132;
    ddp_bank_rec.organization_rec.attribute12 := p1_a133;
    ddp_bank_rec.organization_rec.attribute13 := p1_a134;
    ddp_bank_rec.organization_rec.attribute14 := p1_a135;
    ddp_bank_rec.organization_rec.attribute15 := p1_a136;
    ddp_bank_rec.organization_rec.attribute16 := p1_a137;
    ddp_bank_rec.organization_rec.attribute17 := p1_a138;
    ddp_bank_rec.organization_rec.attribute18 := p1_a139;
    ddp_bank_rec.organization_rec.attribute19 := p1_a140;
    ddp_bank_rec.organization_rec.attribute20 := p1_a141;
    ddp_bank_rec.organization_rec.created_by_module := p1_a142;
    ddp_bank_rec.organization_rec.application_id := rosetta_g_miss_num_map(p1_a143);
    ddp_bank_rec.organization_rec.do_not_confuse_with := p1_a144;
    ddp_bank_rec.organization_rec.actual_content_source := p1_a145;
    ddp_bank_rec.organization_rec.home_country := p1_a146;
    ddp_bank_rec.organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a147);
    ddp_bank_rec.organization_rec.party_rec.party_number := p1_a148;
    ddp_bank_rec.organization_rec.party_rec.validated_flag := p1_a149;
    ddp_bank_rec.organization_rec.party_rec.orig_system_reference := p1_a150;
    ddp_bank_rec.organization_rec.party_rec.orig_system := p1_a151;
    ddp_bank_rec.organization_rec.party_rec.status := p1_a152;
    ddp_bank_rec.organization_rec.party_rec.category_code := p1_a153;
    ddp_bank_rec.organization_rec.party_rec.salutation := p1_a154;
    ddp_bank_rec.organization_rec.party_rec.attribute_category := p1_a155;
    ddp_bank_rec.organization_rec.party_rec.attribute1 := p1_a156;
    ddp_bank_rec.organization_rec.party_rec.attribute2 := p1_a157;
    ddp_bank_rec.organization_rec.party_rec.attribute3 := p1_a158;
    ddp_bank_rec.organization_rec.party_rec.attribute4 := p1_a159;
    ddp_bank_rec.organization_rec.party_rec.attribute5 := p1_a160;
    ddp_bank_rec.organization_rec.party_rec.attribute6 := p1_a161;
    ddp_bank_rec.organization_rec.party_rec.attribute7 := p1_a162;
    ddp_bank_rec.organization_rec.party_rec.attribute8 := p1_a163;
    ddp_bank_rec.organization_rec.party_rec.attribute9 := p1_a164;
    ddp_bank_rec.organization_rec.party_rec.attribute10 := p1_a165;
    ddp_bank_rec.organization_rec.party_rec.attribute11 := p1_a166;
    ddp_bank_rec.organization_rec.party_rec.attribute12 := p1_a167;
    ddp_bank_rec.organization_rec.party_rec.attribute13 := p1_a168;
    ddp_bank_rec.organization_rec.party_rec.attribute14 := p1_a169;
    ddp_bank_rec.organization_rec.party_rec.attribute15 := p1_a170;
    ddp_bank_rec.organization_rec.party_rec.attribute16 := p1_a171;
    ddp_bank_rec.organization_rec.party_rec.attribute17 := p1_a172;
    ddp_bank_rec.organization_rec.party_rec.attribute18 := p1_a173;
    ddp_bank_rec.organization_rec.party_rec.attribute19 := p1_a174;
    ddp_bank_rec.organization_rec.party_rec.attribute20 := p1_a175;
    ddp_bank_rec.organization_rec.party_rec.attribute21 := p1_a176;
    ddp_bank_rec.organization_rec.party_rec.attribute22 := p1_a177;
    ddp_bank_rec.organization_rec.party_rec.attribute23 := p1_a178;
    ddp_bank_rec.organization_rec.party_rec.attribute24 := p1_a179;







    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_bank(p_init_msg_list,
      ddp_bank_rec,
      p_pobject_version_number,
      p_bitobject_version_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_bank_branch_3(p_init_msg_list  VARCHAR2
    , p_bank_party_id  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_profile_id out nocopy  NUMBER
    , x_relationship_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_rel_party_number out nocopy  NUMBER
    , x_bitcode_assignment_id out nocopy  NUMBER
    , x_bbtcode_assignment_id out nocopy  NUMBER
    , x_rfccode_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  DATE := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  DATE := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  NUMBER := null
    , p1_a56  NUMBER := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  NUMBER := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  NUMBER := null
    , p1_a89  NUMBER := null
    , p1_a90  NUMBER := null
    , p1_a91  NUMBER := null
    , p1_a92  NUMBER := null
    , p1_a93  DATE := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  NUMBER := null
    , p1_a104  NUMBER := null
    , p1_a105  NUMBER := null
    , p1_a106  DATE := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  NUMBER := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  NUMBER := null
    , p1_a119  VARCHAR2 := null
    , p1_a120  VARCHAR2 := null
    , p1_a121  VARCHAR2 := null
    , p1_a122  VARCHAR2 := null
    , p1_a123  VARCHAR2 := null
    , p1_a124  VARCHAR2 := null
    , p1_a125  VARCHAR2 := null
    , p1_a126  VARCHAR2 := null
    , p1_a127  VARCHAR2 := null
    , p1_a128  VARCHAR2 := null
    , p1_a129  VARCHAR2 := null
    , p1_a130  VARCHAR2 := null
    , p1_a131  VARCHAR2 := null
    , p1_a132  VARCHAR2 := null
    , p1_a133  VARCHAR2 := null
    , p1_a134  VARCHAR2 := null
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  NUMBER := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  NUMBER := null
    , p1_a148  VARCHAR2 := null
    , p1_a149  VARCHAR2 := null
    , p1_a150  VARCHAR2 := null
    , p1_a151  VARCHAR2 := null
    , p1_a152  VARCHAR2 := null
    , p1_a153  VARCHAR2 := null
    , p1_a154  VARCHAR2 := null
    , p1_a155  VARCHAR2 := null
    , p1_a156  VARCHAR2 := null
    , p1_a157  VARCHAR2 := null
    , p1_a158  VARCHAR2 := null
    , p1_a159  VARCHAR2 := null
    , p1_a160  VARCHAR2 := null
    , p1_a161  VARCHAR2 := null
    , p1_a162  VARCHAR2 := null
    , p1_a163  VARCHAR2 := null
    , p1_a164  VARCHAR2 := null
    , p1_a165  VARCHAR2 := null
    , p1_a166  VARCHAR2 := null
    , p1_a167  VARCHAR2 := null
    , p1_a168  VARCHAR2 := null
    , p1_a169  VARCHAR2 := null
    , p1_a170  VARCHAR2 := null
    , p1_a171  VARCHAR2 := null
    , p1_a172  VARCHAR2 := null
    , p1_a173  VARCHAR2 := null
    , p1_a174  VARCHAR2 := null
    , p1_a175  VARCHAR2 := null
    , p1_a176  VARCHAR2 := null
    , p1_a177  VARCHAR2 := null
    , p1_a178  VARCHAR2 := null
    , p1_a179  VARCHAR2 := null
  )
  as
    ddp_bank_rec hz_bank_pub.bank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_bank_rec.bank_or_branch_number := p1_a0;
    ddp_bank_rec.bank_code := p1_a1;
    ddp_bank_rec.branch_code := p1_a2;
    ddp_bank_rec.institution_type := p1_a3;
    ddp_bank_rec.branch_type := p1_a4;
    ddp_bank_rec.country := p1_a5;
    ddp_bank_rec.rfc_code := p1_a6;
    ddp_bank_rec.inactive_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_bank_rec.organization_rec.organization_name := p1_a8;
    ddp_bank_rec.organization_rec.duns_number_c := p1_a9;
    ddp_bank_rec.organization_rec.enquiry_duns := p1_a10;
    ddp_bank_rec.organization_rec.ceo_name := p1_a11;
    ddp_bank_rec.organization_rec.ceo_title := p1_a12;
    ddp_bank_rec.organization_rec.principal_name := p1_a13;
    ddp_bank_rec.organization_rec.principal_title := p1_a14;
    ddp_bank_rec.organization_rec.legal_status := p1_a15;
    ddp_bank_rec.organization_rec.control_yr := rosetta_g_miss_num_map(p1_a16);
    ddp_bank_rec.organization_rec.employees_total := rosetta_g_miss_num_map(p1_a17);
    ddp_bank_rec.organization_rec.hq_branch_ind := p1_a18;
    ddp_bank_rec.organization_rec.branch_flag := p1_a19;
    ddp_bank_rec.organization_rec.oob_ind := p1_a20;
    ddp_bank_rec.organization_rec.line_of_business := p1_a21;
    ddp_bank_rec.organization_rec.cong_dist_code := p1_a22;
    ddp_bank_rec.organization_rec.sic_code := p1_a23;
    ddp_bank_rec.organization_rec.import_ind := p1_a24;
    ddp_bank_rec.organization_rec.export_ind := p1_a25;
    ddp_bank_rec.organization_rec.labor_surplus_ind := p1_a26;
    ddp_bank_rec.organization_rec.debarment_ind := p1_a27;
    ddp_bank_rec.organization_rec.minority_owned_ind := p1_a28;
    ddp_bank_rec.organization_rec.minority_owned_type := p1_a29;
    ddp_bank_rec.organization_rec.woman_owned_ind := p1_a30;
    ddp_bank_rec.organization_rec.disadv_8a_ind := p1_a31;
    ddp_bank_rec.organization_rec.small_bus_ind := p1_a32;
    ddp_bank_rec.organization_rec.rent_own_ind := p1_a33;
    ddp_bank_rec.organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a34);
    ddp_bank_rec.organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a35);
    ddp_bank_rec.organization_rec.failure_score := p1_a36;
    ddp_bank_rec.organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a37);
    ddp_bank_rec.organization_rec.failure_score_override_code := p1_a38;
    ddp_bank_rec.organization_rec.failure_score_commentary := p1_a39;
    ddp_bank_rec.organization_rec.global_failure_score := p1_a40;
    ddp_bank_rec.organization_rec.db_rating := p1_a41;
    ddp_bank_rec.organization_rec.credit_score := p1_a42;
    ddp_bank_rec.organization_rec.credit_score_commentary := p1_a43;
    ddp_bank_rec.organization_rec.paydex_score := p1_a44;
    ddp_bank_rec.organization_rec.paydex_three_months_ago := p1_a45;
    ddp_bank_rec.organization_rec.paydex_norm := p1_a46;
    ddp_bank_rec.organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a47);
    ddp_bank_rec.organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a48);
    ddp_bank_rec.organization_rec.organization_name_phonetic := p1_a49;
    ddp_bank_rec.organization_rec.tax_reference := p1_a50;
    ddp_bank_rec.organization_rec.gsa_indicator_flag := p1_a51;
    ddp_bank_rec.organization_rec.jgzz_fiscal_code := p1_a52;
    ddp_bank_rec.organization_rec.analysis_fy := p1_a53;
    ddp_bank_rec.organization_rec.fiscal_yearend_month := p1_a54;
    ddp_bank_rec.organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a55);
    ddp_bank_rec.organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a56);
    ddp_bank_rec.organization_rec.year_established := rosetta_g_miss_num_map(p1_a57);
    ddp_bank_rec.organization_rec.mission_statement := p1_a58;
    ddp_bank_rec.organization_rec.organization_type := p1_a59;
    ddp_bank_rec.organization_rec.business_scope := p1_a60;
    ddp_bank_rec.organization_rec.corporation_class := p1_a61;
    ddp_bank_rec.organization_rec.known_as := p1_a62;
    ddp_bank_rec.organization_rec.known_as2 := p1_a63;
    ddp_bank_rec.organization_rec.known_as3 := p1_a64;
    ddp_bank_rec.organization_rec.known_as4 := p1_a65;
    ddp_bank_rec.organization_rec.known_as5 := p1_a66;
    ddp_bank_rec.organization_rec.local_bus_iden_type := p1_a67;
    ddp_bank_rec.organization_rec.local_bus_identifier := p1_a68;
    ddp_bank_rec.organization_rec.pref_functional_currency := p1_a69;
    ddp_bank_rec.organization_rec.registration_type := p1_a70;
    ddp_bank_rec.organization_rec.total_employees_text := p1_a71;
    ddp_bank_rec.organization_rec.total_employees_ind := p1_a72;
    ddp_bank_rec.organization_rec.total_emp_est_ind := p1_a73;
    ddp_bank_rec.organization_rec.total_emp_min_ind := p1_a74;
    ddp_bank_rec.organization_rec.parent_sub_ind := p1_a75;
    ddp_bank_rec.organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a76);
    ddp_bank_rec.organization_rec.sic_code_type := p1_a77;
    ddp_bank_rec.organization_rec.public_private_ownership_flag := p1_a78;
    ddp_bank_rec.organization_rec.internal_flag := p1_a79;
    ddp_bank_rec.organization_rec.local_activity_code_type := p1_a80;
    ddp_bank_rec.organization_rec.local_activity_code := p1_a81;
    ddp_bank_rec.organization_rec.emp_at_primary_adr := p1_a82;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_text := p1_a83;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_est_ind := p1_a84;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_min_ind := p1_a85;
    ddp_bank_rec.organization_rec.high_credit := rosetta_g_miss_num_map(p1_a86);
    ddp_bank_rec.organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a87);
    ddp_bank_rec.organization_rec.total_payments := rosetta_g_miss_num_map(p1_a88);
    ddp_bank_rec.organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a89);
    ddp_bank_rec.organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a90);
    ddp_bank_rec.organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a91);
    ddp_bank_rec.organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a92);
    ddp_bank_rec.organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_bank_rec.organization_rec.credit_score_commentary2 := p1_a94;
    ddp_bank_rec.organization_rec.credit_score_commentary3 := p1_a95;
    ddp_bank_rec.organization_rec.credit_score_commentary4 := p1_a96;
    ddp_bank_rec.organization_rec.credit_score_commentary5 := p1_a97;
    ddp_bank_rec.organization_rec.credit_score_commentary6 := p1_a98;
    ddp_bank_rec.organization_rec.credit_score_commentary7 := p1_a99;
    ddp_bank_rec.organization_rec.credit_score_commentary8 := p1_a100;
    ddp_bank_rec.organization_rec.credit_score_commentary9 := p1_a101;
    ddp_bank_rec.organization_rec.credit_score_commentary10 := p1_a102;
    ddp_bank_rec.organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a103);
    ddp_bank_rec.organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a104);
    ddp_bank_rec.organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a105);
    ddp_bank_rec.organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_bank_rec.organization_rec.failure_score_commentary2 := p1_a107;
    ddp_bank_rec.organization_rec.failure_score_commentary3 := p1_a108;
    ddp_bank_rec.organization_rec.failure_score_commentary4 := p1_a109;
    ddp_bank_rec.organization_rec.failure_score_commentary5 := p1_a110;
    ddp_bank_rec.organization_rec.failure_score_commentary6 := p1_a111;
    ddp_bank_rec.organization_rec.failure_score_commentary7 := p1_a112;
    ddp_bank_rec.organization_rec.failure_score_commentary8 := p1_a113;
    ddp_bank_rec.organization_rec.failure_score_commentary9 := p1_a114;
    ddp_bank_rec.organization_rec.failure_score_commentary10 := p1_a115;
    ddp_bank_rec.organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a116);
    ddp_bank_rec.organization_rec.maximum_credit_currency_code := p1_a117;
    ddp_bank_rec.organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a118);
    ddp_bank_rec.organization_rec.content_source_type := p1_a119;
    ddp_bank_rec.organization_rec.content_source_number := p1_a120;
    ddp_bank_rec.organization_rec.attribute_category := p1_a121;
    ddp_bank_rec.organization_rec.attribute1 := p1_a122;
    ddp_bank_rec.organization_rec.attribute2 := p1_a123;
    ddp_bank_rec.organization_rec.attribute3 := p1_a124;
    ddp_bank_rec.organization_rec.attribute4 := p1_a125;
    ddp_bank_rec.organization_rec.attribute5 := p1_a126;
    ddp_bank_rec.organization_rec.attribute6 := p1_a127;
    ddp_bank_rec.organization_rec.attribute7 := p1_a128;
    ddp_bank_rec.organization_rec.attribute8 := p1_a129;
    ddp_bank_rec.organization_rec.attribute9 := p1_a130;
    ddp_bank_rec.organization_rec.attribute10 := p1_a131;
    ddp_bank_rec.organization_rec.attribute11 := p1_a132;
    ddp_bank_rec.organization_rec.attribute12 := p1_a133;
    ddp_bank_rec.organization_rec.attribute13 := p1_a134;
    ddp_bank_rec.organization_rec.attribute14 := p1_a135;
    ddp_bank_rec.organization_rec.attribute15 := p1_a136;
    ddp_bank_rec.organization_rec.attribute16 := p1_a137;
    ddp_bank_rec.organization_rec.attribute17 := p1_a138;
    ddp_bank_rec.organization_rec.attribute18 := p1_a139;
    ddp_bank_rec.organization_rec.attribute19 := p1_a140;
    ddp_bank_rec.organization_rec.attribute20 := p1_a141;
    ddp_bank_rec.organization_rec.created_by_module := p1_a142;
    ddp_bank_rec.organization_rec.application_id := rosetta_g_miss_num_map(p1_a143);
    ddp_bank_rec.organization_rec.do_not_confuse_with := p1_a144;
    ddp_bank_rec.organization_rec.actual_content_source := p1_a145;
    ddp_bank_rec.organization_rec.home_country := p1_a146;
    ddp_bank_rec.organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a147);
    ddp_bank_rec.organization_rec.party_rec.party_number := p1_a148;
    ddp_bank_rec.organization_rec.party_rec.validated_flag := p1_a149;
    ddp_bank_rec.organization_rec.party_rec.orig_system_reference := p1_a150;
    ddp_bank_rec.organization_rec.party_rec.orig_system := p1_a151;
    ddp_bank_rec.organization_rec.party_rec.status := p1_a152;
    ddp_bank_rec.organization_rec.party_rec.category_code := p1_a153;
    ddp_bank_rec.organization_rec.party_rec.salutation := p1_a154;
    ddp_bank_rec.organization_rec.party_rec.attribute_category := p1_a155;
    ddp_bank_rec.organization_rec.party_rec.attribute1 := p1_a156;
    ddp_bank_rec.organization_rec.party_rec.attribute2 := p1_a157;
    ddp_bank_rec.organization_rec.party_rec.attribute3 := p1_a158;
    ddp_bank_rec.organization_rec.party_rec.attribute4 := p1_a159;
    ddp_bank_rec.organization_rec.party_rec.attribute5 := p1_a160;
    ddp_bank_rec.organization_rec.party_rec.attribute6 := p1_a161;
    ddp_bank_rec.organization_rec.party_rec.attribute7 := p1_a162;
    ddp_bank_rec.organization_rec.party_rec.attribute8 := p1_a163;
    ddp_bank_rec.organization_rec.party_rec.attribute9 := p1_a164;
    ddp_bank_rec.organization_rec.party_rec.attribute10 := p1_a165;
    ddp_bank_rec.organization_rec.party_rec.attribute11 := p1_a166;
    ddp_bank_rec.organization_rec.party_rec.attribute12 := p1_a167;
    ddp_bank_rec.organization_rec.party_rec.attribute13 := p1_a168;
    ddp_bank_rec.organization_rec.party_rec.attribute14 := p1_a169;
    ddp_bank_rec.organization_rec.party_rec.attribute15 := p1_a170;
    ddp_bank_rec.organization_rec.party_rec.attribute16 := p1_a171;
    ddp_bank_rec.organization_rec.party_rec.attribute17 := p1_a172;
    ddp_bank_rec.organization_rec.party_rec.attribute18 := p1_a173;
    ddp_bank_rec.organization_rec.party_rec.attribute19 := p1_a174;
    ddp_bank_rec.organization_rec.party_rec.attribute20 := p1_a175;
    ddp_bank_rec.organization_rec.party_rec.attribute21 := p1_a176;
    ddp_bank_rec.organization_rec.party_rec.attribute22 := p1_a177;
    ddp_bank_rec.organization_rec.party_rec.attribute23 := p1_a178;
    ddp_bank_rec.organization_rec.party_rec.attribute24 := p1_a179;














    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_bank_branch(p_init_msg_list,
      ddp_bank_rec,
      p_bank_party_id,
      x_party_id,
      x_party_number,
      x_profile_id,
      x_relationship_id,
      x_rel_party_id,
      x_rel_party_number,
      x_bitcode_assignment_id,
      x_bbtcode_assignment_id,
      x_rfccode_assignment_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any














  end;

  procedure update_bank_branch_4(p_init_msg_list  VARCHAR2
    , p_bank_party_id  NUMBER
    , p_relationship_id in out nocopy  NUMBER
    , p_pobject_version_number in out nocopy  NUMBER
    , p_bbtobject_version_number in out nocopy  NUMBER
    , p_rfcobject_version_number in out nocopy  NUMBER
    , x_profile_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_rel_party_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  DATE := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  DATE := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  NUMBER := null
    , p1_a56  NUMBER := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  NUMBER := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  NUMBER := null
    , p1_a89  NUMBER := null
    , p1_a90  NUMBER := null
    , p1_a91  NUMBER := null
    , p1_a92  NUMBER := null
    , p1_a93  DATE := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  NUMBER := null
    , p1_a104  NUMBER := null
    , p1_a105  NUMBER := null
    , p1_a106  DATE := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  NUMBER := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  NUMBER := null
    , p1_a119  VARCHAR2 := null
    , p1_a120  VARCHAR2 := null
    , p1_a121  VARCHAR2 := null
    , p1_a122  VARCHAR2 := null
    , p1_a123  VARCHAR2 := null
    , p1_a124  VARCHAR2 := null
    , p1_a125  VARCHAR2 := null
    , p1_a126  VARCHAR2 := null
    , p1_a127  VARCHAR2 := null
    , p1_a128  VARCHAR2 := null
    , p1_a129  VARCHAR2 := null
    , p1_a130  VARCHAR2 := null
    , p1_a131  VARCHAR2 := null
    , p1_a132  VARCHAR2 := null
    , p1_a133  VARCHAR2 := null
    , p1_a134  VARCHAR2 := null
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  NUMBER := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  NUMBER := null
    , p1_a148  VARCHAR2 := null
    , p1_a149  VARCHAR2 := null
    , p1_a150  VARCHAR2 := null
    , p1_a151  VARCHAR2 := null
    , p1_a152  VARCHAR2 := null
    , p1_a153  VARCHAR2 := null
    , p1_a154  VARCHAR2 := null
    , p1_a155  VARCHAR2 := null
    , p1_a156  VARCHAR2 := null
    , p1_a157  VARCHAR2 := null
    , p1_a158  VARCHAR2 := null
    , p1_a159  VARCHAR2 := null
    , p1_a160  VARCHAR2 := null
    , p1_a161  VARCHAR2 := null
    , p1_a162  VARCHAR2 := null
    , p1_a163  VARCHAR2 := null
    , p1_a164  VARCHAR2 := null
    , p1_a165  VARCHAR2 := null
    , p1_a166  VARCHAR2 := null
    , p1_a167  VARCHAR2 := null
    , p1_a168  VARCHAR2 := null
    , p1_a169  VARCHAR2 := null
    , p1_a170  VARCHAR2 := null
    , p1_a171  VARCHAR2 := null
    , p1_a172  VARCHAR2 := null
    , p1_a173  VARCHAR2 := null
    , p1_a174  VARCHAR2 := null
    , p1_a175  VARCHAR2 := null
    , p1_a176  VARCHAR2 := null
    , p1_a177  VARCHAR2 := null
    , p1_a178  VARCHAR2 := null
    , p1_a179  VARCHAR2 := null
  )
  as
    ddp_bank_rec hz_bank_pub.bank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_bank_rec.bank_or_branch_number := p1_a0;
    ddp_bank_rec.bank_code := p1_a1;
    ddp_bank_rec.branch_code := p1_a2;
    ddp_bank_rec.institution_type := p1_a3;
    ddp_bank_rec.branch_type := p1_a4;
    ddp_bank_rec.country := p1_a5;
    ddp_bank_rec.rfc_code := p1_a6;
    ddp_bank_rec.inactive_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_bank_rec.organization_rec.organization_name := p1_a8;
    ddp_bank_rec.organization_rec.duns_number_c := p1_a9;
    ddp_bank_rec.organization_rec.enquiry_duns := p1_a10;
    ddp_bank_rec.organization_rec.ceo_name := p1_a11;
    ddp_bank_rec.organization_rec.ceo_title := p1_a12;
    ddp_bank_rec.organization_rec.principal_name := p1_a13;
    ddp_bank_rec.organization_rec.principal_title := p1_a14;
    ddp_bank_rec.organization_rec.legal_status := p1_a15;
    ddp_bank_rec.organization_rec.control_yr := rosetta_g_miss_num_map(p1_a16);
    ddp_bank_rec.organization_rec.employees_total := rosetta_g_miss_num_map(p1_a17);
    ddp_bank_rec.organization_rec.hq_branch_ind := p1_a18;
    ddp_bank_rec.organization_rec.branch_flag := p1_a19;
    ddp_bank_rec.organization_rec.oob_ind := p1_a20;
    ddp_bank_rec.organization_rec.line_of_business := p1_a21;
    ddp_bank_rec.organization_rec.cong_dist_code := p1_a22;
    ddp_bank_rec.organization_rec.sic_code := p1_a23;
    ddp_bank_rec.organization_rec.import_ind := p1_a24;
    ddp_bank_rec.organization_rec.export_ind := p1_a25;
    ddp_bank_rec.organization_rec.labor_surplus_ind := p1_a26;
    ddp_bank_rec.organization_rec.debarment_ind := p1_a27;
    ddp_bank_rec.organization_rec.minority_owned_ind := p1_a28;
    ddp_bank_rec.organization_rec.minority_owned_type := p1_a29;
    ddp_bank_rec.organization_rec.woman_owned_ind := p1_a30;
    ddp_bank_rec.organization_rec.disadv_8a_ind := p1_a31;
    ddp_bank_rec.organization_rec.small_bus_ind := p1_a32;
    ddp_bank_rec.organization_rec.rent_own_ind := p1_a33;
    ddp_bank_rec.organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a34);
    ddp_bank_rec.organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a35);
    ddp_bank_rec.organization_rec.failure_score := p1_a36;
    ddp_bank_rec.organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a37);
    ddp_bank_rec.organization_rec.failure_score_override_code := p1_a38;
    ddp_bank_rec.organization_rec.failure_score_commentary := p1_a39;
    ddp_bank_rec.organization_rec.global_failure_score := p1_a40;
    ddp_bank_rec.organization_rec.db_rating := p1_a41;
    ddp_bank_rec.organization_rec.credit_score := p1_a42;
    ddp_bank_rec.organization_rec.credit_score_commentary := p1_a43;
    ddp_bank_rec.organization_rec.paydex_score := p1_a44;
    ddp_bank_rec.organization_rec.paydex_three_months_ago := p1_a45;
    ddp_bank_rec.organization_rec.paydex_norm := p1_a46;
    ddp_bank_rec.organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a47);
    ddp_bank_rec.organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a48);
    ddp_bank_rec.organization_rec.organization_name_phonetic := p1_a49;
    ddp_bank_rec.organization_rec.tax_reference := p1_a50;
    ddp_bank_rec.organization_rec.gsa_indicator_flag := p1_a51;
    ddp_bank_rec.organization_rec.jgzz_fiscal_code := p1_a52;
    ddp_bank_rec.organization_rec.analysis_fy := p1_a53;
    ddp_bank_rec.organization_rec.fiscal_yearend_month := p1_a54;
    ddp_bank_rec.organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a55);
    ddp_bank_rec.organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a56);
    ddp_bank_rec.organization_rec.year_established := rosetta_g_miss_num_map(p1_a57);
    ddp_bank_rec.organization_rec.mission_statement := p1_a58;
    ddp_bank_rec.organization_rec.organization_type := p1_a59;
    ddp_bank_rec.organization_rec.business_scope := p1_a60;
    ddp_bank_rec.organization_rec.corporation_class := p1_a61;
    ddp_bank_rec.organization_rec.known_as := p1_a62;
    ddp_bank_rec.organization_rec.known_as2 := p1_a63;
    ddp_bank_rec.organization_rec.known_as3 := p1_a64;
    ddp_bank_rec.organization_rec.known_as4 := p1_a65;
    ddp_bank_rec.organization_rec.known_as5 := p1_a66;
    ddp_bank_rec.organization_rec.local_bus_iden_type := p1_a67;
    ddp_bank_rec.organization_rec.local_bus_identifier := p1_a68;
    ddp_bank_rec.organization_rec.pref_functional_currency := p1_a69;
    ddp_bank_rec.organization_rec.registration_type := p1_a70;
    ddp_bank_rec.organization_rec.total_employees_text := p1_a71;
    ddp_bank_rec.organization_rec.total_employees_ind := p1_a72;
    ddp_bank_rec.organization_rec.total_emp_est_ind := p1_a73;
    ddp_bank_rec.organization_rec.total_emp_min_ind := p1_a74;
    ddp_bank_rec.organization_rec.parent_sub_ind := p1_a75;
    ddp_bank_rec.organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a76);
    ddp_bank_rec.organization_rec.sic_code_type := p1_a77;
    ddp_bank_rec.organization_rec.public_private_ownership_flag := p1_a78;
    ddp_bank_rec.organization_rec.internal_flag := p1_a79;
    ddp_bank_rec.organization_rec.local_activity_code_type := p1_a80;
    ddp_bank_rec.organization_rec.local_activity_code := p1_a81;
    ddp_bank_rec.organization_rec.emp_at_primary_adr := p1_a82;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_text := p1_a83;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_est_ind := p1_a84;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_min_ind := p1_a85;
    ddp_bank_rec.organization_rec.high_credit := rosetta_g_miss_num_map(p1_a86);
    ddp_bank_rec.organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a87);
    ddp_bank_rec.organization_rec.total_payments := rosetta_g_miss_num_map(p1_a88);
    ddp_bank_rec.organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a89);
    ddp_bank_rec.organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a90);
    ddp_bank_rec.organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a91);
    ddp_bank_rec.organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a92);
    ddp_bank_rec.organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_bank_rec.organization_rec.credit_score_commentary2 := p1_a94;
    ddp_bank_rec.organization_rec.credit_score_commentary3 := p1_a95;
    ddp_bank_rec.organization_rec.credit_score_commentary4 := p1_a96;
    ddp_bank_rec.organization_rec.credit_score_commentary5 := p1_a97;
    ddp_bank_rec.organization_rec.credit_score_commentary6 := p1_a98;
    ddp_bank_rec.organization_rec.credit_score_commentary7 := p1_a99;
    ddp_bank_rec.organization_rec.credit_score_commentary8 := p1_a100;
    ddp_bank_rec.organization_rec.credit_score_commentary9 := p1_a101;
    ddp_bank_rec.organization_rec.credit_score_commentary10 := p1_a102;
    ddp_bank_rec.organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a103);
    ddp_bank_rec.organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a104);
    ddp_bank_rec.organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a105);
    ddp_bank_rec.organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_bank_rec.organization_rec.failure_score_commentary2 := p1_a107;
    ddp_bank_rec.organization_rec.failure_score_commentary3 := p1_a108;
    ddp_bank_rec.organization_rec.failure_score_commentary4 := p1_a109;
    ddp_bank_rec.organization_rec.failure_score_commentary5 := p1_a110;
    ddp_bank_rec.organization_rec.failure_score_commentary6 := p1_a111;
    ddp_bank_rec.organization_rec.failure_score_commentary7 := p1_a112;
    ddp_bank_rec.organization_rec.failure_score_commentary8 := p1_a113;
    ddp_bank_rec.organization_rec.failure_score_commentary9 := p1_a114;
    ddp_bank_rec.organization_rec.failure_score_commentary10 := p1_a115;
    ddp_bank_rec.organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a116);
    ddp_bank_rec.organization_rec.maximum_credit_currency_code := p1_a117;
    ddp_bank_rec.organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a118);
    ddp_bank_rec.organization_rec.content_source_type := p1_a119;
    ddp_bank_rec.organization_rec.content_source_number := p1_a120;
    ddp_bank_rec.organization_rec.attribute_category := p1_a121;
    ddp_bank_rec.organization_rec.attribute1 := p1_a122;
    ddp_bank_rec.organization_rec.attribute2 := p1_a123;
    ddp_bank_rec.organization_rec.attribute3 := p1_a124;
    ddp_bank_rec.organization_rec.attribute4 := p1_a125;
    ddp_bank_rec.organization_rec.attribute5 := p1_a126;
    ddp_bank_rec.organization_rec.attribute6 := p1_a127;
    ddp_bank_rec.organization_rec.attribute7 := p1_a128;
    ddp_bank_rec.organization_rec.attribute8 := p1_a129;
    ddp_bank_rec.organization_rec.attribute9 := p1_a130;
    ddp_bank_rec.organization_rec.attribute10 := p1_a131;
    ddp_bank_rec.organization_rec.attribute11 := p1_a132;
    ddp_bank_rec.organization_rec.attribute12 := p1_a133;
    ddp_bank_rec.organization_rec.attribute13 := p1_a134;
    ddp_bank_rec.organization_rec.attribute14 := p1_a135;
    ddp_bank_rec.organization_rec.attribute15 := p1_a136;
    ddp_bank_rec.organization_rec.attribute16 := p1_a137;
    ddp_bank_rec.organization_rec.attribute17 := p1_a138;
    ddp_bank_rec.organization_rec.attribute18 := p1_a139;
    ddp_bank_rec.organization_rec.attribute19 := p1_a140;
    ddp_bank_rec.organization_rec.attribute20 := p1_a141;
    ddp_bank_rec.organization_rec.created_by_module := p1_a142;
    ddp_bank_rec.organization_rec.application_id := rosetta_g_miss_num_map(p1_a143);
    ddp_bank_rec.organization_rec.do_not_confuse_with := p1_a144;
    ddp_bank_rec.organization_rec.actual_content_source := p1_a145;
    ddp_bank_rec.organization_rec.home_country := p1_a146;
    ddp_bank_rec.organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a147);
    ddp_bank_rec.organization_rec.party_rec.party_number := p1_a148;
    ddp_bank_rec.organization_rec.party_rec.validated_flag := p1_a149;
    ddp_bank_rec.organization_rec.party_rec.orig_system_reference := p1_a150;
    ddp_bank_rec.organization_rec.party_rec.orig_system := p1_a151;
    ddp_bank_rec.organization_rec.party_rec.status := p1_a152;
    ddp_bank_rec.organization_rec.party_rec.category_code := p1_a153;
    ddp_bank_rec.organization_rec.party_rec.salutation := p1_a154;
    ddp_bank_rec.organization_rec.party_rec.attribute_category := p1_a155;
    ddp_bank_rec.organization_rec.party_rec.attribute1 := p1_a156;
    ddp_bank_rec.organization_rec.party_rec.attribute2 := p1_a157;
    ddp_bank_rec.organization_rec.party_rec.attribute3 := p1_a158;
    ddp_bank_rec.organization_rec.party_rec.attribute4 := p1_a159;
    ddp_bank_rec.organization_rec.party_rec.attribute5 := p1_a160;
    ddp_bank_rec.organization_rec.party_rec.attribute6 := p1_a161;
    ddp_bank_rec.organization_rec.party_rec.attribute7 := p1_a162;
    ddp_bank_rec.organization_rec.party_rec.attribute8 := p1_a163;
    ddp_bank_rec.organization_rec.party_rec.attribute9 := p1_a164;
    ddp_bank_rec.organization_rec.party_rec.attribute10 := p1_a165;
    ddp_bank_rec.organization_rec.party_rec.attribute11 := p1_a166;
    ddp_bank_rec.organization_rec.party_rec.attribute12 := p1_a167;
    ddp_bank_rec.organization_rec.party_rec.attribute13 := p1_a168;
    ddp_bank_rec.organization_rec.party_rec.attribute14 := p1_a169;
    ddp_bank_rec.organization_rec.party_rec.attribute15 := p1_a170;
    ddp_bank_rec.organization_rec.party_rec.attribute16 := p1_a171;
    ddp_bank_rec.organization_rec.party_rec.attribute17 := p1_a172;
    ddp_bank_rec.organization_rec.party_rec.attribute18 := p1_a173;
    ddp_bank_rec.organization_rec.party_rec.attribute19 := p1_a174;
    ddp_bank_rec.organization_rec.party_rec.attribute20 := p1_a175;
    ddp_bank_rec.organization_rec.party_rec.attribute21 := p1_a176;
    ddp_bank_rec.organization_rec.party_rec.attribute22 := p1_a177;
    ddp_bank_rec.organization_rec.party_rec.attribute23 := p1_a178;
    ddp_bank_rec.organization_rec.party_rec.attribute24 := p1_a179;












    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_bank_branch(p_init_msg_list,
      ddp_bank_rec,
      p_bank_party_id,
      p_relationship_id,
      p_pobject_version_number,
      p_bbtobject_version_number,
      p_rfcobject_version_number,
      x_profile_id,
      x_rel_party_id,
      x_rel_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any












  end;

  procedure create_banking_group_5(p_init_msg_list  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  NUMBER := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
  )
  as
    ddp_group_rec hz_party_v2pub.group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_group_rec.group_name := p1_a0;
    ddp_group_rec.group_type := p1_a1;
    ddp_group_rec.created_by_module := p1_a2;
    ddp_group_rec.mission_statement := p1_a3;
    ddp_group_rec.application_id := rosetta_g_miss_num_map(p1_a4);
    ddp_group_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a5);
    ddp_group_rec.party_rec.party_number := p1_a6;
    ddp_group_rec.party_rec.validated_flag := p1_a7;
    ddp_group_rec.party_rec.orig_system_reference := p1_a8;
    ddp_group_rec.party_rec.orig_system := p1_a9;
    ddp_group_rec.party_rec.status := p1_a10;
    ddp_group_rec.party_rec.category_code := p1_a11;
    ddp_group_rec.party_rec.salutation := p1_a12;
    ddp_group_rec.party_rec.attribute_category := p1_a13;
    ddp_group_rec.party_rec.attribute1 := p1_a14;
    ddp_group_rec.party_rec.attribute2 := p1_a15;
    ddp_group_rec.party_rec.attribute3 := p1_a16;
    ddp_group_rec.party_rec.attribute4 := p1_a17;
    ddp_group_rec.party_rec.attribute5 := p1_a18;
    ddp_group_rec.party_rec.attribute6 := p1_a19;
    ddp_group_rec.party_rec.attribute7 := p1_a20;
    ddp_group_rec.party_rec.attribute8 := p1_a21;
    ddp_group_rec.party_rec.attribute9 := p1_a22;
    ddp_group_rec.party_rec.attribute10 := p1_a23;
    ddp_group_rec.party_rec.attribute11 := p1_a24;
    ddp_group_rec.party_rec.attribute12 := p1_a25;
    ddp_group_rec.party_rec.attribute13 := p1_a26;
    ddp_group_rec.party_rec.attribute14 := p1_a27;
    ddp_group_rec.party_rec.attribute15 := p1_a28;
    ddp_group_rec.party_rec.attribute16 := p1_a29;
    ddp_group_rec.party_rec.attribute17 := p1_a30;
    ddp_group_rec.party_rec.attribute18 := p1_a31;
    ddp_group_rec.party_rec.attribute19 := p1_a32;
    ddp_group_rec.party_rec.attribute20 := p1_a33;
    ddp_group_rec.party_rec.attribute21 := p1_a34;
    ddp_group_rec.party_rec.attribute22 := p1_a35;
    ddp_group_rec.party_rec.attribute23 := p1_a36;
    ddp_group_rec.party_rec.attribute24 := p1_a37;






    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_banking_group(p_init_msg_list,
      ddp_group_rec,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_banking_group_6(p_init_msg_list  VARCHAR2
    , p_pobject_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  NUMBER := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
  )
  as
    ddp_group_rec hz_party_v2pub.group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_group_rec.group_name := p1_a0;
    ddp_group_rec.group_type := p1_a1;
    ddp_group_rec.created_by_module := p1_a2;
    ddp_group_rec.mission_statement := p1_a3;
    ddp_group_rec.application_id := rosetta_g_miss_num_map(p1_a4);
    ddp_group_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a5);
    ddp_group_rec.party_rec.party_number := p1_a6;
    ddp_group_rec.party_rec.validated_flag := p1_a7;
    ddp_group_rec.party_rec.orig_system_reference := p1_a8;
    ddp_group_rec.party_rec.orig_system := p1_a9;
    ddp_group_rec.party_rec.status := p1_a10;
    ddp_group_rec.party_rec.category_code := p1_a11;
    ddp_group_rec.party_rec.salutation := p1_a12;
    ddp_group_rec.party_rec.attribute_category := p1_a13;
    ddp_group_rec.party_rec.attribute1 := p1_a14;
    ddp_group_rec.party_rec.attribute2 := p1_a15;
    ddp_group_rec.party_rec.attribute3 := p1_a16;
    ddp_group_rec.party_rec.attribute4 := p1_a17;
    ddp_group_rec.party_rec.attribute5 := p1_a18;
    ddp_group_rec.party_rec.attribute6 := p1_a19;
    ddp_group_rec.party_rec.attribute7 := p1_a20;
    ddp_group_rec.party_rec.attribute8 := p1_a21;
    ddp_group_rec.party_rec.attribute9 := p1_a22;
    ddp_group_rec.party_rec.attribute10 := p1_a23;
    ddp_group_rec.party_rec.attribute11 := p1_a24;
    ddp_group_rec.party_rec.attribute12 := p1_a25;
    ddp_group_rec.party_rec.attribute13 := p1_a26;
    ddp_group_rec.party_rec.attribute14 := p1_a27;
    ddp_group_rec.party_rec.attribute15 := p1_a28;
    ddp_group_rec.party_rec.attribute16 := p1_a29;
    ddp_group_rec.party_rec.attribute17 := p1_a30;
    ddp_group_rec.party_rec.attribute18 := p1_a31;
    ddp_group_rec.party_rec.attribute19 := p1_a32;
    ddp_group_rec.party_rec.attribute20 := p1_a33;
    ddp_group_rec.party_rec.attribute21 := p1_a34;
    ddp_group_rec.party_rec.attribute22 := p1_a35;
    ddp_group_rec.party_rec.attribute23 := p1_a36;
    ddp_group_rec.party_rec.attribute24 := p1_a37;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_banking_group(p_init_msg_list,
      ddp_group_rec,
      p_pobject_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_bank_group_member_7(p_init_msg_list  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  DATE := null
    , p1_a11  DATE := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  NUMBER := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
    , p1_a101  VARCHAR2 := null
  )
  as
    ddp_relationship_rec hz_relationship_v2pub.relationship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_relationship_rec.relationship_id := rosetta_g_miss_num_map(p1_a0);
    ddp_relationship_rec.subject_id := rosetta_g_miss_num_map(p1_a1);
    ddp_relationship_rec.subject_type := p1_a2;
    ddp_relationship_rec.subject_table_name := p1_a3;
    ddp_relationship_rec.object_id := rosetta_g_miss_num_map(p1_a4);
    ddp_relationship_rec.object_type := p1_a5;
    ddp_relationship_rec.object_table_name := p1_a6;
    ddp_relationship_rec.relationship_code := p1_a7;
    ddp_relationship_rec.relationship_type := p1_a8;
    ddp_relationship_rec.comments := p1_a9;
    ddp_relationship_rec.start_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_relationship_rec.end_date := rosetta_g_miss_date_in_map(p1_a11);
    ddp_relationship_rec.status := p1_a12;
    ddp_relationship_rec.content_source_type := p1_a13;
    ddp_relationship_rec.attribute_category := p1_a14;
    ddp_relationship_rec.attribute1 := p1_a15;
    ddp_relationship_rec.attribute2 := p1_a16;
    ddp_relationship_rec.attribute3 := p1_a17;
    ddp_relationship_rec.attribute4 := p1_a18;
    ddp_relationship_rec.attribute5 := p1_a19;
    ddp_relationship_rec.attribute6 := p1_a20;
    ddp_relationship_rec.attribute7 := p1_a21;
    ddp_relationship_rec.attribute8 := p1_a22;
    ddp_relationship_rec.attribute9 := p1_a23;
    ddp_relationship_rec.attribute10 := p1_a24;
    ddp_relationship_rec.attribute11 := p1_a25;
    ddp_relationship_rec.attribute12 := p1_a26;
    ddp_relationship_rec.attribute13 := p1_a27;
    ddp_relationship_rec.attribute14 := p1_a28;
    ddp_relationship_rec.attribute15 := p1_a29;
    ddp_relationship_rec.attribute16 := p1_a30;
    ddp_relationship_rec.attribute17 := p1_a31;
    ddp_relationship_rec.attribute18 := p1_a32;
    ddp_relationship_rec.attribute19 := p1_a33;
    ddp_relationship_rec.attribute20 := p1_a34;
    ddp_relationship_rec.created_by_module := p1_a35;
    ddp_relationship_rec.application_id := rosetta_g_miss_num_map(p1_a36);
    ddp_relationship_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a37);
    ddp_relationship_rec.party_rec.party_number := p1_a38;
    ddp_relationship_rec.party_rec.validated_flag := p1_a39;
    ddp_relationship_rec.party_rec.orig_system_reference := p1_a40;
    ddp_relationship_rec.party_rec.orig_system := p1_a41;
    ddp_relationship_rec.party_rec.status := p1_a42;
    ddp_relationship_rec.party_rec.category_code := p1_a43;
    ddp_relationship_rec.party_rec.salutation := p1_a44;
    ddp_relationship_rec.party_rec.attribute_category := p1_a45;
    ddp_relationship_rec.party_rec.attribute1 := p1_a46;
    ddp_relationship_rec.party_rec.attribute2 := p1_a47;
    ddp_relationship_rec.party_rec.attribute3 := p1_a48;
    ddp_relationship_rec.party_rec.attribute4 := p1_a49;
    ddp_relationship_rec.party_rec.attribute5 := p1_a50;
    ddp_relationship_rec.party_rec.attribute6 := p1_a51;
    ddp_relationship_rec.party_rec.attribute7 := p1_a52;
    ddp_relationship_rec.party_rec.attribute8 := p1_a53;
    ddp_relationship_rec.party_rec.attribute9 := p1_a54;
    ddp_relationship_rec.party_rec.attribute10 := p1_a55;
    ddp_relationship_rec.party_rec.attribute11 := p1_a56;
    ddp_relationship_rec.party_rec.attribute12 := p1_a57;
    ddp_relationship_rec.party_rec.attribute13 := p1_a58;
    ddp_relationship_rec.party_rec.attribute14 := p1_a59;
    ddp_relationship_rec.party_rec.attribute15 := p1_a60;
    ddp_relationship_rec.party_rec.attribute16 := p1_a61;
    ddp_relationship_rec.party_rec.attribute17 := p1_a62;
    ddp_relationship_rec.party_rec.attribute18 := p1_a63;
    ddp_relationship_rec.party_rec.attribute19 := p1_a64;
    ddp_relationship_rec.party_rec.attribute20 := p1_a65;
    ddp_relationship_rec.party_rec.attribute21 := p1_a66;
    ddp_relationship_rec.party_rec.attribute22 := p1_a67;
    ddp_relationship_rec.party_rec.attribute23 := p1_a68;
    ddp_relationship_rec.party_rec.attribute24 := p1_a69;
    ddp_relationship_rec.additional_information1 := p1_a70;
    ddp_relationship_rec.additional_information2 := p1_a71;
    ddp_relationship_rec.additional_information3 := p1_a72;
    ddp_relationship_rec.additional_information4 := p1_a73;
    ddp_relationship_rec.additional_information5 := p1_a74;
    ddp_relationship_rec.additional_information6 := p1_a75;
    ddp_relationship_rec.additional_information7 := p1_a76;
    ddp_relationship_rec.additional_information8 := p1_a77;
    ddp_relationship_rec.additional_information9 := p1_a78;
    ddp_relationship_rec.additional_information10 := p1_a79;
    ddp_relationship_rec.additional_information11 := p1_a80;
    ddp_relationship_rec.additional_information12 := p1_a81;
    ddp_relationship_rec.additional_information13 := p1_a82;
    ddp_relationship_rec.additional_information14 := p1_a83;
    ddp_relationship_rec.additional_information15 := p1_a84;
    ddp_relationship_rec.additional_information16 := p1_a85;
    ddp_relationship_rec.additional_information17 := p1_a86;
    ddp_relationship_rec.additional_information18 := p1_a87;
    ddp_relationship_rec.additional_information19 := p1_a88;
    ddp_relationship_rec.additional_information20 := p1_a89;
    ddp_relationship_rec.additional_information21 := p1_a90;
    ddp_relationship_rec.additional_information22 := p1_a91;
    ddp_relationship_rec.additional_information23 := p1_a92;
    ddp_relationship_rec.additional_information24 := p1_a93;
    ddp_relationship_rec.additional_information25 := p1_a94;
    ddp_relationship_rec.additional_information26 := p1_a95;
    ddp_relationship_rec.additional_information27 := p1_a96;
    ddp_relationship_rec.additional_information28 := p1_a97;
    ddp_relationship_rec.additional_information29 := p1_a98;
    ddp_relationship_rec.additional_information30 := p1_a99;
    ddp_relationship_rec.percentage_ownership := rosetta_g_miss_num_map(p1_a100);
    ddp_relationship_rec.actual_content_source := p1_a101;







    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_bank_group_member(p_init_msg_list,
      ddp_relationship_rec,
      x_relationship_id,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure update_bank_group_member_8(p_init_msg_list  VARCHAR2
    , p_robject_version_number in out nocopy  NUMBER
    , p_pobject_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  DATE := null
    , p1_a11  DATE := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  NUMBER := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
    , p1_a101  VARCHAR2 := null
  )
  as
    ddp_relationship_rec hz_relationship_v2pub.relationship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_relationship_rec.relationship_id := rosetta_g_miss_num_map(p1_a0);
    ddp_relationship_rec.subject_id := rosetta_g_miss_num_map(p1_a1);
    ddp_relationship_rec.subject_type := p1_a2;
    ddp_relationship_rec.subject_table_name := p1_a3;
    ddp_relationship_rec.object_id := rosetta_g_miss_num_map(p1_a4);
    ddp_relationship_rec.object_type := p1_a5;
    ddp_relationship_rec.object_table_name := p1_a6;
    ddp_relationship_rec.relationship_code := p1_a7;
    ddp_relationship_rec.relationship_type := p1_a8;
    ddp_relationship_rec.comments := p1_a9;
    ddp_relationship_rec.start_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_relationship_rec.end_date := rosetta_g_miss_date_in_map(p1_a11);
    ddp_relationship_rec.status := p1_a12;
    ddp_relationship_rec.content_source_type := p1_a13;
    ddp_relationship_rec.attribute_category := p1_a14;
    ddp_relationship_rec.attribute1 := p1_a15;
    ddp_relationship_rec.attribute2 := p1_a16;
    ddp_relationship_rec.attribute3 := p1_a17;
    ddp_relationship_rec.attribute4 := p1_a18;
    ddp_relationship_rec.attribute5 := p1_a19;
    ddp_relationship_rec.attribute6 := p1_a20;
    ddp_relationship_rec.attribute7 := p1_a21;
    ddp_relationship_rec.attribute8 := p1_a22;
    ddp_relationship_rec.attribute9 := p1_a23;
    ddp_relationship_rec.attribute10 := p1_a24;
    ddp_relationship_rec.attribute11 := p1_a25;
    ddp_relationship_rec.attribute12 := p1_a26;
    ddp_relationship_rec.attribute13 := p1_a27;
    ddp_relationship_rec.attribute14 := p1_a28;
    ddp_relationship_rec.attribute15 := p1_a29;
    ddp_relationship_rec.attribute16 := p1_a30;
    ddp_relationship_rec.attribute17 := p1_a31;
    ddp_relationship_rec.attribute18 := p1_a32;
    ddp_relationship_rec.attribute19 := p1_a33;
    ddp_relationship_rec.attribute20 := p1_a34;
    ddp_relationship_rec.created_by_module := p1_a35;
    ddp_relationship_rec.application_id := rosetta_g_miss_num_map(p1_a36);
    ddp_relationship_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a37);
    ddp_relationship_rec.party_rec.party_number := p1_a38;
    ddp_relationship_rec.party_rec.validated_flag := p1_a39;
    ddp_relationship_rec.party_rec.orig_system_reference := p1_a40;
    ddp_relationship_rec.party_rec.orig_system := p1_a41;
    ddp_relationship_rec.party_rec.status := p1_a42;
    ddp_relationship_rec.party_rec.category_code := p1_a43;
    ddp_relationship_rec.party_rec.salutation := p1_a44;
    ddp_relationship_rec.party_rec.attribute_category := p1_a45;
    ddp_relationship_rec.party_rec.attribute1 := p1_a46;
    ddp_relationship_rec.party_rec.attribute2 := p1_a47;
    ddp_relationship_rec.party_rec.attribute3 := p1_a48;
    ddp_relationship_rec.party_rec.attribute4 := p1_a49;
    ddp_relationship_rec.party_rec.attribute5 := p1_a50;
    ddp_relationship_rec.party_rec.attribute6 := p1_a51;
    ddp_relationship_rec.party_rec.attribute7 := p1_a52;
    ddp_relationship_rec.party_rec.attribute8 := p1_a53;
    ddp_relationship_rec.party_rec.attribute9 := p1_a54;
    ddp_relationship_rec.party_rec.attribute10 := p1_a55;
    ddp_relationship_rec.party_rec.attribute11 := p1_a56;
    ddp_relationship_rec.party_rec.attribute12 := p1_a57;
    ddp_relationship_rec.party_rec.attribute13 := p1_a58;
    ddp_relationship_rec.party_rec.attribute14 := p1_a59;
    ddp_relationship_rec.party_rec.attribute15 := p1_a60;
    ddp_relationship_rec.party_rec.attribute16 := p1_a61;
    ddp_relationship_rec.party_rec.attribute17 := p1_a62;
    ddp_relationship_rec.party_rec.attribute18 := p1_a63;
    ddp_relationship_rec.party_rec.attribute19 := p1_a64;
    ddp_relationship_rec.party_rec.attribute20 := p1_a65;
    ddp_relationship_rec.party_rec.attribute21 := p1_a66;
    ddp_relationship_rec.party_rec.attribute22 := p1_a67;
    ddp_relationship_rec.party_rec.attribute23 := p1_a68;
    ddp_relationship_rec.party_rec.attribute24 := p1_a69;
    ddp_relationship_rec.additional_information1 := p1_a70;
    ddp_relationship_rec.additional_information2 := p1_a71;
    ddp_relationship_rec.additional_information3 := p1_a72;
    ddp_relationship_rec.additional_information4 := p1_a73;
    ddp_relationship_rec.additional_information5 := p1_a74;
    ddp_relationship_rec.additional_information6 := p1_a75;
    ddp_relationship_rec.additional_information7 := p1_a76;
    ddp_relationship_rec.additional_information8 := p1_a77;
    ddp_relationship_rec.additional_information9 := p1_a78;
    ddp_relationship_rec.additional_information10 := p1_a79;
    ddp_relationship_rec.additional_information11 := p1_a80;
    ddp_relationship_rec.additional_information12 := p1_a81;
    ddp_relationship_rec.additional_information13 := p1_a82;
    ddp_relationship_rec.additional_information14 := p1_a83;
    ddp_relationship_rec.additional_information15 := p1_a84;
    ddp_relationship_rec.additional_information16 := p1_a85;
    ddp_relationship_rec.additional_information17 := p1_a86;
    ddp_relationship_rec.additional_information18 := p1_a87;
    ddp_relationship_rec.additional_information19 := p1_a88;
    ddp_relationship_rec.additional_information20 := p1_a89;
    ddp_relationship_rec.additional_information21 := p1_a90;
    ddp_relationship_rec.additional_information22 := p1_a91;
    ddp_relationship_rec.additional_information23 := p1_a92;
    ddp_relationship_rec.additional_information24 := p1_a93;
    ddp_relationship_rec.additional_information25 := p1_a94;
    ddp_relationship_rec.additional_information26 := p1_a95;
    ddp_relationship_rec.additional_information27 := p1_a96;
    ddp_relationship_rec.additional_information28 := p1_a97;
    ddp_relationship_rec.additional_information29 := p1_a98;
    ddp_relationship_rec.additional_information30 := p1_a99;
    ddp_relationship_rec.percentage_ownership := rosetta_g_miss_num_map(p1_a100);
    ddp_relationship_rec.actual_content_source := p1_a101;






    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_bank_group_member(p_init_msg_list,
      ddp_relationship_rec,
      p_robject_version_number,
      p_pobject_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_clearinghouse_assign_9(p_init_msg_list  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  DATE := null
    , p1_a11  DATE := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  NUMBER := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
    , p1_a101  VARCHAR2 := null
  )
  as
    ddp_relationship_rec hz_relationship_v2pub.relationship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_relationship_rec.relationship_id := rosetta_g_miss_num_map(p1_a0);
    ddp_relationship_rec.subject_id := rosetta_g_miss_num_map(p1_a1);
    ddp_relationship_rec.subject_type := p1_a2;
    ddp_relationship_rec.subject_table_name := p1_a3;
    ddp_relationship_rec.object_id := rosetta_g_miss_num_map(p1_a4);
    ddp_relationship_rec.object_type := p1_a5;
    ddp_relationship_rec.object_table_name := p1_a6;
    ddp_relationship_rec.relationship_code := p1_a7;
    ddp_relationship_rec.relationship_type := p1_a8;
    ddp_relationship_rec.comments := p1_a9;
    ddp_relationship_rec.start_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_relationship_rec.end_date := rosetta_g_miss_date_in_map(p1_a11);
    ddp_relationship_rec.status := p1_a12;
    ddp_relationship_rec.content_source_type := p1_a13;
    ddp_relationship_rec.attribute_category := p1_a14;
    ddp_relationship_rec.attribute1 := p1_a15;
    ddp_relationship_rec.attribute2 := p1_a16;
    ddp_relationship_rec.attribute3 := p1_a17;
    ddp_relationship_rec.attribute4 := p1_a18;
    ddp_relationship_rec.attribute5 := p1_a19;
    ddp_relationship_rec.attribute6 := p1_a20;
    ddp_relationship_rec.attribute7 := p1_a21;
    ddp_relationship_rec.attribute8 := p1_a22;
    ddp_relationship_rec.attribute9 := p1_a23;
    ddp_relationship_rec.attribute10 := p1_a24;
    ddp_relationship_rec.attribute11 := p1_a25;
    ddp_relationship_rec.attribute12 := p1_a26;
    ddp_relationship_rec.attribute13 := p1_a27;
    ddp_relationship_rec.attribute14 := p1_a28;
    ddp_relationship_rec.attribute15 := p1_a29;
    ddp_relationship_rec.attribute16 := p1_a30;
    ddp_relationship_rec.attribute17 := p1_a31;
    ddp_relationship_rec.attribute18 := p1_a32;
    ddp_relationship_rec.attribute19 := p1_a33;
    ddp_relationship_rec.attribute20 := p1_a34;
    ddp_relationship_rec.created_by_module := p1_a35;
    ddp_relationship_rec.application_id := rosetta_g_miss_num_map(p1_a36);
    ddp_relationship_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a37);
    ddp_relationship_rec.party_rec.party_number := p1_a38;
    ddp_relationship_rec.party_rec.validated_flag := p1_a39;
    ddp_relationship_rec.party_rec.orig_system_reference := p1_a40;
    ddp_relationship_rec.party_rec.orig_system := p1_a41;
    ddp_relationship_rec.party_rec.status := p1_a42;
    ddp_relationship_rec.party_rec.category_code := p1_a43;
    ddp_relationship_rec.party_rec.salutation := p1_a44;
    ddp_relationship_rec.party_rec.attribute_category := p1_a45;
    ddp_relationship_rec.party_rec.attribute1 := p1_a46;
    ddp_relationship_rec.party_rec.attribute2 := p1_a47;
    ddp_relationship_rec.party_rec.attribute3 := p1_a48;
    ddp_relationship_rec.party_rec.attribute4 := p1_a49;
    ddp_relationship_rec.party_rec.attribute5 := p1_a50;
    ddp_relationship_rec.party_rec.attribute6 := p1_a51;
    ddp_relationship_rec.party_rec.attribute7 := p1_a52;
    ddp_relationship_rec.party_rec.attribute8 := p1_a53;
    ddp_relationship_rec.party_rec.attribute9 := p1_a54;
    ddp_relationship_rec.party_rec.attribute10 := p1_a55;
    ddp_relationship_rec.party_rec.attribute11 := p1_a56;
    ddp_relationship_rec.party_rec.attribute12 := p1_a57;
    ddp_relationship_rec.party_rec.attribute13 := p1_a58;
    ddp_relationship_rec.party_rec.attribute14 := p1_a59;
    ddp_relationship_rec.party_rec.attribute15 := p1_a60;
    ddp_relationship_rec.party_rec.attribute16 := p1_a61;
    ddp_relationship_rec.party_rec.attribute17 := p1_a62;
    ddp_relationship_rec.party_rec.attribute18 := p1_a63;
    ddp_relationship_rec.party_rec.attribute19 := p1_a64;
    ddp_relationship_rec.party_rec.attribute20 := p1_a65;
    ddp_relationship_rec.party_rec.attribute21 := p1_a66;
    ddp_relationship_rec.party_rec.attribute22 := p1_a67;
    ddp_relationship_rec.party_rec.attribute23 := p1_a68;
    ddp_relationship_rec.party_rec.attribute24 := p1_a69;
    ddp_relationship_rec.additional_information1 := p1_a70;
    ddp_relationship_rec.additional_information2 := p1_a71;
    ddp_relationship_rec.additional_information3 := p1_a72;
    ddp_relationship_rec.additional_information4 := p1_a73;
    ddp_relationship_rec.additional_information5 := p1_a74;
    ddp_relationship_rec.additional_information6 := p1_a75;
    ddp_relationship_rec.additional_information7 := p1_a76;
    ddp_relationship_rec.additional_information8 := p1_a77;
    ddp_relationship_rec.additional_information9 := p1_a78;
    ddp_relationship_rec.additional_information10 := p1_a79;
    ddp_relationship_rec.additional_information11 := p1_a80;
    ddp_relationship_rec.additional_information12 := p1_a81;
    ddp_relationship_rec.additional_information13 := p1_a82;
    ddp_relationship_rec.additional_information14 := p1_a83;
    ddp_relationship_rec.additional_information15 := p1_a84;
    ddp_relationship_rec.additional_information16 := p1_a85;
    ddp_relationship_rec.additional_information17 := p1_a86;
    ddp_relationship_rec.additional_information18 := p1_a87;
    ddp_relationship_rec.additional_information19 := p1_a88;
    ddp_relationship_rec.additional_information20 := p1_a89;
    ddp_relationship_rec.additional_information21 := p1_a90;
    ddp_relationship_rec.additional_information22 := p1_a91;
    ddp_relationship_rec.additional_information23 := p1_a92;
    ddp_relationship_rec.additional_information24 := p1_a93;
    ddp_relationship_rec.additional_information25 := p1_a94;
    ddp_relationship_rec.additional_information26 := p1_a95;
    ddp_relationship_rec.additional_information27 := p1_a96;
    ddp_relationship_rec.additional_information28 := p1_a97;
    ddp_relationship_rec.additional_information29 := p1_a98;
    ddp_relationship_rec.additional_information30 := p1_a99;
    ddp_relationship_rec.percentage_ownership := rosetta_g_miss_num_map(p1_a100);
    ddp_relationship_rec.actual_content_source := p1_a101;







    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_clearinghouse_assign(p_init_msg_list,
      ddp_relationship_rec,
      x_relationship_id,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure update_clearinghouse_assign_10(p_init_msg_list  VARCHAR2
    , p_robject_version_number in out nocopy  NUMBER
    , p_pobject_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  DATE := null
    , p1_a11  DATE := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  NUMBER := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
    , p1_a101  VARCHAR2 := null
  )
  as
    ddp_relationship_rec hz_relationship_v2pub.relationship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_relationship_rec.relationship_id := rosetta_g_miss_num_map(p1_a0);
    ddp_relationship_rec.subject_id := rosetta_g_miss_num_map(p1_a1);
    ddp_relationship_rec.subject_type := p1_a2;
    ddp_relationship_rec.subject_table_name := p1_a3;
    ddp_relationship_rec.object_id := rosetta_g_miss_num_map(p1_a4);
    ddp_relationship_rec.object_type := p1_a5;
    ddp_relationship_rec.object_table_name := p1_a6;
    ddp_relationship_rec.relationship_code := p1_a7;
    ddp_relationship_rec.relationship_type := p1_a8;
    ddp_relationship_rec.comments := p1_a9;
    ddp_relationship_rec.start_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_relationship_rec.end_date := rosetta_g_miss_date_in_map(p1_a11);
    ddp_relationship_rec.status := p1_a12;
    ddp_relationship_rec.content_source_type := p1_a13;
    ddp_relationship_rec.attribute_category := p1_a14;
    ddp_relationship_rec.attribute1 := p1_a15;
    ddp_relationship_rec.attribute2 := p1_a16;
    ddp_relationship_rec.attribute3 := p1_a17;
    ddp_relationship_rec.attribute4 := p1_a18;
    ddp_relationship_rec.attribute5 := p1_a19;
    ddp_relationship_rec.attribute6 := p1_a20;
    ddp_relationship_rec.attribute7 := p1_a21;
    ddp_relationship_rec.attribute8 := p1_a22;
    ddp_relationship_rec.attribute9 := p1_a23;
    ddp_relationship_rec.attribute10 := p1_a24;
    ddp_relationship_rec.attribute11 := p1_a25;
    ddp_relationship_rec.attribute12 := p1_a26;
    ddp_relationship_rec.attribute13 := p1_a27;
    ddp_relationship_rec.attribute14 := p1_a28;
    ddp_relationship_rec.attribute15 := p1_a29;
    ddp_relationship_rec.attribute16 := p1_a30;
    ddp_relationship_rec.attribute17 := p1_a31;
    ddp_relationship_rec.attribute18 := p1_a32;
    ddp_relationship_rec.attribute19 := p1_a33;
    ddp_relationship_rec.attribute20 := p1_a34;
    ddp_relationship_rec.created_by_module := p1_a35;
    ddp_relationship_rec.application_id := rosetta_g_miss_num_map(p1_a36);
    ddp_relationship_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a37);
    ddp_relationship_rec.party_rec.party_number := p1_a38;
    ddp_relationship_rec.party_rec.validated_flag := p1_a39;
    ddp_relationship_rec.party_rec.orig_system_reference := p1_a40;
    ddp_relationship_rec.party_rec.orig_system := p1_a41;
    ddp_relationship_rec.party_rec.status := p1_a42;
    ddp_relationship_rec.party_rec.category_code := p1_a43;
    ddp_relationship_rec.party_rec.salutation := p1_a44;
    ddp_relationship_rec.party_rec.attribute_category := p1_a45;
    ddp_relationship_rec.party_rec.attribute1 := p1_a46;
    ddp_relationship_rec.party_rec.attribute2 := p1_a47;
    ddp_relationship_rec.party_rec.attribute3 := p1_a48;
    ddp_relationship_rec.party_rec.attribute4 := p1_a49;
    ddp_relationship_rec.party_rec.attribute5 := p1_a50;
    ddp_relationship_rec.party_rec.attribute6 := p1_a51;
    ddp_relationship_rec.party_rec.attribute7 := p1_a52;
    ddp_relationship_rec.party_rec.attribute8 := p1_a53;
    ddp_relationship_rec.party_rec.attribute9 := p1_a54;
    ddp_relationship_rec.party_rec.attribute10 := p1_a55;
    ddp_relationship_rec.party_rec.attribute11 := p1_a56;
    ddp_relationship_rec.party_rec.attribute12 := p1_a57;
    ddp_relationship_rec.party_rec.attribute13 := p1_a58;
    ddp_relationship_rec.party_rec.attribute14 := p1_a59;
    ddp_relationship_rec.party_rec.attribute15 := p1_a60;
    ddp_relationship_rec.party_rec.attribute16 := p1_a61;
    ddp_relationship_rec.party_rec.attribute17 := p1_a62;
    ddp_relationship_rec.party_rec.attribute18 := p1_a63;
    ddp_relationship_rec.party_rec.attribute19 := p1_a64;
    ddp_relationship_rec.party_rec.attribute20 := p1_a65;
    ddp_relationship_rec.party_rec.attribute21 := p1_a66;
    ddp_relationship_rec.party_rec.attribute22 := p1_a67;
    ddp_relationship_rec.party_rec.attribute23 := p1_a68;
    ddp_relationship_rec.party_rec.attribute24 := p1_a69;
    ddp_relationship_rec.additional_information1 := p1_a70;
    ddp_relationship_rec.additional_information2 := p1_a71;
    ddp_relationship_rec.additional_information3 := p1_a72;
    ddp_relationship_rec.additional_information4 := p1_a73;
    ddp_relationship_rec.additional_information5 := p1_a74;
    ddp_relationship_rec.additional_information6 := p1_a75;
    ddp_relationship_rec.additional_information7 := p1_a76;
    ddp_relationship_rec.additional_information8 := p1_a77;
    ddp_relationship_rec.additional_information9 := p1_a78;
    ddp_relationship_rec.additional_information10 := p1_a79;
    ddp_relationship_rec.additional_information11 := p1_a80;
    ddp_relationship_rec.additional_information12 := p1_a81;
    ddp_relationship_rec.additional_information13 := p1_a82;
    ddp_relationship_rec.additional_information14 := p1_a83;
    ddp_relationship_rec.additional_information15 := p1_a84;
    ddp_relationship_rec.additional_information16 := p1_a85;
    ddp_relationship_rec.additional_information17 := p1_a86;
    ddp_relationship_rec.additional_information18 := p1_a87;
    ddp_relationship_rec.additional_information19 := p1_a88;
    ddp_relationship_rec.additional_information20 := p1_a89;
    ddp_relationship_rec.additional_information21 := p1_a90;
    ddp_relationship_rec.additional_information22 := p1_a91;
    ddp_relationship_rec.additional_information23 := p1_a92;
    ddp_relationship_rec.additional_information24 := p1_a93;
    ddp_relationship_rec.additional_information25 := p1_a94;
    ddp_relationship_rec.additional_information26 := p1_a95;
    ddp_relationship_rec.additional_information27 := p1_a96;
    ddp_relationship_rec.additional_information28 := p1_a97;
    ddp_relationship_rec.additional_information29 := p1_a98;
    ddp_relationship_rec.additional_information30 := p1_a99;
    ddp_relationship_rec.percentage_ownership := rosetta_g_miss_num_map(p1_a100);
    ddp_relationship_rec.actual_content_source := p1_a101;






    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_clearinghouse_assign(p_init_msg_list,
      ddp_relationship_rec,
      p_robject_version_number,
      p_pobject_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_bank_site_11(p_init_msg_list  VARCHAR2
    , x_party_site_id out nocopy  NUMBER
    , x_party_site_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
  )
  as
    ddp_party_site_rec hz_party_site_v2pub.party_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_party_site_rec.party_site_id := rosetta_g_miss_num_map(p1_a0);
    ddp_party_site_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_party_site_rec.location_id := rosetta_g_miss_num_map(p1_a2);
    ddp_party_site_rec.party_site_number := p1_a3;
    ddp_party_site_rec.orig_system_reference := p1_a4;
    ddp_party_site_rec.orig_system := p1_a5;
    ddp_party_site_rec.mailstop := p1_a6;
    ddp_party_site_rec.identifying_address_flag := p1_a7;
    ddp_party_site_rec.status := p1_a8;
    ddp_party_site_rec.party_site_name := p1_a9;
    ddp_party_site_rec.attribute_category := p1_a10;
    ddp_party_site_rec.attribute1 := p1_a11;
    ddp_party_site_rec.attribute2 := p1_a12;
    ddp_party_site_rec.attribute3 := p1_a13;
    ddp_party_site_rec.attribute4 := p1_a14;
    ddp_party_site_rec.attribute5 := p1_a15;
    ddp_party_site_rec.attribute6 := p1_a16;
    ddp_party_site_rec.attribute7 := p1_a17;
    ddp_party_site_rec.attribute8 := p1_a18;
    ddp_party_site_rec.attribute9 := p1_a19;
    ddp_party_site_rec.attribute10 := p1_a20;
    ddp_party_site_rec.attribute11 := p1_a21;
    ddp_party_site_rec.attribute12 := p1_a22;
    ddp_party_site_rec.attribute13 := p1_a23;
    ddp_party_site_rec.attribute14 := p1_a24;
    ddp_party_site_rec.attribute15 := p1_a25;
    ddp_party_site_rec.attribute16 := p1_a26;
    ddp_party_site_rec.attribute17 := p1_a27;
    ddp_party_site_rec.attribute18 := p1_a28;
    ddp_party_site_rec.attribute19 := p1_a29;
    ddp_party_site_rec.attribute20 := p1_a30;
    ddp_party_site_rec.language := p1_a31;
    ddp_party_site_rec.addressee := p1_a32;
    ddp_party_site_rec.created_by_module := p1_a33;
    ddp_party_site_rec.application_id := rosetta_g_miss_num_map(p1_a34);
    ddp_party_site_rec.global_location_number := p1_a35;
    ddp_party_site_rec.duns_number_c := p1_a36;






    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_bank_site(p_init_msg_list,
      ddp_party_site_rec,
      x_party_site_id,
      x_party_site_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_bank_site_12(p_init_msg_list  VARCHAR2
    , p_psobject_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
  )
  as
    ddp_party_site_rec hz_party_site_v2pub.party_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_party_site_rec.party_site_id := rosetta_g_miss_num_map(p1_a0);
    ddp_party_site_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_party_site_rec.location_id := rosetta_g_miss_num_map(p1_a2);
    ddp_party_site_rec.party_site_number := p1_a3;
    ddp_party_site_rec.orig_system_reference := p1_a4;
    ddp_party_site_rec.orig_system := p1_a5;
    ddp_party_site_rec.mailstop := p1_a6;
    ddp_party_site_rec.identifying_address_flag := p1_a7;
    ddp_party_site_rec.status := p1_a8;
    ddp_party_site_rec.party_site_name := p1_a9;
    ddp_party_site_rec.attribute_category := p1_a10;
    ddp_party_site_rec.attribute1 := p1_a11;
    ddp_party_site_rec.attribute2 := p1_a12;
    ddp_party_site_rec.attribute3 := p1_a13;
    ddp_party_site_rec.attribute4 := p1_a14;
    ddp_party_site_rec.attribute5 := p1_a15;
    ddp_party_site_rec.attribute6 := p1_a16;
    ddp_party_site_rec.attribute7 := p1_a17;
    ddp_party_site_rec.attribute8 := p1_a18;
    ddp_party_site_rec.attribute9 := p1_a19;
    ddp_party_site_rec.attribute10 := p1_a20;
    ddp_party_site_rec.attribute11 := p1_a21;
    ddp_party_site_rec.attribute12 := p1_a22;
    ddp_party_site_rec.attribute13 := p1_a23;
    ddp_party_site_rec.attribute14 := p1_a24;
    ddp_party_site_rec.attribute15 := p1_a25;
    ddp_party_site_rec.attribute16 := p1_a26;
    ddp_party_site_rec.attribute17 := p1_a27;
    ddp_party_site_rec.attribute18 := p1_a28;
    ddp_party_site_rec.attribute19 := p1_a29;
    ddp_party_site_rec.attribute20 := p1_a30;
    ddp_party_site_rec.language := p1_a31;
    ddp_party_site_rec.addressee := p1_a32;
    ddp_party_site_rec.created_by_module := p1_a33;
    ddp_party_site_rec.application_id := rosetta_g_miss_num_map(p1_a34);
    ddp_party_site_rec.global_location_number := p1_a35;
    ddp_party_site_rec.duns_number_c := p1_a36;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_bank_site(p_init_msg_list,
      ddp_party_site_rec,
      p_psobject_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_edi_contact_point_13(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_edi_rec.edi_transaction_handling := p2_a0;
    ddp_edi_rec.edi_id_number := p2_a1;
    ddp_edi_rec.edi_payment_method := p2_a2;
    ddp_edi_rec.edi_payment_format := p2_a3;
    ddp_edi_rec.edi_remittance_method := p2_a4;
    ddp_edi_rec.edi_remittance_instruction := p2_a5;
    ddp_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p2_a6);
    ddp_edi_rec.edi_ece_tp_location_code := p2_a7;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_edi_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_edi_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_edi_contact_point_14(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_edi_rec.edi_transaction_handling := p2_a0;
    ddp_edi_rec.edi_id_number := p2_a1;
    ddp_edi_rec.edi_payment_method := p2_a2;
    ddp_edi_rec.edi_payment_format := p2_a3;
    ddp_edi_rec.edi_remittance_method := p2_a4;
    ddp_edi_rec.edi_remittance_instruction := p2_a5;
    ddp_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p2_a6);
    ddp_edi_rec.edi_ece_tp_location_code := p2_a7;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_edi_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_edi_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_eft_contact_point_15(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  NUMBER := null
    , p2_a1  NUMBER := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_eft_rec hz_contact_point_v2pub.eft_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_eft_rec.eft_transmission_program_id := rosetta_g_miss_num_map(p2_a0);
    ddp_eft_rec.eft_printing_program_id := rosetta_g_miss_num_map(p2_a1);
    ddp_eft_rec.eft_user_number := p2_a2;
    ddp_eft_rec.eft_swift_code := p2_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_eft_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_eft_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_eft_contact_point_16(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  NUMBER := null
    , p2_a1  NUMBER := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_eft_rec hz_contact_point_v2pub.eft_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_eft_rec.eft_transmission_program_id := rosetta_g_miss_num_map(p2_a0);
    ddp_eft_rec.eft_printing_program_id := rosetta_g_miss_num_map(p2_a1);
    ddp_eft_rec.eft_user_number := p2_a2;
    ddp_eft_rec.eft_swift_code := p2_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_eft_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_eft_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_web_contact_point_17(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_web_rec.web_type := p2_a0;
    ddp_web_rec.url := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_web_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_web_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_web_contact_point_18(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_web_rec.web_type := p2_a0;
    ddp_web_rec.url := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_web_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_web_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_phone_contact_point_19(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  DATE := null
    , p2_a2  NUMBER := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_phone_rec.phone_calling_calendar := p2_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_phone_rec.timezone_id := rosetta_g_miss_num_map(p2_a2);
    ddp_phone_rec.phone_area_code := p2_a3;
    ddp_phone_rec.phone_country_code := p2_a4;
    ddp_phone_rec.phone_number := p2_a5;
    ddp_phone_rec.phone_extension := p2_a6;
    ddp_phone_rec.phone_line_type := p2_a7;
    ddp_phone_rec.raw_phone_number := p2_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_phone_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_phone_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_phone_contact_point_20(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  DATE := null
    , p2_a2  NUMBER := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_phone_rec.phone_calling_calendar := p2_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_phone_rec.timezone_id := rosetta_g_miss_num_map(p2_a2);
    ddp_phone_rec.phone_area_code := p2_a3;
    ddp_phone_rec.phone_country_code := p2_a4;
    ddp_phone_rec.phone_number := p2_a5;
    ddp_phone_rec.phone_extension := p2_a6;
    ddp_phone_rec.phone_line_type := p2_a7;
    ddp_phone_rec.raw_phone_number := p2_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_phone_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_phone_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_email_contact_point_21(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_email_rec.email_format := p2_a0;
    ddp_email_rec.email_address := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_email_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_email_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_email_contact_point_22(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_email_rec.email_format := p2_a0;
    ddp_email_rec.email_address := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_email_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_email_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_telex_contact_point_23(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_telex_rec.telex_number := p2_a0;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.create_telex_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_telex_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_telex_contact_point_24(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_telex_rec.telex_number := p2_a0;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.update_telex_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_telex_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure validate_bank_25(p_init_msg_list  VARCHAR2
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  DATE := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  DATE := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  NUMBER := null
    , p1_a56  NUMBER := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  NUMBER := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  NUMBER := null
    , p1_a89  NUMBER := null
    , p1_a90  NUMBER := null
    , p1_a91  NUMBER := null
    , p1_a92  NUMBER := null
    , p1_a93  DATE := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  NUMBER := null
    , p1_a104  NUMBER := null
    , p1_a105  NUMBER := null
    , p1_a106  DATE := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  NUMBER := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  NUMBER := null
    , p1_a119  VARCHAR2 := null
    , p1_a120  VARCHAR2 := null
    , p1_a121  VARCHAR2 := null
    , p1_a122  VARCHAR2 := null
    , p1_a123  VARCHAR2 := null
    , p1_a124  VARCHAR2 := null
    , p1_a125  VARCHAR2 := null
    , p1_a126  VARCHAR2 := null
    , p1_a127  VARCHAR2 := null
    , p1_a128  VARCHAR2 := null
    , p1_a129  VARCHAR2 := null
    , p1_a130  VARCHAR2 := null
    , p1_a131  VARCHAR2 := null
    , p1_a132  VARCHAR2 := null
    , p1_a133  VARCHAR2 := null
    , p1_a134  VARCHAR2 := null
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  NUMBER := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  NUMBER := null
    , p1_a148  VARCHAR2 := null
    , p1_a149  VARCHAR2 := null
    , p1_a150  VARCHAR2 := null
    , p1_a151  VARCHAR2 := null
    , p1_a152  VARCHAR2 := null
    , p1_a153  VARCHAR2 := null
    , p1_a154  VARCHAR2 := null
    , p1_a155  VARCHAR2 := null
    , p1_a156  VARCHAR2 := null
    , p1_a157  VARCHAR2 := null
    , p1_a158  VARCHAR2 := null
    , p1_a159  VARCHAR2 := null
    , p1_a160  VARCHAR2 := null
    , p1_a161  VARCHAR2 := null
    , p1_a162  VARCHAR2 := null
    , p1_a163  VARCHAR2 := null
    , p1_a164  VARCHAR2 := null
    , p1_a165  VARCHAR2 := null
    , p1_a166  VARCHAR2 := null
    , p1_a167  VARCHAR2 := null
    , p1_a168  VARCHAR2 := null
    , p1_a169  VARCHAR2 := null
    , p1_a170  VARCHAR2 := null
    , p1_a171  VARCHAR2 := null
    , p1_a172  VARCHAR2 := null
    , p1_a173  VARCHAR2 := null
    , p1_a174  VARCHAR2 := null
    , p1_a175  VARCHAR2 := null
    , p1_a176  VARCHAR2 := null
    , p1_a177  VARCHAR2 := null
    , p1_a178  VARCHAR2 := null
    , p1_a179  VARCHAR2 := null
  )
  as
    ddp_bank_rec hz_bank_pub.bank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_bank_rec.bank_or_branch_number := p1_a0;
    ddp_bank_rec.bank_code := p1_a1;
    ddp_bank_rec.branch_code := p1_a2;
    ddp_bank_rec.institution_type := p1_a3;
    ddp_bank_rec.branch_type := p1_a4;
    ddp_bank_rec.country := p1_a5;
    ddp_bank_rec.rfc_code := p1_a6;
    ddp_bank_rec.inactive_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_bank_rec.organization_rec.organization_name := p1_a8;
    ddp_bank_rec.organization_rec.duns_number_c := p1_a9;
    ddp_bank_rec.organization_rec.enquiry_duns := p1_a10;
    ddp_bank_rec.organization_rec.ceo_name := p1_a11;
    ddp_bank_rec.organization_rec.ceo_title := p1_a12;
    ddp_bank_rec.organization_rec.principal_name := p1_a13;
    ddp_bank_rec.organization_rec.principal_title := p1_a14;
    ddp_bank_rec.organization_rec.legal_status := p1_a15;
    ddp_bank_rec.organization_rec.control_yr := rosetta_g_miss_num_map(p1_a16);
    ddp_bank_rec.organization_rec.employees_total := rosetta_g_miss_num_map(p1_a17);
    ddp_bank_rec.organization_rec.hq_branch_ind := p1_a18;
    ddp_bank_rec.organization_rec.branch_flag := p1_a19;
    ddp_bank_rec.organization_rec.oob_ind := p1_a20;
    ddp_bank_rec.organization_rec.line_of_business := p1_a21;
    ddp_bank_rec.organization_rec.cong_dist_code := p1_a22;
    ddp_bank_rec.organization_rec.sic_code := p1_a23;
    ddp_bank_rec.organization_rec.import_ind := p1_a24;
    ddp_bank_rec.organization_rec.export_ind := p1_a25;
    ddp_bank_rec.organization_rec.labor_surplus_ind := p1_a26;
    ddp_bank_rec.organization_rec.debarment_ind := p1_a27;
    ddp_bank_rec.organization_rec.minority_owned_ind := p1_a28;
    ddp_bank_rec.organization_rec.minority_owned_type := p1_a29;
    ddp_bank_rec.organization_rec.woman_owned_ind := p1_a30;
    ddp_bank_rec.organization_rec.disadv_8a_ind := p1_a31;
    ddp_bank_rec.organization_rec.small_bus_ind := p1_a32;
    ddp_bank_rec.organization_rec.rent_own_ind := p1_a33;
    ddp_bank_rec.organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a34);
    ddp_bank_rec.organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a35);
    ddp_bank_rec.organization_rec.failure_score := p1_a36;
    ddp_bank_rec.organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a37);
    ddp_bank_rec.organization_rec.failure_score_override_code := p1_a38;
    ddp_bank_rec.organization_rec.failure_score_commentary := p1_a39;
    ddp_bank_rec.organization_rec.global_failure_score := p1_a40;
    ddp_bank_rec.organization_rec.db_rating := p1_a41;
    ddp_bank_rec.organization_rec.credit_score := p1_a42;
    ddp_bank_rec.organization_rec.credit_score_commentary := p1_a43;
    ddp_bank_rec.organization_rec.paydex_score := p1_a44;
    ddp_bank_rec.organization_rec.paydex_three_months_ago := p1_a45;
    ddp_bank_rec.organization_rec.paydex_norm := p1_a46;
    ddp_bank_rec.organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a47);
    ddp_bank_rec.organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a48);
    ddp_bank_rec.organization_rec.organization_name_phonetic := p1_a49;
    ddp_bank_rec.organization_rec.tax_reference := p1_a50;
    ddp_bank_rec.organization_rec.gsa_indicator_flag := p1_a51;
    ddp_bank_rec.organization_rec.jgzz_fiscal_code := p1_a52;
    ddp_bank_rec.organization_rec.analysis_fy := p1_a53;
    ddp_bank_rec.organization_rec.fiscal_yearend_month := p1_a54;
    ddp_bank_rec.organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a55);
    ddp_bank_rec.organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a56);
    ddp_bank_rec.organization_rec.year_established := rosetta_g_miss_num_map(p1_a57);
    ddp_bank_rec.organization_rec.mission_statement := p1_a58;
    ddp_bank_rec.organization_rec.organization_type := p1_a59;
    ddp_bank_rec.organization_rec.business_scope := p1_a60;
    ddp_bank_rec.organization_rec.corporation_class := p1_a61;
    ddp_bank_rec.organization_rec.known_as := p1_a62;
    ddp_bank_rec.organization_rec.known_as2 := p1_a63;
    ddp_bank_rec.organization_rec.known_as3 := p1_a64;
    ddp_bank_rec.organization_rec.known_as4 := p1_a65;
    ddp_bank_rec.organization_rec.known_as5 := p1_a66;
    ddp_bank_rec.organization_rec.local_bus_iden_type := p1_a67;
    ddp_bank_rec.organization_rec.local_bus_identifier := p1_a68;
    ddp_bank_rec.organization_rec.pref_functional_currency := p1_a69;
    ddp_bank_rec.organization_rec.registration_type := p1_a70;
    ddp_bank_rec.organization_rec.total_employees_text := p1_a71;
    ddp_bank_rec.organization_rec.total_employees_ind := p1_a72;
    ddp_bank_rec.organization_rec.total_emp_est_ind := p1_a73;
    ddp_bank_rec.organization_rec.total_emp_min_ind := p1_a74;
    ddp_bank_rec.organization_rec.parent_sub_ind := p1_a75;
    ddp_bank_rec.organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a76);
    ddp_bank_rec.organization_rec.sic_code_type := p1_a77;
    ddp_bank_rec.organization_rec.public_private_ownership_flag := p1_a78;
    ddp_bank_rec.organization_rec.internal_flag := p1_a79;
    ddp_bank_rec.organization_rec.local_activity_code_type := p1_a80;
    ddp_bank_rec.organization_rec.local_activity_code := p1_a81;
    ddp_bank_rec.organization_rec.emp_at_primary_adr := p1_a82;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_text := p1_a83;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_est_ind := p1_a84;
    ddp_bank_rec.organization_rec.emp_at_primary_adr_min_ind := p1_a85;
    ddp_bank_rec.organization_rec.high_credit := rosetta_g_miss_num_map(p1_a86);
    ddp_bank_rec.organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a87);
    ddp_bank_rec.organization_rec.total_payments := rosetta_g_miss_num_map(p1_a88);
    ddp_bank_rec.organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a89);
    ddp_bank_rec.organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a90);
    ddp_bank_rec.organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a91);
    ddp_bank_rec.organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a92);
    ddp_bank_rec.organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_bank_rec.organization_rec.credit_score_commentary2 := p1_a94;
    ddp_bank_rec.organization_rec.credit_score_commentary3 := p1_a95;
    ddp_bank_rec.organization_rec.credit_score_commentary4 := p1_a96;
    ddp_bank_rec.organization_rec.credit_score_commentary5 := p1_a97;
    ddp_bank_rec.organization_rec.credit_score_commentary6 := p1_a98;
    ddp_bank_rec.organization_rec.credit_score_commentary7 := p1_a99;
    ddp_bank_rec.organization_rec.credit_score_commentary8 := p1_a100;
    ddp_bank_rec.organization_rec.credit_score_commentary9 := p1_a101;
    ddp_bank_rec.organization_rec.credit_score_commentary10 := p1_a102;
    ddp_bank_rec.organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a103);
    ddp_bank_rec.organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a104);
    ddp_bank_rec.organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a105);
    ddp_bank_rec.organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_bank_rec.organization_rec.failure_score_commentary2 := p1_a107;
    ddp_bank_rec.organization_rec.failure_score_commentary3 := p1_a108;
    ddp_bank_rec.organization_rec.failure_score_commentary4 := p1_a109;
    ddp_bank_rec.organization_rec.failure_score_commentary5 := p1_a110;
    ddp_bank_rec.organization_rec.failure_score_commentary6 := p1_a111;
    ddp_bank_rec.organization_rec.failure_score_commentary7 := p1_a112;
    ddp_bank_rec.organization_rec.failure_score_commentary8 := p1_a113;
    ddp_bank_rec.organization_rec.failure_score_commentary9 := p1_a114;
    ddp_bank_rec.organization_rec.failure_score_commentary10 := p1_a115;
    ddp_bank_rec.organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a116);
    ddp_bank_rec.organization_rec.maximum_credit_currency_code := p1_a117;
    ddp_bank_rec.organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a118);
    ddp_bank_rec.organization_rec.content_source_type := p1_a119;
    ddp_bank_rec.organization_rec.content_source_number := p1_a120;
    ddp_bank_rec.organization_rec.attribute_category := p1_a121;
    ddp_bank_rec.organization_rec.attribute1 := p1_a122;
    ddp_bank_rec.organization_rec.attribute2 := p1_a123;
    ddp_bank_rec.organization_rec.attribute3 := p1_a124;
    ddp_bank_rec.organization_rec.attribute4 := p1_a125;
    ddp_bank_rec.organization_rec.attribute5 := p1_a126;
    ddp_bank_rec.organization_rec.attribute6 := p1_a127;
    ddp_bank_rec.organization_rec.attribute7 := p1_a128;
    ddp_bank_rec.organization_rec.attribute8 := p1_a129;
    ddp_bank_rec.organization_rec.attribute9 := p1_a130;
    ddp_bank_rec.organization_rec.attribute10 := p1_a131;
    ddp_bank_rec.organization_rec.attribute11 := p1_a132;
    ddp_bank_rec.organization_rec.attribute12 := p1_a133;
    ddp_bank_rec.organization_rec.attribute13 := p1_a134;
    ddp_bank_rec.organization_rec.attribute14 := p1_a135;
    ddp_bank_rec.organization_rec.attribute15 := p1_a136;
    ddp_bank_rec.organization_rec.attribute16 := p1_a137;
    ddp_bank_rec.organization_rec.attribute17 := p1_a138;
    ddp_bank_rec.organization_rec.attribute18 := p1_a139;
    ddp_bank_rec.organization_rec.attribute19 := p1_a140;
    ddp_bank_rec.organization_rec.attribute20 := p1_a141;
    ddp_bank_rec.organization_rec.created_by_module := p1_a142;
    ddp_bank_rec.organization_rec.application_id := rosetta_g_miss_num_map(p1_a143);
    ddp_bank_rec.organization_rec.do_not_confuse_with := p1_a144;
    ddp_bank_rec.organization_rec.actual_content_source := p1_a145;
    ddp_bank_rec.organization_rec.home_country := p1_a146;
    ddp_bank_rec.organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a147);
    ddp_bank_rec.organization_rec.party_rec.party_number := p1_a148;
    ddp_bank_rec.organization_rec.party_rec.validated_flag := p1_a149;
    ddp_bank_rec.organization_rec.party_rec.orig_system_reference := p1_a150;
    ddp_bank_rec.organization_rec.party_rec.orig_system := p1_a151;
    ddp_bank_rec.organization_rec.party_rec.status := p1_a152;
    ddp_bank_rec.organization_rec.party_rec.category_code := p1_a153;
    ddp_bank_rec.organization_rec.party_rec.salutation := p1_a154;
    ddp_bank_rec.organization_rec.party_rec.attribute_category := p1_a155;
    ddp_bank_rec.organization_rec.party_rec.attribute1 := p1_a156;
    ddp_bank_rec.organization_rec.party_rec.attribute2 := p1_a157;
    ddp_bank_rec.organization_rec.party_rec.attribute3 := p1_a158;
    ddp_bank_rec.organization_rec.party_rec.attribute4 := p1_a159;
    ddp_bank_rec.organization_rec.party_rec.attribute5 := p1_a160;
    ddp_bank_rec.organization_rec.party_rec.attribute6 := p1_a161;
    ddp_bank_rec.organization_rec.party_rec.attribute7 := p1_a162;
    ddp_bank_rec.organization_rec.party_rec.attribute8 := p1_a163;
    ddp_bank_rec.organization_rec.party_rec.attribute9 := p1_a164;
    ddp_bank_rec.organization_rec.party_rec.attribute10 := p1_a165;
    ddp_bank_rec.organization_rec.party_rec.attribute11 := p1_a166;
    ddp_bank_rec.organization_rec.party_rec.attribute12 := p1_a167;
    ddp_bank_rec.organization_rec.party_rec.attribute13 := p1_a168;
    ddp_bank_rec.organization_rec.party_rec.attribute14 := p1_a169;
    ddp_bank_rec.organization_rec.party_rec.attribute15 := p1_a170;
    ddp_bank_rec.organization_rec.party_rec.attribute16 := p1_a171;
    ddp_bank_rec.organization_rec.party_rec.attribute17 := p1_a172;
    ddp_bank_rec.organization_rec.party_rec.attribute18 := p1_a173;
    ddp_bank_rec.organization_rec.party_rec.attribute19 := p1_a174;
    ddp_bank_rec.organization_rec.party_rec.attribute20 := p1_a175;
    ddp_bank_rec.organization_rec.party_rec.attribute21 := p1_a176;
    ddp_bank_rec.organization_rec.party_rec.attribute22 := p1_a177;
    ddp_bank_rec.organization_rec.party_rec.attribute23 := p1_a178;
    ddp_bank_rec.organization_rec.party_rec.attribute24 := p1_a179;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.validate_bank(p_init_msg_list,
      ddp_bank_rec,
      p_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure validate_bank_branch_26(p_init_msg_list  VARCHAR2
    , p_bank_party_id  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  DATE := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  NUMBER := null
    , p2_a17  NUMBER := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  VARCHAR2 := null
    , p2_a30  VARCHAR2 := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
    , p2_a34  NUMBER := null
    , p2_a35  DATE := null
    , p2_a36  VARCHAR2 := null
    , p2_a37  NUMBER := null
    , p2_a38  VARCHAR2 := null
    , p2_a39  VARCHAR2 := null
    , p2_a40  VARCHAR2 := null
    , p2_a41  VARCHAR2 := null
    , p2_a42  VARCHAR2 := null
    , p2_a43  VARCHAR2 := null
    , p2_a44  VARCHAR2 := null
    , p2_a45  VARCHAR2 := null
    , p2_a46  VARCHAR2 := null
    , p2_a47  DATE := null
    , p2_a48  DATE := null
    , p2_a49  VARCHAR2 := null
    , p2_a50  VARCHAR2 := null
    , p2_a51  VARCHAR2 := null
    , p2_a52  VARCHAR2 := null
    , p2_a53  VARCHAR2 := null
    , p2_a54  VARCHAR2 := null
    , p2_a55  NUMBER := null
    , p2_a56  NUMBER := null
    , p2_a57  NUMBER := null
    , p2_a58  VARCHAR2 := null
    , p2_a59  VARCHAR2 := null
    , p2_a60  VARCHAR2 := null
    , p2_a61  VARCHAR2 := null
    , p2_a62  VARCHAR2 := null
    , p2_a63  VARCHAR2 := null
    , p2_a64  VARCHAR2 := null
    , p2_a65  VARCHAR2 := null
    , p2_a66  VARCHAR2 := null
    , p2_a67  VARCHAR2 := null
    , p2_a68  VARCHAR2 := null
    , p2_a69  VARCHAR2 := null
    , p2_a70  VARCHAR2 := null
    , p2_a71  VARCHAR2 := null
    , p2_a72  VARCHAR2 := null
    , p2_a73  VARCHAR2 := null
    , p2_a74  VARCHAR2 := null
    , p2_a75  VARCHAR2 := null
    , p2_a76  NUMBER := null
    , p2_a77  VARCHAR2 := null
    , p2_a78  VARCHAR2 := null
    , p2_a79  VARCHAR2 := null
    , p2_a80  VARCHAR2 := null
    , p2_a81  VARCHAR2 := null
    , p2_a82  VARCHAR2 := null
    , p2_a83  VARCHAR2 := null
    , p2_a84  VARCHAR2 := null
    , p2_a85  VARCHAR2 := null
    , p2_a86  NUMBER := null
    , p2_a87  NUMBER := null
    , p2_a88  NUMBER := null
    , p2_a89  NUMBER := null
    , p2_a90  NUMBER := null
    , p2_a91  NUMBER := null
    , p2_a92  NUMBER := null
    , p2_a93  DATE := null
    , p2_a94  VARCHAR2 := null
    , p2_a95  VARCHAR2 := null
    , p2_a96  VARCHAR2 := null
    , p2_a97  VARCHAR2 := null
    , p2_a98  VARCHAR2 := null
    , p2_a99  VARCHAR2 := null
    , p2_a100  VARCHAR2 := null
    , p2_a101  VARCHAR2 := null
    , p2_a102  VARCHAR2 := null
    , p2_a103  NUMBER := null
    , p2_a104  NUMBER := null
    , p2_a105  NUMBER := null
    , p2_a106  DATE := null
    , p2_a107  VARCHAR2 := null
    , p2_a108  VARCHAR2 := null
    , p2_a109  VARCHAR2 := null
    , p2_a110  VARCHAR2 := null
    , p2_a111  VARCHAR2 := null
    , p2_a112  VARCHAR2 := null
    , p2_a113  VARCHAR2 := null
    , p2_a114  VARCHAR2 := null
    , p2_a115  VARCHAR2 := null
    , p2_a116  NUMBER := null
    , p2_a117  VARCHAR2 := null
    , p2_a118  NUMBER := null
    , p2_a119  VARCHAR2 := null
    , p2_a120  VARCHAR2 := null
    , p2_a121  VARCHAR2 := null
    , p2_a122  VARCHAR2 := null
    , p2_a123  VARCHAR2 := null
    , p2_a124  VARCHAR2 := null
    , p2_a125  VARCHAR2 := null
    , p2_a126  VARCHAR2 := null
    , p2_a127  VARCHAR2 := null
    , p2_a128  VARCHAR2 := null
    , p2_a129  VARCHAR2 := null
    , p2_a130  VARCHAR2 := null
    , p2_a131  VARCHAR2 := null
    , p2_a132  VARCHAR2 := null
    , p2_a133  VARCHAR2 := null
    , p2_a134  VARCHAR2 := null
    , p2_a135  VARCHAR2 := null
    , p2_a136  VARCHAR2 := null
    , p2_a137  VARCHAR2 := null
    , p2_a138  VARCHAR2 := null
    , p2_a139  VARCHAR2 := null
    , p2_a140  VARCHAR2 := null
    , p2_a141  VARCHAR2 := null
    , p2_a142  VARCHAR2 := null
    , p2_a143  NUMBER := null
    , p2_a144  VARCHAR2 := null
    , p2_a145  VARCHAR2 := null
    , p2_a146  VARCHAR2 := null
    , p2_a147  NUMBER := null
    , p2_a148  VARCHAR2 := null
    , p2_a149  VARCHAR2 := null
    , p2_a150  VARCHAR2 := null
    , p2_a151  VARCHAR2 := null
    , p2_a152  VARCHAR2 := null
    , p2_a153  VARCHAR2 := null
    , p2_a154  VARCHAR2 := null
    , p2_a155  VARCHAR2 := null
    , p2_a156  VARCHAR2 := null
    , p2_a157  VARCHAR2 := null
    , p2_a158  VARCHAR2 := null
    , p2_a159  VARCHAR2 := null
    , p2_a160  VARCHAR2 := null
    , p2_a161  VARCHAR2 := null
    , p2_a162  VARCHAR2 := null
    , p2_a163  VARCHAR2 := null
    , p2_a164  VARCHAR2 := null
    , p2_a165  VARCHAR2 := null
    , p2_a166  VARCHAR2 := null
    , p2_a167  VARCHAR2 := null
    , p2_a168  VARCHAR2 := null
    , p2_a169  VARCHAR2 := null
    , p2_a170  VARCHAR2 := null
    , p2_a171  VARCHAR2 := null
    , p2_a172  VARCHAR2 := null
    , p2_a173  VARCHAR2 := null
    , p2_a174  VARCHAR2 := null
    , p2_a175  VARCHAR2 := null
    , p2_a176  VARCHAR2 := null
    , p2_a177  VARCHAR2 := null
    , p2_a178  VARCHAR2 := null
    , p2_a179  VARCHAR2 := null
  )
  as
    ddp_bank_branch_rec hz_bank_pub.bank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_bank_branch_rec.bank_or_branch_number := p2_a0;
    ddp_bank_branch_rec.bank_code := p2_a1;
    ddp_bank_branch_rec.branch_code := p2_a2;
    ddp_bank_branch_rec.institution_type := p2_a3;
    ddp_bank_branch_rec.branch_type := p2_a4;
    ddp_bank_branch_rec.country := p2_a5;
    ddp_bank_branch_rec.rfc_code := p2_a6;
    ddp_bank_branch_rec.inactive_date := rosetta_g_miss_date_in_map(p2_a7);
    ddp_bank_branch_rec.organization_rec.organization_name := p2_a8;
    ddp_bank_branch_rec.organization_rec.duns_number_c := p2_a9;
    ddp_bank_branch_rec.organization_rec.enquiry_duns := p2_a10;
    ddp_bank_branch_rec.organization_rec.ceo_name := p2_a11;
    ddp_bank_branch_rec.organization_rec.ceo_title := p2_a12;
    ddp_bank_branch_rec.organization_rec.principal_name := p2_a13;
    ddp_bank_branch_rec.organization_rec.principal_title := p2_a14;
    ddp_bank_branch_rec.organization_rec.legal_status := p2_a15;
    ddp_bank_branch_rec.organization_rec.control_yr := rosetta_g_miss_num_map(p2_a16);
    ddp_bank_branch_rec.organization_rec.employees_total := rosetta_g_miss_num_map(p2_a17);
    ddp_bank_branch_rec.organization_rec.hq_branch_ind := p2_a18;
    ddp_bank_branch_rec.organization_rec.branch_flag := p2_a19;
    ddp_bank_branch_rec.organization_rec.oob_ind := p2_a20;
    ddp_bank_branch_rec.organization_rec.line_of_business := p2_a21;
    ddp_bank_branch_rec.organization_rec.cong_dist_code := p2_a22;
    ddp_bank_branch_rec.organization_rec.sic_code := p2_a23;
    ddp_bank_branch_rec.organization_rec.import_ind := p2_a24;
    ddp_bank_branch_rec.organization_rec.export_ind := p2_a25;
    ddp_bank_branch_rec.organization_rec.labor_surplus_ind := p2_a26;
    ddp_bank_branch_rec.organization_rec.debarment_ind := p2_a27;
    ddp_bank_branch_rec.organization_rec.minority_owned_ind := p2_a28;
    ddp_bank_branch_rec.organization_rec.minority_owned_type := p2_a29;
    ddp_bank_branch_rec.organization_rec.woman_owned_ind := p2_a30;
    ddp_bank_branch_rec.organization_rec.disadv_8a_ind := p2_a31;
    ddp_bank_branch_rec.organization_rec.small_bus_ind := p2_a32;
    ddp_bank_branch_rec.organization_rec.rent_own_ind := p2_a33;
    ddp_bank_branch_rec.organization_rec.debarments_count := rosetta_g_miss_num_map(p2_a34);
    ddp_bank_branch_rec.organization_rec.debarments_date := rosetta_g_miss_date_in_map(p2_a35);
    ddp_bank_branch_rec.organization_rec.failure_score := p2_a36;
    ddp_bank_branch_rec.organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p2_a37);
    ddp_bank_branch_rec.organization_rec.failure_score_override_code := p2_a38;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary := p2_a39;
    ddp_bank_branch_rec.organization_rec.global_failure_score := p2_a40;
    ddp_bank_branch_rec.organization_rec.db_rating := p2_a41;
    ddp_bank_branch_rec.organization_rec.credit_score := p2_a42;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary := p2_a43;
    ddp_bank_branch_rec.organization_rec.paydex_score := p2_a44;
    ddp_bank_branch_rec.organization_rec.paydex_three_months_ago := p2_a45;
    ddp_bank_branch_rec.organization_rec.paydex_norm := p2_a46;
    ddp_bank_branch_rec.organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p2_a47);
    ddp_bank_branch_rec.organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p2_a48);
    ddp_bank_branch_rec.organization_rec.organization_name_phonetic := p2_a49;
    ddp_bank_branch_rec.organization_rec.tax_reference := p2_a50;
    ddp_bank_branch_rec.organization_rec.gsa_indicator_flag := p2_a51;
    ddp_bank_branch_rec.organization_rec.jgzz_fiscal_code := p2_a52;
    ddp_bank_branch_rec.organization_rec.analysis_fy := p2_a53;
    ddp_bank_branch_rec.organization_rec.fiscal_yearend_month := p2_a54;
    ddp_bank_branch_rec.organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p2_a55);
    ddp_bank_branch_rec.organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p2_a56);
    ddp_bank_branch_rec.organization_rec.year_established := rosetta_g_miss_num_map(p2_a57);
    ddp_bank_branch_rec.organization_rec.mission_statement := p2_a58;
    ddp_bank_branch_rec.organization_rec.organization_type := p2_a59;
    ddp_bank_branch_rec.organization_rec.business_scope := p2_a60;
    ddp_bank_branch_rec.organization_rec.corporation_class := p2_a61;
    ddp_bank_branch_rec.organization_rec.known_as := p2_a62;
    ddp_bank_branch_rec.organization_rec.known_as2 := p2_a63;
    ddp_bank_branch_rec.organization_rec.known_as3 := p2_a64;
    ddp_bank_branch_rec.organization_rec.known_as4 := p2_a65;
    ddp_bank_branch_rec.organization_rec.known_as5 := p2_a66;
    ddp_bank_branch_rec.organization_rec.local_bus_iden_type := p2_a67;
    ddp_bank_branch_rec.organization_rec.local_bus_identifier := p2_a68;
    ddp_bank_branch_rec.organization_rec.pref_functional_currency := p2_a69;
    ddp_bank_branch_rec.organization_rec.registration_type := p2_a70;
    ddp_bank_branch_rec.organization_rec.total_employees_text := p2_a71;
    ddp_bank_branch_rec.organization_rec.total_employees_ind := p2_a72;
    ddp_bank_branch_rec.organization_rec.total_emp_est_ind := p2_a73;
    ddp_bank_branch_rec.organization_rec.total_emp_min_ind := p2_a74;
    ddp_bank_branch_rec.organization_rec.parent_sub_ind := p2_a75;
    ddp_bank_branch_rec.organization_rec.incorp_year := rosetta_g_miss_num_map(p2_a76);
    ddp_bank_branch_rec.organization_rec.sic_code_type := p2_a77;
    ddp_bank_branch_rec.organization_rec.public_private_ownership_flag := p2_a78;
    ddp_bank_branch_rec.organization_rec.internal_flag := p2_a79;
    ddp_bank_branch_rec.organization_rec.local_activity_code_type := p2_a80;
    ddp_bank_branch_rec.organization_rec.local_activity_code := p2_a81;
    ddp_bank_branch_rec.organization_rec.emp_at_primary_adr := p2_a82;
    ddp_bank_branch_rec.organization_rec.emp_at_primary_adr_text := p2_a83;
    ddp_bank_branch_rec.organization_rec.emp_at_primary_adr_est_ind := p2_a84;
    ddp_bank_branch_rec.organization_rec.emp_at_primary_adr_min_ind := p2_a85;
    ddp_bank_branch_rec.organization_rec.high_credit := rosetta_g_miss_num_map(p2_a86);
    ddp_bank_branch_rec.organization_rec.avg_high_credit := rosetta_g_miss_num_map(p2_a87);
    ddp_bank_branch_rec.organization_rec.total_payments := rosetta_g_miss_num_map(p2_a88);
    ddp_bank_branch_rec.organization_rec.credit_score_class := rosetta_g_miss_num_map(p2_a89);
    ddp_bank_branch_rec.organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p2_a90);
    ddp_bank_branch_rec.organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p2_a91);
    ddp_bank_branch_rec.organization_rec.credit_score_age := rosetta_g_miss_num_map(p2_a92);
    ddp_bank_branch_rec.organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p2_a93);
    ddp_bank_branch_rec.organization_rec.credit_score_commentary2 := p2_a94;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary3 := p2_a95;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary4 := p2_a96;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary5 := p2_a97;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary6 := p2_a98;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary7 := p2_a99;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary8 := p2_a100;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary9 := p2_a101;
    ddp_bank_branch_rec.organization_rec.credit_score_commentary10 := p2_a102;
    ddp_bank_branch_rec.organization_rec.failure_score_class := rosetta_g_miss_num_map(p2_a103);
    ddp_bank_branch_rec.organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p2_a104);
    ddp_bank_branch_rec.organization_rec.failure_score_age := rosetta_g_miss_num_map(p2_a105);
    ddp_bank_branch_rec.organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p2_a106);
    ddp_bank_branch_rec.organization_rec.failure_score_commentary2 := p2_a107;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary3 := p2_a108;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary4 := p2_a109;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary5 := p2_a110;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary6 := p2_a111;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary7 := p2_a112;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary8 := p2_a113;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary9 := p2_a114;
    ddp_bank_branch_rec.organization_rec.failure_score_commentary10 := p2_a115;
    ddp_bank_branch_rec.organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p2_a116);
    ddp_bank_branch_rec.organization_rec.maximum_credit_currency_code := p2_a117;
    ddp_bank_branch_rec.organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p2_a118);
    ddp_bank_branch_rec.organization_rec.content_source_type := p2_a119;
    ddp_bank_branch_rec.organization_rec.content_source_number := p2_a120;
    ddp_bank_branch_rec.organization_rec.attribute_category := p2_a121;
    ddp_bank_branch_rec.organization_rec.attribute1 := p2_a122;
    ddp_bank_branch_rec.organization_rec.attribute2 := p2_a123;
    ddp_bank_branch_rec.organization_rec.attribute3 := p2_a124;
    ddp_bank_branch_rec.organization_rec.attribute4 := p2_a125;
    ddp_bank_branch_rec.organization_rec.attribute5 := p2_a126;
    ddp_bank_branch_rec.organization_rec.attribute6 := p2_a127;
    ddp_bank_branch_rec.organization_rec.attribute7 := p2_a128;
    ddp_bank_branch_rec.organization_rec.attribute8 := p2_a129;
    ddp_bank_branch_rec.organization_rec.attribute9 := p2_a130;
    ddp_bank_branch_rec.organization_rec.attribute10 := p2_a131;
    ddp_bank_branch_rec.organization_rec.attribute11 := p2_a132;
    ddp_bank_branch_rec.organization_rec.attribute12 := p2_a133;
    ddp_bank_branch_rec.organization_rec.attribute13 := p2_a134;
    ddp_bank_branch_rec.organization_rec.attribute14 := p2_a135;
    ddp_bank_branch_rec.organization_rec.attribute15 := p2_a136;
    ddp_bank_branch_rec.organization_rec.attribute16 := p2_a137;
    ddp_bank_branch_rec.organization_rec.attribute17 := p2_a138;
    ddp_bank_branch_rec.organization_rec.attribute18 := p2_a139;
    ddp_bank_branch_rec.organization_rec.attribute19 := p2_a140;
    ddp_bank_branch_rec.organization_rec.attribute20 := p2_a141;
    ddp_bank_branch_rec.organization_rec.created_by_module := p2_a142;
    ddp_bank_branch_rec.organization_rec.application_id := rosetta_g_miss_num_map(p2_a143);
    ddp_bank_branch_rec.organization_rec.do_not_confuse_with := p2_a144;
    ddp_bank_branch_rec.organization_rec.actual_content_source := p2_a145;
    ddp_bank_branch_rec.organization_rec.home_country := p2_a146;
    ddp_bank_branch_rec.organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p2_a147);
    ddp_bank_branch_rec.organization_rec.party_rec.party_number := p2_a148;
    ddp_bank_branch_rec.organization_rec.party_rec.validated_flag := p2_a149;
    ddp_bank_branch_rec.organization_rec.party_rec.orig_system_reference := p2_a150;
    ddp_bank_branch_rec.organization_rec.party_rec.orig_system := p2_a151;
    ddp_bank_branch_rec.organization_rec.party_rec.status := p2_a152;
    ddp_bank_branch_rec.organization_rec.party_rec.category_code := p2_a153;
    ddp_bank_branch_rec.organization_rec.party_rec.salutation := p2_a154;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute_category := p2_a155;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute1 := p2_a156;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute2 := p2_a157;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute3 := p2_a158;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute4 := p2_a159;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute5 := p2_a160;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute6 := p2_a161;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute7 := p2_a162;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute8 := p2_a163;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute9 := p2_a164;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute10 := p2_a165;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute11 := p2_a166;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute12 := p2_a167;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute13 := p2_a168;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute14 := p2_a169;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute15 := p2_a170;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute16 := p2_a171;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute17 := p2_a172;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute18 := p2_a173;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute19 := p2_a174;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute20 := p2_a175;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute21 := p2_a176;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute22 := p2_a177;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute23 := p2_a178;
    ddp_bank_branch_rec.organization_rec.party_rec.attribute24 := p2_a179;





    -- here's the delegated call to the old PL/SQL routine
    hz_bank_pub.validate_bank_branch(p_init_msg_list,
      p_bank_party_id,
      ddp_bank_branch_rec,
      p_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end hz_bank_pub_jw;

/
