--------------------------------------------------------
--  DDL for Package Body OKL_OPTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPTIONS_PVT_W" as
  /* $Header: OKLOOPTB.pls 115.4 2002/12/24 04:10:42 sgorantl noship $ */
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

  procedure create_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_200
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_DATE_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_DATE_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddx_optv_rec okl_options_pvt.optv_rec_type;
    ddx_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.create_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_tbl,
      ddx_optv_rec,
      ddx_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_optv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_optv_rec.object_version_number);
    p7_a2 := ddx_optv_rec.name;
    p7_a3 := ddx_optv_rec.description;
    p7_a4 := ddx_optv_rec.from_date;
    p7_a5 := ddx_optv_rec.to_date;
    p7_a6 := ddx_optv_rec.attribute_category;
    p7_a7 := ddx_optv_rec.attribute1;
    p7_a8 := ddx_optv_rec.attribute2;
    p7_a9 := ddx_optv_rec.attribute3;
    p7_a10 := ddx_optv_rec.attribute4;
    p7_a11 := ddx_optv_rec.attribute5;
    p7_a12 := ddx_optv_rec.attribute6;
    p7_a13 := ddx_optv_rec.attribute7;
    p7_a14 := ddx_optv_rec.attribute8;
    p7_a15 := ddx_optv_rec.attribute9;
    p7_a16 := ddx_optv_rec.attribute10;
    p7_a17 := ddx_optv_rec.attribute11;
    p7_a18 := ddx_optv_rec.attribute12;
    p7_a19 := ddx_optv_rec.attribute13;
    p7_a20 := ddx_optv_rec.attribute14;
    p7_a21 := ddx_optv_rec.attribute15;
    p7_a22 := rosetta_g_miss_num_map(ddx_optv_rec.created_by);
    p7_a23 := ddx_optv_rec.creation_date;
    p7_a24 := rosetta_g_miss_num_map(ddx_optv_rec.last_updated_by);
    p7_a25 := ddx_optv_rec.last_update_date;
    p7_a26 := rosetta_g_miss_num_map(ddx_optv_rec.last_update_login);

    okl_ove_pvt_w.rosetta_table_copy_out_p5(ddx_ovev_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      );
  end;

  procedure update_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_200
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_DATE_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_DATE_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddx_optv_rec okl_options_pvt.optv_rec_type;
    ddx_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.update_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_tbl,
      ddx_optv_rec,
      ddx_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_optv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_optv_rec.object_version_number);
    p7_a2 := ddx_optv_rec.name;
    p7_a3 := ddx_optv_rec.description;
    p7_a4 := ddx_optv_rec.from_date;
    p7_a5 := ddx_optv_rec.to_date;
    p7_a6 := ddx_optv_rec.attribute_category;
    p7_a7 := ddx_optv_rec.attribute1;
    p7_a8 := ddx_optv_rec.attribute2;
    p7_a9 := ddx_optv_rec.attribute3;
    p7_a10 := ddx_optv_rec.attribute4;
    p7_a11 := ddx_optv_rec.attribute5;
    p7_a12 := ddx_optv_rec.attribute6;
    p7_a13 := ddx_optv_rec.attribute7;
    p7_a14 := ddx_optv_rec.attribute8;
    p7_a15 := ddx_optv_rec.attribute9;
    p7_a16 := ddx_optv_rec.attribute10;
    p7_a17 := ddx_optv_rec.attribute11;
    p7_a18 := ddx_optv_rec.attribute12;
    p7_a19 := ddx_optv_rec.attribute13;
    p7_a20 := ddx_optv_rec.attribute14;
    p7_a21 := ddx_optv_rec.attribute15;
    p7_a22 := rosetta_g_miss_num_map(ddx_optv_rec.created_by);
    p7_a23 := ddx_optv_rec.creation_date;
    p7_a24 := rosetta_g_miss_num_map(ddx_optv_rec.last_updated_by);
    p7_a25 := ddx_optv_rec.last_update_date;
    p7_a26 := rosetta_g_miss_num_map(ddx_optv_rec.last_update_login);

    okl_ove_pvt_w.rosetta_table_copy_out_p5(ddx_ovev_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      );
  end;

  procedure validate_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_200
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_DATE_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_DATE_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.validate_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_optv_tbl okl_options_pvt.optv_tbl_type;
    ddx_optv_tbl okl_options_pvt.optv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opt_pvt_w.rosetta_table_copy_in_p5(ddp_optv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.create_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_tbl,
      ddx_optv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_opt_pvt_w.rosetta_table_copy_out_p5(ddx_optv_tbl, p6_a0
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
      );
  end;

  procedure create_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddx_optv_rec okl_options_pvt.optv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.create_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddx_optv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_optv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_optv_rec.object_version_number);
    p6_a2 := ddx_optv_rec.name;
    p6_a3 := ddx_optv_rec.description;
    p6_a4 := ddx_optv_rec.from_date;
    p6_a5 := ddx_optv_rec.to_date;
    p6_a6 := ddx_optv_rec.attribute_category;
    p6_a7 := ddx_optv_rec.attribute1;
    p6_a8 := ddx_optv_rec.attribute2;
    p6_a9 := ddx_optv_rec.attribute3;
    p6_a10 := ddx_optv_rec.attribute4;
    p6_a11 := ddx_optv_rec.attribute5;
    p6_a12 := ddx_optv_rec.attribute6;
    p6_a13 := ddx_optv_rec.attribute7;
    p6_a14 := ddx_optv_rec.attribute8;
    p6_a15 := ddx_optv_rec.attribute9;
    p6_a16 := ddx_optv_rec.attribute10;
    p6_a17 := ddx_optv_rec.attribute11;
    p6_a18 := ddx_optv_rec.attribute12;
    p6_a19 := ddx_optv_rec.attribute13;
    p6_a20 := ddx_optv_rec.attribute14;
    p6_a21 := ddx_optv_rec.attribute15;
    p6_a22 := rosetta_g_miss_num_map(ddx_optv_rec.created_by);
    p6_a23 := ddx_optv_rec.creation_date;
    p6_a24 := rosetta_g_miss_num_map(ddx_optv_rec.last_updated_by);
    p6_a25 := ddx_optv_rec.last_update_date;
    p6_a26 := rosetta_g_miss_num_map(ddx_optv_rec.last_update_login);
  end;

  procedure lock_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
  )

  as
    ddp_optv_tbl okl_options_pvt.optv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opt_pvt_w.rosetta_table_copy_in_p5(ddp_optv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.lock_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.lock_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_optv_tbl okl_options_pvt.optv_tbl_type;
    ddx_optv_tbl okl_options_pvt.optv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opt_pvt_w.rosetta_table_copy_in_p5(ddp_optv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.update_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_tbl,
      ddx_optv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_opt_pvt_w.rosetta_table_copy_out_p5(ddx_optv_tbl, p6_a0
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
      );
  end;

  procedure update_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddx_optv_rec okl_options_pvt.optv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.update_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddx_optv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_optv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_optv_rec.object_version_number);
    p6_a2 := ddx_optv_rec.name;
    p6_a3 := ddx_optv_rec.description;
    p6_a4 := ddx_optv_rec.from_date;
    p6_a5 := ddx_optv_rec.to_date;
    p6_a6 := ddx_optv_rec.attribute_category;
    p6_a7 := ddx_optv_rec.attribute1;
    p6_a8 := ddx_optv_rec.attribute2;
    p6_a9 := ddx_optv_rec.attribute3;
    p6_a10 := ddx_optv_rec.attribute4;
    p6_a11 := ddx_optv_rec.attribute5;
    p6_a12 := ddx_optv_rec.attribute6;
    p6_a13 := ddx_optv_rec.attribute7;
    p6_a14 := ddx_optv_rec.attribute8;
    p6_a15 := ddx_optv_rec.attribute9;
    p6_a16 := ddx_optv_rec.attribute10;
    p6_a17 := ddx_optv_rec.attribute11;
    p6_a18 := ddx_optv_rec.attribute12;
    p6_a19 := ddx_optv_rec.attribute13;
    p6_a20 := ddx_optv_rec.attribute14;
    p6_a21 := ddx_optv_rec.attribute15;
    p6_a22 := rosetta_g_miss_num_map(ddx_optv_rec.created_by);
    p6_a23 := ddx_optv_rec.creation_date;
    p6_a24 := rosetta_g_miss_num_map(ddx_optv_rec.last_updated_by);
    p6_a25 := ddx_optv_rec.last_update_date;
    p6_a26 := rosetta_g_miss_num_map(ddx_optv_rec.last_update_login);
  end;

  procedure delete_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
  )

  as
    ddp_optv_tbl okl_options_pvt.optv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opt_pvt_w.rosetta_table_copy_in_p5(ddp_optv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.delete_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.delete_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
  )

  as
    ddp_optv_tbl okl_options_pvt.optv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opt_pvt_w.rosetta_table_copy_in_p5(ddp_optv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.validate_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_options(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_options_pvt.optv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.validate_options(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddx_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.create_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_tbl,
      ddx_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ove_pvt_w.rosetta_table_copy_out_p5(ddx_ovev_tbl, p6_a0
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
      );
  end;

  procedure create_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ovev_rec okl_options_pvt.ovev_rec_type;
    ddx_ovev_rec okl_options_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ovev_rec.value := p5_a3;
    ddp_ovev_rec.description := p5_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.create_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_rec,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p6_a3 := ddx_ovev_rec.value;
    p6_a4 := ddx_ovev_rec.description;
    p6_a5 := ddx_ovev_rec.from_date;
    p6_a6 := ddx_ovev_rec.to_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p6_a8 := ddx_ovev_rec.creation_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p6_a10 := ddx_ovev_rec.last_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

  procedure lock_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.lock_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ovev_rec okl_options_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ovev_rec.value := p5_a3;
    ddp_ovev_rec.description := p5_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.lock_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddx_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.update_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_tbl,
      ddx_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ove_pvt_w.rosetta_table_copy_out_p5(ddx_ovev_tbl, p6_a0
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
      );
  end;

  procedure update_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ovev_rec okl_options_pvt.ovev_rec_type;
    ddx_ovev_rec okl_options_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ovev_rec.value := p5_a3;
    ddp_ovev_rec.description := p5_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.update_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_rec,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p6_a3 := ddx_ovev_rec.value;
    p6_a4 := ddx_ovev_rec.description;
    p6_a5 := ddx_ovev_rec.from_date;
    p6_a6 := ddx_ovev_rec.to_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p6_a8 := ddx_ovev_rec.creation_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p6_a10 := ddx_ovev_rec.last_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

  procedure delete_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.delete_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ovev_rec okl_options_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ovev_rec.value := p5_a3;
    ddp_ovev_rec.description := p5_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.delete_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_ovev_tbl okl_options_pvt.ovev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ove_pvt_w.rosetta_table_copy_in_p5(ddp_ovev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.validate_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_option_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ovev_rec okl_options_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ovev_rec.value := p5_a3;
    ddp_ovev_rec.description := p5_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_options_pvt.validate_option_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_options_pvt_w;

/
