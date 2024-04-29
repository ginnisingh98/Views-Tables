--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALIDATIONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALIDATIONS_PUB_W" as
  /* $Header: pvxwvldb.pls 115.0 2002/12/07 03:08:06 amaram ship $ */
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

  procedure update_attr_validations(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute_id  NUMBER
    , p_entity_id  NUMBER
    , p_entity  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_enty_attr_validation_rec pv_enty_attr_validations_pvt.enty_attr_validation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enty_attr_validation_rec.validation_id := rosetta_g_miss_num_map(p7_a0);
    ddp_enty_attr_validation_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_enty_attr_validation_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_enty_attr_validation_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_enty_attr_validation_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_enty_attr_validation_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_enty_attr_validation_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_enty_attr_validation_rec.validation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_enty_attr_validation_rec.validated_by_resource_id := rosetta_g_miss_num_map(p7_a8);
    ddp_enty_attr_validation_rec.validation_document_id := rosetta_g_miss_num_map(p7_a9);
    ddp_enty_attr_validation_rec.validation_note := p7_a10;




    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_validations_pub.update_attr_validations(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_validation_rec,
      p_attribute_id,
      p_entity_id,
      p_entity);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end pv_enty_attr_validations_pub_w;

/
