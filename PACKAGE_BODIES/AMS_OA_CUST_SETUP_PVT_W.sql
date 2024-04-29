--------------------------------------------------------
--  DDL for Package Body AMS_OA_CUST_SETUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_OA_CUST_SETUP_PVT_W" as
  /* $Header: amsacusb.pls 115.0 2003/09/15 16:20:59 vanbukum noship $ */
  procedure create_cust_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , x_cust_setup_id out nocopy  NUMBER
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cust_setup_rec.custom_setup_id := p7_a0;
    ddp_cust_setup_rec.last_update_date := p7_a1;
    ddp_cust_setup_rec.last_updated_by := p7_a2;
    ddp_cust_setup_rec.creation_date := p7_a3;
    ddp_cust_setup_rec.created_by := p7_a4;
    ddp_cust_setup_rec.last_update_login := p7_a5;
    ddp_cust_setup_rec.object_version_number := p7_a6;
    ddp_cust_setup_rec.activity_type_code := p7_a7;
    ddp_cust_setup_rec.media_id := p7_a8;
    ddp_cust_setup_rec.enabled_flag := p7_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p7_a10;
    ddp_cust_setup_rec.usage := p7_a11;
    ddp_cust_setup_rec.object_type := p7_a12;
    ddp_cust_setup_rec.source_code_suffix := p7_a13;
    ddp_cust_setup_rec.setup_name := p7_a14;
    ddp_cust_setup_rec.description := p7_a15;
    ddp_cust_setup_rec.application_id := p7_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.create_cust_setup(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cust_setup_rec,
      x_cust_setup_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_cust_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cust_setup_rec.custom_setup_id := p7_a0;
    ddp_cust_setup_rec.last_update_date := p7_a1;
    ddp_cust_setup_rec.last_updated_by := p7_a2;
    ddp_cust_setup_rec.creation_date := p7_a3;
    ddp_cust_setup_rec.created_by := p7_a4;
    ddp_cust_setup_rec.last_update_login := p7_a5;
    ddp_cust_setup_rec.object_version_number := p7_a6;
    ddp_cust_setup_rec.activity_type_code := p7_a7;
    ddp_cust_setup_rec.media_id := p7_a8;
    ddp_cust_setup_rec.enabled_flag := p7_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p7_a10;
    ddp_cust_setup_rec.usage := p7_a11;
    ddp_cust_setup_rec.object_type := p7_a12;
    ddp_cust_setup_rec.source_code_suffix := p7_a13;
    ddp_cust_setup_rec.setup_name := p7_a14;
    ddp_cust_setup_rec.description := p7_a15;
    ddp_cust_setup_rec.application_id := p7_a16;

    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.update_cust_setup(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cust_setup_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_cust_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_cust_setup_rec.custom_setup_id := p6_a0;
    ddp_cust_setup_rec.last_update_date := p6_a1;
    ddp_cust_setup_rec.last_updated_by := p6_a2;
    ddp_cust_setup_rec.creation_date := p6_a3;
    ddp_cust_setup_rec.created_by := p6_a4;
    ddp_cust_setup_rec.last_update_login := p6_a5;
    ddp_cust_setup_rec.object_version_number := p6_a6;
    ddp_cust_setup_rec.activity_type_code := p6_a7;
    ddp_cust_setup_rec.media_id := p6_a8;
    ddp_cust_setup_rec.enabled_flag := p6_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p6_a10;
    ddp_cust_setup_rec.usage := p6_a11;
    ddp_cust_setup_rec.object_type := p6_a12;
    ddp_cust_setup_rec.source_code_suffix := p6_a13;
    ddp_cust_setup_rec.setup_name := p6_a14;
    ddp_cust_setup_rec.description := p6_a15;
    ddp_cust_setup_rec.application_id := p6_a16;

    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.validate_cust_setup(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cust_setup_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_cust_setup_rec.custom_setup_id := p2_a0;
    ddp_cust_setup_rec.last_update_date := p2_a1;
    ddp_cust_setup_rec.last_updated_by := p2_a2;
    ddp_cust_setup_rec.creation_date := p2_a3;
    ddp_cust_setup_rec.created_by := p2_a4;
    ddp_cust_setup_rec.last_update_login := p2_a5;
    ddp_cust_setup_rec.object_version_number := p2_a6;
    ddp_cust_setup_rec.activity_type_code := p2_a7;
    ddp_cust_setup_rec.media_id := p2_a8;
    ddp_cust_setup_rec.enabled_flag := p2_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p2_a10;
    ddp_cust_setup_rec.usage := p2_a11;
    ddp_cust_setup_rec.object_type := p2_a12;
    ddp_cust_setup_rec.source_code_suffix := p2_a13;
    ddp_cust_setup_rec.setup_name := p2_a14;
    ddp_cust_setup_rec.description := p2_a15;
    ddp_cust_setup_rec.application_id := p2_a16;

    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_cust_setup_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_cust_setup_req_items(p_validation_mode  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_setup_rec.custom_setup_id := p1_a0;
    ddp_cust_setup_rec.last_update_date := p1_a1;
    ddp_cust_setup_rec.last_updated_by := p1_a2;
    ddp_cust_setup_rec.creation_date := p1_a3;
    ddp_cust_setup_rec.created_by := p1_a4;
    ddp_cust_setup_rec.last_update_login := p1_a5;
    ddp_cust_setup_rec.object_version_number := p1_a6;
    ddp_cust_setup_rec.activity_type_code := p1_a7;
    ddp_cust_setup_rec.media_id := p1_a8;
    ddp_cust_setup_rec.enabled_flag := p1_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p1_a10;
    ddp_cust_setup_rec.usage := p1_a11;
    ddp_cust_setup_rec.object_type := p1_a12;
    ddp_cust_setup_rec.source_code_suffix := p1_a13;
    ddp_cust_setup_rec.setup_name := p1_a14;
    ddp_cust_setup_rec.description := p1_a15;
    ddp_cust_setup_rec.application_id := p1_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.check_cust_setup_req_items(p_validation_mode,
      ddp_cust_setup_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_cust_setup_uk_items(p_validation_mode  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_setup_rec.custom_setup_id := p1_a0;
    ddp_cust_setup_rec.last_update_date := p1_a1;
    ddp_cust_setup_rec.last_updated_by := p1_a2;
    ddp_cust_setup_rec.creation_date := p1_a3;
    ddp_cust_setup_rec.created_by := p1_a4;
    ddp_cust_setup_rec.last_update_login := p1_a5;
    ddp_cust_setup_rec.object_version_number := p1_a6;
    ddp_cust_setup_rec.activity_type_code := p1_a7;
    ddp_cust_setup_rec.media_id := p1_a8;
    ddp_cust_setup_rec.enabled_flag := p1_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p1_a10;
    ddp_cust_setup_rec.usage := p1_a11;
    ddp_cust_setup_rec.object_type := p1_a12;
    ddp_cust_setup_rec.source_code_suffix := p1_a13;
    ddp_cust_setup_rec.setup_name := p1_a14;
    ddp_cust_setup_rec.description := p1_a15;
    ddp_cust_setup_rec.application_id := p1_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.check_cust_setup_uk_items(p_validation_mode,
      ddp_cust_setup_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_cust_setup_fk_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cust_setup_rec.custom_setup_id := p0_a0;
    ddp_cust_setup_rec.last_update_date := p0_a1;
    ddp_cust_setup_rec.last_updated_by := p0_a2;
    ddp_cust_setup_rec.creation_date := p0_a3;
    ddp_cust_setup_rec.created_by := p0_a4;
    ddp_cust_setup_rec.last_update_login := p0_a5;
    ddp_cust_setup_rec.object_version_number := p0_a6;
    ddp_cust_setup_rec.activity_type_code := p0_a7;
    ddp_cust_setup_rec.media_id := p0_a8;
    ddp_cust_setup_rec.enabled_flag := p0_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p0_a10;
    ddp_cust_setup_rec.usage := p0_a11;
    ddp_cust_setup_rec.object_type := p0_a12;
    ddp_cust_setup_rec.source_code_suffix := p0_a13;
    ddp_cust_setup_rec.setup_name := p0_a14;
    ddp_cust_setup_rec.description := p0_a15;
    ddp_cust_setup_rec.application_id := p0_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.check_cust_setup_fk_items(ddp_cust_setup_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure check_cust_setup_flag_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cust_setup_rec.custom_setup_id := p0_a0;
    ddp_cust_setup_rec.last_update_date := p0_a1;
    ddp_cust_setup_rec.last_updated_by := p0_a2;
    ddp_cust_setup_rec.creation_date := p0_a3;
    ddp_cust_setup_rec.created_by := p0_a4;
    ddp_cust_setup_rec.last_update_login := p0_a5;
    ddp_cust_setup_rec.object_version_number := p0_a6;
    ddp_cust_setup_rec.activity_type_code := p0_a7;
    ddp_cust_setup_rec.media_id := p0_a8;
    ddp_cust_setup_rec.enabled_flag := p0_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p0_a10;
    ddp_cust_setup_rec.usage := p0_a11;
    ddp_cust_setup_rec.object_type := p0_a12;
    ddp_cust_setup_rec.source_code_suffix := p0_a13;
    ddp_cust_setup_rec.setup_name := p0_a14;
    ddp_cust_setup_rec.description := p0_a15;
    ddp_cust_setup_rec.application_id := p0_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.check_cust_setup_flag_items(ddp_cust_setup_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure complete_cust_setup_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
  )

  as
    ddp_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddx_complete_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cust_setup_rec.custom_setup_id := p0_a0;
    ddp_cust_setup_rec.last_update_date := p0_a1;
    ddp_cust_setup_rec.last_updated_by := p0_a2;
    ddp_cust_setup_rec.creation_date := p0_a3;
    ddp_cust_setup_rec.created_by := p0_a4;
    ddp_cust_setup_rec.last_update_login := p0_a5;
    ddp_cust_setup_rec.object_version_number := p0_a6;
    ddp_cust_setup_rec.activity_type_code := p0_a7;
    ddp_cust_setup_rec.media_id := p0_a8;
    ddp_cust_setup_rec.enabled_flag := p0_a9;
    ddp_cust_setup_rec.allow_essential_grouping := p0_a10;
    ddp_cust_setup_rec.usage := p0_a11;
    ddp_cust_setup_rec.object_type := p0_a12;
    ddp_cust_setup_rec.source_code_suffix := p0_a13;
    ddp_cust_setup_rec.setup_name := p0_a14;
    ddp_cust_setup_rec.description := p0_a15;
    ddp_cust_setup_rec.application_id := p0_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.complete_cust_setup_rec(ddp_cust_setup_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.custom_setup_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.activity_type_code;
    p1_a8 := ddx_complete_rec.media_id;
    p1_a9 := ddx_complete_rec.enabled_flag;
    p1_a10 := ddx_complete_rec.allow_essential_grouping;
    p1_a11 := ddx_complete_rec.usage;
    p1_a12 := ddx_complete_rec.object_type;
    p1_a13 := ddx_complete_rec.source_code_suffix;
    p1_a14 := ddx_complete_rec.setup_name;
    p1_a15 := ddx_complete_rec.description;
    p1_a16 := ddx_complete_rec.application_id;
  end;

  procedure init_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
  )

  as
    ddx_cust_setup_rec ams_cust_setup_pvt.cust_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_cust_setup_pvt.init_rec(ddx_cust_setup_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_cust_setup_rec.custom_setup_id;
    p0_a1 := ddx_cust_setup_rec.last_update_date;
    p0_a2 := ddx_cust_setup_rec.last_updated_by;
    p0_a3 := ddx_cust_setup_rec.creation_date;
    p0_a4 := ddx_cust_setup_rec.created_by;
    p0_a5 := ddx_cust_setup_rec.last_update_login;
    p0_a6 := ddx_cust_setup_rec.object_version_number;
    p0_a7 := ddx_cust_setup_rec.activity_type_code;
    p0_a8 := ddx_cust_setup_rec.media_id;
    p0_a9 := ddx_cust_setup_rec.enabled_flag;
    p0_a10 := ddx_cust_setup_rec.allow_essential_grouping;
    p0_a11 := ddx_cust_setup_rec.usage;
    p0_a12 := ddx_cust_setup_rec.object_type;
    p0_a13 := ddx_cust_setup_rec.source_code_suffix;
    p0_a14 := ddx_cust_setup_rec.setup_name;
    p0_a15 := ddx_cust_setup_rec.description;
    p0_a16 := ddx_cust_setup_rec.application_id;
  end;

end ams_oa_cust_setup_pvt_w;

/
