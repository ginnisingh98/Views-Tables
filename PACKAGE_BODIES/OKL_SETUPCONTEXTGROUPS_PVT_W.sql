--------------------------------------------------------
--  DDL for Package Body OKL_SETUPCONTEXTGROUPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPCONTEXTGROUPS_PVT_W" as
  /* $Header: OKLESCGB.pls 120.1 2005/07/12 09:08:32 dkagrawa noship $ */
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
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  DATE
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_cgrv_rec okl_setupcontextgroups_pvt.cgrv_rec_type;
    ddx_no_data_found boolean;
    ddx_cgrv_rec okl_setupcontextgroups_pvt.cgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cgrv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_cgrv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_cgrv_rec.sfwt_flag := p0_a2;
    ddp_cgrv_rec.name := p0_a3;
    ddp_cgrv_rec.description := p0_a4;
    ddp_cgrv_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_cgrv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_cgrv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a7);
    ddp_cgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_cgrv_rec.last_update_login := rosetta_g_miss_num_map(p0_a9);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupcontextgroups_pvt.get_rec(ddp_cgrv_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_cgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_cgrv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_cgrv_rec.object_version_number);
    p3_a2 := ddx_cgrv_rec.sfwt_flag;
    p3_a3 := ddx_cgrv_rec.name;
    p3_a4 := ddx_cgrv_rec.description;
    p3_a5 := rosetta_g_miss_num_map(ddx_cgrv_rec.created_by);
    p3_a6 := ddx_cgrv_rec.creation_date;
    p3_a7 := rosetta_g_miss_num_map(ddx_cgrv_rec.last_updated_by);
    p3_a8 := ddx_cgrv_rec.last_update_date;
    p3_a9 := rosetta_g_miss_num_map(ddx_cgrv_rec.last_update_login);
  end;

  procedure insert_contextgroups(p_api_version  NUMBER
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
    ddp_cgrv_rec okl_setupcontextgroups_pvt.cgrv_rec_type;
    ddx_cgrv_rec okl_setupcontextgroups_pvt.cgrv_rec_type;
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
    okl_setupcontextgroups_pvt.insert_contextgroups(p_api_version,
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

  procedure update_contextgroups(p_api_version  NUMBER
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
    ddp_cgrv_rec okl_setupcontextgroups_pvt.cgrv_rec_type;
    ddx_cgrv_rec okl_setupcontextgroups_pvt.cgrv_rec_type;
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
    okl_setupcontextgroups_pvt.update_contextgroups(p_api_version,
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

end okl_setupcontextgroups_pvt_w;

/
