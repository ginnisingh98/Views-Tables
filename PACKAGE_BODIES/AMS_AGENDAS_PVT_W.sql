--------------------------------------------------------
--  DDL for Package Body AMS_AGENDAS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_AGENDAS_PVT_W" as
  /* $Header: amswagnb.pls 115.2 2002/11/16 00:48:41 dbiswas ship $ */
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

  procedure create_agenda(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_agenda_id OUT NOCOPY  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p4_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p4_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p4_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p4_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p4_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p4_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p4_a8);
    ddp_agenda_rec.active_flag := p4_a9;
    ddp_agenda_rec.default_track_flag := p4_a10;
    ddp_agenda_rec.agenda_type := p4_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p4_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p4_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p4_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p4_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p4_a16);
    ddp_agenda_rec.parent_type := p4_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p4_a18);
    ddp_agenda_rec.attribute_category := p4_a19;
    ddp_agenda_rec.attribute1 := p4_a20;
    ddp_agenda_rec.attribute2 := p4_a21;
    ddp_agenda_rec.attribute3 := p4_a22;
    ddp_agenda_rec.attribute4 := p4_a23;
    ddp_agenda_rec.attribute5 := p4_a24;
    ddp_agenda_rec.attribute6 := p4_a25;
    ddp_agenda_rec.attribute7 := p4_a26;
    ddp_agenda_rec.attribute8 := p4_a27;
    ddp_agenda_rec.attribute9 := p4_a28;
    ddp_agenda_rec.attribute10 := p4_a29;
    ddp_agenda_rec.attribute11 := p4_a30;
    ddp_agenda_rec.attribute12 := p4_a31;
    ddp_agenda_rec.attribute13 := p4_a32;
    ddp_agenda_rec.attribute14 := p4_a33;
    ddp_agenda_rec.attribute15 := p4_a34;
    ddp_agenda_rec.agenda_name := p4_a35;
    ddp_agenda_rec.description := p4_a36;





    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.create_agenda(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_agenda_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_agenda_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_agenda(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p4_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p4_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p4_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p4_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p4_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p4_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p4_a8);
    ddp_agenda_rec.active_flag := p4_a9;
    ddp_agenda_rec.default_track_flag := p4_a10;
    ddp_agenda_rec.agenda_type := p4_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p4_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p4_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p4_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p4_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p4_a16);
    ddp_agenda_rec.parent_type := p4_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p4_a18);
    ddp_agenda_rec.attribute_category := p4_a19;
    ddp_agenda_rec.attribute1 := p4_a20;
    ddp_agenda_rec.attribute2 := p4_a21;
    ddp_agenda_rec.attribute3 := p4_a22;
    ddp_agenda_rec.attribute4 := p4_a23;
    ddp_agenda_rec.attribute5 := p4_a24;
    ddp_agenda_rec.attribute6 := p4_a25;
    ddp_agenda_rec.attribute7 := p4_a26;
    ddp_agenda_rec.attribute8 := p4_a27;
    ddp_agenda_rec.attribute9 := p4_a28;
    ddp_agenda_rec.attribute10 := p4_a29;
    ddp_agenda_rec.attribute11 := p4_a30;
    ddp_agenda_rec.attribute12 := p4_a31;
    ddp_agenda_rec.attribute13 := p4_a32;
    ddp_agenda_rec.attribute14 := p4_a33;
    ddp_agenda_rec.attribute15 := p4_a34;
    ddp_agenda_rec.agenda_name := p4_a35;
    ddp_agenda_rec.description := p4_a36;




    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.update_agenda(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_agenda_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_agenda(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  DATE := fnd_api.g_miss_date
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
    , p3_a33  VARCHAR2 := fnd_api.g_miss_char
    , p3_a34  VARCHAR2 := fnd_api.g_miss_char
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p3_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p3_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p3_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p3_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p3_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p3_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p3_a8);
    ddp_agenda_rec.active_flag := p3_a9;
    ddp_agenda_rec.default_track_flag := p3_a10;
    ddp_agenda_rec.agenda_type := p3_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p3_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p3_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p3_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p3_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p3_a16);
    ddp_agenda_rec.parent_type := p3_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p3_a18);
    ddp_agenda_rec.attribute_category := p3_a19;
    ddp_agenda_rec.attribute1 := p3_a20;
    ddp_agenda_rec.attribute2 := p3_a21;
    ddp_agenda_rec.attribute3 := p3_a22;
    ddp_agenda_rec.attribute4 := p3_a23;
    ddp_agenda_rec.attribute5 := p3_a24;
    ddp_agenda_rec.attribute6 := p3_a25;
    ddp_agenda_rec.attribute7 := p3_a26;
    ddp_agenda_rec.attribute8 := p3_a27;
    ddp_agenda_rec.attribute9 := p3_a28;
    ddp_agenda_rec.attribute10 := p3_a29;
    ddp_agenda_rec.attribute11 := p3_a30;
    ddp_agenda_rec.attribute12 := p3_a31;
    ddp_agenda_rec.attribute13 := p3_a32;
    ddp_agenda_rec.attribute14 := p3_a33;
    ddp_agenda_rec.attribute15 := p3_a34;
    ddp_agenda_rec.agenda_name := p3_a35;
    ddp_agenda_rec.description := p3_a36;




    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.validate_agenda(p_api_version,
      p_init_msg_list,
      p_validation_level,
      ddp_agenda_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure validate_agenda_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
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
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p0_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p0_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_agenda_rec.active_flag := p0_a9;
    ddp_agenda_rec.default_track_flag := p0_a10;
    ddp_agenda_rec.agenda_type := p0_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p0_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p0_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p0_a16);
    ddp_agenda_rec.parent_type := p0_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p0_a18);
    ddp_agenda_rec.attribute_category := p0_a19;
    ddp_agenda_rec.attribute1 := p0_a20;
    ddp_agenda_rec.attribute2 := p0_a21;
    ddp_agenda_rec.attribute3 := p0_a22;
    ddp_agenda_rec.attribute4 := p0_a23;
    ddp_agenda_rec.attribute5 := p0_a24;
    ddp_agenda_rec.attribute6 := p0_a25;
    ddp_agenda_rec.attribute7 := p0_a26;
    ddp_agenda_rec.attribute8 := p0_a27;
    ddp_agenda_rec.attribute9 := p0_a28;
    ddp_agenda_rec.attribute10 := p0_a29;
    ddp_agenda_rec.attribute11 := p0_a30;
    ddp_agenda_rec.attribute12 := p0_a31;
    ddp_agenda_rec.attribute13 := p0_a32;
    ddp_agenda_rec.attribute14 := p0_a33;
    ddp_agenda_rec.attribute15 := p0_a34;
    ddp_agenda_rec.agenda_name := p0_a35;
    ddp_agenda_rec.description := p0_a36;



    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.validate_agenda_items(ddp_agenda_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_agenda_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
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
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  DATE := fnd_api.g_miss_date
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  NUMBER := 0-1962.0724
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
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  VARCHAR2 := fnd_api.g_miss_char
    , p1_a33  VARCHAR2 := fnd_api.g_miss_char
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddp_complete_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p0_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p0_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_agenda_rec.active_flag := p0_a9;
    ddp_agenda_rec.default_track_flag := p0_a10;
    ddp_agenda_rec.agenda_type := p0_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p0_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p0_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p0_a16);
    ddp_agenda_rec.parent_type := p0_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p0_a18);
    ddp_agenda_rec.attribute_category := p0_a19;
    ddp_agenda_rec.attribute1 := p0_a20;
    ddp_agenda_rec.attribute2 := p0_a21;
    ddp_agenda_rec.attribute3 := p0_a22;
    ddp_agenda_rec.attribute4 := p0_a23;
    ddp_agenda_rec.attribute5 := p0_a24;
    ddp_agenda_rec.attribute6 := p0_a25;
    ddp_agenda_rec.attribute7 := p0_a26;
    ddp_agenda_rec.attribute8 := p0_a27;
    ddp_agenda_rec.attribute9 := p0_a28;
    ddp_agenda_rec.attribute10 := p0_a29;
    ddp_agenda_rec.attribute11 := p0_a30;
    ddp_agenda_rec.attribute12 := p0_a31;
    ddp_agenda_rec.attribute13 := p0_a32;
    ddp_agenda_rec.attribute14 := p0_a33;
    ddp_agenda_rec.attribute15 := p0_a34;
    ddp_agenda_rec.agenda_name := p0_a35;
    ddp_agenda_rec.description := p0_a36;

    ddp_complete_rec.agenda_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.setup_type_id := rosetta_g_miss_num_map(p1_a1);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a3);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.active_flag := p1_a9;
    ddp_complete_rec.default_track_flag := p1_a10;
    ddp_complete_rec.agenda_type := p1_a11;
    ddp_complete_rec.room_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.start_date_time := rosetta_g_miss_date_in_map(p1_a13);
    ddp_complete_rec.end_date_time := rosetta_g_miss_date_in_map(p1_a14);
    ddp_complete_rec.coordinator_id := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.timezone_id := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.parent_type := p1_a17;
    ddp_complete_rec.parent_id := rosetta_g_miss_num_map(p1_a18);
    ddp_complete_rec.attribute_category := p1_a19;
    ddp_complete_rec.attribute1 := p1_a20;
    ddp_complete_rec.attribute2 := p1_a21;
    ddp_complete_rec.attribute3 := p1_a22;
    ddp_complete_rec.attribute4 := p1_a23;
    ddp_complete_rec.attribute5 := p1_a24;
    ddp_complete_rec.attribute6 := p1_a25;
    ddp_complete_rec.attribute7 := p1_a26;
    ddp_complete_rec.attribute8 := p1_a27;
    ddp_complete_rec.attribute9 := p1_a28;
    ddp_complete_rec.attribute10 := p1_a29;
    ddp_complete_rec.attribute11 := p1_a30;
    ddp_complete_rec.attribute12 := p1_a31;
    ddp_complete_rec.attribute13 := p1_a32;
    ddp_complete_rec.attribute14 := p1_a33;
    ddp_complete_rec.attribute15 := p1_a34;
    ddp_complete_rec.agenda_name := p1_a35;
    ddp_complete_rec.description := p1_a36;


    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.validate_agenda_record(ddp_agenda_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_agenda_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  NUMBER
    , p1_a2 OUT NOCOPY  DATE
    , p1_a3 OUT NOCOPY  NUMBER
    , p1_a4 OUT NOCOPY  DATE
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  DATE
    , p1_a14 OUT NOCOPY  DATE
    , p1_a15 OUT NOCOPY  NUMBER
    , p1_a16 OUT NOCOPY  NUMBER
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  NUMBER
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
    , p1_a29 OUT NOCOPY  VARCHAR2
    , p1_a30 OUT NOCOPY  VARCHAR2
    , p1_a31 OUT NOCOPY  VARCHAR2
    , p1_a32 OUT NOCOPY  VARCHAR2
    , p1_a33 OUT NOCOPY  VARCHAR2
    , p1_a34 OUT NOCOPY  VARCHAR2
    , p1_a35 OUT NOCOPY  VARCHAR2
    , p1_a36 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
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
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddx_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p0_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p0_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_agenda_rec.active_flag := p0_a9;
    ddp_agenda_rec.default_track_flag := p0_a10;
    ddp_agenda_rec.agenda_type := p0_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p0_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p0_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p0_a16);
    ddp_agenda_rec.parent_type := p0_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p0_a18);
    ddp_agenda_rec.attribute_category := p0_a19;
    ddp_agenda_rec.attribute1 := p0_a20;
    ddp_agenda_rec.attribute2 := p0_a21;
    ddp_agenda_rec.attribute3 := p0_a22;
    ddp_agenda_rec.attribute4 := p0_a23;
    ddp_agenda_rec.attribute5 := p0_a24;
    ddp_agenda_rec.attribute6 := p0_a25;
    ddp_agenda_rec.attribute7 := p0_a26;
    ddp_agenda_rec.attribute8 := p0_a27;
    ddp_agenda_rec.attribute9 := p0_a28;
    ddp_agenda_rec.attribute10 := p0_a29;
    ddp_agenda_rec.attribute11 := p0_a30;
    ddp_agenda_rec.attribute12 := p0_a31;
    ddp_agenda_rec.attribute13 := p0_a32;
    ddp_agenda_rec.attribute14 := p0_a33;
    ddp_agenda_rec.attribute15 := p0_a34;
    ddp_agenda_rec.agenda_name := p0_a35;
    ddp_agenda_rec.description := p0_a36;


    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.init_agenda_rec(ddp_agenda_rec,
      ddx_agenda_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_agenda_rec.agenda_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_agenda_rec.setup_type_id);
    p1_a2 := ddx_agenda_rec.last_update_date;
    p1_a3 := rosetta_g_miss_num_map(ddx_agenda_rec.last_updated_by);
    p1_a4 := ddx_agenda_rec.creation_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_agenda_rec.created_by);
    p1_a6 := rosetta_g_miss_num_map(ddx_agenda_rec.last_update_login);
    p1_a7 := rosetta_g_miss_num_map(ddx_agenda_rec.object_version_number);
    p1_a8 := rosetta_g_miss_num_map(ddx_agenda_rec.application_id);
    p1_a9 := ddx_agenda_rec.active_flag;
    p1_a10 := ddx_agenda_rec.default_track_flag;
    p1_a11 := ddx_agenda_rec.agenda_type;
    p1_a12 := rosetta_g_miss_num_map(ddx_agenda_rec.room_id);
    p1_a13 := ddx_agenda_rec.start_date_time;
    p1_a14 := ddx_agenda_rec.end_date_time;
    p1_a15 := rosetta_g_miss_num_map(ddx_agenda_rec.coordinator_id);
    p1_a16 := rosetta_g_miss_num_map(ddx_agenda_rec.timezone_id);
    p1_a17 := ddx_agenda_rec.parent_type;
    p1_a18 := rosetta_g_miss_num_map(ddx_agenda_rec.parent_id);
    p1_a19 := ddx_agenda_rec.attribute_category;
    p1_a20 := ddx_agenda_rec.attribute1;
    p1_a21 := ddx_agenda_rec.attribute2;
    p1_a22 := ddx_agenda_rec.attribute3;
    p1_a23 := ddx_agenda_rec.attribute4;
    p1_a24 := ddx_agenda_rec.attribute5;
    p1_a25 := ddx_agenda_rec.attribute6;
    p1_a26 := ddx_agenda_rec.attribute7;
    p1_a27 := ddx_agenda_rec.attribute8;
    p1_a28 := ddx_agenda_rec.attribute9;
    p1_a29 := ddx_agenda_rec.attribute10;
    p1_a30 := ddx_agenda_rec.attribute11;
    p1_a31 := ddx_agenda_rec.attribute12;
    p1_a32 := ddx_agenda_rec.attribute13;
    p1_a33 := ddx_agenda_rec.attribute14;
    p1_a34 := ddx_agenda_rec.attribute15;
    p1_a35 := ddx_agenda_rec.agenda_name;
    p1_a36 := ddx_agenda_rec.description;
  end;

  procedure complete_agenda_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  NUMBER
    , p1_a2 OUT NOCOPY  DATE
    , p1_a3 OUT NOCOPY  NUMBER
    , p1_a4 OUT NOCOPY  DATE
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  DATE
    , p1_a14 OUT NOCOPY  DATE
    , p1_a15 OUT NOCOPY  NUMBER
    , p1_a16 OUT NOCOPY  NUMBER
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  NUMBER
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
    , p1_a29 OUT NOCOPY  VARCHAR2
    , p1_a30 OUT NOCOPY  VARCHAR2
    , p1_a31 OUT NOCOPY  VARCHAR2
    , p1_a32 OUT NOCOPY  VARCHAR2
    , p1_a33 OUT NOCOPY  VARCHAR2
    , p1_a34 OUT NOCOPY  VARCHAR2
    , p1_a35 OUT NOCOPY  VARCHAR2
    , p1_a36 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
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
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddx_agenda_rec ams_agendas_pvt.agenda_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_agenda_rec.agenda_id := rosetta_g_miss_num_map(p0_a0);
    ddp_agenda_rec.setup_type_id := rosetta_g_miss_num_map(p0_a1);
    ddp_agenda_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_agenda_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_agenda_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_agenda_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_agenda_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_agenda_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_agenda_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_agenda_rec.active_flag := p0_a9;
    ddp_agenda_rec.default_track_flag := p0_a10;
    ddp_agenda_rec.agenda_type := p0_a11;
    ddp_agenda_rec.room_id := rosetta_g_miss_num_map(p0_a12);
    ddp_agenda_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_agenda_rec.end_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_agenda_rec.coordinator_id := rosetta_g_miss_num_map(p0_a15);
    ddp_agenda_rec.timezone_id := rosetta_g_miss_num_map(p0_a16);
    ddp_agenda_rec.parent_type := p0_a17;
    ddp_agenda_rec.parent_id := rosetta_g_miss_num_map(p0_a18);
    ddp_agenda_rec.attribute_category := p0_a19;
    ddp_agenda_rec.attribute1 := p0_a20;
    ddp_agenda_rec.attribute2 := p0_a21;
    ddp_agenda_rec.attribute3 := p0_a22;
    ddp_agenda_rec.attribute4 := p0_a23;
    ddp_agenda_rec.attribute5 := p0_a24;
    ddp_agenda_rec.attribute6 := p0_a25;
    ddp_agenda_rec.attribute7 := p0_a26;
    ddp_agenda_rec.attribute8 := p0_a27;
    ddp_agenda_rec.attribute9 := p0_a28;
    ddp_agenda_rec.attribute10 := p0_a29;
    ddp_agenda_rec.attribute11 := p0_a30;
    ddp_agenda_rec.attribute12 := p0_a31;
    ddp_agenda_rec.attribute13 := p0_a32;
    ddp_agenda_rec.attribute14 := p0_a33;
    ddp_agenda_rec.attribute15 := p0_a34;
    ddp_agenda_rec.agenda_name := p0_a35;
    ddp_agenda_rec.description := p0_a36;


    -- here's the delegated call to the old PL/SQL routine
    ams_agendas_pvt.complete_agenda_rec(ddp_agenda_rec,
      ddx_agenda_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_agenda_rec.agenda_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_agenda_rec.setup_type_id);
    p1_a2 := ddx_agenda_rec.last_update_date;
    p1_a3 := rosetta_g_miss_num_map(ddx_agenda_rec.last_updated_by);
    p1_a4 := ddx_agenda_rec.creation_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_agenda_rec.created_by);
    p1_a6 := rosetta_g_miss_num_map(ddx_agenda_rec.last_update_login);
    p1_a7 := rosetta_g_miss_num_map(ddx_agenda_rec.object_version_number);
    p1_a8 := rosetta_g_miss_num_map(ddx_agenda_rec.application_id);
    p1_a9 := ddx_agenda_rec.active_flag;
    p1_a10 := ddx_agenda_rec.default_track_flag;
    p1_a11 := ddx_agenda_rec.agenda_type;
    p1_a12 := rosetta_g_miss_num_map(ddx_agenda_rec.room_id);
    p1_a13 := ddx_agenda_rec.start_date_time;
    p1_a14 := ddx_agenda_rec.end_date_time;
    p1_a15 := rosetta_g_miss_num_map(ddx_agenda_rec.coordinator_id);
    p1_a16 := rosetta_g_miss_num_map(ddx_agenda_rec.timezone_id);
    p1_a17 := ddx_agenda_rec.parent_type;
    p1_a18 := rosetta_g_miss_num_map(ddx_agenda_rec.parent_id);
    p1_a19 := ddx_agenda_rec.attribute_category;
    p1_a20 := ddx_agenda_rec.attribute1;
    p1_a21 := ddx_agenda_rec.attribute2;
    p1_a22 := ddx_agenda_rec.attribute3;
    p1_a23 := ddx_agenda_rec.attribute4;
    p1_a24 := ddx_agenda_rec.attribute5;
    p1_a25 := ddx_agenda_rec.attribute6;
    p1_a26 := ddx_agenda_rec.attribute7;
    p1_a27 := ddx_agenda_rec.attribute8;
    p1_a28 := ddx_agenda_rec.attribute9;
    p1_a29 := ddx_agenda_rec.attribute10;
    p1_a30 := ddx_agenda_rec.attribute11;
    p1_a31 := ddx_agenda_rec.attribute12;
    p1_a32 := ddx_agenda_rec.attribute13;
    p1_a33 := ddx_agenda_rec.attribute14;
    p1_a34 := ddx_agenda_rec.attribute15;
    p1_a35 := ddx_agenda_rec.agenda_name;
    p1_a36 := ddx_agenda_rec.description;
  end;

end ams_agendas_pvt_w;

/
