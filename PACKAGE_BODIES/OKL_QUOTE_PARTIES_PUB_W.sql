--------------------------------------------------------
--  DDL for Package Body OKL_QUOTE_PARTIES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QUOTE_PARTIES_PUB_W" as
  /* $Header: OKLUQPYB.pls 115.3 2002/12/04 03:24:50 gkadarka noship $ */
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

  procedure insert_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddx_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.insert_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl,
      ddx_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p6_a0
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
      );
  end;

  procedure insert_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddx_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);


    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.insert_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec,
      ddx_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qpyv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qpyv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_qpyv_rec.qte_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_qpyv_rec.cpl_id);
    p6_a4 := ddx_qpyv_rec.date_sent;
    p6_a5 := ddx_qpyv_rec.qpt_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_qpyv_rec.delay_days);
    p6_a7 := rosetta_g_miss_num_map(ddx_qpyv_rec.allocation_percentage);
    p6_a8 := ddx_qpyv_rec.email_address;
    p6_a9 := ddx_qpyv_rec.party_jtot_object1_code;
    p6_a10 := ddx_qpyv_rec.party_object1_id1;
    p6_a11 := ddx_qpyv_rec.party_object1_id2;
    p6_a12 := ddx_qpyv_rec.contact_jtot_object1_code;
    p6_a13 := ddx_qpyv_rec.contact_object1_id1;
    p6_a14 := ddx_qpyv_rec.contact_object1_id2;
    p6_a15 := rosetta_g_miss_num_map(ddx_qpyv_rec.created_by);
    p6_a16 := ddx_qpyv_rec.creation_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_updated_by);
    p6_a18 := ddx_qpyv_rec.last_update_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_update_login);
  end;

  procedure lock_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.lock_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.lock_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddx_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.update_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl,
      ddx_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p6_a0
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
      );
  end;

  procedure update_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddx_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);


    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.update_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec,
      ddx_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qpyv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qpyv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_qpyv_rec.qte_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_qpyv_rec.cpl_id);
    p6_a4 := ddx_qpyv_rec.date_sent;
    p6_a5 := ddx_qpyv_rec.qpt_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_qpyv_rec.delay_days);
    p6_a7 := rosetta_g_miss_num_map(ddx_qpyv_rec.allocation_percentage);
    p6_a8 := ddx_qpyv_rec.email_address;
    p6_a9 := ddx_qpyv_rec.party_jtot_object1_code;
    p6_a10 := ddx_qpyv_rec.party_object1_id1;
    p6_a11 := ddx_qpyv_rec.party_object1_id2;
    p6_a12 := ddx_qpyv_rec.contact_jtot_object1_code;
    p6_a13 := ddx_qpyv_rec.contact_object1_id1;
    p6_a14 := ddx_qpyv_rec.contact_object1_id2;
    p6_a15 := rosetta_g_miss_num_map(ddx_qpyv_rec.created_by);
    p6_a16 := ddx_qpyv_rec.creation_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_updated_by);
    p6_a18 := ddx_qpyv_rec.last_update_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_update_login);
  end;

  procedure delete_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.delete_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.delete_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_quote_parties_pub.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.validate_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_quote_parties_pub.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_quote_parties_pub.validate_quote_parties(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_quote_parties_pub_w;

/
