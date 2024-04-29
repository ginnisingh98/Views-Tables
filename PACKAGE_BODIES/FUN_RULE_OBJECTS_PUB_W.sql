--------------------------------------------------------
--  DDL for Package Body FUN_RULE_OBJECTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_OBJECTS_PUB_W" as
/* $Header: FUNXTMRULROBRWB.pls 120.3 2006/01/10 14:35:35 ammishra noship $ */
  procedure create_rule_object(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  DATE
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , x_rule_object_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rule_object_rec fun_rule_objects_pub.rule_objects_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_rule_object_rec.rule_object_id := p1_a0;
    ddp_rule_object_rec.application_id := p1_a1;
    ddp_rule_object_rec.rule_object_name := p1_a2;
    ddp_rule_object_rec.user_rule_object_name := p1_a3;
    ddp_rule_object_rec.description := p1_a4;
    ddp_rule_object_rec.result_type := p1_a5;
    ddp_rule_object_rec.required_flag := p1_a6;
    ddp_rule_object_rec.use_default_value_flag := p1_a7;
    ddp_rule_object_rec.default_application_id := p1_a8;
    ddp_rule_object_rec.default_value := p1_a9;
    ddp_rule_object_rec.flex_value_set_id := p1_a10;
    ddp_rule_object_rec.flexfield_name := p1_a11;
    ddp_rule_object_rec.flexfield_app_short_name := p1_a12;
    ddp_rule_object_rec.multi_rule_result_flag := p1_a13;
    ddp_rule_object_rec.use_instance_flag := p1_a14;
    ddp_rule_object_rec.instance_label := p1_a15;
    ddp_rule_object_rec.parent_rule_object_id := p1_a16;
    ddp_rule_object_rec.org_id := p1_a17;
    ddp_rule_object_rec.creation_date := p1_a18;
    ddp_rule_object_rec.created_by := p1_a19;
    ddp_rule_object_rec.last_update_date := p1_a20;
    ddp_rule_object_rec.last_updated_by := p1_a21;
    ddp_rule_object_rec.last_update_login := p1_a22;
    ddp_rule_object_rec.created_by_module := p1_a23;





    -- here's the delegated call to the old PL/SQL routine
    fun_rule_objects_pub.create_rule_object(p_init_msg_list,
      ddp_rule_object_rec,
      x_rule_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_rule_object(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  DATE
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rule_object_rec fun_rule_objects_pub.rule_objects_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_rule_object_rec.rule_object_id := p1_a0;
    ddp_rule_object_rec.application_id := p1_a1;
    ddp_rule_object_rec.rule_object_name := p1_a2;
    ddp_rule_object_rec.user_rule_object_name := p1_a3;
    ddp_rule_object_rec.description := p1_a4;
    ddp_rule_object_rec.result_type := p1_a5;
    ddp_rule_object_rec.required_flag := p1_a6;
    ddp_rule_object_rec.use_default_value_flag := p1_a7;
    ddp_rule_object_rec.default_application_id := p1_a8;
    ddp_rule_object_rec.default_value := p1_a9;
    ddp_rule_object_rec.flex_value_set_id := p1_a10;
    ddp_rule_object_rec.flexfield_name := p1_a11;
    ddp_rule_object_rec.flexfield_app_short_name := p1_a12;
    ddp_rule_object_rec.multi_rule_result_flag := p1_a13;
    ddp_rule_object_rec.use_instance_flag := p1_a14;
    ddp_rule_object_rec.instance_label := p1_a15;
    ddp_rule_object_rec.parent_rule_object_id := p1_a16;
    ddp_rule_object_rec.org_id := p1_a17;
    ddp_rule_object_rec.creation_date := p1_a18;
    ddp_rule_object_rec.created_by := p1_a19;
    ddp_rule_object_rec.last_update_date := p1_a20;
    ddp_rule_object_rec.last_updated_by := p1_a21;
    ddp_rule_object_rec.last_update_login := p1_a22;
    ddp_rule_object_rec.created_by_module := p1_a23;





    -- here's the delegated call to the old PL/SQL routine
    fun_rule_objects_pub.update_rule_object(p_init_msg_list,
      ddp_rule_object_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure get_rule_object_rec(p_init_msg_list  VARCHAR2
    , p_rule_object_name  VARCHAR2
    , p_application_id  NUMBER
    , p_instance_label  VARCHAR2
    , p_org_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  NUMBER
    , p5_a18 out nocopy  DATE
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  DATE
    , p5_a21 out nocopy  NUMBER
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_rule_object_rec fun_rule_objects_pub.rule_objects_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    fun_rule_objects_pub.get_rule_object_rec(p_init_msg_list,
      p_rule_object_name,
      p_application_id,
      p_instance_label,
      p_org_id,
      ddx_rule_object_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_rule_object_rec.rule_object_id;
    p5_a1 := ddx_rule_object_rec.application_id;
    p5_a2 := ddx_rule_object_rec.rule_object_name;
    p5_a3 := ddx_rule_object_rec.user_rule_object_name;
    p5_a4 := ddx_rule_object_rec.description;
    p5_a5 := ddx_rule_object_rec.result_type;
    p5_a6 := ddx_rule_object_rec.required_flag;
    p5_a7 := ddx_rule_object_rec.use_default_value_flag;
    p5_a8 := ddx_rule_object_rec.default_application_id;
    p5_a9 := ddx_rule_object_rec.default_value;
    p5_a10 := ddx_rule_object_rec.flex_value_set_id;
    p5_a11 := ddx_rule_object_rec.flexfield_name;
    p5_a12 := ddx_rule_object_rec.flexfield_app_short_name;
    p5_a13 := ddx_rule_object_rec.multi_rule_result_flag;
    p5_a14 := ddx_rule_object_rec.use_instance_flag;
    p5_a15 := ddx_rule_object_rec.instance_label;
    p5_a16 := ddx_rule_object_rec.parent_rule_object_id;
    p5_a17 := ddx_rule_object_rec.org_id;
    p5_a18 := ddx_rule_object_rec.creation_date;
    p5_a19 := ddx_rule_object_rec.created_by;
    p5_a20 := ddx_rule_object_rec.last_update_date;
    p5_a21 := ddx_rule_object_rec.last_updated_by;
    p5_a22 := ddx_rule_object_rec.last_update_login;
    p5_a23 := ddx_rule_object_rec.created_by_module;



  end;

  procedure get_rule_object_rec(p_init_msg_list  VARCHAR2
    , p_rule_object_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  NUMBER
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  NUMBER
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  NUMBER
    , p2_a18 out nocopy  DATE
    , p2_a19 out nocopy  NUMBER
    , p2_a20 out nocopy  DATE
    , p2_a21 out nocopy  NUMBER
    , p2_a22 out nocopy  NUMBER
    , p2_a23 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_rule_object_rec fun_rule_objects_pub.rule_objects_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    fun_rule_objects_pub.get_rule_object_rec(p_init_msg_list,
      p_rule_object_id,
      ddx_rule_object_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_rule_object_rec.rule_object_id;
    p2_a1 := ddx_rule_object_rec.application_id;
    p2_a2 := ddx_rule_object_rec.rule_object_name;
    p2_a3 := ddx_rule_object_rec.user_rule_object_name;
    p2_a4 := ddx_rule_object_rec.description;
    p2_a5 := ddx_rule_object_rec.result_type;
    p2_a6 := ddx_rule_object_rec.required_flag;
    p2_a7 := ddx_rule_object_rec.use_default_value_flag;
    p2_a8 := ddx_rule_object_rec.default_application_id;
    p2_a9 := ddx_rule_object_rec.default_value;
    p2_a10 := ddx_rule_object_rec.flex_value_set_id;
    p2_a11 := ddx_rule_object_rec.flexfield_name;
    p2_a12 := ddx_rule_object_rec.flexfield_app_short_name;
    p2_a13 := ddx_rule_object_rec.multi_rule_result_flag;
    p2_a14 := ddx_rule_object_rec.use_instance_flag;
    p2_a15 := ddx_rule_object_rec.instance_label;
    p2_a16 := ddx_rule_object_rec.parent_rule_object_id;
    p2_a17 := ddx_rule_object_rec.org_id;
    p2_a18 := ddx_rule_object_rec.creation_date;
    p2_a19 := ddx_rule_object_rec.created_by;
    p2_a20 := ddx_rule_object_rec.last_update_date;
    p2_a21 := ddx_rule_object_rec.last_updated_by;
    p2_a22 := ddx_rule_object_rec.last_update_login;
    p2_a23 := ddx_rule_object_rec.created_by_module;



  end;

  procedure rule_object_instance_exists(p_application_id  NUMBER
    , p_rule_object_name  VARCHAR2
    , p_instance_label  VARCHAR2
    , p_org_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := fun_rule_objects_pub.rule_object_instance_exists(p_application_id,
      p_rule_object_name,
      p_instance_label,
      p_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;



  end;

  procedure rule_object_uses_parameter(p_rule_object_name  VARCHAR2
    , p_parameter_name  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := fun_rule_objects_pub.rule_object_uses_parameter(p_rule_object_name,
      p_parameter_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

end fun_rule_objects_pub_w;

/
