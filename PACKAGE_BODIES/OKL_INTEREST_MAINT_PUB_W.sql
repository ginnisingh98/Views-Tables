--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_MAINT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_MAINT_PUB_W" as
  /* $Header: OKLUINMB.pls 120.1 2005/07/14 12:03:22 asawanka noship $ */
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

  procedure int_hdr_ins_updt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_idxv_rec okl_interest_maint_pub.idxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_idxv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_idxv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_idxv_rec.name := p5_a2;
    ddp_idxv_rec.description := p5_a3;
    ddp_idxv_rec.attribute_category := p5_a4;
    ddp_idxv_rec.attribute1 := p5_a5;
    ddp_idxv_rec.attribute2 := p5_a6;
    ddp_idxv_rec.attribute3 := p5_a7;
    ddp_idxv_rec.attribute4 := p5_a8;
    ddp_idxv_rec.attribute5 := p5_a9;
    ddp_idxv_rec.attribute6 := p5_a10;
    ddp_idxv_rec.attribute7 := p5_a11;
    ddp_idxv_rec.attribute8 := p5_a12;
    ddp_idxv_rec.attribute9 := p5_a13;
    ddp_idxv_rec.attribute10 := p5_a14;
    ddp_idxv_rec.attribute11 := p5_a15;
    ddp_idxv_rec.attribute12 := p5_a16;
    ddp_idxv_rec.attribute13 := p5_a17;
    ddp_idxv_rec.attribute14 := p5_a18;
    ddp_idxv_rec.attribute15 := p5_a19;
    ddp_idxv_rec.idx_type := p5_a20;
    ddp_idxv_rec.idx_frequency := p5_a21;
    ddp_idxv_rec.program_id := rosetta_g_miss_num_map(p5_a22);
    ddp_idxv_rec.request_id := rosetta_g_miss_num_map(p5_a23);
    ddp_idxv_rec.program_application_id := rosetta_g_miss_num_map(p5_a24);
    ddp_idxv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_idxv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_idxv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_idxv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_idxv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_idxv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_interest_maint_pub.int_hdr_ins_updt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_idxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure int_hdr_ins_updt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_idxv_tbl okl_interest_maint_pub.idxv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_idx_pvt_w.rosetta_table_copy_in_p5(ddp_idxv_tbl, p5_a0
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
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_interest_maint_pub.int_hdr_ins_updt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_idxv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure int_dtl_ins_updt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_ivev_rec okl_interest_maint_pub.ivev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ivev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ivev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ivev_rec.idx_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ivev_rec.value := rosetta_g_miss_num_map(p5_a3);
    ddp_ivev_rec.datetime_valid := rosetta_g_miss_date_in_map(p5_a4);
    ddp_ivev_rec.datetime_invalid := rosetta_g_miss_date_in_map(p5_a5);
    ddp_ivev_rec.program_id := rosetta_g_miss_num_map(p5_a6);
    ddp_ivev_rec.program_application_id := rosetta_g_miss_num_map(p5_a7);
    ddp_ivev_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_ivev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_ivev_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_ivev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_ivev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a12);
    ddp_ivev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_ivev_rec.last_update_login := rosetta_g_miss_num_map(p5_a14);

    -- here's the delegated call to the old PL/SQL routine
    okl_interest_maint_pub.int_dtl_ins_updt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ivev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure int_dtl_ins_updt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
  )

  as
    ddp_ivev_tbl okl_interest_maint_pub.ivev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ive_pvt_w.rosetta_table_copy_in_p5(ddp_ivev_tbl, p5_a0
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
      , p5_a14
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_interest_maint_pub.int_dtl_ins_updt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ivev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_interest_maint_pub_w;

/
