--------------------------------------------------------
--  DDL for Package Body ASF_HZ_CLASS_V2PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_HZ_CLASS_V2PUB_W2" as
  /* $Header: asfwcl2b.pls 115.1 2002/03/25 17:19:11 pkm ship    $ */
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

  procedure get_code_assignment_rec(p_init_msg_list  VARCHAR2
    , p_code_assignment_id  NUMBER
    , p2_a0 out  NUMBER
    , p2_a1 out  VARCHAR2
    , p2_a2 out  NUMBER
    , p2_a3 out  VARCHAR2
    , p2_a4 out  VARCHAR2
    , p2_a5 out  VARCHAR2
    , p2_a6 out  VARCHAR2
    , p2_a7 out  DATE
    , p2_a8 out  DATE
    , p2_a9 out  VARCHAR2
    , p2_a10 out  VARCHAR2
    , p2_a11 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
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
    p2_a3 := ddx_code_assignment_rec.class_category;
    p2_a4 := ddx_code_assignment_rec.class_code;
    p2_a5 := ddx_code_assignment_rec.primary_flag;
    p2_a6 := ddx_code_assignment_rec.content_source_type;
    p2_a7 := ddx_code_assignment_rec.start_date_active;
    p2_a8 := ddx_code_assignment_rec.end_date_active;
    p2_a9 := ddx_code_assignment_rec.status;
    p2_a10 := ddx_code_assignment_rec.created_by_module;
    p2_a11 := rosetta_g_miss_num_map(ddx_code_assignment_rec.application_id);



  end;

  procedure create_class_category_use(p_init_msg_list  VARCHAR2
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

  procedure update_class_category_use(p_init_msg_list  VARCHAR2
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

  procedure get_class_category_use_rec(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p_owner_table  VARCHAR2
    , p3_a0 out  VARCHAR2
    , p3_a1 out  VARCHAR2
    , p3_a2 out  VARCHAR2
    , p3_a3 out  VARCHAR2
    , p3_a4 out  VARCHAR2
    , p3_a5 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
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

end asf_hz_class_v2pub_w2;

/
