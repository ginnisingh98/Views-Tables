--------------------------------------------------------
--  DDL for Package Body OKL_TXL_AR_INV_LNS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_AR_INV_LNS_PUB_W" as
  /* $Header: OKLUTWLB.pls 120.3 2007/07/20 09:43:54 akrangan ship $ */
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

  procedure insert_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddx_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl,
      ddx_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_til_pvt_w.rosetta_table_copy_out_p8(ddx_tilv_tbl, p6_a0
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
      );
  end;

  procedure insert_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddx_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec,
      ddx_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tilv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tilv_rec.object_version_number);
    p6_a2 := ddx_tilv_rec.error_message;
    p6_a3 := ddx_tilv_rec.sfwt_flag;
    p6_a4 := rosetta_g_miss_num_map(ddx_tilv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tilv_rec.tpl_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tilv_rec.til_id_reverses);
    p6_a7 := ddx_tilv_rec.inv_receiv_line_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_tilv_rec.sty_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tilv_rec.tai_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tilv_rec.acn_id_cost);
    p6_a11 := rosetta_g_miss_num_map(ddx_tilv_rec.amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_tilv_rec.line_number);
    p6_a13 := rosetta_g_miss_num_map(ddx_tilv_rec.quantity);
    p6_a14 := ddx_tilv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_tilv_rec.receivables_invoice_id);
    p6_a16 := ddx_tilv_rec.date_bill_period_start;
    p6_a17 := rosetta_g_miss_num_map(ddx_tilv_rec.amount_applied);
    p6_a18 := ddx_tilv_rec.date_bill_period_end;
    p6_a19 := rosetta_g_miss_num_map(ddx_tilv_rec.isl_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tilv_rec.ibt_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tilv_rec.late_charge_rec_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_tilv_rec.cll_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_item_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_tilv_rec.qte_line_id);
    p6_a25 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_tilv_rec.bank_acct_id);
    p6_a27 := ddx_tilv_rec.attribute_category;
    p6_a28 := ddx_tilv_rec.attribute1;
    p6_a29 := ddx_tilv_rec.attribute2;
    p6_a30 := ddx_tilv_rec.attribute3;
    p6_a31 := ddx_tilv_rec.attribute4;
    p6_a32 := ddx_tilv_rec.attribute5;
    p6_a33 := ddx_tilv_rec.attribute6;
    p6_a34 := ddx_tilv_rec.attribute7;
    p6_a35 := ddx_tilv_rec.attribute8;
    p6_a36 := ddx_tilv_rec.attribute9;
    p6_a37 := ddx_tilv_rec.attribute10;
    p6_a38 := ddx_tilv_rec.attribute11;
    p6_a39 := ddx_tilv_rec.attribute12;
    p6_a40 := ddx_tilv_rec.attribute13;
    p6_a41 := ddx_tilv_rec.attribute14;
    p6_a42 := ddx_tilv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_tilv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tilv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tilv_rec.program_id);
    p6_a46 := ddx_tilv_rec.program_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_tilv_rec.org_id);
    p6_a48 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_org_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_tilv_rec.created_by);
    p6_a50 := ddx_tilv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tilv_rec.last_updated_by);
    p6_a52 := ddx_tilv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tilv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tilv_rec.txl_ar_line_number);
    p6_a55 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_line_id);
  end;

  procedure lock_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.lock_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.lock_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddx_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.update_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl,
      ddx_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_til_pvt_w.rosetta_table_copy_out_p8(ddx_tilv_tbl, p6_a0
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
      );
  end;

  procedure update_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddx_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.update_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec,
      ddx_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tilv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tilv_rec.object_version_number);
    p6_a2 := ddx_tilv_rec.error_message;
    p6_a3 := ddx_tilv_rec.sfwt_flag;
    p6_a4 := rosetta_g_miss_num_map(ddx_tilv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tilv_rec.tpl_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tilv_rec.til_id_reverses);
    p6_a7 := ddx_tilv_rec.inv_receiv_line_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_tilv_rec.sty_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tilv_rec.tai_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tilv_rec.acn_id_cost);
    p6_a11 := rosetta_g_miss_num_map(ddx_tilv_rec.amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_tilv_rec.line_number);
    p6_a13 := rosetta_g_miss_num_map(ddx_tilv_rec.quantity);
    p6_a14 := ddx_tilv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_tilv_rec.receivables_invoice_id);
    p6_a16 := ddx_tilv_rec.date_bill_period_start;
    p6_a17 := rosetta_g_miss_num_map(ddx_tilv_rec.amount_applied);
    p6_a18 := ddx_tilv_rec.date_bill_period_end;
    p6_a19 := rosetta_g_miss_num_map(ddx_tilv_rec.isl_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tilv_rec.ibt_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tilv_rec.late_charge_rec_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_tilv_rec.cll_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_item_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_tilv_rec.qte_line_id);
    p6_a25 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_tilv_rec.bank_acct_id);
    p6_a27 := ddx_tilv_rec.attribute_category;
    p6_a28 := ddx_tilv_rec.attribute1;
    p6_a29 := ddx_tilv_rec.attribute2;
    p6_a30 := ddx_tilv_rec.attribute3;
    p6_a31 := ddx_tilv_rec.attribute4;
    p6_a32 := ddx_tilv_rec.attribute5;
    p6_a33 := ddx_tilv_rec.attribute6;
    p6_a34 := ddx_tilv_rec.attribute7;
    p6_a35 := ddx_tilv_rec.attribute8;
    p6_a36 := ddx_tilv_rec.attribute9;
    p6_a37 := ddx_tilv_rec.attribute10;
    p6_a38 := ddx_tilv_rec.attribute11;
    p6_a39 := ddx_tilv_rec.attribute12;
    p6_a40 := ddx_tilv_rec.attribute13;
    p6_a41 := ddx_tilv_rec.attribute14;
    p6_a42 := ddx_tilv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_tilv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tilv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tilv_rec.program_id);
    p6_a46 := ddx_tilv_rec.program_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_tilv_rec.org_id);
    p6_a48 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_org_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_tilv_rec.created_by);
    p6_a50 := ddx_tilv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tilv_rec.last_updated_by);
    p6_a52 := ddx_tilv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tilv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tilv_rec.txl_ar_line_number);
    p6_a55 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_line_id);
  end;

  procedure delete_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.delete_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.delete_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.validate_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_txl_ar_inv_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_txl_ar_inv_lns_pub.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_ar_inv_lns_pub.validate_txl_ar_inv_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_txl_ar_inv_lns_pub_w;

/
