--------------------------------------------------------
--  DDL for Package Body PVX_LEAD_PSS_LINES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_LEAD_PSS_LINES_PVT_W" as
  /* $Header: pvxwpssb.pls 115.9 2002/11/20 02:05:23 pklin ship $ */
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

  procedure create_lead_pss_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_lead_pss_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
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
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_lead_pss_lines_rec.lead_pss_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_lead_pss_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_lead_pss_lines_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_lead_pss_lines_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_lead_pss_lines_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_lead_pss_lines_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_lead_pss_lines_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_lead_pss_lines_rec.request_id := rosetta_g_miss_num_map(p7_a7);
    ddp_lead_pss_lines_rec.program_application_id := rosetta_g_miss_num_map(p7_a8);
    ddp_lead_pss_lines_rec.program_id := rosetta_g_miss_num_map(p7_a9);
    ddp_lead_pss_lines_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_lead_pss_lines_rec.object_name := p7_a11;
    ddp_lead_pss_lines_rec.attr_code_id := rosetta_g_miss_num_map(p7_a12);
    ddp_lead_pss_lines_rec.lead_id := rosetta_g_miss_num_map(p7_a13);
    ddp_lead_pss_lines_rec.uom_code := p7_a14;
    ddp_lead_pss_lines_rec.quantity := rosetta_g_miss_num_map(p7_a15);
    ddp_lead_pss_lines_rec.amount := rosetta_g_miss_num_map(p7_a16);
    ddp_lead_pss_lines_rec.attribute_category := p7_a17;
    ddp_lead_pss_lines_rec.attribute1 := p7_a18;
    ddp_lead_pss_lines_rec.attribute2 := p7_a19;
    ddp_lead_pss_lines_rec.attribute3 := p7_a20;
    ddp_lead_pss_lines_rec.attribute4 := p7_a21;
    ddp_lead_pss_lines_rec.attribute5 := p7_a22;
    ddp_lead_pss_lines_rec.attribute6 := p7_a23;
    ddp_lead_pss_lines_rec.attribute7 := p7_a24;
    ddp_lead_pss_lines_rec.attribute8 := p7_a25;
    ddp_lead_pss_lines_rec.attribute9 := p7_a26;
    ddp_lead_pss_lines_rec.attribute10 := p7_a27;
    ddp_lead_pss_lines_rec.attribute11 := p7_a28;
    ddp_lead_pss_lines_rec.attribute12 := p7_a29;
    ddp_lead_pss_lines_rec.attribute13 := p7_a30;
    ddp_lead_pss_lines_rec.attribute14 := p7_a31;
    ddp_lead_pss_lines_rec.attribute15 := p7_a32;
    ddp_lead_pss_lines_rec.object_id := rosetta_g_miss_num_map(p7_a33);
    ddp_lead_pss_lines_rec.partner_id := rosetta_g_miss_num_map(p7_a34);


    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.create_lead_pss_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lead_pss_lines_rec,
      x_lead_pss_line_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_lead_pss_line(p_api_version_number  NUMBER
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
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
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
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_lead_pss_lines_rec.lead_pss_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_lead_pss_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_lead_pss_lines_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_lead_pss_lines_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_lead_pss_lines_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_lead_pss_lines_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_lead_pss_lines_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_lead_pss_lines_rec.request_id := rosetta_g_miss_num_map(p7_a7);
    ddp_lead_pss_lines_rec.program_application_id := rosetta_g_miss_num_map(p7_a8);
    ddp_lead_pss_lines_rec.program_id := rosetta_g_miss_num_map(p7_a9);
    ddp_lead_pss_lines_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_lead_pss_lines_rec.object_name := p7_a11;
    ddp_lead_pss_lines_rec.attr_code_id := rosetta_g_miss_num_map(p7_a12);
    ddp_lead_pss_lines_rec.lead_id := rosetta_g_miss_num_map(p7_a13);
    ddp_lead_pss_lines_rec.uom_code := p7_a14;
    ddp_lead_pss_lines_rec.quantity := rosetta_g_miss_num_map(p7_a15);
    ddp_lead_pss_lines_rec.amount := rosetta_g_miss_num_map(p7_a16);
    ddp_lead_pss_lines_rec.attribute_category := p7_a17;
    ddp_lead_pss_lines_rec.attribute1 := p7_a18;
    ddp_lead_pss_lines_rec.attribute2 := p7_a19;
    ddp_lead_pss_lines_rec.attribute3 := p7_a20;
    ddp_lead_pss_lines_rec.attribute4 := p7_a21;
    ddp_lead_pss_lines_rec.attribute5 := p7_a22;
    ddp_lead_pss_lines_rec.attribute6 := p7_a23;
    ddp_lead_pss_lines_rec.attribute7 := p7_a24;
    ddp_lead_pss_lines_rec.attribute8 := p7_a25;
    ddp_lead_pss_lines_rec.attribute9 := p7_a26;
    ddp_lead_pss_lines_rec.attribute10 := p7_a27;
    ddp_lead_pss_lines_rec.attribute11 := p7_a28;
    ddp_lead_pss_lines_rec.attribute12 := p7_a29;
    ddp_lead_pss_lines_rec.attribute13 := p7_a30;
    ddp_lead_pss_lines_rec.attribute14 := p7_a31;
    ddp_lead_pss_lines_rec.attribute15 := p7_a32;
    ddp_lead_pss_lines_rec.object_id := rosetta_g_miss_num_map(p7_a33);
    ddp_lead_pss_lines_rec.partner_id := rosetta_g_miss_num_map(p7_a34);

    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.update_lead_pss_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lead_pss_lines_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_lead_pss_line(p_api_version_number  NUMBER
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
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
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
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_lead_pss_lines_rec.lead_pss_line_id := rosetta_g_miss_num_map(p6_a0);
    ddp_lead_pss_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_lead_pss_lines_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_lead_pss_lines_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_lead_pss_lines_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_lead_pss_lines_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_lead_pss_lines_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_lead_pss_lines_rec.request_id := rosetta_g_miss_num_map(p6_a7);
    ddp_lead_pss_lines_rec.program_application_id := rosetta_g_miss_num_map(p6_a8);
    ddp_lead_pss_lines_rec.program_id := rosetta_g_miss_num_map(p6_a9);
    ddp_lead_pss_lines_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_lead_pss_lines_rec.object_name := p6_a11;
    ddp_lead_pss_lines_rec.attr_code_id := rosetta_g_miss_num_map(p6_a12);
    ddp_lead_pss_lines_rec.lead_id := rosetta_g_miss_num_map(p6_a13);
    ddp_lead_pss_lines_rec.uom_code := p6_a14;
    ddp_lead_pss_lines_rec.quantity := rosetta_g_miss_num_map(p6_a15);
    ddp_lead_pss_lines_rec.amount := rosetta_g_miss_num_map(p6_a16);
    ddp_lead_pss_lines_rec.attribute_category := p6_a17;
    ddp_lead_pss_lines_rec.attribute1 := p6_a18;
    ddp_lead_pss_lines_rec.attribute2 := p6_a19;
    ddp_lead_pss_lines_rec.attribute3 := p6_a20;
    ddp_lead_pss_lines_rec.attribute4 := p6_a21;
    ddp_lead_pss_lines_rec.attribute5 := p6_a22;
    ddp_lead_pss_lines_rec.attribute6 := p6_a23;
    ddp_lead_pss_lines_rec.attribute7 := p6_a24;
    ddp_lead_pss_lines_rec.attribute8 := p6_a25;
    ddp_lead_pss_lines_rec.attribute9 := p6_a26;
    ddp_lead_pss_lines_rec.attribute10 := p6_a27;
    ddp_lead_pss_lines_rec.attribute11 := p6_a28;
    ddp_lead_pss_lines_rec.attribute12 := p6_a29;
    ddp_lead_pss_lines_rec.attribute13 := p6_a30;
    ddp_lead_pss_lines_rec.attribute14 := p6_a31;
    ddp_lead_pss_lines_rec.attribute15 := p6_a32;
    ddp_lead_pss_lines_rec.object_id := rosetta_g_miss_num_map(p6_a33);
    ddp_lead_pss_lines_rec.partner_id := rosetta_g_miss_num_map(p6_a34);

    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.validate_lead_pss_line(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lead_pss_lines_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_lead_pss_line_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  DATE := fnd_api.g_miss_date
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  NUMBER := 0-1962.0724
    , p2_a10  DATE := fnd_api.g_miss_date
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  NUMBER := 0-1962.0724
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  NUMBER := 0-1962.0724
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  VARCHAR2 := fnd_api.g_miss_char
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  VARCHAR2 := fnd_api.g_miss_char
    , p2_a27  VARCHAR2 := fnd_api.g_miss_char
    , p2_a28  VARCHAR2 := fnd_api.g_miss_char
    , p2_a29  VARCHAR2 := fnd_api.g_miss_char
    , p2_a30  VARCHAR2 := fnd_api.g_miss_char
    , p2_a31  VARCHAR2 := fnd_api.g_miss_char
    , p2_a32  VARCHAR2 := fnd_api.g_miss_char
    , p2_a33  NUMBER := 0-1962.0724
    , p2_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_lead_pss_lines_rec.lead_pss_line_id := rosetta_g_miss_num_map(p2_a0);
    ddp_lead_pss_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_lead_pss_lines_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_lead_pss_lines_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_lead_pss_lines_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_lead_pss_lines_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_lead_pss_lines_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_lead_pss_lines_rec.request_id := rosetta_g_miss_num_map(p2_a7);
    ddp_lead_pss_lines_rec.program_application_id := rosetta_g_miss_num_map(p2_a8);
    ddp_lead_pss_lines_rec.program_id := rosetta_g_miss_num_map(p2_a9);
    ddp_lead_pss_lines_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_lead_pss_lines_rec.object_name := p2_a11;
    ddp_lead_pss_lines_rec.attr_code_id := rosetta_g_miss_num_map(p2_a12);
    ddp_lead_pss_lines_rec.lead_id := rosetta_g_miss_num_map(p2_a13);
    ddp_lead_pss_lines_rec.uom_code := p2_a14;
    ddp_lead_pss_lines_rec.quantity := rosetta_g_miss_num_map(p2_a15);
    ddp_lead_pss_lines_rec.amount := rosetta_g_miss_num_map(p2_a16);
    ddp_lead_pss_lines_rec.attribute_category := p2_a17;
    ddp_lead_pss_lines_rec.attribute1 := p2_a18;
    ddp_lead_pss_lines_rec.attribute2 := p2_a19;
    ddp_lead_pss_lines_rec.attribute3 := p2_a20;
    ddp_lead_pss_lines_rec.attribute4 := p2_a21;
    ddp_lead_pss_lines_rec.attribute5 := p2_a22;
    ddp_lead_pss_lines_rec.attribute6 := p2_a23;
    ddp_lead_pss_lines_rec.attribute7 := p2_a24;
    ddp_lead_pss_lines_rec.attribute8 := p2_a25;
    ddp_lead_pss_lines_rec.attribute9 := p2_a26;
    ddp_lead_pss_lines_rec.attribute10 := p2_a27;
    ddp_lead_pss_lines_rec.attribute11 := p2_a28;
    ddp_lead_pss_lines_rec.attribute12 := p2_a29;
    ddp_lead_pss_lines_rec.attribute13 := p2_a30;
    ddp_lead_pss_lines_rec.attribute14 := p2_a31;
    ddp_lead_pss_lines_rec.attribute15 := p2_a32;
    ddp_lead_pss_lines_rec.object_id := rosetta_g_miss_num_map(p2_a33);
    ddp_lead_pss_lines_rec.partner_id := rosetta_g_miss_num_map(p2_a34);

    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.check_lead_pss_line_items(p_validation_mode,
      x_return_status,
      ddp_lead_pss_lines_rec);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_lead_pss_line_record(p_mode  VARCHAR2
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
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
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
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  VARCHAR2 := fnd_api.g_miss_char
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  VARCHAR2 := fnd_api.g_miss_char
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddp_complete_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_lead_pss_lines_rec.lead_pss_line_id := rosetta_g_miss_num_map(p0_a0);
    ddp_lead_pss_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_lead_pss_lines_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_lead_pss_lines_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_lead_pss_lines_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_lead_pss_lines_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_lead_pss_lines_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_lead_pss_lines_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_lead_pss_lines_rec.program_application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_lead_pss_lines_rec.program_id := rosetta_g_miss_num_map(p0_a9);
    ddp_lead_pss_lines_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_lead_pss_lines_rec.object_name := p0_a11;
    ddp_lead_pss_lines_rec.attr_code_id := rosetta_g_miss_num_map(p0_a12);
    ddp_lead_pss_lines_rec.lead_id := rosetta_g_miss_num_map(p0_a13);
    ddp_lead_pss_lines_rec.uom_code := p0_a14;
    ddp_lead_pss_lines_rec.quantity := rosetta_g_miss_num_map(p0_a15);
    ddp_lead_pss_lines_rec.amount := rosetta_g_miss_num_map(p0_a16);
    ddp_lead_pss_lines_rec.attribute_category := p0_a17;
    ddp_lead_pss_lines_rec.attribute1 := p0_a18;
    ddp_lead_pss_lines_rec.attribute2 := p0_a19;
    ddp_lead_pss_lines_rec.attribute3 := p0_a20;
    ddp_lead_pss_lines_rec.attribute4 := p0_a21;
    ddp_lead_pss_lines_rec.attribute5 := p0_a22;
    ddp_lead_pss_lines_rec.attribute6 := p0_a23;
    ddp_lead_pss_lines_rec.attribute7 := p0_a24;
    ddp_lead_pss_lines_rec.attribute8 := p0_a25;
    ddp_lead_pss_lines_rec.attribute9 := p0_a26;
    ddp_lead_pss_lines_rec.attribute10 := p0_a27;
    ddp_lead_pss_lines_rec.attribute11 := p0_a28;
    ddp_lead_pss_lines_rec.attribute12 := p0_a29;
    ddp_lead_pss_lines_rec.attribute13 := p0_a30;
    ddp_lead_pss_lines_rec.attribute14 := p0_a31;
    ddp_lead_pss_lines_rec.attribute15 := p0_a32;
    ddp_lead_pss_lines_rec.object_id := rosetta_g_miss_num_map(p0_a33);
    ddp_lead_pss_lines_rec.partner_id := rosetta_g_miss_num_map(p0_a34);

    ddp_complete_rec.lead_pss_line_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.request_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.program_application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.program_id := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_complete_rec.object_name := p1_a11;
    ddp_complete_rec.attr_code_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.lead_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.uom_code := p1_a14;
    ddp_complete_rec.quantity := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.amount := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.attribute_category := p1_a17;
    ddp_complete_rec.attribute1 := p1_a18;
    ddp_complete_rec.attribute2 := p1_a19;
    ddp_complete_rec.attribute3 := p1_a20;
    ddp_complete_rec.attribute4 := p1_a21;
    ddp_complete_rec.attribute5 := p1_a22;
    ddp_complete_rec.attribute6 := p1_a23;
    ddp_complete_rec.attribute7 := p1_a24;
    ddp_complete_rec.attribute8 := p1_a25;
    ddp_complete_rec.attribute9 := p1_a26;
    ddp_complete_rec.attribute10 := p1_a27;
    ddp_complete_rec.attribute11 := p1_a28;
    ddp_complete_rec.attribute12 := p1_a29;
    ddp_complete_rec.attribute13 := p1_a30;
    ddp_complete_rec.attribute14 := p1_a31;
    ddp_complete_rec.attribute15 := p1_a32;
    ddp_complete_rec.object_id := rosetta_g_miss_num_map(p1_a33);
    ddp_complete_rec.partner_id := rosetta_g_miss_num_map(p1_a34);



    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.check_lead_pss_line_record(ddp_lead_pss_lines_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any



  end;

  procedure init_lead_pss_line_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  DATE
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
  )
  as
    ddx_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.init_lead_pss_line_rec(ddx_lead_pss_lines_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.lead_pss_line_id);
    p0_a1 := ddx_lead_pss_lines_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.last_updated_by);
    p0_a3 := ddx_lead_pss_lines_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.request_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.program_application_id);
    p0_a9 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.program_id);
    p0_a10 := ddx_lead_pss_lines_rec.program_update_date;
    p0_a11 := ddx_lead_pss_lines_rec.object_name;
    p0_a12 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.attr_code_id);
    p0_a13 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.lead_id);
    p0_a14 := ddx_lead_pss_lines_rec.uom_code;
    p0_a15 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.quantity);
    p0_a16 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.amount);
    p0_a17 := ddx_lead_pss_lines_rec.attribute_category;
    p0_a18 := ddx_lead_pss_lines_rec.attribute1;
    p0_a19 := ddx_lead_pss_lines_rec.attribute2;
    p0_a20 := ddx_lead_pss_lines_rec.attribute3;
    p0_a21 := ddx_lead_pss_lines_rec.attribute4;
    p0_a22 := ddx_lead_pss_lines_rec.attribute5;
    p0_a23 := ddx_lead_pss_lines_rec.attribute6;
    p0_a24 := ddx_lead_pss_lines_rec.attribute7;
    p0_a25 := ddx_lead_pss_lines_rec.attribute8;
    p0_a26 := ddx_lead_pss_lines_rec.attribute9;
    p0_a27 := ddx_lead_pss_lines_rec.attribute10;
    p0_a28 := ddx_lead_pss_lines_rec.attribute11;
    p0_a29 := ddx_lead_pss_lines_rec.attribute12;
    p0_a30 := ddx_lead_pss_lines_rec.attribute13;
    p0_a31 := ddx_lead_pss_lines_rec.attribute14;
    p0_a32 := ddx_lead_pss_lines_rec.attribute15;
    p0_a33 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.object_id);
    p0_a34 := rosetta_g_miss_num_map(ddx_lead_pss_lines_rec.partner_id);
  end;

  procedure complete_lead_pss_line_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  DATE
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
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
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
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
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
  )
  as
    ddp_lead_pss_lines_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddx_complete_rec pvx_lead_pss_lines_pvt.lead_pss_lines_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_lead_pss_lines_rec.lead_pss_line_id := rosetta_g_miss_num_map(p0_a0);
    ddp_lead_pss_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_lead_pss_lines_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_lead_pss_lines_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_lead_pss_lines_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_lead_pss_lines_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_lead_pss_lines_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_lead_pss_lines_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_lead_pss_lines_rec.program_application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_lead_pss_lines_rec.program_id := rosetta_g_miss_num_map(p0_a9);
    ddp_lead_pss_lines_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_lead_pss_lines_rec.object_name := p0_a11;
    ddp_lead_pss_lines_rec.attr_code_id := rosetta_g_miss_num_map(p0_a12);
    ddp_lead_pss_lines_rec.lead_id := rosetta_g_miss_num_map(p0_a13);
    ddp_lead_pss_lines_rec.uom_code := p0_a14;
    ddp_lead_pss_lines_rec.quantity := rosetta_g_miss_num_map(p0_a15);
    ddp_lead_pss_lines_rec.amount := rosetta_g_miss_num_map(p0_a16);
    ddp_lead_pss_lines_rec.attribute_category := p0_a17;
    ddp_lead_pss_lines_rec.attribute1 := p0_a18;
    ddp_lead_pss_lines_rec.attribute2 := p0_a19;
    ddp_lead_pss_lines_rec.attribute3 := p0_a20;
    ddp_lead_pss_lines_rec.attribute4 := p0_a21;
    ddp_lead_pss_lines_rec.attribute5 := p0_a22;
    ddp_lead_pss_lines_rec.attribute6 := p0_a23;
    ddp_lead_pss_lines_rec.attribute7 := p0_a24;
    ddp_lead_pss_lines_rec.attribute8 := p0_a25;
    ddp_lead_pss_lines_rec.attribute9 := p0_a26;
    ddp_lead_pss_lines_rec.attribute10 := p0_a27;
    ddp_lead_pss_lines_rec.attribute11 := p0_a28;
    ddp_lead_pss_lines_rec.attribute12 := p0_a29;
    ddp_lead_pss_lines_rec.attribute13 := p0_a30;
    ddp_lead_pss_lines_rec.attribute14 := p0_a31;
    ddp_lead_pss_lines_rec.attribute15 := p0_a32;
    ddp_lead_pss_lines_rec.object_id := rosetta_g_miss_num_map(p0_a33);
    ddp_lead_pss_lines_rec.partner_id := rosetta_g_miss_num_map(p0_a34);


    -- here's the delegated call to the old PL/SQL routine
    pvx_lead_pss_lines_pvt.complete_lead_pss_line_rec(ddp_lead_pss_lines_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.lead_pss_line_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.request_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.program_application_id);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.program_id);
    p1_a10 := ddx_complete_rec.program_update_date;
    p1_a11 := ddx_complete_rec.object_name;
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.attr_code_id);
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.lead_id);
    p1_a14 := ddx_complete_rec.uom_code;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.quantity);
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.amount);
    p1_a17 := ddx_complete_rec.attribute_category;
    p1_a18 := ddx_complete_rec.attribute1;
    p1_a19 := ddx_complete_rec.attribute2;
    p1_a20 := ddx_complete_rec.attribute3;
    p1_a21 := ddx_complete_rec.attribute4;
    p1_a22 := ddx_complete_rec.attribute5;
    p1_a23 := ddx_complete_rec.attribute6;
    p1_a24 := ddx_complete_rec.attribute7;
    p1_a25 := ddx_complete_rec.attribute8;
    p1_a26 := ddx_complete_rec.attribute9;
    p1_a27 := ddx_complete_rec.attribute10;
    p1_a28 := ddx_complete_rec.attribute11;
    p1_a29 := ddx_complete_rec.attribute12;
    p1_a30 := ddx_complete_rec.attribute13;
    p1_a31 := ddx_complete_rec.attribute14;
    p1_a32 := ddx_complete_rec.attribute15;
    p1_a33 := rosetta_g_miss_num_map(ddx_complete_rec.object_id);
    p1_a34 := rosetta_g_miss_num_map(ddx_complete_rec.partner_id);
  end;

end pvx_lead_pss_lines_pvt_w;

/
