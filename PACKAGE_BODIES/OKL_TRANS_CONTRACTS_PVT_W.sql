--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_CONTRACTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_CONTRACTS_PVT_W" as
  /* $Header: OKLETCTB.pls 120.8.12010000.3 2008/11/12 23:51:44 apaul ship $ */
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

  procedure create_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_2000
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_200
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
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
    , p6_a30 JTF_VARCHAR2_TABLE_100
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_DATE_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_DATE_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_NUMBER_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_VARCHAR2_TABLE_100
    , p6_a46 JTF_VARCHAR2_TABLE_200
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_VARCHAR2_TABLE_200
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_VARCHAR2_TABLE_200
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_VARCHAR2_TABLE_200
    , p6_a55 JTF_VARCHAR2_TABLE_300
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  NUMBER
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  DATE
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  DATE
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  DATE
    , p7_a53 out nocopy  NUMBER
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  DATE
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  VARCHAR2
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  VARCHAR2
    , p7_a74 out nocopy  VARCHAR2
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  NUMBER
    , p7_a78 out nocopy  DATE
    , p7_a79 out nocopy  NUMBER
    , p7_a80 out nocopy  NUMBER
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  DATE
    , p7_a83 out nocopy  NUMBER
    , p7_a84 out nocopy  DATE
    , p7_a85 out nocopy  VARCHAR2
    , p7_a86 out nocopy  VARCHAR2
    , p7_a87 out nocopy  VARCHAR2
    , p7_a88 out nocopy  VARCHAR2
    , p7_a89 out nocopy  VARCHAR2
    , p7_a90 out nocopy  VARCHAR2
    , p7_a91 out nocopy  VARCHAR2
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  DATE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_DATE_TABLE
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_NUMBER_TABLE
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_DATE_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_NUMBER_TABLE
    , p8_a42 out nocopy JTF_NUMBER_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
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
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddp_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddx_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddx_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);

    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p6_a0
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



    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.create_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec,
      ddp_tclv_tbl,
      ddx_tcnv_rec,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p7_a2 := ddx_tcnv_rec.rbr_code;
    p7_a3 := ddx_tcnv_rec.rpy_code;
    p7_a4 := ddx_tcnv_rec.rvn_code;
    p7_a5 := ddx_tcnv_rec.trn_code;
    p7_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p7_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p7_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p7_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p7_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p7_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p7_a12 := ddx_tcnv_rec.tax_deductible_local;
    p7_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p7_a14 := ddx_tcnv_rec.date_accrual;
    p7_a15 := ddx_tcnv_rec.accrual_status_yn;
    p7_a16 := ddx_tcnv_rec.update_status_yn;
    p7_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p7_a18 := ddx_tcnv_rec.currency_code;
    p7_a19 := ddx_tcnv_rec.attribute_category;
    p7_a20 := ddx_tcnv_rec.attribute1;
    p7_a21 := ddx_tcnv_rec.attribute2;
    p7_a22 := ddx_tcnv_rec.attribute3;
    p7_a23 := ddx_tcnv_rec.attribute4;
    p7_a24 := ddx_tcnv_rec.attribute5;
    p7_a25 := ddx_tcnv_rec.attribute6;
    p7_a26 := ddx_tcnv_rec.attribute7;
    p7_a27 := ddx_tcnv_rec.attribute8;
    p7_a28 := ddx_tcnv_rec.attribute9;
    p7_a29 := ddx_tcnv_rec.attribute10;
    p7_a30 := ddx_tcnv_rec.attribute11;
    p7_a31 := ddx_tcnv_rec.attribute12;
    p7_a32 := ddx_tcnv_rec.attribute13;
    p7_a33 := ddx_tcnv_rec.attribute14;
    p7_a34 := ddx_tcnv_rec.attribute15;
    p7_a35 := ddx_tcnv_rec.tcn_type;
    p7_a36 := ddx_tcnv_rec.rjn_code;
    p7_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p7_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p7_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p7_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p7_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p7_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p7_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p7_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p7_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p7_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p7_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p7_a48 := ddx_tcnv_rec.program_update_date;
    p7_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p7_a50 := ddx_tcnv_rec.creation_date;
    p7_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p7_a52 := ddx_tcnv_rec.last_update_date;
    p7_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p7_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p7_a55 := ddx_tcnv_rec.tsu_code;
    p7_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p7_a57 := ddx_tcnv_rec.description;
    p7_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p7_a59 := ddx_tcnv_rec.trx_number;
    p7_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p7_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p7_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p7_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p7_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p7_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p7_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p7_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p7_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p7_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p7_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p7_a71 := ddx_tcnv_rec.accrual_activity;
    p7_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p7_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p7_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p7_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p7_a76 := ddx_tcnv_rec.currency_conversion_type;
    p7_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p7_a78 := ddx_tcnv_rec.currency_conversion_date;
    p7_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p7_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p7_a81 := ddx_tcnv_rec.source_trx_type;
    p7_a82 := ddx_tcnv_rec.canceled_date;
    p7_a83 := rosetta_g_miss_num_map(ddx_tcnv_rec.legal_entity_id);
    p7_a84 := ddx_tcnv_rec.accrual_reversal_date;
    p7_a85 := ddx_tcnv_rec.accounting_reversal_yn;
    p7_a86 := ddx_tcnv_rec.product_name;
    p7_a87 := ddx_tcnv_rec.book_classification_code;
    p7_a88 := ddx_tcnv_rec.tax_owner_code;
    p7_a89 := ddx_tcnv_rec.tmt_status_code;
    p7_a90 := ddx_tcnv_rec.representation_name;
    p7_a91 := ddx_tcnv_rec.representation_code;
    p7_a92 := ddx_tcnv_rec.upgrade_status_flag;
    p7_a93 := ddx_tcnv_rec.transaction_date;

    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p8_a0
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
      );
  end;

  procedure create_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
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
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  VARCHAR2
    , p6_a82 out nocopy  DATE
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
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
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddx_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.create_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec,
      ddx_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p6_a2 := ddx_tcnv_rec.rbr_code;
    p6_a3 := ddx_tcnv_rec.rpy_code;
    p6_a4 := ddx_tcnv_rec.rvn_code;
    p6_a5 := ddx_tcnv_rec.trn_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p6_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p6_a12 := ddx_tcnv_rec.tax_deductible_local;
    p6_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p6_a14 := ddx_tcnv_rec.date_accrual;
    p6_a15 := ddx_tcnv_rec.accrual_status_yn;
    p6_a16 := ddx_tcnv_rec.update_status_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p6_a18 := ddx_tcnv_rec.currency_code;
    p6_a19 := ddx_tcnv_rec.attribute_category;
    p6_a20 := ddx_tcnv_rec.attribute1;
    p6_a21 := ddx_tcnv_rec.attribute2;
    p6_a22 := ddx_tcnv_rec.attribute3;
    p6_a23 := ddx_tcnv_rec.attribute4;
    p6_a24 := ddx_tcnv_rec.attribute5;
    p6_a25 := ddx_tcnv_rec.attribute6;
    p6_a26 := ddx_tcnv_rec.attribute7;
    p6_a27 := ddx_tcnv_rec.attribute8;
    p6_a28 := ddx_tcnv_rec.attribute9;
    p6_a29 := ddx_tcnv_rec.attribute10;
    p6_a30 := ddx_tcnv_rec.attribute11;
    p6_a31 := ddx_tcnv_rec.attribute12;
    p6_a32 := ddx_tcnv_rec.attribute13;
    p6_a33 := ddx_tcnv_rec.attribute14;
    p6_a34 := ddx_tcnv_rec.attribute15;
    p6_a35 := ddx_tcnv_rec.tcn_type;
    p6_a36 := ddx_tcnv_rec.rjn_code;
    p6_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p6_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p6_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p6_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p6_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p6_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p6_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p6_a48 := ddx_tcnv_rec.program_update_date;
    p6_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p6_a50 := ddx_tcnv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p6_a52 := ddx_tcnv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p6_a55 := ddx_tcnv_rec.tsu_code;
    p6_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p6_a57 := ddx_tcnv_rec.description;
    p6_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p6_a59 := ddx_tcnv_rec.trx_number;
    p6_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p6_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p6_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p6_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p6_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p6_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p6_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p6_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p6_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p6_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p6_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p6_a71 := ddx_tcnv_rec.accrual_activity;
    p6_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p6_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p6_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p6_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p6_a76 := ddx_tcnv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p6_a78 := ddx_tcnv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p6_a81 := ddx_tcnv_rec.source_trx_type;
    p6_a82 := ddx_tcnv_rec.canceled_date;
    p6_a83 := rosetta_g_miss_num_map(ddx_tcnv_rec.legal_entity_id);
    p6_a84 := ddx_tcnv_rec.accrual_reversal_date;
    p6_a85 := ddx_tcnv_rec.accounting_reversal_yn;
    p6_a86 := ddx_tcnv_rec.product_name;
    p6_a87 := ddx_tcnv_rec.book_classification_code;
    p6_a88 := ddx_tcnv_rec.tax_owner_code;
    p6_a89 := ddx_tcnv_rec.tmt_status_code;
    p6_a90 := ddx_tcnv_rec.representation_name;
    p6_a91 := ddx_tcnv_rec.representation_code;
    p6_a92 := ddx_tcnv_rec.upgrade_status_flag;
    p6_a93 := ddx_tcnv_rec.transaction_date;
  end;

  procedure create_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_trans_contracts_pvt.tcnv_tbl_type;
    ddx_tcnv_tbl okl_trans_contracts_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.create_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl,
      ddx_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcn_pvt_w.rosetta_table_copy_out_p5(ddx_tcnv_tbl, p6_a0
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
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      );
  end;

  procedure create_trx_cntrct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
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
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
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
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_trans_contracts_pvt.tclv_rec_type;
    ddx_tclv_rec okl_trans_contracts_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.create_trx_cntrct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec,
      ddx_tclv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tclv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tclv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tclv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tclv_rec.rct_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tclv_rec.btc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tclv_rec.tcn_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tclv_rec.khr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id);
    p6_a8 := ddx_tclv_rec.before_transfer_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_tclv_rec.line_number);
    p6_a10 := ddx_tclv_rec.description;
    p6_a11 := rosetta_g_miss_num_map(ddx_tclv_rec.amount);
    p6_a12 := ddx_tclv_rec.currency_code;
    p6_a13 := ddx_tclv_rec.gl_reversal_yn;
    p6_a14 := ddx_tclv_rec.attribute_category;
    p6_a15 := ddx_tclv_rec.attribute1;
    p6_a16 := ddx_tclv_rec.attribute2;
    p6_a17 := ddx_tclv_rec.attribute3;
    p6_a18 := ddx_tclv_rec.attribute4;
    p6_a19 := ddx_tclv_rec.attribute5;
    p6_a20 := ddx_tclv_rec.attribute6;
    p6_a21 := ddx_tclv_rec.attribute7;
    p6_a22 := ddx_tclv_rec.attribute8;
    p6_a23 := ddx_tclv_rec.attribute9;
    p6_a24 := ddx_tclv_rec.attribute10;
    p6_a25 := ddx_tclv_rec.attribute11;
    p6_a26 := ddx_tclv_rec.attribute12;
    p6_a27 := ddx_tclv_rec.attribute13;
    p6_a28 := ddx_tclv_rec.attribute14;
    p6_a29 := ddx_tclv_rec.attribute15;
    p6_a30 := ddx_tclv_rec.tcl_type;
    p6_a31 := rosetta_g_miss_num_map(ddx_tclv_rec.created_by);
    p6_a32 := ddx_tclv_rec.creation_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_tclv_rec.last_updated_by);
    p6_a34 := ddx_tclv_rec.last_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_tclv_rec.org_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_tclv_rec.program_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tclv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tclv_rec.request_id);
    p6_a39 := ddx_tclv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tclv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_tclv_rec.avl_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_tclv_rec.bkt_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id_new);
    p6_a44 := rosetta_g_miss_num_map(ddx_tclv_rec.percentage);
    p6_a45 := ddx_tclv_rec.accrual_rule_yn;
    p6_a46 := ddx_tclv_rec.source_column_1;
    p6_a47 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_1);
    p6_a48 := ddx_tclv_rec.source_column_2;
    p6_a49 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_2);
    p6_a50 := ddx_tclv_rec.source_column_3;
    p6_a51 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_3);
    p6_a52 := ddx_tclv_rec.canceled_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tclv_rec.tax_line_id);
    p6_a54 := ddx_tclv_rec.stream_type_code;
    p6_a55 := ddx_tclv_rec.stream_type_purpose;
    p6_a56 := ddx_tclv_rec.asset_book_type_name;
    p6_a57 := ddx_tclv_rec.upgrade_status_flag;
  end;

  procedure create_trx_cntrct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddx_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
    okl_trans_contracts_pvt.create_trx_cntrct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p6_a0
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

  procedure update_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_2000
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_200
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
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
    , p6_a30 JTF_VARCHAR2_TABLE_100
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_DATE_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_DATE_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_NUMBER_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_VARCHAR2_TABLE_100
    , p6_a46 JTF_VARCHAR2_TABLE_200
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_VARCHAR2_TABLE_200
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_VARCHAR2_TABLE_200
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_VARCHAR2_TABLE_200
    , p6_a55 JTF_VARCHAR2_TABLE_300
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  NUMBER
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  DATE
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  DATE
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  DATE
    , p7_a53 out nocopy  NUMBER
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  DATE
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  VARCHAR2
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  VARCHAR2
    , p7_a74 out nocopy  VARCHAR2
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  NUMBER
    , p7_a78 out nocopy  DATE
    , p7_a79 out nocopy  NUMBER
    , p7_a80 out nocopy  NUMBER
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  DATE
    , p7_a83 out nocopy  NUMBER
    , p7_a84 out nocopy  DATE
    , p7_a85 out nocopy  VARCHAR2
    , p7_a86 out nocopy  VARCHAR2
    , p7_a87 out nocopy  VARCHAR2
    , p7_a88 out nocopy  VARCHAR2
    , p7_a89 out nocopy  VARCHAR2
    , p7_a90 out nocopy  VARCHAR2
    , p7_a91 out nocopy  VARCHAR2
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  DATE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_DATE_TABLE
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_NUMBER_TABLE
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_DATE_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_NUMBER_TABLE
    , p8_a42 out nocopy JTF_NUMBER_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
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
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddp_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddx_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddx_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);

    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p6_a0
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



    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.update_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec,
      ddp_tclv_tbl,
      ddx_tcnv_rec,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p7_a2 := ddx_tcnv_rec.rbr_code;
    p7_a3 := ddx_tcnv_rec.rpy_code;
    p7_a4 := ddx_tcnv_rec.rvn_code;
    p7_a5 := ddx_tcnv_rec.trn_code;
    p7_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p7_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p7_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p7_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p7_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p7_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p7_a12 := ddx_tcnv_rec.tax_deductible_local;
    p7_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p7_a14 := ddx_tcnv_rec.date_accrual;
    p7_a15 := ddx_tcnv_rec.accrual_status_yn;
    p7_a16 := ddx_tcnv_rec.update_status_yn;
    p7_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p7_a18 := ddx_tcnv_rec.currency_code;
    p7_a19 := ddx_tcnv_rec.attribute_category;
    p7_a20 := ddx_tcnv_rec.attribute1;
    p7_a21 := ddx_tcnv_rec.attribute2;
    p7_a22 := ddx_tcnv_rec.attribute3;
    p7_a23 := ddx_tcnv_rec.attribute4;
    p7_a24 := ddx_tcnv_rec.attribute5;
    p7_a25 := ddx_tcnv_rec.attribute6;
    p7_a26 := ddx_tcnv_rec.attribute7;
    p7_a27 := ddx_tcnv_rec.attribute8;
    p7_a28 := ddx_tcnv_rec.attribute9;
    p7_a29 := ddx_tcnv_rec.attribute10;
    p7_a30 := ddx_tcnv_rec.attribute11;
    p7_a31 := ddx_tcnv_rec.attribute12;
    p7_a32 := ddx_tcnv_rec.attribute13;
    p7_a33 := ddx_tcnv_rec.attribute14;
    p7_a34 := ddx_tcnv_rec.attribute15;
    p7_a35 := ddx_tcnv_rec.tcn_type;
    p7_a36 := ddx_tcnv_rec.rjn_code;
    p7_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p7_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p7_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p7_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p7_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p7_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p7_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p7_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p7_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p7_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p7_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p7_a48 := ddx_tcnv_rec.program_update_date;
    p7_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p7_a50 := ddx_tcnv_rec.creation_date;
    p7_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p7_a52 := ddx_tcnv_rec.last_update_date;
    p7_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p7_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p7_a55 := ddx_tcnv_rec.tsu_code;
    p7_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p7_a57 := ddx_tcnv_rec.description;
    p7_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p7_a59 := ddx_tcnv_rec.trx_number;
    p7_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p7_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p7_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p7_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p7_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p7_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p7_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p7_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p7_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p7_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p7_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p7_a71 := ddx_tcnv_rec.accrual_activity;
    p7_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p7_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p7_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p7_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p7_a76 := ddx_tcnv_rec.currency_conversion_type;
    p7_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p7_a78 := ddx_tcnv_rec.currency_conversion_date;
    p7_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p7_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p7_a81 := ddx_tcnv_rec.source_trx_type;
    p7_a82 := ddx_tcnv_rec.canceled_date;
    p7_a83 := rosetta_g_miss_num_map(ddx_tcnv_rec.legal_entity_id);
    p7_a84 := ddx_tcnv_rec.accrual_reversal_date;
    p7_a85 := ddx_tcnv_rec.accounting_reversal_yn;
    p7_a86 := ddx_tcnv_rec.product_name;
    p7_a87 := ddx_tcnv_rec.book_classification_code;
    p7_a88 := ddx_tcnv_rec.tax_owner_code;
    p7_a89 := ddx_tcnv_rec.tmt_status_code;
    p7_a90 := ddx_tcnv_rec.representation_name;
    p7_a91 := ddx_tcnv_rec.representation_code;
    p7_a92 := ddx_tcnv_rec.upgrade_status_flag;
    p7_a93 := ddx_tcnv_rec.transaction_date;

    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p8_a0
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
      );
  end;

  procedure update_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
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
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  VARCHAR2
    , p6_a82 out nocopy  DATE
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
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
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddx_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.update_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec,
      ddx_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p6_a2 := ddx_tcnv_rec.rbr_code;
    p6_a3 := ddx_tcnv_rec.rpy_code;
    p6_a4 := ddx_tcnv_rec.rvn_code;
    p6_a5 := ddx_tcnv_rec.trn_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p6_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p6_a12 := ddx_tcnv_rec.tax_deductible_local;
    p6_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p6_a14 := ddx_tcnv_rec.date_accrual;
    p6_a15 := ddx_tcnv_rec.accrual_status_yn;
    p6_a16 := ddx_tcnv_rec.update_status_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p6_a18 := ddx_tcnv_rec.currency_code;
    p6_a19 := ddx_tcnv_rec.attribute_category;
    p6_a20 := ddx_tcnv_rec.attribute1;
    p6_a21 := ddx_tcnv_rec.attribute2;
    p6_a22 := ddx_tcnv_rec.attribute3;
    p6_a23 := ddx_tcnv_rec.attribute4;
    p6_a24 := ddx_tcnv_rec.attribute5;
    p6_a25 := ddx_tcnv_rec.attribute6;
    p6_a26 := ddx_tcnv_rec.attribute7;
    p6_a27 := ddx_tcnv_rec.attribute8;
    p6_a28 := ddx_tcnv_rec.attribute9;
    p6_a29 := ddx_tcnv_rec.attribute10;
    p6_a30 := ddx_tcnv_rec.attribute11;
    p6_a31 := ddx_tcnv_rec.attribute12;
    p6_a32 := ddx_tcnv_rec.attribute13;
    p6_a33 := ddx_tcnv_rec.attribute14;
    p6_a34 := ddx_tcnv_rec.attribute15;
    p6_a35 := ddx_tcnv_rec.tcn_type;
    p6_a36 := ddx_tcnv_rec.rjn_code;
    p6_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p6_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p6_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p6_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p6_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p6_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p6_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p6_a48 := ddx_tcnv_rec.program_update_date;
    p6_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p6_a50 := ddx_tcnv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p6_a52 := ddx_tcnv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p6_a55 := ddx_tcnv_rec.tsu_code;
    p6_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p6_a57 := ddx_tcnv_rec.description;
    p6_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p6_a59 := ddx_tcnv_rec.trx_number;
    p6_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p6_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p6_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p6_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p6_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p6_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p6_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p6_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p6_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p6_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p6_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p6_a71 := ddx_tcnv_rec.accrual_activity;
    p6_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p6_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p6_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p6_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p6_a76 := ddx_tcnv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p6_a78 := ddx_tcnv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p6_a81 := ddx_tcnv_rec.source_trx_type;
    p6_a82 := ddx_tcnv_rec.canceled_date;
    p6_a83 := rosetta_g_miss_num_map(ddx_tcnv_rec.legal_entity_id);
    p6_a84 := ddx_tcnv_rec.accrual_reversal_date;
    p6_a85 := ddx_tcnv_rec.accounting_reversal_yn;
    p6_a86 := ddx_tcnv_rec.product_name;
    p6_a87 := ddx_tcnv_rec.book_classification_code;
    p6_a88 := ddx_tcnv_rec.tax_owner_code;
    p6_a89 := ddx_tcnv_rec.tmt_status_code;
    p6_a90 := ddx_tcnv_rec.representation_name;
    p6_a91 := ddx_tcnv_rec.representation_code;
    p6_a92 := ddx_tcnv_rec.upgrade_status_flag;
    p6_a93 := ddx_tcnv_rec.transaction_date;
  end;

  procedure update_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_trans_contracts_pvt.tcnv_tbl_type;
    ddx_tcnv_tbl okl_trans_contracts_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.update_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl,
      ddx_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcn_pvt_w.rosetta_table_copy_out_p5(ddx_tcnv_tbl, p6_a0
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
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      );
  end;

  procedure update_trx_cntrct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
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
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
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
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_trans_contracts_pvt.tclv_rec_type;
    ddx_tclv_rec okl_trans_contracts_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.update_trx_cntrct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec,
      ddx_tclv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tclv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tclv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tclv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tclv_rec.rct_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tclv_rec.btc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tclv_rec.tcn_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tclv_rec.khr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id);
    p6_a8 := ddx_tclv_rec.before_transfer_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_tclv_rec.line_number);
    p6_a10 := ddx_tclv_rec.description;
    p6_a11 := rosetta_g_miss_num_map(ddx_tclv_rec.amount);
    p6_a12 := ddx_tclv_rec.currency_code;
    p6_a13 := ddx_tclv_rec.gl_reversal_yn;
    p6_a14 := ddx_tclv_rec.attribute_category;
    p6_a15 := ddx_tclv_rec.attribute1;
    p6_a16 := ddx_tclv_rec.attribute2;
    p6_a17 := ddx_tclv_rec.attribute3;
    p6_a18 := ddx_tclv_rec.attribute4;
    p6_a19 := ddx_tclv_rec.attribute5;
    p6_a20 := ddx_tclv_rec.attribute6;
    p6_a21 := ddx_tclv_rec.attribute7;
    p6_a22 := ddx_tclv_rec.attribute8;
    p6_a23 := ddx_tclv_rec.attribute9;
    p6_a24 := ddx_tclv_rec.attribute10;
    p6_a25 := ddx_tclv_rec.attribute11;
    p6_a26 := ddx_tclv_rec.attribute12;
    p6_a27 := ddx_tclv_rec.attribute13;
    p6_a28 := ddx_tclv_rec.attribute14;
    p6_a29 := ddx_tclv_rec.attribute15;
    p6_a30 := ddx_tclv_rec.tcl_type;
    p6_a31 := rosetta_g_miss_num_map(ddx_tclv_rec.created_by);
    p6_a32 := ddx_tclv_rec.creation_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_tclv_rec.last_updated_by);
    p6_a34 := ddx_tclv_rec.last_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_tclv_rec.org_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_tclv_rec.program_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tclv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tclv_rec.request_id);
    p6_a39 := ddx_tclv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tclv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_tclv_rec.avl_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_tclv_rec.bkt_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id_new);
    p6_a44 := rosetta_g_miss_num_map(ddx_tclv_rec.percentage);
    p6_a45 := ddx_tclv_rec.accrual_rule_yn;
    p6_a46 := ddx_tclv_rec.source_column_1;
    p6_a47 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_1);
    p6_a48 := ddx_tclv_rec.source_column_2;
    p6_a49 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_2);
    p6_a50 := ddx_tclv_rec.source_column_3;
    p6_a51 := rosetta_g_miss_num_map(ddx_tclv_rec.source_value_3);
    p6_a52 := ddx_tclv_rec.canceled_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tclv_rec.tax_line_id);
    p6_a54 := ddx_tclv_rec.stream_type_code;
    p6_a55 := ddx_tclv_rec.stream_type_purpose;
    p6_a56 := ddx_tclv_rec.asset_book_type_name;
    p6_a57 := ddx_tclv_rec.upgrade_status_flag;
  end;

  procedure update_trx_cntrct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddx_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
    okl_trans_contracts_pvt.update_trx_cntrct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl,
      ddx_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcl_pvt_w.rosetta_table_copy_out_p5(ddx_tclv_tbl, p6_a0
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

  procedure delete_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
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
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_trans_contracts_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);

    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.delete_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_trx_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_trans_contracts_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.delete_trx_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_trx_cntrct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
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
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_trans_contracts_pvt.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;
    ddp_tclv_rec.source_column_1 := p5_a46;
    ddp_tclv_rec.source_value_1 := rosetta_g_miss_num_map(p5_a47);
    ddp_tclv_rec.source_column_2 := p5_a48;
    ddp_tclv_rec.source_value_2 := rosetta_g_miss_num_map(p5_a49);
    ddp_tclv_rec.source_column_3 := p5_a50;
    ddp_tclv_rec.source_value_3 := rosetta_g_miss_num_map(p5_a51);
    ddp_tclv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tclv_rec.tax_line_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tclv_rec.stream_type_code := p5_a54;
    ddp_tclv_rec.stream_type_purpose := p5_a55;
    ddp_tclv_rec.asset_book_type_name := p5_a56;
    ddp_tclv_rec.upgrade_status_flag := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_trans_contracts_pvt.delete_trx_cntrct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_trx_cntrct_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_300
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tclv_tbl okl_trans_contracts_pvt.tclv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcl_pvt_w.rosetta_table_copy_in_p5(ddp_tclv_tbl, p5_a0
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
    okl_trans_contracts_pvt.delete_trx_cntrct_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_trans_contracts_pvt_w;

/
