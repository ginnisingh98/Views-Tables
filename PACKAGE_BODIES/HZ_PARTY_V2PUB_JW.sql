--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_V2PUB_JW" as
  /* $Header: ARH2PAJB.pls 120.5 2005/07/26 19:23:25 jhuang noship $ */
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

  procedure create_person_1(p_init_msg_list  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
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
    , p1_a22  DATE := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  DATE := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  DATE := null
    , p1_a30  NUMBER := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  NUMBER := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
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
    , p1_a60  NUMBER := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  NUMBER := null
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
  )
  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddindx binary_integer; indx binary_integer;
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
    ddp_person_rec.deceased_flag := p1_a25;
    ddp_person_rec.gender := p1_a26;
    ddp_person_rec.declared_ethnicity := p1_a27;
    ddp_person_rec.marital_status := p1_a28;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_person_rec.personal_income := rosetta_g_miss_num_map(p1_a30);
    ddp_person_rec.head_of_household_flag := p1_a31;
    ddp_person_rec.household_income := rosetta_g_miss_num_map(p1_a32);
    ddp_person_rec.household_size := rosetta_g_miss_num_map(p1_a33);
    ddp_person_rec.rent_own_ind := p1_a34;
    ddp_person_rec.last_known_gps := p1_a35;
    ddp_person_rec.content_source_type := p1_a36;
    ddp_person_rec.internal_flag := p1_a37;
    ddp_person_rec.attribute_category := p1_a38;
    ddp_person_rec.attribute1 := p1_a39;
    ddp_person_rec.attribute2 := p1_a40;
    ddp_person_rec.attribute3 := p1_a41;
    ddp_person_rec.attribute4 := p1_a42;
    ddp_person_rec.attribute5 := p1_a43;
    ddp_person_rec.attribute6 := p1_a44;
    ddp_person_rec.attribute7 := p1_a45;
    ddp_person_rec.attribute8 := p1_a46;
    ddp_person_rec.attribute9 := p1_a47;
    ddp_person_rec.attribute10 := p1_a48;
    ddp_person_rec.attribute11 := p1_a49;
    ddp_person_rec.attribute12 := p1_a50;
    ddp_person_rec.attribute13 := p1_a51;
    ddp_person_rec.attribute14 := p1_a52;
    ddp_person_rec.attribute15 := p1_a53;
    ddp_person_rec.attribute16 := p1_a54;
    ddp_person_rec.attribute17 := p1_a55;
    ddp_person_rec.attribute18 := p1_a56;
    ddp_person_rec.attribute19 := p1_a57;
    ddp_person_rec.attribute20 := p1_a58;
    ddp_person_rec.created_by_module := p1_a59;
    ddp_person_rec.application_id := rosetta_g_miss_num_map(p1_a60);
    ddp_person_rec.actual_content_source := p1_a61;
    ddp_person_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a62);
    ddp_person_rec.party_rec.party_number := p1_a63;
    ddp_person_rec.party_rec.validated_flag := p1_a64;
    ddp_person_rec.party_rec.orig_system_reference := p1_a65;
    ddp_person_rec.party_rec.orig_system := p1_a66;
    ddp_person_rec.party_rec.status := p1_a67;
    ddp_person_rec.party_rec.category_code := p1_a68;
    ddp_person_rec.party_rec.salutation := p1_a69;
    ddp_person_rec.party_rec.attribute_category := p1_a70;
    ddp_person_rec.party_rec.attribute1 := p1_a71;
    ddp_person_rec.party_rec.attribute2 := p1_a72;
    ddp_person_rec.party_rec.attribute3 := p1_a73;
    ddp_person_rec.party_rec.attribute4 := p1_a74;
    ddp_person_rec.party_rec.attribute5 := p1_a75;
    ddp_person_rec.party_rec.attribute6 := p1_a76;
    ddp_person_rec.party_rec.attribute7 := p1_a77;
    ddp_person_rec.party_rec.attribute8 := p1_a78;
    ddp_person_rec.party_rec.attribute9 := p1_a79;
    ddp_person_rec.party_rec.attribute10 := p1_a80;
    ddp_person_rec.party_rec.attribute11 := p1_a81;
    ddp_person_rec.party_rec.attribute12 := p1_a82;
    ddp_person_rec.party_rec.attribute13 := p1_a83;
    ddp_person_rec.party_rec.attribute14 := p1_a84;
    ddp_person_rec.party_rec.attribute15 := p1_a85;
    ddp_person_rec.party_rec.attribute16 := p1_a86;
    ddp_person_rec.party_rec.attribute17 := p1_a87;
    ddp_person_rec.party_rec.attribute18 := p1_a88;
    ddp_person_rec.party_rec.attribute19 := p1_a89;
    ddp_person_rec.party_rec.attribute20 := p1_a90;
    ddp_person_rec.party_rec.attribute21 := p1_a91;
    ddp_person_rec.party_rec.attribute22 := p1_a92;
    ddp_person_rec.party_rec.attribute23 := p1_a93;
    ddp_person_rec.party_rec.attribute24 := p1_a94;







    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.create_person(p_init_msg_list,
      ddp_person_rec,
      x_party_id,
      x_party_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_person_2(p_init_msg_list  VARCHAR2
    , p_party_usage_code  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
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
    , p1_a22  DATE := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  DATE := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  DATE := null
    , p1_a30  NUMBER := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  NUMBER := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
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
    , p1_a60  NUMBER := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  NUMBER := null
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
  )
  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddindx binary_integer; indx binary_integer;
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
    ddp_person_rec.deceased_flag := p1_a25;
    ddp_person_rec.gender := p1_a26;
    ddp_person_rec.declared_ethnicity := p1_a27;
    ddp_person_rec.marital_status := p1_a28;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_person_rec.personal_income := rosetta_g_miss_num_map(p1_a30);
    ddp_person_rec.head_of_household_flag := p1_a31;
    ddp_person_rec.household_income := rosetta_g_miss_num_map(p1_a32);
    ddp_person_rec.household_size := rosetta_g_miss_num_map(p1_a33);
    ddp_person_rec.rent_own_ind := p1_a34;
    ddp_person_rec.last_known_gps := p1_a35;
    ddp_person_rec.content_source_type := p1_a36;
    ddp_person_rec.internal_flag := p1_a37;
    ddp_person_rec.attribute_category := p1_a38;
    ddp_person_rec.attribute1 := p1_a39;
    ddp_person_rec.attribute2 := p1_a40;
    ddp_person_rec.attribute3 := p1_a41;
    ddp_person_rec.attribute4 := p1_a42;
    ddp_person_rec.attribute5 := p1_a43;
    ddp_person_rec.attribute6 := p1_a44;
    ddp_person_rec.attribute7 := p1_a45;
    ddp_person_rec.attribute8 := p1_a46;
    ddp_person_rec.attribute9 := p1_a47;
    ddp_person_rec.attribute10 := p1_a48;
    ddp_person_rec.attribute11 := p1_a49;
    ddp_person_rec.attribute12 := p1_a50;
    ddp_person_rec.attribute13 := p1_a51;
    ddp_person_rec.attribute14 := p1_a52;
    ddp_person_rec.attribute15 := p1_a53;
    ddp_person_rec.attribute16 := p1_a54;
    ddp_person_rec.attribute17 := p1_a55;
    ddp_person_rec.attribute18 := p1_a56;
    ddp_person_rec.attribute19 := p1_a57;
    ddp_person_rec.attribute20 := p1_a58;
    ddp_person_rec.created_by_module := p1_a59;
    ddp_person_rec.application_id := rosetta_g_miss_num_map(p1_a60);
    ddp_person_rec.actual_content_source := p1_a61;
    ddp_person_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a62);
    ddp_person_rec.party_rec.party_number := p1_a63;
    ddp_person_rec.party_rec.validated_flag := p1_a64;
    ddp_person_rec.party_rec.orig_system_reference := p1_a65;
    ddp_person_rec.party_rec.orig_system := p1_a66;
    ddp_person_rec.party_rec.status := p1_a67;
    ddp_person_rec.party_rec.category_code := p1_a68;
    ddp_person_rec.party_rec.salutation := p1_a69;
    ddp_person_rec.party_rec.attribute_category := p1_a70;
    ddp_person_rec.party_rec.attribute1 := p1_a71;
    ddp_person_rec.party_rec.attribute2 := p1_a72;
    ddp_person_rec.party_rec.attribute3 := p1_a73;
    ddp_person_rec.party_rec.attribute4 := p1_a74;
    ddp_person_rec.party_rec.attribute5 := p1_a75;
    ddp_person_rec.party_rec.attribute6 := p1_a76;
    ddp_person_rec.party_rec.attribute7 := p1_a77;
    ddp_person_rec.party_rec.attribute8 := p1_a78;
    ddp_person_rec.party_rec.attribute9 := p1_a79;
    ddp_person_rec.party_rec.attribute10 := p1_a80;
    ddp_person_rec.party_rec.attribute11 := p1_a81;
    ddp_person_rec.party_rec.attribute12 := p1_a82;
    ddp_person_rec.party_rec.attribute13 := p1_a83;
    ddp_person_rec.party_rec.attribute14 := p1_a84;
    ddp_person_rec.party_rec.attribute15 := p1_a85;
    ddp_person_rec.party_rec.attribute16 := p1_a86;
    ddp_person_rec.party_rec.attribute17 := p1_a87;
    ddp_person_rec.party_rec.attribute18 := p1_a88;
    ddp_person_rec.party_rec.attribute19 := p1_a89;
    ddp_person_rec.party_rec.attribute20 := p1_a90;
    ddp_person_rec.party_rec.attribute21 := p1_a91;
    ddp_person_rec.party_rec.attribute22 := p1_a92;
    ddp_person_rec.party_rec.attribute23 := p1_a93;
    ddp_person_rec.party_rec.attribute24 := p1_a94;








    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.create_person(p_init_msg_list,
      ddp_person_rec,
      p_party_usage_code,
      x_party_id,
      x_party_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_person_3(p_init_msg_list  VARCHAR2
    , p_party_object_version_number in out nocopy  NUMBER
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
    , p1_a22  DATE := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  DATE := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  DATE := null
    , p1_a30  NUMBER := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  NUMBER := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
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
    , p1_a60  NUMBER := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  NUMBER := null
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
  )
  as
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddindx binary_integer; indx binary_integer;
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
    ddp_person_rec.deceased_flag := p1_a25;
    ddp_person_rec.gender := p1_a26;
    ddp_person_rec.declared_ethnicity := p1_a27;
    ddp_person_rec.marital_status := p1_a28;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_person_rec.personal_income := rosetta_g_miss_num_map(p1_a30);
    ddp_person_rec.head_of_household_flag := p1_a31;
    ddp_person_rec.household_income := rosetta_g_miss_num_map(p1_a32);
    ddp_person_rec.household_size := rosetta_g_miss_num_map(p1_a33);
    ddp_person_rec.rent_own_ind := p1_a34;
    ddp_person_rec.last_known_gps := p1_a35;
    ddp_person_rec.content_source_type := p1_a36;
    ddp_person_rec.internal_flag := p1_a37;
    ddp_person_rec.attribute_category := p1_a38;
    ddp_person_rec.attribute1 := p1_a39;
    ddp_person_rec.attribute2 := p1_a40;
    ddp_person_rec.attribute3 := p1_a41;
    ddp_person_rec.attribute4 := p1_a42;
    ddp_person_rec.attribute5 := p1_a43;
    ddp_person_rec.attribute6 := p1_a44;
    ddp_person_rec.attribute7 := p1_a45;
    ddp_person_rec.attribute8 := p1_a46;
    ddp_person_rec.attribute9 := p1_a47;
    ddp_person_rec.attribute10 := p1_a48;
    ddp_person_rec.attribute11 := p1_a49;
    ddp_person_rec.attribute12 := p1_a50;
    ddp_person_rec.attribute13 := p1_a51;
    ddp_person_rec.attribute14 := p1_a52;
    ddp_person_rec.attribute15 := p1_a53;
    ddp_person_rec.attribute16 := p1_a54;
    ddp_person_rec.attribute17 := p1_a55;
    ddp_person_rec.attribute18 := p1_a56;
    ddp_person_rec.attribute19 := p1_a57;
    ddp_person_rec.attribute20 := p1_a58;
    ddp_person_rec.created_by_module := p1_a59;
    ddp_person_rec.application_id := rosetta_g_miss_num_map(p1_a60);
    ddp_person_rec.actual_content_source := p1_a61;
    ddp_person_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a62);
    ddp_person_rec.party_rec.party_number := p1_a63;
    ddp_person_rec.party_rec.validated_flag := p1_a64;
    ddp_person_rec.party_rec.orig_system_reference := p1_a65;
    ddp_person_rec.party_rec.orig_system := p1_a66;
    ddp_person_rec.party_rec.status := p1_a67;
    ddp_person_rec.party_rec.category_code := p1_a68;
    ddp_person_rec.party_rec.salutation := p1_a69;
    ddp_person_rec.party_rec.attribute_category := p1_a70;
    ddp_person_rec.party_rec.attribute1 := p1_a71;
    ddp_person_rec.party_rec.attribute2 := p1_a72;
    ddp_person_rec.party_rec.attribute3 := p1_a73;
    ddp_person_rec.party_rec.attribute4 := p1_a74;
    ddp_person_rec.party_rec.attribute5 := p1_a75;
    ddp_person_rec.party_rec.attribute6 := p1_a76;
    ddp_person_rec.party_rec.attribute7 := p1_a77;
    ddp_person_rec.party_rec.attribute8 := p1_a78;
    ddp_person_rec.party_rec.attribute9 := p1_a79;
    ddp_person_rec.party_rec.attribute10 := p1_a80;
    ddp_person_rec.party_rec.attribute11 := p1_a81;
    ddp_person_rec.party_rec.attribute12 := p1_a82;
    ddp_person_rec.party_rec.attribute13 := p1_a83;
    ddp_person_rec.party_rec.attribute14 := p1_a84;
    ddp_person_rec.party_rec.attribute15 := p1_a85;
    ddp_person_rec.party_rec.attribute16 := p1_a86;
    ddp_person_rec.party_rec.attribute17 := p1_a87;
    ddp_person_rec.party_rec.attribute18 := p1_a88;
    ddp_person_rec.party_rec.attribute19 := p1_a89;
    ddp_person_rec.party_rec.attribute20 := p1_a90;
    ddp_person_rec.party_rec.attribute21 := p1_a91;
    ddp_person_rec.party_rec.attribute22 := p1_a92;
    ddp_person_rec.party_rec.attribute23 := p1_a93;
    ddp_person_rec.party_rec.attribute24 := p1_a94;






    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.update_person(p_init_msg_list,
      ddp_person_rec,
      p_party_object_version_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_group_4(p_init_msg_list  VARCHAR2
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
    hz_party_v2pub.create_group(p_init_msg_list,
      ddp_group_rec,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_group_5(p_init_msg_list  VARCHAR2
    , p_party_object_version_number in out nocopy  NUMBER
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
    hz_party_v2pub.update_group(p_init_msg_list,
      ddp_group_rec,
      p_party_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_organization_6(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_profile_id out nocopy  NUMBER
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  NUMBER := null
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
    , p1_a26  NUMBER := null
    , p1_a27  DATE := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  NUMBER := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  DATE := null
    , p1_a40  DATE := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  NUMBER := null
    , p1_a48  NUMBER := null
    , p1_a49  NUMBER := null
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
    , p1_a68  NUMBER := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  NUMBER := null
    , p1_a79  NUMBER := null
    , p1_a80  NUMBER := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  NUMBER := null
    , p1_a84  NUMBER := null
    , p1_a85  DATE := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  NUMBER := null
    , p1_a96  NUMBER := null
    , p1_a97  NUMBER := null
    , p1_a98  DATE := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  VARCHAR2 := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  VARCHAR2 := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  NUMBER := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  NUMBER := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  VARCHAR2 := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  VARCHAR2 := null
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
    , p1_a135  NUMBER := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  NUMBER := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  VARCHAR2 := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  VARCHAR2 := null
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
  )
  as
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_organization_rec.organization_name := p1_a0;
    ddp_organization_rec.duns_number_c := p1_a1;
    ddp_organization_rec.enquiry_duns := p1_a2;
    ddp_organization_rec.ceo_name := p1_a3;
    ddp_organization_rec.ceo_title := p1_a4;
    ddp_organization_rec.principal_name := p1_a5;
    ddp_organization_rec.principal_title := p1_a6;
    ddp_organization_rec.legal_status := p1_a7;
    ddp_organization_rec.control_yr := rosetta_g_miss_num_map(p1_a8);
    ddp_organization_rec.employees_total := rosetta_g_miss_num_map(p1_a9);
    ddp_organization_rec.hq_branch_ind := p1_a10;
    ddp_organization_rec.branch_flag := p1_a11;
    ddp_organization_rec.oob_ind := p1_a12;
    ddp_organization_rec.line_of_business := p1_a13;
    ddp_organization_rec.cong_dist_code := p1_a14;
    ddp_organization_rec.sic_code := p1_a15;
    ddp_organization_rec.import_ind := p1_a16;
    ddp_organization_rec.export_ind := p1_a17;
    ddp_organization_rec.labor_surplus_ind := p1_a18;
    ddp_organization_rec.debarment_ind := p1_a19;
    ddp_organization_rec.minority_owned_ind := p1_a20;
    ddp_organization_rec.minority_owned_type := p1_a21;
    ddp_organization_rec.woman_owned_ind := p1_a22;
    ddp_organization_rec.disadv_8a_ind := p1_a23;
    ddp_organization_rec.small_bus_ind := p1_a24;
    ddp_organization_rec.rent_own_ind := p1_a25;
    ddp_organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a26);
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_organization_rec.failure_score := p1_a28;
    ddp_organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a29);
    ddp_organization_rec.failure_score_override_code := p1_a30;
    ddp_organization_rec.failure_score_commentary := p1_a31;
    ddp_organization_rec.global_failure_score := p1_a32;
    ddp_organization_rec.db_rating := p1_a33;
    ddp_organization_rec.credit_score := p1_a34;
    ddp_organization_rec.credit_score_commentary := p1_a35;
    ddp_organization_rec.paydex_score := p1_a36;
    ddp_organization_rec.paydex_three_months_ago := p1_a37;
    ddp_organization_rec.paydex_norm := p1_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a40);
    ddp_organization_rec.organization_name_phonetic := p1_a41;
    ddp_organization_rec.tax_reference := p1_a42;
    ddp_organization_rec.gsa_indicator_flag := p1_a43;
    ddp_organization_rec.jgzz_fiscal_code := p1_a44;
    ddp_organization_rec.analysis_fy := p1_a45;
    ddp_organization_rec.fiscal_yearend_month := p1_a46;
    ddp_organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a47);
    ddp_organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a48);
    ddp_organization_rec.year_established := rosetta_g_miss_num_map(p1_a49);
    ddp_organization_rec.mission_statement := p1_a50;
    ddp_organization_rec.organization_type := p1_a51;
    ddp_organization_rec.business_scope := p1_a52;
    ddp_organization_rec.corporation_class := p1_a53;
    ddp_organization_rec.known_as := p1_a54;
    ddp_organization_rec.known_as2 := p1_a55;
    ddp_organization_rec.known_as3 := p1_a56;
    ddp_organization_rec.known_as4 := p1_a57;
    ddp_organization_rec.known_as5 := p1_a58;
    ddp_organization_rec.local_bus_iden_type := p1_a59;
    ddp_organization_rec.local_bus_identifier := p1_a60;
    ddp_organization_rec.pref_functional_currency := p1_a61;
    ddp_organization_rec.registration_type := p1_a62;
    ddp_organization_rec.total_employees_text := p1_a63;
    ddp_organization_rec.total_employees_ind := p1_a64;
    ddp_organization_rec.total_emp_est_ind := p1_a65;
    ddp_organization_rec.total_emp_min_ind := p1_a66;
    ddp_organization_rec.parent_sub_ind := p1_a67;
    ddp_organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a68);
    ddp_organization_rec.sic_code_type := p1_a69;
    ddp_organization_rec.public_private_ownership_flag := p1_a70;
    ddp_organization_rec.internal_flag := p1_a71;
    ddp_organization_rec.local_activity_code_type := p1_a72;
    ddp_organization_rec.local_activity_code := p1_a73;
    ddp_organization_rec.emp_at_primary_adr := p1_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p1_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p1_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p1_a77;
    ddp_organization_rec.high_credit := rosetta_g_miss_num_map(p1_a78);
    ddp_organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a79);
    ddp_organization_rec.total_payments := rosetta_g_miss_num_map(p1_a80);
    ddp_organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a81);
    ddp_organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a82);
    ddp_organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a83);
    ddp_organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a84);
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a85);
    ddp_organization_rec.credit_score_commentary2 := p1_a86;
    ddp_organization_rec.credit_score_commentary3 := p1_a87;
    ddp_organization_rec.credit_score_commentary4 := p1_a88;
    ddp_organization_rec.credit_score_commentary5 := p1_a89;
    ddp_organization_rec.credit_score_commentary6 := p1_a90;
    ddp_organization_rec.credit_score_commentary7 := p1_a91;
    ddp_organization_rec.credit_score_commentary8 := p1_a92;
    ddp_organization_rec.credit_score_commentary9 := p1_a93;
    ddp_organization_rec.credit_score_commentary10 := p1_a94;
    ddp_organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a95);
    ddp_organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a96);
    ddp_organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a97);
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a98);
    ddp_organization_rec.failure_score_commentary2 := p1_a99;
    ddp_organization_rec.failure_score_commentary3 := p1_a100;
    ddp_organization_rec.failure_score_commentary4 := p1_a101;
    ddp_organization_rec.failure_score_commentary5 := p1_a102;
    ddp_organization_rec.failure_score_commentary6 := p1_a103;
    ddp_organization_rec.failure_score_commentary7 := p1_a104;
    ddp_organization_rec.failure_score_commentary8 := p1_a105;
    ddp_organization_rec.failure_score_commentary9 := p1_a106;
    ddp_organization_rec.failure_score_commentary10 := p1_a107;
    ddp_organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a108);
    ddp_organization_rec.maximum_credit_currency_code := p1_a109;
    ddp_organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a110);
    ddp_organization_rec.content_source_type := p1_a111;
    ddp_organization_rec.content_source_number := p1_a112;
    ddp_organization_rec.attribute_category := p1_a113;
    ddp_organization_rec.attribute1 := p1_a114;
    ddp_organization_rec.attribute2 := p1_a115;
    ddp_organization_rec.attribute3 := p1_a116;
    ddp_organization_rec.attribute4 := p1_a117;
    ddp_organization_rec.attribute5 := p1_a118;
    ddp_organization_rec.attribute6 := p1_a119;
    ddp_organization_rec.attribute7 := p1_a120;
    ddp_organization_rec.attribute8 := p1_a121;
    ddp_organization_rec.attribute9 := p1_a122;
    ddp_organization_rec.attribute10 := p1_a123;
    ddp_organization_rec.attribute11 := p1_a124;
    ddp_organization_rec.attribute12 := p1_a125;
    ddp_organization_rec.attribute13 := p1_a126;
    ddp_organization_rec.attribute14 := p1_a127;
    ddp_organization_rec.attribute15 := p1_a128;
    ddp_organization_rec.attribute16 := p1_a129;
    ddp_organization_rec.attribute17 := p1_a130;
    ddp_organization_rec.attribute18 := p1_a131;
    ddp_organization_rec.attribute19 := p1_a132;
    ddp_organization_rec.attribute20 := p1_a133;
    ddp_organization_rec.created_by_module := p1_a134;
    ddp_organization_rec.application_id := rosetta_g_miss_num_map(p1_a135);
    ddp_organization_rec.do_not_confuse_with := p1_a136;
    ddp_organization_rec.actual_content_source := p1_a137;
    ddp_organization_rec.home_country := p1_a138;
    ddp_organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a139);
    ddp_organization_rec.party_rec.party_number := p1_a140;
    ddp_organization_rec.party_rec.validated_flag := p1_a141;
    ddp_organization_rec.party_rec.orig_system_reference := p1_a142;
    ddp_organization_rec.party_rec.orig_system := p1_a143;
    ddp_organization_rec.party_rec.status := p1_a144;
    ddp_organization_rec.party_rec.category_code := p1_a145;
    ddp_organization_rec.party_rec.salutation := p1_a146;
    ddp_organization_rec.party_rec.attribute_category := p1_a147;
    ddp_organization_rec.party_rec.attribute1 := p1_a148;
    ddp_organization_rec.party_rec.attribute2 := p1_a149;
    ddp_organization_rec.party_rec.attribute3 := p1_a150;
    ddp_organization_rec.party_rec.attribute4 := p1_a151;
    ddp_organization_rec.party_rec.attribute5 := p1_a152;
    ddp_organization_rec.party_rec.attribute6 := p1_a153;
    ddp_organization_rec.party_rec.attribute7 := p1_a154;
    ddp_organization_rec.party_rec.attribute8 := p1_a155;
    ddp_organization_rec.party_rec.attribute9 := p1_a156;
    ddp_organization_rec.party_rec.attribute10 := p1_a157;
    ddp_organization_rec.party_rec.attribute11 := p1_a158;
    ddp_organization_rec.party_rec.attribute12 := p1_a159;
    ddp_organization_rec.party_rec.attribute13 := p1_a160;
    ddp_organization_rec.party_rec.attribute14 := p1_a161;
    ddp_organization_rec.party_rec.attribute15 := p1_a162;
    ddp_organization_rec.party_rec.attribute16 := p1_a163;
    ddp_organization_rec.party_rec.attribute17 := p1_a164;
    ddp_organization_rec.party_rec.attribute18 := p1_a165;
    ddp_organization_rec.party_rec.attribute19 := p1_a166;
    ddp_organization_rec.party_rec.attribute20 := p1_a167;
    ddp_organization_rec.party_rec.attribute21 := p1_a168;
    ddp_organization_rec.party_rec.attribute22 := p1_a169;
    ddp_organization_rec.party_rec.attribute23 := p1_a170;
    ddp_organization_rec.party_rec.attribute24 := p1_a171;







    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.create_organization(p_init_msg_list,
      ddp_organization_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_party_id,
      x_party_number,
      x_profile_id);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_organization_7(p_init_msg_list  VARCHAR2
    , p_party_usage_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_profile_id out nocopy  NUMBER
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  NUMBER := null
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
    , p1_a26  NUMBER := null
    , p1_a27  DATE := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  NUMBER := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  DATE := null
    , p1_a40  DATE := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  NUMBER := null
    , p1_a48  NUMBER := null
    , p1_a49  NUMBER := null
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
    , p1_a68  NUMBER := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  NUMBER := null
    , p1_a79  NUMBER := null
    , p1_a80  NUMBER := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  NUMBER := null
    , p1_a84  NUMBER := null
    , p1_a85  DATE := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  NUMBER := null
    , p1_a96  NUMBER := null
    , p1_a97  NUMBER := null
    , p1_a98  DATE := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  VARCHAR2 := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  VARCHAR2 := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  NUMBER := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  NUMBER := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  VARCHAR2 := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  VARCHAR2 := null
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
    , p1_a135  NUMBER := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  NUMBER := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  VARCHAR2 := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  VARCHAR2 := null
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
  )
  as
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_organization_rec.organization_name := p1_a0;
    ddp_organization_rec.duns_number_c := p1_a1;
    ddp_organization_rec.enquiry_duns := p1_a2;
    ddp_organization_rec.ceo_name := p1_a3;
    ddp_organization_rec.ceo_title := p1_a4;
    ddp_organization_rec.principal_name := p1_a5;
    ddp_organization_rec.principal_title := p1_a6;
    ddp_organization_rec.legal_status := p1_a7;
    ddp_organization_rec.control_yr := rosetta_g_miss_num_map(p1_a8);
    ddp_organization_rec.employees_total := rosetta_g_miss_num_map(p1_a9);
    ddp_organization_rec.hq_branch_ind := p1_a10;
    ddp_organization_rec.branch_flag := p1_a11;
    ddp_organization_rec.oob_ind := p1_a12;
    ddp_organization_rec.line_of_business := p1_a13;
    ddp_organization_rec.cong_dist_code := p1_a14;
    ddp_organization_rec.sic_code := p1_a15;
    ddp_organization_rec.import_ind := p1_a16;
    ddp_organization_rec.export_ind := p1_a17;
    ddp_organization_rec.labor_surplus_ind := p1_a18;
    ddp_organization_rec.debarment_ind := p1_a19;
    ddp_organization_rec.minority_owned_ind := p1_a20;
    ddp_organization_rec.minority_owned_type := p1_a21;
    ddp_organization_rec.woman_owned_ind := p1_a22;
    ddp_organization_rec.disadv_8a_ind := p1_a23;
    ddp_organization_rec.small_bus_ind := p1_a24;
    ddp_organization_rec.rent_own_ind := p1_a25;
    ddp_organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a26);
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_organization_rec.failure_score := p1_a28;
    ddp_organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a29);
    ddp_organization_rec.failure_score_override_code := p1_a30;
    ddp_organization_rec.failure_score_commentary := p1_a31;
    ddp_organization_rec.global_failure_score := p1_a32;
    ddp_organization_rec.db_rating := p1_a33;
    ddp_organization_rec.credit_score := p1_a34;
    ddp_organization_rec.credit_score_commentary := p1_a35;
    ddp_organization_rec.paydex_score := p1_a36;
    ddp_organization_rec.paydex_three_months_ago := p1_a37;
    ddp_organization_rec.paydex_norm := p1_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a40);
    ddp_organization_rec.organization_name_phonetic := p1_a41;
    ddp_organization_rec.tax_reference := p1_a42;
    ddp_organization_rec.gsa_indicator_flag := p1_a43;
    ddp_organization_rec.jgzz_fiscal_code := p1_a44;
    ddp_organization_rec.analysis_fy := p1_a45;
    ddp_organization_rec.fiscal_yearend_month := p1_a46;
    ddp_organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a47);
    ddp_organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a48);
    ddp_organization_rec.year_established := rosetta_g_miss_num_map(p1_a49);
    ddp_organization_rec.mission_statement := p1_a50;
    ddp_organization_rec.organization_type := p1_a51;
    ddp_organization_rec.business_scope := p1_a52;
    ddp_organization_rec.corporation_class := p1_a53;
    ddp_organization_rec.known_as := p1_a54;
    ddp_organization_rec.known_as2 := p1_a55;
    ddp_organization_rec.known_as3 := p1_a56;
    ddp_organization_rec.known_as4 := p1_a57;
    ddp_organization_rec.known_as5 := p1_a58;
    ddp_organization_rec.local_bus_iden_type := p1_a59;
    ddp_organization_rec.local_bus_identifier := p1_a60;
    ddp_organization_rec.pref_functional_currency := p1_a61;
    ddp_organization_rec.registration_type := p1_a62;
    ddp_organization_rec.total_employees_text := p1_a63;
    ddp_organization_rec.total_employees_ind := p1_a64;
    ddp_organization_rec.total_emp_est_ind := p1_a65;
    ddp_organization_rec.total_emp_min_ind := p1_a66;
    ddp_organization_rec.parent_sub_ind := p1_a67;
    ddp_organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a68);
    ddp_organization_rec.sic_code_type := p1_a69;
    ddp_organization_rec.public_private_ownership_flag := p1_a70;
    ddp_organization_rec.internal_flag := p1_a71;
    ddp_organization_rec.local_activity_code_type := p1_a72;
    ddp_organization_rec.local_activity_code := p1_a73;
    ddp_organization_rec.emp_at_primary_adr := p1_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p1_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p1_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p1_a77;
    ddp_organization_rec.high_credit := rosetta_g_miss_num_map(p1_a78);
    ddp_organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a79);
    ddp_organization_rec.total_payments := rosetta_g_miss_num_map(p1_a80);
    ddp_organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a81);
    ddp_organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a82);
    ddp_organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a83);
    ddp_organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a84);
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a85);
    ddp_organization_rec.credit_score_commentary2 := p1_a86;
    ddp_organization_rec.credit_score_commentary3 := p1_a87;
    ddp_organization_rec.credit_score_commentary4 := p1_a88;
    ddp_organization_rec.credit_score_commentary5 := p1_a89;
    ddp_organization_rec.credit_score_commentary6 := p1_a90;
    ddp_organization_rec.credit_score_commentary7 := p1_a91;
    ddp_organization_rec.credit_score_commentary8 := p1_a92;
    ddp_organization_rec.credit_score_commentary9 := p1_a93;
    ddp_organization_rec.credit_score_commentary10 := p1_a94;
    ddp_organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a95);
    ddp_organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a96);
    ddp_organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a97);
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a98);
    ddp_organization_rec.failure_score_commentary2 := p1_a99;
    ddp_organization_rec.failure_score_commentary3 := p1_a100;
    ddp_organization_rec.failure_score_commentary4 := p1_a101;
    ddp_organization_rec.failure_score_commentary5 := p1_a102;
    ddp_organization_rec.failure_score_commentary6 := p1_a103;
    ddp_organization_rec.failure_score_commentary7 := p1_a104;
    ddp_organization_rec.failure_score_commentary8 := p1_a105;
    ddp_organization_rec.failure_score_commentary9 := p1_a106;
    ddp_organization_rec.failure_score_commentary10 := p1_a107;
    ddp_organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a108);
    ddp_organization_rec.maximum_credit_currency_code := p1_a109;
    ddp_organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a110);
    ddp_organization_rec.content_source_type := p1_a111;
    ddp_organization_rec.content_source_number := p1_a112;
    ddp_organization_rec.attribute_category := p1_a113;
    ddp_organization_rec.attribute1 := p1_a114;
    ddp_organization_rec.attribute2 := p1_a115;
    ddp_organization_rec.attribute3 := p1_a116;
    ddp_organization_rec.attribute4 := p1_a117;
    ddp_organization_rec.attribute5 := p1_a118;
    ddp_organization_rec.attribute6 := p1_a119;
    ddp_organization_rec.attribute7 := p1_a120;
    ddp_organization_rec.attribute8 := p1_a121;
    ddp_organization_rec.attribute9 := p1_a122;
    ddp_organization_rec.attribute10 := p1_a123;
    ddp_organization_rec.attribute11 := p1_a124;
    ddp_organization_rec.attribute12 := p1_a125;
    ddp_organization_rec.attribute13 := p1_a126;
    ddp_organization_rec.attribute14 := p1_a127;
    ddp_organization_rec.attribute15 := p1_a128;
    ddp_organization_rec.attribute16 := p1_a129;
    ddp_organization_rec.attribute17 := p1_a130;
    ddp_organization_rec.attribute18 := p1_a131;
    ddp_organization_rec.attribute19 := p1_a132;
    ddp_organization_rec.attribute20 := p1_a133;
    ddp_organization_rec.created_by_module := p1_a134;
    ddp_organization_rec.application_id := rosetta_g_miss_num_map(p1_a135);
    ddp_organization_rec.do_not_confuse_with := p1_a136;
    ddp_organization_rec.actual_content_source := p1_a137;
    ddp_organization_rec.home_country := p1_a138;
    ddp_organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a139);
    ddp_organization_rec.party_rec.party_number := p1_a140;
    ddp_organization_rec.party_rec.validated_flag := p1_a141;
    ddp_organization_rec.party_rec.orig_system_reference := p1_a142;
    ddp_organization_rec.party_rec.orig_system := p1_a143;
    ddp_organization_rec.party_rec.status := p1_a144;
    ddp_organization_rec.party_rec.category_code := p1_a145;
    ddp_organization_rec.party_rec.salutation := p1_a146;
    ddp_organization_rec.party_rec.attribute_category := p1_a147;
    ddp_organization_rec.party_rec.attribute1 := p1_a148;
    ddp_organization_rec.party_rec.attribute2 := p1_a149;
    ddp_organization_rec.party_rec.attribute3 := p1_a150;
    ddp_organization_rec.party_rec.attribute4 := p1_a151;
    ddp_organization_rec.party_rec.attribute5 := p1_a152;
    ddp_organization_rec.party_rec.attribute6 := p1_a153;
    ddp_organization_rec.party_rec.attribute7 := p1_a154;
    ddp_organization_rec.party_rec.attribute8 := p1_a155;
    ddp_organization_rec.party_rec.attribute9 := p1_a156;
    ddp_organization_rec.party_rec.attribute10 := p1_a157;
    ddp_organization_rec.party_rec.attribute11 := p1_a158;
    ddp_organization_rec.party_rec.attribute12 := p1_a159;
    ddp_organization_rec.party_rec.attribute13 := p1_a160;
    ddp_organization_rec.party_rec.attribute14 := p1_a161;
    ddp_organization_rec.party_rec.attribute15 := p1_a162;
    ddp_organization_rec.party_rec.attribute16 := p1_a163;
    ddp_organization_rec.party_rec.attribute17 := p1_a164;
    ddp_organization_rec.party_rec.attribute18 := p1_a165;
    ddp_organization_rec.party_rec.attribute19 := p1_a166;
    ddp_organization_rec.party_rec.attribute20 := p1_a167;
    ddp_organization_rec.party_rec.attribute21 := p1_a168;
    ddp_organization_rec.party_rec.attribute22 := p1_a169;
    ddp_organization_rec.party_rec.attribute23 := p1_a170;
    ddp_organization_rec.party_rec.attribute24 := p1_a171;








    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.create_organization(p_init_msg_list,
      ddp_organization_rec,
      p_party_usage_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_party_id,
      x_party_number,
      x_profile_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_organization_8(p_init_msg_list  VARCHAR2
    , p_party_object_version_number in out nocopy  NUMBER
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
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  NUMBER := null
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
    , p1_a26  NUMBER := null
    , p1_a27  DATE := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  NUMBER := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  DATE := null
    , p1_a40  DATE := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  NUMBER := null
    , p1_a48  NUMBER := null
    , p1_a49  NUMBER := null
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
    , p1_a68  NUMBER := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  NUMBER := null
    , p1_a79  NUMBER := null
    , p1_a80  NUMBER := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  NUMBER := null
    , p1_a84  NUMBER := null
    , p1_a85  DATE := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  NUMBER := null
    , p1_a96  NUMBER := null
    , p1_a97  NUMBER := null
    , p1_a98  DATE := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  VARCHAR2 := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  VARCHAR2 := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  NUMBER := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  NUMBER := null
    , p1_a111  VARCHAR2 := null
    , p1_a112  VARCHAR2 := null
    , p1_a113  VARCHAR2 := null
    , p1_a114  VARCHAR2 := null
    , p1_a115  VARCHAR2 := null
    , p1_a116  VARCHAR2 := null
    , p1_a117  VARCHAR2 := null
    , p1_a118  VARCHAR2 := null
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
    , p1_a135  NUMBER := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  NUMBER := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  VARCHAR2 := null
    , p1_a142  VARCHAR2 := null
    , p1_a143  VARCHAR2 := null
    , p1_a144  VARCHAR2 := null
    , p1_a145  VARCHAR2 := null
    , p1_a146  VARCHAR2 := null
    , p1_a147  VARCHAR2 := null
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
  )
  as
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_organization_rec.organization_name := p1_a0;
    ddp_organization_rec.duns_number_c := p1_a1;
    ddp_organization_rec.enquiry_duns := p1_a2;
    ddp_organization_rec.ceo_name := p1_a3;
    ddp_organization_rec.ceo_title := p1_a4;
    ddp_organization_rec.principal_name := p1_a5;
    ddp_organization_rec.principal_title := p1_a6;
    ddp_organization_rec.legal_status := p1_a7;
    ddp_organization_rec.control_yr := rosetta_g_miss_num_map(p1_a8);
    ddp_organization_rec.employees_total := rosetta_g_miss_num_map(p1_a9);
    ddp_organization_rec.hq_branch_ind := p1_a10;
    ddp_organization_rec.branch_flag := p1_a11;
    ddp_organization_rec.oob_ind := p1_a12;
    ddp_organization_rec.line_of_business := p1_a13;
    ddp_organization_rec.cong_dist_code := p1_a14;
    ddp_organization_rec.sic_code := p1_a15;
    ddp_organization_rec.import_ind := p1_a16;
    ddp_organization_rec.export_ind := p1_a17;
    ddp_organization_rec.labor_surplus_ind := p1_a18;
    ddp_organization_rec.debarment_ind := p1_a19;
    ddp_organization_rec.minority_owned_ind := p1_a20;
    ddp_organization_rec.minority_owned_type := p1_a21;
    ddp_organization_rec.woman_owned_ind := p1_a22;
    ddp_organization_rec.disadv_8a_ind := p1_a23;
    ddp_organization_rec.small_bus_ind := p1_a24;
    ddp_organization_rec.rent_own_ind := p1_a25;
    ddp_organization_rec.debarments_count := rosetta_g_miss_num_map(p1_a26);
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_organization_rec.failure_score := p1_a28;
    ddp_organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a29);
    ddp_organization_rec.failure_score_override_code := p1_a30;
    ddp_organization_rec.failure_score_commentary := p1_a31;
    ddp_organization_rec.global_failure_score := p1_a32;
    ddp_organization_rec.db_rating := p1_a33;
    ddp_organization_rec.credit_score := p1_a34;
    ddp_organization_rec.credit_score_commentary := p1_a35;
    ddp_organization_rec.paydex_score := p1_a36;
    ddp_organization_rec.paydex_three_months_ago := p1_a37;
    ddp_organization_rec.paydex_norm := p1_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p1_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p1_a40);
    ddp_organization_rec.organization_name_phonetic := p1_a41;
    ddp_organization_rec.tax_reference := p1_a42;
    ddp_organization_rec.gsa_indicator_flag := p1_a43;
    ddp_organization_rec.jgzz_fiscal_code := p1_a44;
    ddp_organization_rec.analysis_fy := p1_a45;
    ddp_organization_rec.fiscal_yearend_month := p1_a46;
    ddp_organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p1_a47);
    ddp_organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p1_a48);
    ddp_organization_rec.year_established := rosetta_g_miss_num_map(p1_a49);
    ddp_organization_rec.mission_statement := p1_a50;
    ddp_organization_rec.organization_type := p1_a51;
    ddp_organization_rec.business_scope := p1_a52;
    ddp_organization_rec.corporation_class := p1_a53;
    ddp_organization_rec.known_as := p1_a54;
    ddp_organization_rec.known_as2 := p1_a55;
    ddp_organization_rec.known_as3 := p1_a56;
    ddp_organization_rec.known_as4 := p1_a57;
    ddp_organization_rec.known_as5 := p1_a58;
    ddp_organization_rec.local_bus_iden_type := p1_a59;
    ddp_organization_rec.local_bus_identifier := p1_a60;
    ddp_organization_rec.pref_functional_currency := p1_a61;
    ddp_organization_rec.registration_type := p1_a62;
    ddp_organization_rec.total_employees_text := p1_a63;
    ddp_organization_rec.total_employees_ind := p1_a64;
    ddp_organization_rec.total_emp_est_ind := p1_a65;
    ddp_organization_rec.total_emp_min_ind := p1_a66;
    ddp_organization_rec.parent_sub_ind := p1_a67;
    ddp_organization_rec.incorp_year := rosetta_g_miss_num_map(p1_a68);
    ddp_organization_rec.sic_code_type := p1_a69;
    ddp_organization_rec.public_private_ownership_flag := p1_a70;
    ddp_organization_rec.internal_flag := p1_a71;
    ddp_organization_rec.local_activity_code_type := p1_a72;
    ddp_organization_rec.local_activity_code := p1_a73;
    ddp_organization_rec.emp_at_primary_adr := p1_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p1_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p1_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p1_a77;
    ddp_organization_rec.high_credit := rosetta_g_miss_num_map(p1_a78);
    ddp_organization_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a79);
    ddp_organization_rec.total_payments := rosetta_g_miss_num_map(p1_a80);
    ddp_organization_rec.credit_score_class := rosetta_g_miss_num_map(p1_a81);
    ddp_organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a82);
    ddp_organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a83);
    ddp_organization_rec.credit_score_age := rosetta_g_miss_num_map(p1_a84);
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a85);
    ddp_organization_rec.credit_score_commentary2 := p1_a86;
    ddp_organization_rec.credit_score_commentary3 := p1_a87;
    ddp_organization_rec.credit_score_commentary4 := p1_a88;
    ddp_organization_rec.credit_score_commentary5 := p1_a89;
    ddp_organization_rec.credit_score_commentary6 := p1_a90;
    ddp_organization_rec.credit_score_commentary7 := p1_a91;
    ddp_organization_rec.credit_score_commentary8 := p1_a92;
    ddp_organization_rec.credit_score_commentary9 := p1_a93;
    ddp_organization_rec.credit_score_commentary10 := p1_a94;
    ddp_organization_rec.failure_score_class := rosetta_g_miss_num_map(p1_a95);
    ddp_organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a96);
    ddp_organization_rec.failure_score_age := rosetta_g_miss_num_map(p1_a97);
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a98);
    ddp_organization_rec.failure_score_commentary2 := p1_a99;
    ddp_organization_rec.failure_score_commentary3 := p1_a100;
    ddp_organization_rec.failure_score_commentary4 := p1_a101;
    ddp_organization_rec.failure_score_commentary5 := p1_a102;
    ddp_organization_rec.failure_score_commentary6 := p1_a103;
    ddp_organization_rec.failure_score_commentary7 := p1_a104;
    ddp_organization_rec.failure_score_commentary8 := p1_a105;
    ddp_organization_rec.failure_score_commentary9 := p1_a106;
    ddp_organization_rec.failure_score_commentary10 := p1_a107;
    ddp_organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p1_a108);
    ddp_organization_rec.maximum_credit_currency_code := p1_a109;
    ddp_organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p1_a110);
    ddp_organization_rec.content_source_type := p1_a111;
    ddp_organization_rec.content_source_number := p1_a112;
    ddp_organization_rec.attribute_category := p1_a113;
    ddp_organization_rec.attribute1 := p1_a114;
    ddp_organization_rec.attribute2 := p1_a115;
    ddp_organization_rec.attribute3 := p1_a116;
    ddp_organization_rec.attribute4 := p1_a117;
    ddp_organization_rec.attribute5 := p1_a118;
    ddp_organization_rec.attribute6 := p1_a119;
    ddp_organization_rec.attribute7 := p1_a120;
    ddp_organization_rec.attribute8 := p1_a121;
    ddp_organization_rec.attribute9 := p1_a122;
    ddp_organization_rec.attribute10 := p1_a123;
    ddp_organization_rec.attribute11 := p1_a124;
    ddp_organization_rec.attribute12 := p1_a125;
    ddp_organization_rec.attribute13 := p1_a126;
    ddp_organization_rec.attribute14 := p1_a127;
    ddp_organization_rec.attribute15 := p1_a128;
    ddp_organization_rec.attribute16 := p1_a129;
    ddp_organization_rec.attribute17 := p1_a130;
    ddp_organization_rec.attribute18 := p1_a131;
    ddp_organization_rec.attribute19 := p1_a132;
    ddp_organization_rec.attribute20 := p1_a133;
    ddp_organization_rec.created_by_module := p1_a134;
    ddp_organization_rec.application_id := rosetta_g_miss_num_map(p1_a135);
    ddp_organization_rec.do_not_confuse_with := p1_a136;
    ddp_organization_rec.actual_content_source := p1_a137;
    ddp_organization_rec.home_country := p1_a138;
    ddp_organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a139);
    ddp_organization_rec.party_rec.party_number := p1_a140;
    ddp_organization_rec.party_rec.validated_flag := p1_a141;
    ddp_organization_rec.party_rec.orig_system_reference := p1_a142;
    ddp_organization_rec.party_rec.orig_system := p1_a143;
    ddp_organization_rec.party_rec.status := p1_a144;
    ddp_organization_rec.party_rec.category_code := p1_a145;
    ddp_organization_rec.party_rec.salutation := p1_a146;
    ddp_organization_rec.party_rec.attribute_category := p1_a147;
    ddp_organization_rec.party_rec.attribute1 := p1_a148;
    ddp_organization_rec.party_rec.attribute2 := p1_a149;
    ddp_organization_rec.party_rec.attribute3 := p1_a150;
    ddp_organization_rec.party_rec.attribute4 := p1_a151;
    ddp_organization_rec.party_rec.attribute5 := p1_a152;
    ddp_organization_rec.party_rec.attribute6 := p1_a153;
    ddp_organization_rec.party_rec.attribute7 := p1_a154;
    ddp_organization_rec.party_rec.attribute8 := p1_a155;
    ddp_organization_rec.party_rec.attribute9 := p1_a156;
    ddp_organization_rec.party_rec.attribute10 := p1_a157;
    ddp_organization_rec.party_rec.attribute11 := p1_a158;
    ddp_organization_rec.party_rec.attribute12 := p1_a159;
    ddp_organization_rec.party_rec.attribute13 := p1_a160;
    ddp_organization_rec.party_rec.attribute14 := p1_a161;
    ddp_organization_rec.party_rec.attribute15 := p1_a162;
    ddp_organization_rec.party_rec.attribute16 := p1_a163;
    ddp_organization_rec.party_rec.attribute17 := p1_a164;
    ddp_organization_rec.party_rec.attribute18 := p1_a165;
    ddp_organization_rec.party_rec.attribute19 := p1_a166;
    ddp_organization_rec.party_rec.attribute20 := p1_a167;
    ddp_organization_rec.party_rec.attribute21 := p1_a168;
    ddp_organization_rec.party_rec.attribute22 := p1_a169;
    ddp_organization_rec.party_rec.attribute23 := p1_a170;
    ddp_organization_rec.party_rec.attribute24 := p1_a171;






    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.update_organization(p_init_msg_list,
      ddp_organization_rec,
      p_party_object_version_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure get_party_rec_9(p_init_msg_list  VARCHAR2
    , p_party_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_party_rec hz_party_v2pub.party_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.get_party_rec(p_init_msg_list,
      p_party_id,
      ddx_party_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_party_rec.party_id);
    p2_a1 := ddx_party_rec.party_number;
    p2_a2 := ddx_party_rec.validated_flag;
    p2_a3 := ddx_party_rec.orig_system_reference;
    p2_a4 := ddx_party_rec.orig_system;
    p2_a5 := ddx_party_rec.status;
    p2_a6 := ddx_party_rec.category_code;
    p2_a7 := ddx_party_rec.salutation;
    p2_a8 := ddx_party_rec.attribute_category;
    p2_a9 := ddx_party_rec.attribute1;
    p2_a10 := ddx_party_rec.attribute2;
    p2_a11 := ddx_party_rec.attribute3;
    p2_a12 := ddx_party_rec.attribute4;
    p2_a13 := ddx_party_rec.attribute5;
    p2_a14 := ddx_party_rec.attribute6;
    p2_a15 := ddx_party_rec.attribute7;
    p2_a16 := ddx_party_rec.attribute8;
    p2_a17 := ddx_party_rec.attribute9;
    p2_a18 := ddx_party_rec.attribute10;
    p2_a19 := ddx_party_rec.attribute11;
    p2_a20 := ddx_party_rec.attribute12;
    p2_a21 := ddx_party_rec.attribute13;
    p2_a22 := ddx_party_rec.attribute14;
    p2_a23 := ddx_party_rec.attribute15;
    p2_a24 := ddx_party_rec.attribute16;
    p2_a25 := ddx_party_rec.attribute17;
    p2_a26 := ddx_party_rec.attribute18;
    p2_a27 := ddx_party_rec.attribute19;
    p2_a28 := ddx_party_rec.attribute20;
    p2_a29 := ddx_party_rec.attribute21;
    p2_a30 := ddx_party_rec.attribute22;
    p2_a31 := ddx_party_rec.attribute23;
    p2_a32 := ddx_party_rec.attribute24;



  end;

  procedure get_organization_rec_10(p_init_msg_list  VARCHAR2
    , p_party_id  NUMBER
    , p_content_source_type  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  NUMBER
    , p3_a27 out nocopy  DATE
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  NUMBER
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  VARCHAR2
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  VARCHAR2
    , p3_a37 out nocopy  VARCHAR2
    , p3_a38 out nocopy  VARCHAR2
    , p3_a39 out nocopy  DATE
    , p3_a40 out nocopy  DATE
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  VARCHAR2
    , p3_a43 out nocopy  VARCHAR2
    , p3_a44 out nocopy  VARCHAR2
    , p3_a45 out nocopy  VARCHAR2
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  NUMBER
    , p3_a48 out nocopy  NUMBER
    , p3_a49 out nocopy  NUMBER
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  VARCHAR2
    , p3_a52 out nocopy  VARCHAR2
    , p3_a53 out nocopy  VARCHAR2
    , p3_a54 out nocopy  VARCHAR2
    , p3_a55 out nocopy  VARCHAR2
    , p3_a56 out nocopy  VARCHAR2
    , p3_a57 out nocopy  VARCHAR2
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  VARCHAR2
    , p3_a60 out nocopy  VARCHAR2
    , p3_a61 out nocopy  VARCHAR2
    , p3_a62 out nocopy  VARCHAR2
    , p3_a63 out nocopy  VARCHAR2
    , p3_a64 out nocopy  VARCHAR2
    , p3_a65 out nocopy  VARCHAR2
    , p3_a66 out nocopy  VARCHAR2
    , p3_a67 out nocopy  VARCHAR2
    , p3_a68 out nocopy  NUMBER
    , p3_a69 out nocopy  VARCHAR2
    , p3_a70 out nocopy  VARCHAR2
    , p3_a71 out nocopy  VARCHAR2
    , p3_a72 out nocopy  VARCHAR2
    , p3_a73 out nocopy  VARCHAR2
    , p3_a74 out nocopy  VARCHAR2
    , p3_a75 out nocopy  VARCHAR2
    , p3_a76 out nocopy  VARCHAR2
    , p3_a77 out nocopy  VARCHAR2
    , p3_a78 out nocopy  NUMBER
    , p3_a79 out nocopy  NUMBER
    , p3_a80 out nocopy  NUMBER
    , p3_a81 out nocopy  NUMBER
    , p3_a82 out nocopy  NUMBER
    , p3_a83 out nocopy  NUMBER
    , p3_a84 out nocopy  NUMBER
    , p3_a85 out nocopy  DATE
    , p3_a86 out nocopy  VARCHAR2
    , p3_a87 out nocopy  VARCHAR2
    , p3_a88 out nocopy  VARCHAR2
    , p3_a89 out nocopy  VARCHAR2
    , p3_a90 out nocopy  VARCHAR2
    , p3_a91 out nocopy  VARCHAR2
    , p3_a92 out nocopy  VARCHAR2
    , p3_a93 out nocopy  VARCHAR2
    , p3_a94 out nocopy  VARCHAR2
    , p3_a95 out nocopy  NUMBER
    , p3_a96 out nocopy  NUMBER
    , p3_a97 out nocopy  NUMBER
    , p3_a98 out nocopy  DATE
    , p3_a99 out nocopy  VARCHAR2
    , p3_a100 out nocopy  VARCHAR2
    , p3_a101 out nocopy  VARCHAR2
    , p3_a102 out nocopy  VARCHAR2
    , p3_a103 out nocopy  VARCHAR2
    , p3_a104 out nocopy  VARCHAR2
    , p3_a105 out nocopy  VARCHAR2
    , p3_a106 out nocopy  VARCHAR2
    , p3_a107 out nocopy  VARCHAR2
    , p3_a108 out nocopy  NUMBER
    , p3_a109 out nocopy  VARCHAR2
    , p3_a110 out nocopy  NUMBER
    , p3_a111 out nocopy  VARCHAR2
    , p3_a112 out nocopy  VARCHAR2
    , p3_a113 out nocopy  VARCHAR2
    , p3_a114 out nocopy  VARCHAR2
    , p3_a115 out nocopy  VARCHAR2
    , p3_a116 out nocopy  VARCHAR2
    , p3_a117 out nocopy  VARCHAR2
    , p3_a118 out nocopy  VARCHAR2
    , p3_a119 out nocopy  VARCHAR2
    , p3_a120 out nocopy  VARCHAR2
    , p3_a121 out nocopy  VARCHAR2
    , p3_a122 out nocopy  VARCHAR2
    , p3_a123 out nocopy  VARCHAR2
    , p3_a124 out nocopy  VARCHAR2
    , p3_a125 out nocopy  VARCHAR2
    , p3_a126 out nocopy  VARCHAR2
    , p3_a127 out nocopy  VARCHAR2
    , p3_a128 out nocopy  VARCHAR2
    , p3_a129 out nocopy  VARCHAR2
    , p3_a130 out nocopy  VARCHAR2
    , p3_a131 out nocopy  VARCHAR2
    , p3_a132 out nocopy  VARCHAR2
    , p3_a133 out nocopy  VARCHAR2
    , p3_a134 out nocopy  VARCHAR2
    , p3_a135 out nocopy  NUMBER
    , p3_a136 out nocopy  VARCHAR2
    , p3_a137 out nocopy  VARCHAR2
    , p3_a138 out nocopy  VARCHAR2
    , p3_a139 out nocopy  NUMBER
    , p3_a140 out nocopy  VARCHAR2
    , p3_a141 out nocopy  VARCHAR2
    , p3_a142 out nocopy  VARCHAR2
    , p3_a143 out nocopy  VARCHAR2
    , p3_a144 out nocopy  VARCHAR2
    , p3_a145 out nocopy  VARCHAR2
    , p3_a146 out nocopy  VARCHAR2
    , p3_a147 out nocopy  VARCHAR2
    , p3_a148 out nocopy  VARCHAR2
    , p3_a149 out nocopy  VARCHAR2
    , p3_a150 out nocopy  VARCHAR2
    , p3_a151 out nocopy  VARCHAR2
    , p3_a152 out nocopy  VARCHAR2
    , p3_a153 out nocopy  VARCHAR2
    , p3_a154 out nocopy  VARCHAR2
    , p3_a155 out nocopy  VARCHAR2
    , p3_a156 out nocopy  VARCHAR2
    , p3_a157 out nocopy  VARCHAR2
    , p3_a158 out nocopy  VARCHAR2
    , p3_a159 out nocopy  VARCHAR2
    , p3_a160 out nocopy  VARCHAR2
    , p3_a161 out nocopy  VARCHAR2
    , p3_a162 out nocopy  VARCHAR2
    , p3_a163 out nocopy  VARCHAR2
    , p3_a164 out nocopy  VARCHAR2
    , p3_a165 out nocopy  VARCHAR2
    , p3_a166 out nocopy  VARCHAR2
    , p3_a167 out nocopy  VARCHAR2
    , p3_a168 out nocopy  VARCHAR2
    , p3_a169 out nocopy  VARCHAR2
    , p3_a170 out nocopy  VARCHAR2
    , p3_a171 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_organization_rec hz_party_v2pub.organization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.get_organization_rec(p_init_msg_list,
      p_party_id,
      p_content_source_type,
      ddx_organization_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any



    p3_a0 := ddx_organization_rec.organization_name;
    p3_a1 := ddx_organization_rec.duns_number_c;
    p3_a2 := ddx_organization_rec.enquiry_duns;
    p3_a3 := ddx_organization_rec.ceo_name;
    p3_a4 := ddx_organization_rec.ceo_title;
    p3_a5 := ddx_organization_rec.principal_name;
    p3_a6 := ddx_organization_rec.principal_title;
    p3_a7 := ddx_organization_rec.legal_status;
    p3_a8 := rosetta_g_miss_num_map(ddx_organization_rec.control_yr);
    p3_a9 := rosetta_g_miss_num_map(ddx_organization_rec.employees_total);
    p3_a10 := ddx_organization_rec.hq_branch_ind;
    p3_a11 := ddx_organization_rec.branch_flag;
    p3_a12 := ddx_organization_rec.oob_ind;
    p3_a13 := ddx_organization_rec.line_of_business;
    p3_a14 := ddx_organization_rec.cong_dist_code;
    p3_a15 := ddx_organization_rec.sic_code;
    p3_a16 := ddx_organization_rec.import_ind;
    p3_a17 := ddx_organization_rec.export_ind;
    p3_a18 := ddx_organization_rec.labor_surplus_ind;
    p3_a19 := ddx_organization_rec.debarment_ind;
    p3_a20 := ddx_organization_rec.minority_owned_ind;
    p3_a21 := ddx_organization_rec.minority_owned_type;
    p3_a22 := ddx_organization_rec.woman_owned_ind;
    p3_a23 := ddx_organization_rec.disadv_8a_ind;
    p3_a24 := ddx_organization_rec.small_bus_ind;
    p3_a25 := ddx_organization_rec.rent_own_ind;
    p3_a26 := rosetta_g_miss_num_map(ddx_organization_rec.debarments_count);
    p3_a27 := ddx_organization_rec.debarments_date;
    p3_a28 := ddx_organization_rec.failure_score;
    p3_a29 := rosetta_g_miss_num_map(ddx_organization_rec.failure_score_natnl_percentile);
    p3_a30 := ddx_organization_rec.failure_score_override_code;
    p3_a31 := ddx_organization_rec.failure_score_commentary;
    p3_a32 := ddx_organization_rec.global_failure_score;
    p3_a33 := ddx_organization_rec.db_rating;
    p3_a34 := ddx_organization_rec.credit_score;
    p3_a35 := ddx_organization_rec.credit_score_commentary;
    p3_a36 := ddx_organization_rec.paydex_score;
    p3_a37 := ddx_organization_rec.paydex_three_months_ago;
    p3_a38 := ddx_organization_rec.paydex_norm;
    p3_a39 := ddx_organization_rec.best_time_contact_begin;
    p3_a40 := ddx_organization_rec.best_time_contact_end;
    p3_a41 := ddx_organization_rec.organization_name_phonetic;
    p3_a42 := ddx_organization_rec.tax_reference;
    p3_a43 := ddx_organization_rec.gsa_indicator_flag;
    p3_a44 := ddx_organization_rec.jgzz_fiscal_code;
    p3_a45 := ddx_organization_rec.analysis_fy;
    p3_a46 := ddx_organization_rec.fiscal_yearend_month;
    p3_a47 := rosetta_g_miss_num_map(ddx_organization_rec.curr_fy_potential_revenue);
    p3_a48 := rosetta_g_miss_num_map(ddx_organization_rec.next_fy_potential_revenue);
    p3_a49 := rosetta_g_miss_num_map(ddx_organization_rec.year_established);
    p3_a50 := ddx_organization_rec.mission_statement;
    p3_a51 := ddx_organization_rec.organization_type;
    p3_a52 := ddx_organization_rec.business_scope;
    p3_a53 := ddx_organization_rec.corporation_class;
    p3_a54 := ddx_organization_rec.known_as;
    p3_a55 := ddx_organization_rec.known_as2;
    p3_a56 := ddx_organization_rec.known_as3;
    p3_a57 := ddx_organization_rec.known_as4;
    p3_a58 := ddx_organization_rec.known_as5;
    p3_a59 := ddx_organization_rec.local_bus_iden_type;
    p3_a60 := ddx_organization_rec.local_bus_identifier;
    p3_a61 := ddx_organization_rec.pref_functional_currency;
    p3_a62 := ddx_organization_rec.registration_type;
    p3_a63 := ddx_organization_rec.total_employees_text;
    p3_a64 := ddx_organization_rec.total_employees_ind;
    p3_a65 := ddx_organization_rec.total_emp_est_ind;
    p3_a66 := ddx_organization_rec.total_emp_min_ind;
    p3_a67 := ddx_organization_rec.parent_sub_ind;
    p3_a68 := rosetta_g_miss_num_map(ddx_organization_rec.incorp_year);
    p3_a69 := ddx_organization_rec.sic_code_type;
    p3_a70 := ddx_organization_rec.public_private_ownership_flag;
    p3_a71 := ddx_organization_rec.internal_flag;
    p3_a72 := ddx_organization_rec.local_activity_code_type;
    p3_a73 := ddx_organization_rec.local_activity_code;
    p3_a74 := ddx_organization_rec.emp_at_primary_adr;
    p3_a75 := ddx_organization_rec.emp_at_primary_adr_text;
    p3_a76 := ddx_organization_rec.emp_at_primary_adr_est_ind;
    p3_a77 := ddx_organization_rec.emp_at_primary_adr_min_ind;
    p3_a78 := rosetta_g_miss_num_map(ddx_organization_rec.high_credit);
    p3_a79 := rosetta_g_miss_num_map(ddx_organization_rec.avg_high_credit);
    p3_a80 := rosetta_g_miss_num_map(ddx_organization_rec.total_payments);
    p3_a81 := rosetta_g_miss_num_map(ddx_organization_rec.credit_score_class);
    p3_a82 := rosetta_g_miss_num_map(ddx_organization_rec.credit_score_natl_percentile);
    p3_a83 := rosetta_g_miss_num_map(ddx_organization_rec.credit_score_incd_default);
    p3_a84 := rosetta_g_miss_num_map(ddx_organization_rec.credit_score_age);
    p3_a85 := ddx_organization_rec.credit_score_date;
    p3_a86 := ddx_organization_rec.credit_score_commentary2;
    p3_a87 := ddx_organization_rec.credit_score_commentary3;
    p3_a88 := ddx_organization_rec.credit_score_commentary4;
    p3_a89 := ddx_organization_rec.credit_score_commentary5;
    p3_a90 := ddx_organization_rec.credit_score_commentary6;
    p3_a91 := ddx_organization_rec.credit_score_commentary7;
    p3_a92 := ddx_organization_rec.credit_score_commentary8;
    p3_a93 := ddx_organization_rec.credit_score_commentary9;
    p3_a94 := ddx_organization_rec.credit_score_commentary10;
    p3_a95 := rosetta_g_miss_num_map(ddx_organization_rec.failure_score_class);
    p3_a96 := rosetta_g_miss_num_map(ddx_organization_rec.failure_score_incd_default);
    p3_a97 := rosetta_g_miss_num_map(ddx_organization_rec.failure_score_age);
    p3_a98 := ddx_organization_rec.failure_score_date;
    p3_a99 := ddx_organization_rec.failure_score_commentary2;
    p3_a100 := ddx_organization_rec.failure_score_commentary3;
    p3_a101 := ddx_organization_rec.failure_score_commentary4;
    p3_a102 := ddx_organization_rec.failure_score_commentary5;
    p3_a103 := ddx_organization_rec.failure_score_commentary6;
    p3_a104 := ddx_organization_rec.failure_score_commentary7;
    p3_a105 := ddx_organization_rec.failure_score_commentary8;
    p3_a106 := ddx_organization_rec.failure_score_commentary9;
    p3_a107 := ddx_organization_rec.failure_score_commentary10;
    p3_a108 := rosetta_g_miss_num_map(ddx_organization_rec.maximum_credit_recommendation);
    p3_a109 := ddx_organization_rec.maximum_credit_currency_code;
    p3_a110 := rosetta_g_miss_num_map(ddx_organization_rec.displayed_duns_party_id);
    p3_a111 := ddx_organization_rec.content_source_type;
    p3_a112 := ddx_organization_rec.content_source_number;
    p3_a113 := ddx_organization_rec.attribute_category;
    p3_a114 := ddx_organization_rec.attribute1;
    p3_a115 := ddx_organization_rec.attribute2;
    p3_a116 := ddx_organization_rec.attribute3;
    p3_a117 := ddx_organization_rec.attribute4;
    p3_a118 := ddx_organization_rec.attribute5;
    p3_a119 := ddx_organization_rec.attribute6;
    p3_a120 := ddx_organization_rec.attribute7;
    p3_a121 := ddx_organization_rec.attribute8;
    p3_a122 := ddx_organization_rec.attribute9;
    p3_a123 := ddx_organization_rec.attribute10;
    p3_a124 := ddx_organization_rec.attribute11;
    p3_a125 := ddx_organization_rec.attribute12;
    p3_a126 := ddx_organization_rec.attribute13;
    p3_a127 := ddx_organization_rec.attribute14;
    p3_a128 := ddx_organization_rec.attribute15;
    p3_a129 := ddx_organization_rec.attribute16;
    p3_a130 := ddx_organization_rec.attribute17;
    p3_a131 := ddx_organization_rec.attribute18;
    p3_a132 := ddx_organization_rec.attribute19;
    p3_a133 := ddx_organization_rec.attribute20;
    p3_a134 := ddx_organization_rec.created_by_module;
    p3_a135 := rosetta_g_miss_num_map(ddx_organization_rec.application_id);
    p3_a136 := ddx_organization_rec.do_not_confuse_with;
    p3_a137 := ddx_organization_rec.actual_content_source;
    p3_a138 := ddx_organization_rec.home_country;
    p3_a139 := rosetta_g_miss_num_map(ddx_organization_rec.party_rec.party_id);
    p3_a140 := ddx_organization_rec.party_rec.party_number;
    p3_a141 := ddx_organization_rec.party_rec.validated_flag;
    p3_a142 := ddx_organization_rec.party_rec.orig_system_reference;
    p3_a143 := ddx_organization_rec.party_rec.orig_system;
    p3_a144 := ddx_organization_rec.party_rec.status;
    p3_a145 := ddx_organization_rec.party_rec.category_code;
    p3_a146 := ddx_organization_rec.party_rec.salutation;
    p3_a147 := ddx_organization_rec.party_rec.attribute_category;
    p3_a148 := ddx_organization_rec.party_rec.attribute1;
    p3_a149 := ddx_organization_rec.party_rec.attribute2;
    p3_a150 := ddx_organization_rec.party_rec.attribute3;
    p3_a151 := ddx_organization_rec.party_rec.attribute4;
    p3_a152 := ddx_organization_rec.party_rec.attribute5;
    p3_a153 := ddx_organization_rec.party_rec.attribute6;
    p3_a154 := ddx_organization_rec.party_rec.attribute7;
    p3_a155 := ddx_organization_rec.party_rec.attribute8;
    p3_a156 := ddx_organization_rec.party_rec.attribute9;
    p3_a157 := ddx_organization_rec.party_rec.attribute10;
    p3_a158 := ddx_organization_rec.party_rec.attribute11;
    p3_a159 := ddx_organization_rec.party_rec.attribute12;
    p3_a160 := ddx_organization_rec.party_rec.attribute13;
    p3_a161 := ddx_organization_rec.party_rec.attribute14;
    p3_a162 := ddx_organization_rec.party_rec.attribute15;
    p3_a163 := ddx_organization_rec.party_rec.attribute16;
    p3_a164 := ddx_organization_rec.party_rec.attribute17;
    p3_a165 := ddx_organization_rec.party_rec.attribute18;
    p3_a166 := ddx_organization_rec.party_rec.attribute19;
    p3_a167 := ddx_organization_rec.party_rec.attribute20;
    p3_a168 := ddx_organization_rec.party_rec.attribute21;
    p3_a169 := ddx_organization_rec.party_rec.attribute22;
    p3_a170 := ddx_organization_rec.party_rec.attribute23;
    p3_a171 := ddx_organization_rec.party_rec.attribute24;



  end;

  procedure get_person_rec_11(p_init_msg_list  VARCHAR2
    , p_party_id  NUMBER
    , p_content_source_type  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  DATE
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  DATE
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  VARCHAR2
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  DATE
    , p3_a30 out nocopy  NUMBER
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  NUMBER
    , p3_a33 out nocopy  NUMBER
    , p3_a34 out nocopy  VARCHAR2
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  VARCHAR2
    , p3_a37 out nocopy  VARCHAR2
    , p3_a38 out nocopy  VARCHAR2
    , p3_a39 out nocopy  VARCHAR2
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  VARCHAR2
    , p3_a43 out nocopy  VARCHAR2
    , p3_a44 out nocopy  VARCHAR2
    , p3_a45 out nocopy  VARCHAR2
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  VARCHAR2
    , p3_a48 out nocopy  VARCHAR2
    , p3_a49 out nocopy  VARCHAR2
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  VARCHAR2
    , p3_a52 out nocopy  VARCHAR2
    , p3_a53 out nocopy  VARCHAR2
    , p3_a54 out nocopy  VARCHAR2
    , p3_a55 out nocopy  VARCHAR2
    , p3_a56 out nocopy  VARCHAR2
    , p3_a57 out nocopy  VARCHAR2
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  VARCHAR2
    , p3_a60 out nocopy  NUMBER
    , p3_a61 out nocopy  VARCHAR2
    , p3_a62 out nocopy  NUMBER
    , p3_a63 out nocopy  VARCHAR2
    , p3_a64 out nocopy  VARCHAR2
    , p3_a65 out nocopy  VARCHAR2
    , p3_a66 out nocopy  VARCHAR2
    , p3_a67 out nocopy  VARCHAR2
    , p3_a68 out nocopy  VARCHAR2
    , p3_a69 out nocopy  VARCHAR2
    , p3_a70 out nocopy  VARCHAR2
    , p3_a71 out nocopy  VARCHAR2
    , p3_a72 out nocopy  VARCHAR2
    , p3_a73 out nocopy  VARCHAR2
    , p3_a74 out nocopy  VARCHAR2
    , p3_a75 out nocopy  VARCHAR2
    , p3_a76 out nocopy  VARCHAR2
    , p3_a77 out nocopy  VARCHAR2
    , p3_a78 out nocopy  VARCHAR2
    , p3_a79 out nocopy  VARCHAR2
    , p3_a80 out nocopy  VARCHAR2
    , p3_a81 out nocopy  VARCHAR2
    , p3_a82 out nocopy  VARCHAR2
    , p3_a83 out nocopy  VARCHAR2
    , p3_a84 out nocopy  VARCHAR2
    , p3_a85 out nocopy  VARCHAR2
    , p3_a86 out nocopy  VARCHAR2
    , p3_a87 out nocopy  VARCHAR2
    , p3_a88 out nocopy  VARCHAR2
    , p3_a89 out nocopy  VARCHAR2
    , p3_a90 out nocopy  VARCHAR2
    , p3_a91 out nocopy  VARCHAR2
    , p3_a92 out nocopy  VARCHAR2
    , p3_a93 out nocopy  VARCHAR2
    , p3_a94 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_person_rec hz_party_v2pub.person_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.get_person_rec(p_init_msg_list,
      p_party_id,
      p_content_source_type,
      ddx_person_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any



    p3_a0 := ddx_person_rec.person_pre_name_adjunct;
    p3_a1 := ddx_person_rec.person_first_name;
    p3_a2 := ddx_person_rec.person_middle_name;
    p3_a3 := ddx_person_rec.person_last_name;
    p3_a4 := ddx_person_rec.person_name_suffix;
    p3_a5 := ddx_person_rec.person_title;
    p3_a6 := ddx_person_rec.person_academic_title;
    p3_a7 := ddx_person_rec.person_previous_last_name;
    p3_a8 := ddx_person_rec.person_initials;
    p3_a9 := ddx_person_rec.known_as;
    p3_a10 := ddx_person_rec.known_as2;
    p3_a11 := ddx_person_rec.known_as3;
    p3_a12 := ddx_person_rec.known_as4;
    p3_a13 := ddx_person_rec.known_as5;
    p3_a14 := ddx_person_rec.person_name_phonetic;
    p3_a15 := ddx_person_rec.person_first_name_phonetic;
    p3_a16 := ddx_person_rec.person_last_name_phonetic;
    p3_a17 := ddx_person_rec.middle_name_phonetic;
    p3_a18 := ddx_person_rec.tax_reference;
    p3_a19 := ddx_person_rec.jgzz_fiscal_code;
    p3_a20 := ddx_person_rec.person_iden_type;
    p3_a21 := ddx_person_rec.person_identifier;
    p3_a22 := ddx_person_rec.date_of_birth;
    p3_a23 := ddx_person_rec.place_of_birth;
    p3_a24 := ddx_person_rec.date_of_death;
    p3_a25 := ddx_person_rec.deceased_flag;
    p3_a26 := ddx_person_rec.gender;
    p3_a27 := ddx_person_rec.declared_ethnicity;
    p3_a28 := ddx_person_rec.marital_status;
    p3_a29 := ddx_person_rec.marital_status_effective_date;
    p3_a30 := rosetta_g_miss_num_map(ddx_person_rec.personal_income);
    p3_a31 := ddx_person_rec.head_of_household_flag;
    p3_a32 := rosetta_g_miss_num_map(ddx_person_rec.household_income);
    p3_a33 := rosetta_g_miss_num_map(ddx_person_rec.household_size);
    p3_a34 := ddx_person_rec.rent_own_ind;
    p3_a35 := ddx_person_rec.last_known_gps;
    p3_a36 := ddx_person_rec.content_source_type;
    p3_a37 := ddx_person_rec.internal_flag;
    p3_a38 := ddx_person_rec.attribute_category;
    p3_a39 := ddx_person_rec.attribute1;
    p3_a40 := ddx_person_rec.attribute2;
    p3_a41 := ddx_person_rec.attribute3;
    p3_a42 := ddx_person_rec.attribute4;
    p3_a43 := ddx_person_rec.attribute5;
    p3_a44 := ddx_person_rec.attribute6;
    p3_a45 := ddx_person_rec.attribute7;
    p3_a46 := ddx_person_rec.attribute8;
    p3_a47 := ddx_person_rec.attribute9;
    p3_a48 := ddx_person_rec.attribute10;
    p3_a49 := ddx_person_rec.attribute11;
    p3_a50 := ddx_person_rec.attribute12;
    p3_a51 := ddx_person_rec.attribute13;
    p3_a52 := ddx_person_rec.attribute14;
    p3_a53 := ddx_person_rec.attribute15;
    p3_a54 := ddx_person_rec.attribute16;
    p3_a55 := ddx_person_rec.attribute17;
    p3_a56 := ddx_person_rec.attribute18;
    p3_a57 := ddx_person_rec.attribute19;
    p3_a58 := ddx_person_rec.attribute20;
    p3_a59 := ddx_person_rec.created_by_module;
    p3_a60 := rosetta_g_miss_num_map(ddx_person_rec.application_id);
    p3_a61 := ddx_person_rec.actual_content_source;
    p3_a62 := rosetta_g_miss_num_map(ddx_person_rec.party_rec.party_id);
    p3_a63 := ddx_person_rec.party_rec.party_number;
    p3_a64 := ddx_person_rec.party_rec.validated_flag;
    p3_a65 := ddx_person_rec.party_rec.orig_system_reference;
    p3_a66 := ddx_person_rec.party_rec.orig_system;
    p3_a67 := ddx_person_rec.party_rec.status;
    p3_a68 := ddx_person_rec.party_rec.category_code;
    p3_a69 := ddx_person_rec.party_rec.salutation;
    p3_a70 := ddx_person_rec.party_rec.attribute_category;
    p3_a71 := ddx_person_rec.party_rec.attribute1;
    p3_a72 := ddx_person_rec.party_rec.attribute2;
    p3_a73 := ddx_person_rec.party_rec.attribute3;
    p3_a74 := ddx_person_rec.party_rec.attribute4;
    p3_a75 := ddx_person_rec.party_rec.attribute5;
    p3_a76 := ddx_person_rec.party_rec.attribute6;
    p3_a77 := ddx_person_rec.party_rec.attribute7;
    p3_a78 := ddx_person_rec.party_rec.attribute8;
    p3_a79 := ddx_person_rec.party_rec.attribute9;
    p3_a80 := ddx_person_rec.party_rec.attribute10;
    p3_a81 := ddx_person_rec.party_rec.attribute11;
    p3_a82 := ddx_person_rec.party_rec.attribute12;
    p3_a83 := ddx_person_rec.party_rec.attribute13;
    p3_a84 := ddx_person_rec.party_rec.attribute14;
    p3_a85 := ddx_person_rec.party_rec.attribute15;
    p3_a86 := ddx_person_rec.party_rec.attribute16;
    p3_a87 := ddx_person_rec.party_rec.attribute17;
    p3_a88 := ddx_person_rec.party_rec.attribute18;
    p3_a89 := ddx_person_rec.party_rec.attribute19;
    p3_a90 := ddx_person_rec.party_rec.attribute20;
    p3_a91 := ddx_person_rec.party_rec.attribute21;
    p3_a92 := ddx_person_rec.party_rec.attribute22;
    p3_a93 := ddx_person_rec.party_rec.attribute23;
    p3_a94 := ddx_person_rec.party_rec.attribute24;



  end;

  procedure get_group_rec_12(p_init_msg_list  VARCHAR2
    , p_party_id  NUMBER
    , p2_a0 out nocopy  VARCHAR2
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_group_rec hz_party_v2pub.group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_party_v2pub.get_group_rec(p_init_msg_list,
      p_party_id,
      ddx_group_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := ddx_group_rec.group_name;
    p2_a1 := ddx_group_rec.group_type;
    p2_a2 := ddx_group_rec.created_by_module;
    p2_a3 := ddx_group_rec.mission_statement;
    p2_a4 := rosetta_g_miss_num_map(ddx_group_rec.application_id);
    p2_a5 := rosetta_g_miss_num_map(ddx_group_rec.party_rec.party_id);
    p2_a6 := ddx_group_rec.party_rec.party_number;
    p2_a7 := ddx_group_rec.party_rec.validated_flag;
    p2_a8 := ddx_group_rec.party_rec.orig_system_reference;
    p2_a9 := ddx_group_rec.party_rec.orig_system;
    p2_a10 := ddx_group_rec.party_rec.status;
    p2_a11 := ddx_group_rec.party_rec.category_code;
    p2_a12 := ddx_group_rec.party_rec.salutation;
    p2_a13 := ddx_group_rec.party_rec.attribute_category;
    p2_a14 := ddx_group_rec.party_rec.attribute1;
    p2_a15 := ddx_group_rec.party_rec.attribute2;
    p2_a16 := ddx_group_rec.party_rec.attribute3;
    p2_a17 := ddx_group_rec.party_rec.attribute4;
    p2_a18 := ddx_group_rec.party_rec.attribute5;
    p2_a19 := ddx_group_rec.party_rec.attribute6;
    p2_a20 := ddx_group_rec.party_rec.attribute7;
    p2_a21 := ddx_group_rec.party_rec.attribute8;
    p2_a22 := ddx_group_rec.party_rec.attribute9;
    p2_a23 := ddx_group_rec.party_rec.attribute10;
    p2_a24 := ddx_group_rec.party_rec.attribute11;
    p2_a25 := ddx_group_rec.party_rec.attribute12;
    p2_a26 := ddx_group_rec.party_rec.attribute13;
    p2_a27 := ddx_group_rec.party_rec.attribute14;
    p2_a28 := ddx_group_rec.party_rec.attribute15;
    p2_a29 := ddx_group_rec.party_rec.attribute16;
    p2_a30 := ddx_group_rec.party_rec.attribute17;
    p2_a31 := ddx_group_rec.party_rec.attribute18;
    p2_a32 := ddx_group_rec.party_rec.attribute19;
    p2_a33 := ddx_group_rec.party_rec.attribute20;
    p2_a34 := ddx_group_rec.party_rec.attribute21;
    p2_a35 := ddx_group_rec.party_rec.attribute22;
    p2_a36 := ddx_group_rec.party_rec.attribute23;
    p2_a37 := ddx_group_rec.party_rec.attribute24;



  end;

end hz_party_v2pub_jw;

/
