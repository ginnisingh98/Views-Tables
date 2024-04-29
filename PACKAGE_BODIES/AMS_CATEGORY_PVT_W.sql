--------------------------------------------------------
--  DDL for Package Body AMS_CATEGORY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CATEGORY_PVT_W" as
  /* $Header: amswctyb.pls 120.1 2005/10/21 03:54 vmodur noship $ */
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

  procedure create_category(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_category_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
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
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_category_rec.category_id := rosetta_g_miss_num_map(p7_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_category_rec.arc_category_created_for := p7_a7;
    ddp_category_rec.enabled_flag := p7_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p7_a9);
    ddp_category_rec.attribute_category := p7_a10;
    ddp_category_rec.attribute1 := p7_a11;
    ddp_category_rec.attribute2 := p7_a12;
    ddp_category_rec.attribute3 := p7_a13;
    ddp_category_rec.attribute4 := p7_a14;
    ddp_category_rec.attribute5 := p7_a15;
    ddp_category_rec.attribute6 := p7_a16;
    ddp_category_rec.attribute7 := p7_a17;
    ddp_category_rec.attribute8 := p7_a18;
    ddp_category_rec.attribute9 := p7_a19;
    ddp_category_rec.attribute10 := p7_a20;
    ddp_category_rec.attribute11 := p7_a21;
    ddp_category_rec.attribute12 := p7_a22;
    ddp_category_rec.attribute13 := p7_a23;
    ddp_category_rec.attribute14 := p7_a24;
    ddp_category_rec.attribute15 := p7_a25;
    ddp_category_rec.source_lang := p7_a26;
    ddp_category_rec.category_name := p7_a27;
    ddp_category_rec.description := p7_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p7_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p7_a30);
    ddp_category_rec.budget_code_suffix := p7_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p7_a32);


    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.create_category(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_category_rec,
      x_category_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_category(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
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
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_category_rec.category_id := rosetta_g_miss_num_map(p7_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_category_rec.arc_category_created_for := p7_a7;
    ddp_category_rec.enabled_flag := p7_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p7_a9);
    ddp_category_rec.attribute_category := p7_a10;
    ddp_category_rec.attribute1 := p7_a11;
    ddp_category_rec.attribute2 := p7_a12;
    ddp_category_rec.attribute3 := p7_a13;
    ddp_category_rec.attribute4 := p7_a14;
    ddp_category_rec.attribute5 := p7_a15;
    ddp_category_rec.attribute6 := p7_a16;
    ddp_category_rec.attribute7 := p7_a17;
    ddp_category_rec.attribute8 := p7_a18;
    ddp_category_rec.attribute9 := p7_a19;
    ddp_category_rec.attribute10 := p7_a20;
    ddp_category_rec.attribute11 := p7_a21;
    ddp_category_rec.attribute12 := p7_a22;
    ddp_category_rec.attribute13 := p7_a23;
    ddp_category_rec.attribute14 := p7_a24;
    ddp_category_rec.attribute15 := p7_a25;
    ddp_category_rec.source_lang := p7_a26;
    ddp_category_rec.category_name := p7_a27;
    ddp_category_rec.description := p7_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p7_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p7_a30);
    ddp_category_rec.budget_code_suffix := p7_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p7_a32);

    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.update_category(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_category_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure complete_category_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
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
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddx_complete_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_category_rec.category_id := rosetta_g_miss_num_map(p0_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_category_rec.arc_category_created_for := p0_a7;
    ddp_category_rec.enabled_flag := p0_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p0_a9);
    ddp_category_rec.attribute_category := p0_a10;
    ddp_category_rec.attribute1 := p0_a11;
    ddp_category_rec.attribute2 := p0_a12;
    ddp_category_rec.attribute3 := p0_a13;
    ddp_category_rec.attribute4 := p0_a14;
    ddp_category_rec.attribute5 := p0_a15;
    ddp_category_rec.attribute6 := p0_a16;
    ddp_category_rec.attribute7 := p0_a17;
    ddp_category_rec.attribute8 := p0_a18;
    ddp_category_rec.attribute9 := p0_a19;
    ddp_category_rec.attribute10 := p0_a20;
    ddp_category_rec.attribute11 := p0_a21;
    ddp_category_rec.attribute12 := p0_a22;
    ddp_category_rec.attribute13 := p0_a23;
    ddp_category_rec.attribute14 := p0_a24;
    ddp_category_rec.attribute15 := p0_a25;
    ddp_category_rec.source_lang := p0_a26;
    ddp_category_rec.category_name := p0_a27;
    ddp_category_rec.description := p0_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p0_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p0_a30);
    ddp_category_rec.budget_code_suffix := p0_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p0_a32);


    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.complete_category_rec(ddp_category_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.category_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.arc_category_created_for;
    p1_a8 := ddx_complete_rec.enabled_flag;
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.parent_category_id);
    p1_a10 := ddx_complete_rec.attribute_category;
    p1_a11 := ddx_complete_rec.attribute1;
    p1_a12 := ddx_complete_rec.attribute2;
    p1_a13 := ddx_complete_rec.attribute3;
    p1_a14 := ddx_complete_rec.attribute4;
    p1_a15 := ddx_complete_rec.attribute5;
    p1_a16 := ddx_complete_rec.attribute6;
    p1_a17 := ddx_complete_rec.attribute7;
    p1_a18 := ddx_complete_rec.attribute8;
    p1_a19 := ddx_complete_rec.attribute9;
    p1_a20 := ddx_complete_rec.attribute10;
    p1_a21 := ddx_complete_rec.attribute11;
    p1_a22 := ddx_complete_rec.attribute12;
    p1_a23 := ddx_complete_rec.attribute13;
    p1_a24 := ddx_complete_rec.attribute14;
    p1_a25 := ddx_complete_rec.attribute15;
    p1_a26 := ddx_complete_rec.source_lang;
    p1_a27 := ddx_complete_rec.category_name;
    p1_a28 := ddx_complete_rec.description;
    p1_a29 := rosetta_g_miss_num_map(ddx_complete_rec.accrued_liability_account);
    p1_a30 := rosetta_g_miss_num_map(ddx_complete_rec.ded_adjustment_account);
    p1_a31 := ddx_complete_rec.budget_code_suffix;
    p1_a32 := rosetta_g_miss_num_map(ddx_complete_rec.ledger_id);
  end;

  procedure validate_category(p_api_version  NUMBER
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
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
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
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_category_rec.category_id := rosetta_g_miss_num_map(p6_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_category_rec.arc_category_created_for := p6_a7;
    ddp_category_rec.enabled_flag := p6_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p6_a9);
    ddp_category_rec.attribute_category := p6_a10;
    ddp_category_rec.attribute1 := p6_a11;
    ddp_category_rec.attribute2 := p6_a12;
    ddp_category_rec.attribute3 := p6_a13;
    ddp_category_rec.attribute4 := p6_a14;
    ddp_category_rec.attribute5 := p6_a15;
    ddp_category_rec.attribute6 := p6_a16;
    ddp_category_rec.attribute7 := p6_a17;
    ddp_category_rec.attribute8 := p6_a18;
    ddp_category_rec.attribute9 := p6_a19;
    ddp_category_rec.attribute10 := p6_a20;
    ddp_category_rec.attribute11 := p6_a21;
    ddp_category_rec.attribute12 := p6_a22;
    ddp_category_rec.attribute13 := p6_a23;
    ddp_category_rec.attribute14 := p6_a24;
    ddp_category_rec.attribute15 := p6_a25;
    ddp_category_rec.source_lang := p6_a26;
    ddp_category_rec.category_name := p6_a27;
    ddp_category_rec.description := p6_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p6_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p6_a30);
    ddp_category_rec.budget_code_suffix := p6_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p6_a32);

    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.validate_category(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_category_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_cty_items(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_category_rec.category_id := rosetta_g_miss_num_map(p0_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_category_rec.arc_category_created_for := p0_a7;
    ddp_category_rec.enabled_flag := p0_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p0_a9);
    ddp_category_rec.attribute_category := p0_a10;
    ddp_category_rec.attribute1 := p0_a11;
    ddp_category_rec.attribute2 := p0_a12;
    ddp_category_rec.attribute3 := p0_a13;
    ddp_category_rec.attribute4 := p0_a14;
    ddp_category_rec.attribute5 := p0_a15;
    ddp_category_rec.attribute6 := p0_a16;
    ddp_category_rec.attribute7 := p0_a17;
    ddp_category_rec.attribute8 := p0_a18;
    ddp_category_rec.attribute9 := p0_a19;
    ddp_category_rec.attribute10 := p0_a20;
    ddp_category_rec.attribute11 := p0_a21;
    ddp_category_rec.attribute12 := p0_a22;
    ddp_category_rec.attribute13 := p0_a23;
    ddp_category_rec.attribute14 := p0_a24;
    ddp_category_rec.attribute15 := p0_a25;
    ddp_category_rec.source_lang := p0_a26;
    ddp_category_rec.category_name := p0_a27;
    ddp_category_rec.description := p0_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p0_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p0_a30);
    ddp_category_rec.budget_code_suffix := p0_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p0_a32);


    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.validate_cty_items(ddp_category_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure validate_cty_record(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_category_rec.category_id := rosetta_g_miss_num_map(p5_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_category_rec.arc_category_created_for := p5_a7;
    ddp_category_rec.enabled_flag := p5_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p5_a9);
    ddp_category_rec.attribute_category := p5_a10;
    ddp_category_rec.attribute1 := p5_a11;
    ddp_category_rec.attribute2 := p5_a12;
    ddp_category_rec.attribute3 := p5_a13;
    ddp_category_rec.attribute4 := p5_a14;
    ddp_category_rec.attribute5 := p5_a15;
    ddp_category_rec.attribute6 := p5_a16;
    ddp_category_rec.attribute7 := p5_a17;
    ddp_category_rec.attribute8 := p5_a18;
    ddp_category_rec.attribute9 := p5_a19;
    ddp_category_rec.attribute10 := p5_a20;
    ddp_category_rec.attribute11 := p5_a21;
    ddp_category_rec.attribute12 := p5_a22;
    ddp_category_rec.attribute13 := p5_a23;
    ddp_category_rec.attribute14 := p5_a24;
    ddp_category_rec.attribute15 := p5_a25;
    ddp_category_rec.source_lang := p5_a26;
    ddp_category_rec.category_name := p5_a27;
    ddp_category_rec.description := p5_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p5_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p5_a30);
    ddp_category_rec.budget_code_suffix := p5_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.validate_cty_record(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_category_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure check_req_cty_items(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_category_rec ams_category_pvt.category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_category_rec.category_id := rosetta_g_miss_num_map(p0_a0);
    ddp_category_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_category_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_category_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_category_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_category_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_category_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_category_rec.arc_category_created_for := p0_a7;
    ddp_category_rec.enabled_flag := p0_a8;
    ddp_category_rec.parent_category_id := rosetta_g_miss_num_map(p0_a9);
    ddp_category_rec.attribute_category := p0_a10;
    ddp_category_rec.attribute1 := p0_a11;
    ddp_category_rec.attribute2 := p0_a12;
    ddp_category_rec.attribute3 := p0_a13;
    ddp_category_rec.attribute4 := p0_a14;
    ddp_category_rec.attribute5 := p0_a15;
    ddp_category_rec.attribute6 := p0_a16;
    ddp_category_rec.attribute7 := p0_a17;
    ddp_category_rec.attribute8 := p0_a18;
    ddp_category_rec.attribute9 := p0_a19;
    ddp_category_rec.attribute10 := p0_a20;
    ddp_category_rec.attribute11 := p0_a21;
    ddp_category_rec.attribute12 := p0_a22;
    ddp_category_rec.attribute13 := p0_a23;
    ddp_category_rec.attribute14 := p0_a24;
    ddp_category_rec.attribute15 := p0_a25;
    ddp_category_rec.source_lang := p0_a26;
    ddp_category_rec.category_name := p0_a27;
    ddp_category_rec.description := p0_a28;
    ddp_category_rec.accrued_liability_account := rosetta_g_miss_num_map(p0_a29);
    ddp_category_rec.ded_adjustment_account := rosetta_g_miss_num_map(p0_a30);
    ddp_category_rec.budget_code_suffix := p0_a31;
    ddp_category_rec.ledger_id := rosetta_g_miss_num_map(p0_a32);


    -- here's the delegated call to the old PL/SQL routine
    ams_category_pvt.check_req_cty_items(ddp_category_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

end ams_category_pvt_w;

/
