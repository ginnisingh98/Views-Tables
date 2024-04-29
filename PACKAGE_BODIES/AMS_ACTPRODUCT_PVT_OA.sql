--------------------------------------------------------
--  DDL for Package Body AMS_ACTPRODUCT_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTPRODUCT_PVT_OA" as
  /* $Header: amsaacpb.pls 120.0 2005/08/31 09:45 gramanat noship $ */
  procedure create_act_product(p_api_version  NUMBER
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
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , x_act_product_id out nocopy  NUMBER
  )

  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_product_rec.activity_product_id := p7_a0;
    ddp_act_product_rec.last_update_date := p7_a1;
    ddp_act_product_rec.last_updated_by := p7_a2;
    ddp_act_product_rec.creation_date := p7_a3;
    ddp_act_product_rec.created_by := p7_a4;
    ddp_act_product_rec.last_update_login := p7_a5;
    ddp_act_product_rec.object_version_number := p7_a6;
    ddp_act_product_rec.act_product_used_by_id := p7_a7;
    ddp_act_product_rec.arc_act_product_used_by := p7_a8;
    ddp_act_product_rec.product_sale_type := p7_a9;
    ddp_act_product_rec.primary_product_flag := p7_a10;
    ddp_act_product_rec.enabled_flag := p7_a11;
    ddp_act_product_rec.excluded_flag := p7_a12;
    ddp_act_product_rec.category_id := p7_a13;
    ddp_act_product_rec.category_set_id := p7_a14;
    ddp_act_product_rec.organization_id := p7_a15;
    ddp_act_product_rec.inventory_item_id := p7_a16;
    ddp_act_product_rec.level_type_code := p7_a17;
    ddp_act_product_rec.line_lumpsum_amount := p7_a18;
    ddp_act_product_rec.line_lumpsum_qty := p7_a19;
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
    ddp_act_product_rec.channel_id := p7_a36;
    ddp_act_product_rec.uom_code := p7_a37;
    ddp_act_product_rec.quantity := p7_a38;
    ddp_act_product_rec.scan_value := p7_a39;
    ddp_act_product_rec.scan_unit_forecast := p7_a40;
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

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_act_product(p_api_version  NUMBER
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
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
  )

  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_product_rec.activity_product_id := p7_a0;
    ddp_act_product_rec.last_update_date := p7_a1;
    ddp_act_product_rec.last_updated_by := p7_a2;
    ddp_act_product_rec.creation_date := p7_a3;
    ddp_act_product_rec.created_by := p7_a4;
    ddp_act_product_rec.last_update_login := p7_a5;
    ddp_act_product_rec.object_version_number := p7_a6;
    ddp_act_product_rec.act_product_used_by_id := p7_a7;
    ddp_act_product_rec.arc_act_product_used_by := p7_a8;
    ddp_act_product_rec.product_sale_type := p7_a9;
    ddp_act_product_rec.primary_product_flag := p7_a10;
    ddp_act_product_rec.enabled_flag := p7_a11;
    ddp_act_product_rec.excluded_flag := p7_a12;
    ddp_act_product_rec.category_id := p7_a13;
    ddp_act_product_rec.category_set_id := p7_a14;
    ddp_act_product_rec.organization_id := p7_a15;
    ddp_act_product_rec.inventory_item_id := p7_a16;
    ddp_act_product_rec.level_type_code := p7_a17;
    ddp_act_product_rec.line_lumpsum_amount := p7_a18;
    ddp_act_product_rec.line_lumpsum_qty := p7_a19;
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
    ddp_act_product_rec.channel_id := p7_a36;
    ddp_act_product_rec.uom_code := p7_a37;
    ddp_act_product_rec.quantity := p7_a38;
    ddp_act_product_rec.scan_value := p7_a39;
    ddp_act_product_rec.scan_unit_forecast := p7_a40;
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

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_act_product(p_api_version  NUMBER
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
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  VARCHAR2
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  NUMBER
    , p6_a37  VARCHAR2
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  VARCHAR2
  )

  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_product_rec.activity_product_id := p6_a0;
    ddp_act_product_rec.last_update_date := p6_a1;
    ddp_act_product_rec.last_updated_by := p6_a2;
    ddp_act_product_rec.creation_date := p6_a3;
    ddp_act_product_rec.created_by := p6_a4;
    ddp_act_product_rec.last_update_login := p6_a5;
    ddp_act_product_rec.object_version_number := p6_a6;
    ddp_act_product_rec.act_product_used_by_id := p6_a7;
    ddp_act_product_rec.arc_act_product_used_by := p6_a8;
    ddp_act_product_rec.product_sale_type := p6_a9;
    ddp_act_product_rec.primary_product_flag := p6_a10;
    ddp_act_product_rec.enabled_flag := p6_a11;
    ddp_act_product_rec.excluded_flag := p6_a12;
    ddp_act_product_rec.category_id := p6_a13;
    ddp_act_product_rec.category_set_id := p6_a14;
    ddp_act_product_rec.organization_id := p6_a15;
    ddp_act_product_rec.inventory_item_id := p6_a16;
    ddp_act_product_rec.level_type_code := p6_a17;
    ddp_act_product_rec.line_lumpsum_amount := p6_a18;
    ddp_act_product_rec.line_lumpsum_qty := p6_a19;
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
    ddp_act_product_rec.channel_id := p6_a36;
    ddp_act_product_rec.uom_code := p6_a37;
    ddp_act_product_rec.quantity := p6_a38;
    ddp_act_product_rec.scan_value := p6_a39;
    ddp_act_product_rec.scan_unit_forecast := p6_a40;
    ddp_act_product_rec.adjustment_flag := p6_a41;

    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.validate_act_product(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_product_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_act_product_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_product_rec.activity_product_id := p0_a0;
    ddp_act_product_rec.last_update_date := p0_a1;
    ddp_act_product_rec.last_updated_by := p0_a2;
    ddp_act_product_rec.creation_date := p0_a3;
    ddp_act_product_rec.created_by := p0_a4;
    ddp_act_product_rec.last_update_login := p0_a5;
    ddp_act_product_rec.object_version_number := p0_a6;
    ddp_act_product_rec.act_product_used_by_id := p0_a7;
    ddp_act_product_rec.arc_act_product_used_by := p0_a8;
    ddp_act_product_rec.product_sale_type := p0_a9;
    ddp_act_product_rec.primary_product_flag := p0_a10;
    ddp_act_product_rec.enabled_flag := p0_a11;
    ddp_act_product_rec.excluded_flag := p0_a12;
    ddp_act_product_rec.category_id := p0_a13;
    ddp_act_product_rec.category_set_id := p0_a14;
    ddp_act_product_rec.organization_id := p0_a15;
    ddp_act_product_rec.inventory_item_id := p0_a16;
    ddp_act_product_rec.level_type_code := p0_a17;
    ddp_act_product_rec.line_lumpsum_amount := p0_a18;
    ddp_act_product_rec.line_lumpsum_qty := p0_a19;
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
    ddp_act_product_rec.channel_id := p0_a36;
    ddp_act_product_rec.uom_code := p0_a37;
    ddp_act_product_rec.quantity := p0_a38;
    ddp_act_product_rec.scan_value := p0_a39;
    ddp_act_product_rec.scan_unit_forecast := p0_a40;
    ddp_act_product_rec.adjustment_flag := p0_a41;



    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.validate_act_product_items(ddp_act_product_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_act_product_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_product_rec.activity_product_id := p0_a0;
    ddp_act_product_rec.last_update_date := p0_a1;
    ddp_act_product_rec.last_updated_by := p0_a2;
    ddp_act_product_rec.creation_date := p0_a3;
    ddp_act_product_rec.created_by := p0_a4;
    ddp_act_product_rec.last_update_login := p0_a5;
    ddp_act_product_rec.object_version_number := p0_a6;
    ddp_act_product_rec.act_product_used_by_id := p0_a7;
    ddp_act_product_rec.arc_act_product_used_by := p0_a8;
    ddp_act_product_rec.product_sale_type := p0_a9;
    ddp_act_product_rec.primary_product_flag := p0_a10;
    ddp_act_product_rec.enabled_flag := p0_a11;
    ddp_act_product_rec.excluded_flag := p0_a12;
    ddp_act_product_rec.category_id := p0_a13;
    ddp_act_product_rec.category_set_id := p0_a14;
    ddp_act_product_rec.organization_id := p0_a15;
    ddp_act_product_rec.inventory_item_id := p0_a16;
    ddp_act_product_rec.level_type_code := p0_a17;
    ddp_act_product_rec.line_lumpsum_amount := p0_a18;
    ddp_act_product_rec.line_lumpsum_qty := p0_a19;
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
    ddp_act_product_rec.channel_id := p0_a36;
    ddp_act_product_rec.uom_code := p0_a37;
    ddp_act_product_rec.quantity := p0_a38;
    ddp_act_product_rec.scan_value := p0_a39;
    ddp_act_product_rec.scan_unit_forecast := p0_a40;
    ddp_act_product_rec.adjustment_flag := p0_a41;


    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.validate_act_product_record(ddp_act_product_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure complete_act_product_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
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
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  VARCHAR2
  )

  as
    ddp_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddx_act_product_rec ams_actproduct_pvt.act_product_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_product_rec.activity_product_id := p0_a0;
    ddp_act_product_rec.last_update_date := p0_a1;
    ddp_act_product_rec.last_updated_by := p0_a2;
    ddp_act_product_rec.creation_date := p0_a3;
    ddp_act_product_rec.created_by := p0_a4;
    ddp_act_product_rec.last_update_login := p0_a5;
    ddp_act_product_rec.object_version_number := p0_a6;
    ddp_act_product_rec.act_product_used_by_id := p0_a7;
    ddp_act_product_rec.arc_act_product_used_by := p0_a8;
    ddp_act_product_rec.product_sale_type := p0_a9;
    ddp_act_product_rec.primary_product_flag := p0_a10;
    ddp_act_product_rec.enabled_flag := p0_a11;
    ddp_act_product_rec.excluded_flag := p0_a12;
    ddp_act_product_rec.category_id := p0_a13;
    ddp_act_product_rec.category_set_id := p0_a14;
    ddp_act_product_rec.organization_id := p0_a15;
    ddp_act_product_rec.inventory_item_id := p0_a16;
    ddp_act_product_rec.level_type_code := p0_a17;
    ddp_act_product_rec.line_lumpsum_amount := p0_a18;
    ddp_act_product_rec.line_lumpsum_qty := p0_a19;
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
    ddp_act_product_rec.channel_id := p0_a36;
    ddp_act_product_rec.uom_code := p0_a37;
    ddp_act_product_rec.quantity := p0_a38;
    ddp_act_product_rec.scan_value := p0_a39;
    ddp_act_product_rec.scan_unit_forecast := p0_a40;
    ddp_act_product_rec.adjustment_flag := p0_a41;


    -- here's the delegated call to the old PL/SQL routine
    ams_actproduct_pvt.complete_act_product_rec(ddp_act_product_rec,
      ddx_act_product_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_act_product_rec.activity_product_id;
    p1_a1 := ddx_act_product_rec.last_update_date;
    p1_a2 := ddx_act_product_rec.last_updated_by;
    p1_a3 := ddx_act_product_rec.creation_date;
    p1_a4 := ddx_act_product_rec.created_by;
    p1_a5 := ddx_act_product_rec.last_update_login;
    p1_a6 := ddx_act_product_rec.object_version_number;
    p1_a7 := ddx_act_product_rec.act_product_used_by_id;
    p1_a8 := ddx_act_product_rec.arc_act_product_used_by;
    p1_a9 := ddx_act_product_rec.product_sale_type;
    p1_a10 := ddx_act_product_rec.primary_product_flag;
    p1_a11 := ddx_act_product_rec.enabled_flag;
    p1_a12 := ddx_act_product_rec.excluded_flag;
    p1_a13 := ddx_act_product_rec.category_id;
    p1_a14 := ddx_act_product_rec.category_set_id;
    p1_a15 := ddx_act_product_rec.organization_id;
    p1_a16 := ddx_act_product_rec.inventory_item_id;
    p1_a17 := ddx_act_product_rec.level_type_code;
    p1_a18 := ddx_act_product_rec.line_lumpsum_amount;
    p1_a19 := ddx_act_product_rec.line_lumpsum_qty;
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
    p1_a36 := ddx_act_product_rec.channel_id;
    p1_a37 := ddx_act_product_rec.uom_code;
    p1_a38 := ddx_act_product_rec.quantity;
    p1_a39 := ddx_act_product_rec.scan_value;
    p1_a40 := ddx_act_product_rec.scan_unit_forecast;
    p1_a41 := ddx_act_product_rec.adjustment_flag;
  end;

end ams_actproduct_pvt_oa;

/
