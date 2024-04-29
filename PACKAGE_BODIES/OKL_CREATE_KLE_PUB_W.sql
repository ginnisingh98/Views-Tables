--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_KLE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_KLE_PUB_W" as
  /* $Header: OKLUKLLB.pls 115.10 2004/02/05 00:13:29 avsingh noship $ */
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

  procedure update_fin_cap_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  NUMBER
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  DATE
    , p9_a31 out nocopy  DATE
    , p9_a32 out nocopy  DATE
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  NUMBER
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  NUMBER
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
    , p9_a51 out nocopy  VARCHAR2
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  DATE
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  DATE
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  NUMBER
    , p9_a69 out nocopy  NUMBER
    , p9_a70 out nocopy  DATE
    , p9_a71 out nocopy  NUMBER
    , p9_a72 out nocopy  DATE
    , p9_a73 out nocopy  NUMBER
    , p9_a74 out nocopy  NUMBER
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  VARCHAR2
    , p9_a80 out nocopy  VARCHAR2
    , p9_a81 out nocopy  NUMBER
    , p9_a82 out nocopy  VARCHAR2
    , p9_a83 out nocopy  NUMBER
    , p9_a84 out nocopy  NUMBER
    , p9_a85 out nocopy  NUMBER
    , p9_a86 out nocopy  NUMBER
    , p9_a87 out nocopy  VARCHAR2
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  NUMBER
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  NUMBER
    , p10_a19 out nocopy  NUMBER
    , p10_a20 out nocopy  DATE
    , p10_a21 out nocopy  DATE
    , p10_a22 out nocopy  NUMBER
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  DATE
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  NUMBER
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  NUMBER
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  NUMBER
    , p10_a32 out nocopy  NUMBER
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  DATE
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  DATE
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  NUMBER
    , p10_a39 out nocopy  NUMBER
    , p10_a40 out nocopy  NUMBER
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  DATE
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  DATE
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  DATE
    , p10_a48 out nocopy  DATE
    , p10_a49 out nocopy  DATE
    , p10_a50 out nocopy  NUMBER
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  NUMBER
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  NUMBER
    , p10_a58 out nocopy  DATE
    , p10_a59 out nocopy  NUMBER
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , p10_a67 out nocopy  VARCHAR2
    , p10_a68 out nocopy  VARCHAR2
    , p10_a69 out nocopy  VARCHAR2
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  VARCHAR2
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  VARCHAR2
    , p10_a75 out nocopy  VARCHAR2
    , p10_a76 out nocopy  NUMBER
    , p10_a77 out nocopy  NUMBER
    , p10_a78 out nocopy  NUMBER
    , p10_a79 out nocopy  DATE
    , p10_a80 out nocopy  NUMBER
    , p10_a81 out nocopy  DATE
    , p10_a82 out nocopy  NUMBER
    , p10_a83 out nocopy  DATE
    , p10_a84 out nocopy  DATE
    , p10_a85 out nocopy  DATE
    , p10_a86 out nocopy  DATE
    , p10_a87 out nocopy  NUMBER
    , p10_a88 out nocopy  NUMBER
    , p10_a89 out nocopy  NUMBER
    , p10_a90 out nocopy  VARCHAR2
    , p10_a91 out nocopy  NUMBER
    , p10_a92 out nocopy  VARCHAR2
    , p10_a93 out nocopy  NUMBER
    , p10_a94 out nocopy  NUMBER
    , p10_a95 out nocopy  DATE
    , p10_a96 out nocopy  VARCHAR2
    , p10_a97 out nocopy  VARCHAR2
    , p10_a98 out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  DATE := fnd_api.g_miss_date
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  DATE := fnd_api.g_miss_date
    , p8_a21  DATE := fnd_api.g_miss_date
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  DATE := fnd_api.g_miss_date
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  NUMBER := 0-1962.0724
    , p8_a28  NUMBER := 0-1962.0724
    , p8_a29  NUMBER := 0-1962.0724
    , p8_a30  NUMBER := 0-1962.0724
    , p8_a31  NUMBER := 0-1962.0724
    , p8_a32  NUMBER := 0-1962.0724
    , p8_a33  NUMBER := 0-1962.0724
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  DATE := fnd_api.g_miss_date
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  DATE := fnd_api.g_miss_date
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  DATE := fnd_api.g_miss_date
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  DATE := fnd_api.g_miss_date
    , p8_a48  DATE := fnd_api.g_miss_date
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  NUMBER := 0-1962.0724
    , p8_a58  DATE := fnd_api.g_miss_date
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  VARCHAR2 := fnd_api.g_miss_char
    , p8_a68  VARCHAR2 := fnd_api.g_miss_char
    , p8_a69  VARCHAR2 := fnd_api.g_miss_char
    , p8_a70  VARCHAR2 := fnd_api.g_miss_char
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  NUMBER := 0-1962.0724
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  DATE := fnd_api.g_miss_date
    , p8_a80  NUMBER := 0-1962.0724
    , p8_a81  DATE := fnd_api.g_miss_date
    , p8_a82  NUMBER := 0-1962.0724
    , p8_a83  DATE := fnd_api.g_miss_date
    , p8_a84  DATE := fnd_api.g_miss_date
    , p8_a85  DATE := fnd_api.g_miss_date
    , p8_a86  DATE := fnd_api.g_miss_date
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  VARCHAR2 := fnd_api.g_miss_char
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  NUMBER := 0-1962.0724
    , p8_a95  DATE := fnd_api.g_miss_date
    , p8_a96  VARCHAR2 := fnd_api.g_miss_char
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_create_kle_pub.clev_rec_type;
    ddp_klev_rec okl_create_kle_pub.klev_rec_type;
    ddx_clev_rec okl_create_kle_pub.clev_rec_type;
    ddx_klev_rec okl_create_kle_pub.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_clev_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_clev_rec.sfwt_flag := p7_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p7_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p7_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p7_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p7_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p7_a7);
    ddp_clev_rec.line_number := p7_a8;
    ddp_clev_rec.sts_code := p7_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p7_a10);
    ddp_clev_rec.trn_code := p7_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p7_a12);
    ddp_clev_rec.comments := p7_a13;
    ddp_clev_rec.item_description := p7_a14;
    ddp_clev_rec.oke_boe_description := p7_a15;
    ddp_clev_rec.cognomen := p7_a16;
    ddp_clev_rec.hidden_ind := p7_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p7_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p7_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p7_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p7_a21);
    ddp_clev_rec.price_level_ind := p7_a22;
    ddp_clev_rec.invoice_line_level_ind := p7_a23;
    ddp_clev_rec.dpas_rating := p7_a24;
    ddp_clev_rec.block23text := p7_a25;
    ddp_clev_rec.exception_yn := p7_a26;
    ddp_clev_rec.template_used := p7_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p7_a28);
    ddp_clev_rec.name := p7_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p7_a32);
    ddp_clev_rec.upg_orig_system_ref := p7_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a34);
    ddp_clev_rec.orig_system_source_code := p7_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p7_a36);
    ddp_clev_rec.orig_system_reference1 := p7_a37;
    ddp_clev_rec.attribute_category := p7_a38;
    ddp_clev_rec.attribute1 := p7_a39;
    ddp_clev_rec.attribute2 := p7_a40;
    ddp_clev_rec.attribute3 := p7_a41;
    ddp_clev_rec.attribute4 := p7_a42;
    ddp_clev_rec.attribute5 := p7_a43;
    ddp_clev_rec.attribute6 := p7_a44;
    ddp_clev_rec.attribute7 := p7_a45;
    ddp_clev_rec.attribute8 := p7_a46;
    ddp_clev_rec.attribute9 := p7_a47;
    ddp_clev_rec.attribute10 := p7_a48;
    ddp_clev_rec.attribute11 := p7_a49;
    ddp_clev_rec.attribute12 := p7_a50;
    ddp_clev_rec.attribute13 := p7_a51;
    ddp_clev_rec.attribute14 := p7_a52;
    ddp_clev_rec.attribute15 := p7_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p7_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p7_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p7_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a57);
    ddp_clev_rec.price_type := p7_a58;
    ddp_clev_rec.currency_code := p7_a59;
    ddp_clev_rec.currency_code_renewed := p7_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p7_a61);
    ddp_clev_rec.old_sts_code := p7_a62;
    ddp_clev_rec.new_sts_code := p7_a63;
    ddp_clev_rec.old_ste_code := p7_a64;
    ddp_clev_rec.new_ste_code := p7_a65;
    ddp_clev_rec.call_action_asmblr := p7_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p7_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p7_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p7_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p7_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p7_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p7_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p7_a74);
    ddp_clev_rec.item_to_price_yn := p7_a75;
    ddp_clev_rec.price_basis_yn := p7_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p7_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p7_a78);
    ddp_clev_rec.config_complete_yn := p7_a79;
    ddp_clev_rec.config_valid_yn := p7_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p7_a81);
    ddp_clev_rec.config_item_type := p7_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p7_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p7_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p7_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p7_a86);
    ddp_clev_rec.line_renewal_type_code := p7_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p7_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p7_a89);

    ddp_klev_rec.id := rosetta_g_miss_num_map(p8_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p8_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p8_a3);
    ddp_klev_rec.prc_code := p8_a4;
    ddp_klev_rec.fcg_code := p8_a5;
    ddp_klev_rec.nty_code := p8_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p8_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p8_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p8_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p8_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p8_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p8_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p8_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p8_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p8_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p8_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p8_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p8_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p8_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p8_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p8_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p8_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p8_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p8_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p8_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p8_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p8_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p8_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p8_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p8_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p8_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p8_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p8_a34);
    ddp_klev_rec.credit_tenant_yn := p8_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p8_a36);
    ddp_klev_rec.year_of_manufacture := p8_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p8_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p8_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p8_a40);
    ddp_klev_rec.prescribed_asset_yn := p8_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p8_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p8_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p8_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p8_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p8_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p8_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p8_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p8_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p8_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p8_a51);
    ddp_klev_rec.secured_deal_yn := p8_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p8_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p8_a54);
    ddp_klev_rec.re_lease_yn := p8_a55;
    ddp_klev_rec.previous_contract := p8_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p8_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p8_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p8_a59);
    ddp_klev_rec.attribute_category := p8_a60;
    ddp_klev_rec.attribute1 := p8_a61;
    ddp_klev_rec.attribute2 := p8_a62;
    ddp_klev_rec.attribute3 := p8_a63;
    ddp_klev_rec.attribute4 := p8_a64;
    ddp_klev_rec.attribute5 := p8_a65;
    ddp_klev_rec.attribute6 := p8_a66;
    ddp_klev_rec.attribute7 := p8_a67;
    ddp_klev_rec.attribute8 := p8_a68;
    ddp_klev_rec.attribute9 := p8_a69;
    ddp_klev_rec.attribute10 := p8_a70;
    ddp_klev_rec.attribute11 := p8_a71;
    ddp_klev_rec.attribute12 := p8_a72;
    ddp_klev_rec.attribute13 := p8_a73;
    ddp_klev_rec.attribute14 := p8_a74;
    ddp_klev_rec.attribute15 := p8_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p8_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p8_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p8_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p8_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p8_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p8_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p8_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p8_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p8_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p8_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p8_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p8_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p8_a89);
    ddp_klev_rec.residual_code := p8_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p8_a91);
    ddp_klev_rec.credit_nature := p8_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p8_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p8_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p8_a95);
    ddp_klev_rec.pay_investor_frequency := p8_a96;
    ddp_klev_rec.pay_investor_event := p8_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p8_a98);



    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.update_fin_cap_cost(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_rec,
      ddp_klev_rec,
      ddx_clev_rec,
      ddx_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_clev_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_clev_rec.object_version_number);
    p9_a2 := ddx_clev_rec.sfwt_flag;
    p9_a3 := rosetta_g_miss_num_map(ddx_clev_rec.chr_id);
    p9_a4 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id);
    p9_a5 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed);
    p9_a6 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed_to);
    p9_a7 := rosetta_g_miss_num_map(ddx_clev_rec.lse_id);
    p9_a8 := ddx_clev_rec.line_number;
    p9_a9 := ddx_clev_rec.sts_code;
    p9_a10 := rosetta_g_miss_num_map(ddx_clev_rec.display_sequence);
    p9_a11 := ddx_clev_rec.trn_code;
    p9_a12 := rosetta_g_miss_num_map(ddx_clev_rec.dnz_chr_id);
    p9_a13 := ddx_clev_rec.comments;
    p9_a14 := ddx_clev_rec.item_description;
    p9_a15 := ddx_clev_rec.oke_boe_description;
    p9_a16 := ddx_clev_rec.cognomen;
    p9_a17 := ddx_clev_rec.hidden_ind;
    p9_a18 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit);
    p9_a19 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit_percent);
    p9_a20 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated);
    p9_a21 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated_renewed);
    p9_a22 := ddx_clev_rec.price_level_ind;
    p9_a23 := ddx_clev_rec.invoice_line_level_ind;
    p9_a24 := ddx_clev_rec.dpas_rating;
    p9_a25 := ddx_clev_rec.block23text;
    p9_a26 := ddx_clev_rec.exception_yn;
    p9_a27 := ddx_clev_rec.template_used;
    p9_a28 := ddx_clev_rec.date_terminated;
    p9_a29 := ddx_clev_rec.name;
    p9_a30 := ddx_clev_rec.start_date;
    p9_a31 := ddx_clev_rec.end_date;
    p9_a32 := ddx_clev_rec.date_renewed;
    p9_a33 := ddx_clev_rec.upg_orig_system_ref;
    p9_a34 := rosetta_g_miss_num_map(ddx_clev_rec.upg_orig_system_ref_id);
    p9_a35 := ddx_clev_rec.orig_system_source_code;
    p9_a36 := rosetta_g_miss_num_map(ddx_clev_rec.orig_system_id1);
    p9_a37 := ddx_clev_rec.orig_system_reference1;
    p9_a38 := ddx_clev_rec.attribute_category;
    p9_a39 := ddx_clev_rec.attribute1;
    p9_a40 := ddx_clev_rec.attribute2;
    p9_a41 := ddx_clev_rec.attribute3;
    p9_a42 := ddx_clev_rec.attribute4;
    p9_a43 := ddx_clev_rec.attribute5;
    p9_a44 := ddx_clev_rec.attribute6;
    p9_a45 := ddx_clev_rec.attribute7;
    p9_a46 := ddx_clev_rec.attribute8;
    p9_a47 := ddx_clev_rec.attribute9;
    p9_a48 := ddx_clev_rec.attribute10;
    p9_a49 := ddx_clev_rec.attribute11;
    p9_a50 := ddx_clev_rec.attribute12;
    p9_a51 := ddx_clev_rec.attribute13;
    p9_a52 := ddx_clev_rec.attribute14;
    p9_a53 := ddx_clev_rec.attribute15;
    p9_a54 := rosetta_g_miss_num_map(ddx_clev_rec.created_by);
    p9_a55 := ddx_clev_rec.creation_date;
    p9_a56 := rosetta_g_miss_num_map(ddx_clev_rec.last_updated_by);
    p9_a57 := ddx_clev_rec.last_update_date;
    p9_a58 := ddx_clev_rec.price_type;
    p9_a59 := ddx_clev_rec.currency_code;
    p9_a60 := ddx_clev_rec.currency_code_renewed;
    p9_a61 := rosetta_g_miss_num_map(ddx_clev_rec.last_update_login);
    p9_a62 := ddx_clev_rec.old_sts_code;
    p9_a63 := ddx_clev_rec.new_sts_code;
    p9_a64 := ddx_clev_rec.old_ste_code;
    p9_a65 := ddx_clev_rec.new_ste_code;
    p9_a66 := ddx_clev_rec.call_action_asmblr;
    p9_a67 := rosetta_g_miss_num_map(ddx_clev_rec.request_id);
    p9_a68 := rosetta_g_miss_num_map(ddx_clev_rec.program_application_id);
    p9_a69 := rosetta_g_miss_num_map(ddx_clev_rec.program_id);
    p9_a70 := ddx_clev_rec.program_update_date;
    p9_a71 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_id);
    p9_a72 := ddx_clev_rec.pricing_date;
    p9_a73 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_line_id);
    p9_a74 := rosetta_g_miss_num_map(ddx_clev_rec.line_list_price);
    p9_a75 := ddx_clev_rec.item_to_price_yn;
    p9_a76 := ddx_clev_rec.price_basis_yn;
    p9_a77 := rosetta_g_miss_num_map(ddx_clev_rec.config_header_id);
    p9_a78 := rosetta_g_miss_num_map(ddx_clev_rec.config_revision_number);
    p9_a79 := ddx_clev_rec.config_complete_yn;
    p9_a80 := ddx_clev_rec.config_valid_yn;
    p9_a81 := rosetta_g_miss_num_map(ddx_clev_rec.config_top_model_line_id);
    p9_a82 := ddx_clev_rec.config_item_type;
    p9_a83 := rosetta_g_miss_num_map(ddx_clev_rec.config_item_id);
    p9_a84 := rosetta_g_miss_num_map(ddx_clev_rec.cust_acct_id);
    p9_a85 := rosetta_g_miss_num_map(ddx_clev_rec.bill_to_site_use_id);
    p9_a86 := rosetta_g_miss_num_map(ddx_clev_rec.inv_rule_id);
    p9_a87 := ddx_clev_rec.line_renewal_type_code;
    p9_a88 := rosetta_g_miss_num_map(ddx_clev_rec.ship_to_site_use_id);
    p9_a89 := rosetta_g_miss_num_map(ddx_clev_rec.payment_term_id);

    p10_a0 := rosetta_g_miss_num_map(ddx_klev_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_klev_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_klev_rec.kle_id);
    p10_a3 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id);
    p10_a4 := ddx_klev_rec.prc_code;
    p10_a5 := ddx_klev_rec.fcg_code;
    p10_a6 := ddx_klev_rec.nty_code;
    p10_a7 := rosetta_g_miss_num_map(ddx_klev_rec.estimated_oec);
    p10_a8 := rosetta_g_miss_num_map(ddx_klev_rec.lao_amount);
    p10_a9 := ddx_klev_rec.title_date;
    p10_a10 := rosetta_g_miss_num_map(ddx_klev_rec.fee_charge);
    p10_a11 := rosetta_g_miss_num_map(ddx_klev_rec.lrs_percent);
    p10_a12 := rosetta_g_miss_num_map(ddx_klev_rec.initial_direct_cost);
    p10_a13 := rosetta_g_miss_num_map(ddx_klev_rec.percent_stake);
    p10_a14 := rosetta_g_miss_num_map(ddx_klev_rec.percent);
    p10_a15 := rosetta_g_miss_num_map(ddx_klev_rec.evergreen_percent);
    p10_a16 := rosetta_g_miss_num_map(ddx_klev_rec.amount_stake);
    p10_a17 := rosetta_g_miss_num_map(ddx_klev_rec.occupancy);
    p10_a18 := rosetta_g_miss_num_map(ddx_klev_rec.coverage);
    p10_a19 := rosetta_g_miss_num_map(ddx_klev_rec.residual_percentage);
    p10_a20 := ddx_klev_rec.date_last_inspection;
    p10_a21 := ddx_klev_rec.date_sold;
    p10_a22 := rosetta_g_miss_num_map(ddx_klev_rec.lrv_amount);
    p10_a23 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction);
    p10_a24 := ddx_klev_rec.date_next_inspection_due;
    p10_a25 := ddx_klev_rec.date_residual_last_review;
    p10_a26 := ddx_klev_rec.date_last_reamortisation;
    p10_a27 := rosetta_g_miss_num_map(ddx_klev_rec.vendor_advance_paid);
    p10_a28 := rosetta_g_miss_num_map(ddx_klev_rec.weighted_average_life);
    p10_a29 := rosetta_g_miss_num_map(ddx_klev_rec.tradein_amount);
    p10_a30 := rosetta_g_miss_num_map(ddx_klev_rec.bond_equivalent_yield);
    p10_a31 := rosetta_g_miss_num_map(ddx_klev_rec.termination_purchase_amount);
    p10_a32 := rosetta_g_miss_num_map(ddx_klev_rec.refinance_amount);
    p10_a33 := rosetta_g_miss_num_map(ddx_klev_rec.year_built);
    p10_a34 := ddx_klev_rec.delivered_date;
    p10_a35 := ddx_klev_rec.credit_tenant_yn;
    p10_a36 := ddx_klev_rec.date_last_cleanup;
    p10_a37 := ddx_klev_rec.year_of_manufacture;
    p10_a38 := rosetta_g_miss_num_map(ddx_klev_rec.coverage_ratio);
    p10_a39 := rosetta_g_miss_num_map(ddx_klev_rec.remarketed_amount);
    p10_a40 := rosetta_g_miss_num_map(ddx_klev_rec.gross_square_footage);
    p10_a41 := ddx_klev_rec.prescribed_asset_yn;
    p10_a42 := ddx_klev_rec.date_remarketed;
    p10_a43 := rosetta_g_miss_num_map(ddx_klev_rec.net_rentable);
    p10_a44 := rosetta_g_miss_num_map(ddx_klev_rec.remarket_margin);
    p10_a45 := ddx_klev_rec.date_letter_acceptance;
    p10_a46 := rosetta_g_miss_num_map(ddx_klev_rec.repurchased_amount);
    p10_a47 := ddx_klev_rec.date_commitment_expiration;
    p10_a48 := ddx_klev_rec.date_repurchased;
    p10_a49 := ddx_klev_rec.date_appraisal;
    p10_a50 := rosetta_g_miss_num_map(ddx_klev_rec.residual_value);
    p10_a51 := rosetta_g_miss_num_map(ddx_klev_rec.appraisal_value);
    p10_a52 := ddx_klev_rec.secured_deal_yn;
    p10_a53 := rosetta_g_miss_num_map(ddx_klev_rec.gain_loss);
    p10_a54 := rosetta_g_miss_num_map(ddx_klev_rec.floor_amount);
    p10_a55 := ddx_klev_rec.re_lease_yn;
    p10_a56 := ddx_klev_rec.previous_contract;
    p10_a57 := rosetta_g_miss_num_map(ddx_klev_rec.tracked_residual);
    p10_a58 := ddx_klev_rec.date_title_received;
    p10_a59 := rosetta_g_miss_num_map(ddx_klev_rec.amount);
    p10_a60 := ddx_klev_rec.attribute_category;
    p10_a61 := ddx_klev_rec.attribute1;
    p10_a62 := ddx_klev_rec.attribute2;
    p10_a63 := ddx_klev_rec.attribute3;
    p10_a64 := ddx_klev_rec.attribute4;
    p10_a65 := ddx_klev_rec.attribute5;
    p10_a66 := ddx_klev_rec.attribute6;
    p10_a67 := ddx_klev_rec.attribute7;
    p10_a68 := ddx_klev_rec.attribute8;
    p10_a69 := ddx_klev_rec.attribute9;
    p10_a70 := ddx_klev_rec.attribute10;
    p10_a71 := ddx_klev_rec.attribute11;
    p10_a72 := ddx_klev_rec.attribute12;
    p10_a73 := ddx_klev_rec.attribute13;
    p10_a74 := ddx_klev_rec.attribute14;
    p10_a75 := ddx_klev_rec.attribute15;
    p10_a76 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id_for);
    p10_a77 := rosetta_g_miss_num_map(ddx_klev_rec.clg_id);
    p10_a78 := rosetta_g_miss_num_map(ddx_klev_rec.created_by);
    p10_a79 := ddx_klev_rec.creation_date;
    p10_a80 := rosetta_g_miss_num_map(ddx_klev_rec.last_updated_by);
    p10_a81 := ddx_klev_rec.last_update_date;
    p10_a82 := rosetta_g_miss_num_map(ddx_klev_rec.last_update_login);
    p10_a83 := ddx_klev_rec.date_funding;
    p10_a84 := ddx_klev_rec.date_funding_required;
    p10_a85 := ddx_klev_rec.date_accepted;
    p10_a86 := ddx_klev_rec.date_delivery_expected;
    p10_a87 := rosetta_g_miss_num_map(ddx_klev_rec.oec);
    p10_a88 := rosetta_g_miss_num_map(ddx_klev_rec.capital_amount);
    p10_a89 := rosetta_g_miss_num_map(ddx_klev_rec.residual_grnty_amount);
    p10_a90 := ddx_klev_rec.residual_code;
    p10_a91 := rosetta_g_miss_num_map(ddx_klev_rec.rvi_premium);
    p10_a92 := ddx_klev_rec.credit_nature;
    p10_a93 := rosetta_g_miss_num_map(ddx_klev_rec.capitalized_interest);
    p10_a94 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction_percent);
    p10_a95 := ddx_klev_rec.date_pay_investor_start;
    p10_a96 := ddx_klev_rec.pay_investor_frequency;
    p10_a97 := ddx_klev_rec.pay_investor_event;
    p10_a98 := rosetta_g_miss_num_map(ddx_klev_rec.pay_investor_remittance_days);
  end;

  procedure create_add_on_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_DATE_TABLE
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_DATE_TABLE
    , p8_a27 JTF_NUMBER_TABLE
    , p8_a28 JTF_NUMBER_TABLE
    , p8_a29 JTF_NUMBER_TABLE
    , p8_a30 JTF_NUMBER_TABLE
    , p8_a31 JTF_NUMBER_TABLE
    , p8_a32 JTF_NUMBER_TABLE
    , p8_a33 JTF_NUMBER_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_VARCHAR2_TABLE_100
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_DATE_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_DATE_TABLE
    , p8_a48 JTF_DATE_TABLE
    , p8_a49 JTF_DATE_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_VARCHAR2_TABLE_100
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_VARCHAR2_TABLE_100
    , p8_a56 JTF_VARCHAR2_TABLE_100
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_DATE_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_VARCHAR2_TABLE_100
    , p8_a61 JTF_VARCHAR2_TABLE_500
    , p8_a62 JTF_VARCHAR2_TABLE_500
    , p8_a63 JTF_VARCHAR2_TABLE_500
    , p8_a64 JTF_VARCHAR2_TABLE_500
    , p8_a65 JTF_VARCHAR2_TABLE_500
    , p8_a66 JTF_VARCHAR2_TABLE_500
    , p8_a67 JTF_VARCHAR2_TABLE_500
    , p8_a68 JTF_VARCHAR2_TABLE_500
    , p8_a69 JTF_VARCHAR2_TABLE_500
    , p8_a70 JTF_VARCHAR2_TABLE_500
    , p8_a71 JTF_VARCHAR2_TABLE_500
    , p8_a72 JTF_VARCHAR2_TABLE_500
    , p8_a73 JTF_VARCHAR2_TABLE_500
    , p8_a74 JTF_VARCHAR2_TABLE_500
    , p8_a75 JTF_VARCHAR2_TABLE_500
    , p8_a76 JTF_NUMBER_TABLE
    , p8_a77 JTF_NUMBER_TABLE
    , p8_a78 JTF_NUMBER_TABLE
    , p8_a79 JTF_DATE_TABLE
    , p8_a80 JTF_NUMBER_TABLE
    , p8_a81 JTF_DATE_TABLE
    , p8_a82 JTF_NUMBER_TABLE
    , p8_a83 JTF_DATE_TABLE
    , p8_a84 JTF_DATE_TABLE
    , p8_a85 JTF_DATE_TABLE
    , p8_a86 JTF_DATE_TABLE
    , p8_a87 JTF_NUMBER_TABLE
    , p8_a88 JTF_NUMBER_TABLE
    , p8_a89 JTF_NUMBER_TABLE
    , p8_a90 JTF_VARCHAR2_TABLE_100
    , p8_a91 JTF_NUMBER_TABLE
    , p8_a92 JTF_VARCHAR2_TABLE_100
    , p8_a93 JTF_NUMBER_TABLE
    , p8_a94 JTF_NUMBER_TABLE
    , p8_a95 JTF_DATE_TABLE
    , p8_a96 JTF_VARCHAR2_TABLE_100
    , p8_a97 JTF_VARCHAR2_TABLE_100
    , p8_a98 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_DATE_TABLE
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_DATE_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_DATE_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_DATE_TABLE
    , p11_a21 out nocopy JTF_DATE_TABLE
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_NUMBER_TABLE
    , p11_a24 out nocopy JTF_DATE_TABLE
    , p11_a25 out nocopy JTF_DATE_TABLE
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_NUMBER_TABLE
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p11_a29 out nocopy JTF_NUMBER_TABLE
    , p11_a30 out nocopy JTF_NUMBER_TABLE
    , p11_a31 out nocopy JTF_NUMBER_TABLE
    , p11_a32 out nocopy JTF_NUMBER_TABLE
    , p11_a33 out nocopy JTF_NUMBER_TABLE
    , p11_a34 out nocopy JTF_DATE_TABLE
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a38 out nocopy JTF_NUMBER_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a42 out nocopy JTF_DATE_TABLE
    , p11_a43 out nocopy JTF_NUMBER_TABLE
    , p11_a44 out nocopy JTF_NUMBER_TABLE
    , p11_a45 out nocopy JTF_DATE_TABLE
    , p11_a46 out nocopy JTF_NUMBER_TABLE
    , p11_a47 out nocopy JTF_DATE_TABLE
    , p11_a48 out nocopy JTF_DATE_TABLE
    , p11_a49 out nocopy JTF_DATE_TABLE
    , p11_a50 out nocopy JTF_NUMBER_TABLE
    , p11_a51 out nocopy JTF_NUMBER_TABLE
    , p11_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a53 out nocopy JTF_NUMBER_TABLE
    , p11_a54 out nocopy JTF_NUMBER_TABLE
    , p11_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a57 out nocopy JTF_NUMBER_TABLE
    , p11_a58 out nocopy JTF_DATE_TABLE
    , p11_a59 out nocopy JTF_NUMBER_TABLE
    , p11_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a76 out nocopy JTF_NUMBER_TABLE
    , p11_a77 out nocopy JTF_NUMBER_TABLE
    , p11_a78 out nocopy JTF_NUMBER_TABLE
    , p11_a79 out nocopy JTF_DATE_TABLE
    , p11_a80 out nocopy JTF_NUMBER_TABLE
    , p11_a81 out nocopy JTF_DATE_TABLE
    , p11_a82 out nocopy JTF_NUMBER_TABLE
    , p11_a83 out nocopy JTF_DATE_TABLE
    , p11_a84 out nocopy JTF_DATE_TABLE
    , p11_a85 out nocopy JTF_DATE_TABLE
    , p11_a86 out nocopy JTF_DATE_TABLE
    , p11_a87 out nocopy JTF_NUMBER_TABLE
    , p11_a88 out nocopy JTF_NUMBER_TABLE
    , p11_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a91 out nocopy JTF_NUMBER_TABLE
    , p11_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a93 out nocopy JTF_NUMBER_TABLE
    , p11_a94 out nocopy JTF_NUMBER_TABLE
    , p11_a95 out nocopy JTF_DATE_TABLE
    , p11_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a98 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  NUMBER
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  NUMBER
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  NUMBER
    , p12_a19 out nocopy  NUMBER
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  NUMBER
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  DATE
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  DATE
    , p12_a31 out nocopy  DATE
    , p12_a32 out nocopy  DATE
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , p12_a45 out nocopy  VARCHAR2
    , p12_a46 out nocopy  VARCHAR2
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  VARCHAR2
    , p12_a50 out nocopy  VARCHAR2
    , p12_a51 out nocopy  VARCHAR2
    , p12_a52 out nocopy  VARCHAR2
    , p12_a53 out nocopy  VARCHAR2
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  DATE
    , p12_a56 out nocopy  NUMBER
    , p12_a57 out nocopy  DATE
    , p12_a58 out nocopy  VARCHAR2
    , p12_a59 out nocopy  VARCHAR2
    , p12_a60 out nocopy  VARCHAR2
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  VARCHAR2
    , p12_a63 out nocopy  VARCHAR2
    , p12_a64 out nocopy  VARCHAR2
    , p12_a65 out nocopy  VARCHAR2
    , p12_a66 out nocopy  VARCHAR2
    , p12_a67 out nocopy  NUMBER
    , p12_a68 out nocopy  NUMBER
    , p12_a69 out nocopy  NUMBER
    , p12_a70 out nocopy  DATE
    , p12_a71 out nocopy  NUMBER
    , p12_a72 out nocopy  DATE
    , p12_a73 out nocopy  NUMBER
    , p12_a74 out nocopy  NUMBER
    , p12_a75 out nocopy  VARCHAR2
    , p12_a76 out nocopy  VARCHAR2
    , p12_a77 out nocopy  NUMBER
    , p12_a78 out nocopy  NUMBER
    , p12_a79 out nocopy  VARCHAR2
    , p12_a80 out nocopy  VARCHAR2
    , p12_a81 out nocopy  NUMBER
    , p12_a82 out nocopy  VARCHAR2
    , p12_a83 out nocopy  NUMBER
    , p12_a84 out nocopy  NUMBER
    , p12_a85 out nocopy  NUMBER
    , p12_a86 out nocopy  NUMBER
    , p12_a87 out nocopy  VARCHAR2
    , p12_a88 out nocopy  NUMBER
    , p12_a89 out nocopy  NUMBER
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  VARCHAR2
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  NUMBER
    , p13_a8 out nocopy  NUMBER
    , p13_a9 out nocopy  DATE
    , p13_a10 out nocopy  NUMBER
    , p13_a11 out nocopy  NUMBER
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  NUMBER
    , p13_a14 out nocopy  NUMBER
    , p13_a15 out nocopy  NUMBER
    , p13_a16 out nocopy  NUMBER
    , p13_a17 out nocopy  NUMBER
    , p13_a18 out nocopy  NUMBER
    , p13_a19 out nocopy  NUMBER
    , p13_a20 out nocopy  DATE
    , p13_a21 out nocopy  DATE
    , p13_a22 out nocopy  NUMBER
    , p13_a23 out nocopy  NUMBER
    , p13_a24 out nocopy  DATE
    , p13_a25 out nocopy  DATE
    , p13_a26 out nocopy  DATE
    , p13_a27 out nocopy  NUMBER
    , p13_a28 out nocopy  NUMBER
    , p13_a29 out nocopy  NUMBER
    , p13_a30 out nocopy  NUMBER
    , p13_a31 out nocopy  NUMBER
    , p13_a32 out nocopy  NUMBER
    , p13_a33 out nocopy  NUMBER
    , p13_a34 out nocopy  DATE
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  DATE
    , p13_a37 out nocopy  VARCHAR2
    , p13_a38 out nocopy  NUMBER
    , p13_a39 out nocopy  NUMBER
    , p13_a40 out nocopy  NUMBER
    , p13_a41 out nocopy  VARCHAR2
    , p13_a42 out nocopy  DATE
    , p13_a43 out nocopy  NUMBER
    , p13_a44 out nocopy  NUMBER
    , p13_a45 out nocopy  DATE
    , p13_a46 out nocopy  NUMBER
    , p13_a47 out nocopy  DATE
    , p13_a48 out nocopy  DATE
    , p13_a49 out nocopy  DATE
    , p13_a50 out nocopy  NUMBER
    , p13_a51 out nocopy  NUMBER
    , p13_a52 out nocopy  VARCHAR2
    , p13_a53 out nocopy  NUMBER
    , p13_a54 out nocopy  NUMBER
    , p13_a55 out nocopy  VARCHAR2
    , p13_a56 out nocopy  VARCHAR2
    , p13_a57 out nocopy  NUMBER
    , p13_a58 out nocopy  DATE
    , p13_a59 out nocopy  NUMBER
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  VARCHAR2
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p13_a66 out nocopy  VARCHAR2
    , p13_a67 out nocopy  VARCHAR2
    , p13_a68 out nocopy  VARCHAR2
    , p13_a69 out nocopy  VARCHAR2
    , p13_a70 out nocopy  VARCHAR2
    , p13_a71 out nocopy  VARCHAR2
    , p13_a72 out nocopy  VARCHAR2
    , p13_a73 out nocopy  VARCHAR2
    , p13_a74 out nocopy  VARCHAR2
    , p13_a75 out nocopy  VARCHAR2
    , p13_a76 out nocopy  NUMBER
    , p13_a77 out nocopy  NUMBER
    , p13_a78 out nocopy  NUMBER
    , p13_a79 out nocopy  DATE
    , p13_a80 out nocopy  NUMBER
    , p13_a81 out nocopy  DATE
    , p13_a82 out nocopy  NUMBER
    , p13_a83 out nocopy  DATE
    , p13_a84 out nocopy  DATE
    , p13_a85 out nocopy  DATE
    , p13_a86 out nocopy  DATE
    , p13_a87 out nocopy  NUMBER
    , p13_a88 out nocopy  NUMBER
    , p13_a89 out nocopy  NUMBER
    , p13_a90 out nocopy  VARCHAR2
    , p13_a91 out nocopy  NUMBER
    , p13_a92 out nocopy  VARCHAR2
    , p13_a93 out nocopy  NUMBER
    , p13_a94 out nocopy  NUMBER
    , p13_a95 out nocopy  DATE
    , p13_a96 out nocopy  VARCHAR2
    , p13_a97 out nocopy  VARCHAR2
    , p13_a98 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_NUMBER_TABLE
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_NUMBER_TABLE
    , p14_a16 out nocopy JTF_DATE_TABLE
    , p14_a17 out nocopy JTF_NUMBER_TABLE
    , p14_a18 out nocopy JTF_DATE_TABLE
    , p14_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_create_kle_pub.clev_tbl_type;
    ddp_klev_tbl okl_create_kle_pub.klev_tbl_type;
    ddp_cimv_tbl okl_create_kle_pub.cimv_tbl_type;
    ddx_clev_tbl okl_create_kle_pub.clev_tbl_type;
    ddx_klev_tbl okl_create_kle_pub.klev_tbl_type;
    ddx_fin_clev_rec okl_create_kle_pub.clev_rec_type;
    ddx_fin_klev_rec okl_create_kle_pub.klev_rec_type;
    ddx_cimv_tbl okl_create_kle_pub.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p7_a0
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
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p8_a0
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
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      , p8_a90
      , p8_a91
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p9_a0
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
      );






    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.create_add_on_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddp_cimv_tbl,
      ddx_clev_tbl,
      ddx_klev_tbl,
      ddx_fin_clev_rec,
      ddx_fin_klev_rec,
      ddx_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p10_a0
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
      , p10_a58
      , p10_a59
      , p10_a60
      , p10_a61
      , p10_a62
      , p10_a63
      , p10_a64
      , p10_a65
      , p10_a66
      , p10_a67
      , p10_a68
      , p10_a69
      , p10_a70
      , p10_a71
      , p10_a72
      , p10_a73
      , p10_a74
      , p10_a75
      , p10_a76
      , p10_a77
      , p10_a78
      , p10_a79
      , p10_a80
      , p10_a81
      , p10_a82
      , p10_a83
      , p10_a84
      , p10_a85
      , p10_a86
      , p10_a87
      , p10_a88
      , p10_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      , p11_a48
      , p11_a49
      , p11_a50
      , p11_a51
      , p11_a52
      , p11_a53
      , p11_a54
      , p11_a55
      , p11_a56
      , p11_a57
      , p11_a58
      , p11_a59
      , p11_a60
      , p11_a61
      , p11_a62
      , p11_a63
      , p11_a64
      , p11_a65
      , p11_a66
      , p11_a67
      , p11_a68
      , p11_a69
      , p11_a70
      , p11_a71
      , p11_a72
      , p11_a73
      , p11_a74
      , p11_a75
      , p11_a76
      , p11_a77
      , p11_a78
      , p11_a79
      , p11_a80
      , p11_a81
      , p11_a82
      , p11_a83
      , p11_a84
      , p11_a85
      , p11_a86
      , p11_a87
      , p11_a88
      , p11_a89
      , p11_a90
      , p11_a91
      , p11_a92
      , p11_a93
      , p11_a94
      , p11_a95
      , p11_a96
      , p11_a97
      , p11_a98
      );

    p12_a0 := rosetta_g_miss_num_map(ddx_fin_clev_rec.id);
    p12_a1 := rosetta_g_miss_num_map(ddx_fin_clev_rec.object_version_number);
    p12_a2 := ddx_fin_clev_rec.sfwt_flag;
    p12_a3 := rosetta_g_miss_num_map(ddx_fin_clev_rec.chr_id);
    p12_a4 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id);
    p12_a5 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id_renewed);
    p12_a6 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id_renewed_to);
    p12_a7 := rosetta_g_miss_num_map(ddx_fin_clev_rec.lse_id);
    p12_a8 := ddx_fin_clev_rec.line_number;
    p12_a9 := ddx_fin_clev_rec.sts_code;
    p12_a10 := rosetta_g_miss_num_map(ddx_fin_clev_rec.display_sequence);
    p12_a11 := ddx_fin_clev_rec.trn_code;
    p12_a12 := rosetta_g_miss_num_map(ddx_fin_clev_rec.dnz_chr_id);
    p12_a13 := ddx_fin_clev_rec.comments;
    p12_a14 := ddx_fin_clev_rec.item_description;
    p12_a15 := ddx_fin_clev_rec.oke_boe_description;
    p12_a16 := ddx_fin_clev_rec.cognomen;
    p12_a17 := ddx_fin_clev_rec.hidden_ind;
    p12_a18 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_unit);
    p12_a19 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_unit_percent);
    p12_a20 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_negotiated);
    p12_a21 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_negotiated_renewed);
    p12_a22 := ddx_fin_clev_rec.price_level_ind;
    p12_a23 := ddx_fin_clev_rec.invoice_line_level_ind;
    p12_a24 := ddx_fin_clev_rec.dpas_rating;
    p12_a25 := ddx_fin_clev_rec.block23text;
    p12_a26 := ddx_fin_clev_rec.exception_yn;
    p12_a27 := ddx_fin_clev_rec.template_used;
    p12_a28 := ddx_fin_clev_rec.date_terminated;
    p12_a29 := ddx_fin_clev_rec.name;
    p12_a30 := ddx_fin_clev_rec.start_date;
    p12_a31 := ddx_fin_clev_rec.end_date;
    p12_a32 := ddx_fin_clev_rec.date_renewed;
    p12_a33 := ddx_fin_clev_rec.upg_orig_system_ref;
    p12_a34 := rosetta_g_miss_num_map(ddx_fin_clev_rec.upg_orig_system_ref_id);
    p12_a35 := ddx_fin_clev_rec.orig_system_source_code;
    p12_a36 := rosetta_g_miss_num_map(ddx_fin_clev_rec.orig_system_id1);
    p12_a37 := ddx_fin_clev_rec.orig_system_reference1;
    p12_a38 := ddx_fin_clev_rec.attribute_category;
    p12_a39 := ddx_fin_clev_rec.attribute1;
    p12_a40 := ddx_fin_clev_rec.attribute2;
    p12_a41 := ddx_fin_clev_rec.attribute3;
    p12_a42 := ddx_fin_clev_rec.attribute4;
    p12_a43 := ddx_fin_clev_rec.attribute5;
    p12_a44 := ddx_fin_clev_rec.attribute6;
    p12_a45 := ddx_fin_clev_rec.attribute7;
    p12_a46 := ddx_fin_clev_rec.attribute8;
    p12_a47 := ddx_fin_clev_rec.attribute9;
    p12_a48 := ddx_fin_clev_rec.attribute10;
    p12_a49 := ddx_fin_clev_rec.attribute11;
    p12_a50 := ddx_fin_clev_rec.attribute12;
    p12_a51 := ddx_fin_clev_rec.attribute13;
    p12_a52 := ddx_fin_clev_rec.attribute14;
    p12_a53 := ddx_fin_clev_rec.attribute15;
    p12_a54 := rosetta_g_miss_num_map(ddx_fin_clev_rec.created_by);
    p12_a55 := ddx_fin_clev_rec.creation_date;
    p12_a56 := rosetta_g_miss_num_map(ddx_fin_clev_rec.last_updated_by);
    p12_a57 := ddx_fin_clev_rec.last_update_date;
    p12_a58 := ddx_fin_clev_rec.price_type;
    p12_a59 := ddx_fin_clev_rec.currency_code;
    p12_a60 := ddx_fin_clev_rec.currency_code_renewed;
    p12_a61 := rosetta_g_miss_num_map(ddx_fin_clev_rec.last_update_login);
    p12_a62 := ddx_fin_clev_rec.old_sts_code;
    p12_a63 := ddx_fin_clev_rec.new_sts_code;
    p12_a64 := ddx_fin_clev_rec.old_ste_code;
    p12_a65 := ddx_fin_clev_rec.new_ste_code;
    p12_a66 := ddx_fin_clev_rec.call_action_asmblr;
    p12_a67 := rosetta_g_miss_num_map(ddx_fin_clev_rec.request_id);
    p12_a68 := rosetta_g_miss_num_map(ddx_fin_clev_rec.program_application_id);
    p12_a69 := rosetta_g_miss_num_map(ddx_fin_clev_rec.program_id);
    p12_a70 := ddx_fin_clev_rec.program_update_date;
    p12_a71 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_list_id);
    p12_a72 := ddx_fin_clev_rec.pricing_date;
    p12_a73 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_list_line_id);
    p12_a74 := rosetta_g_miss_num_map(ddx_fin_clev_rec.line_list_price);
    p12_a75 := ddx_fin_clev_rec.item_to_price_yn;
    p12_a76 := ddx_fin_clev_rec.price_basis_yn;
    p12_a77 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_header_id);
    p12_a78 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_revision_number);
    p12_a79 := ddx_fin_clev_rec.config_complete_yn;
    p12_a80 := ddx_fin_clev_rec.config_valid_yn;
    p12_a81 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_top_model_line_id);
    p12_a82 := ddx_fin_clev_rec.config_item_type;
    p12_a83 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_item_id);
    p12_a84 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cust_acct_id);
    p12_a85 := rosetta_g_miss_num_map(ddx_fin_clev_rec.bill_to_site_use_id);
    p12_a86 := rosetta_g_miss_num_map(ddx_fin_clev_rec.inv_rule_id);
    p12_a87 := ddx_fin_clev_rec.line_renewal_type_code;
    p12_a88 := rosetta_g_miss_num_map(ddx_fin_clev_rec.ship_to_site_use_id);
    p12_a89 := rosetta_g_miss_num_map(ddx_fin_clev_rec.payment_term_id);

    p13_a0 := rosetta_g_miss_num_map(ddx_fin_klev_rec.id);
    p13_a1 := rosetta_g_miss_num_map(ddx_fin_klev_rec.object_version_number);
    p13_a2 := rosetta_g_miss_num_map(ddx_fin_klev_rec.kle_id);
    p13_a3 := rosetta_g_miss_num_map(ddx_fin_klev_rec.sty_id);
    p13_a4 := ddx_fin_klev_rec.prc_code;
    p13_a5 := ddx_fin_klev_rec.fcg_code;
    p13_a6 := ddx_fin_klev_rec.nty_code;
    p13_a7 := rosetta_g_miss_num_map(ddx_fin_klev_rec.estimated_oec);
    p13_a8 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lao_amount);
    p13_a9 := ddx_fin_klev_rec.title_date;
    p13_a10 := rosetta_g_miss_num_map(ddx_fin_klev_rec.fee_charge);
    p13_a11 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lrs_percent);
    p13_a12 := rosetta_g_miss_num_map(ddx_fin_klev_rec.initial_direct_cost);
    p13_a13 := rosetta_g_miss_num_map(ddx_fin_klev_rec.percent_stake);
    p13_a14 := rosetta_g_miss_num_map(ddx_fin_klev_rec.percent);
    p13_a15 := rosetta_g_miss_num_map(ddx_fin_klev_rec.evergreen_percent);
    p13_a16 := rosetta_g_miss_num_map(ddx_fin_klev_rec.amount_stake);
    p13_a17 := rosetta_g_miss_num_map(ddx_fin_klev_rec.occupancy);
    p13_a18 := rosetta_g_miss_num_map(ddx_fin_klev_rec.coverage);
    p13_a19 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_percentage);
    p13_a20 := ddx_fin_klev_rec.date_last_inspection;
    p13_a21 := ddx_fin_klev_rec.date_sold;
    p13_a22 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lrv_amount);
    p13_a23 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_reduction);
    p13_a24 := ddx_fin_klev_rec.date_next_inspection_due;
    p13_a25 := ddx_fin_klev_rec.date_residual_last_review;
    p13_a26 := ddx_fin_klev_rec.date_last_reamortisation;
    p13_a27 := rosetta_g_miss_num_map(ddx_fin_klev_rec.vendor_advance_paid);
    p13_a28 := rosetta_g_miss_num_map(ddx_fin_klev_rec.weighted_average_life);
    p13_a29 := rosetta_g_miss_num_map(ddx_fin_klev_rec.tradein_amount);
    p13_a30 := rosetta_g_miss_num_map(ddx_fin_klev_rec.bond_equivalent_yield);
    p13_a31 := rosetta_g_miss_num_map(ddx_fin_klev_rec.termination_purchase_amount);
    p13_a32 := rosetta_g_miss_num_map(ddx_fin_klev_rec.refinance_amount);
    p13_a33 := rosetta_g_miss_num_map(ddx_fin_klev_rec.year_built);
    p13_a34 := ddx_fin_klev_rec.delivered_date;
    p13_a35 := ddx_fin_klev_rec.credit_tenant_yn;
    p13_a36 := ddx_fin_klev_rec.date_last_cleanup;
    p13_a37 := ddx_fin_klev_rec.year_of_manufacture;
    p13_a38 := rosetta_g_miss_num_map(ddx_fin_klev_rec.coverage_ratio);
    p13_a39 := rosetta_g_miss_num_map(ddx_fin_klev_rec.remarketed_amount);
    p13_a40 := rosetta_g_miss_num_map(ddx_fin_klev_rec.gross_square_footage);
    p13_a41 := ddx_fin_klev_rec.prescribed_asset_yn;
    p13_a42 := ddx_fin_klev_rec.date_remarketed;
    p13_a43 := rosetta_g_miss_num_map(ddx_fin_klev_rec.net_rentable);
    p13_a44 := rosetta_g_miss_num_map(ddx_fin_klev_rec.remarket_margin);
    p13_a45 := ddx_fin_klev_rec.date_letter_acceptance;
    p13_a46 := rosetta_g_miss_num_map(ddx_fin_klev_rec.repurchased_amount);
    p13_a47 := ddx_fin_klev_rec.date_commitment_expiration;
    p13_a48 := ddx_fin_klev_rec.date_repurchased;
    p13_a49 := ddx_fin_klev_rec.date_appraisal;
    p13_a50 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_value);
    p13_a51 := rosetta_g_miss_num_map(ddx_fin_klev_rec.appraisal_value);
    p13_a52 := ddx_fin_klev_rec.secured_deal_yn;
    p13_a53 := rosetta_g_miss_num_map(ddx_fin_klev_rec.gain_loss);
    p13_a54 := rosetta_g_miss_num_map(ddx_fin_klev_rec.floor_amount);
    p13_a55 := ddx_fin_klev_rec.re_lease_yn;
    p13_a56 := ddx_fin_klev_rec.previous_contract;
    p13_a57 := rosetta_g_miss_num_map(ddx_fin_klev_rec.tracked_residual);
    p13_a58 := ddx_fin_klev_rec.date_title_received;
    p13_a59 := rosetta_g_miss_num_map(ddx_fin_klev_rec.amount);
    p13_a60 := ddx_fin_klev_rec.attribute_category;
    p13_a61 := ddx_fin_klev_rec.attribute1;
    p13_a62 := ddx_fin_klev_rec.attribute2;
    p13_a63 := ddx_fin_klev_rec.attribute3;
    p13_a64 := ddx_fin_klev_rec.attribute4;
    p13_a65 := ddx_fin_klev_rec.attribute5;
    p13_a66 := ddx_fin_klev_rec.attribute6;
    p13_a67 := ddx_fin_klev_rec.attribute7;
    p13_a68 := ddx_fin_klev_rec.attribute8;
    p13_a69 := ddx_fin_klev_rec.attribute9;
    p13_a70 := ddx_fin_klev_rec.attribute10;
    p13_a71 := ddx_fin_klev_rec.attribute11;
    p13_a72 := ddx_fin_klev_rec.attribute12;
    p13_a73 := ddx_fin_klev_rec.attribute13;
    p13_a74 := ddx_fin_klev_rec.attribute14;
    p13_a75 := ddx_fin_klev_rec.attribute15;
    p13_a76 := rosetta_g_miss_num_map(ddx_fin_klev_rec.sty_id_for);
    p13_a77 := rosetta_g_miss_num_map(ddx_fin_klev_rec.clg_id);
    p13_a78 := rosetta_g_miss_num_map(ddx_fin_klev_rec.created_by);
    p13_a79 := ddx_fin_klev_rec.creation_date;
    p13_a80 := rosetta_g_miss_num_map(ddx_fin_klev_rec.last_updated_by);
    p13_a81 := ddx_fin_klev_rec.last_update_date;
    p13_a82 := rosetta_g_miss_num_map(ddx_fin_klev_rec.last_update_login);
    p13_a83 := ddx_fin_klev_rec.date_funding;
    p13_a84 := ddx_fin_klev_rec.date_funding_required;
    p13_a85 := ddx_fin_klev_rec.date_accepted;
    p13_a86 := ddx_fin_klev_rec.date_delivery_expected;
    p13_a87 := rosetta_g_miss_num_map(ddx_fin_klev_rec.oec);
    p13_a88 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_amount);
    p13_a89 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_grnty_amount);
    p13_a90 := ddx_fin_klev_rec.residual_code;
    p13_a91 := rosetta_g_miss_num_map(ddx_fin_klev_rec.rvi_premium);
    p13_a92 := ddx_fin_klev_rec.credit_nature;
    p13_a93 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capitalized_interest);
    p13_a94 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_reduction_percent);
    p13_a95 := ddx_fin_klev_rec.date_pay_investor_start;
    p13_a96 := ddx_fin_klev_rec.pay_investor_frequency;
    p13_a97 := ddx_fin_klev_rec.pay_investor_event;
    p13_a98 := rosetta_g_miss_num_map(ddx_fin_klev_rec.pay_investor_remittance_days);

    okl_okc_migration_pvt_w.rosetta_table_copy_out_p7(ddx_cimv_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      );
  end;

  procedure update_add_on_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_DATE_TABLE
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_DATE_TABLE
    , p8_a27 JTF_NUMBER_TABLE
    , p8_a28 JTF_NUMBER_TABLE
    , p8_a29 JTF_NUMBER_TABLE
    , p8_a30 JTF_NUMBER_TABLE
    , p8_a31 JTF_NUMBER_TABLE
    , p8_a32 JTF_NUMBER_TABLE
    , p8_a33 JTF_NUMBER_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_VARCHAR2_TABLE_100
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_DATE_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_DATE_TABLE
    , p8_a48 JTF_DATE_TABLE
    , p8_a49 JTF_DATE_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_VARCHAR2_TABLE_100
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_VARCHAR2_TABLE_100
    , p8_a56 JTF_VARCHAR2_TABLE_100
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_DATE_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_VARCHAR2_TABLE_100
    , p8_a61 JTF_VARCHAR2_TABLE_500
    , p8_a62 JTF_VARCHAR2_TABLE_500
    , p8_a63 JTF_VARCHAR2_TABLE_500
    , p8_a64 JTF_VARCHAR2_TABLE_500
    , p8_a65 JTF_VARCHAR2_TABLE_500
    , p8_a66 JTF_VARCHAR2_TABLE_500
    , p8_a67 JTF_VARCHAR2_TABLE_500
    , p8_a68 JTF_VARCHAR2_TABLE_500
    , p8_a69 JTF_VARCHAR2_TABLE_500
    , p8_a70 JTF_VARCHAR2_TABLE_500
    , p8_a71 JTF_VARCHAR2_TABLE_500
    , p8_a72 JTF_VARCHAR2_TABLE_500
    , p8_a73 JTF_VARCHAR2_TABLE_500
    , p8_a74 JTF_VARCHAR2_TABLE_500
    , p8_a75 JTF_VARCHAR2_TABLE_500
    , p8_a76 JTF_NUMBER_TABLE
    , p8_a77 JTF_NUMBER_TABLE
    , p8_a78 JTF_NUMBER_TABLE
    , p8_a79 JTF_DATE_TABLE
    , p8_a80 JTF_NUMBER_TABLE
    , p8_a81 JTF_DATE_TABLE
    , p8_a82 JTF_NUMBER_TABLE
    , p8_a83 JTF_DATE_TABLE
    , p8_a84 JTF_DATE_TABLE
    , p8_a85 JTF_DATE_TABLE
    , p8_a86 JTF_DATE_TABLE
    , p8_a87 JTF_NUMBER_TABLE
    , p8_a88 JTF_NUMBER_TABLE
    , p8_a89 JTF_NUMBER_TABLE
    , p8_a90 JTF_VARCHAR2_TABLE_100
    , p8_a91 JTF_NUMBER_TABLE
    , p8_a92 JTF_VARCHAR2_TABLE_100
    , p8_a93 JTF_NUMBER_TABLE
    , p8_a94 JTF_NUMBER_TABLE
    , p8_a95 JTF_DATE_TABLE
    , p8_a96 JTF_VARCHAR2_TABLE_100
    , p8_a97 JTF_VARCHAR2_TABLE_100
    , p8_a98 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_DATE_TABLE
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_DATE_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_DATE_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_DATE_TABLE
    , p11_a21 out nocopy JTF_DATE_TABLE
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_NUMBER_TABLE
    , p11_a24 out nocopy JTF_DATE_TABLE
    , p11_a25 out nocopy JTF_DATE_TABLE
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_NUMBER_TABLE
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p11_a29 out nocopy JTF_NUMBER_TABLE
    , p11_a30 out nocopy JTF_NUMBER_TABLE
    , p11_a31 out nocopy JTF_NUMBER_TABLE
    , p11_a32 out nocopy JTF_NUMBER_TABLE
    , p11_a33 out nocopy JTF_NUMBER_TABLE
    , p11_a34 out nocopy JTF_DATE_TABLE
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a38 out nocopy JTF_NUMBER_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a42 out nocopy JTF_DATE_TABLE
    , p11_a43 out nocopy JTF_NUMBER_TABLE
    , p11_a44 out nocopy JTF_NUMBER_TABLE
    , p11_a45 out nocopy JTF_DATE_TABLE
    , p11_a46 out nocopy JTF_NUMBER_TABLE
    , p11_a47 out nocopy JTF_DATE_TABLE
    , p11_a48 out nocopy JTF_DATE_TABLE
    , p11_a49 out nocopy JTF_DATE_TABLE
    , p11_a50 out nocopy JTF_NUMBER_TABLE
    , p11_a51 out nocopy JTF_NUMBER_TABLE
    , p11_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a53 out nocopy JTF_NUMBER_TABLE
    , p11_a54 out nocopy JTF_NUMBER_TABLE
    , p11_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a57 out nocopy JTF_NUMBER_TABLE
    , p11_a58 out nocopy JTF_DATE_TABLE
    , p11_a59 out nocopy JTF_NUMBER_TABLE
    , p11_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a76 out nocopy JTF_NUMBER_TABLE
    , p11_a77 out nocopy JTF_NUMBER_TABLE
    , p11_a78 out nocopy JTF_NUMBER_TABLE
    , p11_a79 out nocopy JTF_DATE_TABLE
    , p11_a80 out nocopy JTF_NUMBER_TABLE
    , p11_a81 out nocopy JTF_DATE_TABLE
    , p11_a82 out nocopy JTF_NUMBER_TABLE
    , p11_a83 out nocopy JTF_DATE_TABLE
    , p11_a84 out nocopy JTF_DATE_TABLE
    , p11_a85 out nocopy JTF_DATE_TABLE
    , p11_a86 out nocopy JTF_DATE_TABLE
    , p11_a87 out nocopy JTF_NUMBER_TABLE
    , p11_a88 out nocopy JTF_NUMBER_TABLE
    , p11_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a91 out nocopy JTF_NUMBER_TABLE
    , p11_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a93 out nocopy JTF_NUMBER_TABLE
    , p11_a94 out nocopy JTF_NUMBER_TABLE
    , p11_a95 out nocopy JTF_DATE_TABLE
    , p11_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a98 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_NUMBER_TABLE
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a15 out nocopy JTF_NUMBER_TABLE
    , p12_a16 out nocopy JTF_DATE_TABLE
    , p12_a17 out nocopy JTF_NUMBER_TABLE
    , p12_a18 out nocopy JTF_DATE_TABLE
    , p12_a19 out nocopy JTF_NUMBER_TABLE
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  VARCHAR2
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  NUMBER
    , p13_a5 out nocopy  NUMBER
    , p13_a6 out nocopy  NUMBER
    , p13_a7 out nocopy  NUMBER
    , p13_a8 out nocopy  VARCHAR2
    , p13_a9 out nocopy  VARCHAR2
    , p13_a10 out nocopy  NUMBER
    , p13_a11 out nocopy  VARCHAR2
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  VARCHAR2
    , p13_a14 out nocopy  VARCHAR2
    , p13_a15 out nocopy  VARCHAR2
    , p13_a16 out nocopy  VARCHAR2
    , p13_a17 out nocopy  VARCHAR2
    , p13_a18 out nocopy  NUMBER
    , p13_a19 out nocopy  NUMBER
    , p13_a20 out nocopy  NUMBER
    , p13_a21 out nocopy  NUMBER
    , p13_a22 out nocopy  VARCHAR2
    , p13_a23 out nocopy  VARCHAR2
    , p13_a24 out nocopy  VARCHAR2
    , p13_a25 out nocopy  VARCHAR2
    , p13_a26 out nocopy  VARCHAR2
    , p13_a27 out nocopy  VARCHAR2
    , p13_a28 out nocopy  DATE
    , p13_a29 out nocopy  VARCHAR2
    , p13_a30 out nocopy  DATE
    , p13_a31 out nocopy  DATE
    , p13_a32 out nocopy  DATE
    , p13_a33 out nocopy  VARCHAR2
    , p13_a34 out nocopy  NUMBER
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  NUMBER
    , p13_a37 out nocopy  VARCHAR2
    , p13_a38 out nocopy  VARCHAR2
    , p13_a39 out nocopy  VARCHAR2
    , p13_a40 out nocopy  VARCHAR2
    , p13_a41 out nocopy  VARCHAR2
    , p13_a42 out nocopy  VARCHAR2
    , p13_a43 out nocopy  VARCHAR2
    , p13_a44 out nocopy  VARCHAR2
    , p13_a45 out nocopy  VARCHAR2
    , p13_a46 out nocopy  VARCHAR2
    , p13_a47 out nocopy  VARCHAR2
    , p13_a48 out nocopy  VARCHAR2
    , p13_a49 out nocopy  VARCHAR2
    , p13_a50 out nocopy  VARCHAR2
    , p13_a51 out nocopy  VARCHAR2
    , p13_a52 out nocopy  VARCHAR2
    , p13_a53 out nocopy  VARCHAR2
    , p13_a54 out nocopy  NUMBER
    , p13_a55 out nocopy  DATE
    , p13_a56 out nocopy  NUMBER
    , p13_a57 out nocopy  DATE
    , p13_a58 out nocopy  VARCHAR2
    , p13_a59 out nocopy  VARCHAR2
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  NUMBER
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p13_a66 out nocopy  VARCHAR2
    , p13_a67 out nocopy  NUMBER
    , p13_a68 out nocopy  NUMBER
    , p13_a69 out nocopy  NUMBER
    , p13_a70 out nocopy  DATE
    , p13_a71 out nocopy  NUMBER
    , p13_a72 out nocopy  DATE
    , p13_a73 out nocopy  NUMBER
    , p13_a74 out nocopy  NUMBER
    , p13_a75 out nocopy  VARCHAR2
    , p13_a76 out nocopy  VARCHAR2
    , p13_a77 out nocopy  NUMBER
    , p13_a78 out nocopy  NUMBER
    , p13_a79 out nocopy  VARCHAR2
    , p13_a80 out nocopy  VARCHAR2
    , p13_a81 out nocopy  NUMBER
    , p13_a82 out nocopy  VARCHAR2
    , p13_a83 out nocopy  NUMBER
    , p13_a84 out nocopy  NUMBER
    , p13_a85 out nocopy  NUMBER
    , p13_a86 out nocopy  NUMBER
    , p13_a87 out nocopy  VARCHAR2
    , p13_a88 out nocopy  NUMBER
    , p13_a89 out nocopy  NUMBER
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  NUMBER
    , p14_a2 out nocopy  NUMBER
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  VARCHAR2
    , p14_a5 out nocopy  VARCHAR2
    , p14_a6 out nocopy  VARCHAR2
    , p14_a7 out nocopy  NUMBER
    , p14_a8 out nocopy  NUMBER
    , p14_a9 out nocopy  DATE
    , p14_a10 out nocopy  NUMBER
    , p14_a11 out nocopy  NUMBER
    , p14_a12 out nocopy  NUMBER
    , p14_a13 out nocopy  NUMBER
    , p14_a14 out nocopy  NUMBER
    , p14_a15 out nocopy  NUMBER
    , p14_a16 out nocopy  NUMBER
    , p14_a17 out nocopy  NUMBER
    , p14_a18 out nocopy  NUMBER
    , p14_a19 out nocopy  NUMBER
    , p14_a20 out nocopy  DATE
    , p14_a21 out nocopy  DATE
    , p14_a22 out nocopy  NUMBER
    , p14_a23 out nocopy  NUMBER
    , p14_a24 out nocopy  DATE
    , p14_a25 out nocopy  DATE
    , p14_a26 out nocopy  DATE
    , p14_a27 out nocopy  NUMBER
    , p14_a28 out nocopy  NUMBER
    , p14_a29 out nocopy  NUMBER
    , p14_a30 out nocopy  NUMBER
    , p14_a31 out nocopy  NUMBER
    , p14_a32 out nocopy  NUMBER
    , p14_a33 out nocopy  NUMBER
    , p14_a34 out nocopy  DATE
    , p14_a35 out nocopy  VARCHAR2
    , p14_a36 out nocopy  DATE
    , p14_a37 out nocopy  VARCHAR2
    , p14_a38 out nocopy  NUMBER
    , p14_a39 out nocopy  NUMBER
    , p14_a40 out nocopy  NUMBER
    , p14_a41 out nocopy  VARCHAR2
    , p14_a42 out nocopy  DATE
    , p14_a43 out nocopy  NUMBER
    , p14_a44 out nocopy  NUMBER
    , p14_a45 out nocopy  DATE
    , p14_a46 out nocopy  NUMBER
    , p14_a47 out nocopy  DATE
    , p14_a48 out nocopy  DATE
    , p14_a49 out nocopy  DATE
    , p14_a50 out nocopy  NUMBER
    , p14_a51 out nocopy  NUMBER
    , p14_a52 out nocopy  VARCHAR2
    , p14_a53 out nocopy  NUMBER
    , p14_a54 out nocopy  NUMBER
    , p14_a55 out nocopy  VARCHAR2
    , p14_a56 out nocopy  VARCHAR2
    , p14_a57 out nocopy  NUMBER
    , p14_a58 out nocopy  DATE
    , p14_a59 out nocopy  NUMBER
    , p14_a60 out nocopy  VARCHAR2
    , p14_a61 out nocopy  VARCHAR2
    , p14_a62 out nocopy  VARCHAR2
    , p14_a63 out nocopy  VARCHAR2
    , p14_a64 out nocopy  VARCHAR2
    , p14_a65 out nocopy  VARCHAR2
    , p14_a66 out nocopy  VARCHAR2
    , p14_a67 out nocopy  VARCHAR2
    , p14_a68 out nocopy  VARCHAR2
    , p14_a69 out nocopy  VARCHAR2
    , p14_a70 out nocopy  VARCHAR2
    , p14_a71 out nocopy  VARCHAR2
    , p14_a72 out nocopy  VARCHAR2
    , p14_a73 out nocopy  VARCHAR2
    , p14_a74 out nocopy  VARCHAR2
    , p14_a75 out nocopy  VARCHAR2
    , p14_a76 out nocopy  NUMBER
    , p14_a77 out nocopy  NUMBER
    , p14_a78 out nocopy  NUMBER
    , p14_a79 out nocopy  DATE
    , p14_a80 out nocopy  NUMBER
    , p14_a81 out nocopy  DATE
    , p14_a82 out nocopy  NUMBER
    , p14_a83 out nocopy  DATE
    , p14_a84 out nocopy  DATE
    , p14_a85 out nocopy  DATE
    , p14_a86 out nocopy  DATE
    , p14_a87 out nocopy  NUMBER
    , p14_a88 out nocopy  NUMBER
    , p14_a89 out nocopy  NUMBER
    , p14_a90 out nocopy  VARCHAR2
    , p14_a91 out nocopy  NUMBER
    , p14_a92 out nocopy  VARCHAR2
    , p14_a93 out nocopy  NUMBER
    , p14_a94 out nocopy  NUMBER
    , p14_a95 out nocopy  DATE
    , p14_a96 out nocopy  VARCHAR2
    , p14_a97 out nocopy  VARCHAR2
    , p14_a98 out nocopy  NUMBER
  )

  as
    ddp_clev_tbl okl_create_kle_pub.clev_tbl_type;
    ddp_klev_tbl okl_create_kle_pub.klev_tbl_type;
    ddp_cimv_tbl okl_create_kle_pub.cimv_tbl_type;
    ddx_clev_tbl okl_create_kle_pub.clev_tbl_type;
    ddx_klev_tbl okl_create_kle_pub.klev_tbl_type;
    ddx_cimv_tbl okl_create_kle_pub.cimv_tbl_type;
    ddx_fin_clev_rec okl_create_kle_pub.clev_rec_type;
    ddx_fin_klev_rec okl_create_kle_pub.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p7_a0
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
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p8_a0
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
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      , p8_a90
      , p8_a91
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p9_a0
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
      );






    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.update_add_on_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddp_cimv_tbl,
      ddx_clev_tbl,
      ddx_klev_tbl,
      ddx_cimv_tbl,
      ddx_fin_clev_rec,
      ddx_fin_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p10_a0
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
      , p10_a58
      , p10_a59
      , p10_a60
      , p10_a61
      , p10_a62
      , p10_a63
      , p10_a64
      , p10_a65
      , p10_a66
      , p10_a67
      , p10_a68
      , p10_a69
      , p10_a70
      , p10_a71
      , p10_a72
      , p10_a73
      , p10_a74
      , p10_a75
      , p10_a76
      , p10_a77
      , p10_a78
      , p10_a79
      , p10_a80
      , p10_a81
      , p10_a82
      , p10_a83
      , p10_a84
      , p10_a85
      , p10_a86
      , p10_a87
      , p10_a88
      , p10_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      , p11_a48
      , p11_a49
      , p11_a50
      , p11_a51
      , p11_a52
      , p11_a53
      , p11_a54
      , p11_a55
      , p11_a56
      , p11_a57
      , p11_a58
      , p11_a59
      , p11_a60
      , p11_a61
      , p11_a62
      , p11_a63
      , p11_a64
      , p11_a65
      , p11_a66
      , p11_a67
      , p11_a68
      , p11_a69
      , p11_a70
      , p11_a71
      , p11_a72
      , p11_a73
      , p11_a74
      , p11_a75
      , p11_a76
      , p11_a77
      , p11_a78
      , p11_a79
      , p11_a80
      , p11_a81
      , p11_a82
      , p11_a83
      , p11_a84
      , p11_a85
      , p11_a86
      , p11_a87
      , p11_a88
      , p11_a89
      , p11_a90
      , p11_a91
      , p11_a92
      , p11_a93
      , p11_a94
      , p11_a95
      , p11_a96
      , p11_a97
      , p11_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_out_p7(ddx_cimv_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      );

    p13_a0 := rosetta_g_miss_num_map(ddx_fin_clev_rec.id);
    p13_a1 := rosetta_g_miss_num_map(ddx_fin_clev_rec.object_version_number);
    p13_a2 := ddx_fin_clev_rec.sfwt_flag;
    p13_a3 := rosetta_g_miss_num_map(ddx_fin_clev_rec.chr_id);
    p13_a4 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id);
    p13_a5 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id_renewed);
    p13_a6 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id_renewed_to);
    p13_a7 := rosetta_g_miss_num_map(ddx_fin_clev_rec.lse_id);
    p13_a8 := ddx_fin_clev_rec.line_number;
    p13_a9 := ddx_fin_clev_rec.sts_code;
    p13_a10 := rosetta_g_miss_num_map(ddx_fin_clev_rec.display_sequence);
    p13_a11 := ddx_fin_clev_rec.trn_code;
    p13_a12 := rosetta_g_miss_num_map(ddx_fin_clev_rec.dnz_chr_id);
    p13_a13 := ddx_fin_clev_rec.comments;
    p13_a14 := ddx_fin_clev_rec.item_description;
    p13_a15 := ddx_fin_clev_rec.oke_boe_description;
    p13_a16 := ddx_fin_clev_rec.cognomen;
    p13_a17 := ddx_fin_clev_rec.hidden_ind;
    p13_a18 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_unit);
    p13_a19 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_unit_percent);
    p13_a20 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_negotiated);
    p13_a21 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_negotiated_renewed);
    p13_a22 := ddx_fin_clev_rec.price_level_ind;
    p13_a23 := ddx_fin_clev_rec.invoice_line_level_ind;
    p13_a24 := ddx_fin_clev_rec.dpas_rating;
    p13_a25 := ddx_fin_clev_rec.block23text;
    p13_a26 := ddx_fin_clev_rec.exception_yn;
    p13_a27 := ddx_fin_clev_rec.template_used;
    p13_a28 := ddx_fin_clev_rec.date_terminated;
    p13_a29 := ddx_fin_clev_rec.name;
    p13_a30 := ddx_fin_clev_rec.start_date;
    p13_a31 := ddx_fin_clev_rec.end_date;
    p13_a32 := ddx_fin_clev_rec.date_renewed;
    p13_a33 := ddx_fin_clev_rec.upg_orig_system_ref;
    p13_a34 := rosetta_g_miss_num_map(ddx_fin_clev_rec.upg_orig_system_ref_id);
    p13_a35 := ddx_fin_clev_rec.orig_system_source_code;
    p13_a36 := rosetta_g_miss_num_map(ddx_fin_clev_rec.orig_system_id1);
    p13_a37 := ddx_fin_clev_rec.orig_system_reference1;
    p13_a38 := ddx_fin_clev_rec.attribute_category;
    p13_a39 := ddx_fin_clev_rec.attribute1;
    p13_a40 := ddx_fin_clev_rec.attribute2;
    p13_a41 := ddx_fin_clev_rec.attribute3;
    p13_a42 := ddx_fin_clev_rec.attribute4;
    p13_a43 := ddx_fin_clev_rec.attribute5;
    p13_a44 := ddx_fin_clev_rec.attribute6;
    p13_a45 := ddx_fin_clev_rec.attribute7;
    p13_a46 := ddx_fin_clev_rec.attribute8;
    p13_a47 := ddx_fin_clev_rec.attribute9;
    p13_a48 := ddx_fin_clev_rec.attribute10;
    p13_a49 := ddx_fin_clev_rec.attribute11;
    p13_a50 := ddx_fin_clev_rec.attribute12;
    p13_a51 := ddx_fin_clev_rec.attribute13;
    p13_a52 := ddx_fin_clev_rec.attribute14;
    p13_a53 := ddx_fin_clev_rec.attribute15;
    p13_a54 := rosetta_g_miss_num_map(ddx_fin_clev_rec.created_by);
    p13_a55 := ddx_fin_clev_rec.creation_date;
    p13_a56 := rosetta_g_miss_num_map(ddx_fin_clev_rec.last_updated_by);
    p13_a57 := ddx_fin_clev_rec.last_update_date;
    p13_a58 := ddx_fin_clev_rec.price_type;
    p13_a59 := ddx_fin_clev_rec.currency_code;
    p13_a60 := ddx_fin_clev_rec.currency_code_renewed;
    p13_a61 := rosetta_g_miss_num_map(ddx_fin_clev_rec.last_update_login);
    p13_a62 := ddx_fin_clev_rec.old_sts_code;
    p13_a63 := ddx_fin_clev_rec.new_sts_code;
    p13_a64 := ddx_fin_clev_rec.old_ste_code;
    p13_a65 := ddx_fin_clev_rec.new_ste_code;
    p13_a66 := ddx_fin_clev_rec.call_action_asmblr;
    p13_a67 := rosetta_g_miss_num_map(ddx_fin_clev_rec.request_id);
    p13_a68 := rosetta_g_miss_num_map(ddx_fin_clev_rec.program_application_id);
    p13_a69 := rosetta_g_miss_num_map(ddx_fin_clev_rec.program_id);
    p13_a70 := ddx_fin_clev_rec.program_update_date;
    p13_a71 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_list_id);
    p13_a72 := ddx_fin_clev_rec.pricing_date;
    p13_a73 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_list_line_id);
    p13_a74 := rosetta_g_miss_num_map(ddx_fin_clev_rec.line_list_price);
    p13_a75 := ddx_fin_clev_rec.item_to_price_yn;
    p13_a76 := ddx_fin_clev_rec.price_basis_yn;
    p13_a77 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_header_id);
    p13_a78 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_revision_number);
    p13_a79 := ddx_fin_clev_rec.config_complete_yn;
    p13_a80 := ddx_fin_clev_rec.config_valid_yn;
    p13_a81 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_top_model_line_id);
    p13_a82 := ddx_fin_clev_rec.config_item_type;
    p13_a83 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_item_id);
    p13_a84 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cust_acct_id);
    p13_a85 := rosetta_g_miss_num_map(ddx_fin_clev_rec.bill_to_site_use_id);
    p13_a86 := rosetta_g_miss_num_map(ddx_fin_clev_rec.inv_rule_id);
    p13_a87 := ddx_fin_clev_rec.line_renewal_type_code;
    p13_a88 := rosetta_g_miss_num_map(ddx_fin_clev_rec.ship_to_site_use_id);
    p13_a89 := rosetta_g_miss_num_map(ddx_fin_clev_rec.payment_term_id);

    p14_a0 := rosetta_g_miss_num_map(ddx_fin_klev_rec.id);
    p14_a1 := rosetta_g_miss_num_map(ddx_fin_klev_rec.object_version_number);
    p14_a2 := rosetta_g_miss_num_map(ddx_fin_klev_rec.kle_id);
    p14_a3 := rosetta_g_miss_num_map(ddx_fin_klev_rec.sty_id);
    p14_a4 := ddx_fin_klev_rec.prc_code;
    p14_a5 := ddx_fin_klev_rec.fcg_code;
    p14_a6 := ddx_fin_klev_rec.nty_code;
    p14_a7 := rosetta_g_miss_num_map(ddx_fin_klev_rec.estimated_oec);
    p14_a8 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lao_amount);
    p14_a9 := ddx_fin_klev_rec.title_date;
    p14_a10 := rosetta_g_miss_num_map(ddx_fin_klev_rec.fee_charge);
    p14_a11 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lrs_percent);
    p14_a12 := rosetta_g_miss_num_map(ddx_fin_klev_rec.initial_direct_cost);
    p14_a13 := rosetta_g_miss_num_map(ddx_fin_klev_rec.percent_stake);
    p14_a14 := rosetta_g_miss_num_map(ddx_fin_klev_rec.percent);
    p14_a15 := rosetta_g_miss_num_map(ddx_fin_klev_rec.evergreen_percent);
    p14_a16 := rosetta_g_miss_num_map(ddx_fin_klev_rec.amount_stake);
    p14_a17 := rosetta_g_miss_num_map(ddx_fin_klev_rec.occupancy);
    p14_a18 := rosetta_g_miss_num_map(ddx_fin_klev_rec.coverage);
    p14_a19 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_percentage);
    p14_a20 := ddx_fin_klev_rec.date_last_inspection;
    p14_a21 := ddx_fin_klev_rec.date_sold;
    p14_a22 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lrv_amount);
    p14_a23 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_reduction);
    p14_a24 := ddx_fin_klev_rec.date_next_inspection_due;
    p14_a25 := ddx_fin_klev_rec.date_residual_last_review;
    p14_a26 := ddx_fin_klev_rec.date_last_reamortisation;
    p14_a27 := rosetta_g_miss_num_map(ddx_fin_klev_rec.vendor_advance_paid);
    p14_a28 := rosetta_g_miss_num_map(ddx_fin_klev_rec.weighted_average_life);
    p14_a29 := rosetta_g_miss_num_map(ddx_fin_klev_rec.tradein_amount);
    p14_a30 := rosetta_g_miss_num_map(ddx_fin_klev_rec.bond_equivalent_yield);
    p14_a31 := rosetta_g_miss_num_map(ddx_fin_klev_rec.termination_purchase_amount);
    p14_a32 := rosetta_g_miss_num_map(ddx_fin_klev_rec.refinance_amount);
    p14_a33 := rosetta_g_miss_num_map(ddx_fin_klev_rec.year_built);
    p14_a34 := ddx_fin_klev_rec.delivered_date;
    p14_a35 := ddx_fin_klev_rec.credit_tenant_yn;
    p14_a36 := ddx_fin_klev_rec.date_last_cleanup;
    p14_a37 := ddx_fin_klev_rec.year_of_manufacture;
    p14_a38 := rosetta_g_miss_num_map(ddx_fin_klev_rec.coverage_ratio);
    p14_a39 := rosetta_g_miss_num_map(ddx_fin_klev_rec.remarketed_amount);
    p14_a40 := rosetta_g_miss_num_map(ddx_fin_klev_rec.gross_square_footage);
    p14_a41 := ddx_fin_klev_rec.prescribed_asset_yn;
    p14_a42 := ddx_fin_klev_rec.date_remarketed;
    p14_a43 := rosetta_g_miss_num_map(ddx_fin_klev_rec.net_rentable);
    p14_a44 := rosetta_g_miss_num_map(ddx_fin_klev_rec.remarket_margin);
    p14_a45 := ddx_fin_klev_rec.date_letter_acceptance;
    p14_a46 := rosetta_g_miss_num_map(ddx_fin_klev_rec.repurchased_amount);
    p14_a47 := ddx_fin_klev_rec.date_commitment_expiration;
    p14_a48 := ddx_fin_klev_rec.date_repurchased;
    p14_a49 := ddx_fin_klev_rec.date_appraisal;
    p14_a50 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_value);
    p14_a51 := rosetta_g_miss_num_map(ddx_fin_klev_rec.appraisal_value);
    p14_a52 := ddx_fin_klev_rec.secured_deal_yn;
    p14_a53 := rosetta_g_miss_num_map(ddx_fin_klev_rec.gain_loss);
    p14_a54 := rosetta_g_miss_num_map(ddx_fin_klev_rec.floor_amount);
    p14_a55 := ddx_fin_klev_rec.re_lease_yn;
    p14_a56 := ddx_fin_klev_rec.previous_contract;
    p14_a57 := rosetta_g_miss_num_map(ddx_fin_klev_rec.tracked_residual);
    p14_a58 := ddx_fin_klev_rec.date_title_received;
    p14_a59 := rosetta_g_miss_num_map(ddx_fin_klev_rec.amount);
    p14_a60 := ddx_fin_klev_rec.attribute_category;
    p14_a61 := ddx_fin_klev_rec.attribute1;
    p14_a62 := ddx_fin_klev_rec.attribute2;
    p14_a63 := ddx_fin_klev_rec.attribute3;
    p14_a64 := ddx_fin_klev_rec.attribute4;
    p14_a65 := ddx_fin_klev_rec.attribute5;
    p14_a66 := ddx_fin_klev_rec.attribute6;
    p14_a67 := ddx_fin_klev_rec.attribute7;
    p14_a68 := ddx_fin_klev_rec.attribute8;
    p14_a69 := ddx_fin_klev_rec.attribute9;
    p14_a70 := ddx_fin_klev_rec.attribute10;
    p14_a71 := ddx_fin_klev_rec.attribute11;
    p14_a72 := ddx_fin_klev_rec.attribute12;
    p14_a73 := ddx_fin_klev_rec.attribute13;
    p14_a74 := ddx_fin_klev_rec.attribute14;
    p14_a75 := ddx_fin_klev_rec.attribute15;
    p14_a76 := rosetta_g_miss_num_map(ddx_fin_klev_rec.sty_id_for);
    p14_a77 := rosetta_g_miss_num_map(ddx_fin_klev_rec.clg_id);
    p14_a78 := rosetta_g_miss_num_map(ddx_fin_klev_rec.created_by);
    p14_a79 := ddx_fin_klev_rec.creation_date;
    p14_a80 := rosetta_g_miss_num_map(ddx_fin_klev_rec.last_updated_by);
    p14_a81 := ddx_fin_klev_rec.last_update_date;
    p14_a82 := rosetta_g_miss_num_map(ddx_fin_klev_rec.last_update_login);
    p14_a83 := ddx_fin_klev_rec.date_funding;
    p14_a84 := ddx_fin_klev_rec.date_funding_required;
    p14_a85 := ddx_fin_klev_rec.date_accepted;
    p14_a86 := ddx_fin_klev_rec.date_delivery_expected;
    p14_a87 := rosetta_g_miss_num_map(ddx_fin_klev_rec.oec);
    p14_a88 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_amount);
    p14_a89 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_grnty_amount);
    p14_a90 := ddx_fin_klev_rec.residual_code;
    p14_a91 := rosetta_g_miss_num_map(ddx_fin_klev_rec.rvi_premium);
    p14_a92 := ddx_fin_klev_rec.credit_nature;
    p14_a93 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capitalized_interest);
    p14_a94 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_reduction_percent);
    p14_a95 := ddx_fin_klev_rec.date_pay_investor_start;
    p14_a96 := ddx_fin_klev_rec.pay_investor_frequency;
    p14_a97 := ddx_fin_klev_rec.pay_investor_event;
    p14_a98 := rosetta_g_miss_num_map(ddx_fin_klev_rec.pay_investor_remittance_days);
  end;

  procedure delete_add_on_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_DATE_TABLE
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_DATE_TABLE
    , p8_a27 JTF_NUMBER_TABLE
    , p8_a28 JTF_NUMBER_TABLE
    , p8_a29 JTF_NUMBER_TABLE
    , p8_a30 JTF_NUMBER_TABLE
    , p8_a31 JTF_NUMBER_TABLE
    , p8_a32 JTF_NUMBER_TABLE
    , p8_a33 JTF_NUMBER_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_VARCHAR2_TABLE_100
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_DATE_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_DATE_TABLE
    , p8_a48 JTF_DATE_TABLE
    , p8_a49 JTF_DATE_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_VARCHAR2_TABLE_100
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_VARCHAR2_TABLE_100
    , p8_a56 JTF_VARCHAR2_TABLE_100
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_DATE_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_VARCHAR2_TABLE_100
    , p8_a61 JTF_VARCHAR2_TABLE_500
    , p8_a62 JTF_VARCHAR2_TABLE_500
    , p8_a63 JTF_VARCHAR2_TABLE_500
    , p8_a64 JTF_VARCHAR2_TABLE_500
    , p8_a65 JTF_VARCHAR2_TABLE_500
    , p8_a66 JTF_VARCHAR2_TABLE_500
    , p8_a67 JTF_VARCHAR2_TABLE_500
    , p8_a68 JTF_VARCHAR2_TABLE_500
    , p8_a69 JTF_VARCHAR2_TABLE_500
    , p8_a70 JTF_VARCHAR2_TABLE_500
    , p8_a71 JTF_VARCHAR2_TABLE_500
    , p8_a72 JTF_VARCHAR2_TABLE_500
    , p8_a73 JTF_VARCHAR2_TABLE_500
    , p8_a74 JTF_VARCHAR2_TABLE_500
    , p8_a75 JTF_VARCHAR2_TABLE_500
    , p8_a76 JTF_NUMBER_TABLE
    , p8_a77 JTF_NUMBER_TABLE
    , p8_a78 JTF_NUMBER_TABLE
    , p8_a79 JTF_DATE_TABLE
    , p8_a80 JTF_NUMBER_TABLE
    , p8_a81 JTF_DATE_TABLE
    , p8_a82 JTF_NUMBER_TABLE
    , p8_a83 JTF_DATE_TABLE
    , p8_a84 JTF_DATE_TABLE
    , p8_a85 JTF_DATE_TABLE
    , p8_a86 JTF_DATE_TABLE
    , p8_a87 JTF_NUMBER_TABLE
    , p8_a88 JTF_NUMBER_TABLE
    , p8_a89 JTF_NUMBER_TABLE
    , p8_a90 JTF_VARCHAR2_TABLE_100
    , p8_a91 JTF_NUMBER_TABLE
    , p8_a92 JTF_VARCHAR2_TABLE_100
    , p8_a93 JTF_NUMBER_TABLE
    , p8_a94 JTF_NUMBER_TABLE
    , p8_a95 JTF_DATE_TABLE
    , p8_a96 JTF_VARCHAR2_TABLE_100
    , p8_a97 JTF_VARCHAR2_TABLE_100
    , p8_a98 JTF_NUMBER_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  NUMBER
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  DATE
    , p9_a31 out nocopy  DATE
    , p9_a32 out nocopy  DATE
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  NUMBER
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  NUMBER
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
    , p9_a51 out nocopy  VARCHAR2
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  DATE
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  DATE
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  NUMBER
    , p9_a69 out nocopy  NUMBER
    , p9_a70 out nocopy  DATE
    , p9_a71 out nocopy  NUMBER
    , p9_a72 out nocopy  DATE
    , p9_a73 out nocopy  NUMBER
    , p9_a74 out nocopy  NUMBER
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  VARCHAR2
    , p9_a80 out nocopy  VARCHAR2
    , p9_a81 out nocopy  NUMBER
    , p9_a82 out nocopy  VARCHAR2
    , p9_a83 out nocopy  NUMBER
    , p9_a84 out nocopy  NUMBER
    , p9_a85 out nocopy  NUMBER
    , p9_a86 out nocopy  NUMBER
    , p9_a87 out nocopy  VARCHAR2
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  NUMBER
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  NUMBER
    , p10_a19 out nocopy  NUMBER
    , p10_a20 out nocopy  DATE
    , p10_a21 out nocopy  DATE
    , p10_a22 out nocopy  NUMBER
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  DATE
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  NUMBER
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  NUMBER
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  NUMBER
    , p10_a32 out nocopy  NUMBER
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  DATE
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  DATE
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  NUMBER
    , p10_a39 out nocopy  NUMBER
    , p10_a40 out nocopy  NUMBER
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  DATE
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  DATE
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  DATE
    , p10_a48 out nocopy  DATE
    , p10_a49 out nocopy  DATE
    , p10_a50 out nocopy  NUMBER
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  NUMBER
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  NUMBER
    , p10_a58 out nocopy  DATE
    , p10_a59 out nocopy  NUMBER
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , p10_a67 out nocopy  VARCHAR2
    , p10_a68 out nocopy  VARCHAR2
    , p10_a69 out nocopy  VARCHAR2
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  VARCHAR2
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  VARCHAR2
    , p10_a75 out nocopy  VARCHAR2
    , p10_a76 out nocopy  NUMBER
    , p10_a77 out nocopy  NUMBER
    , p10_a78 out nocopy  NUMBER
    , p10_a79 out nocopy  DATE
    , p10_a80 out nocopy  NUMBER
    , p10_a81 out nocopy  DATE
    , p10_a82 out nocopy  NUMBER
    , p10_a83 out nocopy  DATE
    , p10_a84 out nocopy  DATE
    , p10_a85 out nocopy  DATE
    , p10_a86 out nocopy  DATE
    , p10_a87 out nocopy  NUMBER
    , p10_a88 out nocopy  NUMBER
    , p10_a89 out nocopy  NUMBER
    , p10_a90 out nocopy  VARCHAR2
    , p10_a91 out nocopy  NUMBER
    , p10_a92 out nocopy  VARCHAR2
    , p10_a93 out nocopy  NUMBER
    , p10_a94 out nocopy  NUMBER
    , p10_a95 out nocopy  DATE
    , p10_a96 out nocopy  VARCHAR2
    , p10_a97 out nocopy  VARCHAR2
    , p10_a98 out nocopy  NUMBER
  )

  as
    ddp_clev_tbl okl_create_kle_pub.clev_tbl_type;
    ddp_klev_tbl okl_create_kle_pub.klev_tbl_type;
    ddx_fin_clev_rec okl_create_kle_pub.clev_rec_type;
    ddx_fin_klev_rec okl_create_kle_pub.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p7_a0
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
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p8_a0
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
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      , p8_a90
      , p8_a91
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.delete_add_on_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddx_fin_clev_rec,
      ddx_fin_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_fin_clev_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_fin_clev_rec.object_version_number);
    p9_a2 := ddx_fin_clev_rec.sfwt_flag;
    p9_a3 := rosetta_g_miss_num_map(ddx_fin_clev_rec.chr_id);
    p9_a4 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id);
    p9_a5 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id_renewed);
    p9_a6 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cle_id_renewed_to);
    p9_a7 := rosetta_g_miss_num_map(ddx_fin_clev_rec.lse_id);
    p9_a8 := ddx_fin_clev_rec.line_number;
    p9_a9 := ddx_fin_clev_rec.sts_code;
    p9_a10 := rosetta_g_miss_num_map(ddx_fin_clev_rec.display_sequence);
    p9_a11 := ddx_fin_clev_rec.trn_code;
    p9_a12 := rosetta_g_miss_num_map(ddx_fin_clev_rec.dnz_chr_id);
    p9_a13 := ddx_fin_clev_rec.comments;
    p9_a14 := ddx_fin_clev_rec.item_description;
    p9_a15 := ddx_fin_clev_rec.oke_boe_description;
    p9_a16 := ddx_fin_clev_rec.cognomen;
    p9_a17 := ddx_fin_clev_rec.hidden_ind;
    p9_a18 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_unit);
    p9_a19 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_unit_percent);
    p9_a20 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_negotiated);
    p9_a21 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_negotiated_renewed);
    p9_a22 := ddx_fin_clev_rec.price_level_ind;
    p9_a23 := ddx_fin_clev_rec.invoice_line_level_ind;
    p9_a24 := ddx_fin_clev_rec.dpas_rating;
    p9_a25 := ddx_fin_clev_rec.block23text;
    p9_a26 := ddx_fin_clev_rec.exception_yn;
    p9_a27 := ddx_fin_clev_rec.template_used;
    p9_a28 := ddx_fin_clev_rec.date_terminated;
    p9_a29 := ddx_fin_clev_rec.name;
    p9_a30 := ddx_fin_clev_rec.start_date;
    p9_a31 := ddx_fin_clev_rec.end_date;
    p9_a32 := ddx_fin_clev_rec.date_renewed;
    p9_a33 := ddx_fin_clev_rec.upg_orig_system_ref;
    p9_a34 := rosetta_g_miss_num_map(ddx_fin_clev_rec.upg_orig_system_ref_id);
    p9_a35 := ddx_fin_clev_rec.orig_system_source_code;
    p9_a36 := rosetta_g_miss_num_map(ddx_fin_clev_rec.orig_system_id1);
    p9_a37 := ddx_fin_clev_rec.orig_system_reference1;
    p9_a38 := ddx_fin_clev_rec.attribute_category;
    p9_a39 := ddx_fin_clev_rec.attribute1;
    p9_a40 := ddx_fin_clev_rec.attribute2;
    p9_a41 := ddx_fin_clev_rec.attribute3;
    p9_a42 := ddx_fin_clev_rec.attribute4;
    p9_a43 := ddx_fin_clev_rec.attribute5;
    p9_a44 := ddx_fin_clev_rec.attribute6;
    p9_a45 := ddx_fin_clev_rec.attribute7;
    p9_a46 := ddx_fin_clev_rec.attribute8;
    p9_a47 := ddx_fin_clev_rec.attribute9;
    p9_a48 := ddx_fin_clev_rec.attribute10;
    p9_a49 := ddx_fin_clev_rec.attribute11;
    p9_a50 := ddx_fin_clev_rec.attribute12;
    p9_a51 := ddx_fin_clev_rec.attribute13;
    p9_a52 := ddx_fin_clev_rec.attribute14;
    p9_a53 := ddx_fin_clev_rec.attribute15;
    p9_a54 := rosetta_g_miss_num_map(ddx_fin_clev_rec.created_by);
    p9_a55 := ddx_fin_clev_rec.creation_date;
    p9_a56 := rosetta_g_miss_num_map(ddx_fin_clev_rec.last_updated_by);
    p9_a57 := ddx_fin_clev_rec.last_update_date;
    p9_a58 := ddx_fin_clev_rec.price_type;
    p9_a59 := ddx_fin_clev_rec.currency_code;
    p9_a60 := ddx_fin_clev_rec.currency_code_renewed;
    p9_a61 := rosetta_g_miss_num_map(ddx_fin_clev_rec.last_update_login);
    p9_a62 := ddx_fin_clev_rec.old_sts_code;
    p9_a63 := ddx_fin_clev_rec.new_sts_code;
    p9_a64 := ddx_fin_clev_rec.old_ste_code;
    p9_a65 := ddx_fin_clev_rec.new_ste_code;
    p9_a66 := ddx_fin_clev_rec.call_action_asmblr;
    p9_a67 := rosetta_g_miss_num_map(ddx_fin_clev_rec.request_id);
    p9_a68 := rosetta_g_miss_num_map(ddx_fin_clev_rec.program_application_id);
    p9_a69 := rosetta_g_miss_num_map(ddx_fin_clev_rec.program_id);
    p9_a70 := ddx_fin_clev_rec.program_update_date;
    p9_a71 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_list_id);
    p9_a72 := ddx_fin_clev_rec.pricing_date;
    p9_a73 := rosetta_g_miss_num_map(ddx_fin_clev_rec.price_list_line_id);
    p9_a74 := rosetta_g_miss_num_map(ddx_fin_clev_rec.line_list_price);
    p9_a75 := ddx_fin_clev_rec.item_to_price_yn;
    p9_a76 := ddx_fin_clev_rec.price_basis_yn;
    p9_a77 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_header_id);
    p9_a78 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_revision_number);
    p9_a79 := ddx_fin_clev_rec.config_complete_yn;
    p9_a80 := ddx_fin_clev_rec.config_valid_yn;
    p9_a81 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_top_model_line_id);
    p9_a82 := ddx_fin_clev_rec.config_item_type;
    p9_a83 := rosetta_g_miss_num_map(ddx_fin_clev_rec.config_item_id);
    p9_a84 := rosetta_g_miss_num_map(ddx_fin_clev_rec.cust_acct_id);
    p9_a85 := rosetta_g_miss_num_map(ddx_fin_clev_rec.bill_to_site_use_id);
    p9_a86 := rosetta_g_miss_num_map(ddx_fin_clev_rec.inv_rule_id);
    p9_a87 := ddx_fin_clev_rec.line_renewal_type_code;
    p9_a88 := rosetta_g_miss_num_map(ddx_fin_clev_rec.ship_to_site_use_id);
    p9_a89 := rosetta_g_miss_num_map(ddx_fin_clev_rec.payment_term_id);

    p10_a0 := rosetta_g_miss_num_map(ddx_fin_klev_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_fin_klev_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_fin_klev_rec.kle_id);
    p10_a3 := rosetta_g_miss_num_map(ddx_fin_klev_rec.sty_id);
    p10_a4 := ddx_fin_klev_rec.prc_code;
    p10_a5 := ddx_fin_klev_rec.fcg_code;
    p10_a6 := ddx_fin_klev_rec.nty_code;
    p10_a7 := rosetta_g_miss_num_map(ddx_fin_klev_rec.estimated_oec);
    p10_a8 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lao_amount);
    p10_a9 := ddx_fin_klev_rec.title_date;
    p10_a10 := rosetta_g_miss_num_map(ddx_fin_klev_rec.fee_charge);
    p10_a11 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lrs_percent);
    p10_a12 := rosetta_g_miss_num_map(ddx_fin_klev_rec.initial_direct_cost);
    p10_a13 := rosetta_g_miss_num_map(ddx_fin_klev_rec.percent_stake);
    p10_a14 := rosetta_g_miss_num_map(ddx_fin_klev_rec.percent);
    p10_a15 := rosetta_g_miss_num_map(ddx_fin_klev_rec.evergreen_percent);
    p10_a16 := rosetta_g_miss_num_map(ddx_fin_klev_rec.amount_stake);
    p10_a17 := rosetta_g_miss_num_map(ddx_fin_klev_rec.occupancy);
    p10_a18 := rosetta_g_miss_num_map(ddx_fin_klev_rec.coverage);
    p10_a19 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_percentage);
    p10_a20 := ddx_fin_klev_rec.date_last_inspection;
    p10_a21 := ddx_fin_klev_rec.date_sold;
    p10_a22 := rosetta_g_miss_num_map(ddx_fin_klev_rec.lrv_amount);
    p10_a23 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_reduction);
    p10_a24 := ddx_fin_klev_rec.date_next_inspection_due;
    p10_a25 := ddx_fin_klev_rec.date_residual_last_review;
    p10_a26 := ddx_fin_klev_rec.date_last_reamortisation;
    p10_a27 := rosetta_g_miss_num_map(ddx_fin_klev_rec.vendor_advance_paid);
    p10_a28 := rosetta_g_miss_num_map(ddx_fin_klev_rec.weighted_average_life);
    p10_a29 := rosetta_g_miss_num_map(ddx_fin_klev_rec.tradein_amount);
    p10_a30 := rosetta_g_miss_num_map(ddx_fin_klev_rec.bond_equivalent_yield);
    p10_a31 := rosetta_g_miss_num_map(ddx_fin_klev_rec.termination_purchase_amount);
    p10_a32 := rosetta_g_miss_num_map(ddx_fin_klev_rec.refinance_amount);
    p10_a33 := rosetta_g_miss_num_map(ddx_fin_klev_rec.year_built);
    p10_a34 := ddx_fin_klev_rec.delivered_date;
    p10_a35 := ddx_fin_klev_rec.credit_tenant_yn;
    p10_a36 := ddx_fin_klev_rec.date_last_cleanup;
    p10_a37 := ddx_fin_klev_rec.year_of_manufacture;
    p10_a38 := rosetta_g_miss_num_map(ddx_fin_klev_rec.coverage_ratio);
    p10_a39 := rosetta_g_miss_num_map(ddx_fin_klev_rec.remarketed_amount);
    p10_a40 := rosetta_g_miss_num_map(ddx_fin_klev_rec.gross_square_footage);
    p10_a41 := ddx_fin_klev_rec.prescribed_asset_yn;
    p10_a42 := ddx_fin_klev_rec.date_remarketed;
    p10_a43 := rosetta_g_miss_num_map(ddx_fin_klev_rec.net_rentable);
    p10_a44 := rosetta_g_miss_num_map(ddx_fin_klev_rec.remarket_margin);
    p10_a45 := ddx_fin_klev_rec.date_letter_acceptance;
    p10_a46 := rosetta_g_miss_num_map(ddx_fin_klev_rec.repurchased_amount);
    p10_a47 := ddx_fin_klev_rec.date_commitment_expiration;
    p10_a48 := ddx_fin_klev_rec.date_repurchased;
    p10_a49 := ddx_fin_klev_rec.date_appraisal;
    p10_a50 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_value);
    p10_a51 := rosetta_g_miss_num_map(ddx_fin_klev_rec.appraisal_value);
    p10_a52 := ddx_fin_klev_rec.secured_deal_yn;
    p10_a53 := rosetta_g_miss_num_map(ddx_fin_klev_rec.gain_loss);
    p10_a54 := rosetta_g_miss_num_map(ddx_fin_klev_rec.floor_amount);
    p10_a55 := ddx_fin_klev_rec.re_lease_yn;
    p10_a56 := ddx_fin_klev_rec.previous_contract;
    p10_a57 := rosetta_g_miss_num_map(ddx_fin_klev_rec.tracked_residual);
    p10_a58 := ddx_fin_klev_rec.date_title_received;
    p10_a59 := rosetta_g_miss_num_map(ddx_fin_klev_rec.amount);
    p10_a60 := ddx_fin_klev_rec.attribute_category;
    p10_a61 := ddx_fin_klev_rec.attribute1;
    p10_a62 := ddx_fin_klev_rec.attribute2;
    p10_a63 := ddx_fin_klev_rec.attribute3;
    p10_a64 := ddx_fin_klev_rec.attribute4;
    p10_a65 := ddx_fin_klev_rec.attribute5;
    p10_a66 := ddx_fin_klev_rec.attribute6;
    p10_a67 := ddx_fin_klev_rec.attribute7;
    p10_a68 := ddx_fin_klev_rec.attribute8;
    p10_a69 := ddx_fin_klev_rec.attribute9;
    p10_a70 := ddx_fin_klev_rec.attribute10;
    p10_a71 := ddx_fin_klev_rec.attribute11;
    p10_a72 := ddx_fin_klev_rec.attribute12;
    p10_a73 := ddx_fin_klev_rec.attribute13;
    p10_a74 := ddx_fin_klev_rec.attribute14;
    p10_a75 := ddx_fin_klev_rec.attribute15;
    p10_a76 := rosetta_g_miss_num_map(ddx_fin_klev_rec.sty_id_for);
    p10_a77 := rosetta_g_miss_num_map(ddx_fin_klev_rec.clg_id);
    p10_a78 := rosetta_g_miss_num_map(ddx_fin_klev_rec.created_by);
    p10_a79 := ddx_fin_klev_rec.creation_date;
    p10_a80 := rosetta_g_miss_num_map(ddx_fin_klev_rec.last_updated_by);
    p10_a81 := ddx_fin_klev_rec.last_update_date;
    p10_a82 := rosetta_g_miss_num_map(ddx_fin_klev_rec.last_update_login);
    p10_a83 := ddx_fin_klev_rec.date_funding;
    p10_a84 := ddx_fin_klev_rec.date_funding_required;
    p10_a85 := ddx_fin_klev_rec.date_accepted;
    p10_a86 := ddx_fin_klev_rec.date_delivery_expected;
    p10_a87 := rosetta_g_miss_num_map(ddx_fin_klev_rec.oec);
    p10_a88 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_amount);
    p10_a89 := rosetta_g_miss_num_map(ddx_fin_klev_rec.residual_grnty_amount);
    p10_a90 := ddx_fin_klev_rec.residual_code;
    p10_a91 := rosetta_g_miss_num_map(ddx_fin_klev_rec.rvi_premium);
    p10_a92 := ddx_fin_klev_rec.credit_nature;
    p10_a93 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capitalized_interest);
    p10_a94 := rosetta_g_miss_num_map(ddx_fin_klev_rec.capital_reduction_percent);
    p10_a95 := ddx_fin_klev_rec.date_pay_investor_start;
    p10_a96 := ddx_fin_klev_rec.pay_investor_frequency;
    p10_a97 := ddx_fin_klev_rec.pay_investor_event;
    p10_a98 := rosetta_g_miss_num_map(ddx_fin_klev_rec.pay_investor_remittance_days);
  end;

  procedure create_party_roles_rec(p_api_version  NUMBER
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
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  )

  as
    ddp_cplv_rec okl_create_kle_pub.cplv_rec_type;
    ddx_cplv_rec okl_create_kle_pub.cplv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cplv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cplv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cplv_rec.sfwt_flag := p5_a2;
    ddp_cplv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cplv_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_cplv_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cplv_rec.rle_code := p5_a6;
    ddp_cplv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_cplv_rec.object1_id1 := p5_a8;
    ddp_cplv_rec.object1_id2 := p5_a9;
    ddp_cplv_rec.jtot_object1_code := p5_a10;
    ddp_cplv_rec.cognomen := p5_a11;
    ddp_cplv_rec.code := p5_a12;
    ddp_cplv_rec.facility := p5_a13;
    ddp_cplv_rec.minority_group_lookup_code := p5_a14;
    ddp_cplv_rec.small_business_flag := p5_a15;
    ddp_cplv_rec.women_owned_flag := p5_a16;
    ddp_cplv_rec.alias := p5_a17;
    ddp_cplv_rec.attribute_category := p5_a18;
    ddp_cplv_rec.attribute1 := p5_a19;
    ddp_cplv_rec.attribute2 := p5_a20;
    ddp_cplv_rec.attribute3 := p5_a21;
    ddp_cplv_rec.attribute4 := p5_a22;
    ddp_cplv_rec.attribute5 := p5_a23;
    ddp_cplv_rec.attribute6 := p5_a24;
    ddp_cplv_rec.attribute7 := p5_a25;
    ddp_cplv_rec.attribute8 := p5_a26;
    ddp_cplv_rec.attribute9 := p5_a27;
    ddp_cplv_rec.attribute10 := p5_a28;
    ddp_cplv_rec.attribute11 := p5_a29;
    ddp_cplv_rec.attribute12 := p5_a30;
    ddp_cplv_rec.attribute13 := p5_a31;
    ddp_cplv_rec.attribute14 := p5_a32;
    ddp_cplv_rec.attribute15 := p5_a33;
    ddp_cplv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_cplv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_cplv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_cplv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_cplv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_cplv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a39);
    ddp_cplv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a40);


    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.create_party_roles_rec(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_rec,
      ddx_cplv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cplv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cplv_rec.object_version_number);
    p6_a2 := ddx_cplv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_cplv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cplv_rec.chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_cplv_rec.cle_id);
    p6_a6 := ddx_cplv_rec.rle_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_cplv_rec.dnz_chr_id);
    p6_a8 := ddx_cplv_rec.object1_id1;
    p6_a9 := ddx_cplv_rec.object1_id2;
    p6_a10 := ddx_cplv_rec.jtot_object1_code;
    p6_a11 := ddx_cplv_rec.cognomen;
    p6_a12 := ddx_cplv_rec.code;
    p6_a13 := ddx_cplv_rec.facility;
    p6_a14 := ddx_cplv_rec.minority_group_lookup_code;
    p6_a15 := ddx_cplv_rec.small_business_flag;
    p6_a16 := ddx_cplv_rec.women_owned_flag;
    p6_a17 := ddx_cplv_rec.alias;
    p6_a18 := ddx_cplv_rec.attribute_category;
    p6_a19 := ddx_cplv_rec.attribute1;
    p6_a20 := ddx_cplv_rec.attribute2;
    p6_a21 := ddx_cplv_rec.attribute3;
    p6_a22 := ddx_cplv_rec.attribute4;
    p6_a23 := ddx_cplv_rec.attribute5;
    p6_a24 := ddx_cplv_rec.attribute6;
    p6_a25 := ddx_cplv_rec.attribute7;
    p6_a26 := ddx_cplv_rec.attribute8;
    p6_a27 := ddx_cplv_rec.attribute9;
    p6_a28 := ddx_cplv_rec.attribute10;
    p6_a29 := ddx_cplv_rec.attribute11;
    p6_a30 := ddx_cplv_rec.attribute12;
    p6_a31 := ddx_cplv_rec.attribute13;
    p6_a32 := ddx_cplv_rec.attribute14;
    p6_a33 := ddx_cplv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_cplv_rec.created_by);
    p6_a35 := ddx_cplv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_cplv_rec.last_updated_by);
    p6_a37 := ddx_cplv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_cplv_rec.last_update_login);
    p6_a39 := rosetta_g_miss_num_map(ddx_cplv_rec.cust_acct_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_cplv_rec.bill_to_site_use_id);
  end;

  procedure update_party_roles_rec(p_api_version  NUMBER
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
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
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
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  )

  as
    ddp_cplv_rec okl_create_kle_pub.cplv_rec_type;
    ddx_cplv_rec okl_create_kle_pub.cplv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cplv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cplv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cplv_rec.sfwt_flag := p5_a2;
    ddp_cplv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_cplv_rec.chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_cplv_rec.cle_id := rosetta_g_miss_num_map(p5_a5);
    ddp_cplv_rec.rle_code := p5_a6;
    ddp_cplv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_cplv_rec.object1_id1 := p5_a8;
    ddp_cplv_rec.object1_id2 := p5_a9;
    ddp_cplv_rec.jtot_object1_code := p5_a10;
    ddp_cplv_rec.cognomen := p5_a11;
    ddp_cplv_rec.code := p5_a12;
    ddp_cplv_rec.facility := p5_a13;
    ddp_cplv_rec.minority_group_lookup_code := p5_a14;
    ddp_cplv_rec.small_business_flag := p5_a15;
    ddp_cplv_rec.women_owned_flag := p5_a16;
    ddp_cplv_rec.alias := p5_a17;
    ddp_cplv_rec.attribute_category := p5_a18;
    ddp_cplv_rec.attribute1 := p5_a19;
    ddp_cplv_rec.attribute2 := p5_a20;
    ddp_cplv_rec.attribute3 := p5_a21;
    ddp_cplv_rec.attribute4 := p5_a22;
    ddp_cplv_rec.attribute5 := p5_a23;
    ddp_cplv_rec.attribute6 := p5_a24;
    ddp_cplv_rec.attribute7 := p5_a25;
    ddp_cplv_rec.attribute8 := p5_a26;
    ddp_cplv_rec.attribute9 := p5_a27;
    ddp_cplv_rec.attribute10 := p5_a28;
    ddp_cplv_rec.attribute11 := p5_a29;
    ddp_cplv_rec.attribute12 := p5_a30;
    ddp_cplv_rec.attribute13 := p5_a31;
    ddp_cplv_rec.attribute14 := p5_a32;
    ddp_cplv_rec.attribute15 := p5_a33;
    ddp_cplv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_cplv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_cplv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_cplv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_cplv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_cplv_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a39);
    ddp_cplv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a40);


    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.update_party_roles_rec(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cplv_rec,
      ddx_cplv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_cplv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_cplv_rec.object_version_number);
    p6_a2 := ddx_cplv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_cplv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_cplv_rec.chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_cplv_rec.cle_id);
    p6_a6 := ddx_cplv_rec.rle_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_cplv_rec.dnz_chr_id);
    p6_a8 := ddx_cplv_rec.object1_id1;
    p6_a9 := ddx_cplv_rec.object1_id2;
    p6_a10 := ddx_cplv_rec.jtot_object1_code;
    p6_a11 := ddx_cplv_rec.cognomen;
    p6_a12 := ddx_cplv_rec.code;
    p6_a13 := ddx_cplv_rec.facility;
    p6_a14 := ddx_cplv_rec.minority_group_lookup_code;
    p6_a15 := ddx_cplv_rec.small_business_flag;
    p6_a16 := ddx_cplv_rec.women_owned_flag;
    p6_a17 := ddx_cplv_rec.alias;
    p6_a18 := ddx_cplv_rec.attribute_category;
    p6_a19 := ddx_cplv_rec.attribute1;
    p6_a20 := ddx_cplv_rec.attribute2;
    p6_a21 := ddx_cplv_rec.attribute3;
    p6_a22 := ddx_cplv_rec.attribute4;
    p6_a23 := ddx_cplv_rec.attribute5;
    p6_a24 := ddx_cplv_rec.attribute6;
    p6_a25 := ddx_cplv_rec.attribute7;
    p6_a26 := ddx_cplv_rec.attribute8;
    p6_a27 := ddx_cplv_rec.attribute9;
    p6_a28 := ddx_cplv_rec.attribute10;
    p6_a29 := ddx_cplv_rec.attribute11;
    p6_a30 := ddx_cplv_rec.attribute12;
    p6_a31 := ddx_cplv_rec.attribute13;
    p6_a32 := ddx_cplv_rec.attribute14;
    p6_a33 := ddx_cplv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_cplv_rec.created_by);
    p6_a35 := ddx_cplv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_cplv_rec.last_updated_by);
    p6_a37 := ddx_cplv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_cplv_rec.last_update_login);
    p6_a39 := rosetta_g_miss_num_map(ddx_cplv_rec.cust_acct_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_cplv_rec.bill_to_site_use_id);
  end;

  procedure create_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_NUMBER_TABLE
    , p13_a5 JTF_VARCHAR2_TABLE_100
    , p13_a6 JTF_NUMBER_TABLE
    , p13_a7 JTF_VARCHAR2_TABLE_100
    , p13_a8 JTF_VARCHAR2_TABLE_100
    , p13_a9 JTF_VARCHAR2_TABLE_200
    , p13_a10 JTF_VARCHAR2_TABLE_100
    , p13_a11 JTF_VARCHAR2_TABLE_100
    , p13_a12 JTF_VARCHAR2_TABLE_200
    , p13_a13 JTF_VARCHAR2_TABLE_100
    , p13_a14 JTF_NUMBER_TABLE
    , p13_a15 JTF_VARCHAR2_TABLE_100
    , p13_a16 JTF_VARCHAR2_TABLE_100
    , p13_a17 JTF_NUMBER_TABLE
    , p13_a18 JTF_NUMBER_TABLE
    , p13_a19 JTF_VARCHAR2_TABLE_100
    , p13_a20 JTF_VARCHAR2_TABLE_500
    , p13_a21 JTF_VARCHAR2_TABLE_500
    , p13_a22 JTF_VARCHAR2_TABLE_500
    , p13_a23 JTF_VARCHAR2_TABLE_500
    , p13_a24 JTF_VARCHAR2_TABLE_500
    , p13_a25 JTF_VARCHAR2_TABLE_500
    , p13_a26 JTF_VARCHAR2_TABLE_500
    , p13_a27 JTF_VARCHAR2_TABLE_500
    , p13_a28 JTF_VARCHAR2_TABLE_500
    , p13_a29 JTF_VARCHAR2_TABLE_500
    , p13_a30 JTF_VARCHAR2_TABLE_500
    , p13_a31 JTF_VARCHAR2_TABLE_500
    , p13_a32 JTF_VARCHAR2_TABLE_500
    , p13_a33 JTF_VARCHAR2_TABLE_500
    , p13_a34 JTF_VARCHAR2_TABLE_500
    , p13_a35 JTF_NUMBER_TABLE
    , p13_a36 JTF_DATE_TABLE
    , p13_a37 JTF_NUMBER_TABLE
    , p13_a38 JTF_DATE_TABLE
    , p13_a39 JTF_NUMBER_TABLE
    , p13_a40 JTF_NUMBER_TABLE
    , p13_a41 JTF_NUMBER_TABLE
    , p13_a42 JTF_VARCHAR2_TABLE_100
    , p13_a43 JTF_NUMBER_TABLE
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  NUMBER
    , p14_a2 out nocopy  VARCHAR2
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  NUMBER
    , p14_a5 out nocopy  NUMBER
    , p14_a6 out nocopy  NUMBER
    , p14_a7 out nocopy  NUMBER
    , p14_a8 out nocopy  VARCHAR2
    , p14_a9 out nocopy  VARCHAR2
    , p14_a10 out nocopy  NUMBER
    , p14_a11 out nocopy  VARCHAR2
    , p14_a12 out nocopy  NUMBER
    , p14_a13 out nocopy  VARCHAR2
    , p14_a14 out nocopy  VARCHAR2
    , p14_a15 out nocopy  VARCHAR2
    , p14_a16 out nocopy  VARCHAR2
    , p14_a17 out nocopy  VARCHAR2
    , p14_a18 out nocopy  NUMBER
    , p14_a19 out nocopy  NUMBER
    , p14_a20 out nocopy  NUMBER
    , p14_a21 out nocopy  NUMBER
    , p14_a22 out nocopy  VARCHAR2
    , p14_a23 out nocopy  VARCHAR2
    , p14_a24 out nocopy  VARCHAR2
    , p14_a25 out nocopy  VARCHAR2
    , p14_a26 out nocopy  VARCHAR2
    , p14_a27 out nocopy  VARCHAR2
    , p14_a28 out nocopy  DATE
    , p14_a29 out nocopy  VARCHAR2
    , p14_a30 out nocopy  DATE
    , p14_a31 out nocopy  DATE
    , p14_a32 out nocopy  DATE
    , p14_a33 out nocopy  VARCHAR2
    , p14_a34 out nocopy  NUMBER
    , p14_a35 out nocopy  VARCHAR2
    , p14_a36 out nocopy  NUMBER
    , p14_a37 out nocopy  VARCHAR2
    , p14_a38 out nocopy  VARCHAR2
    , p14_a39 out nocopy  VARCHAR2
    , p14_a40 out nocopy  VARCHAR2
    , p14_a41 out nocopy  VARCHAR2
    , p14_a42 out nocopy  VARCHAR2
    , p14_a43 out nocopy  VARCHAR2
    , p14_a44 out nocopy  VARCHAR2
    , p14_a45 out nocopy  VARCHAR2
    , p14_a46 out nocopy  VARCHAR2
    , p14_a47 out nocopy  VARCHAR2
    , p14_a48 out nocopy  VARCHAR2
    , p14_a49 out nocopy  VARCHAR2
    , p14_a50 out nocopy  VARCHAR2
    , p14_a51 out nocopy  VARCHAR2
    , p14_a52 out nocopy  VARCHAR2
    , p14_a53 out nocopy  VARCHAR2
    , p14_a54 out nocopy  NUMBER
    , p14_a55 out nocopy  DATE
    , p14_a56 out nocopy  NUMBER
    , p14_a57 out nocopy  DATE
    , p14_a58 out nocopy  VARCHAR2
    , p14_a59 out nocopy  VARCHAR2
    , p14_a60 out nocopy  VARCHAR2
    , p14_a61 out nocopy  NUMBER
    , p14_a62 out nocopy  VARCHAR2
    , p14_a63 out nocopy  VARCHAR2
    , p14_a64 out nocopy  VARCHAR2
    , p14_a65 out nocopy  VARCHAR2
    , p14_a66 out nocopy  VARCHAR2
    , p14_a67 out nocopy  NUMBER
    , p14_a68 out nocopy  NUMBER
    , p14_a69 out nocopy  NUMBER
    , p14_a70 out nocopy  DATE
    , p14_a71 out nocopy  NUMBER
    , p14_a72 out nocopy  DATE
    , p14_a73 out nocopy  NUMBER
    , p14_a74 out nocopy  NUMBER
    , p14_a75 out nocopy  VARCHAR2
    , p14_a76 out nocopy  VARCHAR2
    , p14_a77 out nocopy  NUMBER
    , p14_a78 out nocopy  NUMBER
    , p14_a79 out nocopy  VARCHAR2
    , p14_a80 out nocopy  VARCHAR2
    , p14_a81 out nocopy  NUMBER
    , p14_a82 out nocopy  VARCHAR2
    , p14_a83 out nocopy  NUMBER
    , p14_a84 out nocopy  NUMBER
    , p14_a85 out nocopy  NUMBER
    , p14_a86 out nocopy  NUMBER
    , p14_a87 out nocopy  VARCHAR2
    , p14_a88 out nocopy  NUMBER
    , p14_a89 out nocopy  NUMBER
    , p15_a0 out nocopy  NUMBER
    , p15_a1 out nocopy  NUMBER
    , p15_a2 out nocopy  VARCHAR2
    , p15_a3 out nocopy  NUMBER
    , p15_a4 out nocopy  NUMBER
    , p15_a5 out nocopy  NUMBER
    , p15_a6 out nocopy  NUMBER
    , p15_a7 out nocopy  NUMBER
    , p15_a8 out nocopy  VARCHAR2
    , p15_a9 out nocopy  VARCHAR2
    , p15_a10 out nocopy  NUMBER
    , p15_a11 out nocopy  VARCHAR2
    , p15_a12 out nocopy  NUMBER
    , p15_a13 out nocopy  VARCHAR2
    , p15_a14 out nocopy  VARCHAR2
    , p15_a15 out nocopy  VARCHAR2
    , p15_a16 out nocopy  VARCHAR2
    , p15_a17 out nocopy  VARCHAR2
    , p15_a18 out nocopy  NUMBER
    , p15_a19 out nocopy  NUMBER
    , p15_a20 out nocopy  NUMBER
    , p15_a21 out nocopy  NUMBER
    , p15_a22 out nocopy  VARCHAR2
    , p15_a23 out nocopy  VARCHAR2
    , p15_a24 out nocopy  VARCHAR2
    , p15_a25 out nocopy  VARCHAR2
    , p15_a26 out nocopy  VARCHAR2
    , p15_a27 out nocopy  VARCHAR2
    , p15_a28 out nocopy  DATE
    , p15_a29 out nocopy  VARCHAR2
    , p15_a30 out nocopy  DATE
    , p15_a31 out nocopy  DATE
    , p15_a32 out nocopy  DATE
    , p15_a33 out nocopy  VARCHAR2
    , p15_a34 out nocopy  NUMBER
    , p15_a35 out nocopy  VARCHAR2
    , p15_a36 out nocopy  NUMBER
    , p15_a37 out nocopy  VARCHAR2
    , p15_a38 out nocopy  VARCHAR2
    , p15_a39 out nocopy  VARCHAR2
    , p15_a40 out nocopy  VARCHAR2
    , p15_a41 out nocopy  VARCHAR2
    , p15_a42 out nocopy  VARCHAR2
    , p15_a43 out nocopy  VARCHAR2
    , p15_a44 out nocopy  VARCHAR2
    , p15_a45 out nocopy  VARCHAR2
    , p15_a46 out nocopy  VARCHAR2
    , p15_a47 out nocopy  VARCHAR2
    , p15_a48 out nocopy  VARCHAR2
    , p15_a49 out nocopy  VARCHAR2
    , p15_a50 out nocopy  VARCHAR2
    , p15_a51 out nocopy  VARCHAR2
    , p15_a52 out nocopy  VARCHAR2
    , p15_a53 out nocopy  VARCHAR2
    , p15_a54 out nocopy  NUMBER
    , p15_a55 out nocopy  DATE
    , p15_a56 out nocopy  NUMBER
    , p15_a57 out nocopy  DATE
    , p15_a58 out nocopy  VARCHAR2
    , p15_a59 out nocopy  VARCHAR2
    , p15_a60 out nocopy  VARCHAR2
    , p15_a61 out nocopy  NUMBER
    , p15_a62 out nocopy  VARCHAR2
    , p15_a63 out nocopy  VARCHAR2
    , p15_a64 out nocopy  VARCHAR2
    , p15_a65 out nocopy  VARCHAR2
    , p15_a66 out nocopy  VARCHAR2
    , p15_a67 out nocopy  NUMBER
    , p15_a68 out nocopy  NUMBER
    , p15_a69 out nocopy  NUMBER
    , p15_a70 out nocopy  DATE
    , p15_a71 out nocopy  NUMBER
    , p15_a72 out nocopy  DATE
    , p15_a73 out nocopy  NUMBER
    , p15_a74 out nocopy  NUMBER
    , p15_a75 out nocopy  VARCHAR2
    , p15_a76 out nocopy  VARCHAR2
    , p15_a77 out nocopy  NUMBER
    , p15_a78 out nocopy  NUMBER
    , p15_a79 out nocopy  VARCHAR2
    , p15_a80 out nocopy  VARCHAR2
    , p15_a81 out nocopy  NUMBER
    , p15_a82 out nocopy  VARCHAR2
    , p15_a83 out nocopy  NUMBER
    , p15_a84 out nocopy  NUMBER
    , p15_a85 out nocopy  NUMBER
    , p15_a86 out nocopy  NUMBER
    , p15_a87 out nocopy  VARCHAR2
    , p15_a88 out nocopy  NUMBER
    , p15_a89 out nocopy  NUMBER
    , p16_a0 out nocopy  NUMBER
    , p16_a1 out nocopy  NUMBER
    , p16_a2 out nocopy  VARCHAR2
    , p16_a3 out nocopy  NUMBER
    , p16_a4 out nocopy  NUMBER
    , p16_a5 out nocopy  NUMBER
    , p16_a6 out nocopy  NUMBER
    , p16_a7 out nocopy  NUMBER
    , p16_a8 out nocopy  VARCHAR2
    , p16_a9 out nocopy  VARCHAR2
    , p16_a10 out nocopy  NUMBER
    , p16_a11 out nocopy  VARCHAR2
    , p16_a12 out nocopy  NUMBER
    , p16_a13 out nocopy  VARCHAR2
    , p16_a14 out nocopy  VARCHAR2
    , p16_a15 out nocopy  VARCHAR2
    , p16_a16 out nocopy  VARCHAR2
    , p16_a17 out nocopy  VARCHAR2
    , p16_a18 out nocopy  NUMBER
    , p16_a19 out nocopy  NUMBER
    , p16_a20 out nocopy  NUMBER
    , p16_a21 out nocopy  NUMBER
    , p16_a22 out nocopy  VARCHAR2
    , p16_a23 out nocopy  VARCHAR2
    , p16_a24 out nocopy  VARCHAR2
    , p16_a25 out nocopy  VARCHAR2
    , p16_a26 out nocopy  VARCHAR2
    , p16_a27 out nocopy  VARCHAR2
    , p16_a28 out nocopy  DATE
    , p16_a29 out nocopy  VARCHAR2
    , p16_a30 out nocopy  DATE
    , p16_a31 out nocopy  DATE
    , p16_a32 out nocopy  DATE
    , p16_a33 out nocopy  VARCHAR2
    , p16_a34 out nocopy  NUMBER
    , p16_a35 out nocopy  VARCHAR2
    , p16_a36 out nocopy  NUMBER
    , p16_a37 out nocopy  VARCHAR2
    , p16_a38 out nocopy  VARCHAR2
    , p16_a39 out nocopy  VARCHAR2
    , p16_a40 out nocopy  VARCHAR2
    , p16_a41 out nocopy  VARCHAR2
    , p16_a42 out nocopy  VARCHAR2
    , p16_a43 out nocopy  VARCHAR2
    , p16_a44 out nocopy  VARCHAR2
    , p16_a45 out nocopy  VARCHAR2
    , p16_a46 out nocopy  VARCHAR2
    , p16_a47 out nocopy  VARCHAR2
    , p16_a48 out nocopy  VARCHAR2
    , p16_a49 out nocopy  VARCHAR2
    , p16_a50 out nocopy  VARCHAR2
    , p16_a51 out nocopy  VARCHAR2
    , p16_a52 out nocopy  VARCHAR2
    , p16_a53 out nocopy  VARCHAR2
    , p16_a54 out nocopy  NUMBER
    , p16_a55 out nocopy  DATE
    , p16_a56 out nocopy  NUMBER
    , p16_a57 out nocopy  DATE
    , p16_a58 out nocopy  VARCHAR2
    , p16_a59 out nocopy  VARCHAR2
    , p16_a60 out nocopy  VARCHAR2
    , p16_a61 out nocopy  NUMBER
    , p16_a62 out nocopy  VARCHAR2
    , p16_a63 out nocopy  VARCHAR2
    , p16_a64 out nocopy  VARCHAR2
    , p16_a65 out nocopy  VARCHAR2
    , p16_a66 out nocopy  VARCHAR2
    , p16_a67 out nocopy  NUMBER
    , p16_a68 out nocopy  NUMBER
    , p16_a69 out nocopy  NUMBER
    , p16_a70 out nocopy  DATE
    , p16_a71 out nocopy  NUMBER
    , p16_a72 out nocopy  DATE
    , p16_a73 out nocopy  NUMBER
    , p16_a74 out nocopy  NUMBER
    , p16_a75 out nocopy  VARCHAR2
    , p16_a76 out nocopy  VARCHAR2
    , p16_a77 out nocopy  NUMBER
    , p16_a78 out nocopy  NUMBER
    , p16_a79 out nocopy  VARCHAR2
    , p16_a80 out nocopy  VARCHAR2
    , p16_a81 out nocopy  NUMBER
    , p16_a82 out nocopy  VARCHAR2
    , p16_a83 out nocopy  NUMBER
    , p16_a84 out nocopy  NUMBER
    , p16_a85 out nocopy  NUMBER
    , p16_a86 out nocopy  NUMBER
    , p16_a87 out nocopy  VARCHAR2
    , p16_a88 out nocopy  NUMBER
    , p16_a89 out nocopy  NUMBER
    , p17_a0 out nocopy  NUMBER
    , p17_a1 out nocopy  NUMBER
    , p17_a2 out nocopy  VARCHAR2
    , p17_a3 out nocopy  NUMBER
    , p17_a4 out nocopy  NUMBER
    , p17_a5 out nocopy  NUMBER
    , p17_a6 out nocopy  NUMBER
    , p17_a7 out nocopy  NUMBER
    , p17_a8 out nocopy  VARCHAR2
    , p17_a9 out nocopy  VARCHAR2
    , p17_a10 out nocopy  NUMBER
    , p17_a11 out nocopy  VARCHAR2
    , p17_a12 out nocopy  NUMBER
    , p17_a13 out nocopy  VARCHAR2
    , p17_a14 out nocopy  VARCHAR2
    , p17_a15 out nocopy  VARCHAR2
    , p17_a16 out nocopy  VARCHAR2
    , p17_a17 out nocopy  VARCHAR2
    , p17_a18 out nocopy  NUMBER
    , p17_a19 out nocopy  NUMBER
    , p17_a20 out nocopy  NUMBER
    , p17_a21 out nocopy  NUMBER
    , p17_a22 out nocopy  VARCHAR2
    , p17_a23 out nocopy  VARCHAR2
    , p17_a24 out nocopy  VARCHAR2
    , p17_a25 out nocopy  VARCHAR2
    , p17_a26 out nocopy  VARCHAR2
    , p17_a27 out nocopy  VARCHAR2
    , p17_a28 out nocopy  DATE
    , p17_a29 out nocopy  VARCHAR2
    , p17_a30 out nocopy  DATE
    , p17_a31 out nocopy  DATE
    , p17_a32 out nocopy  DATE
    , p17_a33 out nocopy  VARCHAR2
    , p17_a34 out nocopy  NUMBER
    , p17_a35 out nocopy  VARCHAR2
    , p17_a36 out nocopy  NUMBER
    , p17_a37 out nocopy  VARCHAR2
    , p17_a38 out nocopy  VARCHAR2
    , p17_a39 out nocopy  VARCHAR2
    , p17_a40 out nocopy  VARCHAR2
    , p17_a41 out nocopy  VARCHAR2
    , p17_a42 out nocopy  VARCHAR2
    , p17_a43 out nocopy  VARCHAR2
    , p17_a44 out nocopy  VARCHAR2
    , p17_a45 out nocopy  VARCHAR2
    , p17_a46 out nocopy  VARCHAR2
    , p17_a47 out nocopy  VARCHAR2
    , p17_a48 out nocopy  VARCHAR2
    , p17_a49 out nocopy  VARCHAR2
    , p17_a50 out nocopy  VARCHAR2
    , p17_a51 out nocopy  VARCHAR2
    , p17_a52 out nocopy  VARCHAR2
    , p17_a53 out nocopy  VARCHAR2
    , p17_a54 out nocopy  NUMBER
    , p17_a55 out nocopy  DATE
    , p17_a56 out nocopy  NUMBER
    , p17_a57 out nocopy  DATE
    , p17_a58 out nocopy  VARCHAR2
    , p17_a59 out nocopy  VARCHAR2
    , p17_a60 out nocopy  VARCHAR2
    , p17_a61 out nocopy  NUMBER
    , p17_a62 out nocopy  VARCHAR2
    , p17_a63 out nocopy  VARCHAR2
    , p17_a64 out nocopy  VARCHAR2
    , p17_a65 out nocopy  VARCHAR2
    , p17_a66 out nocopy  VARCHAR2
    , p17_a67 out nocopy  NUMBER
    , p17_a68 out nocopy  NUMBER
    , p17_a69 out nocopy  NUMBER
    , p17_a70 out nocopy  DATE
    , p17_a71 out nocopy  NUMBER
    , p17_a72 out nocopy  DATE
    , p17_a73 out nocopy  NUMBER
    , p17_a74 out nocopy  NUMBER
    , p17_a75 out nocopy  VARCHAR2
    , p17_a76 out nocopy  VARCHAR2
    , p17_a77 out nocopy  NUMBER
    , p17_a78 out nocopy  NUMBER
    , p17_a79 out nocopy  VARCHAR2
    , p17_a80 out nocopy  VARCHAR2
    , p17_a81 out nocopy  NUMBER
    , p17_a82 out nocopy  VARCHAR2
    , p17_a83 out nocopy  NUMBER
    , p17_a84 out nocopy  NUMBER
    , p17_a85 out nocopy  NUMBER
    , p17_a86 out nocopy  NUMBER
    , p17_a87 out nocopy  VARCHAR2
    , p17_a88 out nocopy  NUMBER
    , p17_a89 out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  DATE := fnd_api.g_miss_date
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  DATE := fnd_api.g_miss_date
    , p8_a21  DATE := fnd_api.g_miss_date
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  DATE := fnd_api.g_miss_date
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  NUMBER := 0-1962.0724
    , p8_a28  NUMBER := 0-1962.0724
    , p8_a29  NUMBER := 0-1962.0724
    , p8_a30  NUMBER := 0-1962.0724
    , p8_a31  NUMBER := 0-1962.0724
    , p8_a32  NUMBER := 0-1962.0724
    , p8_a33  NUMBER := 0-1962.0724
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  DATE := fnd_api.g_miss_date
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  DATE := fnd_api.g_miss_date
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  DATE := fnd_api.g_miss_date
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  DATE := fnd_api.g_miss_date
    , p8_a48  DATE := fnd_api.g_miss_date
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  NUMBER := 0-1962.0724
    , p8_a58  DATE := fnd_api.g_miss_date
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  VARCHAR2 := fnd_api.g_miss_char
    , p8_a68  VARCHAR2 := fnd_api.g_miss_char
    , p8_a69  VARCHAR2 := fnd_api.g_miss_char
    , p8_a70  VARCHAR2 := fnd_api.g_miss_char
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  NUMBER := 0-1962.0724
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  DATE := fnd_api.g_miss_date
    , p8_a80  NUMBER := 0-1962.0724
    , p8_a81  DATE := fnd_api.g_miss_date
    , p8_a82  NUMBER := 0-1962.0724
    , p8_a83  DATE := fnd_api.g_miss_date
    , p8_a84  DATE := fnd_api.g_miss_date
    , p8_a85  DATE := fnd_api.g_miss_date
    , p8_a86  DATE := fnd_api.g_miss_date
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  VARCHAR2 := fnd_api.g_miss_char
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  NUMBER := 0-1962.0724
    , p8_a95  DATE := fnd_api.g_miss_date
    , p8_a96  VARCHAR2 := fnd_api.g_miss_char
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  NUMBER := 0-1962.0724
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  NUMBER := 0-1962.0724
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  DATE := fnd_api.g_miss_date
    , p9_a17  NUMBER := 0-1962.0724
    , p9_a18  DATE := fnd_api.g_miss_date
    , p9_a19  NUMBER := 0-1962.0724
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  NUMBER := 0-1962.0724
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  DATE := fnd_api.g_miss_date
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  DATE := fnd_api.g_miss_date
    , p10_a31  DATE := fnd_api.g_miss_date
    , p10_a32  DATE := fnd_api.g_miss_date
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  NUMBER := 0-1962.0724
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  NUMBER := 0-1962.0724
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := fnd_api.g_miss_char
    , p10_a40  VARCHAR2 := fnd_api.g_miss_char
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  VARCHAR2 := fnd_api.g_miss_char
    , p10_a45  VARCHAR2 := fnd_api.g_miss_char
    , p10_a46  VARCHAR2 := fnd_api.g_miss_char
    , p10_a47  VARCHAR2 := fnd_api.g_miss_char
    , p10_a48  VARCHAR2 := fnd_api.g_miss_char
    , p10_a49  VARCHAR2 := fnd_api.g_miss_char
    , p10_a50  VARCHAR2 := fnd_api.g_miss_char
    , p10_a51  VARCHAR2 := fnd_api.g_miss_char
    , p10_a52  VARCHAR2 := fnd_api.g_miss_char
    , p10_a53  VARCHAR2 := fnd_api.g_miss_char
    , p10_a54  NUMBER := 0-1962.0724
    , p10_a55  DATE := fnd_api.g_miss_date
    , p10_a56  NUMBER := 0-1962.0724
    , p10_a57  DATE := fnd_api.g_miss_date
    , p10_a58  VARCHAR2 := fnd_api.g_miss_char
    , p10_a59  VARCHAR2 := fnd_api.g_miss_char
    , p10_a60  VARCHAR2 := fnd_api.g_miss_char
    , p10_a61  NUMBER := 0-1962.0724
    , p10_a62  VARCHAR2 := fnd_api.g_miss_char
    , p10_a63  VARCHAR2 := fnd_api.g_miss_char
    , p10_a64  VARCHAR2 := fnd_api.g_miss_char
    , p10_a65  VARCHAR2 := fnd_api.g_miss_char
    , p10_a66  VARCHAR2 := fnd_api.g_miss_char
    , p10_a67  NUMBER := 0-1962.0724
    , p10_a68  NUMBER := 0-1962.0724
    , p10_a69  NUMBER := 0-1962.0724
    , p10_a70  DATE := fnd_api.g_miss_date
    , p10_a71  NUMBER := 0-1962.0724
    , p10_a72  DATE := fnd_api.g_miss_date
    , p10_a73  NUMBER := 0-1962.0724
    , p10_a74  NUMBER := 0-1962.0724
    , p10_a75  VARCHAR2 := fnd_api.g_miss_char
    , p10_a76  VARCHAR2 := fnd_api.g_miss_char
    , p10_a77  NUMBER := 0-1962.0724
    , p10_a78  NUMBER := 0-1962.0724
    , p10_a79  VARCHAR2 := fnd_api.g_miss_char
    , p10_a80  VARCHAR2 := fnd_api.g_miss_char
    , p10_a81  NUMBER := 0-1962.0724
    , p10_a82  VARCHAR2 := fnd_api.g_miss_char
    , p10_a83  NUMBER := 0-1962.0724
    , p10_a84  NUMBER := 0-1962.0724
    , p10_a85  NUMBER := 0-1962.0724
    , p10_a86  NUMBER := 0-1962.0724
    , p10_a87  VARCHAR2 := fnd_api.g_miss_char
    , p10_a88  NUMBER := 0-1962.0724
    , p10_a89  NUMBER := 0-1962.0724
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  NUMBER := 0-1962.0724
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  NUMBER := 0-1962.0724
    , p11_a6  VARCHAR2 := fnd_api.g_miss_char
    , p11_a7  VARCHAR2 := fnd_api.g_miss_char
    , p11_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a9  VARCHAR2 := fnd_api.g_miss_char
    , p11_a10  VARCHAR2 := fnd_api.g_miss_char
    , p11_a11  NUMBER := 0-1962.0724
    , p11_a12  VARCHAR2 := fnd_api.g_miss_char
    , p11_a13  NUMBER := 0-1962.0724
    , p11_a14  VARCHAR2 := fnd_api.g_miss_char
    , p11_a15  NUMBER := 0-1962.0724
    , p11_a16  DATE := fnd_api.g_miss_date
    , p11_a17  NUMBER := 0-1962.0724
    , p11_a18  DATE := fnd_api.g_miss_date
    , p11_a19  NUMBER := 0-1962.0724
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  NUMBER := 0-1962.0724
    , p12_a4  NUMBER := 0-1962.0724
    , p12_a5  NUMBER := 0-1962.0724
    , p12_a6  NUMBER := 0-1962.0724
    , p12_a7  NUMBER := 0-1962.0724
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  VARCHAR2 := fnd_api.g_miss_char
    , p12_a13  VARCHAR2 := fnd_api.g_miss_char
    , p12_a14  VARCHAR2 := fnd_api.g_miss_char
    , p12_a15  NUMBER := 0-1962.0724
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  NUMBER := 0-1962.0724
    , p12_a18  VARCHAR2 := fnd_api.g_miss_char
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  NUMBER := 0-1962.0724
    , p12_a21  VARCHAR2 := fnd_api.g_miss_char
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  VARCHAR2 := fnd_api.g_miss_char
    , p12_a24  VARCHAR2 := fnd_api.g_miss_char
    , p12_a25  DATE := fnd_api.g_miss_date
    , p12_a26  DATE := fnd_api.g_miss_date
    , p12_a27  DATE := fnd_api.g_miss_date
    , p12_a28  NUMBER := 0-1962.0724
    , p12_a29  NUMBER := 0-1962.0724
    , p12_a30  NUMBER := 0-1962.0724
    , p12_a31  VARCHAR2 := fnd_api.g_miss_char
    , p12_a32  NUMBER := 0-1962.0724
    , p12_a33  NUMBER := 0-1962.0724
    , p12_a34  NUMBER := 0-1962.0724
    , p12_a35  NUMBER := 0-1962.0724
    , p12_a36  VARCHAR2 := fnd_api.g_miss_char
    , p12_a37  VARCHAR2 := fnd_api.g_miss_char
    , p12_a38  VARCHAR2 := fnd_api.g_miss_char
    , p12_a39  VARCHAR2 := fnd_api.g_miss_char
    , p12_a40  VARCHAR2 := fnd_api.g_miss_char
    , p12_a41  VARCHAR2 := fnd_api.g_miss_char
    , p12_a42  VARCHAR2 := fnd_api.g_miss_char
    , p12_a43  VARCHAR2 := fnd_api.g_miss_char
    , p12_a44  VARCHAR2 := fnd_api.g_miss_char
    , p12_a45  VARCHAR2 := fnd_api.g_miss_char
    , p12_a46  VARCHAR2 := fnd_api.g_miss_char
    , p12_a47  VARCHAR2 := fnd_api.g_miss_char
    , p12_a48  VARCHAR2 := fnd_api.g_miss_char
    , p12_a49  VARCHAR2 := fnd_api.g_miss_char
    , p12_a50  VARCHAR2 := fnd_api.g_miss_char
    , p12_a51  VARCHAR2 := fnd_api.g_miss_char
    , p12_a52  NUMBER := 0-1962.0724
    , p12_a53  DATE := fnd_api.g_miss_date
    , p12_a54  NUMBER := 0-1962.0724
    , p12_a55  DATE := fnd_api.g_miss_date
    , p12_a56  NUMBER := 0-1962.0724
    , p12_a57  VARCHAR2 := fnd_api.g_miss_char
    , p12_a58  NUMBER := 0-1962.0724
    , p12_a59  NUMBER := 0-1962.0724
    , p12_a60  NUMBER := 0-1962.0724
    , p12_a61  NUMBER := 0-1962.0724
    , p12_a62  NUMBER := 0-1962.0724
    , p12_a63  NUMBER := 0-1962.0724
    , p12_a64  NUMBER := 0-1962.0724
    , p12_a65  NUMBER := 0-1962.0724
    , p12_a66  NUMBER := 0-1962.0724
    , p12_a67  DATE := fnd_api.g_miss_date
    , p12_a68  NUMBER := 0-1962.0724
    , p12_a69  NUMBER := 0-1962.0724
    , p12_a70  NUMBER := 0-1962.0724
    , p12_a71  VARCHAR2 := fnd_api.g_miss_char
    , p12_a72  NUMBER := 0-1962.0724
    , p12_a73  VARCHAR2 := fnd_api.g_miss_char
    , p12_a74  VARCHAR2 := fnd_api.g_miss_char
    , p12_a75  NUMBER := 0-1962.0724
    , p12_a76  DATE := fnd_api.g_miss_date
  )

  as
    ddp_clev_fin_rec okl_create_kle_pub.clev_rec_type;
    ddp_klev_fin_rec okl_create_kle_pub.klev_rec_type;
    ddp_cimv_model_rec okl_create_kle_pub.cimv_rec_type;
    ddp_clev_fa_rec okl_create_kle_pub.clev_rec_type;
    ddp_cimv_fa_rec okl_create_kle_pub.cimv_rec_type;
    ddp_talv_fa_rec okl_create_kle_pub.talv_rec_type;
    ddp_itiv_ib_tbl okl_create_kle_pub.itiv_tbl_type;
    ddx_clev_fin_rec okl_create_kle_pub.clev_rec_type;
    ddx_clev_model_rec okl_create_kle_pub.clev_rec_type;
    ddx_clev_fa_rec okl_create_kle_pub.clev_rec_type;
    ddx_clev_ib_rec okl_create_kle_pub.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_clev_fin_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_clev_fin_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_clev_fin_rec.sfwt_flag := p7_a2;
    ddp_clev_fin_rec.chr_id := rosetta_g_miss_num_map(p7_a3);
    ddp_clev_fin_rec.cle_id := rosetta_g_miss_num_map(p7_a4);
    ddp_clev_fin_rec.cle_id_renewed := rosetta_g_miss_num_map(p7_a5);
    ddp_clev_fin_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p7_a6);
    ddp_clev_fin_rec.lse_id := rosetta_g_miss_num_map(p7_a7);
    ddp_clev_fin_rec.line_number := p7_a8;
    ddp_clev_fin_rec.sts_code := p7_a9;
    ddp_clev_fin_rec.display_sequence := rosetta_g_miss_num_map(p7_a10);
    ddp_clev_fin_rec.trn_code := p7_a11;
    ddp_clev_fin_rec.dnz_chr_id := rosetta_g_miss_num_map(p7_a12);
    ddp_clev_fin_rec.comments := p7_a13;
    ddp_clev_fin_rec.item_description := p7_a14;
    ddp_clev_fin_rec.oke_boe_description := p7_a15;
    ddp_clev_fin_rec.cognomen := p7_a16;
    ddp_clev_fin_rec.hidden_ind := p7_a17;
    ddp_clev_fin_rec.price_unit := rosetta_g_miss_num_map(p7_a18);
    ddp_clev_fin_rec.price_unit_percent := rosetta_g_miss_num_map(p7_a19);
    ddp_clev_fin_rec.price_negotiated := rosetta_g_miss_num_map(p7_a20);
    ddp_clev_fin_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p7_a21);
    ddp_clev_fin_rec.price_level_ind := p7_a22;
    ddp_clev_fin_rec.invoice_line_level_ind := p7_a23;
    ddp_clev_fin_rec.dpas_rating := p7_a24;
    ddp_clev_fin_rec.block23text := p7_a25;
    ddp_clev_fin_rec.exception_yn := p7_a26;
    ddp_clev_fin_rec.template_used := p7_a27;
    ddp_clev_fin_rec.date_terminated := rosetta_g_miss_date_in_map(p7_a28);
    ddp_clev_fin_rec.name := p7_a29;
    ddp_clev_fin_rec.start_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_clev_fin_rec.end_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_clev_fin_rec.date_renewed := rosetta_g_miss_date_in_map(p7_a32);
    ddp_clev_fin_rec.upg_orig_system_ref := p7_a33;
    ddp_clev_fin_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a34);
    ddp_clev_fin_rec.orig_system_source_code := p7_a35;
    ddp_clev_fin_rec.orig_system_id1 := rosetta_g_miss_num_map(p7_a36);
    ddp_clev_fin_rec.orig_system_reference1 := p7_a37;
    ddp_clev_fin_rec.attribute_category := p7_a38;
    ddp_clev_fin_rec.attribute1 := p7_a39;
    ddp_clev_fin_rec.attribute2 := p7_a40;
    ddp_clev_fin_rec.attribute3 := p7_a41;
    ddp_clev_fin_rec.attribute4 := p7_a42;
    ddp_clev_fin_rec.attribute5 := p7_a43;
    ddp_clev_fin_rec.attribute6 := p7_a44;
    ddp_clev_fin_rec.attribute7 := p7_a45;
    ddp_clev_fin_rec.attribute8 := p7_a46;
    ddp_clev_fin_rec.attribute9 := p7_a47;
    ddp_clev_fin_rec.attribute10 := p7_a48;
    ddp_clev_fin_rec.attribute11 := p7_a49;
    ddp_clev_fin_rec.attribute12 := p7_a50;
    ddp_clev_fin_rec.attribute13 := p7_a51;
    ddp_clev_fin_rec.attribute14 := p7_a52;
    ddp_clev_fin_rec.attribute15 := p7_a53;
    ddp_clev_fin_rec.created_by := rosetta_g_miss_num_map(p7_a54);
    ddp_clev_fin_rec.creation_date := rosetta_g_miss_date_in_map(p7_a55);
    ddp_clev_fin_rec.last_updated_by := rosetta_g_miss_num_map(p7_a56);
    ddp_clev_fin_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a57);
    ddp_clev_fin_rec.price_type := p7_a58;
    ddp_clev_fin_rec.currency_code := p7_a59;
    ddp_clev_fin_rec.currency_code_renewed := p7_a60;
    ddp_clev_fin_rec.last_update_login := rosetta_g_miss_num_map(p7_a61);
    ddp_clev_fin_rec.old_sts_code := p7_a62;
    ddp_clev_fin_rec.new_sts_code := p7_a63;
    ddp_clev_fin_rec.old_ste_code := p7_a64;
    ddp_clev_fin_rec.new_ste_code := p7_a65;
    ddp_clev_fin_rec.call_action_asmblr := p7_a66;
    ddp_clev_fin_rec.request_id := rosetta_g_miss_num_map(p7_a67);
    ddp_clev_fin_rec.program_application_id := rosetta_g_miss_num_map(p7_a68);
    ddp_clev_fin_rec.program_id := rosetta_g_miss_num_map(p7_a69);
    ddp_clev_fin_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a70);
    ddp_clev_fin_rec.price_list_id := rosetta_g_miss_num_map(p7_a71);
    ddp_clev_fin_rec.pricing_date := rosetta_g_miss_date_in_map(p7_a72);
    ddp_clev_fin_rec.price_list_line_id := rosetta_g_miss_num_map(p7_a73);
    ddp_clev_fin_rec.line_list_price := rosetta_g_miss_num_map(p7_a74);
    ddp_clev_fin_rec.item_to_price_yn := p7_a75;
    ddp_clev_fin_rec.price_basis_yn := p7_a76;
    ddp_clev_fin_rec.config_header_id := rosetta_g_miss_num_map(p7_a77);
    ddp_clev_fin_rec.config_revision_number := rosetta_g_miss_num_map(p7_a78);
    ddp_clev_fin_rec.config_complete_yn := p7_a79;
    ddp_clev_fin_rec.config_valid_yn := p7_a80;
    ddp_clev_fin_rec.config_top_model_line_id := rosetta_g_miss_num_map(p7_a81);
    ddp_clev_fin_rec.config_item_type := p7_a82;
    ddp_clev_fin_rec.config_item_id := rosetta_g_miss_num_map(p7_a83);
    ddp_clev_fin_rec.cust_acct_id := rosetta_g_miss_num_map(p7_a84);
    ddp_clev_fin_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p7_a85);
    ddp_clev_fin_rec.inv_rule_id := rosetta_g_miss_num_map(p7_a86);
    ddp_clev_fin_rec.line_renewal_type_code := p7_a87;
    ddp_clev_fin_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p7_a88);
    ddp_clev_fin_rec.payment_term_id := rosetta_g_miss_num_map(p7_a89);

    ddp_klev_fin_rec.id := rosetta_g_miss_num_map(p8_a0);
    ddp_klev_fin_rec.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_klev_fin_rec.kle_id := rosetta_g_miss_num_map(p8_a2);
    ddp_klev_fin_rec.sty_id := rosetta_g_miss_num_map(p8_a3);
    ddp_klev_fin_rec.prc_code := p8_a4;
    ddp_klev_fin_rec.fcg_code := p8_a5;
    ddp_klev_fin_rec.nty_code := p8_a6;
    ddp_klev_fin_rec.estimated_oec := rosetta_g_miss_num_map(p8_a7);
    ddp_klev_fin_rec.lao_amount := rosetta_g_miss_num_map(p8_a8);
    ddp_klev_fin_rec.title_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_klev_fin_rec.fee_charge := rosetta_g_miss_num_map(p8_a10);
    ddp_klev_fin_rec.lrs_percent := rosetta_g_miss_num_map(p8_a11);
    ddp_klev_fin_rec.initial_direct_cost := rosetta_g_miss_num_map(p8_a12);
    ddp_klev_fin_rec.percent_stake := rosetta_g_miss_num_map(p8_a13);
    ddp_klev_fin_rec.percent := rosetta_g_miss_num_map(p8_a14);
    ddp_klev_fin_rec.evergreen_percent := rosetta_g_miss_num_map(p8_a15);
    ddp_klev_fin_rec.amount_stake := rosetta_g_miss_num_map(p8_a16);
    ddp_klev_fin_rec.occupancy := rosetta_g_miss_num_map(p8_a17);
    ddp_klev_fin_rec.coverage := rosetta_g_miss_num_map(p8_a18);
    ddp_klev_fin_rec.residual_percentage := rosetta_g_miss_num_map(p8_a19);
    ddp_klev_fin_rec.date_last_inspection := rosetta_g_miss_date_in_map(p8_a20);
    ddp_klev_fin_rec.date_sold := rosetta_g_miss_date_in_map(p8_a21);
    ddp_klev_fin_rec.lrv_amount := rosetta_g_miss_num_map(p8_a22);
    ddp_klev_fin_rec.capital_reduction := rosetta_g_miss_num_map(p8_a23);
    ddp_klev_fin_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p8_a24);
    ddp_klev_fin_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p8_a25);
    ddp_klev_fin_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p8_a26);
    ddp_klev_fin_rec.vendor_advance_paid := rosetta_g_miss_num_map(p8_a27);
    ddp_klev_fin_rec.weighted_average_life := rosetta_g_miss_num_map(p8_a28);
    ddp_klev_fin_rec.tradein_amount := rosetta_g_miss_num_map(p8_a29);
    ddp_klev_fin_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p8_a30);
    ddp_klev_fin_rec.termination_purchase_amount := rosetta_g_miss_num_map(p8_a31);
    ddp_klev_fin_rec.refinance_amount := rosetta_g_miss_num_map(p8_a32);
    ddp_klev_fin_rec.year_built := rosetta_g_miss_num_map(p8_a33);
    ddp_klev_fin_rec.delivered_date := rosetta_g_miss_date_in_map(p8_a34);
    ddp_klev_fin_rec.credit_tenant_yn := p8_a35;
    ddp_klev_fin_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p8_a36);
    ddp_klev_fin_rec.year_of_manufacture := p8_a37;
    ddp_klev_fin_rec.coverage_ratio := rosetta_g_miss_num_map(p8_a38);
    ddp_klev_fin_rec.remarketed_amount := rosetta_g_miss_num_map(p8_a39);
    ddp_klev_fin_rec.gross_square_footage := rosetta_g_miss_num_map(p8_a40);
    ddp_klev_fin_rec.prescribed_asset_yn := p8_a41;
    ddp_klev_fin_rec.date_remarketed := rosetta_g_miss_date_in_map(p8_a42);
    ddp_klev_fin_rec.net_rentable := rosetta_g_miss_num_map(p8_a43);
    ddp_klev_fin_rec.remarket_margin := rosetta_g_miss_num_map(p8_a44);
    ddp_klev_fin_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p8_a45);
    ddp_klev_fin_rec.repurchased_amount := rosetta_g_miss_num_map(p8_a46);
    ddp_klev_fin_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p8_a47);
    ddp_klev_fin_rec.date_repurchased := rosetta_g_miss_date_in_map(p8_a48);
    ddp_klev_fin_rec.date_appraisal := rosetta_g_miss_date_in_map(p8_a49);
    ddp_klev_fin_rec.residual_value := rosetta_g_miss_num_map(p8_a50);
    ddp_klev_fin_rec.appraisal_value := rosetta_g_miss_num_map(p8_a51);
    ddp_klev_fin_rec.secured_deal_yn := p8_a52;
    ddp_klev_fin_rec.gain_loss := rosetta_g_miss_num_map(p8_a53);
    ddp_klev_fin_rec.floor_amount := rosetta_g_miss_num_map(p8_a54);
    ddp_klev_fin_rec.re_lease_yn := p8_a55;
    ddp_klev_fin_rec.previous_contract := p8_a56;
    ddp_klev_fin_rec.tracked_residual := rosetta_g_miss_num_map(p8_a57);
    ddp_klev_fin_rec.date_title_received := rosetta_g_miss_date_in_map(p8_a58);
    ddp_klev_fin_rec.amount := rosetta_g_miss_num_map(p8_a59);
    ddp_klev_fin_rec.attribute_category := p8_a60;
    ddp_klev_fin_rec.attribute1 := p8_a61;
    ddp_klev_fin_rec.attribute2 := p8_a62;
    ddp_klev_fin_rec.attribute3 := p8_a63;
    ddp_klev_fin_rec.attribute4 := p8_a64;
    ddp_klev_fin_rec.attribute5 := p8_a65;
    ddp_klev_fin_rec.attribute6 := p8_a66;
    ddp_klev_fin_rec.attribute7 := p8_a67;
    ddp_klev_fin_rec.attribute8 := p8_a68;
    ddp_klev_fin_rec.attribute9 := p8_a69;
    ddp_klev_fin_rec.attribute10 := p8_a70;
    ddp_klev_fin_rec.attribute11 := p8_a71;
    ddp_klev_fin_rec.attribute12 := p8_a72;
    ddp_klev_fin_rec.attribute13 := p8_a73;
    ddp_klev_fin_rec.attribute14 := p8_a74;
    ddp_klev_fin_rec.attribute15 := p8_a75;
    ddp_klev_fin_rec.sty_id_for := rosetta_g_miss_num_map(p8_a76);
    ddp_klev_fin_rec.clg_id := rosetta_g_miss_num_map(p8_a77);
    ddp_klev_fin_rec.created_by := rosetta_g_miss_num_map(p8_a78);
    ddp_klev_fin_rec.creation_date := rosetta_g_miss_date_in_map(p8_a79);
    ddp_klev_fin_rec.last_updated_by := rosetta_g_miss_num_map(p8_a80);
    ddp_klev_fin_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a81);
    ddp_klev_fin_rec.last_update_login := rosetta_g_miss_num_map(p8_a82);
    ddp_klev_fin_rec.date_funding := rosetta_g_miss_date_in_map(p8_a83);
    ddp_klev_fin_rec.date_funding_required := rosetta_g_miss_date_in_map(p8_a84);
    ddp_klev_fin_rec.date_accepted := rosetta_g_miss_date_in_map(p8_a85);
    ddp_klev_fin_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p8_a86);
    ddp_klev_fin_rec.oec := rosetta_g_miss_num_map(p8_a87);
    ddp_klev_fin_rec.capital_amount := rosetta_g_miss_num_map(p8_a88);
    ddp_klev_fin_rec.residual_grnty_amount := rosetta_g_miss_num_map(p8_a89);
    ddp_klev_fin_rec.residual_code := p8_a90;
    ddp_klev_fin_rec.rvi_premium := rosetta_g_miss_num_map(p8_a91);
    ddp_klev_fin_rec.credit_nature := p8_a92;
    ddp_klev_fin_rec.capitalized_interest := rosetta_g_miss_num_map(p8_a93);
    ddp_klev_fin_rec.capital_reduction_percent := rosetta_g_miss_num_map(p8_a94);
    ddp_klev_fin_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p8_a95);
    ddp_klev_fin_rec.pay_investor_frequency := p8_a96;
    ddp_klev_fin_rec.pay_investor_event := p8_a97;
    ddp_klev_fin_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p8_a98);

    ddp_cimv_model_rec.id := rosetta_g_miss_num_map(p9_a0);
    ddp_cimv_model_rec.object_version_number := rosetta_g_miss_num_map(p9_a1);
    ddp_cimv_model_rec.cle_id := rosetta_g_miss_num_map(p9_a2);
    ddp_cimv_model_rec.chr_id := rosetta_g_miss_num_map(p9_a3);
    ddp_cimv_model_rec.cle_id_for := rosetta_g_miss_num_map(p9_a4);
    ddp_cimv_model_rec.dnz_chr_id := rosetta_g_miss_num_map(p9_a5);
    ddp_cimv_model_rec.object1_id1 := p9_a6;
    ddp_cimv_model_rec.object1_id2 := p9_a7;
    ddp_cimv_model_rec.jtot_object1_code := p9_a8;
    ddp_cimv_model_rec.uom_code := p9_a9;
    ddp_cimv_model_rec.exception_yn := p9_a10;
    ddp_cimv_model_rec.number_of_items := rosetta_g_miss_num_map(p9_a11);
    ddp_cimv_model_rec.upg_orig_system_ref := p9_a12;
    ddp_cimv_model_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p9_a13);
    ddp_cimv_model_rec.priced_item_yn := p9_a14;
    ddp_cimv_model_rec.created_by := rosetta_g_miss_num_map(p9_a15);
    ddp_cimv_model_rec.creation_date := rosetta_g_miss_date_in_map(p9_a16);
    ddp_cimv_model_rec.last_updated_by := rosetta_g_miss_num_map(p9_a17);
    ddp_cimv_model_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a18);
    ddp_cimv_model_rec.last_update_login := rosetta_g_miss_num_map(p9_a19);

    ddp_clev_fa_rec.id := rosetta_g_miss_num_map(p10_a0);
    ddp_clev_fa_rec.object_version_number := rosetta_g_miss_num_map(p10_a1);
    ddp_clev_fa_rec.sfwt_flag := p10_a2;
    ddp_clev_fa_rec.chr_id := rosetta_g_miss_num_map(p10_a3);
    ddp_clev_fa_rec.cle_id := rosetta_g_miss_num_map(p10_a4);
    ddp_clev_fa_rec.cle_id_renewed := rosetta_g_miss_num_map(p10_a5);
    ddp_clev_fa_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p10_a6);
    ddp_clev_fa_rec.lse_id := rosetta_g_miss_num_map(p10_a7);
    ddp_clev_fa_rec.line_number := p10_a8;
    ddp_clev_fa_rec.sts_code := p10_a9;
    ddp_clev_fa_rec.display_sequence := rosetta_g_miss_num_map(p10_a10);
    ddp_clev_fa_rec.trn_code := p10_a11;
    ddp_clev_fa_rec.dnz_chr_id := rosetta_g_miss_num_map(p10_a12);
    ddp_clev_fa_rec.comments := p10_a13;
    ddp_clev_fa_rec.item_description := p10_a14;
    ddp_clev_fa_rec.oke_boe_description := p10_a15;
    ddp_clev_fa_rec.cognomen := p10_a16;
    ddp_clev_fa_rec.hidden_ind := p10_a17;
    ddp_clev_fa_rec.price_unit := rosetta_g_miss_num_map(p10_a18);
    ddp_clev_fa_rec.price_unit_percent := rosetta_g_miss_num_map(p10_a19);
    ddp_clev_fa_rec.price_negotiated := rosetta_g_miss_num_map(p10_a20);
    ddp_clev_fa_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p10_a21);
    ddp_clev_fa_rec.price_level_ind := p10_a22;
    ddp_clev_fa_rec.invoice_line_level_ind := p10_a23;
    ddp_clev_fa_rec.dpas_rating := p10_a24;
    ddp_clev_fa_rec.block23text := p10_a25;
    ddp_clev_fa_rec.exception_yn := p10_a26;
    ddp_clev_fa_rec.template_used := p10_a27;
    ddp_clev_fa_rec.date_terminated := rosetta_g_miss_date_in_map(p10_a28);
    ddp_clev_fa_rec.name := p10_a29;
    ddp_clev_fa_rec.start_date := rosetta_g_miss_date_in_map(p10_a30);
    ddp_clev_fa_rec.end_date := rosetta_g_miss_date_in_map(p10_a31);
    ddp_clev_fa_rec.date_renewed := rosetta_g_miss_date_in_map(p10_a32);
    ddp_clev_fa_rec.upg_orig_system_ref := p10_a33;
    ddp_clev_fa_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p10_a34);
    ddp_clev_fa_rec.orig_system_source_code := p10_a35;
    ddp_clev_fa_rec.orig_system_id1 := rosetta_g_miss_num_map(p10_a36);
    ddp_clev_fa_rec.orig_system_reference1 := p10_a37;
    ddp_clev_fa_rec.attribute_category := p10_a38;
    ddp_clev_fa_rec.attribute1 := p10_a39;
    ddp_clev_fa_rec.attribute2 := p10_a40;
    ddp_clev_fa_rec.attribute3 := p10_a41;
    ddp_clev_fa_rec.attribute4 := p10_a42;
    ddp_clev_fa_rec.attribute5 := p10_a43;
    ddp_clev_fa_rec.attribute6 := p10_a44;
    ddp_clev_fa_rec.attribute7 := p10_a45;
    ddp_clev_fa_rec.attribute8 := p10_a46;
    ddp_clev_fa_rec.attribute9 := p10_a47;
    ddp_clev_fa_rec.attribute10 := p10_a48;
    ddp_clev_fa_rec.attribute11 := p10_a49;
    ddp_clev_fa_rec.attribute12 := p10_a50;
    ddp_clev_fa_rec.attribute13 := p10_a51;
    ddp_clev_fa_rec.attribute14 := p10_a52;
    ddp_clev_fa_rec.attribute15 := p10_a53;
    ddp_clev_fa_rec.created_by := rosetta_g_miss_num_map(p10_a54);
    ddp_clev_fa_rec.creation_date := rosetta_g_miss_date_in_map(p10_a55);
    ddp_clev_fa_rec.last_updated_by := rosetta_g_miss_num_map(p10_a56);
    ddp_clev_fa_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a57);
    ddp_clev_fa_rec.price_type := p10_a58;
    ddp_clev_fa_rec.currency_code := p10_a59;
    ddp_clev_fa_rec.currency_code_renewed := p10_a60;
    ddp_clev_fa_rec.last_update_login := rosetta_g_miss_num_map(p10_a61);
    ddp_clev_fa_rec.old_sts_code := p10_a62;
    ddp_clev_fa_rec.new_sts_code := p10_a63;
    ddp_clev_fa_rec.old_ste_code := p10_a64;
    ddp_clev_fa_rec.new_ste_code := p10_a65;
    ddp_clev_fa_rec.call_action_asmblr := p10_a66;
    ddp_clev_fa_rec.request_id := rosetta_g_miss_num_map(p10_a67);
    ddp_clev_fa_rec.program_application_id := rosetta_g_miss_num_map(p10_a68);
    ddp_clev_fa_rec.program_id := rosetta_g_miss_num_map(p10_a69);
    ddp_clev_fa_rec.program_update_date := rosetta_g_miss_date_in_map(p10_a70);
    ddp_clev_fa_rec.price_list_id := rosetta_g_miss_num_map(p10_a71);
    ddp_clev_fa_rec.pricing_date := rosetta_g_miss_date_in_map(p10_a72);
    ddp_clev_fa_rec.price_list_line_id := rosetta_g_miss_num_map(p10_a73);
    ddp_clev_fa_rec.line_list_price := rosetta_g_miss_num_map(p10_a74);
    ddp_clev_fa_rec.item_to_price_yn := p10_a75;
    ddp_clev_fa_rec.price_basis_yn := p10_a76;
    ddp_clev_fa_rec.config_header_id := rosetta_g_miss_num_map(p10_a77);
    ddp_clev_fa_rec.config_revision_number := rosetta_g_miss_num_map(p10_a78);
    ddp_clev_fa_rec.config_complete_yn := p10_a79;
    ddp_clev_fa_rec.config_valid_yn := p10_a80;
    ddp_clev_fa_rec.config_top_model_line_id := rosetta_g_miss_num_map(p10_a81);
    ddp_clev_fa_rec.config_item_type := p10_a82;
    ddp_clev_fa_rec.config_item_id := rosetta_g_miss_num_map(p10_a83);
    ddp_clev_fa_rec.cust_acct_id := rosetta_g_miss_num_map(p10_a84);
    ddp_clev_fa_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p10_a85);
    ddp_clev_fa_rec.inv_rule_id := rosetta_g_miss_num_map(p10_a86);
    ddp_clev_fa_rec.line_renewal_type_code := p10_a87;
    ddp_clev_fa_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p10_a88);
    ddp_clev_fa_rec.payment_term_id := rosetta_g_miss_num_map(p10_a89);

    ddp_cimv_fa_rec.id := rosetta_g_miss_num_map(p11_a0);
    ddp_cimv_fa_rec.object_version_number := rosetta_g_miss_num_map(p11_a1);
    ddp_cimv_fa_rec.cle_id := rosetta_g_miss_num_map(p11_a2);
    ddp_cimv_fa_rec.chr_id := rosetta_g_miss_num_map(p11_a3);
    ddp_cimv_fa_rec.cle_id_for := rosetta_g_miss_num_map(p11_a4);
    ddp_cimv_fa_rec.dnz_chr_id := rosetta_g_miss_num_map(p11_a5);
    ddp_cimv_fa_rec.object1_id1 := p11_a6;
    ddp_cimv_fa_rec.object1_id2 := p11_a7;
    ddp_cimv_fa_rec.jtot_object1_code := p11_a8;
    ddp_cimv_fa_rec.uom_code := p11_a9;
    ddp_cimv_fa_rec.exception_yn := p11_a10;
    ddp_cimv_fa_rec.number_of_items := rosetta_g_miss_num_map(p11_a11);
    ddp_cimv_fa_rec.upg_orig_system_ref := p11_a12;
    ddp_cimv_fa_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p11_a13);
    ddp_cimv_fa_rec.priced_item_yn := p11_a14;
    ddp_cimv_fa_rec.created_by := rosetta_g_miss_num_map(p11_a15);
    ddp_cimv_fa_rec.creation_date := rosetta_g_miss_date_in_map(p11_a16);
    ddp_cimv_fa_rec.last_updated_by := rosetta_g_miss_num_map(p11_a17);
    ddp_cimv_fa_rec.last_update_date := rosetta_g_miss_date_in_map(p11_a18);
    ddp_cimv_fa_rec.last_update_login := rosetta_g_miss_num_map(p11_a19);

    ddp_talv_fa_rec.id := rosetta_g_miss_num_map(p12_a0);
    ddp_talv_fa_rec.object_version_number := rosetta_g_miss_num_map(p12_a1);
    ddp_talv_fa_rec.sfwt_flag := p12_a2;
    ddp_talv_fa_rec.tas_id := rosetta_g_miss_num_map(p12_a3);
    ddp_talv_fa_rec.ilo_id := rosetta_g_miss_num_map(p12_a4);
    ddp_talv_fa_rec.ilo_id_old := rosetta_g_miss_num_map(p12_a5);
    ddp_talv_fa_rec.iay_id := rosetta_g_miss_num_map(p12_a6);
    ddp_talv_fa_rec.iay_id_new := rosetta_g_miss_num_map(p12_a7);
    ddp_talv_fa_rec.kle_id := rosetta_g_miss_num_map(p12_a8);
    ddp_talv_fa_rec.dnz_khr_id := rosetta_g_miss_num_map(p12_a9);
    ddp_talv_fa_rec.line_number := rosetta_g_miss_num_map(p12_a10);
    ddp_talv_fa_rec.org_id := rosetta_g_miss_num_map(p12_a11);
    ddp_talv_fa_rec.tal_type := p12_a12;
    ddp_talv_fa_rec.asset_number := p12_a13;
    ddp_talv_fa_rec.description := p12_a14;
    ddp_talv_fa_rec.fa_location_id := rosetta_g_miss_num_map(p12_a15);
    ddp_talv_fa_rec.original_cost := rosetta_g_miss_num_map(p12_a16);
    ddp_talv_fa_rec.current_units := rosetta_g_miss_num_map(p12_a17);
    ddp_talv_fa_rec.manufacturer_name := p12_a18;
    ddp_talv_fa_rec.year_manufactured := rosetta_g_miss_num_map(p12_a19);
    ddp_talv_fa_rec.supplier_id := rosetta_g_miss_num_map(p12_a20);
    ddp_talv_fa_rec.used_asset_yn := p12_a21;
    ddp_talv_fa_rec.tag_number := p12_a22;
    ddp_talv_fa_rec.model_number := p12_a23;
    ddp_talv_fa_rec.corporate_book := p12_a24;
    ddp_talv_fa_rec.date_purchased := rosetta_g_miss_date_in_map(p12_a25);
    ddp_talv_fa_rec.date_delivery := rosetta_g_miss_date_in_map(p12_a26);
    ddp_talv_fa_rec.in_service_date := rosetta_g_miss_date_in_map(p12_a27);
    ddp_talv_fa_rec.life_in_months := rosetta_g_miss_num_map(p12_a28);
    ddp_talv_fa_rec.depreciation_id := rosetta_g_miss_num_map(p12_a29);
    ddp_talv_fa_rec.depreciation_cost := rosetta_g_miss_num_map(p12_a30);
    ddp_talv_fa_rec.deprn_method := p12_a31;
    ddp_talv_fa_rec.deprn_rate := rosetta_g_miss_num_map(p12_a32);
    ddp_talv_fa_rec.salvage_value := rosetta_g_miss_num_map(p12_a33);
    ddp_talv_fa_rec.percent_salvage_value := rosetta_g_miss_num_map(p12_a34);
    ddp_talv_fa_rec.asset_key_id := rosetta_g_miss_num_map(p12_a35);
    ddp_talv_fa_rec.attribute_category := p12_a36;
    ddp_talv_fa_rec.attribute1 := p12_a37;
    ddp_talv_fa_rec.attribute2 := p12_a38;
    ddp_talv_fa_rec.attribute3 := p12_a39;
    ddp_talv_fa_rec.attribute4 := p12_a40;
    ddp_talv_fa_rec.attribute5 := p12_a41;
    ddp_talv_fa_rec.attribute6 := p12_a42;
    ddp_talv_fa_rec.attribute7 := p12_a43;
    ddp_talv_fa_rec.attribute8 := p12_a44;
    ddp_talv_fa_rec.attribute9 := p12_a45;
    ddp_talv_fa_rec.attribute10 := p12_a46;
    ddp_talv_fa_rec.attribute11 := p12_a47;
    ddp_talv_fa_rec.attribute12 := p12_a48;
    ddp_talv_fa_rec.attribute13 := p12_a49;
    ddp_talv_fa_rec.attribute14 := p12_a50;
    ddp_talv_fa_rec.attribute15 := p12_a51;
    ddp_talv_fa_rec.created_by := rosetta_g_miss_num_map(p12_a52);
    ddp_talv_fa_rec.creation_date := rosetta_g_miss_date_in_map(p12_a53);
    ddp_talv_fa_rec.last_updated_by := rosetta_g_miss_num_map(p12_a54);
    ddp_talv_fa_rec.last_update_date := rosetta_g_miss_date_in_map(p12_a55);
    ddp_talv_fa_rec.last_update_login := rosetta_g_miss_num_map(p12_a56);
    ddp_talv_fa_rec.depreciate_yn := p12_a57;
    ddp_talv_fa_rec.hold_period_days := rosetta_g_miss_num_map(p12_a58);
    ddp_talv_fa_rec.old_salvage_value := rosetta_g_miss_num_map(p12_a59);
    ddp_talv_fa_rec.new_residual_value := rosetta_g_miss_num_map(p12_a60);
    ddp_talv_fa_rec.old_residual_value := rosetta_g_miss_num_map(p12_a61);
    ddp_talv_fa_rec.units_retired := rosetta_g_miss_num_map(p12_a62);
    ddp_talv_fa_rec.cost_retired := rosetta_g_miss_num_map(p12_a63);
    ddp_talv_fa_rec.sale_proceeds := rosetta_g_miss_num_map(p12_a64);
    ddp_talv_fa_rec.removal_cost := rosetta_g_miss_num_map(p12_a65);
    ddp_talv_fa_rec.dnz_asset_id := rosetta_g_miss_num_map(p12_a66);
    ddp_talv_fa_rec.date_due := rosetta_g_miss_date_in_map(p12_a67);
    ddp_talv_fa_rec.rep_asset_id := rosetta_g_miss_num_map(p12_a68);
    ddp_talv_fa_rec.lke_asset_id := rosetta_g_miss_num_map(p12_a69);
    ddp_talv_fa_rec.match_amount := rosetta_g_miss_num_map(p12_a70);
    ddp_talv_fa_rec.split_into_singles_flag := p12_a71;
    ddp_talv_fa_rec.split_into_units := rosetta_g_miss_num_map(p12_a72);
    ddp_talv_fa_rec.currency_code := p12_a73;
    ddp_talv_fa_rec.currency_conversion_type := p12_a74;
    ddp_talv_fa_rec.currency_conversion_rate := rosetta_g_miss_num_map(p12_a75);
    ddp_talv_fa_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p12_a76);

    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_itiv_ib_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      , p13_a24
      , p13_a25
      , p13_a26
      , p13_a27
      , p13_a28
      , p13_a29
      , p13_a30
      , p13_a31
      , p13_a32
      , p13_a33
      , p13_a34
      , p13_a35
      , p13_a36
      , p13_a37
      , p13_a38
      , p13_a39
      , p13_a40
      , p13_a41
      , p13_a42
      , p13_a43
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.create_all_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_fin_rec,
      ddp_klev_fin_rec,
      ddp_cimv_model_rec,
      ddp_clev_fa_rec,
      ddp_cimv_fa_rec,
      ddp_talv_fa_rec,
      ddp_itiv_ib_tbl,
      ddx_clev_fin_rec,
      ddx_clev_model_rec,
      ddx_clev_fa_rec,
      ddx_clev_ib_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    p14_a0 := rosetta_g_miss_num_map(ddx_clev_fin_rec.id);
    p14_a1 := rosetta_g_miss_num_map(ddx_clev_fin_rec.object_version_number);
    p14_a2 := ddx_clev_fin_rec.sfwt_flag;
    p14_a3 := rosetta_g_miss_num_map(ddx_clev_fin_rec.chr_id);
    p14_a4 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id);
    p14_a5 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed);
    p14_a6 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed_to);
    p14_a7 := rosetta_g_miss_num_map(ddx_clev_fin_rec.lse_id);
    p14_a8 := ddx_clev_fin_rec.line_number;
    p14_a9 := ddx_clev_fin_rec.sts_code;
    p14_a10 := rosetta_g_miss_num_map(ddx_clev_fin_rec.display_sequence);
    p14_a11 := ddx_clev_fin_rec.trn_code;
    p14_a12 := rosetta_g_miss_num_map(ddx_clev_fin_rec.dnz_chr_id);
    p14_a13 := ddx_clev_fin_rec.comments;
    p14_a14 := ddx_clev_fin_rec.item_description;
    p14_a15 := ddx_clev_fin_rec.oke_boe_description;
    p14_a16 := ddx_clev_fin_rec.cognomen;
    p14_a17 := ddx_clev_fin_rec.hidden_ind;
    p14_a18 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit);
    p14_a19 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit_percent);
    p14_a20 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated);
    p14_a21 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated_renewed);
    p14_a22 := ddx_clev_fin_rec.price_level_ind;
    p14_a23 := ddx_clev_fin_rec.invoice_line_level_ind;
    p14_a24 := ddx_clev_fin_rec.dpas_rating;
    p14_a25 := ddx_clev_fin_rec.block23text;
    p14_a26 := ddx_clev_fin_rec.exception_yn;
    p14_a27 := ddx_clev_fin_rec.template_used;
    p14_a28 := ddx_clev_fin_rec.date_terminated;
    p14_a29 := ddx_clev_fin_rec.name;
    p14_a30 := ddx_clev_fin_rec.start_date;
    p14_a31 := ddx_clev_fin_rec.end_date;
    p14_a32 := ddx_clev_fin_rec.date_renewed;
    p14_a33 := ddx_clev_fin_rec.upg_orig_system_ref;
    p14_a34 := rosetta_g_miss_num_map(ddx_clev_fin_rec.upg_orig_system_ref_id);
    p14_a35 := ddx_clev_fin_rec.orig_system_source_code;
    p14_a36 := rosetta_g_miss_num_map(ddx_clev_fin_rec.orig_system_id1);
    p14_a37 := ddx_clev_fin_rec.orig_system_reference1;
    p14_a38 := ddx_clev_fin_rec.attribute_category;
    p14_a39 := ddx_clev_fin_rec.attribute1;
    p14_a40 := ddx_clev_fin_rec.attribute2;
    p14_a41 := ddx_clev_fin_rec.attribute3;
    p14_a42 := ddx_clev_fin_rec.attribute4;
    p14_a43 := ddx_clev_fin_rec.attribute5;
    p14_a44 := ddx_clev_fin_rec.attribute6;
    p14_a45 := ddx_clev_fin_rec.attribute7;
    p14_a46 := ddx_clev_fin_rec.attribute8;
    p14_a47 := ddx_clev_fin_rec.attribute9;
    p14_a48 := ddx_clev_fin_rec.attribute10;
    p14_a49 := ddx_clev_fin_rec.attribute11;
    p14_a50 := ddx_clev_fin_rec.attribute12;
    p14_a51 := ddx_clev_fin_rec.attribute13;
    p14_a52 := ddx_clev_fin_rec.attribute14;
    p14_a53 := ddx_clev_fin_rec.attribute15;
    p14_a54 := rosetta_g_miss_num_map(ddx_clev_fin_rec.created_by);
    p14_a55 := ddx_clev_fin_rec.creation_date;
    p14_a56 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_updated_by);
    p14_a57 := ddx_clev_fin_rec.last_update_date;
    p14_a58 := ddx_clev_fin_rec.price_type;
    p14_a59 := ddx_clev_fin_rec.currency_code;
    p14_a60 := ddx_clev_fin_rec.currency_code_renewed;
    p14_a61 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_update_login);
    p14_a62 := ddx_clev_fin_rec.old_sts_code;
    p14_a63 := ddx_clev_fin_rec.new_sts_code;
    p14_a64 := ddx_clev_fin_rec.old_ste_code;
    p14_a65 := ddx_clev_fin_rec.new_ste_code;
    p14_a66 := ddx_clev_fin_rec.call_action_asmblr;
    p14_a67 := rosetta_g_miss_num_map(ddx_clev_fin_rec.request_id);
    p14_a68 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_application_id);
    p14_a69 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_id);
    p14_a70 := ddx_clev_fin_rec.program_update_date;
    p14_a71 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_id);
    p14_a72 := ddx_clev_fin_rec.pricing_date;
    p14_a73 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_line_id);
    p14_a74 := rosetta_g_miss_num_map(ddx_clev_fin_rec.line_list_price);
    p14_a75 := ddx_clev_fin_rec.item_to_price_yn;
    p14_a76 := ddx_clev_fin_rec.price_basis_yn;
    p14_a77 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_header_id);
    p14_a78 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_revision_number);
    p14_a79 := ddx_clev_fin_rec.config_complete_yn;
    p14_a80 := ddx_clev_fin_rec.config_valid_yn;
    p14_a81 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_top_model_line_id);
    p14_a82 := ddx_clev_fin_rec.config_item_type;
    p14_a83 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_item_id);
    p14_a84 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cust_acct_id);
    p14_a85 := rosetta_g_miss_num_map(ddx_clev_fin_rec.bill_to_site_use_id);
    p14_a86 := rosetta_g_miss_num_map(ddx_clev_fin_rec.inv_rule_id);
    p14_a87 := ddx_clev_fin_rec.line_renewal_type_code;
    p14_a88 := rosetta_g_miss_num_map(ddx_clev_fin_rec.ship_to_site_use_id);
    p14_a89 := rosetta_g_miss_num_map(ddx_clev_fin_rec.payment_term_id);

    p15_a0 := rosetta_g_miss_num_map(ddx_clev_model_rec.id);
    p15_a1 := rosetta_g_miss_num_map(ddx_clev_model_rec.object_version_number);
    p15_a2 := ddx_clev_model_rec.sfwt_flag;
    p15_a3 := rosetta_g_miss_num_map(ddx_clev_model_rec.chr_id);
    p15_a4 := rosetta_g_miss_num_map(ddx_clev_model_rec.cle_id);
    p15_a5 := rosetta_g_miss_num_map(ddx_clev_model_rec.cle_id_renewed);
    p15_a6 := rosetta_g_miss_num_map(ddx_clev_model_rec.cle_id_renewed_to);
    p15_a7 := rosetta_g_miss_num_map(ddx_clev_model_rec.lse_id);
    p15_a8 := ddx_clev_model_rec.line_number;
    p15_a9 := ddx_clev_model_rec.sts_code;
    p15_a10 := rosetta_g_miss_num_map(ddx_clev_model_rec.display_sequence);
    p15_a11 := ddx_clev_model_rec.trn_code;
    p15_a12 := rosetta_g_miss_num_map(ddx_clev_model_rec.dnz_chr_id);
    p15_a13 := ddx_clev_model_rec.comments;
    p15_a14 := ddx_clev_model_rec.item_description;
    p15_a15 := ddx_clev_model_rec.oke_boe_description;
    p15_a16 := ddx_clev_model_rec.cognomen;
    p15_a17 := ddx_clev_model_rec.hidden_ind;
    p15_a18 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_unit);
    p15_a19 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_unit_percent);
    p15_a20 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_negotiated);
    p15_a21 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_negotiated_renewed);
    p15_a22 := ddx_clev_model_rec.price_level_ind;
    p15_a23 := ddx_clev_model_rec.invoice_line_level_ind;
    p15_a24 := ddx_clev_model_rec.dpas_rating;
    p15_a25 := ddx_clev_model_rec.block23text;
    p15_a26 := ddx_clev_model_rec.exception_yn;
    p15_a27 := ddx_clev_model_rec.template_used;
    p15_a28 := ddx_clev_model_rec.date_terminated;
    p15_a29 := ddx_clev_model_rec.name;
    p15_a30 := ddx_clev_model_rec.start_date;
    p15_a31 := ddx_clev_model_rec.end_date;
    p15_a32 := ddx_clev_model_rec.date_renewed;
    p15_a33 := ddx_clev_model_rec.upg_orig_system_ref;
    p15_a34 := rosetta_g_miss_num_map(ddx_clev_model_rec.upg_orig_system_ref_id);
    p15_a35 := ddx_clev_model_rec.orig_system_source_code;
    p15_a36 := rosetta_g_miss_num_map(ddx_clev_model_rec.orig_system_id1);
    p15_a37 := ddx_clev_model_rec.orig_system_reference1;
    p15_a38 := ddx_clev_model_rec.attribute_category;
    p15_a39 := ddx_clev_model_rec.attribute1;
    p15_a40 := ddx_clev_model_rec.attribute2;
    p15_a41 := ddx_clev_model_rec.attribute3;
    p15_a42 := ddx_clev_model_rec.attribute4;
    p15_a43 := ddx_clev_model_rec.attribute5;
    p15_a44 := ddx_clev_model_rec.attribute6;
    p15_a45 := ddx_clev_model_rec.attribute7;
    p15_a46 := ddx_clev_model_rec.attribute8;
    p15_a47 := ddx_clev_model_rec.attribute9;
    p15_a48 := ddx_clev_model_rec.attribute10;
    p15_a49 := ddx_clev_model_rec.attribute11;
    p15_a50 := ddx_clev_model_rec.attribute12;
    p15_a51 := ddx_clev_model_rec.attribute13;
    p15_a52 := ddx_clev_model_rec.attribute14;
    p15_a53 := ddx_clev_model_rec.attribute15;
    p15_a54 := rosetta_g_miss_num_map(ddx_clev_model_rec.created_by);
    p15_a55 := ddx_clev_model_rec.creation_date;
    p15_a56 := rosetta_g_miss_num_map(ddx_clev_model_rec.last_updated_by);
    p15_a57 := ddx_clev_model_rec.last_update_date;
    p15_a58 := ddx_clev_model_rec.price_type;
    p15_a59 := ddx_clev_model_rec.currency_code;
    p15_a60 := ddx_clev_model_rec.currency_code_renewed;
    p15_a61 := rosetta_g_miss_num_map(ddx_clev_model_rec.last_update_login);
    p15_a62 := ddx_clev_model_rec.old_sts_code;
    p15_a63 := ddx_clev_model_rec.new_sts_code;
    p15_a64 := ddx_clev_model_rec.old_ste_code;
    p15_a65 := ddx_clev_model_rec.new_ste_code;
    p15_a66 := ddx_clev_model_rec.call_action_asmblr;
    p15_a67 := rosetta_g_miss_num_map(ddx_clev_model_rec.request_id);
    p15_a68 := rosetta_g_miss_num_map(ddx_clev_model_rec.program_application_id);
    p15_a69 := rosetta_g_miss_num_map(ddx_clev_model_rec.program_id);
    p15_a70 := ddx_clev_model_rec.program_update_date;
    p15_a71 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_list_id);
    p15_a72 := ddx_clev_model_rec.pricing_date;
    p15_a73 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_list_line_id);
    p15_a74 := rosetta_g_miss_num_map(ddx_clev_model_rec.line_list_price);
    p15_a75 := ddx_clev_model_rec.item_to_price_yn;
    p15_a76 := ddx_clev_model_rec.price_basis_yn;
    p15_a77 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_header_id);
    p15_a78 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_revision_number);
    p15_a79 := ddx_clev_model_rec.config_complete_yn;
    p15_a80 := ddx_clev_model_rec.config_valid_yn;
    p15_a81 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_top_model_line_id);
    p15_a82 := ddx_clev_model_rec.config_item_type;
    p15_a83 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_item_id);
    p15_a84 := rosetta_g_miss_num_map(ddx_clev_model_rec.cust_acct_id);
    p15_a85 := rosetta_g_miss_num_map(ddx_clev_model_rec.bill_to_site_use_id);
    p15_a86 := rosetta_g_miss_num_map(ddx_clev_model_rec.inv_rule_id);
    p15_a87 := ddx_clev_model_rec.line_renewal_type_code;
    p15_a88 := rosetta_g_miss_num_map(ddx_clev_model_rec.ship_to_site_use_id);
    p15_a89 := rosetta_g_miss_num_map(ddx_clev_model_rec.payment_term_id);

    p16_a0 := rosetta_g_miss_num_map(ddx_clev_fa_rec.id);
    p16_a1 := rosetta_g_miss_num_map(ddx_clev_fa_rec.object_version_number);
    p16_a2 := ddx_clev_fa_rec.sfwt_flag;
    p16_a3 := rosetta_g_miss_num_map(ddx_clev_fa_rec.chr_id);
    p16_a4 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cle_id);
    p16_a5 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cle_id_renewed);
    p16_a6 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cle_id_renewed_to);
    p16_a7 := rosetta_g_miss_num_map(ddx_clev_fa_rec.lse_id);
    p16_a8 := ddx_clev_fa_rec.line_number;
    p16_a9 := ddx_clev_fa_rec.sts_code;
    p16_a10 := rosetta_g_miss_num_map(ddx_clev_fa_rec.display_sequence);
    p16_a11 := ddx_clev_fa_rec.trn_code;
    p16_a12 := rosetta_g_miss_num_map(ddx_clev_fa_rec.dnz_chr_id);
    p16_a13 := ddx_clev_fa_rec.comments;
    p16_a14 := ddx_clev_fa_rec.item_description;
    p16_a15 := ddx_clev_fa_rec.oke_boe_description;
    p16_a16 := ddx_clev_fa_rec.cognomen;
    p16_a17 := ddx_clev_fa_rec.hidden_ind;
    p16_a18 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_unit);
    p16_a19 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_unit_percent);
    p16_a20 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_negotiated);
    p16_a21 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_negotiated_renewed);
    p16_a22 := ddx_clev_fa_rec.price_level_ind;
    p16_a23 := ddx_clev_fa_rec.invoice_line_level_ind;
    p16_a24 := ddx_clev_fa_rec.dpas_rating;
    p16_a25 := ddx_clev_fa_rec.block23text;
    p16_a26 := ddx_clev_fa_rec.exception_yn;
    p16_a27 := ddx_clev_fa_rec.template_used;
    p16_a28 := ddx_clev_fa_rec.date_terminated;
    p16_a29 := ddx_clev_fa_rec.name;
    p16_a30 := ddx_clev_fa_rec.start_date;
    p16_a31 := ddx_clev_fa_rec.end_date;
    p16_a32 := ddx_clev_fa_rec.date_renewed;
    p16_a33 := ddx_clev_fa_rec.upg_orig_system_ref;
    p16_a34 := rosetta_g_miss_num_map(ddx_clev_fa_rec.upg_orig_system_ref_id);
    p16_a35 := ddx_clev_fa_rec.orig_system_source_code;
    p16_a36 := rosetta_g_miss_num_map(ddx_clev_fa_rec.orig_system_id1);
    p16_a37 := ddx_clev_fa_rec.orig_system_reference1;
    p16_a38 := ddx_clev_fa_rec.attribute_category;
    p16_a39 := ddx_clev_fa_rec.attribute1;
    p16_a40 := ddx_clev_fa_rec.attribute2;
    p16_a41 := ddx_clev_fa_rec.attribute3;
    p16_a42 := ddx_clev_fa_rec.attribute4;
    p16_a43 := ddx_clev_fa_rec.attribute5;
    p16_a44 := ddx_clev_fa_rec.attribute6;
    p16_a45 := ddx_clev_fa_rec.attribute7;
    p16_a46 := ddx_clev_fa_rec.attribute8;
    p16_a47 := ddx_clev_fa_rec.attribute9;
    p16_a48 := ddx_clev_fa_rec.attribute10;
    p16_a49 := ddx_clev_fa_rec.attribute11;
    p16_a50 := ddx_clev_fa_rec.attribute12;
    p16_a51 := ddx_clev_fa_rec.attribute13;
    p16_a52 := ddx_clev_fa_rec.attribute14;
    p16_a53 := ddx_clev_fa_rec.attribute15;
    p16_a54 := rosetta_g_miss_num_map(ddx_clev_fa_rec.created_by);
    p16_a55 := ddx_clev_fa_rec.creation_date;
    p16_a56 := rosetta_g_miss_num_map(ddx_clev_fa_rec.last_updated_by);
    p16_a57 := ddx_clev_fa_rec.last_update_date;
    p16_a58 := ddx_clev_fa_rec.price_type;
    p16_a59 := ddx_clev_fa_rec.currency_code;
    p16_a60 := ddx_clev_fa_rec.currency_code_renewed;
    p16_a61 := rosetta_g_miss_num_map(ddx_clev_fa_rec.last_update_login);
    p16_a62 := ddx_clev_fa_rec.old_sts_code;
    p16_a63 := ddx_clev_fa_rec.new_sts_code;
    p16_a64 := ddx_clev_fa_rec.old_ste_code;
    p16_a65 := ddx_clev_fa_rec.new_ste_code;
    p16_a66 := ddx_clev_fa_rec.call_action_asmblr;
    p16_a67 := rosetta_g_miss_num_map(ddx_clev_fa_rec.request_id);
    p16_a68 := rosetta_g_miss_num_map(ddx_clev_fa_rec.program_application_id);
    p16_a69 := rosetta_g_miss_num_map(ddx_clev_fa_rec.program_id);
    p16_a70 := ddx_clev_fa_rec.program_update_date;
    p16_a71 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_list_id);
    p16_a72 := ddx_clev_fa_rec.pricing_date;
    p16_a73 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_list_line_id);
    p16_a74 := rosetta_g_miss_num_map(ddx_clev_fa_rec.line_list_price);
    p16_a75 := ddx_clev_fa_rec.item_to_price_yn;
    p16_a76 := ddx_clev_fa_rec.price_basis_yn;
    p16_a77 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_header_id);
    p16_a78 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_revision_number);
    p16_a79 := ddx_clev_fa_rec.config_complete_yn;
    p16_a80 := ddx_clev_fa_rec.config_valid_yn;
    p16_a81 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_top_model_line_id);
    p16_a82 := ddx_clev_fa_rec.config_item_type;
    p16_a83 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_item_id);
    p16_a84 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cust_acct_id);
    p16_a85 := rosetta_g_miss_num_map(ddx_clev_fa_rec.bill_to_site_use_id);
    p16_a86 := rosetta_g_miss_num_map(ddx_clev_fa_rec.inv_rule_id);
    p16_a87 := ddx_clev_fa_rec.line_renewal_type_code;
    p16_a88 := rosetta_g_miss_num_map(ddx_clev_fa_rec.ship_to_site_use_id);
    p16_a89 := rosetta_g_miss_num_map(ddx_clev_fa_rec.payment_term_id);

    p17_a0 := rosetta_g_miss_num_map(ddx_clev_ib_rec.id);
    p17_a1 := rosetta_g_miss_num_map(ddx_clev_ib_rec.object_version_number);
    p17_a2 := ddx_clev_ib_rec.sfwt_flag;
    p17_a3 := rosetta_g_miss_num_map(ddx_clev_ib_rec.chr_id);
    p17_a4 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cle_id);
    p17_a5 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cle_id_renewed);
    p17_a6 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cle_id_renewed_to);
    p17_a7 := rosetta_g_miss_num_map(ddx_clev_ib_rec.lse_id);
    p17_a8 := ddx_clev_ib_rec.line_number;
    p17_a9 := ddx_clev_ib_rec.sts_code;
    p17_a10 := rosetta_g_miss_num_map(ddx_clev_ib_rec.display_sequence);
    p17_a11 := ddx_clev_ib_rec.trn_code;
    p17_a12 := rosetta_g_miss_num_map(ddx_clev_ib_rec.dnz_chr_id);
    p17_a13 := ddx_clev_ib_rec.comments;
    p17_a14 := ddx_clev_ib_rec.item_description;
    p17_a15 := ddx_clev_ib_rec.oke_boe_description;
    p17_a16 := ddx_clev_ib_rec.cognomen;
    p17_a17 := ddx_clev_ib_rec.hidden_ind;
    p17_a18 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_unit);
    p17_a19 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_unit_percent);
    p17_a20 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_negotiated);
    p17_a21 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_negotiated_renewed);
    p17_a22 := ddx_clev_ib_rec.price_level_ind;
    p17_a23 := ddx_clev_ib_rec.invoice_line_level_ind;
    p17_a24 := ddx_clev_ib_rec.dpas_rating;
    p17_a25 := ddx_clev_ib_rec.block23text;
    p17_a26 := ddx_clev_ib_rec.exception_yn;
    p17_a27 := ddx_clev_ib_rec.template_used;
    p17_a28 := ddx_clev_ib_rec.date_terminated;
    p17_a29 := ddx_clev_ib_rec.name;
    p17_a30 := ddx_clev_ib_rec.start_date;
    p17_a31 := ddx_clev_ib_rec.end_date;
    p17_a32 := ddx_clev_ib_rec.date_renewed;
    p17_a33 := ddx_clev_ib_rec.upg_orig_system_ref;
    p17_a34 := rosetta_g_miss_num_map(ddx_clev_ib_rec.upg_orig_system_ref_id);
    p17_a35 := ddx_clev_ib_rec.orig_system_source_code;
    p17_a36 := rosetta_g_miss_num_map(ddx_clev_ib_rec.orig_system_id1);
    p17_a37 := ddx_clev_ib_rec.orig_system_reference1;
    p17_a38 := ddx_clev_ib_rec.attribute_category;
    p17_a39 := ddx_clev_ib_rec.attribute1;
    p17_a40 := ddx_clev_ib_rec.attribute2;
    p17_a41 := ddx_clev_ib_rec.attribute3;
    p17_a42 := ddx_clev_ib_rec.attribute4;
    p17_a43 := ddx_clev_ib_rec.attribute5;
    p17_a44 := ddx_clev_ib_rec.attribute6;
    p17_a45 := ddx_clev_ib_rec.attribute7;
    p17_a46 := ddx_clev_ib_rec.attribute8;
    p17_a47 := ddx_clev_ib_rec.attribute9;
    p17_a48 := ddx_clev_ib_rec.attribute10;
    p17_a49 := ddx_clev_ib_rec.attribute11;
    p17_a50 := ddx_clev_ib_rec.attribute12;
    p17_a51 := ddx_clev_ib_rec.attribute13;
    p17_a52 := ddx_clev_ib_rec.attribute14;
    p17_a53 := ddx_clev_ib_rec.attribute15;
    p17_a54 := rosetta_g_miss_num_map(ddx_clev_ib_rec.created_by);
    p17_a55 := ddx_clev_ib_rec.creation_date;
    p17_a56 := rosetta_g_miss_num_map(ddx_clev_ib_rec.last_updated_by);
    p17_a57 := ddx_clev_ib_rec.last_update_date;
    p17_a58 := ddx_clev_ib_rec.price_type;
    p17_a59 := ddx_clev_ib_rec.currency_code;
    p17_a60 := ddx_clev_ib_rec.currency_code_renewed;
    p17_a61 := rosetta_g_miss_num_map(ddx_clev_ib_rec.last_update_login);
    p17_a62 := ddx_clev_ib_rec.old_sts_code;
    p17_a63 := ddx_clev_ib_rec.new_sts_code;
    p17_a64 := ddx_clev_ib_rec.old_ste_code;
    p17_a65 := ddx_clev_ib_rec.new_ste_code;
    p17_a66 := ddx_clev_ib_rec.call_action_asmblr;
    p17_a67 := rosetta_g_miss_num_map(ddx_clev_ib_rec.request_id);
    p17_a68 := rosetta_g_miss_num_map(ddx_clev_ib_rec.program_application_id);
    p17_a69 := rosetta_g_miss_num_map(ddx_clev_ib_rec.program_id);
    p17_a70 := ddx_clev_ib_rec.program_update_date;
    p17_a71 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_list_id);
    p17_a72 := ddx_clev_ib_rec.pricing_date;
    p17_a73 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_list_line_id);
    p17_a74 := rosetta_g_miss_num_map(ddx_clev_ib_rec.line_list_price);
    p17_a75 := ddx_clev_ib_rec.item_to_price_yn;
    p17_a76 := ddx_clev_ib_rec.price_basis_yn;
    p17_a77 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_header_id);
    p17_a78 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_revision_number);
    p17_a79 := ddx_clev_ib_rec.config_complete_yn;
    p17_a80 := ddx_clev_ib_rec.config_valid_yn;
    p17_a81 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_top_model_line_id);
    p17_a82 := ddx_clev_ib_rec.config_item_type;
    p17_a83 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_item_id);
    p17_a84 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cust_acct_id);
    p17_a85 := rosetta_g_miss_num_map(ddx_clev_ib_rec.bill_to_site_use_id);
    p17_a86 := rosetta_g_miss_num_map(ddx_clev_ib_rec.inv_rule_id);
    p17_a87 := ddx_clev_ib_rec.line_renewal_type_code;
    p17_a88 := rosetta_g_miss_num_map(ddx_clev_ib_rec.ship_to_site_use_id);
    p17_a89 := rosetta_g_miss_num_map(ddx_clev_ib_rec.payment_term_id);
  end;

  procedure update_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p16_a0 out nocopy  NUMBER
    , p16_a1 out nocopy  NUMBER
    , p16_a2 out nocopy  VARCHAR2
    , p16_a3 out nocopy  NUMBER
    , p16_a4 out nocopy  NUMBER
    , p16_a5 out nocopy  NUMBER
    , p16_a6 out nocopy  NUMBER
    , p16_a7 out nocopy  NUMBER
    , p16_a8 out nocopy  VARCHAR2
    , p16_a9 out nocopy  VARCHAR2
    , p16_a10 out nocopy  NUMBER
    , p16_a11 out nocopy  VARCHAR2
    , p16_a12 out nocopy  NUMBER
    , p16_a13 out nocopy  VARCHAR2
    , p16_a14 out nocopy  VARCHAR2
    , p16_a15 out nocopy  VARCHAR2
    , p16_a16 out nocopy  VARCHAR2
    , p16_a17 out nocopy  VARCHAR2
    , p16_a18 out nocopy  NUMBER
    , p16_a19 out nocopy  NUMBER
    , p16_a20 out nocopy  NUMBER
    , p16_a21 out nocopy  NUMBER
    , p16_a22 out nocopy  VARCHAR2
    , p16_a23 out nocopy  VARCHAR2
    , p16_a24 out nocopy  VARCHAR2
    , p16_a25 out nocopy  VARCHAR2
    , p16_a26 out nocopy  VARCHAR2
    , p16_a27 out nocopy  VARCHAR2
    , p16_a28 out nocopy  DATE
    , p16_a29 out nocopy  VARCHAR2
    , p16_a30 out nocopy  DATE
    , p16_a31 out nocopy  DATE
    , p16_a32 out nocopy  DATE
    , p16_a33 out nocopy  VARCHAR2
    , p16_a34 out nocopy  NUMBER
    , p16_a35 out nocopy  VARCHAR2
    , p16_a36 out nocopy  NUMBER
    , p16_a37 out nocopy  VARCHAR2
    , p16_a38 out nocopy  VARCHAR2
    , p16_a39 out nocopy  VARCHAR2
    , p16_a40 out nocopy  VARCHAR2
    , p16_a41 out nocopy  VARCHAR2
    , p16_a42 out nocopy  VARCHAR2
    , p16_a43 out nocopy  VARCHAR2
    , p16_a44 out nocopy  VARCHAR2
    , p16_a45 out nocopy  VARCHAR2
    , p16_a46 out nocopy  VARCHAR2
    , p16_a47 out nocopy  VARCHAR2
    , p16_a48 out nocopy  VARCHAR2
    , p16_a49 out nocopy  VARCHAR2
    , p16_a50 out nocopy  VARCHAR2
    , p16_a51 out nocopy  VARCHAR2
    , p16_a52 out nocopy  VARCHAR2
    , p16_a53 out nocopy  VARCHAR2
    , p16_a54 out nocopy  NUMBER
    , p16_a55 out nocopy  DATE
    , p16_a56 out nocopy  NUMBER
    , p16_a57 out nocopy  DATE
    , p16_a58 out nocopy  VARCHAR2
    , p16_a59 out nocopy  VARCHAR2
    , p16_a60 out nocopy  VARCHAR2
    , p16_a61 out nocopy  NUMBER
    , p16_a62 out nocopy  VARCHAR2
    , p16_a63 out nocopy  VARCHAR2
    , p16_a64 out nocopy  VARCHAR2
    , p16_a65 out nocopy  VARCHAR2
    , p16_a66 out nocopy  VARCHAR2
    , p16_a67 out nocopy  NUMBER
    , p16_a68 out nocopy  NUMBER
    , p16_a69 out nocopy  NUMBER
    , p16_a70 out nocopy  DATE
    , p16_a71 out nocopy  NUMBER
    , p16_a72 out nocopy  DATE
    , p16_a73 out nocopy  NUMBER
    , p16_a74 out nocopy  NUMBER
    , p16_a75 out nocopy  VARCHAR2
    , p16_a76 out nocopy  VARCHAR2
    , p16_a77 out nocopy  NUMBER
    , p16_a78 out nocopy  NUMBER
    , p16_a79 out nocopy  VARCHAR2
    , p16_a80 out nocopy  VARCHAR2
    , p16_a81 out nocopy  NUMBER
    , p16_a82 out nocopy  VARCHAR2
    , p16_a83 out nocopy  NUMBER
    , p16_a84 out nocopy  NUMBER
    , p16_a85 out nocopy  NUMBER
    , p16_a86 out nocopy  NUMBER
    , p16_a87 out nocopy  VARCHAR2
    , p16_a88 out nocopy  NUMBER
    , p16_a89 out nocopy  NUMBER
    , p17_a0 out nocopy  NUMBER
    , p17_a1 out nocopy  NUMBER
    , p17_a2 out nocopy  VARCHAR2
    , p17_a3 out nocopy  NUMBER
    , p17_a4 out nocopy  NUMBER
    , p17_a5 out nocopy  NUMBER
    , p17_a6 out nocopy  NUMBER
    , p17_a7 out nocopy  NUMBER
    , p17_a8 out nocopy  VARCHAR2
    , p17_a9 out nocopy  VARCHAR2
    , p17_a10 out nocopy  NUMBER
    , p17_a11 out nocopy  VARCHAR2
    , p17_a12 out nocopy  NUMBER
    , p17_a13 out nocopy  VARCHAR2
    , p17_a14 out nocopy  VARCHAR2
    , p17_a15 out nocopy  VARCHAR2
    , p17_a16 out nocopy  VARCHAR2
    , p17_a17 out nocopy  VARCHAR2
    , p17_a18 out nocopy  NUMBER
    , p17_a19 out nocopy  NUMBER
    , p17_a20 out nocopy  NUMBER
    , p17_a21 out nocopy  NUMBER
    , p17_a22 out nocopy  VARCHAR2
    , p17_a23 out nocopy  VARCHAR2
    , p17_a24 out nocopy  VARCHAR2
    , p17_a25 out nocopy  VARCHAR2
    , p17_a26 out nocopy  VARCHAR2
    , p17_a27 out nocopy  VARCHAR2
    , p17_a28 out nocopy  DATE
    , p17_a29 out nocopy  VARCHAR2
    , p17_a30 out nocopy  DATE
    , p17_a31 out nocopy  DATE
    , p17_a32 out nocopy  DATE
    , p17_a33 out nocopy  VARCHAR2
    , p17_a34 out nocopy  NUMBER
    , p17_a35 out nocopy  VARCHAR2
    , p17_a36 out nocopy  NUMBER
    , p17_a37 out nocopy  VARCHAR2
    , p17_a38 out nocopy  VARCHAR2
    , p17_a39 out nocopy  VARCHAR2
    , p17_a40 out nocopy  VARCHAR2
    , p17_a41 out nocopy  VARCHAR2
    , p17_a42 out nocopy  VARCHAR2
    , p17_a43 out nocopy  VARCHAR2
    , p17_a44 out nocopy  VARCHAR2
    , p17_a45 out nocopy  VARCHAR2
    , p17_a46 out nocopy  VARCHAR2
    , p17_a47 out nocopy  VARCHAR2
    , p17_a48 out nocopy  VARCHAR2
    , p17_a49 out nocopy  VARCHAR2
    , p17_a50 out nocopy  VARCHAR2
    , p17_a51 out nocopy  VARCHAR2
    , p17_a52 out nocopy  VARCHAR2
    , p17_a53 out nocopy  VARCHAR2
    , p17_a54 out nocopy  NUMBER
    , p17_a55 out nocopy  DATE
    , p17_a56 out nocopy  NUMBER
    , p17_a57 out nocopy  DATE
    , p17_a58 out nocopy  VARCHAR2
    , p17_a59 out nocopy  VARCHAR2
    , p17_a60 out nocopy  VARCHAR2
    , p17_a61 out nocopy  NUMBER
    , p17_a62 out nocopy  VARCHAR2
    , p17_a63 out nocopy  VARCHAR2
    , p17_a64 out nocopy  VARCHAR2
    , p17_a65 out nocopy  VARCHAR2
    , p17_a66 out nocopy  VARCHAR2
    , p17_a67 out nocopy  NUMBER
    , p17_a68 out nocopy  NUMBER
    , p17_a69 out nocopy  NUMBER
    , p17_a70 out nocopy  DATE
    , p17_a71 out nocopy  NUMBER
    , p17_a72 out nocopy  DATE
    , p17_a73 out nocopy  NUMBER
    , p17_a74 out nocopy  NUMBER
    , p17_a75 out nocopy  VARCHAR2
    , p17_a76 out nocopy  VARCHAR2
    , p17_a77 out nocopy  NUMBER
    , p17_a78 out nocopy  NUMBER
    , p17_a79 out nocopy  VARCHAR2
    , p17_a80 out nocopy  VARCHAR2
    , p17_a81 out nocopy  NUMBER
    , p17_a82 out nocopy  VARCHAR2
    , p17_a83 out nocopy  NUMBER
    , p17_a84 out nocopy  NUMBER
    , p17_a85 out nocopy  NUMBER
    , p17_a86 out nocopy  NUMBER
    , p17_a87 out nocopy  VARCHAR2
    , p17_a88 out nocopy  NUMBER
    , p17_a89 out nocopy  NUMBER
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  NUMBER
    , p18_a2 out nocopy  VARCHAR2
    , p18_a3 out nocopy  NUMBER
    , p18_a4 out nocopy  NUMBER
    , p18_a5 out nocopy  NUMBER
    , p18_a6 out nocopy  NUMBER
    , p18_a7 out nocopy  NUMBER
    , p18_a8 out nocopy  VARCHAR2
    , p18_a9 out nocopy  VARCHAR2
    , p18_a10 out nocopy  NUMBER
    , p18_a11 out nocopy  VARCHAR2
    , p18_a12 out nocopy  NUMBER
    , p18_a13 out nocopy  VARCHAR2
    , p18_a14 out nocopy  VARCHAR2
    , p18_a15 out nocopy  VARCHAR2
    , p18_a16 out nocopy  VARCHAR2
    , p18_a17 out nocopy  VARCHAR2
    , p18_a18 out nocopy  NUMBER
    , p18_a19 out nocopy  NUMBER
    , p18_a20 out nocopy  NUMBER
    , p18_a21 out nocopy  NUMBER
    , p18_a22 out nocopy  VARCHAR2
    , p18_a23 out nocopy  VARCHAR2
    , p18_a24 out nocopy  VARCHAR2
    , p18_a25 out nocopy  VARCHAR2
    , p18_a26 out nocopy  VARCHAR2
    , p18_a27 out nocopy  VARCHAR2
    , p18_a28 out nocopy  DATE
    , p18_a29 out nocopy  VARCHAR2
    , p18_a30 out nocopy  DATE
    , p18_a31 out nocopy  DATE
    , p18_a32 out nocopy  DATE
    , p18_a33 out nocopy  VARCHAR2
    , p18_a34 out nocopy  NUMBER
    , p18_a35 out nocopy  VARCHAR2
    , p18_a36 out nocopy  NUMBER
    , p18_a37 out nocopy  VARCHAR2
    , p18_a38 out nocopy  VARCHAR2
    , p18_a39 out nocopy  VARCHAR2
    , p18_a40 out nocopy  VARCHAR2
    , p18_a41 out nocopy  VARCHAR2
    , p18_a42 out nocopy  VARCHAR2
    , p18_a43 out nocopy  VARCHAR2
    , p18_a44 out nocopy  VARCHAR2
    , p18_a45 out nocopy  VARCHAR2
    , p18_a46 out nocopy  VARCHAR2
    , p18_a47 out nocopy  VARCHAR2
    , p18_a48 out nocopy  VARCHAR2
    , p18_a49 out nocopy  VARCHAR2
    , p18_a50 out nocopy  VARCHAR2
    , p18_a51 out nocopy  VARCHAR2
    , p18_a52 out nocopy  VARCHAR2
    , p18_a53 out nocopy  VARCHAR2
    , p18_a54 out nocopy  NUMBER
    , p18_a55 out nocopy  DATE
    , p18_a56 out nocopy  NUMBER
    , p18_a57 out nocopy  DATE
    , p18_a58 out nocopy  VARCHAR2
    , p18_a59 out nocopy  VARCHAR2
    , p18_a60 out nocopy  VARCHAR2
    , p18_a61 out nocopy  NUMBER
    , p18_a62 out nocopy  VARCHAR2
    , p18_a63 out nocopy  VARCHAR2
    , p18_a64 out nocopy  VARCHAR2
    , p18_a65 out nocopy  VARCHAR2
    , p18_a66 out nocopy  VARCHAR2
    , p18_a67 out nocopy  NUMBER
    , p18_a68 out nocopy  NUMBER
    , p18_a69 out nocopy  NUMBER
    , p18_a70 out nocopy  DATE
    , p18_a71 out nocopy  NUMBER
    , p18_a72 out nocopy  DATE
    , p18_a73 out nocopy  NUMBER
    , p18_a74 out nocopy  NUMBER
    , p18_a75 out nocopy  VARCHAR2
    , p18_a76 out nocopy  VARCHAR2
    , p18_a77 out nocopy  NUMBER
    , p18_a78 out nocopy  NUMBER
    , p18_a79 out nocopy  VARCHAR2
    , p18_a80 out nocopy  VARCHAR2
    , p18_a81 out nocopy  NUMBER
    , p18_a82 out nocopy  VARCHAR2
    , p18_a83 out nocopy  NUMBER
    , p18_a84 out nocopy  NUMBER
    , p18_a85 out nocopy  NUMBER
    , p18_a86 out nocopy  NUMBER
    , p18_a87 out nocopy  VARCHAR2
    , p18_a88 out nocopy  NUMBER
    , p18_a89 out nocopy  NUMBER
    , p19_a0 out nocopy  NUMBER
    , p19_a1 out nocopy  NUMBER
    , p19_a2 out nocopy  VARCHAR2
    , p19_a3 out nocopy  NUMBER
    , p19_a4 out nocopy  NUMBER
    , p19_a5 out nocopy  NUMBER
    , p19_a6 out nocopy  NUMBER
    , p19_a7 out nocopy  NUMBER
    , p19_a8 out nocopy  VARCHAR2
    , p19_a9 out nocopy  VARCHAR2
    , p19_a10 out nocopy  NUMBER
    , p19_a11 out nocopy  VARCHAR2
    , p19_a12 out nocopy  NUMBER
    , p19_a13 out nocopy  VARCHAR2
    , p19_a14 out nocopy  VARCHAR2
    , p19_a15 out nocopy  VARCHAR2
    , p19_a16 out nocopy  VARCHAR2
    , p19_a17 out nocopy  VARCHAR2
    , p19_a18 out nocopy  NUMBER
    , p19_a19 out nocopy  NUMBER
    , p19_a20 out nocopy  NUMBER
    , p19_a21 out nocopy  NUMBER
    , p19_a22 out nocopy  VARCHAR2
    , p19_a23 out nocopy  VARCHAR2
    , p19_a24 out nocopy  VARCHAR2
    , p19_a25 out nocopy  VARCHAR2
    , p19_a26 out nocopy  VARCHAR2
    , p19_a27 out nocopy  VARCHAR2
    , p19_a28 out nocopy  DATE
    , p19_a29 out nocopy  VARCHAR2
    , p19_a30 out nocopy  DATE
    , p19_a31 out nocopy  DATE
    , p19_a32 out nocopy  DATE
    , p19_a33 out nocopy  VARCHAR2
    , p19_a34 out nocopy  NUMBER
    , p19_a35 out nocopy  VARCHAR2
    , p19_a36 out nocopy  NUMBER
    , p19_a37 out nocopy  VARCHAR2
    , p19_a38 out nocopy  VARCHAR2
    , p19_a39 out nocopy  VARCHAR2
    , p19_a40 out nocopy  VARCHAR2
    , p19_a41 out nocopy  VARCHAR2
    , p19_a42 out nocopy  VARCHAR2
    , p19_a43 out nocopy  VARCHAR2
    , p19_a44 out nocopy  VARCHAR2
    , p19_a45 out nocopy  VARCHAR2
    , p19_a46 out nocopy  VARCHAR2
    , p19_a47 out nocopy  VARCHAR2
    , p19_a48 out nocopy  VARCHAR2
    , p19_a49 out nocopy  VARCHAR2
    , p19_a50 out nocopy  VARCHAR2
    , p19_a51 out nocopy  VARCHAR2
    , p19_a52 out nocopy  VARCHAR2
    , p19_a53 out nocopy  VARCHAR2
    , p19_a54 out nocopy  NUMBER
    , p19_a55 out nocopy  DATE
    , p19_a56 out nocopy  NUMBER
    , p19_a57 out nocopy  DATE
    , p19_a58 out nocopy  VARCHAR2
    , p19_a59 out nocopy  VARCHAR2
    , p19_a60 out nocopy  VARCHAR2
    , p19_a61 out nocopy  NUMBER
    , p19_a62 out nocopy  VARCHAR2
    , p19_a63 out nocopy  VARCHAR2
    , p19_a64 out nocopy  VARCHAR2
    , p19_a65 out nocopy  VARCHAR2
    , p19_a66 out nocopy  VARCHAR2
    , p19_a67 out nocopy  NUMBER
    , p19_a68 out nocopy  NUMBER
    , p19_a69 out nocopy  NUMBER
    , p19_a70 out nocopy  DATE
    , p19_a71 out nocopy  NUMBER
    , p19_a72 out nocopy  DATE
    , p19_a73 out nocopy  NUMBER
    , p19_a74 out nocopy  NUMBER
    , p19_a75 out nocopy  VARCHAR2
    , p19_a76 out nocopy  VARCHAR2
    , p19_a77 out nocopy  NUMBER
    , p19_a78 out nocopy  NUMBER
    , p19_a79 out nocopy  VARCHAR2
    , p19_a80 out nocopy  VARCHAR2
    , p19_a81 out nocopy  NUMBER
    , p19_a82 out nocopy  VARCHAR2
    , p19_a83 out nocopy  NUMBER
    , p19_a84 out nocopy  NUMBER
    , p19_a85 out nocopy  NUMBER
    , p19_a86 out nocopy  NUMBER
    , p19_a87 out nocopy  VARCHAR2
    , p19_a88 out nocopy  NUMBER
    , p19_a89 out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  DATE := fnd_api.g_miss_date
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  DATE := fnd_api.g_miss_date
    , p8_a21  DATE := fnd_api.g_miss_date
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  DATE := fnd_api.g_miss_date
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  NUMBER := 0-1962.0724
    , p8_a28  NUMBER := 0-1962.0724
    , p8_a29  NUMBER := 0-1962.0724
    , p8_a30  NUMBER := 0-1962.0724
    , p8_a31  NUMBER := 0-1962.0724
    , p8_a32  NUMBER := 0-1962.0724
    , p8_a33  NUMBER := 0-1962.0724
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  DATE := fnd_api.g_miss_date
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  DATE := fnd_api.g_miss_date
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  DATE := fnd_api.g_miss_date
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  DATE := fnd_api.g_miss_date
    , p8_a48  DATE := fnd_api.g_miss_date
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  NUMBER := 0-1962.0724
    , p8_a58  DATE := fnd_api.g_miss_date
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  VARCHAR2 := fnd_api.g_miss_char
    , p8_a68  VARCHAR2 := fnd_api.g_miss_char
    , p8_a69  VARCHAR2 := fnd_api.g_miss_char
    , p8_a70  VARCHAR2 := fnd_api.g_miss_char
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  NUMBER := 0-1962.0724
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  DATE := fnd_api.g_miss_date
    , p8_a80  NUMBER := 0-1962.0724
    , p8_a81  DATE := fnd_api.g_miss_date
    , p8_a82  NUMBER := 0-1962.0724
    , p8_a83  DATE := fnd_api.g_miss_date
    , p8_a84  DATE := fnd_api.g_miss_date
    , p8_a85  DATE := fnd_api.g_miss_date
    , p8_a86  DATE := fnd_api.g_miss_date
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  VARCHAR2 := fnd_api.g_miss_char
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  NUMBER := 0-1962.0724
    , p8_a95  DATE := fnd_api.g_miss_date
    , p8_a96  VARCHAR2 := fnd_api.g_miss_char
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  NUMBER := 0-1962.0724
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  NUMBER := 0-1962.0724
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  DATE := fnd_api.g_miss_date
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  DATE := fnd_api.g_miss_date
    , p9_a31  DATE := fnd_api.g_miss_date
    , p9_a32  DATE := fnd_api.g_miss_date
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  NUMBER := 0-1962.0724
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  NUMBER := 0-1962.0724
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  NUMBER := 0-1962.0724
    , p9_a55  DATE := fnd_api.g_miss_date
    , p9_a56  NUMBER := 0-1962.0724
    , p9_a57  DATE := fnd_api.g_miss_date
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  NUMBER := 0-1962.0724
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  NUMBER := 0-1962.0724
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  DATE := fnd_api.g_miss_date
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  DATE := fnd_api.g_miss_date
    , p9_a73  NUMBER := 0-1962.0724
    , p9_a74  NUMBER := 0-1962.0724
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  VARCHAR2 := fnd_api.g_miss_char
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  VARCHAR2 := fnd_api.g_miss_char
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  NUMBER := 0-1962.0724
    , p9_a82  VARCHAR2 := fnd_api.g_miss_char
    , p9_a83  NUMBER := 0-1962.0724
    , p9_a84  NUMBER := 0-1962.0724
    , p9_a85  NUMBER := 0-1962.0724
    , p9_a86  NUMBER := 0-1962.0724
    , p9_a87  VARCHAR2 := fnd_api.g_miss_char
    , p9_a88  NUMBER := 0-1962.0724
    , p9_a89  NUMBER := 0-1962.0724
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  NUMBER := 0-1962.0724
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  DATE := fnd_api.g_miss_date
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  DATE := fnd_api.g_miss_date
    , p10_a19  NUMBER := 0-1962.0724
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  VARCHAR2 := fnd_api.g_miss_char
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  NUMBER := 0-1962.0724
    , p11_a6  NUMBER := 0-1962.0724
    , p11_a7  NUMBER := 0-1962.0724
    , p11_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a9  VARCHAR2 := fnd_api.g_miss_char
    , p11_a10  NUMBER := 0-1962.0724
    , p11_a11  VARCHAR2 := fnd_api.g_miss_char
    , p11_a12  NUMBER := 0-1962.0724
    , p11_a13  VARCHAR2 := fnd_api.g_miss_char
    , p11_a14  VARCHAR2 := fnd_api.g_miss_char
    , p11_a15  VARCHAR2 := fnd_api.g_miss_char
    , p11_a16  VARCHAR2 := fnd_api.g_miss_char
    , p11_a17  VARCHAR2 := fnd_api.g_miss_char
    , p11_a18  NUMBER := 0-1962.0724
    , p11_a19  NUMBER := 0-1962.0724
    , p11_a20  NUMBER := 0-1962.0724
    , p11_a21  NUMBER := 0-1962.0724
    , p11_a22  VARCHAR2 := fnd_api.g_miss_char
    , p11_a23  VARCHAR2 := fnd_api.g_miss_char
    , p11_a24  VARCHAR2 := fnd_api.g_miss_char
    , p11_a25  VARCHAR2 := fnd_api.g_miss_char
    , p11_a26  VARCHAR2 := fnd_api.g_miss_char
    , p11_a27  VARCHAR2 := fnd_api.g_miss_char
    , p11_a28  DATE := fnd_api.g_miss_date
    , p11_a29  VARCHAR2 := fnd_api.g_miss_char
    , p11_a30  DATE := fnd_api.g_miss_date
    , p11_a31  DATE := fnd_api.g_miss_date
    , p11_a32  DATE := fnd_api.g_miss_date
    , p11_a33  VARCHAR2 := fnd_api.g_miss_char
    , p11_a34  NUMBER := 0-1962.0724
    , p11_a35  VARCHAR2 := fnd_api.g_miss_char
    , p11_a36  NUMBER := 0-1962.0724
    , p11_a37  VARCHAR2 := fnd_api.g_miss_char
    , p11_a38  VARCHAR2 := fnd_api.g_miss_char
    , p11_a39  VARCHAR2 := fnd_api.g_miss_char
    , p11_a40  VARCHAR2 := fnd_api.g_miss_char
    , p11_a41  VARCHAR2 := fnd_api.g_miss_char
    , p11_a42  VARCHAR2 := fnd_api.g_miss_char
    , p11_a43  VARCHAR2 := fnd_api.g_miss_char
    , p11_a44  VARCHAR2 := fnd_api.g_miss_char
    , p11_a45  VARCHAR2 := fnd_api.g_miss_char
    , p11_a46  VARCHAR2 := fnd_api.g_miss_char
    , p11_a47  VARCHAR2 := fnd_api.g_miss_char
    , p11_a48  VARCHAR2 := fnd_api.g_miss_char
    , p11_a49  VARCHAR2 := fnd_api.g_miss_char
    , p11_a50  VARCHAR2 := fnd_api.g_miss_char
    , p11_a51  VARCHAR2 := fnd_api.g_miss_char
    , p11_a52  VARCHAR2 := fnd_api.g_miss_char
    , p11_a53  VARCHAR2 := fnd_api.g_miss_char
    , p11_a54  NUMBER := 0-1962.0724
    , p11_a55  DATE := fnd_api.g_miss_date
    , p11_a56  NUMBER := 0-1962.0724
    , p11_a57  DATE := fnd_api.g_miss_date
    , p11_a58  VARCHAR2 := fnd_api.g_miss_char
    , p11_a59  VARCHAR2 := fnd_api.g_miss_char
    , p11_a60  VARCHAR2 := fnd_api.g_miss_char
    , p11_a61  NUMBER := 0-1962.0724
    , p11_a62  VARCHAR2 := fnd_api.g_miss_char
    , p11_a63  VARCHAR2 := fnd_api.g_miss_char
    , p11_a64  VARCHAR2 := fnd_api.g_miss_char
    , p11_a65  VARCHAR2 := fnd_api.g_miss_char
    , p11_a66  VARCHAR2 := fnd_api.g_miss_char
    , p11_a67  NUMBER := 0-1962.0724
    , p11_a68  NUMBER := 0-1962.0724
    , p11_a69  NUMBER := 0-1962.0724
    , p11_a70  DATE := fnd_api.g_miss_date
    , p11_a71  NUMBER := 0-1962.0724
    , p11_a72  DATE := fnd_api.g_miss_date
    , p11_a73  NUMBER := 0-1962.0724
    , p11_a74  NUMBER := 0-1962.0724
    , p11_a75  VARCHAR2 := fnd_api.g_miss_char
    , p11_a76  VARCHAR2 := fnd_api.g_miss_char
    , p11_a77  NUMBER := 0-1962.0724
    , p11_a78  NUMBER := 0-1962.0724
    , p11_a79  VARCHAR2 := fnd_api.g_miss_char
    , p11_a80  VARCHAR2 := fnd_api.g_miss_char
    , p11_a81  NUMBER := 0-1962.0724
    , p11_a82  VARCHAR2 := fnd_api.g_miss_char
    , p11_a83  NUMBER := 0-1962.0724
    , p11_a84  NUMBER := 0-1962.0724
    , p11_a85  NUMBER := 0-1962.0724
    , p11_a86  NUMBER := 0-1962.0724
    , p11_a87  VARCHAR2 := fnd_api.g_miss_char
    , p11_a88  NUMBER := 0-1962.0724
    , p11_a89  NUMBER := 0-1962.0724
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  NUMBER := 0-1962.0724
    , p12_a3  NUMBER := 0-1962.0724
    , p12_a4  NUMBER := 0-1962.0724
    , p12_a5  NUMBER := 0-1962.0724
    , p12_a6  VARCHAR2 := fnd_api.g_miss_char
    , p12_a7  VARCHAR2 := fnd_api.g_miss_char
    , p12_a8  VARCHAR2 := fnd_api.g_miss_char
    , p12_a9  VARCHAR2 := fnd_api.g_miss_char
    , p12_a10  VARCHAR2 := fnd_api.g_miss_char
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  VARCHAR2 := fnd_api.g_miss_char
    , p12_a13  NUMBER := 0-1962.0724
    , p12_a14  VARCHAR2 := fnd_api.g_miss_char
    , p12_a15  NUMBER := 0-1962.0724
    , p12_a16  DATE := fnd_api.g_miss_date
    , p12_a17  NUMBER := 0-1962.0724
    , p12_a18  DATE := fnd_api.g_miss_date
    , p12_a19  NUMBER := 0-1962.0724
    , p13_a0  NUMBER := 0-1962.0724
    , p13_a1  NUMBER := 0-1962.0724
    , p13_a2  VARCHAR2 := fnd_api.g_miss_char
    , p13_a3  NUMBER := 0-1962.0724
    , p13_a4  NUMBER := 0-1962.0724
    , p13_a5  NUMBER := 0-1962.0724
    , p13_a6  NUMBER := 0-1962.0724
    , p13_a7  NUMBER := 0-1962.0724
    , p13_a8  NUMBER := 0-1962.0724
    , p13_a9  NUMBER := 0-1962.0724
    , p13_a10  NUMBER := 0-1962.0724
    , p13_a11  NUMBER := 0-1962.0724
    , p13_a12  VARCHAR2 := fnd_api.g_miss_char
    , p13_a13  VARCHAR2 := fnd_api.g_miss_char
    , p13_a14  VARCHAR2 := fnd_api.g_miss_char
    , p13_a15  NUMBER := 0-1962.0724
    , p13_a16  NUMBER := 0-1962.0724
    , p13_a17  NUMBER := 0-1962.0724
    , p13_a18  VARCHAR2 := fnd_api.g_miss_char
    , p13_a19  NUMBER := 0-1962.0724
    , p13_a20  NUMBER := 0-1962.0724
    , p13_a21  VARCHAR2 := fnd_api.g_miss_char
    , p13_a22  VARCHAR2 := fnd_api.g_miss_char
    , p13_a23  VARCHAR2 := fnd_api.g_miss_char
    , p13_a24  VARCHAR2 := fnd_api.g_miss_char
    , p13_a25  DATE := fnd_api.g_miss_date
    , p13_a26  DATE := fnd_api.g_miss_date
    , p13_a27  DATE := fnd_api.g_miss_date
    , p13_a28  NUMBER := 0-1962.0724
    , p13_a29  NUMBER := 0-1962.0724
    , p13_a30  NUMBER := 0-1962.0724
    , p13_a31  VARCHAR2 := fnd_api.g_miss_char
    , p13_a32  NUMBER := 0-1962.0724
    , p13_a33  NUMBER := 0-1962.0724
    , p13_a34  NUMBER := 0-1962.0724
    , p13_a35  NUMBER := 0-1962.0724
    , p13_a36  VARCHAR2 := fnd_api.g_miss_char
    , p13_a37  VARCHAR2 := fnd_api.g_miss_char
    , p13_a38  VARCHAR2 := fnd_api.g_miss_char
    , p13_a39  VARCHAR2 := fnd_api.g_miss_char
    , p13_a40  VARCHAR2 := fnd_api.g_miss_char
    , p13_a41  VARCHAR2 := fnd_api.g_miss_char
    , p13_a42  VARCHAR2 := fnd_api.g_miss_char
    , p13_a43  VARCHAR2 := fnd_api.g_miss_char
    , p13_a44  VARCHAR2 := fnd_api.g_miss_char
    , p13_a45  VARCHAR2 := fnd_api.g_miss_char
    , p13_a46  VARCHAR2 := fnd_api.g_miss_char
    , p13_a47  VARCHAR2 := fnd_api.g_miss_char
    , p13_a48  VARCHAR2 := fnd_api.g_miss_char
    , p13_a49  VARCHAR2 := fnd_api.g_miss_char
    , p13_a50  VARCHAR2 := fnd_api.g_miss_char
    , p13_a51  VARCHAR2 := fnd_api.g_miss_char
    , p13_a52  NUMBER := 0-1962.0724
    , p13_a53  DATE := fnd_api.g_miss_date
    , p13_a54  NUMBER := 0-1962.0724
    , p13_a55  DATE := fnd_api.g_miss_date
    , p13_a56  NUMBER := 0-1962.0724
    , p13_a57  VARCHAR2 := fnd_api.g_miss_char
    , p13_a58  NUMBER := 0-1962.0724
    , p13_a59  NUMBER := 0-1962.0724
    , p13_a60  NUMBER := 0-1962.0724
    , p13_a61  NUMBER := 0-1962.0724
    , p13_a62  NUMBER := 0-1962.0724
    , p13_a63  NUMBER := 0-1962.0724
    , p13_a64  NUMBER := 0-1962.0724
    , p13_a65  NUMBER := 0-1962.0724
    , p13_a66  NUMBER := 0-1962.0724
    , p13_a67  DATE := fnd_api.g_miss_date
    , p13_a68  NUMBER := 0-1962.0724
    , p13_a69  NUMBER := 0-1962.0724
    , p13_a70  NUMBER := 0-1962.0724
    , p13_a71  VARCHAR2 := fnd_api.g_miss_char
    , p13_a72  NUMBER := 0-1962.0724
    , p13_a73  VARCHAR2 := fnd_api.g_miss_char
    , p13_a74  VARCHAR2 := fnd_api.g_miss_char
    , p13_a75  NUMBER := 0-1962.0724
    , p13_a76  DATE := fnd_api.g_miss_date
    , p14_a0  NUMBER := 0-1962.0724
    , p14_a1  NUMBER := 0-1962.0724
    , p14_a2  VARCHAR2 := fnd_api.g_miss_char
    , p14_a3  NUMBER := 0-1962.0724
    , p14_a4  NUMBER := 0-1962.0724
    , p14_a5  NUMBER := 0-1962.0724
    , p14_a6  NUMBER := 0-1962.0724
    , p14_a7  NUMBER := 0-1962.0724
    , p14_a8  VARCHAR2 := fnd_api.g_miss_char
    , p14_a9  VARCHAR2 := fnd_api.g_miss_char
    , p14_a10  NUMBER := 0-1962.0724
    , p14_a11  VARCHAR2 := fnd_api.g_miss_char
    , p14_a12  NUMBER := 0-1962.0724
    , p14_a13  VARCHAR2 := fnd_api.g_miss_char
    , p14_a14  VARCHAR2 := fnd_api.g_miss_char
    , p14_a15  VARCHAR2 := fnd_api.g_miss_char
    , p14_a16  VARCHAR2 := fnd_api.g_miss_char
    , p14_a17  VARCHAR2 := fnd_api.g_miss_char
    , p14_a18  NUMBER := 0-1962.0724
    , p14_a19  NUMBER := 0-1962.0724
    , p14_a20  NUMBER := 0-1962.0724
    , p14_a21  NUMBER := 0-1962.0724
    , p14_a22  VARCHAR2 := fnd_api.g_miss_char
    , p14_a23  VARCHAR2 := fnd_api.g_miss_char
    , p14_a24  VARCHAR2 := fnd_api.g_miss_char
    , p14_a25  VARCHAR2 := fnd_api.g_miss_char
    , p14_a26  VARCHAR2 := fnd_api.g_miss_char
    , p14_a27  VARCHAR2 := fnd_api.g_miss_char
    , p14_a28  DATE := fnd_api.g_miss_date
    , p14_a29  VARCHAR2 := fnd_api.g_miss_char
    , p14_a30  DATE := fnd_api.g_miss_date
    , p14_a31  DATE := fnd_api.g_miss_date
    , p14_a32  DATE := fnd_api.g_miss_date
    , p14_a33  VARCHAR2 := fnd_api.g_miss_char
    , p14_a34  NUMBER := 0-1962.0724
    , p14_a35  VARCHAR2 := fnd_api.g_miss_char
    , p14_a36  NUMBER := 0-1962.0724
    , p14_a37  VARCHAR2 := fnd_api.g_miss_char
    , p14_a38  VARCHAR2 := fnd_api.g_miss_char
    , p14_a39  VARCHAR2 := fnd_api.g_miss_char
    , p14_a40  VARCHAR2 := fnd_api.g_miss_char
    , p14_a41  VARCHAR2 := fnd_api.g_miss_char
    , p14_a42  VARCHAR2 := fnd_api.g_miss_char
    , p14_a43  VARCHAR2 := fnd_api.g_miss_char
    , p14_a44  VARCHAR2 := fnd_api.g_miss_char
    , p14_a45  VARCHAR2 := fnd_api.g_miss_char
    , p14_a46  VARCHAR2 := fnd_api.g_miss_char
    , p14_a47  VARCHAR2 := fnd_api.g_miss_char
    , p14_a48  VARCHAR2 := fnd_api.g_miss_char
    , p14_a49  VARCHAR2 := fnd_api.g_miss_char
    , p14_a50  VARCHAR2 := fnd_api.g_miss_char
    , p14_a51  VARCHAR2 := fnd_api.g_miss_char
    , p14_a52  VARCHAR2 := fnd_api.g_miss_char
    , p14_a53  VARCHAR2 := fnd_api.g_miss_char
    , p14_a54  NUMBER := 0-1962.0724
    , p14_a55  DATE := fnd_api.g_miss_date
    , p14_a56  NUMBER := 0-1962.0724
    , p14_a57  DATE := fnd_api.g_miss_date
    , p14_a58  VARCHAR2 := fnd_api.g_miss_char
    , p14_a59  VARCHAR2 := fnd_api.g_miss_char
    , p14_a60  VARCHAR2 := fnd_api.g_miss_char
    , p14_a61  NUMBER := 0-1962.0724
    , p14_a62  VARCHAR2 := fnd_api.g_miss_char
    , p14_a63  VARCHAR2 := fnd_api.g_miss_char
    , p14_a64  VARCHAR2 := fnd_api.g_miss_char
    , p14_a65  VARCHAR2 := fnd_api.g_miss_char
    , p14_a66  VARCHAR2 := fnd_api.g_miss_char
    , p14_a67  NUMBER := 0-1962.0724
    , p14_a68  NUMBER := 0-1962.0724
    , p14_a69  NUMBER := 0-1962.0724
    , p14_a70  DATE := fnd_api.g_miss_date
    , p14_a71  NUMBER := 0-1962.0724
    , p14_a72  DATE := fnd_api.g_miss_date
    , p14_a73  NUMBER := 0-1962.0724
    , p14_a74  NUMBER := 0-1962.0724
    , p14_a75  VARCHAR2 := fnd_api.g_miss_char
    , p14_a76  VARCHAR2 := fnd_api.g_miss_char
    , p14_a77  NUMBER := 0-1962.0724
    , p14_a78  NUMBER := 0-1962.0724
    , p14_a79  VARCHAR2 := fnd_api.g_miss_char
    , p14_a80  VARCHAR2 := fnd_api.g_miss_char
    , p14_a81  NUMBER := 0-1962.0724
    , p14_a82  VARCHAR2 := fnd_api.g_miss_char
    , p14_a83  NUMBER := 0-1962.0724
    , p14_a84  NUMBER := 0-1962.0724
    , p14_a85  NUMBER := 0-1962.0724
    , p14_a86  NUMBER := 0-1962.0724
    , p14_a87  VARCHAR2 := fnd_api.g_miss_char
    , p14_a88  NUMBER := 0-1962.0724
    , p14_a89  NUMBER := 0-1962.0724
    , p15_a0  NUMBER := 0-1962.0724
    , p15_a1  NUMBER := 0-1962.0724
    , p15_a2  NUMBER := 0-1962.0724
    , p15_a3  NUMBER := 0-1962.0724
    , p15_a4  NUMBER := 0-1962.0724
    , p15_a5  VARCHAR2 := fnd_api.g_miss_char
    , p15_a6  NUMBER := 0-1962.0724
    , p15_a7  VARCHAR2 := fnd_api.g_miss_char
    , p15_a8  VARCHAR2 := fnd_api.g_miss_char
    , p15_a9  VARCHAR2 := fnd_api.g_miss_char
    , p15_a10  VARCHAR2 := fnd_api.g_miss_char
    , p15_a11  VARCHAR2 := fnd_api.g_miss_char
    , p15_a12  VARCHAR2 := fnd_api.g_miss_char
    , p15_a13  VARCHAR2 := fnd_api.g_miss_char
    , p15_a14  NUMBER := 0-1962.0724
    , p15_a15  VARCHAR2 := fnd_api.g_miss_char
    , p15_a16  VARCHAR2 := fnd_api.g_miss_char
    , p15_a17  NUMBER := 0-1962.0724
    , p15_a18  NUMBER := 0-1962.0724
    , p15_a19  VARCHAR2 := fnd_api.g_miss_char
    , p15_a20  VARCHAR2 := fnd_api.g_miss_char
    , p15_a21  VARCHAR2 := fnd_api.g_miss_char
    , p15_a22  VARCHAR2 := fnd_api.g_miss_char
    , p15_a23  VARCHAR2 := fnd_api.g_miss_char
    , p15_a24  VARCHAR2 := fnd_api.g_miss_char
    , p15_a25  VARCHAR2 := fnd_api.g_miss_char
    , p15_a26  VARCHAR2 := fnd_api.g_miss_char
    , p15_a27  VARCHAR2 := fnd_api.g_miss_char
    , p15_a28  VARCHAR2 := fnd_api.g_miss_char
    , p15_a29  VARCHAR2 := fnd_api.g_miss_char
    , p15_a30  VARCHAR2 := fnd_api.g_miss_char
    , p15_a31  VARCHAR2 := fnd_api.g_miss_char
    , p15_a32  VARCHAR2 := fnd_api.g_miss_char
    , p15_a33  VARCHAR2 := fnd_api.g_miss_char
    , p15_a34  VARCHAR2 := fnd_api.g_miss_char
    , p15_a35  NUMBER := 0-1962.0724
    , p15_a36  DATE := fnd_api.g_miss_date
    , p15_a37  NUMBER := 0-1962.0724
    , p15_a38  DATE := fnd_api.g_miss_date
    , p15_a39  NUMBER := 0-1962.0724
    , p15_a40  NUMBER := 0-1962.0724
    , p15_a41  NUMBER := 0-1962.0724
    , p15_a42  VARCHAR2 := fnd_api.g_miss_char
    , p15_a43  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_fin_rec okl_create_kle_pub.clev_rec_type;
    ddp_klev_fin_rec okl_create_kle_pub.klev_rec_type;
    ddp_clev_model_rec okl_create_kle_pub.clev_rec_type;
    ddp_cimv_model_rec okl_create_kle_pub.cimv_rec_type;
    ddp_clev_fa_rec okl_create_kle_pub.clev_rec_type;
    ddp_cimv_fa_rec okl_create_kle_pub.cimv_rec_type;
    ddp_talv_fa_rec okl_create_kle_pub.talv_rec_type;
    ddp_clev_ib_rec okl_create_kle_pub.clev_rec_type;
    ddp_itiv_ib_rec okl_create_kle_pub.itiv_rec_type;
    ddx_clev_fin_rec okl_create_kle_pub.clev_rec_type;
    ddx_clev_model_rec okl_create_kle_pub.clev_rec_type;
    ddx_clev_fa_rec okl_create_kle_pub.clev_rec_type;
    ddx_clev_ib_rec okl_create_kle_pub.clev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_clev_fin_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_clev_fin_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_clev_fin_rec.sfwt_flag := p7_a2;
    ddp_clev_fin_rec.chr_id := rosetta_g_miss_num_map(p7_a3);
    ddp_clev_fin_rec.cle_id := rosetta_g_miss_num_map(p7_a4);
    ddp_clev_fin_rec.cle_id_renewed := rosetta_g_miss_num_map(p7_a5);
    ddp_clev_fin_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p7_a6);
    ddp_clev_fin_rec.lse_id := rosetta_g_miss_num_map(p7_a7);
    ddp_clev_fin_rec.line_number := p7_a8;
    ddp_clev_fin_rec.sts_code := p7_a9;
    ddp_clev_fin_rec.display_sequence := rosetta_g_miss_num_map(p7_a10);
    ddp_clev_fin_rec.trn_code := p7_a11;
    ddp_clev_fin_rec.dnz_chr_id := rosetta_g_miss_num_map(p7_a12);
    ddp_clev_fin_rec.comments := p7_a13;
    ddp_clev_fin_rec.item_description := p7_a14;
    ddp_clev_fin_rec.oke_boe_description := p7_a15;
    ddp_clev_fin_rec.cognomen := p7_a16;
    ddp_clev_fin_rec.hidden_ind := p7_a17;
    ddp_clev_fin_rec.price_unit := rosetta_g_miss_num_map(p7_a18);
    ddp_clev_fin_rec.price_unit_percent := rosetta_g_miss_num_map(p7_a19);
    ddp_clev_fin_rec.price_negotiated := rosetta_g_miss_num_map(p7_a20);
    ddp_clev_fin_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p7_a21);
    ddp_clev_fin_rec.price_level_ind := p7_a22;
    ddp_clev_fin_rec.invoice_line_level_ind := p7_a23;
    ddp_clev_fin_rec.dpas_rating := p7_a24;
    ddp_clev_fin_rec.block23text := p7_a25;
    ddp_clev_fin_rec.exception_yn := p7_a26;
    ddp_clev_fin_rec.template_used := p7_a27;
    ddp_clev_fin_rec.date_terminated := rosetta_g_miss_date_in_map(p7_a28);
    ddp_clev_fin_rec.name := p7_a29;
    ddp_clev_fin_rec.start_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_clev_fin_rec.end_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_clev_fin_rec.date_renewed := rosetta_g_miss_date_in_map(p7_a32);
    ddp_clev_fin_rec.upg_orig_system_ref := p7_a33;
    ddp_clev_fin_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a34);
    ddp_clev_fin_rec.orig_system_source_code := p7_a35;
    ddp_clev_fin_rec.orig_system_id1 := rosetta_g_miss_num_map(p7_a36);
    ddp_clev_fin_rec.orig_system_reference1 := p7_a37;
    ddp_clev_fin_rec.attribute_category := p7_a38;
    ddp_clev_fin_rec.attribute1 := p7_a39;
    ddp_clev_fin_rec.attribute2 := p7_a40;
    ddp_clev_fin_rec.attribute3 := p7_a41;
    ddp_clev_fin_rec.attribute4 := p7_a42;
    ddp_clev_fin_rec.attribute5 := p7_a43;
    ddp_clev_fin_rec.attribute6 := p7_a44;
    ddp_clev_fin_rec.attribute7 := p7_a45;
    ddp_clev_fin_rec.attribute8 := p7_a46;
    ddp_clev_fin_rec.attribute9 := p7_a47;
    ddp_clev_fin_rec.attribute10 := p7_a48;
    ddp_clev_fin_rec.attribute11 := p7_a49;
    ddp_clev_fin_rec.attribute12 := p7_a50;
    ddp_clev_fin_rec.attribute13 := p7_a51;
    ddp_clev_fin_rec.attribute14 := p7_a52;
    ddp_clev_fin_rec.attribute15 := p7_a53;
    ddp_clev_fin_rec.created_by := rosetta_g_miss_num_map(p7_a54);
    ddp_clev_fin_rec.creation_date := rosetta_g_miss_date_in_map(p7_a55);
    ddp_clev_fin_rec.last_updated_by := rosetta_g_miss_num_map(p7_a56);
    ddp_clev_fin_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a57);
    ddp_clev_fin_rec.price_type := p7_a58;
    ddp_clev_fin_rec.currency_code := p7_a59;
    ddp_clev_fin_rec.currency_code_renewed := p7_a60;
    ddp_clev_fin_rec.last_update_login := rosetta_g_miss_num_map(p7_a61);
    ddp_clev_fin_rec.old_sts_code := p7_a62;
    ddp_clev_fin_rec.new_sts_code := p7_a63;
    ddp_clev_fin_rec.old_ste_code := p7_a64;
    ddp_clev_fin_rec.new_ste_code := p7_a65;
    ddp_clev_fin_rec.call_action_asmblr := p7_a66;
    ddp_clev_fin_rec.request_id := rosetta_g_miss_num_map(p7_a67);
    ddp_clev_fin_rec.program_application_id := rosetta_g_miss_num_map(p7_a68);
    ddp_clev_fin_rec.program_id := rosetta_g_miss_num_map(p7_a69);
    ddp_clev_fin_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a70);
    ddp_clev_fin_rec.price_list_id := rosetta_g_miss_num_map(p7_a71);
    ddp_clev_fin_rec.pricing_date := rosetta_g_miss_date_in_map(p7_a72);
    ddp_clev_fin_rec.price_list_line_id := rosetta_g_miss_num_map(p7_a73);
    ddp_clev_fin_rec.line_list_price := rosetta_g_miss_num_map(p7_a74);
    ddp_clev_fin_rec.item_to_price_yn := p7_a75;
    ddp_clev_fin_rec.price_basis_yn := p7_a76;
    ddp_clev_fin_rec.config_header_id := rosetta_g_miss_num_map(p7_a77);
    ddp_clev_fin_rec.config_revision_number := rosetta_g_miss_num_map(p7_a78);
    ddp_clev_fin_rec.config_complete_yn := p7_a79;
    ddp_clev_fin_rec.config_valid_yn := p7_a80;
    ddp_clev_fin_rec.config_top_model_line_id := rosetta_g_miss_num_map(p7_a81);
    ddp_clev_fin_rec.config_item_type := p7_a82;
    ddp_clev_fin_rec.config_item_id := rosetta_g_miss_num_map(p7_a83);
    ddp_clev_fin_rec.cust_acct_id := rosetta_g_miss_num_map(p7_a84);
    ddp_clev_fin_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p7_a85);
    ddp_clev_fin_rec.inv_rule_id := rosetta_g_miss_num_map(p7_a86);
    ddp_clev_fin_rec.line_renewal_type_code := p7_a87;
    ddp_clev_fin_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p7_a88);
    ddp_clev_fin_rec.payment_term_id := rosetta_g_miss_num_map(p7_a89);

    ddp_klev_fin_rec.id := rosetta_g_miss_num_map(p8_a0);
    ddp_klev_fin_rec.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_klev_fin_rec.kle_id := rosetta_g_miss_num_map(p8_a2);
    ddp_klev_fin_rec.sty_id := rosetta_g_miss_num_map(p8_a3);
    ddp_klev_fin_rec.prc_code := p8_a4;
    ddp_klev_fin_rec.fcg_code := p8_a5;
    ddp_klev_fin_rec.nty_code := p8_a6;
    ddp_klev_fin_rec.estimated_oec := rosetta_g_miss_num_map(p8_a7);
    ddp_klev_fin_rec.lao_amount := rosetta_g_miss_num_map(p8_a8);
    ddp_klev_fin_rec.title_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_klev_fin_rec.fee_charge := rosetta_g_miss_num_map(p8_a10);
    ddp_klev_fin_rec.lrs_percent := rosetta_g_miss_num_map(p8_a11);
    ddp_klev_fin_rec.initial_direct_cost := rosetta_g_miss_num_map(p8_a12);
    ddp_klev_fin_rec.percent_stake := rosetta_g_miss_num_map(p8_a13);
    ddp_klev_fin_rec.percent := rosetta_g_miss_num_map(p8_a14);
    ddp_klev_fin_rec.evergreen_percent := rosetta_g_miss_num_map(p8_a15);
    ddp_klev_fin_rec.amount_stake := rosetta_g_miss_num_map(p8_a16);
    ddp_klev_fin_rec.occupancy := rosetta_g_miss_num_map(p8_a17);
    ddp_klev_fin_rec.coverage := rosetta_g_miss_num_map(p8_a18);
    ddp_klev_fin_rec.residual_percentage := rosetta_g_miss_num_map(p8_a19);
    ddp_klev_fin_rec.date_last_inspection := rosetta_g_miss_date_in_map(p8_a20);
    ddp_klev_fin_rec.date_sold := rosetta_g_miss_date_in_map(p8_a21);
    ddp_klev_fin_rec.lrv_amount := rosetta_g_miss_num_map(p8_a22);
    ddp_klev_fin_rec.capital_reduction := rosetta_g_miss_num_map(p8_a23);
    ddp_klev_fin_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p8_a24);
    ddp_klev_fin_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p8_a25);
    ddp_klev_fin_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p8_a26);
    ddp_klev_fin_rec.vendor_advance_paid := rosetta_g_miss_num_map(p8_a27);
    ddp_klev_fin_rec.weighted_average_life := rosetta_g_miss_num_map(p8_a28);
    ddp_klev_fin_rec.tradein_amount := rosetta_g_miss_num_map(p8_a29);
    ddp_klev_fin_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p8_a30);
    ddp_klev_fin_rec.termination_purchase_amount := rosetta_g_miss_num_map(p8_a31);
    ddp_klev_fin_rec.refinance_amount := rosetta_g_miss_num_map(p8_a32);
    ddp_klev_fin_rec.year_built := rosetta_g_miss_num_map(p8_a33);
    ddp_klev_fin_rec.delivered_date := rosetta_g_miss_date_in_map(p8_a34);
    ddp_klev_fin_rec.credit_tenant_yn := p8_a35;
    ddp_klev_fin_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p8_a36);
    ddp_klev_fin_rec.year_of_manufacture := p8_a37;
    ddp_klev_fin_rec.coverage_ratio := rosetta_g_miss_num_map(p8_a38);
    ddp_klev_fin_rec.remarketed_amount := rosetta_g_miss_num_map(p8_a39);
    ddp_klev_fin_rec.gross_square_footage := rosetta_g_miss_num_map(p8_a40);
    ddp_klev_fin_rec.prescribed_asset_yn := p8_a41;
    ddp_klev_fin_rec.date_remarketed := rosetta_g_miss_date_in_map(p8_a42);
    ddp_klev_fin_rec.net_rentable := rosetta_g_miss_num_map(p8_a43);
    ddp_klev_fin_rec.remarket_margin := rosetta_g_miss_num_map(p8_a44);
    ddp_klev_fin_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p8_a45);
    ddp_klev_fin_rec.repurchased_amount := rosetta_g_miss_num_map(p8_a46);
    ddp_klev_fin_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p8_a47);
    ddp_klev_fin_rec.date_repurchased := rosetta_g_miss_date_in_map(p8_a48);
    ddp_klev_fin_rec.date_appraisal := rosetta_g_miss_date_in_map(p8_a49);
    ddp_klev_fin_rec.residual_value := rosetta_g_miss_num_map(p8_a50);
    ddp_klev_fin_rec.appraisal_value := rosetta_g_miss_num_map(p8_a51);
    ddp_klev_fin_rec.secured_deal_yn := p8_a52;
    ddp_klev_fin_rec.gain_loss := rosetta_g_miss_num_map(p8_a53);
    ddp_klev_fin_rec.floor_amount := rosetta_g_miss_num_map(p8_a54);
    ddp_klev_fin_rec.re_lease_yn := p8_a55;
    ddp_klev_fin_rec.previous_contract := p8_a56;
    ddp_klev_fin_rec.tracked_residual := rosetta_g_miss_num_map(p8_a57);
    ddp_klev_fin_rec.date_title_received := rosetta_g_miss_date_in_map(p8_a58);
    ddp_klev_fin_rec.amount := rosetta_g_miss_num_map(p8_a59);
    ddp_klev_fin_rec.attribute_category := p8_a60;
    ddp_klev_fin_rec.attribute1 := p8_a61;
    ddp_klev_fin_rec.attribute2 := p8_a62;
    ddp_klev_fin_rec.attribute3 := p8_a63;
    ddp_klev_fin_rec.attribute4 := p8_a64;
    ddp_klev_fin_rec.attribute5 := p8_a65;
    ddp_klev_fin_rec.attribute6 := p8_a66;
    ddp_klev_fin_rec.attribute7 := p8_a67;
    ddp_klev_fin_rec.attribute8 := p8_a68;
    ddp_klev_fin_rec.attribute9 := p8_a69;
    ddp_klev_fin_rec.attribute10 := p8_a70;
    ddp_klev_fin_rec.attribute11 := p8_a71;
    ddp_klev_fin_rec.attribute12 := p8_a72;
    ddp_klev_fin_rec.attribute13 := p8_a73;
    ddp_klev_fin_rec.attribute14 := p8_a74;
    ddp_klev_fin_rec.attribute15 := p8_a75;
    ddp_klev_fin_rec.sty_id_for := rosetta_g_miss_num_map(p8_a76);
    ddp_klev_fin_rec.clg_id := rosetta_g_miss_num_map(p8_a77);
    ddp_klev_fin_rec.created_by := rosetta_g_miss_num_map(p8_a78);
    ddp_klev_fin_rec.creation_date := rosetta_g_miss_date_in_map(p8_a79);
    ddp_klev_fin_rec.last_updated_by := rosetta_g_miss_num_map(p8_a80);
    ddp_klev_fin_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a81);
    ddp_klev_fin_rec.last_update_login := rosetta_g_miss_num_map(p8_a82);
    ddp_klev_fin_rec.date_funding := rosetta_g_miss_date_in_map(p8_a83);
    ddp_klev_fin_rec.date_funding_required := rosetta_g_miss_date_in_map(p8_a84);
    ddp_klev_fin_rec.date_accepted := rosetta_g_miss_date_in_map(p8_a85);
    ddp_klev_fin_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p8_a86);
    ddp_klev_fin_rec.oec := rosetta_g_miss_num_map(p8_a87);
    ddp_klev_fin_rec.capital_amount := rosetta_g_miss_num_map(p8_a88);
    ddp_klev_fin_rec.residual_grnty_amount := rosetta_g_miss_num_map(p8_a89);
    ddp_klev_fin_rec.residual_code := p8_a90;
    ddp_klev_fin_rec.rvi_premium := rosetta_g_miss_num_map(p8_a91);
    ddp_klev_fin_rec.credit_nature := p8_a92;
    ddp_klev_fin_rec.capitalized_interest := rosetta_g_miss_num_map(p8_a93);
    ddp_klev_fin_rec.capital_reduction_percent := rosetta_g_miss_num_map(p8_a94);
    ddp_klev_fin_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p8_a95);
    ddp_klev_fin_rec.pay_investor_frequency := p8_a96;
    ddp_klev_fin_rec.pay_investor_event := p8_a97;
    ddp_klev_fin_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p8_a98);

    ddp_clev_model_rec.id := rosetta_g_miss_num_map(p9_a0);
    ddp_clev_model_rec.object_version_number := rosetta_g_miss_num_map(p9_a1);
    ddp_clev_model_rec.sfwt_flag := p9_a2;
    ddp_clev_model_rec.chr_id := rosetta_g_miss_num_map(p9_a3);
    ddp_clev_model_rec.cle_id := rosetta_g_miss_num_map(p9_a4);
    ddp_clev_model_rec.cle_id_renewed := rosetta_g_miss_num_map(p9_a5);
    ddp_clev_model_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p9_a6);
    ddp_clev_model_rec.lse_id := rosetta_g_miss_num_map(p9_a7);
    ddp_clev_model_rec.line_number := p9_a8;
    ddp_clev_model_rec.sts_code := p9_a9;
    ddp_clev_model_rec.display_sequence := rosetta_g_miss_num_map(p9_a10);
    ddp_clev_model_rec.trn_code := p9_a11;
    ddp_clev_model_rec.dnz_chr_id := rosetta_g_miss_num_map(p9_a12);
    ddp_clev_model_rec.comments := p9_a13;
    ddp_clev_model_rec.item_description := p9_a14;
    ddp_clev_model_rec.oke_boe_description := p9_a15;
    ddp_clev_model_rec.cognomen := p9_a16;
    ddp_clev_model_rec.hidden_ind := p9_a17;
    ddp_clev_model_rec.price_unit := rosetta_g_miss_num_map(p9_a18);
    ddp_clev_model_rec.price_unit_percent := rosetta_g_miss_num_map(p9_a19);
    ddp_clev_model_rec.price_negotiated := rosetta_g_miss_num_map(p9_a20);
    ddp_clev_model_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p9_a21);
    ddp_clev_model_rec.price_level_ind := p9_a22;
    ddp_clev_model_rec.invoice_line_level_ind := p9_a23;
    ddp_clev_model_rec.dpas_rating := p9_a24;
    ddp_clev_model_rec.block23text := p9_a25;
    ddp_clev_model_rec.exception_yn := p9_a26;
    ddp_clev_model_rec.template_used := p9_a27;
    ddp_clev_model_rec.date_terminated := rosetta_g_miss_date_in_map(p9_a28);
    ddp_clev_model_rec.name := p9_a29;
    ddp_clev_model_rec.start_date := rosetta_g_miss_date_in_map(p9_a30);
    ddp_clev_model_rec.end_date := rosetta_g_miss_date_in_map(p9_a31);
    ddp_clev_model_rec.date_renewed := rosetta_g_miss_date_in_map(p9_a32);
    ddp_clev_model_rec.upg_orig_system_ref := p9_a33;
    ddp_clev_model_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p9_a34);
    ddp_clev_model_rec.orig_system_source_code := p9_a35;
    ddp_clev_model_rec.orig_system_id1 := rosetta_g_miss_num_map(p9_a36);
    ddp_clev_model_rec.orig_system_reference1 := p9_a37;
    ddp_clev_model_rec.attribute_category := p9_a38;
    ddp_clev_model_rec.attribute1 := p9_a39;
    ddp_clev_model_rec.attribute2 := p9_a40;
    ddp_clev_model_rec.attribute3 := p9_a41;
    ddp_clev_model_rec.attribute4 := p9_a42;
    ddp_clev_model_rec.attribute5 := p9_a43;
    ddp_clev_model_rec.attribute6 := p9_a44;
    ddp_clev_model_rec.attribute7 := p9_a45;
    ddp_clev_model_rec.attribute8 := p9_a46;
    ddp_clev_model_rec.attribute9 := p9_a47;
    ddp_clev_model_rec.attribute10 := p9_a48;
    ddp_clev_model_rec.attribute11 := p9_a49;
    ddp_clev_model_rec.attribute12 := p9_a50;
    ddp_clev_model_rec.attribute13 := p9_a51;
    ddp_clev_model_rec.attribute14 := p9_a52;
    ddp_clev_model_rec.attribute15 := p9_a53;
    ddp_clev_model_rec.created_by := rosetta_g_miss_num_map(p9_a54);
    ddp_clev_model_rec.creation_date := rosetta_g_miss_date_in_map(p9_a55);
    ddp_clev_model_rec.last_updated_by := rosetta_g_miss_num_map(p9_a56);
    ddp_clev_model_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a57);
    ddp_clev_model_rec.price_type := p9_a58;
    ddp_clev_model_rec.currency_code := p9_a59;
    ddp_clev_model_rec.currency_code_renewed := p9_a60;
    ddp_clev_model_rec.last_update_login := rosetta_g_miss_num_map(p9_a61);
    ddp_clev_model_rec.old_sts_code := p9_a62;
    ddp_clev_model_rec.new_sts_code := p9_a63;
    ddp_clev_model_rec.old_ste_code := p9_a64;
    ddp_clev_model_rec.new_ste_code := p9_a65;
    ddp_clev_model_rec.call_action_asmblr := p9_a66;
    ddp_clev_model_rec.request_id := rosetta_g_miss_num_map(p9_a67);
    ddp_clev_model_rec.program_application_id := rosetta_g_miss_num_map(p9_a68);
    ddp_clev_model_rec.program_id := rosetta_g_miss_num_map(p9_a69);
    ddp_clev_model_rec.program_update_date := rosetta_g_miss_date_in_map(p9_a70);
    ddp_clev_model_rec.price_list_id := rosetta_g_miss_num_map(p9_a71);
    ddp_clev_model_rec.pricing_date := rosetta_g_miss_date_in_map(p9_a72);
    ddp_clev_model_rec.price_list_line_id := rosetta_g_miss_num_map(p9_a73);
    ddp_clev_model_rec.line_list_price := rosetta_g_miss_num_map(p9_a74);
    ddp_clev_model_rec.item_to_price_yn := p9_a75;
    ddp_clev_model_rec.price_basis_yn := p9_a76;
    ddp_clev_model_rec.config_header_id := rosetta_g_miss_num_map(p9_a77);
    ddp_clev_model_rec.config_revision_number := rosetta_g_miss_num_map(p9_a78);
    ddp_clev_model_rec.config_complete_yn := p9_a79;
    ddp_clev_model_rec.config_valid_yn := p9_a80;
    ddp_clev_model_rec.config_top_model_line_id := rosetta_g_miss_num_map(p9_a81);
    ddp_clev_model_rec.config_item_type := p9_a82;
    ddp_clev_model_rec.config_item_id := rosetta_g_miss_num_map(p9_a83);
    ddp_clev_model_rec.cust_acct_id := rosetta_g_miss_num_map(p9_a84);
    ddp_clev_model_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p9_a85);
    ddp_clev_model_rec.inv_rule_id := rosetta_g_miss_num_map(p9_a86);
    ddp_clev_model_rec.line_renewal_type_code := p9_a87;
    ddp_clev_model_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p9_a88);
    ddp_clev_model_rec.payment_term_id := rosetta_g_miss_num_map(p9_a89);

    ddp_cimv_model_rec.id := rosetta_g_miss_num_map(p10_a0);
    ddp_cimv_model_rec.object_version_number := rosetta_g_miss_num_map(p10_a1);
    ddp_cimv_model_rec.cle_id := rosetta_g_miss_num_map(p10_a2);
    ddp_cimv_model_rec.chr_id := rosetta_g_miss_num_map(p10_a3);
    ddp_cimv_model_rec.cle_id_for := rosetta_g_miss_num_map(p10_a4);
    ddp_cimv_model_rec.dnz_chr_id := rosetta_g_miss_num_map(p10_a5);
    ddp_cimv_model_rec.object1_id1 := p10_a6;
    ddp_cimv_model_rec.object1_id2 := p10_a7;
    ddp_cimv_model_rec.jtot_object1_code := p10_a8;
    ddp_cimv_model_rec.uom_code := p10_a9;
    ddp_cimv_model_rec.exception_yn := p10_a10;
    ddp_cimv_model_rec.number_of_items := rosetta_g_miss_num_map(p10_a11);
    ddp_cimv_model_rec.upg_orig_system_ref := p10_a12;
    ddp_cimv_model_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p10_a13);
    ddp_cimv_model_rec.priced_item_yn := p10_a14;
    ddp_cimv_model_rec.created_by := rosetta_g_miss_num_map(p10_a15);
    ddp_cimv_model_rec.creation_date := rosetta_g_miss_date_in_map(p10_a16);
    ddp_cimv_model_rec.last_updated_by := rosetta_g_miss_num_map(p10_a17);
    ddp_cimv_model_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a18);
    ddp_cimv_model_rec.last_update_login := rosetta_g_miss_num_map(p10_a19);

    ddp_clev_fa_rec.id := rosetta_g_miss_num_map(p11_a0);
    ddp_clev_fa_rec.object_version_number := rosetta_g_miss_num_map(p11_a1);
    ddp_clev_fa_rec.sfwt_flag := p11_a2;
    ddp_clev_fa_rec.chr_id := rosetta_g_miss_num_map(p11_a3);
    ddp_clev_fa_rec.cle_id := rosetta_g_miss_num_map(p11_a4);
    ddp_clev_fa_rec.cle_id_renewed := rosetta_g_miss_num_map(p11_a5);
    ddp_clev_fa_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p11_a6);
    ddp_clev_fa_rec.lse_id := rosetta_g_miss_num_map(p11_a7);
    ddp_clev_fa_rec.line_number := p11_a8;
    ddp_clev_fa_rec.sts_code := p11_a9;
    ddp_clev_fa_rec.display_sequence := rosetta_g_miss_num_map(p11_a10);
    ddp_clev_fa_rec.trn_code := p11_a11;
    ddp_clev_fa_rec.dnz_chr_id := rosetta_g_miss_num_map(p11_a12);
    ddp_clev_fa_rec.comments := p11_a13;
    ddp_clev_fa_rec.item_description := p11_a14;
    ddp_clev_fa_rec.oke_boe_description := p11_a15;
    ddp_clev_fa_rec.cognomen := p11_a16;
    ddp_clev_fa_rec.hidden_ind := p11_a17;
    ddp_clev_fa_rec.price_unit := rosetta_g_miss_num_map(p11_a18);
    ddp_clev_fa_rec.price_unit_percent := rosetta_g_miss_num_map(p11_a19);
    ddp_clev_fa_rec.price_negotiated := rosetta_g_miss_num_map(p11_a20);
    ddp_clev_fa_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p11_a21);
    ddp_clev_fa_rec.price_level_ind := p11_a22;
    ddp_clev_fa_rec.invoice_line_level_ind := p11_a23;
    ddp_clev_fa_rec.dpas_rating := p11_a24;
    ddp_clev_fa_rec.block23text := p11_a25;
    ddp_clev_fa_rec.exception_yn := p11_a26;
    ddp_clev_fa_rec.template_used := p11_a27;
    ddp_clev_fa_rec.date_terminated := rosetta_g_miss_date_in_map(p11_a28);
    ddp_clev_fa_rec.name := p11_a29;
    ddp_clev_fa_rec.start_date := rosetta_g_miss_date_in_map(p11_a30);
    ddp_clev_fa_rec.end_date := rosetta_g_miss_date_in_map(p11_a31);
    ddp_clev_fa_rec.date_renewed := rosetta_g_miss_date_in_map(p11_a32);
    ddp_clev_fa_rec.upg_orig_system_ref := p11_a33;
    ddp_clev_fa_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p11_a34);
    ddp_clev_fa_rec.orig_system_source_code := p11_a35;
    ddp_clev_fa_rec.orig_system_id1 := rosetta_g_miss_num_map(p11_a36);
    ddp_clev_fa_rec.orig_system_reference1 := p11_a37;
    ddp_clev_fa_rec.attribute_category := p11_a38;
    ddp_clev_fa_rec.attribute1 := p11_a39;
    ddp_clev_fa_rec.attribute2 := p11_a40;
    ddp_clev_fa_rec.attribute3 := p11_a41;
    ddp_clev_fa_rec.attribute4 := p11_a42;
    ddp_clev_fa_rec.attribute5 := p11_a43;
    ddp_clev_fa_rec.attribute6 := p11_a44;
    ddp_clev_fa_rec.attribute7 := p11_a45;
    ddp_clev_fa_rec.attribute8 := p11_a46;
    ddp_clev_fa_rec.attribute9 := p11_a47;
    ddp_clev_fa_rec.attribute10 := p11_a48;
    ddp_clev_fa_rec.attribute11 := p11_a49;
    ddp_clev_fa_rec.attribute12 := p11_a50;
    ddp_clev_fa_rec.attribute13 := p11_a51;
    ddp_clev_fa_rec.attribute14 := p11_a52;
    ddp_clev_fa_rec.attribute15 := p11_a53;
    ddp_clev_fa_rec.created_by := rosetta_g_miss_num_map(p11_a54);
    ddp_clev_fa_rec.creation_date := rosetta_g_miss_date_in_map(p11_a55);
    ddp_clev_fa_rec.last_updated_by := rosetta_g_miss_num_map(p11_a56);
    ddp_clev_fa_rec.last_update_date := rosetta_g_miss_date_in_map(p11_a57);
    ddp_clev_fa_rec.price_type := p11_a58;
    ddp_clev_fa_rec.currency_code := p11_a59;
    ddp_clev_fa_rec.currency_code_renewed := p11_a60;
    ddp_clev_fa_rec.last_update_login := rosetta_g_miss_num_map(p11_a61);
    ddp_clev_fa_rec.old_sts_code := p11_a62;
    ddp_clev_fa_rec.new_sts_code := p11_a63;
    ddp_clev_fa_rec.old_ste_code := p11_a64;
    ddp_clev_fa_rec.new_ste_code := p11_a65;
    ddp_clev_fa_rec.call_action_asmblr := p11_a66;
    ddp_clev_fa_rec.request_id := rosetta_g_miss_num_map(p11_a67);
    ddp_clev_fa_rec.program_application_id := rosetta_g_miss_num_map(p11_a68);
    ddp_clev_fa_rec.program_id := rosetta_g_miss_num_map(p11_a69);
    ddp_clev_fa_rec.program_update_date := rosetta_g_miss_date_in_map(p11_a70);
    ddp_clev_fa_rec.price_list_id := rosetta_g_miss_num_map(p11_a71);
    ddp_clev_fa_rec.pricing_date := rosetta_g_miss_date_in_map(p11_a72);
    ddp_clev_fa_rec.price_list_line_id := rosetta_g_miss_num_map(p11_a73);
    ddp_clev_fa_rec.line_list_price := rosetta_g_miss_num_map(p11_a74);
    ddp_clev_fa_rec.item_to_price_yn := p11_a75;
    ddp_clev_fa_rec.price_basis_yn := p11_a76;
    ddp_clev_fa_rec.config_header_id := rosetta_g_miss_num_map(p11_a77);
    ddp_clev_fa_rec.config_revision_number := rosetta_g_miss_num_map(p11_a78);
    ddp_clev_fa_rec.config_complete_yn := p11_a79;
    ddp_clev_fa_rec.config_valid_yn := p11_a80;
    ddp_clev_fa_rec.config_top_model_line_id := rosetta_g_miss_num_map(p11_a81);
    ddp_clev_fa_rec.config_item_type := p11_a82;
    ddp_clev_fa_rec.config_item_id := rosetta_g_miss_num_map(p11_a83);
    ddp_clev_fa_rec.cust_acct_id := rosetta_g_miss_num_map(p11_a84);
    ddp_clev_fa_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p11_a85);
    ddp_clev_fa_rec.inv_rule_id := rosetta_g_miss_num_map(p11_a86);
    ddp_clev_fa_rec.line_renewal_type_code := p11_a87;
    ddp_clev_fa_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p11_a88);
    ddp_clev_fa_rec.payment_term_id := rosetta_g_miss_num_map(p11_a89);

    ddp_cimv_fa_rec.id := rosetta_g_miss_num_map(p12_a0);
    ddp_cimv_fa_rec.object_version_number := rosetta_g_miss_num_map(p12_a1);
    ddp_cimv_fa_rec.cle_id := rosetta_g_miss_num_map(p12_a2);
    ddp_cimv_fa_rec.chr_id := rosetta_g_miss_num_map(p12_a3);
    ddp_cimv_fa_rec.cle_id_for := rosetta_g_miss_num_map(p12_a4);
    ddp_cimv_fa_rec.dnz_chr_id := rosetta_g_miss_num_map(p12_a5);
    ddp_cimv_fa_rec.object1_id1 := p12_a6;
    ddp_cimv_fa_rec.object1_id2 := p12_a7;
    ddp_cimv_fa_rec.jtot_object1_code := p12_a8;
    ddp_cimv_fa_rec.uom_code := p12_a9;
    ddp_cimv_fa_rec.exception_yn := p12_a10;
    ddp_cimv_fa_rec.number_of_items := rosetta_g_miss_num_map(p12_a11);
    ddp_cimv_fa_rec.upg_orig_system_ref := p12_a12;
    ddp_cimv_fa_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p12_a13);
    ddp_cimv_fa_rec.priced_item_yn := p12_a14;
    ddp_cimv_fa_rec.created_by := rosetta_g_miss_num_map(p12_a15);
    ddp_cimv_fa_rec.creation_date := rosetta_g_miss_date_in_map(p12_a16);
    ddp_cimv_fa_rec.last_updated_by := rosetta_g_miss_num_map(p12_a17);
    ddp_cimv_fa_rec.last_update_date := rosetta_g_miss_date_in_map(p12_a18);
    ddp_cimv_fa_rec.last_update_login := rosetta_g_miss_num_map(p12_a19);

    ddp_talv_fa_rec.id := rosetta_g_miss_num_map(p13_a0);
    ddp_talv_fa_rec.object_version_number := rosetta_g_miss_num_map(p13_a1);
    ddp_talv_fa_rec.sfwt_flag := p13_a2;
    ddp_talv_fa_rec.tas_id := rosetta_g_miss_num_map(p13_a3);
    ddp_talv_fa_rec.ilo_id := rosetta_g_miss_num_map(p13_a4);
    ddp_talv_fa_rec.ilo_id_old := rosetta_g_miss_num_map(p13_a5);
    ddp_talv_fa_rec.iay_id := rosetta_g_miss_num_map(p13_a6);
    ddp_talv_fa_rec.iay_id_new := rosetta_g_miss_num_map(p13_a7);
    ddp_talv_fa_rec.kle_id := rosetta_g_miss_num_map(p13_a8);
    ddp_talv_fa_rec.dnz_khr_id := rosetta_g_miss_num_map(p13_a9);
    ddp_talv_fa_rec.line_number := rosetta_g_miss_num_map(p13_a10);
    ddp_talv_fa_rec.org_id := rosetta_g_miss_num_map(p13_a11);
    ddp_talv_fa_rec.tal_type := p13_a12;
    ddp_talv_fa_rec.asset_number := p13_a13;
    ddp_talv_fa_rec.description := p13_a14;
    ddp_talv_fa_rec.fa_location_id := rosetta_g_miss_num_map(p13_a15);
    ddp_talv_fa_rec.original_cost := rosetta_g_miss_num_map(p13_a16);
    ddp_talv_fa_rec.current_units := rosetta_g_miss_num_map(p13_a17);
    ddp_talv_fa_rec.manufacturer_name := p13_a18;
    ddp_talv_fa_rec.year_manufactured := rosetta_g_miss_num_map(p13_a19);
    ddp_talv_fa_rec.supplier_id := rosetta_g_miss_num_map(p13_a20);
    ddp_talv_fa_rec.used_asset_yn := p13_a21;
    ddp_talv_fa_rec.tag_number := p13_a22;
    ddp_talv_fa_rec.model_number := p13_a23;
    ddp_talv_fa_rec.corporate_book := p13_a24;
    ddp_talv_fa_rec.date_purchased := rosetta_g_miss_date_in_map(p13_a25);
    ddp_talv_fa_rec.date_delivery := rosetta_g_miss_date_in_map(p13_a26);
    ddp_talv_fa_rec.in_service_date := rosetta_g_miss_date_in_map(p13_a27);
    ddp_talv_fa_rec.life_in_months := rosetta_g_miss_num_map(p13_a28);
    ddp_talv_fa_rec.depreciation_id := rosetta_g_miss_num_map(p13_a29);
    ddp_talv_fa_rec.depreciation_cost := rosetta_g_miss_num_map(p13_a30);
    ddp_talv_fa_rec.deprn_method := p13_a31;
    ddp_talv_fa_rec.deprn_rate := rosetta_g_miss_num_map(p13_a32);
    ddp_talv_fa_rec.salvage_value := rosetta_g_miss_num_map(p13_a33);
    ddp_talv_fa_rec.percent_salvage_value := rosetta_g_miss_num_map(p13_a34);
    ddp_talv_fa_rec.asset_key_id := rosetta_g_miss_num_map(p13_a35);
    ddp_talv_fa_rec.attribute_category := p13_a36;
    ddp_talv_fa_rec.attribute1 := p13_a37;
    ddp_talv_fa_rec.attribute2 := p13_a38;
    ddp_talv_fa_rec.attribute3 := p13_a39;
    ddp_talv_fa_rec.attribute4 := p13_a40;
    ddp_talv_fa_rec.attribute5 := p13_a41;
    ddp_talv_fa_rec.attribute6 := p13_a42;
    ddp_talv_fa_rec.attribute7 := p13_a43;
    ddp_talv_fa_rec.attribute8 := p13_a44;
    ddp_talv_fa_rec.attribute9 := p13_a45;
    ddp_talv_fa_rec.attribute10 := p13_a46;
    ddp_talv_fa_rec.attribute11 := p13_a47;
    ddp_talv_fa_rec.attribute12 := p13_a48;
    ddp_talv_fa_rec.attribute13 := p13_a49;
    ddp_talv_fa_rec.attribute14 := p13_a50;
    ddp_talv_fa_rec.attribute15 := p13_a51;
    ddp_talv_fa_rec.created_by := rosetta_g_miss_num_map(p13_a52);
    ddp_talv_fa_rec.creation_date := rosetta_g_miss_date_in_map(p13_a53);
    ddp_talv_fa_rec.last_updated_by := rosetta_g_miss_num_map(p13_a54);
    ddp_talv_fa_rec.last_update_date := rosetta_g_miss_date_in_map(p13_a55);
    ddp_talv_fa_rec.last_update_login := rosetta_g_miss_num_map(p13_a56);
    ddp_talv_fa_rec.depreciate_yn := p13_a57;
    ddp_talv_fa_rec.hold_period_days := rosetta_g_miss_num_map(p13_a58);
    ddp_talv_fa_rec.old_salvage_value := rosetta_g_miss_num_map(p13_a59);
    ddp_talv_fa_rec.new_residual_value := rosetta_g_miss_num_map(p13_a60);
    ddp_talv_fa_rec.old_residual_value := rosetta_g_miss_num_map(p13_a61);
    ddp_talv_fa_rec.units_retired := rosetta_g_miss_num_map(p13_a62);
    ddp_talv_fa_rec.cost_retired := rosetta_g_miss_num_map(p13_a63);
    ddp_talv_fa_rec.sale_proceeds := rosetta_g_miss_num_map(p13_a64);
    ddp_talv_fa_rec.removal_cost := rosetta_g_miss_num_map(p13_a65);
    ddp_talv_fa_rec.dnz_asset_id := rosetta_g_miss_num_map(p13_a66);
    ddp_talv_fa_rec.date_due := rosetta_g_miss_date_in_map(p13_a67);
    ddp_talv_fa_rec.rep_asset_id := rosetta_g_miss_num_map(p13_a68);
    ddp_talv_fa_rec.lke_asset_id := rosetta_g_miss_num_map(p13_a69);
    ddp_talv_fa_rec.match_amount := rosetta_g_miss_num_map(p13_a70);
    ddp_talv_fa_rec.split_into_singles_flag := p13_a71;
    ddp_talv_fa_rec.split_into_units := rosetta_g_miss_num_map(p13_a72);
    ddp_talv_fa_rec.currency_code := p13_a73;
    ddp_talv_fa_rec.currency_conversion_type := p13_a74;
    ddp_talv_fa_rec.currency_conversion_rate := rosetta_g_miss_num_map(p13_a75);
    ddp_talv_fa_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p13_a76);

    ddp_clev_ib_rec.id := rosetta_g_miss_num_map(p14_a0);
    ddp_clev_ib_rec.object_version_number := rosetta_g_miss_num_map(p14_a1);
    ddp_clev_ib_rec.sfwt_flag := p14_a2;
    ddp_clev_ib_rec.chr_id := rosetta_g_miss_num_map(p14_a3);
    ddp_clev_ib_rec.cle_id := rosetta_g_miss_num_map(p14_a4);
    ddp_clev_ib_rec.cle_id_renewed := rosetta_g_miss_num_map(p14_a5);
    ddp_clev_ib_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p14_a6);
    ddp_clev_ib_rec.lse_id := rosetta_g_miss_num_map(p14_a7);
    ddp_clev_ib_rec.line_number := p14_a8;
    ddp_clev_ib_rec.sts_code := p14_a9;
    ddp_clev_ib_rec.display_sequence := rosetta_g_miss_num_map(p14_a10);
    ddp_clev_ib_rec.trn_code := p14_a11;
    ddp_clev_ib_rec.dnz_chr_id := rosetta_g_miss_num_map(p14_a12);
    ddp_clev_ib_rec.comments := p14_a13;
    ddp_clev_ib_rec.item_description := p14_a14;
    ddp_clev_ib_rec.oke_boe_description := p14_a15;
    ddp_clev_ib_rec.cognomen := p14_a16;
    ddp_clev_ib_rec.hidden_ind := p14_a17;
    ddp_clev_ib_rec.price_unit := rosetta_g_miss_num_map(p14_a18);
    ddp_clev_ib_rec.price_unit_percent := rosetta_g_miss_num_map(p14_a19);
    ddp_clev_ib_rec.price_negotiated := rosetta_g_miss_num_map(p14_a20);
    ddp_clev_ib_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p14_a21);
    ddp_clev_ib_rec.price_level_ind := p14_a22;
    ddp_clev_ib_rec.invoice_line_level_ind := p14_a23;
    ddp_clev_ib_rec.dpas_rating := p14_a24;
    ddp_clev_ib_rec.block23text := p14_a25;
    ddp_clev_ib_rec.exception_yn := p14_a26;
    ddp_clev_ib_rec.template_used := p14_a27;
    ddp_clev_ib_rec.date_terminated := rosetta_g_miss_date_in_map(p14_a28);
    ddp_clev_ib_rec.name := p14_a29;
    ddp_clev_ib_rec.start_date := rosetta_g_miss_date_in_map(p14_a30);
    ddp_clev_ib_rec.end_date := rosetta_g_miss_date_in_map(p14_a31);
    ddp_clev_ib_rec.date_renewed := rosetta_g_miss_date_in_map(p14_a32);
    ddp_clev_ib_rec.upg_orig_system_ref := p14_a33;
    ddp_clev_ib_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p14_a34);
    ddp_clev_ib_rec.orig_system_source_code := p14_a35;
    ddp_clev_ib_rec.orig_system_id1 := rosetta_g_miss_num_map(p14_a36);
    ddp_clev_ib_rec.orig_system_reference1 := p14_a37;
    ddp_clev_ib_rec.attribute_category := p14_a38;
    ddp_clev_ib_rec.attribute1 := p14_a39;
    ddp_clev_ib_rec.attribute2 := p14_a40;
    ddp_clev_ib_rec.attribute3 := p14_a41;
    ddp_clev_ib_rec.attribute4 := p14_a42;
    ddp_clev_ib_rec.attribute5 := p14_a43;
    ddp_clev_ib_rec.attribute6 := p14_a44;
    ddp_clev_ib_rec.attribute7 := p14_a45;
    ddp_clev_ib_rec.attribute8 := p14_a46;
    ddp_clev_ib_rec.attribute9 := p14_a47;
    ddp_clev_ib_rec.attribute10 := p14_a48;
    ddp_clev_ib_rec.attribute11 := p14_a49;
    ddp_clev_ib_rec.attribute12 := p14_a50;
    ddp_clev_ib_rec.attribute13 := p14_a51;
    ddp_clev_ib_rec.attribute14 := p14_a52;
    ddp_clev_ib_rec.attribute15 := p14_a53;
    ddp_clev_ib_rec.created_by := rosetta_g_miss_num_map(p14_a54);
    ddp_clev_ib_rec.creation_date := rosetta_g_miss_date_in_map(p14_a55);
    ddp_clev_ib_rec.last_updated_by := rosetta_g_miss_num_map(p14_a56);
    ddp_clev_ib_rec.last_update_date := rosetta_g_miss_date_in_map(p14_a57);
    ddp_clev_ib_rec.price_type := p14_a58;
    ddp_clev_ib_rec.currency_code := p14_a59;
    ddp_clev_ib_rec.currency_code_renewed := p14_a60;
    ddp_clev_ib_rec.last_update_login := rosetta_g_miss_num_map(p14_a61);
    ddp_clev_ib_rec.old_sts_code := p14_a62;
    ddp_clev_ib_rec.new_sts_code := p14_a63;
    ddp_clev_ib_rec.old_ste_code := p14_a64;
    ddp_clev_ib_rec.new_ste_code := p14_a65;
    ddp_clev_ib_rec.call_action_asmblr := p14_a66;
    ddp_clev_ib_rec.request_id := rosetta_g_miss_num_map(p14_a67);
    ddp_clev_ib_rec.program_application_id := rosetta_g_miss_num_map(p14_a68);
    ddp_clev_ib_rec.program_id := rosetta_g_miss_num_map(p14_a69);
    ddp_clev_ib_rec.program_update_date := rosetta_g_miss_date_in_map(p14_a70);
    ddp_clev_ib_rec.price_list_id := rosetta_g_miss_num_map(p14_a71);
    ddp_clev_ib_rec.pricing_date := rosetta_g_miss_date_in_map(p14_a72);
    ddp_clev_ib_rec.price_list_line_id := rosetta_g_miss_num_map(p14_a73);
    ddp_clev_ib_rec.line_list_price := rosetta_g_miss_num_map(p14_a74);
    ddp_clev_ib_rec.item_to_price_yn := p14_a75;
    ddp_clev_ib_rec.price_basis_yn := p14_a76;
    ddp_clev_ib_rec.config_header_id := rosetta_g_miss_num_map(p14_a77);
    ddp_clev_ib_rec.config_revision_number := rosetta_g_miss_num_map(p14_a78);
    ddp_clev_ib_rec.config_complete_yn := p14_a79;
    ddp_clev_ib_rec.config_valid_yn := p14_a80;
    ddp_clev_ib_rec.config_top_model_line_id := rosetta_g_miss_num_map(p14_a81);
    ddp_clev_ib_rec.config_item_type := p14_a82;
    ddp_clev_ib_rec.config_item_id := rosetta_g_miss_num_map(p14_a83);
    ddp_clev_ib_rec.cust_acct_id := rosetta_g_miss_num_map(p14_a84);
    ddp_clev_ib_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p14_a85);
    ddp_clev_ib_rec.inv_rule_id := rosetta_g_miss_num_map(p14_a86);
    ddp_clev_ib_rec.line_renewal_type_code := p14_a87;
    ddp_clev_ib_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p14_a88);
    ddp_clev_ib_rec.payment_term_id := rosetta_g_miss_num_map(p14_a89);

    ddp_itiv_ib_rec.id := rosetta_g_miss_num_map(p15_a0);
    ddp_itiv_ib_rec.object_version_number := rosetta_g_miss_num_map(p15_a1);
    ddp_itiv_ib_rec.tas_id := rosetta_g_miss_num_map(p15_a2);
    ddp_itiv_ib_rec.tal_id := rosetta_g_miss_num_map(p15_a3);
    ddp_itiv_ib_rec.kle_id := rosetta_g_miss_num_map(p15_a4);
    ddp_itiv_ib_rec.tal_type := p15_a5;
    ddp_itiv_ib_rec.line_number := rosetta_g_miss_num_map(p15_a6);
    ddp_itiv_ib_rec.instance_number_ib := p15_a7;
    ddp_itiv_ib_rec.object_id1_new := p15_a8;
    ddp_itiv_ib_rec.object_id2_new := p15_a9;
    ddp_itiv_ib_rec.jtot_object_code_new := p15_a10;
    ddp_itiv_ib_rec.object_id1_old := p15_a11;
    ddp_itiv_ib_rec.object_id2_old := p15_a12;
    ddp_itiv_ib_rec.jtot_object_code_old := p15_a13;
    ddp_itiv_ib_rec.inventory_org_id := rosetta_g_miss_num_map(p15_a14);
    ddp_itiv_ib_rec.serial_number := p15_a15;
    ddp_itiv_ib_rec.mfg_serial_number_yn := p15_a16;
    ddp_itiv_ib_rec.inventory_item_id := rosetta_g_miss_num_map(p15_a17);
    ddp_itiv_ib_rec.inv_master_org_id := rosetta_g_miss_num_map(p15_a18);
    ddp_itiv_ib_rec.attribute_category := p15_a19;
    ddp_itiv_ib_rec.attribute1 := p15_a20;
    ddp_itiv_ib_rec.attribute2 := p15_a21;
    ddp_itiv_ib_rec.attribute3 := p15_a22;
    ddp_itiv_ib_rec.attribute4 := p15_a23;
    ddp_itiv_ib_rec.attribute5 := p15_a24;
    ddp_itiv_ib_rec.attribute6 := p15_a25;
    ddp_itiv_ib_rec.attribute7 := p15_a26;
    ddp_itiv_ib_rec.attribute8 := p15_a27;
    ddp_itiv_ib_rec.attribute9 := p15_a28;
    ddp_itiv_ib_rec.attribute10 := p15_a29;
    ddp_itiv_ib_rec.attribute11 := p15_a30;
    ddp_itiv_ib_rec.attribute12 := p15_a31;
    ddp_itiv_ib_rec.attribute13 := p15_a32;
    ddp_itiv_ib_rec.attribute14 := p15_a33;
    ddp_itiv_ib_rec.attribute15 := p15_a34;
    ddp_itiv_ib_rec.created_by := rosetta_g_miss_num_map(p15_a35);
    ddp_itiv_ib_rec.creation_date := rosetta_g_miss_date_in_map(p15_a36);
    ddp_itiv_ib_rec.last_updated_by := rosetta_g_miss_num_map(p15_a37);
    ddp_itiv_ib_rec.last_update_date := rosetta_g_miss_date_in_map(p15_a38);
    ddp_itiv_ib_rec.last_update_login := rosetta_g_miss_num_map(p15_a39);
    ddp_itiv_ib_rec.dnz_cle_id := rosetta_g_miss_num_map(p15_a40);
    ddp_itiv_ib_rec.instance_id := rosetta_g_miss_num_map(p15_a41);
    ddp_itiv_ib_rec.selected_for_split_flag := p15_a42;
    ddp_itiv_ib_rec.asd_id := rosetta_g_miss_num_map(p15_a43);





    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.update_all_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_fin_rec,
      ddp_klev_fin_rec,
      ddp_clev_model_rec,
      ddp_cimv_model_rec,
      ddp_clev_fa_rec,
      ddp_cimv_fa_rec,
      ddp_talv_fa_rec,
      ddp_clev_ib_rec,
      ddp_itiv_ib_rec,
      ddx_clev_fin_rec,
      ddx_clev_model_rec,
      ddx_clev_fa_rec,
      ddx_clev_ib_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















    p16_a0 := rosetta_g_miss_num_map(ddx_clev_fin_rec.id);
    p16_a1 := rosetta_g_miss_num_map(ddx_clev_fin_rec.object_version_number);
    p16_a2 := ddx_clev_fin_rec.sfwt_flag;
    p16_a3 := rosetta_g_miss_num_map(ddx_clev_fin_rec.chr_id);
    p16_a4 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id);
    p16_a5 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed);
    p16_a6 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed_to);
    p16_a7 := rosetta_g_miss_num_map(ddx_clev_fin_rec.lse_id);
    p16_a8 := ddx_clev_fin_rec.line_number;
    p16_a9 := ddx_clev_fin_rec.sts_code;
    p16_a10 := rosetta_g_miss_num_map(ddx_clev_fin_rec.display_sequence);
    p16_a11 := ddx_clev_fin_rec.trn_code;
    p16_a12 := rosetta_g_miss_num_map(ddx_clev_fin_rec.dnz_chr_id);
    p16_a13 := ddx_clev_fin_rec.comments;
    p16_a14 := ddx_clev_fin_rec.item_description;
    p16_a15 := ddx_clev_fin_rec.oke_boe_description;
    p16_a16 := ddx_clev_fin_rec.cognomen;
    p16_a17 := ddx_clev_fin_rec.hidden_ind;
    p16_a18 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit);
    p16_a19 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit_percent);
    p16_a20 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated);
    p16_a21 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated_renewed);
    p16_a22 := ddx_clev_fin_rec.price_level_ind;
    p16_a23 := ddx_clev_fin_rec.invoice_line_level_ind;
    p16_a24 := ddx_clev_fin_rec.dpas_rating;
    p16_a25 := ddx_clev_fin_rec.block23text;
    p16_a26 := ddx_clev_fin_rec.exception_yn;
    p16_a27 := ddx_clev_fin_rec.template_used;
    p16_a28 := ddx_clev_fin_rec.date_terminated;
    p16_a29 := ddx_clev_fin_rec.name;
    p16_a30 := ddx_clev_fin_rec.start_date;
    p16_a31 := ddx_clev_fin_rec.end_date;
    p16_a32 := ddx_clev_fin_rec.date_renewed;
    p16_a33 := ddx_clev_fin_rec.upg_orig_system_ref;
    p16_a34 := rosetta_g_miss_num_map(ddx_clev_fin_rec.upg_orig_system_ref_id);
    p16_a35 := ddx_clev_fin_rec.orig_system_source_code;
    p16_a36 := rosetta_g_miss_num_map(ddx_clev_fin_rec.orig_system_id1);
    p16_a37 := ddx_clev_fin_rec.orig_system_reference1;
    p16_a38 := ddx_clev_fin_rec.attribute_category;
    p16_a39 := ddx_clev_fin_rec.attribute1;
    p16_a40 := ddx_clev_fin_rec.attribute2;
    p16_a41 := ddx_clev_fin_rec.attribute3;
    p16_a42 := ddx_clev_fin_rec.attribute4;
    p16_a43 := ddx_clev_fin_rec.attribute5;
    p16_a44 := ddx_clev_fin_rec.attribute6;
    p16_a45 := ddx_clev_fin_rec.attribute7;
    p16_a46 := ddx_clev_fin_rec.attribute8;
    p16_a47 := ddx_clev_fin_rec.attribute9;
    p16_a48 := ddx_clev_fin_rec.attribute10;
    p16_a49 := ddx_clev_fin_rec.attribute11;
    p16_a50 := ddx_clev_fin_rec.attribute12;
    p16_a51 := ddx_clev_fin_rec.attribute13;
    p16_a52 := ddx_clev_fin_rec.attribute14;
    p16_a53 := ddx_clev_fin_rec.attribute15;
    p16_a54 := rosetta_g_miss_num_map(ddx_clev_fin_rec.created_by);
    p16_a55 := ddx_clev_fin_rec.creation_date;
    p16_a56 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_updated_by);
    p16_a57 := ddx_clev_fin_rec.last_update_date;
    p16_a58 := ddx_clev_fin_rec.price_type;
    p16_a59 := ddx_clev_fin_rec.currency_code;
    p16_a60 := ddx_clev_fin_rec.currency_code_renewed;
    p16_a61 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_update_login);
    p16_a62 := ddx_clev_fin_rec.old_sts_code;
    p16_a63 := ddx_clev_fin_rec.new_sts_code;
    p16_a64 := ddx_clev_fin_rec.old_ste_code;
    p16_a65 := ddx_clev_fin_rec.new_ste_code;
    p16_a66 := ddx_clev_fin_rec.call_action_asmblr;
    p16_a67 := rosetta_g_miss_num_map(ddx_clev_fin_rec.request_id);
    p16_a68 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_application_id);
    p16_a69 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_id);
    p16_a70 := ddx_clev_fin_rec.program_update_date;
    p16_a71 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_id);
    p16_a72 := ddx_clev_fin_rec.pricing_date;
    p16_a73 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_line_id);
    p16_a74 := rosetta_g_miss_num_map(ddx_clev_fin_rec.line_list_price);
    p16_a75 := ddx_clev_fin_rec.item_to_price_yn;
    p16_a76 := ddx_clev_fin_rec.price_basis_yn;
    p16_a77 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_header_id);
    p16_a78 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_revision_number);
    p16_a79 := ddx_clev_fin_rec.config_complete_yn;
    p16_a80 := ddx_clev_fin_rec.config_valid_yn;
    p16_a81 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_top_model_line_id);
    p16_a82 := ddx_clev_fin_rec.config_item_type;
    p16_a83 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_item_id);
    p16_a84 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cust_acct_id);
    p16_a85 := rosetta_g_miss_num_map(ddx_clev_fin_rec.bill_to_site_use_id);
    p16_a86 := rosetta_g_miss_num_map(ddx_clev_fin_rec.inv_rule_id);
    p16_a87 := ddx_clev_fin_rec.line_renewal_type_code;
    p16_a88 := rosetta_g_miss_num_map(ddx_clev_fin_rec.ship_to_site_use_id);
    p16_a89 := rosetta_g_miss_num_map(ddx_clev_fin_rec.payment_term_id);

    p17_a0 := rosetta_g_miss_num_map(ddx_clev_model_rec.id);
    p17_a1 := rosetta_g_miss_num_map(ddx_clev_model_rec.object_version_number);
    p17_a2 := ddx_clev_model_rec.sfwt_flag;
    p17_a3 := rosetta_g_miss_num_map(ddx_clev_model_rec.chr_id);
    p17_a4 := rosetta_g_miss_num_map(ddx_clev_model_rec.cle_id);
    p17_a5 := rosetta_g_miss_num_map(ddx_clev_model_rec.cle_id_renewed);
    p17_a6 := rosetta_g_miss_num_map(ddx_clev_model_rec.cle_id_renewed_to);
    p17_a7 := rosetta_g_miss_num_map(ddx_clev_model_rec.lse_id);
    p17_a8 := ddx_clev_model_rec.line_number;
    p17_a9 := ddx_clev_model_rec.sts_code;
    p17_a10 := rosetta_g_miss_num_map(ddx_clev_model_rec.display_sequence);
    p17_a11 := ddx_clev_model_rec.trn_code;
    p17_a12 := rosetta_g_miss_num_map(ddx_clev_model_rec.dnz_chr_id);
    p17_a13 := ddx_clev_model_rec.comments;
    p17_a14 := ddx_clev_model_rec.item_description;
    p17_a15 := ddx_clev_model_rec.oke_boe_description;
    p17_a16 := ddx_clev_model_rec.cognomen;
    p17_a17 := ddx_clev_model_rec.hidden_ind;
    p17_a18 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_unit);
    p17_a19 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_unit_percent);
    p17_a20 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_negotiated);
    p17_a21 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_negotiated_renewed);
    p17_a22 := ddx_clev_model_rec.price_level_ind;
    p17_a23 := ddx_clev_model_rec.invoice_line_level_ind;
    p17_a24 := ddx_clev_model_rec.dpas_rating;
    p17_a25 := ddx_clev_model_rec.block23text;
    p17_a26 := ddx_clev_model_rec.exception_yn;
    p17_a27 := ddx_clev_model_rec.template_used;
    p17_a28 := ddx_clev_model_rec.date_terminated;
    p17_a29 := ddx_clev_model_rec.name;
    p17_a30 := ddx_clev_model_rec.start_date;
    p17_a31 := ddx_clev_model_rec.end_date;
    p17_a32 := ddx_clev_model_rec.date_renewed;
    p17_a33 := ddx_clev_model_rec.upg_orig_system_ref;
    p17_a34 := rosetta_g_miss_num_map(ddx_clev_model_rec.upg_orig_system_ref_id);
    p17_a35 := ddx_clev_model_rec.orig_system_source_code;
    p17_a36 := rosetta_g_miss_num_map(ddx_clev_model_rec.orig_system_id1);
    p17_a37 := ddx_clev_model_rec.orig_system_reference1;
    p17_a38 := ddx_clev_model_rec.attribute_category;
    p17_a39 := ddx_clev_model_rec.attribute1;
    p17_a40 := ddx_clev_model_rec.attribute2;
    p17_a41 := ddx_clev_model_rec.attribute3;
    p17_a42 := ddx_clev_model_rec.attribute4;
    p17_a43 := ddx_clev_model_rec.attribute5;
    p17_a44 := ddx_clev_model_rec.attribute6;
    p17_a45 := ddx_clev_model_rec.attribute7;
    p17_a46 := ddx_clev_model_rec.attribute8;
    p17_a47 := ddx_clev_model_rec.attribute9;
    p17_a48 := ddx_clev_model_rec.attribute10;
    p17_a49 := ddx_clev_model_rec.attribute11;
    p17_a50 := ddx_clev_model_rec.attribute12;
    p17_a51 := ddx_clev_model_rec.attribute13;
    p17_a52 := ddx_clev_model_rec.attribute14;
    p17_a53 := ddx_clev_model_rec.attribute15;
    p17_a54 := rosetta_g_miss_num_map(ddx_clev_model_rec.created_by);
    p17_a55 := ddx_clev_model_rec.creation_date;
    p17_a56 := rosetta_g_miss_num_map(ddx_clev_model_rec.last_updated_by);
    p17_a57 := ddx_clev_model_rec.last_update_date;
    p17_a58 := ddx_clev_model_rec.price_type;
    p17_a59 := ddx_clev_model_rec.currency_code;
    p17_a60 := ddx_clev_model_rec.currency_code_renewed;
    p17_a61 := rosetta_g_miss_num_map(ddx_clev_model_rec.last_update_login);
    p17_a62 := ddx_clev_model_rec.old_sts_code;
    p17_a63 := ddx_clev_model_rec.new_sts_code;
    p17_a64 := ddx_clev_model_rec.old_ste_code;
    p17_a65 := ddx_clev_model_rec.new_ste_code;
    p17_a66 := ddx_clev_model_rec.call_action_asmblr;
    p17_a67 := rosetta_g_miss_num_map(ddx_clev_model_rec.request_id);
    p17_a68 := rosetta_g_miss_num_map(ddx_clev_model_rec.program_application_id);
    p17_a69 := rosetta_g_miss_num_map(ddx_clev_model_rec.program_id);
    p17_a70 := ddx_clev_model_rec.program_update_date;
    p17_a71 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_list_id);
    p17_a72 := ddx_clev_model_rec.pricing_date;
    p17_a73 := rosetta_g_miss_num_map(ddx_clev_model_rec.price_list_line_id);
    p17_a74 := rosetta_g_miss_num_map(ddx_clev_model_rec.line_list_price);
    p17_a75 := ddx_clev_model_rec.item_to_price_yn;
    p17_a76 := ddx_clev_model_rec.price_basis_yn;
    p17_a77 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_header_id);
    p17_a78 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_revision_number);
    p17_a79 := ddx_clev_model_rec.config_complete_yn;
    p17_a80 := ddx_clev_model_rec.config_valid_yn;
    p17_a81 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_top_model_line_id);
    p17_a82 := ddx_clev_model_rec.config_item_type;
    p17_a83 := rosetta_g_miss_num_map(ddx_clev_model_rec.config_item_id);
    p17_a84 := rosetta_g_miss_num_map(ddx_clev_model_rec.cust_acct_id);
    p17_a85 := rosetta_g_miss_num_map(ddx_clev_model_rec.bill_to_site_use_id);
    p17_a86 := rosetta_g_miss_num_map(ddx_clev_model_rec.inv_rule_id);
    p17_a87 := ddx_clev_model_rec.line_renewal_type_code;
    p17_a88 := rosetta_g_miss_num_map(ddx_clev_model_rec.ship_to_site_use_id);
    p17_a89 := rosetta_g_miss_num_map(ddx_clev_model_rec.payment_term_id);

    p18_a0 := rosetta_g_miss_num_map(ddx_clev_fa_rec.id);
    p18_a1 := rosetta_g_miss_num_map(ddx_clev_fa_rec.object_version_number);
    p18_a2 := ddx_clev_fa_rec.sfwt_flag;
    p18_a3 := rosetta_g_miss_num_map(ddx_clev_fa_rec.chr_id);
    p18_a4 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cle_id);
    p18_a5 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cle_id_renewed);
    p18_a6 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cle_id_renewed_to);
    p18_a7 := rosetta_g_miss_num_map(ddx_clev_fa_rec.lse_id);
    p18_a8 := ddx_clev_fa_rec.line_number;
    p18_a9 := ddx_clev_fa_rec.sts_code;
    p18_a10 := rosetta_g_miss_num_map(ddx_clev_fa_rec.display_sequence);
    p18_a11 := ddx_clev_fa_rec.trn_code;
    p18_a12 := rosetta_g_miss_num_map(ddx_clev_fa_rec.dnz_chr_id);
    p18_a13 := ddx_clev_fa_rec.comments;
    p18_a14 := ddx_clev_fa_rec.item_description;
    p18_a15 := ddx_clev_fa_rec.oke_boe_description;
    p18_a16 := ddx_clev_fa_rec.cognomen;
    p18_a17 := ddx_clev_fa_rec.hidden_ind;
    p18_a18 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_unit);
    p18_a19 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_unit_percent);
    p18_a20 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_negotiated);
    p18_a21 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_negotiated_renewed);
    p18_a22 := ddx_clev_fa_rec.price_level_ind;
    p18_a23 := ddx_clev_fa_rec.invoice_line_level_ind;
    p18_a24 := ddx_clev_fa_rec.dpas_rating;
    p18_a25 := ddx_clev_fa_rec.block23text;
    p18_a26 := ddx_clev_fa_rec.exception_yn;
    p18_a27 := ddx_clev_fa_rec.template_used;
    p18_a28 := ddx_clev_fa_rec.date_terminated;
    p18_a29 := ddx_clev_fa_rec.name;
    p18_a30 := ddx_clev_fa_rec.start_date;
    p18_a31 := ddx_clev_fa_rec.end_date;
    p18_a32 := ddx_clev_fa_rec.date_renewed;
    p18_a33 := ddx_clev_fa_rec.upg_orig_system_ref;
    p18_a34 := rosetta_g_miss_num_map(ddx_clev_fa_rec.upg_orig_system_ref_id);
    p18_a35 := ddx_clev_fa_rec.orig_system_source_code;
    p18_a36 := rosetta_g_miss_num_map(ddx_clev_fa_rec.orig_system_id1);
    p18_a37 := ddx_clev_fa_rec.orig_system_reference1;
    p18_a38 := ddx_clev_fa_rec.attribute_category;
    p18_a39 := ddx_clev_fa_rec.attribute1;
    p18_a40 := ddx_clev_fa_rec.attribute2;
    p18_a41 := ddx_clev_fa_rec.attribute3;
    p18_a42 := ddx_clev_fa_rec.attribute4;
    p18_a43 := ddx_clev_fa_rec.attribute5;
    p18_a44 := ddx_clev_fa_rec.attribute6;
    p18_a45 := ddx_clev_fa_rec.attribute7;
    p18_a46 := ddx_clev_fa_rec.attribute8;
    p18_a47 := ddx_clev_fa_rec.attribute9;
    p18_a48 := ddx_clev_fa_rec.attribute10;
    p18_a49 := ddx_clev_fa_rec.attribute11;
    p18_a50 := ddx_clev_fa_rec.attribute12;
    p18_a51 := ddx_clev_fa_rec.attribute13;
    p18_a52 := ddx_clev_fa_rec.attribute14;
    p18_a53 := ddx_clev_fa_rec.attribute15;
    p18_a54 := rosetta_g_miss_num_map(ddx_clev_fa_rec.created_by);
    p18_a55 := ddx_clev_fa_rec.creation_date;
    p18_a56 := rosetta_g_miss_num_map(ddx_clev_fa_rec.last_updated_by);
    p18_a57 := ddx_clev_fa_rec.last_update_date;
    p18_a58 := ddx_clev_fa_rec.price_type;
    p18_a59 := ddx_clev_fa_rec.currency_code;
    p18_a60 := ddx_clev_fa_rec.currency_code_renewed;
    p18_a61 := rosetta_g_miss_num_map(ddx_clev_fa_rec.last_update_login);
    p18_a62 := ddx_clev_fa_rec.old_sts_code;
    p18_a63 := ddx_clev_fa_rec.new_sts_code;
    p18_a64 := ddx_clev_fa_rec.old_ste_code;
    p18_a65 := ddx_clev_fa_rec.new_ste_code;
    p18_a66 := ddx_clev_fa_rec.call_action_asmblr;
    p18_a67 := rosetta_g_miss_num_map(ddx_clev_fa_rec.request_id);
    p18_a68 := rosetta_g_miss_num_map(ddx_clev_fa_rec.program_application_id);
    p18_a69 := rosetta_g_miss_num_map(ddx_clev_fa_rec.program_id);
    p18_a70 := ddx_clev_fa_rec.program_update_date;
    p18_a71 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_list_id);
    p18_a72 := ddx_clev_fa_rec.pricing_date;
    p18_a73 := rosetta_g_miss_num_map(ddx_clev_fa_rec.price_list_line_id);
    p18_a74 := rosetta_g_miss_num_map(ddx_clev_fa_rec.line_list_price);
    p18_a75 := ddx_clev_fa_rec.item_to_price_yn;
    p18_a76 := ddx_clev_fa_rec.price_basis_yn;
    p18_a77 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_header_id);
    p18_a78 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_revision_number);
    p18_a79 := ddx_clev_fa_rec.config_complete_yn;
    p18_a80 := ddx_clev_fa_rec.config_valid_yn;
    p18_a81 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_top_model_line_id);
    p18_a82 := ddx_clev_fa_rec.config_item_type;
    p18_a83 := rosetta_g_miss_num_map(ddx_clev_fa_rec.config_item_id);
    p18_a84 := rosetta_g_miss_num_map(ddx_clev_fa_rec.cust_acct_id);
    p18_a85 := rosetta_g_miss_num_map(ddx_clev_fa_rec.bill_to_site_use_id);
    p18_a86 := rosetta_g_miss_num_map(ddx_clev_fa_rec.inv_rule_id);
    p18_a87 := ddx_clev_fa_rec.line_renewal_type_code;
    p18_a88 := rosetta_g_miss_num_map(ddx_clev_fa_rec.ship_to_site_use_id);
    p18_a89 := rosetta_g_miss_num_map(ddx_clev_fa_rec.payment_term_id);

    p19_a0 := rosetta_g_miss_num_map(ddx_clev_ib_rec.id);
    p19_a1 := rosetta_g_miss_num_map(ddx_clev_ib_rec.object_version_number);
    p19_a2 := ddx_clev_ib_rec.sfwt_flag;
    p19_a3 := rosetta_g_miss_num_map(ddx_clev_ib_rec.chr_id);
    p19_a4 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cle_id);
    p19_a5 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cle_id_renewed);
    p19_a6 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cle_id_renewed_to);
    p19_a7 := rosetta_g_miss_num_map(ddx_clev_ib_rec.lse_id);
    p19_a8 := ddx_clev_ib_rec.line_number;
    p19_a9 := ddx_clev_ib_rec.sts_code;
    p19_a10 := rosetta_g_miss_num_map(ddx_clev_ib_rec.display_sequence);
    p19_a11 := ddx_clev_ib_rec.trn_code;
    p19_a12 := rosetta_g_miss_num_map(ddx_clev_ib_rec.dnz_chr_id);
    p19_a13 := ddx_clev_ib_rec.comments;
    p19_a14 := ddx_clev_ib_rec.item_description;
    p19_a15 := ddx_clev_ib_rec.oke_boe_description;
    p19_a16 := ddx_clev_ib_rec.cognomen;
    p19_a17 := ddx_clev_ib_rec.hidden_ind;
    p19_a18 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_unit);
    p19_a19 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_unit_percent);
    p19_a20 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_negotiated);
    p19_a21 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_negotiated_renewed);
    p19_a22 := ddx_clev_ib_rec.price_level_ind;
    p19_a23 := ddx_clev_ib_rec.invoice_line_level_ind;
    p19_a24 := ddx_clev_ib_rec.dpas_rating;
    p19_a25 := ddx_clev_ib_rec.block23text;
    p19_a26 := ddx_clev_ib_rec.exception_yn;
    p19_a27 := ddx_clev_ib_rec.template_used;
    p19_a28 := ddx_clev_ib_rec.date_terminated;
    p19_a29 := ddx_clev_ib_rec.name;
    p19_a30 := ddx_clev_ib_rec.start_date;
    p19_a31 := ddx_clev_ib_rec.end_date;
    p19_a32 := ddx_clev_ib_rec.date_renewed;
    p19_a33 := ddx_clev_ib_rec.upg_orig_system_ref;
    p19_a34 := rosetta_g_miss_num_map(ddx_clev_ib_rec.upg_orig_system_ref_id);
    p19_a35 := ddx_clev_ib_rec.orig_system_source_code;
    p19_a36 := rosetta_g_miss_num_map(ddx_clev_ib_rec.orig_system_id1);
    p19_a37 := ddx_clev_ib_rec.orig_system_reference1;
    p19_a38 := ddx_clev_ib_rec.attribute_category;
    p19_a39 := ddx_clev_ib_rec.attribute1;
    p19_a40 := ddx_clev_ib_rec.attribute2;
    p19_a41 := ddx_clev_ib_rec.attribute3;
    p19_a42 := ddx_clev_ib_rec.attribute4;
    p19_a43 := ddx_clev_ib_rec.attribute5;
    p19_a44 := ddx_clev_ib_rec.attribute6;
    p19_a45 := ddx_clev_ib_rec.attribute7;
    p19_a46 := ddx_clev_ib_rec.attribute8;
    p19_a47 := ddx_clev_ib_rec.attribute9;
    p19_a48 := ddx_clev_ib_rec.attribute10;
    p19_a49 := ddx_clev_ib_rec.attribute11;
    p19_a50 := ddx_clev_ib_rec.attribute12;
    p19_a51 := ddx_clev_ib_rec.attribute13;
    p19_a52 := ddx_clev_ib_rec.attribute14;
    p19_a53 := ddx_clev_ib_rec.attribute15;
    p19_a54 := rosetta_g_miss_num_map(ddx_clev_ib_rec.created_by);
    p19_a55 := ddx_clev_ib_rec.creation_date;
    p19_a56 := rosetta_g_miss_num_map(ddx_clev_ib_rec.last_updated_by);
    p19_a57 := ddx_clev_ib_rec.last_update_date;
    p19_a58 := ddx_clev_ib_rec.price_type;
    p19_a59 := ddx_clev_ib_rec.currency_code;
    p19_a60 := ddx_clev_ib_rec.currency_code_renewed;
    p19_a61 := rosetta_g_miss_num_map(ddx_clev_ib_rec.last_update_login);
    p19_a62 := ddx_clev_ib_rec.old_sts_code;
    p19_a63 := ddx_clev_ib_rec.new_sts_code;
    p19_a64 := ddx_clev_ib_rec.old_ste_code;
    p19_a65 := ddx_clev_ib_rec.new_ste_code;
    p19_a66 := ddx_clev_ib_rec.call_action_asmblr;
    p19_a67 := rosetta_g_miss_num_map(ddx_clev_ib_rec.request_id);
    p19_a68 := rosetta_g_miss_num_map(ddx_clev_ib_rec.program_application_id);
    p19_a69 := rosetta_g_miss_num_map(ddx_clev_ib_rec.program_id);
    p19_a70 := ddx_clev_ib_rec.program_update_date;
    p19_a71 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_list_id);
    p19_a72 := ddx_clev_ib_rec.pricing_date;
    p19_a73 := rosetta_g_miss_num_map(ddx_clev_ib_rec.price_list_line_id);
    p19_a74 := rosetta_g_miss_num_map(ddx_clev_ib_rec.line_list_price);
    p19_a75 := ddx_clev_ib_rec.item_to_price_yn;
    p19_a76 := ddx_clev_ib_rec.price_basis_yn;
    p19_a77 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_header_id);
    p19_a78 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_revision_number);
    p19_a79 := ddx_clev_ib_rec.config_complete_yn;
    p19_a80 := ddx_clev_ib_rec.config_valid_yn;
    p19_a81 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_top_model_line_id);
    p19_a82 := ddx_clev_ib_rec.config_item_type;
    p19_a83 := rosetta_g_miss_num_map(ddx_clev_ib_rec.config_item_id);
    p19_a84 := rosetta_g_miss_num_map(ddx_clev_ib_rec.cust_acct_id);
    p19_a85 := rosetta_g_miss_num_map(ddx_clev_ib_rec.bill_to_site_use_id);
    p19_a86 := rosetta_g_miss_num_map(ddx_clev_ib_rec.inv_rule_id);
    p19_a87 := ddx_clev_ib_rec.line_renewal_type_code;
    p19_a88 := rosetta_g_miss_num_map(ddx_clev_ib_rec.ship_to_site_use_id);
    p19_a89 := rosetta_g_miss_num_map(ddx_clev_ib_rec.payment_term_id);
  end;

  procedure create_ints_ib_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p_current_units  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_VARCHAR2_TABLE_100
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_VARCHAR2_TABLE_100
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_500
    , p9_a21 JTF_VARCHAR2_TABLE_500
    , p9_a22 JTF_VARCHAR2_TABLE_500
    , p9_a23 JTF_VARCHAR2_TABLE_500
    , p9_a24 JTF_VARCHAR2_TABLE_500
    , p9_a25 JTF_VARCHAR2_TABLE_500
    , p9_a26 JTF_VARCHAR2_TABLE_500
    , p9_a27 JTF_VARCHAR2_TABLE_500
    , p9_a28 JTF_VARCHAR2_TABLE_500
    , p9_a29 JTF_VARCHAR2_TABLE_500
    , p9_a30 JTF_VARCHAR2_TABLE_500
    , p9_a31 JTF_VARCHAR2_TABLE_500
    , p9_a32 JTF_VARCHAR2_TABLE_500
    , p9_a33 JTF_VARCHAR2_TABLE_500
    , p9_a34 JTF_VARCHAR2_TABLE_500
    , p9_a35 JTF_NUMBER_TABLE
    , p9_a36 JTF_DATE_TABLE
    , p9_a37 JTF_NUMBER_TABLE
    , p9_a38 JTF_DATE_TABLE
    , p9_a39 JTF_NUMBER_TABLE
    , p9_a40 JTF_NUMBER_TABLE
    , p9_a41 JTF_NUMBER_TABLE
    , p9_a42 JTF_VARCHAR2_TABLE_100
    , p9_a43 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a35 out nocopy JTF_NUMBER_TABLE
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_NUMBER_TABLE
    , p11_a38 out nocopy JTF_DATE_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_NUMBER_TABLE
    , p11_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a43 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  NUMBER
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  NUMBER
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  NUMBER
    , p12_a19 out nocopy  NUMBER
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  NUMBER
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  DATE
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  DATE
    , p12_a31 out nocopy  DATE
    , p12_a32 out nocopy  DATE
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , p12_a45 out nocopy  VARCHAR2
    , p12_a46 out nocopy  VARCHAR2
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  VARCHAR2
    , p12_a50 out nocopy  VARCHAR2
    , p12_a51 out nocopy  VARCHAR2
    , p12_a52 out nocopy  VARCHAR2
    , p12_a53 out nocopy  VARCHAR2
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  DATE
    , p12_a56 out nocopy  NUMBER
    , p12_a57 out nocopy  DATE
    , p12_a58 out nocopy  VARCHAR2
    , p12_a59 out nocopy  VARCHAR2
    , p12_a60 out nocopy  VARCHAR2
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  VARCHAR2
    , p12_a63 out nocopy  VARCHAR2
    , p12_a64 out nocopy  VARCHAR2
    , p12_a65 out nocopy  VARCHAR2
    , p12_a66 out nocopy  VARCHAR2
    , p12_a67 out nocopy  NUMBER
    , p12_a68 out nocopy  NUMBER
    , p12_a69 out nocopy  NUMBER
    , p12_a70 out nocopy  DATE
    , p12_a71 out nocopy  NUMBER
    , p12_a72 out nocopy  DATE
    , p12_a73 out nocopy  NUMBER
    , p12_a74 out nocopy  NUMBER
    , p12_a75 out nocopy  VARCHAR2
    , p12_a76 out nocopy  VARCHAR2
    , p12_a77 out nocopy  NUMBER
    , p12_a78 out nocopy  NUMBER
    , p12_a79 out nocopy  VARCHAR2
    , p12_a80 out nocopy  VARCHAR2
    , p12_a81 out nocopy  NUMBER
    , p12_a82 out nocopy  VARCHAR2
    , p12_a83 out nocopy  NUMBER
    , p12_a84 out nocopy  NUMBER
    , p12_a85 out nocopy  NUMBER
    , p12_a86 out nocopy  NUMBER
    , p12_a87 out nocopy  VARCHAR2
    , p12_a88 out nocopy  NUMBER
    , p12_a89 out nocopy  NUMBER
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  VARCHAR2
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  NUMBER
    , p13_a8 out nocopy  NUMBER
    , p13_a9 out nocopy  DATE
    , p13_a10 out nocopy  NUMBER
    , p13_a11 out nocopy  NUMBER
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  NUMBER
    , p13_a14 out nocopy  NUMBER
    , p13_a15 out nocopy  NUMBER
    , p13_a16 out nocopy  NUMBER
    , p13_a17 out nocopy  NUMBER
    , p13_a18 out nocopy  NUMBER
    , p13_a19 out nocopy  NUMBER
    , p13_a20 out nocopy  DATE
    , p13_a21 out nocopy  DATE
    , p13_a22 out nocopy  NUMBER
    , p13_a23 out nocopy  NUMBER
    , p13_a24 out nocopy  DATE
    , p13_a25 out nocopy  DATE
    , p13_a26 out nocopy  DATE
    , p13_a27 out nocopy  NUMBER
    , p13_a28 out nocopy  NUMBER
    , p13_a29 out nocopy  NUMBER
    , p13_a30 out nocopy  NUMBER
    , p13_a31 out nocopy  NUMBER
    , p13_a32 out nocopy  NUMBER
    , p13_a33 out nocopy  NUMBER
    , p13_a34 out nocopy  DATE
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  DATE
    , p13_a37 out nocopy  VARCHAR2
    , p13_a38 out nocopy  NUMBER
    , p13_a39 out nocopy  NUMBER
    , p13_a40 out nocopy  NUMBER
    , p13_a41 out nocopy  VARCHAR2
    , p13_a42 out nocopy  DATE
    , p13_a43 out nocopy  NUMBER
    , p13_a44 out nocopy  NUMBER
    , p13_a45 out nocopy  DATE
    , p13_a46 out nocopy  NUMBER
    , p13_a47 out nocopy  DATE
    , p13_a48 out nocopy  DATE
    , p13_a49 out nocopy  DATE
    , p13_a50 out nocopy  NUMBER
    , p13_a51 out nocopy  NUMBER
    , p13_a52 out nocopy  VARCHAR2
    , p13_a53 out nocopy  NUMBER
    , p13_a54 out nocopy  NUMBER
    , p13_a55 out nocopy  VARCHAR2
    , p13_a56 out nocopy  VARCHAR2
    , p13_a57 out nocopy  NUMBER
    , p13_a58 out nocopy  DATE
    , p13_a59 out nocopy  NUMBER
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  VARCHAR2
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p13_a66 out nocopy  VARCHAR2
    , p13_a67 out nocopy  VARCHAR2
    , p13_a68 out nocopy  VARCHAR2
    , p13_a69 out nocopy  VARCHAR2
    , p13_a70 out nocopy  VARCHAR2
    , p13_a71 out nocopy  VARCHAR2
    , p13_a72 out nocopy  VARCHAR2
    , p13_a73 out nocopy  VARCHAR2
    , p13_a74 out nocopy  VARCHAR2
    , p13_a75 out nocopy  VARCHAR2
    , p13_a76 out nocopy  NUMBER
    , p13_a77 out nocopy  NUMBER
    , p13_a78 out nocopy  NUMBER
    , p13_a79 out nocopy  DATE
    , p13_a80 out nocopy  NUMBER
    , p13_a81 out nocopy  DATE
    , p13_a82 out nocopy  NUMBER
    , p13_a83 out nocopy  DATE
    , p13_a84 out nocopy  DATE
    , p13_a85 out nocopy  DATE
    , p13_a86 out nocopy  DATE
    , p13_a87 out nocopy  NUMBER
    , p13_a88 out nocopy  NUMBER
    , p13_a89 out nocopy  NUMBER
    , p13_a90 out nocopy  VARCHAR2
    , p13_a91 out nocopy  NUMBER
    , p13_a92 out nocopy  VARCHAR2
    , p13_a93 out nocopy  NUMBER
    , p13_a94 out nocopy  NUMBER
    , p13_a95 out nocopy  DATE
    , p13_a96 out nocopy  VARCHAR2
    , p13_a97 out nocopy  VARCHAR2
    , p13_a98 out nocopy  NUMBER
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  NUMBER
    , p14_a2 out nocopy  NUMBER
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  NUMBER
    , p14_a5 out nocopy  NUMBER
    , p14_a6 out nocopy  VARCHAR2
    , p14_a7 out nocopy  VARCHAR2
    , p14_a8 out nocopy  VARCHAR2
    , p14_a9 out nocopy  VARCHAR2
    , p14_a10 out nocopy  VARCHAR2
    , p14_a11 out nocopy  NUMBER
    , p14_a12 out nocopy  VARCHAR2
    , p14_a13 out nocopy  NUMBER
    , p14_a14 out nocopy  VARCHAR2
    , p14_a15 out nocopy  NUMBER
    , p14_a16 out nocopy  DATE
    , p14_a17 out nocopy  NUMBER
    , p14_a18 out nocopy  DATE
    , p14_a19 out nocopy  NUMBER
    , p15_a0 out nocopy  NUMBER
    , p15_a1 out nocopy  NUMBER
    , p15_a2 out nocopy  NUMBER
    , p15_a3 out nocopy  NUMBER
    , p15_a4 out nocopy  NUMBER
    , p15_a5 out nocopy  NUMBER
    , p15_a6 out nocopy  VARCHAR2
    , p15_a7 out nocopy  VARCHAR2
    , p15_a8 out nocopy  VARCHAR2
    , p15_a9 out nocopy  VARCHAR2
    , p15_a10 out nocopy  VARCHAR2
    , p15_a11 out nocopy  NUMBER
    , p15_a12 out nocopy  VARCHAR2
    , p15_a13 out nocopy  NUMBER
    , p15_a14 out nocopy  VARCHAR2
    , p15_a15 out nocopy  NUMBER
    , p15_a16 out nocopy  DATE
    , p15_a17 out nocopy  NUMBER
    , p15_a18 out nocopy  DATE
    , p15_a19 out nocopy  NUMBER
    , p16_a0 out nocopy  NUMBER
    , p16_a1 out nocopy  NUMBER
    , p16_a2 out nocopy  VARCHAR2
    , p16_a3 out nocopy  NUMBER
    , p16_a4 out nocopy  NUMBER
    , p16_a5 out nocopy  NUMBER
    , p16_a6 out nocopy  NUMBER
    , p16_a7 out nocopy  NUMBER
    , p16_a8 out nocopy  NUMBER
    , p16_a9 out nocopy  NUMBER
    , p16_a10 out nocopy  NUMBER
    , p16_a11 out nocopy  NUMBER
    , p16_a12 out nocopy  VARCHAR2
    , p16_a13 out nocopy  VARCHAR2
    , p16_a14 out nocopy  VARCHAR2
    , p16_a15 out nocopy  NUMBER
    , p16_a16 out nocopy  NUMBER
    , p16_a17 out nocopy  NUMBER
    , p16_a18 out nocopy  VARCHAR2
    , p16_a19 out nocopy  NUMBER
    , p16_a20 out nocopy  NUMBER
    , p16_a21 out nocopy  VARCHAR2
    , p16_a22 out nocopy  VARCHAR2
    , p16_a23 out nocopy  VARCHAR2
    , p16_a24 out nocopy  VARCHAR2
    , p16_a25 out nocopy  DATE
    , p16_a26 out nocopy  DATE
    , p16_a27 out nocopy  DATE
    , p16_a28 out nocopy  NUMBER
    , p16_a29 out nocopy  NUMBER
    , p16_a30 out nocopy  NUMBER
    , p16_a31 out nocopy  VARCHAR2
    , p16_a32 out nocopy  NUMBER
    , p16_a33 out nocopy  NUMBER
    , p16_a34 out nocopy  NUMBER
    , p16_a35 out nocopy  NUMBER
    , p16_a36 out nocopy  VARCHAR2
    , p16_a37 out nocopy  VARCHAR2
    , p16_a38 out nocopy  VARCHAR2
    , p16_a39 out nocopy  VARCHAR2
    , p16_a40 out nocopy  VARCHAR2
    , p16_a41 out nocopy  VARCHAR2
    , p16_a42 out nocopy  VARCHAR2
    , p16_a43 out nocopy  VARCHAR2
    , p16_a44 out nocopy  VARCHAR2
    , p16_a45 out nocopy  VARCHAR2
    , p16_a46 out nocopy  VARCHAR2
    , p16_a47 out nocopy  VARCHAR2
    , p16_a48 out nocopy  VARCHAR2
    , p16_a49 out nocopy  VARCHAR2
    , p16_a50 out nocopy  VARCHAR2
    , p16_a51 out nocopy  VARCHAR2
    , p16_a52 out nocopy  NUMBER
    , p16_a53 out nocopy  DATE
    , p16_a54 out nocopy  NUMBER
    , p16_a55 out nocopy  DATE
    , p16_a56 out nocopy  NUMBER
    , p16_a57 out nocopy  VARCHAR2
    , p16_a58 out nocopy  NUMBER
    , p16_a59 out nocopy  NUMBER
    , p16_a60 out nocopy  NUMBER
    , p16_a61 out nocopy  NUMBER
    , p16_a62 out nocopy  NUMBER
    , p16_a63 out nocopy  NUMBER
    , p16_a64 out nocopy  NUMBER
    , p16_a65 out nocopy  NUMBER
    , p16_a66 out nocopy  NUMBER
    , p16_a67 out nocopy  DATE
    , p16_a68 out nocopy  NUMBER
    , p16_a69 out nocopy  NUMBER
    , p16_a70 out nocopy  NUMBER
    , p16_a71 out nocopy  VARCHAR2
    , p16_a72 out nocopy  NUMBER
    , p16_a73 out nocopy  VARCHAR2
    , p16_a74 out nocopy  VARCHAR2
    , p16_a75 out nocopy  NUMBER
    , p16_a76 out nocopy  DATE
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  NUMBER := 0-1962.0724
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  DATE := fnd_api.g_miss_date
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  DATE := fnd_api.g_miss_date
    , p8_a31  DATE := fnd_api.g_miss_date
    , p8_a32  DATE := fnd_api.g_miss_date
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  NUMBER := 0-1962.0724
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
    , p8_a43  VARCHAR2 := fnd_api.g_miss_char
    , p8_a44  VARCHAR2 := fnd_api.g_miss_char
    , p8_a45  VARCHAR2 := fnd_api.g_miss_char
    , p8_a46  VARCHAR2 := fnd_api.g_miss_char
    , p8_a47  VARCHAR2 := fnd_api.g_miss_char
    , p8_a48  VARCHAR2 := fnd_api.g_miss_char
    , p8_a49  VARCHAR2 := fnd_api.g_miss_char
    , p8_a50  VARCHAR2 := fnd_api.g_miss_char
    , p8_a51  VARCHAR2 := fnd_api.g_miss_char
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  VARCHAR2 := fnd_api.g_miss_char
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  DATE := fnd_api.g_miss_date
    , p8_a56  NUMBER := 0-1962.0724
    , p8_a57  DATE := fnd_api.g_miss_date
    , p8_a58  VARCHAR2 := fnd_api.g_miss_char
    , p8_a59  VARCHAR2 := fnd_api.g_miss_char
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  NUMBER := 0-1962.0724
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  NUMBER := 0-1962.0724
    , p8_a68  NUMBER := 0-1962.0724
    , p8_a69  NUMBER := 0-1962.0724
    , p8_a70  DATE := fnd_api.g_miss_date
    , p8_a71  NUMBER := 0-1962.0724
    , p8_a72  DATE := fnd_api.g_miss_date
    , p8_a73  NUMBER := 0-1962.0724
    , p8_a74  NUMBER := 0-1962.0724
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  VARCHAR2 := fnd_api.g_miss_char
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  VARCHAR2 := fnd_api.g_miss_char
    , p8_a80  VARCHAR2 := fnd_api.g_miss_char
    , p8_a81  NUMBER := 0-1962.0724
    , p8_a82  VARCHAR2 := fnd_api.g_miss_char
    , p8_a83  NUMBER := 0-1962.0724
    , p8_a84  NUMBER := 0-1962.0724
    , p8_a85  NUMBER := 0-1962.0724
    , p8_a86  NUMBER := 0-1962.0724
    , p8_a87  VARCHAR2 := fnd_api.g_miss_char
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_ib_rec okl_create_kle_pub.clev_rec_type;
    ddp_itiv_ib_tbl okl_create_kle_pub.itiv_tbl_type;
    ddx_clev_ib_tbl okl_create_kle_pub.clev_tbl_type;
    ddx_itiv_ib_tbl okl_create_kle_pub.itiv_tbl_type;
    ddx_clev_fin_rec okl_create_kle_pub.clev_rec_type;
    ddx_klev_fin_rec okl_create_kle_pub.klev_rec_type;
    ddx_cimv_model_rec okl_create_kle_pub.cimv_rec_type;
    ddx_cimv_fa_rec okl_create_kle_pub.cimv_rec_type;
    ddx_talv_fa_rec okl_create_kle_pub.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_clev_ib_rec.id := rosetta_g_miss_num_map(p8_a0);
    ddp_clev_ib_rec.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_clev_ib_rec.sfwt_flag := p8_a2;
    ddp_clev_ib_rec.chr_id := rosetta_g_miss_num_map(p8_a3);
    ddp_clev_ib_rec.cle_id := rosetta_g_miss_num_map(p8_a4);
    ddp_clev_ib_rec.cle_id_renewed := rosetta_g_miss_num_map(p8_a5);
    ddp_clev_ib_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p8_a6);
    ddp_clev_ib_rec.lse_id := rosetta_g_miss_num_map(p8_a7);
    ddp_clev_ib_rec.line_number := p8_a8;
    ddp_clev_ib_rec.sts_code := p8_a9;
    ddp_clev_ib_rec.display_sequence := rosetta_g_miss_num_map(p8_a10);
    ddp_clev_ib_rec.trn_code := p8_a11;
    ddp_clev_ib_rec.dnz_chr_id := rosetta_g_miss_num_map(p8_a12);
    ddp_clev_ib_rec.comments := p8_a13;
    ddp_clev_ib_rec.item_description := p8_a14;
    ddp_clev_ib_rec.oke_boe_description := p8_a15;
    ddp_clev_ib_rec.cognomen := p8_a16;
    ddp_clev_ib_rec.hidden_ind := p8_a17;
    ddp_clev_ib_rec.price_unit := rosetta_g_miss_num_map(p8_a18);
    ddp_clev_ib_rec.price_unit_percent := rosetta_g_miss_num_map(p8_a19);
    ddp_clev_ib_rec.price_negotiated := rosetta_g_miss_num_map(p8_a20);
    ddp_clev_ib_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p8_a21);
    ddp_clev_ib_rec.price_level_ind := p8_a22;
    ddp_clev_ib_rec.invoice_line_level_ind := p8_a23;
    ddp_clev_ib_rec.dpas_rating := p8_a24;
    ddp_clev_ib_rec.block23text := p8_a25;
    ddp_clev_ib_rec.exception_yn := p8_a26;
    ddp_clev_ib_rec.template_used := p8_a27;
    ddp_clev_ib_rec.date_terminated := rosetta_g_miss_date_in_map(p8_a28);
    ddp_clev_ib_rec.name := p8_a29;
    ddp_clev_ib_rec.start_date := rosetta_g_miss_date_in_map(p8_a30);
    ddp_clev_ib_rec.end_date := rosetta_g_miss_date_in_map(p8_a31);
    ddp_clev_ib_rec.date_renewed := rosetta_g_miss_date_in_map(p8_a32);
    ddp_clev_ib_rec.upg_orig_system_ref := p8_a33;
    ddp_clev_ib_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p8_a34);
    ddp_clev_ib_rec.orig_system_source_code := p8_a35;
    ddp_clev_ib_rec.orig_system_id1 := rosetta_g_miss_num_map(p8_a36);
    ddp_clev_ib_rec.orig_system_reference1 := p8_a37;
    ddp_clev_ib_rec.attribute_category := p8_a38;
    ddp_clev_ib_rec.attribute1 := p8_a39;
    ddp_clev_ib_rec.attribute2 := p8_a40;
    ddp_clev_ib_rec.attribute3 := p8_a41;
    ddp_clev_ib_rec.attribute4 := p8_a42;
    ddp_clev_ib_rec.attribute5 := p8_a43;
    ddp_clev_ib_rec.attribute6 := p8_a44;
    ddp_clev_ib_rec.attribute7 := p8_a45;
    ddp_clev_ib_rec.attribute8 := p8_a46;
    ddp_clev_ib_rec.attribute9 := p8_a47;
    ddp_clev_ib_rec.attribute10 := p8_a48;
    ddp_clev_ib_rec.attribute11 := p8_a49;
    ddp_clev_ib_rec.attribute12 := p8_a50;
    ddp_clev_ib_rec.attribute13 := p8_a51;
    ddp_clev_ib_rec.attribute14 := p8_a52;
    ddp_clev_ib_rec.attribute15 := p8_a53;
    ddp_clev_ib_rec.created_by := rosetta_g_miss_num_map(p8_a54);
    ddp_clev_ib_rec.creation_date := rosetta_g_miss_date_in_map(p8_a55);
    ddp_clev_ib_rec.last_updated_by := rosetta_g_miss_num_map(p8_a56);
    ddp_clev_ib_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a57);
    ddp_clev_ib_rec.price_type := p8_a58;
    ddp_clev_ib_rec.currency_code := p8_a59;
    ddp_clev_ib_rec.currency_code_renewed := p8_a60;
    ddp_clev_ib_rec.last_update_login := rosetta_g_miss_num_map(p8_a61);
    ddp_clev_ib_rec.old_sts_code := p8_a62;
    ddp_clev_ib_rec.new_sts_code := p8_a63;
    ddp_clev_ib_rec.old_ste_code := p8_a64;
    ddp_clev_ib_rec.new_ste_code := p8_a65;
    ddp_clev_ib_rec.call_action_asmblr := p8_a66;
    ddp_clev_ib_rec.request_id := rosetta_g_miss_num_map(p8_a67);
    ddp_clev_ib_rec.program_application_id := rosetta_g_miss_num_map(p8_a68);
    ddp_clev_ib_rec.program_id := rosetta_g_miss_num_map(p8_a69);
    ddp_clev_ib_rec.program_update_date := rosetta_g_miss_date_in_map(p8_a70);
    ddp_clev_ib_rec.price_list_id := rosetta_g_miss_num_map(p8_a71);
    ddp_clev_ib_rec.pricing_date := rosetta_g_miss_date_in_map(p8_a72);
    ddp_clev_ib_rec.price_list_line_id := rosetta_g_miss_num_map(p8_a73);
    ddp_clev_ib_rec.line_list_price := rosetta_g_miss_num_map(p8_a74);
    ddp_clev_ib_rec.item_to_price_yn := p8_a75;
    ddp_clev_ib_rec.price_basis_yn := p8_a76;
    ddp_clev_ib_rec.config_header_id := rosetta_g_miss_num_map(p8_a77);
    ddp_clev_ib_rec.config_revision_number := rosetta_g_miss_num_map(p8_a78);
    ddp_clev_ib_rec.config_complete_yn := p8_a79;
    ddp_clev_ib_rec.config_valid_yn := p8_a80;
    ddp_clev_ib_rec.config_top_model_line_id := rosetta_g_miss_num_map(p8_a81);
    ddp_clev_ib_rec.config_item_type := p8_a82;
    ddp_clev_ib_rec.config_item_id := rosetta_g_miss_num_map(p8_a83);
    ddp_clev_ib_rec.cust_acct_id := rosetta_g_miss_num_map(p8_a84);
    ddp_clev_ib_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p8_a85);
    ddp_clev_ib_rec.inv_rule_id := rosetta_g_miss_num_map(p8_a86);
    ddp_clev_ib_rec.line_renewal_type_code := p8_a87;
    ddp_clev_ib_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p8_a88);
    ddp_clev_ib_rec.payment_term_id := rosetta_g_miss_num_map(p8_a89);

    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_itiv_ib_tbl, p9_a0
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
      , p9_a42
      , p9_a43
      );








    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.create_ints_ib_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      p_current_units,
      ddp_clev_ib_rec,
      ddp_itiv_ib_tbl,
      ddx_clev_ib_tbl,
      ddx_itiv_ib_tbl,
      ddx_clev_fin_rec,
      ddx_klev_fin_rec,
      ddx_cimv_model_rec,
      ddx_cimv_fa_rec,
      ddx_talv_fa_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_ib_tbl, p10_a0
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
      , p10_a58
      , p10_a59
      , p10_a60
      , p10_a61
      , p10_a62
      , p10_a63
      , p10_a64
      , p10_a65
      , p10_a66
      , p10_a67
      , p10_a68
      , p10_a69
      , p10_a70
      , p10_a71
      , p10_a72
      , p10_a73
      , p10_a74
      , p10_a75
      , p10_a76
      , p10_a77
      , p10_a78
      , p10_a79
      , p10_a80
      , p10_a81
      , p10_a82
      , p10_a83
      , p10_a84
      , p10_a85
      , p10_a86
      , p10_a87
      , p10_a88
      , p10_a89
      );

    okl_iti_pvt_w.rosetta_table_copy_out_p5(ddx_itiv_ib_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      );

    p12_a0 := rosetta_g_miss_num_map(ddx_clev_fin_rec.id);
    p12_a1 := rosetta_g_miss_num_map(ddx_clev_fin_rec.object_version_number);
    p12_a2 := ddx_clev_fin_rec.sfwt_flag;
    p12_a3 := rosetta_g_miss_num_map(ddx_clev_fin_rec.chr_id);
    p12_a4 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id);
    p12_a5 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed);
    p12_a6 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed_to);
    p12_a7 := rosetta_g_miss_num_map(ddx_clev_fin_rec.lse_id);
    p12_a8 := ddx_clev_fin_rec.line_number;
    p12_a9 := ddx_clev_fin_rec.sts_code;
    p12_a10 := rosetta_g_miss_num_map(ddx_clev_fin_rec.display_sequence);
    p12_a11 := ddx_clev_fin_rec.trn_code;
    p12_a12 := rosetta_g_miss_num_map(ddx_clev_fin_rec.dnz_chr_id);
    p12_a13 := ddx_clev_fin_rec.comments;
    p12_a14 := ddx_clev_fin_rec.item_description;
    p12_a15 := ddx_clev_fin_rec.oke_boe_description;
    p12_a16 := ddx_clev_fin_rec.cognomen;
    p12_a17 := ddx_clev_fin_rec.hidden_ind;
    p12_a18 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit);
    p12_a19 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit_percent);
    p12_a20 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated);
    p12_a21 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated_renewed);
    p12_a22 := ddx_clev_fin_rec.price_level_ind;
    p12_a23 := ddx_clev_fin_rec.invoice_line_level_ind;
    p12_a24 := ddx_clev_fin_rec.dpas_rating;
    p12_a25 := ddx_clev_fin_rec.block23text;
    p12_a26 := ddx_clev_fin_rec.exception_yn;
    p12_a27 := ddx_clev_fin_rec.template_used;
    p12_a28 := ddx_clev_fin_rec.date_terminated;
    p12_a29 := ddx_clev_fin_rec.name;
    p12_a30 := ddx_clev_fin_rec.start_date;
    p12_a31 := ddx_clev_fin_rec.end_date;
    p12_a32 := ddx_clev_fin_rec.date_renewed;
    p12_a33 := ddx_clev_fin_rec.upg_orig_system_ref;
    p12_a34 := rosetta_g_miss_num_map(ddx_clev_fin_rec.upg_orig_system_ref_id);
    p12_a35 := ddx_clev_fin_rec.orig_system_source_code;
    p12_a36 := rosetta_g_miss_num_map(ddx_clev_fin_rec.orig_system_id1);
    p12_a37 := ddx_clev_fin_rec.orig_system_reference1;
    p12_a38 := ddx_clev_fin_rec.attribute_category;
    p12_a39 := ddx_clev_fin_rec.attribute1;
    p12_a40 := ddx_clev_fin_rec.attribute2;
    p12_a41 := ddx_clev_fin_rec.attribute3;
    p12_a42 := ddx_clev_fin_rec.attribute4;
    p12_a43 := ddx_clev_fin_rec.attribute5;
    p12_a44 := ddx_clev_fin_rec.attribute6;
    p12_a45 := ddx_clev_fin_rec.attribute7;
    p12_a46 := ddx_clev_fin_rec.attribute8;
    p12_a47 := ddx_clev_fin_rec.attribute9;
    p12_a48 := ddx_clev_fin_rec.attribute10;
    p12_a49 := ddx_clev_fin_rec.attribute11;
    p12_a50 := ddx_clev_fin_rec.attribute12;
    p12_a51 := ddx_clev_fin_rec.attribute13;
    p12_a52 := ddx_clev_fin_rec.attribute14;
    p12_a53 := ddx_clev_fin_rec.attribute15;
    p12_a54 := rosetta_g_miss_num_map(ddx_clev_fin_rec.created_by);
    p12_a55 := ddx_clev_fin_rec.creation_date;
    p12_a56 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_updated_by);
    p12_a57 := ddx_clev_fin_rec.last_update_date;
    p12_a58 := ddx_clev_fin_rec.price_type;
    p12_a59 := ddx_clev_fin_rec.currency_code;
    p12_a60 := ddx_clev_fin_rec.currency_code_renewed;
    p12_a61 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_update_login);
    p12_a62 := ddx_clev_fin_rec.old_sts_code;
    p12_a63 := ddx_clev_fin_rec.new_sts_code;
    p12_a64 := ddx_clev_fin_rec.old_ste_code;
    p12_a65 := ddx_clev_fin_rec.new_ste_code;
    p12_a66 := ddx_clev_fin_rec.call_action_asmblr;
    p12_a67 := rosetta_g_miss_num_map(ddx_clev_fin_rec.request_id);
    p12_a68 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_application_id);
    p12_a69 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_id);
    p12_a70 := ddx_clev_fin_rec.program_update_date;
    p12_a71 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_id);
    p12_a72 := ddx_clev_fin_rec.pricing_date;
    p12_a73 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_line_id);
    p12_a74 := rosetta_g_miss_num_map(ddx_clev_fin_rec.line_list_price);
    p12_a75 := ddx_clev_fin_rec.item_to_price_yn;
    p12_a76 := ddx_clev_fin_rec.price_basis_yn;
    p12_a77 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_header_id);
    p12_a78 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_revision_number);
    p12_a79 := ddx_clev_fin_rec.config_complete_yn;
    p12_a80 := ddx_clev_fin_rec.config_valid_yn;
    p12_a81 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_top_model_line_id);
    p12_a82 := ddx_clev_fin_rec.config_item_type;
    p12_a83 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_item_id);
    p12_a84 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cust_acct_id);
    p12_a85 := rosetta_g_miss_num_map(ddx_clev_fin_rec.bill_to_site_use_id);
    p12_a86 := rosetta_g_miss_num_map(ddx_clev_fin_rec.inv_rule_id);
    p12_a87 := ddx_clev_fin_rec.line_renewal_type_code;
    p12_a88 := rosetta_g_miss_num_map(ddx_clev_fin_rec.ship_to_site_use_id);
    p12_a89 := rosetta_g_miss_num_map(ddx_clev_fin_rec.payment_term_id);

    p13_a0 := rosetta_g_miss_num_map(ddx_klev_fin_rec.id);
    p13_a1 := rosetta_g_miss_num_map(ddx_klev_fin_rec.object_version_number);
    p13_a2 := rosetta_g_miss_num_map(ddx_klev_fin_rec.kle_id);
    p13_a3 := rosetta_g_miss_num_map(ddx_klev_fin_rec.sty_id);
    p13_a4 := ddx_klev_fin_rec.prc_code;
    p13_a5 := ddx_klev_fin_rec.fcg_code;
    p13_a6 := ddx_klev_fin_rec.nty_code;
    p13_a7 := rosetta_g_miss_num_map(ddx_klev_fin_rec.estimated_oec);
    p13_a8 := rosetta_g_miss_num_map(ddx_klev_fin_rec.lao_amount);
    p13_a9 := ddx_klev_fin_rec.title_date;
    p13_a10 := rosetta_g_miss_num_map(ddx_klev_fin_rec.fee_charge);
    p13_a11 := rosetta_g_miss_num_map(ddx_klev_fin_rec.lrs_percent);
    p13_a12 := rosetta_g_miss_num_map(ddx_klev_fin_rec.initial_direct_cost);
    p13_a13 := rosetta_g_miss_num_map(ddx_klev_fin_rec.percent_stake);
    p13_a14 := rosetta_g_miss_num_map(ddx_klev_fin_rec.percent);
    p13_a15 := rosetta_g_miss_num_map(ddx_klev_fin_rec.evergreen_percent);
    p13_a16 := rosetta_g_miss_num_map(ddx_klev_fin_rec.amount_stake);
    p13_a17 := rosetta_g_miss_num_map(ddx_klev_fin_rec.occupancy);
    p13_a18 := rosetta_g_miss_num_map(ddx_klev_fin_rec.coverage);
    p13_a19 := rosetta_g_miss_num_map(ddx_klev_fin_rec.residual_percentage);
    p13_a20 := ddx_klev_fin_rec.date_last_inspection;
    p13_a21 := ddx_klev_fin_rec.date_sold;
    p13_a22 := rosetta_g_miss_num_map(ddx_klev_fin_rec.lrv_amount);
    p13_a23 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capital_reduction);
    p13_a24 := ddx_klev_fin_rec.date_next_inspection_due;
    p13_a25 := ddx_klev_fin_rec.date_residual_last_review;
    p13_a26 := ddx_klev_fin_rec.date_last_reamortisation;
    p13_a27 := rosetta_g_miss_num_map(ddx_klev_fin_rec.vendor_advance_paid);
    p13_a28 := rosetta_g_miss_num_map(ddx_klev_fin_rec.weighted_average_life);
    p13_a29 := rosetta_g_miss_num_map(ddx_klev_fin_rec.tradein_amount);
    p13_a30 := rosetta_g_miss_num_map(ddx_klev_fin_rec.bond_equivalent_yield);
    p13_a31 := rosetta_g_miss_num_map(ddx_klev_fin_rec.termination_purchase_amount);
    p13_a32 := rosetta_g_miss_num_map(ddx_klev_fin_rec.refinance_amount);
    p13_a33 := rosetta_g_miss_num_map(ddx_klev_fin_rec.year_built);
    p13_a34 := ddx_klev_fin_rec.delivered_date;
    p13_a35 := ddx_klev_fin_rec.credit_tenant_yn;
    p13_a36 := ddx_klev_fin_rec.date_last_cleanup;
    p13_a37 := ddx_klev_fin_rec.year_of_manufacture;
    p13_a38 := rosetta_g_miss_num_map(ddx_klev_fin_rec.coverage_ratio);
    p13_a39 := rosetta_g_miss_num_map(ddx_klev_fin_rec.remarketed_amount);
    p13_a40 := rosetta_g_miss_num_map(ddx_klev_fin_rec.gross_square_footage);
    p13_a41 := ddx_klev_fin_rec.prescribed_asset_yn;
    p13_a42 := ddx_klev_fin_rec.date_remarketed;
    p13_a43 := rosetta_g_miss_num_map(ddx_klev_fin_rec.net_rentable);
    p13_a44 := rosetta_g_miss_num_map(ddx_klev_fin_rec.remarket_margin);
    p13_a45 := ddx_klev_fin_rec.date_letter_acceptance;
    p13_a46 := rosetta_g_miss_num_map(ddx_klev_fin_rec.repurchased_amount);
    p13_a47 := ddx_klev_fin_rec.date_commitment_expiration;
    p13_a48 := ddx_klev_fin_rec.date_repurchased;
    p13_a49 := ddx_klev_fin_rec.date_appraisal;
    p13_a50 := rosetta_g_miss_num_map(ddx_klev_fin_rec.residual_value);
    p13_a51 := rosetta_g_miss_num_map(ddx_klev_fin_rec.appraisal_value);
    p13_a52 := ddx_klev_fin_rec.secured_deal_yn;
    p13_a53 := rosetta_g_miss_num_map(ddx_klev_fin_rec.gain_loss);
    p13_a54 := rosetta_g_miss_num_map(ddx_klev_fin_rec.floor_amount);
    p13_a55 := ddx_klev_fin_rec.re_lease_yn;
    p13_a56 := ddx_klev_fin_rec.previous_contract;
    p13_a57 := rosetta_g_miss_num_map(ddx_klev_fin_rec.tracked_residual);
    p13_a58 := ddx_klev_fin_rec.date_title_received;
    p13_a59 := rosetta_g_miss_num_map(ddx_klev_fin_rec.amount);
    p13_a60 := ddx_klev_fin_rec.attribute_category;
    p13_a61 := ddx_klev_fin_rec.attribute1;
    p13_a62 := ddx_klev_fin_rec.attribute2;
    p13_a63 := ddx_klev_fin_rec.attribute3;
    p13_a64 := ddx_klev_fin_rec.attribute4;
    p13_a65 := ddx_klev_fin_rec.attribute5;
    p13_a66 := ddx_klev_fin_rec.attribute6;
    p13_a67 := ddx_klev_fin_rec.attribute7;
    p13_a68 := ddx_klev_fin_rec.attribute8;
    p13_a69 := ddx_klev_fin_rec.attribute9;
    p13_a70 := ddx_klev_fin_rec.attribute10;
    p13_a71 := ddx_klev_fin_rec.attribute11;
    p13_a72 := ddx_klev_fin_rec.attribute12;
    p13_a73 := ddx_klev_fin_rec.attribute13;
    p13_a74 := ddx_klev_fin_rec.attribute14;
    p13_a75 := ddx_klev_fin_rec.attribute15;
    p13_a76 := rosetta_g_miss_num_map(ddx_klev_fin_rec.sty_id_for);
    p13_a77 := rosetta_g_miss_num_map(ddx_klev_fin_rec.clg_id);
    p13_a78 := rosetta_g_miss_num_map(ddx_klev_fin_rec.created_by);
    p13_a79 := ddx_klev_fin_rec.creation_date;
    p13_a80 := rosetta_g_miss_num_map(ddx_klev_fin_rec.last_updated_by);
    p13_a81 := ddx_klev_fin_rec.last_update_date;
    p13_a82 := rosetta_g_miss_num_map(ddx_klev_fin_rec.last_update_login);
    p13_a83 := ddx_klev_fin_rec.date_funding;
    p13_a84 := ddx_klev_fin_rec.date_funding_required;
    p13_a85 := ddx_klev_fin_rec.date_accepted;
    p13_a86 := ddx_klev_fin_rec.date_delivery_expected;
    p13_a87 := rosetta_g_miss_num_map(ddx_klev_fin_rec.oec);
    p13_a88 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capital_amount);
    p13_a89 := rosetta_g_miss_num_map(ddx_klev_fin_rec.residual_grnty_amount);
    p13_a90 := ddx_klev_fin_rec.residual_code;
    p13_a91 := rosetta_g_miss_num_map(ddx_klev_fin_rec.rvi_premium);
    p13_a92 := ddx_klev_fin_rec.credit_nature;
    p13_a93 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capitalized_interest);
    p13_a94 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capital_reduction_percent);
    p13_a95 := ddx_klev_fin_rec.date_pay_investor_start;
    p13_a96 := ddx_klev_fin_rec.pay_investor_frequency;
    p13_a97 := ddx_klev_fin_rec.pay_investor_event;
    p13_a98 := rosetta_g_miss_num_map(ddx_klev_fin_rec.pay_investor_remittance_days);

    p14_a0 := rosetta_g_miss_num_map(ddx_cimv_model_rec.id);
    p14_a1 := rosetta_g_miss_num_map(ddx_cimv_model_rec.object_version_number);
    p14_a2 := rosetta_g_miss_num_map(ddx_cimv_model_rec.cle_id);
    p14_a3 := rosetta_g_miss_num_map(ddx_cimv_model_rec.chr_id);
    p14_a4 := rosetta_g_miss_num_map(ddx_cimv_model_rec.cle_id_for);
    p14_a5 := rosetta_g_miss_num_map(ddx_cimv_model_rec.dnz_chr_id);
    p14_a6 := ddx_cimv_model_rec.object1_id1;
    p14_a7 := ddx_cimv_model_rec.object1_id2;
    p14_a8 := ddx_cimv_model_rec.jtot_object1_code;
    p14_a9 := ddx_cimv_model_rec.uom_code;
    p14_a10 := ddx_cimv_model_rec.exception_yn;
    p14_a11 := rosetta_g_miss_num_map(ddx_cimv_model_rec.number_of_items);
    p14_a12 := ddx_cimv_model_rec.upg_orig_system_ref;
    p14_a13 := rosetta_g_miss_num_map(ddx_cimv_model_rec.upg_orig_system_ref_id);
    p14_a14 := ddx_cimv_model_rec.priced_item_yn;
    p14_a15 := rosetta_g_miss_num_map(ddx_cimv_model_rec.created_by);
    p14_a16 := ddx_cimv_model_rec.creation_date;
    p14_a17 := rosetta_g_miss_num_map(ddx_cimv_model_rec.last_updated_by);
    p14_a18 := ddx_cimv_model_rec.last_update_date;
    p14_a19 := rosetta_g_miss_num_map(ddx_cimv_model_rec.last_update_login);

    p15_a0 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.id);
    p15_a1 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.object_version_number);
    p15_a2 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.cle_id);
    p15_a3 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.chr_id);
    p15_a4 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.cle_id_for);
    p15_a5 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.dnz_chr_id);
    p15_a6 := ddx_cimv_fa_rec.object1_id1;
    p15_a7 := ddx_cimv_fa_rec.object1_id2;
    p15_a8 := ddx_cimv_fa_rec.jtot_object1_code;
    p15_a9 := ddx_cimv_fa_rec.uom_code;
    p15_a10 := ddx_cimv_fa_rec.exception_yn;
    p15_a11 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.number_of_items);
    p15_a12 := ddx_cimv_fa_rec.upg_orig_system_ref;
    p15_a13 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.upg_orig_system_ref_id);
    p15_a14 := ddx_cimv_fa_rec.priced_item_yn;
    p15_a15 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.created_by);
    p15_a16 := ddx_cimv_fa_rec.creation_date;
    p15_a17 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.last_updated_by);
    p15_a18 := ddx_cimv_fa_rec.last_update_date;
    p15_a19 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.last_update_login);

    p16_a0 := rosetta_g_miss_num_map(ddx_talv_fa_rec.id);
    p16_a1 := rosetta_g_miss_num_map(ddx_talv_fa_rec.object_version_number);
    p16_a2 := ddx_talv_fa_rec.sfwt_flag;
    p16_a3 := rosetta_g_miss_num_map(ddx_talv_fa_rec.tas_id);
    p16_a4 := rosetta_g_miss_num_map(ddx_talv_fa_rec.ilo_id);
    p16_a5 := rosetta_g_miss_num_map(ddx_talv_fa_rec.ilo_id_old);
    p16_a6 := rosetta_g_miss_num_map(ddx_talv_fa_rec.iay_id);
    p16_a7 := rosetta_g_miss_num_map(ddx_talv_fa_rec.iay_id_new);
    p16_a8 := rosetta_g_miss_num_map(ddx_talv_fa_rec.kle_id);
    p16_a9 := rosetta_g_miss_num_map(ddx_talv_fa_rec.dnz_khr_id);
    p16_a10 := rosetta_g_miss_num_map(ddx_talv_fa_rec.line_number);
    p16_a11 := rosetta_g_miss_num_map(ddx_talv_fa_rec.org_id);
    p16_a12 := ddx_talv_fa_rec.tal_type;
    p16_a13 := ddx_talv_fa_rec.asset_number;
    p16_a14 := ddx_talv_fa_rec.description;
    p16_a15 := rosetta_g_miss_num_map(ddx_talv_fa_rec.fa_location_id);
    p16_a16 := rosetta_g_miss_num_map(ddx_talv_fa_rec.original_cost);
    p16_a17 := rosetta_g_miss_num_map(ddx_talv_fa_rec.current_units);
    p16_a18 := ddx_talv_fa_rec.manufacturer_name;
    p16_a19 := rosetta_g_miss_num_map(ddx_talv_fa_rec.year_manufactured);
    p16_a20 := rosetta_g_miss_num_map(ddx_talv_fa_rec.supplier_id);
    p16_a21 := ddx_talv_fa_rec.used_asset_yn;
    p16_a22 := ddx_talv_fa_rec.tag_number;
    p16_a23 := ddx_talv_fa_rec.model_number;
    p16_a24 := ddx_talv_fa_rec.corporate_book;
    p16_a25 := ddx_talv_fa_rec.date_purchased;
    p16_a26 := ddx_talv_fa_rec.date_delivery;
    p16_a27 := ddx_talv_fa_rec.in_service_date;
    p16_a28 := rosetta_g_miss_num_map(ddx_talv_fa_rec.life_in_months);
    p16_a29 := rosetta_g_miss_num_map(ddx_talv_fa_rec.depreciation_id);
    p16_a30 := rosetta_g_miss_num_map(ddx_talv_fa_rec.depreciation_cost);
    p16_a31 := ddx_talv_fa_rec.deprn_method;
    p16_a32 := rosetta_g_miss_num_map(ddx_talv_fa_rec.deprn_rate);
    p16_a33 := rosetta_g_miss_num_map(ddx_talv_fa_rec.salvage_value);
    p16_a34 := rosetta_g_miss_num_map(ddx_talv_fa_rec.percent_salvage_value);
    p16_a35 := rosetta_g_miss_num_map(ddx_talv_fa_rec.asset_key_id);
    p16_a36 := ddx_talv_fa_rec.attribute_category;
    p16_a37 := ddx_talv_fa_rec.attribute1;
    p16_a38 := ddx_talv_fa_rec.attribute2;
    p16_a39 := ddx_talv_fa_rec.attribute3;
    p16_a40 := ddx_talv_fa_rec.attribute4;
    p16_a41 := ddx_talv_fa_rec.attribute5;
    p16_a42 := ddx_talv_fa_rec.attribute6;
    p16_a43 := ddx_talv_fa_rec.attribute7;
    p16_a44 := ddx_talv_fa_rec.attribute8;
    p16_a45 := ddx_talv_fa_rec.attribute9;
    p16_a46 := ddx_talv_fa_rec.attribute10;
    p16_a47 := ddx_talv_fa_rec.attribute11;
    p16_a48 := ddx_talv_fa_rec.attribute12;
    p16_a49 := ddx_talv_fa_rec.attribute13;
    p16_a50 := ddx_talv_fa_rec.attribute14;
    p16_a51 := ddx_talv_fa_rec.attribute15;
    p16_a52 := rosetta_g_miss_num_map(ddx_talv_fa_rec.created_by);
    p16_a53 := ddx_talv_fa_rec.creation_date;
    p16_a54 := rosetta_g_miss_num_map(ddx_talv_fa_rec.last_updated_by);
    p16_a55 := ddx_talv_fa_rec.last_update_date;
    p16_a56 := rosetta_g_miss_num_map(ddx_talv_fa_rec.last_update_login);
    p16_a57 := ddx_talv_fa_rec.depreciate_yn;
    p16_a58 := rosetta_g_miss_num_map(ddx_talv_fa_rec.hold_period_days);
    p16_a59 := rosetta_g_miss_num_map(ddx_talv_fa_rec.old_salvage_value);
    p16_a60 := rosetta_g_miss_num_map(ddx_talv_fa_rec.new_residual_value);
    p16_a61 := rosetta_g_miss_num_map(ddx_talv_fa_rec.old_residual_value);
    p16_a62 := rosetta_g_miss_num_map(ddx_talv_fa_rec.units_retired);
    p16_a63 := rosetta_g_miss_num_map(ddx_talv_fa_rec.cost_retired);
    p16_a64 := rosetta_g_miss_num_map(ddx_talv_fa_rec.sale_proceeds);
    p16_a65 := rosetta_g_miss_num_map(ddx_talv_fa_rec.removal_cost);
    p16_a66 := rosetta_g_miss_num_map(ddx_talv_fa_rec.dnz_asset_id);
    p16_a67 := ddx_talv_fa_rec.date_due;
    p16_a68 := rosetta_g_miss_num_map(ddx_talv_fa_rec.rep_asset_id);
    p16_a69 := rosetta_g_miss_num_map(ddx_talv_fa_rec.lke_asset_id);
    p16_a70 := rosetta_g_miss_num_map(ddx_talv_fa_rec.match_amount);
    p16_a71 := ddx_talv_fa_rec.split_into_singles_flag;
    p16_a72 := rosetta_g_miss_num_map(ddx_talv_fa_rec.split_into_units);
    p16_a73 := ddx_talv_fa_rec.currency_code;
    p16_a74 := ddx_talv_fa_rec.currency_conversion_type;
    p16_a75 := rosetta_g_miss_num_map(ddx_talv_fa_rec.currency_conversion_rate);
    p16_a76 := ddx_talv_fa_rec.currency_conversion_date;
  end;

  procedure update_ints_ib_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p_top_line_id  NUMBER
    , p_dnz_chr_id  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_VARCHAR2_TABLE_100
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_VARCHAR2_TABLE_100
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_500
    , p9_a21 JTF_VARCHAR2_TABLE_500
    , p9_a22 JTF_VARCHAR2_TABLE_500
    , p9_a23 JTF_VARCHAR2_TABLE_500
    , p9_a24 JTF_VARCHAR2_TABLE_500
    , p9_a25 JTF_VARCHAR2_TABLE_500
    , p9_a26 JTF_VARCHAR2_TABLE_500
    , p9_a27 JTF_VARCHAR2_TABLE_500
    , p9_a28 JTF_VARCHAR2_TABLE_500
    , p9_a29 JTF_VARCHAR2_TABLE_500
    , p9_a30 JTF_VARCHAR2_TABLE_500
    , p9_a31 JTF_VARCHAR2_TABLE_500
    , p9_a32 JTF_VARCHAR2_TABLE_500
    , p9_a33 JTF_VARCHAR2_TABLE_500
    , p9_a34 JTF_VARCHAR2_TABLE_500
    , p9_a35 JTF_NUMBER_TABLE
    , p9_a36 JTF_DATE_TABLE
    , p9_a37 JTF_NUMBER_TABLE
    , p9_a38 JTF_DATE_TABLE
    , p9_a39 JTF_NUMBER_TABLE
    , p9_a40 JTF_NUMBER_TABLE
    , p9_a41 JTF_NUMBER_TABLE
    , p9_a42 JTF_VARCHAR2_TABLE_100
    , p9_a43 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a35 out nocopy JTF_NUMBER_TABLE
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_NUMBER_TABLE
    , p11_a38 out nocopy JTF_DATE_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_NUMBER_TABLE
    , p11_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a43 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_itiv_ib_tbl okl_create_kle_pub.itiv_tbl_type;
    ddx_clev_ib_tbl okl_create_kle_pub.clev_tbl_type;
    ddx_itiv_ib_tbl okl_create_kle_pub.itiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    okl_iti_pvt_w.rosetta_table_copy_in_p5(ddp_itiv_ib_tbl, p9_a0
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
      , p9_a42
      , p9_a43
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.update_ints_ib_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      p_top_line_id,
      p_dnz_chr_id,
      ddp_itiv_ib_tbl,
      ddx_clev_ib_tbl,
      ddx_itiv_ib_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_ib_tbl, p10_a0
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
      , p10_a58
      , p10_a59
      , p10_a60
      , p10_a61
      , p10_a62
      , p10_a63
      , p10_a64
      , p10_a65
      , p10_a66
      , p10_a67
      , p10_a68
      , p10_a69
      , p10_a70
      , p10_a71
      , p10_a72
      , p10_a73
      , p10_a74
      , p10_a75
      , p10_a76
      , p10_a77
      , p10_a78
      , p10_a79
      , p10_a80
      , p10_a81
      , p10_a82
      , p10_a83
      , p10_a84
      , p10_a85
      , p10_a86
      , p10_a87
      , p10_a88
      , p10_a89
      );

    okl_iti_pvt_w.rosetta_table_copy_out_p5(ddx_itiv_ib_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      );
  end;

  procedure delete_ints_ib_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  NUMBER
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  NUMBER
    , p8_a55 out nocopy  DATE
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  DATE
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  DATE
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  NUMBER
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  VARCHAR2
    , p8_a80 out nocopy  VARCHAR2
    , p8_a81 out nocopy  NUMBER
    , p8_a82 out nocopy  VARCHAR2
    , p8_a83 out nocopy  NUMBER
    , p8_a84 out nocopy  NUMBER
    , p8_a85 out nocopy  NUMBER
    , p8_a86 out nocopy  NUMBER
    , p8_a87 out nocopy  VARCHAR2
    , p8_a88 out nocopy  NUMBER
    , p8_a89 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  NUMBER
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  NUMBER
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  DATE
    , p9_a21 out nocopy  DATE
    , p9_a22 out nocopy  NUMBER
    , p9_a23 out nocopy  NUMBER
    , p9_a24 out nocopy  DATE
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  NUMBER
    , p9_a28 out nocopy  NUMBER
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  NUMBER
    , p9_a34 out nocopy  DATE
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  DATE
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  NUMBER
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  DATE
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  DATE
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  DATE
    , p9_a48 out nocopy  DATE
    , p9_a49 out nocopy  DATE
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  VARCHAR2
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  DATE
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  VARCHAR2
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  NUMBER
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  DATE
    , p9_a80 out nocopy  NUMBER
    , p9_a81 out nocopy  DATE
    , p9_a82 out nocopy  NUMBER
    , p9_a83 out nocopy  DATE
    , p9_a84 out nocopy  DATE
    , p9_a85 out nocopy  DATE
    , p9_a86 out nocopy  DATE
    , p9_a87 out nocopy  NUMBER
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p9_a90 out nocopy  VARCHAR2
    , p9_a91 out nocopy  NUMBER
    , p9_a92 out nocopy  VARCHAR2
    , p9_a93 out nocopy  NUMBER
    , p9_a94 out nocopy  NUMBER
    , p9_a95 out nocopy  DATE
    , p9_a96 out nocopy  VARCHAR2
    , p9_a97 out nocopy  VARCHAR2
    , p9_a98 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  DATE
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  DATE
    , p10_a19 out nocopy  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  VARCHAR2
    , p11_a7 out nocopy  VARCHAR2
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  DATE
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  DATE
    , p11_a19 out nocopy  NUMBER
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  NUMBER
    , p12_a9 out nocopy  NUMBER
    , p12_a10 out nocopy  NUMBER
    , p12_a11 out nocopy  NUMBER
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  NUMBER
    , p12_a16 out nocopy  NUMBER
    , p12_a17 out nocopy  NUMBER
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  NUMBER
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  DATE
    , p12_a26 out nocopy  DATE
    , p12_a27 out nocopy  DATE
    , p12_a28 out nocopy  NUMBER
    , p12_a29 out nocopy  NUMBER
    , p12_a30 out nocopy  NUMBER
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  NUMBER
    , p12_a33 out nocopy  NUMBER
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  NUMBER
    , p12_a36 out nocopy  VARCHAR2
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , p12_a45 out nocopy  VARCHAR2
    , p12_a46 out nocopy  VARCHAR2
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  VARCHAR2
    , p12_a50 out nocopy  VARCHAR2
    , p12_a51 out nocopy  VARCHAR2
    , p12_a52 out nocopy  NUMBER
    , p12_a53 out nocopy  DATE
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  DATE
    , p12_a56 out nocopy  NUMBER
    , p12_a57 out nocopy  VARCHAR2
    , p12_a58 out nocopy  NUMBER
    , p12_a59 out nocopy  NUMBER
    , p12_a60 out nocopy  NUMBER
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  NUMBER
    , p12_a63 out nocopy  NUMBER
    , p12_a64 out nocopy  NUMBER
    , p12_a65 out nocopy  NUMBER
    , p12_a66 out nocopy  NUMBER
    , p12_a67 out nocopy  DATE
    , p12_a68 out nocopy  NUMBER
    , p12_a69 out nocopy  NUMBER
    , p12_a70 out nocopy  NUMBER
    , p12_a71 out nocopy  VARCHAR2
    , p12_a72 out nocopy  NUMBER
    , p12_a73 out nocopy  VARCHAR2
    , p12_a74 out nocopy  VARCHAR2
    , p12_a75 out nocopy  NUMBER
    , p12_a76 out nocopy  DATE
  )

  as
    ddp_clev_ib_tbl okl_create_kle_pub.clev_tbl_type;
    ddx_clev_fin_rec okl_create_kle_pub.clev_rec_type;
    ddx_klev_fin_rec okl_create_kle_pub.klev_rec_type;
    ddx_cimv_model_rec okl_create_kle_pub.cimv_rec_type;
    ddx_cimv_fa_rec okl_create_kle_pub.cimv_rec_type;
    ddx_talv_fa_rec okl_create_kle_pub.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_ib_tbl, p7_a0
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
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      );






    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.delete_ints_ib_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_new_yn,
      p_asset_number,
      ddp_clev_ib_tbl,
      ddx_clev_fin_rec,
      ddx_klev_fin_rec,
      ddx_cimv_model_rec,
      ddx_cimv_fa_rec,
      ddx_talv_fa_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_clev_fin_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_clev_fin_rec.object_version_number);
    p8_a2 := ddx_clev_fin_rec.sfwt_flag;
    p8_a3 := rosetta_g_miss_num_map(ddx_clev_fin_rec.chr_id);
    p8_a4 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id);
    p8_a5 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed);
    p8_a6 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cle_id_renewed_to);
    p8_a7 := rosetta_g_miss_num_map(ddx_clev_fin_rec.lse_id);
    p8_a8 := ddx_clev_fin_rec.line_number;
    p8_a9 := ddx_clev_fin_rec.sts_code;
    p8_a10 := rosetta_g_miss_num_map(ddx_clev_fin_rec.display_sequence);
    p8_a11 := ddx_clev_fin_rec.trn_code;
    p8_a12 := rosetta_g_miss_num_map(ddx_clev_fin_rec.dnz_chr_id);
    p8_a13 := ddx_clev_fin_rec.comments;
    p8_a14 := ddx_clev_fin_rec.item_description;
    p8_a15 := ddx_clev_fin_rec.oke_boe_description;
    p8_a16 := ddx_clev_fin_rec.cognomen;
    p8_a17 := ddx_clev_fin_rec.hidden_ind;
    p8_a18 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit);
    p8_a19 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_unit_percent);
    p8_a20 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated);
    p8_a21 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_negotiated_renewed);
    p8_a22 := ddx_clev_fin_rec.price_level_ind;
    p8_a23 := ddx_clev_fin_rec.invoice_line_level_ind;
    p8_a24 := ddx_clev_fin_rec.dpas_rating;
    p8_a25 := ddx_clev_fin_rec.block23text;
    p8_a26 := ddx_clev_fin_rec.exception_yn;
    p8_a27 := ddx_clev_fin_rec.template_used;
    p8_a28 := ddx_clev_fin_rec.date_terminated;
    p8_a29 := ddx_clev_fin_rec.name;
    p8_a30 := ddx_clev_fin_rec.start_date;
    p8_a31 := ddx_clev_fin_rec.end_date;
    p8_a32 := ddx_clev_fin_rec.date_renewed;
    p8_a33 := ddx_clev_fin_rec.upg_orig_system_ref;
    p8_a34 := rosetta_g_miss_num_map(ddx_clev_fin_rec.upg_orig_system_ref_id);
    p8_a35 := ddx_clev_fin_rec.orig_system_source_code;
    p8_a36 := rosetta_g_miss_num_map(ddx_clev_fin_rec.orig_system_id1);
    p8_a37 := ddx_clev_fin_rec.orig_system_reference1;
    p8_a38 := ddx_clev_fin_rec.attribute_category;
    p8_a39 := ddx_clev_fin_rec.attribute1;
    p8_a40 := ddx_clev_fin_rec.attribute2;
    p8_a41 := ddx_clev_fin_rec.attribute3;
    p8_a42 := ddx_clev_fin_rec.attribute4;
    p8_a43 := ddx_clev_fin_rec.attribute5;
    p8_a44 := ddx_clev_fin_rec.attribute6;
    p8_a45 := ddx_clev_fin_rec.attribute7;
    p8_a46 := ddx_clev_fin_rec.attribute8;
    p8_a47 := ddx_clev_fin_rec.attribute9;
    p8_a48 := ddx_clev_fin_rec.attribute10;
    p8_a49 := ddx_clev_fin_rec.attribute11;
    p8_a50 := ddx_clev_fin_rec.attribute12;
    p8_a51 := ddx_clev_fin_rec.attribute13;
    p8_a52 := ddx_clev_fin_rec.attribute14;
    p8_a53 := ddx_clev_fin_rec.attribute15;
    p8_a54 := rosetta_g_miss_num_map(ddx_clev_fin_rec.created_by);
    p8_a55 := ddx_clev_fin_rec.creation_date;
    p8_a56 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_updated_by);
    p8_a57 := ddx_clev_fin_rec.last_update_date;
    p8_a58 := ddx_clev_fin_rec.price_type;
    p8_a59 := ddx_clev_fin_rec.currency_code;
    p8_a60 := ddx_clev_fin_rec.currency_code_renewed;
    p8_a61 := rosetta_g_miss_num_map(ddx_clev_fin_rec.last_update_login);
    p8_a62 := ddx_clev_fin_rec.old_sts_code;
    p8_a63 := ddx_clev_fin_rec.new_sts_code;
    p8_a64 := ddx_clev_fin_rec.old_ste_code;
    p8_a65 := ddx_clev_fin_rec.new_ste_code;
    p8_a66 := ddx_clev_fin_rec.call_action_asmblr;
    p8_a67 := rosetta_g_miss_num_map(ddx_clev_fin_rec.request_id);
    p8_a68 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_application_id);
    p8_a69 := rosetta_g_miss_num_map(ddx_clev_fin_rec.program_id);
    p8_a70 := ddx_clev_fin_rec.program_update_date;
    p8_a71 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_id);
    p8_a72 := ddx_clev_fin_rec.pricing_date;
    p8_a73 := rosetta_g_miss_num_map(ddx_clev_fin_rec.price_list_line_id);
    p8_a74 := rosetta_g_miss_num_map(ddx_clev_fin_rec.line_list_price);
    p8_a75 := ddx_clev_fin_rec.item_to_price_yn;
    p8_a76 := ddx_clev_fin_rec.price_basis_yn;
    p8_a77 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_header_id);
    p8_a78 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_revision_number);
    p8_a79 := ddx_clev_fin_rec.config_complete_yn;
    p8_a80 := ddx_clev_fin_rec.config_valid_yn;
    p8_a81 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_top_model_line_id);
    p8_a82 := ddx_clev_fin_rec.config_item_type;
    p8_a83 := rosetta_g_miss_num_map(ddx_clev_fin_rec.config_item_id);
    p8_a84 := rosetta_g_miss_num_map(ddx_clev_fin_rec.cust_acct_id);
    p8_a85 := rosetta_g_miss_num_map(ddx_clev_fin_rec.bill_to_site_use_id);
    p8_a86 := rosetta_g_miss_num_map(ddx_clev_fin_rec.inv_rule_id);
    p8_a87 := ddx_clev_fin_rec.line_renewal_type_code;
    p8_a88 := rosetta_g_miss_num_map(ddx_clev_fin_rec.ship_to_site_use_id);
    p8_a89 := rosetta_g_miss_num_map(ddx_clev_fin_rec.payment_term_id);

    p9_a0 := rosetta_g_miss_num_map(ddx_klev_fin_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_klev_fin_rec.object_version_number);
    p9_a2 := rosetta_g_miss_num_map(ddx_klev_fin_rec.kle_id);
    p9_a3 := rosetta_g_miss_num_map(ddx_klev_fin_rec.sty_id);
    p9_a4 := ddx_klev_fin_rec.prc_code;
    p9_a5 := ddx_klev_fin_rec.fcg_code;
    p9_a6 := ddx_klev_fin_rec.nty_code;
    p9_a7 := rosetta_g_miss_num_map(ddx_klev_fin_rec.estimated_oec);
    p9_a8 := rosetta_g_miss_num_map(ddx_klev_fin_rec.lao_amount);
    p9_a9 := ddx_klev_fin_rec.title_date;
    p9_a10 := rosetta_g_miss_num_map(ddx_klev_fin_rec.fee_charge);
    p9_a11 := rosetta_g_miss_num_map(ddx_klev_fin_rec.lrs_percent);
    p9_a12 := rosetta_g_miss_num_map(ddx_klev_fin_rec.initial_direct_cost);
    p9_a13 := rosetta_g_miss_num_map(ddx_klev_fin_rec.percent_stake);
    p9_a14 := rosetta_g_miss_num_map(ddx_klev_fin_rec.percent);
    p9_a15 := rosetta_g_miss_num_map(ddx_klev_fin_rec.evergreen_percent);
    p9_a16 := rosetta_g_miss_num_map(ddx_klev_fin_rec.amount_stake);
    p9_a17 := rosetta_g_miss_num_map(ddx_klev_fin_rec.occupancy);
    p9_a18 := rosetta_g_miss_num_map(ddx_klev_fin_rec.coverage);
    p9_a19 := rosetta_g_miss_num_map(ddx_klev_fin_rec.residual_percentage);
    p9_a20 := ddx_klev_fin_rec.date_last_inspection;
    p9_a21 := ddx_klev_fin_rec.date_sold;
    p9_a22 := rosetta_g_miss_num_map(ddx_klev_fin_rec.lrv_amount);
    p9_a23 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capital_reduction);
    p9_a24 := ddx_klev_fin_rec.date_next_inspection_due;
    p9_a25 := ddx_klev_fin_rec.date_residual_last_review;
    p9_a26 := ddx_klev_fin_rec.date_last_reamortisation;
    p9_a27 := rosetta_g_miss_num_map(ddx_klev_fin_rec.vendor_advance_paid);
    p9_a28 := rosetta_g_miss_num_map(ddx_klev_fin_rec.weighted_average_life);
    p9_a29 := rosetta_g_miss_num_map(ddx_klev_fin_rec.tradein_amount);
    p9_a30 := rosetta_g_miss_num_map(ddx_klev_fin_rec.bond_equivalent_yield);
    p9_a31 := rosetta_g_miss_num_map(ddx_klev_fin_rec.termination_purchase_amount);
    p9_a32 := rosetta_g_miss_num_map(ddx_klev_fin_rec.refinance_amount);
    p9_a33 := rosetta_g_miss_num_map(ddx_klev_fin_rec.year_built);
    p9_a34 := ddx_klev_fin_rec.delivered_date;
    p9_a35 := ddx_klev_fin_rec.credit_tenant_yn;
    p9_a36 := ddx_klev_fin_rec.date_last_cleanup;
    p9_a37 := ddx_klev_fin_rec.year_of_manufacture;
    p9_a38 := rosetta_g_miss_num_map(ddx_klev_fin_rec.coverage_ratio);
    p9_a39 := rosetta_g_miss_num_map(ddx_klev_fin_rec.remarketed_amount);
    p9_a40 := rosetta_g_miss_num_map(ddx_klev_fin_rec.gross_square_footage);
    p9_a41 := ddx_klev_fin_rec.prescribed_asset_yn;
    p9_a42 := ddx_klev_fin_rec.date_remarketed;
    p9_a43 := rosetta_g_miss_num_map(ddx_klev_fin_rec.net_rentable);
    p9_a44 := rosetta_g_miss_num_map(ddx_klev_fin_rec.remarket_margin);
    p9_a45 := ddx_klev_fin_rec.date_letter_acceptance;
    p9_a46 := rosetta_g_miss_num_map(ddx_klev_fin_rec.repurchased_amount);
    p9_a47 := ddx_klev_fin_rec.date_commitment_expiration;
    p9_a48 := ddx_klev_fin_rec.date_repurchased;
    p9_a49 := ddx_klev_fin_rec.date_appraisal;
    p9_a50 := rosetta_g_miss_num_map(ddx_klev_fin_rec.residual_value);
    p9_a51 := rosetta_g_miss_num_map(ddx_klev_fin_rec.appraisal_value);
    p9_a52 := ddx_klev_fin_rec.secured_deal_yn;
    p9_a53 := rosetta_g_miss_num_map(ddx_klev_fin_rec.gain_loss);
    p9_a54 := rosetta_g_miss_num_map(ddx_klev_fin_rec.floor_amount);
    p9_a55 := ddx_klev_fin_rec.re_lease_yn;
    p9_a56 := ddx_klev_fin_rec.previous_contract;
    p9_a57 := rosetta_g_miss_num_map(ddx_klev_fin_rec.tracked_residual);
    p9_a58 := ddx_klev_fin_rec.date_title_received;
    p9_a59 := rosetta_g_miss_num_map(ddx_klev_fin_rec.amount);
    p9_a60 := ddx_klev_fin_rec.attribute_category;
    p9_a61 := ddx_klev_fin_rec.attribute1;
    p9_a62 := ddx_klev_fin_rec.attribute2;
    p9_a63 := ddx_klev_fin_rec.attribute3;
    p9_a64 := ddx_klev_fin_rec.attribute4;
    p9_a65 := ddx_klev_fin_rec.attribute5;
    p9_a66 := ddx_klev_fin_rec.attribute6;
    p9_a67 := ddx_klev_fin_rec.attribute7;
    p9_a68 := ddx_klev_fin_rec.attribute8;
    p9_a69 := ddx_klev_fin_rec.attribute9;
    p9_a70 := ddx_klev_fin_rec.attribute10;
    p9_a71 := ddx_klev_fin_rec.attribute11;
    p9_a72 := ddx_klev_fin_rec.attribute12;
    p9_a73 := ddx_klev_fin_rec.attribute13;
    p9_a74 := ddx_klev_fin_rec.attribute14;
    p9_a75 := ddx_klev_fin_rec.attribute15;
    p9_a76 := rosetta_g_miss_num_map(ddx_klev_fin_rec.sty_id_for);
    p9_a77 := rosetta_g_miss_num_map(ddx_klev_fin_rec.clg_id);
    p9_a78 := rosetta_g_miss_num_map(ddx_klev_fin_rec.created_by);
    p9_a79 := ddx_klev_fin_rec.creation_date;
    p9_a80 := rosetta_g_miss_num_map(ddx_klev_fin_rec.last_updated_by);
    p9_a81 := ddx_klev_fin_rec.last_update_date;
    p9_a82 := rosetta_g_miss_num_map(ddx_klev_fin_rec.last_update_login);
    p9_a83 := ddx_klev_fin_rec.date_funding;
    p9_a84 := ddx_klev_fin_rec.date_funding_required;
    p9_a85 := ddx_klev_fin_rec.date_accepted;
    p9_a86 := ddx_klev_fin_rec.date_delivery_expected;
    p9_a87 := rosetta_g_miss_num_map(ddx_klev_fin_rec.oec);
    p9_a88 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capital_amount);
    p9_a89 := rosetta_g_miss_num_map(ddx_klev_fin_rec.residual_grnty_amount);
    p9_a90 := ddx_klev_fin_rec.residual_code;
    p9_a91 := rosetta_g_miss_num_map(ddx_klev_fin_rec.rvi_premium);
    p9_a92 := ddx_klev_fin_rec.credit_nature;
    p9_a93 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capitalized_interest);
    p9_a94 := rosetta_g_miss_num_map(ddx_klev_fin_rec.capital_reduction_percent);
    p9_a95 := ddx_klev_fin_rec.date_pay_investor_start;
    p9_a96 := ddx_klev_fin_rec.pay_investor_frequency;
    p9_a97 := ddx_klev_fin_rec.pay_investor_event;
    p9_a98 := rosetta_g_miss_num_map(ddx_klev_fin_rec.pay_investor_remittance_days);

    p10_a0 := rosetta_g_miss_num_map(ddx_cimv_model_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_cimv_model_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_cimv_model_rec.cle_id);
    p10_a3 := rosetta_g_miss_num_map(ddx_cimv_model_rec.chr_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_cimv_model_rec.cle_id_for);
    p10_a5 := rosetta_g_miss_num_map(ddx_cimv_model_rec.dnz_chr_id);
    p10_a6 := ddx_cimv_model_rec.object1_id1;
    p10_a7 := ddx_cimv_model_rec.object1_id2;
    p10_a8 := ddx_cimv_model_rec.jtot_object1_code;
    p10_a9 := ddx_cimv_model_rec.uom_code;
    p10_a10 := ddx_cimv_model_rec.exception_yn;
    p10_a11 := rosetta_g_miss_num_map(ddx_cimv_model_rec.number_of_items);
    p10_a12 := ddx_cimv_model_rec.upg_orig_system_ref;
    p10_a13 := rosetta_g_miss_num_map(ddx_cimv_model_rec.upg_orig_system_ref_id);
    p10_a14 := ddx_cimv_model_rec.priced_item_yn;
    p10_a15 := rosetta_g_miss_num_map(ddx_cimv_model_rec.created_by);
    p10_a16 := ddx_cimv_model_rec.creation_date;
    p10_a17 := rosetta_g_miss_num_map(ddx_cimv_model_rec.last_updated_by);
    p10_a18 := ddx_cimv_model_rec.last_update_date;
    p10_a19 := rosetta_g_miss_num_map(ddx_cimv_model_rec.last_update_login);

    p11_a0 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.object_version_number);
    p11_a2 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.cle_id);
    p11_a3 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.chr_id);
    p11_a4 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.cle_id_for);
    p11_a5 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.dnz_chr_id);
    p11_a6 := ddx_cimv_fa_rec.object1_id1;
    p11_a7 := ddx_cimv_fa_rec.object1_id2;
    p11_a8 := ddx_cimv_fa_rec.jtot_object1_code;
    p11_a9 := ddx_cimv_fa_rec.uom_code;
    p11_a10 := ddx_cimv_fa_rec.exception_yn;
    p11_a11 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.number_of_items);
    p11_a12 := ddx_cimv_fa_rec.upg_orig_system_ref;
    p11_a13 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.upg_orig_system_ref_id);
    p11_a14 := ddx_cimv_fa_rec.priced_item_yn;
    p11_a15 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.created_by);
    p11_a16 := ddx_cimv_fa_rec.creation_date;
    p11_a17 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.last_updated_by);
    p11_a18 := ddx_cimv_fa_rec.last_update_date;
    p11_a19 := rosetta_g_miss_num_map(ddx_cimv_fa_rec.last_update_login);

    p12_a0 := rosetta_g_miss_num_map(ddx_talv_fa_rec.id);
    p12_a1 := rosetta_g_miss_num_map(ddx_talv_fa_rec.object_version_number);
    p12_a2 := ddx_talv_fa_rec.sfwt_flag;
    p12_a3 := rosetta_g_miss_num_map(ddx_talv_fa_rec.tas_id);
    p12_a4 := rosetta_g_miss_num_map(ddx_talv_fa_rec.ilo_id);
    p12_a5 := rosetta_g_miss_num_map(ddx_talv_fa_rec.ilo_id_old);
    p12_a6 := rosetta_g_miss_num_map(ddx_talv_fa_rec.iay_id);
    p12_a7 := rosetta_g_miss_num_map(ddx_talv_fa_rec.iay_id_new);
    p12_a8 := rosetta_g_miss_num_map(ddx_talv_fa_rec.kle_id);
    p12_a9 := rosetta_g_miss_num_map(ddx_talv_fa_rec.dnz_khr_id);
    p12_a10 := rosetta_g_miss_num_map(ddx_talv_fa_rec.line_number);
    p12_a11 := rosetta_g_miss_num_map(ddx_talv_fa_rec.org_id);
    p12_a12 := ddx_talv_fa_rec.tal_type;
    p12_a13 := ddx_talv_fa_rec.asset_number;
    p12_a14 := ddx_talv_fa_rec.description;
    p12_a15 := rosetta_g_miss_num_map(ddx_talv_fa_rec.fa_location_id);
    p12_a16 := rosetta_g_miss_num_map(ddx_talv_fa_rec.original_cost);
    p12_a17 := rosetta_g_miss_num_map(ddx_talv_fa_rec.current_units);
    p12_a18 := ddx_talv_fa_rec.manufacturer_name;
    p12_a19 := rosetta_g_miss_num_map(ddx_talv_fa_rec.year_manufactured);
    p12_a20 := rosetta_g_miss_num_map(ddx_talv_fa_rec.supplier_id);
    p12_a21 := ddx_talv_fa_rec.used_asset_yn;
    p12_a22 := ddx_talv_fa_rec.tag_number;
    p12_a23 := ddx_talv_fa_rec.model_number;
    p12_a24 := ddx_talv_fa_rec.corporate_book;
    p12_a25 := ddx_talv_fa_rec.date_purchased;
    p12_a26 := ddx_talv_fa_rec.date_delivery;
    p12_a27 := ddx_talv_fa_rec.in_service_date;
    p12_a28 := rosetta_g_miss_num_map(ddx_talv_fa_rec.life_in_months);
    p12_a29 := rosetta_g_miss_num_map(ddx_talv_fa_rec.depreciation_id);
    p12_a30 := rosetta_g_miss_num_map(ddx_talv_fa_rec.depreciation_cost);
    p12_a31 := ddx_talv_fa_rec.deprn_method;
    p12_a32 := rosetta_g_miss_num_map(ddx_talv_fa_rec.deprn_rate);
    p12_a33 := rosetta_g_miss_num_map(ddx_talv_fa_rec.salvage_value);
    p12_a34 := rosetta_g_miss_num_map(ddx_talv_fa_rec.percent_salvage_value);
    p12_a35 := rosetta_g_miss_num_map(ddx_talv_fa_rec.asset_key_id);
    p12_a36 := ddx_talv_fa_rec.attribute_category;
    p12_a37 := ddx_talv_fa_rec.attribute1;
    p12_a38 := ddx_talv_fa_rec.attribute2;
    p12_a39 := ddx_talv_fa_rec.attribute3;
    p12_a40 := ddx_talv_fa_rec.attribute4;
    p12_a41 := ddx_talv_fa_rec.attribute5;
    p12_a42 := ddx_talv_fa_rec.attribute6;
    p12_a43 := ddx_talv_fa_rec.attribute7;
    p12_a44 := ddx_talv_fa_rec.attribute8;
    p12_a45 := ddx_talv_fa_rec.attribute9;
    p12_a46 := ddx_talv_fa_rec.attribute10;
    p12_a47 := ddx_talv_fa_rec.attribute11;
    p12_a48 := ddx_talv_fa_rec.attribute12;
    p12_a49 := ddx_talv_fa_rec.attribute13;
    p12_a50 := ddx_talv_fa_rec.attribute14;
    p12_a51 := ddx_talv_fa_rec.attribute15;
    p12_a52 := rosetta_g_miss_num_map(ddx_talv_fa_rec.created_by);
    p12_a53 := ddx_talv_fa_rec.creation_date;
    p12_a54 := rosetta_g_miss_num_map(ddx_talv_fa_rec.last_updated_by);
    p12_a55 := ddx_talv_fa_rec.last_update_date;
    p12_a56 := rosetta_g_miss_num_map(ddx_talv_fa_rec.last_update_login);
    p12_a57 := ddx_talv_fa_rec.depreciate_yn;
    p12_a58 := rosetta_g_miss_num_map(ddx_talv_fa_rec.hold_period_days);
    p12_a59 := rosetta_g_miss_num_map(ddx_talv_fa_rec.old_salvage_value);
    p12_a60 := rosetta_g_miss_num_map(ddx_talv_fa_rec.new_residual_value);
    p12_a61 := rosetta_g_miss_num_map(ddx_talv_fa_rec.old_residual_value);
    p12_a62 := rosetta_g_miss_num_map(ddx_talv_fa_rec.units_retired);
    p12_a63 := rosetta_g_miss_num_map(ddx_talv_fa_rec.cost_retired);
    p12_a64 := rosetta_g_miss_num_map(ddx_talv_fa_rec.sale_proceeds);
    p12_a65 := rosetta_g_miss_num_map(ddx_talv_fa_rec.removal_cost);
    p12_a66 := rosetta_g_miss_num_map(ddx_talv_fa_rec.dnz_asset_id);
    p12_a67 := ddx_talv_fa_rec.date_due;
    p12_a68 := rosetta_g_miss_num_map(ddx_talv_fa_rec.rep_asset_id);
    p12_a69 := rosetta_g_miss_num_map(ddx_talv_fa_rec.lke_asset_id);
    p12_a70 := rosetta_g_miss_num_map(ddx_talv_fa_rec.match_amount);
    p12_a71 := ddx_talv_fa_rec.split_into_singles_flag;
    p12_a72 := rosetta_g_miss_num_map(ddx_talv_fa_rec.split_into_units);
    p12_a73 := ddx_talv_fa_rec.currency_code;
    p12_a74 := ddx_talv_fa_rec.currency_conversion_type;
    p12_a75 := rosetta_g_miss_num_map(ddx_talv_fa_rec.currency_conversion_rate);
    p12_a76 := ddx_talv_fa_rec.currency_conversion_date;
  end;

  procedure create_asset_line_details(p_api_version  NUMBER
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
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_txdv_tbl okl_create_kle_pub.txdv_tbl_type;
    ddx_txdv_tbl okl_create_kle_pub.txdv_tbl_type;
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


    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.create_asset_line_details(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_txdv_tbl,
      ddx_txdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p6_a0
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
  end;

  procedure update_asset_line_details(p_api_version  NUMBER
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
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_txdv_tbl okl_create_kle_pub.txdv_tbl_type;
    ddx_txdv_tbl okl_create_kle_pub.txdv_tbl_type;
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


    -- here's the delegated call to the old PL/SQL routine
    okl_create_kle_pub.update_asset_line_details(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_txdv_tbl,
      ddx_txdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_asd_pvt_w.rosetta_table_copy_out_p8(ddx_txdv_tbl, p6_a0
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
  end;

end okl_create_kle_pub_w;

/
