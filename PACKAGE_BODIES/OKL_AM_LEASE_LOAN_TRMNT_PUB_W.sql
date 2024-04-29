--------------------------------------------------------
--  DDL for Package Body OKL_AM_LEASE_LOAN_TRMNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PUB_W" as
  /* $Header: OKLULLTB.pls 120.7.12010000.5 2008/12/03 12:34:38 sosharma ship $ */
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

  procedure lease_loan_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  DATE := fnd_api.g_miss_date
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  DATE := fnd_api.g_miss_date
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_term_rec okl_am_lease_loan_trmnt_pub.term_rec_type;
    ddp_tcnv_rec okl_am_lease_loan_trmnt_pub.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_term_rec.p_contract_id := rosetta_g_miss_num_map(p5_a0);
    ddp_term_rec.p_contract_number := p5_a1;
    ddp_term_rec.p_contract_modifier := p5_a2;
    ddp_term_rec.p_orig_end_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_term_rec.p_contract_version := p5_a4;
    ddp_term_rec.p_termination_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_term_rec.p_termination_reason := p5_a6;
    ddp_term_rec.p_quote_id := rosetta_g_miss_num_map(p5_a7);
    ddp_term_rec.p_quote_type := p5_a8;
    ddp_term_rec.p_quote_reason := p5_a9;
    ddp_term_rec.p_early_termination_yn := p5_a10;
    ddp_term_rec.p_control_flag := p5_a11;
    ddp_term_rec.p_recycle_flag := p5_a12;

    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_tcnv_rec.rbr_code := p6_a2;
    ddp_tcnv_rec.rpy_code := p6_a3;
    ddp_tcnv_rec.rvn_code := p6_a4;
    ddp_tcnv_rec.trn_code := p6_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p6_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p6_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p6_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p6_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p6_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p6_a11);
    ddp_tcnv_rec.tax_deductible_local := p6_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p6_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p6_a14);
    ddp_tcnv_rec.accrual_status_yn := p6_a15;
    ddp_tcnv_rec.update_status_yn := p6_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p6_a17);
    ddp_tcnv_rec.currency_code := p6_a18;
    ddp_tcnv_rec.attribute_category := p6_a19;
    ddp_tcnv_rec.attribute1 := p6_a20;
    ddp_tcnv_rec.attribute2 := p6_a21;
    ddp_tcnv_rec.attribute3 := p6_a22;
    ddp_tcnv_rec.attribute4 := p6_a23;
    ddp_tcnv_rec.attribute5 := p6_a24;
    ddp_tcnv_rec.attribute6 := p6_a25;
    ddp_tcnv_rec.attribute7 := p6_a26;
    ddp_tcnv_rec.attribute8 := p6_a27;
    ddp_tcnv_rec.attribute9 := p6_a28;
    ddp_tcnv_rec.attribute10 := p6_a29;
    ddp_tcnv_rec.attribute11 := p6_a30;
    ddp_tcnv_rec.attribute12 := p6_a31;
    ddp_tcnv_rec.attribute13 := p6_a32;
    ddp_tcnv_rec.attribute14 := p6_a33;
    ddp_tcnv_rec.attribute15 := p6_a34;
    ddp_tcnv_rec.tcn_type := p6_a35;
    ddp_tcnv_rec.rjn_code := p6_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p6_a37);
    ddp_tcnv_rec.party_rel_id2_old := p6_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p6_a39);
    ddp_tcnv_rec.party_rel_id2_new := p6_a40;
    ddp_tcnv_rec.complete_transfer_yn := p6_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p6_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p6_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p6_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p6_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p6_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p6_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p6_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p6_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p6_a54);
    ddp_tcnv_rec.tsu_code := p6_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p6_a56);
    ddp_tcnv_rec.description := p6_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p6_a58);
    ddp_tcnv_rec.trx_number := p6_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p6_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p6_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p6_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p6_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p6_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p6_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p6_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p6_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p6_a68;
    ddp_tcnv_rec.tmt_validated_yn := p6_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p6_a70;
    ddp_tcnv_rec.accrual_activity := p6_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p6_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p6_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p6_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p6_a75;
    ddp_tcnv_rec.currency_conversion_type := p6_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p6_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p6_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p6_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p6_a80);
    ddp_tcnv_rec.source_trx_type := p6_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p6_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p6_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p6_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p6_a85;
    ddp_tcnv_rec.product_name := p6_a86;
    ddp_tcnv_rec.book_classification_code := p6_a87;
    ddp_tcnv_rec.tax_owner_code := p6_a88;
    ddp_tcnv_rec.tmt_status_code := p6_a89;
    ddp_tcnv_rec.representation_name := p6_a90;
    ddp_tcnv_rec.representation_code := p6_a91;
    ddp_tcnv_rec.upgrade_status_flag := p6_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p6_a93);

    -- here's the delegated call to the old PL/SQL routine
    okl_am_lease_loan_trmnt_pub.lease_loan_termination(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_term_rec,
      ddp_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure lease_loan_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_VARCHAR2_TABLE_200
    , p6_a19 JTF_VARCHAR2_TABLE_100
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
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_100
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_NUMBER_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_VARCHAR2_TABLE_2000
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_100
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_VARCHAR2_TABLE_100
    , p6_a68 JTF_VARCHAR2_TABLE_100
    , p6_a69 JTF_VARCHAR2_TABLE_100
    , p6_a70 JTF_VARCHAR2_TABLE_100
    , p6_a71 JTF_VARCHAR2_TABLE_100
    , p6_a72 JTF_VARCHAR2_TABLE_100
    , p6_a73 JTF_VARCHAR2_TABLE_100
    , p6_a74 JTF_VARCHAR2_TABLE_100
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_DATE_TABLE
    , p6_a79 JTF_NUMBER_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_VARCHAR2_TABLE_100
    , p6_a82 JTF_DATE_TABLE
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_VARCHAR2_TABLE_100
    , p6_a86 JTF_VARCHAR2_TABLE_200
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_VARCHAR2_TABLE_200
    , p6_a89 JTF_VARCHAR2_TABLE_100
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_VARCHAR2_TABLE_100
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_DATE_TABLE
  )

  as
    ddp_term_tbl okl_am_lease_loan_trmnt_pub.term_tbl_type;
    ddp_tcnv_tbl okl_am_lease_loan_trmnt_pub.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_lease_loan_trmnt_pvt_w.rosetta_table_copy_in_p13(ddp_term_tbl, p5_a0
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
      );

    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p6_a0
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

    -- here's the delegated call to the old PL/SQL routine
    okl_am_lease_loan_trmnt_pub.lease_loan_termination(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_term_tbl,
      ddp_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_am_lease_loan_trmnt_pub_w;

/
