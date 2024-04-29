--------------------------------------------------------
--  DDL for Package Body FUN_RULE_DETAILS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_DETAILS_PUB_W" as
  /* $Header: FUNXTMRULRDTRWB.pls 120.0 2005/06/20 04:30:03 ammishra noship $ */
  procedure create_rule_detail(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  DATE
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , x_rule_detail_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rule_detail_rec fun_rule_details_pub.rule_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_rule_detail_rec.rule_detail_id := p1_a0;
    ddp_rule_detail_rec.rule_object_id := p1_a1;
    ddp_rule_detail_rec.rule_name := p1_a2;
    ddp_rule_detail_rec.seq := p1_a3;
    ddp_rule_detail_rec.operator := p1_a4;
    ddp_rule_detail_rec.enabled_flag := p1_a5;
    ddp_rule_detail_rec.result_application_id := p1_a6;
    ddp_rule_detail_rec.result_value := p1_a7;
    ddp_rule_detail_rec.creation_date := p1_a8;
    ddp_rule_detail_rec.created_by := p1_a9;
    ddp_rule_detail_rec.last_update_date := p1_a10;
    ddp_rule_detail_rec.last_updated_by := p1_a11;
    ddp_rule_detail_rec.last_update_login := p1_a12;
    ddp_rule_detail_rec.created_by_module := p1_a13;





    -- here's the delegated call to the old PL/SQL routine
    fun_rule_details_pub.create_rule_detail(p_init_msg_list,
      ddp_rule_detail_rec,
      x_rule_detail_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_rule_detail(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  DATE
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rule_detail_rec fun_rule_details_pub.rule_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_rule_detail_rec.rule_detail_id := p1_a0;
    ddp_rule_detail_rec.rule_object_id := p1_a1;
    ddp_rule_detail_rec.rule_name := p1_a2;
    ddp_rule_detail_rec.seq := p1_a3;
    ddp_rule_detail_rec.operator := p1_a4;
    ddp_rule_detail_rec.enabled_flag := p1_a5;
    ddp_rule_detail_rec.result_application_id := p1_a6;
    ddp_rule_detail_rec.result_value := p1_a7;
    ddp_rule_detail_rec.creation_date := p1_a8;
    ddp_rule_detail_rec.created_by := p1_a9;
    ddp_rule_detail_rec.last_update_date := p1_a10;
    ddp_rule_detail_rec.last_updated_by := p1_a11;
    ddp_rule_detail_rec.last_update_login := p1_a12;
    ddp_rule_detail_rec.created_by_module := p1_a13;





    -- here's the delegated call to the old PL/SQL routine
    fun_rule_details_pub.update_rule_detail(p_init_msg_list,
      ddp_rule_detail_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure get_rule_detail_rec(p_init_msg_list  VARCHAR2
    , p_rule_detail_id  NUMBER
    , p_rule_object_id  NUMBER
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_rule_detail_rec fun_rule_details_pub.rule_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    fun_rule_details_pub.get_rule_detail_rec(p_init_msg_list,
      p_rule_detail_id,
      p_rule_object_id,
      ddx_rule_detail_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_rule_detail_rec.rule_detail_id;
    p3_a1 := ddx_rule_detail_rec.rule_object_id;
    p3_a2 := ddx_rule_detail_rec.rule_name;
    p3_a3 := ddx_rule_detail_rec.seq;
    p3_a4 := ddx_rule_detail_rec.operator;
    p3_a5 := ddx_rule_detail_rec.enabled_flag;
    p3_a6 := ddx_rule_detail_rec.result_application_id;
    p3_a7 := ddx_rule_detail_rec.result_value;
    p3_a8 := ddx_rule_detail_rec.creation_date;
    p3_a9 := ddx_rule_detail_rec.created_by;
    p3_a10 := ddx_rule_detail_rec.last_update_date;
    p3_a11 := ddx_rule_detail_rec.last_updated_by;
    p3_a12 := ddx_rule_detail_rec.last_update_login;
    p3_a13 := ddx_rule_detail_rec.created_by_module;



  end;

end fun_rule_details_pub_w;

/
