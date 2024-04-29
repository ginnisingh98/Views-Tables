--------------------------------------------------------
--  DDL for Package Body OKL_CHECKLIST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CHECKLIST_PVT_W" as
  /* $Header: OKLECKLB.pls 120.4 2006/03/27 10:56:30 pagarg noship $ */
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

  procedure create_checklist_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddx_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clhv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clhv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clhv_rec.checklist_number := p5_a2;
    ddp_clhv_rec.description := p5_a3;
    ddp_clhv_rec.short_description := p5_a4;
    ddp_clhv_rec.checklist_type := p5_a5;
    ddp_clhv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_clhv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clhv_rec.status_code := p5_a8;
    ddp_clhv_rec.attribute_category := p5_a9;
    ddp_clhv_rec.attribute1 := p5_a10;
    ddp_clhv_rec.attribute2 := p5_a11;
    ddp_clhv_rec.attribute3 := p5_a12;
    ddp_clhv_rec.attribute4 := p5_a13;
    ddp_clhv_rec.attribute5 := p5_a14;
    ddp_clhv_rec.attribute6 := p5_a15;
    ddp_clhv_rec.attribute7 := p5_a16;
    ddp_clhv_rec.attribute8 := p5_a17;
    ddp_clhv_rec.attribute9 := p5_a18;
    ddp_clhv_rec.attribute10 := p5_a19;
    ddp_clhv_rec.attribute11 := p5_a20;
    ddp_clhv_rec.attribute12 := p5_a21;
    ddp_clhv_rec.attribute13 := p5_a22;
    ddp_clhv_rec.attribute14 := p5_a23;
    ddp_clhv_rec.attribute15 := p5_a24;
    ddp_clhv_rec.org_id := rosetta_g_miss_num_map(p5_a25);
    ddp_clhv_rec.request_id := rosetta_g_miss_num_map(p5_a26);
    ddp_clhv_rec.program_application_id := rosetta_g_miss_num_map(p5_a27);
    ddp_clhv_rec.program_id := rosetta_g_miss_num_map(p5_a28);
    ddp_clhv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clhv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_clhv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clhv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_clhv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_clhv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_clhv_rec.checklist_purpose_code := p5_a35;
    ddp_clhv_rec.decision_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clhv_rec.checklist_obj_id := rosetta_g_miss_num_map(p5_a37);
    ddp_clhv_rec.checklist_obj_type_code := p5_a38;
    ddp_clhv_rec.ckl_id := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.create_checklist_hdr(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clhv_rec,
      ddx_clhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_clhv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_clhv_rec.object_version_number);
    p6_a2 := ddx_clhv_rec.checklist_number;
    p6_a3 := ddx_clhv_rec.description;
    p6_a4 := ddx_clhv_rec.short_description;
    p6_a5 := ddx_clhv_rec.checklist_type;
    p6_a6 := ddx_clhv_rec.start_date;
    p6_a7 := ddx_clhv_rec.end_date;
    p6_a8 := ddx_clhv_rec.status_code;
    p6_a9 := ddx_clhv_rec.attribute_category;
    p6_a10 := ddx_clhv_rec.attribute1;
    p6_a11 := ddx_clhv_rec.attribute2;
    p6_a12 := ddx_clhv_rec.attribute3;
    p6_a13 := ddx_clhv_rec.attribute4;
    p6_a14 := ddx_clhv_rec.attribute5;
    p6_a15 := ddx_clhv_rec.attribute6;
    p6_a16 := ddx_clhv_rec.attribute7;
    p6_a17 := ddx_clhv_rec.attribute8;
    p6_a18 := ddx_clhv_rec.attribute9;
    p6_a19 := ddx_clhv_rec.attribute10;
    p6_a20 := ddx_clhv_rec.attribute11;
    p6_a21 := ddx_clhv_rec.attribute12;
    p6_a22 := ddx_clhv_rec.attribute13;
    p6_a23 := ddx_clhv_rec.attribute14;
    p6_a24 := ddx_clhv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_clhv_rec.org_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_clhv_rec.request_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_clhv_rec.program_application_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_clhv_rec.program_id);
    p6_a29 := ddx_clhv_rec.program_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_clhv_rec.created_by);
    p6_a31 := ddx_clhv_rec.creation_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_clhv_rec.last_updated_by);
    p6_a33 := ddx_clhv_rec.last_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_clhv_rec.last_update_login);
    p6_a35 := ddx_clhv_rec.checklist_purpose_code;
    p6_a36 := ddx_clhv_rec.decision_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_clhv_rec.checklist_obj_id);
    p6_a38 := ddx_clhv_rec.checklist_obj_type_code;
    p6_a39 := rosetta_g_miss_num_map(ddx_clhv_rec.ckl_id);
  end;

  procedure update_checklist_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddx_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clhv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clhv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clhv_rec.checklist_number := p5_a2;
    ddp_clhv_rec.description := p5_a3;
    ddp_clhv_rec.short_description := p5_a4;
    ddp_clhv_rec.checklist_type := p5_a5;
    ddp_clhv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_clhv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clhv_rec.status_code := p5_a8;
    ddp_clhv_rec.attribute_category := p5_a9;
    ddp_clhv_rec.attribute1 := p5_a10;
    ddp_clhv_rec.attribute2 := p5_a11;
    ddp_clhv_rec.attribute3 := p5_a12;
    ddp_clhv_rec.attribute4 := p5_a13;
    ddp_clhv_rec.attribute5 := p5_a14;
    ddp_clhv_rec.attribute6 := p5_a15;
    ddp_clhv_rec.attribute7 := p5_a16;
    ddp_clhv_rec.attribute8 := p5_a17;
    ddp_clhv_rec.attribute9 := p5_a18;
    ddp_clhv_rec.attribute10 := p5_a19;
    ddp_clhv_rec.attribute11 := p5_a20;
    ddp_clhv_rec.attribute12 := p5_a21;
    ddp_clhv_rec.attribute13 := p5_a22;
    ddp_clhv_rec.attribute14 := p5_a23;
    ddp_clhv_rec.attribute15 := p5_a24;
    ddp_clhv_rec.org_id := rosetta_g_miss_num_map(p5_a25);
    ddp_clhv_rec.request_id := rosetta_g_miss_num_map(p5_a26);
    ddp_clhv_rec.program_application_id := rosetta_g_miss_num_map(p5_a27);
    ddp_clhv_rec.program_id := rosetta_g_miss_num_map(p5_a28);
    ddp_clhv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clhv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_clhv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clhv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_clhv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_clhv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_clhv_rec.checklist_purpose_code := p5_a35;
    ddp_clhv_rec.decision_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clhv_rec.checklist_obj_id := rosetta_g_miss_num_map(p5_a37);
    ddp_clhv_rec.checklist_obj_type_code := p5_a38;
    ddp_clhv_rec.ckl_id := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.update_checklist_hdr(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clhv_rec,
      ddx_clhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_clhv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_clhv_rec.object_version_number);
    p6_a2 := ddx_clhv_rec.checklist_number;
    p6_a3 := ddx_clhv_rec.description;
    p6_a4 := ddx_clhv_rec.short_description;
    p6_a5 := ddx_clhv_rec.checklist_type;
    p6_a6 := ddx_clhv_rec.start_date;
    p6_a7 := ddx_clhv_rec.end_date;
    p6_a8 := ddx_clhv_rec.status_code;
    p6_a9 := ddx_clhv_rec.attribute_category;
    p6_a10 := ddx_clhv_rec.attribute1;
    p6_a11 := ddx_clhv_rec.attribute2;
    p6_a12 := ddx_clhv_rec.attribute3;
    p6_a13 := ddx_clhv_rec.attribute4;
    p6_a14 := ddx_clhv_rec.attribute5;
    p6_a15 := ddx_clhv_rec.attribute6;
    p6_a16 := ddx_clhv_rec.attribute7;
    p6_a17 := ddx_clhv_rec.attribute8;
    p6_a18 := ddx_clhv_rec.attribute9;
    p6_a19 := ddx_clhv_rec.attribute10;
    p6_a20 := ddx_clhv_rec.attribute11;
    p6_a21 := ddx_clhv_rec.attribute12;
    p6_a22 := ddx_clhv_rec.attribute13;
    p6_a23 := ddx_clhv_rec.attribute14;
    p6_a24 := ddx_clhv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_clhv_rec.org_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_clhv_rec.request_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_clhv_rec.program_application_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_clhv_rec.program_id);
    p6_a29 := ddx_clhv_rec.program_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_clhv_rec.created_by);
    p6_a31 := ddx_clhv_rec.creation_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_clhv_rec.last_updated_by);
    p6_a33 := ddx_clhv_rec.last_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_clhv_rec.last_update_login);
    p6_a35 := ddx_clhv_rec.checklist_purpose_code;
    p6_a36 := ddx_clhv_rec.decision_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_clhv_rec.checklist_obj_id);
    p6_a38 := ddx_clhv_rec.checklist_obj_type_code;
    p6_a39 := rosetta_g_miss_num_map(ddx_clhv_rec.ckl_id);
  end;

  procedure delete_checklist_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clhv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clhv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clhv_rec.checklist_number := p5_a2;
    ddp_clhv_rec.description := p5_a3;
    ddp_clhv_rec.short_description := p5_a4;
    ddp_clhv_rec.checklist_type := p5_a5;
    ddp_clhv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_clhv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clhv_rec.status_code := p5_a8;
    ddp_clhv_rec.attribute_category := p5_a9;
    ddp_clhv_rec.attribute1 := p5_a10;
    ddp_clhv_rec.attribute2 := p5_a11;
    ddp_clhv_rec.attribute3 := p5_a12;
    ddp_clhv_rec.attribute4 := p5_a13;
    ddp_clhv_rec.attribute5 := p5_a14;
    ddp_clhv_rec.attribute6 := p5_a15;
    ddp_clhv_rec.attribute7 := p5_a16;
    ddp_clhv_rec.attribute8 := p5_a17;
    ddp_clhv_rec.attribute9 := p5_a18;
    ddp_clhv_rec.attribute10 := p5_a19;
    ddp_clhv_rec.attribute11 := p5_a20;
    ddp_clhv_rec.attribute12 := p5_a21;
    ddp_clhv_rec.attribute13 := p5_a22;
    ddp_clhv_rec.attribute14 := p5_a23;
    ddp_clhv_rec.attribute15 := p5_a24;
    ddp_clhv_rec.org_id := rosetta_g_miss_num_map(p5_a25);
    ddp_clhv_rec.request_id := rosetta_g_miss_num_map(p5_a26);
    ddp_clhv_rec.program_application_id := rosetta_g_miss_num_map(p5_a27);
    ddp_clhv_rec.program_id := rosetta_g_miss_num_map(p5_a28);
    ddp_clhv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clhv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_clhv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clhv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_clhv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_clhv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_clhv_rec.checklist_purpose_code := p5_a35;
    ddp_clhv_rec.decision_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clhv_rec.checklist_obj_id := rosetta_g_miss_num_map(p5_a37);
    ddp_clhv_rec.checklist_obj_type_code := p5_a38;
    ddp_clhv_rec.ckl_id := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.delete_checklist_hdr(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_checklist_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddx_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cld_pvt_w.rosetta_table_copy_in_p2(ddp_cldv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.create_checklist_dtl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cldv_tbl,
      ddx_cldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cld_pvt_w.rosetta_table_copy_out_p2(ddx_cldv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      );
  end;

  procedure update_checklist_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddx_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cld_pvt_w.rosetta_table_copy_in_p2(ddp_cldv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.update_checklist_dtl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cldv_tbl,
      ddx_cldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cld_pvt_w.rosetta_table_copy_out_p2(ddx_cldv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      );
  end;

  procedure delete_checklist_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cld_pvt_w.rosetta_table_copy_in_p2(ddp_cldv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.delete_checklist_dtl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_checklist_inst_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddx_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clhv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clhv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clhv_rec.checklist_number := p5_a2;
    ddp_clhv_rec.description := p5_a3;
    ddp_clhv_rec.short_description := p5_a4;
    ddp_clhv_rec.checklist_type := p5_a5;
    ddp_clhv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_clhv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clhv_rec.status_code := p5_a8;
    ddp_clhv_rec.attribute_category := p5_a9;
    ddp_clhv_rec.attribute1 := p5_a10;
    ddp_clhv_rec.attribute2 := p5_a11;
    ddp_clhv_rec.attribute3 := p5_a12;
    ddp_clhv_rec.attribute4 := p5_a13;
    ddp_clhv_rec.attribute5 := p5_a14;
    ddp_clhv_rec.attribute6 := p5_a15;
    ddp_clhv_rec.attribute7 := p5_a16;
    ddp_clhv_rec.attribute8 := p5_a17;
    ddp_clhv_rec.attribute9 := p5_a18;
    ddp_clhv_rec.attribute10 := p5_a19;
    ddp_clhv_rec.attribute11 := p5_a20;
    ddp_clhv_rec.attribute12 := p5_a21;
    ddp_clhv_rec.attribute13 := p5_a22;
    ddp_clhv_rec.attribute14 := p5_a23;
    ddp_clhv_rec.attribute15 := p5_a24;
    ddp_clhv_rec.org_id := rosetta_g_miss_num_map(p5_a25);
    ddp_clhv_rec.request_id := rosetta_g_miss_num_map(p5_a26);
    ddp_clhv_rec.program_application_id := rosetta_g_miss_num_map(p5_a27);
    ddp_clhv_rec.program_id := rosetta_g_miss_num_map(p5_a28);
    ddp_clhv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clhv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_clhv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clhv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_clhv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_clhv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_clhv_rec.checklist_purpose_code := p5_a35;
    ddp_clhv_rec.decision_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clhv_rec.checklist_obj_id := rosetta_g_miss_num_map(p5_a37);
    ddp_clhv_rec.checklist_obj_type_code := p5_a38;
    ddp_clhv_rec.ckl_id := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.create_checklist_inst_hdr(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clhv_rec,
      ddx_clhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_clhv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_clhv_rec.object_version_number);
    p6_a2 := ddx_clhv_rec.checklist_number;
    p6_a3 := ddx_clhv_rec.description;
    p6_a4 := ddx_clhv_rec.short_description;
    p6_a5 := ddx_clhv_rec.checklist_type;
    p6_a6 := ddx_clhv_rec.start_date;
    p6_a7 := ddx_clhv_rec.end_date;
    p6_a8 := ddx_clhv_rec.status_code;
    p6_a9 := ddx_clhv_rec.attribute_category;
    p6_a10 := ddx_clhv_rec.attribute1;
    p6_a11 := ddx_clhv_rec.attribute2;
    p6_a12 := ddx_clhv_rec.attribute3;
    p6_a13 := ddx_clhv_rec.attribute4;
    p6_a14 := ddx_clhv_rec.attribute5;
    p6_a15 := ddx_clhv_rec.attribute6;
    p6_a16 := ddx_clhv_rec.attribute7;
    p6_a17 := ddx_clhv_rec.attribute8;
    p6_a18 := ddx_clhv_rec.attribute9;
    p6_a19 := ddx_clhv_rec.attribute10;
    p6_a20 := ddx_clhv_rec.attribute11;
    p6_a21 := ddx_clhv_rec.attribute12;
    p6_a22 := ddx_clhv_rec.attribute13;
    p6_a23 := ddx_clhv_rec.attribute14;
    p6_a24 := ddx_clhv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_clhv_rec.org_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_clhv_rec.request_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_clhv_rec.program_application_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_clhv_rec.program_id);
    p6_a29 := ddx_clhv_rec.program_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_clhv_rec.created_by);
    p6_a31 := ddx_clhv_rec.creation_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_clhv_rec.last_updated_by);
    p6_a33 := ddx_clhv_rec.last_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_clhv_rec.last_update_login);
    p6_a35 := ddx_clhv_rec.checklist_purpose_code;
    p6_a36 := ddx_clhv_rec.decision_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_clhv_rec.checklist_obj_id);
    p6_a38 := ddx_clhv_rec.checklist_obj_type_code;
    p6_a39 := rosetta_g_miss_num_map(ddx_clhv_rec.ckl_id);
  end;

  procedure update_checklist_inst_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddx_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clhv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clhv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clhv_rec.checklist_number := p5_a2;
    ddp_clhv_rec.description := p5_a3;
    ddp_clhv_rec.short_description := p5_a4;
    ddp_clhv_rec.checklist_type := p5_a5;
    ddp_clhv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_clhv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clhv_rec.status_code := p5_a8;
    ddp_clhv_rec.attribute_category := p5_a9;
    ddp_clhv_rec.attribute1 := p5_a10;
    ddp_clhv_rec.attribute2 := p5_a11;
    ddp_clhv_rec.attribute3 := p5_a12;
    ddp_clhv_rec.attribute4 := p5_a13;
    ddp_clhv_rec.attribute5 := p5_a14;
    ddp_clhv_rec.attribute6 := p5_a15;
    ddp_clhv_rec.attribute7 := p5_a16;
    ddp_clhv_rec.attribute8 := p5_a17;
    ddp_clhv_rec.attribute9 := p5_a18;
    ddp_clhv_rec.attribute10 := p5_a19;
    ddp_clhv_rec.attribute11 := p5_a20;
    ddp_clhv_rec.attribute12 := p5_a21;
    ddp_clhv_rec.attribute13 := p5_a22;
    ddp_clhv_rec.attribute14 := p5_a23;
    ddp_clhv_rec.attribute15 := p5_a24;
    ddp_clhv_rec.org_id := rosetta_g_miss_num_map(p5_a25);
    ddp_clhv_rec.request_id := rosetta_g_miss_num_map(p5_a26);
    ddp_clhv_rec.program_application_id := rosetta_g_miss_num_map(p5_a27);
    ddp_clhv_rec.program_id := rosetta_g_miss_num_map(p5_a28);
    ddp_clhv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clhv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_clhv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clhv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_clhv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_clhv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_clhv_rec.checklist_purpose_code := p5_a35;
    ddp_clhv_rec.decision_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clhv_rec.checklist_obj_id := rosetta_g_miss_num_map(p5_a37);
    ddp_clhv_rec.checklist_obj_type_code := p5_a38;
    ddp_clhv_rec.ckl_id := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.update_checklist_inst_hdr(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clhv_rec,
      ddx_clhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_clhv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_clhv_rec.object_version_number);
    p6_a2 := ddx_clhv_rec.checklist_number;
    p6_a3 := ddx_clhv_rec.description;
    p6_a4 := ddx_clhv_rec.short_description;
    p6_a5 := ddx_clhv_rec.checklist_type;
    p6_a6 := ddx_clhv_rec.start_date;
    p6_a7 := ddx_clhv_rec.end_date;
    p6_a8 := ddx_clhv_rec.status_code;
    p6_a9 := ddx_clhv_rec.attribute_category;
    p6_a10 := ddx_clhv_rec.attribute1;
    p6_a11 := ddx_clhv_rec.attribute2;
    p6_a12 := ddx_clhv_rec.attribute3;
    p6_a13 := ddx_clhv_rec.attribute4;
    p6_a14 := ddx_clhv_rec.attribute5;
    p6_a15 := ddx_clhv_rec.attribute6;
    p6_a16 := ddx_clhv_rec.attribute7;
    p6_a17 := ddx_clhv_rec.attribute8;
    p6_a18 := ddx_clhv_rec.attribute9;
    p6_a19 := ddx_clhv_rec.attribute10;
    p6_a20 := ddx_clhv_rec.attribute11;
    p6_a21 := ddx_clhv_rec.attribute12;
    p6_a22 := ddx_clhv_rec.attribute13;
    p6_a23 := ddx_clhv_rec.attribute14;
    p6_a24 := ddx_clhv_rec.attribute15;
    p6_a25 := rosetta_g_miss_num_map(ddx_clhv_rec.org_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_clhv_rec.request_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_clhv_rec.program_application_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_clhv_rec.program_id);
    p6_a29 := ddx_clhv_rec.program_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_clhv_rec.created_by);
    p6_a31 := ddx_clhv_rec.creation_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_clhv_rec.last_updated_by);
    p6_a33 := ddx_clhv_rec.last_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_clhv_rec.last_update_login);
    p6_a35 := ddx_clhv_rec.checklist_purpose_code;
    p6_a36 := ddx_clhv_rec.decision_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_clhv_rec.checklist_obj_id);
    p6_a38 := ddx_clhv_rec.checklist_obj_type_code;
    p6_a39 := rosetta_g_miss_num_map(ddx_clhv_rec.ckl_id);
  end;

  procedure delete_checklist_inst_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_clhv_rec okl_checklist_pvt.clhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clhv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clhv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clhv_rec.checklist_number := p5_a2;
    ddp_clhv_rec.description := p5_a3;
    ddp_clhv_rec.short_description := p5_a4;
    ddp_clhv_rec.checklist_type := p5_a5;
    ddp_clhv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_clhv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_clhv_rec.status_code := p5_a8;
    ddp_clhv_rec.attribute_category := p5_a9;
    ddp_clhv_rec.attribute1 := p5_a10;
    ddp_clhv_rec.attribute2 := p5_a11;
    ddp_clhv_rec.attribute3 := p5_a12;
    ddp_clhv_rec.attribute4 := p5_a13;
    ddp_clhv_rec.attribute5 := p5_a14;
    ddp_clhv_rec.attribute6 := p5_a15;
    ddp_clhv_rec.attribute7 := p5_a16;
    ddp_clhv_rec.attribute8 := p5_a17;
    ddp_clhv_rec.attribute9 := p5_a18;
    ddp_clhv_rec.attribute10 := p5_a19;
    ddp_clhv_rec.attribute11 := p5_a20;
    ddp_clhv_rec.attribute12 := p5_a21;
    ddp_clhv_rec.attribute13 := p5_a22;
    ddp_clhv_rec.attribute14 := p5_a23;
    ddp_clhv_rec.attribute15 := p5_a24;
    ddp_clhv_rec.org_id := rosetta_g_miss_num_map(p5_a25);
    ddp_clhv_rec.request_id := rosetta_g_miss_num_map(p5_a26);
    ddp_clhv_rec.program_application_id := rosetta_g_miss_num_map(p5_a27);
    ddp_clhv_rec.program_id := rosetta_g_miss_num_map(p5_a28);
    ddp_clhv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_clhv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_clhv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clhv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_clhv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_clhv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_clhv_rec.checklist_purpose_code := p5_a35;
    ddp_clhv_rec.decision_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_clhv_rec.checklist_obj_id := rosetta_g_miss_num_map(p5_a37);
    ddp_clhv_rec.checklist_obj_type_code := p5_a38;
    ddp_clhv_rec.ckl_id := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.delete_checklist_inst_hdr(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_checklist_inst_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddx_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cld_pvt_w.rosetta_table_copy_in_p2(ddp_cldv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.create_checklist_inst_dtl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cldv_tbl,
      ddx_cldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cld_pvt_w.rosetta_table_copy_out_p2(ddx_cldv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      );
  end;

  procedure update_checklist_inst_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddx_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cld_pvt_w.rosetta_table_copy_in_p2(ddp_cldv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.update_checklist_inst_dtl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cldv_tbl,
      ddx_cldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cld_pvt_w.rosetta_table_copy_out_p2(ddx_cldv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      );
  end;

  procedure delete_checklist_inst_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_cldv_tbl okl_checklist_pvt.cldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cld_pvt_w.rosetta_table_copy_in_p2(ddp_cldv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_checklist_pvt.delete_checklist_inst_dtl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_checklist_pvt_w;

/
