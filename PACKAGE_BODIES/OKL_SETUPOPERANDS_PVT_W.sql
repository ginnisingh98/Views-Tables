--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPERANDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPERANDS_PVT_W" as
  /* $Header: OKLESOPB.pls 120.1 2005/07/12 09:10:29 dkagrawa noship $ */
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
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  DATE
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  NUMBER
    , p3_a14 out nocopy  DATE
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  DATE
    , p3_a17 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_setupoperands_pvt.opdv_rec_type;
    ddx_no_data_found boolean;
    ddx_opdv_rec okl_setupoperands_pvt.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_opdv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_opdv_rec.sfwt_flag := p0_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p0_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p0_a4);
    ddp_opdv_rec.name := p0_a5;
    ddp_opdv_rec.description := p0_a6;
    ddp_opdv_rec.version := p0_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_opdv_rec.source := p0_a10;
    ddp_opdv_rec.opd_type := p0_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p0_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p0_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p0_a17);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupoperands_pvt.get_rec(ddp_opdv_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_opdv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_opdv_rec.object_version_number);
    p3_a2 := ddx_opdv_rec.sfwt_flag;
    p3_a3 := rosetta_g_miss_num_map(ddx_opdv_rec.fma_id);
    p3_a4 := rosetta_g_miss_num_map(ddx_opdv_rec.dsf_id);
    p3_a5 := ddx_opdv_rec.name;
    p3_a6 := ddx_opdv_rec.description;
    p3_a7 := ddx_opdv_rec.version;
    p3_a8 := ddx_opdv_rec.start_date;
    p3_a9 := ddx_opdv_rec.end_date;
    p3_a10 := ddx_opdv_rec.source;
    p3_a11 := ddx_opdv_rec.opd_type;
    p3_a12 := rosetta_g_miss_num_map(ddx_opdv_rec.org_id);
    p3_a13 := rosetta_g_miss_num_map(ddx_opdv_rec.created_by);
    p3_a14 := ddx_opdv_rec.creation_date;
    p3_a15 := rosetta_g_miss_num_map(ddx_opdv_rec.last_updated_by);
    p3_a16 := ddx_opdv_rec.last_update_date;
    p3_a17 := rosetta_g_miss_num_map(ddx_opdv_rec.last_update_login);
  end;

  procedure insert_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_setupoperands_pvt.opdv_rec_type;
    ddx_opdv_rec okl_setupoperands_pvt.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupoperands_pvt.insert_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec,
      ddx_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_opdv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_opdv_rec.object_version_number);
    p6_a2 := ddx_opdv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_opdv_rec.fma_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_opdv_rec.dsf_id);
    p6_a5 := ddx_opdv_rec.name;
    p6_a6 := ddx_opdv_rec.description;
    p6_a7 := ddx_opdv_rec.version;
    p6_a8 := ddx_opdv_rec.start_date;
    p6_a9 := ddx_opdv_rec.end_date;
    p6_a10 := ddx_opdv_rec.source;
    p6_a11 := ddx_opdv_rec.opd_type;
    p6_a12 := rosetta_g_miss_num_map(ddx_opdv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_opdv_rec.created_by);
    p6_a14 := ddx_opdv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_opdv_rec.last_updated_by);
    p6_a16 := ddx_opdv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_opdv_rec.last_update_login);
  end;

  procedure update_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_setupoperands_pvt.opdv_rec_type;
    ddx_opdv_rec okl_setupoperands_pvt.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupoperands_pvt.update_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec,
      ddx_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_opdv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_opdv_rec.object_version_number);
    p6_a2 := ddx_opdv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_opdv_rec.fma_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_opdv_rec.dsf_id);
    p6_a5 := ddx_opdv_rec.name;
    p6_a6 := ddx_opdv_rec.description;
    p6_a7 := ddx_opdv_rec.version;
    p6_a8 := ddx_opdv_rec.start_date;
    p6_a9 := ddx_opdv_rec.end_date;
    p6_a10 := ddx_opdv_rec.source;
    p6_a11 := ddx_opdv_rec.opd_type;
    p6_a12 := rosetta_g_miss_num_map(ddx_opdv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_opdv_rec.created_by);
    p6_a14 := ddx_opdv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_opdv_rec.last_updated_by);
    p6_a16 := ddx_opdv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_opdv_rec.last_update_login);
  end;

end okl_setupoperands_pvt_w;

/
