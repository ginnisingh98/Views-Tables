--------------------------------------------------------
--  DDL for Package Body AMS_ATTACHMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ATTACHMENT_PVT_W" as
  /* $Header: amswatcb.pls 115.4 2003/05/06 12:46:50 mayjain ship $ */
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

  procedure create_fnd_attachment(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_document_id out nocopy  NUMBER
    , x_attached_document_id out nocopy  NUMBER
    , p7_a0  VARCHAR2 := fnd_api.g_miss_char
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_fnd_attachment_rec ams_attachment_pvt.fnd_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_fnd_attachment_rec.rowid := p7_a0;
    ddp_fnd_attachment_rec.document_id := rosetta_g_miss_num_map(p7_a1);
    ddp_fnd_attachment_rec.datatype_id := rosetta_g_miss_num_map(p7_a2);
    ddp_fnd_attachment_rec.category_id := rosetta_g_miss_num_map(p7_a3);
    ddp_fnd_attachment_rec.security_type := rosetta_g_miss_num_map(p7_a4);
    ddp_fnd_attachment_rec.publish_flag := p7_a5;
    ddp_fnd_attachment_rec.description := p7_a6;
    ddp_fnd_attachment_rec.file_name := p7_a7;
    ddp_fnd_attachment_rec.media_id := rosetta_g_miss_num_map(p7_a8);
    ddp_fnd_attachment_rec.file_size := p7_a9;
    ddp_fnd_attachment_rec.attached_document_id := rosetta_g_miss_num_map(p7_a10);
    ddp_fnd_attachment_rec.seq_num := rosetta_g_miss_num_map(p7_a11);
    ddp_fnd_attachment_rec.entity_name := p7_a12;
    ddp_fnd_attachment_rec.pk1_value := p7_a13;
    ddp_fnd_attachment_rec.automatically_added_flag := p7_a14;
    ddp_fnd_attachment_rec.short_text := p7_a15;
    ddp_fnd_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_fnd_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_fnd_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_fnd_attachment_rec.created_by := rosetta_g_miss_num_map(p7_a19);
    ddp_fnd_attachment_rec.last_update_login := rosetta_g_miss_num_map(p7_a20);
    ddp_fnd_attachment_rec.attachment_type := p7_a21;
    ddp_fnd_attachment_rec.language := p7_a22;
    ddp_fnd_attachment_rec.usage_type := p7_a23;
    ddp_fnd_attachment_rec.concur_last_update_date := rosetta_g_miss_date_in_map(p7_a24);



    -- here's the delegated call to the old PL/SQL routine
    ams_attachment_pvt.create_fnd_attachment(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fnd_attachment_rec,
      x_document_id,
      x_attached_document_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_fnd_attachment(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2 := fnd_api.g_miss_char
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_fnd_attachment_rec ams_attachment_pvt.fnd_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_fnd_attachment_rec.rowid := p7_a0;
    ddp_fnd_attachment_rec.document_id := rosetta_g_miss_num_map(p7_a1);
    ddp_fnd_attachment_rec.datatype_id := rosetta_g_miss_num_map(p7_a2);
    ddp_fnd_attachment_rec.category_id := rosetta_g_miss_num_map(p7_a3);
    ddp_fnd_attachment_rec.security_type := rosetta_g_miss_num_map(p7_a4);
    ddp_fnd_attachment_rec.publish_flag := p7_a5;
    ddp_fnd_attachment_rec.description := p7_a6;
    ddp_fnd_attachment_rec.file_name := p7_a7;
    ddp_fnd_attachment_rec.media_id := rosetta_g_miss_num_map(p7_a8);
    ddp_fnd_attachment_rec.file_size := p7_a9;
    ddp_fnd_attachment_rec.attached_document_id := rosetta_g_miss_num_map(p7_a10);
    ddp_fnd_attachment_rec.seq_num := rosetta_g_miss_num_map(p7_a11);
    ddp_fnd_attachment_rec.entity_name := p7_a12;
    ddp_fnd_attachment_rec.pk1_value := p7_a13;
    ddp_fnd_attachment_rec.automatically_added_flag := p7_a14;
    ddp_fnd_attachment_rec.short_text := p7_a15;
    ddp_fnd_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_fnd_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_fnd_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_fnd_attachment_rec.created_by := rosetta_g_miss_num_map(p7_a19);
    ddp_fnd_attachment_rec.last_update_login := rosetta_g_miss_num_map(p7_a20);
    ddp_fnd_attachment_rec.attachment_type := p7_a21;
    ddp_fnd_attachment_rec.language := p7_a22;
    ddp_fnd_attachment_rec.usage_type := p7_a23;
    ddp_fnd_attachment_rec.concur_last_update_date := rosetta_g_miss_date_in_map(p7_a24);

    -- here's the delegated call to the old PL/SQL routine
    ams_attachment_pvt.update_fnd_attachment(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fnd_attachment_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ams_attachment_pvt_w;

/
