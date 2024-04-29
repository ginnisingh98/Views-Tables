--------------------------------------------------------
--  DDL for Package Body AMS_VENUE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_VENUE_PVT_W" as
  /* $Header: amswvnub.pls 115.8 2002/11/16 01:47:41 dbiswas ship $ */
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

  procedure create_venue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_venue_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_venue_rec.venue_type_code := p7_a8;
    ddp_venue_rec.venue_type_name := p7_a9;
    ddp_venue_rec.direct_phone_flag := p7_a10;
    ddp_venue_rec.internal_flag := p7_a11;
    ddp_venue_rec.enabled_flag := p7_a12;
    ddp_venue_rec.rating_code := p7_a13;
    ddp_venue_rec.telecom_code := p7_a14;
    ddp_venue_rec.rating_name := p7_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p7_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p7_a17);
    ddp_venue_rec.area_size_uom_code := p7_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p7_a19);
    ddp_venue_rec.ceiling_height_uom_code := p7_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p7_a21);
    ddp_venue_rec.usage_cost_uom_code := p7_a22;
    ddp_venue_rec.usage_cost_currency_code := p7_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p7_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p7_a25);
    ddp_venue_rec.directions := p7_a26;
    ddp_venue_rec.venue_code := p7_a27;
    ddp_venue_rec.object_type := p7_a28;
    ddp_venue_rec.attribute_category := p7_a29;
    ddp_venue_rec.attribute1 := p7_a30;
    ddp_venue_rec.attribute2 := p7_a31;
    ddp_venue_rec.attribute3 := p7_a32;
    ddp_venue_rec.attribute4 := p7_a33;
    ddp_venue_rec.attribute5 := p7_a34;
    ddp_venue_rec.attribute6 := p7_a35;
    ddp_venue_rec.attribute7 := p7_a36;
    ddp_venue_rec.attribute8 := p7_a37;
    ddp_venue_rec.attribute9 := p7_a38;
    ddp_venue_rec.attribute10 := p7_a39;
    ddp_venue_rec.attribute11 := p7_a40;
    ddp_venue_rec.attribute12 := p7_a41;
    ddp_venue_rec.attribute13 := p7_a42;
    ddp_venue_rec.attribute14 := p7_a43;
    ddp_venue_rec.attribute15 := p7_a44;
    ddp_venue_rec.venue_name := p7_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p7_a46);
    ddp_venue_rec.description := p7_a47;
    ddp_venue_rec.address1 := p7_a48;
    ddp_venue_rec.address2 := p7_a49;
    ddp_venue_rec.address3 := p7_a50;
    ddp_venue_rec.address4 := p7_a51;
    ddp_venue_rec.country_code := p7_a52;
    ddp_venue_rec.country := p7_a53;
    ddp_venue_rec.city := p7_a54;
    ddp_venue_rec.postal_code := p7_a55;
    ddp_venue_rec.state := p7_a56;
    ddp_venue_rec.province := p7_a57;
    ddp_venue_rec.county := p7_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p7_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p7_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p7_a61);


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.create_venue(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rec,
      x_venue_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure create_room(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_venue_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_venue_rec.venue_type_code := p7_a8;
    ddp_venue_rec.venue_type_name := p7_a9;
    ddp_venue_rec.direct_phone_flag := p7_a10;
    ddp_venue_rec.internal_flag := p7_a11;
    ddp_venue_rec.enabled_flag := p7_a12;
    ddp_venue_rec.rating_code := p7_a13;
    ddp_venue_rec.telecom_code := p7_a14;
    ddp_venue_rec.rating_name := p7_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p7_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p7_a17);
    ddp_venue_rec.area_size_uom_code := p7_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p7_a19);
    ddp_venue_rec.ceiling_height_uom_code := p7_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p7_a21);
    ddp_venue_rec.usage_cost_uom_code := p7_a22;
    ddp_venue_rec.usage_cost_currency_code := p7_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p7_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p7_a25);
    ddp_venue_rec.directions := p7_a26;
    ddp_venue_rec.venue_code := p7_a27;
    ddp_venue_rec.object_type := p7_a28;
    ddp_venue_rec.attribute_category := p7_a29;
    ddp_venue_rec.attribute1 := p7_a30;
    ddp_venue_rec.attribute2 := p7_a31;
    ddp_venue_rec.attribute3 := p7_a32;
    ddp_venue_rec.attribute4 := p7_a33;
    ddp_venue_rec.attribute5 := p7_a34;
    ddp_venue_rec.attribute6 := p7_a35;
    ddp_venue_rec.attribute7 := p7_a36;
    ddp_venue_rec.attribute8 := p7_a37;
    ddp_venue_rec.attribute9 := p7_a38;
    ddp_venue_rec.attribute10 := p7_a39;
    ddp_venue_rec.attribute11 := p7_a40;
    ddp_venue_rec.attribute12 := p7_a41;
    ddp_venue_rec.attribute13 := p7_a42;
    ddp_venue_rec.attribute14 := p7_a43;
    ddp_venue_rec.attribute15 := p7_a44;
    ddp_venue_rec.venue_name := p7_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p7_a46);
    ddp_venue_rec.description := p7_a47;
    ddp_venue_rec.address1 := p7_a48;
    ddp_venue_rec.address2 := p7_a49;
    ddp_venue_rec.address3 := p7_a50;
    ddp_venue_rec.address4 := p7_a51;
    ddp_venue_rec.country_code := p7_a52;
    ddp_venue_rec.country := p7_a53;
    ddp_venue_rec.city := p7_a54;
    ddp_venue_rec.postal_code := p7_a55;
    ddp_venue_rec.state := p7_a56;
    ddp_venue_rec.province := p7_a57;
    ddp_venue_rec.county := p7_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p7_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p7_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p7_a61);


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.create_room(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rec,
      x_venue_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_venue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_venue_rec.venue_type_code := p7_a8;
    ddp_venue_rec.venue_type_name := p7_a9;
    ddp_venue_rec.direct_phone_flag := p7_a10;
    ddp_venue_rec.internal_flag := p7_a11;
    ddp_venue_rec.enabled_flag := p7_a12;
    ddp_venue_rec.rating_code := p7_a13;
    ddp_venue_rec.telecom_code := p7_a14;
    ddp_venue_rec.rating_name := p7_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p7_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p7_a17);
    ddp_venue_rec.area_size_uom_code := p7_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p7_a19);
    ddp_venue_rec.ceiling_height_uom_code := p7_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p7_a21);
    ddp_venue_rec.usage_cost_uom_code := p7_a22;
    ddp_venue_rec.usage_cost_currency_code := p7_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p7_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p7_a25);
    ddp_venue_rec.directions := p7_a26;
    ddp_venue_rec.venue_code := p7_a27;
    ddp_venue_rec.object_type := p7_a28;
    ddp_venue_rec.attribute_category := p7_a29;
    ddp_venue_rec.attribute1 := p7_a30;
    ddp_venue_rec.attribute2 := p7_a31;
    ddp_venue_rec.attribute3 := p7_a32;
    ddp_venue_rec.attribute4 := p7_a33;
    ddp_venue_rec.attribute5 := p7_a34;
    ddp_venue_rec.attribute6 := p7_a35;
    ddp_venue_rec.attribute7 := p7_a36;
    ddp_venue_rec.attribute8 := p7_a37;
    ddp_venue_rec.attribute9 := p7_a38;
    ddp_venue_rec.attribute10 := p7_a39;
    ddp_venue_rec.attribute11 := p7_a40;
    ddp_venue_rec.attribute12 := p7_a41;
    ddp_venue_rec.attribute13 := p7_a42;
    ddp_venue_rec.attribute14 := p7_a43;
    ddp_venue_rec.attribute15 := p7_a44;
    ddp_venue_rec.venue_name := p7_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p7_a46);
    ddp_venue_rec.description := p7_a47;
    ddp_venue_rec.address1 := p7_a48;
    ddp_venue_rec.address2 := p7_a49;
    ddp_venue_rec.address3 := p7_a50;
    ddp_venue_rec.address4 := p7_a51;
    ddp_venue_rec.country_code := p7_a52;
    ddp_venue_rec.country := p7_a53;
    ddp_venue_rec.city := p7_a54;
    ddp_venue_rec.postal_code := p7_a55;
    ddp_venue_rec.state := p7_a56;
    ddp_venue_rec.province := p7_a57;
    ddp_venue_rec.county := p7_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p7_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p7_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p7_a61);

    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.update_venue(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure update_room(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_venue_rec.venue_type_code := p7_a8;
    ddp_venue_rec.venue_type_name := p7_a9;
    ddp_venue_rec.direct_phone_flag := p7_a10;
    ddp_venue_rec.internal_flag := p7_a11;
    ddp_venue_rec.enabled_flag := p7_a12;
    ddp_venue_rec.rating_code := p7_a13;
    ddp_venue_rec.telecom_code := p7_a14;
    ddp_venue_rec.rating_name := p7_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p7_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p7_a17);
    ddp_venue_rec.area_size_uom_code := p7_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p7_a19);
    ddp_venue_rec.ceiling_height_uom_code := p7_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p7_a21);
    ddp_venue_rec.usage_cost_uom_code := p7_a22;
    ddp_venue_rec.usage_cost_currency_code := p7_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p7_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p7_a25);
    ddp_venue_rec.directions := p7_a26;
    ddp_venue_rec.venue_code := p7_a27;
    ddp_venue_rec.object_type := p7_a28;
    ddp_venue_rec.attribute_category := p7_a29;
    ddp_venue_rec.attribute1 := p7_a30;
    ddp_venue_rec.attribute2 := p7_a31;
    ddp_venue_rec.attribute3 := p7_a32;
    ddp_venue_rec.attribute4 := p7_a33;
    ddp_venue_rec.attribute5 := p7_a34;
    ddp_venue_rec.attribute6 := p7_a35;
    ddp_venue_rec.attribute7 := p7_a36;
    ddp_venue_rec.attribute8 := p7_a37;
    ddp_venue_rec.attribute9 := p7_a38;
    ddp_venue_rec.attribute10 := p7_a39;
    ddp_venue_rec.attribute11 := p7_a40;
    ddp_venue_rec.attribute12 := p7_a41;
    ddp_venue_rec.attribute13 := p7_a42;
    ddp_venue_rec.attribute14 := p7_a43;
    ddp_venue_rec.attribute15 := p7_a44;
    ddp_venue_rec.venue_name := p7_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p7_a46);
    ddp_venue_rec.description := p7_a47;
    ddp_venue_rec.address1 := p7_a48;
    ddp_venue_rec.address2 := p7_a49;
    ddp_venue_rec.address3 := p7_a50;
    ddp_venue_rec.address4 := p7_a51;
    ddp_venue_rec.country_code := p7_a52;
    ddp_venue_rec.country := p7_a53;
    ddp_venue_rec.city := p7_a54;
    ddp_venue_rec.postal_code := p7_a55;
    ddp_venue_rec.state := p7_a56;
    ddp_venue_rec.province := p7_a57;
    ddp_venue_rec.county := p7_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p7_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p7_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p7_a61);

    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.update_room(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_venue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_object_type  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p7_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_venue_rec.venue_type_code := p7_a8;
    ddp_venue_rec.venue_type_name := p7_a9;
    ddp_venue_rec.direct_phone_flag := p7_a10;
    ddp_venue_rec.internal_flag := p7_a11;
    ddp_venue_rec.enabled_flag := p7_a12;
    ddp_venue_rec.rating_code := p7_a13;
    ddp_venue_rec.telecom_code := p7_a14;
    ddp_venue_rec.rating_name := p7_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p7_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p7_a17);
    ddp_venue_rec.area_size_uom_code := p7_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p7_a19);
    ddp_venue_rec.ceiling_height_uom_code := p7_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p7_a21);
    ddp_venue_rec.usage_cost_uom_code := p7_a22;
    ddp_venue_rec.usage_cost_currency_code := p7_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p7_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p7_a25);
    ddp_venue_rec.directions := p7_a26;
    ddp_venue_rec.venue_code := p7_a27;
    ddp_venue_rec.object_type := p7_a28;
    ddp_venue_rec.attribute_category := p7_a29;
    ddp_venue_rec.attribute1 := p7_a30;
    ddp_venue_rec.attribute2 := p7_a31;
    ddp_venue_rec.attribute3 := p7_a32;
    ddp_venue_rec.attribute4 := p7_a33;
    ddp_venue_rec.attribute5 := p7_a34;
    ddp_venue_rec.attribute6 := p7_a35;
    ddp_venue_rec.attribute7 := p7_a36;
    ddp_venue_rec.attribute8 := p7_a37;
    ddp_venue_rec.attribute9 := p7_a38;
    ddp_venue_rec.attribute10 := p7_a39;
    ddp_venue_rec.attribute11 := p7_a40;
    ddp_venue_rec.attribute12 := p7_a41;
    ddp_venue_rec.attribute13 := p7_a42;
    ddp_venue_rec.attribute14 := p7_a43;
    ddp_venue_rec.attribute15 := p7_a44;
    ddp_venue_rec.venue_name := p7_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p7_a46);
    ddp_venue_rec.description := p7_a47;
    ddp_venue_rec.address1 := p7_a48;
    ddp_venue_rec.address2 := p7_a49;
    ddp_venue_rec.address3 := p7_a50;
    ddp_venue_rec.address4 := p7_a51;
    ddp_venue_rec.country_code := p7_a52;
    ddp_venue_rec.country := p7_a53;
    ddp_venue_rec.city := p7_a54;
    ddp_venue_rec.postal_code := p7_a55;
    ddp_venue_rec.state := p7_a56;
    ddp_venue_rec.province := p7_a57;
    ddp_venue_rec.county := p7_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p7_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p7_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p7_a61);


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.validate_venue(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_venue_rec,
      p_object_type);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure check_venue_items(p_object_type  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p0_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_venue_rec.venue_type_code := p0_a8;
    ddp_venue_rec.venue_type_name := p0_a9;
    ddp_venue_rec.direct_phone_flag := p0_a10;
    ddp_venue_rec.internal_flag := p0_a11;
    ddp_venue_rec.enabled_flag := p0_a12;
    ddp_venue_rec.rating_code := p0_a13;
    ddp_venue_rec.telecom_code := p0_a14;
    ddp_venue_rec.rating_name := p0_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p0_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p0_a17);
    ddp_venue_rec.area_size_uom_code := p0_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p0_a19);
    ddp_venue_rec.ceiling_height_uom_code := p0_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p0_a21);
    ddp_venue_rec.usage_cost_uom_code := p0_a22;
    ddp_venue_rec.usage_cost_currency_code := p0_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p0_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p0_a25);
    ddp_venue_rec.directions := p0_a26;
    ddp_venue_rec.venue_code := p0_a27;
    ddp_venue_rec.object_type := p0_a28;
    ddp_venue_rec.attribute_category := p0_a29;
    ddp_venue_rec.attribute1 := p0_a30;
    ddp_venue_rec.attribute2 := p0_a31;
    ddp_venue_rec.attribute3 := p0_a32;
    ddp_venue_rec.attribute4 := p0_a33;
    ddp_venue_rec.attribute5 := p0_a34;
    ddp_venue_rec.attribute6 := p0_a35;
    ddp_venue_rec.attribute7 := p0_a36;
    ddp_venue_rec.attribute8 := p0_a37;
    ddp_venue_rec.attribute9 := p0_a38;
    ddp_venue_rec.attribute10 := p0_a39;
    ddp_venue_rec.attribute11 := p0_a40;
    ddp_venue_rec.attribute12 := p0_a41;
    ddp_venue_rec.attribute13 := p0_a42;
    ddp_venue_rec.attribute14 := p0_a43;
    ddp_venue_rec.attribute15 := p0_a44;
    ddp_venue_rec.venue_name := p0_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p0_a46);
    ddp_venue_rec.description := p0_a47;
    ddp_venue_rec.address1 := p0_a48;
    ddp_venue_rec.address2 := p0_a49;
    ddp_venue_rec.address3 := p0_a50;
    ddp_venue_rec.address4 := p0_a51;
    ddp_venue_rec.country_code := p0_a52;
    ddp_venue_rec.country := p0_a53;
    ddp_venue_rec.city := p0_a54;
    ddp_venue_rec.postal_code := p0_a55;
    ddp_venue_rec.state := p0_a56;
    ddp_venue_rec.province := p0_a57;
    ddp_venue_rec.county := p0_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p0_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p0_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p0_a61);




    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.check_venue_items(ddp_venue_rec,
      p_object_type,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any



  end;

  procedure check_venue_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  DATE := fnd_api.g_miss_date
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  NUMBER := 0-1962.0724
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  NUMBER := 0-1962.0724
    , p1_a26  VARCHAR2 := fnd_api.g_miss_char
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  VARCHAR2 := fnd_api.g_miss_char
    , p1_a33  VARCHAR2 := fnd_api.g_miss_char
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  VARCHAR2 := fnd_api.g_miss_char
    , p1_a37  VARCHAR2 := fnd_api.g_miss_char
    , p1_a38  VARCHAR2 := fnd_api.g_miss_char
    , p1_a39  VARCHAR2 := fnd_api.g_miss_char
    , p1_a40  VARCHAR2 := fnd_api.g_miss_char
    , p1_a41  VARCHAR2 := fnd_api.g_miss_char
    , p1_a42  VARCHAR2 := fnd_api.g_miss_char
    , p1_a43  VARCHAR2 := fnd_api.g_miss_char
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  VARCHAR2 := fnd_api.g_miss_char
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  VARCHAR2 := fnd_api.g_miss_char
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  VARCHAR2 := fnd_api.g_miss_char
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  NUMBER := 0-1962.0724
    , p1_a60  NUMBER := 0-1962.0724
    , p1_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddp_complete_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p0_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_venue_rec.venue_type_code := p0_a8;
    ddp_venue_rec.venue_type_name := p0_a9;
    ddp_venue_rec.direct_phone_flag := p0_a10;
    ddp_venue_rec.internal_flag := p0_a11;
    ddp_venue_rec.enabled_flag := p0_a12;
    ddp_venue_rec.rating_code := p0_a13;
    ddp_venue_rec.telecom_code := p0_a14;
    ddp_venue_rec.rating_name := p0_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p0_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p0_a17);
    ddp_venue_rec.area_size_uom_code := p0_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p0_a19);
    ddp_venue_rec.ceiling_height_uom_code := p0_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p0_a21);
    ddp_venue_rec.usage_cost_uom_code := p0_a22;
    ddp_venue_rec.usage_cost_currency_code := p0_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p0_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p0_a25);
    ddp_venue_rec.directions := p0_a26;
    ddp_venue_rec.venue_code := p0_a27;
    ddp_venue_rec.object_type := p0_a28;
    ddp_venue_rec.attribute_category := p0_a29;
    ddp_venue_rec.attribute1 := p0_a30;
    ddp_venue_rec.attribute2 := p0_a31;
    ddp_venue_rec.attribute3 := p0_a32;
    ddp_venue_rec.attribute4 := p0_a33;
    ddp_venue_rec.attribute5 := p0_a34;
    ddp_venue_rec.attribute6 := p0_a35;
    ddp_venue_rec.attribute7 := p0_a36;
    ddp_venue_rec.attribute8 := p0_a37;
    ddp_venue_rec.attribute9 := p0_a38;
    ddp_venue_rec.attribute10 := p0_a39;
    ddp_venue_rec.attribute11 := p0_a40;
    ddp_venue_rec.attribute12 := p0_a41;
    ddp_venue_rec.attribute13 := p0_a42;
    ddp_venue_rec.attribute14 := p0_a43;
    ddp_venue_rec.attribute15 := p0_a44;
    ddp_venue_rec.venue_name := p0_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p0_a46);
    ddp_venue_rec.description := p0_a47;
    ddp_venue_rec.address1 := p0_a48;
    ddp_venue_rec.address2 := p0_a49;
    ddp_venue_rec.address3 := p0_a50;
    ddp_venue_rec.address4 := p0_a51;
    ddp_venue_rec.country_code := p0_a52;
    ddp_venue_rec.country := p0_a53;
    ddp_venue_rec.city := p0_a54;
    ddp_venue_rec.postal_code := p0_a55;
    ddp_venue_rec.state := p0_a56;
    ddp_venue_rec.province := p0_a57;
    ddp_venue_rec.county := p0_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p0_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p0_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p0_a61);

    ddp_complete_rec.venue_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.custom_setup_id := rosetta_g_miss_num_map(p1_a1);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a3);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.venue_type_code := p1_a8;
    ddp_complete_rec.venue_type_name := p1_a9;
    ddp_complete_rec.direct_phone_flag := p1_a10;
    ddp_complete_rec.internal_flag := p1_a11;
    ddp_complete_rec.enabled_flag := p1_a12;
    ddp_complete_rec.rating_code := p1_a13;
    ddp_complete_rec.telecom_code := p1_a14;
    ddp_complete_rec.rating_name := p1_a15;
    ddp_complete_rec.capacity := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.area_size := rosetta_g_miss_num_map(p1_a17);
    ddp_complete_rec.area_size_uom_code := p1_a18;
    ddp_complete_rec.ceiling_height := rosetta_g_miss_num_map(p1_a19);
    ddp_complete_rec.ceiling_height_uom_code := p1_a20;
    ddp_complete_rec.usage_cost := rosetta_g_miss_num_map(p1_a21);
    ddp_complete_rec.usage_cost_uom_code := p1_a22;
    ddp_complete_rec.usage_cost_currency_code := p1_a23;
    ddp_complete_rec.parent_venue_id := rosetta_g_miss_num_map(p1_a24);
    ddp_complete_rec.location_id := rosetta_g_miss_num_map(p1_a25);
    ddp_complete_rec.directions := p1_a26;
    ddp_complete_rec.venue_code := p1_a27;
    ddp_complete_rec.object_type := p1_a28;
    ddp_complete_rec.attribute_category := p1_a29;
    ddp_complete_rec.attribute1 := p1_a30;
    ddp_complete_rec.attribute2 := p1_a31;
    ddp_complete_rec.attribute3 := p1_a32;
    ddp_complete_rec.attribute4 := p1_a33;
    ddp_complete_rec.attribute5 := p1_a34;
    ddp_complete_rec.attribute6 := p1_a35;
    ddp_complete_rec.attribute7 := p1_a36;
    ddp_complete_rec.attribute8 := p1_a37;
    ddp_complete_rec.attribute9 := p1_a38;
    ddp_complete_rec.attribute10 := p1_a39;
    ddp_complete_rec.attribute11 := p1_a40;
    ddp_complete_rec.attribute12 := p1_a41;
    ddp_complete_rec.attribute13 := p1_a42;
    ddp_complete_rec.attribute14 := p1_a43;
    ddp_complete_rec.attribute15 := p1_a44;
    ddp_complete_rec.venue_name := p1_a45;
    ddp_complete_rec.party_id := rosetta_g_miss_num_map(p1_a46);
    ddp_complete_rec.description := p1_a47;
    ddp_complete_rec.address1 := p1_a48;
    ddp_complete_rec.address2 := p1_a49;
    ddp_complete_rec.address3 := p1_a50;
    ddp_complete_rec.address4 := p1_a51;
    ddp_complete_rec.country_code := p1_a52;
    ddp_complete_rec.country := p1_a53;
    ddp_complete_rec.city := p1_a54;
    ddp_complete_rec.postal_code := p1_a55;
    ddp_complete_rec.state := p1_a56;
    ddp_complete_rec.province := p1_a57;
    ddp_complete_rec.county := p1_a58;
    ddp_complete_rec.salesforce_id := rosetta_g_miss_num_map(p1_a59);
    ddp_complete_rec.sales_group_id := rosetta_g_miss_num_map(p1_a60);
    ddp_complete_rec.person_id := rosetta_g_miss_num_map(p1_a61);


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.check_venue_record(ddp_venue_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_venue_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  NUMBER
    , p0_a2 OUT NOCOPY  DATE
    , p0_a3 OUT NOCOPY  NUMBER
    , p0_a4 OUT NOCOPY  DATE
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  VARCHAR2
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  NUMBER
    , p0_a17 OUT NOCOPY  NUMBER
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  NUMBER
    , p0_a20 OUT NOCOPY  VARCHAR2
    , p0_a21 OUT NOCOPY  NUMBER
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  NUMBER
    , p0_a25 OUT NOCOPY  NUMBER
    , p0_a26 OUT NOCOPY  VARCHAR2
    , p0_a27 OUT NOCOPY  VARCHAR2
    , p0_a28 OUT NOCOPY  VARCHAR2
    , p0_a29 OUT NOCOPY  VARCHAR2
    , p0_a30 OUT NOCOPY  VARCHAR2
    , p0_a31 OUT NOCOPY  VARCHAR2
    , p0_a32 OUT NOCOPY  VARCHAR2
    , p0_a33 OUT NOCOPY  VARCHAR2
    , p0_a34 OUT NOCOPY  VARCHAR2
    , p0_a35 OUT NOCOPY  VARCHAR2
    , p0_a36 OUT NOCOPY  VARCHAR2
    , p0_a37 OUT NOCOPY  VARCHAR2
    , p0_a38 OUT NOCOPY  VARCHAR2
    , p0_a39 OUT NOCOPY  VARCHAR2
    , p0_a40 OUT NOCOPY  VARCHAR2
    , p0_a41 OUT NOCOPY  VARCHAR2
    , p0_a42 OUT NOCOPY  VARCHAR2
    , p0_a43 OUT NOCOPY  VARCHAR2
    , p0_a44 OUT NOCOPY  VARCHAR2
    , p0_a45 OUT NOCOPY  VARCHAR2
    , p0_a46 OUT NOCOPY  NUMBER
    , p0_a47 OUT NOCOPY  VARCHAR2
    , p0_a48 OUT NOCOPY  VARCHAR2
    , p0_a49 OUT NOCOPY  VARCHAR2
    , p0_a50 OUT NOCOPY  VARCHAR2
    , p0_a51 OUT NOCOPY  VARCHAR2
    , p0_a52 OUT NOCOPY  VARCHAR2
    , p0_a53 OUT NOCOPY  VARCHAR2
    , p0_a54 OUT NOCOPY  VARCHAR2
    , p0_a55 OUT NOCOPY  VARCHAR2
    , p0_a56 OUT NOCOPY  VARCHAR2
    , p0_a57 OUT NOCOPY  VARCHAR2
    , p0_a58 OUT NOCOPY  VARCHAR2
    , p0_a59 OUT NOCOPY  NUMBER
    , p0_a60 OUT NOCOPY  NUMBER
    , p0_a61 OUT NOCOPY  NUMBER
  )
  as
    ddx_venue_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.init_venue_rec(ddx_venue_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_venue_rec.venue_id);
    p0_a1 := rosetta_g_miss_num_map(ddx_venue_rec.custom_setup_id);
    p0_a2 := ddx_venue_rec.last_update_date;
    p0_a3 := rosetta_g_miss_num_map(ddx_venue_rec.last_updated_by);
    p0_a4 := ddx_venue_rec.creation_date;
    p0_a5 := rosetta_g_miss_num_map(ddx_venue_rec.created_by);
    p0_a6 := rosetta_g_miss_num_map(ddx_venue_rec.last_update_login);
    p0_a7 := rosetta_g_miss_num_map(ddx_venue_rec.object_version_number);
    p0_a8 := ddx_venue_rec.venue_type_code;
    p0_a9 := ddx_venue_rec.venue_type_name;
    p0_a10 := ddx_venue_rec.direct_phone_flag;
    p0_a11 := ddx_venue_rec.internal_flag;
    p0_a12 := ddx_venue_rec.enabled_flag;
    p0_a13 := ddx_venue_rec.rating_code;
    p0_a14 := ddx_venue_rec.telecom_code;
    p0_a15 := ddx_venue_rec.rating_name;
    p0_a16 := rosetta_g_miss_num_map(ddx_venue_rec.capacity);
    p0_a17 := rosetta_g_miss_num_map(ddx_venue_rec.area_size);
    p0_a18 := ddx_venue_rec.area_size_uom_code;
    p0_a19 := rosetta_g_miss_num_map(ddx_venue_rec.ceiling_height);
    p0_a20 := ddx_venue_rec.ceiling_height_uom_code;
    p0_a21 := rosetta_g_miss_num_map(ddx_venue_rec.usage_cost);
    p0_a22 := ddx_venue_rec.usage_cost_uom_code;
    p0_a23 := ddx_venue_rec.usage_cost_currency_code;
    p0_a24 := rosetta_g_miss_num_map(ddx_venue_rec.parent_venue_id);
    p0_a25 := rosetta_g_miss_num_map(ddx_venue_rec.location_id);
    p0_a26 := ddx_venue_rec.directions;
    p0_a27 := ddx_venue_rec.venue_code;
    p0_a28 := ddx_venue_rec.object_type;
    p0_a29 := ddx_venue_rec.attribute_category;
    p0_a30 := ddx_venue_rec.attribute1;
    p0_a31 := ddx_venue_rec.attribute2;
    p0_a32 := ddx_venue_rec.attribute3;
    p0_a33 := ddx_venue_rec.attribute4;
    p0_a34 := ddx_venue_rec.attribute5;
    p0_a35 := ddx_venue_rec.attribute6;
    p0_a36 := ddx_venue_rec.attribute7;
    p0_a37 := ddx_venue_rec.attribute8;
    p0_a38 := ddx_venue_rec.attribute9;
    p0_a39 := ddx_venue_rec.attribute10;
    p0_a40 := ddx_venue_rec.attribute11;
    p0_a41 := ddx_venue_rec.attribute12;
    p0_a42 := ddx_venue_rec.attribute13;
    p0_a43 := ddx_venue_rec.attribute14;
    p0_a44 := ddx_venue_rec.attribute15;
    p0_a45 := ddx_venue_rec.venue_name;
    p0_a46 := rosetta_g_miss_num_map(ddx_venue_rec.party_id);
    p0_a47 := ddx_venue_rec.description;
    p0_a48 := ddx_venue_rec.address1;
    p0_a49 := ddx_venue_rec.address2;
    p0_a50 := ddx_venue_rec.address3;
    p0_a51 := ddx_venue_rec.address4;
    p0_a52 := ddx_venue_rec.country_code;
    p0_a53 := ddx_venue_rec.country;
    p0_a54 := ddx_venue_rec.city;
    p0_a55 := ddx_venue_rec.postal_code;
    p0_a56 := ddx_venue_rec.state;
    p0_a57 := ddx_venue_rec.province;
    p0_a58 := ddx_venue_rec.county;
    p0_a59 := rosetta_g_miss_num_map(ddx_venue_rec.salesforce_id);
    p0_a60 := rosetta_g_miss_num_map(ddx_venue_rec.sales_group_id);
    p0_a61 := rosetta_g_miss_num_map(ddx_venue_rec.person_id);
  end;

  procedure complete_venue_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  NUMBER
    , p1_a2 OUT NOCOPY  DATE
    , p1_a3 OUT NOCOPY  NUMBER
    , p1_a4 OUT NOCOPY  DATE
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  VARCHAR2
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  NUMBER
    , p1_a17 OUT NOCOPY  NUMBER
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  NUMBER
    , p1_a20 OUT NOCOPY  VARCHAR2
    , p1_a21 OUT NOCOPY  NUMBER
    , p1_a22 OUT NOCOPY  VARCHAR2
    , p1_a23 OUT NOCOPY  VARCHAR2
    , p1_a24 OUT NOCOPY  NUMBER
    , p1_a25 OUT NOCOPY  NUMBER
    , p1_a26 OUT NOCOPY  VARCHAR2
    , p1_a27 OUT NOCOPY  VARCHAR2
    , p1_a28 OUT NOCOPY  VARCHAR2
    , p1_a29 OUT NOCOPY  VARCHAR2
    , p1_a30 OUT NOCOPY  VARCHAR2
    , p1_a31 OUT NOCOPY  VARCHAR2
    , p1_a32 OUT NOCOPY  VARCHAR2
    , p1_a33 OUT NOCOPY  VARCHAR2
    , p1_a34 OUT NOCOPY  VARCHAR2
    , p1_a35 OUT NOCOPY  VARCHAR2
    , p1_a36 OUT NOCOPY  VARCHAR2
    , p1_a37 OUT NOCOPY  VARCHAR2
    , p1_a38 OUT NOCOPY  VARCHAR2
    , p1_a39 OUT NOCOPY  VARCHAR2
    , p1_a40 OUT NOCOPY  VARCHAR2
    , p1_a41 OUT NOCOPY  VARCHAR2
    , p1_a42 OUT NOCOPY  VARCHAR2
    , p1_a43 OUT NOCOPY  VARCHAR2
    , p1_a44 OUT NOCOPY  VARCHAR2
    , p1_a45 OUT NOCOPY  VARCHAR2
    , p1_a46 OUT NOCOPY  NUMBER
    , p1_a47 OUT NOCOPY  VARCHAR2
    , p1_a48 OUT NOCOPY  VARCHAR2
    , p1_a49 OUT NOCOPY  VARCHAR2
    , p1_a50 OUT NOCOPY  VARCHAR2
    , p1_a51 OUT NOCOPY  VARCHAR2
    , p1_a52 OUT NOCOPY  VARCHAR2
    , p1_a53 OUT NOCOPY  VARCHAR2
    , p1_a54 OUT NOCOPY  VARCHAR2
    , p1_a55 OUT NOCOPY  VARCHAR2
    , p1_a56 OUT NOCOPY  VARCHAR2
    , p1_a57 OUT NOCOPY  VARCHAR2
    , p1_a58 OUT NOCOPY  VARCHAR2
    , p1_a59 OUT NOCOPY  NUMBER
    , p1_a60 OUT NOCOPY  NUMBER
    , p1_a61 OUT NOCOPY  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
  )
  as
    ddp_venue_rec ams_venue_pvt.venue_rec_type;
    ddx_complete_rec ams_venue_pvt.venue_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_venue_rec.venue_id := rosetta_g_miss_num_map(p0_a0);
    ddp_venue_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a1);
    ddp_venue_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_venue_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_venue_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_venue_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_venue_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_venue_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_venue_rec.venue_type_code := p0_a8;
    ddp_venue_rec.venue_type_name := p0_a9;
    ddp_venue_rec.direct_phone_flag := p0_a10;
    ddp_venue_rec.internal_flag := p0_a11;
    ddp_venue_rec.enabled_flag := p0_a12;
    ddp_venue_rec.rating_code := p0_a13;
    ddp_venue_rec.telecom_code := p0_a14;
    ddp_venue_rec.rating_name := p0_a15;
    ddp_venue_rec.capacity := rosetta_g_miss_num_map(p0_a16);
    ddp_venue_rec.area_size := rosetta_g_miss_num_map(p0_a17);
    ddp_venue_rec.area_size_uom_code := p0_a18;
    ddp_venue_rec.ceiling_height := rosetta_g_miss_num_map(p0_a19);
    ddp_venue_rec.ceiling_height_uom_code := p0_a20;
    ddp_venue_rec.usage_cost := rosetta_g_miss_num_map(p0_a21);
    ddp_venue_rec.usage_cost_uom_code := p0_a22;
    ddp_venue_rec.usage_cost_currency_code := p0_a23;
    ddp_venue_rec.parent_venue_id := rosetta_g_miss_num_map(p0_a24);
    ddp_venue_rec.location_id := rosetta_g_miss_num_map(p0_a25);
    ddp_venue_rec.directions := p0_a26;
    ddp_venue_rec.venue_code := p0_a27;
    ddp_venue_rec.object_type := p0_a28;
    ddp_venue_rec.attribute_category := p0_a29;
    ddp_venue_rec.attribute1 := p0_a30;
    ddp_venue_rec.attribute2 := p0_a31;
    ddp_venue_rec.attribute3 := p0_a32;
    ddp_venue_rec.attribute4 := p0_a33;
    ddp_venue_rec.attribute5 := p0_a34;
    ddp_venue_rec.attribute6 := p0_a35;
    ddp_venue_rec.attribute7 := p0_a36;
    ddp_venue_rec.attribute8 := p0_a37;
    ddp_venue_rec.attribute9 := p0_a38;
    ddp_venue_rec.attribute10 := p0_a39;
    ddp_venue_rec.attribute11 := p0_a40;
    ddp_venue_rec.attribute12 := p0_a41;
    ddp_venue_rec.attribute13 := p0_a42;
    ddp_venue_rec.attribute14 := p0_a43;
    ddp_venue_rec.attribute15 := p0_a44;
    ddp_venue_rec.venue_name := p0_a45;
    ddp_venue_rec.party_id := rosetta_g_miss_num_map(p0_a46);
    ddp_venue_rec.description := p0_a47;
    ddp_venue_rec.address1 := p0_a48;
    ddp_venue_rec.address2 := p0_a49;
    ddp_venue_rec.address3 := p0_a50;
    ddp_venue_rec.address4 := p0_a51;
    ddp_venue_rec.country_code := p0_a52;
    ddp_venue_rec.country := p0_a53;
    ddp_venue_rec.city := p0_a54;
    ddp_venue_rec.postal_code := p0_a55;
    ddp_venue_rec.state := p0_a56;
    ddp_venue_rec.province := p0_a57;
    ddp_venue_rec.county := p0_a58;
    ddp_venue_rec.salesforce_id := rosetta_g_miss_num_map(p0_a59);
    ddp_venue_rec.sales_group_id := rosetta_g_miss_num_map(p0_a60);
    ddp_venue_rec.person_id := rosetta_g_miss_num_map(p0_a61);


    -- here's the delegated call to the old PL/SQL routine
    ams_venue_pvt.complete_venue_rec(ddp_venue_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.venue_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_complete_rec.custom_setup_id);
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a8 := ddx_complete_rec.venue_type_code;
    p1_a9 := ddx_complete_rec.venue_type_name;
    p1_a10 := ddx_complete_rec.direct_phone_flag;
    p1_a11 := ddx_complete_rec.internal_flag;
    p1_a12 := ddx_complete_rec.enabled_flag;
    p1_a13 := ddx_complete_rec.rating_code;
    p1_a14 := ddx_complete_rec.telecom_code;
    p1_a15 := ddx_complete_rec.rating_name;
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.capacity);
    p1_a17 := rosetta_g_miss_num_map(ddx_complete_rec.area_size);
    p1_a18 := ddx_complete_rec.area_size_uom_code;
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.ceiling_height);
    p1_a20 := ddx_complete_rec.ceiling_height_uom_code;
    p1_a21 := rosetta_g_miss_num_map(ddx_complete_rec.usage_cost);
    p1_a22 := ddx_complete_rec.usage_cost_uom_code;
    p1_a23 := ddx_complete_rec.usage_cost_currency_code;
    p1_a24 := rosetta_g_miss_num_map(ddx_complete_rec.parent_venue_id);
    p1_a25 := rosetta_g_miss_num_map(ddx_complete_rec.location_id);
    p1_a26 := ddx_complete_rec.directions;
    p1_a27 := ddx_complete_rec.venue_code;
    p1_a28 := ddx_complete_rec.object_type;
    p1_a29 := ddx_complete_rec.attribute_category;
    p1_a30 := ddx_complete_rec.attribute1;
    p1_a31 := ddx_complete_rec.attribute2;
    p1_a32 := ddx_complete_rec.attribute3;
    p1_a33 := ddx_complete_rec.attribute4;
    p1_a34 := ddx_complete_rec.attribute5;
    p1_a35 := ddx_complete_rec.attribute6;
    p1_a36 := ddx_complete_rec.attribute7;
    p1_a37 := ddx_complete_rec.attribute8;
    p1_a38 := ddx_complete_rec.attribute9;
    p1_a39 := ddx_complete_rec.attribute10;
    p1_a40 := ddx_complete_rec.attribute11;
    p1_a41 := ddx_complete_rec.attribute12;
    p1_a42 := ddx_complete_rec.attribute13;
    p1_a43 := ddx_complete_rec.attribute14;
    p1_a44 := ddx_complete_rec.attribute15;
    p1_a45 := ddx_complete_rec.venue_name;
    p1_a46 := rosetta_g_miss_num_map(ddx_complete_rec.party_id);
    p1_a47 := ddx_complete_rec.description;
    p1_a48 := ddx_complete_rec.address1;
    p1_a49 := ddx_complete_rec.address2;
    p1_a50 := ddx_complete_rec.address3;
    p1_a51 := ddx_complete_rec.address4;
    p1_a52 := ddx_complete_rec.country_code;
    p1_a53 := ddx_complete_rec.country;
    p1_a54 := ddx_complete_rec.city;
    p1_a55 := ddx_complete_rec.postal_code;
    p1_a56 := ddx_complete_rec.state;
    p1_a57 := ddx_complete_rec.province;
    p1_a58 := ddx_complete_rec.county;
    p1_a59 := rosetta_g_miss_num_map(ddx_complete_rec.salesforce_id);
    p1_a60 := rosetta_g_miss_num_map(ddx_complete_rec.sales_group_id);
    p1_a61 := rosetta_g_miss_num_map(ddx_complete_rec.person_id);
  end;

end ams_venue_pvt_w;

/
