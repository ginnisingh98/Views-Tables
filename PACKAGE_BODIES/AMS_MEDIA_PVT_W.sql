--------------------------------------------------------
--  DDL for Package Body AMS_MEDIA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MEDIA_PVT_W" as
  /* $Header: amswmedb.pls 115.13 2002/12/30 05:38:57 cgoyal ship $ */
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

  procedure create_media(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_media_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_media_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_media_rec.media_id := rosetta_g_miss_num_map(p7_a0);
    ddp_media_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_media_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_media_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_media_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_media_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_media_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_media_rec.media_type_code := p7_a7;
    ddp_media_rec.media_type_name := p7_a8;
    ddp_media_rec.inbound_flag := p7_a9;
    ddp_media_rec.enabled_flag := p7_a10;
    ddp_media_rec.attribute_category := p7_a11;
    ddp_media_rec.attribute1 := p7_a12;
    ddp_media_rec.attribute2 := p7_a13;
    ddp_media_rec.attribute3 := p7_a14;
    ddp_media_rec.attribute4 := p7_a15;
    ddp_media_rec.attribute5 := p7_a16;
    ddp_media_rec.attribute6 := p7_a17;
    ddp_media_rec.attribute7 := p7_a18;
    ddp_media_rec.attribute8 := p7_a19;
    ddp_media_rec.attribute9 := p7_a20;
    ddp_media_rec.attribute10 := p7_a21;
    ddp_media_rec.attribute11 := p7_a22;
    ddp_media_rec.attribute12 := p7_a23;
    ddp_media_rec.attribute13 := p7_a24;
    ddp_media_rec.attribute14 := p7_a25;
    ddp_media_rec.attribute15 := p7_a26;
    ddp_media_rec.media_name := p7_a27;
    ddp_media_rec.description := p7_a28;


    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.create_media(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec,
      x_media_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_media(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_media_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_media_rec.media_id := rosetta_g_miss_num_map(p7_a0);
    ddp_media_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_media_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_media_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_media_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_media_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_media_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_media_rec.media_type_code := p7_a7;
    ddp_media_rec.media_type_name := p7_a8;
    ddp_media_rec.inbound_flag := p7_a9;
    ddp_media_rec.enabled_flag := p7_a10;
    ddp_media_rec.attribute_category := p7_a11;
    ddp_media_rec.attribute1 := p7_a12;
    ddp_media_rec.attribute2 := p7_a13;
    ddp_media_rec.attribute3 := p7_a14;
    ddp_media_rec.attribute4 := p7_a15;
    ddp_media_rec.attribute5 := p7_a16;
    ddp_media_rec.attribute6 := p7_a17;
    ddp_media_rec.attribute7 := p7_a18;
    ddp_media_rec.attribute8 := p7_a19;
    ddp_media_rec.attribute9 := p7_a20;
    ddp_media_rec.attribute10 := p7_a21;
    ddp_media_rec.attribute11 := p7_a22;
    ddp_media_rec.attribute12 := p7_a23;
    ddp_media_rec.attribute13 := p7_a24;
    ddp_media_rec.attribute14 := p7_a25;
    ddp_media_rec.attribute15 := p7_a26;
    ddp_media_rec.media_name := p7_a27;
    ddp_media_rec.description := p7_a28;

    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.update_media(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_media(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_media_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_media_rec.media_id := rosetta_g_miss_num_map(p7_a0);
    ddp_media_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_media_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_media_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_media_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_media_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_media_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_media_rec.media_type_code := p7_a7;
    ddp_media_rec.media_type_name := p7_a8;
    ddp_media_rec.inbound_flag := p7_a9;
    ddp_media_rec.enabled_flag := p7_a10;
    ddp_media_rec.attribute_category := p7_a11;
    ddp_media_rec.attribute1 := p7_a12;
    ddp_media_rec.attribute2 := p7_a13;
    ddp_media_rec.attribute3 := p7_a14;
    ddp_media_rec.attribute4 := p7_a15;
    ddp_media_rec.attribute5 := p7_a16;
    ddp_media_rec.attribute6 := p7_a17;
    ddp_media_rec.attribute7 := p7_a18;
    ddp_media_rec.attribute8 := p7_a19;
    ddp_media_rec.attribute9 := p7_a20;
    ddp_media_rec.attribute10 := p7_a21;
    ddp_media_rec.attribute11 := p7_a22;
    ddp_media_rec.attribute12 := p7_a23;
    ddp_media_rec.attribute13 := p7_a24;
    ddp_media_rec.attribute14 := p7_a25;
    ddp_media_rec.attribute15 := p7_a26;
    ddp_media_rec.media_name := p7_a27;
    ddp_media_rec.description := p7_a28;

    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.validate_media(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_media_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_media_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_media_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_media_rec.media_id := rosetta_g_miss_num_map(p0_a0);
    ddp_media_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_media_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_media_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_media_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_media_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_media_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_media_rec.media_type_code := p0_a7;
    ddp_media_rec.media_type_name := p0_a8;
    ddp_media_rec.inbound_flag := p0_a9;
    ddp_media_rec.enabled_flag := p0_a10;
    ddp_media_rec.attribute_category := p0_a11;
    ddp_media_rec.attribute1 := p0_a12;
    ddp_media_rec.attribute2 := p0_a13;
    ddp_media_rec.attribute3 := p0_a14;
    ddp_media_rec.attribute4 := p0_a15;
    ddp_media_rec.attribute5 := p0_a16;
    ddp_media_rec.attribute6 := p0_a17;
    ddp_media_rec.attribute7 := p0_a18;
    ddp_media_rec.attribute8 := p0_a19;
    ddp_media_rec.attribute9 := p0_a20;
    ddp_media_rec.attribute10 := p0_a21;
    ddp_media_rec.attribute11 := p0_a22;
    ddp_media_rec.attribute12 := p0_a23;
    ddp_media_rec.attribute13 := p0_a24;
    ddp_media_rec.attribute14 := p0_a25;
    ddp_media_rec.attribute15 := p0_a26;
    ddp_media_rec.media_name := p0_a27;
    ddp_media_rec.description := p0_a28;



    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.check_media_items(ddp_media_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_media_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
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
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  VARCHAR2 := fnd_api.g_miss_char
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_media_rec ams_media_pvt.media_rec_type;
    ddp_complete_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_media_rec.media_id := rosetta_g_miss_num_map(p0_a0);
    ddp_media_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_media_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_media_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_media_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_media_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_media_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_media_rec.media_type_code := p0_a7;
    ddp_media_rec.media_type_name := p0_a8;
    ddp_media_rec.inbound_flag := p0_a9;
    ddp_media_rec.enabled_flag := p0_a10;
    ddp_media_rec.attribute_category := p0_a11;
    ddp_media_rec.attribute1 := p0_a12;
    ddp_media_rec.attribute2 := p0_a13;
    ddp_media_rec.attribute3 := p0_a14;
    ddp_media_rec.attribute4 := p0_a15;
    ddp_media_rec.attribute5 := p0_a16;
    ddp_media_rec.attribute6 := p0_a17;
    ddp_media_rec.attribute7 := p0_a18;
    ddp_media_rec.attribute8 := p0_a19;
    ddp_media_rec.attribute9 := p0_a20;
    ddp_media_rec.attribute10 := p0_a21;
    ddp_media_rec.attribute11 := p0_a22;
    ddp_media_rec.attribute12 := p0_a23;
    ddp_media_rec.attribute13 := p0_a24;
    ddp_media_rec.attribute14 := p0_a25;
    ddp_media_rec.attribute15 := p0_a26;
    ddp_media_rec.media_name := p0_a27;
    ddp_media_rec.description := p0_a28;

    ddp_complete_rec.media_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.media_type_code := p1_a7;
    ddp_complete_rec.media_type_name := p1_a8;
    ddp_complete_rec.inbound_flag := p1_a9;
    ddp_complete_rec.enabled_flag := p1_a10;
    ddp_complete_rec.attribute_category := p1_a11;
    ddp_complete_rec.attribute1 := p1_a12;
    ddp_complete_rec.attribute2 := p1_a13;
    ddp_complete_rec.attribute3 := p1_a14;
    ddp_complete_rec.attribute4 := p1_a15;
    ddp_complete_rec.attribute5 := p1_a16;
    ddp_complete_rec.attribute6 := p1_a17;
    ddp_complete_rec.attribute7 := p1_a18;
    ddp_complete_rec.attribute8 := p1_a19;
    ddp_complete_rec.attribute9 := p1_a20;
    ddp_complete_rec.attribute10 := p1_a21;
    ddp_complete_rec.attribute11 := p1_a22;
    ddp_complete_rec.attribute12 := p1_a23;
    ddp_complete_rec.attribute13 := p1_a24;
    ddp_complete_rec.attribute14 := p1_a25;
    ddp_complete_rec.attribute15 := p1_a26;
    ddp_complete_rec.media_name := p1_a27;
    ddp_complete_rec.description := p1_a28;


    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.check_media_record(ddp_media_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_media_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  VARCHAR2
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  VARCHAR2
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  VARCHAR2
    , p0_a20 OUT NOCOPY  VARCHAR2
    , p0_a21 OUT NOCOPY  VARCHAR2
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  VARCHAR2
    , p0_a25 OUT NOCOPY  VARCHAR2
    , p0_a26 OUT NOCOPY  VARCHAR2
    , p0_a27 OUT NOCOPY  VARCHAR2
    , p0_a28 OUT NOCOPY  VARCHAR2
  )
  as
    ddx_media_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.init_media_rec(ddx_media_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_media_rec.media_id);
    p0_a1 := ddx_media_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_media_rec.last_updated_by);
    p0_a3 := ddx_media_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_media_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_media_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_media_rec.object_version_number);
    p0_a7 := ddx_media_rec.media_type_code;
    p0_a8 := ddx_media_rec.media_type_name;
    p0_a9 := ddx_media_rec.inbound_flag;
    p0_a10 := ddx_media_rec.enabled_flag;
    p0_a11 := ddx_media_rec.attribute_category;
    p0_a12 := ddx_media_rec.attribute1;
    p0_a13 := ddx_media_rec.attribute2;
    p0_a14 := ddx_media_rec.attribute3;
    p0_a15 := ddx_media_rec.attribute4;
    p0_a16 := ddx_media_rec.attribute5;
    p0_a17 := ddx_media_rec.attribute6;
    p0_a18 := ddx_media_rec.attribute7;
    p0_a19 := ddx_media_rec.attribute8;
    p0_a20 := ddx_media_rec.attribute9;
    p0_a21 := ddx_media_rec.attribute10;
    p0_a22 := ddx_media_rec.attribute11;
    p0_a23 := ddx_media_rec.attribute12;
    p0_a24 := ddx_media_rec.attribute13;
    p0_a25 := ddx_media_rec.attribute14;
    p0_a26 := ddx_media_rec.attribute15;
    p0_a27 := ddx_media_rec.media_name;
    p0_a28 := ddx_media_rec.description;
  end;

  procedure complete_media_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  VARCHAR2
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  VARCHAR2
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  VARCHAR2
    , p1_a20 OUT NOCOPY  VARCHAR2
    , p1_a21 OUT NOCOPY  VARCHAR2
    , p1_a22 OUT NOCOPY  VARCHAR2
    , p1_a23 OUT NOCOPY  VARCHAR2
    , p1_a24 OUT NOCOPY  VARCHAR2
    , p1_a25 OUT NOCOPY  VARCHAR2
    , p1_a26 OUT NOCOPY  VARCHAR2
    , p1_a27 OUT NOCOPY  VARCHAR2
    , p1_a28 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_media_rec ams_media_pvt.media_rec_type;
    ddx_complete_rec ams_media_pvt.media_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_media_rec.media_id := rosetta_g_miss_num_map(p0_a0);
    ddp_media_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_media_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_media_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_media_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_media_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_media_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_media_rec.media_type_code := p0_a7;
    ddp_media_rec.media_type_name := p0_a8;
    ddp_media_rec.inbound_flag := p0_a9;
    ddp_media_rec.enabled_flag := p0_a10;
    ddp_media_rec.attribute_category := p0_a11;
    ddp_media_rec.attribute1 := p0_a12;
    ddp_media_rec.attribute2 := p0_a13;
    ddp_media_rec.attribute3 := p0_a14;
    ddp_media_rec.attribute4 := p0_a15;
    ddp_media_rec.attribute5 := p0_a16;
    ddp_media_rec.attribute6 := p0_a17;
    ddp_media_rec.attribute7 := p0_a18;
    ddp_media_rec.attribute8 := p0_a19;
    ddp_media_rec.attribute9 := p0_a20;
    ddp_media_rec.attribute10 := p0_a21;
    ddp_media_rec.attribute11 := p0_a22;
    ddp_media_rec.attribute12 := p0_a23;
    ddp_media_rec.attribute13 := p0_a24;
    ddp_media_rec.attribute14 := p0_a25;
    ddp_media_rec.attribute15 := p0_a26;
    ddp_media_rec.media_name := p0_a27;
    ddp_media_rec.description := p0_a28;


    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.complete_media_rec(ddp_media_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.media_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.media_type_code;
    p1_a8 := ddx_complete_rec.media_type_name;
    p1_a9 := ddx_complete_rec.inbound_flag;
    p1_a10 := ddx_complete_rec.enabled_flag;
    p1_a11 := ddx_complete_rec.attribute_category;
    p1_a12 := ddx_complete_rec.attribute1;
    p1_a13 := ddx_complete_rec.attribute2;
    p1_a14 := ddx_complete_rec.attribute3;
    p1_a15 := ddx_complete_rec.attribute4;
    p1_a16 := ddx_complete_rec.attribute5;
    p1_a17 := ddx_complete_rec.attribute6;
    p1_a18 := ddx_complete_rec.attribute7;
    p1_a19 := ddx_complete_rec.attribute8;
    p1_a20 := ddx_complete_rec.attribute9;
    p1_a21 := ddx_complete_rec.attribute10;
    p1_a22 := ddx_complete_rec.attribute11;
    p1_a23 := ddx_complete_rec.attribute12;
    p1_a24 := ddx_complete_rec.attribute13;
    p1_a25 := ddx_complete_rec.attribute14;
    p1_a26 := ddx_complete_rec.attribute15;
    p1_a27 := ddx_complete_rec.media_name;
    p1_a28 := ddx_complete_rec.description;
  end;

  procedure create_mediachannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_mediachl_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mediachl_rec.media_channel_id := rosetta_g_miss_num_map(p7_a0);
    ddp_mediachl_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_mediachl_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_mediachl_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_mediachl_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_mediachl_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_mediachl_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_mediachl_rec.media_id := rosetta_g_miss_num_map(p7_a7);
    ddp_mediachl_rec.channel_id := rosetta_g_miss_num_map(p7_a8);
    ddp_mediachl_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_mediachl_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a10);


    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.create_mediachannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mediachl_rec,
      x_mediachl_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_mediachannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mediachl_rec.media_channel_id := rosetta_g_miss_num_map(p7_a0);
    ddp_mediachl_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_mediachl_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_mediachl_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_mediachl_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_mediachl_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_mediachl_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_mediachl_rec.media_id := rosetta_g_miss_num_map(p7_a7);
    ddp_mediachl_rec.channel_id := rosetta_g_miss_num_map(p7_a8);
    ddp_mediachl_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_mediachl_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a10);

    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.update_mediachannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mediachl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_mediachannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mediachl_rec.media_channel_id := rosetta_g_miss_num_map(p7_a0);
    ddp_mediachl_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_mediachl_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_mediachl_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_mediachl_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_mediachl_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_mediachl_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_mediachl_rec.media_id := rosetta_g_miss_num_map(p7_a7);
    ddp_mediachl_rec.channel_id := rosetta_g_miss_num_map(p7_a8);
    ddp_mediachl_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_mediachl_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a10);

    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.validate_mediachannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mediachl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_mediachannel_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_mediachl_rec.media_channel_id := rosetta_g_miss_num_map(p0_a0);
    ddp_mediachl_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_mediachl_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_mediachl_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_mediachl_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_mediachl_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_mediachl_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_mediachl_rec.media_id := rosetta_g_miss_num_map(p0_a7);
    ddp_mediachl_rec.channel_id := rosetta_g_miss_num_map(p0_a8);
    ddp_mediachl_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_mediachl_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a10);



    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.check_mediachannel_items(ddp_mediachl_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_mediachannel_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  DATE := fnd_api.g_miss_date
    , p1_a10  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddp_complete_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_mediachl_rec.media_channel_id := rosetta_g_miss_num_map(p0_a0);
    ddp_mediachl_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_mediachl_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_mediachl_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_mediachl_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_mediachl_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_mediachl_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_mediachl_rec.media_id := rosetta_g_miss_num_map(p0_a7);
    ddp_mediachl_rec.channel_id := rosetta_g_miss_num_map(p0_a8);
    ddp_mediachl_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_mediachl_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a10);

    ddp_complete_rec.media_channel_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.media_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.channel_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a10);


    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.check_mediachannel_record(ddp_mediachl_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_mediachannel_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  DATE
    , p0_a10 OUT NOCOPY  DATE
  )
  as
    ddx_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.init_mediachannel_rec(ddx_mediachl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_mediachl_rec.media_channel_id);
    p0_a1 := ddx_mediachl_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_mediachl_rec.last_updated_by);
    p0_a3 := ddx_mediachl_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_mediachl_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_mediachl_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_mediachl_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_mediachl_rec.media_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_mediachl_rec.channel_id);
    p0_a9 := ddx_mediachl_rec.active_from_date;
    p0_a10 := ddx_mediachl_rec.active_to_date;
  end;

  procedure complete_mediachannel_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  DATE
    , p1_a10 OUT NOCOPY  DATE
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mediachl_rec ams_media_pvt.mediachannel_rec_type;
    ddx_complete_rec ams_media_pvt.mediachannel_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_mediachl_rec.media_channel_id := rosetta_g_miss_num_map(p0_a0);
    ddp_mediachl_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_mediachl_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_mediachl_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_mediachl_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_mediachl_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_mediachl_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_mediachl_rec.media_id := rosetta_g_miss_num_map(p0_a7);
    ddp_mediachl_rec.channel_id := rosetta_g_miss_num_map(p0_a8);
    ddp_mediachl_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_mediachl_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a10);


    -- here's the delegated call to the old PL/SQL routine
    ams_media_pvt.complete_mediachannel_rec(ddp_mediachl_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.media_channel_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.media_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.channel_id);
    p1_a9 := ddx_complete_rec.active_from_date;
    p1_a10 := ddx_complete_rec.active_to_date;
  end;

end ams_media_pvt_w;

/
