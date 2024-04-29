--------------------------------------------------------
--  DDL for Package Body OZF_OA_ACT_OFFERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OA_ACT_OFFERS_PVT_W" as
  /* $Header: ozfaoffb.pls 115.0 2003/10/23 04:22:51 musman noship $ */
  procedure create_act_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , x_act_offer_id out nocopy  NUMBER
  )

  as
    ddp_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_offer_rec.activity_offer_id := p7_a0;
    ddp_act_offer_rec.last_update_date := p7_a1;
    ddp_act_offer_rec.last_updated_by := p7_a2;
    ddp_act_offer_rec.creation_date := p7_a3;
    ddp_act_offer_rec.created_by := p7_a4;
    ddp_act_offer_rec.last_update_login := p7_a5;
    ddp_act_offer_rec.object_version_number := p7_a6;
    ddp_act_offer_rec.act_offer_used_by_id := p7_a7;
    ddp_act_offer_rec.arc_act_offer_used_by := p7_a8;
    ddp_act_offer_rec.primary_offer_flag := p7_a9;
    ddp_act_offer_rec.active_period_set := p7_a10;
    ddp_act_offer_rec.active_period := p7_a11;
    ddp_act_offer_rec.qp_list_header_id := p7_a12;
    ddp_act_offer_rec.security_group_id := p7_a13;


    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.create_act_offer(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_offer_rec,
      x_act_offer_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_act_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
  )

  as
    ddp_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_offer_rec.activity_offer_id := p7_a0;
    ddp_act_offer_rec.last_update_date := p7_a1;
    ddp_act_offer_rec.last_updated_by := p7_a2;
    ddp_act_offer_rec.creation_date := p7_a3;
    ddp_act_offer_rec.created_by := p7_a4;
    ddp_act_offer_rec.last_update_login := p7_a5;
    ddp_act_offer_rec.object_version_number := p7_a6;
    ddp_act_offer_rec.act_offer_used_by_id := p7_a7;
    ddp_act_offer_rec.arc_act_offer_used_by := p7_a8;
    ddp_act_offer_rec.primary_offer_flag := p7_a9;
    ddp_act_offer_rec.active_period_set := p7_a10;
    ddp_act_offer_rec.active_period := p7_a11;
    ddp_act_offer_rec.qp_list_header_id := p7_a12;
    ddp_act_offer_rec.security_group_id := p7_a13;

    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.update_act_offer(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_offer_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_act_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
  )

  as
    ddp_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_offer_rec.activity_offer_id := p6_a0;
    ddp_act_offer_rec.last_update_date := p6_a1;
    ddp_act_offer_rec.last_updated_by := p6_a2;
    ddp_act_offer_rec.creation_date := p6_a3;
    ddp_act_offer_rec.created_by := p6_a4;
    ddp_act_offer_rec.last_update_login := p6_a5;
    ddp_act_offer_rec.object_version_number := p6_a6;
    ddp_act_offer_rec.act_offer_used_by_id := p6_a7;
    ddp_act_offer_rec.arc_act_offer_used_by := p6_a8;
    ddp_act_offer_rec.primary_offer_flag := p6_a9;
    ddp_act_offer_rec.active_period_set := p6_a10;
    ddp_act_offer_rec.active_period := p6_a11;
    ddp_act_offer_rec.qp_list_header_id := p6_a12;
    ddp_act_offer_rec.security_group_id := p6_a13;

    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.validate_act_offer(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_offer_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  NUMBER
    , p2_a13  NUMBER
  )

  as
    ddp_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_act_offer_rec.activity_offer_id := p2_a0;
    ddp_act_offer_rec.last_update_date := p2_a1;
    ddp_act_offer_rec.last_updated_by := p2_a2;
    ddp_act_offer_rec.creation_date := p2_a3;
    ddp_act_offer_rec.created_by := p2_a4;
    ddp_act_offer_rec.last_update_login := p2_a5;
    ddp_act_offer_rec.object_version_number := p2_a6;
    ddp_act_offer_rec.act_offer_used_by_id := p2_a7;
    ddp_act_offer_rec.arc_act_offer_used_by := p2_a8;
    ddp_act_offer_rec.primary_offer_flag := p2_a9;
    ddp_act_offer_rec.active_period_set := p2_a10;
    ddp_act_offer_rec.active_period := p2_a11;
    ddp_act_offer_rec.qp_list_header_id := p2_a12;
    ddp_act_offer_rec.security_group_id := p2_a13;

    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_act_offer_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddp_complete_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_offer_rec.activity_offer_id := p0_a0;
    ddp_act_offer_rec.last_update_date := p0_a1;
    ddp_act_offer_rec.last_updated_by := p0_a2;
    ddp_act_offer_rec.creation_date := p0_a3;
    ddp_act_offer_rec.created_by := p0_a4;
    ddp_act_offer_rec.last_update_login := p0_a5;
    ddp_act_offer_rec.object_version_number := p0_a6;
    ddp_act_offer_rec.act_offer_used_by_id := p0_a7;
    ddp_act_offer_rec.arc_act_offer_used_by := p0_a8;
    ddp_act_offer_rec.primary_offer_flag := p0_a9;
    ddp_act_offer_rec.active_period_set := p0_a10;
    ddp_act_offer_rec.active_period := p0_a11;
    ddp_act_offer_rec.qp_list_header_id := p0_a12;
    ddp_act_offer_rec.security_group_id := p0_a13;

    ddp_complete_rec.activity_offer_id := p1_a0;
    ddp_complete_rec.last_update_date := p1_a1;
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := p1_a3;
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.object_version_number := p1_a6;
    ddp_complete_rec.act_offer_used_by_id := p1_a7;
    ddp_complete_rec.arc_act_offer_used_by := p1_a8;
    ddp_complete_rec.primary_offer_flag := p1_a9;
    ddp_complete_rec.active_period_set := p1_a10;
    ddp_complete_rec.active_period := p1_a11;
    ddp_complete_rec.qp_list_header_id := p1_a12;
    ddp_complete_rec.security_group_id := p1_a13;


    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.check_record(ddp_act_offer_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
  )

  as
    ddp_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddx_complete_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_offer_rec.activity_offer_id := p0_a0;
    ddp_act_offer_rec.last_update_date := p0_a1;
    ddp_act_offer_rec.last_updated_by := p0_a2;
    ddp_act_offer_rec.creation_date := p0_a3;
    ddp_act_offer_rec.created_by := p0_a4;
    ddp_act_offer_rec.last_update_login := p0_a5;
    ddp_act_offer_rec.object_version_number := p0_a6;
    ddp_act_offer_rec.act_offer_used_by_id := p0_a7;
    ddp_act_offer_rec.arc_act_offer_used_by := p0_a8;
    ddp_act_offer_rec.primary_offer_flag := p0_a9;
    ddp_act_offer_rec.active_period_set := p0_a10;
    ddp_act_offer_rec.active_period := p0_a11;
    ddp_act_offer_rec.qp_list_header_id := p0_a12;
    ddp_act_offer_rec.security_group_id := p0_a13;


    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.complete_rec(ddp_act_offer_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.activity_offer_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.act_offer_used_by_id;
    p1_a8 := ddx_complete_rec.arc_act_offer_used_by;
    p1_a9 := ddx_complete_rec.primary_offer_flag;
    p1_a10 := ddx_complete_rec.active_period_set;
    p1_a11 := ddx_complete_rec.active_period;
    p1_a12 := ddx_complete_rec.qp_list_header_id;
    p1_a13 := ddx_complete_rec.security_group_id;
  end;

  procedure init_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
  )

  as
    ddx_act_offer_rec ozf_act_offers_pvt.act_offer_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_act_offers_pvt.init_rec(ddx_act_offer_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_act_offer_rec.activity_offer_id;
    p0_a1 := ddx_act_offer_rec.last_update_date;
    p0_a2 := ddx_act_offer_rec.last_updated_by;
    p0_a3 := ddx_act_offer_rec.creation_date;
    p0_a4 := ddx_act_offer_rec.created_by;
    p0_a5 := ddx_act_offer_rec.last_update_login;
    p0_a6 := ddx_act_offer_rec.object_version_number;
    p0_a7 := ddx_act_offer_rec.act_offer_used_by_id;
    p0_a8 := ddx_act_offer_rec.arc_act_offer_used_by;
    p0_a9 := ddx_act_offer_rec.primary_offer_flag;
    p0_a10 := ddx_act_offer_rec.active_period_set;
    p0_a11 := ddx_act_offer_rec.active_period;
    p0_a12 := ddx_act_offer_rec.qp_list_header_id;
    p0_a13 := ddx_act_offer_rec.security_group_id;
  end;

end ozf_oa_act_offers_pvt_w;

/
