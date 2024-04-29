--------------------------------------------------------
--  DDL for Package Body OKL_SETUPFORMULAE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPFORMULAE_PVT_W" as
  /* $Header: OKLESFMB.pls 120.1 2005/07/12 09:09:38 dkagrawa noship $ */
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

  procedure get_rec(x_return_status out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  DATE
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  NUMBER
    , p3_a30 out nocopy  DATE
    , p3_a31 out nocopy  NUMBER
    , p3_a32 out nocopy  DATE
    , p3_a33 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
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
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  NUMBER := 0-1962.0724
    , p0_a32  DATE := fnd_api.g_miss_date
    , p0_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_fmav_rec okl_setupformulae_pvt.fmav_rec_type;
    ddx_no_data_found boolean;
    ddx_fmav_rec okl_setupformulae_pvt.fmav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fmav_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_fmav_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_fmav_rec.sfwt_flag := p0_a2;
    ddp_fmav_rec.cgr_id := rosetta_g_miss_num_map(p0_a3);
    ddp_fmav_rec.fyp_code := p0_a4;
    ddp_fmav_rec.name := p0_a5;
    ddp_fmav_rec.formula_string := p0_a6;
    ddp_fmav_rec.description := p0_a7;
    ddp_fmav_rec.version := p0_a8;
    ddp_fmav_rec.start_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_fmav_rec.end_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_fmav_rec.attribute_category := p0_a11;
    ddp_fmav_rec.attribute1 := p0_a12;
    ddp_fmav_rec.attribute2 := p0_a13;
    ddp_fmav_rec.attribute3 := p0_a14;
    ddp_fmav_rec.attribute4 := p0_a15;
    ddp_fmav_rec.attribute5 := p0_a16;
    ddp_fmav_rec.attribute6 := p0_a17;
    ddp_fmav_rec.attribute7 := p0_a18;
    ddp_fmav_rec.attribute8 := p0_a19;
    ddp_fmav_rec.attribute9 := p0_a20;
    ddp_fmav_rec.attribute10 := p0_a21;
    ddp_fmav_rec.attribute11 := p0_a22;
    ddp_fmav_rec.attribute12 := p0_a23;
    ddp_fmav_rec.attribute13 := p0_a24;
    ddp_fmav_rec.attribute14 := p0_a25;
    ddp_fmav_rec.attribute15 := p0_a26;
    ddp_fmav_rec.org_id := rosetta_g_miss_num_map(p0_a27);
    ddp_fmav_rec.there_can_be_only_one_yn := p0_a28;
    ddp_fmav_rec.created_by := rosetta_g_miss_num_map(p0_a29);
    ddp_fmav_rec.creation_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_fmav_rec.last_updated_by := rosetta_g_miss_num_map(p0_a31);
    ddp_fmav_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a32);
    ddp_fmav_rec.last_update_login := rosetta_g_miss_num_map(p0_a33);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupformulae_pvt.get_rec(ddp_fmav_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_fmav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_fmav_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_fmav_rec.object_version_number);
    p3_a2 := ddx_fmav_rec.sfwt_flag;
    p3_a3 := rosetta_g_miss_num_map(ddx_fmav_rec.cgr_id);
    p3_a4 := ddx_fmav_rec.fyp_code;
    p3_a5 := ddx_fmav_rec.name;
    p3_a6 := ddx_fmav_rec.formula_string;
    p3_a7 := ddx_fmav_rec.description;
    p3_a8 := ddx_fmav_rec.version;
    p3_a9 := ddx_fmav_rec.start_date;
    p3_a10 := ddx_fmav_rec.end_date;
    p3_a11 := ddx_fmav_rec.attribute_category;
    p3_a12 := ddx_fmav_rec.attribute1;
    p3_a13 := ddx_fmav_rec.attribute2;
    p3_a14 := ddx_fmav_rec.attribute3;
    p3_a15 := ddx_fmav_rec.attribute4;
    p3_a16 := ddx_fmav_rec.attribute5;
    p3_a17 := ddx_fmav_rec.attribute6;
    p3_a18 := ddx_fmav_rec.attribute7;
    p3_a19 := ddx_fmav_rec.attribute8;
    p3_a20 := ddx_fmav_rec.attribute9;
    p3_a21 := ddx_fmav_rec.attribute10;
    p3_a22 := ddx_fmav_rec.attribute11;
    p3_a23 := ddx_fmav_rec.attribute12;
    p3_a24 := ddx_fmav_rec.attribute13;
    p3_a25 := ddx_fmav_rec.attribute14;
    p3_a26 := ddx_fmav_rec.attribute15;
    p3_a27 := rosetta_g_miss_num_map(ddx_fmav_rec.org_id);
    p3_a28 := ddx_fmav_rec.there_can_be_only_one_yn;
    p3_a29 := rosetta_g_miss_num_map(ddx_fmav_rec.created_by);
    p3_a30 := ddx_fmav_rec.creation_date;
    p3_a31 := rosetta_g_miss_num_map(ddx_fmav_rec.last_updated_by);
    p3_a32 := ddx_fmav_rec.last_update_date;
    p3_a33 := rosetta_g_miss_num_map(ddx_fmav_rec.last_update_login);
  end;

  procedure insert_formulae(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
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
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  DATE := fnd_api.g_miss_date
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
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_fmav_rec okl_setupformulae_pvt.fmav_rec_type;
    ddx_fmav_rec okl_setupformulae_pvt.fmav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fmav_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fmav_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fmav_rec.sfwt_flag := p5_a2;
    ddp_fmav_rec.cgr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fmav_rec.fyp_code := p5_a4;
    ddp_fmav_rec.name := p5_a5;
    ddp_fmav_rec.formula_string := p5_a6;
    ddp_fmav_rec.description := p5_a7;
    ddp_fmav_rec.version := p5_a8;
    ddp_fmav_rec.start_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_fmav_rec.end_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fmav_rec.attribute_category := p5_a11;
    ddp_fmav_rec.attribute1 := p5_a12;
    ddp_fmav_rec.attribute2 := p5_a13;
    ddp_fmav_rec.attribute3 := p5_a14;
    ddp_fmav_rec.attribute4 := p5_a15;
    ddp_fmav_rec.attribute5 := p5_a16;
    ddp_fmav_rec.attribute6 := p5_a17;
    ddp_fmav_rec.attribute7 := p5_a18;
    ddp_fmav_rec.attribute8 := p5_a19;
    ddp_fmav_rec.attribute9 := p5_a20;
    ddp_fmav_rec.attribute10 := p5_a21;
    ddp_fmav_rec.attribute11 := p5_a22;
    ddp_fmav_rec.attribute12 := p5_a23;
    ddp_fmav_rec.attribute13 := p5_a24;
    ddp_fmav_rec.attribute14 := p5_a25;
    ddp_fmav_rec.attribute15 := p5_a26;
    ddp_fmav_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_fmav_rec.there_can_be_only_one_yn := p5_a28;
    ddp_fmav_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_fmav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_fmav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_fmav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_fmav_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupformulae_pvt.insert_formulae(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fmav_rec,
      ddx_fmav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fmav_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fmav_rec.object_version_number);
    p6_a2 := ddx_fmav_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_fmav_rec.cgr_id);
    p6_a4 := ddx_fmav_rec.fyp_code;
    p6_a5 := ddx_fmav_rec.name;
    p6_a6 := ddx_fmav_rec.formula_string;
    p6_a7 := ddx_fmav_rec.description;
    p6_a8 := ddx_fmav_rec.version;
    p6_a9 := ddx_fmav_rec.start_date;
    p6_a10 := ddx_fmav_rec.end_date;
    p6_a11 := ddx_fmav_rec.attribute_category;
    p6_a12 := ddx_fmav_rec.attribute1;
    p6_a13 := ddx_fmav_rec.attribute2;
    p6_a14 := ddx_fmav_rec.attribute3;
    p6_a15 := ddx_fmav_rec.attribute4;
    p6_a16 := ddx_fmav_rec.attribute5;
    p6_a17 := ddx_fmav_rec.attribute6;
    p6_a18 := ddx_fmav_rec.attribute7;
    p6_a19 := ddx_fmav_rec.attribute8;
    p6_a20 := ddx_fmav_rec.attribute9;
    p6_a21 := ddx_fmav_rec.attribute10;
    p6_a22 := ddx_fmav_rec.attribute11;
    p6_a23 := ddx_fmav_rec.attribute12;
    p6_a24 := ddx_fmav_rec.attribute13;
    p6_a25 := ddx_fmav_rec.attribute14;
    p6_a26 := ddx_fmav_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_fmav_rec.org_id);
    p6_a28 := ddx_fmav_rec.there_can_be_only_one_yn;
    p6_a29 := rosetta_g_miss_num_map(ddx_fmav_rec.created_by);
    p6_a30 := ddx_fmav_rec.creation_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_fmav_rec.last_updated_by);
    p6_a32 := ddx_fmav_rec.last_update_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_fmav_rec.last_update_login);
  end;

  procedure update_formulae(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
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
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  DATE := fnd_api.g_miss_date
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
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
  )

  as
    ddp_fmav_rec okl_setupformulae_pvt.fmav_rec_type;
    ddx_fmav_rec okl_setupformulae_pvt.fmav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fmav_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fmav_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fmav_rec.sfwt_flag := p5_a2;
    ddp_fmav_rec.cgr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fmav_rec.fyp_code := p5_a4;
    ddp_fmav_rec.name := p5_a5;
    ddp_fmav_rec.formula_string := p5_a6;
    ddp_fmav_rec.description := p5_a7;
    ddp_fmav_rec.version := p5_a8;
    ddp_fmav_rec.start_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_fmav_rec.end_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fmav_rec.attribute_category := p5_a11;
    ddp_fmav_rec.attribute1 := p5_a12;
    ddp_fmav_rec.attribute2 := p5_a13;
    ddp_fmav_rec.attribute3 := p5_a14;
    ddp_fmav_rec.attribute4 := p5_a15;
    ddp_fmav_rec.attribute5 := p5_a16;
    ddp_fmav_rec.attribute6 := p5_a17;
    ddp_fmav_rec.attribute7 := p5_a18;
    ddp_fmav_rec.attribute8 := p5_a19;
    ddp_fmav_rec.attribute9 := p5_a20;
    ddp_fmav_rec.attribute10 := p5_a21;
    ddp_fmav_rec.attribute11 := p5_a22;
    ddp_fmav_rec.attribute12 := p5_a23;
    ddp_fmav_rec.attribute13 := p5_a24;
    ddp_fmav_rec.attribute14 := p5_a25;
    ddp_fmav_rec.attribute15 := p5_a26;
    ddp_fmav_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_fmav_rec.there_can_be_only_one_yn := p5_a28;
    ddp_fmav_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddp_fmav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_fmav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a31);
    ddp_fmav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_fmav_rec.last_update_login := rosetta_g_miss_num_map(p5_a33);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupformulae_pvt.update_formulae(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fmav_rec,
      ddx_fmav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fmav_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fmav_rec.object_version_number);
    p6_a2 := ddx_fmav_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_fmav_rec.cgr_id);
    p6_a4 := ddx_fmav_rec.fyp_code;
    p6_a5 := ddx_fmav_rec.name;
    p6_a6 := ddx_fmav_rec.formula_string;
    p6_a7 := ddx_fmav_rec.description;
    p6_a8 := ddx_fmav_rec.version;
    p6_a9 := ddx_fmav_rec.start_date;
    p6_a10 := ddx_fmav_rec.end_date;
    p6_a11 := ddx_fmav_rec.attribute_category;
    p6_a12 := ddx_fmav_rec.attribute1;
    p6_a13 := ddx_fmav_rec.attribute2;
    p6_a14 := ddx_fmav_rec.attribute3;
    p6_a15 := ddx_fmav_rec.attribute4;
    p6_a16 := ddx_fmav_rec.attribute5;
    p6_a17 := ddx_fmav_rec.attribute6;
    p6_a18 := ddx_fmav_rec.attribute7;
    p6_a19 := ddx_fmav_rec.attribute8;
    p6_a20 := ddx_fmav_rec.attribute9;
    p6_a21 := ddx_fmav_rec.attribute10;
    p6_a22 := ddx_fmav_rec.attribute11;
    p6_a23 := ddx_fmav_rec.attribute12;
    p6_a24 := ddx_fmav_rec.attribute13;
    p6_a25 := ddx_fmav_rec.attribute14;
    p6_a26 := ddx_fmav_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_fmav_rec.org_id);
    p6_a28 := ddx_fmav_rec.there_can_be_only_one_yn;
    p6_a29 := rosetta_g_miss_num_map(ddx_fmav_rec.created_by);
    p6_a30 := ddx_fmav_rec.creation_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_fmav_rec.last_updated_by);
    p6_a32 := ddx_fmav_rec.last_update_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_fmav_rec.last_update_login);
  end;

end okl_setupformulae_pvt_w;

/