--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPQYVALUES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPQYVALUES_PVT_W" as
  /* $Header: OKLESQVB.pls 115.2 2002/12/24 04:04:27 sgorantl noship $ */
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
    , p3_a2 out nocopy  NUMBER
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  DATE
    , p3_a6 out nocopy  DATE
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_qvev_rec okl_setuppqyvalues_pvt.qvev_rec_type;
    ddx_no_data_found boolean;
    ddx_qvev_rec okl_setuppqyvalues_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_qvev_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p0_a2);
    ddp_qvev_rec.value := p0_a3;
    ddp_qvev_rec.description := p0_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);




    -- here's the delegated call to the old PL/SQL routine
    okl_setuppqyvalues_pvt.get_rec(ddp_qvev_rec,
      ddx_no_data_found,
      x_return_status,
      ddx_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;


    p3_a0 := rosetta_g_miss_num_map(ddx_qvev_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_qvev_rec.object_version_number);
    p3_a2 := rosetta_g_miss_num_map(ddx_qvev_rec.pqy_id);
    p3_a3 := ddx_qvev_rec.value;
    p3_a4 := ddx_qvev_rec.description;
    p3_a5 := ddx_qvev_rec.from_date;
    p3_a6 := ddx_qvev_rec.to_date;
    p3_a7 := rosetta_g_miss_num_map(ddx_qvev_rec.created_by);
    p3_a8 := ddx_qvev_rec.creation_date;
    p3_a9 := rosetta_g_miss_num_map(ddx_qvev_rec.last_updated_by);
    p3_a10 := ddx_qvev_rec.last_update_date;
    p3_a11 := rosetta_g_miss_num_map(ddx_qvev_rec.last_update_login);
  end;

  procedure insert_pqyvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
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
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  DATE := fnd_api.g_miss_date
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_pqyv_rec okl_setuppqyvalues_pvt.pqyv_rec_type;
    ddp_qvev_rec okl_setuppqyvalues_pvt.qvev_rec_type;
    ddx_qvev_rec okl_setuppqyvalues_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    ddp_qvev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p6_a2);
    ddp_qvev_rec.value := p6_a3;
    ddp_qvev_rec.description := p6_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuppqyvalues_pvt.insert_pqyvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddp_qvev_rec,
      ddx_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_qvev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_qvev_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_qvev_rec.pqy_id);
    p7_a3 := ddx_qvev_rec.value;
    p7_a4 := ddx_qvev_rec.description;
    p7_a5 := ddx_qvev_rec.from_date;
    p7_a6 := ddx_qvev_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_qvev_rec.created_by);
    p7_a8 := ddx_qvev_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_qvev_rec.last_updated_by);
    p7_a10 := ddx_qvev_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_qvev_rec.last_update_login);
  end;

  procedure update_pqyvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
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
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  DATE := fnd_api.g_miss_date
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_pqyv_rec okl_setuppqyvalues_pvt.pqyv_rec_type;
    ddp_qvev_rec okl_setuppqyvalues_pvt.qvev_rec_type;
    ddx_qvev_rec okl_setuppqyvalues_pvt.qvev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pqyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pqyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pqyv_rec.name := p5_a2;
    ddp_pqyv_rec.description := p5_a3;
    ddp_pqyv_rec.location_yn := p5_a4;
    ddp_pqyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_pqyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pqyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_pqyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_pqyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pqyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pqyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    ddp_qvev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_qvev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_qvev_rec.pqy_id := rosetta_g_miss_num_map(p6_a2);
    ddp_qvev_rec.value := p6_a3;
    ddp_qvev_rec.description := p6_a4;
    ddp_qvev_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_qvev_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_qvev_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_qvev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_qvev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_qvev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_qvev_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuppqyvalues_pvt.update_pqyvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pqyv_rec,
      ddp_qvev_rec,
      ddx_qvev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_qvev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_qvev_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_qvev_rec.pqy_id);
    p7_a3 := ddx_qvev_rec.value;
    p7_a4 := ddx_qvev_rec.description;
    p7_a5 := ddx_qvev_rec.from_date;
    p7_a6 := ddx_qvev_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_qvev_rec.created_by);
    p7_a8 := ddx_qvev_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_qvev_rec.last_updated_by);
    p7_a10 := ddx_qvev_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_qvev_rec.last_update_login);
  end;

end okl_setuppqyvalues_pvt_w;

/
