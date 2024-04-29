--------------------------------------------------------
--  DDL for Package Body HZ_ORIG_SYSTEM_REF_PVT_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORIG_SYSTEM_REF_PVT_JW" as
  /* $Header: ARHMOSJB.pls 120.5 2006/05/31 12:17:33 idali noship $ */
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

  procedure create_orig_sys_entity_mapp_1(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
  )
  as
    ddp_orig_sys_entity_map_rec hz_orig_system_ref_pub.orig_sys_entity_map_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_orig_sys_entity_map_rec.orig_system := p2_a0;
    ddp_orig_sys_entity_map_rec.owner_table_name := p2_a1;
    ddp_orig_sys_entity_map_rec.status := p2_a2;
    ddp_orig_sys_entity_map_rec.multiple_flag := p2_a3;
    ddp_orig_sys_entity_map_rec.multi_osr_flag := p2_a4;
    ddp_orig_sys_entity_map_rec.created_by_module := p2_a5;
    ddp_orig_sys_entity_map_rec.application_id := rosetta_g_miss_num_map(p2_a6);
    ddp_orig_sys_entity_map_rec.attribute_category := p2_a7;
    ddp_orig_sys_entity_map_rec.attribute1 := p2_a8;
    ddp_orig_sys_entity_map_rec.attribute2 := p2_a9;
    ddp_orig_sys_entity_map_rec.attribute3 := p2_a10;
    ddp_orig_sys_entity_map_rec.attribute4 := p2_a11;
    ddp_orig_sys_entity_map_rec.attribute5 := p2_a12;
    ddp_orig_sys_entity_map_rec.attribute6 := p2_a13;
    ddp_orig_sys_entity_map_rec.attribute7 := p2_a14;
    ddp_orig_sys_entity_map_rec.attribute8 := p2_a15;
    ddp_orig_sys_entity_map_rec.attribute9 := p2_a16;
    ddp_orig_sys_entity_map_rec.attribute10 := p2_a17;
    ddp_orig_sys_entity_map_rec.attribute11 := p2_a18;
    ddp_orig_sys_entity_map_rec.attribute12 := p2_a19;
    ddp_orig_sys_entity_map_rec.attribute13 := p2_a20;
    ddp_orig_sys_entity_map_rec.attribute14 := p2_a21;
    ddp_orig_sys_entity_map_rec.attribute15 := p2_a22;
    ddp_orig_sys_entity_map_rec.attribute16 := p2_a23;
    ddp_orig_sys_entity_map_rec.attribute17 := p2_a24;
    ddp_orig_sys_entity_map_rec.attribute18 := p2_a25;
    ddp_orig_sys_entity_map_rec.attribute19 := p2_a26;
    ddp_orig_sys_entity_map_rec.attribute20 := p2_a27;




    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.create_orig_sys_entity_mapping(p_init_msg_list,
      p_validation_level,
      ddp_orig_sys_entity_map_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_orig_sys_entity_mapp_2(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
  )
  as
    ddp_orig_sys_entity_map_rec hz_orig_system_ref_pub.orig_sys_entity_map_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_orig_sys_entity_map_rec.orig_system := p2_a0;
    ddp_orig_sys_entity_map_rec.owner_table_name := p2_a1;
    ddp_orig_sys_entity_map_rec.status := p2_a2;
    ddp_orig_sys_entity_map_rec.multiple_flag := p2_a3;
    ddp_orig_sys_entity_map_rec.multi_osr_flag := p2_a4;
    ddp_orig_sys_entity_map_rec.created_by_module := p2_a5;
    ddp_orig_sys_entity_map_rec.application_id := rosetta_g_miss_num_map(p2_a6);
    ddp_orig_sys_entity_map_rec.attribute_category := p2_a7;
    ddp_orig_sys_entity_map_rec.attribute1 := p2_a8;
    ddp_orig_sys_entity_map_rec.attribute2 := p2_a9;
    ddp_orig_sys_entity_map_rec.attribute3 := p2_a10;
    ddp_orig_sys_entity_map_rec.attribute4 := p2_a11;
    ddp_orig_sys_entity_map_rec.attribute5 := p2_a12;
    ddp_orig_sys_entity_map_rec.attribute6 := p2_a13;
    ddp_orig_sys_entity_map_rec.attribute7 := p2_a14;
    ddp_orig_sys_entity_map_rec.attribute8 := p2_a15;
    ddp_orig_sys_entity_map_rec.attribute9 := p2_a16;
    ddp_orig_sys_entity_map_rec.attribute10 := p2_a17;
    ddp_orig_sys_entity_map_rec.attribute11 := p2_a18;
    ddp_orig_sys_entity_map_rec.attribute12 := p2_a19;
    ddp_orig_sys_entity_map_rec.attribute13 := p2_a20;
    ddp_orig_sys_entity_map_rec.attribute14 := p2_a21;
    ddp_orig_sys_entity_map_rec.attribute15 := p2_a22;
    ddp_orig_sys_entity_map_rec.attribute16 := p2_a23;
    ddp_orig_sys_entity_map_rec.attribute17 := p2_a24;
    ddp_orig_sys_entity_map_rec.attribute18 := p2_a25;
    ddp_orig_sys_entity_map_rec.attribute19 := p2_a26;
    ddp_orig_sys_entity_map_rec.attribute20 := p2_a27;





    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.update_orig_sys_entity_mapping(p_init_msg_list,
      p_validation_level,
      ddp_orig_sys_entity_map_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_orig_system_referenc_3(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  NUMBER := null
    , p2_a5  NUMBER := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  DATE := null
    , p2_a10  DATE := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  NUMBER := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  VARCHAR2 := null
    , p2_a30  VARCHAR2 := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
  )
  as
    ddp_orig_sys_reference_rec hz_orig_system_ref_pub.orig_sys_reference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_orig_sys_reference_rec.orig_system_ref_id := rosetta_g_miss_num_map(p2_a0);
    ddp_orig_sys_reference_rec.orig_system := p2_a1;
    ddp_orig_sys_reference_rec.orig_system_reference := p2_a2;
    ddp_orig_sys_reference_rec.owner_table_name := p2_a3;
    ddp_orig_sys_reference_rec.owner_table_id := rosetta_g_miss_num_map(p2_a4);
    ddp_orig_sys_reference_rec.party_id := rosetta_g_miss_num_map(p2_a5);
    ddp_orig_sys_reference_rec.status := p2_a6;
    ddp_orig_sys_reference_rec.reason_code := p2_a7;
    ddp_orig_sys_reference_rec.old_orig_system_reference := p2_a8;
    ddp_orig_sys_reference_rec.start_date_active := rosetta_g_miss_date_in_map(p2_a9);
    ddp_orig_sys_reference_rec.end_date_active := rosetta_g_miss_date_in_map(p2_a10);
    ddp_orig_sys_reference_rec.created_by_module := p2_a11;
    ddp_orig_sys_reference_rec.application_id := rosetta_g_miss_num_map(p2_a12);
    ddp_orig_sys_reference_rec.attribute_category := p2_a13;
    ddp_orig_sys_reference_rec.attribute1 := p2_a14;
    ddp_orig_sys_reference_rec.attribute2 := p2_a15;
    ddp_orig_sys_reference_rec.attribute3 := p2_a16;
    ddp_orig_sys_reference_rec.attribute4 := p2_a17;
    ddp_orig_sys_reference_rec.attribute5 := p2_a18;
    ddp_orig_sys_reference_rec.attribute6 := p2_a19;
    ddp_orig_sys_reference_rec.attribute7 := p2_a20;
    ddp_orig_sys_reference_rec.attribute8 := p2_a21;
    ddp_orig_sys_reference_rec.attribute9 := p2_a22;
    ddp_orig_sys_reference_rec.attribute10 := p2_a23;
    ddp_orig_sys_reference_rec.attribute11 := p2_a24;
    ddp_orig_sys_reference_rec.attribute12 := p2_a25;
    ddp_orig_sys_reference_rec.attribute13 := p2_a26;
    ddp_orig_sys_reference_rec.attribute14 := p2_a27;
    ddp_orig_sys_reference_rec.attribute15 := p2_a28;
    ddp_orig_sys_reference_rec.attribute16 := p2_a29;
    ddp_orig_sys_reference_rec.attribute17 := p2_a30;
    ddp_orig_sys_reference_rec.attribute18 := p2_a31;
    ddp_orig_sys_reference_rec.attribute19 := p2_a32;
    ddp_orig_sys_reference_rec.attribute20 := p2_a33;




    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.create_orig_system_reference(p_init_msg_list,
      p_validation_level,
      ddp_orig_sys_reference_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_orig_system_referenc_4(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  NUMBER := null
    , p2_a5  NUMBER := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  DATE := null
    , p2_a10  DATE := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  NUMBER := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  VARCHAR2 := null
    , p2_a30  VARCHAR2 := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
  )
  as
    ddp_orig_sys_reference_rec hz_orig_system_ref_pub.orig_sys_reference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_orig_sys_reference_rec.orig_system_ref_id := rosetta_g_miss_num_map(p2_a0);
    ddp_orig_sys_reference_rec.orig_system := p2_a1;
    ddp_orig_sys_reference_rec.orig_system_reference := p2_a2;
    ddp_orig_sys_reference_rec.owner_table_name := p2_a3;
    ddp_orig_sys_reference_rec.owner_table_id := rosetta_g_miss_num_map(p2_a4);
    ddp_orig_sys_reference_rec.party_id := rosetta_g_miss_num_map(p2_a5);
    ddp_orig_sys_reference_rec.status := p2_a6;
    ddp_orig_sys_reference_rec.reason_code := p2_a7;
    ddp_orig_sys_reference_rec.old_orig_system_reference := p2_a8;
    ddp_orig_sys_reference_rec.start_date_active := rosetta_g_miss_date_in_map(p2_a9);
    ddp_orig_sys_reference_rec.end_date_active := rosetta_g_miss_date_in_map(p2_a10);
    ddp_orig_sys_reference_rec.created_by_module := p2_a11;
    ddp_orig_sys_reference_rec.application_id := rosetta_g_miss_num_map(p2_a12);
    ddp_orig_sys_reference_rec.attribute_category := p2_a13;
    ddp_orig_sys_reference_rec.attribute1 := p2_a14;
    ddp_orig_sys_reference_rec.attribute2 := p2_a15;
    ddp_orig_sys_reference_rec.attribute3 := p2_a16;
    ddp_orig_sys_reference_rec.attribute4 := p2_a17;
    ddp_orig_sys_reference_rec.attribute5 := p2_a18;
    ddp_orig_sys_reference_rec.attribute6 := p2_a19;
    ddp_orig_sys_reference_rec.attribute7 := p2_a20;
    ddp_orig_sys_reference_rec.attribute8 := p2_a21;
    ddp_orig_sys_reference_rec.attribute9 := p2_a22;
    ddp_orig_sys_reference_rec.attribute10 := p2_a23;
    ddp_orig_sys_reference_rec.attribute11 := p2_a24;
    ddp_orig_sys_reference_rec.attribute12 := p2_a25;
    ddp_orig_sys_reference_rec.attribute13 := p2_a26;
    ddp_orig_sys_reference_rec.attribute14 := p2_a27;
    ddp_orig_sys_reference_rec.attribute15 := p2_a28;
    ddp_orig_sys_reference_rec.attribute16 := p2_a29;
    ddp_orig_sys_reference_rec.attribute17 := p2_a30;
    ddp_orig_sys_reference_rec.attribute18 := p2_a31;
    ddp_orig_sys_reference_rec.attribute19 := p2_a32;
    ddp_orig_sys_reference_rec.attribute20 := p2_a33;





    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.update_orig_system_reference(p_init_msg_list,
      p_validation_level,
      ddp_orig_sys_reference_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure get_orig_sys_reference_rec_5(p_init_msg_list  VARCHAR2
    , p_orig_system_ref_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  DATE
    , p2_a10 out nocopy  DATE
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_orig_sys_reference_rec hz_orig_system_ref_pub.orig_sys_reference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.get_orig_sys_reference_rec(p_init_msg_list,
      p_orig_system_ref_id,
      ddx_orig_sys_reference_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_orig_sys_reference_rec.orig_system_ref_id);
    p2_a1 := ddx_orig_sys_reference_rec.orig_system;
    p2_a2 := ddx_orig_sys_reference_rec.orig_system_reference;
    p2_a3 := ddx_orig_sys_reference_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_orig_sys_reference_rec.owner_table_id);
    p2_a5 := rosetta_g_miss_num_map(ddx_orig_sys_reference_rec.party_id);
    p2_a6 := ddx_orig_sys_reference_rec.status;
    p2_a7 := ddx_orig_sys_reference_rec.reason_code;
    p2_a8 := ddx_orig_sys_reference_rec.old_orig_system_reference;
    p2_a9 := ddx_orig_sys_reference_rec.start_date_active;
    p2_a10 := ddx_orig_sys_reference_rec.end_date_active;
    p2_a11 := ddx_orig_sys_reference_rec.created_by_module;
    p2_a12 := rosetta_g_miss_num_map(ddx_orig_sys_reference_rec.application_id);
    p2_a13 := ddx_orig_sys_reference_rec.attribute_category;
    p2_a14 := ddx_orig_sys_reference_rec.attribute1;
    p2_a15 := ddx_orig_sys_reference_rec.attribute2;
    p2_a16 := ddx_orig_sys_reference_rec.attribute3;
    p2_a17 := ddx_orig_sys_reference_rec.attribute4;
    p2_a18 := ddx_orig_sys_reference_rec.attribute5;
    p2_a19 := ddx_orig_sys_reference_rec.attribute6;
    p2_a20 := ddx_orig_sys_reference_rec.attribute7;
    p2_a21 := ddx_orig_sys_reference_rec.attribute8;
    p2_a22 := ddx_orig_sys_reference_rec.attribute9;
    p2_a23 := ddx_orig_sys_reference_rec.attribute10;
    p2_a24 := ddx_orig_sys_reference_rec.attribute11;
    p2_a25 := ddx_orig_sys_reference_rec.attribute12;
    p2_a26 := ddx_orig_sys_reference_rec.attribute13;
    p2_a27 := ddx_orig_sys_reference_rec.attribute14;
    p2_a28 := ddx_orig_sys_reference_rec.attribute15;
    p2_a29 := ddx_orig_sys_reference_rec.attribute16;
    p2_a30 := ddx_orig_sys_reference_rec.attribute17;
    p2_a31 := ddx_orig_sys_reference_rec.attribute18;
    p2_a32 := ddx_orig_sys_reference_rec.attribute19;
    p2_a33 := ddx_orig_sys_reference_rec.attribute20;



  end;

  procedure create_orig_system_6(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
  )
  as
    ddp_orig_sys_rec hz_orig_system_ref_pvt.orig_sys_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_orig_sys_rec.orig_system_id := rosetta_g_miss_num_map(p2_a0);
    ddp_orig_sys_rec.orig_system := p2_a1;
    ddp_orig_sys_rec.orig_system_name := p2_a2;
    ddp_orig_sys_rec.description := p2_a3;
    ddp_orig_sys_rec.orig_system_type := p2_a4;
    ddp_orig_sys_rec.sst_flag := p2_a5;
    ddp_orig_sys_rec.status := p2_a6;
    ddp_orig_sys_rec.created_by_module := p2_a7;
    ddp_orig_sys_rec.attribute_category := p2_a8;
    ddp_orig_sys_rec.attribute1 := p2_a9;
    ddp_orig_sys_rec.attribute2 := p2_a10;
    ddp_orig_sys_rec.attribute3 := p2_a11;
    ddp_orig_sys_rec.attribute4 := p2_a12;
    ddp_orig_sys_rec.attribute5 := p2_a13;
    ddp_orig_sys_rec.attribute6 := p2_a14;
    ddp_orig_sys_rec.attribute7 := p2_a15;
    ddp_orig_sys_rec.attribute8 := p2_a16;
    ddp_orig_sys_rec.attribute9 := p2_a17;
    ddp_orig_sys_rec.attribute10 := p2_a18;
    ddp_orig_sys_rec.attribute11 := p2_a19;
    ddp_orig_sys_rec.attribute12 := p2_a20;
    ddp_orig_sys_rec.attribute13 := p2_a21;
    ddp_orig_sys_rec.attribute14 := p2_a22;
    ddp_orig_sys_rec.attribute15 := p2_a23;
    ddp_orig_sys_rec.attribute16 := p2_a24;
    ddp_orig_sys_rec.attribute17 := p2_a25;
    ddp_orig_sys_rec.attribute18 := p2_a26;
    ddp_orig_sys_rec.attribute19 := p2_a27;
    ddp_orig_sys_rec.attribute20 := p2_a28;




    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.create_orig_system(p_init_msg_list,
      p_validation_level,
      ddp_orig_sys_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_orig_system_7(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
  )
  as
    ddp_orig_sys_rec hz_orig_system_ref_pvt.orig_sys_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_orig_sys_rec.orig_system_id := rosetta_g_miss_num_map(p2_a0);
    ddp_orig_sys_rec.orig_system := p2_a1;
    ddp_orig_sys_rec.orig_system_name := p2_a2;
    ddp_orig_sys_rec.description := p2_a3;
    ddp_orig_sys_rec.orig_system_type := p2_a4;
    ddp_orig_sys_rec.sst_flag := p2_a5;
    ddp_orig_sys_rec.status := p2_a6;
    ddp_orig_sys_rec.created_by_module := p2_a7;
    ddp_orig_sys_rec.attribute_category := p2_a8;
    ddp_orig_sys_rec.attribute1 := p2_a9;
    ddp_orig_sys_rec.attribute2 := p2_a10;
    ddp_orig_sys_rec.attribute3 := p2_a11;
    ddp_orig_sys_rec.attribute4 := p2_a12;
    ddp_orig_sys_rec.attribute5 := p2_a13;
    ddp_orig_sys_rec.attribute6 := p2_a14;
    ddp_orig_sys_rec.attribute7 := p2_a15;
    ddp_orig_sys_rec.attribute8 := p2_a16;
    ddp_orig_sys_rec.attribute9 := p2_a17;
    ddp_orig_sys_rec.attribute10 := p2_a18;
    ddp_orig_sys_rec.attribute11 := p2_a19;
    ddp_orig_sys_rec.attribute12 := p2_a20;
    ddp_orig_sys_rec.attribute13 := p2_a21;
    ddp_orig_sys_rec.attribute14 := p2_a22;
    ddp_orig_sys_rec.attribute15 := p2_a23;
    ddp_orig_sys_rec.attribute16 := p2_a24;
    ddp_orig_sys_rec.attribute17 := p2_a25;
    ddp_orig_sys_rec.attribute18 := p2_a26;
    ddp_orig_sys_rec.attribute19 := p2_a27;
    ddp_orig_sys_rec.attribute20 := p2_a28;





    -- here's the delegated call to the old PL/SQL routine
    hz_orig_system_ref_pvt.update_orig_system(p_init_msg_list,
      p_validation_level,
      ddp_orig_sys_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end hz_orig_system_ref_pvt_jw;

/
