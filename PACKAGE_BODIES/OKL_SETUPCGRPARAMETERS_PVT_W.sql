--------------------------------------------------------
--  DDL for Package Body OKL_SETUPCGRPARAMETERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPCGRPARAMETERS_PVT_W" as
  /* $Header: OKLESCMB.pls 120.1 2005/07/12 09:08:48 dkagrawa noship $ */
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
    , p3_a2 out nocopy  NUMBER
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  DATE
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  DATE
    , p3_a8 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
  )

  as
    ddp_cgmv_rec okl_setupcgrparameters_pvt.cgmv_rec_type;
    ddx_no_data_found boolean;
    ddx_cgmv_rec okl_setupcgrparameters_pvt.cgmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cgmv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_cgmv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_cgmv_rec.cgr_id := rosetta_g_miss_num_map(p0_a2);
    ddp_cgmv_rec.pmr_id := rosetta_g_miss_num_map(p0_a3);
    ddp_cgmv_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_cgmv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_cgmv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a6);
    ddp_cgmv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_cgmv_rec.last_update_login := rosetta_g_miss_num_map(p0_a8);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupcgrparameters_pvt.get_rec(ddp_cgmv_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_cgmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_cgmv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_cgmv_rec.object_version_number);
    p3_a2 := rosetta_g_miss_num_map(ddx_cgmv_rec.cgr_id);
    p3_a3 := rosetta_g_miss_num_map(ddx_cgmv_rec.pmr_id);
    p3_a4 := rosetta_g_miss_num_map(ddx_cgmv_rec.created_by);
    p3_a5 := ddx_cgmv_rec.creation_date;
    p3_a6 := rosetta_g_miss_num_map(ddx_cgmv_rec.last_updated_by);
    p3_a7 := ddx_cgmv_rec.last_update_date;
    p3_a8 := rosetta_g_miss_num_map(ddx_cgmv_rec.last_update_login);
  end;

  procedure insert_cgrparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
  )

  as
    ddp_cgmv_rec okl_setupcgrparameters_pvt.cgmv_rec_type;
    ddx_cgmv_rec okl_setupcgrparameters_pvt.cgmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgmv_rec.cgr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_cgmv_rec.pmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cgmv_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_cgmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_cgmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a6);
    ddp_cgmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_cgmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a8);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupcgrparameters_pvt.insert_cgrparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgmv_rec,
      ddx_cgmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cgmv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cgmv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_cgmv_rec.cgr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_cgmv_rec.pmr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cgmv_rec.created_by);
    p6_a5 := ddx_cgmv_rec.creation_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_cgmv_rec.last_updated_by);
    p6_a7 := ddx_cgmv_rec.last_update_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_cgmv_rec.last_update_login);
  end;

  procedure update_cgrparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
  )

  as
    ddp_cgmv_rec okl_setupcgrparameters_pvt.cgmv_rec_type;
    ddx_cgmv_rec okl_setupcgrparameters_pvt.cgmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cgmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cgmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cgmv_rec.cgr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_cgmv_rec.pmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cgmv_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_cgmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_cgmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a6);
    ddp_cgmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_cgmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a8);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupcgrparameters_pvt.update_cgrparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgmv_rec,
      ddx_cgmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cgmv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cgmv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_cgmv_rec.cgr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_cgmv_rec.pmr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cgmv_rec.created_by);
    p6_a5 := ddx_cgmv_rec.creation_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_cgmv_rec.last_updated_by);
    p6_a7 := ddx_cgmv_rec.last_update_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_cgmv_rec.last_update_login);
  end;

  procedure delete_cgrparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
  )

  as
    ddp_cgmv_tbl okl_setupcgrparameters_pvt.cgmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgm_pvt_w.rosetta_table_copy_in_p5(ddp_cgmv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_setupcgrparameters_pvt.delete_cgrparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_cgrparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cgmv_tbl okl_setupcgrparameters_pvt.cgmv_tbl_type;
    ddx_cgmv_tbl okl_setupcgrparameters_pvt.cgmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgm_pvt_w.rosetta_table_copy_in_p5(ddp_cgmv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setupcgrparameters_pvt.insert_cgrparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgmv_tbl,
      ddx_cgmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cgm_pvt_w.rosetta_table_copy_out_p5(ddx_cgmv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure update_cgrparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cgmv_tbl okl_setupcgrparameters_pvt.cgmv_tbl_type;
    ddx_cgmv_tbl okl_setupcgrparameters_pvt.cgmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cgm_pvt_w.rosetta_table_copy_in_p5(ddp_cgmv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setupcgrparameters_pvt.update_cgrparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cgmv_tbl,
      ddx_cgmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cgm_pvt_w.rosetta_table_copy_out_p5(ddx_cgmv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

end okl_setupcgrparameters_pvt_w;

/
