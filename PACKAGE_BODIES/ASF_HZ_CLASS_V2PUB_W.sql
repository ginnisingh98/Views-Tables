--------------------------------------------------------
--  DDL for Package Body ASF_HZ_CLASS_V2PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_HZ_CLASS_V2PUB_W" as
  /* $Header: asfwclsb.pls 115.1 2002/03/25 17:19:15 pkm ship    $ */
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

  procedure create_class_category(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  NUMBER := 0-1962.0724
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_class_category_rec hz_classification_v2pub.class_category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_category_rec.class_category := p1_a0;
    ddp_class_category_rec.allow_multi_parent_flag := p1_a1;
    ddp_class_category_rec.allow_multi_assign_flag := p1_a2;
    ddp_class_category_rec.allow_leaf_node_only_flag := p1_a3;
    ddp_class_category_rec.created_by_module := p1_a4;
    ddp_class_category_rec.application_id := rosetta_g_miss_num_map(p1_a5);




    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_class_category(p_init_msg_list,
      ddp_class_category_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_class_category(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  NUMBER := 0-1962.0724
    , p_object_version_number in out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_class_category_rec hz_classification_v2pub.class_category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_category_rec.class_category := p1_a0;
    ddp_class_category_rec.allow_multi_parent_flag := p1_a1;
    ddp_class_category_rec.allow_multi_assign_flag := p1_a2;
    ddp_class_category_rec.allow_leaf_node_only_flag := p1_a3;
    ddp_class_category_rec.created_by_module := p1_a4;
    ddp_class_category_rec.application_id := rosetta_g_miss_num_map(p1_a5);





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_class_category(p_init_msg_list,
      ddp_class_category_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_class_category_rec(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p2_a0 out  VARCHAR2
    , p2_a1 out  VARCHAR2
    , p2_a2 out  VARCHAR2
    , p2_a3 out  VARCHAR2
    , p2_a4 out  VARCHAR2
    , p2_a5 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddx_class_category_rec hz_classification_v2pub.class_category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.get_class_category_rec(p_init_msg_list,
      p_class_category,
      ddx_class_category_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := ddx_class_category_rec.class_category;
    p2_a1 := ddx_class_category_rec.allow_multi_parent_flag;
    p2_a2 := ddx_class_category_rec.allow_multi_assign_flag;
    p2_a3 := ddx_class_category_rec.allow_leaf_node_only_flag;
    p2_a4 := ddx_class_category_rec.created_by_module;
    p2_a5 := rosetta_g_miss_num_map(ddx_class_category_rec.application_id);



  end;

  procedure create_class_code_relation(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_class_code_relation_rec hz_classification_v2pub.class_code_relation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_code_relation_rec.class_category := p1_a0;
    ddp_class_code_relation_rec.class_code := p1_a1;
    ddp_class_code_relation_rec.sub_class_code := p1_a2;
    ddp_class_code_relation_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a3);
    ddp_class_code_relation_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a4);
    ddp_class_code_relation_rec.created_by_module := p1_a5;
    ddp_class_code_relation_rec.application_id := rosetta_g_miss_num_map(p1_a6);




    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_class_code_relation(p_init_msg_list,
      ddp_class_code_relation_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_class_code_relation(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p_object_version_number in out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_class_code_relation_rec hz_classification_v2pub.class_code_relation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_code_relation_rec.class_category := p1_a0;
    ddp_class_code_relation_rec.class_code := p1_a1;
    ddp_class_code_relation_rec.sub_class_code := p1_a2;
    ddp_class_code_relation_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a3);
    ddp_class_code_relation_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a4);
    ddp_class_code_relation_rec.created_by_module := p1_a5;
    ddp_class_code_relation_rec.application_id := rosetta_g_miss_num_map(p1_a6);





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_class_code_relation(p_init_msg_list,
      ddp_class_code_relation_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_class_code_relation_rec(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p_class_code  VARCHAR2
    , p_sub_class_code  VARCHAR2
    , p_start_date_active  date
    , p5_a0 out  VARCHAR2
    , p5_a1 out  VARCHAR2
    , p5_a2 out  VARCHAR2
    , p5_a3 out  DATE
    , p5_a4 out  DATE
    , p5_a5 out  VARCHAR2
    , p5_a6 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_start_date_active date;
    ddx_class_code_relation_rec hz_classification_v2pub.class_code_relation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.get_class_code_relation_rec(p_init_msg_list,
      p_class_category,
      p_class_code,
      p_sub_class_code,
      ddp_start_date_active,
      ddx_class_code_relation_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





    p5_a0 := ddx_class_code_relation_rec.class_category;
    p5_a1 := ddx_class_code_relation_rec.class_code;
    p5_a2 := ddx_class_code_relation_rec.sub_class_code;
    p5_a3 := ddx_class_code_relation_rec.start_date_active;
    p5_a4 := ddx_class_code_relation_rec.end_date_active;
    p5_a5 := ddx_class_code_relation_rec.created_by_module;
    p5_a6 := rosetta_g_miss_num_map(ddx_class_code_relation_rec.application_id);



  end;

  procedure create_code_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  DATE := fnd_api.g_miss_date
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  NUMBER := 0-1962.0724
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_code_assignment_id out  NUMBER
  )
  as
    ddp_code_assignment_rec hz_classification_v2pub.code_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_code_assignment_rec.code_assignment_id := rosetta_g_miss_num_map(p1_a0);
    ddp_code_assignment_rec.owner_table_name := p1_a1;
    ddp_code_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p1_a2);
    ddp_code_assignment_rec.class_category := p1_a3;
    ddp_code_assignment_rec.class_code := p1_a4;
    ddp_code_assignment_rec.primary_flag := p1_a5;
    ddp_code_assignment_rec.content_source_type := p1_a6;
    ddp_code_assignment_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a7);
    ddp_code_assignment_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a8);
    ddp_code_assignment_rec.status := p1_a9;
    ddp_code_assignment_rec.created_by_module := p1_a10;
    ddp_code_assignment_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_code_assignment(p_init_msg_list,
      ddp_code_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_code_assignment_id);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_code_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  DATE := fnd_api.g_miss_date
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  NUMBER := 0-1962.0724
    , p_object_version_number in out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )
  as
    ddp_code_assignment_rec hz_classification_v2pub.code_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_code_assignment_rec.code_assignment_id := rosetta_g_miss_num_map(p1_a0);
    ddp_code_assignment_rec.owner_table_name := p1_a1;
    ddp_code_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p1_a2);
    ddp_code_assignment_rec.class_category := p1_a3;
    ddp_code_assignment_rec.class_code := p1_a4;
    ddp_code_assignment_rec.primary_flag := p1_a5;
    ddp_code_assignment_rec.content_source_type := p1_a6;
    ddp_code_assignment_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a7);
    ddp_code_assignment_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a8);
    ddp_code_assignment_rec.status := p1_a9;
    ddp_code_assignment_rec.created_by_module := p1_a10;
    ddp_code_assignment_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_code_assignment(p_init_msg_list,
      ddp_code_assignment_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end asf_hz_class_v2pub_w;

/
