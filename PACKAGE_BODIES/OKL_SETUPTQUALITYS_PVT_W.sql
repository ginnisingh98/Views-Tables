--------------------------------------------------------
--  DDL for Package Body OKL_SETUPTQUALITYS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPTQUALITYS_PVT_W" as
  /* $Header: OKLESTQB.pls 115.2 2002/12/24 04:04:48 sgorantl noship $ */
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
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  DATE
    , p3_a5 out nocopy  DATE
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  DATE
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  DATE
    , p3_a10 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_ptqv_rec okl_setuptqualitys_pvt.ptqv_rec_type;
    ddx_no_data_found boolean;
    ddx_ptqv_rec okl_setuptqualitys_pvt.ptqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ptqv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_ptqv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_ptqv_rec.name := p0_a2;
    ddp_ptqv_rec.description := p0_a3;
    ddp_ptqv_rec.from_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_ptqv_rec.to_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_ptqv_rec.created_by := rosetta_g_miss_num_map(p0_a6);
    ddp_ptqv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_ptqv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a8);
    ddp_ptqv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_ptqv_rec.last_update_login := rosetta_g_miss_num_map(p0_a10);




    -- here's the delegated call to the old PL/SQL routine
    okl_setuptqualitys_pvt.get_rec(ddp_ptqv_rec,
      ddx_no_data_found,
      x_return_status,
      ddx_ptqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;


    p3_a0 := rosetta_g_miss_num_map(ddx_ptqv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_ptqv_rec.object_version_number);
    p3_a2 := ddx_ptqv_rec.name;
    p3_a3 := ddx_ptqv_rec.description;
    p3_a4 := ddx_ptqv_rec.from_date;
    p3_a5 := ddx_ptqv_rec.to_date;
    p3_a6 := rosetta_g_miss_num_map(ddx_ptqv_rec.created_by);
    p3_a7 := ddx_ptqv_rec.creation_date;
    p3_a8 := rosetta_g_miss_num_map(ddx_ptqv_rec.last_updated_by);
    p3_a9 := ddx_ptqv_rec.last_update_date;
    p3_a10 := rosetta_g_miss_num_map(ddx_ptqv_rec.last_update_login);
  end;

  procedure insert_tqualitys(p_api_version  NUMBER
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
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_ptqv_rec okl_setuptqualitys_pvt.ptqv_rec_type;
    ddx_ptqv_rec okl_setuptqualitys_pvt.ptqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptqv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ptqv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ptqv_rec.name := p5_a2;
    ddp_ptqv_rec.description := p5_a3;
    ddp_ptqv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_ptqv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ptqv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_ptqv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_ptqv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_ptqv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_ptqv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuptqualitys_pvt.insert_tqualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptqv_rec,
      ddx_ptqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ptqv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ptqv_rec.object_version_number);
    p6_a2 := ddx_ptqv_rec.name;
    p6_a3 := ddx_ptqv_rec.description;
    p6_a4 := ddx_ptqv_rec.from_date;
    p6_a5 := ddx_ptqv_rec.to_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_ptqv_rec.created_by);
    p6_a7 := ddx_ptqv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_ptqv_rec.last_updated_by);
    p6_a9 := ddx_ptqv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_ptqv_rec.last_update_login);
  end;

  procedure update_tqualitys(p_api_version  NUMBER
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
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_ptqv_rec okl_setuptqualitys_pvt.ptqv_rec_type;
    ddx_ptqv_rec okl_setuptqualitys_pvt.ptqv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptqv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ptqv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ptqv_rec.name := p5_a2;
    ddp_ptqv_rec.description := p5_a3;
    ddp_ptqv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_ptqv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ptqv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_ptqv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_ptqv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_ptqv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_ptqv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuptqualitys_pvt.update_tqualitys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptqv_rec,
      ddx_ptqv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ptqv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ptqv_rec.object_version_number);
    p6_a2 := ddx_ptqv_rec.name;
    p6_a3 := ddx_ptqv_rec.description;
    p6_a4 := ddx_ptqv_rec.from_date;
    p6_a5 := ddx_ptqv_rec.to_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_ptqv_rec.created_by);
    p6_a7 := ddx_ptqv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_ptqv_rec.last_updated_by);
    p6_a9 := ddx_ptqv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_ptqv_rec.last_update_login);
  end;

end okl_setuptqualitys_pvt_w;

/
