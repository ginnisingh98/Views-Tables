--------------------------------------------------------
--  DDL for Package Body IEX_WEBSWITCH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WEBSWITCH_PVT_W" as
  /* $Header: iexvadtb.pls 120.1 2005/07/06 15:14:19 schekuri noship $ */
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

  procedure create_webswitch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
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
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  DATE := fnd_api.g_miss_date
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  DATE := fnd_api.g_miss_date
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_cgi_switch_rec iex_webswitch_pvt.cgi_switch_rec_type;
    ddp_switch_data_rec iex_webswitch_pvt.switch_data_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cgi_switch_rec.cgi_switch_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cgi_switch_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_cgi_switch_rec.program_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cgi_switch_rec.enabled_flag := p7_a3;
    ddp_cgi_switch_rec.switch_code := p7_a4;
    ddp_cgi_switch_rec.switch_type := p7_a5;
    ddp_cgi_switch_rec.is_required_yn := p7_a6;
    ddp_cgi_switch_rec.sort_order := rosetta_g_miss_num_map(p7_a7);
    ddp_cgi_switch_rec.data_separator := p7_a8;
    ddp_cgi_switch_rec.query_string_id := rosetta_g_miss_num_map(p7_a9);
    ddp_cgi_switch_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_cgi_switch_rec.last_updated_by := rosetta_g_miss_num_map(p7_a11);
    ddp_cgi_switch_rec.creation_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_cgi_switch_rec.created_by := rosetta_g_miss_num_map(p7_a13);
    ddp_cgi_switch_rec.last_update_login := rosetta_g_miss_num_map(p7_a14);
    ddp_cgi_switch_rec.org_id := rosetta_g_miss_num_map(p7_a15);
    ddp_cgi_switch_rec.attribute_category := p7_a16;
    ddp_cgi_switch_rec.attribute1 := p7_a17;
    ddp_cgi_switch_rec.attribute2 := p7_a18;
    ddp_cgi_switch_rec.attribute3 := p7_a19;
    ddp_cgi_switch_rec.attribute4 := p7_a20;
    ddp_cgi_switch_rec.attribute5 := p7_a21;
    ddp_cgi_switch_rec.attribute6 := p7_a22;
    ddp_cgi_switch_rec.attribute7 := p7_a23;
    ddp_cgi_switch_rec.attribute8 := p7_a24;
    ddp_cgi_switch_rec.attribute9 := p7_a25;
    ddp_cgi_switch_rec.attribute10 := p7_a26;
    ddp_cgi_switch_rec.attribute11 := p7_a27;
    ddp_cgi_switch_rec.attribute12 := p7_a28;
    ddp_cgi_switch_rec.attribute13 := p7_a29;
    ddp_cgi_switch_rec.attribute14 := p7_a30;
    ddp_cgi_switch_rec.attribute15 := p7_a31;

    ddp_switch_data_rec.switch_data_id := rosetta_g_miss_num_map(p8_a0);
    ddp_switch_data_rec.program_id := rosetta_g_miss_num_map(p8_a1);
    ddp_switch_data_rec.object_version_number := rosetta_g_miss_num_map(p8_a2);
    ddp_switch_data_rec.first_name_yn := p8_a3;
    ddp_switch_data_rec.last_name_yn := p8_a4;
    ddp_switch_data_rec.address_yn := p8_a5;
    ddp_switch_data_rec.city_yn := p8_a6;
    ddp_switch_data_rec.state_yn := p8_a7;
    ddp_switch_data_rec.zip_yn := p8_a8;
    ddp_switch_data_rec.country_yn := p8_a9;
    ddp_switch_data_rec.sort_order := rosetta_g_miss_num_map(p8_a10);
    ddp_switch_data_rec.enabled_flag := p8_a11;
    ddp_switch_data_rec.cgi_switch_id := rosetta_g_miss_num_map(p8_a12);
    ddp_switch_data_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a13);
    ddp_switch_data_rec.last_updated_by := rosetta_g_miss_num_map(p8_a14);
    ddp_switch_data_rec.creation_date := rosetta_g_miss_date_in_map(p8_a15);
    ddp_switch_data_rec.created_by := rosetta_g_miss_num_map(p8_a16);
    ddp_switch_data_rec.last_update_login := rosetta_g_miss_num_map(p8_a17);
    ddp_switch_data_rec.org_id := rosetta_g_miss_num_map(p8_a18);
    ddp_switch_data_rec.attribute_category := p8_a19;
    ddp_switch_data_rec.attribute1 := p8_a20;
    ddp_switch_data_rec.attribute2 := p8_a21;
    ddp_switch_data_rec.attribute3 := p8_a22;
    ddp_switch_data_rec.attribute4 := p8_a23;
    ddp_switch_data_rec.attribute5 := p8_a24;
    ddp_switch_data_rec.attribute6 := p8_a25;
    ddp_switch_data_rec.attribute7 := p8_a26;
    ddp_switch_data_rec.attribute8 := p8_a27;
    ddp_switch_data_rec.attribute9 := p8_a28;
    ddp_switch_data_rec.attribute10 := p8_a29;
    ddp_switch_data_rec.attribute11 := p8_a30;
    ddp_switch_data_rec.attribute12 := p8_a31;
    ddp_switch_data_rec.attribute13 := p8_a32;
    ddp_switch_data_rec.attribute14 := p8_a33;
    ddp_switch_data_rec.attribute15 := p8_a34;

    -- here's the delegated call to the old PL/SQL routine
    iex_webswitch_pvt.create_webswitch(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgi_switch_rec,
      ddp_switch_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_webswitch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
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
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  DATE := fnd_api.g_miss_date
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  DATE := fnd_api.g_miss_date
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_cgi_switch_rec iex_webswitch_pvt.cgi_switch_rec_type;
    ddp_switch_data_rec iex_webswitch_pvt.switch_data_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cgi_switch_rec.cgi_switch_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cgi_switch_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_cgi_switch_rec.program_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cgi_switch_rec.enabled_flag := p7_a3;
    ddp_cgi_switch_rec.switch_code := p7_a4;
    ddp_cgi_switch_rec.switch_type := p7_a5;
    ddp_cgi_switch_rec.is_required_yn := p7_a6;
    ddp_cgi_switch_rec.sort_order := rosetta_g_miss_num_map(p7_a7);
    ddp_cgi_switch_rec.data_separator := p7_a8;
    ddp_cgi_switch_rec.query_string_id := rosetta_g_miss_num_map(p7_a9);
    ddp_cgi_switch_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_cgi_switch_rec.last_updated_by := rosetta_g_miss_num_map(p7_a11);
    ddp_cgi_switch_rec.creation_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_cgi_switch_rec.created_by := rosetta_g_miss_num_map(p7_a13);
    ddp_cgi_switch_rec.last_update_login := rosetta_g_miss_num_map(p7_a14);
    ddp_cgi_switch_rec.org_id := rosetta_g_miss_num_map(p7_a15);
    ddp_cgi_switch_rec.attribute_category := p7_a16;
    ddp_cgi_switch_rec.attribute1 := p7_a17;
    ddp_cgi_switch_rec.attribute2 := p7_a18;
    ddp_cgi_switch_rec.attribute3 := p7_a19;
    ddp_cgi_switch_rec.attribute4 := p7_a20;
    ddp_cgi_switch_rec.attribute5 := p7_a21;
    ddp_cgi_switch_rec.attribute6 := p7_a22;
    ddp_cgi_switch_rec.attribute7 := p7_a23;
    ddp_cgi_switch_rec.attribute8 := p7_a24;
    ddp_cgi_switch_rec.attribute9 := p7_a25;
    ddp_cgi_switch_rec.attribute10 := p7_a26;
    ddp_cgi_switch_rec.attribute11 := p7_a27;
    ddp_cgi_switch_rec.attribute12 := p7_a28;
    ddp_cgi_switch_rec.attribute13 := p7_a29;
    ddp_cgi_switch_rec.attribute14 := p7_a30;
    ddp_cgi_switch_rec.attribute15 := p7_a31;

    ddp_switch_data_rec.switch_data_id := rosetta_g_miss_num_map(p8_a0);
    ddp_switch_data_rec.program_id := rosetta_g_miss_num_map(p8_a1);
    ddp_switch_data_rec.object_version_number := rosetta_g_miss_num_map(p8_a2);
    ddp_switch_data_rec.first_name_yn := p8_a3;
    ddp_switch_data_rec.last_name_yn := p8_a4;
    ddp_switch_data_rec.address_yn := p8_a5;
    ddp_switch_data_rec.city_yn := p8_a6;
    ddp_switch_data_rec.state_yn := p8_a7;
    ddp_switch_data_rec.zip_yn := p8_a8;
    ddp_switch_data_rec.country_yn := p8_a9;
    ddp_switch_data_rec.sort_order := rosetta_g_miss_num_map(p8_a10);
    ddp_switch_data_rec.enabled_flag := p8_a11;
    ddp_switch_data_rec.cgi_switch_id := rosetta_g_miss_num_map(p8_a12);
    ddp_switch_data_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a13);
    ddp_switch_data_rec.last_updated_by := rosetta_g_miss_num_map(p8_a14);
    ddp_switch_data_rec.creation_date := rosetta_g_miss_date_in_map(p8_a15);
    ddp_switch_data_rec.created_by := rosetta_g_miss_num_map(p8_a16);
    ddp_switch_data_rec.last_update_login := rosetta_g_miss_num_map(p8_a17);
    ddp_switch_data_rec.org_id := rosetta_g_miss_num_map(p8_a18);
    ddp_switch_data_rec.attribute_category := p8_a19;
    ddp_switch_data_rec.attribute1 := p8_a20;
    ddp_switch_data_rec.attribute2 := p8_a21;
    ddp_switch_data_rec.attribute3 := p8_a22;
    ddp_switch_data_rec.attribute4 := p8_a23;
    ddp_switch_data_rec.attribute5 := p8_a24;
    ddp_switch_data_rec.attribute6 := p8_a25;
    ddp_switch_data_rec.attribute7 := p8_a26;
    ddp_switch_data_rec.attribute8 := p8_a27;
    ddp_switch_data_rec.attribute9 := p8_a28;
    ddp_switch_data_rec.attribute10 := p8_a29;
    ddp_switch_data_rec.attribute11 := p8_a30;
    ddp_switch_data_rec.attribute12 := p8_a31;
    ddp_switch_data_rec.attribute13 := p8_a32;
    ddp_switch_data_rec.attribute14 := p8_a33;
    ddp_switch_data_rec.attribute15 := p8_a34;

    -- here's the delegated call to the old PL/SQL routine
    iex_webswitch_pvt.update_webswitch(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgi_switch_rec,
      ddp_switch_data_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end iex_webswitch_pvt_w;

/
