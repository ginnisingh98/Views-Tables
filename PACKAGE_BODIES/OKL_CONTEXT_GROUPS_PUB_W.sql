--------------------------------------------------------
--  DDL for Package Body OKL_CONTEXT_GROUPS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTEXT_GROUPS_PUB_W" as
  /* $Header: OKLUCGRB.pls 120.1 2005/07/08 10:19:54 asawanka noship $ */
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

  procedure insert_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddx_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgrv_rec.sfwt_flag := p5_a2;
    ddp_cgrv_rec.name := p5_a3;
    ddp_cgrv_rec.description := p5_a4;
    ddp_cgrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_cgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_cgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_cgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_cgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);


    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.insert_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_rec,
      ddx_cgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cgrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cgrv_rec.object_version_number);
    p6_a2 := ddx_cgrv_rec.sfwt_flag;
    p6_a3 := ddx_cgrv_rec.name;
    p6_a4 := ddx_cgrv_rec.description;
    p6_a5 := rosetta_g_miss_num_map(ddx_cgrv_rec.created_by);
    p6_a6 := ddx_cgrv_rec.creation_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_cgrv_rec.last_updated_by);
    p6_a8 := ddx_cgrv_rec.last_update_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_cgrv_rec.last_update_login);
  end;

  procedure insert_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddx_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgr_pvt_w.rosetta_table_copy_in_p8(ddp_cgrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.insert_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_tbl,
      ddx_cgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cgr_pvt_w.rosetta_table_copy_out_p8(ddx_cgrv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure lock_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgrv_rec.sfwt_flag := p5_a2;
    ddp_cgrv_rec.name := p5_a3;
    ddp_cgrv_rec.description := p5_a4;
    ddp_cgrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_cgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_cgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_cgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_cgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.lock_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgr_pvt_w.rosetta_table_copy_in_p8(ddp_cgrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.lock_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddx_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgrv_rec.sfwt_flag := p5_a2;
    ddp_cgrv_rec.name := p5_a3;
    ddp_cgrv_rec.description := p5_a4;
    ddp_cgrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_cgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_cgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_cgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_cgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);


    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.update_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_rec,
      ddx_cgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cgrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cgrv_rec.object_version_number);
    p6_a2 := ddx_cgrv_rec.sfwt_flag;
    p6_a3 := ddx_cgrv_rec.name;
    p6_a4 := ddx_cgrv_rec.description;
    p6_a5 := rosetta_g_miss_num_map(ddx_cgrv_rec.created_by);
    p6_a6 := ddx_cgrv_rec.creation_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_cgrv_rec.last_updated_by);
    p6_a8 := ddx_cgrv_rec.last_update_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_cgrv_rec.last_update_login);
  end;

  procedure update_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddx_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgr_pvt_w.rosetta_table_copy_in_p8(ddp_cgrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.update_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_tbl,
      ddx_cgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cgr_pvt_w.rosetta_table_copy_out_p8(ddx_cgrv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure delete_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgrv_rec.sfwt_flag := p5_a2;
    ddp_cgrv_rec.name := p5_a3;
    ddp_cgrv_rec.description := p5_a4;
    ddp_cgrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_cgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_cgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_cgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_cgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.delete_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgr_pvt_w.rosetta_table_copy_in_p8(ddp_cgrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.delete_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_cgrv_rec okl_context_groups_pub.cgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgrv_rec.sfwt_flag := p5_a2;
    ddp_cgrv_rec.name := p5_a3;
    ddp_cgrv_rec.description := p5_a4;
    ddp_cgrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_cgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_cgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_cgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_cgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.validate_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_context_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_cgrv_tbl okl_context_groups_pub.cgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgr_pvt_w.rosetta_table_copy_in_p8(ddp_cgrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_context_groups_pub.validate_context_groups(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_context_groups_pub_w;

/
