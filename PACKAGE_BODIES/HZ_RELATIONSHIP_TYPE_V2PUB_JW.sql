--------------------------------------------------------
--  DDL for Package Body HZ_RELATIONSHIP_TYPE_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_RELATIONSHIP_TYPE_V2PUB_JW" as
  /* $Header: ARH2RTJB.pls 120.4 2005/06/18 04:29:11 jhuang noship $ */
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

  procedure create_relationship_type_1(p_init_msg_list  VARCHAR2
    , x_relationship_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  NUMBER := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
  )
  as
    ddp_relationship_type_rec hz_relationship_type_v2pub.relationship_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_relationship_type_rec.relationship_type_id := rosetta_g_miss_num_map(p1_a0);
    ddp_relationship_type_rec.relationship_type := p1_a1;
    ddp_relationship_type_rec.forward_rel_code := p1_a2;
    ddp_relationship_type_rec.backward_rel_code := p1_a3;
    ddp_relationship_type_rec.direction_code := p1_a4;
    ddp_relationship_type_rec.hierarchical_flag := p1_a5;
    ddp_relationship_type_rec.create_party_flag := p1_a6;
    ddp_relationship_type_rec.allow_relate_to_self_flag := p1_a7;
    ddp_relationship_type_rec.allow_circular_relationships := p1_a8;
    ddp_relationship_type_rec.subject_type := p1_a9;
    ddp_relationship_type_rec.object_type := p1_a10;
    ddp_relationship_type_rec.status := p1_a11;
    ddp_relationship_type_rec.created_by_module := p1_a12;
    ddp_relationship_type_rec.application_id := rosetta_g_miss_num_map(p1_a13);
    ddp_relationship_type_rec.multiple_parent_allowed := p1_a14;
    ddp_relationship_type_rec.incl_unrelated_entities := p1_a15;
    ddp_relationship_type_rec.forward_role := p1_a16;
    ddp_relationship_type_rec.backward_role := p1_a17;





    -- here's the delegated call to the old PL/SQL routine
    hz_relationship_type_v2pub.create_relationship_type(p_init_msg_list,
      ddp_relationship_type_rec,
      x_relationship_type_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_relationship_type_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  NUMBER := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
  )
  as
    ddp_relationship_type_rec hz_relationship_type_v2pub.relationship_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_relationship_type_rec.relationship_type_id := rosetta_g_miss_num_map(p1_a0);
    ddp_relationship_type_rec.relationship_type := p1_a1;
    ddp_relationship_type_rec.forward_rel_code := p1_a2;
    ddp_relationship_type_rec.backward_rel_code := p1_a3;
    ddp_relationship_type_rec.direction_code := p1_a4;
    ddp_relationship_type_rec.hierarchical_flag := p1_a5;
    ddp_relationship_type_rec.create_party_flag := p1_a6;
    ddp_relationship_type_rec.allow_relate_to_self_flag := p1_a7;
    ddp_relationship_type_rec.allow_circular_relationships := p1_a8;
    ddp_relationship_type_rec.subject_type := p1_a9;
    ddp_relationship_type_rec.object_type := p1_a10;
    ddp_relationship_type_rec.status := p1_a11;
    ddp_relationship_type_rec.created_by_module := p1_a12;
    ddp_relationship_type_rec.application_id := rosetta_g_miss_num_map(p1_a13);
    ddp_relationship_type_rec.multiple_parent_allowed := p1_a14;
    ddp_relationship_type_rec.incl_unrelated_entities := p1_a15;
    ddp_relationship_type_rec.forward_role := p1_a16;
    ddp_relationship_type_rec.backward_role := p1_a17;





    -- here's the delegated call to the old PL/SQL routine
    hz_relationship_type_v2pub.update_relationship_type(p_init_msg_list,
      ddp_relationship_type_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end hz_relationship_type_v2pub_jw;

/
