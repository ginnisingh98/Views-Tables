--------------------------------------------------------
--  DDL for Package Body HZ_CLASSIFICATION_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CLASSIFICATION_V2PUB_JW" as
  /* $Header: ARH2CLJB.pls 120.3 2005/06/18 04:27:30 jhuang noship $ */
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

  procedure create_class_category_1(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  NUMBER := null
    , p1_a6  VARCHAR2 := null
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
    ddp_class_category_rec.delimiter := p1_a6;




    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_class_category(p_init_msg_list,
      ddp_class_category_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_class_category_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  NUMBER := null
    , p1_a6  VARCHAR2 := null
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
    ddp_class_category_rec.delimiter := p1_a6;





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_class_category(p_init_msg_list,
      ddp_class_category_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_class_category_rec_3(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p2_a0 out nocopy  VARCHAR2
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    p2_a6 := ddx_class_category_rec.delimiter;



  end;

  procedure create_class_code_relation_4(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  DATE := null
    , p1_a4  DATE := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
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

  procedure update_class_code_relation_5(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  DATE := null
    , p1_a4  DATE := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
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

  procedure get_class_code_relation_rec_6(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p_class_code  VARCHAR2
    , p_sub_class_code  VARCHAR2
    , p_start_date_active  date
    , p5_a0 out nocopy  VARCHAR2
    , p5_a1 out nocopy  VARCHAR2
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  DATE
    , p5_a4 out nocopy  DATE
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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

  procedure create_code_assignment_7(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_code_assignment_id out nocopy  NUMBER
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  DATE := null
    , p1_a13  DATE := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
  )
  as
    ddp_code_assignment_rec hz_classification_v2pub.code_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_code_assignment_rec.code_assignment_id := rosetta_g_miss_num_map(p1_a0);
    ddp_code_assignment_rec.owner_table_name := p1_a1;
    ddp_code_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p1_a2);
    ddp_code_assignment_rec.owner_table_key_1 := p1_a3;
    ddp_code_assignment_rec.owner_table_key_2 := p1_a4;
    ddp_code_assignment_rec.owner_table_key_3 := p1_a5;
    ddp_code_assignment_rec.owner_table_key_4 := p1_a6;
    ddp_code_assignment_rec.owner_table_key_5 := p1_a7;
    ddp_code_assignment_rec.class_category := p1_a8;
    ddp_code_assignment_rec.class_code := p1_a9;
    ddp_code_assignment_rec.primary_flag := p1_a10;
    ddp_code_assignment_rec.content_source_type := p1_a11;
    ddp_code_assignment_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a12);
    ddp_code_assignment_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a13);
    ddp_code_assignment_rec.status := p1_a14;
    ddp_code_assignment_rec.created_by_module := p1_a15;
    ddp_code_assignment_rec.rank := rosetta_g_miss_num_map(p1_a16);
    ddp_code_assignment_rec.application_id := rosetta_g_miss_num_map(p1_a17);
    ddp_code_assignment_rec.actual_content_source := p1_a18;





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_code_assignment(p_init_msg_list,
      ddp_code_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_code_assignment_id);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_code_assignment_8(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  DATE := null
    , p1_a13  DATE := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
  )
  as
    ddp_code_assignment_rec hz_classification_v2pub.code_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_code_assignment_rec.code_assignment_id := rosetta_g_miss_num_map(p1_a0);
    ddp_code_assignment_rec.owner_table_name := p1_a1;
    ddp_code_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p1_a2);
    ddp_code_assignment_rec.owner_table_key_1 := p1_a3;
    ddp_code_assignment_rec.owner_table_key_2 := p1_a4;
    ddp_code_assignment_rec.owner_table_key_3 := p1_a5;
    ddp_code_assignment_rec.owner_table_key_4 := p1_a6;
    ddp_code_assignment_rec.owner_table_key_5 := p1_a7;
    ddp_code_assignment_rec.class_category := p1_a8;
    ddp_code_assignment_rec.class_code := p1_a9;
    ddp_code_assignment_rec.primary_flag := p1_a10;
    ddp_code_assignment_rec.content_source_type := p1_a11;
    ddp_code_assignment_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a12);
    ddp_code_assignment_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a13);
    ddp_code_assignment_rec.status := p1_a14;
    ddp_code_assignment_rec.created_by_module := p1_a15;
    ddp_code_assignment_rec.rank := rosetta_g_miss_num_map(p1_a16);
    ddp_code_assignment_rec.application_id := rosetta_g_miss_num_map(p1_a17);
    ddp_code_assignment_rec.actual_content_source := p1_a18;





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_code_assignment(p_init_msg_list,
      ddp_code_assignment_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_code_assignment_rec_9(p_init_msg_list  VARCHAR2
    , p_code_assignment_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  DATE
    , p2_a13 out nocopy  DATE
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  NUMBER
    , p2_a17 out nocopy  NUMBER
    , p2_a18 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_code_assignment_rec hz_classification_v2pub.code_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.get_code_assignment_rec(p_init_msg_list,
      p_code_assignment_id,
      ddx_code_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_code_assignment_rec.code_assignment_id);
    p2_a1 := ddx_code_assignment_rec.owner_table_name;
    p2_a2 := rosetta_g_miss_num_map(ddx_code_assignment_rec.owner_table_id);
    p2_a3 := ddx_code_assignment_rec.owner_table_key_1;
    p2_a4 := ddx_code_assignment_rec.owner_table_key_2;
    p2_a5 := ddx_code_assignment_rec.owner_table_key_3;
    p2_a6 := ddx_code_assignment_rec.owner_table_key_4;
    p2_a7 := ddx_code_assignment_rec.owner_table_key_5;
    p2_a8 := ddx_code_assignment_rec.class_category;
    p2_a9 := ddx_code_assignment_rec.class_code;
    p2_a10 := ddx_code_assignment_rec.primary_flag;
    p2_a11 := ddx_code_assignment_rec.content_source_type;
    p2_a12 := ddx_code_assignment_rec.start_date_active;
    p2_a13 := ddx_code_assignment_rec.end_date_active;
    p2_a14 := ddx_code_assignment_rec.status;
    p2_a15 := ddx_code_assignment_rec.created_by_module;
    p2_a16 := rosetta_g_miss_num_map(ddx_code_assignment_rec.rank);
    p2_a17 := rosetta_g_miss_num_map(ddx_code_assignment_rec.application_id);
    p2_a18 := ddx_code_assignment_rec.actual_content_source;



  end;

  procedure create_class_category_use_10(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  NUMBER := null
  )
  as
    ddp_class_category_use_rec hz_classification_v2pub.class_category_use_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_category_use_rec.class_category := p1_a0;
    ddp_class_category_use_rec.owner_table := p1_a1;
    ddp_class_category_use_rec.column_name := p1_a2;
    ddp_class_category_use_rec.additional_where_clause := p1_a3;
    ddp_class_category_use_rec.created_by_module := p1_a4;
    ddp_class_category_use_rec.application_id := rosetta_g_miss_num_map(p1_a5);




    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_class_category_use(p_init_msg_list,
      ddp_class_category_use_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_class_category_use_11(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  NUMBER := null
  )
  as
    ddp_class_category_use_rec hz_classification_v2pub.class_category_use_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_category_use_rec.class_category := p1_a0;
    ddp_class_category_use_rec.owner_table := p1_a1;
    ddp_class_category_use_rec.column_name := p1_a2;
    ddp_class_category_use_rec.additional_where_clause := p1_a3;
    ddp_class_category_use_rec.created_by_module := p1_a4;
    ddp_class_category_use_rec.application_id := rosetta_g_miss_num_map(p1_a5);





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_class_category_use(p_init_msg_list,
      ddp_class_category_use_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_class_category_use_rec_12(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p_owner_table  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_class_category_use_rec hz_classification_v2pub.class_category_use_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.get_class_category_use_rec(p_init_msg_list,
      p_class_category,
      p_owner_table,
      ddx_class_category_use_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any



    p3_a0 := ddx_class_category_use_rec.class_category;
    p3_a1 := ddx_class_category_use_rec.owner_table;
    p3_a2 := ddx_class_category_use_rec.column_name;
    p3_a3 := ddx_class_category_use_rec.additional_where_clause;
    p3_a4 := ddx_class_category_use_rec.created_by_module;
    p3_a5 := rosetta_g_miss_num_map(ddx_class_category_use_rec.application_id);



  end;

  procedure create_class_code_13(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  DATE := null
    , p1_a6  VARCHAR2 := null
  )
  as
    ddp_class_code_rec hz_classification_v2pub.class_code_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_code_rec.type := p1_a0;
    ddp_class_code_rec.code := p1_a1;
    ddp_class_code_rec.meaning := p1_a2;
    ddp_class_code_rec.description := p1_a3;
    ddp_class_code_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a4);
    ddp_class_code_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a5);
    ddp_class_code_rec.enabled_flag := p1_a6;




    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.create_class_code(p_init_msg_list,
      ddp_class_code_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_class_code_14(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  DATE := null
    , p1_a6  VARCHAR2 := null
  )
  as
    ddp_class_code_rec hz_classification_v2pub.class_code_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_class_code_rec.type := p1_a0;
    ddp_class_code_rec.code := p1_a1;
    ddp_class_code_rec.meaning := p1_a2;
    ddp_class_code_rec.description := p1_a3;
    ddp_class_code_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a4);
    ddp_class_code_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a5);
    ddp_class_code_rec.enabled_flag := p1_a6;





    -- here's the delegated call to the old PL/SQL routine
    hz_classification_v2pub.update_class_code(p_init_msg_list,
      ddp_class_code_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end hz_classification_v2pub_jw;

/
