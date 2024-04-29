--------------------------------------------------------
--  DDL for Package Body OKL_TXL_ITM_INSTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_ITM_INSTS_PUB_W" as
  /* $Header: OKLUITIB.pls 115.5 2002/12/20 19:24:27 avsingh noship $ */
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

  procedure create_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddx_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iipv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_iipv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_iipv_rec.tas_id := rosetta_g_miss_num_map(p5_a2);
    ddp_iipv_rec.tal_id := rosetta_g_miss_num_map(p5_a3);
    ddp_iipv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_iipv_rec.tal_type := p5_a5;
    ddp_iipv_rec.line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_iipv_rec.instance_number_ib := p5_a7;
    ddp_iipv_rec.object_id1_new := p5_a8;
    ddp_iipv_rec.object_id2_new := p5_a9;
    ddp_iipv_rec.jtot_object_code_new := p5_a10;
    ddp_iipv_rec.object_id1_old := p5_a11;
    ddp_iipv_rec.object_id2_old := p5_a12;
    ddp_iipv_rec.jtot_object_code_old := p5_a13;
    ddp_iipv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_iipv_rec.serial_number := p5_a15;
    ddp_iipv_rec.mfg_serial_number_yn := p5_a16;
    ddp_iipv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a17);
    ddp_iipv_rec.inv_master_org_id := rosetta_g_miss_num_map(p5_a18);
    ddp_iipv_rec.attribute_category := p5_a19;
    ddp_iipv_rec.attribute1 := p5_a20;
    ddp_iipv_rec.attribute2 := p5_a21;
    ddp_iipv_rec.attribute3 := p5_a22;
    ddp_iipv_rec.attribute4 := p5_a23;
    ddp_iipv_rec.attribute5 := p5_a24;
    ddp_iipv_rec.attribute6 := p5_a25;
    ddp_iipv_rec.attribute7 := p5_a26;
    ddp_iipv_rec.attribute8 := p5_a27;
    ddp_iipv_rec.attribute9 := p5_a28;
    ddp_iipv_rec.attribute10 := p5_a29;
    ddp_iipv_rec.attribute11 := p5_a30;
    ddp_iipv_rec.attribute12 := p5_a31;
    ddp_iipv_rec.attribute13 := p5_a32;
    ddp_iipv_rec.attribute14 := p5_a33;
    ddp_iipv_rec.attribute15 := p5_a34;
    ddp_iipv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_iipv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_iipv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_iipv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_iipv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_iipv_rec.dnz_cle_id := rosetta_g_miss_num_map(p5_a40);
    ddp_iipv_rec.instance_id := rosetta_g_miss_num_map(p5_a41);
    ddp_iipv_rec.selected_for_split_flag := p5_a42;
    ddp_iipv_rec.asd_id := rosetta_g_miss_num_map(p5_a43);


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.create_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_rec,
      ddx_iipv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_iipv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_iipv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_iipv_rec.tas_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_iipv_rec.tal_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_iipv_rec.kle_id);
    p6_a5 := ddx_iipv_rec.tal_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_iipv_rec.line_number);
    p6_a7 := ddx_iipv_rec.instance_number_ib;
    p6_a8 := ddx_iipv_rec.object_id1_new;
    p6_a9 := ddx_iipv_rec.object_id2_new;
    p6_a10 := ddx_iipv_rec.jtot_object_code_new;
    p6_a11 := ddx_iipv_rec.object_id1_old;
    p6_a12 := ddx_iipv_rec.object_id2_old;
    p6_a13 := ddx_iipv_rec.jtot_object_code_old;
    p6_a14 := rosetta_g_miss_num_map(ddx_iipv_rec.inventory_org_id);
    p6_a15 := ddx_iipv_rec.serial_number;
    p6_a16 := ddx_iipv_rec.mfg_serial_number_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_iipv_rec.inventory_item_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_iipv_rec.inv_master_org_id);
    p6_a19 := ddx_iipv_rec.attribute_category;
    p6_a20 := ddx_iipv_rec.attribute1;
    p6_a21 := ddx_iipv_rec.attribute2;
    p6_a22 := ddx_iipv_rec.attribute3;
    p6_a23 := ddx_iipv_rec.attribute4;
    p6_a24 := ddx_iipv_rec.attribute5;
    p6_a25 := ddx_iipv_rec.attribute6;
    p6_a26 := ddx_iipv_rec.attribute7;
    p6_a27 := ddx_iipv_rec.attribute8;
    p6_a28 := ddx_iipv_rec.attribute9;
    p6_a29 := ddx_iipv_rec.attribute10;
    p6_a30 := ddx_iipv_rec.attribute11;
    p6_a31 := ddx_iipv_rec.attribute12;
    p6_a32 := ddx_iipv_rec.attribute13;
    p6_a33 := ddx_iipv_rec.attribute14;
    p6_a34 := ddx_iipv_rec.attribute15;
    p6_a35 := rosetta_g_miss_num_map(ddx_iipv_rec.created_by);
    p6_a36 := ddx_iipv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_iipv_rec.last_updated_by);
    p6_a38 := ddx_iipv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_iipv_rec.last_update_login);
    p6_a40 := rosetta_g_miss_num_map(ddx_iipv_rec.dnz_cle_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_iipv_rec.instance_id);
    p6_a42 := ddx_iipv_rec.selected_for_split_flag;
    p6_a43 := rosetta_g_miss_num_map(ddx_iipv_rec.asd_id);
  end;

  procedure create_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddx_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_iipv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.create_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_tbl,
      ddx_iipv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_iti_pvt_w.rosetta_table_copy_out_p5(ddx_iipv_tbl, p6_a0
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
      );
  end;

  procedure update_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddx_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iipv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_iipv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_iipv_rec.tas_id := rosetta_g_miss_num_map(p5_a2);
    ddp_iipv_rec.tal_id := rosetta_g_miss_num_map(p5_a3);
    ddp_iipv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_iipv_rec.tal_type := p5_a5;
    ddp_iipv_rec.line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_iipv_rec.instance_number_ib := p5_a7;
    ddp_iipv_rec.object_id1_new := p5_a8;
    ddp_iipv_rec.object_id2_new := p5_a9;
    ddp_iipv_rec.jtot_object_code_new := p5_a10;
    ddp_iipv_rec.object_id1_old := p5_a11;
    ddp_iipv_rec.object_id2_old := p5_a12;
    ddp_iipv_rec.jtot_object_code_old := p5_a13;
    ddp_iipv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_iipv_rec.serial_number := p5_a15;
    ddp_iipv_rec.mfg_serial_number_yn := p5_a16;
    ddp_iipv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a17);
    ddp_iipv_rec.inv_master_org_id := rosetta_g_miss_num_map(p5_a18);
    ddp_iipv_rec.attribute_category := p5_a19;
    ddp_iipv_rec.attribute1 := p5_a20;
    ddp_iipv_rec.attribute2 := p5_a21;
    ddp_iipv_rec.attribute3 := p5_a22;
    ddp_iipv_rec.attribute4 := p5_a23;
    ddp_iipv_rec.attribute5 := p5_a24;
    ddp_iipv_rec.attribute6 := p5_a25;
    ddp_iipv_rec.attribute7 := p5_a26;
    ddp_iipv_rec.attribute8 := p5_a27;
    ddp_iipv_rec.attribute9 := p5_a28;
    ddp_iipv_rec.attribute10 := p5_a29;
    ddp_iipv_rec.attribute11 := p5_a30;
    ddp_iipv_rec.attribute12 := p5_a31;
    ddp_iipv_rec.attribute13 := p5_a32;
    ddp_iipv_rec.attribute14 := p5_a33;
    ddp_iipv_rec.attribute15 := p5_a34;
    ddp_iipv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_iipv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_iipv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_iipv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_iipv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_iipv_rec.dnz_cle_id := rosetta_g_miss_num_map(p5_a40);
    ddp_iipv_rec.instance_id := rosetta_g_miss_num_map(p5_a41);
    ddp_iipv_rec.selected_for_split_flag := p5_a42;
    ddp_iipv_rec.asd_id := rosetta_g_miss_num_map(p5_a43);


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.update_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_rec,
      ddx_iipv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_iipv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_iipv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_iipv_rec.tas_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_iipv_rec.tal_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_iipv_rec.kle_id);
    p6_a5 := ddx_iipv_rec.tal_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_iipv_rec.line_number);
    p6_a7 := ddx_iipv_rec.instance_number_ib;
    p6_a8 := ddx_iipv_rec.object_id1_new;
    p6_a9 := ddx_iipv_rec.object_id2_new;
    p6_a10 := ddx_iipv_rec.jtot_object_code_new;
    p6_a11 := ddx_iipv_rec.object_id1_old;
    p6_a12 := ddx_iipv_rec.object_id2_old;
    p6_a13 := ddx_iipv_rec.jtot_object_code_old;
    p6_a14 := rosetta_g_miss_num_map(ddx_iipv_rec.inventory_org_id);
    p6_a15 := ddx_iipv_rec.serial_number;
    p6_a16 := ddx_iipv_rec.mfg_serial_number_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_iipv_rec.inventory_item_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_iipv_rec.inv_master_org_id);
    p6_a19 := ddx_iipv_rec.attribute_category;
    p6_a20 := ddx_iipv_rec.attribute1;
    p6_a21 := ddx_iipv_rec.attribute2;
    p6_a22 := ddx_iipv_rec.attribute3;
    p6_a23 := ddx_iipv_rec.attribute4;
    p6_a24 := ddx_iipv_rec.attribute5;
    p6_a25 := ddx_iipv_rec.attribute6;
    p6_a26 := ddx_iipv_rec.attribute7;
    p6_a27 := ddx_iipv_rec.attribute8;
    p6_a28 := ddx_iipv_rec.attribute9;
    p6_a29 := ddx_iipv_rec.attribute10;
    p6_a30 := ddx_iipv_rec.attribute11;
    p6_a31 := ddx_iipv_rec.attribute12;
    p6_a32 := ddx_iipv_rec.attribute13;
    p6_a33 := ddx_iipv_rec.attribute14;
    p6_a34 := ddx_iipv_rec.attribute15;
    p6_a35 := rosetta_g_miss_num_map(ddx_iipv_rec.created_by);
    p6_a36 := ddx_iipv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_iipv_rec.last_updated_by);
    p6_a38 := ddx_iipv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_iipv_rec.last_update_login);
    p6_a40 := rosetta_g_miss_num_map(ddx_iipv_rec.dnz_cle_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_iipv_rec.instance_id);
    p6_a42 := ddx_iipv_rec.selected_for_split_flag;
    p6_a43 := rosetta_g_miss_num_map(ddx_iipv_rec.asd_id);
  end;

  procedure update_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddx_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_iipv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.update_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_tbl,
      ddx_iipv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_iti_pvt_w.rosetta_table_copy_out_p5(ddx_iipv_tbl, p6_a0
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
      );
  end;

  procedure delete_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iipv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_iipv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_iipv_rec.tas_id := rosetta_g_miss_num_map(p5_a2);
    ddp_iipv_rec.tal_id := rosetta_g_miss_num_map(p5_a3);
    ddp_iipv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_iipv_rec.tal_type := p5_a5;
    ddp_iipv_rec.line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_iipv_rec.instance_number_ib := p5_a7;
    ddp_iipv_rec.object_id1_new := p5_a8;
    ddp_iipv_rec.object_id2_new := p5_a9;
    ddp_iipv_rec.jtot_object_code_new := p5_a10;
    ddp_iipv_rec.object_id1_old := p5_a11;
    ddp_iipv_rec.object_id2_old := p5_a12;
    ddp_iipv_rec.jtot_object_code_old := p5_a13;
    ddp_iipv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_iipv_rec.serial_number := p5_a15;
    ddp_iipv_rec.mfg_serial_number_yn := p5_a16;
    ddp_iipv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a17);
    ddp_iipv_rec.inv_master_org_id := rosetta_g_miss_num_map(p5_a18);
    ddp_iipv_rec.attribute_category := p5_a19;
    ddp_iipv_rec.attribute1 := p5_a20;
    ddp_iipv_rec.attribute2 := p5_a21;
    ddp_iipv_rec.attribute3 := p5_a22;
    ddp_iipv_rec.attribute4 := p5_a23;
    ddp_iipv_rec.attribute5 := p5_a24;
    ddp_iipv_rec.attribute6 := p5_a25;
    ddp_iipv_rec.attribute7 := p5_a26;
    ddp_iipv_rec.attribute8 := p5_a27;
    ddp_iipv_rec.attribute9 := p5_a28;
    ddp_iipv_rec.attribute10 := p5_a29;
    ddp_iipv_rec.attribute11 := p5_a30;
    ddp_iipv_rec.attribute12 := p5_a31;
    ddp_iipv_rec.attribute13 := p5_a32;
    ddp_iipv_rec.attribute14 := p5_a33;
    ddp_iipv_rec.attribute15 := p5_a34;
    ddp_iipv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_iipv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_iipv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_iipv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_iipv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_iipv_rec.dnz_cle_id := rosetta_g_miss_num_map(p5_a40);
    ddp_iipv_rec.instance_id := rosetta_g_miss_num_map(p5_a41);
    ddp_iipv_rec.selected_for_split_flag := p5_a42;
    ddp_iipv_rec.asd_id := rosetta_g_miss_num_map(p5_a43);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.delete_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
  )

  as
    ddp_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_iipv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.delete_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iipv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_iipv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_iipv_rec.tas_id := rosetta_g_miss_num_map(p5_a2);
    ddp_iipv_rec.tal_id := rosetta_g_miss_num_map(p5_a3);
    ddp_iipv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_iipv_rec.tal_type := p5_a5;
    ddp_iipv_rec.line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_iipv_rec.instance_number_ib := p5_a7;
    ddp_iipv_rec.object_id1_new := p5_a8;
    ddp_iipv_rec.object_id2_new := p5_a9;
    ddp_iipv_rec.jtot_object_code_new := p5_a10;
    ddp_iipv_rec.object_id1_old := p5_a11;
    ddp_iipv_rec.object_id2_old := p5_a12;
    ddp_iipv_rec.jtot_object_code_old := p5_a13;
    ddp_iipv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_iipv_rec.serial_number := p5_a15;
    ddp_iipv_rec.mfg_serial_number_yn := p5_a16;
    ddp_iipv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a17);
    ddp_iipv_rec.inv_master_org_id := rosetta_g_miss_num_map(p5_a18);
    ddp_iipv_rec.attribute_category := p5_a19;
    ddp_iipv_rec.attribute1 := p5_a20;
    ddp_iipv_rec.attribute2 := p5_a21;
    ddp_iipv_rec.attribute3 := p5_a22;
    ddp_iipv_rec.attribute4 := p5_a23;
    ddp_iipv_rec.attribute5 := p5_a24;
    ddp_iipv_rec.attribute6 := p5_a25;
    ddp_iipv_rec.attribute7 := p5_a26;
    ddp_iipv_rec.attribute8 := p5_a27;
    ddp_iipv_rec.attribute9 := p5_a28;
    ddp_iipv_rec.attribute10 := p5_a29;
    ddp_iipv_rec.attribute11 := p5_a30;
    ddp_iipv_rec.attribute12 := p5_a31;
    ddp_iipv_rec.attribute13 := p5_a32;
    ddp_iipv_rec.attribute14 := p5_a33;
    ddp_iipv_rec.attribute15 := p5_a34;
    ddp_iipv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_iipv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_iipv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_iipv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_iipv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_iipv_rec.dnz_cle_id := rosetta_g_miss_num_map(p5_a40);
    ddp_iipv_rec.instance_id := rosetta_g_miss_num_map(p5_a41);
    ddp_iipv_rec.selected_for_split_flag := p5_a42;
    ddp_iipv_rec.asd_id := rosetta_g_miss_num_map(p5_a43);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.lock_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
  )

  as
    ddp_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_iipv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.lock_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
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
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_iipv_rec okl_txl_itm_insts_pub.iipv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_iipv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_iipv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_iipv_rec.tas_id := rosetta_g_miss_num_map(p5_a2);
    ddp_iipv_rec.tal_id := rosetta_g_miss_num_map(p5_a3);
    ddp_iipv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_iipv_rec.tal_type := p5_a5;
    ddp_iipv_rec.line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_iipv_rec.instance_number_ib := p5_a7;
    ddp_iipv_rec.object_id1_new := p5_a8;
    ddp_iipv_rec.object_id2_new := p5_a9;
    ddp_iipv_rec.jtot_object_code_new := p5_a10;
    ddp_iipv_rec.object_id1_old := p5_a11;
    ddp_iipv_rec.object_id2_old := p5_a12;
    ddp_iipv_rec.jtot_object_code_old := p5_a13;
    ddp_iipv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_iipv_rec.serial_number := p5_a15;
    ddp_iipv_rec.mfg_serial_number_yn := p5_a16;
    ddp_iipv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a17);
    ddp_iipv_rec.inv_master_org_id := rosetta_g_miss_num_map(p5_a18);
    ddp_iipv_rec.attribute_category := p5_a19;
    ddp_iipv_rec.attribute1 := p5_a20;
    ddp_iipv_rec.attribute2 := p5_a21;
    ddp_iipv_rec.attribute3 := p5_a22;
    ddp_iipv_rec.attribute4 := p5_a23;
    ddp_iipv_rec.attribute5 := p5_a24;
    ddp_iipv_rec.attribute6 := p5_a25;
    ddp_iipv_rec.attribute7 := p5_a26;
    ddp_iipv_rec.attribute8 := p5_a27;
    ddp_iipv_rec.attribute9 := p5_a28;
    ddp_iipv_rec.attribute10 := p5_a29;
    ddp_iipv_rec.attribute11 := p5_a30;
    ddp_iipv_rec.attribute12 := p5_a31;
    ddp_iipv_rec.attribute13 := p5_a32;
    ddp_iipv_rec.attribute14 := p5_a33;
    ddp_iipv_rec.attribute15 := p5_a34;
    ddp_iipv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_iipv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_iipv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_iipv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_iipv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_iipv_rec.dnz_cle_id := rosetta_g_miss_num_map(p5_a40);
    ddp_iipv_rec.instance_id := rosetta_g_miss_num_map(p5_a41);
    ddp_iipv_rec.selected_for_split_flag := p5_a42;
    ddp_iipv_rec.asd_id := rosetta_g_miss_num_map(p5_a43);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.validate_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_txl_itm_insts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
  )

  as
    ddp_iipv_tbl okl_txl_itm_insts_pub.iipv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_iipv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_itm_insts_pub.validate_txl_itm_insts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_iipv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_txl_itm_insts_pub_w;

/
