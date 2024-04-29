--------------------------------------------------------
--  DDL for Package Body AMS_TRACKING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRACKING_PVT_W" as
  /* $Header: amswtrkb.pls 120.2 2006/01/05 13:24 rrajesh ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure log_interaction(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  DATE := fnd_api.g_miss_date
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  DATE := fnd_api.g_miss_date
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  NUMBER := 0-1962.0724
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_track_rec ams_tracking_pvt.interaction_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_track_rec.created_by := rosetta_g_miss_num_map(p8_a0);
    ddp_track_rec.creation_date := rosetta_g_miss_date_in_map(p8_a1);
    ddp_track_rec.last_updated_by := rosetta_g_miss_num_map(p8_a2);
    ddp_track_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a3);
    ddp_track_rec.last_update_login := rosetta_g_miss_num_map(p8_a4);
    ddp_track_rec.object_version_number := rosetta_g_miss_num_map(p8_a5);
    ddp_track_rec.web_content_id := rosetta_g_miss_num_map(p8_a6);
    ddp_track_rec.obj_type := p8_a7;
    ddp_track_rec.obj_src_code := p8_a8;
    ddp_track_rec.obj_id := rosetta_g_miss_num_map(p8_a9);
    ddp_track_rec.offer_src_code := p8_a10;
    ddp_track_rec.offer_id := rosetta_g_miss_num_map(p8_a11);
    ddp_track_rec.party_id := rosetta_g_miss_num_map(p8_a12);
    ddp_track_rec.affiliate_id := rosetta_g_miss_num_map(p8_a13);
    ddp_track_rec.posting_id := rosetta_g_miss_num_map(p8_a14);
    ddp_track_rec.did := rosetta_g_miss_num_map(p8_a15);
    ddp_track_rec.flavour := p8_a16;
    ddp_track_rec.web_tracking_id := rosetta_g_miss_num_map(p8_a17);

    -- here's the delegated call to the old PL/SQL routine
    ams_tracking_pvt.log_interaction(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_interaction_id,
      ddp_track_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure log_redirect(x_redirect_url out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_action_parameter_code out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
  )

  as
    ddtracking_rec ams_tracking_pvt.interaction_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddtracking_rec.created_by := rosetta_g_miss_num_map(p0_a0);
    ddtracking_rec.creation_date := rosetta_g_miss_date_in_map(p0_a1);
    ddtracking_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddtracking_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddtracking_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddtracking_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddtracking_rec.web_content_id := rosetta_g_miss_num_map(p0_a6);
    ddtracking_rec.obj_type := p0_a7;
    ddtracking_rec.obj_src_code := p0_a8;
    ddtracking_rec.obj_id := rosetta_g_miss_num_map(p0_a9);
    ddtracking_rec.offer_src_code := p0_a10;
    ddtracking_rec.offer_id := rosetta_g_miss_num_map(p0_a11);
    ddtracking_rec.party_id := rosetta_g_miss_num_map(p0_a12);
    ddtracking_rec.affiliate_id := rosetta_g_miss_num_map(p0_a13);
    ddtracking_rec.posting_id := rosetta_g_miss_num_map(p0_a14);
    ddtracking_rec.did := rosetta_g_miss_num_map(p0_a15);
    ddtracking_rec.flavour := p0_a16;
    ddtracking_rec.web_tracking_id := rosetta_g_miss_num_map(p0_a17);




    -- here's the delegated call to the old PL/SQL routine
    ams_tracking_pvt.log_redirect(ddtracking_rec,
      x_redirect_url,
      x_interaction_id,
      x_action_parameter_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure weblite_log(x_interaction_id out nocopy  NUMBER
    , x_msource out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
  )

  as
    ddtracking_rec ams_tracking_pvt.interaction_track_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddtracking_rec.created_by := rosetta_g_miss_num_map(p0_a0);
    ddtracking_rec.creation_date := rosetta_g_miss_date_in_map(p0_a1);
    ddtracking_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddtracking_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddtracking_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddtracking_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddtracking_rec.web_content_id := rosetta_g_miss_num_map(p0_a6);
    ddtracking_rec.obj_type := p0_a7;
    ddtracking_rec.obj_src_code := p0_a8;
    ddtracking_rec.obj_id := rosetta_g_miss_num_map(p0_a9);
    ddtracking_rec.offer_src_code := p0_a10;
    ddtracking_rec.offer_id := rosetta_g_miss_num_map(p0_a11);
    ddtracking_rec.party_id := rosetta_g_miss_num_map(p0_a12);
    ddtracking_rec.affiliate_id := rosetta_g_miss_num_map(p0_a13);
    ddtracking_rec.posting_id := rosetta_g_miss_num_map(p0_a14);
    ddtracking_rec.did := rosetta_g_miss_num_map(p0_a15);
    ddtracking_rec.flavour := p0_a16;
    ddtracking_rec.web_tracking_id := rosetta_g_miss_num_map(p0_a17);






    -- here's the delegated call to the old PL/SQL routine
    ams_tracking_pvt.weblite_log(ddtracking_rec,
      x_interaction_id,
      x_msource,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_tracking_pvt_w;

/
