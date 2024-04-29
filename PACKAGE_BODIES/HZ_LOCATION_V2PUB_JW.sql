--------------------------------------------------------
--  DDL for Package Body HZ_LOCATION_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATION_V2PUB_JW" as
  /* $Header: ARH2LOJB.pls 120.5 2005/10/07 16:41:11 baianand noship $ */
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

  procedure create_location_1(p_init_msg_list  VARCHAR2
    , x_location_id out nocopy  NUMBER
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
    , p1_a27  DATE := null
    , p1_a28  DATE := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  VARCHAR2 := null
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
  )
  as
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_location_rec.location_id := rosetta_g_miss_num_map(p1_a0);
    ddp_location_rec.orig_system_reference := p1_a1;
    ddp_location_rec.orig_system := p1_a2;
    ddp_location_rec.country := p1_a3;
    ddp_location_rec.address1 := p1_a4;
    ddp_location_rec.address2 := p1_a5;
    ddp_location_rec.address3 := p1_a6;
    ddp_location_rec.address4 := p1_a7;
    ddp_location_rec.city := p1_a8;
    ddp_location_rec.postal_code := p1_a9;
    ddp_location_rec.state := p1_a10;
    ddp_location_rec.province := p1_a11;
    ddp_location_rec.county := p1_a12;
    ddp_location_rec.address_key := p1_a13;
    ddp_location_rec.address_style := p1_a14;
    ddp_location_rec.validated_flag := p1_a15;
    ddp_location_rec.address_lines_phonetic := p1_a16;
    ddp_location_rec.po_box_number := p1_a17;
    ddp_location_rec.house_number := p1_a18;
    ddp_location_rec.street_suffix := p1_a19;
    ddp_location_rec.street := p1_a20;
    ddp_location_rec.street_number := p1_a21;
    ddp_location_rec.floor := p1_a22;
    ddp_location_rec.suite := p1_a23;
    ddp_location_rec.postal_plus4_code := p1_a24;
    ddp_location_rec.position := p1_a25;
    ddp_location_rec.location_directions := p1_a26;
    ddp_location_rec.address_effective_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_location_rec.clli_code := p1_a29;
    ddp_location_rec.language := p1_a30;
    ddp_location_rec.short_description := p1_a31;
    ddp_location_rec.description := p1_a32;
    ddp_location_rec.geometry_status_code := p1_a33;
    ddp_location_rec.loc_hierarchy_id := rosetta_g_miss_num_map(p1_a34);
    ddp_location_rec.sales_tax_geocode := p1_a35;
    ddp_location_rec.sales_tax_inside_city_limits := p1_a36;
    ddp_location_rec.fa_location_id := rosetta_g_miss_num_map(p1_a37);
    ddp_location_rec.content_source_type := p1_a38;
    ddp_location_rec.attribute_category := p1_a39;
    ddp_location_rec.attribute1 := p1_a40;
    ddp_location_rec.attribute2 := p1_a41;
    ddp_location_rec.attribute3 := p1_a42;
    ddp_location_rec.attribute4 := p1_a43;
    ddp_location_rec.attribute5 := p1_a44;
    ddp_location_rec.attribute6 := p1_a45;
    ddp_location_rec.attribute7 := p1_a46;
    ddp_location_rec.attribute8 := p1_a47;
    ddp_location_rec.attribute9 := p1_a48;
    ddp_location_rec.attribute10 := p1_a49;
    ddp_location_rec.attribute11 := p1_a50;
    ddp_location_rec.attribute12 := p1_a51;
    ddp_location_rec.attribute13 := p1_a52;
    ddp_location_rec.attribute14 := p1_a53;
    ddp_location_rec.attribute15 := p1_a54;
    ddp_location_rec.attribute16 := p1_a55;
    ddp_location_rec.attribute17 := p1_a56;
    ddp_location_rec.attribute18 := p1_a57;
    ddp_location_rec.attribute19 := p1_a58;
    ddp_location_rec.attribute20 := p1_a59;
    ddp_location_rec.timezone_id := rosetta_g_miss_num_map(p1_a60);
    ddp_location_rec.created_by_module := p1_a61;
    ddp_location_rec.application_id := rosetta_g_miss_num_map(p1_a62);
    ddp_location_rec.actual_content_source := p1_a63;
    ddp_location_rec.delivery_point_code := p1_a64;





    -- here's the delegated call to the old PL/SQL routine
    hz_location_v2pub.create_location(p_init_msg_list,
      ddp_location_rec,
      x_location_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_location_2(p_init_msg_list  VARCHAR2
    , p_do_addr_val  VARCHAR2
    , x_location_id out nocopy  NUMBER
    , x_addr_val_status out nocopy  VARCHAR2
    , x_addr_warn_msg out nocopy  VARCHAR2
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
    , p1_a27  DATE := null
    , p1_a28  DATE := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  VARCHAR2 := null
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
  )
  as
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_location_rec.location_id := rosetta_g_miss_num_map(p1_a0);
    ddp_location_rec.orig_system_reference := p1_a1;
    ddp_location_rec.orig_system := p1_a2;
    ddp_location_rec.country := p1_a3;
    ddp_location_rec.address1 := p1_a4;
    ddp_location_rec.address2 := p1_a5;
    ddp_location_rec.address3 := p1_a6;
    ddp_location_rec.address4 := p1_a7;
    ddp_location_rec.city := p1_a8;
    ddp_location_rec.postal_code := p1_a9;
    ddp_location_rec.state := p1_a10;
    ddp_location_rec.province := p1_a11;
    ddp_location_rec.county := p1_a12;
    ddp_location_rec.address_key := p1_a13;
    ddp_location_rec.address_style := p1_a14;
    ddp_location_rec.validated_flag := p1_a15;
    ddp_location_rec.address_lines_phonetic := p1_a16;
    ddp_location_rec.po_box_number := p1_a17;
    ddp_location_rec.house_number := p1_a18;
    ddp_location_rec.street_suffix := p1_a19;
    ddp_location_rec.street := p1_a20;
    ddp_location_rec.street_number := p1_a21;
    ddp_location_rec.floor := p1_a22;
    ddp_location_rec.suite := p1_a23;
    ddp_location_rec.postal_plus4_code := p1_a24;
    ddp_location_rec.position := p1_a25;
    ddp_location_rec.location_directions := p1_a26;
    ddp_location_rec.address_effective_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_location_rec.clli_code := p1_a29;
    ddp_location_rec.language := p1_a30;
    ddp_location_rec.short_description := p1_a31;
    ddp_location_rec.description := p1_a32;
    ddp_location_rec.geometry_status_code := p1_a33;
    ddp_location_rec.loc_hierarchy_id := rosetta_g_miss_num_map(p1_a34);
    ddp_location_rec.sales_tax_geocode := p1_a35;
    ddp_location_rec.sales_tax_inside_city_limits := p1_a36;
    ddp_location_rec.fa_location_id := rosetta_g_miss_num_map(p1_a37);
    ddp_location_rec.content_source_type := p1_a38;
    ddp_location_rec.attribute_category := p1_a39;
    ddp_location_rec.attribute1 := p1_a40;
    ddp_location_rec.attribute2 := p1_a41;
    ddp_location_rec.attribute3 := p1_a42;
    ddp_location_rec.attribute4 := p1_a43;
    ddp_location_rec.attribute5 := p1_a44;
    ddp_location_rec.attribute6 := p1_a45;
    ddp_location_rec.attribute7 := p1_a46;
    ddp_location_rec.attribute8 := p1_a47;
    ddp_location_rec.attribute9 := p1_a48;
    ddp_location_rec.attribute10 := p1_a49;
    ddp_location_rec.attribute11 := p1_a50;
    ddp_location_rec.attribute12 := p1_a51;
    ddp_location_rec.attribute13 := p1_a52;
    ddp_location_rec.attribute14 := p1_a53;
    ddp_location_rec.attribute15 := p1_a54;
    ddp_location_rec.attribute16 := p1_a55;
    ddp_location_rec.attribute17 := p1_a56;
    ddp_location_rec.attribute18 := p1_a57;
    ddp_location_rec.attribute19 := p1_a58;
    ddp_location_rec.attribute20 := p1_a59;
    ddp_location_rec.timezone_id := rosetta_g_miss_num_map(p1_a60);
    ddp_location_rec.created_by_module := p1_a61;
    ddp_location_rec.application_id := rosetta_g_miss_num_map(p1_a62);
    ddp_location_rec.actual_content_source := p1_a63;
    ddp_location_rec.delivery_point_code := p1_a64;








    -- here's the delegated call to the old PL/SQL routine
    hz_location_v2pub.create_location(p_init_msg_list,
      ddp_location_rec,
      p_do_addr_val,
      x_location_id,
      x_addr_val_status,
      x_addr_warn_msg,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_location_3(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
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
    , p1_a27  DATE := null
    , p1_a28  DATE := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  VARCHAR2 := null
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
  )
  as
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_location_rec.location_id := rosetta_g_miss_num_map(p1_a0);
    ddp_location_rec.orig_system_reference := p1_a1;
    ddp_location_rec.orig_system := p1_a2;
    ddp_location_rec.country := p1_a3;
    ddp_location_rec.address1 := p1_a4;
    ddp_location_rec.address2 := p1_a5;
    ddp_location_rec.address3 := p1_a6;
    ddp_location_rec.address4 := p1_a7;
    ddp_location_rec.city := p1_a8;
    ddp_location_rec.postal_code := p1_a9;
    ddp_location_rec.state := p1_a10;
    ddp_location_rec.province := p1_a11;
    ddp_location_rec.county := p1_a12;
    ddp_location_rec.address_key := p1_a13;
    ddp_location_rec.address_style := p1_a14;
    ddp_location_rec.validated_flag := p1_a15;
    ddp_location_rec.address_lines_phonetic := p1_a16;
    ddp_location_rec.po_box_number := p1_a17;
    ddp_location_rec.house_number := p1_a18;
    ddp_location_rec.street_suffix := p1_a19;
    ddp_location_rec.street := p1_a20;
    ddp_location_rec.street_number := p1_a21;
    ddp_location_rec.floor := p1_a22;
    ddp_location_rec.suite := p1_a23;
    ddp_location_rec.postal_plus4_code := p1_a24;
    ddp_location_rec.position := p1_a25;
    ddp_location_rec.location_directions := p1_a26;
    ddp_location_rec.address_effective_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_location_rec.clli_code := p1_a29;
    ddp_location_rec.language := p1_a30;
    ddp_location_rec.short_description := p1_a31;
    ddp_location_rec.description := p1_a32;
    ddp_location_rec.geometry_status_code := p1_a33;
    ddp_location_rec.loc_hierarchy_id := rosetta_g_miss_num_map(p1_a34);
    ddp_location_rec.sales_tax_geocode := p1_a35;
    ddp_location_rec.sales_tax_inside_city_limits := p1_a36;
    ddp_location_rec.fa_location_id := rosetta_g_miss_num_map(p1_a37);
    ddp_location_rec.content_source_type := p1_a38;
    ddp_location_rec.attribute_category := p1_a39;
    ddp_location_rec.attribute1 := p1_a40;
    ddp_location_rec.attribute2 := p1_a41;
    ddp_location_rec.attribute3 := p1_a42;
    ddp_location_rec.attribute4 := p1_a43;
    ddp_location_rec.attribute5 := p1_a44;
    ddp_location_rec.attribute6 := p1_a45;
    ddp_location_rec.attribute7 := p1_a46;
    ddp_location_rec.attribute8 := p1_a47;
    ddp_location_rec.attribute9 := p1_a48;
    ddp_location_rec.attribute10 := p1_a49;
    ddp_location_rec.attribute11 := p1_a50;
    ddp_location_rec.attribute12 := p1_a51;
    ddp_location_rec.attribute13 := p1_a52;
    ddp_location_rec.attribute14 := p1_a53;
    ddp_location_rec.attribute15 := p1_a54;
    ddp_location_rec.attribute16 := p1_a55;
    ddp_location_rec.attribute17 := p1_a56;
    ddp_location_rec.attribute18 := p1_a57;
    ddp_location_rec.attribute19 := p1_a58;
    ddp_location_rec.attribute20 := p1_a59;
    ddp_location_rec.timezone_id := rosetta_g_miss_num_map(p1_a60);
    ddp_location_rec.created_by_module := p1_a61;
    ddp_location_rec.application_id := rosetta_g_miss_num_map(p1_a62);
    ddp_location_rec.actual_content_source := p1_a63;
    ddp_location_rec.delivery_point_code := p1_a64;





    -- here's the delegated call to the old PL/SQL routine
    hz_location_v2pub.update_location(p_init_msg_list,
      ddp_location_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_location_4(p_init_msg_list  VARCHAR2
    , p_do_addr_val  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_addr_val_status out nocopy  VARCHAR2
    , x_addr_warn_msg out nocopy  VARCHAR2
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
    , p1_a27  DATE := null
    , p1_a28  DATE := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  NUMBER := null
    , p1_a35  VARCHAR2 := null
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
  )
  as
    ddp_location_rec hz_location_v2pub.location_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_location_rec.location_id := rosetta_g_miss_num_map(p1_a0);
    ddp_location_rec.orig_system_reference := p1_a1;
    ddp_location_rec.orig_system := p1_a2;
    ddp_location_rec.country := p1_a3;
    ddp_location_rec.address1 := p1_a4;
    ddp_location_rec.address2 := p1_a5;
    ddp_location_rec.address3 := p1_a6;
    ddp_location_rec.address4 := p1_a7;
    ddp_location_rec.city := p1_a8;
    ddp_location_rec.postal_code := p1_a9;
    ddp_location_rec.state := p1_a10;
    ddp_location_rec.province := p1_a11;
    ddp_location_rec.county := p1_a12;
    ddp_location_rec.address_key := p1_a13;
    ddp_location_rec.address_style := p1_a14;
    ddp_location_rec.validated_flag := p1_a15;
    ddp_location_rec.address_lines_phonetic := p1_a16;
    ddp_location_rec.po_box_number := p1_a17;
    ddp_location_rec.house_number := p1_a18;
    ddp_location_rec.street_suffix := p1_a19;
    ddp_location_rec.street := p1_a20;
    ddp_location_rec.street_number := p1_a21;
    ddp_location_rec.floor := p1_a22;
    ddp_location_rec.suite := p1_a23;
    ddp_location_rec.postal_plus4_code := p1_a24;
    ddp_location_rec.position := p1_a25;
    ddp_location_rec.location_directions := p1_a26;
    ddp_location_rec.address_effective_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_location_rec.address_expiration_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_location_rec.clli_code := p1_a29;
    ddp_location_rec.language := p1_a30;
    ddp_location_rec.short_description := p1_a31;
    ddp_location_rec.description := p1_a32;
    ddp_location_rec.geometry_status_code := p1_a33;
    ddp_location_rec.loc_hierarchy_id := rosetta_g_miss_num_map(p1_a34);
    ddp_location_rec.sales_tax_geocode := p1_a35;
    ddp_location_rec.sales_tax_inside_city_limits := p1_a36;
    ddp_location_rec.fa_location_id := rosetta_g_miss_num_map(p1_a37);
    ddp_location_rec.content_source_type := p1_a38;
    ddp_location_rec.attribute_category := p1_a39;
    ddp_location_rec.attribute1 := p1_a40;
    ddp_location_rec.attribute2 := p1_a41;
    ddp_location_rec.attribute3 := p1_a42;
    ddp_location_rec.attribute4 := p1_a43;
    ddp_location_rec.attribute5 := p1_a44;
    ddp_location_rec.attribute6 := p1_a45;
    ddp_location_rec.attribute7 := p1_a46;
    ddp_location_rec.attribute8 := p1_a47;
    ddp_location_rec.attribute9 := p1_a48;
    ddp_location_rec.attribute10 := p1_a49;
    ddp_location_rec.attribute11 := p1_a50;
    ddp_location_rec.attribute12 := p1_a51;
    ddp_location_rec.attribute13 := p1_a52;
    ddp_location_rec.attribute14 := p1_a53;
    ddp_location_rec.attribute15 := p1_a54;
    ddp_location_rec.attribute16 := p1_a55;
    ddp_location_rec.attribute17 := p1_a56;
    ddp_location_rec.attribute18 := p1_a57;
    ddp_location_rec.attribute19 := p1_a58;
    ddp_location_rec.attribute20 := p1_a59;
    ddp_location_rec.timezone_id := rosetta_g_miss_num_map(p1_a60);
    ddp_location_rec.created_by_module := p1_a61;
    ddp_location_rec.application_id := rosetta_g_miss_num_map(p1_a62);
    ddp_location_rec.actual_content_source := p1_a63;
    ddp_location_rec.delivery_point_code := p1_a64;








    -- here's the delegated call to the old PL/SQL routine
    hz_location_v2pub.update_location(p_init_msg_list,
      ddp_location_rec,
      p_do_addr_val,
      p_object_version_number,
      x_addr_val_status,
      x_addr_warn_msg,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure get_location_rec_5(p_init_msg_list  VARCHAR2
    , p_location_id  NUMBER
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
    , p2_a27 out nocopy  DATE
    , p2_a28 out nocopy  DATE
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  NUMBER
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  NUMBER
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p2_a42 out nocopy  VARCHAR2
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p2_a45 out nocopy  VARCHAR2
    , p2_a46 out nocopy  VARCHAR2
    , p2_a47 out nocopy  VARCHAR2
    , p2_a48 out nocopy  VARCHAR2
    , p2_a49 out nocopy  VARCHAR2
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  NUMBER
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  NUMBER
    , p2_a63 out nocopy  VARCHAR2
    , p2_a64 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_location_rec hz_location_v2pub.location_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_location_v2pub.get_location_rec(p_init_msg_list,
      p_location_id,
      ddx_location_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_location_rec.location_id);
    p2_a1 := ddx_location_rec.orig_system_reference;
    p2_a2 := ddx_location_rec.orig_system;
    p2_a3 := ddx_location_rec.country;
    p2_a4 := ddx_location_rec.address1;
    p2_a5 := ddx_location_rec.address2;
    p2_a6 := ddx_location_rec.address3;
    p2_a7 := ddx_location_rec.address4;
    p2_a8 := ddx_location_rec.city;
    p2_a9 := ddx_location_rec.postal_code;
    p2_a10 := ddx_location_rec.state;
    p2_a11 := ddx_location_rec.province;
    p2_a12 := ddx_location_rec.county;
    p2_a13 := ddx_location_rec.address_key;
    p2_a14 := ddx_location_rec.address_style;
    p2_a15 := ddx_location_rec.validated_flag;
    p2_a16 := ddx_location_rec.address_lines_phonetic;
    p2_a17 := ddx_location_rec.po_box_number;
    p2_a18 := ddx_location_rec.house_number;
    p2_a19 := ddx_location_rec.street_suffix;
    p2_a20 := ddx_location_rec.street;
    p2_a21 := ddx_location_rec.street_number;
    p2_a22 := ddx_location_rec.floor;
    p2_a23 := ddx_location_rec.suite;
    p2_a24 := ddx_location_rec.postal_plus4_code;
    p2_a25 := ddx_location_rec.position;
    p2_a26 := ddx_location_rec.location_directions;
    p2_a27 := ddx_location_rec.address_effective_date;
    p2_a28 := ddx_location_rec.address_expiration_date;
    p2_a29 := ddx_location_rec.clli_code;
    p2_a30 := ddx_location_rec.language;
    p2_a31 := ddx_location_rec.short_description;
    p2_a32 := ddx_location_rec.description;
    p2_a33 := ddx_location_rec.geometry_status_code;
    p2_a34 := rosetta_g_miss_num_map(ddx_location_rec.loc_hierarchy_id);
    p2_a35 := ddx_location_rec.sales_tax_geocode;
    p2_a36 := ddx_location_rec.sales_tax_inside_city_limits;
    p2_a37 := rosetta_g_miss_num_map(ddx_location_rec.fa_location_id);
    p2_a38 := ddx_location_rec.content_source_type;
    p2_a39 := ddx_location_rec.attribute_category;
    p2_a40 := ddx_location_rec.attribute1;
    p2_a41 := ddx_location_rec.attribute2;
    p2_a42 := ddx_location_rec.attribute3;
    p2_a43 := ddx_location_rec.attribute4;
    p2_a44 := ddx_location_rec.attribute5;
    p2_a45 := ddx_location_rec.attribute6;
    p2_a46 := ddx_location_rec.attribute7;
    p2_a47 := ddx_location_rec.attribute8;
    p2_a48 := ddx_location_rec.attribute9;
    p2_a49 := ddx_location_rec.attribute10;
    p2_a50 := ddx_location_rec.attribute11;
    p2_a51 := ddx_location_rec.attribute12;
    p2_a52 := ddx_location_rec.attribute13;
    p2_a53 := ddx_location_rec.attribute14;
    p2_a54 := ddx_location_rec.attribute15;
    p2_a55 := ddx_location_rec.attribute16;
    p2_a56 := ddx_location_rec.attribute17;
    p2_a57 := ddx_location_rec.attribute18;
    p2_a58 := ddx_location_rec.attribute19;
    p2_a59 := ddx_location_rec.attribute20;
    p2_a60 := rosetta_g_miss_num_map(ddx_location_rec.timezone_id);
    p2_a61 := ddx_location_rec.created_by_module;
    p2_a62 := rosetta_g_miss_num_map(ddx_location_rec.application_id);
    p2_a63 := ddx_location_rec.actual_content_source;
    p2_a64 := ddx_location_rec.delivery_point_code;



  end;

end hz_location_v2pub_jw;

/
