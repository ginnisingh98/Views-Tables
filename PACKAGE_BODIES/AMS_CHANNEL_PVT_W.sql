--------------------------------------------------------
--  DDL for Package Body AMS_CHANNEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CHANNEL_PVT_W" as
  /* $Header: amswchab.pls 115.17 2003/06/04 18:40:16 dbiswas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_chan_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
  )

  as
    ddp_chan_rec ams_channel_pvt.chan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_chan_rec.channel_id := p7_a0;
    ddp_chan_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_chan_rec.last_updated_by := p7_a2;
    ddp_chan_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_chan_rec.created_by := p7_a4;
    ddp_chan_rec.last_update_login := p7_a5;
    ddp_chan_rec.object_version_number := p7_a6;
    ddp_chan_rec.channel_type_code := p7_a7;
    ddp_chan_rec.order_sequence := p7_a8;
    ddp_chan_rec.managed_by_person_id := p7_a9;
    ddp_chan_rec.outbound_flag := p7_a10;
    ddp_chan_rec.inbound_flag := p7_a11;
    ddp_chan_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_chan_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_chan_rec.rating := p7_a14;
    ddp_chan_rec.preferred_vendor_id := p7_a15;
    ddp_chan_rec.party_id := p7_a16;
    ddp_chan_rec.attribute_category := p7_a17;
    ddp_chan_rec.attribute1 := p7_a18;
    ddp_chan_rec.attribute2 := p7_a19;
    ddp_chan_rec.attribute3 := p7_a20;
    ddp_chan_rec.attribute4 := p7_a21;
    ddp_chan_rec.attribute5 := p7_a22;
    ddp_chan_rec.attribute6 := p7_a23;
    ddp_chan_rec.attribute7 := p7_a24;
    ddp_chan_rec.attribute8 := p7_a25;
    ddp_chan_rec.attribute9 := p7_a26;
    ddp_chan_rec.attribute10 := p7_a27;
    ddp_chan_rec.attribute11 := p7_a28;
    ddp_chan_rec.attribute12 := p7_a29;
    ddp_chan_rec.attribute13 := p7_a30;
    ddp_chan_rec.attribute14 := p7_a31;
    ddp_chan_rec.attribute15 := p7_a32;
    ddp_chan_rec.channel_name := p7_a33;
    ddp_chan_rec.description := p7_a34;
    ddp_chan_rec.country_id := p7_a35;


    -- here's the delegated call to the old PL/SQL routine
    ams_channel_pvt.create_channel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chan_rec,
      x_chan_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
  )

  as
    ddp_chan_rec ams_channel_pvt.chan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_chan_rec.channel_id := p7_a0;
    ddp_chan_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_chan_rec.last_updated_by := p7_a2;
    ddp_chan_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_chan_rec.created_by := p7_a4;
    ddp_chan_rec.last_update_login := p7_a5;
    ddp_chan_rec.object_version_number := p7_a6;
    ddp_chan_rec.channel_type_code := p7_a7;
    ddp_chan_rec.order_sequence := p7_a8;
    ddp_chan_rec.managed_by_person_id := p7_a9;
    ddp_chan_rec.outbound_flag := p7_a10;
    ddp_chan_rec.inbound_flag := p7_a11;
    ddp_chan_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_chan_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_chan_rec.rating := p7_a14;
    ddp_chan_rec.preferred_vendor_id := p7_a15;
    ddp_chan_rec.party_id := p7_a16;
    ddp_chan_rec.attribute_category := p7_a17;
    ddp_chan_rec.attribute1 := p7_a18;
    ddp_chan_rec.attribute2 := p7_a19;
    ddp_chan_rec.attribute3 := p7_a20;
    ddp_chan_rec.attribute4 := p7_a21;
    ddp_chan_rec.attribute5 := p7_a22;
    ddp_chan_rec.attribute6 := p7_a23;
    ddp_chan_rec.attribute7 := p7_a24;
    ddp_chan_rec.attribute8 := p7_a25;
    ddp_chan_rec.attribute9 := p7_a26;
    ddp_chan_rec.attribute10 := p7_a27;
    ddp_chan_rec.attribute11 := p7_a28;
    ddp_chan_rec.attribute12 := p7_a29;
    ddp_chan_rec.attribute13 := p7_a30;
    ddp_chan_rec.attribute14 := p7_a31;
    ddp_chan_rec.attribute15 := p7_a32;
    ddp_chan_rec.channel_name := p7_a33;
    ddp_chan_rec.description := p7_a34;
    ddp_chan_rec.country_id := p7_a35;

    -- here's the delegated call to the old PL/SQL routine
    ams_channel_pvt.update_channel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chan_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  NUMBER := 0-1962.0724
  )

  as
    ddp_chan_rec ams_channel_pvt.chan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_chan_rec.channel_id := p6_a0;
    ddp_chan_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_chan_rec.last_updated_by := p6_a2;
    ddp_chan_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_chan_rec.created_by := p6_a4;
    ddp_chan_rec.last_update_login := p6_a5;
    ddp_chan_rec.object_version_number := p6_a6;
    ddp_chan_rec.channel_type_code := p6_a7;
    ddp_chan_rec.order_sequence := p6_a8;
    ddp_chan_rec.managed_by_person_id := p6_a9;
    ddp_chan_rec.outbound_flag := p6_a10;
    ddp_chan_rec.inbound_flag := p6_a11;
    ddp_chan_rec.active_from_date := rosetta_g_miss_date_in_map(p6_a12);
    ddp_chan_rec.active_to_date := rosetta_g_miss_date_in_map(p6_a13);
    ddp_chan_rec.rating := p6_a14;
    ddp_chan_rec.preferred_vendor_id := p6_a15;
    ddp_chan_rec.party_id := p6_a16;
    ddp_chan_rec.attribute_category := p6_a17;
    ddp_chan_rec.attribute1 := p6_a18;
    ddp_chan_rec.attribute2 := p6_a19;
    ddp_chan_rec.attribute3 := p6_a20;
    ddp_chan_rec.attribute4 := p6_a21;
    ddp_chan_rec.attribute5 := p6_a22;
    ddp_chan_rec.attribute6 := p6_a23;
    ddp_chan_rec.attribute7 := p6_a24;
    ddp_chan_rec.attribute8 := p6_a25;
    ddp_chan_rec.attribute9 := p6_a26;
    ddp_chan_rec.attribute10 := p6_a27;
    ddp_chan_rec.attribute11 := p6_a28;
    ddp_chan_rec.attribute12 := p6_a29;
    ddp_chan_rec.attribute13 := p6_a30;
    ddp_chan_rec.attribute14 := p6_a31;
    ddp_chan_rec.attribute15 := p6_a32;
    ddp_chan_rec.channel_name := p6_a33;
    ddp_chan_rec.description := p6_a34;
    ddp_chan_rec.country_id := p6_a35;

    -- here's the delegated call to the old PL/SQL routine
    ams_channel_pvt.validate_channel(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_chan_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_chan_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
  )

  as
    ddp_chan_rec ams_channel_pvt.chan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_chan_rec.channel_id := p0_a0;
    ddp_chan_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_chan_rec.last_updated_by := p0_a2;
    ddp_chan_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_chan_rec.created_by := p0_a4;
    ddp_chan_rec.last_update_login := p0_a5;
    ddp_chan_rec.object_version_number := p0_a6;
    ddp_chan_rec.channel_type_code := p0_a7;
    ddp_chan_rec.order_sequence := p0_a8;
    ddp_chan_rec.managed_by_person_id := p0_a9;
    ddp_chan_rec.outbound_flag := p0_a10;
    ddp_chan_rec.inbound_flag := p0_a11;
    ddp_chan_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_chan_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a13);
    ddp_chan_rec.rating := p0_a14;
    ddp_chan_rec.preferred_vendor_id := p0_a15;
    ddp_chan_rec.party_id := p0_a16;
    ddp_chan_rec.attribute_category := p0_a17;
    ddp_chan_rec.attribute1 := p0_a18;
    ddp_chan_rec.attribute2 := p0_a19;
    ddp_chan_rec.attribute3 := p0_a20;
    ddp_chan_rec.attribute4 := p0_a21;
    ddp_chan_rec.attribute5 := p0_a22;
    ddp_chan_rec.attribute6 := p0_a23;
    ddp_chan_rec.attribute7 := p0_a24;
    ddp_chan_rec.attribute8 := p0_a25;
    ddp_chan_rec.attribute9 := p0_a26;
    ddp_chan_rec.attribute10 := p0_a27;
    ddp_chan_rec.attribute11 := p0_a28;
    ddp_chan_rec.attribute12 := p0_a29;
    ddp_chan_rec.attribute13 := p0_a30;
    ddp_chan_rec.attribute14 := p0_a31;
    ddp_chan_rec.attribute15 := p0_a32;
    ddp_chan_rec.channel_name := p0_a33;
    ddp_chan_rec.description := p0_a34;
    ddp_chan_rec.country_id := p0_a35;



    -- here's the delegated call to the old PL/SQL routine
    ams_channel_pvt.check_chan_items(ddp_chan_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_chan_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  DATE
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  NUMBER
  )

  as
    ddx_chan_rec ams_channel_pvt.chan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_channel_pvt.init_chan_rec(ddx_chan_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_chan_rec.channel_id;
    p0_a1 := ddx_chan_rec.last_update_date;
    p0_a2 := ddx_chan_rec.last_updated_by;
    p0_a3 := ddx_chan_rec.creation_date;
    p0_a4 := ddx_chan_rec.created_by;
    p0_a5 := ddx_chan_rec.last_update_login;
    p0_a6 := ddx_chan_rec.object_version_number;
    p0_a7 := ddx_chan_rec.channel_type_code;
    p0_a8 := ddx_chan_rec.order_sequence;
    p0_a9 := ddx_chan_rec.managed_by_person_id;
    p0_a10 := ddx_chan_rec.outbound_flag;
    p0_a11 := ddx_chan_rec.inbound_flag;
    p0_a12 := ddx_chan_rec.active_from_date;
    p0_a13 := ddx_chan_rec.active_to_date;
    p0_a14 := ddx_chan_rec.rating;
    p0_a15 := ddx_chan_rec.preferred_vendor_id;
    p0_a16 := ddx_chan_rec.party_id;
    p0_a17 := ddx_chan_rec.attribute_category;
    p0_a18 := ddx_chan_rec.attribute1;
    p0_a19 := ddx_chan_rec.attribute2;
    p0_a20 := ddx_chan_rec.attribute3;
    p0_a21 := ddx_chan_rec.attribute4;
    p0_a22 := ddx_chan_rec.attribute5;
    p0_a23 := ddx_chan_rec.attribute6;
    p0_a24 := ddx_chan_rec.attribute7;
    p0_a25 := ddx_chan_rec.attribute8;
    p0_a26 := ddx_chan_rec.attribute9;
    p0_a27 := ddx_chan_rec.attribute10;
    p0_a28 := ddx_chan_rec.attribute11;
    p0_a29 := ddx_chan_rec.attribute12;
    p0_a30 := ddx_chan_rec.attribute13;
    p0_a31 := ddx_chan_rec.attribute14;
    p0_a32 := ddx_chan_rec.attribute15;
    p0_a33 := ddx_chan_rec.channel_name;
    p0_a34 := ddx_chan_rec.description;
    p0_a35 := ddx_chan_rec.country_id;
  end;

  procedure complete_chan_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  DATE
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
  )

  as
    ddp_chan_rec ams_channel_pvt.chan_rec_type;
    ddx_complete_rec ams_channel_pvt.chan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_chan_rec.channel_id := p0_a0;
    ddp_chan_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_chan_rec.last_updated_by := p0_a2;
    ddp_chan_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_chan_rec.created_by := p0_a4;
    ddp_chan_rec.last_update_login := p0_a5;
    ddp_chan_rec.object_version_number := p0_a6;
    ddp_chan_rec.channel_type_code := p0_a7;
    ddp_chan_rec.order_sequence := p0_a8;
    ddp_chan_rec.managed_by_person_id := p0_a9;
    ddp_chan_rec.outbound_flag := p0_a10;
    ddp_chan_rec.inbound_flag := p0_a11;
    ddp_chan_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_chan_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a13);
    ddp_chan_rec.rating := p0_a14;
    ddp_chan_rec.preferred_vendor_id := p0_a15;
    ddp_chan_rec.party_id := p0_a16;
    ddp_chan_rec.attribute_category := p0_a17;
    ddp_chan_rec.attribute1 := p0_a18;
    ddp_chan_rec.attribute2 := p0_a19;
    ddp_chan_rec.attribute3 := p0_a20;
    ddp_chan_rec.attribute4 := p0_a21;
    ddp_chan_rec.attribute5 := p0_a22;
    ddp_chan_rec.attribute6 := p0_a23;
    ddp_chan_rec.attribute7 := p0_a24;
    ddp_chan_rec.attribute8 := p0_a25;
    ddp_chan_rec.attribute9 := p0_a26;
    ddp_chan_rec.attribute10 := p0_a27;
    ddp_chan_rec.attribute11 := p0_a28;
    ddp_chan_rec.attribute12 := p0_a29;
    ddp_chan_rec.attribute13 := p0_a30;
    ddp_chan_rec.attribute14 := p0_a31;
    ddp_chan_rec.attribute15 := p0_a32;
    ddp_chan_rec.channel_name := p0_a33;
    ddp_chan_rec.description := p0_a34;
    ddp_chan_rec.country_id := p0_a35;


    -- here's the delegated call to the old PL/SQL routine
    ams_channel_pvt.complete_chan_rec(ddp_chan_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.channel_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.channel_type_code;
    p1_a8 := ddx_complete_rec.order_sequence;
    p1_a9 := ddx_complete_rec.managed_by_person_id;
    p1_a10 := ddx_complete_rec.outbound_flag;
    p1_a11 := ddx_complete_rec.inbound_flag;
    p1_a12 := ddx_complete_rec.active_from_date;
    p1_a13 := ddx_complete_rec.active_to_date;
    p1_a14 := ddx_complete_rec.rating;
    p1_a15 := ddx_complete_rec.preferred_vendor_id;
    p1_a16 := ddx_complete_rec.party_id;
    p1_a17 := ddx_complete_rec.attribute_category;
    p1_a18 := ddx_complete_rec.attribute1;
    p1_a19 := ddx_complete_rec.attribute2;
    p1_a20 := ddx_complete_rec.attribute3;
    p1_a21 := ddx_complete_rec.attribute4;
    p1_a22 := ddx_complete_rec.attribute5;
    p1_a23 := ddx_complete_rec.attribute6;
    p1_a24 := ddx_complete_rec.attribute7;
    p1_a25 := ddx_complete_rec.attribute8;
    p1_a26 := ddx_complete_rec.attribute9;
    p1_a27 := ddx_complete_rec.attribute10;
    p1_a28 := ddx_complete_rec.attribute11;
    p1_a29 := ddx_complete_rec.attribute12;
    p1_a30 := ddx_complete_rec.attribute13;
    p1_a31 := ddx_complete_rec.attribute14;
    p1_a32 := ddx_complete_rec.attribute15;
    p1_a33 := ddx_complete_rec.channel_name;
    p1_a34 := ddx_complete_rec.description;
    p1_a35 := ddx_complete_rec.country_id;
  end;

end ams_channel_pvt_w;

/
