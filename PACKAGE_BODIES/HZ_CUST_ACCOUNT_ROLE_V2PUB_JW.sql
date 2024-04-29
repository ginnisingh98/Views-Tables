--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCOUNT_ROLE_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCOUNT_ROLE_V2PUB_JW" as
  /* $Header: ARH2CRJB.pls 120.3 2005/06/18 04:27:50 jhuang noship $ */
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

  procedure create_cust_account_role_1(p_init_msg_list  VARCHAR2
    , x_cust_account_role_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
  )
  as
    ddp_cust_account_role_rec hz_cust_account_role_v2pub.cust_account_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_account_role_rec.cust_account_role_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_account_role_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_account_role_rec.cust_account_id := rosetta_g_miss_num_map(p1_a2);
    ddp_cust_account_role_rec.cust_acct_site_id := rosetta_g_miss_num_map(p1_a3);
    ddp_cust_account_role_rec.primary_flag := p1_a4;
    ddp_cust_account_role_rec.role_type := p1_a5;
    ddp_cust_account_role_rec.source_code := p1_a6;
    ddp_cust_account_role_rec.attribute_category := p1_a7;
    ddp_cust_account_role_rec.attribute1 := p1_a8;
    ddp_cust_account_role_rec.attribute2 := p1_a9;
    ddp_cust_account_role_rec.attribute3 := p1_a10;
    ddp_cust_account_role_rec.attribute4 := p1_a11;
    ddp_cust_account_role_rec.attribute5 := p1_a12;
    ddp_cust_account_role_rec.attribute6 := p1_a13;
    ddp_cust_account_role_rec.attribute7 := p1_a14;
    ddp_cust_account_role_rec.attribute8 := p1_a15;
    ddp_cust_account_role_rec.attribute9 := p1_a16;
    ddp_cust_account_role_rec.attribute10 := p1_a17;
    ddp_cust_account_role_rec.attribute11 := p1_a18;
    ddp_cust_account_role_rec.attribute12 := p1_a19;
    ddp_cust_account_role_rec.attribute13 := p1_a20;
    ddp_cust_account_role_rec.attribute14 := p1_a21;
    ddp_cust_account_role_rec.attribute15 := p1_a22;
    ddp_cust_account_role_rec.attribute16 := p1_a23;
    ddp_cust_account_role_rec.attribute17 := p1_a24;
    ddp_cust_account_role_rec.attribute18 := p1_a25;
    ddp_cust_account_role_rec.attribute19 := p1_a26;
    ddp_cust_account_role_rec.attribute20 := p1_a27;
    ddp_cust_account_role_rec.attribute21 := p1_a28;
    ddp_cust_account_role_rec.attribute22 := p1_a29;
    ddp_cust_account_role_rec.attribute23 := p1_a30;
    ddp_cust_account_role_rec.attribute24 := p1_a31;
    ddp_cust_account_role_rec.orig_system_reference := p1_a32;
    ddp_cust_account_role_rec.orig_system := p1_a33;
    ddp_cust_account_role_rec.attribute25 := p1_a34;
    ddp_cust_account_role_rec.status := p1_a35;
    ddp_cust_account_role_rec.created_by_module := p1_a36;
    ddp_cust_account_role_rec.application_id := rosetta_g_miss_num_map(p1_a37);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_role_v2pub.create_cust_account_role(p_init_msg_list,
      ddp_cust_account_role_rec,
      x_cust_account_role_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_cust_account_role_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  NUMBER := null
  )
  as
    ddp_cust_account_role_rec hz_cust_account_role_v2pub.cust_account_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_account_role_rec.cust_account_role_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_account_role_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_account_role_rec.cust_account_id := rosetta_g_miss_num_map(p1_a2);
    ddp_cust_account_role_rec.cust_acct_site_id := rosetta_g_miss_num_map(p1_a3);
    ddp_cust_account_role_rec.primary_flag := p1_a4;
    ddp_cust_account_role_rec.role_type := p1_a5;
    ddp_cust_account_role_rec.source_code := p1_a6;
    ddp_cust_account_role_rec.attribute_category := p1_a7;
    ddp_cust_account_role_rec.attribute1 := p1_a8;
    ddp_cust_account_role_rec.attribute2 := p1_a9;
    ddp_cust_account_role_rec.attribute3 := p1_a10;
    ddp_cust_account_role_rec.attribute4 := p1_a11;
    ddp_cust_account_role_rec.attribute5 := p1_a12;
    ddp_cust_account_role_rec.attribute6 := p1_a13;
    ddp_cust_account_role_rec.attribute7 := p1_a14;
    ddp_cust_account_role_rec.attribute8 := p1_a15;
    ddp_cust_account_role_rec.attribute9 := p1_a16;
    ddp_cust_account_role_rec.attribute10 := p1_a17;
    ddp_cust_account_role_rec.attribute11 := p1_a18;
    ddp_cust_account_role_rec.attribute12 := p1_a19;
    ddp_cust_account_role_rec.attribute13 := p1_a20;
    ddp_cust_account_role_rec.attribute14 := p1_a21;
    ddp_cust_account_role_rec.attribute15 := p1_a22;
    ddp_cust_account_role_rec.attribute16 := p1_a23;
    ddp_cust_account_role_rec.attribute17 := p1_a24;
    ddp_cust_account_role_rec.attribute18 := p1_a25;
    ddp_cust_account_role_rec.attribute19 := p1_a26;
    ddp_cust_account_role_rec.attribute20 := p1_a27;
    ddp_cust_account_role_rec.attribute21 := p1_a28;
    ddp_cust_account_role_rec.attribute22 := p1_a29;
    ddp_cust_account_role_rec.attribute23 := p1_a30;
    ddp_cust_account_role_rec.attribute24 := p1_a31;
    ddp_cust_account_role_rec.orig_system_reference := p1_a32;
    ddp_cust_account_role_rec.orig_system := p1_a33;
    ddp_cust_account_role_rec.attribute25 := p1_a34;
    ddp_cust_account_role_rec.status := p1_a35;
    ddp_cust_account_role_rec.created_by_module := p1_a36;
    ddp_cust_account_role_rec.application_id := rosetta_g_miss_num_map(p1_a37);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_role_v2pub.update_cust_account_role(p_init_msg_list,
      ddp_cust_account_role_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_cust_account_role_rec_3(p_init_msg_list  VARCHAR2
    , p_cust_account_role_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  NUMBER
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
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
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_cust_account_role_rec hz_cust_account_role_v2pub.cust_account_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_role_v2pub.get_cust_account_role_rec(p_init_msg_list,
      p_cust_account_role_id,
      ddx_cust_account_role_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_cust_account_role_rec.cust_account_role_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_cust_account_role_rec.party_id);
    p2_a2 := rosetta_g_miss_num_map(ddx_cust_account_role_rec.cust_account_id);
    p2_a3 := rosetta_g_miss_num_map(ddx_cust_account_role_rec.cust_acct_site_id);
    p2_a4 := ddx_cust_account_role_rec.primary_flag;
    p2_a5 := ddx_cust_account_role_rec.role_type;
    p2_a6 := ddx_cust_account_role_rec.source_code;
    p2_a7 := ddx_cust_account_role_rec.attribute_category;
    p2_a8 := ddx_cust_account_role_rec.attribute1;
    p2_a9 := ddx_cust_account_role_rec.attribute2;
    p2_a10 := ddx_cust_account_role_rec.attribute3;
    p2_a11 := ddx_cust_account_role_rec.attribute4;
    p2_a12 := ddx_cust_account_role_rec.attribute5;
    p2_a13 := ddx_cust_account_role_rec.attribute6;
    p2_a14 := ddx_cust_account_role_rec.attribute7;
    p2_a15 := ddx_cust_account_role_rec.attribute8;
    p2_a16 := ddx_cust_account_role_rec.attribute9;
    p2_a17 := ddx_cust_account_role_rec.attribute10;
    p2_a18 := ddx_cust_account_role_rec.attribute11;
    p2_a19 := ddx_cust_account_role_rec.attribute12;
    p2_a20 := ddx_cust_account_role_rec.attribute13;
    p2_a21 := ddx_cust_account_role_rec.attribute14;
    p2_a22 := ddx_cust_account_role_rec.attribute15;
    p2_a23 := ddx_cust_account_role_rec.attribute16;
    p2_a24 := ddx_cust_account_role_rec.attribute17;
    p2_a25 := ddx_cust_account_role_rec.attribute18;
    p2_a26 := ddx_cust_account_role_rec.attribute19;
    p2_a27 := ddx_cust_account_role_rec.attribute20;
    p2_a28 := ddx_cust_account_role_rec.attribute21;
    p2_a29 := ddx_cust_account_role_rec.attribute22;
    p2_a30 := ddx_cust_account_role_rec.attribute23;
    p2_a31 := ddx_cust_account_role_rec.attribute24;
    p2_a32 := ddx_cust_account_role_rec.orig_system_reference;
    p2_a33 := ddx_cust_account_role_rec.orig_system;
    p2_a34 := ddx_cust_account_role_rec.attribute25;
    p2_a35 := ddx_cust_account_role_rec.status;
    p2_a36 := ddx_cust_account_role_rec.created_by_module;
    p2_a37 := rosetta_g_miss_num_map(ddx_cust_account_role_rec.application_id);



  end;

  procedure create_role_responsibility_4(p_init_msg_list  VARCHAR2
    , x_responsibility_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a22  NUMBER := null
  )
  as
    ddp_role_responsibility_rec hz_cust_account_role_v2pub.role_responsibility_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_role_responsibility_rec.responsibility_id := rosetta_g_miss_num_map(p1_a0);
    ddp_role_responsibility_rec.cust_account_role_id := rosetta_g_miss_num_map(p1_a1);
    ddp_role_responsibility_rec.responsibility_type := p1_a2;
    ddp_role_responsibility_rec.primary_flag := p1_a3;
    ddp_role_responsibility_rec.attribute_category := p1_a4;
    ddp_role_responsibility_rec.attribute1 := p1_a5;
    ddp_role_responsibility_rec.attribute2 := p1_a6;
    ddp_role_responsibility_rec.attribute3 := p1_a7;
    ddp_role_responsibility_rec.attribute4 := p1_a8;
    ddp_role_responsibility_rec.attribute5 := p1_a9;
    ddp_role_responsibility_rec.attribute6 := p1_a10;
    ddp_role_responsibility_rec.attribute7 := p1_a11;
    ddp_role_responsibility_rec.attribute8 := p1_a12;
    ddp_role_responsibility_rec.attribute9 := p1_a13;
    ddp_role_responsibility_rec.attribute10 := p1_a14;
    ddp_role_responsibility_rec.attribute11 := p1_a15;
    ddp_role_responsibility_rec.attribute12 := p1_a16;
    ddp_role_responsibility_rec.attribute13 := p1_a17;
    ddp_role_responsibility_rec.attribute14 := p1_a18;
    ddp_role_responsibility_rec.attribute15 := p1_a19;
    ddp_role_responsibility_rec.orig_system_reference := p1_a20;
    ddp_role_responsibility_rec.created_by_module := p1_a21;
    ddp_role_responsibility_rec.application_id := rosetta_g_miss_num_map(p1_a22);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_role_v2pub.create_role_responsibility(p_init_msg_list,
      ddp_role_responsibility_rec,
      x_responsibility_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_role_responsibility_5(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
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
    , p1_a22  NUMBER := null
  )
  as
    ddp_role_responsibility_rec hz_cust_account_role_v2pub.role_responsibility_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_role_responsibility_rec.responsibility_id := rosetta_g_miss_num_map(p1_a0);
    ddp_role_responsibility_rec.cust_account_role_id := rosetta_g_miss_num_map(p1_a1);
    ddp_role_responsibility_rec.responsibility_type := p1_a2;
    ddp_role_responsibility_rec.primary_flag := p1_a3;
    ddp_role_responsibility_rec.attribute_category := p1_a4;
    ddp_role_responsibility_rec.attribute1 := p1_a5;
    ddp_role_responsibility_rec.attribute2 := p1_a6;
    ddp_role_responsibility_rec.attribute3 := p1_a7;
    ddp_role_responsibility_rec.attribute4 := p1_a8;
    ddp_role_responsibility_rec.attribute5 := p1_a9;
    ddp_role_responsibility_rec.attribute6 := p1_a10;
    ddp_role_responsibility_rec.attribute7 := p1_a11;
    ddp_role_responsibility_rec.attribute8 := p1_a12;
    ddp_role_responsibility_rec.attribute9 := p1_a13;
    ddp_role_responsibility_rec.attribute10 := p1_a14;
    ddp_role_responsibility_rec.attribute11 := p1_a15;
    ddp_role_responsibility_rec.attribute12 := p1_a16;
    ddp_role_responsibility_rec.attribute13 := p1_a17;
    ddp_role_responsibility_rec.attribute14 := p1_a18;
    ddp_role_responsibility_rec.attribute15 := p1_a19;
    ddp_role_responsibility_rec.orig_system_reference := p1_a20;
    ddp_role_responsibility_rec.created_by_module := p1_a21;
    ddp_role_responsibility_rec.application_id := rosetta_g_miss_num_map(p1_a22);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_role_v2pub.update_role_responsibility(p_init_msg_list,
      ddp_role_responsibility_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_role_responsibility_rec_6(p_init_msg_list  VARCHAR2
    , p_responsibility_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_role_responsibility_rec hz_cust_account_role_v2pub.role_responsibility_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_role_v2pub.get_role_responsibility_rec(p_init_msg_list,
      p_responsibility_id,
      ddx_role_responsibility_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_role_responsibility_rec.responsibility_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_role_responsibility_rec.cust_account_role_id);
    p2_a2 := ddx_role_responsibility_rec.responsibility_type;
    p2_a3 := ddx_role_responsibility_rec.primary_flag;
    p2_a4 := ddx_role_responsibility_rec.attribute_category;
    p2_a5 := ddx_role_responsibility_rec.attribute1;
    p2_a6 := ddx_role_responsibility_rec.attribute2;
    p2_a7 := ddx_role_responsibility_rec.attribute3;
    p2_a8 := ddx_role_responsibility_rec.attribute4;
    p2_a9 := ddx_role_responsibility_rec.attribute5;
    p2_a10 := ddx_role_responsibility_rec.attribute6;
    p2_a11 := ddx_role_responsibility_rec.attribute7;
    p2_a12 := ddx_role_responsibility_rec.attribute8;
    p2_a13 := ddx_role_responsibility_rec.attribute9;
    p2_a14 := ddx_role_responsibility_rec.attribute10;
    p2_a15 := ddx_role_responsibility_rec.attribute11;
    p2_a16 := ddx_role_responsibility_rec.attribute12;
    p2_a17 := ddx_role_responsibility_rec.attribute13;
    p2_a18 := ddx_role_responsibility_rec.attribute14;
    p2_a19 := ddx_role_responsibility_rec.attribute15;
    p2_a20 := ddx_role_responsibility_rec.orig_system_reference;
    p2_a21 := ddx_role_responsibility_rec.created_by_module;
    p2_a22 := rosetta_g_miss_num_map(ddx_role_responsibility_rec.application_id);



  end;

end hz_cust_account_role_v2pub_jw;

/
