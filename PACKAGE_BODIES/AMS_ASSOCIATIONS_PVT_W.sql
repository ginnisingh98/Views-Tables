--------------------------------------------------------
--  DDL for Package Body AMS_ASSOCIATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ASSOCIATIONS_PVT_W" as
  /* $Header: amswassb.pls 120.1 2005/06/15 11:44 appldev  $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure create_association(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_association_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_association_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_association_rec.object_association_id := rosetta_g_miss_num_map(p7_a0);
    ddp_association_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_association_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_association_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_association_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_association_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_association_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_association_rec.master_object_type := p7_a7;
    ddp_association_rec.master_object_id := rosetta_g_miss_num_map(p7_a8);
    ddp_association_rec.using_object_type := p7_a9;
    ddp_association_rec.using_object_id := rosetta_g_miss_num_map(p7_a10);
    ddp_association_rec.primary_flag := p7_a11;
    ddp_association_rec.usage_type := p7_a12;
    ddp_association_rec.quantity_needed := rosetta_g_miss_num_map(p7_a13);
    ddp_association_rec.quantity_needed_by_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_association_rec.cost_frozen_flag := p7_a15;
    ddp_association_rec.pct_of_cost_to_charge_used_by := rosetta_g_miss_num_map(p7_a16);
    ddp_association_rec.max_cost_to_charge_used_by := rosetta_g_miss_num_map(p7_a17);
    ddp_association_rec.max_cost_currency_code := p7_a18;
    ddp_association_rec.metric_class := p7_a19;
    ddp_association_rec.fulfill_on_type_code := p7_a20;
    ddp_association_rec.attribute_category := p7_a21;
    ddp_association_rec.attribute1 := p7_a22;
    ddp_association_rec.attribute2 := p7_a23;
    ddp_association_rec.attribute3 := p7_a24;
    ddp_association_rec.attribute4 := p7_a25;
    ddp_association_rec.attribute5 := p7_a26;
    ddp_association_rec.attribute6 := p7_a27;
    ddp_association_rec.attribute7 := p7_a28;
    ddp_association_rec.attribute8 := p7_a29;
    ddp_association_rec.attribute9 := p7_a30;
    ddp_association_rec.attribute10 := p7_a31;
    ddp_association_rec.attribute11 := p7_a32;
    ddp_association_rec.attribute12 := p7_a33;
    ddp_association_rec.attribute13 := p7_a34;
    ddp_association_rec.attribute14 := p7_a35;
    ddp_association_rec.attribute15 := p7_a36;
    ddp_association_rec.content_type := p7_a37;
    ddp_association_rec.sequence_no := rosetta_g_miss_num_map(p7_a38);


    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.create_association(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_association_rec,
      x_object_association_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_association(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_association_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_association_rec.object_association_id := rosetta_g_miss_num_map(p7_a0);
    ddp_association_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_association_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_association_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_association_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_association_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_association_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_association_rec.master_object_type := p7_a7;
    ddp_association_rec.master_object_id := rosetta_g_miss_num_map(p7_a8);
    ddp_association_rec.using_object_type := p7_a9;
    ddp_association_rec.using_object_id := rosetta_g_miss_num_map(p7_a10);
    ddp_association_rec.primary_flag := p7_a11;
    ddp_association_rec.usage_type := p7_a12;
    ddp_association_rec.quantity_needed := rosetta_g_miss_num_map(p7_a13);
    ddp_association_rec.quantity_needed_by_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_association_rec.cost_frozen_flag := p7_a15;
    ddp_association_rec.pct_of_cost_to_charge_used_by := rosetta_g_miss_num_map(p7_a16);
    ddp_association_rec.max_cost_to_charge_used_by := rosetta_g_miss_num_map(p7_a17);
    ddp_association_rec.max_cost_currency_code := p7_a18;
    ddp_association_rec.metric_class := p7_a19;
    ddp_association_rec.fulfill_on_type_code := p7_a20;
    ddp_association_rec.attribute_category := p7_a21;
    ddp_association_rec.attribute1 := p7_a22;
    ddp_association_rec.attribute2 := p7_a23;
    ddp_association_rec.attribute3 := p7_a24;
    ddp_association_rec.attribute4 := p7_a25;
    ddp_association_rec.attribute5 := p7_a26;
    ddp_association_rec.attribute6 := p7_a27;
    ddp_association_rec.attribute7 := p7_a28;
    ddp_association_rec.attribute8 := p7_a29;
    ddp_association_rec.attribute9 := p7_a30;
    ddp_association_rec.attribute10 := p7_a31;
    ddp_association_rec.attribute11 := p7_a32;
    ddp_association_rec.attribute12 := p7_a33;
    ddp_association_rec.attribute13 := p7_a34;
    ddp_association_rec.attribute14 := p7_a35;
    ddp_association_rec.attribute15 := p7_a36;
    ddp_association_rec.content_type := p7_a37;
    ddp_association_rec.sequence_no := rosetta_g_miss_num_map(p7_a38);

    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.update_association(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_association_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_association(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_association_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_association_rec.object_association_id := rosetta_g_miss_num_map(p6_a0);
    ddp_association_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_association_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_association_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_association_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_association_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_association_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_association_rec.master_object_type := p6_a7;
    ddp_association_rec.master_object_id := rosetta_g_miss_num_map(p6_a8);
    ddp_association_rec.using_object_type := p6_a9;
    ddp_association_rec.using_object_id := rosetta_g_miss_num_map(p6_a10);
    ddp_association_rec.primary_flag := p6_a11;
    ddp_association_rec.usage_type := p6_a12;
    ddp_association_rec.quantity_needed := rosetta_g_miss_num_map(p6_a13);
    ddp_association_rec.quantity_needed_by_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_association_rec.cost_frozen_flag := p6_a15;
    ddp_association_rec.pct_of_cost_to_charge_used_by := rosetta_g_miss_num_map(p6_a16);
    ddp_association_rec.max_cost_to_charge_used_by := rosetta_g_miss_num_map(p6_a17);
    ddp_association_rec.max_cost_currency_code := p6_a18;
    ddp_association_rec.metric_class := p6_a19;
    ddp_association_rec.fulfill_on_type_code := p6_a20;
    ddp_association_rec.attribute_category := p6_a21;
    ddp_association_rec.attribute1 := p6_a22;
    ddp_association_rec.attribute2 := p6_a23;
    ddp_association_rec.attribute3 := p6_a24;
    ddp_association_rec.attribute4 := p6_a25;
    ddp_association_rec.attribute5 := p6_a26;
    ddp_association_rec.attribute6 := p6_a27;
    ddp_association_rec.attribute7 := p6_a28;
    ddp_association_rec.attribute8 := p6_a29;
    ddp_association_rec.attribute9 := p6_a30;
    ddp_association_rec.attribute10 := p6_a31;
    ddp_association_rec.attribute11 := p6_a32;
    ddp_association_rec.attribute12 := p6_a33;
    ddp_association_rec.attribute13 := p6_a34;
    ddp_association_rec.attribute14 := p6_a35;
    ddp_association_rec.attribute15 := p6_a36;
    ddp_association_rec.content_type := p6_a37;
    ddp_association_rec.sequence_no := rosetta_g_miss_num_map(p6_a38);

    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.validate_association(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_association_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_association_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_association_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_association_rec.object_association_id := rosetta_g_miss_num_map(p0_a0);
    ddp_association_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_association_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_association_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_association_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_association_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_association_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_association_rec.master_object_type := p0_a7;
    ddp_association_rec.master_object_id := rosetta_g_miss_num_map(p0_a8);
    ddp_association_rec.using_object_type := p0_a9;
    ddp_association_rec.using_object_id := rosetta_g_miss_num_map(p0_a10);
    ddp_association_rec.primary_flag := p0_a11;
    ddp_association_rec.usage_type := p0_a12;
    ddp_association_rec.quantity_needed := rosetta_g_miss_num_map(p0_a13);
    ddp_association_rec.quantity_needed_by_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_association_rec.cost_frozen_flag := p0_a15;
    ddp_association_rec.pct_of_cost_to_charge_used_by := rosetta_g_miss_num_map(p0_a16);
    ddp_association_rec.max_cost_to_charge_used_by := rosetta_g_miss_num_map(p0_a17);
    ddp_association_rec.max_cost_currency_code := p0_a18;
    ddp_association_rec.metric_class := p0_a19;
    ddp_association_rec.fulfill_on_type_code := p0_a20;
    ddp_association_rec.attribute_category := p0_a21;
    ddp_association_rec.attribute1 := p0_a22;
    ddp_association_rec.attribute2 := p0_a23;
    ddp_association_rec.attribute3 := p0_a24;
    ddp_association_rec.attribute4 := p0_a25;
    ddp_association_rec.attribute5 := p0_a26;
    ddp_association_rec.attribute6 := p0_a27;
    ddp_association_rec.attribute7 := p0_a28;
    ddp_association_rec.attribute8 := p0_a29;
    ddp_association_rec.attribute9 := p0_a30;
    ddp_association_rec.attribute10 := p0_a31;
    ddp_association_rec.attribute11 := p0_a32;
    ddp_association_rec.attribute12 := p0_a33;
    ddp_association_rec.attribute13 := p0_a34;
    ddp_association_rec.attribute14 := p0_a35;
    ddp_association_rec.attribute15 := p0_a36;
    ddp_association_rec.content_type := p0_a37;
    ddp_association_rec.sequence_no := rosetta_g_miss_num_map(p0_a38);



    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.check_association_items(ddp_association_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_association_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_association_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_association_rec.object_association_id := rosetta_g_miss_num_map(p0_a0);
    ddp_association_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_association_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_association_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_association_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_association_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_association_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_association_rec.master_object_type := p0_a7;
    ddp_association_rec.master_object_id := rosetta_g_miss_num_map(p0_a8);
    ddp_association_rec.using_object_type := p0_a9;
    ddp_association_rec.using_object_id := rosetta_g_miss_num_map(p0_a10);
    ddp_association_rec.primary_flag := p0_a11;
    ddp_association_rec.usage_type := p0_a12;
    ddp_association_rec.quantity_needed := rosetta_g_miss_num_map(p0_a13);
    ddp_association_rec.quantity_needed_by_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_association_rec.cost_frozen_flag := p0_a15;
    ddp_association_rec.pct_of_cost_to_charge_used_by := rosetta_g_miss_num_map(p0_a16);
    ddp_association_rec.max_cost_to_charge_used_by := rosetta_g_miss_num_map(p0_a17);
    ddp_association_rec.max_cost_currency_code := p0_a18;
    ddp_association_rec.metric_class := p0_a19;
    ddp_association_rec.fulfill_on_type_code := p0_a20;
    ddp_association_rec.attribute_category := p0_a21;
    ddp_association_rec.attribute1 := p0_a22;
    ddp_association_rec.attribute2 := p0_a23;
    ddp_association_rec.attribute3 := p0_a24;
    ddp_association_rec.attribute4 := p0_a25;
    ddp_association_rec.attribute5 := p0_a26;
    ddp_association_rec.attribute6 := p0_a27;
    ddp_association_rec.attribute7 := p0_a28;
    ddp_association_rec.attribute8 := p0_a29;
    ddp_association_rec.attribute9 := p0_a30;
    ddp_association_rec.attribute10 := p0_a31;
    ddp_association_rec.attribute11 := p0_a32;
    ddp_association_rec.attribute12 := p0_a33;
    ddp_association_rec.attribute13 := p0_a34;
    ddp_association_rec.attribute14 := p0_a35;
    ddp_association_rec.attribute15 := p0_a36;
    ddp_association_rec.content_type := p0_a37;
    ddp_association_rec.sequence_no := rosetta_g_miss_num_map(p0_a38);


    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.check_association_record(ddp_association_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure complete_association_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_association_rec ams_associations_pvt.association_rec_type;
    ddx_complete_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_association_rec.object_association_id := rosetta_g_miss_num_map(p0_a0);
    ddp_association_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_association_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_association_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_association_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_association_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_association_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_association_rec.master_object_type := p0_a7;
    ddp_association_rec.master_object_id := rosetta_g_miss_num_map(p0_a8);
    ddp_association_rec.using_object_type := p0_a9;
    ddp_association_rec.using_object_id := rosetta_g_miss_num_map(p0_a10);
    ddp_association_rec.primary_flag := p0_a11;
    ddp_association_rec.usage_type := p0_a12;
    ddp_association_rec.quantity_needed := rosetta_g_miss_num_map(p0_a13);
    ddp_association_rec.quantity_needed_by_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_association_rec.cost_frozen_flag := p0_a15;
    ddp_association_rec.pct_of_cost_to_charge_used_by := rosetta_g_miss_num_map(p0_a16);
    ddp_association_rec.max_cost_to_charge_used_by := rosetta_g_miss_num_map(p0_a17);
    ddp_association_rec.max_cost_currency_code := p0_a18;
    ddp_association_rec.metric_class := p0_a19;
    ddp_association_rec.fulfill_on_type_code := p0_a20;
    ddp_association_rec.attribute_category := p0_a21;
    ddp_association_rec.attribute1 := p0_a22;
    ddp_association_rec.attribute2 := p0_a23;
    ddp_association_rec.attribute3 := p0_a24;
    ddp_association_rec.attribute4 := p0_a25;
    ddp_association_rec.attribute5 := p0_a26;
    ddp_association_rec.attribute6 := p0_a27;
    ddp_association_rec.attribute7 := p0_a28;
    ddp_association_rec.attribute8 := p0_a29;
    ddp_association_rec.attribute9 := p0_a30;
    ddp_association_rec.attribute10 := p0_a31;
    ddp_association_rec.attribute11 := p0_a32;
    ddp_association_rec.attribute12 := p0_a33;
    ddp_association_rec.attribute13 := p0_a34;
    ddp_association_rec.attribute14 := p0_a35;
    ddp_association_rec.attribute15 := p0_a36;
    ddp_association_rec.content_type := p0_a37;
    ddp_association_rec.sequence_no := rosetta_g_miss_num_map(p0_a38);


    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.complete_association_rec(ddp_association_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.object_association_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.master_object_type;
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.master_object_id);
    p1_a9 := ddx_complete_rec.using_object_type;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.using_object_id);
    p1_a11 := ddx_complete_rec.primary_flag;
    p1_a12 := ddx_complete_rec.usage_type;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.quantity_needed);
    p1_a14 := ddx_complete_rec.quantity_needed_by_date;
    p1_a15 := ddx_complete_rec.cost_frozen_flag;
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.pct_of_cost_to_charge_used_by);
    p1_a17 := rosetta_g_miss_num_map(ddx_complete_rec.max_cost_to_charge_used_by);
    p1_a18 := ddx_complete_rec.max_cost_currency_code;
    p1_a19 := ddx_complete_rec.metric_class;
    p1_a20 := ddx_complete_rec.fulfill_on_type_code;
    p1_a21 := ddx_complete_rec.attribute_category;
    p1_a22 := ddx_complete_rec.attribute1;
    p1_a23 := ddx_complete_rec.attribute2;
    p1_a24 := ddx_complete_rec.attribute3;
    p1_a25 := ddx_complete_rec.attribute4;
    p1_a26 := ddx_complete_rec.attribute5;
    p1_a27 := ddx_complete_rec.attribute6;
    p1_a28 := ddx_complete_rec.attribute7;
    p1_a29 := ddx_complete_rec.attribute8;
    p1_a30 := ddx_complete_rec.attribute9;
    p1_a31 := ddx_complete_rec.attribute10;
    p1_a32 := ddx_complete_rec.attribute11;
    p1_a33 := ddx_complete_rec.attribute12;
    p1_a34 := ddx_complete_rec.attribute13;
    p1_a35 := ddx_complete_rec.attribute14;
    p1_a36 := ddx_complete_rec.attribute15;
    p1_a37 := ddx_complete_rec.content_type;
    p1_a38 := rosetta_g_miss_num_map(ddx_complete_rec.sequence_no);
  end;

  procedure init_association_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  NUMBER
  )

  as
    ddx_association_rec ams_associations_pvt.association_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_associations_pvt.init_association_rec(ddx_association_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_association_rec.object_association_id);
    p0_a1 := ddx_association_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_association_rec.last_updated_by);
    p0_a3 := ddx_association_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_association_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_association_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_association_rec.object_version_number);
    p0_a7 := ddx_association_rec.master_object_type;
    p0_a8 := rosetta_g_miss_num_map(ddx_association_rec.master_object_id);
    p0_a9 := ddx_association_rec.using_object_type;
    p0_a10 := rosetta_g_miss_num_map(ddx_association_rec.using_object_id);
    p0_a11 := ddx_association_rec.primary_flag;
    p0_a12 := ddx_association_rec.usage_type;
    p0_a13 := rosetta_g_miss_num_map(ddx_association_rec.quantity_needed);
    p0_a14 := ddx_association_rec.quantity_needed_by_date;
    p0_a15 := ddx_association_rec.cost_frozen_flag;
    p0_a16 := rosetta_g_miss_num_map(ddx_association_rec.pct_of_cost_to_charge_used_by);
    p0_a17 := rosetta_g_miss_num_map(ddx_association_rec.max_cost_to_charge_used_by);
    p0_a18 := ddx_association_rec.max_cost_currency_code;
    p0_a19 := ddx_association_rec.metric_class;
    p0_a20 := ddx_association_rec.fulfill_on_type_code;
    p0_a21 := ddx_association_rec.attribute_category;
    p0_a22 := ddx_association_rec.attribute1;
    p0_a23 := ddx_association_rec.attribute2;
    p0_a24 := ddx_association_rec.attribute3;
    p0_a25 := ddx_association_rec.attribute4;
    p0_a26 := ddx_association_rec.attribute5;
    p0_a27 := ddx_association_rec.attribute6;
    p0_a28 := ddx_association_rec.attribute7;
    p0_a29 := ddx_association_rec.attribute8;
    p0_a30 := ddx_association_rec.attribute9;
    p0_a31 := ddx_association_rec.attribute10;
    p0_a32 := ddx_association_rec.attribute11;
    p0_a33 := ddx_association_rec.attribute12;
    p0_a34 := ddx_association_rec.attribute13;
    p0_a35 := ddx_association_rec.attribute14;
    p0_a36 := ddx_association_rec.attribute15;
    p0_a37 := ddx_association_rec.content_type;
    p0_a38 := rosetta_g_miss_num_map(ddx_association_rec.sequence_no);
  end;

end ams_associations_pvt_w;

/
