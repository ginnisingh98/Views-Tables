--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPMVALUES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPMVALUES_PUB_W" as
  /* $Header: OKLUSMVB.pls 120.2 2007/03/04 09:58:42 dcshanmu ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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
    , x_msg_data out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  NUMBER
    , p4_a3 out nocopy  NUMBER
    , p4_a4 out nocopy  NUMBER
    , p4_a5 out nocopy  DATE
    , p4_a6 out nocopy  DATE
    , p4_a7 out nocopy  NUMBER
    , p4_a8 out nocopy  DATE
    , p4_a9 out nocopy  NUMBER
    , p4_a10 out nocopy  DATE
    , p4_a11 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_pmvv_rec okl_setuppmvalues_pub.pmvv_rec_type;
    ddx_no_data_found boolean;
    ddx_pmvv_rec okl_setuppmvalues_pub.pmvv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pmvv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_pmvv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_pmvv_rec.ptv_id := rosetta_g_miss_num_map(p0_a2);
    ddp_pmvv_rec.ptl_id := rosetta_g_miss_num_map(p0_a3);
    ddp_pmvv_rec.ptq_id := rosetta_g_miss_num_map(p0_a4);
    ddp_pmvv_rec.from_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_pmvv_rec.to_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_pmvv_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_pmvv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_pmvv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_pmvv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_pmvv_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);





    -- here's the delegated call to the old PL/SQL routine
    okl_setuppmvalues_pub.get_rec(ddp_pmvv_rec,
      x_return_status,
      x_msg_data,
      ddx_no_data_found,
      ddx_pmvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p4_a0 := rosetta_g_miss_num_map(ddx_pmvv_rec.id);
    p4_a1 := rosetta_g_miss_num_map(ddx_pmvv_rec.object_version_number);
    p4_a2 := rosetta_g_miss_num_map(ddx_pmvv_rec.ptv_id);
    p4_a3 := rosetta_g_miss_num_map(ddx_pmvv_rec.ptl_id);
    p4_a4 := rosetta_g_miss_num_map(ddx_pmvv_rec.ptq_id);
    p4_a5 := ddx_pmvv_rec.from_date;
    p4_a6 := ddx_pmvv_rec.to_date;
    p4_a7 := rosetta_g_miss_num_map(ddx_pmvv_rec.created_by);
    p4_a8 := ddx_pmvv_rec.creation_date;
    p4_a9 := rosetta_g_miss_num_map(ddx_pmvv_rec.last_updated_by);
    p4_a10 := ddx_pmvv_rec.last_update_date;
    p4_a11 := rosetta_g_miss_num_map(ddx_pmvv_rec.last_update_login);
  end;

  procedure insert_pmvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
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
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  DATE := fnd_api.g_miss_date
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ptlv_rec okl_setuppmvalues_pub.ptlv_rec_type;
    ddp_pmvv_rec okl_setuppmvalues_pub.pmvv_rec_type;
    ddx_pmvv_rec okl_setuppmvalues_pub.pmvv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ptlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ptlv_rec.name := p5_a2;
    ddp_ptlv_rec.version := p5_a3;
    ddp_ptlv_rec.description := p5_a4;
    ddp_ptlv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ptlv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ptlv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ptlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ptlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ptlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ptlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    ddp_pmvv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_pmvv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_pmvv_rec.ptv_id := rosetta_g_miss_num_map(p6_a2);
    ddp_pmvv_rec.ptl_id := rosetta_g_miss_num_map(p6_a3);
    ddp_pmvv_rec.ptq_id := rosetta_g_miss_num_map(p6_a4);
    ddp_pmvv_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_pmvv_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_pmvv_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_pmvv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_pmvv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_pmvv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_pmvv_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuppmvalues_pub.insert_pmvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptlv_rec,
      ddp_pmvv_rec,
      ddx_pmvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_pmvv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_pmvv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_pmvv_rec.ptv_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_pmvv_rec.ptl_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_pmvv_rec.ptq_id);
    p7_a5 := ddx_pmvv_rec.from_date;
    p7_a6 := ddx_pmvv_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_pmvv_rec.created_by);
    p7_a8 := ddx_pmvv_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_pmvv_rec.last_updated_by);
    p7_a10 := ddx_pmvv_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_pmvv_rec.last_update_login);
  end;

  procedure insert_pmvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_DATE_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_DATE_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_DATE_TABLE
    , p7_a6 out nocopy JTF_DATE_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
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
    ddp_ptlv_rec okl_setuppmvalues_pub.ptlv_rec_type;
    ddp_pmvv_tbl okl_setuppmvalues_pub.pmvv_tbl_type;
    ddx_pmvv_tbl okl_setuppmvalues_pub.pmvv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ptlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ptlv_rec.name := p5_a2;
    ddp_ptlv_rec.version := p5_a3;
    ddp_ptlv_rec.description := p5_a4;
    ddp_ptlv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ptlv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ptlv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ptlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ptlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ptlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ptlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    okl_pmv_pvt_w.rosetta_table_copy_in_p5(ddp_pmvv_tbl, p6_a0
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
    okl_setuppmvalues_pub.insert_pmvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptlv_rec,
      ddp_pmvv_tbl,
      ddx_pmvv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_pmv_pvt_w.rosetta_table_copy_out_p5(ddx_pmvv_tbl, p7_a0
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
      , p7_a11
      );
  end;

  procedure delete_pmvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
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
    ddp_ptlv_rec okl_setuppmvalues_pub.ptlv_rec_type;
    ddp_pmvv_tbl okl_setuppmvalues_pub.pmvv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ptlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ptlv_rec.name := p5_a2;
    ddp_ptlv_rec.version := p5_a3;
    ddp_ptlv_rec.description := p5_a4;
    ddp_ptlv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ptlv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ptlv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_ptlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ptlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_ptlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_ptlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    okl_pmv_pvt_w.rosetta_table_copy_in_p5(ddp_pmvv_tbl, p6_a0
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
    okl_setuppmvalues_pub.delete_pmvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptlv_rec,
      ddp_pmvv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_setuppmvalues_pub_w;

/
