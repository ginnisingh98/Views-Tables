--------------------------------------------------------
--  DDL for Package Body OKL_RESI_CAT_SETS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RESI_CAT_SETS_PVT_W" as
  /* $Header: OKLERCSB.pls 120.1 2005/07/08 14:38:53 smadhava noship $ */
  procedure create_rcs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_DATE_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_DATE_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rcsv_rec okl_resi_cat_sets_pvt.okl_rcsv_rec;
    ddp_res_tbl okl_resi_cat_sets_pvt.okl_res_tbl;
    ddx_rcsv_rec okl_resi_cat_sets_pvt.okl_rcsv_rec;
    ddx_res_tbl okl_resi_cat_sets_pvt.okl_res_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rcsv_rec.resi_category_set_id := p5_a0;
    ddp_rcsv_rec.orig_resi_cat_set_id := p5_a1;
    ddp_rcsv_rec.object_version_number := p5_a2;
    ddp_rcsv_rec.org_id := p5_a3;
    ddp_rcsv_rec.source_code := p5_a4;
    ddp_rcsv_rec.sts_code := p5_a5;
    ddp_rcsv_rec.resi_cat_name := p5_a6;
    ddp_rcsv_rec.resi_cat_desc := p5_a7;
    ddp_rcsv_rec.sfwt_flag := p5_a8;
    ddp_rcsv_rec.created_by := p5_a9;
    ddp_rcsv_rec.creation_date := p5_a10;
    ddp_rcsv_rec.last_updated_by := p5_a11;
    ddp_rcsv_rec.last_update_date := p5_a12;
    ddp_rcsv_rec.last_update_login := p5_a13;

    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p6_a0
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
    okl_resi_cat_sets_pvt.create_rcs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rcsv_rec,
      ddp_res_tbl,
      ddx_rcsv_rec,
      ddx_res_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_rcsv_rec.resi_category_set_id;
    p7_a1 := ddx_rcsv_rec.orig_resi_cat_set_id;
    p7_a2 := ddx_rcsv_rec.object_version_number;
    p7_a3 := ddx_rcsv_rec.org_id;
    p7_a4 := ddx_rcsv_rec.source_code;
    p7_a5 := ddx_rcsv_rec.sts_code;
    p7_a6 := ddx_rcsv_rec.resi_cat_name;
    p7_a7 := ddx_rcsv_rec.resi_cat_desc;
    p7_a8 := ddx_rcsv_rec.sfwt_flag;
    p7_a9 := ddx_rcsv_rec.created_by;
    p7_a10 := ddx_rcsv_rec.creation_date;
    p7_a11 := ddx_rcsv_rec.last_updated_by;
    p7_a12 := ddx_rcsv_rec.last_update_date;
    p7_a13 := ddx_rcsv_rec.last_update_login;

    okl_res_pvt_w.rosetta_table_copy_out_p1(ddx_res_tbl, p8_a0
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

  procedure update_rcs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_DATE_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
  )

  as
    ddp_rcsv_rec okl_resi_cat_sets_pvt.okl_rcsv_rec;
    ddp_res_tbl okl_resi_cat_sets_pvt.okl_res_tbl;
    ddx_rcsv_rec okl_resi_cat_sets_pvt.okl_rcsv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rcsv_rec.resi_category_set_id := p5_a0;
    ddp_rcsv_rec.orig_resi_cat_set_id := p5_a1;
    ddp_rcsv_rec.object_version_number := p5_a2;
    ddp_rcsv_rec.org_id := p5_a3;
    ddp_rcsv_rec.source_code := p5_a4;
    ddp_rcsv_rec.sts_code := p5_a5;
    ddp_rcsv_rec.resi_cat_name := p5_a6;
    ddp_rcsv_rec.resi_cat_desc := p5_a7;
    ddp_rcsv_rec.sfwt_flag := p5_a8;
    ddp_rcsv_rec.created_by := p5_a9;
    ddp_rcsv_rec.creation_date := p5_a10;
    ddp_rcsv_rec.last_updated_by := p5_a11;
    ddp_rcsv_rec.last_update_date := p5_a12;
    ddp_rcsv_rec.last_update_login := p5_a13;

    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p6_a0
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
    okl_resi_cat_sets_pvt.update_rcs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rcsv_rec,
      ddp_res_tbl,
      ddx_rcsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_rcsv_rec.resi_category_set_id;
    p7_a1 := ddx_rcsv_rec.orig_resi_cat_set_id;
    p7_a2 := ddx_rcsv_rec.object_version_number;
    p7_a3 := ddx_rcsv_rec.org_id;
    p7_a4 := ddx_rcsv_rec.source_code;
    p7_a5 := ddx_rcsv_rec.sts_code;
    p7_a6 := ddx_rcsv_rec.resi_cat_name;
    p7_a7 := ddx_rcsv_rec.resi_cat_desc;
    p7_a8 := ddx_rcsv_rec.sfwt_flag;
    p7_a9 := ddx_rcsv_rec.created_by;
    p7_a10 := ddx_rcsv_rec.creation_date;
    p7_a11 := ddx_rcsv_rec.last_updated_by;
    p7_a12 := ddx_rcsv_rec.last_update_date;
    p7_a13 := ddx_rcsv_rec.last_update_login;
  end;

  procedure activate_rcs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_DATE_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
  )

  as
    ddp_rcsv_rec okl_resi_cat_sets_pvt.okl_rcsv_rec;
    ddp_res_tbl okl_resi_cat_sets_pvt.okl_res_tbl;
    ddx_rcsv_rec okl_resi_cat_sets_pvt.okl_rcsv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rcsv_rec.resi_category_set_id := p5_a0;
    ddp_rcsv_rec.orig_resi_cat_set_id := p5_a1;
    ddp_rcsv_rec.object_version_number := p5_a2;
    ddp_rcsv_rec.org_id := p5_a3;
    ddp_rcsv_rec.source_code := p5_a4;
    ddp_rcsv_rec.sts_code := p5_a5;
    ddp_rcsv_rec.resi_cat_name := p5_a6;
    ddp_rcsv_rec.resi_cat_desc := p5_a7;
    ddp_rcsv_rec.sfwt_flag := p5_a8;
    ddp_rcsv_rec.created_by := p5_a9;
    ddp_rcsv_rec.creation_date := p5_a10;
    ddp_rcsv_rec.last_updated_by := p5_a11;
    ddp_rcsv_rec.last_update_date := p5_a12;
    ddp_rcsv_rec.last_update_login := p5_a13;

    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p6_a0
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
    okl_resi_cat_sets_pvt.activate_rcs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rcsv_rec,
      ddp_res_tbl,
      ddx_rcsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_rcsv_rec.resi_category_set_id;
    p7_a1 := ddx_rcsv_rec.orig_resi_cat_set_id;
    p7_a2 := ddx_rcsv_rec.object_version_number;
    p7_a3 := ddx_rcsv_rec.org_id;
    p7_a4 := ddx_rcsv_rec.source_code;
    p7_a5 := ddx_rcsv_rec.sts_code;
    p7_a6 := ddx_rcsv_rec.resi_cat_name;
    p7_a7 := ddx_rcsv_rec.resi_cat_desc;
    p7_a8 := ddx_rcsv_rec.sfwt_flag;
    p7_a9 := ddx_rcsv_rec.created_by;
    p7_a10 := ddx_rcsv_rec.creation_date;
    p7_a11 := ddx_rcsv_rec.last_updated_by;
    p7_a12 := ddx_rcsv_rec.last_update_date;
    p7_a13 := ddx_rcsv_rec.last_update_login;
  end;

  procedure delete_objects(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_res_tbl okl_resi_cat_sets_pvt.okl_res_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p5_a0
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
    okl_resi_cat_sets_pvt.delete_objects(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_resi_cat_sets_pvt_w;

/
