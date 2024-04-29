--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_DISB_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_DISB_RULES_PVT_W" as
  /* $Header: OKLESDRB.pls 120.0 2007/04/27 09:16:03 gkhuntet noship $ */
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

  procedure create_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  DATE
    , p8_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_drav_rec okl_setup_disb_rules_pvt.drav_rec_type;
    ddp_drs_tbl okl_setup_disb_rules_pvt.drs_tbl_type;
    ddp_drv_tbl okl_setup_disb_rules_pvt.drv_tbl_type;
    ddx_drav_rec okl_setup_disb_rules_pvt.drav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drav_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drav_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drav_rec.sfwt_flag := p5_a2;
    ddp_drav_rec.rule_name := p5_a3;
    ddp_drav_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drav_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drav_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drav_rec.fee_option := p5_a7;
    ddp_drav_rec.fee_basis := p5_a8;
    ddp_drav_rec.fee_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_drav_rec.fee_percent := rosetta_g_miss_num_map(p5_a10);
    ddp_drav_rec.consolidate_by_due_date := p5_a11;
    ddp_drav_rec.frequency := p5_a12;
    ddp_drav_rec.day_of_month := rosetta_g_miss_num_map(p5_a13);
    ddp_drav_rec.scheduled_month := p5_a14;
    ddp_drav_rec.consolidate_strm_type := p5_a15;
    ddp_drav_rec.description := p5_a16;
    ddp_drav_rec.attribute_category := p5_a17;
    ddp_drav_rec.attribute1 := p5_a18;
    ddp_drav_rec.attribute2 := p5_a19;
    ddp_drav_rec.attribute3 := p5_a20;
    ddp_drav_rec.attribute4 := p5_a21;
    ddp_drav_rec.attribute5 := p5_a22;
    ddp_drav_rec.attribute6 := p5_a23;
    ddp_drav_rec.attribute7 := p5_a24;
    ddp_drav_rec.attribute8 := p5_a25;
    ddp_drav_rec.attribute9 := p5_a26;
    ddp_drav_rec.attribute10 := p5_a27;
    ddp_drav_rec.attribute11 := p5_a28;
    ddp_drav_rec.attribute12 := p5_a29;
    ddp_drav_rec.attribute13 := p5_a30;
    ddp_drav_rec.attribute14 := p5_a31;
    ddp_drav_rec.attribute15 := p5_a32;
    ddp_drav_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_drav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_drav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_drav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_drav_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    okl_drs_pvt_w.rosetta_table_copy_in_p2(ddp_drs_tbl, p6_a0
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
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      );

    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p7_a0
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
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_disb_rules_pvt.create_disbursement_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drav_rec,
      ddp_drs_tbl,
      ddp_drv_tbl,
      ddx_drav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_drav_rec.disb_rule_id);
    p8_a1 := rosetta_g_miss_num_map(ddx_drav_rec.object_version_number);
    p8_a2 := ddx_drav_rec.sfwt_flag;
    p8_a3 := ddx_drav_rec.rule_name;
    p8_a4 := rosetta_g_miss_num_map(ddx_drav_rec.org_id);
    p8_a5 := ddx_drav_rec.start_date;
    p8_a6 := ddx_drav_rec.end_date;
    p8_a7 := ddx_drav_rec.fee_option;
    p8_a8 := ddx_drav_rec.fee_basis;
    p8_a9 := rosetta_g_miss_num_map(ddx_drav_rec.fee_amount);
    p8_a10 := rosetta_g_miss_num_map(ddx_drav_rec.fee_percent);
    p8_a11 := ddx_drav_rec.consolidate_by_due_date;
    p8_a12 := ddx_drav_rec.frequency;
    p8_a13 := rosetta_g_miss_num_map(ddx_drav_rec.day_of_month);
    p8_a14 := ddx_drav_rec.scheduled_month;
    p8_a15 := ddx_drav_rec.consolidate_strm_type;
    p8_a16 := ddx_drav_rec.description;
    p8_a17 := ddx_drav_rec.attribute_category;
    p8_a18 := ddx_drav_rec.attribute1;
    p8_a19 := ddx_drav_rec.attribute2;
    p8_a20 := ddx_drav_rec.attribute3;
    p8_a21 := ddx_drav_rec.attribute4;
    p8_a22 := ddx_drav_rec.attribute5;
    p8_a23 := ddx_drav_rec.attribute6;
    p8_a24 := ddx_drav_rec.attribute7;
    p8_a25 := ddx_drav_rec.attribute8;
    p8_a26 := ddx_drav_rec.attribute9;
    p8_a27 := ddx_drav_rec.attribute10;
    p8_a28 := ddx_drav_rec.attribute11;
    p8_a29 := ddx_drav_rec.attribute12;
    p8_a30 := ddx_drav_rec.attribute13;
    p8_a31 := ddx_drav_rec.attribute14;
    p8_a32 := ddx_drav_rec.attribute15;
    p8_a33 := rosetta_g_miss_num_map(ddx_drav_rec.created_by);
    p8_a34 := ddx_drav_rec.creation_date;
    p8_a35 := rosetta_g_miss_num_map(ddx_drav_rec.last_updated_by);
    p8_a36 := ddx_drav_rec.last_update_date;
    p8_a37 := rosetta_g_miss_num_map(ddx_drav_rec.last_update_login);
  end;

  procedure update_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  DATE
    , p8_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_drav_rec okl_setup_disb_rules_pvt.drav_rec_type;
    ddp_drs_tbl okl_setup_disb_rules_pvt.drs_tbl_type;
    ddp_drv_tbl okl_setup_disb_rules_pvt.drv_tbl_type;
    ddx_drav_rec okl_setup_disb_rules_pvt.drav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drav_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drav_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drav_rec.sfwt_flag := p5_a2;
    ddp_drav_rec.rule_name := p5_a3;
    ddp_drav_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drav_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drav_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drav_rec.fee_option := p5_a7;
    ddp_drav_rec.fee_basis := p5_a8;
    ddp_drav_rec.fee_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_drav_rec.fee_percent := rosetta_g_miss_num_map(p5_a10);
    ddp_drav_rec.consolidate_by_due_date := p5_a11;
    ddp_drav_rec.frequency := p5_a12;
    ddp_drav_rec.day_of_month := rosetta_g_miss_num_map(p5_a13);
    ddp_drav_rec.scheduled_month := p5_a14;
    ddp_drav_rec.consolidate_strm_type := p5_a15;
    ddp_drav_rec.description := p5_a16;
    ddp_drav_rec.attribute_category := p5_a17;
    ddp_drav_rec.attribute1 := p5_a18;
    ddp_drav_rec.attribute2 := p5_a19;
    ddp_drav_rec.attribute3 := p5_a20;
    ddp_drav_rec.attribute4 := p5_a21;
    ddp_drav_rec.attribute5 := p5_a22;
    ddp_drav_rec.attribute6 := p5_a23;
    ddp_drav_rec.attribute7 := p5_a24;
    ddp_drav_rec.attribute8 := p5_a25;
    ddp_drav_rec.attribute9 := p5_a26;
    ddp_drav_rec.attribute10 := p5_a27;
    ddp_drav_rec.attribute11 := p5_a28;
    ddp_drav_rec.attribute12 := p5_a29;
    ddp_drav_rec.attribute13 := p5_a30;
    ddp_drav_rec.attribute14 := p5_a31;
    ddp_drav_rec.attribute15 := p5_a32;
    ddp_drav_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_drav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_drav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_drav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_drav_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    okl_drs_pvt_w.rosetta_table_copy_in_p2(ddp_drs_tbl, p6_a0
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
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      );

    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p7_a0
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
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_disb_rules_pvt.update_disbursement_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drav_rec,
      ddp_drs_tbl,
      ddp_drv_tbl,
      ddx_drav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_drav_rec.disb_rule_id);
    p8_a1 := rosetta_g_miss_num_map(ddx_drav_rec.object_version_number);
    p8_a2 := ddx_drav_rec.sfwt_flag;
    p8_a3 := ddx_drav_rec.rule_name;
    p8_a4 := rosetta_g_miss_num_map(ddx_drav_rec.org_id);
    p8_a5 := ddx_drav_rec.start_date;
    p8_a6 := ddx_drav_rec.end_date;
    p8_a7 := ddx_drav_rec.fee_option;
    p8_a8 := ddx_drav_rec.fee_basis;
    p8_a9 := rosetta_g_miss_num_map(ddx_drav_rec.fee_amount);
    p8_a10 := rosetta_g_miss_num_map(ddx_drav_rec.fee_percent);
    p8_a11 := ddx_drav_rec.consolidate_by_due_date;
    p8_a12 := ddx_drav_rec.frequency;
    p8_a13 := rosetta_g_miss_num_map(ddx_drav_rec.day_of_month);
    p8_a14 := ddx_drav_rec.scheduled_month;
    p8_a15 := ddx_drav_rec.consolidate_strm_type;
    p8_a16 := ddx_drav_rec.description;
    p8_a17 := ddx_drav_rec.attribute_category;
    p8_a18 := ddx_drav_rec.attribute1;
    p8_a19 := ddx_drav_rec.attribute2;
    p8_a20 := ddx_drav_rec.attribute3;
    p8_a21 := ddx_drav_rec.attribute4;
    p8_a22 := ddx_drav_rec.attribute5;
    p8_a23 := ddx_drav_rec.attribute6;
    p8_a24 := ddx_drav_rec.attribute7;
    p8_a25 := ddx_drav_rec.attribute8;
    p8_a26 := ddx_drav_rec.attribute9;
    p8_a27 := ddx_drav_rec.attribute10;
    p8_a28 := ddx_drav_rec.attribute11;
    p8_a29 := ddx_drav_rec.attribute12;
    p8_a30 := ddx_drav_rec.attribute13;
    p8_a31 := ddx_drav_rec.attribute14;
    p8_a32 := ddx_drav_rec.attribute15;
    p8_a33 := rosetta_g_miss_num_map(ddx_drav_rec.created_by);
    p8_a34 := ddx_drav_rec.creation_date;
    p8_a35 := rosetta_g_miss_num_map(ddx_drav_rec.last_updated_by);
    p8_a36 := ddx_drav_rec.last_update_date;
    p8_a37 := rosetta_g_miss_num_map(ddx_drav_rec.last_update_login);
  end;

  procedure validate_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_drav_rec okl_setup_disb_rules_pvt.drav_rec_type;
    ddp_drs_tbl okl_setup_disb_rules_pvt.drs_tbl_type;
    ddp_drv_tbl okl_setup_disb_rules_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drav_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drav_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drav_rec.sfwt_flag := p5_a2;
    ddp_drav_rec.rule_name := p5_a3;
    ddp_drav_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drav_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drav_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drav_rec.fee_option := p5_a7;
    ddp_drav_rec.fee_basis := p5_a8;
    ddp_drav_rec.fee_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_drav_rec.fee_percent := rosetta_g_miss_num_map(p5_a10);
    ddp_drav_rec.consolidate_by_due_date := p5_a11;
    ddp_drav_rec.frequency := p5_a12;
    ddp_drav_rec.day_of_month := rosetta_g_miss_num_map(p5_a13);
    ddp_drav_rec.scheduled_month := p5_a14;
    ddp_drav_rec.consolidate_strm_type := p5_a15;
    ddp_drav_rec.description := p5_a16;
    ddp_drav_rec.attribute_category := p5_a17;
    ddp_drav_rec.attribute1 := p5_a18;
    ddp_drav_rec.attribute2 := p5_a19;
    ddp_drav_rec.attribute3 := p5_a20;
    ddp_drav_rec.attribute4 := p5_a21;
    ddp_drav_rec.attribute5 := p5_a22;
    ddp_drav_rec.attribute6 := p5_a23;
    ddp_drav_rec.attribute7 := p5_a24;
    ddp_drav_rec.attribute8 := p5_a25;
    ddp_drav_rec.attribute9 := p5_a26;
    ddp_drav_rec.attribute10 := p5_a27;
    ddp_drav_rec.attribute11 := p5_a28;
    ddp_drav_rec.attribute12 := p5_a29;
    ddp_drav_rec.attribute13 := p5_a30;
    ddp_drav_rec.attribute14 := p5_a31;
    ddp_drav_rec.attribute15 := p5_a32;
    ddp_drav_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_drav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_drav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_drav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_drav_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    okl_drs_pvt_w.rosetta_table_copy_in_p2(ddp_drs_tbl, p6_a0
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
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      );

    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p7_a0
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
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_setup_disb_rules_pvt.validate_disbursement_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drav_rec,
      ddp_drs_tbl,
      ddp_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_v_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_drv_tbl okl_setup_disb_rules_pvt.drv_tbl_type;
    ddx_drv_tbl okl_setup_disb_rules_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p5_a0
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
    okl_setup_disb_rules_pvt.create_v_disbursement_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_tbl,
      ddx_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_drv_pvt_w.rosetta_table_copy_out_p2(ddx_drv_tbl, p6_a0
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
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      );
  end;

end okl_setup_disb_rules_pvt_w;

/
