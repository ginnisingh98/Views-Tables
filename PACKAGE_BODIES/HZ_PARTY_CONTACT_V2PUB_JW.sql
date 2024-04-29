--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_CONTACT_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_CONTACT_V2PUB_JW" as
  /* $Header: ARH2PCJB.pls 120.3 2005/06/18 04:28:49 jhuang noship $ */
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

  procedure create_org_contact_1(p_init_msg_list  VARCHAR2
    , x_org_contact_id out nocopy  NUMBER
    , x_party_rel_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
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
    , p1_a11  NUMBER := null
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
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  NUMBER := null
    , p1_a41  NUMBER := null
    , p1_a42  NUMBER := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  NUMBER := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  DATE := null
    , p1_a52  DATE := null
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
    , p1_a77  NUMBER := null
    , p1_a78  NUMBER := null
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
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  VARCHAR2 := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  VARCHAR2 := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
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
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  NUMBER := null
    , p1_a142  VARCHAR2 := null
  )
  as
    ddp_org_contact_rec hz_party_contact_v2pub.org_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_org_contact_rec.org_contact_id := rosetta_g_miss_num_map(p1_a0);
    ddp_org_contact_rec.comments := p1_a1;
    ddp_org_contact_rec.contact_number := p1_a2;
    ddp_org_contact_rec.department_code := p1_a3;
    ddp_org_contact_rec.department := p1_a4;
    ddp_org_contact_rec.title := p1_a5;
    ddp_org_contact_rec.job_title := p1_a6;
    ddp_org_contact_rec.decision_maker_flag := p1_a7;
    ddp_org_contact_rec.job_title_code := p1_a8;
    ddp_org_contact_rec.reference_use_flag := p1_a9;
    ddp_org_contact_rec.rank := p1_a10;
    ddp_org_contact_rec.party_site_id := rosetta_g_miss_num_map(p1_a11);
    ddp_org_contact_rec.orig_system_reference := p1_a12;
    ddp_org_contact_rec.orig_system := p1_a13;
    ddp_org_contact_rec.attribute_category := p1_a14;
    ddp_org_contact_rec.attribute1 := p1_a15;
    ddp_org_contact_rec.attribute2 := p1_a16;
    ddp_org_contact_rec.attribute3 := p1_a17;
    ddp_org_contact_rec.attribute4 := p1_a18;
    ddp_org_contact_rec.attribute5 := p1_a19;
    ddp_org_contact_rec.attribute6 := p1_a20;
    ddp_org_contact_rec.attribute7 := p1_a21;
    ddp_org_contact_rec.attribute8 := p1_a22;
    ddp_org_contact_rec.attribute9 := p1_a23;
    ddp_org_contact_rec.attribute10 := p1_a24;
    ddp_org_contact_rec.attribute11 := p1_a25;
    ddp_org_contact_rec.attribute12 := p1_a26;
    ddp_org_contact_rec.attribute13 := p1_a27;
    ddp_org_contact_rec.attribute14 := p1_a28;
    ddp_org_contact_rec.attribute15 := p1_a29;
    ddp_org_contact_rec.attribute16 := p1_a30;
    ddp_org_contact_rec.attribute17 := p1_a31;
    ddp_org_contact_rec.attribute18 := p1_a32;
    ddp_org_contact_rec.attribute19 := p1_a33;
    ddp_org_contact_rec.attribute20 := p1_a34;
    ddp_org_contact_rec.attribute21 := p1_a35;
    ddp_org_contact_rec.attribute22 := p1_a36;
    ddp_org_contact_rec.attribute23 := p1_a37;
    ddp_org_contact_rec.attribute24 := p1_a38;
    ddp_org_contact_rec.created_by_module := p1_a39;
    ddp_org_contact_rec.application_id := rosetta_g_miss_num_map(p1_a40);
    ddp_org_contact_rec.party_rel_rec.relationship_id := rosetta_g_miss_num_map(p1_a41);
    ddp_org_contact_rec.party_rel_rec.subject_id := rosetta_g_miss_num_map(p1_a42);
    ddp_org_contact_rec.party_rel_rec.subject_type := p1_a43;
    ddp_org_contact_rec.party_rel_rec.subject_table_name := p1_a44;
    ddp_org_contact_rec.party_rel_rec.object_id := rosetta_g_miss_num_map(p1_a45);
    ddp_org_contact_rec.party_rel_rec.object_type := p1_a46;
    ddp_org_contact_rec.party_rel_rec.object_table_name := p1_a47;
    ddp_org_contact_rec.party_rel_rec.relationship_code := p1_a48;
    ddp_org_contact_rec.party_rel_rec.relationship_type := p1_a49;
    ddp_org_contact_rec.party_rel_rec.comments := p1_a50;
    ddp_org_contact_rec.party_rel_rec.start_date := rosetta_g_miss_date_in_map(p1_a51);
    ddp_org_contact_rec.party_rel_rec.end_date := rosetta_g_miss_date_in_map(p1_a52);
    ddp_org_contact_rec.party_rel_rec.status := p1_a53;
    ddp_org_contact_rec.party_rel_rec.content_source_type := p1_a54;
    ddp_org_contact_rec.party_rel_rec.attribute_category := p1_a55;
    ddp_org_contact_rec.party_rel_rec.attribute1 := p1_a56;
    ddp_org_contact_rec.party_rel_rec.attribute2 := p1_a57;
    ddp_org_contact_rec.party_rel_rec.attribute3 := p1_a58;
    ddp_org_contact_rec.party_rel_rec.attribute4 := p1_a59;
    ddp_org_contact_rec.party_rel_rec.attribute5 := p1_a60;
    ddp_org_contact_rec.party_rel_rec.attribute6 := p1_a61;
    ddp_org_contact_rec.party_rel_rec.attribute7 := p1_a62;
    ddp_org_contact_rec.party_rel_rec.attribute8 := p1_a63;
    ddp_org_contact_rec.party_rel_rec.attribute9 := p1_a64;
    ddp_org_contact_rec.party_rel_rec.attribute10 := p1_a65;
    ddp_org_contact_rec.party_rel_rec.attribute11 := p1_a66;
    ddp_org_contact_rec.party_rel_rec.attribute12 := p1_a67;
    ddp_org_contact_rec.party_rel_rec.attribute13 := p1_a68;
    ddp_org_contact_rec.party_rel_rec.attribute14 := p1_a69;
    ddp_org_contact_rec.party_rel_rec.attribute15 := p1_a70;
    ddp_org_contact_rec.party_rel_rec.attribute16 := p1_a71;
    ddp_org_contact_rec.party_rel_rec.attribute17 := p1_a72;
    ddp_org_contact_rec.party_rel_rec.attribute18 := p1_a73;
    ddp_org_contact_rec.party_rel_rec.attribute19 := p1_a74;
    ddp_org_contact_rec.party_rel_rec.attribute20 := p1_a75;
    ddp_org_contact_rec.party_rel_rec.created_by_module := p1_a76;
    ddp_org_contact_rec.party_rel_rec.application_id := rosetta_g_miss_num_map(p1_a77);
    ddp_org_contact_rec.party_rel_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a78);
    ddp_org_contact_rec.party_rel_rec.party_rec.party_number := p1_a79;
    ddp_org_contact_rec.party_rel_rec.party_rec.validated_flag := p1_a80;
    ddp_org_contact_rec.party_rel_rec.party_rec.orig_system_reference := p1_a81;
    ddp_org_contact_rec.party_rel_rec.party_rec.orig_system := p1_a82;
    ddp_org_contact_rec.party_rel_rec.party_rec.status := p1_a83;
    ddp_org_contact_rec.party_rel_rec.party_rec.category_code := p1_a84;
    ddp_org_contact_rec.party_rel_rec.party_rec.salutation := p1_a85;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute_category := p1_a86;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute1 := p1_a87;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute2 := p1_a88;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute3 := p1_a89;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute4 := p1_a90;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute5 := p1_a91;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute6 := p1_a92;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute7 := p1_a93;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute8 := p1_a94;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute9 := p1_a95;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute10 := p1_a96;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute11 := p1_a97;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute12 := p1_a98;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute13 := p1_a99;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute14 := p1_a100;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute15 := p1_a101;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute16 := p1_a102;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute17 := p1_a103;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute18 := p1_a104;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute19 := p1_a105;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute20 := p1_a106;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute21 := p1_a107;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute22 := p1_a108;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute23 := p1_a109;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute24 := p1_a110;
    ddp_org_contact_rec.party_rel_rec.additional_information1 := p1_a111;
    ddp_org_contact_rec.party_rel_rec.additional_information2 := p1_a112;
    ddp_org_contact_rec.party_rel_rec.additional_information3 := p1_a113;
    ddp_org_contact_rec.party_rel_rec.additional_information4 := p1_a114;
    ddp_org_contact_rec.party_rel_rec.additional_information5 := p1_a115;
    ddp_org_contact_rec.party_rel_rec.additional_information6 := p1_a116;
    ddp_org_contact_rec.party_rel_rec.additional_information7 := p1_a117;
    ddp_org_contact_rec.party_rel_rec.additional_information8 := p1_a118;
    ddp_org_contact_rec.party_rel_rec.additional_information9 := p1_a119;
    ddp_org_contact_rec.party_rel_rec.additional_information10 := p1_a120;
    ddp_org_contact_rec.party_rel_rec.additional_information11 := p1_a121;
    ddp_org_contact_rec.party_rel_rec.additional_information12 := p1_a122;
    ddp_org_contact_rec.party_rel_rec.additional_information13 := p1_a123;
    ddp_org_contact_rec.party_rel_rec.additional_information14 := p1_a124;
    ddp_org_contact_rec.party_rel_rec.additional_information15 := p1_a125;
    ddp_org_contact_rec.party_rel_rec.additional_information16 := p1_a126;
    ddp_org_contact_rec.party_rel_rec.additional_information17 := p1_a127;
    ddp_org_contact_rec.party_rel_rec.additional_information18 := p1_a128;
    ddp_org_contact_rec.party_rel_rec.additional_information19 := p1_a129;
    ddp_org_contact_rec.party_rel_rec.additional_information20 := p1_a130;
    ddp_org_contact_rec.party_rel_rec.additional_information21 := p1_a131;
    ddp_org_contact_rec.party_rel_rec.additional_information22 := p1_a132;
    ddp_org_contact_rec.party_rel_rec.additional_information23 := p1_a133;
    ddp_org_contact_rec.party_rel_rec.additional_information24 := p1_a134;
    ddp_org_contact_rec.party_rel_rec.additional_information25 := p1_a135;
    ddp_org_contact_rec.party_rel_rec.additional_information26 := p1_a136;
    ddp_org_contact_rec.party_rel_rec.additional_information27 := p1_a137;
    ddp_org_contact_rec.party_rel_rec.additional_information28 := p1_a138;
    ddp_org_contact_rec.party_rel_rec.additional_information29 := p1_a139;
    ddp_org_contact_rec.party_rel_rec.additional_information30 := p1_a140;
    ddp_org_contact_rec.party_rel_rec.percentage_ownership := rosetta_g_miss_num_map(p1_a141);
    ddp_org_contact_rec.party_rel_rec.actual_content_source := p1_a142;








    -- here's the delegated call to the old PL/SQL routine
    hz_party_contact_v2pub.create_org_contact(p_init_msg_list,
      ddp_org_contact_rec,
      x_org_contact_id,
      x_party_rel_id,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_org_contact_2(p_init_msg_list  VARCHAR2
    , p_cont_object_version_number in out nocopy  NUMBER
    , p_rel_object_version_number in out nocopy  NUMBER
    , p_party_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
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
    , p1_a11  NUMBER := null
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
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  NUMBER := null
    , p1_a41  NUMBER := null
    , p1_a42  NUMBER := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  NUMBER := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  DATE := null
    , p1_a52  DATE := null
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
    , p1_a77  NUMBER := null
    , p1_a78  NUMBER := null
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
    , p1_a100  VARCHAR2 := null
    , p1_a101  VARCHAR2 := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  VARCHAR2 := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  VARCHAR2 := null
    , p1_a107  VARCHAR2 := null
    , p1_a108  VARCHAR2 := null
    , p1_a109  VARCHAR2 := null
    , p1_a110  VARCHAR2 := null
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
    , p1_a135  VARCHAR2 := null
    , p1_a136  VARCHAR2 := null
    , p1_a137  VARCHAR2 := null
    , p1_a138  VARCHAR2 := null
    , p1_a139  VARCHAR2 := null
    , p1_a140  VARCHAR2 := null
    , p1_a141  NUMBER := null
    , p1_a142  VARCHAR2 := null
  )
  as
    ddp_org_contact_rec hz_party_contact_v2pub.org_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_org_contact_rec.org_contact_id := rosetta_g_miss_num_map(p1_a0);
    ddp_org_contact_rec.comments := p1_a1;
    ddp_org_contact_rec.contact_number := p1_a2;
    ddp_org_contact_rec.department_code := p1_a3;
    ddp_org_contact_rec.department := p1_a4;
    ddp_org_contact_rec.title := p1_a5;
    ddp_org_contact_rec.job_title := p1_a6;
    ddp_org_contact_rec.decision_maker_flag := p1_a7;
    ddp_org_contact_rec.job_title_code := p1_a8;
    ddp_org_contact_rec.reference_use_flag := p1_a9;
    ddp_org_contact_rec.rank := p1_a10;
    ddp_org_contact_rec.party_site_id := rosetta_g_miss_num_map(p1_a11);
    ddp_org_contact_rec.orig_system_reference := p1_a12;
    ddp_org_contact_rec.orig_system := p1_a13;
    ddp_org_contact_rec.attribute_category := p1_a14;
    ddp_org_contact_rec.attribute1 := p1_a15;
    ddp_org_contact_rec.attribute2 := p1_a16;
    ddp_org_contact_rec.attribute3 := p1_a17;
    ddp_org_contact_rec.attribute4 := p1_a18;
    ddp_org_contact_rec.attribute5 := p1_a19;
    ddp_org_contact_rec.attribute6 := p1_a20;
    ddp_org_contact_rec.attribute7 := p1_a21;
    ddp_org_contact_rec.attribute8 := p1_a22;
    ddp_org_contact_rec.attribute9 := p1_a23;
    ddp_org_contact_rec.attribute10 := p1_a24;
    ddp_org_contact_rec.attribute11 := p1_a25;
    ddp_org_contact_rec.attribute12 := p1_a26;
    ddp_org_contact_rec.attribute13 := p1_a27;
    ddp_org_contact_rec.attribute14 := p1_a28;
    ddp_org_contact_rec.attribute15 := p1_a29;
    ddp_org_contact_rec.attribute16 := p1_a30;
    ddp_org_contact_rec.attribute17 := p1_a31;
    ddp_org_contact_rec.attribute18 := p1_a32;
    ddp_org_contact_rec.attribute19 := p1_a33;
    ddp_org_contact_rec.attribute20 := p1_a34;
    ddp_org_contact_rec.attribute21 := p1_a35;
    ddp_org_contact_rec.attribute22 := p1_a36;
    ddp_org_contact_rec.attribute23 := p1_a37;
    ddp_org_contact_rec.attribute24 := p1_a38;
    ddp_org_contact_rec.created_by_module := p1_a39;
    ddp_org_contact_rec.application_id := rosetta_g_miss_num_map(p1_a40);
    ddp_org_contact_rec.party_rel_rec.relationship_id := rosetta_g_miss_num_map(p1_a41);
    ddp_org_contact_rec.party_rel_rec.subject_id := rosetta_g_miss_num_map(p1_a42);
    ddp_org_contact_rec.party_rel_rec.subject_type := p1_a43;
    ddp_org_contact_rec.party_rel_rec.subject_table_name := p1_a44;
    ddp_org_contact_rec.party_rel_rec.object_id := rosetta_g_miss_num_map(p1_a45);
    ddp_org_contact_rec.party_rel_rec.object_type := p1_a46;
    ddp_org_contact_rec.party_rel_rec.object_table_name := p1_a47;
    ddp_org_contact_rec.party_rel_rec.relationship_code := p1_a48;
    ddp_org_contact_rec.party_rel_rec.relationship_type := p1_a49;
    ddp_org_contact_rec.party_rel_rec.comments := p1_a50;
    ddp_org_contact_rec.party_rel_rec.start_date := rosetta_g_miss_date_in_map(p1_a51);
    ddp_org_contact_rec.party_rel_rec.end_date := rosetta_g_miss_date_in_map(p1_a52);
    ddp_org_contact_rec.party_rel_rec.status := p1_a53;
    ddp_org_contact_rec.party_rel_rec.content_source_type := p1_a54;
    ddp_org_contact_rec.party_rel_rec.attribute_category := p1_a55;
    ddp_org_contact_rec.party_rel_rec.attribute1 := p1_a56;
    ddp_org_contact_rec.party_rel_rec.attribute2 := p1_a57;
    ddp_org_contact_rec.party_rel_rec.attribute3 := p1_a58;
    ddp_org_contact_rec.party_rel_rec.attribute4 := p1_a59;
    ddp_org_contact_rec.party_rel_rec.attribute5 := p1_a60;
    ddp_org_contact_rec.party_rel_rec.attribute6 := p1_a61;
    ddp_org_contact_rec.party_rel_rec.attribute7 := p1_a62;
    ddp_org_contact_rec.party_rel_rec.attribute8 := p1_a63;
    ddp_org_contact_rec.party_rel_rec.attribute9 := p1_a64;
    ddp_org_contact_rec.party_rel_rec.attribute10 := p1_a65;
    ddp_org_contact_rec.party_rel_rec.attribute11 := p1_a66;
    ddp_org_contact_rec.party_rel_rec.attribute12 := p1_a67;
    ddp_org_contact_rec.party_rel_rec.attribute13 := p1_a68;
    ddp_org_contact_rec.party_rel_rec.attribute14 := p1_a69;
    ddp_org_contact_rec.party_rel_rec.attribute15 := p1_a70;
    ddp_org_contact_rec.party_rel_rec.attribute16 := p1_a71;
    ddp_org_contact_rec.party_rel_rec.attribute17 := p1_a72;
    ddp_org_contact_rec.party_rel_rec.attribute18 := p1_a73;
    ddp_org_contact_rec.party_rel_rec.attribute19 := p1_a74;
    ddp_org_contact_rec.party_rel_rec.attribute20 := p1_a75;
    ddp_org_contact_rec.party_rel_rec.created_by_module := p1_a76;
    ddp_org_contact_rec.party_rel_rec.application_id := rosetta_g_miss_num_map(p1_a77);
    ddp_org_contact_rec.party_rel_rec.party_rec.party_id := rosetta_g_miss_num_map(p1_a78);
    ddp_org_contact_rec.party_rel_rec.party_rec.party_number := p1_a79;
    ddp_org_contact_rec.party_rel_rec.party_rec.validated_flag := p1_a80;
    ddp_org_contact_rec.party_rel_rec.party_rec.orig_system_reference := p1_a81;
    ddp_org_contact_rec.party_rel_rec.party_rec.orig_system := p1_a82;
    ddp_org_contact_rec.party_rel_rec.party_rec.status := p1_a83;
    ddp_org_contact_rec.party_rel_rec.party_rec.category_code := p1_a84;
    ddp_org_contact_rec.party_rel_rec.party_rec.salutation := p1_a85;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute_category := p1_a86;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute1 := p1_a87;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute2 := p1_a88;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute3 := p1_a89;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute4 := p1_a90;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute5 := p1_a91;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute6 := p1_a92;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute7 := p1_a93;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute8 := p1_a94;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute9 := p1_a95;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute10 := p1_a96;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute11 := p1_a97;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute12 := p1_a98;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute13 := p1_a99;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute14 := p1_a100;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute15 := p1_a101;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute16 := p1_a102;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute17 := p1_a103;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute18 := p1_a104;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute19 := p1_a105;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute20 := p1_a106;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute21 := p1_a107;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute22 := p1_a108;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute23 := p1_a109;
    ddp_org_contact_rec.party_rel_rec.party_rec.attribute24 := p1_a110;
    ddp_org_contact_rec.party_rel_rec.additional_information1 := p1_a111;
    ddp_org_contact_rec.party_rel_rec.additional_information2 := p1_a112;
    ddp_org_contact_rec.party_rel_rec.additional_information3 := p1_a113;
    ddp_org_contact_rec.party_rel_rec.additional_information4 := p1_a114;
    ddp_org_contact_rec.party_rel_rec.additional_information5 := p1_a115;
    ddp_org_contact_rec.party_rel_rec.additional_information6 := p1_a116;
    ddp_org_contact_rec.party_rel_rec.additional_information7 := p1_a117;
    ddp_org_contact_rec.party_rel_rec.additional_information8 := p1_a118;
    ddp_org_contact_rec.party_rel_rec.additional_information9 := p1_a119;
    ddp_org_contact_rec.party_rel_rec.additional_information10 := p1_a120;
    ddp_org_contact_rec.party_rel_rec.additional_information11 := p1_a121;
    ddp_org_contact_rec.party_rel_rec.additional_information12 := p1_a122;
    ddp_org_contact_rec.party_rel_rec.additional_information13 := p1_a123;
    ddp_org_contact_rec.party_rel_rec.additional_information14 := p1_a124;
    ddp_org_contact_rec.party_rel_rec.additional_information15 := p1_a125;
    ddp_org_contact_rec.party_rel_rec.additional_information16 := p1_a126;
    ddp_org_contact_rec.party_rel_rec.additional_information17 := p1_a127;
    ddp_org_contact_rec.party_rel_rec.additional_information18 := p1_a128;
    ddp_org_contact_rec.party_rel_rec.additional_information19 := p1_a129;
    ddp_org_contact_rec.party_rel_rec.additional_information20 := p1_a130;
    ddp_org_contact_rec.party_rel_rec.additional_information21 := p1_a131;
    ddp_org_contact_rec.party_rel_rec.additional_information22 := p1_a132;
    ddp_org_contact_rec.party_rel_rec.additional_information23 := p1_a133;
    ddp_org_contact_rec.party_rel_rec.additional_information24 := p1_a134;
    ddp_org_contact_rec.party_rel_rec.additional_information25 := p1_a135;
    ddp_org_contact_rec.party_rel_rec.additional_information26 := p1_a136;
    ddp_org_contact_rec.party_rel_rec.additional_information27 := p1_a137;
    ddp_org_contact_rec.party_rel_rec.additional_information28 := p1_a138;
    ddp_org_contact_rec.party_rel_rec.additional_information29 := p1_a139;
    ddp_org_contact_rec.party_rel_rec.additional_information30 := p1_a140;
    ddp_org_contact_rec.party_rel_rec.percentage_ownership := rosetta_g_miss_num_map(p1_a141);
    ddp_org_contact_rec.party_rel_rec.actual_content_source := p1_a142;







    -- here's the delegated call to the old PL/SQL routine
    hz_party_contact_v2pub.update_org_contact(p_init_msg_list,
      ddp_org_contact_rec,
      p_cont_object_version_number,
      p_rel_object_version_number,
      p_party_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_org_contact_role_3(p_init_msg_list  VARCHAR2
    , x_org_contact_role_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  NUMBER := null
  )
  as
    ddp_org_contact_role_rec hz_party_contact_v2pub.org_contact_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_org_contact_role_rec.org_contact_role_id := rosetta_g_miss_num_map(p1_a0);
    ddp_org_contact_role_rec.role_type := p1_a1;
    ddp_org_contact_role_rec.primary_flag := p1_a2;
    ddp_org_contact_role_rec.org_contact_id := rosetta_g_miss_num_map(p1_a3);
    ddp_org_contact_role_rec.orig_system_reference := p1_a4;
    ddp_org_contact_role_rec.orig_system := p1_a5;
    ddp_org_contact_role_rec.role_level := p1_a6;
    ddp_org_contact_role_rec.primary_contact_per_role_type := p1_a7;
    ddp_org_contact_role_rec.status := p1_a8;
    ddp_org_contact_role_rec.created_by_module := p1_a9;
    ddp_org_contact_role_rec.application_id := rosetta_g_miss_num_map(p1_a10);





    -- here's the delegated call to the old PL/SQL routine
    hz_party_contact_v2pub.create_org_contact_role(p_init_msg_list,
      ddp_org_contact_role_rec,
      x_org_contact_role_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_org_contact_role_4(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  NUMBER := null
  )
  as
    ddp_org_contact_role_rec hz_party_contact_v2pub.org_contact_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_org_contact_role_rec.org_contact_role_id := rosetta_g_miss_num_map(p1_a0);
    ddp_org_contact_role_rec.role_type := p1_a1;
    ddp_org_contact_role_rec.primary_flag := p1_a2;
    ddp_org_contact_role_rec.org_contact_id := rosetta_g_miss_num_map(p1_a3);
    ddp_org_contact_role_rec.orig_system_reference := p1_a4;
    ddp_org_contact_role_rec.orig_system := p1_a5;
    ddp_org_contact_role_rec.role_level := p1_a6;
    ddp_org_contact_role_rec.primary_contact_per_role_type := p1_a7;
    ddp_org_contact_role_rec.status := p1_a8;
    ddp_org_contact_role_rec.created_by_module := p1_a9;
    ddp_org_contact_role_rec.application_id := rosetta_g_miss_num_map(p1_a10);





    -- here's the delegated call to the old PL/SQL routine
    hz_party_contact_v2pub.update_org_contact_role(p_init_msg_list,
      ddp_org_contact_role_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_org_contact_rec_5(p_init_msg_list  VARCHAR2
    , p_org_contact_id  NUMBER
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
    , p2_a11 out nocopy  NUMBER
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
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  NUMBER
    , p2_a41 out nocopy  NUMBER
    , p2_a42 out nocopy  NUMBER
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p2_a45 out nocopy  NUMBER
    , p2_a46 out nocopy  VARCHAR2
    , p2_a47 out nocopy  VARCHAR2
    , p2_a48 out nocopy  VARCHAR2
    , p2_a49 out nocopy  VARCHAR2
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  DATE
    , p2_a52 out nocopy  DATE
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  VARCHAR2
    , p2_a63 out nocopy  VARCHAR2
    , p2_a64 out nocopy  VARCHAR2
    , p2_a65 out nocopy  VARCHAR2
    , p2_a66 out nocopy  VARCHAR2
    , p2_a67 out nocopy  VARCHAR2
    , p2_a68 out nocopy  VARCHAR2
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  VARCHAR2
    , p2_a71 out nocopy  VARCHAR2
    , p2_a72 out nocopy  VARCHAR2
    , p2_a73 out nocopy  VARCHAR2
    , p2_a74 out nocopy  VARCHAR2
    , p2_a75 out nocopy  VARCHAR2
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  NUMBER
    , p2_a78 out nocopy  NUMBER
    , p2_a79 out nocopy  VARCHAR2
    , p2_a80 out nocopy  VARCHAR2
    , p2_a81 out nocopy  VARCHAR2
    , p2_a82 out nocopy  VARCHAR2
    , p2_a83 out nocopy  VARCHAR2
    , p2_a84 out nocopy  VARCHAR2
    , p2_a85 out nocopy  VARCHAR2
    , p2_a86 out nocopy  VARCHAR2
    , p2_a87 out nocopy  VARCHAR2
    , p2_a88 out nocopy  VARCHAR2
    , p2_a89 out nocopy  VARCHAR2
    , p2_a90 out nocopy  VARCHAR2
    , p2_a91 out nocopy  VARCHAR2
    , p2_a92 out nocopy  VARCHAR2
    , p2_a93 out nocopy  VARCHAR2
    , p2_a94 out nocopy  VARCHAR2
    , p2_a95 out nocopy  VARCHAR2
    , p2_a96 out nocopy  VARCHAR2
    , p2_a97 out nocopy  VARCHAR2
    , p2_a98 out nocopy  VARCHAR2
    , p2_a99 out nocopy  VARCHAR2
    , p2_a100 out nocopy  VARCHAR2
    , p2_a101 out nocopy  VARCHAR2
    , p2_a102 out nocopy  VARCHAR2
    , p2_a103 out nocopy  VARCHAR2
    , p2_a104 out nocopy  VARCHAR2
    , p2_a105 out nocopy  VARCHAR2
    , p2_a106 out nocopy  VARCHAR2
    , p2_a107 out nocopy  VARCHAR2
    , p2_a108 out nocopy  VARCHAR2
    , p2_a109 out nocopy  VARCHAR2
    , p2_a110 out nocopy  VARCHAR2
    , p2_a111 out nocopy  VARCHAR2
    , p2_a112 out nocopy  VARCHAR2
    , p2_a113 out nocopy  VARCHAR2
    , p2_a114 out nocopy  VARCHAR2
    , p2_a115 out nocopy  VARCHAR2
    , p2_a116 out nocopy  VARCHAR2
    , p2_a117 out nocopy  VARCHAR2
    , p2_a118 out nocopy  VARCHAR2
    , p2_a119 out nocopy  VARCHAR2
    , p2_a120 out nocopy  VARCHAR2
    , p2_a121 out nocopy  VARCHAR2
    , p2_a122 out nocopy  VARCHAR2
    , p2_a123 out nocopy  VARCHAR2
    , p2_a124 out nocopy  VARCHAR2
    , p2_a125 out nocopy  VARCHAR2
    , p2_a126 out nocopy  VARCHAR2
    , p2_a127 out nocopy  VARCHAR2
    , p2_a128 out nocopy  VARCHAR2
    , p2_a129 out nocopy  VARCHAR2
    , p2_a130 out nocopy  VARCHAR2
    , p2_a131 out nocopy  VARCHAR2
    , p2_a132 out nocopy  VARCHAR2
    , p2_a133 out nocopy  VARCHAR2
    , p2_a134 out nocopy  VARCHAR2
    , p2_a135 out nocopy  VARCHAR2
    , p2_a136 out nocopy  VARCHAR2
    , p2_a137 out nocopy  VARCHAR2
    , p2_a138 out nocopy  VARCHAR2
    , p2_a139 out nocopy  VARCHAR2
    , p2_a140 out nocopy  VARCHAR2
    , p2_a141 out nocopy  NUMBER
    , p2_a142 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_org_contact_rec hz_party_contact_v2pub.org_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_party_contact_v2pub.get_org_contact_rec(p_init_msg_list,
      p_org_contact_id,
      ddx_org_contact_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_org_contact_rec.org_contact_id);
    p2_a1 := ddx_org_contact_rec.comments;
    p2_a2 := ddx_org_contact_rec.contact_number;
    p2_a3 := ddx_org_contact_rec.department_code;
    p2_a4 := ddx_org_contact_rec.department;
    p2_a5 := ddx_org_contact_rec.title;
    p2_a6 := ddx_org_contact_rec.job_title;
    p2_a7 := ddx_org_contact_rec.decision_maker_flag;
    p2_a8 := ddx_org_contact_rec.job_title_code;
    p2_a9 := ddx_org_contact_rec.reference_use_flag;
    p2_a10 := ddx_org_contact_rec.rank;
    p2_a11 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_site_id);
    p2_a12 := ddx_org_contact_rec.orig_system_reference;
    p2_a13 := ddx_org_contact_rec.orig_system;
    p2_a14 := ddx_org_contact_rec.attribute_category;
    p2_a15 := ddx_org_contact_rec.attribute1;
    p2_a16 := ddx_org_contact_rec.attribute2;
    p2_a17 := ddx_org_contact_rec.attribute3;
    p2_a18 := ddx_org_contact_rec.attribute4;
    p2_a19 := ddx_org_contact_rec.attribute5;
    p2_a20 := ddx_org_contact_rec.attribute6;
    p2_a21 := ddx_org_contact_rec.attribute7;
    p2_a22 := ddx_org_contact_rec.attribute8;
    p2_a23 := ddx_org_contact_rec.attribute9;
    p2_a24 := ddx_org_contact_rec.attribute10;
    p2_a25 := ddx_org_contact_rec.attribute11;
    p2_a26 := ddx_org_contact_rec.attribute12;
    p2_a27 := ddx_org_contact_rec.attribute13;
    p2_a28 := ddx_org_contact_rec.attribute14;
    p2_a29 := ddx_org_contact_rec.attribute15;
    p2_a30 := ddx_org_contact_rec.attribute16;
    p2_a31 := ddx_org_contact_rec.attribute17;
    p2_a32 := ddx_org_contact_rec.attribute18;
    p2_a33 := ddx_org_contact_rec.attribute19;
    p2_a34 := ddx_org_contact_rec.attribute20;
    p2_a35 := ddx_org_contact_rec.attribute21;
    p2_a36 := ddx_org_contact_rec.attribute22;
    p2_a37 := ddx_org_contact_rec.attribute23;
    p2_a38 := ddx_org_contact_rec.attribute24;
    p2_a39 := ddx_org_contact_rec.created_by_module;
    p2_a40 := rosetta_g_miss_num_map(ddx_org_contact_rec.application_id);
    p2_a41 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_rel_rec.relationship_id);
    p2_a42 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_rel_rec.subject_id);
    p2_a43 := ddx_org_contact_rec.party_rel_rec.subject_type;
    p2_a44 := ddx_org_contact_rec.party_rel_rec.subject_table_name;
    p2_a45 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_rel_rec.object_id);
    p2_a46 := ddx_org_contact_rec.party_rel_rec.object_type;
    p2_a47 := ddx_org_contact_rec.party_rel_rec.object_table_name;
    p2_a48 := ddx_org_contact_rec.party_rel_rec.relationship_code;
    p2_a49 := ddx_org_contact_rec.party_rel_rec.relationship_type;
    p2_a50 := ddx_org_contact_rec.party_rel_rec.comments;
    p2_a51 := ddx_org_contact_rec.party_rel_rec.start_date;
    p2_a52 := ddx_org_contact_rec.party_rel_rec.end_date;
    p2_a53 := ddx_org_contact_rec.party_rel_rec.status;
    p2_a54 := ddx_org_contact_rec.party_rel_rec.content_source_type;
    p2_a55 := ddx_org_contact_rec.party_rel_rec.attribute_category;
    p2_a56 := ddx_org_contact_rec.party_rel_rec.attribute1;
    p2_a57 := ddx_org_contact_rec.party_rel_rec.attribute2;
    p2_a58 := ddx_org_contact_rec.party_rel_rec.attribute3;
    p2_a59 := ddx_org_contact_rec.party_rel_rec.attribute4;
    p2_a60 := ddx_org_contact_rec.party_rel_rec.attribute5;
    p2_a61 := ddx_org_contact_rec.party_rel_rec.attribute6;
    p2_a62 := ddx_org_contact_rec.party_rel_rec.attribute7;
    p2_a63 := ddx_org_contact_rec.party_rel_rec.attribute8;
    p2_a64 := ddx_org_contact_rec.party_rel_rec.attribute9;
    p2_a65 := ddx_org_contact_rec.party_rel_rec.attribute10;
    p2_a66 := ddx_org_contact_rec.party_rel_rec.attribute11;
    p2_a67 := ddx_org_contact_rec.party_rel_rec.attribute12;
    p2_a68 := ddx_org_contact_rec.party_rel_rec.attribute13;
    p2_a69 := ddx_org_contact_rec.party_rel_rec.attribute14;
    p2_a70 := ddx_org_contact_rec.party_rel_rec.attribute15;
    p2_a71 := ddx_org_contact_rec.party_rel_rec.attribute16;
    p2_a72 := ddx_org_contact_rec.party_rel_rec.attribute17;
    p2_a73 := ddx_org_contact_rec.party_rel_rec.attribute18;
    p2_a74 := ddx_org_contact_rec.party_rel_rec.attribute19;
    p2_a75 := ddx_org_contact_rec.party_rel_rec.attribute20;
    p2_a76 := ddx_org_contact_rec.party_rel_rec.created_by_module;
    p2_a77 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_rel_rec.application_id);
    p2_a78 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_rel_rec.party_rec.party_id);
    p2_a79 := ddx_org_contact_rec.party_rel_rec.party_rec.party_number;
    p2_a80 := ddx_org_contact_rec.party_rel_rec.party_rec.validated_flag;
    p2_a81 := ddx_org_contact_rec.party_rel_rec.party_rec.orig_system_reference;
    p2_a82 := ddx_org_contact_rec.party_rel_rec.party_rec.orig_system;
    p2_a83 := ddx_org_contact_rec.party_rel_rec.party_rec.status;
    p2_a84 := ddx_org_contact_rec.party_rel_rec.party_rec.category_code;
    p2_a85 := ddx_org_contact_rec.party_rel_rec.party_rec.salutation;
    p2_a86 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute_category;
    p2_a87 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute1;
    p2_a88 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute2;
    p2_a89 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute3;
    p2_a90 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute4;
    p2_a91 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute5;
    p2_a92 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute6;
    p2_a93 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute7;
    p2_a94 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute8;
    p2_a95 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute9;
    p2_a96 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute10;
    p2_a97 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute11;
    p2_a98 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute12;
    p2_a99 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute13;
    p2_a100 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute14;
    p2_a101 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute15;
    p2_a102 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute16;
    p2_a103 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute17;
    p2_a104 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute18;
    p2_a105 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute19;
    p2_a106 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute20;
    p2_a107 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute21;
    p2_a108 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute22;
    p2_a109 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute23;
    p2_a110 := ddx_org_contact_rec.party_rel_rec.party_rec.attribute24;
    p2_a111 := ddx_org_contact_rec.party_rel_rec.additional_information1;
    p2_a112 := ddx_org_contact_rec.party_rel_rec.additional_information2;
    p2_a113 := ddx_org_contact_rec.party_rel_rec.additional_information3;
    p2_a114 := ddx_org_contact_rec.party_rel_rec.additional_information4;
    p2_a115 := ddx_org_contact_rec.party_rel_rec.additional_information5;
    p2_a116 := ddx_org_contact_rec.party_rel_rec.additional_information6;
    p2_a117 := ddx_org_contact_rec.party_rel_rec.additional_information7;
    p2_a118 := ddx_org_contact_rec.party_rel_rec.additional_information8;
    p2_a119 := ddx_org_contact_rec.party_rel_rec.additional_information9;
    p2_a120 := ddx_org_contact_rec.party_rel_rec.additional_information10;
    p2_a121 := ddx_org_contact_rec.party_rel_rec.additional_information11;
    p2_a122 := ddx_org_contact_rec.party_rel_rec.additional_information12;
    p2_a123 := ddx_org_contact_rec.party_rel_rec.additional_information13;
    p2_a124 := ddx_org_contact_rec.party_rel_rec.additional_information14;
    p2_a125 := ddx_org_contact_rec.party_rel_rec.additional_information15;
    p2_a126 := ddx_org_contact_rec.party_rel_rec.additional_information16;
    p2_a127 := ddx_org_contact_rec.party_rel_rec.additional_information17;
    p2_a128 := ddx_org_contact_rec.party_rel_rec.additional_information18;
    p2_a129 := ddx_org_contact_rec.party_rel_rec.additional_information19;
    p2_a130 := ddx_org_contact_rec.party_rel_rec.additional_information20;
    p2_a131 := ddx_org_contact_rec.party_rel_rec.additional_information21;
    p2_a132 := ddx_org_contact_rec.party_rel_rec.additional_information22;
    p2_a133 := ddx_org_contact_rec.party_rel_rec.additional_information23;
    p2_a134 := ddx_org_contact_rec.party_rel_rec.additional_information24;
    p2_a135 := ddx_org_contact_rec.party_rel_rec.additional_information25;
    p2_a136 := ddx_org_contact_rec.party_rel_rec.additional_information26;
    p2_a137 := ddx_org_contact_rec.party_rel_rec.additional_information27;
    p2_a138 := ddx_org_contact_rec.party_rel_rec.additional_information28;
    p2_a139 := ddx_org_contact_rec.party_rel_rec.additional_information29;
    p2_a140 := ddx_org_contact_rec.party_rel_rec.additional_information30;
    p2_a141 := rosetta_g_miss_num_map(ddx_org_contact_rec.party_rel_rec.percentage_ownership);
    p2_a142 := ddx_org_contact_rec.party_rel_rec.actual_content_source;



  end;

  procedure get_org_contact_role_rec_6(p_init_msg_list  VARCHAR2
    , p_org_contact_role_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  NUMBER
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_org_contact_role_rec hz_party_contact_v2pub.org_contact_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_party_contact_v2pub.get_org_contact_role_rec(p_init_msg_list,
      p_org_contact_role_id,
      ddx_org_contact_role_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_org_contact_role_rec.org_contact_role_id);
    p2_a1 := ddx_org_contact_role_rec.role_type;
    p2_a2 := ddx_org_contact_role_rec.primary_flag;
    p2_a3 := rosetta_g_miss_num_map(ddx_org_contact_role_rec.org_contact_id);
    p2_a4 := ddx_org_contact_role_rec.orig_system_reference;
    p2_a5 := ddx_org_contact_role_rec.orig_system;
    p2_a6 := ddx_org_contact_role_rec.role_level;
    p2_a7 := ddx_org_contact_role_rec.primary_contact_per_role_type;
    p2_a8 := ddx_org_contact_role_rec.status;
    p2_a9 := ddx_org_contact_role_rec.created_by_module;
    p2_a10 := rosetta_g_miss_num_map(ddx_org_contact_role_rec.application_id);



  end;

end hz_party_contact_v2pub_jw;

/
