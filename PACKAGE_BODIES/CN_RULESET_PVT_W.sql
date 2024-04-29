--------------------------------------------------------
--  DDL for Package Body CN_RULESET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULESET_PVT_W" as
  /* $Header: cnwrsetb.pls 120.2 2005/10/10 01:06 rramakri noship $ */
  procedure create_ruleset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_ruleset_id out nocopy  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  DATE
    , p9_a4  DATE
    , p9_a5  VARCHAR2
    , p9_a6  NUMBER
    , p9_a7  VARCHAR2
    , p9_a8  NUMBER
  )

  as
    ddp_ruleset_rec cn_ruleset_pvt.ruleset_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_ruleset_rec.ruleset_id := p9_a0;
    ddp_ruleset_rec.ruleset_name := p9_a1;
    ddp_ruleset_rec.module_type := p9_a2;
    ddp_ruleset_rec.end_date := p9_a3;
    ddp_ruleset_rec.start_date := p9_a4;
    ddp_ruleset_rec.sync_flag := p9_a5;
    ddp_ruleset_rec.object_version_number := p9_a6;
    ddp_ruleset_rec.status := p9_a7;
    ddp_ruleset_rec.org_id := p9_a8;

    -- here's the delegated call to the old PL/SQL routine
    cn_ruleset_pvt.create_ruleset(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      x_ruleset_id,
      ddp_ruleset_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_ruleset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  DATE
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  NUMBER
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
  )

  as
    ddp_old_ruleset_rec cn_ruleset_pvt.ruleset_rec_type;
    ddp_ruleset_rec cn_ruleset_pvt.ruleset_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_old_ruleset_rec.ruleset_id := p8_a0;
    ddp_old_ruleset_rec.ruleset_name := p8_a1;
    ddp_old_ruleset_rec.module_type := p8_a2;
    ddp_old_ruleset_rec.end_date := p8_a3;
    ddp_old_ruleset_rec.start_date := p8_a4;
    ddp_old_ruleset_rec.sync_flag := p8_a5;
    ddp_old_ruleset_rec.object_version_number := p8_a6;
    ddp_old_ruleset_rec.status := p8_a7;
    ddp_old_ruleset_rec.org_id := p8_a8;

    ddp_ruleset_rec.ruleset_id := p9_a0;
    ddp_ruleset_rec.ruleset_name := p9_a1;
    ddp_ruleset_rec.module_type := p9_a2;
    ddp_ruleset_rec.end_date := p9_a3;
    ddp_ruleset_rec.start_date := p9_a4;
    ddp_ruleset_rec.sync_flag := p9_a5;
    ddp_ruleset_rec.object_version_number := p9_a6;
    ddp_ruleset_rec.status := p9_a7;
    ddp_ruleset_rec.org_id := p9_a8;

    -- here's the delegated call to the old PL/SQL routine
    cn_ruleset_pvt.update_ruleset(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddp_old_ruleset_rec,
      ddp_ruleset_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_old_ruleset_rec.ruleset_id;
    p8_a1 := ddp_old_ruleset_rec.ruleset_name;
    p8_a2 := ddp_old_ruleset_rec.module_type;
    p8_a3 := ddp_old_ruleset_rec.end_date;
    p8_a4 := ddp_old_ruleset_rec.start_date;
    p8_a5 := ddp_old_ruleset_rec.sync_flag;
    p8_a6 := ddp_old_ruleset_rec.object_version_number;
    p8_a7 := ddp_old_ruleset_rec.status;
    p8_a8 := ddp_old_ruleset_rec.org_id;

    p9_a0 := ddp_ruleset_rec.ruleset_id;
    p9_a1 := ddp_ruleset_rec.ruleset_name;
    p9_a2 := ddp_ruleset_rec.module_type;
    p9_a3 := ddp_ruleset_rec.end_date;
    p9_a4 := ddp_ruleset_rec.start_date;
    p9_a5 := ddp_ruleset_rec.sync_flag;
    p9_a6 := ddp_ruleset_rec.object_version_number;
    p9_a7 := ddp_ruleset_rec.status;
    p9_a8 := ddp_ruleset_rec.org_id;
  end;

end cn_ruleset_pvt_w;

/
