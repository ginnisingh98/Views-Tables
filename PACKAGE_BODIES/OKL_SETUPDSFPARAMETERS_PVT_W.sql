--------------------------------------------------------
--  DDL for Package Body OKL_SETUPDSFPARAMETERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPDSFPARAMETERS_PVT_W" as
  /* $Header: OKLESFRB.pls 120.1 2005/07/12 09:09:55 dkagrawa noship $ */
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
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  DATE
    , p3_a13 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_fprv_rec okl_setupdsfparameters_pvt.fprv_rec_type;
    ddx_no_data_found boolean;
    ddx_fprv_rec okl_setupdsfparameters_pvt.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fprv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_fprv_rec.sfwt_flag := p0_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p0_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p0_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p0_a5);
    ddp_fprv_rec.value := p0_a6;
    ddp_fprv_rec.instructions := p0_a7;
    ddp_fprv_rec.fpr_type := p0_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p0_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p0_a13);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupdsfparameters_pvt.get_rec(ddp_fprv_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_fprv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_fprv_rec.object_version_number);
    p3_a2 := ddx_fprv_rec.sfwt_flag;
    p3_a3 := rosetta_g_miss_num_map(ddx_fprv_rec.dsf_id);
    p3_a4 := rosetta_g_miss_num_map(ddx_fprv_rec.pmr_id);
    p3_a5 := rosetta_g_miss_num_map(ddx_fprv_rec.sequence_number);
    p3_a6 := ddx_fprv_rec.value;
    p3_a7 := ddx_fprv_rec.instructions;
    p3_a8 := ddx_fprv_rec.fpr_type;
    p3_a9 := rosetta_g_miss_num_map(ddx_fprv_rec.created_by);
    p3_a10 := ddx_fprv_rec.creation_date;
    p3_a11 := rosetta_g_miss_num_map(ddx_fprv_rec.last_updated_by);
    p3_a12 := ddx_fprv_rec.last_update_date;
    p3_a13 := rosetta_g_miss_num_map(ddx_fprv_rec.last_update_login);
  end;

  procedure insert_dsfparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_dsfv_rec okl_setupdsfparameters_pvt.dsfv_rec_type;
    ddp_fprv_rec okl_setupdsfparameters_pvt.fprv_rec_type;
    ddx_fprv_rec okl_setupdsfparameters_pvt.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dsfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dsfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dsfv_rec.sfwt_flag := p5_a2;
    ddp_dsfv_rec.fnctn_code := p5_a3;
    ddp_dsfv_rec.name := p5_a4;
    ddp_dsfv_rec.description := p5_a5;
    ddp_dsfv_rec.version := p5_a6;
    ddp_dsfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_dsfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_dsfv_rec.source := p5_a9;
    ddp_dsfv_rec.attribute_category := p5_a10;
    ddp_dsfv_rec.attribute1 := p5_a11;
    ddp_dsfv_rec.attribute2 := p5_a12;
    ddp_dsfv_rec.attribute3 := p5_a13;
    ddp_dsfv_rec.attribute4 := p5_a14;
    ddp_dsfv_rec.attribute5 := p5_a15;
    ddp_dsfv_rec.attribute6 := p5_a16;
    ddp_dsfv_rec.attribute7 := p5_a17;
    ddp_dsfv_rec.attribute8 := p5_a18;
    ddp_dsfv_rec.attribute9 := p5_a19;
    ddp_dsfv_rec.attribute10 := p5_a20;
    ddp_dsfv_rec.attribute11 := p5_a21;
    ddp_dsfv_rec.attribute12 := p5_a22;
    ddp_dsfv_rec.attribute13 := p5_a23;
    ddp_dsfv_rec.attribute14 := p5_a24;
    ddp_dsfv_rec.attribute15 := p5_a25;
    ddp_dsfv_rec.org_id := rosetta_g_miss_num_map(p5_a26);
    ddp_dsfv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_dsfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_dsfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_dsfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_dsfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    ddp_fprv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_fprv_rec.sfwt_flag := p6_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p6_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p6_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p6_a5);
    ddp_fprv_rec.value := p6_a6;
    ddp_fprv_rec.instructions := p6_a7;
    ddp_fprv_rec.fpr_type := p6_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p6_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p6_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupdsfparameters_pvt.insert_dsfparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dsfv_rec,
      ddp_fprv_rec,
      ddx_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_fprv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_fprv_rec.object_version_number);
    p7_a2 := ddx_fprv_rec.sfwt_flag;
    p7_a3 := rosetta_g_miss_num_map(ddx_fprv_rec.dsf_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_fprv_rec.pmr_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_fprv_rec.sequence_number);
    p7_a6 := ddx_fprv_rec.value;
    p7_a7 := ddx_fprv_rec.instructions;
    p7_a8 := ddx_fprv_rec.fpr_type;
    p7_a9 := rosetta_g_miss_num_map(ddx_fprv_rec.created_by);
    p7_a10 := ddx_fprv_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_fprv_rec.last_updated_by);
    p7_a12 := ddx_fprv_rec.last_update_date;
    p7_a13 := rosetta_g_miss_num_map(ddx_fprv_rec.last_update_login);
  end;

  procedure update_dsfparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_dsfv_rec okl_setupdsfparameters_pvt.dsfv_rec_type;
    ddp_fprv_rec okl_setupdsfparameters_pvt.fprv_rec_type;
    ddx_fprv_rec okl_setupdsfparameters_pvt.fprv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dsfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dsfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dsfv_rec.sfwt_flag := p5_a2;
    ddp_dsfv_rec.fnctn_code := p5_a3;
    ddp_dsfv_rec.name := p5_a4;
    ddp_dsfv_rec.description := p5_a5;
    ddp_dsfv_rec.version := p5_a6;
    ddp_dsfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_dsfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_dsfv_rec.source := p5_a9;
    ddp_dsfv_rec.attribute_category := p5_a10;
    ddp_dsfv_rec.attribute1 := p5_a11;
    ddp_dsfv_rec.attribute2 := p5_a12;
    ddp_dsfv_rec.attribute3 := p5_a13;
    ddp_dsfv_rec.attribute4 := p5_a14;
    ddp_dsfv_rec.attribute5 := p5_a15;
    ddp_dsfv_rec.attribute6 := p5_a16;
    ddp_dsfv_rec.attribute7 := p5_a17;
    ddp_dsfv_rec.attribute8 := p5_a18;
    ddp_dsfv_rec.attribute9 := p5_a19;
    ddp_dsfv_rec.attribute10 := p5_a20;
    ddp_dsfv_rec.attribute11 := p5_a21;
    ddp_dsfv_rec.attribute12 := p5_a22;
    ddp_dsfv_rec.attribute13 := p5_a23;
    ddp_dsfv_rec.attribute14 := p5_a24;
    ddp_dsfv_rec.attribute15 := p5_a25;
    ddp_dsfv_rec.org_id := rosetta_g_miss_num_map(p5_a26);
    ddp_dsfv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_dsfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_dsfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_dsfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_dsfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    ddp_fprv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_fprv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_fprv_rec.sfwt_flag := p6_a2;
    ddp_fprv_rec.dsf_id := rosetta_g_miss_num_map(p6_a3);
    ddp_fprv_rec.pmr_id := rosetta_g_miss_num_map(p6_a4);
    ddp_fprv_rec.sequence_number := rosetta_g_miss_num_map(p6_a5);
    ddp_fprv_rec.value := p6_a6;
    ddp_fprv_rec.instructions := p6_a7;
    ddp_fprv_rec.fpr_type := p6_a8;
    ddp_fprv_rec.created_by := rosetta_g_miss_num_map(p6_a9);
    ddp_fprv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_fprv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a11);
    ddp_fprv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a12);
    ddp_fprv_rec.last_update_login := rosetta_g_miss_num_map(p6_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupdsfparameters_pvt.update_dsfparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dsfv_rec,
      ddp_fprv_rec,
      ddx_fprv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_fprv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_fprv_rec.object_version_number);
    p7_a2 := ddx_fprv_rec.sfwt_flag;
    p7_a3 := rosetta_g_miss_num_map(ddx_fprv_rec.dsf_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_fprv_rec.pmr_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_fprv_rec.sequence_number);
    p7_a6 := ddx_fprv_rec.value;
    p7_a7 := ddx_fprv_rec.instructions;
    p7_a8 := ddx_fprv_rec.fpr_type;
    p7_a9 := rosetta_g_miss_num_map(ddx_fprv_rec.created_by);
    p7_a10 := ddx_fprv_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_fprv_rec.last_updated_by);
    p7_a12 := ddx_fprv_rec.last_update_date;
    p7_a13 := rosetta_g_miss_num_map(ddx_fprv_rec.last_update_login);
  end;

  procedure delete_dsfparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_800
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_fprv_tbl okl_setupdsfparameters_pvt.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p5_a0
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
      , p5_a12
      , p5_a13
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_setupdsfparameters_pvt.delete_dsfparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_dsfparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_300
    , p6_a7 JTF_VARCHAR2_TABLE_800
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_800
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_DATE_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_dsfv_rec okl_setupdsfparameters_pvt.dsfv_rec_type;
    ddp_fprv_tbl okl_setupdsfparameters_pvt.fprv_tbl_type;
    ddx_fprv_tbl okl_setupdsfparameters_pvt.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dsfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dsfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dsfv_rec.sfwt_flag := p5_a2;
    ddp_dsfv_rec.fnctn_code := p5_a3;
    ddp_dsfv_rec.name := p5_a4;
    ddp_dsfv_rec.description := p5_a5;
    ddp_dsfv_rec.version := p5_a6;
    ddp_dsfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_dsfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_dsfv_rec.source := p5_a9;
    ddp_dsfv_rec.attribute_category := p5_a10;
    ddp_dsfv_rec.attribute1 := p5_a11;
    ddp_dsfv_rec.attribute2 := p5_a12;
    ddp_dsfv_rec.attribute3 := p5_a13;
    ddp_dsfv_rec.attribute4 := p5_a14;
    ddp_dsfv_rec.attribute5 := p5_a15;
    ddp_dsfv_rec.attribute6 := p5_a16;
    ddp_dsfv_rec.attribute7 := p5_a17;
    ddp_dsfv_rec.attribute8 := p5_a18;
    ddp_dsfv_rec.attribute9 := p5_a19;
    ddp_dsfv_rec.attribute10 := p5_a20;
    ddp_dsfv_rec.attribute11 := p5_a21;
    ddp_dsfv_rec.attribute12 := p5_a22;
    ddp_dsfv_rec.attribute13 := p5_a23;
    ddp_dsfv_rec.attribute14 := p5_a24;
    ddp_dsfv_rec.attribute15 := p5_a25;
    ddp_dsfv_rec.org_id := rosetta_g_miss_num_map(p5_a26);
    ddp_dsfv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_dsfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_dsfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_dsfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_dsfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p6_a0
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
      , p6_a12
      , p6_a13
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setupdsfparameters_pvt.insert_dsfparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dsfv_rec,
      ddp_fprv_tbl,
      ddx_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_fpr_pvt_w.rosetta_table_copy_out_p8(ddx_fprv_tbl, p7_a0
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
      , p7_a12
      , p7_a13
      );
  end;

  procedure update_dsfparameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_300
    , p6_a7 JTF_VARCHAR2_TABLE_800
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_800
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_DATE_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
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
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_dsfv_rec okl_setupdsfparameters_pvt.dsfv_rec_type;
    ddp_fprv_tbl okl_setupdsfparameters_pvt.fprv_tbl_type;
    ddx_fprv_tbl okl_setupdsfparameters_pvt.fprv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dsfv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dsfv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dsfv_rec.sfwt_flag := p5_a2;
    ddp_dsfv_rec.fnctn_code := p5_a3;
    ddp_dsfv_rec.name := p5_a4;
    ddp_dsfv_rec.description := p5_a5;
    ddp_dsfv_rec.version := p5_a6;
    ddp_dsfv_rec.start_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_dsfv_rec.end_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_dsfv_rec.source := p5_a9;
    ddp_dsfv_rec.attribute_category := p5_a10;
    ddp_dsfv_rec.attribute1 := p5_a11;
    ddp_dsfv_rec.attribute2 := p5_a12;
    ddp_dsfv_rec.attribute3 := p5_a13;
    ddp_dsfv_rec.attribute4 := p5_a14;
    ddp_dsfv_rec.attribute5 := p5_a15;
    ddp_dsfv_rec.attribute6 := p5_a16;
    ddp_dsfv_rec.attribute7 := p5_a17;
    ddp_dsfv_rec.attribute8 := p5_a18;
    ddp_dsfv_rec.attribute9 := p5_a19;
    ddp_dsfv_rec.attribute10 := p5_a20;
    ddp_dsfv_rec.attribute11 := p5_a21;
    ddp_dsfv_rec.attribute12 := p5_a22;
    ddp_dsfv_rec.attribute13 := p5_a23;
    ddp_dsfv_rec.attribute14 := p5_a24;
    ddp_dsfv_rec.attribute15 := p5_a25;
    ddp_dsfv_rec.org_id := rosetta_g_miss_num_map(p5_a26);
    ddp_dsfv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_dsfv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_dsfv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_dsfv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_dsfv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    okl_fpr_pvt_w.rosetta_table_copy_in_p8(ddp_fprv_tbl, p6_a0
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
      , p6_a12
      , p6_a13
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setupdsfparameters_pvt.update_dsfparameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dsfv_rec,
      ddp_fprv_tbl,
      ddx_fprv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_fpr_pvt_w.rosetta_table_copy_out_p8(ddx_fprv_tbl, p7_a0
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
      , p7_a12
      , p7_a13
      );
  end;

end okl_setupdsfparameters_pvt_w;

/
