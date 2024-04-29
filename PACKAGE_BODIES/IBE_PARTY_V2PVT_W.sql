--------------------------------------------------------
--  DDL for Package Body IBE_PARTY_V2PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PARTY_V2PVT_W" as
  /* $Header: IBEWPARB.pls 120.1 2005/06/20 09:29:00 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_individual_user(p_username  VARCHAR2
    , p_password  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
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
    , p2_a21  VARCHAR2
    , p2_a22  DATE
    , p2_a23  VARCHAR2
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  VARCHAR2
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  NUMBER
    , p2_a60  VARCHAR2
    , p2_a61  NUMBER
    , p2_a62  VARCHAR2
    , p2_a63  VARCHAR2
    , p2_a64  VARCHAR2
    , p2_a65  VARCHAR2
    , p2_a66  VARCHAR2
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  VARCHAR2
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  VARCHAR2
    , p2_a79  VARCHAR2
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  VARCHAR2
    , p2_a91  VARCHAR2
    , p2_a92  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p_contact_preference  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_user_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddp_work_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_home_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_person_rec.person_pre_name_adjunct := p2_a0;
    ddp_person_rec.person_first_name := p2_a1;
    ddp_person_rec.person_middle_name := p2_a2;
    ddp_person_rec.person_last_name := p2_a3;
    ddp_person_rec.person_name_suffix := p2_a4;
    ddp_person_rec.person_title := p2_a5;
    ddp_person_rec.person_academic_title := p2_a6;
    ddp_person_rec.person_previous_last_name := p2_a7;
    ddp_person_rec.person_initials := p2_a8;
    ddp_person_rec.known_as := p2_a9;
    ddp_person_rec.known_as2 := p2_a10;
    ddp_person_rec.known_as3 := p2_a11;
    ddp_person_rec.known_as4 := p2_a12;
    ddp_person_rec.known_as5 := p2_a13;
    ddp_person_rec.person_name_phonetic := p2_a14;
    ddp_person_rec.person_first_name_phonetic := p2_a15;
    ddp_person_rec.person_last_name_phonetic := p2_a16;
    ddp_person_rec.middle_name_phonetic := p2_a17;
    ddp_person_rec.tax_reference := p2_a18;
    ddp_person_rec.jgzz_fiscal_code := p2_a19;
    ddp_person_rec.person_iden_type := p2_a20;
    ddp_person_rec.person_identifier := p2_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a22);
    ddp_person_rec.place_of_birth := p2_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a24);
    ddp_person_rec.gender := p2_a25;
    ddp_person_rec.declared_ethnicity := p2_a26;
    ddp_person_rec.marital_status := p2_a27;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a28);
    ddp_person_rec.personal_income := p2_a29;
    ddp_person_rec.head_of_household_flag := p2_a30;
    ddp_person_rec.household_income := p2_a31;
    ddp_person_rec.household_size := p2_a32;
    ddp_person_rec.rent_own_ind := p2_a33;
    ddp_person_rec.last_known_gps := p2_a34;
    ddp_person_rec.content_source_type := p2_a35;
    ddp_person_rec.internal_flag := p2_a36;
    ddp_person_rec.attribute_category := p2_a37;
    ddp_person_rec.attribute1 := p2_a38;
    ddp_person_rec.attribute2 := p2_a39;
    ddp_person_rec.attribute3 := p2_a40;
    ddp_person_rec.attribute4 := p2_a41;
    ddp_person_rec.attribute5 := p2_a42;
    ddp_person_rec.attribute6 := p2_a43;
    ddp_person_rec.attribute7 := p2_a44;
    ddp_person_rec.attribute8 := p2_a45;
    ddp_person_rec.attribute9 := p2_a46;
    ddp_person_rec.attribute10 := p2_a47;
    ddp_person_rec.attribute11 := p2_a48;
    ddp_person_rec.attribute12 := p2_a49;
    ddp_person_rec.attribute13 := p2_a50;
    ddp_person_rec.attribute14 := p2_a51;
    ddp_person_rec.attribute15 := p2_a52;
    ddp_person_rec.attribute16 := p2_a53;
    ddp_person_rec.attribute17 := p2_a54;
    ddp_person_rec.attribute18 := p2_a55;
    ddp_person_rec.attribute19 := p2_a56;
    ddp_person_rec.attribute20 := p2_a57;
    ddp_person_rec.created_by_module := p2_a58;
    ddp_person_rec.application_id := p2_a59;
    ddp_person_rec.actual_content_source := p2_a60;
    ddp_person_rec.party_rec.party_id := p2_a61;
    ddp_person_rec.party_rec.party_number := p2_a62;
    ddp_person_rec.party_rec.validated_flag := p2_a63;
    ddp_person_rec.party_rec.orig_system_reference := p2_a64;
    ddp_person_rec.party_rec.status := p2_a65;
    ddp_person_rec.party_rec.category_code := p2_a66;
    ddp_person_rec.party_rec.salutation := p2_a67;
    ddp_person_rec.party_rec.attribute_category := p2_a68;
    ddp_person_rec.party_rec.attribute1 := p2_a69;
    ddp_person_rec.party_rec.attribute2 := p2_a70;
    ddp_person_rec.party_rec.attribute3 := p2_a71;
    ddp_person_rec.party_rec.attribute4 := p2_a72;
    ddp_person_rec.party_rec.attribute5 := p2_a73;
    ddp_person_rec.party_rec.attribute6 := p2_a74;
    ddp_person_rec.party_rec.attribute7 := p2_a75;
    ddp_person_rec.party_rec.attribute8 := p2_a76;
    ddp_person_rec.party_rec.attribute9 := p2_a77;
    ddp_person_rec.party_rec.attribute10 := p2_a78;
    ddp_person_rec.party_rec.attribute11 := p2_a79;
    ddp_person_rec.party_rec.attribute12 := p2_a80;
    ddp_person_rec.party_rec.attribute13 := p2_a81;
    ddp_person_rec.party_rec.attribute14 := p2_a82;
    ddp_person_rec.party_rec.attribute15 := p2_a83;
    ddp_person_rec.party_rec.attribute16 := p2_a84;
    ddp_person_rec.party_rec.attribute17 := p2_a85;
    ddp_person_rec.party_rec.attribute18 := p2_a86;
    ddp_person_rec.party_rec.attribute19 := p2_a87;
    ddp_person_rec.party_rec.attribute20 := p2_a88;
    ddp_person_rec.party_rec.attribute21 := p2_a89;
    ddp_person_rec.party_rec.attribute22 := p2_a90;
    ddp_person_rec.party_rec.attribute23 := p2_a91;
    ddp_person_rec.party_rec.attribute24 := p2_a92;

    ddp_email_rec.email_format := p3_a0;
    ddp_email_rec.email_address := p3_a1;

    ddp_work_phone_rec.phone_calling_calendar := p4_a0;
    ddp_work_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p4_a1);
    ddp_work_phone_rec.timezone_id := p4_a2;
    ddp_work_phone_rec.phone_area_code := p4_a3;
    ddp_work_phone_rec.phone_country_code := p4_a4;
    ddp_work_phone_rec.phone_number := p4_a5;
    ddp_work_phone_rec.phone_extension := p4_a6;
    ddp_work_phone_rec.phone_line_type := p4_a7;
    ddp_work_phone_rec.raw_phone_number := p4_a8;

    ddp_home_phone_rec.phone_calling_calendar := p5_a0;
    ddp_home_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p5_a1);
    ddp_home_phone_rec.timezone_id := p5_a2;
    ddp_home_phone_rec.phone_area_code := p5_a3;
    ddp_home_phone_rec.phone_country_code := p5_a4;
    ddp_home_phone_rec.phone_number := p5_a5;
    ddp_home_phone_rec.phone_extension := p5_a6;
    ddp_home_phone_rec.phone_line_type := p5_a7;
    ddp_home_phone_rec.raw_phone_number := p5_a8;

    ddp_fax_rec.phone_calling_calendar := p6_a0;
    ddp_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p6_a1);
    ddp_fax_rec.timezone_id := p6_a2;
    ddp_fax_rec.phone_area_code := p6_a3;
    ddp_fax_rec.phone_country_code := p6_a4;
    ddp_fax_rec.phone_number := p6_a5;
    ddp_fax_rec.phone_extension := p6_a6;
    ddp_fax_rec.phone_line_type := p6_a7;
    ddp_fax_rec.raw_phone_number := p6_a8;







    -- here's the delegated call to the old PL/SQL routine
    ibe_party_v2pvt.create_individual_user(p_username,
      p_password,
      ddp_person_rec,
      ddp_email_rec,
      ddp_work_phone_rec,
      ddp_home_phone_rec,
      ddp_fax_rec,
      p_contact_preference,
      x_person_party_id,
      x_user_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure create_business_user(p_username  VARCHAR2
    , p_password  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
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
    , p2_a21  VARCHAR2
    , p2_a22  DATE
    , p2_a23  VARCHAR2
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  VARCHAR2
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  NUMBER
    , p2_a60  VARCHAR2
    , p2_a61  NUMBER
    , p2_a62  VARCHAR2
    , p2_a63  VARCHAR2
    , p2_a64  VARCHAR2
    , p2_a65  VARCHAR2
    , p2_a66  VARCHAR2
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  VARCHAR2
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  VARCHAR2
    , p2_a79  VARCHAR2
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  VARCHAR2
    , p2_a91  VARCHAR2
    , p2_a92  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  NUMBER
    , p3_a9  NUMBER
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
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  NUMBER
    , p3_a27  DATE
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  DATE
    , p3_a40  DATE
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  VARCHAR2
    , p3_a62  VARCHAR2
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  VARCHAR2
    , p3_a68  NUMBER
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  NUMBER
    , p3_a79  NUMBER
    , p3_a80  NUMBER
    , p3_a81  NUMBER
    , p3_a82  NUMBER
    , p3_a83  NUMBER
    , p3_a84  NUMBER
    , p3_a85  DATE
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  VARCHAR2
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  NUMBER
    , p3_a96  NUMBER
    , p3_a97  NUMBER
    , p3_a98  DATE
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  VARCHAR2
    , p3_a102  VARCHAR2
    , p3_a103  VARCHAR2
    , p3_a104  VARCHAR2
    , p3_a105  VARCHAR2
    , p3_a106  VARCHAR2
    , p3_a107  VARCHAR2
    , p3_a108  NUMBER
    , p3_a109  VARCHAR2
    , p3_a110  NUMBER
    , p3_a111  VARCHAR2
    , p3_a112  VARCHAR2
    , p3_a113  VARCHAR2
    , p3_a114  VARCHAR2
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  VARCHAR2
    , p3_a118  VARCHAR2
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  VARCHAR2
    , p3_a125  VARCHAR2
    , p3_a126  VARCHAR2
    , p3_a127  VARCHAR2
    , p3_a128  VARCHAR2
    , p3_a129  VARCHAR2
    , p3_a130  VARCHAR2
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  NUMBER
    , p3_a136  VARCHAR2
    , p3_a137  VARCHAR2
    , p3_a138  NUMBER
    , p3_a139  VARCHAR2
    , p3_a140  VARCHAR2
    , p3_a141  VARCHAR2
    , p3_a142  VARCHAR2
    , p3_a143  VARCHAR2
    , p3_a144  VARCHAR2
    , p3_a145  VARCHAR2
    , p3_a146  VARCHAR2
    , p3_a147  VARCHAR2
    , p3_a148  VARCHAR2
    , p3_a149  VARCHAR2
    , p3_a150  VARCHAR2
    , p3_a151  VARCHAR2
    , p3_a152  VARCHAR2
    , p3_a153  VARCHAR2
    , p3_a154  VARCHAR2
    , p3_a155  VARCHAR2
    , p3_a156  VARCHAR2
    , p3_a157  VARCHAR2
    , p3_a158  VARCHAR2
    , p3_a159  VARCHAR2
    , p3_a160  VARCHAR2
    , p3_a161  VARCHAR2
    , p3_a162  VARCHAR2
    , p3_a163  VARCHAR2
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  VARCHAR2
    , p3_a167  VARCHAR2
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
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
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  DATE
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  NUMBER
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  NUMBER
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  VARCHAR2
    , p4_a56  VARCHAR2
    , p4_a57  NUMBER
    , p4_a58  VARCHAR2
    , p4_a59  NUMBER
    , p4_a60  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  DATE
    , p9_a2  NUMBER
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p_rel_contact_preference  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_org_party_id out nocopy  NUMBER
    , x_user_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddp_org_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_org_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_rel_workphone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_rel_homephone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_rel_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_rel_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_person_rec.person_pre_name_adjunct := p2_a0;
    ddp_person_rec.person_first_name := p2_a1;
    ddp_person_rec.person_middle_name := p2_a2;
    ddp_person_rec.person_last_name := p2_a3;
    ddp_person_rec.person_name_suffix := p2_a4;
    ddp_person_rec.person_title := p2_a5;
    ddp_person_rec.person_academic_title := p2_a6;
    ddp_person_rec.person_previous_last_name := p2_a7;
    ddp_person_rec.person_initials := p2_a8;
    ddp_person_rec.known_as := p2_a9;
    ddp_person_rec.known_as2 := p2_a10;
    ddp_person_rec.known_as3 := p2_a11;
    ddp_person_rec.known_as4 := p2_a12;
    ddp_person_rec.known_as5 := p2_a13;
    ddp_person_rec.person_name_phonetic := p2_a14;
    ddp_person_rec.person_first_name_phonetic := p2_a15;
    ddp_person_rec.person_last_name_phonetic := p2_a16;
    ddp_person_rec.middle_name_phonetic := p2_a17;
    ddp_person_rec.tax_reference := p2_a18;
    ddp_person_rec.jgzz_fiscal_code := p2_a19;
    ddp_person_rec.person_iden_type := p2_a20;
    ddp_person_rec.person_identifier := p2_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a22);
    ddp_person_rec.place_of_birth := p2_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a24);
    ddp_person_rec.gender := p2_a25;
    ddp_person_rec.declared_ethnicity := p2_a26;
    ddp_person_rec.marital_status := p2_a27;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a28);
    ddp_person_rec.personal_income := p2_a29;
    ddp_person_rec.head_of_household_flag := p2_a30;
    ddp_person_rec.household_income := p2_a31;
    ddp_person_rec.household_size := p2_a32;
    ddp_person_rec.rent_own_ind := p2_a33;
    ddp_person_rec.last_known_gps := p2_a34;
    ddp_person_rec.content_source_type := p2_a35;
    ddp_person_rec.internal_flag := p2_a36;
    ddp_person_rec.attribute_category := p2_a37;
    ddp_person_rec.attribute1 := p2_a38;
    ddp_person_rec.attribute2 := p2_a39;
    ddp_person_rec.attribute3 := p2_a40;
    ddp_person_rec.attribute4 := p2_a41;
    ddp_person_rec.attribute5 := p2_a42;
    ddp_person_rec.attribute6 := p2_a43;
    ddp_person_rec.attribute7 := p2_a44;
    ddp_person_rec.attribute8 := p2_a45;
    ddp_person_rec.attribute9 := p2_a46;
    ddp_person_rec.attribute10 := p2_a47;
    ddp_person_rec.attribute11 := p2_a48;
    ddp_person_rec.attribute12 := p2_a49;
    ddp_person_rec.attribute13 := p2_a50;
    ddp_person_rec.attribute14 := p2_a51;
    ddp_person_rec.attribute15 := p2_a52;
    ddp_person_rec.attribute16 := p2_a53;
    ddp_person_rec.attribute17 := p2_a54;
    ddp_person_rec.attribute18 := p2_a55;
    ddp_person_rec.attribute19 := p2_a56;
    ddp_person_rec.attribute20 := p2_a57;
    ddp_person_rec.created_by_module := p2_a58;
    ddp_person_rec.application_id := p2_a59;
    ddp_person_rec.actual_content_source := p2_a60;
    ddp_person_rec.party_rec.party_id := p2_a61;
    ddp_person_rec.party_rec.party_number := p2_a62;
    ddp_person_rec.party_rec.validated_flag := p2_a63;
    ddp_person_rec.party_rec.orig_system_reference := p2_a64;
    ddp_person_rec.party_rec.status := p2_a65;
    ddp_person_rec.party_rec.category_code := p2_a66;
    ddp_person_rec.party_rec.salutation := p2_a67;
    ddp_person_rec.party_rec.attribute_category := p2_a68;
    ddp_person_rec.party_rec.attribute1 := p2_a69;
    ddp_person_rec.party_rec.attribute2 := p2_a70;
    ddp_person_rec.party_rec.attribute3 := p2_a71;
    ddp_person_rec.party_rec.attribute4 := p2_a72;
    ddp_person_rec.party_rec.attribute5 := p2_a73;
    ddp_person_rec.party_rec.attribute6 := p2_a74;
    ddp_person_rec.party_rec.attribute7 := p2_a75;
    ddp_person_rec.party_rec.attribute8 := p2_a76;
    ddp_person_rec.party_rec.attribute9 := p2_a77;
    ddp_person_rec.party_rec.attribute10 := p2_a78;
    ddp_person_rec.party_rec.attribute11 := p2_a79;
    ddp_person_rec.party_rec.attribute12 := p2_a80;
    ddp_person_rec.party_rec.attribute13 := p2_a81;
    ddp_person_rec.party_rec.attribute14 := p2_a82;
    ddp_person_rec.party_rec.attribute15 := p2_a83;
    ddp_person_rec.party_rec.attribute16 := p2_a84;
    ddp_person_rec.party_rec.attribute17 := p2_a85;
    ddp_person_rec.party_rec.attribute18 := p2_a86;
    ddp_person_rec.party_rec.attribute19 := p2_a87;
    ddp_person_rec.party_rec.attribute20 := p2_a88;
    ddp_person_rec.party_rec.attribute21 := p2_a89;
    ddp_person_rec.party_rec.attribute22 := p2_a90;
    ddp_person_rec.party_rec.attribute23 := p2_a91;
    ddp_person_rec.party_rec.attribute24 := p2_a92;

    ddp_organization_rec.organization_name := p3_a0;
    ddp_organization_rec.duns_number_c := p3_a1;
    ddp_organization_rec.enquiry_duns := p3_a2;
    ddp_organization_rec.ceo_name := p3_a3;
    ddp_organization_rec.ceo_title := p3_a4;
    ddp_organization_rec.principal_name := p3_a5;
    ddp_organization_rec.principal_title := p3_a6;
    ddp_organization_rec.legal_status := p3_a7;
    ddp_organization_rec.control_yr := p3_a8;
    ddp_organization_rec.employees_total := p3_a9;
    ddp_organization_rec.hq_branch_ind := p3_a10;
    ddp_organization_rec.branch_flag := p3_a11;
    ddp_organization_rec.oob_ind := p3_a12;
    ddp_organization_rec.line_of_business := p3_a13;
    ddp_organization_rec.cong_dist_code := p3_a14;
    ddp_organization_rec.sic_code := p3_a15;
    ddp_organization_rec.import_ind := p3_a16;
    ddp_organization_rec.export_ind := p3_a17;
    ddp_organization_rec.labor_surplus_ind := p3_a18;
    ddp_organization_rec.debarment_ind := p3_a19;
    ddp_organization_rec.minority_owned_ind := p3_a20;
    ddp_organization_rec.minority_owned_type := p3_a21;
    ddp_organization_rec.woman_owned_ind := p3_a22;
    ddp_organization_rec.disadv_8a_ind := p3_a23;
    ddp_organization_rec.small_bus_ind := p3_a24;
    ddp_organization_rec.rent_own_ind := p3_a25;
    ddp_organization_rec.debarments_count := p3_a26;
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p3_a27);
    ddp_organization_rec.failure_score := p3_a28;
    ddp_organization_rec.failure_score_natnl_percentile := p3_a29;
    ddp_organization_rec.failure_score_override_code := p3_a30;
    ddp_organization_rec.failure_score_commentary := p3_a31;
    ddp_organization_rec.global_failure_score := p3_a32;
    ddp_organization_rec.db_rating := p3_a33;
    ddp_organization_rec.credit_score := p3_a34;
    ddp_organization_rec.credit_score_commentary := p3_a35;
    ddp_organization_rec.paydex_score := p3_a36;
    ddp_organization_rec.paydex_three_months_ago := p3_a37;
    ddp_organization_rec.paydex_norm := p3_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p3_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p3_a40);
    ddp_organization_rec.organization_name_phonetic := p3_a41;
    ddp_organization_rec.tax_reference := p3_a42;
    ddp_organization_rec.gsa_indicator_flag := p3_a43;
    ddp_organization_rec.jgzz_fiscal_code := p3_a44;
    ddp_organization_rec.analysis_fy := p3_a45;
    ddp_organization_rec.fiscal_yearend_month := p3_a46;
    ddp_organization_rec.curr_fy_potential_revenue := p3_a47;
    ddp_organization_rec.next_fy_potential_revenue := p3_a48;
    ddp_organization_rec.year_established := p3_a49;
    ddp_organization_rec.mission_statement := p3_a50;
    ddp_organization_rec.organization_type := p3_a51;
    ddp_organization_rec.business_scope := p3_a52;
    ddp_organization_rec.corporation_class := p3_a53;
    ddp_organization_rec.known_as := p3_a54;
    ddp_organization_rec.known_as2 := p3_a55;
    ddp_organization_rec.known_as3 := p3_a56;
    ddp_organization_rec.known_as4 := p3_a57;
    ddp_organization_rec.known_as5 := p3_a58;
    ddp_organization_rec.local_bus_iden_type := p3_a59;
    ddp_organization_rec.local_bus_identifier := p3_a60;
    ddp_organization_rec.pref_functional_currency := p3_a61;
    ddp_organization_rec.registration_type := p3_a62;
    ddp_organization_rec.total_employees_text := p3_a63;
    ddp_organization_rec.total_employees_ind := p3_a64;
    ddp_organization_rec.total_emp_est_ind := p3_a65;
    ddp_organization_rec.total_emp_min_ind := p3_a66;
    ddp_organization_rec.parent_sub_ind := p3_a67;
    ddp_organization_rec.incorp_year := p3_a68;
    ddp_organization_rec.sic_code_type := p3_a69;
    ddp_organization_rec.public_private_ownership_flag := p3_a70;
    ddp_organization_rec.internal_flag := p3_a71;
    ddp_organization_rec.local_activity_code_type := p3_a72;
    ddp_organization_rec.local_activity_code := p3_a73;
    ddp_organization_rec.emp_at_primary_adr := p3_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p3_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p3_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p3_a77;
    ddp_organization_rec.high_credit := p3_a78;
    ddp_organization_rec.avg_high_credit := p3_a79;
    ddp_organization_rec.total_payments := p3_a80;
    ddp_organization_rec.credit_score_class := p3_a81;
    ddp_organization_rec.credit_score_natl_percentile := p3_a82;
    ddp_organization_rec.credit_score_incd_default := p3_a83;
    ddp_organization_rec.credit_score_age := p3_a84;
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p3_a85);
    ddp_organization_rec.credit_score_commentary2 := p3_a86;
    ddp_organization_rec.credit_score_commentary3 := p3_a87;
    ddp_organization_rec.credit_score_commentary4 := p3_a88;
    ddp_organization_rec.credit_score_commentary5 := p3_a89;
    ddp_organization_rec.credit_score_commentary6 := p3_a90;
    ddp_organization_rec.credit_score_commentary7 := p3_a91;
    ddp_organization_rec.credit_score_commentary8 := p3_a92;
    ddp_organization_rec.credit_score_commentary9 := p3_a93;
    ddp_organization_rec.credit_score_commentary10 := p3_a94;
    ddp_organization_rec.failure_score_class := p3_a95;
    ddp_organization_rec.failure_score_incd_default := p3_a96;
    ddp_organization_rec.failure_score_age := p3_a97;
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p3_a98);
    ddp_organization_rec.failure_score_commentary2 := p3_a99;
    ddp_organization_rec.failure_score_commentary3 := p3_a100;
    ddp_organization_rec.failure_score_commentary4 := p3_a101;
    ddp_organization_rec.failure_score_commentary5 := p3_a102;
    ddp_organization_rec.failure_score_commentary6 := p3_a103;
    ddp_organization_rec.failure_score_commentary7 := p3_a104;
    ddp_organization_rec.failure_score_commentary8 := p3_a105;
    ddp_organization_rec.failure_score_commentary9 := p3_a106;
    ddp_organization_rec.failure_score_commentary10 := p3_a107;
    ddp_organization_rec.maximum_credit_recommendation := p3_a108;
    ddp_organization_rec.maximum_credit_currency_code := p3_a109;
    ddp_organization_rec.displayed_duns_party_id := p3_a110;
    ddp_organization_rec.content_source_type := p3_a111;
    ddp_organization_rec.content_source_number := p3_a112;
    ddp_organization_rec.attribute_category := p3_a113;
    ddp_organization_rec.attribute1 := p3_a114;
    ddp_organization_rec.attribute2 := p3_a115;
    ddp_organization_rec.attribute3 := p3_a116;
    ddp_organization_rec.attribute4 := p3_a117;
    ddp_organization_rec.attribute5 := p3_a118;
    ddp_organization_rec.attribute6 := p3_a119;
    ddp_organization_rec.attribute7 := p3_a120;
    ddp_organization_rec.attribute8 := p3_a121;
    ddp_organization_rec.attribute9 := p3_a122;
    ddp_organization_rec.attribute10 := p3_a123;
    ddp_organization_rec.attribute11 := p3_a124;
    ddp_organization_rec.attribute12 := p3_a125;
    ddp_organization_rec.attribute13 := p3_a126;
    ddp_organization_rec.attribute14 := p3_a127;
    ddp_organization_rec.attribute15 := p3_a128;
    ddp_organization_rec.attribute16 := p3_a129;
    ddp_organization_rec.attribute17 := p3_a130;
    ddp_organization_rec.attribute18 := p3_a131;
    ddp_organization_rec.attribute19 := p3_a132;
    ddp_organization_rec.attribute20 := p3_a133;
    ddp_organization_rec.created_by_module := p3_a134;
    ddp_organization_rec.application_id := p3_a135;
    ddp_organization_rec.do_not_confuse_with := p3_a136;
    ddp_organization_rec.actual_content_source := p3_a137;
    ddp_organization_rec.party_rec.party_id := p3_a138;
    ddp_organization_rec.party_rec.party_number := p3_a139;
    ddp_organization_rec.party_rec.validated_flag := p3_a140;
    ddp_organization_rec.party_rec.orig_system_reference := p3_a141;
    ddp_organization_rec.party_rec.status := p3_a142;
    ddp_organization_rec.party_rec.category_code := p3_a143;
    ddp_organization_rec.party_rec.salutation := p3_a144;
    ddp_organization_rec.party_rec.attribute_category := p3_a145;
    ddp_organization_rec.party_rec.attribute1 := p3_a146;
    ddp_organization_rec.party_rec.attribute2 := p3_a147;
    ddp_organization_rec.party_rec.attribute3 := p3_a148;
    ddp_organization_rec.party_rec.attribute4 := p3_a149;
    ddp_organization_rec.party_rec.attribute5 := p3_a150;
    ddp_organization_rec.party_rec.attribute6 := p3_a151;
    ddp_organization_rec.party_rec.attribute7 := p3_a152;
    ddp_organization_rec.party_rec.attribute8 := p3_a153;
    ddp_organization_rec.party_rec.attribute9 := p3_a154;
    ddp_organization_rec.party_rec.attribute10 := p3_a155;
    ddp_organization_rec.party_rec.attribute11 := p3_a156;
    ddp_organization_rec.party_rec.attribute12 := p3_a157;
    ddp_organization_rec.party_rec.attribute13 := p3_a158;
    ddp_organization_rec.party_rec.attribute14 := p3_a159;
    ddp_organization_rec.party_rec.attribute15 := p3_a160;
    ddp_organization_rec.party_rec.attribute16 := p3_a161;
    ddp_organization_rec.party_rec.attribute17 := p3_a162;
    ddp_organization_rec.party_rec.attribute18 := p3_a163;
    ddp_organization_rec.party_rec.attribute19 := p3_a164;
    ddp_organization_rec.party_rec.attribute20 := p3_a165;
    ddp_organization_rec.party_rec.attribute21 := p3_a166;
    ddp_organization_rec.party_rec.attribute22 := p3_a167;
    ddp_organization_rec.party_rec.attribute23 := p3_a168;
    ddp_organization_rec.party_rec.attribute24 := p3_a169;

    ddp_location_rec.location_id := p4_a0;
    ddp_location_rec.orig_system_reference := p4_a1;
    ddp_location_rec.country := p4_a2;
    ddp_location_rec.address1 := p4_a3;
    ddp_location_rec.address2 := p4_a4;
    ddp_location_rec.address3 := p4_a5;
    ddp_location_rec.address4 := p4_a6;
    ddp_location_rec.city := p4_a7;
    ddp_location_rec.postal_code := p4_a8;
    ddp_location_rec.state := p4_a9;
    ddp_location_rec.province := p4_a10;
    ddp_location_rec.county := p4_a11;
    ddp_location_rec.address_key := p4_a12;
    ddp_location_rec.address_style := p4_a13;
    ddp_location_rec.validated_flag := p4_a14;
    ddp_location_rec.address_lines_phonetic := p4_a15;
    ddp_location_rec.po_box_number := p4_a16;
    ddp_location_rec.house_number := p4_a17;
    ddp_location_rec.street_suffix := p4_a18;
    ddp_location_rec.street := p4_a19;
    ddp_location_rec.street_number := p4_a20;
    ddp_location_rec.floor := p4_a21;
    ddp_location_rec.suite := p4_a22;
    ddp_location_rec.postal_plus4_code := p4_a23;
    ddp_location_rec.position := p4_a24;
    ddp_location_rec.location_directions := p4_a25;
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p4_a26);
    ddp_location_rec.clli_code := p4_a27;
    ddp_location_rec.language := p4_a28;
    ddp_location_rec.short_description := p4_a29;
    ddp_location_rec.description := p4_a30;
    ddp_location_rec.loc_hierarchy_id := p4_a31;
    ddp_location_rec.sales_tax_geocode := p4_a32;
    ddp_location_rec.sales_tax_inside_city_limits := p4_a33;
    ddp_location_rec.fa_location_id := p4_a34;
    ddp_location_rec.content_source_type := p4_a35;
    ddp_location_rec.attribute_category := p4_a36;
    ddp_location_rec.attribute1 := p4_a37;
    ddp_location_rec.attribute2 := p4_a38;
    ddp_location_rec.attribute3 := p4_a39;
    ddp_location_rec.attribute4 := p4_a40;
    ddp_location_rec.attribute5 := p4_a41;
    ddp_location_rec.attribute6 := p4_a42;
    ddp_location_rec.attribute7 := p4_a43;
    ddp_location_rec.attribute8 := p4_a44;
    ddp_location_rec.attribute9 := p4_a45;
    ddp_location_rec.attribute10 := p4_a46;
    ddp_location_rec.attribute11 := p4_a47;
    ddp_location_rec.attribute12 := p4_a48;
    ddp_location_rec.attribute13 := p4_a49;
    ddp_location_rec.attribute14 := p4_a50;
    ddp_location_rec.attribute15 := p4_a51;
    ddp_location_rec.attribute16 := p4_a52;
    ddp_location_rec.attribute17 := p4_a53;
    ddp_location_rec.attribute18 := p4_a54;
    ddp_location_rec.attribute19 := p4_a55;
    ddp_location_rec.attribute20 := p4_a56;
    ddp_location_rec.timezone_id := p4_a57;
    ddp_location_rec.created_by_module := p4_a58;
    ddp_location_rec.application_id := p4_a59;
    ddp_location_rec.actual_content_source := p4_a60;

    ddp_org_phone_rec.phone_calling_calendar := p5_a0;
    ddp_org_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p5_a1);
    ddp_org_phone_rec.timezone_id := p5_a2;
    ddp_org_phone_rec.phone_area_code := p5_a3;
    ddp_org_phone_rec.phone_country_code := p5_a4;
    ddp_org_phone_rec.phone_number := p5_a5;
    ddp_org_phone_rec.phone_extension := p5_a6;
    ddp_org_phone_rec.phone_line_type := p5_a7;
    ddp_org_phone_rec.raw_phone_number := p5_a8;

    ddp_org_fax_rec.phone_calling_calendar := p6_a0;
    ddp_org_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p6_a1);
    ddp_org_fax_rec.timezone_id := p6_a2;
    ddp_org_fax_rec.phone_area_code := p6_a3;
    ddp_org_fax_rec.phone_country_code := p6_a4;
    ddp_org_fax_rec.phone_number := p6_a5;
    ddp_org_fax_rec.phone_extension := p6_a6;
    ddp_org_fax_rec.phone_line_type := p6_a7;
    ddp_org_fax_rec.raw_phone_number := p6_a8;

    ddp_rel_workphone_rec.phone_calling_calendar := p7_a0;
    ddp_rel_workphone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p7_a1);
    ddp_rel_workphone_rec.timezone_id := p7_a2;
    ddp_rel_workphone_rec.phone_area_code := p7_a3;
    ddp_rel_workphone_rec.phone_country_code := p7_a4;
    ddp_rel_workphone_rec.phone_number := p7_a5;
    ddp_rel_workphone_rec.phone_extension := p7_a6;
    ddp_rel_workphone_rec.phone_line_type := p7_a7;
    ddp_rel_workphone_rec.raw_phone_number := p7_a8;

    ddp_rel_homephone_rec.phone_calling_calendar := p8_a0;
    ddp_rel_homephone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p8_a1);
    ddp_rel_homephone_rec.timezone_id := p8_a2;
    ddp_rel_homephone_rec.phone_area_code := p8_a3;
    ddp_rel_homephone_rec.phone_country_code := p8_a4;
    ddp_rel_homephone_rec.phone_number := p8_a5;
    ddp_rel_homephone_rec.phone_extension := p8_a6;
    ddp_rel_homephone_rec.phone_line_type := p8_a7;
    ddp_rel_homephone_rec.raw_phone_number := p8_a8;

    ddp_rel_fax_rec.phone_calling_calendar := p9_a0;
    ddp_rel_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p9_a1);
    ddp_rel_fax_rec.timezone_id := p9_a2;
    ddp_rel_fax_rec.phone_area_code := p9_a3;
    ddp_rel_fax_rec.phone_country_code := p9_a4;
    ddp_rel_fax_rec.phone_number := p9_a5;
    ddp_rel_fax_rec.phone_extension := p9_a6;
    ddp_rel_fax_rec.phone_line_type := p9_a7;
    ddp_rel_fax_rec.raw_phone_number := p9_a8;

    ddp_rel_email_rec.email_format := p10_a0;
    ddp_rel_email_rec.email_address := p10_a1;









    -- here's the delegated call to the old PL/SQL routine
    ibe_party_v2pvt.create_business_user(p_username,
      p_password,
      ddp_person_rec,
      ddp_organization_rec,
      ddp_location_rec,
      ddp_org_phone_rec,
      ddp_org_fax_rec,
      ddp_rel_workphone_rec,
      ddp_rel_homephone_rec,
      ddp_rel_fax_rec,
      ddp_rel_email_rec,
      p_rel_contact_preference,
      x_person_party_id,
      x_rel_party_id,
      x_org_party_id,
      x_user_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















  end;

  procedure create_org_contact(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
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
    , p0_a21  VARCHAR2
    , p0_a22  DATE
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  DATE
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p_relationship_type  VARCHAR2
    , p_org_party_id  NUMBER
    , p3_a0  VARCHAR2
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  VARCHAR2
    , p_created_by_module  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddp_work_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_home_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_person_rec.person_pre_name_adjunct := p0_a0;
    ddp_person_rec.person_first_name := p0_a1;
    ddp_person_rec.person_middle_name := p0_a2;
    ddp_person_rec.person_last_name := p0_a3;
    ddp_person_rec.person_name_suffix := p0_a4;
    ddp_person_rec.person_title := p0_a5;
    ddp_person_rec.person_academic_title := p0_a6;
    ddp_person_rec.person_previous_last_name := p0_a7;
    ddp_person_rec.person_initials := p0_a8;
    ddp_person_rec.known_as := p0_a9;
    ddp_person_rec.known_as2 := p0_a10;
    ddp_person_rec.known_as3 := p0_a11;
    ddp_person_rec.known_as4 := p0_a12;
    ddp_person_rec.known_as5 := p0_a13;
    ddp_person_rec.person_name_phonetic := p0_a14;
    ddp_person_rec.person_first_name_phonetic := p0_a15;
    ddp_person_rec.person_last_name_phonetic := p0_a16;
    ddp_person_rec.middle_name_phonetic := p0_a17;
    ddp_person_rec.tax_reference := p0_a18;
    ddp_person_rec.jgzz_fiscal_code := p0_a19;
    ddp_person_rec.person_iden_type := p0_a20;
    ddp_person_rec.person_identifier := p0_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p0_a22);
    ddp_person_rec.place_of_birth := p0_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p0_a24);
    ddp_person_rec.gender := p0_a25;
    ddp_person_rec.declared_ethnicity := p0_a26;
    ddp_person_rec.marital_status := p0_a27;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_person_rec.personal_income := p0_a29;
    ddp_person_rec.head_of_household_flag := p0_a30;
    ddp_person_rec.household_income := p0_a31;
    ddp_person_rec.household_size := p0_a32;
    ddp_person_rec.rent_own_ind := p0_a33;
    ddp_person_rec.last_known_gps := p0_a34;
    ddp_person_rec.content_source_type := p0_a35;
    ddp_person_rec.internal_flag := p0_a36;
    ddp_person_rec.attribute_category := p0_a37;
    ddp_person_rec.attribute1 := p0_a38;
    ddp_person_rec.attribute2 := p0_a39;
    ddp_person_rec.attribute3 := p0_a40;
    ddp_person_rec.attribute4 := p0_a41;
    ddp_person_rec.attribute5 := p0_a42;
    ddp_person_rec.attribute6 := p0_a43;
    ddp_person_rec.attribute7 := p0_a44;
    ddp_person_rec.attribute8 := p0_a45;
    ddp_person_rec.attribute9 := p0_a46;
    ddp_person_rec.attribute10 := p0_a47;
    ddp_person_rec.attribute11 := p0_a48;
    ddp_person_rec.attribute12 := p0_a49;
    ddp_person_rec.attribute13 := p0_a50;
    ddp_person_rec.attribute14 := p0_a51;
    ddp_person_rec.attribute15 := p0_a52;
    ddp_person_rec.attribute16 := p0_a53;
    ddp_person_rec.attribute17 := p0_a54;
    ddp_person_rec.attribute18 := p0_a55;
    ddp_person_rec.attribute19 := p0_a56;
    ddp_person_rec.attribute20 := p0_a57;
    ddp_person_rec.created_by_module := p0_a58;
    ddp_person_rec.application_id := p0_a59;
    ddp_person_rec.actual_content_source := p0_a60;
    ddp_person_rec.party_rec.party_id := p0_a61;
    ddp_person_rec.party_rec.party_number := p0_a62;
    ddp_person_rec.party_rec.validated_flag := p0_a63;
    ddp_person_rec.party_rec.orig_system_reference := p0_a64;
    ddp_person_rec.party_rec.status := p0_a65;
    ddp_person_rec.party_rec.category_code := p0_a66;
    ddp_person_rec.party_rec.salutation := p0_a67;
    ddp_person_rec.party_rec.attribute_category := p0_a68;
    ddp_person_rec.party_rec.attribute1 := p0_a69;
    ddp_person_rec.party_rec.attribute2 := p0_a70;
    ddp_person_rec.party_rec.attribute3 := p0_a71;
    ddp_person_rec.party_rec.attribute4 := p0_a72;
    ddp_person_rec.party_rec.attribute5 := p0_a73;
    ddp_person_rec.party_rec.attribute6 := p0_a74;
    ddp_person_rec.party_rec.attribute7 := p0_a75;
    ddp_person_rec.party_rec.attribute8 := p0_a76;
    ddp_person_rec.party_rec.attribute9 := p0_a77;
    ddp_person_rec.party_rec.attribute10 := p0_a78;
    ddp_person_rec.party_rec.attribute11 := p0_a79;
    ddp_person_rec.party_rec.attribute12 := p0_a80;
    ddp_person_rec.party_rec.attribute13 := p0_a81;
    ddp_person_rec.party_rec.attribute14 := p0_a82;
    ddp_person_rec.party_rec.attribute15 := p0_a83;
    ddp_person_rec.party_rec.attribute16 := p0_a84;
    ddp_person_rec.party_rec.attribute17 := p0_a85;
    ddp_person_rec.party_rec.attribute18 := p0_a86;
    ddp_person_rec.party_rec.attribute19 := p0_a87;
    ddp_person_rec.party_rec.attribute20 := p0_a88;
    ddp_person_rec.party_rec.attribute21 := p0_a89;
    ddp_person_rec.party_rec.attribute22 := p0_a90;
    ddp_person_rec.party_rec.attribute23 := p0_a91;
    ddp_person_rec.party_rec.attribute24 := p0_a92;



    ddp_work_phone_rec.phone_calling_calendar := p3_a0;
    ddp_work_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p3_a1);
    ddp_work_phone_rec.timezone_id := p3_a2;
    ddp_work_phone_rec.phone_area_code := p3_a3;
    ddp_work_phone_rec.phone_country_code := p3_a4;
    ddp_work_phone_rec.phone_number := p3_a5;
    ddp_work_phone_rec.phone_extension := p3_a6;
    ddp_work_phone_rec.phone_line_type := p3_a7;
    ddp_work_phone_rec.raw_phone_number := p3_a8;

    ddp_home_phone_rec.phone_calling_calendar := p4_a0;
    ddp_home_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p4_a1);
    ddp_home_phone_rec.timezone_id := p4_a2;
    ddp_home_phone_rec.phone_area_code := p4_a3;
    ddp_home_phone_rec.phone_country_code := p4_a4;
    ddp_home_phone_rec.phone_number := p4_a5;
    ddp_home_phone_rec.phone_extension := p4_a6;
    ddp_home_phone_rec.phone_line_type := p4_a7;
    ddp_home_phone_rec.raw_phone_number := p4_a8;

    ddp_fax_rec.phone_calling_calendar := p5_a0;
    ddp_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p5_a1);
    ddp_fax_rec.timezone_id := p5_a2;
    ddp_fax_rec.phone_area_code := p5_a3;
    ddp_fax_rec.phone_country_code := p5_a4;
    ddp_fax_rec.phone_number := p5_a5;
    ddp_fax_rec.phone_extension := p5_a6;
    ddp_fax_rec.phone_line_type := p5_a7;
    ddp_fax_rec.raw_phone_number := p5_a8;

    ddp_email_rec.email_format := p6_a0;
    ddp_email_rec.email_address := p6_a1;







    -- here's the delegated call to the old PL/SQL routine
    ibe_party_v2pvt.create_org_contact(ddp_person_rec,
      p_relationship_type,
      p_org_party_id,
      ddp_work_phone_rec,
      ddp_home_phone_rec,
      ddp_fax_rec,
      ddp_email_rec,
      p_created_by_module,
      x_person_party_id,
      x_rel_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure create_person(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
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
    , p0_a21  VARCHAR2
    , p0_a22  DATE
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  DATE
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p1_a0  VARCHAR2
    , p1_a1  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p_created_by_module  VARCHAR2
    , p_account  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_account_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddp_work_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_home_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_person_rec.person_pre_name_adjunct := p0_a0;
    ddp_person_rec.person_first_name := p0_a1;
    ddp_person_rec.person_middle_name := p0_a2;
    ddp_person_rec.person_last_name := p0_a3;
    ddp_person_rec.person_name_suffix := p0_a4;
    ddp_person_rec.person_title := p0_a5;
    ddp_person_rec.person_academic_title := p0_a6;
    ddp_person_rec.person_previous_last_name := p0_a7;
    ddp_person_rec.person_initials := p0_a8;
    ddp_person_rec.known_as := p0_a9;
    ddp_person_rec.known_as2 := p0_a10;
    ddp_person_rec.known_as3 := p0_a11;
    ddp_person_rec.known_as4 := p0_a12;
    ddp_person_rec.known_as5 := p0_a13;
    ddp_person_rec.person_name_phonetic := p0_a14;
    ddp_person_rec.person_first_name_phonetic := p0_a15;
    ddp_person_rec.person_last_name_phonetic := p0_a16;
    ddp_person_rec.middle_name_phonetic := p0_a17;
    ddp_person_rec.tax_reference := p0_a18;
    ddp_person_rec.jgzz_fiscal_code := p0_a19;
    ddp_person_rec.person_iden_type := p0_a20;
    ddp_person_rec.person_identifier := p0_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p0_a22);
    ddp_person_rec.place_of_birth := p0_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p0_a24);
    ddp_person_rec.gender := p0_a25;
    ddp_person_rec.declared_ethnicity := p0_a26;
    ddp_person_rec.marital_status := p0_a27;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_person_rec.personal_income := p0_a29;
    ddp_person_rec.head_of_household_flag := p0_a30;
    ddp_person_rec.household_income := p0_a31;
    ddp_person_rec.household_size := p0_a32;
    ddp_person_rec.rent_own_ind := p0_a33;
    ddp_person_rec.last_known_gps := p0_a34;
    ddp_person_rec.content_source_type := p0_a35;
    ddp_person_rec.internal_flag := p0_a36;
    ddp_person_rec.attribute_category := p0_a37;
    ddp_person_rec.attribute1 := p0_a38;
    ddp_person_rec.attribute2 := p0_a39;
    ddp_person_rec.attribute3 := p0_a40;
    ddp_person_rec.attribute4 := p0_a41;
    ddp_person_rec.attribute5 := p0_a42;
    ddp_person_rec.attribute6 := p0_a43;
    ddp_person_rec.attribute7 := p0_a44;
    ddp_person_rec.attribute8 := p0_a45;
    ddp_person_rec.attribute9 := p0_a46;
    ddp_person_rec.attribute10 := p0_a47;
    ddp_person_rec.attribute11 := p0_a48;
    ddp_person_rec.attribute12 := p0_a49;
    ddp_person_rec.attribute13 := p0_a50;
    ddp_person_rec.attribute14 := p0_a51;
    ddp_person_rec.attribute15 := p0_a52;
    ddp_person_rec.attribute16 := p0_a53;
    ddp_person_rec.attribute17 := p0_a54;
    ddp_person_rec.attribute18 := p0_a55;
    ddp_person_rec.attribute19 := p0_a56;
    ddp_person_rec.attribute20 := p0_a57;
    ddp_person_rec.created_by_module := p0_a58;
    ddp_person_rec.application_id := p0_a59;
    ddp_person_rec.actual_content_source := p0_a60;
    ddp_person_rec.party_rec.party_id := p0_a61;
    ddp_person_rec.party_rec.party_number := p0_a62;
    ddp_person_rec.party_rec.validated_flag := p0_a63;
    ddp_person_rec.party_rec.orig_system_reference := p0_a64;
    ddp_person_rec.party_rec.status := p0_a65;
    ddp_person_rec.party_rec.category_code := p0_a66;
    ddp_person_rec.party_rec.salutation := p0_a67;
    ddp_person_rec.party_rec.attribute_category := p0_a68;
    ddp_person_rec.party_rec.attribute1 := p0_a69;
    ddp_person_rec.party_rec.attribute2 := p0_a70;
    ddp_person_rec.party_rec.attribute3 := p0_a71;
    ddp_person_rec.party_rec.attribute4 := p0_a72;
    ddp_person_rec.party_rec.attribute5 := p0_a73;
    ddp_person_rec.party_rec.attribute6 := p0_a74;
    ddp_person_rec.party_rec.attribute7 := p0_a75;
    ddp_person_rec.party_rec.attribute8 := p0_a76;
    ddp_person_rec.party_rec.attribute9 := p0_a77;
    ddp_person_rec.party_rec.attribute10 := p0_a78;
    ddp_person_rec.party_rec.attribute11 := p0_a79;
    ddp_person_rec.party_rec.attribute12 := p0_a80;
    ddp_person_rec.party_rec.attribute13 := p0_a81;
    ddp_person_rec.party_rec.attribute14 := p0_a82;
    ddp_person_rec.party_rec.attribute15 := p0_a83;
    ddp_person_rec.party_rec.attribute16 := p0_a84;
    ddp_person_rec.party_rec.attribute17 := p0_a85;
    ddp_person_rec.party_rec.attribute18 := p0_a86;
    ddp_person_rec.party_rec.attribute19 := p0_a87;
    ddp_person_rec.party_rec.attribute20 := p0_a88;
    ddp_person_rec.party_rec.attribute21 := p0_a89;
    ddp_person_rec.party_rec.attribute22 := p0_a90;
    ddp_person_rec.party_rec.attribute23 := p0_a91;
    ddp_person_rec.party_rec.attribute24 := p0_a92;

    ddp_email_rec.email_format := p1_a0;
    ddp_email_rec.email_address := p1_a1;

    ddp_work_phone_rec.phone_calling_calendar := p2_a0;
    ddp_work_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_work_phone_rec.timezone_id := p2_a2;
    ddp_work_phone_rec.phone_area_code := p2_a3;
    ddp_work_phone_rec.phone_country_code := p2_a4;
    ddp_work_phone_rec.phone_number := p2_a5;
    ddp_work_phone_rec.phone_extension := p2_a6;
    ddp_work_phone_rec.phone_line_type := p2_a7;
    ddp_work_phone_rec.raw_phone_number := p2_a8;

    ddp_home_phone_rec.phone_calling_calendar := p3_a0;
    ddp_home_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p3_a1);
    ddp_home_phone_rec.timezone_id := p3_a2;
    ddp_home_phone_rec.phone_area_code := p3_a3;
    ddp_home_phone_rec.phone_country_code := p3_a4;
    ddp_home_phone_rec.phone_number := p3_a5;
    ddp_home_phone_rec.phone_extension := p3_a6;
    ddp_home_phone_rec.phone_line_type := p3_a7;
    ddp_home_phone_rec.raw_phone_number := p3_a8;

    ddp_fax_rec.phone_calling_calendar := p4_a0;
    ddp_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p4_a1);
    ddp_fax_rec.timezone_id := p4_a2;
    ddp_fax_rec.phone_area_code := p4_a3;
    ddp_fax_rec.phone_country_code := p4_a4;
    ddp_fax_rec.phone_number := p4_a5;
    ddp_fax_rec.phone_extension := p4_a6;
    ddp_fax_rec.phone_line_type := p4_a7;
    ddp_fax_rec.raw_phone_number := p4_a8;








    -- here's the delegated call to the old PL/SQL routine
    ibe_party_v2pvt.create_person(ddp_person_rec,
      ddp_email_rec,
      ddp_work_phone_rec,
      ddp_home_phone_rec,
      ddp_fax_rec,
      p_created_by_module,
      p_account,
      x_person_party_id,
      x_account_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure create_organization(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  NUMBER
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
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  DATE
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  NUMBER
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  NUMBER
    , p0_a79  NUMBER
    , p0_a80  NUMBER
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  DATE
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  DATE
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  VARCHAR2
    , p0_a106  VARCHAR2
    , p0_a107  VARCHAR2
    , p0_a108  NUMBER
    , p0_a109  VARCHAR2
    , p0_a110  NUMBER
    , p0_a111  VARCHAR2
    , p0_a112  VARCHAR2
    , p0_a113  VARCHAR2
    , p0_a114  VARCHAR2
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  VARCHAR2
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  VARCHAR2
    , p0_a126  VARCHAR2
    , p0_a127  VARCHAR2
    , p0_a128  VARCHAR2
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  NUMBER
    , p0_a136  VARCHAR2
    , p0_a137  VARCHAR2
    , p0_a138  NUMBER
    , p0_a139  VARCHAR2
    , p0_a140  VARCHAR2
    , p0_a141  VARCHAR2
    , p0_a142  VARCHAR2
    , p0_a143  VARCHAR2
    , p0_a144  VARCHAR2
    , p0_a145  VARCHAR2
    , p0_a146  VARCHAR2
    , p0_a147  VARCHAR2
    , p0_a148  VARCHAR2
    , p0_a149  VARCHAR2
    , p0_a150  VARCHAR2
    , p0_a151  VARCHAR2
    , p0_a152  VARCHAR2
    , p0_a153  VARCHAR2
    , p0_a154  VARCHAR2
    , p0_a155  VARCHAR2
    , p0_a156  VARCHAR2
    , p0_a157  VARCHAR2
    , p0_a158  VARCHAR2
    , p0_a159  VARCHAR2
    , p0_a160  VARCHAR2
    , p0_a161  VARCHAR2
    , p0_a162  VARCHAR2
    , p0_a163  VARCHAR2
    , p0_a164  VARCHAR2
    , p0_a165  VARCHAR2
    , p0_a166  VARCHAR2
    , p0_a167  VARCHAR2
    , p0_a168  VARCHAR2
    , p0_a169  VARCHAR2
    , p1_a0  VARCHAR2
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
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
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  DATE
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  NUMBER
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  NUMBER
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  NUMBER
    , p3_a58  VARCHAR2
    , p3_a59  NUMBER
    , p3_a60  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
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
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  NUMBER
    , p_primary_billto  VARCHAR2
    , p_primary_shipto  VARCHAR2
    , p_billto  VARCHAR2
    , p_shipto  VARCHAR2
    , p_default_primary  VARCHAR2
    , p_created_by_module  VARCHAR2
    , p_account  VARCHAR2
    , x_org_party_id out nocopy  NUMBER
    , x_account_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_org_workphone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_org_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddp_party_site_rec hz_party_site_v2pub.party_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_organization_rec.organization_name := p0_a0;
    ddp_organization_rec.duns_number_c := p0_a1;
    ddp_organization_rec.enquiry_duns := p0_a2;
    ddp_organization_rec.ceo_name := p0_a3;
    ddp_organization_rec.ceo_title := p0_a4;
    ddp_organization_rec.principal_name := p0_a5;
    ddp_organization_rec.principal_title := p0_a6;
    ddp_organization_rec.legal_status := p0_a7;
    ddp_organization_rec.control_yr := p0_a8;
    ddp_organization_rec.employees_total := p0_a9;
    ddp_organization_rec.hq_branch_ind := p0_a10;
    ddp_organization_rec.branch_flag := p0_a11;
    ddp_organization_rec.oob_ind := p0_a12;
    ddp_organization_rec.line_of_business := p0_a13;
    ddp_organization_rec.cong_dist_code := p0_a14;
    ddp_organization_rec.sic_code := p0_a15;
    ddp_organization_rec.import_ind := p0_a16;
    ddp_organization_rec.export_ind := p0_a17;
    ddp_organization_rec.labor_surplus_ind := p0_a18;
    ddp_organization_rec.debarment_ind := p0_a19;
    ddp_organization_rec.minority_owned_ind := p0_a20;
    ddp_organization_rec.minority_owned_type := p0_a21;
    ddp_organization_rec.woman_owned_ind := p0_a22;
    ddp_organization_rec.disadv_8a_ind := p0_a23;
    ddp_organization_rec.small_bus_ind := p0_a24;
    ddp_organization_rec.rent_own_ind := p0_a25;
    ddp_organization_rec.debarments_count := p0_a26;
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p0_a27);
    ddp_organization_rec.failure_score := p0_a28;
    ddp_organization_rec.failure_score_natnl_percentile := p0_a29;
    ddp_organization_rec.failure_score_override_code := p0_a30;
    ddp_organization_rec.failure_score_commentary := p0_a31;
    ddp_organization_rec.global_failure_score := p0_a32;
    ddp_organization_rec.db_rating := p0_a33;
    ddp_organization_rec.credit_score := p0_a34;
    ddp_organization_rec.credit_score_commentary := p0_a35;
    ddp_organization_rec.paydex_score := p0_a36;
    ddp_organization_rec.paydex_three_months_ago := p0_a37;
    ddp_organization_rec.paydex_norm := p0_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p0_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p0_a40);
    ddp_organization_rec.organization_name_phonetic := p0_a41;
    ddp_organization_rec.tax_reference := p0_a42;
    ddp_organization_rec.gsa_indicator_flag := p0_a43;
    ddp_organization_rec.jgzz_fiscal_code := p0_a44;
    ddp_organization_rec.analysis_fy := p0_a45;
    ddp_organization_rec.fiscal_yearend_month := p0_a46;
    ddp_organization_rec.curr_fy_potential_revenue := p0_a47;
    ddp_organization_rec.next_fy_potential_revenue := p0_a48;
    ddp_organization_rec.year_established := p0_a49;
    ddp_organization_rec.mission_statement := p0_a50;
    ddp_organization_rec.organization_type := p0_a51;
    ddp_organization_rec.business_scope := p0_a52;
    ddp_organization_rec.corporation_class := p0_a53;
    ddp_organization_rec.known_as := p0_a54;
    ddp_organization_rec.known_as2 := p0_a55;
    ddp_organization_rec.known_as3 := p0_a56;
    ddp_organization_rec.known_as4 := p0_a57;
    ddp_organization_rec.known_as5 := p0_a58;
    ddp_organization_rec.local_bus_iden_type := p0_a59;
    ddp_organization_rec.local_bus_identifier := p0_a60;
    ddp_organization_rec.pref_functional_currency := p0_a61;
    ddp_organization_rec.registration_type := p0_a62;
    ddp_organization_rec.total_employees_text := p0_a63;
    ddp_organization_rec.total_employees_ind := p0_a64;
    ddp_organization_rec.total_emp_est_ind := p0_a65;
    ddp_organization_rec.total_emp_min_ind := p0_a66;
    ddp_organization_rec.parent_sub_ind := p0_a67;
    ddp_organization_rec.incorp_year := p0_a68;
    ddp_organization_rec.sic_code_type := p0_a69;
    ddp_organization_rec.public_private_ownership_flag := p0_a70;
    ddp_organization_rec.internal_flag := p0_a71;
    ddp_organization_rec.local_activity_code_type := p0_a72;
    ddp_organization_rec.local_activity_code := p0_a73;
    ddp_organization_rec.emp_at_primary_adr := p0_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p0_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p0_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p0_a77;
    ddp_organization_rec.high_credit := p0_a78;
    ddp_organization_rec.avg_high_credit := p0_a79;
    ddp_organization_rec.total_payments := p0_a80;
    ddp_organization_rec.credit_score_class := p0_a81;
    ddp_organization_rec.credit_score_natl_percentile := p0_a82;
    ddp_organization_rec.credit_score_incd_default := p0_a83;
    ddp_organization_rec.credit_score_age := p0_a84;
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p0_a85);
    ddp_organization_rec.credit_score_commentary2 := p0_a86;
    ddp_organization_rec.credit_score_commentary3 := p0_a87;
    ddp_organization_rec.credit_score_commentary4 := p0_a88;
    ddp_organization_rec.credit_score_commentary5 := p0_a89;
    ddp_organization_rec.credit_score_commentary6 := p0_a90;
    ddp_organization_rec.credit_score_commentary7 := p0_a91;
    ddp_organization_rec.credit_score_commentary8 := p0_a92;
    ddp_organization_rec.credit_score_commentary9 := p0_a93;
    ddp_organization_rec.credit_score_commentary10 := p0_a94;
    ddp_organization_rec.failure_score_class := p0_a95;
    ddp_organization_rec.failure_score_incd_default := p0_a96;
    ddp_organization_rec.failure_score_age := p0_a97;
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p0_a98);
    ddp_organization_rec.failure_score_commentary2 := p0_a99;
    ddp_organization_rec.failure_score_commentary3 := p0_a100;
    ddp_organization_rec.failure_score_commentary4 := p0_a101;
    ddp_organization_rec.failure_score_commentary5 := p0_a102;
    ddp_organization_rec.failure_score_commentary6 := p0_a103;
    ddp_organization_rec.failure_score_commentary7 := p0_a104;
    ddp_organization_rec.failure_score_commentary8 := p0_a105;
    ddp_organization_rec.failure_score_commentary9 := p0_a106;
    ddp_organization_rec.failure_score_commentary10 := p0_a107;
    ddp_organization_rec.maximum_credit_recommendation := p0_a108;
    ddp_organization_rec.maximum_credit_currency_code := p0_a109;
    ddp_organization_rec.displayed_duns_party_id := p0_a110;
    ddp_organization_rec.content_source_type := p0_a111;
    ddp_organization_rec.content_source_number := p0_a112;
    ddp_organization_rec.attribute_category := p0_a113;
    ddp_organization_rec.attribute1 := p0_a114;
    ddp_organization_rec.attribute2 := p0_a115;
    ddp_organization_rec.attribute3 := p0_a116;
    ddp_organization_rec.attribute4 := p0_a117;
    ddp_organization_rec.attribute5 := p0_a118;
    ddp_organization_rec.attribute6 := p0_a119;
    ddp_organization_rec.attribute7 := p0_a120;
    ddp_organization_rec.attribute8 := p0_a121;
    ddp_organization_rec.attribute9 := p0_a122;
    ddp_organization_rec.attribute10 := p0_a123;
    ddp_organization_rec.attribute11 := p0_a124;
    ddp_organization_rec.attribute12 := p0_a125;
    ddp_organization_rec.attribute13 := p0_a126;
    ddp_organization_rec.attribute14 := p0_a127;
    ddp_organization_rec.attribute15 := p0_a128;
    ddp_organization_rec.attribute16 := p0_a129;
    ddp_organization_rec.attribute17 := p0_a130;
    ddp_organization_rec.attribute18 := p0_a131;
    ddp_organization_rec.attribute19 := p0_a132;
    ddp_organization_rec.attribute20 := p0_a133;
    ddp_organization_rec.created_by_module := p0_a134;
    ddp_organization_rec.application_id := p0_a135;
    ddp_organization_rec.do_not_confuse_with := p0_a136;
    ddp_organization_rec.actual_content_source := p0_a137;
    ddp_organization_rec.party_rec.party_id := p0_a138;
    ddp_organization_rec.party_rec.party_number := p0_a139;
    ddp_organization_rec.party_rec.validated_flag := p0_a140;
    ddp_organization_rec.party_rec.orig_system_reference := p0_a141;
    ddp_organization_rec.party_rec.status := p0_a142;
    ddp_organization_rec.party_rec.category_code := p0_a143;
    ddp_organization_rec.party_rec.salutation := p0_a144;
    ddp_organization_rec.party_rec.attribute_category := p0_a145;
    ddp_organization_rec.party_rec.attribute1 := p0_a146;
    ddp_organization_rec.party_rec.attribute2 := p0_a147;
    ddp_organization_rec.party_rec.attribute3 := p0_a148;
    ddp_organization_rec.party_rec.attribute4 := p0_a149;
    ddp_organization_rec.party_rec.attribute5 := p0_a150;
    ddp_organization_rec.party_rec.attribute6 := p0_a151;
    ddp_organization_rec.party_rec.attribute7 := p0_a152;
    ddp_organization_rec.party_rec.attribute8 := p0_a153;
    ddp_organization_rec.party_rec.attribute9 := p0_a154;
    ddp_organization_rec.party_rec.attribute10 := p0_a155;
    ddp_organization_rec.party_rec.attribute11 := p0_a156;
    ddp_organization_rec.party_rec.attribute12 := p0_a157;
    ddp_organization_rec.party_rec.attribute13 := p0_a158;
    ddp_organization_rec.party_rec.attribute14 := p0_a159;
    ddp_organization_rec.party_rec.attribute15 := p0_a160;
    ddp_organization_rec.party_rec.attribute16 := p0_a161;
    ddp_organization_rec.party_rec.attribute17 := p0_a162;
    ddp_organization_rec.party_rec.attribute18 := p0_a163;
    ddp_organization_rec.party_rec.attribute19 := p0_a164;
    ddp_organization_rec.party_rec.attribute20 := p0_a165;
    ddp_organization_rec.party_rec.attribute21 := p0_a166;
    ddp_organization_rec.party_rec.attribute22 := p0_a167;
    ddp_organization_rec.party_rec.attribute23 := p0_a168;
    ddp_organization_rec.party_rec.attribute24 := p0_a169;

    ddp_org_workphone_rec.phone_calling_calendar := p1_a0;
    ddp_org_workphone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p1_a1);
    ddp_org_workphone_rec.timezone_id := p1_a2;
    ddp_org_workphone_rec.phone_area_code := p1_a3;
    ddp_org_workphone_rec.phone_country_code := p1_a4;
    ddp_org_workphone_rec.phone_number := p1_a5;
    ddp_org_workphone_rec.phone_extension := p1_a6;
    ddp_org_workphone_rec.phone_line_type := p1_a7;
    ddp_org_workphone_rec.raw_phone_number := p1_a8;

    ddp_org_fax_rec.phone_calling_calendar := p2_a0;
    ddp_org_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_org_fax_rec.timezone_id := p2_a2;
    ddp_org_fax_rec.phone_area_code := p2_a3;
    ddp_org_fax_rec.phone_country_code := p2_a4;
    ddp_org_fax_rec.phone_number := p2_a5;
    ddp_org_fax_rec.phone_extension := p2_a6;
    ddp_org_fax_rec.phone_line_type := p2_a7;
    ddp_org_fax_rec.raw_phone_number := p2_a8;

    ddp_location_rec.location_id := p3_a0;
    ddp_location_rec.orig_system_reference := p3_a1;
    ddp_location_rec.country := p3_a2;
    ddp_location_rec.address1 := p3_a3;
    ddp_location_rec.address2 := p3_a4;
    ddp_location_rec.address3 := p3_a5;
    ddp_location_rec.address4 := p3_a6;
    ddp_location_rec.city := p3_a7;
    ddp_location_rec.postal_code := p3_a8;
    ddp_location_rec.state := p3_a9;
    ddp_location_rec.province := p3_a10;
    ddp_location_rec.county := p3_a11;
    ddp_location_rec.address_key := p3_a12;
    ddp_location_rec.address_style := p3_a13;
    ddp_location_rec.validated_flag := p3_a14;
    ddp_location_rec.address_lines_phonetic := p3_a15;
    ddp_location_rec.po_box_number := p3_a16;
    ddp_location_rec.house_number := p3_a17;
    ddp_location_rec.street_suffix := p3_a18;
    ddp_location_rec.street := p3_a19;
    ddp_location_rec.street_number := p3_a20;
    ddp_location_rec.floor := p3_a21;
    ddp_location_rec.suite := p3_a22;
    ddp_location_rec.postal_plus4_code := p3_a23;
    ddp_location_rec.position := p3_a24;
    ddp_location_rec.location_directions := p3_a25;
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p3_a26);
    ddp_location_rec.clli_code := p3_a27;
    ddp_location_rec.language := p3_a28;
    ddp_location_rec.short_description := p3_a29;
    ddp_location_rec.description := p3_a30;
    ddp_location_rec.loc_hierarchy_id := p3_a31;
    ddp_location_rec.sales_tax_geocode := p3_a32;
    ddp_location_rec.sales_tax_inside_city_limits := p3_a33;
    ddp_location_rec.fa_location_id := p3_a34;
    ddp_location_rec.content_source_type := p3_a35;
    ddp_location_rec.attribute_category := p3_a36;
    ddp_location_rec.attribute1 := p3_a37;
    ddp_location_rec.attribute2 := p3_a38;
    ddp_location_rec.attribute3 := p3_a39;
    ddp_location_rec.attribute4 := p3_a40;
    ddp_location_rec.attribute5 := p3_a41;
    ddp_location_rec.attribute6 := p3_a42;
    ddp_location_rec.attribute7 := p3_a43;
    ddp_location_rec.attribute8 := p3_a44;
    ddp_location_rec.attribute9 := p3_a45;
    ddp_location_rec.attribute10 := p3_a46;
    ddp_location_rec.attribute11 := p3_a47;
    ddp_location_rec.attribute12 := p3_a48;
    ddp_location_rec.attribute13 := p3_a49;
    ddp_location_rec.attribute14 := p3_a50;
    ddp_location_rec.attribute15 := p3_a51;
    ddp_location_rec.attribute16 := p3_a52;
    ddp_location_rec.attribute17 := p3_a53;
    ddp_location_rec.attribute18 := p3_a54;
    ddp_location_rec.attribute19 := p3_a55;
    ddp_location_rec.attribute20 := p3_a56;
    ddp_location_rec.timezone_id := p3_a57;
    ddp_location_rec.created_by_module := p3_a58;
    ddp_location_rec.application_id := p3_a59;
    ddp_location_rec.actual_content_source := p3_a60;

    ddp_party_site_rec.party_site_id := p4_a0;
    ddp_party_site_rec.party_id := p4_a1;
    ddp_party_site_rec.location_id := p4_a2;
    ddp_party_site_rec.party_site_number := p4_a3;
    ddp_party_site_rec.orig_system_reference := p4_a4;
    ddp_party_site_rec.mailstop := p4_a5;
    ddp_party_site_rec.identifying_address_flag := p4_a6;
    ddp_party_site_rec.status := p4_a7;
    ddp_party_site_rec.party_site_name := p4_a8;
    ddp_party_site_rec.attribute_category := p4_a9;
    ddp_party_site_rec.attribute1 := p4_a10;
    ddp_party_site_rec.attribute2 := p4_a11;
    ddp_party_site_rec.attribute3 := p4_a12;
    ddp_party_site_rec.attribute4 := p4_a13;
    ddp_party_site_rec.attribute5 := p4_a14;
    ddp_party_site_rec.attribute6 := p4_a15;
    ddp_party_site_rec.attribute7 := p4_a16;
    ddp_party_site_rec.attribute8 := p4_a17;
    ddp_party_site_rec.attribute9 := p4_a18;
    ddp_party_site_rec.attribute10 := p4_a19;
    ddp_party_site_rec.attribute11 := p4_a20;
    ddp_party_site_rec.attribute12 := p4_a21;
    ddp_party_site_rec.attribute13 := p4_a22;
    ddp_party_site_rec.attribute14 := p4_a23;
    ddp_party_site_rec.attribute15 := p4_a24;
    ddp_party_site_rec.attribute16 := p4_a25;
    ddp_party_site_rec.attribute17 := p4_a26;
    ddp_party_site_rec.attribute18 := p4_a27;
    ddp_party_site_rec.attribute19 := p4_a28;
    ddp_party_site_rec.attribute20 := p4_a29;
    ddp_party_site_rec.language := p4_a30;
    ddp_party_site_rec.addressee := p4_a31;
    ddp_party_site_rec.created_by_module := p4_a32;
    ddp_party_site_rec.application_id := p4_a33;









    -- here's the delegated call to the old PL/SQL routine
    ibe_party_v2pvt.create_organization(ddp_organization_rec,
      ddp_org_workphone_rec,
      ddp_org_fax_rec,
      ddp_location_rec,
      ddp_party_site_rec,
      p_primary_billto,
      p_primary_shipto,
      p_billto,
      p_shipto,
      p_default_primary,
      p_created_by_module,
      p_account,
      x_org_party_id,
      x_account_id,
      x_party_site_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure create_contact_points(p_owner_table_id  NUMBER
    , p1_a0  VARCHAR2
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p_contact_point_purpose  number
    , p_created_by_module  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_work_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_home_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddp_contact_point_purpose boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_work_phone_rec.phone_calling_calendar := p1_a0;
    ddp_work_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p1_a1);
    ddp_work_phone_rec.timezone_id := p1_a2;
    ddp_work_phone_rec.phone_area_code := p1_a3;
    ddp_work_phone_rec.phone_country_code := p1_a4;
    ddp_work_phone_rec.phone_number := p1_a5;
    ddp_work_phone_rec.phone_extension := p1_a6;
    ddp_work_phone_rec.phone_line_type := p1_a7;
    ddp_work_phone_rec.raw_phone_number := p1_a8;

    ddp_home_phone_rec.phone_calling_calendar := p2_a0;
    ddp_home_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_home_phone_rec.timezone_id := p2_a2;
    ddp_home_phone_rec.phone_area_code := p2_a3;
    ddp_home_phone_rec.phone_country_code := p2_a4;
    ddp_home_phone_rec.phone_number := p2_a5;
    ddp_home_phone_rec.phone_extension := p2_a6;
    ddp_home_phone_rec.phone_line_type := p2_a7;
    ddp_home_phone_rec.raw_phone_number := p2_a8;

    ddp_fax_rec.phone_calling_calendar := p3_a0;
    ddp_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p3_a1);
    ddp_fax_rec.timezone_id := p3_a2;
    ddp_fax_rec.phone_area_code := p3_a3;
    ddp_fax_rec.phone_country_code := p3_a4;
    ddp_fax_rec.phone_number := p3_a5;
    ddp_fax_rec.phone_extension := p3_a6;
    ddp_fax_rec.phone_line_type := p3_a7;
    ddp_fax_rec.raw_phone_number := p3_a8;

    ddp_email_rec.email_format := p4_a0;
    ddp_email_rec.email_address := p4_a1;

    if p_contact_point_purpose is null
      then ddp_contact_point_purpose := null;
    elsif p_contact_point_purpose = 0
      then ddp_contact_point_purpose := false;
    else ddp_contact_point_purpose := true;
    end if;





    -- here's the delegated call to the old PL/SQL routine
    ibe_party_v2pvt.create_contact_points(p_owner_table_id,
      ddp_work_phone_rec,
      ddp_home_phone_rec,
      ddp_fax_rec,
      ddp_email_rec,
      ddp_contact_point_purpose,
      p_created_by_module,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure find_organization(x_org_id in out nocopy  NUMBER
    , x_org_num in out nocopy  VARCHAR2
    , x_org_name in out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ibe_party_v2pvt.find_organization(x_org_id,
      x_org_num,
      x_org_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;


  end;


procedure Save_Tca_Entities(p1_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a2  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a9  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a10  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a11  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a12  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a13  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a14  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a15  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a16  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a17  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a18  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a19  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a20  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a21  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a22  DATE := FND_API.G_MISS_DATE
    , p1_a23  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a24  DATE := FND_API.G_MISS_DATE
    , p1_a25  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a26  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a27  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a28  DATE := FND_API.G_MISS_DATE
    , p1_a29  NUMBER := FND_API.G_MISS_NUM
    , p1_a30  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a31  NUMBER := FND_API.G_MISS_NUM
    , p1_a32  NUMBER := FND_API.G_MISS_NUM
    , p1_a33  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a34  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a35  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a36  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a37  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a38  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a39  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a40  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a41  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a42  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a43  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a44  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a45  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a46  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a47  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a48  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a49  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a50  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a51  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a52  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a53  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a54  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a55  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a56  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a57  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a58  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a59  NUMBER := FND_API.G_MISS_NUM
    , p1_a60  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a61  NUMBER := FND_API.G_MISS_NUM
    , p1_a62  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a63  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a64  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a65  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a66  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a67  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a68  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a69  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a70  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a71  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a72  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a73  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a74  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a75  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a76  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a77  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a78  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a79  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a80  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a81  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a82  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a83  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a84  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a85  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a86  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a87  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a88  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a89  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a90  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a91  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a92  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_person_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_email_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p2_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p2_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_email_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_workph_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p3_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a1  DATE := FND_API.G_MISS_DATE
    , p3_a2  NUMBER := FND_API.G_MISS_NUM
    , p3_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_workph_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_homeph_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p4_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a1  DATE := FND_API.G_MISS_DATE
    , p4_a2  NUMBER := FND_API.G_MISS_NUM
    , p4_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_homeph_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_fax_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p5_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a1  DATE := FND_API.G_MISS_DATE
    , p5_a2  NUMBER := FND_API.G_MISS_NUM
    , p5_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_fax_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_contact_preference_id     NUMBER := FND_API.G_MISS_NUM
    , p_contact_preference        VARCHAR2 := FND_API.G_MISS_CHAR
    , p_cntct_pref_object_ver_num NUMBER := FND_API.G_MISS_NUM
    , p_cntct_level_table_id      NUMBER := FND_API.G_MISS_NUM
    , p_cntct_level_table_name    VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a2  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a8  NUMBER := FND_API.G_MISS_NUM
    , p6_a9  NUMBER := FND_API.G_MISS_NUM
    , p6_a10  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a11  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a12  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a13  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a14  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a15  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a16  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a17  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a18  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a19  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a20  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a21  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a22  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a23  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a24  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a25  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a26  NUMBER := FND_API.G_MISS_NUM
    , p6_a27  DATE := FND_API.G_MISS_DATE
    , p6_a28  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a29  NUMBER := FND_API.G_MISS_NUM
    , p6_a30  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a31  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a32  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a33  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a34  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a35  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a36  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a37  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a38  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a39  DATE := FND_API.G_MISS_DATE
    , p6_a40  DATE := FND_API.G_MISS_DATE
    , p6_a41  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a42  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a43  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a44  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a45  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a46  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a47  NUMBER := FND_API.G_MISS_NUM
    , p6_a48  NUMBER := FND_API.G_MISS_NUM
    , p6_a49  NUMBER := FND_API.G_MISS_NUM
    , p6_a50  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a51  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a52  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a53  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a54  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a55  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a56  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a57  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a58  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a59  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a60  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a61  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a62  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a63  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a64  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a65  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a66  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a67  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a68  NUMBER := FND_API.G_MISS_NUM
    , p6_a69  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a70  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a71  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a72  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a73  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a74  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a75  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a76  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a77  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a78  NUMBER := FND_API.G_MISS_NUM
    , p6_a79  NUMBER := FND_API.G_MISS_NUM
    , p6_a80  NUMBER := FND_API.G_MISS_NUM
    , p6_a81  NUMBER := FND_API.G_MISS_NUM
    , p6_a82  NUMBER := FND_API.G_MISS_NUM
    , p6_a83  NUMBER := FND_API.G_MISS_NUM
    , p6_a84  NUMBER := FND_API.G_MISS_NUM
    , p6_a85  DATE := FND_API.G_MISS_DATE
    , p6_a86  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a87  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a88  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a89  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a90  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a91  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a92  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a93  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a94  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a95  NUMBER := FND_API.G_MISS_NUM
    , p6_a96  NUMBER := FND_API.G_MISS_NUM
    , p6_a97  NUMBER := FND_API.G_MISS_NUM
    , p6_a98  DATE := FND_API.G_MISS_DATE
    , p6_a99  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a100  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a101  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a102  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a103  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a104  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a105  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a106  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a107  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a108  NUMBER := FND_API.G_MISS_NUM
    , p6_a109  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a110  NUMBER := FND_API.G_MISS_NUM
    , p6_a111  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a112  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a113  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a114  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a115  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a116  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a117  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a118  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a119  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a120  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a121  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a122  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a123  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a124  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a125  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a126  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a127  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a128  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a129  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a130  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a131  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a132  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a133  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a134  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a135  NUMBER := FND_API.G_MISS_NUM
    , p6_a136  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a137  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a138  NUMBER := FND_API.G_MISS_NUM
    , p6_a139  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a140  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a141  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a142  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a143  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a144  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a145  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a146  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a147  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a148  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a149  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a150  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a151  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a152  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a153  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a154  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a155  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a156  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a157  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a158  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a159  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a160  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a161  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a162  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a163  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a164  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a165  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a166  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a167  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a168  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a169  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_org_object_version_number   NUMBER := FND_API.G_MISS_NUM
    , p7_a0  NUMBER := FND_API.G_MISS_NUM
    , p7_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a2  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a9  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a10  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a11  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a12  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a13  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a14  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a15  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a16  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a17  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a18  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a19  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a20  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a21  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a22  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a23  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a24  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a25  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a26  DATE := FND_API.G_MISS_DATE
    , p7_a27  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a28  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a29  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a30  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a31  NUMBER := FND_API.G_MISS_NUM
    , p7_a32  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a33  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a34  NUMBER := FND_API.G_MISS_NUM
    , p7_a35  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a36  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a37  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a38  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a39  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a40  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a41  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a42  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a43  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a44  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a45  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a46  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a47  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a48  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a49  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a50  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a51  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a52  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a53  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a54  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a55  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a56  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a57  NUMBER := FND_API.G_MISS_NUM
    , p7_a58  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a59  NUMBER := FND_API.G_MISS_NUM
    , p7_a60  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_loc_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_orgph_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p8_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a1  DATE := FND_API.G_MISS_DATE
    , p8_a2  NUMBER := FND_API.G_MISS_NUM
    , p8_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_orgph_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_orgfax_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p9_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a1  DATE := FND_API.G_MISS_DATE
    , p9_a2  NUMBER := FND_API.G_MISS_NUM
    , p9_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_orgfax_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_create_party_rel VARCHAR2 := FND_API.G_MISS_CHAR
    , p_created_by_module VARCHAR2 := FND_API.G_MISS_CHAR
    , x_person_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_org_party_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddp_email_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddp_workph_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_workphone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_homeph_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_homephone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_fax_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_fax_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_cntct_pref_rec hz_contact_preference_v2pub.contact_preference_rec_type;
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddp_orgph_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_org_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_orgfax_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_org_fax_rec hz_contact_point_v2pub.phone_rec_type;

  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_person_rec.person_pre_name_adjunct := p1_a0;
    ddp_person_rec.person_first_name := p1_a1;
    ddp_person_rec.person_middle_name := p1_a2;
    ddp_person_rec.person_last_name := p1_a3;
    ddp_person_rec.person_name_suffix := p1_a4;
    ddp_person_rec.person_title := p1_a5;
    ddp_person_rec.person_academic_title := p1_a6;
    ddp_person_rec.person_previous_last_name := p1_a7;
    ddp_person_rec.person_initials := p1_a8;
    ddp_person_rec.known_as := p1_a9;
    ddp_person_rec.known_as2 := p1_a10;
    ddp_person_rec.known_as3 := p1_a11;
    ddp_person_rec.known_as4 := p1_a12;
    ddp_person_rec.known_as5 := p1_a13;
    ddp_person_rec.person_name_phonetic := p1_a14;
    ddp_person_rec.person_first_name_phonetic := p1_a15;
    ddp_person_rec.person_last_name_phonetic := p1_a16;
    ddp_person_rec.middle_name_phonetic := p1_a17;
    ddp_person_rec.tax_reference := p1_a18;
    ddp_person_rec.jgzz_fiscal_code := p1_a19;
    ddp_person_rec.person_iden_type := p1_a20;
    ddp_person_rec.person_identifier := p1_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p1_a22);
    ddp_person_rec.place_of_birth := p1_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p1_a24);
    ddp_person_rec.gender := p1_a25;
    ddp_person_rec.declared_ethnicity := p1_a26;
    ddp_person_rec.marital_status := p1_a27;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_person_rec.personal_income := p1_a29;
    ddp_person_rec.head_of_household_flag := p1_a30;
    ddp_person_rec.household_income := p1_a31;
    ddp_person_rec.household_size := p1_a32;
    ddp_person_rec.rent_own_ind := p1_a33;
    ddp_person_rec.last_known_gps := p1_a34;
    ddp_person_rec.content_source_type := p1_a35;
    ddp_person_rec.internal_flag := p1_a36;
    ddp_person_rec.attribute_category := p1_a37;
    ddp_person_rec.attribute1 := p1_a38;
    ddp_person_rec.attribute2 := p1_a39;
    ddp_person_rec.attribute3 := p1_a40;
    ddp_person_rec.attribute4 := p1_a41;
    ddp_person_rec.attribute5 := p1_a42;
    ddp_person_rec.attribute6 := p1_a43;
    ddp_person_rec.attribute7 := p1_a44;
    ddp_person_rec.attribute8 := p1_a45;
    ddp_person_rec.attribute9 := p1_a46;
    ddp_person_rec.attribute10 := p1_a47;
    ddp_person_rec.attribute11 := p1_a48;
    ddp_person_rec.attribute12 := p1_a49;
    ddp_person_rec.attribute13 := p1_a50;
    ddp_person_rec.attribute14 := p1_a51;
    ddp_person_rec.attribute15 := p1_a52;
    ddp_person_rec.attribute16 := p1_a53;
    ddp_person_rec.attribute17 := p1_a54;
    ddp_person_rec.attribute18 := p1_a55;
    ddp_person_rec.attribute19 := p1_a56;
    ddp_person_rec.attribute20 := p1_a57;
    ddp_person_rec.created_by_module := p1_a58;
    ddp_person_rec.application_id := p1_a59;
    ddp_person_rec.actual_content_source := p1_a60;
    ddp_person_rec.party_rec.party_id := p1_a61;
    ddp_person_rec.party_rec.party_number := p1_a62;
    ddp_person_rec.party_rec.validated_flag := p1_a63;
    ddp_person_rec.party_rec.orig_system_reference := p1_a64;
    ddp_person_rec.party_rec.status := p1_a65;
    ddp_person_rec.party_rec.category_code := p1_a66;
    ddp_person_rec.party_rec.salutation := p1_a67;
    ddp_person_rec.party_rec.attribute_category := p1_a68;
    ddp_person_rec.party_rec.attribute1 := p1_a69;
    ddp_person_rec.party_rec.attribute2 := p1_a70;
    ddp_person_rec.party_rec.attribute3 := p1_a71;
    ddp_person_rec.party_rec.attribute4 := p1_a72;
    ddp_person_rec.party_rec.attribute5 := p1_a73;
    ddp_person_rec.party_rec.attribute6 := p1_a74;
    ddp_person_rec.party_rec.attribute7 := p1_a75;
    ddp_person_rec.party_rec.attribute8 := p1_a76;
    ddp_person_rec.party_rec.attribute9 := p1_a77;
    ddp_person_rec.party_rec.attribute10 := p1_a78;
    ddp_person_rec.party_rec.attribute11 := p1_a79;
    ddp_person_rec.party_rec.attribute12 := p1_a80;
    ddp_person_rec.party_rec.attribute13 := p1_a81;
    ddp_person_rec.party_rec.attribute14 := p1_a82;
    ddp_person_rec.party_rec.attribute15 := p1_a83;
    ddp_person_rec.party_rec.attribute16 := p1_a84;
    ddp_person_rec.party_rec.attribute17 := p1_a85;
    ddp_person_rec.party_rec.attribute18 := p1_a86;
    ddp_person_rec.party_rec.attribute19 := p1_a87;
    ddp_person_rec.party_rec.attribute20 := p1_a88;
    ddp_person_rec.party_rec.attribute21 := p1_a89;
    ddp_person_rec.party_rec.attribute22 := p1_a90;
    ddp_person_rec.party_rec.attribute23 := p1_a91;
    ddp_person_rec.party_rec.attribute24 := p1_a92;

    ddp_email_contact_point_rec.contact_point_id := p_email_contact_point_id;
    ddp_email_rec.email_format := p2_a0;
    ddp_email_rec.email_address := p2_a1;

    ddp_workph_contact_point_rec.contact_point_id := p_workph_contact_point_id;
    ddp_workphone_rec.phone_calling_calendar := p3_a0;
    ddp_workphone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p3_a1);
    ddp_workphone_rec.timezone_id := p3_a2;
    ddp_workphone_rec.phone_area_code := p3_a3;
    ddp_workphone_rec.phone_country_code := p3_a4;
    ddp_workphone_rec.phone_number := p3_a5;
    ddp_workphone_rec.phone_extension := p3_a6;
    ddp_workphone_rec.phone_line_type := p3_a7;
    ddp_workphone_rec.raw_phone_number := p3_a8;

    ddp_homeph_contact_point_rec.contact_point_id := p_homeph_contact_point_id;
    ddp_homephone_rec.phone_calling_calendar := p4_a0;
    ddp_homephone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p4_a1);
    ddp_homephone_rec.timezone_id := p4_a2;
    ddp_homephone_rec.phone_area_code := p4_a3;
    ddp_homephone_rec.phone_country_code := p4_a4;
    ddp_homephone_rec.phone_number := p4_a5;
    ddp_homephone_rec.phone_extension := p4_a6;
    ddp_homephone_rec.phone_line_type := p4_a7;
    ddp_homephone_rec.raw_phone_number := p4_a8;

    ddp_fax_contact_point_rec.contact_point_id := p_fax_contact_point_id;
    ddp_fax_rec.phone_calling_calendar := p5_a0;
    ddp_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p5_a1);
    ddp_fax_rec.timezone_id := p5_a2;
    ddp_fax_rec.phone_area_code := p5_a3;
    ddp_fax_rec.phone_country_code := p5_a4;
    ddp_fax_rec.phone_number := p5_a5;
    ddp_fax_rec.phone_extension := p5_a6;
    ddp_fax_rec.phone_line_type := p5_a7;
    ddp_fax_rec.raw_phone_number := p5_a8;

    ddp_cntct_pref_rec.contact_preference_id := p_contact_preference_id;
    ddp_cntct_pref_rec.preference_code := p_contact_preference;

    IF( p_cntct_level_table_id IS NOT NULL AND p_cntct_level_table_id <> FND_API.G_MISS_NUM ) THEN
        ddp_cntct_pref_rec.contact_level_table_id := p_cntct_level_table_id;
    END IF;

    IF( p_cntct_level_table_name IS NOT NULL AND p_cntct_level_table_name <> FND_API.G_MISS_CHAR ) THEN
        ddp_cntct_pref_rec.contact_level_table := p_cntct_level_table_name;
    END IF;

    ddp_organization_rec.organization_name := p6_a0;
    ddp_organization_rec.duns_number_c := p6_a1;
    ddp_organization_rec.enquiry_duns := p6_a2;
    ddp_organization_rec.ceo_name := p6_a3;
    ddp_organization_rec.ceo_title := p6_a4;
    ddp_organization_rec.principal_name := p6_a5;
    ddp_organization_rec.principal_title := p6_a6;
    ddp_organization_rec.legal_status := p6_a7;
    ddp_organization_rec.control_yr := p6_a8;
    ddp_organization_rec.employees_total := p6_a9;
    ddp_organization_rec.hq_branch_ind := p6_a10;
    ddp_organization_rec.branch_flag := p6_a11;
    ddp_organization_rec.oob_ind := p6_a12;
    ddp_organization_rec.line_of_business := p6_a13;
    ddp_organization_rec.cong_dist_code := p6_a14;
    ddp_organization_rec.sic_code := p6_a15;
    ddp_organization_rec.import_ind := p6_a16;
    ddp_organization_rec.export_ind := p6_a17;
    ddp_organization_rec.labor_surplus_ind := p6_a18;
    ddp_organization_rec.debarment_ind := p6_a19;
    ddp_organization_rec.minority_owned_ind := p6_a20;
    ddp_organization_rec.minority_owned_type := p6_a21;
    ddp_organization_rec.woman_owned_ind := p6_a22;
    ddp_organization_rec.disadv_8a_ind := p6_a23;
    ddp_organization_rec.small_bus_ind := p6_a24;
    ddp_organization_rec.rent_own_ind := p6_a25;
    ddp_organization_rec.debarments_count := p6_a26;
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_organization_rec.failure_score := p6_a28;
    ddp_organization_rec.failure_score_natnl_percentile := p6_a29;
    ddp_organization_rec.failure_score_override_code := p6_a30;
    ddp_organization_rec.failure_score_commentary := p6_a31;
    ddp_organization_rec.global_failure_score := p6_a32;
    ddp_organization_rec.db_rating := p6_a33;
    ddp_organization_rec.credit_score := p6_a34;
    ddp_organization_rec.credit_score_commentary := p6_a35;
    ddp_organization_rec.paydex_score := p6_a36;
    ddp_organization_rec.paydex_three_months_ago := p6_a37;
    ddp_organization_rec.paydex_norm := p6_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p6_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p6_a40);
    ddp_organization_rec.organization_name_phonetic := p6_a41;
    ddp_organization_rec.tax_reference := p6_a42;
    ddp_organization_rec.gsa_indicator_flag := p6_a43;
    ddp_organization_rec.jgzz_fiscal_code := p6_a44;
    ddp_organization_rec.analysis_fy := p6_a45;
    ddp_organization_rec.fiscal_yearend_month := p6_a46;
    ddp_organization_rec.curr_fy_potential_revenue := p6_a47;
    ddp_organization_rec.next_fy_potential_revenue := p6_a48;
    ddp_organization_rec.year_established := p6_a49;
    ddp_organization_rec.mission_statement := p6_a50;
    ddp_organization_rec.organization_type := p6_a51;
    ddp_organization_rec.business_scope := p6_a52;
    ddp_organization_rec.corporation_class := p6_a53;
    ddp_organization_rec.known_as := p6_a54;
    ddp_organization_rec.known_as2 := p6_a55;
    ddp_organization_rec.known_as3 := p6_a56;
    ddp_organization_rec.known_as4 := p6_a57;
    ddp_organization_rec.known_as5 := p6_a58;
    ddp_organization_rec.local_bus_iden_type := p6_a59;
    ddp_organization_rec.local_bus_identifier := p6_a60;
    ddp_organization_rec.pref_functional_currency := p6_a61;
    ddp_organization_rec.registration_type := p6_a62;
    ddp_organization_rec.total_employees_text := p6_a63;
    ddp_organization_rec.total_employees_ind := p6_a64;
    ddp_organization_rec.total_emp_est_ind := p6_a65;
    ddp_organization_rec.total_emp_min_ind := p6_a66;
    ddp_organization_rec.parent_sub_ind := p6_a67;
    ddp_organization_rec.incorp_year := p6_a68;
    ddp_organization_rec.sic_code_type := p6_a69;
    ddp_organization_rec.public_private_ownership_flag := p6_a70;
    ddp_organization_rec.internal_flag := p6_a71;
    ddp_organization_rec.local_activity_code_type := p6_a72;
    ddp_organization_rec.local_activity_code := p6_a73;
    ddp_organization_rec.emp_at_primary_adr := p6_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p6_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p6_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p6_a77;
    ddp_organization_rec.high_credit := p6_a78;
    ddp_organization_rec.avg_high_credit := p6_a79;
    ddp_organization_rec.total_payments := p6_a80;
    ddp_organization_rec.credit_score_class := p6_a81;
    ddp_organization_rec.credit_score_natl_percentile := p6_a82;
    ddp_organization_rec.credit_score_incd_default := p6_a83;
    ddp_organization_rec.credit_score_age := p6_a84;
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p6_a85);
    ddp_organization_rec.credit_score_commentary2 := p6_a86;
    ddp_organization_rec.credit_score_commentary3 := p6_a87;
    ddp_organization_rec.credit_score_commentary4 := p6_a88;
    ddp_organization_rec.credit_score_commentary5 := p6_a89;
    ddp_organization_rec.credit_score_commentary6 := p6_a90;
    ddp_organization_rec.credit_score_commentary7 := p6_a91;
    ddp_organization_rec.credit_score_commentary8 := p6_a92;
    ddp_organization_rec.credit_score_commentary9 := p6_a93;
    ddp_organization_rec.credit_score_commentary10 := p6_a94;
    ddp_organization_rec.failure_score_class := p6_a95;
    ddp_organization_rec.failure_score_incd_default := p6_a96;
    ddp_organization_rec.failure_score_age := p6_a97;
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p6_a98);
    ddp_organization_rec.failure_score_commentary2 := p6_a99;
    ddp_organization_rec.failure_score_commentary3 := p6_a100;
    ddp_organization_rec.failure_score_commentary4 := p6_a101;
    ddp_organization_rec.failure_score_commentary5 := p6_a102;
    ddp_organization_rec.failure_score_commentary6 := p6_a103;
    ddp_organization_rec.failure_score_commentary7 := p6_a104;
    ddp_organization_rec.failure_score_commentary8 := p6_a105;
    ddp_organization_rec.failure_score_commentary9 := p6_a106;
    ddp_organization_rec.failure_score_commentary10 := p6_a107;
    ddp_organization_rec.maximum_credit_recommendation := p6_a108;
    ddp_organization_rec.maximum_credit_currency_code := p6_a109;
    ddp_organization_rec.displayed_duns_party_id := p6_a110;
    ddp_organization_rec.content_source_type := p6_a111;
    ddp_organization_rec.content_source_number := p6_a112;
    ddp_organization_rec.attribute_category := p6_a113;
    ddp_organization_rec.attribute1 := p6_a114;
    ddp_organization_rec.attribute2 := p6_a115;
    ddp_organization_rec.attribute3 := p6_a116;
    ddp_organization_rec.attribute4 := p6_a117;
    ddp_organization_rec.attribute5 := p6_a118;
    ddp_organization_rec.attribute6 := p6_a119;
    ddp_organization_rec.attribute7 := p6_a120;
    ddp_organization_rec.attribute8 := p6_a121;
    ddp_organization_rec.attribute9 := p6_a122;
    ddp_organization_rec.attribute10 := p6_a123;
    ddp_organization_rec.attribute11 := p6_a124;
    ddp_organization_rec.attribute12 := p6_a125;
    ddp_organization_rec.attribute13 := p6_a126;
    ddp_organization_rec.attribute14 := p6_a127;
    ddp_organization_rec.attribute15 := p6_a128;
    ddp_organization_rec.attribute16 := p6_a129;
    ddp_organization_rec.attribute17 := p6_a130;
    ddp_organization_rec.attribute18 := p6_a131;
    ddp_organization_rec.attribute19 := p6_a132;
    ddp_organization_rec.attribute20 := p6_a133;
    ddp_organization_rec.created_by_module := p6_a134;
    ddp_organization_rec.application_id := p6_a135;
    ddp_organization_rec.do_not_confuse_with := p6_a136;
    ddp_organization_rec.actual_content_source := p6_a137;
    ddp_organization_rec.party_rec.party_id := p6_a138;
    ddp_organization_rec.party_rec.party_number := p6_a139;
    ddp_organization_rec.party_rec.validated_flag := p6_a140;
    ddp_organization_rec.party_rec.orig_system_reference := p6_a141;
    ddp_organization_rec.party_rec.status := p6_a142;
    ddp_organization_rec.party_rec.category_code := p6_a143;
    ddp_organization_rec.party_rec.salutation := p6_a144;
    ddp_organization_rec.party_rec.attribute_category := p6_a145;
    ddp_organization_rec.party_rec.attribute1 := p6_a146;
    ddp_organization_rec.party_rec.attribute2 := p6_a147;
    ddp_organization_rec.party_rec.attribute3 := p6_a148;
    ddp_organization_rec.party_rec.attribute4 := p6_a149;
    ddp_organization_rec.party_rec.attribute5 := p6_a150;
    ddp_organization_rec.party_rec.attribute6 := p6_a151;
    ddp_organization_rec.party_rec.attribute7 := p6_a152;
    ddp_organization_rec.party_rec.attribute8 := p6_a153;
    ddp_organization_rec.party_rec.attribute9 := p6_a154;
    ddp_organization_rec.party_rec.attribute10 := p6_a155;
    ddp_organization_rec.party_rec.attribute11 := p6_a156;
    ddp_organization_rec.party_rec.attribute12 := p6_a157;
    ddp_organization_rec.party_rec.attribute13 := p6_a158;
    ddp_organization_rec.party_rec.attribute14 := p6_a159;
    ddp_organization_rec.party_rec.attribute15 := p6_a160;
    ddp_organization_rec.party_rec.attribute16 := p6_a161;
    ddp_organization_rec.party_rec.attribute17 := p6_a162;
    ddp_organization_rec.party_rec.attribute18 := p6_a163;
    ddp_organization_rec.party_rec.attribute19 := p6_a164;
    ddp_organization_rec.party_rec.attribute20 := p6_a165;
    ddp_organization_rec.party_rec.attribute21 := p6_a166;
    ddp_organization_rec.party_rec.attribute22 := p6_a167;
    ddp_organization_rec.party_rec.attribute23 := p6_a168;
    ddp_organization_rec.party_rec.attribute24 := p6_a169;

    ddp_location_rec.location_id := p7_a0;
    ddp_location_rec.orig_system_reference := p7_a1;
    ddp_location_rec.country := p7_a2;
    ddp_location_rec.address1 := p7_a3;
    ddp_location_rec.address2 := p7_a4;
    ddp_location_rec.address3 := p7_a5;
    ddp_location_rec.address4 := p7_a6;
    ddp_location_rec.city := p7_a7;
    ddp_location_rec.postal_code := p7_a8;
    ddp_location_rec.state := p7_a9;
    ddp_location_rec.province := p7_a10;
    ddp_location_rec.county := p7_a11;
    ddp_location_rec.address_key := p7_a12;
    ddp_location_rec.address_style := p7_a13;
    ddp_location_rec.validated_flag := p7_a14;
    ddp_location_rec.address_lines_phonetic := p7_a15;
    ddp_location_rec.po_box_number := p7_a16;
    ddp_location_rec.house_number := p7_a17;
    ddp_location_rec.street_suffix := p7_a18;
    ddp_location_rec.street := p7_a19;
    ddp_location_rec.street_number := p7_a20;
    ddp_location_rec.floor := p7_a21;
    ddp_location_rec.suite := p7_a22;
    ddp_location_rec.postal_plus4_code := p7_a23;
    ddp_location_rec.position := p7_a24;
    ddp_location_rec.location_directions := p7_a25;
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p7_a26);
    ddp_location_rec.clli_code := p7_a27;
    ddp_location_rec.language := p7_a28;
    ddp_location_rec.short_description := p7_a29;
    ddp_location_rec.description := p7_a30;
    ddp_location_rec.loc_hierarchy_id := p7_a31;
    ddp_location_rec.sales_tax_geocode := p7_a32;
    ddp_location_rec.sales_tax_inside_city_limits := p7_a33;
    ddp_location_rec.fa_location_id := p7_a34;
    ddp_location_rec.content_source_type := p7_a35;
    ddp_location_rec.attribute_category := p7_a36;
    ddp_location_rec.attribute1 := p7_a37;
    ddp_location_rec.attribute2 := p7_a38;
    ddp_location_rec.attribute3 := p7_a39;
    ddp_location_rec.attribute4 := p7_a40;
    ddp_location_rec.attribute5 := p7_a41;
    ddp_location_rec.attribute6 := p7_a42;
    ddp_location_rec.attribute7 := p7_a43;
    ddp_location_rec.attribute8 := p7_a44;
    ddp_location_rec.attribute9 := p7_a45;
    ddp_location_rec.attribute10 := p7_a46;
    ddp_location_rec.attribute11 := p7_a47;
    ddp_location_rec.attribute12 := p7_a48;
    ddp_location_rec.attribute13 := p7_a49;
    ddp_location_rec.attribute14 := p7_a50;
    ddp_location_rec.attribute15 := p7_a51;
    ddp_location_rec.attribute16 := p7_a52;
    ddp_location_rec.attribute17 := p7_a53;
    ddp_location_rec.attribute18 := p7_a54;
    ddp_location_rec.attribute19 := p7_a55;
    ddp_location_rec.attribute20 := p7_a56;
    ddp_location_rec.timezone_id := p7_a57;
    ddp_location_rec.created_by_module := p7_a58;
    ddp_location_rec.application_id := p7_a59;
    ddp_location_rec.actual_content_source := p7_a60;

    ddp_orgph_contact_point_rec.contact_point_id := p_orgph_contact_point_id;
    ddp_org_phone_rec.phone_calling_calendar := p8_a0;
    ddp_org_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p8_a1);
    ddp_org_phone_rec.timezone_id := p8_a2;
    ddp_org_phone_rec.phone_area_code := p8_a3;
    ddp_org_phone_rec.phone_country_code := p8_a4;
    ddp_org_phone_rec.phone_number := p8_a5;
    ddp_org_phone_rec.phone_extension := p8_a6;
    ddp_org_phone_rec.phone_line_type := p8_a7;
    ddp_org_phone_rec.raw_phone_number := p8_a8;

    ddp_orgfax_contact_point_rec.contact_point_id := p_orgfax_contact_point_id;
    ddp_org_fax_rec.phone_calling_calendar := p9_a0;
    ddp_org_fax_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p9_a1);
    ddp_org_fax_rec.timezone_id := p9_a2;
    ddp_org_fax_rec.phone_area_code := p9_a3;
    ddp_org_fax_rec.phone_country_code := p9_a4;
    ddp_org_fax_rec.phone_number := p9_a5;
    ddp_org_fax_rec.phone_extension := p9_a6;
    ddp_org_fax_rec.phone_line_type := p9_a7;
    ddp_org_fax_rec.raw_phone_number := p9_a8;


    -- here's the delegated call to the PL/SQL routine
    ibe_party_v2pvt.Save_Tca_Entities(ddp_person_rec,
      p_person_object_version_number,
      ddp_email_contact_point_rec,
      ddp_email_rec,
      p_email_object_version_number,
      ddp_workph_contact_point_rec,
      ddp_workphone_rec,
      p_workph_object_version_number,
      ddp_homeph_contact_point_rec,
      ddp_homephone_rec,
      p_homeph_object_version_number,
      ddp_fax_contact_point_rec,
      ddp_fax_rec,
      p_fax_object_version_number,
      ddp_cntct_pref_rec,
      p_cntct_pref_object_ver_num,
      ddp_organization_rec,
      p_org_object_version_number,
      ddp_location_rec,
      p_loc_object_version_number,
      ddp_orgph_contact_point_rec,
      ddp_org_phone_rec,
      p_orgph_object_version_number,
      ddp_orgfax_contact_point_rec,
      ddp_org_fax_rec,
      p_orgfax_object_version_number,
      p_create_party_rel,
      p_created_by_module,
      x_person_party_id,
      x_rel_party_id,
      x_org_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

end;

end ibe_party_v2pvt_w;

/
