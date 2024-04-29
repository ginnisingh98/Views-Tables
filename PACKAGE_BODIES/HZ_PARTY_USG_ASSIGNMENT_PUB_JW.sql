--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USG_ASSIGNMENT_PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USG_ASSIGNMENT_PUB_JW" as
  /* $Header: ARHPUSJB.pls 120.0 2005/05/24 01:36:12 jhuang noship $ */
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  DATE := null
    , p1_a3  DATE := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
  )
  as
    ddp_party_usg_assignment_rec hz_party_usg_assignment_pvt.party_usg_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_party_usg_assignment_rec.party_id := rosetta_g_miss_num_map(p1_a0);
    ddp_party_usg_assignment_rec.party_usage_code := p1_a1;
    ddp_party_usg_assignment_rec.effective_start_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_party_usg_assignment_rec.effective_end_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_party_usg_assignment_rec.comments := p1_a4;
    ddp_party_usg_assignment_rec.owner_table_name := p1_a5;
    ddp_party_usg_assignment_rec.owner_table_id := rosetta_g_miss_num_map(p1_a6);
    ddp_party_usg_assignment_rec.created_by_module := p1_a7;
    ddp_party_usg_assignment_rec.attribute_category := p1_a8;
    ddp_party_usg_assignment_rec.attribute1 := p1_a9;
    ddp_party_usg_assignment_rec.attribute2 := p1_a10;
    ddp_party_usg_assignment_rec.attribute3 := p1_a11;
    ddp_party_usg_assignment_rec.attribute4 := p1_a12;
    ddp_party_usg_assignment_rec.attribute5 := p1_a13;
    ddp_party_usg_assignment_rec.attribute6 := p1_a14;
    ddp_party_usg_assignment_rec.attribute7 := p1_a15;
    ddp_party_usg_assignment_rec.attribute8 := p1_a16;
    ddp_party_usg_assignment_rec.attribute9 := p1_a17;
    ddp_party_usg_assignment_rec.attribute10 := p1_a18;
    ddp_party_usg_assignment_rec.attribute11 := p1_a19;
    ddp_party_usg_assignment_rec.attribute12 := p1_a20;
    ddp_party_usg_assignment_rec.attribute13 := p1_a21;
    ddp_party_usg_assignment_rec.attribute14 := p1_a22;
    ddp_party_usg_assignment_rec.attribute15 := p1_a23;
    ddp_party_usg_assignment_rec.attribute16 := p1_a24;
    ddp_party_usg_assignment_rec.attribute17 := p1_a25;
    ddp_party_usg_assignment_rec.attribute18 := p1_a26;
    ddp_party_usg_assignment_rec.attribute19 := p1_a27;
    ddp_party_usg_assignment_rec.attribute20 := p1_a28;




    -- here's the delegated call to the old PL/SQL routine
    hz_party_usg_assignment_pub.assign_party_usage(p_init_msg_list,
      ddp_party_usg_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure update_usg_assignment_2(p_init_msg_list  VARCHAR2
    , p_party_usg_assignment_id  NUMBER
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
    hz_party_usg_assignment_pub.update_usg_assignment(p_init_msg_list,
      p_party_usg_assignment_id,
      ddp_party_usg_assignment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end hz_party_usg_assignment_pub_jw;

/
