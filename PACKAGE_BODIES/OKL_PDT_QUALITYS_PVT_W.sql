--------------------------------------------------------
--  DDL for Package Body OKL_PDT_QUALITYS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PDT_QUALITYS_PVT_W" as
  /* $Header: OKLOPQYB.pls 115.6 2002/12/24 04:12:15 sgorantl noship $ */
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

  procedure create_pdt_qualitys(p_api_version  NUMBER
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
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddx_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddx_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p6_a0
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
    okl_pdt_qualitys_pvt.create_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddp_qvev_tbl,
      ddx_pqyv_rec,
      ddx_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_pqyv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_pqyv_rec.object_version_number);
    p7_a2 := ddx_pqyv_rec.name;
    p7_a3 := ddx_pqyv_rec.description;
    p7_a4 := ddx_pqyv_rec.location_yn;
    p7_a5 := ddx_pqyv_rec.from_date;
    p7_a6 := ddx_pqyv_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_pqyv_rec.created_by);
    p7_a8 := ddx_pqyv_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_updated_by);
    p7_a10 := ddx_pqyv_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_update_login);

    okl_qve_pvt_w.rosetta_table_copy_out_p5(ddx_qvev_tbl, p8_a0
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

  procedure update_pdt_qualitys(p_api_version  NUMBER
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
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddx_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddx_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p6_a0
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
    okl_pdt_qualitys_pvt.update_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddp_qvev_tbl,
      ddx_pqyv_rec,
      ddx_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_pqyv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_pqyv_rec.object_version_number);
    p7_a2 := ddx_pqyv_rec.name;
    p7_a3 := ddx_pqyv_rec.description;
    p7_a4 := ddx_pqyv_rec.location_yn;
    p7_a5 := ddx_pqyv_rec.from_date;
    p7_a6 := ddx_pqyv_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_pqyv_rec.created_by);
    p7_a8 := ddx_pqyv_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_updated_by);
    p7_a10 := ddx_pqyv_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_update_login);

    okl_qve_pvt_w.rosetta_table_copy_out_p5(ddx_qvev_tbl, p8_a0
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

  procedure validate_pdt_qualitys(p_api_version  NUMBER
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p6_a0
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
    okl_pdt_qualitys_pvt.validate_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddp_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddx_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pqy_pvt_w.rosetta_table_copy_in_p5(ddp_pqyv_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.create_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_tbl,
      ddx_pqyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pqy_pvt_w.rosetta_table_copy_out_p5(ddx_pqyv_tbl, p6_a0
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

  procedure create_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
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
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddx_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.create_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddx_pqyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pqyv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pqyv_rec.object_version_number);
    p6_a2 := ddx_pqyv_rec.name;
    p6_a3 := ddx_pqyv_rec.description;
    p6_a4 := ddx_pqyv_rec.location_yn;
    p6_a5 := ddx_pqyv_rec.from_date;
    p6_a6 := ddx_pqyv_rec.to_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_pqyv_rec.created_by);
    p6_a8 := ddx_pqyv_rec.creation_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_updated_by);
    p6_a10 := ddx_pqyv_rec.last_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_update_login);
  end;

  procedure lock_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pqy_pvt_w.rosetta_table_copy_in_p5(ddp_pqyv_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.lock_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.lock_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddx_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pqy_pvt_w.rosetta_table_copy_in_p5(ddp_pqyv_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.update_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_tbl,
      ddx_pqyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pqy_pvt_w.rosetta_table_copy_out_p5(ddx_pqyv_tbl, p6_a0
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

  procedure update_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
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
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddx_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.update_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddx_pqyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pqyv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pqyv_rec.object_version_number);
    p6_a2 := ddx_pqyv_rec.name;
    p6_a3 := ddx_pqyv_rec.description;
    p6_a4 := ddx_pqyv_rec.location_yn;
    p6_a5 := ddx_pqyv_rec.from_date;
    p6_a6 := ddx_pqyv_rec.to_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_pqyv_rec.created_by);
    p6_a8 := ddx_pqyv_rec.creation_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_updated_by);
    p6_a10 := ddx_pqyv_rec.last_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_pqyv_rec.last_update_login);
  end;

  procedure delete_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pqy_pvt_w.rosetta_table_copy_in_p5(ddp_pqyv_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.delete_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.delete_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_pqyv_tbl okl_pdt_qualitys_pvt.pqyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pqy_pvt_w.rosetta_table_copy_in_p5(ddp_pqyv_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.validate_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_pdt_qualitys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
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
    ddp_pqyv_rec okl_pdt_qualitys_pvt.pqyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.validate_pdt_qualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddx_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.create_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_tbl,
      ddx_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qve_pvt_w.rosetta_table_copy_out_p5(ddx_qvev_tbl, p6_a0
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

  procedure create_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddx_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qvev_rec.value := p5_a3;
    ddp_qvev_rec.description := p5_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.create_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_rec,
      ddx_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qvev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qvev_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_qvev_rec.pqy_id);
    p6_a3 := ddx_qvev_rec.value;
    p6_a4 := ddx_qvev_rec.description;
    p6_a5 := ddx_qvev_rec.from_date;
    p6_a6 := ddx_qvev_rec.to_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_qvev_rec.created_by);
    p6_a8 := ddx_qvev_rec.creation_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_qvev_rec.last_updated_by);
    p6_a10 := ddx_qvev_rec.last_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_qvev_rec.last_update_login);
  end;

  procedure lock_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.lock_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qvev_rec.value := p5_a3;
    ddp_qvev_rec.description := p5_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.lock_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddx_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.update_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_tbl,
      ddx_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qve_pvt_w.rosetta_table_copy_out_p5(ddx_qvev_tbl, p6_a0
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

  procedure update_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddx_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qvev_rec.value := p5_a3;
    ddp_qvev_rec.description := p5_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.update_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_rec,
      ddx_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qvev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qvev_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_qvev_rec.pqy_id);
    p6_a3 := ddx_qvev_rec.value;
    p6_a4 := ddx_qvev_rec.description;
    p6_a5 := ddx_qvev_rec.from_date;
    p6_a6 := ddx_qvev_rec.to_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_qvev_rec.created_by);
    p6_a8 := ddx_qvev_rec.creation_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_qvev_rec.last_updated_by);
    p6_a10 := ddx_qvev_rec.last_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_qvev_rec.last_update_login);
  end;

  procedure delete_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.delete_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qvev_rec.value := p5_a3;
    ddp_qvev_rec.description := p5_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.delete_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_tbl okl_pdt_qualitys_pvt.qvev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qve_pvt_w.rosetta_table_copy_in_p5(ddp_qvev_tbl, p5_a0
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
    okl_pdt_qualitys_pvt.validate_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_pdt_quality_vals(p_api_version  NUMBER
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
    ddp_qvev_rec okl_pdt_qualitys_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qvev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qvev_rec.value := p5_a3;
    ddp_qvev_rec.description := p5_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_qualitys_pvt.validate_pdt_quality_vals(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_pdt_qualitys_pvt_w;

/
