--------------------------------------------------------
--  DDL for Package Body OKL_AM_AMORTIZE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_AMORTIZE_PUB_W" as
  /* $Header: OKLUTATB.pls 120.5.12010000.2 2010/04/29 15:43:53 rpillay ship $ */
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

  procedure create_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_early_termination_yn  VARCHAR2
    , p_quote_eff_date  date
    , p_quote_accpt_date  date
  )

  as
    ddp_quote_eff_date date;
    ddp_quote_accpt_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_quote_eff_date := rosetta_g_miss_date_in_map(p_quote_eff_date);

    ddp_quote_accpt_date := rosetta_g_miss_date_in_map(p_quote_accpt_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_am_amortize_pub.create_offlease_asset_trx(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_kle_id => p_kle_id,
      p_early_termination_yn => p_early_termination_yn,
      p_quote_eff_date => ddp_quote_eff_date,
      p_quote_accpt_date => ddp_quote_accpt_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_early_termination_yn  VARCHAR2
    , p_quote_eff_date  date
    , p_quote_accpt_date  date
  )

  as
    ddp_quote_eff_date date;
    ddp_quote_accpt_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_quote_eff_date := rosetta_g_miss_date_in_map(p_quote_eff_date);

    ddp_quote_accpt_date := rosetta_g_miss_date_in_map(p_quote_accpt_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_am_amortize_pub.create_offlease_asset_trx(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_contract_id => p_contract_id,
      p_early_termination_yn => p_early_termination_yn,
      p_quote_eff_date => ddp_quote_eff_date,
      p_quote_accpt_date => ddp_quote_accpt_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
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
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
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
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  NUMBER := 0-1962.0724
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
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  DATE := fnd_api.g_miss_date
    , p6_a58  NUMBER := 0-1962.0724
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  NUMBER := 0-1962.0724
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  NUMBER := 0-1962.0724
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  DATE := fnd_api.g_miss_date
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  NUMBER := 0-1962.0724
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_header_rec okl_am_amortize_pub.thpv_rec_type;
    ddp_lines_rec okl_am_amortize_pub.tlpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_header_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_header_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_header_rec.ica_id := rosetta_g_miss_num_map(p5_a2);
    ddp_header_rec.attribute_category := p5_a3;
    ddp_header_rec.attribute1 := p5_a4;
    ddp_header_rec.attribute2 := p5_a5;
    ddp_header_rec.attribute3 := p5_a6;
    ddp_header_rec.attribute4 := p5_a7;
    ddp_header_rec.attribute5 := p5_a8;
    ddp_header_rec.attribute6 := p5_a9;
    ddp_header_rec.attribute7 := p5_a10;
    ddp_header_rec.attribute8 := p5_a11;
    ddp_header_rec.attribute9 := p5_a12;
    ddp_header_rec.attribute10 := p5_a13;
    ddp_header_rec.attribute11 := p5_a14;
    ddp_header_rec.attribute12 := p5_a15;
    ddp_header_rec.attribute13 := p5_a16;
    ddp_header_rec.attribute14 := p5_a17;
    ddp_header_rec.attribute15 := p5_a18;
    ddp_header_rec.tas_type := p5_a19;
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p5_a20);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p5_a22);
    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p5_a24);
    ddp_header_rec.tsu_code := p5_a25;
    ddp_header_rec.try_id := rosetta_g_miss_num_map(p5_a26);
    ddp_header_rec.date_trans_occurred := rosetta_g_miss_date_in_map(p5_a27);
    ddp_header_rec.trans_number := rosetta_g_miss_num_map(p5_a28);
    ddp_header_rec.comments := p5_a29;
    ddp_header_rec.req_asset_id := rosetta_g_miss_num_map(p5_a30);
    ddp_header_rec.total_match_amount := rosetta_g_miss_num_map(p5_a31);
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_header_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a33);
    ddp_header_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a34);

    ddp_lines_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_lines_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_lines_rec.sfwt_flag := p6_a2;
    ddp_lines_rec.tas_id := rosetta_g_miss_num_map(p6_a3);
    ddp_lines_rec.ilo_id := rosetta_g_miss_num_map(p6_a4);
    ddp_lines_rec.ilo_id_old := rosetta_g_miss_num_map(p6_a5);
    ddp_lines_rec.iay_id := rosetta_g_miss_num_map(p6_a6);
    ddp_lines_rec.iay_id_new := rosetta_g_miss_num_map(p6_a7);
    ddp_lines_rec.kle_id := rosetta_g_miss_num_map(p6_a8);
    ddp_lines_rec.dnz_khr_id := rosetta_g_miss_num_map(p6_a9);
    ddp_lines_rec.line_number := rosetta_g_miss_num_map(p6_a10);
    ddp_lines_rec.org_id := rosetta_g_miss_num_map(p6_a11);
    ddp_lines_rec.tal_type := p6_a12;
    ddp_lines_rec.asset_number := p6_a13;
    ddp_lines_rec.description := p6_a14;
    ddp_lines_rec.fa_location_id := rosetta_g_miss_num_map(p6_a15);
    ddp_lines_rec.original_cost := rosetta_g_miss_num_map(p6_a16);
    ddp_lines_rec.current_units := rosetta_g_miss_num_map(p6_a17);
    ddp_lines_rec.manufacturer_name := p6_a18;
    ddp_lines_rec.year_manufactured := rosetta_g_miss_num_map(p6_a19);
    ddp_lines_rec.supplier_id := rosetta_g_miss_num_map(p6_a20);
    ddp_lines_rec.used_asset_yn := p6_a21;
    ddp_lines_rec.tag_number := p6_a22;
    ddp_lines_rec.model_number := p6_a23;
    ddp_lines_rec.corporate_book := p6_a24;
    ddp_lines_rec.date_purchased := rosetta_g_miss_date_in_map(p6_a25);
    ddp_lines_rec.date_delivery := rosetta_g_miss_date_in_map(p6_a26);
    ddp_lines_rec.in_service_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_lines_rec.life_in_months := rosetta_g_miss_num_map(p6_a28);
    ddp_lines_rec.depreciation_id := rosetta_g_miss_num_map(p6_a29);
    ddp_lines_rec.depreciation_cost := rosetta_g_miss_num_map(p6_a30);
    ddp_lines_rec.deprn_method := p6_a31;
    ddp_lines_rec.deprn_rate := rosetta_g_miss_num_map(p6_a32);
    ddp_lines_rec.salvage_value := rosetta_g_miss_num_map(p6_a33);
    ddp_lines_rec.percent_salvage_value := rosetta_g_miss_num_map(p6_a34);
    ddp_lines_rec.asset_key_id := rosetta_g_miss_num_map(p6_a35);
    ddp_lines_rec.fa_trx_date := rosetta_g_miss_date_in_map(p6_a36);
    ddp_lines_rec.fa_cost := rosetta_g_miss_num_map(p6_a37);
    ddp_lines_rec.attribute_category := p6_a38;
    ddp_lines_rec.attribute1 := p6_a39;
    ddp_lines_rec.attribute2 := p6_a40;
    ddp_lines_rec.attribute3 := p6_a41;
    ddp_lines_rec.attribute4 := p6_a42;
    ddp_lines_rec.attribute5 := p6_a43;
    ddp_lines_rec.attribute6 := p6_a44;
    ddp_lines_rec.attribute7 := p6_a45;
    ddp_lines_rec.attribute8 := p6_a46;
    ddp_lines_rec.attribute9 := p6_a47;
    ddp_lines_rec.attribute10 := p6_a48;
    ddp_lines_rec.attribute11 := p6_a49;
    ddp_lines_rec.attribute12 := p6_a50;
    ddp_lines_rec.attribute13 := p6_a51;
    ddp_lines_rec.attribute14 := p6_a52;
    ddp_lines_rec.attribute15 := p6_a53;
    ddp_lines_rec.created_by := rosetta_g_miss_num_map(p6_a54);
    ddp_lines_rec.creation_date := rosetta_g_miss_date_in_map(p6_a55);
    ddp_lines_rec.last_updated_by := rosetta_g_miss_num_map(p6_a56);
    ddp_lines_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a57);
    ddp_lines_rec.last_update_login := rosetta_g_miss_num_map(p6_a58);
    ddp_lines_rec.depreciate_yn := p6_a59;
    ddp_lines_rec.hold_period_days := rosetta_g_miss_num_map(p6_a60);
    ddp_lines_rec.old_salvage_value := rosetta_g_miss_num_map(p6_a61);
    ddp_lines_rec.new_residual_value := rosetta_g_miss_num_map(p6_a62);
    ddp_lines_rec.old_residual_value := rosetta_g_miss_num_map(p6_a63);
    ddp_lines_rec.units_retired := rosetta_g_miss_num_map(p6_a64);
    ddp_lines_rec.cost_retired := rosetta_g_miss_num_map(p6_a65);
    ddp_lines_rec.sale_proceeds := rosetta_g_miss_num_map(p6_a66);
    ddp_lines_rec.removal_cost := rosetta_g_miss_num_map(p6_a67);
    ddp_lines_rec.dnz_asset_id := rosetta_g_miss_num_map(p6_a68);
    ddp_lines_rec.date_due := rosetta_g_miss_date_in_map(p6_a69);
    ddp_lines_rec.rep_asset_id := rosetta_g_miss_num_map(p6_a70);
    ddp_lines_rec.lke_asset_id := rosetta_g_miss_num_map(p6_a71);
    ddp_lines_rec.match_amount := rosetta_g_miss_num_map(p6_a72);
    ddp_lines_rec.split_into_singles_flag := p6_a73;
    ddp_lines_rec.split_into_units := rosetta_g_miss_num_map(p6_a74);
    ddp_lines_rec.currency_code := p6_a75;
    ddp_lines_rec.currency_conversion_type := p6_a76;
    ddp_lines_rec.currency_conversion_rate := rosetta_g_miss_num_map(p6_a77);
    ddp_lines_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p6_a78);
    ddp_lines_rec.residual_shr_party_id := rosetta_g_miss_num_map(p6_a79);
    ddp_lines_rec.residual_shr_amount := rosetta_g_miss_num_map(p6_a80);
    ddp_lines_rec.retirement_id := rosetta_g_miss_num_map(p6_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_am_amortize_pub.update_offlease_asset_trx(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_header_rec,
      ddp_lines_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_500
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
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_VARCHAR2_TABLE_400
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_VARCHAR2_TABLE_100
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_NUMBER_TABLE
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_NUMBER_TABLE
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_NUMBER_TABLE
    , p6_a63 JTF_NUMBER_TABLE
    , p6_a64 JTF_NUMBER_TABLE
    , p6_a65 JTF_NUMBER_TABLE
    , p6_a66 JTF_NUMBER_TABLE
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_DATE_TABLE
    , p6_a70 JTF_NUMBER_TABLE
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_NUMBER_TABLE
    , p6_a73 JTF_VARCHAR2_TABLE_100
    , p6_a74 JTF_NUMBER_TABLE
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_DATE_TABLE
    , p6_a79 JTF_NUMBER_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_NUMBER_TABLE
    , x_record_status out nocopy  VARCHAR2
  )

  as
    ddp_header_tbl okl_am_amortize_pub.thpv_tbl_type;
    ddp_lines_tbl okl_am_amortize_pub.tlpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tas_pvt_w.rosetta_table_copy_in_p5(ddp_header_tbl, p5_a0
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
      );

    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_lines_tbl, p6_a0
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


    -- here's the delegated call to the old PL/SQL routine
    okl_am_amortize_pub.update_offlease_asset_trx(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_header_tbl,
      ddp_lines_tbl,
      x_record_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_depreciation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
  )

  as
    ddp_deprn_rec okl_am_amortize_pub.deprn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_deprn_rec.p_tas_id := rosetta_g_miss_num_map(p5_a0);
    ddp_deprn_rec.p_tal_id := rosetta_g_miss_num_map(p5_a1);
    ddp_deprn_rec.p_dep_method := p5_a2;
    ddp_deprn_rec.p_life_in_months := rosetta_g_miss_num_map(p5_a3);
    ddp_deprn_rec.p_deprn_rate_percent := rosetta_g_miss_num_map(p5_a4);
    ddp_deprn_rec.p_date_trns_occured := rosetta_g_miss_date_in_map(p5_a5);
    ddp_deprn_rec.p_salvage_value := rosetta_g_miss_num_map(p5_a6);

    -- here's the delegated call to the old PL/SQL routine
    okl_am_amortize_pub.update_depreciation(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deprn_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_am_amortize_pub_w;

/
