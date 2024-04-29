--------------------------------------------------------
--  DDL for Package Body AMS_COMPETITOR_PRODUCT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COMPETITOR_PRODUCT_PVT_W" as
  /* $Header: amswcprb.pls 120.2 2005/08/04 08:20 appldev ship $ */
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

  procedure create_comp_product(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_competitor_product_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
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
  )

  as
    ddp_comp_prod_rec ams_competitor_product_pvt.comp_prod_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_comp_prod_rec.competitor_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_comp_prod_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_comp_prod_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_comp_prod_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_comp_prod_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_comp_prod_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_comp_prod_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_comp_prod_rec.competitor_party_id := rosetta_g_miss_num_map(p7_a7);
    ddp_comp_prod_rec.competitor_product_code := p7_a8;
    ddp_comp_prod_rec.interest_type_id := rosetta_g_miss_num_map(p7_a9);
    ddp_comp_prod_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a10);
    ddp_comp_prod_rec.organization_id := rosetta_g_miss_num_map(p7_a11);
    ddp_comp_prod_rec.comp_product_url := p7_a12;
    ddp_comp_prod_rec.original_system_ref := p7_a13;
    ddp_comp_prod_rec.competitor_product_name := p7_a14;
    ddp_comp_prod_rec.description := p7_a15;
    ddp_comp_prod_rec.start_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_comp_prod_rec.end_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_comp_prod_rec.category_id := rosetta_g_miss_num_map(p7_a18);
    ddp_comp_prod_rec.category_set_id := rosetta_g_miss_num_map(p7_a19);
    ddp_comp_prod_rec.context := p7_a20;
    ddp_comp_prod_rec.attribute1 := p7_a21;
    ddp_comp_prod_rec.attribute2 := p7_a22;
    ddp_comp_prod_rec.attribute3 := p7_a23;
    ddp_comp_prod_rec.attribute4 := p7_a24;
    ddp_comp_prod_rec.attribute5 := p7_a25;
    ddp_comp_prod_rec.attribute6 := p7_a26;
    ddp_comp_prod_rec.attribute7 := p7_a27;
    ddp_comp_prod_rec.attribute8 := p7_a28;
    ddp_comp_prod_rec.attribute9 := p7_a29;
    ddp_comp_prod_rec.attribute10 := p7_a30;
    ddp_comp_prod_rec.attribute11 := p7_a31;
    ddp_comp_prod_rec.attribute12 := p7_a32;
    ddp_comp_prod_rec.attribute13 := p7_a33;
    ddp_comp_prod_rec.attribute14 := p7_a34;
    ddp_comp_prod_rec.attribute15 := p7_a35;


    -- here's the delegated call to the old PL/SQL routine
    ams_competitor_product_pvt.create_comp_product(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_comp_prod_rec,
      x_competitor_product_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_comp_product(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
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
  )

  as
    ddp_comp_prod_rec ams_competitor_product_pvt.comp_prod_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_comp_prod_rec.competitor_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_comp_prod_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_comp_prod_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_comp_prod_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_comp_prod_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_comp_prod_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_comp_prod_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_comp_prod_rec.competitor_party_id := rosetta_g_miss_num_map(p7_a7);
    ddp_comp_prod_rec.competitor_product_code := p7_a8;
    ddp_comp_prod_rec.interest_type_id := rosetta_g_miss_num_map(p7_a9);
    ddp_comp_prod_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a10);
    ddp_comp_prod_rec.organization_id := rosetta_g_miss_num_map(p7_a11);
    ddp_comp_prod_rec.comp_product_url := p7_a12;
    ddp_comp_prod_rec.original_system_ref := p7_a13;
    ddp_comp_prod_rec.competitor_product_name := p7_a14;
    ddp_comp_prod_rec.description := p7_a15;
    ddp_comp_prod_rec.start_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_comp_prod_rec.end_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_comp_prod_rec.category_id := rosetta_g_miss_num_map(p7_a18);
    ddp_comp_prod_rec.category_set_id := rosetta_g_miss_num_map(p7_a19);
    ddp_comp_prod_rec.context := p7_a20;
    ddp_comp_prod_rec.attribute1 := p7_a21;
    ddp_comp_prod_rec.attribute2 := p7_a22;
    ddp_comp_prod_rec.attribute3 := p7_a23;
    ddp_comp_prod_rec.attribute4 := p7_a24;
    ddp_comp_prod_rec.attribute5 := p7_a25;
    ddp_comp_prod_rec.attribute6 := p7_a26;
    ddp_comp_prod_rec.attribute7 := p7_a27;
    ddp_comp_prod_rec.attribute8 := p7_a28;
    ddp_comp_prod_rec.attribute9 := p7_a29;
    ddp_comp_prod_rec.attribute10 := p7_a30;
    ddp_comp_prod_rec.attribute11 := p7_a31;
    ddp_comp_prod_rec.attribute12 := p7_a32;
    ddp_comp_prod_rec.attribute13 := p7_a33;
    ddp_comp_prod_rec.attribute14 := p7_a34;
    ddp_comp_prod_rec.attribute15 := p7_a35;


    -- here's the delegated call to the old PL/SQL routine
    ams_competitor_product_pvt.update_comp_product(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_comp_prod_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_comp_prod(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  DATE := fnd_api.g_miss_date
    , p4_a17  DATE := fnd_api.g_miss_date
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_comp_prod_rec ams_competitor_product_pvt.comp_prod_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_comp_prod_rec.competitor_product_id := rosetta_g_miss_num_map(p4_a0);
    ddp_comp_prod_rec.object_version_number := rosetta_g_miss_num_map(p4_a1);
    ddp_comp_prod_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_comp_prod_rec.last_updated_by := rosetta_g_miss_num_map(p4_a3);
    ddp_comp_prod_rec.creation_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_comp_prod_rec.created_by := rosetta_g_miss_num_map(p4_a5);
    ddp_comp_prod_rec.last_update_login := rosetta_g_miss_num_map(p4_a6);
    ddp_comp_prod_rec.competitor_party_id := rosetta_g_miss_num_map(p4_a7);
    ddp_comp_prod_rec.competitor_product_code := p4_a8;
    ddp_comp_prod_rec.interest_type_id := rosetta_g_miss_num_map(p4_a9);
    ddp_comp_prod_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a10);
    ddp_comp_prod_rec.organization_id := rosetta_g_miss_num_map(p4_a11);
    ddp_comp_prod_rec.comp_product_url := p4_a12;
    ddp_comp_prod_rec.original_system_ref := p4_a13;
    ddp_comp_prod_rec.competitor_product_name := p4_a14;
    ddp_comp_prod_rec.description := p4_a15;
    ddp_comp_prod_rec.start_date := rosetta_g_miss_date_in_map(p4_a16);
    ddp_comp_prod_rec.end_date := rosetta_g_miss_date_in_map(p4_a17);
    ddp_comp_prod_rec.category_id := rosetta_g_miss_num_map(p4_a18);
    ddp_comp_prod_rec.category_set_id := rosetta_g_miss_num_map(p4_a19);
    ddp_comp_prod_rec.context := p4_a20;
    ddp_comp_prod_rec.attribute1 := p4_a21;
    ddp_comp_prod_rec.attribute2 := p4_a22;
    ddp_comp_prod_rec.attribute3 := p4_a23;
    ddp_comp_prod_rec.attribute4 := p4_a24;
    ddp_comp_prod_rec.attribute5 := p4_a25;
    ddp_comp_prod_rec.attribute6 := p4_a26;
    ddp_comp_prod_rec.attribute7 := p4_a27;
    ddp_comp_prod_rec.attribute8 := p4_a28;
    ddp_comp_prod_rec.attribute9 := p4_a29;
    ddp_comp_prod_rec.attribute10 := p4_a30;
    ddp_comp_prod_rec.attribute11 := p4_a31;
    ddp_comp_prod_rec.attribute12 := p4_a32;
    ddp_comp_prod_rec.attribute13 := p4_a33;
    ddp_comp_prod_rec.attribute14 := p4_a34;
    ddp_comp_prod_rec.attribute15 := p4_a35;




    -- here's the delegated call to the old PL/SQL routine
    ams_competitor_product_pvt.validate_comp_prod(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_comp_prod_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ams_competitor_product_pvt_w;

/
