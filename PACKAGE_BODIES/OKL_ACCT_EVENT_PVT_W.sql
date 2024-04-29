--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_EVENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_EVENT_PVT_W" as
  /* $Header: OKLOAETB.pls 120.1 2005/07/07 13:35:46 dkagrawa noship $ */
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

  procedure create_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_800
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_VARCHAR2_TABLE_800
    , p7_a17 JTF_VARCHAR2_TABLE_800
    , p7_a18 JTF_VARCHAR2_TABLE_800
    , p7_a19 JTF_VARCHAR2_TABLE_800
    , p7_a20 JTF_VARCHAR2_TABLE_800
    , p7_a21 JTF_VARCHAR2_TABLE_800
    , p7_a22 JTF_VARCHAR2_TABLE_800
    , p7_a23 JTF_VARCHAR2_TABLE_800
    , p7_a24 JTF_VARCHAR2_TABLE_800
    , p7_a25 JTF_VARCHAR2_TABLE_800
    , p7_a26 JTF_VARCHAR2_TABLE_800
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_VARCHAR2_TABLE_100
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_VARCHAR2_TABLE_100
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_NUMBER_TABLE
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_VARCHAR2_TABLE_100
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_VARCHAR2_TABLE_100
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_DATE_TABLE
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_DATE_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  DATE
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  DATE
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_DATE_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_DATE_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a27 out nocopy JTF_NUMBER_TABLE
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_NUMBER_TABLE
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a31 out nocopy JTF_NUMBER_TABLE
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_NUMBER_TABLE
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_NUMBER_TABLE
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 out nocopy JTF_NUMBER_TABLE
    , p10_a43 out nocopy JTF_NUMBER_TABLE
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a45 out nocopy JTF_NUMBER_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_DATE_TABLE
    , p10_a48 out nocopy JTF_NUMBER_TABLE
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_NUMBER_TABLE
    , p10_a51 out nocopy JTF_DATE_TABLE
    , p10_a52 out nocopy JTF_NUMBER_TABLE
    , p10_a53 out nocopy JTF_DATE_TABLE
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_NUMBER_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddx_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddx_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddx_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p6_a0
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
      );

    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p7_a0
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
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec,
      ddp_aehv_tbl,
      ddp_aelv_tbl,
      ddx_aetv_rec,
      ddx_aehv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_aetv_rec.accounting_event_id);
    p8_a1 := rosetta_g_miss_num_map(ddx_aetv_rec.object_version_number);
    p8_a2 := rosetta_g_miss_num_map(ddx_aetv_rec.org_id);
    p8_a3 := ddx_aetv_rec.event_type_code;
    p8_a4 := ddx_aetv_rec.accounting_date;
    p8_a5 := rosetta_g_miss_num_map(ddx_aetv_rec.event_number);
    p8_a6 := ddx_aetv_rec.event_status_code;
    p8_a7 := rosetta_g_miss_num_map(ddx_aetv_rec.source_id);
    p8_a8 := ddx_aetv_rec.source_table;
    p8_a9 := rosetta_g_miss_num_map(ddx_aetv_rec.program_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_aetv_rec.program_application_id);
    p8_a11 := ddx_aetv_rec.program_update_date;
    p8_a12 := rosetta_g_miss_num_map(ddx_aetv_rec.request_id);
    p8_a13 := rosetta_g_miss_num_map(ddx_aetv_rec.created_by);
    p8_a14 := ddx_aetv_rec.creation_date;
    p8_a15 := rosetta_g_miss_num_map(ddx_aetv_rec.last_updated_by);
    p8_a16 := ddx_aetv_rec.last_update_date;
    p8_a17 := rosetta_g_miss_num_map(ddx_aetv_rec.last_update_login);

    okl_aeh_pvt_w.rosetta_table_copy_out_p5(ddx_aehv_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      );

    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      , p10_a56
      , p10_a57
      );
  end;

  procedure update_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_800
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_VARCHAR2_TABLE_800
    , p7_a17 JTF_VARCHAR2_TABLE_800
    , p7_a18 JTF_VARCHAR2_TABLE_800
    , p7_a19 JTF_VARCHAR2_TABLE_800
    , p7_a20 JTF_VARCHAR2_TABLE_800
    , p7_a21 JTF_VARCHAR2_TABLE_800
    , p7_a22 JTF_VARCHAR2_TABLE_800
    , p7_a23 JTF_VARCHAR2_TABLE_800
    , p7_a24 JTF_VARCHAR2_TABLE_800
    , p7_a25 JTF_VARCHAR2_TABLE_800
    , p7_a26 JTF_VARCHAR2_TABLE_800
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_VARCHAR2_TABLE_100
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_VARCHAR2_TABLE_100
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_NUMBER_TABLE
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_VARCHAR2_TABLE_100
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_VARCHAR2_TABLE_100
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_DATE_TABLE
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_DATE_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  DATE
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  DATE
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_DATE_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_DATE_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p10_a27 out nocopy JTF_NUMBER_TABLE
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_NUMBER_TABLE
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a31 out nocopy JTF_NUMBER_TABLE
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_NUMBER_TABLE
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_NUMBER_TABLE
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 out nocopy JTF_NUMBER_TABLE
    , p10_a43 out nocopy JTF_NUMBER_TABLE
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a45 out nocopy JTF_NUMBER_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_DATE_TABLE
    , p10_a48 out nocopy JTF_NUMBER_TABLE
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_NUMBER_TABLE
    , p10_a51 out nocopy JTF_DATE_TABLE
    , p10_a52 out nocopy JTF_NUMBER_TABLE
    , p10_a53 out nocopy JTF_DATE_TABLE
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_NUMBER_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddx_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddx_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddx_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p6_a0
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
      );

    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p7_a0
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
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec,
      ddp_aehv_tbl,
      ddp_aelv_tbl,
      ddx_aetv_rec,
      ddx_aehv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_aetv_rec.accounting_event_id);
    p8_a1 := rosetta_g_miss_num_map(ddx_aetv_rec.object_version_number);
    p8_a2 := rosetta_g_miss_num_map(ddx_aetv_rec.org_id);
    p8_a3 := ddx_aetv_rec.event_type_code;
    p8_a4 := ddx_aetv_rec.accounting_date;
    p8_a5 := rosetta_g_miss_num_map(ddx_aetv_rec.event_number);
    p8_a6 := ddx_aetv_rec.event_status_code;
    p8_a7 := rosetta_g_miss_num_map(ddx_aetv_rec.source_id);
    p8_a8 := ddx_aetv_rec.source_table;
    p8_a9 := rosetta_g_miss_num_map(ddx_aetv_rec.program_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_aetv_rec.program_application_id);
    p8_a11 := ddx_aetv_rec.program_update_date;
    p8_a12 := rosetta_g_miss_num_map(ddx_aetv_rec.request_id);
    p8_a13 := rosetta_g_miss_num_map(ddx_aetv_rec.created_by);
    p8_a14 := ddx_aetv_rec.creation_date;
    p8_a15 := rosetta_g_miss_num_map(ddx_aetv_rec.last_updated_by);
    p8_a16 := ddx_aetv_rec.last_update_date;
    p8_a17 := rosetta_g_miss_num_map(ddx_aetv_rec.last_update_login);

    okl_aeh_pvt_w.rosetta_table_copy_out_p5(ddx_aehv_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      );

    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      , p10_a56
      , p10_a57
      );
  end;

  procedure validate_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_800
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_VARCHAR2_TABLE_800
    , p7_a17 JTF_VARCHAR2_TABLE_800
    , p7_a18 JTF_VARCHAR2_TABLE_800
    , p7_a19 JTF_VARCHAR2_TABLE_800
    , p7_a20 JTF_VARCHAR2_TABLE_800
    , p7_a21 JTF_VARCHAR2_TABLE_800
    , p7_a22 JTF_VARCHAR2_TABLE_800
    , p7_a23 JTF_VARCHAR2_TABLE_800
    , p7_a24 JTF_VARCHAR2_TABLE_800
    , p7_a25 JTF_VARCHAR2_TABLE_800
    , p7_a26 JTF_VARCHAR2_TABLE_800
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_VARCHAR2_TABLE_100
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_VARCHAR2_TABLE_100
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_NUMBER_TABLE
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_VARCHAR2_TABLE_100
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_VARCHAR2_TABLE_100
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_DATE_TABLE
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_DATE_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p6_a0
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
      );

    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p7_a0
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
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec,
      ddp_aehv_tbl,
      ddp_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddx_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aet_pvt_w.rosetta_table_copy_in_p5(ddp_aetv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_tbl,
      ddx_aetv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aet_pvt_w.rosetta_table_copy_out_p5(ddx_aetv_tbl, p6_a0
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
      );
  end;

  procedure create_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddx_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec,
      ddx_aetv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aetv_rec.accounting_event_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aetv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aetv_rec.org_id);
    p6_a3 := ddx_aetv_rec.event_type_code;
    p6_a4 := ddx_aetv_rec.accounting_date;
    p6_a5 := rosetta_g_miss_num_map(ddx_aetv_rec.event_number);
    p6_a6 := ddx_aetv_rec.event_status_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_aetv_rec.source_id);
    p6_a8 := ddx_aetv_rec.source_table;
    p6_a9 := rosetta_g_miss_num_map(ddx_aetv_rec.program_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_aetv_rec.program_application_id);
    p6_a11 := ddx_aetv_rec.program_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_aetv_rec.request_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_aetv_rec.created_by);
    p6_a14 := ddx_aetv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_aetv_rec.last_updated_by);
    p6_a16 := ddx_aetv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_aetv_rec.last_update_login);
  end;

  procedure lock_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aet_pvt_w.rosetta_table_copy_in_p5(ddp_aetv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.lock_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.lock_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddx_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aet_pvt_w.rosetta_table_copy_in_p5(ddp_aetv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_tbl,
      ddx_aetv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aet_pvt_w.rosetta_table_copy_out_p5(ddx_aetv_tbl, p6_a0
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
      );
  end;

  procedure update_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddx_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec,
      ddx_aetv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aetv_rec.accounting_event_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aetv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aetv_rec.org_id);
    p6_a3 := ddx_aetv_rec.event_type_code;
    p6_a4 := ddx_aetv_rec.accounting_date;
    p6_a5 := rosetta_g_miss_num_map(ddx_aetv_rec.event_number);
    p6_a6 := ddx_aetv_rec.event_status_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_aetv_rec.source_id);
    p6_a8 := ddx_aetv_rec.source_table;
    p6_a9 := rosetta_g_miss_num_map(ddx_aetv_rec.program_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_aetv_rec.program_application_id);
    p6_a11 := ddx_aetv_rec.program_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_aetv_rec.request_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_aetv_rec.created_by);
    p6_a14 := ddx_aetv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_aetv_rec.last_updated_by);
    p6_a16 := ddx_aetv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_aetv_rec.last_update_login);
  end;

  procedure delete_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aet_pvt_w.rosetta_table_copy_in_p5(ddp_aetv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.delete_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.delete_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_aetv_tbl okl_acct_event_pvt.aetv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aet_pvt_w.rosetta_table_copy_in_p5(ddp_aetv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acct_event(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_aetv_rec okl_acct_event_pvt.aetv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aetv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aetv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aetv_rec.org_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aetv_rec.event_type_code := p5_a3;
    ddp_aetv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_aetv_rec.event_number := rosetta_g_miss_num_map(p5_a5);
    ddp_aetv_rec.event_status_code := p5_a6;
    ddp_aetv_rec.source_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aetv_rec.source_table := p5_a8;
    ddp_aetv_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_aetv_rec.program_application_id := rosetta_g_miss_num_map(p5_a10);
    ddp_aetv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aetv_rec.request_id := rosetta_g_miss_num_map(p5_a12);
    ddp_aetv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_aetv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_aetv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_aetv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_aetv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_event(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aetv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_800
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddx_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_tbl,
      ddx_aehv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aeh_pvt_w.rosetta_table_copy_out_p5(ddx_aehv_tbl, p6_a0
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
      );
  end;

  procedure create_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddx_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aehv_rec.post_to_gl_flag := p5_a0;
    ddp_aehv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_aehv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_aehv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a3);
    ddp_aehv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aehv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aehv_rec.ae_category := p5_a6;
    ddp_aehv_rec.sequence_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aehv_rec.sequence_value := rosetta_g_miss_num_map(p5_a8);
    ddp_aehv_rec.period_name := p5_a9;
    ddp_aehv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_aehv_rec.description := p5_a11;
    ddp_aehv_rec.accounting_error_code := p5_a12;
    ddp_aehv_rec.cross_currency_flag := p5_a13;
    ddp_aehv_rec.gl_transfer_flag := p5_a14;
    ddp_aehv_rec.gl_transfer_error_code := p5_a15;
    ddp_aehv_rec.gl_transfer_run_id := rosetta_g_miss_num_map(p5_a16);
    ddp_aehv_rec.gl_reversal_flag := p5_a17;
    ddp_aehv_rec.program_id := rosetta_g_miss_num_map(p5_a18);
    ddp_aehv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_aehv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_aehv_rec.request_id := rosetta_g_miss_num_map(p5_a21);
    ddp_aehv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_aehv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_aehv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_aehv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_aehv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_rec,
      ddx_aehv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_aehv_rec.post_to_gl_flag;
    p6_a1 := rosetta_g_miss_num_map(ddx_aehv_rec.ae_header_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_aehv_rec.object_version_number);
    p6_a3 := rosetta_g_miss_num_map(ddx_aehv_rec.accounting_event_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_aehv_rec.set_of_books_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aehv_rec.org_id);
    p6_a6 := ddx_aehv_rec.ae_category;
    p6_a7 := rosetta_g_miss_num_map(ddx_aehv_rec.sequence_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_aehv_rec.sequence_value);
    p6_a9 := ddx_aehv_rec.period_name;
    p6_a10 := ddx_aehv_rec.accounting_date;
    p6_a11 := ddx_aehv_rec.description;
    p6_a12 := ddx_aehv_rec.accounting_error_code;
    p6_a13 := ddx_aehv_rec.cross_currency_flag;
    p6_a14 := ddx_aehv_rec.gl_transfer_flag;
    p6_a15 := ddx_aehv_rec.gl_transfer_error_code;
    p6_a16 := rosetta_g_miss_num_map(ddx_aehv_rec.gl_transfer_run_id);
    p6_a17 := ddx_aehv_rec.gl_reversal_flag;
    p6_a18 := rosetta_g_miss_num_map(ddx_aehv_rec.program_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_aehv_rec.program_application_id);
    p6_a20 := ddx_aehv_rec.program_update_date;
    p6_a21 := rosetta_g_miss_num_map(ddx_aehv_rec.request_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_aehv_rec.created_by);
    p6_a23 := ddx_aehv_rec.creation_date;
    p6_a24 := rosetta_g_miss_num_map(ddx_aehv_rec.last_updated_by);
    p6_a25 := ddx_aehv_rec.last_update_date;
    p6_a26 := rosetta_g_miss_num_map(ddx_aehv_rec.last_update_login);
  end;

  procedure lock_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_800
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
  )

  as
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.lock_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aehv_rec.post_to_gl_flag := p5_a0;
    ddp_aehv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_aehv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_aehv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a3);
    ddp_aehv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aehv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aehv_rec.ae_category := p5_a6;
    ddp_aehv_rec.sequence_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aehv_rec.sequence_value := rosetta_g_miss_num_map(p5_a8);
    ddp_aehv_rec.period_name := p5_a9;
    ddp_aehv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_aehv_rec.description := p5_a11;
    ddp_aehv_rec.accounting_error_code := p5_a12;
    ddp_aehv_rec.cross_currency_flag := p5_a13;
    ddp_aehv_rec.gl_transfer_flag := p5_a14;
    ddp_aehv_rec.gl_transfer_error_code := p5_a15;
    ddp_aehv_rec.gl_transfer_run_id := rosetta_g_miss_num_map(p5_a16);
    ddp_aehv_rec.gl_reversal_flag := p5_a17;
    ddp_aehv_rec.program_id := rosetta_g_miss_num_map(p5_a18);
    ddp_aehv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_aehv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_aehv_rec.request_id := rosetta_g_miss_num_map(p5_a21);
    ddp_aehv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_aehv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_aehv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_aehv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_aehv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.lock_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_800
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddx_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_tbl,
      ddx_aehv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aeh_pvt_w.rosetta_table_copy_out_p5(ddx_aehv_tbl, p6_a0
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
      );
  end;

  procedure update_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddx_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aehv_rec.post_to_gl_flag := p5_a0;
    ddp_aehv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_aehv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_aehv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a3);
    ddp_aehv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aehv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aehv_rec.ae_category := p5_a6;
    ddp_aehv_rec.sequence_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aehv_rec.sequence_value := rosetta_g_miss_num_map(p5_a8);
    ddp_aehv_rec.period_name := p5_a9;
    ddp_aehv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_aehv_rec.description := p5_a11;
    ddp_aehv_rec.accounting_error_code := p5_a12;
    ddp_aehv_rec.cross_currency_flag := p5_a13;
    ddp_aehv_rec.gl_transfer_flag := p5_a14;
    ddp_aehv_rec.gl_transfer_error_code := p5_a15;
    ddp_aehv_rec.gl_transfer_run_id := rosetta_g_miss_num_map(p5_a16);
    ddp_aehv_rec.gl_reversal_flag := p5_a17;
    ddp_aehv_rec.program_id := rosetta_g_miss_num_map(p5_a18);
    ddp_aehv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_aehv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_aehv_rec.request_id := rosetta_g_miss_num_map(p5_a21);
    ddp_aehv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_aehv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_aehv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_aehv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_aehv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_rec,
      ddx_aehv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_aehv_rec.post_to_gl_flag;
    p6_a1 := rosetta_g_miss_num_map(ddx_aehv_rec.ae_header_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_aehv_rec.object_version_number);
    p6_a3 := rosetta_g_miss_num_map(ddx_aehv_rec.accounting_event_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_aehv_rec.set_of_books_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aehv_rec.org_id);
    p6_a6 := ddx_aehv_rec.ae_category;
    p6_a7 := rosetta_g_miss_num_map(ddx_aehv_rec.sequence_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_aehv_rec.sequence_value);
    p6_a9 := ddx_aehv_rec.period_name;
    p6_a10 := ddx_aehv_rec.accounting_date;
    p6_a11 := ddx_aehv_rec.description;
    p6_a12 := ddx_aehv_rec.accounting_error_code;
    p6_a13 := ddx_aehv_rec.cross_currency_flag;
    p6_a14 := ddx_aehv_rec.gl_transfer_flag;
    p6_a15 := ddx_aehv_rec.gl_transfer_error_code;
    p6_a16 := rosetta_g_miss_num_map(ddx_aehv_rec.gl_transfer_run_id);
    p6_a17 := ddx_aehv_rec.gl_reversal_flag;
    p6_a18 := rosetta_g_miss_num_map(ddx_aehv_rec.program_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_aehv_rec.program_application_id);
    p6_a20 := ddx_aehv_rec.program_update_date;
    p6_a21 := rosetta_g_miss_num_map(ddx_aehv_rec.request_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_aehv_rec.created_by);
    p6_a23 := ddx_aehv_rec.creation_date;
    p6_a24 := rosetta_g_miss_num_map(ddx_aehv_rec.last_updated_by);
    p6_a25 := ddx_aehv_rec.last_update_date;
    p6_a26 := rosetta_g_miss_num_map(ddx_aehv_rec.last_update_login);
  end;

  procedure delete_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_800
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
  )

  as
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.delete_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aehv_rec.post_to_gl_flag := p5_a0;
    ddp_aehv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_aehv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_aehv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a3);
    ddp_aehv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aehv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aehv_rec.ae_category := p5_a6;
    ddp_aehv_rec.sequence_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aehv_rec.sequence_value := rosetta_g_miss_num_map(p5_a8);
    ddp_aehv_rec.period_name := p5_a9;
    ddp_aehv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_aehv_rec.description := p5_a11;
    ddp_aehv_rec.accounting_error_code := p5_a12;
    ddp_aehv_rec.cross_currency_flag := p5_a13;
    ddp_aehv_rec.gl_transfer_flag := p5_a14;
    ddp_aehv_rec.gl_transfer_error_code := p5_a15;
    ddp_aehv_rec.gl_transfer_run_id := rosetta_g_miss_num_map(p5_a16);
    ddp_aehv_rec.gl_reversal_flag := p5_a17;
    ddp_aehv_rec.program_id := rosetta_g_miss_num_map(p5_a18);
    ddp_aehv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_aehv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_aehv_rec.request_id := rosetta_g_miss_num_map(p5_a21);
    ddp_aehv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_aehv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_aehv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_aehv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_aehv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.delete_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_800
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
  )

  as
    ddp_aehv_tbl okl_acct_event_pvt.aehv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aeh_pvt_w.rosetta_table_copy_in_p5(ddp_aehv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acct_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_aehv_rec okl_acct_event_pvt.aehv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aehv_rec.post_to_gl_flag := p5_a0;
    ddp_aehv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_aehv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_aehv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a3);
    ddp_aehv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aehv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aehv_rec.ae_category := p5_a6;
    ddp_aehv_rec.sequence_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aehv_rec.sequence_value := rosetta_g_miss_num_map(p5_a8);
    ddp_aehv_rec.period_name := p5_a9;
    ddp_aehv_rec.accounting_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_aehv_rec.description := p5_a11;
    ddp_aehv_rec.accounting_error_code := p5_a12;
    ddp_aehv_rec.cross_currency_flag := p5_a13;
    ddp_aehv_rec.gl_transfer_flag := p5_a14;
    ddp_aehv_rec.gl_transfer_error_code := p5_a15;
    ddp_aehv_rec.gl_transfer_run_id := rosetta_g_miss_num_map(p5_a16);
    ddp_aehv_rec.gl_reversal_flag := p5_a17;
    ddp_aehv_rec.program_id := rosetta_g_miss_num_map(p5_a18);
    ddp_aehv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_aehv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_aehv_rec.request_id := rosetta_g_miss_num_map(p5_a21);
    ddp_aehv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_aehv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_aehv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_aehv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_aehv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aehv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddx_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p6_a0
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
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      );
  end;

  procedure create_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddx_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.create_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec,
      ddx_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aelv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_header_id);
    p6_a3 := ddx_aelv_rec.currency_conversion_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_aelv_rec.code_combination_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aelv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_number);
    p6_a7 := ddx_aelv_rec.ae_line_type_code;
    p6_a8 := ddx_aelv_rec.currency_conversion_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_aelv_rec.currency_conversion_rate);
    p6_a10 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_dr);
    p6_a11 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_cr);
    p6_a12 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_dr);
    p6_a13 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_cr);
    p6_a14 := ddx_aelv_rec.source_table;
    p6_a15 := rosetta_g_miss_num_map(ddx_aelv_rec.source_id);
    p6_a16 := ddx_aelv_rec.reference1;
    p6_a17 := ddx_aelv_rec.reference2;
    p6_a18 := ddx_aelv_rec.reference3;
    p6_a19 := ddx_aelv_rec.reference4;
    p6_a20 := ddx_aelv_rec.reference5;
    p6_a21 := ddx_aelv_rec.reference6;
    p6_a22 := ddx_aelv_rec.reference7;
    p6_a23 := ddx_aelv_rec.reference8;
    p6_a24 := ddx_aelv_rec.reference9;
    p6_a25 := ddx_aelv_rec.reference10;
    p6_a26 := ddx_aelv_rec.description;
    p6_a27 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_sub_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_aelv_rec.stat_amount);
    p6_a30 := ddx_aelv_rec.ussgl_transaction_code;
    p6_a31 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_id);
    p6_a32 := ddx_aelv_rec.accounting_error_code;
    p6_a33 := ddx_aelv_rec.gl_transfer_error_code;
    p6_a34 := rosetta_g_miss_num_map(ddx_aelv_rec.gl_sl_link_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_dr);
    p6_a36 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_cr);
    p6_a37 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_dr);
    p6_a38 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_cr);
    p6_a39 := ddx_aelv_rec.applied_from_trx_hdr_table;
    p6_a40 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_from_trx_hdr_id);
    p6_a41 := ddx_aelv_rec.applied_to_trx_hdr_table;
    p6_a42 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_to_trx_hdr_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_link_id);
    p6_a44 := ddx_aelv_rec.currency_code;
    p6_a45 := rosetta_g_miss_num_map(ddx_aelv_rec.program_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_aelv_rec.program_application_id);
    p6_a47 := ddx_aelv_rec.program_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_aelv_rec.request_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_aelv_rec.aeh_tbl_index);
    p6_a50 := rosetta_g_miss_num_map(ddx_aelv_rec.created_by);
    p6_a51 := ddx_aelv_rec.creation_date;
    p6_a52 := rosetta_g_miss_num_map(ddx_aelv_rec.last_updated_by);
    p6_a53 := ddx_aelv_rec.last_update_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_aelv_rec.last_update_login);
    p6_a55 := rosetta_g_miss_num_map(ddx_aelv_rec.account_overlay_source_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_value);
    p6_a57 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_code_id);
  end;

  procedure lock_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.lock_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.lock_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddx_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p6_a0
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
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      );
  end;

  procedure update_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddx_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);


    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.update_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec,
      ddx_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aelv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_header_id);
    p6_a3 := ddx_aelv_rec.currency_conversion_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_aelv_rec.code_combination_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aelv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_number);
    p6_a7 := ddx_aelv_rec.ae_line_type_code;
    p6_a8 := ddx_aelv_rec.currency_conversion_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_aelv_rec.currency_conversion_rate);
    p6_a10 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_dr);
    p6_a11 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_cr);
    p6_a12 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_dr);
    p6_a13 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_cr);
    p6_a14 := ddx_aelv_rec.source_table;
    p6_a15 := rosetta_g_miss_num_map(ddx_aelv_rec.source_id);
    p6_a16 := ddx_aelv_rec.reference1;
    p6_a17 := ddx_aelv_rec.reference2;
    p6_a18 := ddx_aelv_rec.reference3;
    p6_a19 := ddx_aelv_rec.reference4;
    p6_a20 := ddx_aelv_rec.reference5;
    p6_a21 := ddx_aelv_rec.reference6;
    p6_a22 := ddx_aelv_rec.reference7;
    p6_a23 := ddx_aelv_rec.reference8;
    p6_a24 := ddx_aelv_rec.reference9;
    p6_a25 := ddx_aelv_rec.reference10;
    p6_a26 := ddx_aelv_rec.description;
    p6_a27 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_sub_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_aelv_rec.stat_amount);
    p6_a30 := ddx_aelv_rec.ussgl_transaction_code;
    p6_a31 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_id);
    p6_a32 := ddx_aelv_rec.accounting_error_code;
    p6_a33 := ddx_aelv_rec.gl_transfer_error_code;
    p6_a34 := rosetta_g_miss_num_map(ddx_aelv_rec.gl_sl_link_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_dr);
    p6_a36 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_cr);
    p6_a37 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_dr);
    p6_a38 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_cr);
    p6_a39 := ddx_aelv_rec.applied_from_trx_hdr_table;
    p6_a40 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_from_trx_hdr_id);
    p6_a41 := ddx_aelv_rec.applied_to_trx_hdr_table;
    p6_a42 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_to_trx_hdr_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_link_id);
    p6_a44 := ddx_aelv_rec.currency_code;
    p6_a45 := rosetta_g_miss_num_map(ddx_aelv_rec.program_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_aelv_rec.program_application_id);
    p6_a47 := ddx_aelv_rec.program_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_aelv_rec.request_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_aelv_rec.aeh_tbl_index);
    p6_a50 := rosetta_g_miss_num_map(ddx_aelv_rec.created_by);
    p6_a51 := ddx_aelv_rec.creation_date;
    p6_a52 := rosetta_g_miss_num_map(ddx_aelv_rec.last_updated_by);
    p6_a53 := ddx_aelv_rec.last_update_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_aelv_rec.last_update_login);
    p6_a55 := rosetta_g_miss_num_map(ddx_aelv_rec.account_overlay_source_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_value);
    p6_a57 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_code_id);
  end;

  procedure delete_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.delete_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.delete_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_acct_event_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_acct_event_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);

    -- here's the delegated call to the old PL/SQL routine
    okl_acct_event_pvt.validate_acct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_acct_event_pvt_w;

/
