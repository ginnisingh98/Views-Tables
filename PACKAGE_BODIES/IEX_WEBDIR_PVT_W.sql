--------------------------------------------------------
--  DDL for Package Body IEX_WEBDIR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WEBDIR_PVT_W" as
  /* $Header: iexvaddb.pls 120.1 2005/07/06 15:09:18 schekuri noship $ */
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

  procedure create_webassist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  DATE := fnd_api.g_miss_date
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  NUMBER := 0-1962.0724
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  NUMBER := 0-1962.0724
    , p9_a4  DATE := fnd_api.g_miss_date
    , p9_a5  DATE := fnd_api.g_miss_date
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  DATE := fnd_api.g_miss_date
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_assist_rec iex_webdir_pvt.assist_rec_type;
    ddp_web_assist_rec iex_webdir_pvt.web_assist_rec_type;
    ddp_web_search_rec iex_webdir_pvt.web_search_rec_type;
    ddp_query_string_rec iex_webdir_pvt.query_string_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_assist_rec.assist_id := rosetta_g_miss_num_map(p7_a0);
    ddp_assist_rec.program_id := rosetta_g_miss_num_map(p7_a1);
    ddp_assist_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_assist_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_assist_rec.last_updated_by := rosetta_g_miss_num_map(p7_a4);
    ddp_assist_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_assist_rec.created_by := rosetta_g_miss_num_map(p7_a6);
    ddp_assist_rec.last_update_login := rosetta_g_miss_num_map(p7_a7);
    ddp_assist_rec.assistance_type := p7_a8;
    ddp_assist_rec.location := p7_a9;

    ddp_web_assist_rec.web_assist_id := rosetta_g_miss_num_map(p8_a0);
    ddp_web_assist_rec.proxy_host := p8_a1;
    ddp_web_assist_rec.proxy_port := p8_a2;
    ddp_web_assist_rec.enabled_flag := p8_a3;
    ddp_web_assist_rec.program_id := rosetta_g_miss_num_map(p8_a4);
    ddp_web_assist_rec.creation_date := rosetta_g_miss_date_in_map(p8_a5);
    ddp_web_assist_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a6);
    ddp_web_assist_rec.created_by := rosetta_g_miss_num_map(p8_a7);
    ddp_web_assist_rec.last_updated_by := rosetta_g_miss_num_map(p8_a8);
    ddp_web_assist_rec.last_update_login := rosetta_g_miss_num_map(p8_a9);
    ddp_web_assist_rec.assist_id := rosetta_g_miss_num_map(p8_a10);
    ddp_web_assist_rec.object_version_number := rosetta_g_miss_num_map(p8_a11);
    ddp_web_assist_rec.attribute_category := p8_a12;
    ddp_web_assist_rec.attribute1 := p8_a13;
    ddp_web_assist_rec.attribute2 := p8_a14;
    ddp_web_assist_rec.attribute3 := p8_a15;
    ddp_web_assist_rec.attribute4 := p8_a16;
    ddp_web_assist_rec.attribute5 := p8_a17;
    ddp_web_assist_rec.attribute6 := p8_a18;
    ddp_web_assist_rec.attribute7 := p8_a19;
    ddp_web_assist_rec.attribute8 := p8_a20;
    ddp_web_assist_rec.attribute9 := p8_a21;
    ddp_web_assist_rec.attribute10 := p8_a22;
    ddp_web_assist_rec.attribute11 := p8_a23;
    ddp_web_assist_rec.attribute12 := p8_a24;
    ddp_web_assist_rec.attribute13 := p8_a25;
    ddp_web_assist_rec.attribute14 := p8_a26;
    ddp_web_assist_rec.attribute15 := p8_a27;

    ddp_web_search_rec.search_id := rosetta_g_miss_num_map(p9_a0);
    ddp_web_search_rec.enabled_flag := p9_a1;
    ddp_web_search_rec.program_id := rosetta_g_miss_num_map(p9_a2);
    ddp_web_search_rec.object_version_number := rosetta_g_miss_num_map(p9_a3);
    ddp_web_search_rec.creation_date := rosetta_g_miss_date_in_map(p9_a4);
    ddp_web_search_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a5);
    ddp_web_search_rec.created_by := rosetta_g_miss_num_map(p9_a6);
    ddp_web_search_rec.last_updated_by := rosetta_g_miss_num_map(p9_a7);
    ddp_web_search_rec.last_update_login := rosetta_g_miss_num_map(p9_a8);
    ddp_web_search_rec.search_url := p9_a9;
    ddp_web_search_rec.cgi_server := p9_a10;
    ddp_web_search_rec.next_page_ident := p9_a11;
    ddp_web_search_rec.max_nbr_pages := rosetta_g_miss_num_map(p9_a12);
    ddp_web_search_rec.web_assist_id := rosetta_g_miss_num_map(p9_a13);
    ddp_web_search_rec.directory_assist_flag := p9_a14;
    ddp_web_search_rec.attribute_category := p9_a15;
    ddp_web_search_rec.attribute1 := p9_a16;
    ddp_web_search_rec.attribute2 := p9_a17;
    ddp_web_search_rec.attribute3 := p9_a18;
    ddp_web_search_rec.attribute4 := p9_a19;
    ddp_web_search_rec.attribute5 := p9_a20;
    ddp_web_search_rec.attribute6 := p9_a21;
    ddp_web_search_rec.attribute7 := p9_a22;
    ddp_web_search_rec.attribute8 := p9_a23;
    ddp_web_search_rec.attribute9 := p9_a24;
    ddp_web_search_rec.attribute10 := p9_a25;
    ddp_web_search_rec.attribute11 := p9_a26;
    ddp_web_search_rec.attribute12 := p9_a27;
    ddp_web_search_rec.attribute13 := p9_a28;
    ddp_web_search_rec.attribute14 := p9_a29;
    ddp_web_search_rec.attribute15 := p9_a30;

    ddp_query_string_rec.query_string_id := rosetta_g_miss_num_map(p10_a0);
    ddp_query_string_rec.program_id := rosetta_g_miss_num_map(p10_a1);
    ddp_query_string_rec.object_version_number := rosetta_g_miss_num_map(p10_a2);
    ddp_query_string_rec.creation_date := rosetta_g_miss_date_in_map(p10_a3);
    ddp_query_string_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a4);
    ddp_query_string_rec.created_by := rosetta_g_miss_num_map(p10_a5);
    ddp_query_string_rec.last_updated_by := rosetta_g_miss_num_map(p10_a6);
    ddp_query_string_rec.last_update_login := rosetta_g_miss_num_map(p10_a7);
    ddp_query_string_rec.switch_separator := p10_a8;
    ddp_query_string_rec.url_separator := p10_a9;
    ddp_query_string_rec.header_const := p10_a10;
    ddp_query_string_rec.search_id := rosetta_g_miss_num_map(p10_a11);
    ddp_query_string_rec.trailer_const := p10_a12;
    ddp_query_string_rec.enabled_flag := p10_a13;
    ddp_query_string_rec.attribute_category := p10_a14;
    ddp_query_string_rec.attribute1 := p10_a15;
    ddp_query_string_rec.attribute2 := p10_a16;
    ddp_query_string_rec.attribute3 := p10_a17;
    ddp_query_string_rec.attribute4 := p10_a18;
    ddp_query_string_rec.attribute5 := p10_a19;
    ddp_query_string_rec.attribute6 := p10_a20;
    ddp_query_string_rec.attribute7 := p10_a21;
    ddp_query_string_rec.attribute8 := p10_a22;
    ddp_query_string_rec.attribute9 := p10_a23;
    ddp_query_string_rec.attribute10 := p10_a24;
    ddp_query_string_rec.attribute11 := p10_a25;
    ddp_query_string_rec.attribute12 := p10_a26;
    ddp_query_string_rec.attribute13 := p10_a27;
    ddp_query_string_rec.attribute14 := p10_a28;
    ddp_query_string_rec.attribute15 := p10_a29;

    -- here's the delegated call to the old PL/SQL routine
    iex_webdir_pvt.create_webassist(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_assist_rec,
      ddp_web_assist_rec,
      ddp_web_search_rec,
      ddp_query_string_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_webassist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  DATE := fnd_api.g_miss_date
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  NUMBER := 0-1962.0724
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  NUMBER := 0-1962.0724
    , p9_a4  DATE := fnd_api.g_miss_date
    , p9_a5  DATE := fnd_api.g_miss_date
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  DATE := fnd_api.g_miss_date
    , p10_a4  DATE := fnd_api.g_miss_date
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  VARCHAR2 := fnd_api.g_miss_char
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_assist_rec iex_webdir_pvt.assist_rec_type;
    ddp_web_assist_rec iex_webdir_pvt.web_assist_rec_type;
    ddp_web_search_rec iex_webdir_pvt.web_search_rec_type;
    ddp_query_string_rec iex_webdir_pvt.query_string_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_assist_rec.assist_id := rosetta_g_miss_num_map(p7_a0);
    ddp_assist_rec.program_id := rosetta_g_miss_num_map(p7_a1);
    ddp_assist_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_assist_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_assist_rec.last_updated_by := rosetta_g_miss_num_map(p7_a4);
    ddp_assist_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_assist_rec.created_by := rosetta_g_miss_num_map(p7_a6);
    ddp_assist_rec.last_update_login := rosetta_g_miss_num_map(p7_a7);
    ddp_assist_rec.assistance_type := p7_a8;
    ddp_assist_rec.location := p7_a9;

    ddp_web_assist_rec.web_assist_id := rosetta_g_miss_num_map(p8_a0);
    ddp_web_assist_rec.proxy_host := p8_a1;
    ddp_web_assist_rec.proxy_port := p8_a2;
    ddp_web_assist_rec.enabled_flag := p8_a3;
    ddp_web_assist_rec.program_id := rosetta_g_miss_num_map(p8_a4);
    ddp_web_assist_rec.creation_date := rosetta_g_miss_date_in_map(p8_a5);
    ddp_web_assist_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a6);
    ddp_web_assist_rec.created_by := rosetta_g_miss_num_map(p8_a7);
    ddp_web_assist_rec.last_updated_by := rosetta_g_miss_num_map(p8_a8);
    ddp_web_assist_rec.last_update_login := rosetta_g_miss_num_map(p8_a9);
    ddp_web_assist_rec.assist_id := rosetta_g_miss_num_map(p8_a10);
    ddp_web_assist_rec.object_version_number := rosetta_g_miss_num_map(p8_a11);
    ddp_web_assist_rec.attribute_category := p8_a12;
    ddp_web_assist_rec.attribute1 := p8_a13;
    ddp_web_assist_rec.attribute2 := p8_a14;
    ddp_web_assist_rec.attribute3 := p8_a15;
    ddp_web_assist_rec.attribute4 := p8_a16;
    ddp_web_assist_rec.attribute5 := p8_a17;
    ddp_web_assist_rec.attribute6 := p8_a18;
    ddp_web_assist_rec.attribute7 := p8_a19;
    ddp_web_assist_rec.attribute8 := p8_a20;
    ddp_web_assist_rec.attribute9 := p8_a21;
    ddp_web_assist_rec.attribute10 := p8_a22;
    ddp_web_assist_rec.attribute11 := p8_a23;
    ddp_web_assist_rec.attribute12 := p8_a24;
    ddp_web_assist_rec.attribute13 := p8_a25;
    ddp_web_assist_rec.attribute14 := p8_a26;
    ddp_web_assist_rec.attribute15 := p8_a27;

    ddp_web_search_rec.search_id := rosetta_g_miss_num_map(p9_a0);
    ddp_web_search_rec.enabled_flag := p9_a1;
    ddp_web_search_rec.program_id := rosetta_g_miss_num_map(p9_a2);
    ddp_web_search_rec.object_version_number := rosetta_g_miss_num_map(p9_a3);
    ddp_web_search_rec.creation_date := rosetta_g_miss_date_in_map(p9_a4);
    ddp_web_search_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a5);
    ddp_web_search_rec.created_by := rosetta_g_miss_num_map(p9_a6);
    ddp_web_search_rec.last_updated_by := rosetta_g_miss_num_map(p9_a7);
    ddp_web_search_rec.last_update_login := rosetta_g_miss_num_map(p9_a8);
    ddp_web_search_rec.search_url := p9_a9;
    ddp_web_search_rec.cgi_server := p9_a10;
    ddp_web_search_rec.next_page_ident := p9_a11;
    ddp_web_search_rec.max_nbr_pages := rosetta_g_miss_num_map(p9_a12);
    ddp_web_search_rec.web_assist_id := rosetta_g_miss_num_map(p9_a13);
    ddp_web_search_rec.directory_assist_flag := p9_a14;
    ddp_web_search_rec.attribute_category := p9_a15;
    ddp_web_search_rec.attribute1 := p9_a16;
    ddp_web_search_rec.attribute2 := p9_a17;
    ddp_web_search_rec.attribute3 := p9_a18;
    ddp_web_search_rec.attribute4 := p9_a19;
    ddp_web_search_rec.attribute5 := p9_a20;
    ddp_web_search_rec.attribute6 := p9_a21;
    ddp_web_search_rec.attribute7 := p9_a22;
    ddp_web_search_rec.attribute8 := p9_a23;
    ddp_web_search_rec.attribute9 := p9_a24;
    ddp_web_search_rec.attribute10 := p9_a25;
    ddp_web_search_rec.attribute11 := p9_a26;
    ddp_web_search_rec.attribute12 := p9_a27;
    ddp_web_search_rec.attribute13 := p9_a28;
    ddp_web_search_rec.attribute14 := p9_a29;
    ddp_web_search_rec.attribute15 := p9_a30;

    ddp_query_string_rec.query_string_id := rosetta_g_miss_num_map(p10_a0);
    ddp_query_string_rec.program_id := rosetta_g_miss_num_map(p10_a1);
    ddp_query_string_rec.object_version_number := rosetta_g_miss_num_map(p10_a2);
    ddp_query_string_rec.creation_date := rosetta_g_miss_date_in_map(p10_a3);
    ddp_query_string_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a4);
    ddp_query_string_rec.created_by := rosetta_g_miss_num_map(p10_a5);
    ddp_query_string_rec.last_updated_by := rosetta_g_miss_num_map(p10_a6);
    ddp_query_string_rec.last_update_login := rosetta_g_miss_num_map(p10_a7);
    ddp_query_string_rec.switch_separator := p10_a8;
    ddp_query_string_rec.url_separator := p10_a9;
    ddp_query_string_rec.header_const := p10_a10;
    ddp_query_string_rec.search_id := rosetta_g_miss_num_map(p10_a11);
    ddp_query_string_rec.trailer_const := p10_a12;
    ddp_query_string_rec.enabled_flag := p10_a13;
    ddp_query_string_rec.attribute_category := p10_a14;
    ddp_query_string_rec.attribute1 := p10_a15;
    ddp_query_string_rec.attribute2 := p10_a16;
    ddp_query_string_rec.attribute3 := p10_a17;
    ddp_query_string_rec.attribute4 := p10_a18;
    ddp_query_string_rec.attribute5 := p10_a19;
    ddp_query_string_rec.attribute6 := p10_a20;
    ddp_query_string_rec.attribute7 := p10_a21;
    ddp_query_string_rec.attribute8 := p10_a22;
    ddp_query_string_rec.attribute9 := p10_a23;
    ddp_query_string_rec.attribute10 := p10_a24;
    ddp_query_string_rec.attribute11 := p10_a25;
    ddp_query_string_rec.attribute12 := p10_a26;
    ddp_query_string_rec.attribute13 := p10_a27;
    ddp_query_string_rec.attribute14 := p10_a28;
    ddp_query_string_rec.attribute15 := p10_a29;

    -- here's the delegated call to the old PL/SQL routine
    iex_webdir_pvt.update_webassist(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_assist_rec,
      ddp_web_assist_rec,
      ddp_web_search_rec,
      ddp_query_string_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end iex_webdir_pvt_w;

/
