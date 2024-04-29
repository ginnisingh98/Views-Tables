--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_REVISION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_REVISION_PUB_W" as
  /* $Header: amswrevb.pls 115.5 2002/11/11 22:08:09 abhola ship $ */
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

  procedure create_item_revision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  DATE := fnd_api.g_miss_date
    , p7_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_item_revision_rec ams_item_revision_pub.item_revision_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_item_revision_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a0);
    ddp_item_revision_rec.organization_id := rosetta_g_miss_num_map(p7_a1);
    ddp_item_revision_rec.revision := p7_a2;
    ddp_item_revision_rec.description := p7_a3;
    ddp_item_revision_rec.change_notice := p7_a4;
    ddp_item_revision_rec.ecn_initiation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_item_revision_rec.implementation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_item_revision_rec.effectivity_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_item_revision_rec.revised_item_sequence_id := rosetta_g_miss_num_map(p7_a8);
    ddp_item_revision_rec.attribute_category := p7_a9;
    ddp_item_revision_rec.attribute1 := p7_a10;
    ddp_item_revision_rec.attribute2 := p7_a11;
    ddp_item_revision_rec.attribute3 := p7_a12;
    ddp_item_revision_rec.attribute4 := p7_a13;
    ddp_item_revision_rec.attribute5 := p7_a14;
    ddp_item_revision_rec.attribute6 := p7_a15;
    ddp_item_revision_rec.attribute7 := p7_a16;
    ddp_item_revision_rec.attribute8 := p7_a17;
    ddp_item_revision_rec.attribute9 := p7_a18;
    ddp_item_revision_rec.attribute10 := p7_a19;
    ddp_item_revision_rec.attribute11 := p7_a20;
    ddp_item_revision_rec.attribute12 := p7_a21;
    ddp_item_revision_rec.attribute13 := p7_a22;
    ddp_item_revision_rec.attribute14 := p7_a23;
    ddp_item_revision_rec.attribute15 := p7_a24;
    ddp_item_revision_rec.creation_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_item_revision_rec.created_by := rosetta_g_miss_num_map(p7_a26);
    ddp_item_revision_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_item_revision_rec.last_updated_by := rosetta_g_miss_num_map(p7_a28);
    ddp_item_revision_rec.last_update_login := rosetta_g_miss_num_map(p7_a29);
    ddp_item_revision_rec.request_id := rosetta_g_miss_num_map(p7_a30);
    ddp_item_revision_rec.program_application_id := rosetta_g_miss_num_map(p7_a31);
    ddp_item_revision_rec.program_id := rosetta_g_miss_num_map(p7_a32);
    ddp_item_revision_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a33);
    ddp_item_revision_rec.object_version_number := rosetta_g_miss_num_map(p7_a34);

    -- here's the delegated call to the old PL/SQL routine
    ams_item_revision_pub.create_item_revision(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_revision_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure update_item_revision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  DATE := fnd_api.g_miss_date
    , p7_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_item_revision_rec ams_item_revision_pub.item_revision_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_item_revision_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a0);
    ddp_item_revision_rec.organization_id := rosetta_g_miss_num_map(p7_a1);
    ddp_item_revision_rec.revision := p7_a2;
    ddp_item_revision_rec.description := p7_a3;
    ddp_item_revision_rec.change_notice := p7_a4;
    ddp_item_revision_rec.ecn_initiation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_item_revision_rec.implementation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_item_revision_rec.effectivity_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_item_revision_rec.revised_item_sequence_id := rosetta_g_miss_num_map(p7_a8);
    ddp_item_revision_rec.attribute_category := p7_a9;
    ddp_item_revision_rec.attribute1 := p7_a10;
    ddp_item_revision_rec.attribute2 := p7_a11;
    ddp_item_revision_rec.attribute3 := p7_a12;
    ddp_item_revision_rec.attribute4 := p7_a13;
    ddp_item_revision_rec.attribute5 := p7_a14;
    ddp_item_revision_rec.attribute6 := p7_a15;
    ddp_item_revision_rec.attribute7 := p7_a16;
    ddp_item_revision_rec.attribute8 := p7_a17;
    ddp_item_revision_rec.attribute9 := p7_a18;
    ddp_item_revision_rec.attribute10 := p7_a19;
    ddp_item_revision_rec.attribute11 := p7_a20;
    ddp_item_revision_rec.attribute12 := p7_a21;
    ddp_item_revision_rec.attribute13 := p7_a22;
    ddp_item_revision_rec.attribute14 := p7_a23;
    ddp_item_revision_rec.attribute15 := p7_a24;
    ddp_item_revision_rec.creation_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_item_revision_rec.created_by := rosetta_g_miss_num_map(p7_a26);
    ddp_item_revision_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_item_revision_rec.last_updated_by := rosetta_g_miss_num_map(p7_a28);
    ddp_item_revision_rec.last_update_login := rosetta_g_miss_num_map(p7_a29);
    ddp_item_revision_rec.request_id := rosetta_g_miss_num_map(p7_a30);
    ddp_item_revision_rec.program_application_id := rosetta_g_miss_num_map(p7_a31);
    ddp_item_revision_rec.program_id := rosetta_g_miss_num_map(p7_a32);
    ddp_item_revision_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a33);
    ddp_item_revision_rec.object_version_number := rosetta_g_miss_num_map(p7_a34);

    -- here's the delegated call to the old PL/SQL routine
    ams_item_revision_pub.update_item_revision(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_revision_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

end ams_item_revision_pub_w;

/
