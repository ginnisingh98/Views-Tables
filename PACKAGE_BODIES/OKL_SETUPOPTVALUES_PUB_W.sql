--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPTVALUES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPTVALUES_PUB_W" as
  /* $Header: OKLUSOVB.pls 115.2 2002/12/24 04:19:57 sgorantl noship $ */
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
    , x_msg_data out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  NUMBER
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
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
    ddp_ovev_rec okl_setupoptvalues_pub.ovev_rec_type;
    ddx_no_data_found boolean;
    ddx_ovev_rec okl_setupoptvalues_pub.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ovev_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p0_a2);
    ddp_ovev_rec.value := p0_a3;
    ddp_ovev_rec.description := p0_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);





    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pub.get_rec(ddp_ovev_rec,
      x_return_status,
      x_msg_data,
      ddx_no_data_found,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p4_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p4_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p4_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p4_a3 := ddx_ovev_rec.value;
    p4_a4 := ddx_ovev_rec.description;
    p4_a5 := ddx_ovev_rec.from_date;
    p4_a6 := ddx_ovev_rec.to_date;
    p4_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p4_a8 := ddx_ovev_rec.creation_date;
    p4_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p4_a10 := ddx_ovev_rec.last_update_date;
    p4_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

  procedure insert_optvalues(p_api_version  NUMBER
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
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
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
    ddp_optv_rec okl_setupoptvalues_pub.optv_rec_type;
    ddp_ovev_rec okl_setupoptvalues_pub.ovev_rec_type;
    ddx_ovev_rec okl_setupoptvalues_pub.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    ddp_ovev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p6_a2);
    ddp_ovev_rec.value := p6_a3;
    ddp_ovev_rec.description := p6_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pub.insert_optvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_rec,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p7_a3 := ddx_ovev_rec.value;
    p7_a4 := ddx_ovev_rec.description;
    p7_a5 := ddx_ovev_rec.from_date;
    p7_a6 := ddx_ovev_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p7_a8 := ddx_ovev_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p7_a10 := ddx_ovev_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

  procedure update_optvalues(p_api_version  NUMBER
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
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
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
    ddp_optv_rec okl_setupoptvalues_pub.optv_rec_type;
    ddp_ovev_rec okl_setupoptvalues_pub.ovev_rec_type;
    ddx_ovev_rec okl_setupoptvalues_pub.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    ddp_ovev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p6_a2);
    ddp_ovev_rec.value := p6_a3;
    ddp_ovev_rec.description := p6_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pub.update_optvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_rec,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p7_a3 := ddx_ovev_rec.value;
    p7_a4 := ddx_ovev_rec.description;
    p7_a5 := ddx_ovev_rec.from_date;
    p7_a6 := ddx_ovev_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p7_a8 := ddx_ovev_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p7_a10 := ddx_ovev_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

end okl_setupoptvalues_pub_w;

/
