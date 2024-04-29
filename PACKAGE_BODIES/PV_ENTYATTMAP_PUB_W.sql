--------------------------------------------------------
--  DDL for Package Body PV_ENTYATTMAP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTYATTMAP_PUB_W" as
  /* $Header: pvrweamb.pls 120.0 2005/05/27 15:33:38 appldev noship $ */
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

  procedure create_entyattmap(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_mapping_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entyattmap_rec pv_rule_rectype_pub.entyattmap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_entyattmap_rec.mapping_id := rosetta_g_miss_num_map(p5_a0);
    ddp_entyattmap_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_entyattmap_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_entyattmap_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_entyattmap_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_entyattmap_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_entyattmap_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_entyattmap_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_entyattmap_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_entyattmap_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_entyattmap_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_entyattmap_rec.process_rule_id := rosetta_g_miss_num_map(p5_a11);
    ddp_entyattmap_rec.source_attr_type := p5_a12;
    ddp_entyattmap_rec.source_attr_id := rosetta_g_miss_num_map(p5_a13);
    ddp_entyattmap_rec.target_attr_type := p5_a14;
    ddp_entyattmap_rec.target_attr_id := rosetta_g_miss_num_map(p5_a15);
    ddp_entyattmap_rec.operator := p5_a16;
    ddp_entyattmap_rec.attribute_category := p5_a17;
    ddp_entyattmap_rec.attribute1 := p5_a18;
    ddp_entyattmap_rec.attribute2 := p5_a19;
    ddp_entyattmap_rec.attribute3 := p5_a20;
    ddp_entyattmap_rec.attribute4 := p5_a21;
    ddp_entyattmap_rec.attribute5 := p5_a22;
    ddp_entyattmap_rec.attribute6 := p5_a23;
    ddp_entyattmap_rec.attribute7 := p5_a24;
    ddp_entyattmap_rec.attribute8 := p5_a25;
    ddp_entyattmap_rec.attribute9 := p5_a26;
    ddp_entyattmap_rec.attribute10 := p5_a27;
    ddp_entyattmap_rec.attribute11 := p5_a28;
    ddp_entyattmap_rec.attribute12 := p5_a29;
    ddp_entyattmap_rec.attribute13 := p5_a30;
    ddp_entyattmap_rec.attribute14 := p5_a31;
    ddp_entyattmap_rec.attribute15 := p5_a32;





    -- here's the delegated call to the old PL/SQL routine
    pv_entyattmap_pub.create_entyattmap(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_entyattmap_rec,
      x_mapping_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_entyattmap(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entyattmap_rec pv_rule_rectype_pub.entyattmap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_entyattmap_rec.mapping_id := rosetta_g_miss_num_map(p5_a0);
    ddp_entyattmap_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_entyattmap_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_entyattmap_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_entyattmap_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_entyattmap_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_entyattmap_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_entyattmap_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_entyattmap_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_entyattmap_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_entyattmap_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_entyattmap_rec.process_rule_id := rosetta_g_miss_num_map(p5_a11);
    ddp_entyattmap_rec.source_attr_type := p5_a12;
    ddp_entyattmap_rec.source_attr_id := rosetta_g_miss_num_map(p5_a13);
    ddp_entyattmap_rec.target_attr_type := p5_a14;
    ddp_entyattmap_rec.target_attr_id := rosetta_g_miss_num_map(p5_a15);
    ddp_entyattmap_rec.operator := p5_a16;
    ddp_entyattmap_rec.attribute_category := p5_a17;
    ddp_entyattmap_rec.attribute1 := p5_a18;
    ddp_entyattmap_rec.attribute2 := p5_a19;
    ddp_entyattmap_rec.attribute3 := p5_a20;
    ddp_entyattmap_rec.attribute4 := p5_a21;
    ddp_entyattmap_rec.attribute5 := p5_a22;
    ddp_entyattmap_rec.attribute6 := p5_a23;
    ddp_entyattmap_rec.attribute7 := p5_a24;
    ddp_entyattmap_rec.attribute8 := p5_a25;
    ddp_entyattmap_rec.attribute9 := p5_a26;
    ddp_entyattmap_rec.attribute10 := p5_a27;
    ddp_entyattmap_rec.attribute11 := p5_a28;
    ddp_entyattmap_rec.attribute12 := p5_a29;
    ddp_entyattmap_rec.attribute13 := p5_a30;
    ddp_entyattmap_rec.attribute14 := p5_a31;
    ddp_entyattmap_rec.attribute15 := p5_a32;




    -- here's the delegated call to the old PL/SQL routine
    pv_entyattmap_pub.update_entyattmap(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_entyattmap_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure delete_entyattmap(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_entyattmap_rec pv_rule_rectype_pub.entyattmap_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_entyattmap_rec.mapping_id := rosetta_g_miss_num_map(p5_a0);
    ddp_entyattmap_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_entyattmap_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_entyattmap_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_entyattmap_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_entyattmap_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_entyattmap_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_entyattmap_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_entyattmap_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_entyattmap_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_entyattmap_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_entyattmap_rec.process_rule_id := rosetta_g_miss_num_map(p5_a11);
    ddp_entyattmap_rec.source_attr_type := p5_a12;
    ddp_entyattmap_rec.source_attr_id := rosetta_g_miss_num_map(p5_a13);
    ddp_entyattmap_rec.target_attr_type := p5_a14;
    ddp_entyattmap_rec.target_attr_id := rosetta_g_miss_num_map(p5_a15);
    ddp_entyattmap_rec.operator := p5_a16;
    ddp_entyattmap_rec.attribute_category := p5_a17;
    ddp_entyattmap_rec.attribute1 := p5_a18;
    ddp_entyattmap_rec.attribute2 := p5_a19;
    ddp_entyattmap_rec.attribute3 := p5_a20;
    ddp_entyattmap_rec.attribute4 := p5_a21;
    ddp_entyattmap_rec.attribute5 := p5_a22;
    ddp_entyattmap_rec.attribute6 := p5_a23;
    ddp_entyattmap_rec.attribute7 := p5_a24;
    ddp_entyattmap_rec.attribute8 := p5_a25;
    ddp_entyattmap_rec.attribute9 := p5_a26;
    ddp_entyattmap_rec.attribute10 := p5_a27;
    ddp_entyattmap_rec.attribute11 := p5_a28;
    ddp_entyattmap_rec.attribute12 := p5_a29;
    ddp_entyattmap_rec.attribute13 := p5_a30;
    ddp_entyattmap_rec.attribute14 := p5_a31;
    ddp_entyattmap_rec.attribute15 := p5_a32;




    -- here's the delegated call to the old PL/SQL routine
    pv_entyattmap_pub.delete_entyattmap(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_entyattmap_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end pv_entyattmap_pub_w;

/
