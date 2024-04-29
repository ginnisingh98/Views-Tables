--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_REBOOK_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_REBOOK_PUB_W" as
  /* $Header: OKLURBKB.pls 120.2 2005/12/06 23:43:48 rpillay noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_txn_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_from_chr_id  NUMBER
    , p_rebook_reason_code  VARCHAR2
    , p_rebook_description  VARCHAR2
    , p_trx_date  date
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  NUMBER
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
    , p9_a32 out nocopy  VARCHAR2
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  VARCHAR2
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  VARCHAR2
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  NUMBER
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  NUMBER
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  NUMBER
    , p9_a48 out nocopy  DATE
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  DATE
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  DATE
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  VARCHAR2
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  VARCHAR2
    , p9_a58 out nocopy  DATE
    , p9_a59 out nocopy  VARCHAR2
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
    , x_rebook_chr_id out nocopy  NUMBER
  )

  as
    ddp_trx_date date;
    ddx_tcnv_rec okl_contract_rebook_pub.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_contract_rebook_pub.create_txn_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_from_chr_id,
      p_rebook_reason_code,
      p_rebook_description,
      ddp_trx_date,
      ddx_tcnv_rec,
      x_rebook_chr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p9_a2 := ddx_tcnv_rec.rbr_code;
    p9_a3 := ddx_tcnv_rec.rpy_code;
    p9_a4 := ddx_tcnv_rec.rvn_code;
    p9_a5 := ddx_tcnv_rec.trn_code;
    p9_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p9_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p9_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p9_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p9_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p9_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p9_a12 := ddx_tcnv_rec.tax_deductible_local;
    p9_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p9_a14 := ddx_tcnv_rec.date_accrual;
    p9_a15 := ddx_tcnv_rec.accrual_status_yn;
    p9_a16 := ddx_tcnv_rec.update_status_yn;
    p9_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p9_a18 := ddx_tcnv_rec.currency_code;
    p9_a19 := ddx_tcnv_rec.attribute_category;
    p9_a20 := ddx_tcnv_rec.attribute1;
    p9_a21 := ddx_tcnv_rec.attribute2;
    p9_a22 := ddx_tcnv_rec.attribute3;
    p9_a23 := ddx_tcnv_rec.attribute4;
    p9_a24 := ddx_tcnv_rec.attribute5;
    p9_a25 := ddx_tcnv_rec.attribute6;
    p9_a26 := ddx_tcnv_rec.attribute7;
    p9_a27 := ddx_tcnv_rec.attribute8;
    p9_a28 := ddx_tcnv_rec.attribute9;
    p9_a29 := ddx_tcnv_rec.attribute10;
    p9_a30 := ddx_tcnv_rec.attribute11;
    p9_a31 := ddx_tcnv_rec.attribute12;
    p9_a32 := ddx_tcnv_rec.attribute13;
    p9_a33 := ddx_tcnv_rec.attribute14;
    p9_a34 := ddx_tcnv_rec.attribute15;
    p9_a35 := ddx_tcnv_rec.tcn_type;
    p9_a36 := ddx_tcnv_rec.rjn_code;
    p9_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p9_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p9_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p9_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p9_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p9_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p9_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p9_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p9_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p9_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p9_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p9_a48 := ddx_tcnv_rec.program_update_date;
    p9_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p9_a50 := ddx_tcnv_rec.creation_date;
    p9_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p9_a52 := ddx_tcnv_rec.last_update_date;
    p9_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p9_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p9_a55 := ddx_tcnv_rec.tsu_code;
    p9_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p9_a57 := ddx_tcnv_rec.description;
    p9_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p9_a59 := ddx_tcnv_rec.trx_number;
    p9_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p9_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p9_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p9_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p9_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p9_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p9_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p9_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p9_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p9_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p9_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;

  end;

end okl_contract_rebook_pub_w;

/
