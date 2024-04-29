--------------------------------------------------------
--  DDL for Package Body JTF_AMV_ATTACHMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AMV_ATTACHMENT_PUB_W" as
  /* $Header: jtfpatwb.pls 120.3 2005/09/13 11:10:04 vimohan ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure create_act_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_act_attachment_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_attachment_rec.attachment_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_attachment_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_attachment_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_attachment_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_attachment_rec.owner_user_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_attachment_rec.attachment_used_by_id := rosetta_g_miss_num_map(p7_a8);
    ddp_act_attachment_rec.attachment_used_by := p7_a9;
    ddp_act_attachment_rec.version := p7_a10;
    ddp_act_attachment_rec.enabled_flag := p7_a11;
    ddp_act_attachment_rec.can_fulfill_electronic_flag := p7_a12;
    ddp_act_attachment_rec.file_id := rosetta_g_miss_num_map(p7_a13);
    ddp_act_attachment_rec.file_name := p7_a14;
    ddp_act_attachment_rec.file_extension := p7_a15;
    ddp_act_attachment_rec.document_id := rosetta_g_miss_num_map(p7_a16);
    ddp_act_attachment_rec.keywords := p7_a17;
    ddp_act_attachment_rec.display_width := rosetta_g_miss_num_map(p7_a18);
    ddp_act_attachment_rec.display_height := rosetta_g_miss_num_map(p7_a19);
    ddp_act_attachment_rec.display_location := p7_a20;
    ddp_act_attachment_rec.link_to := p7_a21;
    ddp_act_attachment_rec.link_url := p7_a22;
    ddp_act_attachment_rec.send_for_preview_flag := p7_a23;
    ddp_act_attachment_rec.attachment_type := p7_a24;
    ddp_act_attachment_rec.language_code := p7_a25;
    ddp_act_attachment_rec.application_id := rosetta_g_miss_num_map(p7_a26);
    ddp_act_attachment_rec.description := p7_a27;
    ddp_act_attachment_rec.default_style_sheet := p7_a28;
    ddp_act_attachment_rec.display_url := p7_a29;
    ddp_act_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p7_a30);
    ddp_act_attachment_rec.display_program := p7_a31;
    ddp_act_attachment_rec.attribute_category := p7_a32;
    ddp_act_attachment_rec.attribute1 := p7_a33;
    ddp_act_attachment_rec.attribute2 := p7_a34;
    ddp_act_attachment_rec.attribute3 := p7_a35;
    ddp_act_attachment_rec.attribute4 := p7_a36;
    ddp_act_attachment_rec.attribute5 := p7_a37;
    ddp_act_attachment_rec.attribute6 := p7_a38;
    ddp_act_attachment_rec.attribute7 := p7_a39;
    ddp_act_attachment_rec.attribute8 := p7_a40;
    ddp_act_attachment_rec.attribute9 := p7_a41;
    ddp_act_attachment_rec.attribute10 := p7_a42;
    ddp_act_attachment_rec.attribute11 := p7_a43;
    ddp_act_attachment_rec.attribute12 := p7_a44;
    ddp_act_attachment_rec.attribute13 := p7_a45;
    ddp_act_attachment_rec.attribute14 := p7_a46;
    ddp_act_attachment_rec.attribute15 := p7_a47;
    ddp_act_attachment_rec.display_text := p7_a48;
    ddp_act_attachment_rec.alternate_text := p7_a49;
    ddp_act_attachment_rec.secured_flag := p7_a50;
    ddp_act_attachment_rec.attachment_sub_type := p7_a51;


    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.create_act_attachment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_attachment_rec,
      x_act_attachment_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_act_attachment(p_api_version  NUMBER
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
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_attachment_rec.attachment_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_attachment_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_attachment_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_attachment_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_attachment_rec.owner_user_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_attachment_rec.attachment_used_by_id := rosetta_g_miss_num_map(p7_a8);
    ddp_act_attachment_rec.attachment_used_by := p7_a9;
    ddp_act_attachment_rec.version := p7_a10;
    ddp_act_attachment_rec.enabled_flag := p7_a11;
    ddp_act_attachment_rec.can_fulfill_electronic_flag := p7_a12;
    ddp_act_attachment_rec.file_id := rosetta_g_miss_num_map(p7_a13);
    ddp_act_attachment_rec.file_name := p7_a14;
    ddp_act_attachment_rec.file_extension := p7_a15;
    ddp_act_attachment_rec.document_id := rosetta_g_miss_num_map(p7_a16);
    ddp_act_attachment_rec.keywords := p7_a17;
    ddp_act_attachment_rec.display_width := rosetta_g_miss_num_map(p7_a18);
    ddp_act_attachment_rec.display_height := rosetta_g_miss_num_map(p7_a19);
    ddp_act_attachment_rec.display_location := p7_a20;
    ddp_act_attachment_rec.link_to := p7_a21;
    ddp_act_attachment_rec.link_url := p7_a22;
    ddp_act_attachment_rec.send_for_preview_flag := p7_a23;
    ddp_act_attachment_rec.attachment_type := p7_a24;
    ddp_act_attachment_rec.language_code := p7_a25;
    ddp_act_attachment_rec.application_id := rosetta_g_miss_num_map(p7_a26);
    ddp_act_attachment_rec.description := p7_a27;
    ddp_act_attachment_rec.default_style_sheet := p7_a28;
    ddp_act_attachment_rec.display_url := p7_a29;
    ddp_act_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p7_a30);
    ddp_act_attachment_rec.display_program := p7_a31;
    ddp_act_attachment_rec.attribute_category := p7_a32;
    ddp_act_attachment_rec.attribute1 := p7_a33;
    ddp_act_attachment_rec.attribute2 := p7_a34;
    ddp_act_attachment_rec.attribute3 := p7_a35;
    ddp_act_attachment_rec.attribute4 := p7_a36;
    ddp_act_attachment_rec.attribute5 := p7_a37;
    ddp_act_attachment_rec.attribute6 := p7_a38;
    ddp_act_attachment_rec.attribute7 := p7_a39;
    ddp_act_attachment_rec.attribute8 := p7_a40;
    ddp_act_attachment_rec.attribute9 := p7_a41;
    ddp_act_attachment_rec.attribute10 := p7_a42;
    ddp_act_attachment_rec.attribute11 := p7_a43;
    ddp_act_attachment_rec.attribute12 := p7_a44;
    ddp_act_attachment_rec.attribute13 := p7_a45;
    ddp_act_attachment_rec.attribute14 := p7_a46;
    ddp_act_attachment_rec.attribute15 := p7_a47;
    ddp_act_attachment_rec.display_text := p7_a48;
    ddp_act_attachment_rec.alternate_text := p7_a49;
    ddp_act_attachment_rec.secured_flag := p7_a50;
    ddp_act_attachment_rec.attachment_sub_type := p7_a51;

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.update_act_attachment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_attachment_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_act_attachment(p_api_version  NUMBER
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
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_attachment_rec.attachment_id := rosetta_g_miss_num_map(p6_a0);
    ddp_act_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_act_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_act_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_act_attachment_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_act_attachment_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_act_attachment_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_act_attachment_rec.owner_user_id := rosetta_g_miss_num_map(p6_a7);
    ddp_act_attachment_rec.attachment_used_by_id := rosetta_g_miss_num_map(p6_a8);
    ddp_act_attachment_rec.attachment_used_by := p6_a9;
    ddp_act_attachment_rec.version := p6_a10;
    ddp_act_attachment_rec.enabled_flag := p6_a11;
    ddp_act_attachment_rec.can_fulfill_electronic_flag := p6_a12;
    ddp_act_attachment_rec.file_id := rosetta_g_miss_num_map(p6_a13);
    ddp_act_attachment_rec.file_name := p6_a14;
    ddp_act_attachment_rec.file_extension := p6_a15;
    ddp_act_attachment_rec.document_id := rosetta_g_miss_num_map(p6_a16);
    ddp_act_attachment_rec.keywords := p6_a17;
    ddp_act_attachment_rec.display_width := rosetta_g_miss_num_map(p6_a18);
    ddp_act_attachment_rec.display_height := rosetta_g_miss_num_map(p6_a19);
    ddp_act_attachment_rec.display_location := p6_a20;
    ddp_act_attachment_rec.link_to := p6_a21;
    ddp_act_attachment_rec.link_url := p6_a22;
    ddp_act_attachment_rec.send_for_preview_flag := p6_a23;
    ddp_act_attachment_rec.attachment_type := p6_a24;
    ddp_act_attachment_rec.language_code := p6_a25;
    ddp_act_attachment_rec.application_id := rosetta_g_miss_num_map(p6_a26);
    ddp_act_attachment_rec.description := p6_a27;
    ddp_act_attachment_rec.default_style_sheet := p6_a28;
    ddp_act_attachment_rec.display_url := p6_a29;
    ddp_act_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p6_a30);
    ddp_act_attachment_rec.display_program := p6_a31;
    ddp_act_attachment_rec.attribute_category := p6_a32;
    ddp_act_attachment_rec.attribute1 := p6_a33;
    ddp_act_attachment_rec.attribute2 := p6_a34;
    ddp_act_attachment_rec.attribute3 := p6_a35;
    ddp_act_attachment_rec.attribute4 := p6_a36;
    ddp_act_attachment_rec.attribute5 := p6_a37;
    ddp_act_attachment_rec.attribute6 := p6_a38;
    ddp_act_attachment_rec.attribute7 := p6_a39;
    ddp_act_attachment_rec.attribute8 := p6_a40;
    ddp_act_attachment_rec.attribute9 := p6_a41;
    ddp_act_attachment_rec.attribute10 := p6_a42;
    ddp_act_attachment_rec.attribute11 := p6_a43;
    ddp_act_attachment_rec.attribute12 := p6_a44;
    ddp_act_attachment_rec.attribute13 := p6_a45;
    ddp_act_attachment_rec.attribute14 := p6_a46;
    ddp_act_attachment_rec.attribute15 := p6_a47;
    ddp_act_attachment_rec.display_text := p6_a48;
    ddp_act_attachment_rec.alternate_text := p6_a49;
    ddp_act_attachment_rec.secured_flag := p6_a50;
    ddp_act_attachment_rec.attachment_sub_type := p6_a51;

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.validate_act_attachment(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_attachment_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_act_attachment_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_attachment_rec.attachment_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_attachment_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_attachment_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_attachment_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_attachment_rec.owner_user_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_attachment_rec.attachment_used_by_id := rosetta_g_miss_num_map(p0_a8);
    ddp_act_attachment_rec.attachment_used_by := p0_a9;
    ddp_act_attachment_rec.version := p0_a10;
    ddp_act_attachment_rec.enabled_flag := p0_a11;
    ddp_act_attachment_rec.can_fulfill_electronic_flag := p0_a12;
    ddp_act_attachment_rec.file_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_attachment_rec.file_name := p0_a14;
    ddp_act_attachment_rec.file_extension := p0_a15;
    ddp_act_attachment_rec.document_id := rosetta_g_miss_num_map(p0_a16);
    ddp_act_attachment_rec.keywords := p0_a17;
    ddp_act_attachment_rec.display_width := rosetta_g_miss_num_map(p0_a18);
    ddp_act_attachment_rec.display_height := rosetta_g_miss_num_map(p0_a19);
    ddp_act_attachment_rec.display_location := p0_a20;
    ddp_act_attachment_rec.link_to := p0_a21;
    ddp_act_attachment_rec.link_url := p0_a22;
    ddp_act_attachment_rec.send_for_preview_flag := p0_a23;
    ddp_act_attachment_rec.attachment_type := p0_a24;
    ddp_act_attachment_rec.language_code := p0_a25;
    ddp_act_attachment_rec.application_id := rosetta_g_miss_num_map(p0_a26);
    ddp_act_attachment_rec.description := p0_a27;
    ddp_act_attachment_rec.default_style_sheet := p0_a28;
    ddp_act_attachment_rec.display_url := p0_a29;
    ddp_act_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p0_a30);
    ddp_act_attachment_rec.display_program := p0_a31;
    ddp_act_attachment_rec.attribute_category := p0_a32;
    ddp_act_attachment_rec.attribute1 := p0_a33;
    ddp_act_attachment_rec.attribute2 := p0_a34;
    ddp_act_attachment_rec.attribute3 := p0_a35;
    ddp_act_attachment_rec.attribute4 := p0_a36;
    ddp_act_attachment_rec.attribute5 := p0_a37;
    ddp_act_attachment_rec.attribute6 := p0_a38;
    ddp_act_attachment_rec.attribute7 := p0_a39;
    ddp_act_attachment_rec.attribute8 := p0_a40;
    ddp_act_attachment_rec.attribute9 := p0_a41;
    ddp_act_attachment_rec.attribute10 := p0_a42;
    ddp_act_attachment_rec.attribute11 := p0_a43;
    ddp_act_attachment_rec.attribute12 := p0_a44;
    ddp_act_attachment_rec.attribute13 := p0_a45;
    ddp_act_attachment_rec.attribute14 := p0_a46;
    ddp_act_attachment_rec.attribute15 := p0_a47;
    ddp_act_attachment_rec.display_text := p0_a48;
    ddp_act_attachment_rec.alternate_text := p0_a49;
    ddp_act_attachment_rec.secured_flag := p0_a50;
    ddp_act_attachment_rec.attachment_sub_type := p0_a51;



    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.check_act_attachment_items(ddp_act_attachment_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_act_attachment_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  NUMBER := 0-1962.0724
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  NUMBER := 0-1962.0724
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  VARCHAR2 := fnd_api.g_miss_char
    , p1_a33  VARCHAR2 := fnd_api.g_miss_char
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  VARCHAR2 := fnd_api.g_miss_char
    , p1_a37  VARCHAR2 := fnd_api.g_miss_char
    , p1_a38  VARCHAR2 := fnd_api.g_miss_char
    , p1_a39  VARCHAR2 := fnd_api.g_miss_char
    , p1_a40  VARCHAR2 := fnd_api.g_miss_char
    , p1_a41  VARCHAR2 := fnd_api.g_miss_char
    , p1_a42  VARCHAR2 := fnd_api.g_miss_char
    , p1_a43  VARCHAR2 := fnd_api.g_miss_char
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  VARCHAR2 := fnd_api.g_miss_char
    , p1_a46  VARCHAR2 := fnd_api.g_miss_char
    , p1_a47  VARCHAR2 := fnd_api.g_miss_char
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  VARCHAR2 := fnd_api.g_miss_char
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddp_complete_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_attachment_rec.attachment_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_attachment_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_attachment_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_attachment_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_attachment_rec.owner_user_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_attachment_rec.attachment_used_by_id := rosetta_g_miss_num_map(p0_a8);
    ddp_act_attachment_rec.attachment_used_by := p0_a9;
    ddp_act_attachment_rec.version := p0_a10;
    ddp_act_attachment_rec.enabled_flag := p0_a11;
    ddp_act_attachment_rec.can_fulfill_electronic_flag := p0_a12;
    ddp_act_attachment_rec.file_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_attachment_rec.file_name := p0_a14;
    ddp_act_attachment_rec.file_extension := p0_a15;
    ddp_act_attachment_rec.document_id := rosetta_g_miss_num_map(p0_a16);
    ddp_act_attachment_rec.keywords := p0_a17;
    ddp_act_attachment_rec.display_width := rosetta_g_miss_num_map(p0_a18);
    ddp_act_attachment_rec.display_height := rosetta_g_miss_num_map(p0_a19);
    ddp_act_attachment_rec.display_location := p0_a20;
    ddp_act_attachment_rec.link_to := p0_a21;
    ddp_act_attachment_rec.link_url := p0_a22;
    ddp_act_attachment_rec.send_for_preview_flag := p0_a23;
    ddp_act_attachment_rec.attachment_type := p0_a24;
    ddp_act_attachment_rec.language_code := p0_a25;
    ddp_act_attachment_rec.application_id := rosetta_g_miss_num_map(p0_a26);
    ddp_act_attachment_rec.description := p0_a27;
    ddp_act_attachment_rec.default_style_sheet := p0_a28;
    ddp_act_attachment_rec.display_url := p0_a29;
    ddp_act_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p0_a30);
    ddp_act_attachment_rec.display_program := p0_a31;
    ddp_act_attachment_rec.attribute_category := p0_a32;
    ddp_act_attachment_rec.attribute1 := p0_a33;
    ddp_act_attachment_rec.attribute2 := p0_a34;
    ddp_act_attachment_rec.attribute3 := p0_a35;
    ddp_act_attachment_rec.attribute4 := p0_a36;
    ddp_act_attachment_rec.attribute5 := p0_a37;
    ddp_act_attachment_rec.attribute6 := p0_a38;
    ddp_act_attachment_rec.attribute7 := p0_a39;
    ddp_act_attachment_rec.attribute8 := p0_a40;
    ddp_act_attachment_rec.attribute9 := p0_a41;
    ddp_act_attachment_rec.attribute10 := p0_a42;
    ddp_act_attachment_rec.attribute11 := p0_a43;
    ddp_act_attachment_rec.attribute12 := p0_a44;
    ddp_act_attachment_rec.attribute13 := p0_a45;
    ddp_act_attachment_rec.attribute14 := p0_a46;
    ddp_act_attachment_rec.attribute15 := p0_a47;
    ddp_act_attachment_rec.display_text := p0_a48;
    ddp_act_attachment_rec.alternate_text := p0_a49;
    ddp_act_attachment_rec.secured_flag := p0_a50;
    ddp_act_attachment_rec.attachment_sub_type := p0_a51;

    ddp_complete_rec.attachment_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.owner_user_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.attachment_used_by_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.attachment_used_by := p1_a9;
    ddp_complete_rec.version := p1_a10;
    ddp_complete_rec.enabled_flag := p1_a11;
    ddp_complete_rec.can_fulfill_electronic_flag := p1_a12;
    ddp_complete_rec.file_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.file_name := p1_a14;
    ddp_complete_rec.file_extension := p1_a15;
    ddp_complete_rec.document_id := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.keywords := p1_a17;
    ddp_complete_rec.display_width := rosetta_g_miss_num_map(p1_a18);
    ddp_complete_rec.display_height := rosetta_g_miss_num_map(p1_a19);
    ddp_complete_rec.display_location := p1_a20;
    ddp_complete_rec.link_to := p1_a21;
    ddp_complete_rec.link_url := p1_a22;
    ddp_complete_rec.send_for_preview_flag := p1_a23;
    ddp_complete_rec.attachment_type := p1_a24;
    ddp_complete_rec.language_code := p1_a25;
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a26);
    ddp_complete_rec.description := p1_a27;
    ddp_complete_rec.default_style_sheet := p1_a28;
    ddp_complete_rec.display_url := p1_a29;
    ddp_complete_rec.display_rule_id := rosetta_g_miss_num_map(p1_a30);
    ddp_complete_rec.display_program := p1_a31;
    ddp_complete_rec.attribute_category := p1_a32;
    ddp_complete_rec.attribute1 := p1_a33;
    ddp_complete_rec.attribute2 := p1_a34;
    ddp_complete_rec.attribute3 := p1_a35;
    ddp_complete_rec.attribute4 := p1_a36;
    ddp_complete_rec.attribute5 := p1_a37;
    ddp_complete_rec.attribute6 := p1_a38;
    ddp_complete_rec.attribute7 := p1_a39;
    ddp_complete_rec.attribute8 := p1_a40;
    ddp_complete_rec.attribute9 := p1_a41;
    ddp_complete_rec.attribute10 := p1_a42;
    ddp_complete_rec.attribute11 := p1_a43;
    ddp_complete_rec.attribute12 := p1_a44;
    ddp_complete_rec.attribute13 := p1_a45;
    ddp_complete_rec.attribute14 := p1_a46;
    ddp_complete_rec.attribute15 := p1_a47;
    ddp_complete_rec.display_text := p1_a48;
    ddp_complete_rec.alternate_text := p1_a49;
    ddp_complete_rec.secured_flag := p1_a50;
    ddp_complete_rec.attachment_sub_type := p1_a51;


    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.check_act_attachment_record(ddp_act_attachment_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure miss_act_attachment_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  VARCHAR2
    , p0_a51 out nocopy  VARCHAR2
  )

  as
    ddx_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.miss_act_attachment_rec(ddx_act_attachment_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_act_attachment_rec.attachment_id);
    p0_a1 := ddx_act_attachment_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_act_attachment_rec.last_updated_by);
    p0_a3 := ddx_act_attachment_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_act_attachment_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_act_attachment_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_act_attachment_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_act_attachment_rec.owner_user_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_act_attachment_rec.attachment_used_by_id);
    p0_a9 := ddx_act_attachment_rec.attachment_used_by;
    p0_a10 := ddx_act_attachment_rec.version;
    p0_a11 := ddx_act_attachment_rec.enabled_flag;
    p0_a12 := ddx_act_attachment_rec.can_fulfill_electronic_flag;
    p0_a13 := rosetta_g_miss_num_map(ddx_act_attachment_rec.file_id);
    p0_a14 := ddx_act_attachment_rec.file_name;
    p0_a15 := ddx_act_attachment_rec.file_extension;
    p0_a16 := rosetta_g_miss_num_map(ddx_act_attachment_rec.document_id);
    p0_a17 := ddx_act_attachment_rec.keywords;
    p0_a18 := rosetta_g_miss_num_map(ddx_act_attachment_rec.display_width);
    p0_a19 := rosetta_g_miss_num_map(ddx_act_attachment_rec.display_height);
    p0_a20 := ddx_act_attachment_rec.display_location;
    p0_a21 := ddx_act_attachment_rec.link_to;
    p0_a22 := ddx_act_attachment_rec.link_url;
    p0_a23 := ddx_act_attachment_rec.send_for_preview_flag;
    p0_a24 := ddx_act_attachment_rec.attachment_type;
    p0_a25 := ddx_act_attachment_rec.language_code;
    p0_a26 := rosetta_g_miss_num_map(ddx_act_attachment_rec.application_id);
    p0_a27 := ddx_act_attachment_rec.description;
    p0_a28 := ddx_act_attachment_rec.default_style_sheet;
    p0_a29 := ddx_act_attachment_rec.display_url;
    p0_a30 := rosetta_g_miss_num_map(ddx_act_attachment_rec.display_rule_id);
    p0_a31 := ddx_act_attachment_rec.display_program;
    p0_a32 := ddx_act_attachment_rec.attribute_category;
    p0_a33 := ddx_act_attachment_rec.attribute1;
    p0_a34 := ddx_act_attachment_rec.attribute2;
    p0_a35 := ddx_act_attachment_rec.attribute3;
    p0_a36 := ddx_act_attachment_rec.attribute4;
    p0_a37 := ddx_act_attachment_rec.attribute5;
    p0_a38 := ddx_act_attachment_rec.attribute6;
    p0_a39 := ddx_act_attachment_rec.attribute7;
    p0_a40 := ddx_act_attachment_rec.attribute8;
    p0_a41 := ddx_act_attachment_rec.attribute9;
    p0_a42 := ddx_act_attachment_rec.attribute10;
    p0_a43 := ddx_act_attachment_rec.attribute11;
    p0_a44 := ddx_act_attachment_rec.attribute12;
    p0_a45 := ddx_act_attachment_rec.attribute13;
    p0_a46 := ddx_act_attachment_rec.attribute14;
    p0_a47 := ddx_act_attachment_rec.attribute15;
    p0_a48 := ddx_act_attachment_rec.display_text;
    p0_a49 := ddx_act_attachment_rec.alternate_text;
    p0_a50 := ddx_act_attachment_rec.secured_flag;
    p0_a51 := ddx_act_attachment_rec.attachment_sub_type;
  end;

  procedure complete_act_attachment_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  VARCHAR2
    , p1_a51 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_attachment_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddx_complete_rec jtf_amv_attachment_pub.act_attachment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_attachment_rec.attachment_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_attachment_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_attachment_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_attachment_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_attachment_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_attachment_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_attachment_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_attachment_rec.owner_user_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_attachment_rec.attachment_used_by_id := rosetta_g_miss_num_map(p0_a8);
    ddp_act_attachment_rec.attachment_used_by := p0_a9;
    ddp_act_attachment_rec.version := p0_a10;
    ddp_act_attachment_rec.enabled_flag := p0_a11;
    ddp_act_attachment_rec.can_fulfill_electronic_flag := p0_a12;
    ddp_act_attachment_rec.file_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_attachment_rec.file_name := p0_a14;
    ddp_act_attachment_rec.file_extension := p0_a15;
    ddp_act_attachment_rec.document_id := rosetta_g_miss_num_map(p0_a16);
    ddp_act_attachment_rec.keywords := p0_a17;
    ddp_act_attachment_rec.display_width := rosetta_g_miss_num_map(p0_a18);
    ddp_act_attachment_rec.display_height := rosetta_g_miss_num_map(p0_a19);
    ddp_act_attachment_rec.display_location := p0_a20;
    ddp_act_attachment_rec.link_to := p0_a21;
    ddp_act_attachment_rec.link_url := p0_a22;
    ddp_act_attachment_rec.send_for_preview_flag := p0_a23;
    ddp_act_attachment_rec.attachment_type := p0_a24;
    ddp_act_attachment_rec.language_code := p0_a25;
    ddp_act_attachment_rec.application_id := rosetta_g_miss_num_map(p0_a26);
    ddp_act_attachment_rec.description := p0_a27;
    ddp_act_attachment_rec.default_style_sheet := p0_a28;
    ddp_act_attachment_rec.display_url := p0_a29;
    ddp_act_attachment_rec.display_rule_id := rosetta_g_miss_num_map(p0_a30);
    ddp_act_attachment_rec.display_program := p0_a31;
    ddp_act_attachment_rec.attribute_category := p0_a32;
    ddp_act_attachment_rec.attribute1 := p0_a33;
    ddp_act_attachment_rec.attribute2 := p0_a34;
    ddp_act_attachment_rec.attribute3 := p0_a35;
    ddp_act_attachment_rec.attribute4 := p0_a36;
    ddp_act_attachment_rec.attribute5 := p0_a37;
    ddp_act_attachment_rec.attribute6 := p0_a38;
    ddp_act_attachment_rec.attribute7 := p0_a39;
    ddp_act_attachment_rec.attribute8 := p0_a40;
    ddp_act_attachment_rec.attribute9 := p0_a41;
    ddp_act_attachment_rec.attribute10 := p0_a42;
    ddp_act_attachment_rec.attribute11 := p0_a43;
    ddp_act_attachment_rec.attribute12 := p0_a44;
    ddp_act_attachment_rec.attribute13 := p0_a45;
    ddp_act_attachment_rec.attribute14 := p0_a46;
    ddp_act_attachment_rec.attribute15 := p0_a47;
    ddp_act_attachment_rec.display_text := p0_a48;
    ddp_act_attachment_rec.alternate_text := p0_a49;
    ddp_act_attachment_rec.secured_flag := p0_a50;
    ddp_act_attachment_rec.attachment_sub_type := p0_a51;


    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_attachment_pub.complete_act_attachment_rec(ddp_act_attachment_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.attachment_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.owner_user_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.attachment_used_by_id);
    p1_a9 := ddx_complete_rec.attachment_used_by;
    p1_a10 := ddx_complete_rec.version;
    p1_a11 := ddx_complete_rec.enabled_flag;
    p1_a12 := ddx_complete_rec.can_fulfill_electronic_flag;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.file_id);
    p1_a14 := ddx_complete_rec.file_name;
    p1_a15 := ddx_complete_rec.file_extension;
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.document_id);
    p1_a17 := ddx_complete_rec.keywords;
    p1_a18 := rosetta_g_miss_num_map(ddx_complete_rec.display_width);
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.display_height);
    p1_a20 := ddx_complete_rec.display_location;
    p1_a21 := ddx_complete_rec.link_to;
    p1_a22 := ddx_complete_rec.link_url;
    p1_a23 := ddx_complete_rec.send_for_preview_flag;
    p1_a24 := ddx_complete_rec.attachment_type;
    p1_a25 := ddx_complete_rec.language_code;
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.application_id);
    p1_a27 := ddx_complete_rec.description;
    p1_a28 := ddx_complete_rec.default_style_sheet;
    p1_a29 := ddx_complete_rec.display_url;
    p1_a30 := rosetta_g_miss_num_map(ddx_complete_rec.display_rule_id);
    p1_a31 := ddx_complete_rec.display_program;
    p1_a32 := ddx_complete_rec.attribute_category;
    p1_a33 := ddx_complete_rec.attribute1;
    p1_a34 := ddx_complete_rec.attribute2;
    p1_a35 := ddx_complete_rec.attribute3;
    p1_a36 := ddx_complete_rec.attribute4;
    p1_a37 := ddx_complete_rec.attribute5;
    p1_a38 := ddx_complete_rec.attribute6;
    p1_a39 := ddx_complete_rec.attribute7;
    p1_a40 := ddx_complete_rec.attribute8;
    p1_a41 := ddx_complete_rec.attribute9;
    p1_a42 := ddx_complete_rec.attribute10;
    p1_a43 := ddx_complete_rec.attribute11;
    p1_a44 := ddx_complete_rec.attribute12;
    p1_a45 := ddx_complete_rec.attribute13;
    p1_a46 := ddx_complete_rec.attribute14;
    p1_a47 := ddx_complete_rec.attribute15;
    p1_a48 := ddx_complete_rec.display_text;
    p1_a49 := ddx_complete_rec.alternate_text;
    p1_a50 := ddx_complete_rec.secured_flag;
    p1_a51 := ddx_complete_rec.attachment_sub_type;
  end;

end jtf_amv_attachment_pub_w;

/
