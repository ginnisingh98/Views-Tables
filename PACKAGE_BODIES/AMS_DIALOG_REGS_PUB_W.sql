--------------------------------------------------------
--  DDL for Package Body AMS_DIALOG_REGS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DIALOG_REGS_PUB_W" as
  /* $Header: amswderb.pls 120.5 2006/08/16 04:49:59 rrajesh noship $ */
  -- This package is used in event registrion through scripting
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure register(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  DATE
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
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
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  DATE
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  DATE
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
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  NUMBER
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  NUMBER
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  DATE
    , p7_a104  DATE
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  NUMBER
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  NUMBER
    , p7_a118  VARCHAR2
    , p7_a119  NUMBER
    , p7_a120  VARCHAR2
    , p7_a121  NUMBER
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  DATE
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  VARCHAR2
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
    , p7_a153  NUMBER
    , p7_a154  NUMBER
    , p7_a155  NUMBER
    , p7_a156  NUMBER
    , p7_a157  VARCHAR2
    , p7_a158  VARCHAR2
    , p7_a159  VARCHAR2
    , p7_a160  VARCHAR2
    , p_block_fulfillment  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_application_id  NUMBER
    , x_confirm_code out nocopy  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_system_status_code out nocopy  VARCHAR2
    , p7_a161  VARCHAR2
  )

  as
    ddp_reg_det_rec ams_dialog_regs_pub.registrationdetails;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_reg_det_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a0);
    ddp_reg_det_rec.last_updated_by := p7_a1;
    ddp_reg_det_rec.creation_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_reg_det_rec.created_by := p7_a3;
    ddp_reg_det_rec.last_update_login := p7_a4;
    ddp_reg_det_rec.event_source_code := p7_a5;
    ddp_reg_det_rec.registration_source_type := p7_a6;
    ddp_reg_det_rec.attendance_flag := p7_a7;
    ddp_reg_det_rec.waitlisted_flag := p7_a8;
    ddp_reg_det_rec.cancellation_flag := p7_a9;
    ddp_reg_det_rec.cancellation_reason_code := p7_a10;
    ddp_reg_det_rec.confirmation_code := p7_a11;
    ddp_reg_det_rec.original_system_reference := p7_a12;
    ddp_reg_det_rec.reg_party_id := p7_a13;
    ddp_reg_det_rec.reg_party_type := p7_a14;
    ddp_reg_det_rec.reg_contact_id := p7_a15;
    ddp_reg_det_rec.reg_party_name := p7_a16;
    ddp_reg_det_rec.reg_title := p7_a17;
    ddp_reg_det_rec.reg_first_name := p7_a18;
    ddp_reg_det_rec.reg_middle_name := p7_a19;
    ddp_reg_det_rec.reg_last_name := p7_a20;
    ddp_reg_det_rec.reg_address1 := p7_a21;
    ddp_reg_det_rec.reg_address2 := p7_a22;
    ddp_reg_det_rec.reg_address3 := p7_a23;
    ddp_reg_det_rec.reg_address4 := p7_a24;
    ddp_reg_det_rec.reg_gender := p7_a25;
    ddp_reg_det_rec.reg_address_line_phonetic := p7_a26;
    ddp_reg_det_rec.reg_analysis_fy := p7_a27;
    ddp_reg_det_rec.reg_apt_flag := p7_a28;
    ddp_reg_det_rec.reg_best_time_contact_begin := rosetta_g_miss_date_in_map(p7_a29);
    ddp_reg_det_rec.reg_best_time_contact_end := rosetta_g_miss_date_in_map(p7_a30);
    ddp_reg_det_rec.reg_category_code := p7_a31;
    ddp_reg_det_rec.reg_ceo_name := p7_a32;
    ddp_reg_det_rec.reg_city := p7_a33;
    ddp_reg_det_rec.reg_country := p7_a34;
    ddp_reg_det_rec.reg_county := p7_a35;
    ddp_reg_det_rec.reg_current_fy_potential_rev := p7_a36;
    ddp_reg_det_rec.reg_next_fy_potential_rev := p7_a37;
    ddp_reg_det_rec.reg_household_income := p7_a38;
    ddp_reg_det_rec.reg_decision_maker_flag := p7_a39;
    ddp_reg_det_rec.reg_department := p7_a40;
    ddp_reg_det_rec.reg_dun_no_c := p7_a41;
    ddp_reg_det_rec.reg_email_address := p7_a42;
    ddp_reg_det_rec.reg_employee_total := p7_a43;
    ddp_reg_det_rec.reg_fy_end_month := p7_a44;
    ddp_reg_det_rec.reg_floor := p7_a45;
    ddp_reg_det_rec.reg_gsa_indicator_flag := p7_a46;
    ddp_reg_det_rec.reg_house_number := p7_a47;
    ddp_reg_det_rec.reg_identifying_address_flag := p7_a48;
    ddp_reg_det_rec.reg_jgzz_fiscal_code := p7_a49;
    ddp_reg_det_rec.reg_job_title := p7_a50;
    ddp_reg_det_rec.reg_last_order_date := rosetta_g_miss_date_in_map(p7_a51);
    ddp_reg_det_rec.reg_org_legal_status := p7_a52;
    ddp_reg_det_rec.reg_line_of_business := p7_a53;
    ddp_reg_det_rec.reg_mission_statement := p7_a54;
    ddp_reg_det_rec.reg_org_name_phonetic := p7_a55;
    ddp_reg_det_rec.reg_overseas_address_flag := p7_a56;
    ddp_reg_det_rec.reg_name_suffix := p7_a57;
    ddp_reg_det_rec.reg_phone_area_code := p7_a58;
    ddp_reg_det_rec.reg_phone_country_code := p7_a59;
    ddp_reg_det_rec.reg_phone_extension := p7_a60;
    ddp_reg_det_rec.reg_phone_number := p7_a61;
    ddp_reg_det_rec.reg_postal_code := p7_a62;
    ddp_reg_det_rec.reg_postal_plus4_code := p7_a63;
    ddp_reg_det_rec.reg_po_box_no := p7_a64;
    ddp_reg_det_rec.reg_province := p7_a65;
    ddp_reg_det_rec.reg_rural_route_no := p7_a66;
    ddp_reg_det_rec.reg_rural_route_type := p7_a67;
    ddp_reg_det_rec.reg_secondary_suffix_element := p7_a68;
    ddp_reg_det_rec.reg_sic_code := p7_a69;
    ddp_reg_det_rec.reg_sic_code_type := p7_a70;
    ddp_reg_det_rec.reg_site_use_code := p7_a71;
    ddp_reg_det_rec.reg_state := p7_a72;
    ddp_reg_det_rec.reg_street := p7_a73;
    ddp_reg_det_rec.reg_street_number := p7_a74;
    ddp_reg_det_rec.reg_street_suffix := p7_a75;
    ddp_reg_det_rec.reg_suite := p7_a76;
    ddp_reg_det_rec.reg_tax_name := p7_a77;
    ddp_reg_det_rec.reg_tax_reference := p7_a78;
    ddp_reg_det_rec.reg_timezone := p7_a79;
    ddp_reg_det_rec.reg_total_no_of_orders := p7_a80;
    ddp_reg_det_rec.reg_total_order_amount := p7_a81;
    ddp_reg_det_rec.reg_year_established := p7_a82;
    ddp_reg_det_rec.reg_url := p7_a83;
    ddp_reg_det_rec.reg_survey_notes := p7_a84;
    ddp_reg_det_rec.reg_contact_me_flag := p7_a85;
    ddp_reg_det_rec.reg_email_ok_flag := p7_a86;
    ddp_reg_det_rec.att_party_id := p7_a87;
    ddp_reg_det_rec.att_party_type := p7_a88;
    ddp_reg_det_rec.att_contact_id := p7_a89;
    ddp_reg_det_rec.att_party_name := p7_a90;
    ddp_reg_det_rec.att_title := p7_a91;
    ddp_reg_det_rec.att_first_name := p7_a92;
    ddp_reg_det_rec.att_middle_name := p7_a93;
    ddp_reg_det_rec.att_last_name := p7_a94;
    ddp_reg_det_rec.att_address1 := p7_a95;
    ddp_reg_det_rec.att_address2 := p7_a96;
    ddp_reg_det_rec.att_address3 := p7_a97;
    ddp_reg_det_rec.att_address4 := p7_a98;
    ddp_reg_det_rec.att_gender := p7_a99;
    ddp_reg_det_rec.att_address_line_phonetic := p7_a100;
    ddp_reg_det_rec.att_analysis_fy := p7_a101;
    ddp_reg_det_rec.att_apt_flag := p7_a102;
    ddp_reg_det_rec.att_best_time_contact_begin := rosetta_g_miss_date_in_map(p7_a103);
    ddp_reg_det_rec.att_best_time_contact_end := rosetta_g_miss_date_in_map(p7_a104);
    ddp_reg_det_rec.att_category_code := p7_a105;
    ddp_reg_det_rec.att_ceo_name := p7_a106;
    ddp_reg_det_rec.att_city := p7_a107;
    ddp_reg_det_rec.att_country := p7_a108;
    ddp_reg_det_rec.att_county := p7_a109;
    ddp_reg_det_rec.att_current_fy_potential_rev := p7_a110;
    ddp_reg_det_rec.att_next_fy_potential_rev := p7_a111;
    ddp_reg_det_rec.att_household_income := p7_a112;
    ddp_reg_det_rec.att_decision_maker_flag := p7_a113;
    ddp_reg_det_rec.att_department := p7_a114;
    ddp_reg_det_rec.att_dun_no_c := p7_a115;
    ddp_reg_det_rec.att_email_address := p7_a116;
    ddp_reg_det_rec.att_employee_total := p7_a117;
    ddp_reg_det_rec.att_fy_end_month := p7_a118;
    ddp_reg_det_rec.att_floor := p7_a119;
    ddp_reg_det_rec.att_gsa_indicator_flag := p7_a120;
    ddp_reg_det_rec.att_house_number := p7_a121;
    ddp_reg_det_rec.att_identifying_address_flag := p7_a122;
    ddp_reg_det_rec.att_jgzz_fiscal_code := p7_a123;
    ddp_reg_det_rec.att_job_title := p7_a124;
    ddp_reg_det_rec.att_last_order_date := rosetta_g_miss_date_in_map(p7_a125);
    ddp_reg_det_rec.att_org_legal_status := p7_a126;
    ddp_reg_det_rec.att_line_of_business := p7_a127;
    ddp_reg_det_rec.att_mission_statement := p7_a128;
    ddp_reg_det_rec.att_org_name_phonetic := p7_a129;
    ddp_reg_det_rec.att_overseas_address_flag := p7_a130;
    ddp_reg_det_rec.att_name_suffix := p7_a131;
    ddp_reg_det_rec.att_phone_area_code := p7_a132;
    ddp_reg_det_rec.att_phone_country_code := p7_a133;
    ddp_reg_det_rec.att_phone_extension := p7_a134;
    ddp_reg_det_rec.att_phone_number := p7_a135;
    ddp_reg_det_rec.att_postal_code := p7_a136;
    ddp_reg_det_rec.att_postal_plus4_code := p7_a137;
    ddp_reg_det_rec.att_po_box_no := p7_a138;
    ddp_reg_det_rec.att_province := p7_a139;
    ddp_reg_det_rec.att_rural_route_no := p7_a140;
    ddp_reg_det_rec.att_rural_route_type := p7_a141;
    ddp_reg_det_rec.att_secondary_suffix_element := p7_a142;
    ddp_reg_det_rec.att_sic_code := p7_a143;
    ddp_reg_det_rec.att_sic_code_type := p7_a144;
    ddp_reg_det_rec.att_site_use_code := p7_a145;
    ddp_reg_det_rec.att_state := p7_a146;
    ddp_reg_det_rec.att_street := p7_a147;
    ddp_reg_det_rec.att_street_number := p7_a148;
    ddp_reg_det_rec.att_street_suffix := p7_a149;
    ddp_reg_det_rec.att_suite := p7_a150;
    ddp_reg_det_rec.att_tax_name := p7_a151;
    ddp_reg_det_rec.att_tax_reference := p7_a152;
    ddp_reg_det_rec.att_timezone := p7_a153;
    ddp_reg_det_rec.att_total_no_of_orders := p7_a154;
    ddp_reg_det_rec.att_total_order_amount := p7_a155;
    ddp_reg_det_rec.att_year_established := p7_a156;
    ddp_reg_det_rec.att_url := p7_a157;
    ddp_reg_det_rec.att_survey_notes := p7_a158;
    ddp_reg_det_rec.att_contact_me_flag := p7_a159;
    ddp_reg_det_rec.att_email_ok_flag := p7_a160;
    ddp_reg_det_rec.update_reg_rec := p7_a161;







    -- here's the delegated call to the old PL/SQL routine
    ams_dialog_regs_pub.register(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_reg_det_rec,
      p_block_fulfillment,
      p_owner_user_id,
      p_application_id,
      x_confirm_code,
      x_party_id,
      x_system_status_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

end ams_dialog_regs_pub_w;

/
