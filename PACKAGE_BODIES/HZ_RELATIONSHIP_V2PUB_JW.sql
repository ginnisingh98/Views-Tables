--------------------------------------------------------
--  DDL for Package Body HZ_RELATIONSHIP_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_RELATIONSHIP_V2PUB_JW" as
  /* $Header: ARH2REJB.pls 120.5 2005/06/18 04:29:19 jhuang noship $ */
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

  procedure create_relationship_1(p_init_msg_list  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_create_org_contact  VARCHAR2
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
    hz_relationship_v2pub.create_relationship(p_init_msg_list,
      ddp_relationship_rec,
      x_relationship_id,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_create_org_contact);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure create_relationship_2(p_init_msg_list  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
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
    hz_relationship_v2pub.create_relationship(p_init_msg_list,
      ddp_relationship_rec,
      x_relationship_id,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure create_relationship_with_us_3(p_init_msg_list  VARCHAR2
    , p_contact_party_id  NUMBER
    , p_contact_party_usage_code  VARCHAR2
    , p_create_org_contact  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
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
    hz_relationship_v2pub.create_relationship_with_usg(p_init_msg_list,
      ddp_relationship_rec,
      p_contact_party_id,
      p_contact_party_usage_code,
      p_create_org_contact,
      x_relationship_id,
      x_party_id,
      x_party_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










  end;

  procedure update_relationship_4(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_party_object_version_number in out nocopy  NUMBER
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
    hz_relationship_v2pub.update_relationship(p_init_msg_list,
      ddp_relationship_rec,
      p_object_version_number,
      p_party_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure get_relationship_rec_5(p_init_msg_list  VARCHAR2
    , p_relationship_id  NUMBER
    , p_directional_flag  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  DATE
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
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  VARCHAR2
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  VARCHAR2
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  NUMBER
    , p3_a37 out nocopy  NUMBER
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
    , p3_a60 out nocopy  VARCHAR2
    , p3_a61 out nocopy  VARCHAR2
    , p3_a62 out nocopy  VARCHAR2
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
    , p3_a95 out nocopy  VARCHAR2
    , p3_a96 out nocopy  VARCHAR2
    , p3_a97 out nocopy  VARCHAR2
    , p3_a98 out nocopy  VARCHAR2
    , p3_a99 out nocopy  VARCHAR2
    , p3_a100 out nocopy  NUMBER
    , p3_a101 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_rel_rec hz_relationship_v2pub.relationship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_relationship_v2pub.get_relationship_rec(p_init_msg_list,
      p_relationship_id,
      p_directional_flag,
      ddx_rel_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_rel_rec.relationship_id);
    p3_a1 := rosetta_g_miss_num_map(ddx_rel_rec.subject_id);
    p3_a2 := ddx_rel_rec.subject_type;
    p3_a3 := ddx_rel_rec.subject_table_name;
    p3_a4 := rosetta_g_miss_num_map(ddx_rel_rec.object_id);
    p3_a5 := ddx_rel_rec.object_type;
    p3_a6 := ddx_rel_rec.object_table_name;
    p3_a7 := ddx_rel_rec.relationship_code;
    p3_a8 := ddx_rel_rec.relationship_type;
    p3_a9 := ddx_rel_rec.comments;
    p3_a10 := ddx_rel_rec.start_date;
    p3_a11 := ddx_rel_rec.end_date;
    p3_a12 := ddx_rel_rec.status;
    p3_a13 := ddx_rel_rec.content_source_type;
    p3_a14 := ddx_rel_rec.attribute_category;
    p3_a15 := ddx_rel_rec.attribute1;
    p3_a16 := ddx_rel_rec.attribute2;
    p3_a17 := ddx_rel_rec.attribute3;
    p3_a18 := ddx_rel_rec.attribute4;
    p3_a19 := ddx_rel_rec.attribute5;
    p3_a20 := ddx_rel_rec.attribute6;
    p3_a21 := ddx_rel_rec.attribute7;
    p3_a22 := ddx_rel_rec.attribute8;
    p3_a23 := ddx_rel_rec.attribute9;
    p3_a24 := ddx_rel_rec.attribute10;
    p3_a25 := ddx_rel_rec.attribute11;
    p3_a26 := ddx_rel_rec.attribute12;
    p3_a27 := ddx_rel_rec.attribute13;
    p3_a28 := ddx_rel_rec.attribute14;
    p3_a29 := ddx_rel_rec.attribute15;
    p3_a30 := ddx_rel_rec.attribute16;
    p3_a31 := ddx_rel_rec.attribute17;
    p3_a32 := ddx_rel_rec.attribute18;
    p3_a33 := ddx_rel_rec.attribute19;
    p3_a34 := ddx_rel_rec.attribute20;
    p3_a35 := ddx_rel_rec.created_by_module;
    p3_a36 := rosetta_g_miss_num_map(ddx_rel_rec.application_id);
    p3_a37 := rosetta_g_miss_num_map(ddx_rel_rec.party_rec.party_id);
    p3_a38 := ddx_rel_rec.party_rec.party_number;
    p3_a39 := ddx_rel_rec.party_rec.validated_flag;
    p3_a40 := ddx_rel_rec.party_rec.orig_system_reference;
    p3_a41 := ddx_rel_rec.party_rec.orig_system;
    p3_a42 := ddx_rel_rec.party_rec.status;
    p3_a43 := ddx_rel_rec.party_rec.category_code;
    p3_a44 := ddx_rel_rec.party_rec.salutation;
    p3_a45 := ddx_rel_rec.party_rec.attribute_category;
    p3_a46 := ddx_rel_rec.party_rec.attribute1;
    p3_a47 := ddx_rel_rec.party_rec.attribute2;
    p3_a48 := ddx_rel_rec.party_rec.attribute3;
    p3_a49 := ddx_rel_rec.party_rec.attribute4;
    p3_a50 := ddx_rel_rec.party_rec.attribute5;
    p3_a51 := ddx_rel_rec.party_rec.attribute6;
    p3_a52 := ddx_rel_rec.party_rec.attribute7;
    p3_a53 := ddx_rel_rec.party_rec.attribute8;
    p3_a54 := ddx_rel_rec.party_rec.attribute9;
    p3_a55 := ddx_rel_rec.party_rec.attribute10;
    p3_a56 := ddx_rel_rec.party_rec.attribute11;
    p3_a57 := ddx_rel_rec.party_rec.attribute12;
    p3_a58 := ddx_rel_rec.party_rec.attribute13;
    p3_a59 := ddx_rel_rec.party_rec.attribute14;
    p3_a60 := ddx_rel_rec.party_rec.attribute15;
    p3_a61 := ddx_rel_rec.party_rec.attribute16;
    p3_a62 := ddx_rel_rec.party_rec.attribute17;
    p3_a63 := ddx_rel_rec.party_rec.attribute18;
    p3_a64 := ddx_rel_rec.party_rec.attribute19;
    p3_a65 := ddx_rel_rec.party_rec.attribute20;
    p3_a66 := ddx_rel_rec.party_rec.attribute21;
    p3_a67 := ddx_rel_rec.party_rec.attribute22;
    p3_a68 := ddx_rel_rec.party_rec.attribute23;
    p3_a69 := ddx_rel_rec.party_rec.attribute24;
    p3_a70 := ddx_rel_rec.additional_information1;
    p3_a71 := ddx_rel_rec.additional_information2;
    p3_a72 := ddx_rel_rec.additional_information3;
    p3_a73 := ddx_rel_rec.additional_information4;
    p3_a74 := ddx_rel_rec.additional_information5;
    p3_a75 := ddx_rel_rec.additional_information6;
    p3_a76 := ddx_rel_rec.additional_information7;
    p3_a77 := ddx_rel_rec.additional_information8;
    p3_a78 := ddx_rel_rec.additional_information9;
    p3_a79 := ddx_rel_rec.additional_information10;
    p3_a80 := ddx_rel_rec.additional_information11;
    p3_a81 := ddx_rel_rec.additional_information12;
    p3_a82 := ddx_rel_rec.additional_information13;
    p3_a83 := ddx_rel_rec.additional_information14;
    p3_a84 := ddx_rel_rec.additional_information15;
    p3_a85 := ddx_rel_rec.additional_information16;
    p3_a86 := ddx_rel_rec.additional_information17;
    p3_a87 := ddx_rel_rec.additional_information18;
    p3_a88 := ddx_rel_rec.additional_information19;
    p3_a89 := ddx_rel_rec.additional_information20;
    p3_a90 := ddx_rel_rec.additional_information21;
    p3_a91 := ddx_rel_rec.additional_information22;
    p3_a92 := ddx_rel_rec.additional_information23;
    p3_a93 := ddx_rel_rec.additional_information24;
    p3_a94 := ddx_rel_rec.additional_information25;
    p3_a95 := ddx_rel_rec.additional_information26;
    p3_a96 := ddx_rel_rec.additional_information27;
    p3_a97 := ddx_rel_rec.additional_information28;
    p3_a98 := ddx_rel_rec.additional_information29;
    p3_a99 := ddx_rel_rec.additional_information30;
    p3_a100 := rosetta_g_miss_num_map(ddx_rel_rec.percentage_ownership);
    p3_a101 := ddx_rel_rec.actual_content_source;



  end;

end hz_relationship_v2pub_jw;

/
