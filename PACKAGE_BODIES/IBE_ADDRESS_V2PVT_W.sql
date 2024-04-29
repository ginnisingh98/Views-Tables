--------------------------------------------------------
--  DDL for Package Body IBE_ADDRESS_V2PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ADDRESS_V2PVT_W" as
  /* $Header: IBEVAWB.pls 115.0 2003/08/21 04:32:04 adwu noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_address(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
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
    , p3_a27  DATE
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
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
    , p3_a57  VARCHAR2
    , p3_a58  NUMBER
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_location_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
  )

  as
    ddp_location hz_location_v2pub.location_rec_type;
    ddp_party_site hz_party_site_v2pub.party_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_location.location_id := p3_a0;
    ddp_location.orig_system_reference := p3_a1;
    ddp_location.country := p3_a2;
    ddp_location.address1 := p3_a3;
    ddp_location.address2 := p3_a4;
    ddp_location.address3 := p3_a5;
    ddp_location.address4 := p3_a6;
    ddp_location.city := p3_a7;
    ddp_location.postal_code := p3_a8;
    ddp_location.state := p3_a9;
    ddp_location.province := p3_a10;
    ddp_location.county := p3_a11;
    ddp_location.address_key := p3_a12;
    ddp_location.address_style := p3_a13;
    ddp_location.validated_flag := p3_a14;
    ddp_location.address_lines_phonetic := p3_a15;
    ddp_location.po_box_number := p3_a16;
    ddp_location.house_number := p3_a17;
    ddp_location.street_suffix := p3_a18;
    ddp_location.street := p3_a19;
    ddp_location.street_number := p3_a20;
    ddp_location.floor := p3_a21;
    ddp_location.suite := p3_a22;
    ddp_location.postal_plus4_code := p3_a23;
    ddp_location.position := p3_a24;
    ddp_location.location_directions := p3_a25;
    ddp_location.address_effective_date := rosetta_g_miss_date_in_map(p3_a26);
    ddp_location.address_expiration_date := rosetta_g_miss_date_in_map(p3_a27);
    ddp_location.clli_code := p3_a28;
    ddp_location.language := p3_a29;
    ddp_location.short_description := p3_a30;
    ddp_location.description := p3_a31;
    ddp_location.loc_hierarchy_id := p3_a32;
    ddp_location.sales_tax_geocode := p3_a33;
    ddp_location.sales_tax_inside_city_limits := p3_a34;
    ddp_location.fa_location_id := p3_a35;
    ddp_location.content_source_type := p3_a36;
    ddp_location.attribute_category := p3_a37;
    ddp_location.attribute1 := p3_a38;
    ddp_location.attribute2 := p3_a39;
    ddp_location.attribute3 := p3_a40;
    ddp_location.attribute4 := p3_a41;
    ddp_location.attribute5 := p3_a42;
    ddp_location.attribute6 := p3_a43;
    ddp_location.attribute7 := p3_a44;
    ddp_location.attribute8 := p3_a45;
    ddp_location.attribute9 := p3_a46;
    ddp_location.attribute10 := p3_a47;
    ddp_location.attribute11 := p3_a48;
    ddp_location.attribute12 := p3_a49;
    ddp_location.attribute13 := p3_a50;
    ddp_location.attribute14 := p3_a51;
    ddp_location.attribute15 := p3_a52;
    ddp_location.attribute16 := p3_a53;
    ddp_location.attribute17 := p3_a54;
    ddp_location.attribute18 := p3_a55;
    ddp_location.attribute19 := p3_a56;
    ddp_location.attribute20 := p3_a57;
    ddp_location.timezone_id := p3_a58;
    ddp_location.created_by_module := p3_a59;
    ddp_location.application_id := p3_a60;
    ddp_location.actual_content_source := p3_a61;

    ddp_party_site.party_site_id := p4_a0;
    ddp_party_site.party_id := p4_a1;
    ddp_party_site.location_id := p4_a2;
    ddp_party_site.party_site_number := p4_a3;
    ddp_party_site.orig_system_reference := p4_a4;
    ddp_party_site.mailstop := p4_a5;
    ddp_party_site.identifying_address_flag := p4_a6;
    ddp_party_site.status := p4_a7;
    ddp_party_site.party_site_name := p4_a8;
    ddp_party_site.attribute_category := p4_a9;
    ddp_party_site.attribute1 := p4_a10;
    ddp_party_site.attribute2 := p4_a11;
    ddp_party_site.attribute3 := p4_a12;
    ddp_party_site.attribute4 := p4_a13;
    ddp_party_site.attribute5 := p4_a14;
    ddp_party_site.attribute6 := p4_a15;
    ddp_party_site.attribute7 := p4_a16;
    ddp_party_site.attribute8 := p4_a17;
    ddp_party_site.attribute9 := p4_a18;
    ddp_party_site.attribute10 := p4_a19;
    ddp_party_site.attribute11 := p4_a20;
    ddp_party_site.attribute12 := p4_a21;
    ddp_party_site.attribute13 := p4_a22;
    ddp_party_site.attribute14 := p4_a23;
    ddp_party_site.attribute15 := p4_a24;
    ddp_party_site.attribute16 := p4_a25;
    ddp_party_site.attribute17 := p4_a26;
    ddp_party_site.attribute18 := p4_a27;
    ddp_party_site.attribute19 := p4_a28;
    ddp_party_site.attribute20 := p4_a29;
    ddp_party_site.language := p4_a30;
    ddp_party_site.addressee := p4_a31;
    ddp_party_site.created_by_module := p4_a32;
    ddp_party_site.application_id := p4_a33;











    -- here's the delegated call to the old PL/SQL routine
    ibe_address_v2pvt.create_address(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_location,
      ddp_party_site,
      p_primary_billto,
      p_primary_shipto,
      p_billto,
      p_shipto,
      p_default_primary,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_location_id,
      x_party_site_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure update_address(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_party_site_id  NUMBER
    , p_ps_object_version_number  NUMBER
    , p_bill_object_version_number  NUMBER
    , p_ship_object_version_number  NUMBER
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
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
    , p7_a26  DATE
    , p7_a27  DATE
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
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
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  NUMBER
    , p_primary_billto  VARCHAR2
    , p_primary_shipto  VARCHAR2
    , p_billto  VARCHAR2
    , p_shipto  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_location_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
  )

  as
    ddp_location hz_location_v2pub.location_rec_type;
    ddp_party_site hz_party_site_v2pub.party_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_location.location_id := p7_a0;
    ddp_location.orig_system_reference := p7_a1;
    ddp_location.country := p7_a2;
    ddp_location.address1 := p7_a3;
    ddp_location.address2 := p7_a4;
    ddp_location.address3 := p7_a5;
    ddp_location.address4 := p7_a6;
    ddp_location.city := p7_a7;
    ddp_location.postal_code := p7_a8;
    ddp_location.state := p7_a9;
    ddp_location.province := p7_a10;
    ddp_location.county := p7_a11;
    ddp_location.address_key := p7_a12;
    ddp_location.address_style := p7_a13;
    ddp_location.validated_flag := p7_a14;
    ddp_location.address_lines_phonetic := p7_a15;
    ddp_location.po_box_number := p7_a16;
    ddp_location.house_number := p7_a17;
    ddp_location.street_suffix := p7_a18;
    ddp_location.street := p7_a19;
    ddp_location.street_number := p7_a20;
    ddp_location.floor := p7_a21;
    ddp_location.suite := p7_a22;
    ddp_location.postal_plus4_code := p7_a23;
    ddp_location.position := p7_a24;
    ddp_location.location_directions := p7_a25;
    ddp_location.address_effective_date := rosetta_g_miss_date_in_map(p7_a26);
    ddp_location.address_expiration_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_location.clli_code := p7_a28;
    ddp_location.language := p7_a29;
    ddp_location.short_description := p7_a30;
    ddp_location.description := p7_a31;
    ddp_location.loc_hierarchy_id := p7_a32;
    ddp_location.sales_tax_geocode := p7_a33;
    ddp_location.sales_tax_inside_city_limits := p7_a34;
    ddp_location.fa_location_id := p7_a35;
    ddp_location.content_source_type := p7_a36;
    ddp_location.attribute_category := p7_a37;
    ddp_location.attribute1 := p7_a38;
    ddp_location.attribute2 := p7_a39;
    ddp_location.attribute3 := p7_a40;
    ddp_location.attribute4 := p7_a41;
    ddp_location.attribute5 := p7_a42;
    ddp_location.attribute6 := p7_a43;
    ddp_location.attribute7 := p7_a44;
    ddp_location.attribute8 := p7_a45;
    ddp_location.attribute9 := p7_a46;
    ddp_location.attribute10 := p7_a47;
    ddp_location.attribute11 := p7_a48;
    ddp_location.attribute12 := p7_a49;
    ddp_location.attribute13 := p7_a50;
    ddp_location.attribute14 := p7_a51;
    ddp_location.attribute15 := p7_a52;
    ddp_location.attribute16 := p7_a53;
    ddp_location.attribute17 := p7_a54;
    ddp_location.attribute18 := p7_a55;
    ddp_location.attribute19 := p7_a56;
    ddp_location.attribute20 := p7_a57;
    ddp_location.timezone_id := p7_a58;
    ddp_location.created_by_module := p7_a59;
    ddp_location.application_id := p7_a60;
    ddp_location.actual_content_source := p7_a61;

    ddp_party_site.party_site_id := p8_a0;
    ddp_party_site.party_id := p8_a1;
    ddp_party_site.location_id := p8_a2;
    ddp_party_site.party_site_number := p8_a3;
    ddp_party_site.orig_system_reference := p8_a4;
    ddp_party_site.mailstop := p8_a5;
    ddp_party_site.identifying_address_flag := p8_a6;
    ddp_party_site.status := p8_a7;
    ddp_party_site.party_site_name := p8_a8;
    ddp_party_site.attribute_category := p8_a9;
    ddp_party_site.attribute1 := p8_a10;
    ddp_party_site.attribute2 := p8_a11;
    ddp_party_site.attribute3 := p8_a12;
    ddp_party_site.attribute4 := p8_a13;
    ddp_party_site.attribute5 := p8_a14;
    ddp_party_site.attribute6 := p8_a15;
    ddp_party_site.attribute7 := p8_a16;
    ddp_party_site.attribute8 := p8_a17;
    ddp_party_site.attribute9 := p8_a18;
    ddp_party_site.attribute10 := p8_a19;
    ddp_party_site.attribute11 := p8_a20;
    ddp_party_site.attribute12 := p8_a21;
    ddp_party_site.attribute13 := p8_a22;
    ddp_party_site.attribute14 := p8_a23;
    ddp_party_site.attribute15 := p8_a24;
    ddp_party_site.attribute16 := p8_a25;
    ddp_party_site.attribute17 := p8_a26;
    ddp_party_site.attribute18 := p8_a27;
    ddp_party_site.attribute19 := p8_a28;
    ddp_party_site.attribute20 := p8_a29;
    ddp_party_site.language := p8_a30;
    ddp_party_site.addressee := p8_a31;
    ddp_party_site.created_by_module := p8_a32;
    ddp_party_site.application_id := p8_a33;










    -- here's the delegated call to the old PL/SQL routine
    ibe_address_v2pvt.update_address(p_api_version,
      p_init_msg_list,
      p_commit,
      p_party_site_id,
      p_ps_object_version_number,
      p_bill_object_version_number,
      p_ship_object_version_number,
      ddp_location,
      ddp_party_site,
      p_primary_billto,
      p_primary_shipto,
      p_billto,
      p_shipto,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_location_id,
      x_party_site_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

















  end;

end ibe_address_v2pvt_w;

/
