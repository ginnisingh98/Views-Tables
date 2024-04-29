--------------------------------------------------------
--  DDL for Package Body AHL_RA_SETUPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RA_SETUPS_PVT_W" as
  /* $Header: AHLWRASB.pls 120.2 2005/09/15 00:15 sagarwal noship $ */
  procedure create_setup_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  DATE
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  NUMBER
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
  )

  as
    ddp_x_setup_data_rec ahl_ra_setups_pvt.ra_setup_data_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_setup_data_rec.ra_setup_id := p8_a0;
    ddp_x_setup_data_rec.setup_code := p8_a1;
    ddp_x_setup_data_rec.status_id := p8_a2;
    ddp_x_setup_data_rec.removal_code := p8_a3;
    ddp_x_setup_data_rec.operation_flag := p8_a4;
    ddp_x_setup_data_rec.object_version_number := p8_a5;
    ddp_x_setup_data_rec.security_group_id := p8_a6;
    ddp_x_setup_data_rec.creation_date := p8_a7;
    ddp_x_setup_data_rec.created_by := p8_a8;
    ddp_x_setup_data_rec.last_update_date := p8_a9;
    ddp_x_setup_data_rec.last_updated_by := p8_a10;
    ddp_x_setup_data_rec.last_update_login := p8_a11;
    ddp_x_setup_data_rec.attribute_category := p8_a12;
    ddp_x_setup_data_rec.attribute1 := p8_a13;
    ddp_x_setup_data_rec.attribute2 := p8_a14;
    ddp_x_setup_data_rec.attribute3 := p8_a15;
    ddp_x_setup_data_rec.attribute4 := p8_a16;
    ddp_x_setup_data_rec.attribute5 := p8_a17;
    ddp_x_setup_data_rec.attribute6 := p8_a18;
    ddp_x_setup_data_rec.attribute7 := p8_a19;
    ddp_x_setup_data_rec.attribute8 := p8_a20;
    ddp_x_setup_data_rec.attribute9 := p8_a21;
    ddp_x_setup_data_rec.attribute10 := p8_a22;
    ddp_x_setup_data_rec.attribute11 := p8_a23;
    ddp_x_setup_data_rec.attribute12 := p8_a24;
    ddp_x_setup_data_rec.attribute13 := p8_a25;
    ddp_x_setup_data_rec.attribute14 := p8_a26;
    ddp_x_setup_data_rec.attribute15 := p8_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.create_setup_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_setup_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_setup_data_rec.ra_setup_id;
    p8_a1 := ddp_x_setup_data_rec.setup_code;
    p8_a2 := ddp_x_setup_data_rec.status_id;
    p8_a3 := ddp_x_setup_data_rec.removal_code;
    p8_a4 := ddp_x_setup_data_rec.operation_flag;
    p8_a5 := ddp_x_setup_data_rec.object_version_number;
    p8_a6 := ddp_x_setup_data_rec.security_group_id;
    p8_a7 := ddp_x_setup_data_rec.creation_date;
    p8_a8 := ddp_x_setup_data_rec.created_by;
    p8_a9 := ddp_x_setup_data_rec.last_update_date;
    p8_a10 := ddp_x_setup_data_rec.last_updated_by;
    p8_a11 := ddp_x_setup_data_rec.last_update_login;
    p8_a12 := ddp_x_setup_data_rec.attribute_category;
    p8_a13 := ddp_x_setup_data_rec.attribute1;
    p8_a14 := ddp_x_setup_data_rec.attribute2;
    p8_a15 := ddp_x_setup_data_rec.attribute3;
    p8_a16 := ddp_x_setup_data_rec.attribute4;
    p8_a17 := ddp_x_setup_data_rec.attribute5;
    p8_a18 := ddp_x_setup_data_rec.attribute6;
    p8_a19 := ddp_x_setup_data_rec.attribute7;
    p8_a20 := ddp_x_setup_data_rec.attribute8;
    p8_a21 := ddp_x_setup_data_rec.attribute9;
    p8_a22 := ddp_x_setup_data_rec.attribute10;
    p8_a23 := ddp_x_setup_data_rec.attribute11;
    p8_a24 := ddp_x_setup_data_rec.attribute12;
    p8_a25 := ddp_x_setup_data_rec.attribute13;
    p8_a26 := ddp_x_setup_data_rec.attribute14;
    p8_a27 := ddp_x_setup_data_rec.attribute15;
  end;

  procedure delete_setup_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
    , p8_a2  NUMBER
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  DATE
    , p8_a8  NUMBER
    , p8_a9  DATE
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
  )

  as
    ddp_setup_data_rec ahl_ra_setups_pvt.ra_setup_data_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_setup_data_rec.ra_setup_id := p8_a0;
    ddp_setup_data_rec.setup_code := p8_a1;
    ddp_setup_data_rec.status_id := p8_a2;
    ddp_setup_data_rec.removal_code := p8_a3;
    ddp_setup_data_rec.operation_flag := p8_a4;
    ddp_setup_data_rec.object_version_number := p8_a5;
    ddp_setup_data_rec.security_group_id := p8_a6;
    ddp_setup_data_rec.creation_date := p8_a7;
    ddp_setup_data_rec.created_by := p8_a8;
    ddp_setup_data_rec.last_update_date := p8_a9;
    ddp_setup_data_rec.last_updated_by := p8_a10;
    ddp_setup_data_rec.last_update_login := p8_a11;
    ddp_setup_data_rec.attribute_category := p8_a12;
    ddp_setup_data_rec.attribute1 := p8_a13;
    ddp_setup_data_rec.attribute2 := p8_a14;
    ddp_setup_data_rec.attribute3 := p8_a15;
    ddp_setup_data_rec.attribute4 := p8_a16;
    ddp_setup_data_rec.attribute5 := p8_a17;
    ddp_setup_data_rec.attribute6 := p8_a18;
    ddp_setup_data_rec.attribute7 := p8_a19;
    ddp_setup_data_rec.attribute8 := p8_a20;
    ddp_setup_data_rec.attribute9 := p8_a21;
    ddp_setup_data_rec.attribute10 := p8_a22;
    ddp_setup_data_rec.attribute11 := p8_a23;
    ddp_setup_data_rec.attribute12 := p8_a24;
    ddp_setup_data_rec.attribute13 := p8_a25;
    ddp_setup_data_rec.attribute14 := p8_a26;
    ddp_setup_data_rec.attribute15 := p8_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.delete_setup_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_setup_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_reliability_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
  )

  as
    ddp_x_reliability_data_rec ahl_ra_setups_pvt.ra_definition_hdr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_reliability_data_rec.ra_definition_hdr_id := p8_a0;
    ddp_x_reliability_data_rec.mc_header_id := p8_a1;
    ddp_x_reliability_data_rec.inventory_item_id := p8_a2;
    ddp_x_reliability_data_rec.inventory_org_id := p8_a3;
    ddp_x_reliability_data_rec.item_revision := p8_a4;
    ddp_x_reliability_data_rec.relationship_id := p8_a5;
    ddp_x_reliability_data_rec.operation_flag := p8_a6;
    ddp_x_reliability_data_rec.object_version_number := p8_a7;
    ddp_x_reliability_data_rec.security_group_id := p8_a8;
    ddp_x_reliability_data_rec.creation_date := p8_a9;
    ddp_x_reliability_data_rec.created_by := p8_a10;
    ddp_x_reliability_data_rec.last_update_date := p8_a11;
    ddp_x_reliability_data_rec.last_updated_by := p8_a12;
    ddp_x_reliability_data_rec.last_update_login := p8_a13;
    ddp_x_reliability_data_rec.attribute_category := p8_a14;
    ddp_x_reliability_data_rec.attribute1 := p8_a15;
    ddp_x_reliability_data_rec.attribute2 := p8_a16;
    ddp_x_reliability_data_rec.attribute3 := p8_a17;
    ddp_x_reliability_data_rec.attribute4 := p8_a18;
    ddp_x_reliability_data_rec.attribute5 := p8_a19;
    ddp_x_reliability_data_rec.attribute6 := p8_a20;
    ddp_x_reliability_data_rec.attribute7 := p8_a21;
    ddp_x_reliability_data_rec.attribute8 := p8_a22;
    ddp_x_reliability_data_rec.attribute9 := p8_a23;
    ddp_x_reliability_data_rec.attribute10 := p8_a24;
    ddp_x_reliability_data_rec.attribute11 := p8_a25;
    ddp_x_reliability_data_rec.attribute12 := p8_a26;
    ddp_x_reliability_data_rec.attribute13 := p8_a27;
    ddp_x_reliability_data_rec.attribute14 := p8_a28;
    ddp_x_reliability_data_rec.attribute15 := p8_a29;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.create_reliability_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_reliability_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_reliability_data_rec.ra_definition_hdr_id;
    p8_a1 := ddp_x_reliability_data_rec.mc_header_id;
    p8_a2 := ddp_x_reliability_data_rec.inventory_item_id;
    p8_a3 := ddp_x_reliability_data_rec.inventory_org_id;
    p8_a4 := ddp_x_reliability_data_rec.item_revision;
    p8_a5 := ddp_x_reliability_data_rec.relationship_id;
    p8_a6 := ddp_x_reliability_data_rec.operation_flag;
    p8_a7 := ddp_x_reliability_data_rec.object_version_number;
    p8_a8 := ddp_x_reliability_data_rec.security_group_id;
    p8_a9 := ddp_x_reliability_data_rec.creation_date;
    p8_a10 := ddp_x_reliability_data_rec.created_by;
    p8_a11 := ddp_x_reliability_data_rec.last_update_date;
    p8_a12 := ddp_x_reliability_data_rec.last_updated_by;
    p8_a13 := ddp_x_reliability_data_rec.last_update_login;
    p8_a14 := ddp_x_reliability_data_rec.attribute_category;
    p8_a15 := ddp_x_reliability_data_rec.attribute1;
    p8_a16 := ddp_x_reliability_data_rec.attribute2;
    p8_a17 := ddp_x_reliability_data_rec.attribute3;
    p8_a18 := ddp_x_reliability_data_rec.attribute4;
    p8_a19 := ddp_x_reliability_data_rec.attribute5;
    p8_a20 := ddp_x_reliability_data_rec.attribute6;
    p8_a21 := ddp_x_reliability_data_rec.attribute7;
    p8_a22 := ddp_x_reliability_data_rec.attribute8;
    p8_a23 := ddp_x_reliability_data_rec.attribute9;
    p8_a24 := ddp_x_reliability_data_rec.attribute10;
    p8_a25 := ddp_x_reliability_data_rec.attribute11;
    p8_a26 := ddp_x_reliability_data_rec.attribute12;
    p8_a27 := ddp_x_reliability_data_rec.attribute13;
    p8_a28 := ddp_x_reliability_data_rec.attribute14;
    p8_a29 := ddp_x_reliability_data_rec.attribute15;
  end;

  procedure delete_reliability_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  VARCHAR2
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  DATE
    , p8_a10  NUMBER
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
  )

  as
    ddp_reliability_data_rec ahl_ra_setups_pvt.ra_definition_hdr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_reliability_data_rec.ra_definition_hdr_id := p8_a0;
    ddp_reliability_data_rec.mc_header_id := p8_a1;
    ddp_reliability_data_rec.inventory_item_id := p8_a2;
    ddp_reliability_data_rec.inventory_org_id := p8_a3;
    ddp_reliability_data_rec.item_revision := p8_a4;
    ddp_reliability_data_rec.relationship_id := p8_a5;
    ddp_reliability_data_rec.operation_flag := p8_a6;
    ddp_reliability_data_rec.object_version_number := p8_a7;
    ddp_reliability_data_rec.security_group_id := p8_a8;
    ddp_reliability_data_rec.creation_date := p8_a9;
    ddp_reliability_data_rec.created_by := p8_a10;
    ddp_reliability_data_rec.last_update_date := p8_a11;
    ddp_reliability_data_rec.last_updated_by := p8_a12;
    ddp_reliability_data_rec.last_update_login := p8_a13;
    ddp_reliability_data_rec.attribute_category := p8_a14;
    ddp_reliability_data_rec.attribute1 := p8_a15;
    ddp_reliability_data_rec.attribute2 := p8_a16;
    ddp_reliability_data_rec.attribute3 := p8_a17;
    ddp_reliability_data_rec.attribute4 := p8_a18;
    ddp_reliability_data_rec.attribute5 := p8_a19;
    ddp_reliability_data_rec.attribute6 := p8_a20;
    ddp_reliability_data_rec.attribute7 := p8_a21;
    ddp_reliability_data_rec.attribute8 := p8_a22;
    ddp_reliability_data_rec.attribute9 := p8_a23;
    ddp_reliability_data_rec.attribute10 := p8_a24;
    ddp_reliability_data_rec.attribute11 := p8_a25;
    ddp_reliability_data_rec.attribute12 := p8_a26;
    ddp_reliability_data_rec.attribute13 := p8_a27;
    ddp_reliability_data_rec.attribute14 := p8_a28;
    ddp_reliability_data_rec.attribute15 := p8_a29;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.delete_reliability_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_reliability_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_mtbf_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  DATE
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  DATE
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  NUMBER
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
  )

  as
    ddp_x_reliability_data_rec ahl_ra_setups_pvt.ra_definition_hdr_rec_type;
    ddp_x_mtbf_data_rec ahl_ra_setups_pvt.ra_definition_dtls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_reliability_data_rec.ra_definition_hdr_id := p8_a0;
    ddp_x_reliability_data_rec.mc_header_id := p8_a1;
    ddp_x_reliability_data_rec.inventory_item_id := p8_a2;
    ddp_x_reliability_data_rec.inventory_org_id := p8_a3;
    ddp_x_reliability_data_rec.item_revision := p8_a4;
    ddp_x_reliability_data_rec.relationship_id := p8_a5;
    ddp_x_reliability_data_rec.operation_flag := p8_a6;
    ddp_x_reliability_data_rec.object_version_number := p8_a7;
    ddp_x_reliability_data_rec.security_group_id := p8_a8;
    ddp_x_reliability_data_rec.creation_date := p8_a9;
    ddp_x_reliability_data_rec.created_by := p8_a10;
    ddp_x_reliability_data_rec.last_update_date := p8_a11;
    ddp_x_reliability_data_rec.last_updated_by := p8_a12;
    ddp_x_reliability_data_rec.last_update_login := p8_a13;
    ddp_x_reliability_data_rec.attribute_category := p8_a14;
    ddp_x_reliability_data_rec.attribute1 := p8_a15;
    ddp_x_reliability_data_rec.attribute2 := p8_a16;
    ddp_x_reliability_data_rec.attribute3 := p8_a17;
    ddp_x_reliability_data_rec.attribute4 := p8_a18;
    ddp_x_reliability_data_rec.attribute5 := p8_a19;
    ddp_x_reliability_data_rec.attribute6 := p8_a20;
    ddp_x_reliability_data_rec.attribute7 := p8_a21;
    ddp_x_reliability_data_rec.attribute8 := p8_a22;
    ddp_x_reliability_data_rec.attribute9 := p8_a23;
    ddp_x_reliability_data_rec.attribute10 := p8_a24;
    ddp_x_reliability_data_rec.attribute11 := p8_a25;
    ddp_x_reliability_data_rec.attribute12 := p8_a26;
    ddp_x_reliability_data_rec.attribute13 := p8_a27;
    ddp_x_reliability_data_rec.attribute14 := p8_a28;
    ddp_x_reliability_data_rec.attribute15 := p8_a29;

    ddp_x_mtbf_data_rec.ra_definition_dtl_id := p9_a0;
    ddp_x_mtbf_data_rec.ra_definition_hdr_id := p9_a1;
    ddp_x_mtbf_data_rec.counter_id := p9_a2;
    ddp_x_mtbf_data_rec.mtbf_value := p9_a3;
    ddp_x_mtbf_data_rec.operation_flag := p9_a4;
    ddp_x_mtbf_data_rec.object_version_number := p9_a5;
    ddp_x_mtbf_data_rec.security_group_id := p9_a6;
    ddp_x_mtbf_data_rec.creation_date := p9_a7;
    ddp_x_mtbf_data_rec.created_by := p9_a8;
    ddp_x_mtbf_data_rec.last_update_date := p9_a9;
    ddp_x_mtbf_data_rec.last_updated_by := p9_a10;
    ddp_x_mtbf_data_rec.last_update_login := p9_a11;
    ddp_x_mtbf_data_rec.attribute_category := p9_a12;
    ddp_x_mtbf_data_rec.attribute1 := p9_a13;
    ddp_x_mtbf_data_rec.attribute2 := p9_a14;
    ddp_x_mtbf_data_rec.attribute3 := p9_a15;
    ddp_x_mtbf_data_rec.attribute4 := p9_a16;
    ddp_x_mtbf_data_rec.attribute5 := p9_a17;
    ddp_x_mtbf_data_rec.attribute6 := p9_a18;
    ddp_x_mtbf_data_rec.attribute7 := p9_a19;
    ddp_x_mtbf_data_rec.attribute8 := p9_a20;
    ddp_x_mtbf_data_rec.attribute9 := p9_a21;
    ddp_x_mtbf_data_rec.attribute10 := p9_a22;
    ddp_x_mtbf_data_rec.attribute11 := p9_a23;
    ddp_x_mtbf_data_rec.attribute12 := p9_a24;
    ddp_x_mtbf_data_rec.attribute13 := p9_a25;
    ddp_x_mtbf_data_rec.attribute14 := p9_a26;
    ddp_x_mtbf_data_rec.attribute15 := p9_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.create_mtbf_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_reliability_data_rec,
      ddp_x_mtbf_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_reliability_data_rec.ra_definition_hdr_id;
    p8_a1 := ddp_x_reliability_data_rec.mc_header_id;
    p8_a2 := ddp_x_reliability_data_rec.inventory_item_id;
    p8_a3 := ddp_x_reliability_data_rec.inventory_org_id;
    p8_a4 := ddp_x_reliability_data_rec.item_revision;
    p8_a5 := ddp_x_reliability_data_rec.relationship_id;
    p8_a6 := ddp_x_reliability_data_rec.operation_flag;
    p8_a7 := ddp_x_reliability_data_rec.object_version_number;
    p8_a8 := ddp_x_reliability_data_rec.security_group_id;
    p8_a9 := ddp_x_reliability_data_rec.creation_date;
    p8_a10 := ddp_x_reliability_data_rec.created_by;
    p8_a11 := ddp_x_reliability_data_rec.last_update_date;
    p8_a12 := ddp_x_reliability_data_rec.last_updated_by;
    p8_a13 := ddp_x_reliability_data_rec.last_update_login;
    p8_a14 := ddp_x_reliability_data_rec.attribute_category;
    p8_a15 := ddp_x_reliability_data_rec.attribute1;
    p8_a16 := ddp_x_reliability_data_rec.attribute2;
    p8_a17 := ddp_x_reliability_data_rec.attribute3;
    p8_a18 := ddp_x_reliability_data_rec.attribute4;
    p8_a19 := ddp_x_reliability_data_rec.attribute5;
    p8_a20 := ddp_x_reliability_data_rec.attribute6;
    p8_a21 := ddp_x_reliability_data_rec.attribute7;
    p8_a22 := ddp_x_reliability_data_rec.attribute8;
    p8_a23 := ddp_x_reliability_data_rec.attribute9;
    p8_a24 := ddp_x_reliability_data_rec.attribute10;
    p8_a25 := ddp_x_reliability_data_rec.attribute11;
    p8_a26 := ddp_x_reliability_data_rec.attribute12;
    p8_a27 := ddp_x_reliability_data_rec.attribute13;
    p8_a28 := ddp_x_reliability_data_rec.attribute14;
    p8_a29 := ddp_x_reliability_data_rec.attribute15;

    p9_a0 := ddp_x_mtbf_data_rec.ra_definition_dtl_id;
    p9_a1 := ddp_x_mtbf_data_rec.ra_definition_hdr_id;
    p9_a2 := ddp_x_mtbf_data_rec.counter_id;
    p9_a3 := ddp_x_mtbf_data_rec.mtbf_value;
    p9_a4 := ddp_x_mtbf_data_rec.operation_flag;
    p9_a5 := ddp_x_mtbf_data_rec.object_version_number;
    p9_a6 := ddp_x_mtbf_data_rec.security_group_id;
    p9_a7 := ddp_x_mtbf_data_rec.creation_date;
    p9_a8 := ddp_x_mtbf_data_rec.created_by;
    p9_a9 := ddp_x_mtbf_data_rec.last_update_date;
    p9_a10 := ddp_x_mtbf_data_rec.last_updated_by;
    p9_a11 := ddp_x_mtbf_data_rec.last_update_login;
    p9_a12 := ddp_x_mtbf_data_rec.attribute_category;
    p9_a13 := ddp_x_mtbf_data_rec.attribute1;
    p9_a14 := ddp_x_mtbf_data_rec.attribute2;
    p9_a15 := ddp_x_mtbf_data_rec.attribute3;
    p9_a16 := ddp_x_mtbf_data_rec.attribute4;
    p9_a17 := ddp_x_mtbf_data_rec.attribute5;
    p9_a18 := ddp_x_mtbf_data_rec.attribute6;
    p9_a19 := ddp_x_mtbf_data_rec.attribute7;
    p9_a20 := ddp_x_mtbf_data_rec.attribute8;
    p9_a21 := ddp_x_mtbf_data_rec.attribute9;
    p9_a22 := ddp_x_mtbf_data_rec.attribute10;
    p9_a23 := ddp_x_mtbf_data_rec.attribute11;
    p9_a24 := ddp_x_mtbf_data_rec.attribute12;
    p9_a25 := ddp_x_mtbf_data_rec.attribute13;
    p9_a26 := ddp_x_mtbf_data_rec.attribute14;
    p9_a27 := ddp_x_mtbf_data_rec.attribute15;
  end;

  procedure update_mtbf_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  DATE
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  DATE
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  NUMBER
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
  )

  as
    ddp_x_reliability_data_rec ahl_ra_setups_pvt.ra_definition_hdr_rec_type;
    ddp_x_mtbf_data_rec ahl_ra_setups_pvt.ra_definition_dtls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_reliability_data_rec.ra_definition_hdr_id := p8_a0;
    ddp_x_reliability_data_rec.mc_header_id := p8_a1;
    ddp_x_reliability_data_rec.inventory_item_id := p8_a2;
    ddp_x_reliability_data_rec.inventory_org_id := p8_a3;
    ddp_x_reliability_data_rec.item_revision := p8_a4;
    ddp_x_reliability_data_rec.relationship_id := p8_a5;
    ddp_x_reliability_data_rec.operation_flag := p8_a6;
    ddp_x_reliability_data_rec.object_version_number := p8_a7;
    ddp_x_reliability_data_rec.security_group_id := p8_a8;
    ddp_x_reliability_data_rec.creation_date := p8_a9;
    ddp_x_reliability_data_rec.created_by := p8_a10;
    ddp_x_reliability_data_rec.last_update_date := p8_a11;
    ddp_x_reliability_data_rec.last_updated_by := p8_a12;
    ddp_x_reliability_data_rec.last_update_login := p8_a13;
    ddp_x_reliability_data_rec.attribute_category := p8_a14;
    ddp_x_reliability_data_rec.attribute1 := p8_a15;
    ddp_x_reliability_data_rec.attribute2 := p8_a16;
    ddp_x_reliability_data_rec.attribute3 := p8_a17;
    ddp_x_reliability_data_rec.attribute4 := p8_a18;
    ddp_x_reliability_data_rec.attribute5 := p8_a19;
    ddp_x_reliability_data_rec.attribute6 := p8_a20;
    ddp_x_reliability_data_rec.attribute7 := p8_a21;
    ddp_x_reliability_data_rec.attribute8 := p8_a22;
    ddp_x_reliability_data_rec.attribute9 := p8_a23;
    ddp_x_reliability_data_rec.attribute10 := p8_a24;
    ddp_x_reliability_data_rec.attribute11 := p8_a25;
    ddp_x_reliability_data_rec.attribute12 := p8_a26;
    ddp_x_reliability_data_rec.attribute13 := p8_a27;
    ddp_x_reliability_data_rec.attribute14 := p8_a28;
    ddp_x_reliability_data_rec.attribute15 := p8_a29;

    ddp_x_mtbf_data_rec.ra_definition_dtl_id := p9_a0;
    ddp_x_mtbf_data_rec.ra_definition_hdr_id := p9_a1;
    ddp_x_mtbf_data_rec.counter_id := p9_a2;
    ddp_x_mtbf_data_rec.mtbf_value := p9_a3;
    ddp_x_mtbf_data_rec.operation_flag := p9_a4;
    ddp_x_mtbf_data_rec.object_version_number := p9_a5;
    ddp_x_mtbf_data_rec.security_group_id := p9_a6;
    ddp_x_mtbf_data_rec.creation_date := p9_a7;
    ddp_x_mtbf_data_rec.created_by := p9_a8;
    ddp_x_mtbf_data_rec.last_update_date := p9_a9;
    ddp_x_mtbf_data_rec.last_updated_by := p9_a10;
    ddp_x_mtbf_data_rec.last_update_login := p9_a11;
    ddp_x_mtbf_data_rec.attribute_category := p9_a12;
    ddp_x_mtbf_data_rec.attribute1 := p9_a13;
    ddp_x_mtbf_data_rec.attribute2 := p9_a14;
    ddp_x_mtbf_data_rec.attribute3 := p9_a15;
    ddp_x_mtbf_data_rec.attribute4 := p9_a16;
    ddp_x_mtbf_data_rec.attribute5 := p9_a17;
    ddp_x_mtbf_data_rec.attribute6 := p9_a18;
    ddp_x_mtbf_data_rec.attribute7 := p9_a19;
    ddp_x_mtbf_data_rec.attribute8 := p9_a20;
    ddp_x_mtbf_data_rec.attribute9 := p9_a21;
    ddp_x_mtbf_data_rec.attribute10 := p9_a22;
    ddp_x_mtbf_data_rec.attribute11 := p9_a23;
    ddp_x_mtbf_data_rec.attribute12 := p9_a24;
    ddp_x_mtbf_data_rec.attribute13 := p9_a25;
    ddp_x_mtbf_data_rec.attribute14 := p9_a26;
    ddp_x_mtbf_data_rec.attribute15 := p9_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.update_mtbf_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_reliability_data_rec,
      ddp_x_mtbf_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_reliability_data_rec.ra_definition_hdr_id;
    p8_a1 := ddp_x_reliability_data_rec.mc_header_id;
    p8_a2 := ddp_x_reliability_data_rec.inventory_item_id;
    p8_a3 := ddp_x_reliability_data_rec.inventory_org_id;
    p8_a4 := ddp_x_reliability_data_rec.item_revision;
    p8_a5 := ddp_x_reliability_data_rec.relationship_id;
    p8_a6 := ddp_x_reliability_data_rec.operation_flag;
    p8_a7 := ddp_x_reliability_data_rec.object_version_number;
    p8_a8 := ddp_x_reliability_data_rec.security_group_id;
    p8_a9 := ddp_x_reliability_data_rec.creation_date;
    p8_a10 := ddp_x_reliability_data_rec.created_by;
    p8_a11 := ddp_x_reliability_data_rec.last_update_date;
    p8_a12 := ddp_x_reliability_data_rec.last_updated_by;
    p8_a13 := ddp_x_reliability_data_rec.last_update_login;
    p8_a14 := ddp_x_reliability_data_rec.attribute_category;
    p8_a15 := ddp_x_reliability_data_rec.attribute1;
    p8_a16 := ddp_x_reliability_data_rec.attribute2;
    p8_a17 := ddp_x_reliability_data_rec.attribute3;
    p8_a18 := ddp_x_reliability_data_rec.attribute4;
    p8_a19 := ddp_x_reliability_data_rec.attribute5;
    p8_a20 := ddp_x_reliability_data_rec.attribute6;
    p8_a21 := ddp_x_reliability_data_rec.attribute7;
    p8_a22 := ddp_x_reliability_data_rec.attribute8;
    p8_a23 := ddp_x_reliability_data_rec.attribute9;
    p8_a24 := ddp_x_reliability_data_rec.attribute10;
    p8_a25 := ddp_x_reliability_data_rec.attribute11;
    p8_a26 := ddp_x_reliability_data_rec.attribute12;
    p8_a27 := ddp_x_reliability_data_rec.attribute13;
    p8_a28 := ddp_x_reliability_data_rec.attribute14;
    p8_a29 := ddp_x_reliability_data_rec.attribute15;

    p9_a0 := ddp_x_mtbf_data_rec.ra_definition_dtl_id;
    p9_a1 := ddp_x_mtbf_data_rec.ra_definition_hdr_id;
    p9_a2 := ddp_x_mtbf_data_rec.counter_id;
    p9_a3 := ddp_x_mtbf_data_rec.mtbf_value;
    p9_a4 := ddp_x_mtbf_data_rec.operation_flag;
    p9_a5 := ddp_x_mtbf_data_rec.object_version_number;
    p9_a6 := ddp_x_mtbf_data_rec.security_group_id;
    p9_a7 := ddp_x_mtbf_data_rec.creation_date;
    p9_a8 := ddp_x_mtbf_data_rec.created_by;
    p9_a9 := ddp_x_mtbf_data_rec.last_update_date;
    p9_a10 := ddp_x_mtbf_data_rec.last_updated_by;
    p9_a11 := ddp_x_mtbf_data_rec.last_update_login;
    p9_a12 := ddp_x_mtbf_data_rec.attribute_category;
    p9_a13 := ddp_x_mtbf_data_rec.attribute1;
    p9_a14 := ddp_x_mtbf_data_rec.attribute2;
    p9_a15 := ddp_x_mtbf_data_rec.attribute3;
    p9_a16 := ddp_x_mtbf_data_rec.attribute4;
    p9_a17 := ddp_x_mtbf_data_rec.attribute5;
    p9_a18 := ddp_x_mtbf_data_rec.attribute6;
    p9_a19 := ddp_x_mtbf_data_rec.attribute7;
    p9_a20 := ddp_x_mtbf_data_rec.attribute8;
    p9_a21 := ddp_x_mtbf_data_rec.attribute9;
    p9_a22 := ddp_x_mtbf_data_rec.attribute10;
    p9_a23 := ddp_x_mtbf_data_rec.attribute11;
    p9_a24 := ddp_x_mtbf_data_rec.attribute12;
    p9_a25 := ddp_x_mtbf_data_rec.attribute13;
    p9_a26 := ddp_x_mtbf_data_rec.attribute14;
    p9_a27 := ddp_x_mtbf_data_rec.attribute15;
  end;

  procedure delete_mtbf_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  NUMBER
    , p9_a3  NUMBER
    , p9_a4  VARCHAR2
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  DATE
    , p9_a8  NUMBER
    , p9_a9  DATE
    , p9_a10  NUMBER
    , p9_a11  NUMBER
    , p9_a12  VARCHAR2
    , p9_a13  VARCHAR2
    , p9_a14  VARCHAR2
    , p9_a15  VARCHAR2
    , p9_a16  VARCHAR2
    , p9_a17  VARCHAR2
    , p9_a18  VARCHAR2
    , p9_a19  VARCHAR2
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  VARCHAR2
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  VARCHAR2
    , p9_a27  VARCHAR2
  )

  as
    ddp_x_reliability_data_rec ahl_ra_setups_pvt.ra_definition_hdr_rec_type;
    ddp_mtbf_data_rec ahl_ra_setups_pvt.ra_definition_dtls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_reliability_data_rec.ra_definition_hdr_id := p8_a0;
    ddp_x_reliability_data_rec.mc_header_id := p8_a1;
    ddp_x_reliability_data_rec.inventory_item_id := p8_a2;
    ddp_x_reliability_data_rec.inventory_org_id := p8_a3;
    ddp_x_reliability_data_rec.item_revision := p8_a4;
    ddp_x_reliability_data_rec.relationship_id := p8_a5;
    ddp_x_reliability_data_rec.operation_flag := p8_a6;
    ddp_x_reliability_data_rec.object_version_number := p8_a7;
    ddp_x_reliability_data_rec.security_group_id := p8_a8;
    ddp_x_reliability_data_rec.creation_date := p8_a9;
    ddp_x_reliability_data_rec.created_by := p8_a10;
    ddp_x_reliability_data_rec.last_update_date := p8_a11;
    ddp_x_reliability_data_rec.last_updated_by := p8_a12;
    ddp_x_reliability_data_rec.last_update_login := p8_a13;
    ddp_x_reliability_data_rec.attribute_category := p8_a14;
    ddp_x_reliability_data_rec.attribute1 := p8_a15;
    ddp_x_reliability_data_rec.attribute2 := p8_a16;
    ddp_x_reliability_data_rec.attribute3 := p8_a17;
    ddp_x_reliability_data_rec.attribute4 := p8_a18;
    ddp_x_reliability_data_rec.attribute5 := p8_a19;
    ddp_x_reliability_data_rec.attribute6 := p8_a20;
    ddp_x_reliability_data_rec.attribute7 := p8_a21;
    ddp_x_reliability_data_rec.attribute8 := p8_a22;
    ddp_x_reliability_data_rec.attribute9 := p8_a23;
    ddp_x_reliability_data_rec.attribute10 := p8_a24;
    ddp_x_reliability_data_rec.attribute11 := p8_a25;
    ddp_x_reliability_data_rec.attribute12 := p8_a26;
    ddp_x_reliability_data_rec.attribute13 := p8_a27;
    ddp_x_reliability_data_rec.attribute14 := p8_a28;
    ddp_x_reliability_data_rec.attribute15 := p8_a29;

    ddp_mtbf_data_rec.ra_definition_dtl_id := p9_a0;
    ddp_mtbf_data_rec.ra_definition_hdr_id := p9_a1;
    ddp_mtbf_data_rec.counter_id := p9_a2;
    ddp_mtbf_data_rec.mtbf_value := p9_a3;
    ddp_mtbf_data_rec.operation_flag := p9_a4;
    ddp_mtbf_data_rec.object_version_number := p9_a5;
    ddp_mtbf_data_rec.security_group_id := p9_a6;
    ddp_mtbf_data_rec.creation_date := p9_a7;
    ddp_mtbf_data_rec.created_by := p9_a8;
    ddp_mtbf_data_rec.last_update_date := p9_a9;
    ddp_mtbf_data_rec.last_updated_by := p9_a10;
    ddp_mtbf_data_rec.last_update_login := p9_a11;
    ddp_mtbf_data_rec.attribute_category := p9_a12;
    ddp_mtbf_data_rec.attribute1 := p9_a13;
    ddp_mtbf_data_rec.attribute2 := p9_a14;
    ddp_mtbf_data_rec.attribute3 := p9_a15;
    ddp_mtbf_data_rec.attribute4 := p9_a16;
    ddp_mtbf_data_rec.attribute5 := p9_a17;
    ddp_mtbf_data_rec.attribute6 := p9_a18;
    ddp_mtbf_data_rec.attribute7 := p9_a19;
    ddp_mtbf_data_rec.attribute8 := p9_a20;
    ddp_mtbf_data_rec.attribute9 := p9_a21;
    ddp_mtbf_data_rec.attribute10 := p9_a22;
    ddp_mtbf_data_rec.attribute11 := p9_a23;
    ddp_mtbf_data_rec.attribute12 := p9_a24;
    ddp_mtbf_data_rec.attribute13 := p9_a25;
    ddp_mtbf_data_rec.attribute14 := p9_a26;
    ddp_mtbf_data_rec.attribute15 := p9_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.delete_mtbf_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_reliability_data_rec,
      ddp_mtbf_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_reliability_data_rec.ra_definition_hdr_id;
    p8_a1 := ddp_x_reliability_data_rec.mc_header_id;
    p8_a2 := ddp_x_reliability_data_rec.inventory_item_id;
    p8_a3 := ddp_x_reliability_data_rec.inventory_org_id;
    p8_a4 := ddp_x_reliability_data_rec.item_revision;
    p8_a5 := ddp_x_reliability_data_rec.relationship_id;
    p8_a6 := ddp_x_reliability_data_rec.operation_flag;
    p8_a7 := ddp_x_reliability_data_rec.object_version_number;
    p8_a8 := ddp_x_reliability_data_rec.security_group_id;
    p8_a9 := ddp_x_reliability_data_rec.creation_date;
    p8_a10 := ddp_x_reliability_data_rec.created_by;
    p8_a11 := ddp_x_reliability_data_rec.last_update_date;
    p8_a12 := ddp_x_reliability_data_rec.last_updated_by;
    p8_a13 := ddp_x_reliability_data_rec.last_update_login;
    p8_a14 := ddp_x_reliability_data_rec.attribute_category;
    p8_a15 := ddp_x_reliability_data_rec.attribute1;
    p8_a16 := ddp_x_reliability_data_rec.attribute2;
    p8_a17 := ddp_x_reliability_data_rec.attribute3;
    p8_a18 := ddp_x_reliability_data_rec.attribute4;
    p8_a19 := ddp_x_reliability_data_rec.attribute5;
    p8_a20 := ddp_x_reliability_data_rec.attribute6;
    p8_a21 := ddp_x_reliability_data_rec.attribute7;
    p8_a22 := ddp_x_reliability_data_rec.attribute8;
    p8_a23 := ddp_x_reliability_data_rec.attribute9;
    p8_a24 := ddp_x_reliability_data_rec.attribute10;
    p8_a25 := ddp_x_reliability_data_rec.attribute11;
    p8_a26 := ddp_x_reliability_data_rec.attribute12;
    p8_a27 := ddp_x_reliability_data_rec.attribute13;
    p8_a28 := ddp_x_reliability_data_rec.attribute14;
    p8_a29 := ddp_x_reliability_data_rec.attribute15;

  end;

  procedure create_counter_assoc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  DATE
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  NUMBER
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
  )

  as
    ddp_x_counter_assoc_rec ahl_ra_setups_pvt.ra_counter_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_counter_assoc_rec.ra_counter_association_id := p8_a0;
    ddp_x_counter_assoc_rec.since_new_counter_id := p8_a1;
    ddp_x_counter_assoc_rec.since_overhaul_counter_id := p8_a2;
    ddp_x_counter_assoc_rec.description := p8_a3;
    ddp_x_counter_assoc_rec.operation_flag := p8_a4;
    ddp_x_counter_assoc_rec.object_version_number := p8_a5;
    ddp_x_counter_assoc_rec.security_group_id := p8_a6;
    ddp_x_counter_assoc_rec.creation_date := p8_a7;
    ddp_x_counter_assoc_rec.created_by := p8_a8;
    ddp_x_counter_assoc_rec.last_update_date := p8_a9;
    ddp_x_counter_assoc_rec.last_updated_by := p8_a10;
    ddp_x_counter_assoc_rec.last_update_login := p8_a11;
    ddp_x_counter_assoc_rec.attribute_category := p8_a12;
    ddp_x_counter_assoc_rec.attribute1 := p8_a13;
    ddp_x_counter_assoc_rec.attribute2 := p8_a14;
    ddp_x_counter_assoc_rec.attribute3 := p8_a15;
    ddp_x_counter_assoc_rec.attribute4 := p8_a16;
    ddp_x_counter_assoc_rec.attribute5 := p8_a17;
    ddp_x_counter_assoc_rec.attribute6 := p8_a18;
    ddp_x_counter_assoc_rec.attribute7 := p8_a19;
    ddp_x_counter_assoc_rec.attribute8 := p8_a20;
    ddp_x_counter_assoc_rec.attribute9 := p8_a21;
    ddp_x_counter_assoc_rec.attribute10 := p8_a22;
    ddp_x_counter_assoc_rec.attribute11 := p8_a23;
    ddp_x_counter_assoc_rec.attribute12 := p8_a24;
    ddp_x_counter_assoc_rec.attribute13 := p8_a25;
    ddp_x_counter_assoc_rec.attribute14 := p8_a26;
    ddp_x_counter_assoc_rec.attribute15 := p8_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.create_counter_assoc(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_counter_assoc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_counter_assoc_rec.ra_counter_association_id;
    p8_a1 := ddp_x_counter_assoc_rec.since_new_counter_id;
    p8_a2 := ddp_x_counter_assoc_rec.since_overhaul_counter_id;
    p8_a3 := ddp_x_counter_assoc_rec.description;
    p8_a4 := ddp_x_counter_assoc_rec.operation_flag;
    p8_a5 := ddp_x_counter_assoc_rec.object_version_number;
    p8_a6 := ddp_x_counter_assoc_rec.security_group_id;
    p8_a7 := ddp_x_counter_assoc_rec.creation_date;
    p8_a8 := ddp_x_counter_assoc_rec.created_by;
    p8_a9 := ddp_x_counter_assoc_rec.last_update_date;
    p8_a10 := ddp_x_counter_assoc_rec.last_updated_by;
    p8_a11 := ddp_x_counter_assoc_rec.last_update_login;
    p8_a12 := ddp_x_counter_assoc_rec.attribute_category;
    p8_a13 := ddp_x_counter_assoc_rec.attribute1;
    p8_a14 := ddp_x_counter_assoc_rec.attribute2;
    p8_a15 := ddp_x_counter_assoc_rec.attribute3;
    p8_a16 := ddp_x_counter_assoc_rec.attribute4;
    p8_a17 := ddp_x_counter_assoc_rec.attribute5;
    p8_a18 := ddp_x_counter_assoc_rec.attribute6;
    p8_a19 := ddp_x_counter_assoc_rec.attribute7;
    p8_a20 := ddp_x_counter_assoc_rec.attribute8;
    p8_a21 := ddp_x_counter_assoc_rec.attribute9;
    p8_a22 := ddp_x_counter_assoc_rec.attribute10;
    p8_a23 := ddp_x_counter_assoc_rec.attribute11;
    p8_a24 := ddp_x_counter_assoc_rec.attribute12;
    p8_a25 := ddp_x_counter_assoc_rec.attribute13;
    p8_a26 := ddp_x_counter_assoc_rec.attribute14;
    p8_a27 := ddp_x_counter_assoc_rec.attribute15;
  end;

  procedure delete_counter_assoc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  DATE
    , p8_a8  NUMBER
    , p8_a9  DATE
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
  )

  as
    ddp_counter_assoc_rec ahl_ra_setups_pvt.ra_counter_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_counter_assoc_rec.ra_counter_association_id := p8_a0;
    ddp_counter_assoc_rec.since_new_counter_id := p8_a1;
    ddp_counter_assoc_rec.since_overhaul_counter_id := p8_a2;
    ddp_counter_assoc_rec.description := p8_a3;
    ddp_counter_assoc_rec.operation_flag := p8_a4;
    ddp_counter_assoc_rec.object_version_number := p8_a5;
    ddp_counter_assoc_rec.security_group_id := p8_a6;
    ddp_counter_assoc_rec.creation_date := p8_a7;
    ddp_counter_assoc_rec.created_by := p8_a8;
    ddp_counter_assoc_rec.last_update_date := p8_a9;
    ddp_counter_assoc_rec.last_updated_by := p8_a10;
    ddp_counter_assoc_rec.last_update_login := p8_a11;
    ddp_counter_assoc_rec.attribute_category := p8_a12;
    ddp_counter_assoc_rec.attribute1 := p8_a13;
    ddp_counter_assoc_rec.attribute2 := p8_a14;
    ddp_counter_assoc_rec.attribute3 := p8_a15;
    ddp_counter_assoc_rec.attribute4 := p8_a16;
    ddp_counter_assoc_rec.attribute5 := p8_a17;
    ddp_counter_assoc_rec.attribute6 := p8_a18;
    ddp_counter_assoc_rec.attribute7 := p8_a19;
    ddp_counter_assoc_rec.attribute8 := p8_a20;
    ddp_counter_assoc_rec.attribute9 := p8_a21;
    ddp_counter_assoc_rec.attribute10 := p8_a22;
    ddp_counter_assoc_rec.attribute11 := p8_a23;
    ddp_counter_assoc_rec.attribute12 := p8_a24;
    ddp_counter_assoc_rec.attribute13 := p8_a25;
    ddp_counter_assoc_rec.attribute14 := p8_a26;
    ddp_counter_assoc_rec.attribute15 := p8_a27;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.delete_counter_assoc(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_counter_assoc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_fct_assoc_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
  )

  as
    ddp_x_fct_assoc_rec ahl_ra_setups_pvt.ra_fct_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_fct_assoc_rec.ra_fct_association_id := p8_a0;
    ddp_x_fct_assoc_rec.forecast_designator := p8_a1;
    ddp_x_fct_assoc_rec.association_type_code := p8_a2;
    ddp_x_fct_assoc_rec.organization_id := p8_a3;
    ddp_x_fct_assoc_rec.probability_from := p8_a4;
    ddp_x_fct_assoc_rec.probability_to := p8_a5;
    ddp_x_fct_assoc_rec.operation_flag := p8_a6;
    ddp_x_fct_assoc_rec.object_version_number := p8_a7;
    ddp_x_fct_assoc_rec.security_group_id := p8_a8;
    ddp_x_fct_assoc_rec.creation_date := p8_a9;
    ddp_x_fct_assoc_rec.created_by := p8_a10;
    ddp_x_fct_assoc_rec.last_update_date := p8_a11;
    ddp_x_fct_assoc_rec.last_updated_by := p8_a12;
    ddp_x_fct_assoc_rec.last_update_login := p8_a13;
    ddp_x_fct_assoc_rec.attribute_category := p8_a14;
    ddp_x_fct_assoc_rec.attribute1 := p8_a15;
    ddp_x_fct_assoc_rec.attribute2 := p8_a16;
    ddp_x_fct_assoc_rec.attribute3 := p8_a17;
    ddp_x_fct_assoc_rec.attribute4 := p8_a18;
    ddp_x_fct_assoc_rec.attribute5 := p8_a19;
    ddp_x_fct_assoc_rec.attribute6 := p8_a20;
    ddp_x_fct_assoc_rec.attribute7 := p8_a21;
    ddp_x_fct_assoc_rec.attribute8 := p8_a22;
    ddp_x_fct_assoc_rec.attribute9 := p8_a23;
    ddp_x_fct_assoc_rec.attribute10 := p8_a24;
    ddp_x_fct_assoc_rec.attribute11 := p8_a25;
    ddp_x_fct_assoc_rec.attribute12 := p8_a26;
    ddp_x_fct_assoc_rec.attribute13 := p8_a27;
    ddp_x_fct_assoc_rec.attribute14 := p8_a28;
    ddp_x_fct_assoc_rec.attribute15 := p8_a29;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.create_fct_assoc_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_fct_assoc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_fct_assoc_rec.ra_fct_association_id;
    p8_a1 := ddp_x_fct_assoc_rec.forecast_designator;
    p8_a2 := ddp_x_fct_assoc_rec.association_type_code;
    p8_a3 := ddp_x_fct_assoc_rec.organization_id;
    p8_a4 := ddp_x_fct_assoc_rec.probability_from;
    p8_a5 := ddp_x_fct_assoc_rec.probability_to;
    p8_a6 := ddp_x_fct_assoc_rec.operation_flag;
    p8_a7 := ddp_x_fct_assoc_rec.object_version_number;
    p8_a8 := ddp_x_fct_assoc_rec.security_group_id;
    p8_a9 := ddp_x_fct_assoc_rec.creation_date;
    p8_a10 := ddp_x_fct_assoc_rec.created_by;
    p8_a11 := ddp_x_fct_assoc_rec.last_update_date;
    p8_a12 := ddp_x_fct_assoc_rec.last_updated_by;
    p8_a13 := ddp_x_fct_assoc_rec.last_update_login;
    p8_a14 := ddp_x_fct_assoc_rec.attribute_category;
    p8_a15 := ddp_x_fct_assoc_rec.attribute1;
    p8_a16 := ddp_x_fct_assoc_rec.attribute2;
    p8_a17 := ddp_x_fct_assoc_rec.attribute3;
    p8_a18 := ddp_x_fct_assoc_rec.attribute4;
    p8_a19 := ddp_x_fct_assoc_rec.attribute5;
    p8_a20 := ddp_x_fct_assoc_rec.attribute6;
    p8_a21 := ddp_x_fct_assoc_rec.attribute7;
    p8_a22 := ddp_x_fct_assoc_rec.attribute8;
    p8_a23 := ddp_x_fct_assoc_rec.attribute9;
    p8_a24 := ddp_x_fct_assoc_rec.attribute10;
    p8_a25 := ddp_x_fct_assoc_rec.attribute11;
    p8_a26 := ddp_x_fct_assoc_rec.attribute12;
    p8_a27 := ddp_x_fct_assoc_rec.attribute13;
    p8_a28 := ddp_x_fct_assoc_rec.attribute14;
    p8_a29 := ddp_x_fct_assoc_rec.attribute15;
  end;

  procedure update_fct_assoc_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  DATE
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  NUMBER
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
  )

  as
    ddp_x_fct_assoc_rec ahl_ra_setups_pvt.ra_fct_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_fct_assoc_rec.ra_fct_association_id := p8_a0;
    ddp_x_fct_assoc_rec.forecast_designator := p8_a1;
    ddp_x_fct_assoc_rec.association_type_code := p8_a2;
    ddp_x_fct_assoc_rec.organization_id := p8_a3;
    ddp_x_fct_assoc_rec.probability_from := p8_a4;
    ddp_x_fct_assoc_rec.probability_to := p8_a5;
    ddp_x_fct_assoc_rec.operation_flag := p8_a6;
    ddp_x_fct_assoc_rec.object_version_number := p8_a7;
    ddp_x_fct_assoc_rec.security_group_id := p8_a8;
    ddp_x_fct_assoc_rec.creation_date := p8_a9;
    ddp_x_fct_assoc_rec.created_by := p8_a10;
    ddp_x_fct_assoc_rec.last_update_date := p8_a11;
    ddp_x_fct_assoc_rec.last_updated_by := p8_a12;
    ddp_x_fct_assoc_rec.last_update_login := p8_a13;
    ddp_x_fct_assoc_rec.attribute_category := p8_a14;
    ddp_x_fct_assoc_rec.attribute1 := p8_a15;
    ddp_x_fct_assoc_rec.attribute2 := p8_a16;
    ddp_x_fct_assoc_rec.attribute3 := p8_a17;
    ddp_x_fct_assoc_rec.attribute4 := p8_a18;
    ddp_x_fct_assoc_rec.attribute5 := p8_a19;
    ddp_x_fct_assoc_rec.attribute6 := p8_a20;
    ddp_x_fct_assoc_rec.attribute7 := p8_a21;
    ddp_x_fct_assoc_rec.attribute8 := p8_a22;
    ddp_x_fct_assoc_rec.attribute9 := p8_a23;
    ddp_x_fct_assoc_rec.attribute10 := p8_a24;
    ddp_x_fct_assoc_rec.attribute11 := p8_a25;
    ddp_x_fct_assoc_rec.attribute12 := p8_a26;
    ddp_x_fct_assoc_rec.attribute13 := p8_a27;
    ddp_x_fct_assoc_rec.attribute14 := p8_a28;
    ddp_x_fct_assoc_rec.attribute15 := p8_a29;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.update_fct_assoc_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_fct_assoc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_fct_assoc_rec.ra_fct_association_id;
    p8_a1 := ddp_x_fct_assoc_rec.forecast_designator;
    p8_a2 := ddp_x_fct_assoc_rec.association_type_code;
    p8_a3 := ddp_x_fct_assoc_rec.organization_id;
    p8_a4 := ddp_x_fct_assoc_rec.probability_from;
    p8_a5 := ddp_x_fct_assoc_rec.probability_to;
    p8_a6 := ddp_x_fct_assoc_rec.operation_flag;
    p8_a7 := ddp_x_fct_assoc_rec.object_version_number;
    p8_a8 := ddp_x_fct_assoc_rec.security_group_id;
    p8_a9 := ddp_x_fct_assoc_rec.creation_date;
    p8_a10 := ddp_x_fct_assoc_rec.created_by;
    p8_a11 := ddp_x_fct_assoc_rec.last_update_date;
    p8_a12 := ddp_x_fct_assoc_rec.last_updated_by;
    p8_a13 := ddp_x_fct_assoc_rec.last_update_login;
    p8_a14 := ddp_x_fct_assoc_rec.attribute_category;
    p8_a15 := ddp_x_fct_assoc_rec.attribute1;
    p8_a16 := ddp_x_fct_assoc_rec.attribute2;
    p8_a17 := ddp_x_fct_assoc_rec.attribute3;
    p8_a18 := ddp_x_fct_assoc_rec.attribute4;
    p8_a19 := ddp_x_fct_assoc_rec.attribute5;
    p8_a20 := ddp_x_fct_assoc_rec.attribute6;
    p8_a21 := ddp_x_fct_assoc_rec.attribute7;
    p8_a22 := ddp_x_fct_assoc_rec.attribute8;
    p8_a23 := ddp_x_fct_assoc_rec.attribute9;
    p8_a24 := ddp_x_fct_assoc_rec.attribute10;
    p8_a25 := ddp_x_fct_assoc_rec.attribute11;
    p8_a26 := ddp_x_fct_assoc_rec.attribute12;
    p8_a27 := ddp_x_fct_assoc_rec.attribute13;
    p8_a28 := ddp_x_fct_assoc_rec.attribute14;
    p8_a29 := ddp_x_fct_assoc_rec.attribute15;
  end;

  procedure delete_fct_assoc_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  DATE
    , p8_a10  NUMBER
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
  )

  as
    ddp_fct_assoc_rec ahl_ra_setups_pvt.ra_fct_assoc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_fct_assoc_rec.ra_fct_association_id := p8_a0;
    ddp_fct_assoc_rec.forecast_designator := p8_a1;
    ddp_fct_assoc_rec.association_type_code := p8_a2;
    ddp_fct_assoc_rec.organization_id := p8_a3;
    ddp_fct_assoc_rec.probability_from := p8_a4;
    ddp_fct_assoc_rec.probability_to := p8_a5;
    ddp_fct_assoc_rec.operation_flag := p8_a6;
    ddp_fct_assoc_rec.object_version_number := p8_a7;
    ddp_fct_assoc_rec.security_group_id := p8_a8;
    ddp_fct_assoc_rec.creation_date := p8_a9;
    ddp_fct_assoc_rec.created_by := p8_a10;
    ddp_fct_assoc_rec.last_update_date := p8_a11;
    ddp_fct_assoc_rec.last_updated_by := p8_a12;
    ddp_fct_assoc_rec.last_update_login := p8_a13;
    ddp_fct_assoc_rec.attribute_category := p8_a14;
    ddp_fct_assoc_rec.attribute1 := p8_a15;
    ddp_fct_assoc_rec.attribute2 := p8_a16;
    ddp_fct_assoc_rec.attribute3 := p8_a17;
    ddp_fct_assoc_rec.attribute4 := p8_a18;
    ddp_fct_assoc_rec.attribute5 := p8_a19;
    ddp_fct_assoc_rec.attribute6 := p8_a20;
    ddp_fct_assoc_rec.attribute7 := p8_a21;
    ddp_fct_assoc_rec.attribute8 := p8_a22;
    ddp_fct_assoc_rec.attribute9 := p8_a23;
    ddp_fct_assoc_rec.attribute10 := p8_a24;
    ddp_fct_assoc_rec.attribute11 := p8_a25;
    ddp_fct_assoc_rec.attribute12 := p8_a26;
    ddp_fct_assoc_rec.attribute13 := p8_a27;
    ddp_fct_assoc_rec.attribute14 := p8_a28;
    ddp_fct_assoc_rec.attribute15 := p8_a29;

    -- here's the delegated call to the old PL/SQL routine
    ahl_ra_setups_pvt.delete_fct_assoc_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fct_assoc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ahl_ra_setups_pvt_w;

/
