--------------------------------------------------------
--  DDL for Package Body AMS_LIST_WORD_REPLACES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_WORD_REPLACES_PVT_W" as
  /* $Header: amswwdrb.pls 115.6 2002/11/22 08:58:02 jieli ship $ */
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

  procedure create_list_word_replace(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_wrd_rpl_id OUT NOCOPY  NUMBER
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
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p7_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_wrd_rpl_rec.original_word := p7_a7;
    ddp_wrd_rpl_rec.replacement_word := p7_a8;
    ddp_wrd_rpl_rec.enabled_flag := p7_a9;
    ddp_wrd_rpl_rec.description := p7_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.create_list_word_replace(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_wrd_rpl_rec,
      x_wrd_rpl_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_list_word_replace(p_api_version  NUMBER
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
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p7_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_wrd_rpl_rec.original_word := p7_a7;
    ddp_wrd_rpl_rec.replacement_word := p7_a8;
    ddp_wrd_rpl_rec.enabled_flag := p7_a9;
    ddp_wrd_rpl_rec.description := p7_a10;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.update_list_word_replace(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_wrd_rpl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_list_word_replace(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p6_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_wrd_rpl_rec.original_word := p6_a7;
    ddp_wrd_rpl_rec.replacement_word := p6_a8;
    ddp_wrd_rpl_rec.enabled_flag := p6_a9;
    ddp_wrd_rpl_rec.description := p6_a10;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.validate_list_word_replace(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_wrd_rpl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  DATE := fnd_api.g_miss_date
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p2_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_wrd_rpl_rec.original_word := p2_a7;
    ddp_wrd_rpl_rec.replacement_word := p2_a8;
    ddp_wrd_rpl_rec.enabled_flag := p2_a9;
    ddp_wrd_rpl_rec.description := p2_a10;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_wrd_rpl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p1_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_wrd_rpl_rec.original_word := p1_a7;
    ddp_wrd_rpl_rec.replacement_word := p1_a8;
    ddp_wrd_rpl_rec.enabled_flag := p1_a9;
    ddp_wrd_rpl_rec.description := p1_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.check_req_items(p_validation_mode,
      ddp_wrd_rpl_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p1_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_wrd_rpl_rec.original_word := p1_a7;
    ddp_wrd_rpl_rec.replacement_word := p1_a8;
    ddp_wrd_rpl_rec.enabled_flag := p1_a9;
    ddp_wrd_rpl_rec.description := p1_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.check_uk_items(p_validation_mode,
      ddp_wrd_rpl_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure complete_rec(p1_a0 OUT NOCOPY  NUMBER
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
  )
  as
    ddp_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddx_complete_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_wrd_rpl_rec.list_word_replaces_id := rosetta_g_miss_num_map(p0_a0);
    ddp_wrd_rpl_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_wrd_rpl_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_wrd_rpl_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_wrd_rpl_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_wrd_rpl_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_wrd_rpl_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_wrd_rpl_rec.original_word := p0_a7;
    ddp_wrd_rpl_rec.replacement_word := p0_a8;
    ddp_wrd_rpl_rec.enabled_flag := p0_a9;
    ddp_wrd_rpl_rec.description := p0_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.complete_rec(ddp_wrd_rpl_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.list_word_replaces_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.original_word;
    p1_a8 := ddx_complete_rec.replacement_word;
    p1_a9 := ddx_complete_rec.enabled_flag;
    p1_a10 := ddx_complete_rec.description;
  end;

  procedure init_rec(p0_a0 OUT NOCOPY  NUMBER
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
  )
  as
    ddx_wrd_rpl_rec ams_list_word_replaces_pvt.wrd_rpl_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_list_word_replaces_pvt.init_rec(ddx_wrd_rpl_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_wrd_rpl_rec.list_word_replaces_id);
    p0_a1 := ddx_wrd_rpl_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_wrd_rpl_rec.last_updated_by);
    p0_a3 := ddx_wrd_rpl_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_wrd_rpl_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_wrd_rpl_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_wrd_rpl_rec.object_version_number);
    p0_a7 := ddx_wrd_rpl_rec.original_word;
    p0_a8 := ddx_wrd_rpl_rec.replacement_word;
    p0_a9 := ddx_wrd_rpl_rec.enabled_flag;
    p0_a10 := ddx_wrd_rpl_rec.description;
  end;

end ams_list_word_replaces_pvt_w;

/
