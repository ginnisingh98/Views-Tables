--------------------------------------------------------
--  DDL for Package Body OKL_FNCTN_PRMTRS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FNCTN_PRMTRS_PUB_W" as
  /* $Header: OKLUFPRB.pls 120.1 2005/07/12 07:07:03 asawanka noship $ */
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

  procedure insert_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddx_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fprv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fprv_rec.sfwt_flag := p5_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p5_a5);
    ddp_fprv_rec.value := p5_a6;
    ddp_fprv_rec.instructions := p5_a7;
    ddp_fprv_rec.fpr_type := p5_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.insert_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_rec,
      ddx_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fprv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fprv_rec.object_version_number);
    p6_a2 := ddx_fprv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_fprv_rec.dsf_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_fprv_rec.pmr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_fprv_rec.sequence_number);
    p6_a6 := ddx_fprv_rec.value;
    p6_a7 := ddx_fprv_rec.instructions;
    p6_a8 := ddx_fprv_rec.fpr_type;
    p6_a9 := rosetta_g_miss_num_map(ddx_fprv_rec.created_by);
    p6_a10 := ddx_fprv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_fprv_rec.last_updated_by);
    p6_a12 := ddx_fprv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_fprv_rec.last_update_login);
  end;

  procedure insert_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_800
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddx_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.insert_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_tbl,
      ddx_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fpr_pvt_w.rosetta_table_copy_out_p8(ddx_fprv_tbl, p6_a0
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
      );
  end;

  procedure lock_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fprv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fprv_rec.sfwt_flag := p5_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p5_a5);
    ddp_fprv_rec.value := p5_a6;
    ddp_fprv_rec.instructions := p5_a7;
    ddp_fprv_rec.fpr_type := p5_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.lock_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_800
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.lock_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddx_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fprv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fprv_rec.sfwt_flag := p5_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p5_a5);
    ddp_fprv_rec.value := p5_a6;
    ddp_fprv_rec.instructions := p5_a7;
    ddp_fprv_rec.fpr_type := p5_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.update_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_rec,
      ddx_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fprv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_fprv_rec.object_version_number);
    p6_a2 := ddx_fprv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_fprv_rec.dsf_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_fprv_rec.pmr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_fprv_rec.sequence_number);
    p6_a6 := ddx_fprv_rec.value;
    p6_a7 := ddx_fprv_rec.instructions;
    p6_a8 := ddx_fprv_rec.fpr_type;
    p6_a9 := rosetta_g_miss_num_map(ddx_fprv_rec.created_by);
    p6_a10 := ddx_fprv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_fprv_rec.last_updated_by);
    p6_a12 := ddx_fprv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_fprv_rec.last_update_login);
  end;

  procedure update_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_800
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddx_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.update_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_tbl,
      ddx_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fpr_pvt_w.rosetta_table_copy_out_p8(ddx_fprv_tbl, p6_a0
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
      );
  end;

  procedure delete_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fprv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fprv_rec.sfwt_flag := p5_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p5_a5);
    ddp_fprv_rec.value := p5_a6;
    ddp_fprv_rec.instructions := p5_a7;
    ddp_fprv_rec.fpr_type := p5_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.delete_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_800
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.delete_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_fprv_rec okl_fnctn_prmtrs_pub.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fprv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_fprv_rec.sfwt_flag := p5_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p5_a5);
    ddp_fprv_rec.value := p5_a6;
    ddp_fprv_rec.instructions := p5_a7;
    ddp_fprv_rec.fpr_type := p5_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.validate_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_fnctn_prmtrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_800
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_fprv_tbl okl_fnctn_prmtrs_pub.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_fnctn_prmtrs_pub.validate_fnctn_prmtrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_fnctn_prmtrs_pub_w;

/
