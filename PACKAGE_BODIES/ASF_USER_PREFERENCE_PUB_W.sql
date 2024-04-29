--------------------------------------------------------
--  DDL for Package Body ASF_USER_PREFERENCE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_USER_PREFERENCE_PUB_W" as
  /* $Header: asfupfwb.pls 115.3 2003/01/28 22:14:23 avijayak ship $ */
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

  procedure create_preference(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
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
  )

  as
    ddp_user_preference_rec asf_user_preference_pub.user_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_user_preference_rec.preference_id := rosetta_g_miss_num_map(p0_a0);
    ddp_user_preference_rec.user_id := rosetta_g_miss_num_map(p0_a1);
    ddp_user_preference_rec.created_by := rosetta_g_miss_num_map(p0_a2);
    ddp_user_preference_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_user_preference_rec.last_updated_by := rosetta_g_miss_num_map(p0_a4);
    ddp_user_preference_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_user_preference_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_user_preference_rec.owner_table_name := p0_a7;
    ddp_user_preference_rec.owner_table_id := rosetta_g_miss_num_map(p0_a8);
    ddp_user_preference_rec.category := p0_a9;
    ddp_user_preference_rec.preference_code := p0_a10;
    ddp_user_preference_rec.preference_value := p0_a11;
    ddp_user_preference_rec.attribute_category := p0_a12;
    ddp_user_preference_rec.attribute1 := p0_a13;
    ddp_user_preference_rec.attribute2 := p0_a14;
    ddp_user_preference_rec.attribute3 := p0_a15;
    ddp_user_preference_rec.attribute4 := p0_a16;
    ddp_user_preference_rec.attribute5 := p0_a17;
    ddp_user_preference_rec.attribute6 := p0_a18;
    ddp_user_preference_rec.attribute7 := p0_a19;
    ddp_user_preference_rec.attribute8 := p0_a20;
    ddp_user_preference_rec.attribute9 := p0_a21;
    ddp_user_preference_rec.attribute10 := p0_a22;
    ddp_user_preference_rec.attribute11 := p0_a23;
    ddp_user_preference_rec.attribute12 := p0_a24;
    ddp_user_preference_rec.attribute13 := p0_a25;
    ddp_user_preference_rec.attribute14 := p0_a26;
    ddp_user_preference_rec.attribute15 := p0_a27;




    -- here's the delegated call to the old PL/SQL routine
    asf_user_preference_pub.create_preference(ddp_user_preference_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure update_preference(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
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
  )

  as
    ddp_user_preference_rec asf_user_preference_pub.user_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_user_preference_rec.preference_id := rosetta_g_miss_num_map(p0_a0);
    ddp_user_preference_rec.user_id := rosetta_g_miss_num_map(p0_a1);
    ddp_user_preference_rec.created_by := rosetta_g_miss_num_map(p0_a2);
    ddp_user_preference_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_user_preference_rec.last_updated_by := rosetta_g_miss_num_map(p0_a4);
    ddp_user_preference_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_user_preference_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_user_preference_rec.owner_table_name := p0_a7;
    ddp_user_preference_rec.owner_table_id := rosetta_g_miss_num_map(p0_a8);
    ddp_user_preference_rec.category := p0_a9;
    ddp_user_preference_rec.preference_code := p0_a10;
    ddp_user_preference_rec.preference_value := p0_a11;
    ddp_user_preference_rec.attribute_category := p0_a12;
    ddp_user_preference_rec.attribute1 := p0_a13;
    ddp_user_preference_rec.attribute2 := p0_a14;
    ddp_user_preference_rec.attribute3 := p0_a15;
    ddp_user_preference_rec.attribute4 := p0_a16;
    ddp_user_preference_rec.attribute5 := p0_a17;
    ddp_user_preference_rec.attribute6 := p0_a18;
    ddp_user_preference_rec.attribute7 := p0_a19;
    ddp_user_preference_rec.attribute8 := p0_a20;
    ddp_user_preference_rec.attribute9 := p0_a21;
    ddp_user_preference_rec.attribute10 := p0_a22;
    ddp_user_preference_rec.attribute11 := p0_a23;
    ddp_user_preference_rec.attribute12 := p0_a24;
    ddp_user_preference_rec.attribute13 := p0_a25;
    ddp_user_preference_rec.attribute14 := p0_a26;
    ddp_user_preference_rec.attribute15 := p0_a27;




    -- here's the delegated call to the old PL/SQL routine
    asf_user_preference_pub.update_preference(ddp_user_preference_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure delete_preference(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
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
  )

  as
    ddp_user_preference_rec asf_user_preference_pub.user_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_user_preference_rec.preference_id := rosetta_g_miss_num_map(p0_a0);
    ddp_user_preference_rec.user_id := rosetta_g_miss_num_map(p0_a1);
    ddp_user_preference_rec.created_by := rosetta_g_miss_num_map(p0_a2);
    ddp_user_preference_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_user_preference_rec.last_updated_by := rosetta_g_miss_num_map(p0_a4);
    ddp_user_preference_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_user_preference_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_user_preference_rec.owner_table_name := p0_a7;
    ddp_user_preference_rec.owner_table_id := rosetta_g_miss_num_map(p0_a8);
    ddp_user_preference_rec.category := p0_a9;
    ddp_user_preference_rec.preference_code := p0_a10;
    ddp_user_preference_rec.preference_value := p0_a11;
    ddp_user_preference_rec.attribute_category := p0_a12;
    ddp_user_preference_rec.attribute1 := p0_a13;
    ddp_user_preference_rec.attribute2 := p0_a14;
    ddp_user_preference_rec.attribute3 := p0_a15;
    ddp_user_preference_rec.attribute4 := p0_a16;
    ddp_user_preference_rec.attribute5 := p0_a17;
    ddp_user_preference_rec.attribute6 := p0_a18;
    ddp_user_preference_rec.attribute7 := p0_a19;
    ddp_user_preference_rec.attribute8 := p0_a20;
    ddp_user_preference_rec.attribute9 := p0_a21;
    ddp_user_preference_rec.attribute10 := p0_a22;
    ddp_user_preference_rec.attribute11 := p0_a23;
    ddp_user_preference_rec.attribute12 := p0_a24;
    ddp_user_preference_rec.attribute13 := p0_a25;
    ddp_user_preference_rec.attribute14 := p0_a26;
    ddp_user_preference_rec.attribute15 := p0_a27;




    -- here's the delegated call to the old PL/SQL routine
    asf_user_preference_pub.delete_preference(ddp_user_preference_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

end asf_user_preference_pub_w;

/
