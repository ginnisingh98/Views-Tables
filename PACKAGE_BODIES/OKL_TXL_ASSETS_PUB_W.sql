--------------------------------------------------------
--  DDL for Package Body OKL_TXL_ASSETS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_ASSETS_PUB_W" as
  /* $Header: OKLUTALB.pls 120.3.12010000.2 2010/04/29 15:30:11 rpillay ship $ */
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

  procedure create_txl_asset_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  DATE
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddx_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tlpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tlpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tlpv_rec.sfwt_flag := p5_a2;
    ddp_tlpv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tlpv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tlpv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_tlpv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tlpv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_tlpv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tlpv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tlpv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_tlpv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tlpv_rec.tal_type := p5_a12;
    ddp_tlpv_rec.asset_number := p5_a13;
    ddp_tlpv_rec.description := p5_a14;
    ddp_tlpv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tlpv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_tlpv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_tlpv_rec.manufacturer_name := p5_a18;
    ddp_tlpv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_tlpv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tlpv_rec.used_asset_yn := p5_a21;
    ddp_tlpv_rec.tag_number := p5_a22;
    ddp_tlpv_rec.model_number := p5_a23;
    ddp_tlpv_rec.corporate_book := p5_a24;
    ddp_tlpv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tlpv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_tlpv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_tlpv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_tlpv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tlpv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_tlpv_rec.deprn_method := p5_a31;
    ddp_tlpv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_tlpv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_tlpv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_tlpv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tlpv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_tlpv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_tlpv_rec.attribute_category := p5_a38;
    ddp_tlpv_rec.attribute1 := p5_a39;
    ddp_tlpv_rec.attribute2 := p5_a40;
    ddp_tlpv_rec.attribute3 := p5_a41;
    ddp_tlpv_rec.attribute4 := p5_a42;
    ddp_tlpv_rec.attribute5 := p5_a43;
    ddp_tlpv_rec.attribute6 := p5_a44;
    ddp_tlpv_rec.attribute7 := p5_a45;
    ddp_tlpv_rec.attribute8 := p5_a46;
    ddp_tlpv_rec.attribute9 := p5_a47;
    ddp_tlpv_rec.attribute10 := p5_a48;
    ddp_tlpv_rec.attribute11 := p5_a49;
    ddp_tlpv_rec.attribute12 := p5_a50;
    ddp_tlpv_rec.attribute13 := p5_a51;
    ddp_tlpv_rec.attribute14 := p5_a52;
    ddp_tlpv_rec.attribute15 := p5_a53;
    ddp_tlpv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_tlpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_tlpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_tlpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_tlpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_tlpv_rec.depreciate_yn := p5_a59;
    ddp_tlpv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_tlpv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_tlpv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_tlpv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_tlpv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_tlpv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_tlpv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_tlpv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_tlpv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_tlpv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_tlpv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_tlpv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tlpv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_tlpv_rec.split_into_singles_flag := p5_a73;
    ddp_tlpv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_tlpv_rec.currency_code := p5_a75;
    ddp_tlpv_rec.currency_conversion_type := p5_a76;
    ddp_tlpv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tlpv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tlpv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tlpv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_tlpv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.create_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_rec,
      ddx_tlpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tlpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tlpv_rec.object_version_number);
    p6_a2 := ddx_tlpv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_tlpv_rec.tas_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tlpv_rec.ilo_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tlpv_rec.ilo_id_old);
    p6_a6 := rosetta_g_miss_num_map(ddx_tlpv_rec.iay_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tlpv_rec.iay_id_new);
    p6_a8 := rosetta_g_miss_num_map(ddx_tlpv_rec.kle_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tlpv_rec.dnz_khr_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tlpv_rec.line_number);
    p6_a11 := rosetta_g_miss_num_map(ddx_tlpv_rec.org_id);
    p6_a12 := ddx_tlpv_rec.tal_type;
    p6_a13 := ddx_tlpv_rec.asset_number;
    p6_a14 := ddx_tlpv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_tlpv_rec.fa_location_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_tlpv_rec.original_cost);
    p6_a17 := rosetta_g_miss_num_map(ddx_tlpv_rec.current_units);
    p6_a18 := ddx_tlpv_rec.manufacturer_name;
    p6_a19 := rosetta_g_miss_num_map(ddx_tlpv_rec.year_manufactured);
    p6_a20 := rosetta_g_miss_num_map(ddx_tlpv_rec.supplier_id);
    p6_a21 := ddx_tlpv_rec.used_asset_yn;
    p6_a22 := ddx_tlpv_rec.tag_number;
    p6_a23 := ddx_tlpv_rec.model_number;
    p6_a24 := ddx_tlpv_rec.corporate_book;
    p6_a25 := ddx_tlpv_rec.date_purchased;
    p6_a26 := ddx_tlpv_rec.date_delivery;
    p6_a27 := ddx_tlpv_rec.in_service_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_tlpv_rec.life_in_months);
    p6_a29 := rosetta_g_miss_num_map(ddx_tlpv_rec.depreciation_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_tlpv_rec.depreciation_cost);
    p6_a31 := ddx_tlpv_rec.deprn_method;
    p6_a32 := rosetta_g_miss_num_map(ddx_tlpv_rec.deprn_rate);
    p6_a33 := rosetta_g_miss_num_map(ddx_tlpv_rec.salvage_value);
    p6_a34 := rosetta_g_miss_num_map(ddx_tlpv_rec.percent_salvage_value);
    p6_a35 := rosetta_g_miss_num_map(ddx_tlpv_rec.asset_key_id);
    p6_a36 := ddx_tlpv_rec.fa_trx_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_tlpv_rec.fa_cost);
    p6_a38 := ddx_tlpv_rec.attribute_category;
    p6_a39 := ddx_tlpv_rec.attribute1;
    p6_a40 := ddx_tlpv_rec.attribute2;
    p6_a41 := ddx_tlpv_rec.attribute3;
    p6_a42 := ddx_tlpv_rec.attribute4;
    p6_a43 := ddx_tlpv_rec.attribute5;
    p6_a44 := ddx_tlpv_rec.attribute6;
    p6_a45 := ddx_tlpv_rec.attribute7;
    p6_a46 := ddx_tlpv_rec.attribute8;
    p6_a47 := ddx_tlpv_rec.attribute9;
    p6_a48 := ddx_tlpv_rec.attribute10;
    p6_a49 := ddx_tlpv_rec.attribute11;
    p6_a50 := ddx_tlpv_rec.attribute12;
    p6_a51 := ddx_tlpv_rec.attribute13;
    p6_a52 := ddx_tlpv_rec.attribute14;
    p6_a53 := ddx_tlpv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_tlpv_rec.created_by);
    p6_a55 := ddx_tlpv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_tlpv_rec.last_updated_by);
    p6_a57 := ddx_tlpv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_tlpv_rec.last_update_login);
    p6_a59 := ddx_tlpv_rec.depreciate_yn;
    p6_a60 := rosetta_g_miss_num_map(ddx_tlpv_rec.hold_period_days);
    p6_a61 := rosetta_g_miss_num_map(ddx_tlpv_rec.old_salvage_value);
    p6_a62 := rosetta_g_miss_num_map(ddx_tlpv_rec.new_residual_value);
    p6_a63 := rosetta_g_miss_num_map(ddx_tlpv_rec.old_residual_value);
    p6_a64 := rosetta_g_miss_num_map(ddx_tlpv_rec.units_retired);
    p6_a65 := rosetta_g_miss_num_map(ddx_tlpv_rec.cost_retired);
    p6_a66 := rosetta_g_miss_num_map(ddx_tlpv_rec.sale_proceeds);
    p6_a67 := rosetta_g_miss_num_map(ddx_tlpv_rec.removal_cost);
    p6_a68 := rosetta_g_miss_num_map(ddx_tlpv_rec.dnz_asset_id);
    p6_a69 := ddx_tlpv_rec.date_due;
    p6_a70 := rosetta_g_miss_num_map(ddx_tlpv_rec.rep_asset_id);
    p6_a71 := rosetta_g_miss_num_map(ddx_tlpv_rec.lke_asset_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_tlpv_rec.match_amount);
    p6_a73 := ddx_tlpv_rec.split_into_singles_flag;
    p6_a74 := rosetta_g_miss_num_map(ddx_tlpv_rec.split_into_units);
    p6_a75 := ddx_tlpv_rec.currency_code;
    p6_a76 := ddx_tlpv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_tlpv_rec.currency_conversion_rate);
    p6_a78 := ddx_tlpv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_tlpv_rec.residual_shr_party_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_tlpv_rec.residual_shr_amount);
    p6_a81 := rosetta_g_miss_num_map(ddx_tlpv_rec.retirement_id);
  end;

  procedure create_txl_asset_def(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_DATE_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddx_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_tlpv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.create_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_tbl,
      ddx_tlpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tal_pvt_w.rosetta_table_copy_out_p8(ddx_tlpv_tbl, p6_a0
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
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      );
  end;

  procedure update_txl_asset_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  DATE
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddx_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tlpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tlpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tlpv_rec.sfwt_flag := p5_a2;
    ddp_tlpv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tlpv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tlpv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_tlpv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tlpv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_tlpv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tlpv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tlpv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_tlpv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tlpv_rec.tal_type := p5_a12;
    ddp_tlpv_rec.asset_number := p5_a13;
    ddp_tlpv_rec.description := p5_a14;
    ddp_tlpv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tlpv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_tlpv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_tlpv_rec.manufacturer_name := p5_a18;
    ddp_tlpv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_tlpv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tlpv_rec.used_asset_yn := p5_a21;
    ddp_tlpv_rec.tag_number := p5_a22;
    ddp_tlpv_rec.model_number := p5_a23;
    ddp_tlpv_rec.corporate_book := p5_a24;
    ddp_tlpv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tlpv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_tlpv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_tlpv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_tlpv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tlpv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_tlpv_rec.deprn_method := p5_a31;
    ddp_tlpv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_tlpv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_tlpv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_tlpv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tlpv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_tlpv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_tlpv_rec.attribute_category := p5_a38;
    ddp_tlpv_rec.attribute1 := p5_a39;
    ddp_tlpv_rec.attribute2 := p5_a40;
    ddp_tlpv_rec.attribute3 := p5_a41;
    ddp_tlpv_rec.attribute4 := p5_a42;
    ddp_tlpv_rec.attribute5 := p5_a43;
    ddp_tlpv_rec.attribute6 := p5_a44;
    ddp_tlpv_rec.attribute7 := p5_a45;
    ddp_tlpv_rec.attribute8 := p5_a46;
    ddp_tlpv_rec.attribute9 := p5_a47;
    ddp_tlpv_rec.attribute10 := p5_a48;
    ddp_tlpv_rec.attribute11 := p5_a49;
    ddp_tlpv_rec.attribute12 := p5_a50;
    ddp_tlpv_rec.attribute13 := p5_a51;
    ddp_tlpv_rec.attribute14 := p5_a52;
    ddp_tlpv_rec.attribute15 := p5_a53;
    ddp_tlpv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_tlpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_tlpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_tlpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_tlpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_tlpv_rec.depreciate_yn := p5_a59;
    ddp_tlpv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_tlpv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_tlpv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_tlpv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_tlpv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_tlpv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_tlpv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_tlpv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_tlpv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_tlpv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_tlpv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_tlpv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tlpv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_tlpv_rec.split_into_singles_flag := p5_a73;
    ddp_tlpv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_tlpv_rec.currency_code := p5_a75;
    ddp_tlpv_rec.currency_conversion_type := p5_a76;
    ddp_tlpv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tlpv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tlpv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tlpv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_tlpv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.update_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_rec,
      ddx_tlpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tlpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tlpv_rec.object_version_number);
    p6_a2 := ddx_tlpv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_tlpv_rec.tas_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tlpv_rec.ilo_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tlpv_rec.ilo_id_old);
    p6_a6 := rosetta_g_miss_num_map(ddx_tlpv_rec.iay_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tlpv_rec.iay_id_new);
    p6_a8 := rosetta_g_miss_num_map(ddx_tlpv_rec.kle_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tlpv_rec.dnz_khr_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tlpv_rec.line_number);
    p6_a11 := rosetta_g_miss_num_map(ddx_tlpv_rec.org_id);
    p6_a12 := ddx_tlpv_rec.tal_type;
    p6_a13 := ddx_tlpv_rec.asset_number;
    p6_a14 := ddx_tlpv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_tlpv_rec.fa_location_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_tlpv_rec.original_cost);
    p6_a17 := rosetta_g_miss_num_map(ddx_tlpv_rec.current_units);
    p6_a18 := ddx_tlpv_rec.manufacturer_name;
    p6_a19 := rosetta_g_miss_num_map(ddx_tlpv_rec.year_manufactured);
    p6_a20 := rosetta_g_miss_num_map(ddx_tlpv_rec.supplier_id);
    p6_a21 := ddx_tlpv_rec.used_asset_yn;
    p6_a22 := ddx_tlpv_rec.tag_number;
    p6_a23 := ddx_tlpv_rec.model_number;
    p6_a24 := ddx_tlpv_rec.corporate_book;
    p6_a25 := ddx_tlpv_rec.date_purchased;
    p6_a26 := ddx_tlpv_rec.date_delivery;
    p6_a27 := ddx_tlpv_rec.in_service_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_tlpv_rec.life_in_months);
    p6_a29 := rosetta_g_miss_num_map(ddx_tlpv_rec.depreciation_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_tlpv_rec.depreciation_cost);
    p6_a31 := ddx_tlpv_rec.deprn_method;
    p6_a32 := rosetta_g_miss_num_map(ddx_tlpv_rec.deprn_rate);
    p6_a33 := rosetta_g_miss_num_map(ddx_tlpv_rec.salvage_value);
    p6_a34 := rosetta_g_miss_num_map(ddx_tlpv_rec.percent_salvage_value);
    p6_a35 := rosetta_g_miss_num_map(ddx_tlpv_rec.asset_key_id);
    p6_a36 := ddx_tlpv_rec.fa_trx_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_tlpv_rec.fa_cost);
    p6_a38 := ddx_tlpv_rec.attribute_category;
    p6_a39 := ddx_tlpv_rec.attribute1;
    p6_a40 := ddx_tlpv_rec.attribute2;
    p6_a41 := ddx_tlpv_rec.attribute3;
    p6_a42 := ddx_tlpv_rec.attribute4;
    p6_a43 := ddx_tlpv_rec.attribute5;
    p6_a44 := ddx_tlpv_rec.attribute6;
    p6_a45 := ddx_tlpv_rec.attribute7;
    p6_a46 := ddx_tlpv_rec.attribute8;
    p6_a47 := ddx_tlpv_rec.attribute9;
    p6_a48 := ddx_tlpv_rec.attribute10;
    p6_a49 := ddx_tlpv_rec.attribute11;
    p6_a50 := ddx_tlpv_rec.attribute12;
    p6_a51 := ddx_tlpv_rec.attribute13;
    p6_a52 := ddx_tlpv_rec.attribute14;
    p6_a53 := ddx_tlpv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_tlpv_rec.created_by);
    p6_a55 := ddx_tlpv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_tlpv_rec.last_updated_by);
    p6_a57 := ddx_tlpv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_tlpv_rec.last_update_login);
    p6_a59 := ddx_tlpv_rec.depreciate_yn;
    p6_a60 := rosetta_g_miss_num_map(ddx_tlpv_rec.hold_period_days);
    p6_a61 := rosetta_g_miss_num_map(ddx_tlpv_rec.old_salvage_value);
    p6_a62 := rosetta_g_miss_num_map(ddx_tlpv_rec.new_residual_value);
    p6_a63 := rosetta_g_miss_num_map(ddx_tlpv_rec.old_residual_value);
    p6_a64 := rosetta_g_miss_num_map(ddx_tlpv_rec.units_retired);
    p6_a65 := rosetta_g_miss_num_map(ddx_tlpv_rec.cost_retired);
    p6_a66 := rosetta_g_miss_num_map(ddx_tlpv_rec.sale_proceeds);
    p6_a67 := rosetta_g_miss_num_map(ddx_tlpv_rec.removal_cost);
    p6_a68 := rosetta_g_miss_num_map(ddx_tlpv_rec.dnz_asset_id);
    p6_a69 := ddx_tlpv_rec.date_due;
    p6_a70 := rosetta_g_miss_num_map(ddx_tlpv_rec.rep_asset_id);
    p6_a71 := rosetta_g_miss_num_map(ddx_tlpv_rec.lke_asset_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_tlpv_rec.match_amount);
    p6_a73 := ddx_tlpv_rec.split_into_singles_flag;
    p6_a74 := rosetta_g_miss_num_map(ddx_tlpv_rec.split_into_units);
    p6_a75 := ddx_tlpv_rec.currency_code;
    p6_a76 := ddx_tlpv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_tlpv_rec.currency_conversion_rate);
    p6_a78 := ddx_tlpv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_tlpv_rec.residual_shr_party_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_tlpv_rec.residual_shr_amount);
    p6_a81 := rosetta_g_miss_num_map(ddx_tlpv_rec.retirement_id);
  end;

  procedure update_txl_asset_def(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_DATE_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddx_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_tlpv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.update_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_tbl,
      ddx_tlpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tal_pvt_w.rosetta_table_copy_out_p8(ddx_tlpv_tbl, p6_a0
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
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      );
  end;

  procedure delete_txl_asset_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tlpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tlpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tlpv_rec.sfwt_flag := p5_a2;
    ddp_tlpv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tlpv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tlpv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_tlpv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tlpv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_tlpv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tlpv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tlpv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_tlpv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tlpv_rec.tal_type := p5_a12;
    ddp_tlpv_rec.asset_number := p5_a13;
    ddp_tlpv_rec.description := p5_a14;
    ddp_tlpv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tlpv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_tlpv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_tlpv_rec.manufacturer_name := p5_a18;
    ddp_tlpv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_tlpv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tlpv_rec.used_asset_yn := p5_a21;
    ddp_tlpv_rec.tag_number := p5_a22;
    ddp_tlpv_rec.model_number := p5_a23;
    ddp_tlpv_rec.corporate_book := p5_a24;
    ddp_tlpv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tlpv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_tlpv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_tlpv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_tlpv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tlpv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_tlpv_rec.deprn_method := p5_a31;
    ddp_tlpv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_tlpv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_tlpv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_tlpv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tlpv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_tlpv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_tlpv_rec.attribute_category := p5_a38;
    ddp_tlpv_rec.attribute1 := p5_a39;
    ddp_tlpv_rec.attribute2 := p5_a40;
    ddp_tlpv_rec.attribute3 := p5_a41;
    ddp_tlpv_rec.attribute4 := p5_a42;
    ddp_tlpv_rec.attribute5 := p5_a43;
    ddp_tlpv_rec.attribute6 := p5_a44;
    ddp_tlpv_rec.attribute7 := p5_a45;
    ddp_tlpv_rec.attribute8 := p5_a46;
    ddp_tlpv_rec.attribute9 := p5_a47;
    ddp_tlpv_rec.attribute10 := p5_a48;
    ddp_tlpv_rec.attribute11 := p5_a49;
    ddp_tlpv_rec.attribute12 := p5_a50;
    ddp_tlpv_rec.attribute13 := p5_a51;
    ddp_tlpv_rec.attribute14 := p5_a52;
    ddp_tlpv_rec.attribute15 := p5_a53;
    ddp_tlpv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_tlpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_tlpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_tlpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_tlpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_tlpv_rec.depreciate_yn := p5_a59;
    ddp_tlpv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_tlpv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_tlpv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_tlpv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_tlpv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_tlpv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_tlpv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_tlpv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_tlpv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_tlpv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_tlpv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_tlpv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tlpv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_tlpv_rec.split_into_singles_flag := p5_a73;
    ddp_tlpv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_tlpv_rec.currency_code := p5_a75;
    ddp_tlpv_rec.currency_conversion_type := p5_a76;
    ddp_tlpv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tlpv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tlpv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tlpv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_tlpv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.delete_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_txl_asset_def(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
  )

  as
    ddp_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_tlpv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.delete_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_txl_asset_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tlpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tlpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tlpv_rec.sfwt_flag := p5_a2;
    ddp_tlpv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tlpv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tlpv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_tlpv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tlpv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_tlpv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tlpv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tlpv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_tlpv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tlpv_rec.tal_type := p5_a12;
    ddp_tlpv_rec.asset_number := p5_a13;
    ddp_tlpv_rec.description := p5_a14;
    ddp_tlpv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tlpv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_tlpv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_tlpv_rec.manufacturer_name := p5_a18;
    ddp_tlpv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_tlpv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tlpv_rec.used_asset_yn := p5_a21;
    ddp_tlpv_rec.tag_number := p5_a22;
    ddp_tlpv_rec.model_number := p5_a23;
    ddp_tlpv_rec.corporate_book := p5_a24;
    ddp_tlpv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tlpv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_tlpv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_tlpv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_tlpv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tlpv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_tlpv_rec.deprn_method := p5_a31;
    ddp_tlpv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_tlpv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_tlpv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_tlpv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tlpv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_tlpv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_tlpv_rec.attribute_category := p5_a38;
    ddp_tlpv_rec.attribute1 := p5_a39;
    ddp_tlpv_rec.attribute2 := p5_a40;
    ddp_tlpv_rec.attribute3 := p5_a41;
    ddp_tlpv_rec.attribute4 := p5_a42;
    ddp_tlpv_rec.attribute5 := p5_a43;
    ddp_tlpv_rec.attribute6 := p5_a44;
    ddp_tlpv_rec.attribute7 := p5_a45;
    ddp_tlpv_rec.attribute8 := p5_a46;
    ddp_tlpv_rec.attribute9 := p5_a47;
    ddp_tlpv_rec.attribute10 := p5_a48;
    ddp_tlpv_rec.attribute11 := p5_a49;
    ddp_tlpv_rec.attribute12 := p5_a50;
    ddp_tlpv_rec.attribute13 := p5_a51;
    ddp_tlpv_rec.attribute14 := p5_a52;
    ddp_tlpv_rec.attribute15 := p5_a53;
    ddp_tlpv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_tlpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_tlpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_tlpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_tlpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_tlpv_rec.depreciate_yn := p5_a59;
    ddp_tlpv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_tlpv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_tlpv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_tlpv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_tlpv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_tlpv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_tlpv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_tlpv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_tlpv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_tlpv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_tlpv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_tlpv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tlpv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_tlpv_rec.split_into_singles_flag := p5_a73;
    ddp_tlpv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_tlpv_rec.currency_code := p5_a75;
    ddp_tlpv_rec.currency_conversion_type := p5_a76;
    ddp_tlpv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tlpv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tlpv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tlpv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_tlpv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.lock_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_txl_asset_def(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
  )

  as
    ddp_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_tlpv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.lock_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_txl_asset_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_tlpv_rec okl_txl_assets_pub.tlpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tlpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tlpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tlpv_rec.sfwt_flag := p5_a2;
    ddp_tlpv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tlpv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tlpv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_tlpv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tlpv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_tlpv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tlpv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tlpv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_tlpv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tlpv_rec.tal_type := p5_a12;
    ddp_tlpv_rec.asset_number := p5_a13;
    ddp_tlpv_rec.description := p5_a14;
    ddp_tlpv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tlpv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_tlpv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_tlpv_rec.manufacturer_name := p5_a18;
    ddp_tlpv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_tlpv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tlpv_rec.used_asset_yn := p5_a21;
    ddp_tlpv_rec.tag_number := p5_a22;
    ddp_tlpv_rec.model_number := p5_a23;
    ddp_tlpv_rec.corporate_book := p5_a24;
    ddp_tlpv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tlpv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_tlpv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_tlpv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_tlpv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_tlpv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_tlpv_rec.deprn_method := p5_a31;
    ddp_tlpv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_tlpv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_tlpv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_tlpv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tlpv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_tlpv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_tlpv_rec.attribute_category := p5_a38;
    ddp_tlpv_rec.attribute1 := p5_a39;
    ddp_tlpv_rec.attribute2 := p5_a40;
    ddp_tlpv_rec.attribute3 := p5_a41;
    ddp_tlpv_rec.attribute4 := p5_a42;
    ddp_tlpv_rec.attribute5 := p5_a43;
    ddp_tlpv_rec.attribute6 := p5_a44;
    ddp_tlpv_rec.attribute7 := p5_a45;
    ddp_tlpv_rec.attribute8 := p5_a46;
    ddp_tlpv_rec.attribute9 := p5_a47;
    ddp_tlpv_rec.attribute10 := p5_a48;
    ddp_tlpv_rec.attribute11 := p5_a49;
    ddp_tlpv_rec.attribute12 := p5_a50;
    ddp_tlpv_rec.attribute13 := p5_a51;
    ddp_tlpv_rec.attribute14 := p5_a52;
    ddp_tlpv_rec.attribute15 := p5_a53;
    ddp_tlpv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_tlpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_tlpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_tlpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_tlpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_tlpv_rec.depreciate_yn := p5_a59;
    ddp_tlpv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_tlpv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_tlpv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_tlpv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_tlpv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_tlpv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_tlpv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_tlpv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_tlpv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_tlpv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_tlpv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_tlpv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tlpv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_tlpv_rec.split_into_singles_flag := p5_a73;
    ddp_tlpv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_tlpv_rec.currency_code := p5_a75;
    ddp_tlpv_rec.currency_conversion_type := p5_a76;
    ddp_tlpv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tlpv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tlpv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tlpv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_tlpv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.validate_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_txl_asset_def(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
  )

  as
    ddp_tlpv_tbl okl_txl_assets_pub.tlpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_tlpv_tbl, p5_a0
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
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_txl_assets_pub.validate_txl_asset_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tlpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_txl_assets_pub_w;

/
