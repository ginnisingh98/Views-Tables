--------------------------------------------------------
--  DDL for Package Body OKL_VERSION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VERSION_PVT_W" as
  /* $Header: OKLEVERB.pls 120.1 2005/07/12 12:50:20 dkagrawa noship $ */
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

  procedure version_contract(p_api_version  NUMBER
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
    , p_commit  VARCHAR2
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
    ddp_cvmv_rec okl_version_pvt.cvmv_rec_type;
    ddx_cvmv_rec okl_version_pvt.cvmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cvmv_rec.chr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_cvmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cvmv_rec.major_version := rosetta_g_miss_num_map(p5_a2);
    ddp_cvmv_rec.minor_version := rosetta_g_miss_num_map(p5_a3);
    ddp_cvmv_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_cvmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_cvmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a6);
    ddp_cvmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_cvmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a8);



    -- here's the delegated call to the old PL/SQL routine
    okl_version_pvt.version_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cvmv_rec,
      ddx_cvmv_rec,
      p_commit);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cvmv_rec.chr_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cvmv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_cvmv_rec.major_version);
    p6_a3 := rosetta_g_miss_num_map(ddx_cvmv_rec.minor_version);
    p6_a4 := rosetta_g_miss_num_map(ddx_cvmv_rec.created_by);
    p6_a5 := ddx_cvmv_rec.creation_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_cvmv_rec.last_updated_by);
    p6_a7 := ddx_cvmv_rec.last_update_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_cvmv_rec.last_update_login);

  end;

end okl_version_pvt_w;

/