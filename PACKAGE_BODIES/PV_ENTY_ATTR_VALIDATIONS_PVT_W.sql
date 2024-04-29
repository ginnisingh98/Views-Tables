--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALIDATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALIDATIONS_PVT_W" as
  /* $Header: pvxwatvb.pls 115.0 2002/12/07 03:07:45 amaram ship $ */
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

  procedure create_enty_attr_validation(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_enty_attr_validation_id out nocopy  NUMBER
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
    pv_enty_attr_validations_pvt.create_enty_attr_validation(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_validation_rec,
      x_enty_attr_validation_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_enty_attr_validation(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
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
    pv_enty_attr_validations_pvt.update_enty_attr_validation(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_validation_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_enty_attr_validation(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  DATE := fnd_api.g_miss_date
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_enty_attr_validation_rec pv_enty_attr_validations_pvt.enty_attr_validation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_enty_attr_validation_rec.validation_id := rosetta_g_miss_num_map(p4_a0);
    ddp_enty_attr_validation_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_enty_attr_validation_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_enty_attr_validation_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_enty_attr_validation_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_enty_attr_validation_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_enty_attr_validation_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_enty_attr_validation_rec.validation_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_enty_attr_validation_rec.validated_by_resource_id := rosetta_g_miss_num_map(p4_a8);
    ddp_enty_attr_validation_rec.validation_document_id := rosetta_g_miss_num_map(p4_a9);
    ddp_enty_attr_validation_rec.validation_note := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_validations_pvt.validate_enty_attr_validation(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_enty_attr_validation_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_enty_attr_vldtn_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_enty_attr_validation_rec pv_enty_attr_validations_pvt.enty_attr_validation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_enty_attr_validation_rec.validation_id := rosetta_g_miss_num_map(p0_a0);
    ddp_enty_attr_validation_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_enty_attr_validation_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_enty_attr_validation_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_enty_attr_validation_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_enty_attr_validation_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_enty_attr_validation_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_enty_attr_validation_rec.validation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_enty_attr_validation_rec.validated_by_resource_id := rosetta_g_miss_num_map(p0_a8);
    ddp_enty_attr_validation_rec.validation_document_id := rosetta_g_miss_num_map(p0_a9);
    ddp_enty_attr_validation_rec.validation_note := p0_a10;



    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_validations_pvt.check_enty_attr_vldtn_items(ddp_enty_attr_validation_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_enty_attr_vldtn_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_validation_mode  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_enty_attr_validation_rec pv_enty_attr_validations_pvt.enty_attr_validation_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_enty_attr_validation_rec.validation_id := rosetta_g_miss_num_map(p5_a0);
    ddp_enty_attr_validation_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_enty_attr_validation_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_enty_attr_validation_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_enty_attr_validation_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_enty_attr_validation_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_enty_attr_validation_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_enty_attr_validation_rec.validation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_enty_attr_validation_rec.validated_by_resource_id := rosetta_g_miss_num_map(p5_a8);
    ddp_enty_attr_validation_rec.validation_document_id := rosetta_g_miss_num_map(p5_a9);
    ddp_enty_attr_validation_rec.validation_note := p5_a10;


    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_validations_pvt.validate_enty_attr_vldtn_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enty_attr_validation_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end pv_enty_attr_validations_pvt_w;

/
