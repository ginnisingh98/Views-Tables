--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RETURN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RETURN_PUB_W" as
  /* $Header: OKLUARRB.pls 120.4 2007/11/14 19:36:26 rmunjulu ship $ */
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

  procedure create_asset_return(p_api_version  NUMBER
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
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
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
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p_quote_id  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_am_asset_return_pub.artv_rec_type;
    ddx_artv_rec okl_am_asset_return_pub.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);



    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_return_pub.create_asset_return(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec,
      ddx_artv_rec,
      p_quote_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_artv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_artv_rec.object_version_number);
    p6_a2 := ddx_artv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_artv_rec.rmr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_artv_rec.imr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_artv_rec.rna_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_artv_rec.kle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_artv_rec.iso_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_artv_rec.security_dep_trx_ap_id);
    p6_a9 := ddx_artv_rec.ars_code;
    p6_a10 := ddx_artv_rec.art1_code;
    p6_a11 := ddx_artv_rec.date_returned;
    p6_a12 := ddx_artv_rec.date_title_returned;
    p6_a13 := ddx_artv_rec.date_return_due;
    p6_a14 := ddx_artv_rec.date_return_notified;
    p6_a15 := ddx_artv_rec.relocate_asset_yn;
    p6_a16 := ddx_artv_rec.voluntary_yn;
    p6_a17 := ddx_artv_rec.date_repossession_required;
    p6_a18 := ddx_artv_rec.date_repossession_actual;
    p6_a19 := ddx_artv_rec.date_hold_until;
    p6_a20 := ddx_artv_rec.commmercially_reas_sale_yn;
    p6_a21 := ddx_artv_rec.comments;
    p6_a22 := ddx_artv_rec.attribute_category;
    p6_a23 := ddx_artv_rec.attribute1;
    p6_a24 := ddx_artv_rec.attribute2;
    p6_a25 := ddx_artv_rec.attribute3;
    p6_a26 := ddx_artv_rec.attribute4;
    p6_a27 := ddx_artv_rec.attribute5;
    p6_a28 := ddx_artv_rec.attribute6;
    p6_a29 := ddx_artv_rec.attribute7;
    p6_a30 := ddx_artv_rec.attribute8;
    p6_a31 := ddx_artv_rec.attribute9;
    p6_a32 := ddx_artv_rec.attribute10;
    p6_a33 := ddx_artv_rec.attribute11;
    p6_a34 := ddx_artv_rec.attribute12;
    p6_a35 := ddx_artv_rec.attribute13;
    p6_a36 := ddx_artv_rec.attribute14;
    p6_a37 := ddx_artv_rec.attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_artv_rec.org_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_artv_rec.request_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_artv_rec.program_application_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_artv_rec.program_id);
    p6_a42 := ddx_artv_rec.program_update_date;
    p6_a43 := rosetta_g_miss_num_map(ddx_artv_rec.created_by);
    p6_a44 := ddx_artv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_artv_rec.last_updated_by);
    p6_a46 := ddx_artv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_artv_rec.last_update_login);
    p6_a48 := rosetta_g_miss_num_map(ddx_artv_rec.floor_price);
    p6_a49 := ddx_artv_rec.new_item_number;
    p6_a50 := rosetta_g_miss_num_map(ddx_artv_rec.new_item_price);
    p6_a51 := ddx_artv_rec.asset_relocated_yn;
    p6_a52 := ddx_artv_rec.new_item_description;
    p6_a53 := ddx_artv_rec.repurchase_agmt_yn;
    p6_a54 := ddx_artv_rec.like_kind_yn;
    p6_a55 := ddx_artv_rec.currency_code;
    p6_a56 := ddx_artv_rec.currency_conversion_code;
    p6_a57 := ddx_artv_rec.currency_conversion_type;
    p6_a58 := rosetta_g_miss_num_map(ddx_artv_rec.currency_conversion_rate);
    p6_a59 := ddx_artv_rec.currency_conversion_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_artv_rec.legal_entity_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_artv_rec.asset_fmv_amount);

  end;

  procedure update_asset_return(p_api_version  NUMBER
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
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
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
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_am_asset_return_pub.artv_rec_type;
    ddx_artv_rec okl_am_asset_return_pub.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_return_pub.update_asset_return(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec,
      ddx_artv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_artv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_artv_rec.object_version_number);
    p6_a2 := ddx_artv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_artv_rec.rmr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_artv_rec.imr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_artv_rec.rna_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_artv_rec.kle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_artv_rec.iso_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_artv_rec.security_dep_trx_ap_id);
    p6_a9 := ddx_artv_rec.ars_code;
    p6_a10 := ddx_artv_rec.art1_code;
    p6_a11 := ddx_artv_rec.date_returned;
    p6_a12 := ddx_artv_rec.date_title_returned;
    p6_a13 := ddx_artv_rec.date_return_due;
    p6_a14 := ddx_artv_rec.date_return_notified;
    p6_a15 := ddx_artv_rec.relocate_asset_yn;
    p6_a16 := ddx_artv_rec.voluntary_yn;
    p6_a17 := ddx_artv_rec.date_repossession_required;
    p6_a18 := ddx_artv_rec.date_repossession_actual;
    p6_a19 := ddx_artv_rec.date_hold_until;
    p6_a20 := ddx_artv_rec.commmercially_reas_sale_yn;
    p6_a21 := ddx_artv_rec.comments;
    p6_a22 := ddx_artv_rec.attribute_category;
    p6_a23 := ddx_artv_rec.attribute1;
    p6_a24 := ddx_artv_rec.attribute2;
    p6_a25 := ddx_artv_rec.attribute3;
    p6_a26 := ddx_artv_rec.attribute4;
    p6_a27 := ddx_artv_rec.attribute5;
    p6_a28 := ddx_artv_rec.attribute6;
    p6_a29 := ddx_artv_rec.attribute7;
    p6_a30 := ddx_artv_rec.attribute8;
    p6_a31 := ddx_artv_rec.attribute9;
    p6_a32 := ddx_artv_rec.attribute10;
    p6_a33 := ddx_artv_rec.attribute11;
    p6_a34 := ddx_artv_rec.attribute12;
    p6_a35 := ddx_artv_rec.attribute13;
    p6_a36 := ddx_artv_rec.attribute14;
    p6_a37 := ddx_artv_rec.attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_artv_rec.org_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_artv_rec.request_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_artv_rec.program_application_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_artv_rec.program_id);
    p6_a42 := ddx_artv_rec.program_update_date;
    p6_a43 := rosetta_g_miss_num_map(ddx_artv_rec.created_by);
    p6_a44 := ddx_artv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_artv_rec.last_updated_by);
    p6_a46 := ddx_artv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_artv_rec.last_update_login);
    p6_a48 := rosetta_g_miss_num_map(ddx_artv_rec.floor_price);
    p6_a49 := ddx_artv_rec.new_item_number;
    p6_a50 := rosetta_g_miss_num_map(ddx_artv_rec.new_item_price);
    p6_a51 := ddx_artv_rec.asset_relocated_yn;
    p6_a52 := ddx_artv_rec.new_item_description;
    p6_a53 := ddx_artv_rec.repurchase_agmt_yn;
    p6_a54 := ddx_artv_rec.like_kind_yn;
    p6_a55 := ddx_artv_rec.currency_code;
    p6_a56 := ddx_artv_rec.currency_conversion_code;
    p6_a57 := ddx_artv_rec.currency_conversion_type;
    p6_a58 := rosetta_g_miss_num_map(ddx_artv_rec.currency_conversion_rate);
    p6_a59 := ddx_artv_rec.currency_conversion_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_artv_rec.legal_entity_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_artv_rec.asset_fmv_amount);
  end;

  procedure create_asset_return(p_api_version  NUMBER
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
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
    , p5_a22 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p_quote_id  NUMBER
  )

  as
    ddp_artv_tbl okl_am_asset_return_pub.artv_tbl_type;
    ddx_artv_tbl okl_am_asset_return_pub.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_return_pub.create_asset_return(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl,
      ddx_artv_tbl,
      p_quote_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_art_pvt_w.rosetta_table_copy_out_p8(ddx_artv_tbl, p6_a0
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
      );

  end;

  procedure update_asset_return(p_api_version  NUMBER
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
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
    , p5_a22 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_artv_tbl okl_am_asset_return_pub.artv_tbl_type;
    ddx_artv_tbl okl_am_asset_return_pub.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_return_pub.update_asset_return(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl,
      ddx_artv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_art_pvt_w.rosetta_table_copy_out_p8(ddx_artv_tbl, p6_a0
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
      );
  end;

end okl_am_asset_return_pub_w;

/
