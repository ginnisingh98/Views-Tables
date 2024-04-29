--------------------------------------------------------
--  DDL for Package Body AMS_SETUP_ATTR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SETUP_ATTR_PVT_W" as
  /* $Header: amswattb.pls 115.14 2002/12/30 05:31:40 vmodur ship $ */
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

  procedure create_setup_attr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_setup_attr_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p7_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p7_a8);
    ddp_setup_attr_rec.object_attribute := p7_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p7_a10;
    ddp_setup_attr_rec.attr_available_flag := p7_a11;
    ddp_setup_attr_rec.function_name := p7_a12;
    ddp_setup_attr_rec.parent_function_name := p7_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p7_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p7_a15);
    ddp_setup_attr_rec.show_in_report := p7_a16;
    ddp_setup_attr_rec.show_in_cue_card := p7_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p7_a18;
    ddp_setup_attr_rec.related_ak_attribute := p7_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p7_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.create_setup_attr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_setup_attr_rec,
      x_setup_attr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_setup_attr(p_api_version  NUMBER
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
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p7_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p7_a8);
    ddp_setup_attr_rec.object_attribute := p7_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p7_a10;
    ddp_setup_attr_rec.attr_available_flag := p7_a11;
    ddp_setup_attr_rec.function_name := p7_a12;
    ddp_setup_attr_rec.parent_function_name := p7_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p7_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p7_a15);
    ddp_setup_attr_rec.show_in_report := p7_a16;
    ddp_setup_attr_rec.show_in_cue_card := p7_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p7_a18;
    ddp_setup_attr_rec.related_ak_attribute := p7_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p7_a20);

    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.update_setup_attr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_setup_attr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_setup_attr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p6_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p6_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p6_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p6_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p6_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p6_a8);
    ddp_setup_attr_rec.object_attribute := p6_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p6_a10;
    ddp_setup_attr_rec.attr_available_flag := p6_a11;
    ddp_setup_attr_rec.function_name := p6_a12;
    ddp_setup_attr_rec.parent_function_name := p6_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p6_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p6_a15);
    ddp_setup_attr_rec.show_in_report := p6_a16;
    ddp_setup_attr_rec.show_in_cue_card := p6_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p6_a18;
    ddp_setup_attr_rec.related_ak_attribute := p6_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p6_a20);

    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.validate_setup_attr(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_setup_attr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  DATE := fnd_api.g_miss_date
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p2_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p2_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p2_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p2_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p2_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p2_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p2_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p2_a8);
    ddp_setup_attr_rec.object_attribute := p2_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p2_a10;
    ddp_setup_attr_rec.attr_available_flag := p2_a11;
    ddp_setup_attr_rec.function_name := p2_a12;
    ddp_setup_attr_rec.parent_function_name := p2_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p2_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p2_a15);
    ddp_setup_attr_rec.show_in_report := p2_a16;
    ddp_setup_attr_rec.show_in_cue_card := p2_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p2_a18;
    ddp_setup_attr_rec.related_ak_attribute := p2_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p2_a20);

    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_setup_attr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_setup_attr_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p1_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p1_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p1_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p1_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p1_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p1_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p1_a8);
    ddp_setup_attr_rec.object_attribute := p1_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p1_a10;
    ddp_setup_attr_rec.attr_available_flag := p1_a11;
    ddp_setup_attr_rec.function_name := p1_a12;
    ddp_setup_attr_rec.parent_function_name := p1_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p1_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p1_a15);
    ddp_setup_attr_rec.show_in_report := p1_a16;
    ddp_setup_attr_rec.show_in_cue_card := p1_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p1_a18;
    ddp_setup_attr_rec.related_ak_attribute := p1_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p1_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.check_setup_attr_req_items(p_validation_mode,
      ddp_setup_attr_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_setup_attr_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p1_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p1_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p1_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p1_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p1_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p1_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p1_a8);
    ddp_setup_attr_rec.object_attribute := p1_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p1_a10;
    ddp_setup_attr_rec.attr_available_flag := p1_a11;
    ddp_setup_attr_rec.function_name := p1_a12;
    ddp_setup_attr_rec.parent_function_name := p1_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p1_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p1_a15);
    ddp_setup_attr_rec.show_in_report := p1_a16;
    ddp_setup_attr_rec.show_in_cue_card := p1_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p1_a18;
    ddp_setup_attr_rec.related_ak_attribute := p1_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p1_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.check_setup_attr_uk_items(p_validation_mode,
      ddp_setup_attr_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_setup_attr_fk_items(x_return_status OUT NOCOPY  VARCHAR2
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
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p0_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p0_a8);
    ddp_setup_attr_rec.object_attribute := p0_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p0_a10;
    ddp_setup_attr_rec.attr_available_flag := p0_a11;
    ddp_setup_attr_rec.function_name := p0_a12;
    ddp_setup_attr_rec.parent_function_name := p0_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p0_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p0_a15);
    ddp_setup_attr_rec.show_in_report := p0_a16;
    ddp_setup_attr_rec.show_in_cue_card := p0_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p0_a18;
    ddp_setup_attr_rec.related_ak_attribute := p0_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p0_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.check_setup_attr_fk_items(ddp_setup_attr_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure check_setup_attr_flag_items(x_return_status OUT NOCOPY  VARCHAR2
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
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p0_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p0_a8);
    ddp_setup_attr_rec.object_attribute := p0_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p0_a10;
    ddp_setup_attr_rec.attr_available_flag := p0_a11;
    ddp_setup_attr_rec.function_name := p0_a12;
    ddp_setup_attr_rec.parent_function_name := p0_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p0_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p0_a15);
    ddp_setup_attr_rec.show_in_report := p0_a16;
    ddp_setup_attr_rec.show_in_cue_card := p0_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p0_a18;
    ddp_setup_attr_rec.related_ak_attribute := p0_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p0_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.check_setup_attr_flag_items(ddp_setup_attr_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure complete_setup_attr_rec(p1_a0 OUT NOCOPY  NUMBER
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
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  VARCHAR2
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  NUMBER
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  VARCHAR2
    , p1_a20 OUT NOCOPY  NUMBER
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
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddx_complete_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_setup_attr_rec.setup_attribute_id := rosetta_g_miss_num_map(p0_a0);
    ddp_setup_attr_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a1);
    ddp_setup_attr_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_setup_attr_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_setup_attr_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_setup_attr_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_setup_attr_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_setup_attr_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_setup_attr_rec.display_sequence_no := rosetta_g_miss_num_map(p0_a8);
    ddp_setup_attr_rec.object_attribute := p0_a9;
    ddp_setup_attr_rec.attr_mandatory_flag := p0_a10;
    ddp_setup_attr_rec.attr_available_flag := p0_a11;
    ddp_setup_attr_rec.function_name := p0_a12;
    ddp_setup_attr_rec.parent_function_name := p0_a13;
    ddp_setup_attr_rec.parent_setup_attribute := p0_a14;
    ddp_setup_attr_rec.parent_display_sequence := rosetta_g_miss_num_map(p0_a15);
    ddp_setup_attr_rec.show_in_report := p0_a16;
    ddp_setup_attr_rec.show_in_cue_card := p0_a17;
    ddp_setup_attr_rec.copy_allowed_flag := p0_a18;
    ddp_setup_attr_rec.related_ak_attribute := p0_a19;
    ddp_setup_attr_rec.essential_seq_num := rosetta_g_miss_num_map(p0_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.complete_setup_attr_rec(ddp_setup_attr_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.setup_attribute_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_complete_rec.custom_setup_id);
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.display_sequence_no);
    p1_a9 := ddx_complete_rec.object_attribute;
    p1_a10 := ddx_complete_rec.attr_mandatory_flag;
    p1_a11 := ddx_complete_rec.attr_available_flag;
    p1_a12 := ddx_complete_rec.function_name;
    p1_a13 := ddx_complete_rec.parent_function_name;
    p1_a14 := ddx_complete_rec.parent_setup_attribute;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.parent_display_sequence);
    p1_a16 := ddx_complete_rec.show_in_report;
    p1_a17 := ddx_complete_rec.show_in_cue_card;
    p1_a18 := ddx_complete_rec.copy_allowed_flag;
    p1_a19 := ddx_complete_rec.related_ak_attribute;
    p1_a20 := rosetta_g_miss_num_map(ddx_complete_rec.essential_seq_num);
  end;

  procedure init_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  NUMBER
    , p0_a2 OUT NOCOPY  DATE
    , p0_a3 OUT NOCOPY  NUMBER
    , p0_a4 OUT NOCOPY  DATE
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  VARCHAR2
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  NUMBER
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  VARCHAR2
    , p0_a20 OUT NOCOPY  NUMBER
  )

  as
    ddx_setup_attr_rec ams_setup_attr_pvt.setup_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_setup_attr_pvt.init_rec(ddx_setup_attr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_setup_attr_rec.setup_attribute_id);
    p0_a1 := rosetta_g_miss_num_map(ddx_setup_attr_rec.custom_setup_id);
    p0_a2 := ddx_setup_attr_rec.last_update_date;
    p0_a3 := rosetta_g_miss_num_map(ddx_setup_attr_rec.last_updated_by);
    p0_a4 := ddx_setup_attr_rec.creation_date;
    p0_a5 := rosetta_g_miss_num_map(ddx_setup_attr_rec.created_by);
    p0_a6 := rosetta_g_miss_num_map(ddx_setup_attr_rec.last_update_login);
    p0_a7 := rosetta_g_miss_num_map(ddx_setup_attr_rec.object_version_number);
    p0_a8 := rosetta_g_miss_num_map(ddx_setup_attr_rec.display_sequence_no);
    p0_a9 := ddx_setup_attr_rec.object_attribute;
    p0_a10 := ddx_setup_attr_rec.attr_mandatory_flag;
    p0_a11 := ddx_setup_attr_rec.attr_available_flag;
    p0_a12 := ddx_setup_attr_rec.function_name;
    p0_a13 := ddx_setup_attr_rec.parent_function_name;
    p0_a14 := ddx_setup_attr_rec.parent_setup_attribute;
    p0_a15 := rosetta_g_miss_num_map(ddx_setup_attr_rec.parent_display_sequence);
    p0_a16 := ddx_setup_attr_rec.show_in_report;
    p0_a17 := ddx_setup_attr_rec.show_in_cue_card;
    p0_a18 := ddx_setup_attr_rec.copy_allowed_flag;
    p0_a19 := ddx_setup_attr_rec.related_ak_attribute;
    p0_a20 := rosetta_g_miss_num_map(ddx_setup_attr_rec.essential_seq_num);
  end;

end ams_setup_attr_pvt_w;

/
