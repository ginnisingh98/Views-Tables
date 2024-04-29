--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPOVALUES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPOVALUES_PVT_W" as
  /* $Header: OKLESDVB.pls 115.2 2002/12/24 04:00:47 sgorantl noship $ */
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

  procedure get_rec(x_no_data_found out nocopy  number
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  NUMBER
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  DATE
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  DATE
    , p3_a7 out nocopy  DATE
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  DATE
    , p3_a10 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_povv_rec okl_setuppovalues_pvt.povv_rec_type;
    ddx_no_data_found boolean;
    ddx_povv_rec okl_setuppovalues_pvt.povv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_povv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_povv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_povv_rec.ove_id := rosetta_g_miss_num_map(p0_a2);
    ddp_povv_rec.pon_id := rosetta_g_miss_num_map(p0_a3);
    ddp_povv_rec.from_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_povv_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_povv_rec.to_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_povv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_povv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a8);
    ddp_povv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_povv_rec.last_update_login := rosetta_g_miss_num_map(p0_a10);




    -- here's the delegated call to the old PL/SQL routine
    okl_setuppovalues_pvt.get_rec(ddp_povv_rec,
      ddx_no_data_found,
      x_return_status,
      ddx_povv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;


    p3_a0 := rosetta_g_miss_num_map(ddx_povv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_povv_rec.object_version_number);
    p3_a2 := rosetta_g_miss_num_map(ddx_povv_rec.ove_id);
    p3_a3 := rosetta_g_miss_num_map(ddx_povv_rec.pon_id);
    p3_a4 := ddx_povv_rec.from_date;
    p3_a5 := rosetta_g_miss_num_map(ddx_povv_rec.created_by);
    p3_a6 := ddx_povv_rec.to_date;
    p3_a7 := ddx_povv_rec.creation_date;
    p3_a8 := rosetta_g_miss_num_map(ddx_povv_rec.last_updated_by);
    p3_a9 := ddx_povv_rec.last_update_date;
    p3_a10 := rosetta_g_miss_num_map(ddx_povv_rec.last_update_login);
  end;

  procedure insert_povalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  DATE
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  DATE := fnd_api.g_miss_date
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_pdtv_rec okl_setuppovalues_pvt.pdtv_rec_type;
    ddp_optv_rec okl_setuppovalues_pvt.optv_rec_type;
    ddp_povv_rec okl_setuppovalues_pvt.povv_rec_type;
    ddx_povv_rec okl_setuppovalues_pvt.povv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pdtv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pdtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pdtv_rec.aes_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pdtv_rec.ptl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pdtv_rec.name := p5_a4;
    ddp_pdtv_rec.description := p5_a5;
    ddp_pdtv_rec.reporting_pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_pdtv_rec.legacy_product_yn := p5_a7;
    ddp_pdtv_rec.from_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pdtv_rec.version := p5_a9;
    ddp_pdtv_rec.to_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pdtv_rec.attribute_category := p5_a11;
    ddp_pdtv_rec.attribute1 := p5_a12;
    ddp_pdtv_rec.attribute2 := p5_a13;
    ddp_pdtv_rec.attribute3 := p5_a14;
    ddp_pdtv_rec.attribute4 := p5_a15;
    ddp_pdtv_rec.attribute5 := p5_a16;
    ddp_pdtv_rec.attribute6 := p5_a17;
    ddp_pdtv_rec.attribute7 := p5_a18;
    ddp_pdtv_rec.attribute8 := p5_a19;
    ddp_pdtv_rec.attribute9 := p5_a20;
    ddp_pdtv_rec.attribute10 := p5_a21;
    ddp_pdtv_rec.attribute11 := p5_a22;
    ddp_pdtv_rec.attribute12 := p5_a23;
    ddp_pdtv_rec.attribute13 := p5_a24;
    ddp_pdtv_rec.attribute14 := p5_a25;
    ddp_pdtv_rec.attribute15 := p5_a26;
    ddp_pdtv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pdtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pdtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pdtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pdtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    ddp_optv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_optv_rec.name := p6_a2;
    ddp_optv_rec.description := p6_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_optv_rec.attribute_category := p6_a6;
    ddp_optv_rec.attribute1 := p6_a7;
    ddp_optv_rec.attribute2 := p6_a8;
    ddp_optv_rec.attribute3 := p6_a9;
    ddp_optv_rec.attribute4 := p6_a10;
    ddp_optv_rec.attribute5 := p6_a11;
    ddp_optv_rec.attribute6 := p6_a12;
    ddp_optv_rec.attribute7 := p6_a13;
    ddp_optv_rec.attribute8 := p6_a14;
    ddp_optv_rec.attribute9 := p6_a15;
    ddp_optv_rec.attribute10 := p6_a16;
    ddp_optv_rec.attribute11 := p6_a17;
    ddp_optv_rec.attribute12 := p6_a18;
    ddp_optv_rec.attribute13 := p6_a19;
    ddp_optv_rec.attribute14 := p6_a20;
    ddp_optv_rec.attribute15 := p6_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p6_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p6_a26);

    ddp_povv_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_povv_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_povv_rec.ove_id := rosetta_g_miss_num_map(p7_a2);
    ddp_povv_rec.pon_id := rosetta_g_miss_num_map(p7_a3);
    ddp_povv_rec.from_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_povv_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_povv_rec.to_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_povv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_povv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a8);
    ddp_povv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_povv_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuppovalues_pvt.insert_povalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddp_optv_rec,
      ddp_povv_rec,
      ddx_povv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_povv_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_povv_rec.object_version_number);
    p8_a2 := rosetta_g_miss_num_map(ddx_povv_rec.ove_id);
    p8_a3 := rosetta_g_miss_num_map(ddx_povv_rec.pon_id);
    p8_a4 := ddx_povv_rec.from_date;
    p8_a5 := rosetta_g_miss_num_map(ddx_povv_rec.created_by);
    p8_a6 := ddx_povv_rec.to_date;
    p8_a7 := ddx_povv_rec.creation_date;
    p8_a8 := rosetta_g_miss_num_map(ddx_povv_rec.last_updated_by);
    p8_a9 := ddx_povv_rec.last_update_date;
    p8_a10 := rosetta_g_miss_num_map(ddx_povv_rec.last_update_login);
  end;

  procedure delete_povalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  DATE := fnd_api.g_miss_date
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_pdtv_rec okl_setuppovalues_pvt.pdtv_rec_type;
    ddp_optv_rec okl_setuppovalues_pvt.optv_rec_type;
    ddp_povv_tbl okl_setuppovalues_pvt.povv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pdtv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pdtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pdtv_rec.aes_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pdtv_rec.ptl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pdtv_rec.name := p5_a4;
    ddp_pdtv_rec.description := p5_a5;
    ddp_pdtv_rec.reporting_pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_pdtv_rec.legacy_product_yn := p5_a7;
    ddp_pdtv_rec.from_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pdtv_rec.version := p5_a9;
    ddp_pdtv_rec.to_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pdtv_rec.attribute_category := p5_a11;
    ddp_pdtv_rec.attribute1 := p5_a12;
    ddp_pdtv_rec.attribute2 := p5_a13;
    ddp_pdtv_rec.attribute3 := p5_a14;
    ddp_pdtv_rec.attribute4 := p5_a15;
    ddp_pdtv_rec.attribute5 := p5_a16;
    ddp_pdtv_rec.attribute6 := p5_a17;
    ddp_pdtv_rec.attribute7 := p5_a18;
    ddp_pdtv_rec.attribute8 := p5_a19;
    ddp_pdtv_rec.attribute9 := p5_a20;
    ddp_pdtv_rec.attribute10 := p5_a21;
    ddp_pdtv_rec.attribute11 := p5_a22;
    ddp_pdtv_rec.attribute12 := p5_a23;
    ddp_pdtv_rec.attribute13 := p5_a24;
    ddp_pdtv_rec.attribute14 := p5_a25;
    ddp_pdtv_rec.attribute15 := p5_a26;
    ddp_pdtv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pdtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pdtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pdtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pdtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    ddp_optv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_optv_rec.name := p6_a2;
    ddp_optv_rec.description := p6_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_optv_rec.attribute_category := p6_a6;
    ddp_optv_rec.attribute1 := p6_a7;
    ddp_optv_rec.attribute2 := p6_a8;
    ddp_optv_rec.attribute3 := p6_a9;
    ddp_optv_rec.attribute4 := p6_a10;
    ddp_optv_rec.attribute5 := p6_a11;
    ddp_optv_rec.attribute6 := p6_a12;
    ddp_optv_rec.attribute7 := p6_a13;
    ddp_optv_rec.attribute8 := p6_a14;
    ddp_optv_rec.attribute9 := p6_a15;
    ddp_optv_rec.attribute10 := p6_a16;
    ddp_optv_rec.attribute11 := p6_a17;
    ddp_optv_rec.attribute12 := p6_a18;
    ddp_optv_rec.attribute13 := p6_a19;
    ddp_optv_rec.attribute14 := p6_a20;
    ddp_optv_rec.attribute15 := p6_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p6_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p6_a26);

    okl_pov_pvt_w.rosetta_table_copy_in_p5(ddp_povv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_setuppovalues_pvt.delete_povalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddp_optv_rec,
      ddp_povv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_setuppovalues_pvt_w;

/
