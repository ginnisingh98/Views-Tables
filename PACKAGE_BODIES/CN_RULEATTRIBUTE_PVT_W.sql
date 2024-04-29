--------------------------------------------------------
--  DDL for Package Body CN_RULEATTRIBUTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULEATTRIBUTE_PVT_W" as
  /* $Header: cnwratrb.pls 120.1 2005/06/16 03:29 appldev  $ */
  procedure create_ruleattribute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  NUMBER
  )

  as
    ddp_ruleattribute_rec cn_ruleattribute_pvt.ruleattribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_ruleattribute_rec.ruleset_id := p8_a0;
    ddp_ruleattribute_rec.rule_id := p8_a1;
    ddp_ruleattribute_rec.attribute_rule_id := p8_a2;
    ddp_ruleattribute_rec.org_id := p8_a3;
    ddp_ruleattribute_rec.object_name := p8_a4;
    ddp_ruleattribute_rec.not_flag := p8_a5;
    ddp_ruleattribute_rec.value_1 := p8_a6;
    ddp_ruleattribute_rec.value_2 := p8_a7;
    ddp_ruleattribute_rec.data_flag := p8_a8;
    ddp_ruleattribute_rec.object_version_number := p8_a9;

    -- here's the delegated call to the old PL/SQL routine
    cn_ruleattribute_pvt.create_ruleattribute(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddp_ruleattribute_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_ruleattribute_rec.ruleset_id;
    p8_a1 := ddp_ruleattribute_rec.rule_id;
    p8_a2 := ddp_ruleattribute_rec.attribute_rule_id;
    p8_a3 := ddp_ruleattribute_rec.org_id;
    p8_a4 := ddp_ruleattribute_rec.object_name;
    p8_a5 := ddp_ruleattribute_rec.not_flag;
    p8_a6 := ddp_ruleattribute_rec.value_1;
    p8_a7 := ddp_ruleattribute_rec.value_2;
    p8_a8 := ddp_ruleattribute_rec.data_flag;
    p8_a9 := ddp_ruleattribute_rec.object_version_number;
  end;

  procedure update_ruleattribute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  NUMBER
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  NUMBER
  )

  as
    ddp_old_ruleattribute_rec cn_ruleattribute_pvt.ruleattribute_rec_type;
    ddp_ruleattribute_rec cn_ruleattribute_pvt.ruleattribute_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_old_ruleattribute_rec.ruleset_id := p8_a0;
    ddp_old_ruleattribute_rec.rule_id := p8_a1;
    ddp_old_ruleattribute_rec.attribute_rule_id := p8_a2;
    ddp_old_ruleattribute_rec.org_id := p8_a3;
    ddp_old_ruleattribute_rec.object_name := p8_a4;
    ddp_old_ruleattribute_rec.not_flag := p8_a5;
    ddp_old_ruleattribute_rec.value_1 := p8_a6;
    ddp_old_ruleattribute_rec.value_2 := p8_a7;
    ddp_old_ruleattribute_rec.data_flag := p8_a8;
    ddp_old_ruleattribute_rec.object_version_number := p8_a9;

    ddp_ruleattribute_rec.ruleset_id := p9_a0;
    ddp_ruleattribute_rec.rule_id := p9_a1;
    ddp_ruleattribute_rec.attribute_rule_id := p9_a2;
    ddp_ruleattribute_rec.org_id := p9_a3;
    ddp_ruleattribute_rec.object_name := p9_a4;
    ddp_ruleattribute_rec.not_flag := p9_a5;
    ddp_ruleattribute_rec.value_1 := p9_a6;
    ddp_ruleattribute_rec.value_2 := p9_a7;
    ddp_ruleattribute_rec.data_flag := p9_a8;
    ddp_ruleattribute_rec.object_version_number := p9_a9;

    -- here's the delegated call to the old PL/SQL routine
    cn_ruleattribute_pvt.update_ruleattribute(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddp_old_ruleattribute_rec,
      ddp_ruleattribute_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_old_ruleattribute_rec.ruleset_id;
    p8_a1 := ddp_old_ruleattribute_rec.rule_id;
    p8_a2 := ddp_old_ruleattribute_rec.attribute_rule_id;
    p8_a3 := ddp_old_ruleattribute_rec.org_id;
    p8_a4 := ddp_old_ruleattribute_rec.object_name;
    p8_a5 := ddp_old_ruleattribute_rec.not_flag;
    p8_a6 := ddp_old_ruleattribute_rec.value_1;
    p8_a7 := ddp_old_ruleattribute_rec.value_2;
    p8_a8 := ddp_old_ruleattribute_rec.data_flag;
    p8_a9 := ddp_old_ruleattribute_rec.object_version_number;

    p9_a0 := ddp_ruleattribute_rec.ruleset_id;
    p9_a1 := ddp_ruleattribute_rec.rule_id;
    p9_a2 := ddp_ruleattribute_rec.attribute_rule_id;
    p9_a3 := ddp_ruleattribute_rec.org_id;
    p9_a4 := ddp_ruleattribute_rec.object_name;
    p9_a5 := ddp_ruleattribute_rec.not_flag;
    p9_a6 := ddp_ruleattribute_rec.value_1;
    p9_a7 := ddp_ruleattribute_rec.value_2;
    p9_a8 := ddp_ruleattribute_rec.data_flag;
    p9_a9 := ddp_ruleattribute_rec.object_version_number;
  end;

end cn_ruleattribute_pvt_w;

/
