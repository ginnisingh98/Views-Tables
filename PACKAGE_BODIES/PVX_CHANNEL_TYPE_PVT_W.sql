--------------------------------------------------------
--  DDL for Package Body PVX_CHANNEL_TYPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_CHANNEL_TYPE_PVT_W" as
  /* $Header: pvwchnlb.pls 115.6 2002/12/26 16:05:14 vansub ship $ */
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

  procedure create_channel_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_channel_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_channel_type_rec pvx_channel_type_pvt.channel_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_channel_type_rec.channel_type_id := rosetta_g_miss_num_map(p4_a0);
    ddp_channel_type_rec.channel_lookup_type := p4_a1;
    ddp_channel_type_rec.channel_lookup_code := p4_a2;
    ddp_channel_type_rec.indirect_channel_flag := p4_a3;
    ddp_channel_type_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_channel_type_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_channel_type_rec.creation_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_channel_type_rec.created_by := rosetta_g_miss_num_map(p4_a7);
    ddp_channel_type_rec.last_update_login := rosetta_g_miss_num_map(p4_a8);
    ddp_channel_type_rec.object_version_number := rosetta_g_miss_num_map(p4_a9);
    ddp_channel_type_rec.rank := rosetta_g_miss_num_map(p4_a10);





    -- here's the delegated call to the old PL/SQL routine
    pvx_channel_type_pvt.create_channel_type(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_channel_type_rec,
      x_channel_type_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_channel_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_channel_type_rec pvx_channel_type_pvt.channel_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_channel_type_rec.channel_type_id := rosetta_g_miss_num_map(p4_a0);
    ddp_channel_type_rec.channel_lookup_type := p4_a1;
    ddp_channel_type_rec.channel_lookup_code := p4_a2;
    ddp_channel_type_rec.indirect_channel_flag := p4_a3;
    ddp_channel_type_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_channel_type_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_channel_type_rec.creation_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_channel_type_rec.created_by := rosetta_g_miss_num_map(p4_a7);
    ddp_channel_type_rec.last_update_login := rosetta_g_miss_num_map(p4_a8);
    ddp_channel_type_rec.object_version_number := rosetta_g_miss_num_map(p4_a9);
    ddp_channel_type_rec.rank := rosetta_g_miss_num_map(p4_a10);




    -- here's the delegated call to the old PL/SQL routine
    pvx_channel_type_pvt.update_channel_type(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_channel_type_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure complete_channel_type_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  DATE
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_channel_type_rec pvx_channel_type_pvt.channel_type_rec_type;
    ddx_complete_rec pvx_channel_type_pvt.channel_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_channel_type_rec.channel_type_id := rosetta_g_miss_num_map(p0_a0);
    ddp_channel_type_rec.channel_lookup_type := p0_a1;
    ddp_channel_type_rec.channel_lookup_code := p0_a2;
    ddp_channel_type_rec.indirect_channel_flag := p0_a3;
    ddp_channel_type_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_channel_type_rec.last_updated_by := rosetta_g_miss_num_map(p0_a5);
    ddp_channel_type_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_channel_type_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_channel_type_rec.last_update_login := rosetta_g_miss_num_map(p0_a8);
    ddp_channel_type_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddp_channel_type_rec.rank := rosetta_g_miss_num_map(p0_a10);


    -- here's the delegated call to the old PL/SQL routine
    pvx_channel_type_pvt.complete_channel_type_rec(ddp_channel_type_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.channel_type_id);
    p1_a1 := ddx_complete_rec.channel_lookup_type;
    p1_a2 := ddx_complete_rec.channel_lookup_code;
    p1_a3 := ddx_complete_rec.indirect_channel_flag;
    p1_a4 := ddx_complete_rec.last_update_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a6 := ddx_complete_rec.creation_date;
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.rank);
  end;

end pvx_channel_type_pvt_w;

/
