--------------------------------------------------------
--  DDL for Package Body HZ_DSS_GROUPS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_GROUPS_PUB_W" as
  /* $Header: ARHPDGJB.pls 120.2 2005/06/18 04:28:01 jhuang noship $ */
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

  procedure create_group_1(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_group hz_dss_groups_pub.dss_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_group.dss_group_code := p1_a0;
    ddp_dss_group.order_before_group_code := p1_a1;
    ddp_dss_group.bes_enable_flag := p1_a2;
    ddp_dss_group.status := p1_a3;
    ddp_dss_group.dss_group_name := p1_a4;
    ddp_dss_group.description := p1_a5;




    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_group(p_init_msg_list,
      ddp_dss_group,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure update_group_2(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_group hz_dss_groups_pub.dss_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_group.dss_group_code := p1_a0;
    ddp_dss_group.order_before_group_code := p1_a1;
    ddp_dss_group.bes_enable_flag := p1_a2;
    ddp_dss_group.status := p1_a3;
    ddp_dss_group.dss_group_name := p1_a4;
    ddp_dss_group.description := p1_a5;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.update_group(p_init_msg_list,
      ddp_dss_group,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_secured_criterion_3(p_init_msg_list  VARCHAR2
    , x_secured_item_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_criterion hz_dss_groups_pub.dss_secured_criterion_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_criterion.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_criterion.dss_group_code := p1_a1;
    ddp_dss_secured_criterion.owner_table_name := p1_a2;
    ddp_dss_secured_criterion.owner_table_id1 := p1_a3;
    ddp_dss_secured_criterion.owner_table_id2 := p1_a4;
    ddp_dss_secured_criterion.owner_table_id3 := p1_a5;
    ddp_dss_secured_criterion.owner_table_id4 := p1_a6;
    ddp_dss_secured_criterion.owner_table_id5 := p1_a7;
    ddp_dss_secured_criterion.status := p1_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_secured_criterion(p_init_msg_list,
      ddp_dss_secured_criterion,
      x_secured_item_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_secured_module_4(p_init_msg_list  VARCHAR2
    , x_secured_item_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_module hz_dss_groups_pub.dss_secured_module_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_module.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_module.dss_group_code := p1_a1;
    ddp_dss_secured_module.created_by_module := p1_a2;
    ddp_dss_secured_module.status := p1_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_secured_module(p_init_msg_list,
      ddp_dss_secured_module,
      x_secured_item_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_secured_module_5(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_module hz_dss_groups_pub.dss_secured_module_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_module.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_module.dss_group_code := p1_a1;
    ddp_dss_secured_module.created_by_module := p1_a2;
    ddp_dss_secured_module.status := p1_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.update_secured_module(p_init_msg_list,
      ddp_dss_secured_module,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_secured_classificati_6(p_init_msg_list  VARCHAR2
    , x_secured_item_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_class hz_dss_groups_pub.dss_secured_class_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_class.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_class.dss_group_code := p1_a1;
    ddp_dss_secured_class.class_category := p1_a2;
    ddp_dss_secured_class.class_code := p1_a3;
    ddp_dss_secured_class.status := p1_a4;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_secured_classification(p_init_msg_list,
      ddp_dss_secured_class,
      x_secured_item_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_secured_criterion_7(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_criterion hz_dss_groups_pub.dss_secured_criterion_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_criterion.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_criterion.dss_group_code := p1_a1;
    ddp_dss_secured_criterion.owner_table_name := p1_a2;
    ddp_dss_secured_criterion.owner_table_id1 := p1_a3;
    ddp_dss_secured_criterion.owner_table_id2 := p1_a4;
    ddp_dss_secured_criterion.owner_table_id3 := p1_a5;
    ddp_dss_secured_criterion.owner_table_id4 := p1_a6;
    ddp_dss_secured_criterion.owner_table_id5 := p1_a7;
    ddp_dss_secured_criterion.status := p1_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.update_secured_criterion(p_init_msg_list,
      ddp_dss_secured_criterion,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_secured_classificati_8(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_class hz_dss_groups_pub.dss_secured_class_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_class.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_class.dss_group_code := p1_a1;
    ddp_dss_secured_class.class_category := p1_a2;
    ddp_dss_secured_class.class_code := p1_a3;
    ddp_dss_secured_class.status := p1_a4;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.update_secured_classification(p_init_msg_list,
      ddp_dss_secured_class,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_secured_rel_type_9(p_init_msg_list  VARCHAR2
    , x_secured_item_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_rel_type hz_dss_groups_pub.dss_secured_rel_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_rel_type.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_rel_type.dss_group_code := p1_a1;
    ddp_dss_secured_rel_type.relationship_type_id := rosetta_g_miss_num_map(p1_a2);
    ddp_dss_secured_rel_type.status := p1_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_secured_rel_type(p_init_msg_list,
      ddp_dss_secured_rel_type,
      x_secured_item_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_secured_rel_type_10(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_rel_type hz_dss_groups_pub.dss_secured_rel_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_rel_type.secured_item_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_secured_rel_type.dss_group_code := p1_a1;
    ddp_dss_secured_rel_type.relationship_type_id := rosetta_g_miss_num_map(p1_a2);
    ddp_dss_secured_rel_type.status := p1_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.update_secured_rel_type(p_init_msg_list,
      ddp_dss_secured_rel_type,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_assignment_11(p_init_msg_list  VARCHAR2
    , x_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_assignment hz_dss_groups_pub.dss_assignment_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_assignment.dss_group_code := p1_a0;
    ddp_dss_assignment.assignment_id := p1_a1;
    ddp_dss_assignment.owner_table_name := p1_a2;
    ddp_dss_assignment.owner_table_id1 := p1_a3;
    ddp_dss_assignment.owner_table_id2 := p1_a4;
    ddp_dss_assignment.owner_table_id3 := p1_a5;
    ddp_dss_assignment.owner_table_id4 := p1_a6;
    ddp_dss_assignment.owner_table_id5 := p1_a7;
    ddp_dss_assignment.status := p1_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_assignment(p_init_msg_list,
      ddp_dss_assignment,
      x_assignment_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_secured_entity_12(p_init_msg_list  VARCHAR2
    , x_dss_instance_set_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_entity hz_dss_groups_pub.dss_secured_entity_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_entity.dss_group_code := p1_a0;
    ddp_dss_secured_entity.entity_id := rosetta_g_miss_num_map(p1_a1);
    ddp_dss_secured_entity.status := p1_a2;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.create_secured_entity(p_init_msg_list,
      ddp_dss_secured_entity,
      x_dss_instance_set_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_secured_entity_13(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_secured_entity hz_dss_groups_pub.dss_secured_entity_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_secured_entity.dss_group_code := p1_a0;
    ddp_dss_secured_entity.entity_id := rosetta_g_miss_num_map(p1_a1);
    ddp_dss_secured_entity.status := p1_a2;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_groups_pub.update_secured_entity(p_init_msg_list,
      ddp_dss_secured_entity,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end hz_dss_groups_pub_w;

/
