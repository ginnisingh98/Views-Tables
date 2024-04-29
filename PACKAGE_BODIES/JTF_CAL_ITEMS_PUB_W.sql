--------------------------------------------------------
--  DDL for Package Body JTF_CAL_ITEMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_ITEMS_PUB_W" as
  /* $Header: jtfcwitb.pls 120.2 2006/04/28 00:15 deeprao ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure createitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  DATE
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  DATE
    , p6_a14  NUMBER
    , p6_a15  DATE
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , x_cal_item_id out nocopy  NUMBER
  )

  as
    ddp_itm_rec jtf_cal_items_pub.calitemrec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_itm_rec.cal_resource_id := p6_a0;
    ddp_itm_rec.cal_resource_type := p6_a1;
    ddp_itm_rec.cal_item_id := p6_a2;
    ddp_itm_rec.item_type_code := p6_a3;
    ddp_itm_rec.item_name := p6_a4;
    ddp_itm_rec.item_description := p6_a5;
    ddp_itm_rec.source_code := p6_a6;
    ddp_itm_rec.source_id := p6_a7;
    ddp_itm_rec.start_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_itm_rec.end_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_itm_rec.timezone_id := p6_a10;
    ddp_itm_rec.url := p6_a11;
    ddp_itm_rec.created_by := p6_a12;
    ddp_itm_rec.creation_date := rosetta_g_miss_date_in_map(p6_a13);
    ddp_itm_rec.last_updated_by := p6_a14;
    ddp_itm_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a15);
    ddp_itm_rec.last_update_login := p6_a16;
    ddp_itm_rec.object_version_number := p6_a17;
    ddp_itm_rec.application_id := p6_a18;


    -- here's the delegated call to the old PL/SQL routine
    jtf_cal_items_pub.createitem(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_itm_rec,
      x_cal_item_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure updateitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  NUMBER
    , p7_a15  DATE
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_itm_rec jtf_cal_items_pub.calitemrec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_itm_rec.cal_resource_id := p7_a0;
    ddp_itm_rec.cal_resource_type := p7_a1;
    ddp_itm_rec.cal_item_id := p7_a2;
    ddp_itm_rec.item_type_code := p7_a3;
    ddp_itm_rec.item_name := p7_a4;
    ddp_itm_rec.item_description := p7_a5;
    ddp_itm_rec.source_code := p7_a6;
    ddp_itm_rec.source_id := p7_a7;
    ddp_itm_rec.start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_itm_rec.end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_itm_rec.timezone_id := p7_a10;
    ddp_itm_rec.url := p7_a11;
    ddp_itm_rec.created_by := p7_a12;
    ddp_itm_rec.creation_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_itm_rec.last_updated_by := p7_a14;
    ddp_itm_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_itm_rec.last_update_login := p7_a16;
    ddp_itm_rec.object_version_number := p7_a17;
    ddp_itm_rec.application_id := p7_a18;


    -- here's the delegated call to the old PL/SQL routine
    jtf_cal_items_pub.updateitem(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_itm_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end jtf_cal_items_pub_w;

/
