--------------------------------------------------------
--  DDL for Package Body OKL_PRTFL_CONTRACTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PRTFL_CONTRACTS_PUB_W" as
  /* $Header: OKLUPFCB.pls 115.1 2002/12/19 23:30:26 gkadarka noship $ */
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

  procedure insert_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_300
    , p5_a13 JTF_VARCHAR2_TABLE_300
    , p5_a14 JTF_VARCHAR2_TABLE_300
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddx_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pfc_pvt_w.rosetta_table_copy_in_p2(ddp_pfcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.insert_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_tbl,
      ddx_pfcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pfc_pvt_w.rosetta_table_copy_out_p2(ddx_pfcv_tbl, p6_a0
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
      );
  end;

  procedure insert_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
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
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
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
  )

  as
    ddp_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddx_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pfcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pfcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pfcv_rec.sfwt_flag := p5_a2;
    ddp_pfcv_rec.line_level_yn := p5_a3;
    ddp_pfcv_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pfcv_rec.name := p5_a5;
    ddp_pfcv_rec.description := p5_a6;
    ddp_pfcv_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_pfcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pfcv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_pfcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pfcv_rec.attribute_category := p5_a11;
    ddp_pfcv_rec.attribute1 := p5_a12;
    ddp_pfcv_rec.attribute2 := p5_a13;
    ddp_pfcv_rec.attribute3 := p5_a14;
    ddp_pfcv_rec.attribute4 := p5_a15;
    ddp_pfcv_rec.attribute5 := p5_a16;
    ddp_pfcv_rec.attribute6 := p5_a17;
    ddp_pfcv_rec.attribute7 := p5_a18;
    ddp_pfcv_rec.attribute8 := p5_a19;
    ddp_pfcv_rec.attribute9 := p5_a20;
    ddp_pfcv_rec.attribute10 := p5_a21;
    ddp_pfcv_rec.attribute11 := p5_a22;
    ddp_pfcv_rec.attribute12 := p5_a23;
    ddp_pfcv_rec.attribute13 := p5_a24;
    ddp_pfcv_rec.attribute14 := p5_a25;
    ddp_pfcv_rec.attribute15 := p5_a26;
    ddp_pfcv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pfcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pfcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pfcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pfcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.insert_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_rec,
      ddx_pfcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pfcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pfcv_rec.object_version_number);
    p6_a2 := ddx_pfcv_rec.sfwt_flag;
    p6_a3 := ddx_pfcv_rec.line_level_yn;
    p6_a4 := rosetta_g_miss_num_map(ddx_pfcv_rec.khr_id);
    p6_a5 := ddx_pfcv_rec.name;
    p6_a6 := ddx_pfcv_rec.description;
    p6_a7 := rosetta_g_miss_num_map(ddx_pfcv_rec.request_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_pfcv_rec.program_application_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_pfcv_rec.program_id);
    p6_a10 := ddx_pfcv_rec.program_update_date;
    p6_a11 := ddx_pfcv_rec.attribute_category;
    p6_a12 := ddx_pfcv_rec.attribute1;
    p6_a13 := ddx_pfcv_rec.attribute2;
    p6_a14 := ddx_pfcv_rec.attribute3;
    p6_a15 := ddx_pfcv_rec.attribute4;
    p6_a16 := ddx_pfcv_rec.attribute5;
    p6_a17 := ddx_pfcv_rec.attribute6;
    p6_a18 := ddx_pfcv_rec.attribute7;
    p6_a19 := ddx_pfcv_rec.attribute8;
    p6_a20 := ddx_pfcv_rec.attribute9;
    p6_a21 := ddx_pfcv_rec.attribute10;
    p6_a22 := ddx_pfcv_rec.attribute11;
    p6_a23 := ddx_pfcv_rec.attribute12;
    p6_a24 := ddx_pfcv_rec.attribute13;
    p6_a25 := ddx_pfcv_rec.attribute14;
    p6_a26 := ddx_pfcv_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_pfcv_rec.created_by);
    p6_a28 := ddx_pfcv_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_pfcv_rec.last_updated_by);
    p6_a30 := ddx_pfcv_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_pfcv_rec.last_update_login);
  end;

  procedure lock_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_300
    , p5_a13 JTF_VARCHAR2_TABLE_300
    , p5_a14 JTF_VARCHAR2_TABLE_300
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
  )

  as
    ddp_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pfc_pvt_w.rosetta_table_copy_in_p2(ddp_pfcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.lock_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
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
  )

  as
    ddp_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pfcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pfcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pfcv_rec.sfwt_flag := p5_a2;
    ddp_pfcv_rec.line_level_yn := p5_a3;
    ddp_pfcv_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pfcv_rec.name := p5_a5;
    ddp_pfcv_rec.description := p5_a6;
    ddp_pfcv_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_pfcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pfcv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_pfcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pfcv_rec.attribute_category := p5_a11;
    ddp_pfcv_rec.attribute1 := p5_a12;
    ddp_pfcv_rec.attribute2 := p5_a13;
    ddp_pfcv_rec.attribute3 := p5_a14;
    ddp_pfcv_rec.attribute4 := p5_a15;
    ddp_pfcv_rec.attribute5 := p5_a16;
    ddp_pfcv_rec.attribute6 := p5_a17;
    ddp_pfcv_rec.attribute7 := p5_a18;
    ddp_pfcv_rec.attribute8 := p5_a19;
    ddp_pfcv_rec.attribute9 := p5_a20;
    ddp_pfcv_rec.attribute10 := p5_a21;
    ddp_pfcv_rec.attribute11 := p5_a22;
    ddp_pfcv_rec.attribute12 := p5_a23;
    ddp_pfcv_rec.attribute13 := p5_a24;
    ddp_pfcv_rec.attribute14 := p5_a25;
    ddp_pfcv_rec.attribute15 := p5_a26;
    ddp_pfcv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pfcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pfcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pfcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pfcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.lock_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_300
    , p5_a13 JTF_VARCHAR2_TABLE_300
    , p5_a14 JTF_VARCHAR2_TABLE_300
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddx_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pfc_pvt_w.rosetta_table_copy_in_p2(ddp_pfcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.update_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_tbl,
      ddx_pfcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pfc_pvt_w.rosetta_table_copy_out_p2(ddx_pfcv_tbl, p6_a0
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
      );
  end;

  procedure update_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
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
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
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
  )

  as
    ddp_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddx_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pfcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pfcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pfcv_rec.sfwt_flag := p5_a2;
    ddp_pfcv_rec.line_level_yn := p5_a3;
    ddp_pfcv_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pfcv_rec.name := p5_a5;
    ddp_pfcv_rec.description := p5_a6;
    ddp_pfcv_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_pfcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pfcv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_pfcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pfcv_rec.attribute_category := p5_a11;
    ddp_pfcv_rec.attribute1 := p5_a12;
    ddp_pfcv_rec.attribute2 := p5_a13;
    ddp_pfcv_rec.attribute3 := p5_a14;
    ddp_pfcv_rec.attribute4 := p5_a15;
    ddp_pfcv_rec.attribute5 := p5_a16;
    ddp_pfcv_rec.attribute6 := p5_a17;
    ddp_pfcv_rec.attribute7 := p5_a18;
    ddp_pfcv_rec.attribute8 := p5_a19;
    ddp_pfcv_rec.attribute9 := p5_a20;
    ddp_pfcv_rec.attribute10 := p5_a21;
    ddp_pfcv_rec.attribute11 := p5_a22;
    ddp_pfcv_rec.attribute12 := p5_a23;
    ddp_pfcv_rec.attribute13 := p5_a24;
    ddp_pfcv_rec.attribute14 := p5_a25;
    ddp_pfcv_rec.attribute15 := p5_a26;
    ddp_pfcv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pfcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pfcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pfcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pfcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.update_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_rec,
      ddx_pfcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pfcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pfcv_rec.object_version_number);
    p6_a2 := ddx_pfcv_rec.sfwt_flag;
    p6_a3 := ddx_pfcv_rec.line_level_yn;
    p6_a4 := rosetta_g_miss_num_map(ddx_pfcv_rec.khr_id);
    p6_a5 := ddx_pfcv_rec.name;
    p6_a6 := ddx_pfcv_rec.description;
    p6_a7 := rosetta_g_miss_num_map(ddx_pfcv_rec.request_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_pfcv_rec.program_application_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_pfcv_rec.program_id);
    p6_a10 := ddx_pfcv_rec.program_update_date;
    p6_a11 := ddx_pfcv_rec.attribute_category;
    p6_a12 := ddx_pfcv_rec.attribute1;
    p6_a13 := ddx_pfcv_rec.attribute2;
    p6_a14 := ddx_pfcv_rec.attribute3;
    p6_a15 := ddx_pfcv_rec.attribute4;
    p6_a16 := ddx_pfcv_rec.attribute5;
    p6_a17 := ddx_pfcv_rec.attribute6;
    p6_a18 := ddx_pfcv_rec.attribute7;
    p6_a19 := ddx_pfcv_rec.attribute8;
    p6_a20 := ddx_pfcv_rec.attribute9;
    p6_a21 := ddx_pfcv_rec.attribute10;
    p6_a22 := ddx_pfcv_rec.attribute11;
    p6_a23 := ddx_pfcv_rec.attribute12;
    p6_a24 := ddx_pfcv_rec.attribute13;
    p6_a25 := ddx_pfcv_rec.attribute14;
    p6_a26 := ddx_pfcv_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_pfcv_rec.created_by);
    p6_a28 := ddx_pfcv_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_pfcv_rec.last_updated_by);
    p6_a30 := ddx_pfcv_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_pfcv_rec.last_update_login);
  end;

  procedure delete_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_300
    , p5_a13 JTF_VARCHAR2_TABLE_300
    , p5_a14 JTF_VARCHAR2_TABLE_300
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
  )

  as
    ddp_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pfc_pvt_w.rosetta_table_copy_in_p2(ddp_pfcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.delete_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
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
  )

  as
    ddp_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pfcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pfcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pfcv_rec.sfwt_flag := p5_a2;
    ddp_pfcv_rec.line_level_yn := p5_a3;
    ddp_pfcv_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pfcv_rec.name := p5_a5;
    ddp_pfcv_rec.description := p5_a6;
    ddp_pfcv_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_pfcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pfcv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_pfcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pfcv_rec.attribute_category := p5_a11;
    ddp_pfcv_rec.attribute1 := p5_a12;
    ddp_pfcv_rec.attribute2 := p5_a13;
    ddp_pfcv_rec.attribute3 := p5_a14;
    ddp_pfcv_rec.attribute4 := p5_a15;
    ddp_pfcv_rec.attribute5 := p5_a16;
    ddp_pfcv_rec.attribute6 := p5_a17;
    ddp_pfcv_rec.attribute7 := p5_a18;
    ddp_pfcv_rec.attribute8 := p5_a19;
    ddp_pfcv_rec.attribute9 := p5_a20;
    ddp_pfcv_rec.attribute10 := p5_a21;
    ddp_pfcv_rec.attribute11 := p5_a22;
    ddp_pfcv_rec.attribute12 := p5_a23;
    ddp_pfcv_rec.attribute13 := p5_a24;
    ddp_pfcv_rec.attribute14 := p5_a25;
    ddp_pfcv_rec.attribute15 := p5_a26;
    ddp_pfcv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pfcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pfcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pfcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pfcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.delete_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_300
    , p5_a13 JTF_VARCHAR2_TABLE_300
    , p5_a14 JTF_VARCHAR2_TABLE_300
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
  )

  as
    ddp_pfcv_tbl okl_prtfl_contracts_pub.pfcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pfc_pvt_w.rosetta_table_copy_in_p2(ddp_pfcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.validate_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_prtfl_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
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
  )

  as
    ddp_pfcv_rec okl_prtfl_contracts_pub.pfcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pfcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pfcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pfcv_rec.sfwt_flag := p5_a2;
    ddp_pfcv_rec.line_level_yn := p5_a3;
    ddp_pfcv_rec.khr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pfcv_rec.name := p5_a5;
    ddp_pfcv_rec.description := p5_a6;
    ddp_pfcv_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_pfcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_pfcv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_pfcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pfcv_rec.attribute_category := p5_a11;
    ddp_pfcv_rec.attribute1 := p5_a12;
    ddp_pfcv_rec.attribute2 := p5_a13;
    ddp_pfcv_rec.attribute3 := p5_a14;
    ddp_pfcv_rec.attribute4 := p5_a15;
    ddp_pfcv_rec.attribute5 := p5_a16;
    ddp_pfcv_rec.attribute6 := p5_a17;
    ddp_pfcv_rec.attribute7 := p5_a18;
    ddp_pfcv_rec.attribute8 := p5_a19;
    ddp_pfcv_rec.attribute9 := p5_a20;
    ddp_pfcv_rec.attribute10 := p5_a21;
    ddp_pfcv_rec.attribute11 := p5_a22;
    ddp_pfcv_rec.attribute12 := p5_a23;
    ddp_pfcv_rec.attribute13 := p5_a24;
    ddp_pfcv_rec.attribute14 := p5_a25;
    ddp_pfcv_rec.attribute15 := p5_a26;
    ddp_pfcv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_pfcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_pfcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_pfcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_pfcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_prtfl_contracts_pub.validate_prtfl_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pfcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_prtfl_contracts_pub_w;

/
