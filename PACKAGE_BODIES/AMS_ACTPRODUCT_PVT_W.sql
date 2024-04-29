--------------------------------------------------------
--  DDL for Package Body AMS_ACTPRODUCT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTPRODUCT_PVT_W" as
  /* $Header: amswprdb.pls 115.11 2003/10/22 01:55:20 musman ship $ */
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

  procedure create_act_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_act_product_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
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
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_product_rec.activity_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_product_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_product_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_product_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_product_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_product_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_product_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_product_rec.act_product_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_product_rec.arc_act_product_used_by := p7_a8;
    ddp_act_product_rec.product_sale_type := p7_a9;
    ddp_act_product_rec.primary_product_flag := p7_a10;
    ddp_act_product_rec.enabled_flag := p7_a11;
    ddp_act_product_rec.excluded_flag := p7_a12;
    ddp_act_product_rec.category_id := rosetta_g_miss_num_map(p7_a13);
    ddp_act_product_rec.category_set_id := rosetta_g_miss_num_map(p7_a14);
    ddp_act_product_rec.organization_id := rosetta_g_miss_num_map(p7_a15);
    ddp_act_product_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a16);
    ddp_act_product_rec.level_type_code := p7_a17;
    ddp_act_product_rec.line_lumpsum_amount := rosetta_g_miss_num_map(p7_a18);
    ddp_act_product_rec.line_lumpsum_qty := rosetta_g_miss_num_map(p7_a19);
    ddp_act_product_rec.attribute_category := p7_a20;
    ddp_act_product_rec.attribute1 := p7_a21;
    ddp_act_product_rec.attribute2 := p7_a22;
    ddp_act_product_rec.attribute3 := p7_a23;
    ddp_act_product_rec.attribute4 := p7_a24;
    ddp_act_product_rec.attribute5 := p7_a25;
    ddp_act_product_rec.attribute6 := p7_a26;
    ddp_act_product_rec.attribute7 := p7_a27;
    ddp_act_product_rec.attribute8 := p7_a28;
    ddp_act_product_rec.attribute9 := p7_a29;
    ddp_act_product_rec.attribute10 := p7_a30;
    ddp_act_product_rec.attribute11 := p7_a31;
    ddp_act_product_rec.attribute12 := p7_a32;
    ddp_act_product_rec.attribute13 := p7_a33;
    ddp_act_product_rec.attribute14 := p7_a34;
    ddp_act_product_rec.attribute15 := p7_a35;
    ddp_act_product_rec.channel_id := rosetta_g_miss_num_map(p7_a36);
    ddp_act_product_rec.uom_code := p7_a37;
    ddp_act_product_rec.quantity := rosetta_g_miss_num_map(p7_a38);
    ddp_act_product_rec.scan_value := rosetta_g_miss_num_map(p7_a39);
    ddp_act_product_rec.scan_unit_forecast := rosetta_g_miss_num_map(p7_a40);
    ddp_act_product_rec.adjustment_flag := p7_a41;


    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.create_act_product(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_product_rec,
      x_act_product_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_act_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
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
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_product_rec.activity_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_product_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_product_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_product_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_product_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_product_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_product_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_product_rec.act_product_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_product_rec.arc_act_product_used_by := p7_a8;
    ddp_act_product_rec.product_sale_type := p7_a9;
    ddp_act_product_rec.primary_product_flag := p7_a10;
    ddp_act_product_rec.enabled_flag := p7_a11;
    ddp_act_product_rec.excluded_flag := p7_a12;
    ddp_act_product_rec.category_id := rosetta_g_miss_num_map(p7_a13);
    ddp_act_product_rec.category_set_id := rosetta_g_miss_num_map(p7_a14);
    ddp_act_product_rec.organization_id := rosetta_g_miss_num_map(p7_a15);
    ddp_act_product_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a16);
    ddp_act_product_rec.level_type_code := p7_a17;
    ddp_act_product_rec.line_lumpsum_amount := rosetta_g_miss_num_map(p7_a18);
    ddp_act_product_rec.line_lumpsum_qty := rosetta_g_miss_num_map(p7_a19);
    ddp_act_product_rec.attribute_category := p7_a20;
    ddp_act_product_rec.attribute1 := p7_a21;
    ddp_act_product_rec.attribute2 := p7_a22;
    ddp_act_product_rec.attribute3 := p7_a23;
    ddp_act_product_rec.attribute4 := p7_a24;
    ddp_act_product_rec.attribute5 := p7_a25;
    ddp_act_product_rec.attribute6 := p7_a26;
    ddp_act_product_rec.attribute7 := p7_a27;
    ddp_act_product_rec.attribute8 := p7_a28;
    ddp_act_product_rec.attribute9 := p7_a29;
    ddp_act_product_rec.attribute10 := p7_a30;
    ddp_act_product_rec.attribute11 := p7_a31;
    ddp_act_product_rec.attribute12 := p7_a32;
    ddp_act_product_rec.attribute13 := p7_a33;
    ddp_act_product_rec.attribute14 := p7_a34;
    ddp_act_product_rec.attribute15 := p7_a35;
    ddp_act_product_rec.channel_id := rosetta_g_miss_num_map(p7_a36);
    ddp_act_product_rec.uom_code := p7_a37;
    ddp_act_product_rec.quantity := rosetta_g_miss_num_map(p7_a38);
    ddp_act_product_rec.scan_value := rosetta_g_miss_num_map(p7_a39);
    ddp_act_product_rec.scan_unit_forecast := rosetta_g_miss_num_map(p7_a40);
    ddp_act_product_rec.adjustment_flag := p7_a41;

    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.update_act_product(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_product_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_act_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
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
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_product_rec.activity_product_id := rosetta_g_miss_num_map(p6_a0);
    ddp_act_product_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_act_product_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_act_product_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_act_product_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_act_product_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_act_product_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_act_product_rec.act_product_used_by_id := rosetta_g_miss_num_map(p6_a7);
    ddp_act_product_rec.arc_act_product_used_by := p6_a8;
    ddp_act_product_rec.product_sale_type := p6_a9;
    ddp_act_product_rec.primary_product_flag := p6_a10;
    ddp_act_product_rec.enabled_flag := p6_a11;
    ddp_act_product_rec.excluded_flag := p6_a12;
    ddp_act_product_rec.category_id := rosetta_g_miss_num_map(p6_a13);
    ddp_act_product_rec.category_set_id := rosetta_g_miss_num_map(p6_a14);
    ddp_act_product_rec.organization_id := rosetta_g_miss_num_map(p6_a15);
    ddp_act_product_rec.inventory_item_id := rosetta_g_miss_num_map(p6_a16);
    ddp_act_product_rec.level_type_code := p6_a17;
    ddp_act_product_rec.line_lumpsum_amount := rosetta_g_miss_num_map(p6_a18);
    ddp_act_product_rec.line_lumpsum_qty := rosetta_g_miss_num_map(p6_a19);
    ddp_act_product_rec.attribute_category := p6_a20;
    ddp_act_product_rec.attribute1 := p6_a21;
    ddp_act_product_rec.attribute2 := p6_a22;
    ddp_act_product_rec.attribute3 := p6_a23;
    ddp_act_product_rec.attribute4 := p6_a24;
    ddp_act_product_rec.attribute5 := p6_a25;
    ddp_act_product_rec.attribute6 := p6_a26;
    ddp_act_product_rec.attribute7 := p6_a27;
    ddp_act_product_rec.attribute8 := p6_a28;
    ddp_act_product_rec.attribute9 := p6_a29;
    ddp_act_product_rec.attribute10 := p6_a30;
    ddp_act_product_rec.attribute11 := p6_a31;
    ddp_act_product_rec.attribute12 := p6_a32;
    ddp_act_product_rec.attribute13 := p6_a33;
    ddp_act_product_rec.attribute14 := p6_a34;
    ddp_act_product_rec.attribute15 := p6_a35;
    ddp_act_product_rec.channel_id := rosetta_g_miss_num_map(p6_a36);
    ddp_act_product_rec.uom_code := p6_a37;
    ddp_act_product_rec.quantity := rosetta_g_miss_num_map(p6_a38);
    ddp_act_product_rec.scan_value := rosetta_g_miss_num_map(p6_a39);
    ddp_act_product_rec.scan_unit_forecast := rosetta_g_miss_num_map(p6_a40);
    ddp_act_product_rec.adjustment_flag := p6_a41;

    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.validate_act_product(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_product_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure validate_act_product_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
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
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_product_rec.activity_product_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_product_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_product_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_product_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_product_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_product_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_product_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_product_rec.act_product_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_product_rec.arc_act_product_used_by := p0_a8;
    ddp_act_product_rec.product_sale_type := p0_a9;
    ddp_act_product_rec.primary_product_flag := p0_a10;
    ddp_act_product_rec.enabled_flag := p0_a11;
    ddp_act_product_rec.excluded_flag := p0_a12;
    ddp_act_product_rec.category_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_product_rec.category_set_id := rosetta_g_miss_num_map(p0_a14);
    ddp_act_product_rec.organization_id := rosetta_g_miss_num_map(p0_a15);
    ddp_act_product_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a16);
    ddp_act_product_rec.level_type_code := p0_a17;
    ddp_act_product_rec.line_lumpsum_amount := rosetta_g_miss_num_map(p0_a18);
    ddp_act_product_rec.line_lumpsum_qty := rosetta_g_miss_num_map(p0_a19);
    ddp_act_product_rec.attribute_category := p0_a20;
    ddp_act_product_rec.attribute1 := p0_a21;
    ddp_act_product_rec.attribute2 := p0_a22;
    ddp_act_product_rec.attribute3 := p0_a23;
    ddp_act_product_rec.attribute4 := p0_a24;
    ddp_act_product_rec.attribute5 := p0_a25;
    ddp_act_product_rec.attribute6 := p0_a26;
    ddp_act_product_rec.attribute7 := p0_a27;
    ddp_act_product_rec.attribute8 := p0_a28;
    ddp_act_product_rec.attribute9 := p0_a29;
    ddp_act_product_rec.attribute10 := p0_a30;
    ddp_act_product_rec.attribute11 := p0_a31;
    ddp_act_product_rec.attribute12 := p0_a32;
    ddp_act_product_rec.attribute13 := p0_a33;
    ddp_act_product_rec.attribute14 := p0_a34;
    ddp_act_product_rec.attribute15 := p0_a35;
    ddp_act_product_rec.channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_act_product_rec.uom_code := p0_a37;
    ddp_act_product_rec.quantity := rosetta_g_miss_num_map(p0_a38);
    ddp_act_product_rec.scan_value := rosetta_g_miss_num_map(p0_a39);
    ddp_act_product_rec.scan_unit_forecast := rosetta_g_miss_num_map(p0_a40);
    ddp_act_product_rec.adjustment_flag := p0_a41;



    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.validate_act_product_items(ddp_act_product_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_act_product_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
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
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_product_rec.activity_product_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_product_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_product_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_product_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_product_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_product_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_product_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_product_rec.act_product_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_product_rec.arc_act_product_used_by := p0_a8;
    ddp_act_product_rec.product_sale_type := p0_a9;
    ddp_act_product_rec.primary_product_flag := p0_a10;
    ddp_act_product_rec.enabled_flag := p0_a11;
    ddp_act_product_rec.excluded_flag := p0_a12;
    ddp_act_product_rec.category_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_product_rec.category_set_id := rosetta_g_miss_num_map(p0_a14);
    ddp_act_product_rec.organization_id := rosetta_g_miss_num_map(p0_a15);
    ddp_act_product_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a16);
    ddp_act_product_rec.level_type_code := p0_a17;
    ddp_act_product_rec.line_lumpsum_amount := rosetta_g_miss_num_map(p0_a18);
    ddp_act_product_rec.line_lumpsum_qty := rosetta_g_miss_num_map(p0_a19);
    ddp_act_product_rec.attribute_category := p0_a20;
    ddp_act_product_rec.attribute1 := p0_a21;
    ddp_act_product_rec.attribute2 := p0_a22;
    ddp_act_product_rec.attribute3 := p0_a23;
    ddp_act_product_rec.attribute4 := p0_a24;
    ddp_act_product_rec.attribute5 := p0_a25;
    ddp_act_product_rec.attribute6 := p0_a26;
    ddp_act_product_rec.attribute7 := p0_a27;
    ddp_act_product_rec.attribute8 := p0_a28;
    ddp_act_product_rec.attribute9 := p0_a29;
    ddp_act_product_rec.attribute10 := p0_a30;
    ddp_act_product_rec.attribute11 := p0_a31;
    ddp_act_product_rec.attribute12 := p0_a32;
    ddp_act_product_rec.attribute13 := p0_a33;
    ddp_act_product_rec.attribute14 := p0_a34;
    ddp_act_product_rec.attribute15 := p0_a35;
    ddp_act_product_rec.channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_act_product_rec.uom_code := p0_a37;
    ddp_act_product_rec.quantity := rosetta_g_miss_num_map(p0_a38);
    ddp_act_product_rec.scan_value := rosetta_g_miss_num_map(p0_a39);
    ddp_act_product_rec.scan_unit_forecast := rosetta_g_miss_num_map(p0_a40);
    ddp_act_product_rec.adjustment_flag := p0_a41;


    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.validate_act_product_record(ddp_act_product_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure complete_act_product_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  NUMBER
    , p1_a15 OUT NOCOPY  NUMBER
    , p1_a16 OUT NOCOPY  NUMBER
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  NUMBER
    , p1_a19 OUT NOCOPY  NUMBER
    , p1_a20 OUT NOCOPY  VARCHAR2
    , p1_a21 OUT NOCOPY  VARCHAR2
    , p1_a22 OUT NOCOPY  VARCHAR2
    , p1_a23 OUT NOCOPY  VARCHAR2
    , p1_a24 OUT NOCOPY  VARCHAR2
    , p1_a25 OUT NOCOPY  VARCHAR2
    , p1_a26 OUT NOCOPY  VARCHAR2
    , p1_a27 OUT NOCOPY  VARCHAR2
    , p1_a28 OUT NOCOPY  VARCHAR2
    , p1_a29 OUT NOCOPY  VARCHAR2
    , p1_a30 OUT NOCOPY  VARCHAR2
    , p1_a31 OUT NOCOPY  VARCHAR2
    , p1_a32 OUT NOCOPY  VARCHAR2
    , p1_a33 OUT NOCOPY  VARCHAR2
    , p1_a34 OUT NOCOPY  VARCHAR2
    , p1_a35 OUT NOCOPY  VARCHAR2
    , p1_a36 OUT NOCOPY  NUMBER
    , p1_a37 OUT NOCOPY  VARCHAR2
    , p1_a38 OUT NOCOPY  NUMBER
    , p1_a39 OUT NOCOPY  NUMBER
    , p1_a40 OUT NOCOPY  NUMBER
    , p1_a41 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
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
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddx_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_product_rec.activity_product_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_product_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_product_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_product_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_product_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_product_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_product_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_product_rec.act_product_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_product_rec.arc_act_product_used_by := p0_a8;
    ddp_act_product_rec.product_sale_type := p0_a9;
    ddp_act_product_rec.primary_product_flag := p0_a10;
    ddp_act_product_rec.enabled_flag := p0_a11;
    ddp_act_product_rec.excluded_flag := p0_a12;
    ddp_act_product_rec.category_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_product_rec.category_set_id := rosetta_g_miss_num_map(p0_a14);
    ddp_act_product_rec.organization_id := rosetta_g_miss_num_map(p0_a15);
    ddp_act_product_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a16);
    ddp_act_product_rec.level_type_code := p0_a17;
    ddp_act_product_rec.line_lumpsum_amount := rosetta_g_miss_num_map(p0_a18);
    ddp_act_product_rec.line_lumpsum_qty := rosetta_g_miss_num_map(p0_a19);
    ddp_act_product_rec.attribute_category := p0_a20;
    ddp_act_product_rec.attribute1 := p0_a21;
    ddp_act_product_rec.attribute2 := p0_a22;
    ddp_act_product_rec.attribute3 := p0_a23;
    ddp_act_product_rec.attribute4 := p0_a24;
    ddp_act_product_rec.attribute5 := p0_a25;
    ddp_act_product_rec.attribute6 := p0_a26;
    ddp_act_product_rec.attribute7 := p0_a27;
    ddp_act_product_rec.attribute8 := p0_a28;
    ddp_act_product_rec.attribute9 := p0_a29;
    ddp_act_product_rec.attribute10 := p0_a30;
    ddp_act_product_rec.attribute11 := p0_a31;
    ddp_act_product_rec.attribute12 := p0_a32;
    ddp_act_product_rec.attribute13 := p0_a33;
    ddp_act_product_rec.attribute14 := p0_a34;
    ddp_act_product_rec.attribute15 := p0_a35;
    ddp_act_product_rec.channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_act_product_rec.uom_code := p0_a37;
    ddp_act_product_rec.quantity := rosetta_g_miss_num_map(p0_a38);
    ddp_act_product_rec.scan_value := rosetta_g_miss_num_map(p0_a39);
    ddp_act_product_rec.scan_unit_forecast := rosetta_g_miss_num_map(p0_a40);
    ddp_act_product_rec.adjustment_flag := p0_a41;


    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.complete_act_product_rec(ddp_act_product_rec,
      ddx_act_product_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_act_product_rec.activity_product_id);
    p1_a1 := ddx_act_product_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_act_product_rec.last_updated_by);
    p1_a3 := ddx_act_product_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_act_product_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_act_product_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_act_product_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_act_product_rec.act_product_used_by_id);
    p1_a8 := ddx_act_product_rec.arc_act_product_used_by;
    p1_a9 := ddx_act_product_rec.product_sale_type;
    p1_a10 := ddx_act_product_rec.primary_product_flag;
    p1_a11 := ddx_act_product_rec.enabled_flag;
    p1_a12 := ddx_act_product_rec.excluded_flag;
    p1_a13 := rosetta_g_miss_num_map(ddx_act_product_rec.category_id);
    p1_a14 := rosetta_g_miss_num_map(ddx_act_product_rec.category_set_id);
    p1_a15 := rosetta_g_miss_num_map(ddx_act_product_rec.organization_id);
    p1_a16 := rosetta_g_miss_num_map(ddx_act_product_rec.inventory_item_id);
    p1_a17 := ddx_act_product_rec.level_type_code;
    p1_a18 := rosetta_g_miss_num_map(ddx_act_product_rec.line_lumpsum_amount);
    p1_a19 := rosetta_g_miss_num_map(ddx_act_product_rec.line_lumpsum_qty);
    p1_a20 := ddx_act_product_rec.attribute_category;
    p1_a21 := ddx_act_product_rec.attribute1;
    p1_a22 := ddx_act_product_rec.attribute2;
    p1_a23 := ddx_act_product_rec.attribute3;
    p1_a24 := ddx_act_product_rec.attribute4;
    p1_a25 := ddx_act_product_rec.attribute5;
    p1_a26 := ddx_act_product_rec.attribute6;
    p1_a27 := ddx_act_product_rec.attribute7;
    p1_a28 := ddx_act_product_rec.attribute8;
    p1_a29 := ddx_act_product_rec.attribute9;
    p1_a30 := ddx_act_product_rec.attribute10;
    p1_a31 := ddx_act_product_rec.attribute11;
    p1_a32 := ddx_act_product_rec.attribute12;
    p1_a33 := ddx_act_product_rec.attribute13;
    p1_a34 := ddx_act_product_rec.attribute14;
    p1_a35 := ddx_act_product_rec.attribute15;
    p1_a36 := rosetta_g_miss_num_map(ddx_act_product_rec.channel_id);
    p1_a37 := ddx_act_product_rec.uom_code;
    p1_a38 := rosetta_g_miss_num_map(ddx_act_product_rec.quantity);
    p1_a39 := rosetta_g_miss_num_map(ddx_act_product_rec.scan_value);
    p1_a40 := rosetta_g_miss_num_map(ddx_act_product_rec.scan_unit_forecast);
    p1_a41 := ddx_act_product_rec.adjustment_flag;
  end;

end ams_actproduct_pvt_w;

/
