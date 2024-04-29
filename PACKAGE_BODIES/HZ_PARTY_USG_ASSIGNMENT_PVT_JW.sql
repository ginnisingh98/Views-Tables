--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USG_ASSIGNMENT_PVT_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USG_ASSIGNMENT_PVT_JW" as
  /* $Header: ARHPUPJB.pls 120.0 2005/05/24 01:29:19 jhuang noship $ */
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

  procedure assign_party_usage_1(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  DATE := null
    , p2_a3  DATE := null
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
    , p2_a28  VARCHAR2 := null
  )
  as
    ddp_party_usg_assignment_rec hz_party_usg_assignment_pvt.party_usg_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_party_usg_assignment_rec.party_id := rosetta_g_miss_num_map(p2_a0);
    ddp_party_usg_assignment_rec.party_usage_code := p2_a1;
    ddp_party_usg_assignment_rec.effective_start_date := rosetta_g_miss_date_in_map(p2_a2);
    ddp_party_usg_assignment_rec.effective_end_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_party_usg_assignment_rec.comments := p2_a4;
    ddp_party_usg_assignment_rec.owner_table_name := p2_a5;
    ddp_party_usg_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p2_a6);
    ddp_party_usg_assignment_rec.created_by_module := p2_a7;
    ddp_party_usg_assignment_rec.attribute_category := p2_a8;
    ddp_party_usg_assignment_rec.attribute1 := p2_a9;
    ddp_party_usg_assignment_rec.attribute2 := p2_a10;
    ddp_party_usg_assignment_rec.attribute3 := p2_a11;
    ddp_party_usg_assignment_rec.attribute4 := p2_a12;
    ddp_party_usg_assignment_rec.attribute5 := p2_a13;
    ddp_party_usg_assignment_rec.attribute6 := p2_a14;
    ddp_party_usg_assignment_rec.attribute7 := p2_a15;
    ddp_party_usg_assignment_rec.attribute8 := p2_a16;
    ddp_party_usg_assignment_rec.attribute9 := p2_a17;
    ddp_party_usg_assignment_rec.attribute10 := p2_a18;
    ddp_party_usg_assignment_rec.attribute11 := p2_a19;
    ddp_party_usg_assignment_rec.attribute12 := p2_a20;
    ddp_party_usg_assignment_rec.attribute13 := p2_a21;
    ddp_party_usg_assignment_rec.attribute14 := p2_a22;
    ddp_party_usg_assignment_rec.attribute15 := p2_a23;
    ddp_party_usg_assignment_rec.attribute16 := p2_a24;
    ddp_party_usg_assignment_rec.attribute17 := p2_a25;
    ddp_party_usg_assignment_rec.attribute18 := p2_a26;
    ddp_party_usg_assignment_rec.attribute19 := p2_a27;
    ddp_party_usg_assignment_rec.attribute20 := p2_a28;




    -- here's the delegated call to the old PL/SQL routine
    hz_party_usg_assignment_pvt.assign_party_usage(p_init_msg_list,
      p_validation_level,
      ddp_party_usg_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_usg_assignment_2(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_party_usg_assignment_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := null
    , p3_a1  VARCHAR2 := null
    , p3_a2  DATE := null
    , p3_a3  DATE := null
    , p3_a4  VARCHAR2 := null
    , p3_a5  VARCHAR2 := null
    , p3_a6  NUMBER := null
    , p3_a7  VARCHAR2 := null
    , p3_a8  VARCHAR2 := null
    , p3_a9  VARCHAR2 := null
    , p3_a10  VARCHAR2 := null
    , p3_a11  VARCHAR2 := null
    , p3_a12  VARCHAR2 := null
    , p3_a13  VARCHAR2 := null
    , p3_a14  VARCHAR2 := null
    , p3_a15  VARCHAR2 := null
    , p3_a16  VARCHAR2 := null
    , p3_a17  VARCHAR2 := null
    , p3_a18  VARCHAR2 := null
    , p3_a19  VARCHAR2 := null
    , p3_a20  VARCHAR2 := null
    , p3_a21  VARCHAR2 := null
    , p3_a22  VARCHAR2 := null
    , p3_a23  VARCHAR2 := null
    , p3_a24  VARCHAR2 := null
    , p3_a25  VARCHAR2 := null
    , p3_a26  VARCHAR2 := null
    , p3_a27  VARCHAR2 := null
    , p3_a28  VARCHAR2 := null
  )
  as
    ddp_party_usg_assignment_rec hz_party_usg_assignment_pvt.party_usg_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_party_usg_assignment_rec.party_id := rosetta_g_miss_num_map(p3_a0);
    ddp_party_usg_assignment_rec.party_usage_code := p3_a1;
    ddp_party_usg_assignment_rec.effective_start_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_party_usg_assignment_rec.effective_end_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_party_usg_assignment_rec.comments := p3_a4;
    ddp_party_usg_assignment_rec.owner_table_name := p3_a5;
    ddp_party_usg_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p3_a6);
    ddp_party_usg_assignment_rec.created_by_module := p3_a7;
    ddp_party_usg_assignment_rec.attribute_category := p3_a8;
    ddp_party_usg_assignment_rec.attribute1 := p3_a9;
    ddp_party_usg_assignment_rec.attribute2 := p3_a10;
    ddp_party_usg_assignment_rec.attribute3 := p3_a11;
    ddp_party_usg_assignment_rec.attribute4 := p3_a12;
    ddp_party_usg_assignment_rec.attribute5 := p3_a13;
    ddp_party_usg_assignment_rec.attribute6 := p3_a14;
    ddp_party_usg_assignment_rec.attribute7 := p3_a15;
    ddp_party_usg_assignment_rec.attribute8 := p3_a16;
    ddp_party_usg_assignment_rec.attribute9 := p3_a17;
    ddp_party_usg_assignment_rec.attribute10 := p3_a18;
    ddp_party_usg_assignment_rec.attribute11 := p3_a19;
    ddp_party_usg_assignment_rec.attribute12 := p3_a20;
    ddp_party_usg_assignment_rec.attribute13 := p3_a21;
    ddp_party_usg_assignment_rec.attribute14 := p3_a22;
    ddp_party_usg_assignment_rec.attribute15 := p3_a23;
    ddp_party_usg_assignment_rec.attribute16 := p3_a24;
    ddp_party_usg_assignment_rec.attribute17 := p3_a25;
    ddp_party_usg_assignment_rec.attribute18 := p3_a26;
    ddp_party_usg_assignment_rec.attribute19 := p3_a27;
    ddp_party_usg_assignment_rec.attribute20 := p3_a28;




    -- here's the delegated call to the old PL/SQL routine
    hz_party_usg_assignment_pvt.update_usg_assignment(p_init_msg_list,
      p_validation_level,
      p_party_usg_assignment_id,
      ddp_party_usg_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end hz_party_usg_assignment_pvt_jw;

/
