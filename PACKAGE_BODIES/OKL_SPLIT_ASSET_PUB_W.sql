--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_ASSET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_ASSET_PUB_W" as
  /* $Header: OKLUSPAB.pls 115.9 2004/02/17 22:57:28 avsingh noship $ */
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

  procedure create_split_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p_split_into_individuals_yn  VARCHAR2
    , p_split_into_units  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_NUMBER_TABLE
    , p9_a34 out nocopy JTF_DATE_TABLE
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , p9_a36 out nocopy JTF_DATE_TABLE
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_DATE_TABLE
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  NUMBER
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  NUMBER
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  NUMBER
    , p10_a20 out nocopy  NUMBER
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  DATE
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  DATE
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  NUMBER
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  NUMBER
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  NUMBER
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  VARCHAR2
    , p10_a43 out nocopy  VARCHAR2
    , p10_a44 out nocopy  VARCHAR2
    , p10_a45 out nocopy  VARCHAR2
    , p10_a46 out nocopy  VARCHAR2
    , p10_a47 out nocopy  VARCHAR2
    , p10_a48 out nocopy  VARCHAR2
    , p10_a49 out nocopy  VARCHAR2
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  DATE
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  DATE
    , p10_a55 out nocopy  NUMBER
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  NUMBER
    , p10_a58 out nocopy  NUMBER
    , p10_a59 out nocopy  NUMBER
    , p10_a60 out nocopy  NUMBER
    , p10_a61 out nocopy  NUMBER
    , p10_a62 out nocopy  NUMBER
    , p10_a63 out nocopy  NUMBER
    , p10_a64 out nocopy  NUMBER
    , p10_a65 out nocopy  NUMBER
    , p10_a66 out nocopy  DATE
    , p10_a67 out nocopy  NUMBER
    , p10_a68 out nocopy  NUMBER
    , p10_a69 out nocopy  NUMBER
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  NUMBER
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  NUMBER
    , p10_a75 out nocopy  DATE
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  VARCHAR2
    , p11_a6 out nocopy  VARCHAR2
    , p11_a7 out nocopy  VARCHAR2
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  VARCHAR2
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  VARCHAR2
    , p11_a18 out nocopy  VARCHAR2
    , p11_a19 out nocopy  VARCHAR2
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  DATE
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  NUMBER
    , p11_a27 out nocopy  DATE
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  VARCHAR2
    , p11_a30 out nocopy  NUMBER
    , p11_a31 out nocopy  NUMBER
    , p11_a32 out nocopy  NUMBER
  )

  as
    ddp_ib_tbl okl_split_asset_pub.ib_tbl_type;
    ddx_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddx_txlv_rec okl_split_asset_pub.txlv_rec_type;
    ddx_trxv_rec okl_split_asset_pub.trxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_split_asset_pvt_w.rosetta_table_copy_in_p13(ddp_ib_tbl, p8_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.create_split_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      p_split_into_individuals_yn,
      p_split_into_units,
      ddp_ib_tbl,
      ddx_txdv_tbl,
      ddx_txlv_rec,
      ddx_trxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p9_a0
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
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      );

    p10_a0 := rosetta_g_miss_num_map(ddx_txlv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_txlv_rec.object_version_number);
    p10_a2 := ddx_txlv_rec.sfwt_flag;
    p10_a3 := rosetta_g_miss_num_map(ddx_txlv_rec.tas_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id);
    p10_a5 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id_old);
    p10_a6 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id);
    p10_a7 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id_new);
    p10_a8 := rosetta_g_miss_num_map(ddx_txlv_rec.kle_id);
    p10_a9 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_khr_id);
    p10_a10 := rosetta_g_miss_num_map(ddx_txlv_rec.line_number);
    p10_a11 := rosetta_g_miss_num_map(ddx_txlv_rec.org_id);
    p10_a12 := ddx_txlv_rec.tal_type;
    p10_a13 := ddx_txlv_rec.asset_number;
    p10_a14 := ddx_txlv_rec.description;
    p10_a15 := rosetta_g_miss_num_map(ddx_txlv_rec.fa_location_id);
    p10_a16 := rosetta_g_miss_num_map(ddx_txlv_rec.original_cost);
    p10_a17 := rosetta_g_miss_num_map(ddx_txlv_rec.current_units);
    p10_a18 := ddx_txlv_rec.manufacturer_name;
    p10_a19 := rosetta_g_miss_num_map(ddx_txlv_rec.year_manufactured);
    p10_a20 := rosetta_g_miss_num_map(ddx_txlv_rec.supplier_id);
    p10_a21 := ddx_txlv_rec.used_asset_yn;
    p10_a22 := ddx_txlv_rec.tag_number;
    p10_a23 := ddx_txlv_rec.model_number;
    p10_a24 := ddx_txlv_rec.corporate_book;
    p10_a25 := ddx_txlv_rec.date_purchased;
    p10_a26 := ddx_txlv_rec.date_delivery;
    p10_a27 := ddx_txlv_rec.in_service_date;
    p10_a28 := rosetta_g_miss_num_map(ddx_txlv_rec.life_in_months);
    p10_a29 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_id);
    p10_a30 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_cost);
    p10_a31 := ddx_txlv_rec.deprn_method;
    p10_a32 := rosetta_g_miss_num_map(ddx_txlv_rec.deprn_rate);
    p10_a33 := rosetta_g_miss_num_map(ddx_txlv_rec.salvage_value);
    p10_a34 := rosetta_g_miss_num_map(ddx_txlv_rec.percent_salvage_value);
    p10_a35 := ddx_txlv_rec.attribute_category;
    p10_a36 := ddx_txlv_rec.attribute1;
    p10_a37 := ddx_txlv_rec.attribute2;
    p10_a38 := ddx_txlv_rec.attribute3;
    p10_a39 := ddx_txlv_rec.attribute4;
    p10_a40 := ddx_txlv_rec.attribute5;
    p10_a41 := ddx_txlv_rec.attribute6;
    p10_a42 := ddx_txlv_rec.attribute7;
    p10_a43 := ddx_txlv_rec.attribute8;
    p10_a44 := ddx_txlv_rec.attribute9;
    p10_a45 := ddx_txlv_rec.attribute10;
    p10_a46 := ddx_txlv_rec.attribute11;
    p10_a47 := ddx_txlv_rec.attribute12;
    p10_a48 := ddx_txlv_rec.attribute13;
    p10_a49 := ddx_txlv_rec.attribute14;
    p10_a50 := ddx_txlv_rec.attribute15;
    p10_a51 := rosetta_g_miss_num_map(ddx_txlv_rec.created_by);
    p10_a52 := ddx_txlv_rec.creation_date;
    p10_a53 := rosetta_g_miss_num_map(ddx_txlv_rec.last_updated_by);
    p10_a54 := ddx_txlv_rec.last_update_date;
    p10_a55 := rosetta_g_miss_num_map(ddx_txlv_rec.last_update_login);
    p10_a56 := ddx_txlv_rec.depreciate_yn;
    p10_a57 := rosetta_g_miss_num_map(ddx_txlv_rec.hold_period_days);
    p10_a58 := rosetta_g_miss_num_map(ddx_txlv_rec.old_salvage_value);
    p10_a59 := rosetta_g_miss_num_map(ddx_txlv_rec.new_residual_value);
    p10_a60 := rosetta_g_miss_num_map(ddx_txlv_rec.old_residual_value);
    p10_a61 := rosetta_g_miss_num_map(ddx_txlv_rec.units_retired);
    p10_a62 := rosetta_g_miss_num_map(ddx_txlv_rec.cost_retired);
    p10_a63 := rosetta_g_miss_num_map(ddx_txlv_rec.sale_proceeds);
    p10_a64 := rosetta_g_miss_num_map(ddx_txlv_rec.removal_cost);
    p10_a65 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_asset_id);
    p10_a66 := ddx_txlv_rec.date_due;
    p10_a67 := rosetta_g_miss_num_map(ddx_txlv_rec.rep_asset_id);
    p10_a68 := rosetta_g_miss_num_map(ddx_txlv_rec.lke_asset_id);
    p10_a69 := rosetta_g_miss_num_map(ddx_txlv_rec.match_amount);
    p10_a70 := ddx_txlv_rec.split_into_singles_flag;
    p10_a71 := rosetta_g_miss_num_map(ddx_txlv_rec.split_into_units);
    p10_a72 := ddx_txlv_rec.currency_code;
    p10_a73 := ddx_txlv_rec.currency_conversion_type;
    p10_a74 := rosetta_g_miss_num_map(ddx_txlv_rec.currency_conversion_rate);
    p10_a75 := ddx_txlv_rec.currency_conversion_date;

    p11_a0 := rosetta_g_miss_num_map(ddx_trxv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_trxv_rec.object_version_number);
    p11_a2 := rosetta_g_miss_num_map(ddx_trxv_rec.ica_id);
    p11_a3 := ddx_trxv_rec.attribute_category;
    p11_a4 := ddx_trxv_rec.attribute1;
    p11_a5 := ddx_trxv_rec.attribute2;
    p11_a6 := ddx_trxv_rec.attribute3;
    p11_a7 := ddx_trxv_rec.attribute4;
    p11_a8 := ddx_trxv_rec.attribute5;
    p11_a9 := ddx_trxv_rec.attribute6;
    p11_a10 := ddx_trxv_rec.attribute7;
    p11_a11 := ddx_trxv_rec.attribute8;
    p11_a12 := ddx_trxv_rec.attribute9;
    p11_a13 := ddx_trxv_rec.attribute10;
    p11_a14 := ddx_trxv_rec.attribute11;
    p11_a15 := ddx_trxv_rec.attribute12;
    p11_a16 := ddx_trxv_rec.attribute13;
    p11_a17 := ddx_trxv_rec.attribute14;
    p11_a18 := ddx_trxv_rec.attribute15;
    p11_a19 := ddx_trxv_rec.tas_type;
    p11_a20 := rosetta_g_miss_num_map(ddx_trxv_rec.created_by);
    p11_a21 := ddx_trxv_rec.creation_date;
    p11_a22 := rosetta_g_miss_num_map(ddx_trxv_rec.last_updated_by);
    p11_a23 := ddx_trxv_rec.last_update_date;
    p11_a24 := rosetta_g_miss_num_map(ddx_trxv_rec.last_update_login);
    p11_a25 := ddx_trxv_rec.tsu_code;
    p11_a26 := rosetta_g_miss_num_map(ddx_trxv_rec.try_id);
    p11_a27 := ddx_trxv_rec.date_trans_occurred;
    p11_a28 := rosetta_g_miss_num_map(ddx_trxv_rec.trans_number);
    p11_a29 := ddx_trxv_rec.comments;
    p11_a30 := rosetta_g_miss_num_map(ddx_trxv_rec.req_asset_id);
    p11_a31 := rosetta_g_miss_num_map(ddx_trxv_rec.total_match_amount);
    p11_a32 := rosetta_g_miss_num_map(ddx_trxv_rec.org_id);
  end;

  procedure create_split_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p_split_into_individuals_yn  VARCHAR2
    , p_split_into_units  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_DATE_TABLE
    , p8_a37 out nocopy JTF_NUMBER_TABLE
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_DATE_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  NUMBER
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  NUMBER
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  NUMBER
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  DATE
    , p9_a28 out nocopy  NUMBER
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  VARCHAR2
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  NUMBER
    , p9_a34 out nocopy  NUMBER
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  VARCHAR2
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  VARCHAR2
    , p9_a40 out nocopy  VARCHAR2
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  VARCHAR2
    , p9_a43 out nocopy  VARCHAR2
    , p9_a44 out nocopy  VARCHAR2
    , p9_a45 out nocopy  VARCHAR2
    , p9_a46 out nocopy  VARCHAR2
    , p9_a47 out nocopy  VARCHAR2
    , p9_a48 out nocopy  VARCHAR2
    , p9_a49 out nocopy  VARCHAR2
    , p9_a50 out nocopy  VARCHAR2
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  DATE
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  DATE
    , p9_a55 out nocopy  NUMBER
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  NUMBER
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  NUMBER
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  NUMBER
    , p9_a63 out nocopy  NUMBER
    , p9_a64 out nocopy  NUMBER
    , p9_a65 out nocopy  NUMBER
    , p9_a66 out nocopy  DATE
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  NUMBER
    , p9_a69 out nocopy  NUMBER
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  NUMBER
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  NUMBER
    , p9_a75 out nocopy  DATE
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  NUMBER
    , p10_a21 out nocopy  DATE
    , p10_a22 out nocopy  NUMBER
    , p10_a23 out nocopy  DATE
    , p10_a24 out nocopy  NUMBER
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  NUMBER
    , p10_a27 out nocopy  DATE
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  NUMBER
    , p10_a32 out nocopy  NUMBER
  )

  as
    ddx_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddx_txlv_rec okl_split_asset_pub.txlv_rec_type;
    ddx_trxv_rec okl_split_asset_pub.trxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.create_split_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      p_split_into_individuals_yn,
      p_split_into_units,
      ddx_txdv_tbl,
      ddx_txlv_rec,
      ddx_trxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      );

    p9_a0 := rosetta_g_miss_num_map(ddx_txlv_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_txlv_rec.object_version_number);
    p9_a2 := ddx_txlv_rec.sfwt_flag;
    p9_a3 := rosetta_g_miss_num_map(ddx_txlv_rec.tas_id);
    p9_a4 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id);
    p9_a5 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id_old);
    p9_a6 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id);
    p9_a7 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id_new);
    p9_a8 := rosetta_g_miss_num_map(ddx_txlv_rec.kle_id);
    p9_a9 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_khr_id);
    p9_a10 := rosetta_g_miss_num_map(ddx_txlv_rec.line_number);
    p9_a11 := rosetta_g_miss_num_map(ddx_txlv_rec.org_id);
    p9_a12 := ddx_txlv_rec.tal_type;
    p9_a13 := ddx_txlv_rec.asset_number;
    p9_a14 := ddx_txlv_rec.description;
    p9_a15 := rosetta_g_miss_num_map(ddx_txlv_rec.fa_location_id);
    p9_a16 := rosetta_g_miss_num_map(ddx_txlv_rec.original_cost);
    p9_a17 := rosetta_g_miss_num_map(ddx_txlv_rec.current_units);
    p9_a18 := ddx_txlv_rec.manufacturer_name;
    p9_a19 := rosetta_g_miss_num_map(ddx_txlv_rec.year_manufactured);
    p9_a20 := rosetta_g_miss_num_map(ddx_txlv_rec.supplier_id);
    p9_a21 := ddx_txlv_rec.used_asset_yn;
    p9_a22 := ddx_txlv_rec.tag_number;
    p9_a23 := ddx_txlv_rec.model_number;
    p9_a24 := ddx_txlv_rec.corporate_book;
    p9_a25 := ddx_txlv_rec.date_purchased;
    p9_a26 := ddx_txlv_rec.date_delivery;
    p9_a27 := ddx_txlv_rec.in_service_date;
    p9_a28 := rosetta_g_miss_num_map(ddx_txlv_rec.life_in_months);
    p9_a29 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_id);
    p9_a30 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_cost);
    p9_a31 := ddx_txlv_rec.deprn_method;
    p9_a32 := rosetta_g_miss_num_map(ddx_txlv_rec.deprn_rate);
    p9_a33 := rosetta_g_miss_num_map(ddx_txlv_rec.salvage_value);
    p9_a34 := rosetta_g_miss_num_map(ddx_txlv_rec.percent_salvage_value);
    p9_a35 := ddx_txlv_rec.attribute_category;
    p9_a36 := ddx_txlv_rec.attribute1;
    p9_a37 := ddx_txlv_rec.attribute2;
    p9_a38 := ddx_txlv_rec.attribute3;
    p9_a39 := ddx_txlv_rec.attribute4;
    p9_a40 := ddx_txlv_rec.attribute5;
    p9_a41 := ddx_txlv_rec.attribute6;
    p9_a42 := ddx_txlv_rec.attribute7;
    p9_a43 := ddx_txlv_rec.attribute8;
    p9_a44 := ddx_txlv_rec.attribute9;
    p9_a45 := ddx_txlv_rec.attribute10;
    p9_a46 := ddx_txlv_rec.attribute11;
    p9_a47 := ddx_txlv_rec.attribute12;
    p9_a48 := ddx_txlv_rec.attribute13;
    p9_a49 := ddx_txlv_rec.attribute14;
    p9_a50 := ddx_txlv_rec.attribute15;
    p9_a51 := rosetta_g_miss_num_map(ddx_txlv_rec.created_by);
    p9_a52 := ddx_txlv_rec.creation_date;
    p9_a53 := rosetta_g_miss_num_map(ddx_txlv_rec.last_updated_by);
    p9_a54 := ddx_txlv_rec.last_update_date;
    p9_a55 := rosetta_g_miss_num_map(ddx_txlv_rec.last_update_login);
    p9_a56 := ddx_txlv_rec.depreciate_yn;
    p9_a57 := rosetta_g_miss_num_map(ddx_txlv_rec.hold_period_days);
    p9_a58 := rosetta_g_miss_num_map(ddx_txlv_rec.old_salvage_value);
    p9_a59 := rosetta_g_miss_num_map(ddx_txlv_rec.new_residual_value);
    p9_a60 := rosetta_g_miss_num_map(ddx_txlv_rec.old_residual_value);
    p9_a61 := rosetta_g_miss_num_map(ddx_txlv_rec.units_retired);
    p9_a62 := rosetta_g_miss_num_map(ddx_txlv_rec.cost_retired);
    p9_a63 := rosetta_g_miss_num_map(ddx_txlv_rec.sale_proceeds);
    p9_a64 := rosetta_g_miss_num_map(ddx_txlv_rec.removal_cost);
    p9_a65 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_asset_id);
    p9_a66 := ddx_txlv_rec.date_due;
    p9_a67 := rosetta_g_miss_num_map(ddx_txlv_rec.rep_asset_id);
    p9_a68 := rosetta_g_miss_num_map(ddx_txlv_rec.lke_asset_id);
    p9_a69 := rosetta_g_miss_num_map(ddx_txlv_rec.match_amount);
    p9_a70 := ddx_txlv_rec.split_into_singles_flag;
    p9_a71 := rosetta_g_miss_num_map(ddx_txlv_rec.split_into_units);
    p9_a72 := ddx_txlv_rec.currency_code;
    p9_a73 := ddx_txlv_rec.currency_conversion_type;
    p9_a74 := rosetta_g_miss_num_map(ddx_txlv_rec.currency_conversion_rate);
    p9_a75 := ddx_txlv_rec.currency_conversion_date;

    p10_a0 := rosetta_g_miss_num_map(ddx_trxv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_trxv_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_trxv_rec.ica_id);
    p10_a3 := ddx_trxv_rec.attribute_category;
    p10_a4 := ddx_trxv_rec.attribute1;
    p10_a5 := ddx_trxv_rec.attribute2;
    p10_a6 := ddx_trxv_rec.attribute3;
    p10_a7 := ddx_trxv_rec.attribute4;
    p10_a8 := ddx_trxv_rec.attribute5;
    p10_a9 := ddx_trxv_rec.attribute6;
    p10_a10 := ddx_trxv_rec.attribute7;
    p10_a11 := ddx_trxv_rec.attribute8;
    p10_a12 := ddx_trxv_rec.attribute9;
    p10_a13 := ddx_trxv_rec.attribute10;
    p10_a14 := ddx_trxv_rec.attribute11;
    p10_a15 := ddx_trxv_rec.attribute12;
    p10_a16 := ddx_trxv_rec.attribute13;
    p10_a17 := ddx_trxv_rec.attribute14;
    p10_a18 := ddx_trxv_rec.attribute15;
    p10_a19 := ddx_trxv_rec.tas_type;
    p10_a20 := rosetta_g_miss_num_map(ddx_trxv_rec.created_by);
    p10_a21 := ddx_trxv_rec.creation_date;
    p10_a22 := rosetta_g_miss_num_map(ddx_trxv_rec.last_updated_by);
    p10_a23 := ddx_trxv_rec.last_update_date;
    p10_a24 := rosetta_g_miss_num_map(ddx_trxv_rec.last_update_login);
    p10_a25 := ddx_trxv_rec.tsu_code;
    p10_a26 := rosetta_g_miss_num_map(ddx_trxv_rec.try_id);
    p10_a27 := ddx_trxv_rec.date_trans_occurred;
    p10_a28 := rosetta_g_miss_num_map(ddx_trxv_rec.trans_number);
    p10_a29 := ddx_trxv_rec.comments;
    p10_a30 := rosetta_g_miss_num_map(ddx_trxv_rec.req_asset_id);
    p10_a31 := rosetta_g_miss_num_map(ddx_trxv_rec.total_match_amount);
    p10_a32 := rosetta_g_miss_num_map(ddx_trxv_rec.org_id);
  end;

  procedure create_split_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p_split_into_individuals_yn  VARCHAR2
    , p_split_into_units  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p_trx_date  date
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_NUMBER_TABLE
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_NUMBER_TABLE
    , p10_a34 out nocopy JTF_DATE_TABLE
    , p10_a35 out nocopy JTF_NUMBER_TABLE
    , p10_a36 out nocopy JTF_DATE_TABLE
    , p10_a37 out nocopy JTF_NUMBER_TABLE
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_DATE_TABLE
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  VARCHAR2
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  VARCHAR2
    , p11_a22 out nocopy  VARCHAR2
    , p11_a23 out nocopy  VARCHAR2
    , p11_a24 out nocopy  VARCHAR2
    , p11_a25 out nocopy  DATE
    , p11_a26 out nocopy  DATE
    , p11_a27 out nocopy  DATE
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  NUMBER
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  NUMBER
    , p11_a33 out nocopy  NUMBER
    , p11_a34 out nocopy  NUMBER
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  VARCHAR2
    , p11_a44 out nocopy  VARCHAR2
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  VARCHAR2
    , p11_a47 out nocopy  VARCHAR2
    , p11_a48 out nocopy  VARCHAR2
    , p11_a49 out nocopy  VARCHAR2
    , p11_a50 out nocopy  VARCHAR2
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  DATE
    , p11_a53 out nocopy  NUMBER
    , p11_a54 out nocopy  DATE
    , p11_a55 out nocopy  NUMBER
    , p11_a56 out nocopy  VARCHAR2
    , p11_a57 out nocopy  NUMBER
    , p11_a58 out nocopy  NUMBER
    , p11_a59 out nocopy  NUMBER
    , p11_a60 out nocopy  NUMBER
    , p11_a61 out nocopy  NUMBER
    , p11_a62 out nocopy  NUMBER
    , p11_a63 out nocopy  NUMBER
    , p11_a64 out nocopy  NUMBER
    , p11_a65 out nocopy  NUMBER
    , p11_a66 out nocopy  DATE
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  NUMBER
    , p11_a69 out nocopy  NUMBER
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  NUMBER
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  VARCHAR2
    , p11_a74 out nocopy  NUMBER
    , p11_a75 out nocopy  DATE
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  NUMBER
    , p12_a3 out nocopy  VARCHAR2
    , p12_a4 out nocopy  VARCHAR2
    , p12_a5 out nocopy  VARCHAR2
    , p12_a6 out nocopy  VARCHAR2
    , p12_a7 out nocopy  VARCHAR2
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  VARCHAR2
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  DATE
    , p12_a22 out nocopy  NUMBER
    , p12_a23 out nocopy  DATE
    , p12_a24 out nocopy  NUMBER
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  NUMBER
    , p12_a27 out nocopy  DATE
    , p12_a28 out nocopy  NUMBER
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  NUMBER
    , p12_a31 out nocopy  NUMBER
    , p12_a32 out nocopy  NUMBER
  )

  as
    ddp_ib_tbl okl_split_asset_pub.ib_tbl_type;
    ddp_trx_date date;
    ddx_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddx_txlv_rec okl_split_asset_pub.txlv_rec_type;
    ddx_trxv_rec okl_split_asset_pub.trxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okl_split_asset_pvt_w.rosetta_table_copy_in_p13(ddp_ib_tbl, p8_a0
      );

    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.create_split_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      p_split_into_individuals_yn,
      p_split_into_units,
      ddp_ib_tbl,
      ddp_trx_date,
      ddx_txdv_tbl,
      ddx_txlv_rec,
      ddx_trxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p10_a0
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
      );

    p11_a0 := rosetta_g_miss_num_map(ddx_txlv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_txlv_rec.object_version_number);
    p11_a2 := ddx_txlv_rec.sfwt_flag;
    p11_a3 := rosetta_g_miss_num_map(ddx_txlv_rec.tas_id);
    p11_a4 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id);
    p11_a5 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id_old);
    p11_a6 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id);
    p11_a7 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id_new);
    p11_a8 := rosetta_g_miss_num_map(ddx_txlv_rec.kle_id);
    p11_a9 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_khr_id);
    p11_a10 := rosetta_g_miss_num_map(ddx_txlv_rec.line_number);
    p11_a11 := rosetta_g_miss_num_map(ddx_txlv_rec.org_id);
    p11_a12 := ddx_txlv_rec.tal_type;
    p11_a13 := ddx_txlv_rec.asset_number;
    p11_a14 := ddx_txlv_rec.description;
    p11_a15 := rosetta_g_miss_num_map(ddx_txlv_rec.fa_location_id);
    p11_a16 := rosetta_g_miss_num_map(ddx_txlv_rec.original_cost);
    p11_a17 := rosetta_g_miss_num_map(ddx_txlv_rec.current_units);
    p11_a18 := ddx_txlv_rec.manufacturer_name;
    p11_a19 := rosetta_g_miss_num_map(ddx_txlv_rec.year_manufactured);
    p11_a20 := rosetta_g_miss_num_map(ddx_txlv_rec.supplier_id);
    p11_a21 := ddx_txlv_rec.used_asset_yn;
    p11_a22 := ddx_txlv_rec.tag_number;
    p11_a23 := ddx_txlv_rec.model_number;
    p11_a24 := ddx_txlv_rec.corporate_book;
    p11_a25 := ddx_txlv_rec.date_purchased;
    p11_a26 := ddx_txlv_rec.date_delivery;
    p11_a27 := ddx_txlv_rec.in_service_date;
    p11_a28 := rosetta_g_miss_num_map(ddx_txlv_rec.life_in_months);
    p11_a29 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_id);
    p11_a30 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_cost);
    p11_a31 := ddx_txlv_rec.deprn_method;
    p11_a32 := rosetta_g_miss_num_map(ddx_txlv_rec.deprn_rate);
    p11_a33 := rosetta_g_miss_num_map(ddx_txlv_rec.salvage_value);
    p11_a34 := rosetta_g_miss_num_map(ddx_txlv_rec.percent_salvage_value);
    p11_a35 := ddx_txlv_rec.attribute_category;
    p11_a36 := ddx_txlv_rec.attribute1;
    p11_a37 := ddx_txlv_rec.attribute2;
    p11_a38 := ddx_txlv_rec.attribute3;
    p11_a39 := ddx_txlv_rec.attribute4;
    p11_a40 := ddx_txlv_rec.attribute5;
    p11_a41 := ddx_txlv_rec.attribute6;
    p11_a42 := ddx_txlv_rec.attribute7;
    p11_a43 := ddx_txlv_rec.attribute8;
    p11_a44 := ddx_txlv_rec.attribute9;
    p11_a45 := ddx_txlv_rec.attribute10;
    p11_a46 := ddx_txlv_rec.attribute11;
    p11_a47 := ddx_txlv_rec.attribute12;
    p11_a48 := ddx_txlv_rec.attribute13;
    p11_a49 := ddx_txlv_rec.attribute14;
    p11_a50 := ddx_txlv_rec.attribute15;
    p11_a51 := rosetta_g_miss_num_map(ddx_txlv_rec.created_by);
    p11_a52 := ddx_txlv_rec.creation_date;
    p11_a53 := rosetta_g_miss_num_map(ddx_txlv_rec.last_updated_by);
    p11_a54 := ddx_txlv_rec.last_update_date;
    p11_a55 := rosetta_g_miss_num_map(ddx_txlv_rec.last_update_login);
    p11_a56 := ddx_txlv_rec.depreciate_yn;
    p11_a57 := rosetta_g_miss_num_map(ddx_txlv_rec.hold_period_days);
    p11_a58 := rosetta_g_miss_num_map(ddx_txlv_rec.old_salvage_value);
    p11_a59 := rosetta_g_miss_num_map(ddx_txlv_rec.new_residual_value);
    p11_a60 := rosetta_g_miss_num_map(ddx_txlv_rec.old_residual_value);
    p11_a61 := rosetta_g_miss_num_map(ddx_txlv_rec.units_retired);
    p11_a62 := rosetta_g_miss_num_map(ddx_txlv_rec.cost_retired);
    p11_a63 := rosetta_g_miss_num_map(ddx_txlv_rec.sale_proceeds);
    p11_a64 := rosetta_g_miss_num_map(ddx_txlv_rec.removal_cost);
    p11_a65 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_asset_id);
    p11_a66 := ddx_txlv_rec.date_due;
    p11_a67 := rosetta_g_miss_num_map(ddx_txlv_rec.rep_asset_id);
    p11_a68 := rosetta_g_miss_num_map(ddx_txlv_rec.lke_asset_id);
    p11_a69 := rosetta_g_miss_num_map(ddx_txlv_rec.match_amount);
    p11_a70 := ddx_txlv_rec.split_into_singles_flag;
    p11_a71 := rosetta_g_miss_num_map(ddx_txlv_rec.split_into_units);
    p11_a72 := ddx_txlv_rec.currency_code;
    p11_a73 := ddx_txlv_rec.currency_conversion_type;
    p11_a74 := rosetta_g_miss_num_map(ddx_txlv_rec.currency_conversion_rate);
    p11_a75 := ddx_txlv_rec.currency_conversion_date;

    p12_a0 := rosetta_g_miss_num_map(ddx_trxv_rec.id);
    p12_a1 := rosetta_g_miss_num_map(ddx_trxv_rec.object_version_number);
    p12_a2 := rosetta_g_miss_num_map(ddx_trxv_rec.ica_id);
    p12_a3 := ddx_trxv_rec.attribute_category;
    p12_a4 := ddx_trxv_rec.attribute1;
    p12_a5 := ddx_trxv_rec.attribute2;
    p12_a6 := ddx_trxv_rec.attribute3;
    p12_a7 := ddx_trxv_rec.attribute4;
    p12_a8 := ddx_trxv_rec.attribute5;
    p12_a9 := ddx_trxv_rec.attribute6;
    p12_a10 := ddx_trxv_rec.attribute7;
    p12_a11 := ddx_trxv_rec.attribute8;
    p12_a12 := ddx_trxv_rec.attribute9;
    p12_a13 := ddx_trxv_rec.attribute10;
    p12_a14 := ddx_trxv_rec.attribute11;
    p12_a15 := ddx_trxv_rec.attribute12;
    p12_a16 := ddx_trxv_rec.attribute13;
    p12_a17 := ddx_trxv_rec.attribute14;
    p12_a18 := ddx_trxv_rec.attribute15;
    p12_a19 := ddx_trxv_rec.tas_type;
    p12_a20 := rosetta_g_miss_num_map(ddx_trxv_rec.created_by);
    p12_a21 := ddx_trxv_rec.creation_date;
    p12_a22 := rosetta_g_miss_num_map(ddx_trxv_rec.last_updated_by);
    p12_a23 := ddx_trxv_rec.last_update_date;
    p12_a24 := rosetta_g_miss_num_map(ddx_trxv_rec.last_update_login);
    p12_a25 := ddx_trxv_rec.tsu_code;
    p12_a26 := rosetta_g_miss_num_map(ddx_trxv_rec.try_id);
    p12_a27 := ddx_trxv_rec.date_trans_occurred;
    p12_a28 := rosetta_g_miss_num_map(ddx_trxv_rec.trans_number);
    p12_a29 := ddx_trxv_rec.comments;
    p12_a30 := rosetta_g_miss_num_map(ddx_trxv_rec.req_asset_id);
    p12_a31 := rosetta_g_miss_num_map(ddx_trxv_rec.total_match_amount);
    p12_a32 := rosetta_g_miss_num_map(ddx_trxv_rec.org_id);
  end;

  procedure create_split_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p_split_into_individuals_yn  VARCHAR2
    , p_split_into_units  NUMBER
    , p_trx_date  date
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_NUMBER_TABLE
    , p9_a34 out nocopy JTF_DATE_TABLE
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , p9_a36 out nocopy JTF_DATE_TABLE
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_DATE_TABLE
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  NUMBER
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  NUMBER
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  NUMBER
    , p10_a20 out nocopy  NUMBER
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  DATE
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  DATE
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  NUMBER
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  NUMBER
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  NUMBER
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  VARCHAR2
    , p10_a43 out nocopy  VARCHAR2
    , p10_a44 out nocopy  VARCHAR2
    , p10_a45 out nocopy  VARCHAR2
    , p10_a46 out nocopy  VARCHAR2
    , p10_a47 out nocopy  VARCHAR2
    , p10_a48 out nocopy  VARCHAR2
    , p10_a49 out nocopy  VARCHAR2
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  DATE
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  DATE
    , p10_a55 out nocopy  NUMBER
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  NUMBER
    , p10_a58 out nocopy  NUMBER
    , p10_a59 out nocopy  NUMBER
    , p10_a60 out nocopy  NUMBER
    , p10_a61 out nocopy  NUMBER
    , p10_a62 out nocopy  NUMBER
    , p10_a63 out nocopy  NUMBER
    , p10_a64 out nocopy  NUMBER
    , p10_a65 out nocopy  NUMBER
    , p10_a66 out nocopy  DATE
    , p10_a67 out nocopy  NUMBER
    , p10_a68 out nocopy  NUMBER
    , p10_a69 out nocopy  NUMBER
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  NUMBER
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  NUMBER
    , p10_a75 out nocopy  DATE
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  VARCHAR2
    , p11_a6 out nocopy  VARCHAR2
    , p11_a7 out nocopy  VARCHAR2
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  VARCHAR2
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  VARCHAR2
    , p11_a18 out nocopy  VARCHAR2
    , p11_a19 out nocopy  VARCHAR2
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  DATE
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  NUMBER
    , p11_a27 out nocopy  DATE
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  VARCHAR2
    , p11_a30 out nocopy  NUMBER
    , p11_a31 out nocopy  NUMBER
    , p11_a32 out nocopy  NUMBER
  )

  as
    ddp_trx_date date;
    ddx_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddx_txlv_rec okl_split_asset_pub.txlv_rec_type;
    ddx_trxv_rec okl_split_asset_pub.trxv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.create_split_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      p_split_into_individuals_yn,
      p_split_into_units,
      ddp_trx_date,
      ddx_txdv_tbl,
      ddx_txlv_rec,
      ddx_trxv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p9_a0
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
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      );

    p10_a0 := rosetta_g_miss_num_map(ddx_txlv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_txlv_rec.object_version_number);
    p10_a2 := ddx_txlv_rec.sfwt_flag;
    p10_a3 := rosetta_g_miss_num_map(ddx_txlv_rec.tas_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id);
    p10_a5 := rosetta_g_miss_num_map(ddx_txlv_rec.ilo_id_old);
    p10_a6 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id);
    p10_a7 := rosetta_g_miss_num_map(ddx_txlv_rec.iay_id_new);
    p10_a8 := rosetta_g_miss_num_map(ddx_txlv_rec.kle_id);
    p10_a9 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_khr_id);
    p10_a10 := rosetta_g_miss_num_map(ddx_txlv_rec.line_number);
    p10_a11 := rosetta_g_miss_num_map(ddx_txlv_rec.org_id);
    p10_a12 := ddx_txlv_rec.tal_type;
    p10_a13 := ddx_txlv_rec.asset_number;
    p10_a14 := ddx_txlv_rec.description;
    p10_a15 := rosetta_g_miss_num_map(ddx_txlv_rec.fa_location_id);
    p10_a16 := rosetta_g_miss_num_map(ddx_txlv_rec.original_cost);
    p10_a17 := rosetta_g_miss_num_map(ddx_txlv_rec.current_units);
    p10_a18 := ddx_txlv_rec.manufacturer_name;
    p10_a19 := rosetta_g_miss_num_map(ddx_txlv_rec.year_manufactured);
    p10_a20 := rosetta_g_miss_num_map(ddx_txlv_rec.supplier_id);
    p10_a21 := ddx_txlv_rec.used_asset_yn;
    p10_a22 := ddx_txlv_rec.tag_number;
    p10_a23 := ddx_txlv_rec.model_number;
    p10_a24 := ddx_txlv_rec.corporate_book;
    p10_a25 := ddx_txlv_rec.date_purchased;
    p10_a26 := ddx_txlv_rec.date_delivery;
    p10_a27 := ddx_txlv_rec.in_service_date;
    p10_a28 := rosetta_g_miss_num_map(ddx_txlv_rec.life_in_months);
    p10_a29 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_id);
    p10_a30 := rosetta_g_miss_num_map(ddx_txlv_rec.depreciation_cost);
    p10_a31 := ddx_txlv_rec.deprn_method;
    p10_a32 := rosetta_g_miss_num_map(ddx_txlv_rec.deprn_rate);
    p10_a33 := rosetta_g_miss_num_map(ddx_txlv_rec.salvage_value);
    p10_a34 := rosetta_g_miss_num_map(ddx_txlv_rec.percent_salvage_value);
    p10_a35 := ddx_txlv_rec.attribute_category;
    p10_a36 := ddx_txlv_rec.attribute1;
    p10_a37 := ddx_txlv_rec.attribute2;
    p10_a38 := ddx_txlv_rec.attribute3;
    p10_a39 := ddx_txlv_rec.attribute4;
    p10_a40 := ddx_txlv_rec.attribute5;
    p10_a41 := ddx_txlv_rec.attribute6;
    p10_a42 := ddx_txlv_rec.attribute7;
    p10_a43 := ddx_txlv_rec.attribute8;
    p10_a44 := ddx_txlv_rec.attribute9;
    p10_a45 := ddx_txlv_rec.attribute10;
    p10_a46 := ddx_txlv_rec.attribute11;
    p10_a47 := ddx_txlv_rec.attribute12;
    p10_a48 := ddx_txlv_rec.attribute13;
    p10_a49 := ddx_txlv_rec.attribute14;
    p10_a50 := ddx_txlv_rec.attribute15;
    p10_a51 := rosetta_g_miss_num_map(ddx_txlv_rec.created_by);
    p10_a52 := ddx_txlv_rec.creation_date;
    p10_a53 := rosetta_g_miss_num_map(ddx_txlv_rec.last_updated_by);
    p10_a54 := ddx_txlv_rec.last_update_date;
    p10_a55 := rosetta_g_miss_num_map(ddx_txlv_rec.last_update_login);
    p10_a56 := ddx_txlv_rec.depreciate_yn;
    p10_a57 := rosetta_g_miss_num_map(ddx_txlv_rec.hold_period_days);
    p10_a58 := rosetta_g_miss_num_map(ddx_txlv_rec.old_salvage_value);
    p10_a59 := rosetta_g_miss_num_map(ddx_txlv_rec.new_residual_value);
    p10_a60 := rosetta_g_miss_num_map(ddx_txlv_rec.old_residual_value);
    p10_a61 := rosetta_g_miss_num_map(ddx_txlv_rec.units_retired);
    p10_a62 := rosetta_g_miss_num_map(ddx_txlv_rec.cost_retired);
    p10_a63 := rosetta_g_miss_num_map(ddx_txlv_rec.sale_proceeds);
    p10_a64 := rosetta_g_miss_num_map(ddx_txlv_rec.removal_cost);
    p10_a65 := rosetta_g_miss_num_map(ddx_txlv_rec.dnz_asset_id);
    p10_a66 := ddx_txlv_rec.date_due;
    p10_a67 := rosetta_g_miss_num_map(ddx_txlv_rec.rep_asset_id);
    p10_a68 := rosetta_g_miss_num_map(ddx_txlv_rec.lke_asset_id);
    p10_a69 := rosetta_g_miss_num_map(ddx_txlv_rec.match_amount);
    p10_a70 := ddx_txlv_rec.split_into_singles_flag;
    p10_a71 := rosetta_g_miss_num_map(ddx_txlv_rec.split_into_units);
    p10_a72 := ddx_txlv_rec.currency_code;
    p10_a73 := ddx_txlv_rec.currency_conversion_type;
    p10_a74 := rosetta_g_miss_num_map(ddx_txlv_rec.currency_conversion_rate);
    p10_a75 := ddx_txlv_rec.currency_conversion_date;

    p11_a0 := rosetta_g_miss_num_map(ddx_trxv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_trxv_rec.object_version_number);
    p11_a2 := rosetta_g_miss_num_map(ddx_trxv_rec.ica_id);
    p11_a3 := ddx_trxv_rec.attribute_category;
    p11_a4 := ddx_trxv_rec.attribute1;
    p11_a5 := ddx_trxv_rec.attribute2;
    p11_a6 := ddx_trxv_rec.attribute3;
    p11_a7 := ddx_trxv_rec.attribute4;
    p11_a8 := ddx_trxv_rec.attribute5;
    p11_a9 := ddx_trxv_rec.attribute6;
    p11_a10 := ddx_trxv_rec.attribute7;
    p11_a11 := ddx_trxv_rec.attribute8;
    p11_a12 := ddx_trxv_rec.attribute9;
    p11_a13 := ddx_trxv_rec.attribute10;
    p11_a14 := ddx_trxv_rec.attribute11;
    p11_a15 := ddx_trxv_rec.attribute12;
    p11_a16 := ddx_trxv_rec.attribute13;
    p11_a17 := ddx_trxv_rec.attribute14;
    p11_a18 := ddx_trxv_rec.attribute15;
    p11_a19 := ddx_trxv_rec.tas_type;
    p11_a20 := rosetta_g_miss_num_map(ddx_trxv_rec.created_by);
    p11_a21 := ddx_trxv_rec.creation_date;
    p11_a22 := rosetta_g_miss_num_map(ddx_trxv_rec.last_updated_by);
    p11_a23 := ddx_trxv_rec.last_update_date;
    p11_a24 := rosetta_g_miss_num_map(ddx_trxv_rec.last_update_login);
    p11_a25 := ddx_trxv_rec.tsu_code;
    p11_a26 := rosetta_g_miss_num_map(ddx_trxv_rec.try_id);
    p11_a27 := ddx_trxv_rec.date_trans_occurred;
    p11_a28 := rosetta_g_miss_num_map(ddx_trxv_rec.trans_number);
    p11_a29 := ddx_trxv_rec.comments;
    p11_a30 := rosetta_g_miss_num_map(ddx_trxv_rec.req_asset_id);
    p11_a31 := rosetta_g_miss_num_map(ddx_trxv_rec.total_match_amount);
    p11_a32 := rosetta_g_miss_num_map(ddx_trxv_rec.org_id);
  end;

  procedure update_split_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_VARCHAR2_TABLE_2000
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_100
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_NUMBER_TABLE
    , p7_a16 out nocopy JTF_NUMBER_TABLE
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_DATE_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddx_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_asd_pvt_w.rosetta_table_copy_in_p8(ddp_txdv_tbl, p6_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.update_split_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      ddp_txdv_tbl,
      ddx_txdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p7_a0
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
      );
  end;

  procedure split_fixed_asset(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  DATE := fnd_api.g_miss_date
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  DATE := fnd_api.g_miss_date
    , p6_a55  NUMBER := 0-1962.0724
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  NUMBER := 0-1962.0724
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  NUMBER := 0-1962.0724
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  NUMBER := 0-1962.0724
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  DATE := fnd_api.g_miss_date
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  DATE := fnd_api.g_miss_date
  )

  as
    ddp_txdv_tbl okl_split_asset_pub.txdv_tbl_type;
    ddp_txlv_rec okl_split_asset_pub.txlv_rec_type;
    ddx_cle_tbl okl_split_asset_pub.cle_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_asd_pvt_w.rosetta_table_copy_in_p8(ddp_txdv_tbl, p5_a0
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
      );

    ddp_txlv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_txlv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_txlv_rec.sfwt_flag := p6_a2;
    ddp_txlv_rec.tas_id := rosetta_g_miss_num_map(p6_a3);
    ddp_txlv_rec.ilo_id := rosetta_g_miss_num_map(p6_a4);
    ddp_txlv_rec.ilo_id_old := rosetta_g_miss_num_map(p6_a5);
    ddp_txlv_rec.iay_id := rosetta_g_miss_num_map(p6_a6);
    ddp_txlv_rec.iay_id_new := rosetta_g_miss_num_map(p6_a7);
    ddp_txlv_rec.kle_id := rosetta_g_miss_num_map(p6_a8);
    ddp_txlv_rec.dnz_khr_id := rosetta_g_miss_num_map(p6_a9);
    ddp_txlv_rec.line_number := rosetta_g_miss_num_map(p6_a10);
    ddp_txlv_rec.org_id := rosetta_g_miss_num_map(p6_a11);
    ddp_txlv_rec.tal_type := p6_a12;
    ddp_txlv_rec.asset_number := p6_a13;
    ddp_txlv_rec.description := p6_a14;
    ddp_txlv_rec.fa_location_id := rosetta_g_miss_num_map(p6_a15);
    ddp_txlv_rec.original_cost := rosetta_g_miss_num_map(p6_a16);
    ddp_txlv_rec.current_units := rosetta_g_miss_num_map(p6_a17);
    ddp_txlv_rec.manufacturer_name := p6_a18;
    ddp_txlv_rec.year_manufactured := rosetta_g_miss_num_map(p6_a19);
    ddp_txlv_rec.supplier_id := rosetta_g_miss_num_map(p6_a20);
    ddp_txlv_rec.used_asset_yn := p6_a21;
    ddp_txlv_rec.tag_number := p6_a22;
    ddp_txlv_rec.model_number := p6_a23;
    ddp_txlv_rec.corporate_book := p6_a24;
    ddp_txlv_rec.date_purchased := rosetta_g_miss_date_in_map(p6_a25);
    ddp_txlv_rec.date_delivery := rosetta_g_miss_date_in_map(p6_a26);
    ddp_txlv_rec.in_service_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_txlv_rec.life_in_months := rosetta_g_miss_num_map(p6_a28);
    ddp_txlv_rec.depreciation_id := rosetta_g_miss_num_map(p6_a29);
    ddp_txlv_rec.depreciation_cost := rosetta_g_miss_num_map(p6_a30);
    ddp_txlv_rec.deprn_method := p6_a31;
    ddp_txlv_rec.deprn_rate := rosetta_g_miss_num_map(p6_a32);
    ddp_txlv_rec.salvage_value := rosetta_g_miss_num_map(p6_a33);
    ddp_txlv_rec.percent_salvage_value := rosetta_g_miss_num_map(p6_a34);
    ddp_txlv_rec.attribute_category := p6_a35;
    ddp_txlv_rec.attribute1 := p6_a36;
    ddp_txlv_rec.attribute2 := p6_a37;
    ddp_txlv_rec.attribute3 := p6_a38;
    ddp_txlv_rec.attribute4 := p6_a39;
    ddp_txlv_rec.attribute5 := p6_a40;
    ddp_txlv_rec.attribute6 := p6_a41;
    ddp_txlv_rec.attribute7 := p6_a42;
    ddp_txlv_rec.attribute8 := p6_a43;
    ddp_txlv_rec.attribute9 := p6_a44;
    ddp_txlv_rec.attribute10 := p6_a45;
    ddp_txlv_rec.attribute11 := p6_a46;
    ddp_txlv_rec.attribute12 := p6_a47;
    ddp_txlv_rec.attribute13 := p6_a48;
    ddp_txlv_rec.attribute14 := p6_a49;
    ddp_txlv_rec.attribute15 := p6_a50;
    ddp_txlv_rec.created_by := rosetta_g_miss_num_map(p6_a51);
    ddp_txlv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a52);
    ddp_txlv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a53);
    ddp_txlv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a54);
    ddp_txlv_rec.last_update_login := rosetta_g_miss_num_map(p6_a55);
    ddp_txlv_rec.depreciate_yn := p6_a56;
    ddp_txlv_rec.hold_period_days := rosetta_g_miss_num_map(p6_a57);
    ddp_txlv_rec.old_salvage_value := rosetta_g_miss_num_map(p6_a58);
    ddp_txlv_rec.new_residual_value := rosetta_g_miss_num_map(p6_a59);
    ddp_txlv_rec.old_residual_value := rosetta_g_miss_num_map(p6_a60);
    ddp_txlv_rec.units_retired := rosetta_g_miss_num_map(p6_a61);
    ddp_txlv_rec.cost_retired := rosetta_g_miss_num_map(p6_a62);
    ddp_txlv_rec.sale_proceeds := rosetta_g_miss_num_map(p6_a63);
    ddp_txlv_rec.removal_cost := rosetta_g_miss_num_map(p6_a64);
    ddp_txlv_rec.dnz_asset_id := rosetta_g_miss_num_map(p6_a65);
    ddp_txlv_rec.date_due := rosetta_g_miss_date_in_map(p6_a66);
    ddp_txlv_rec.rep_asset_id := rosetta_g_miss_num_map(p6_a67);
    ddp_txlv_rec.lke_asset_id := rosetta_g_miss_num_map(p6_a68);
    ddp_txlv_rec.match_amount := rosetta_g_miss_num_map(p6_a69);
    ddp_txlv_rec.split_into_singles_flag := p6_a70;
    ddp_txlv_rec.split_into_units := rosetta_g_miss_num_map(p6_a71);
    ddp_txlv_rec.currency_code := p6_a72;
    ddp_txlv_rec.currency_conversion_type := p6_a73;
    ddp_txlv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p6_a74);
    ddp_txlv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p6_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.split_fixed_asset(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_txdv_tbl,
      ddp_txlv_rec,
      ddx_cle_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_split_asset_pvt_w.rosetta_table_copy_out_p10(ddx_cle_tbl, p7_a0
      );
  end;

  procedure split_fixed_asset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_cle_tbl okl_split_asset_pub.cle_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_split_asset_pub.split_fixed_asset(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      ddx_cle_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_split_asset_pvt_w.rosetta_table_copy_out_p10(ddx_cle_tbl, p6_a0
      );
  end;

  procedure create_split_comp_srl_num(p_api_version  NUMBER
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
    ddp_itiv_tbl okl_split_asset_pub.itiv_tbl_type;
    ddx_itiv_tbl okl_split_asset_pub.itiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_itiv_tbl, p5_a0
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
    okl_split_asset_pub.create_split_comp_srl_num(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_itiv_tbl,
      ddx_itiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_iti_pvt_w.rosetta_table_copy_out_p5(ddx_itiv_tbl, p6_a0
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

end okl_split_asset_pub_w;

/
