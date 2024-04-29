--------------------------------------------------------
--  DDL for Package Body OKL_RELEASE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RELEASE_PVT_W" as
  /* $Header: OKLEREKB.pls 120.4 2005/10/30 04:06:43 appldev noship $ */
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

  procedure create_release_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_release_reason_code  VARCHAR2
    , p_release_description  VARCHAR2
    , p_trx_date  date
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  VARCHAR2
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  DATE
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  VARCHAR2
    , p11_a19 out nocopy  VARCHAR2
    , p11_a20 out nocopy  VARCHAR2
    , p11_a21 out nocopy  VARCHAR2
    , p11_a22 out nocopy  VARCHAR2
    , p11_a23 out nocopy  VARCHAR2
    , p11_a24 out nocopy  VARCHAR2
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  VARCHAR2
    , p11_a28 out nocopy  VARCHAR2
    , p11_a29 out nocopy  VARCHAR2
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  NUMBER
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  NUMBER
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  NUMBER
    , p11_a43 out nocopy  NUMBER
    , p11_a44 out nocopy  NUMBER
    , p11_a45 out nocopy  NUMBER
    , p11_a46 out nocopy  NUMBER
    , p11_a47 out nocopy  NUMBER
    , p11_a48 out nocopy  DATE
    , p11_a49 out nocopy  NUMBER
    , p11_a50 out nocopy  DATE
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  DATE
    , p11_a53 out nocopy  NUMBER
    , p11_a54 out nocopy  NUMBER
    , p11_a55 out nocopy  VARCHAR2
    , p11_a56 out nocopy  NUMBER
    , p11_a57 out nocopy  VARCHAR2
    , p11_a58 out nocopy  DATE
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  VARCHAR2
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  VARCHAR2
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  VARCHAR2
    , p11_a66 out nocopy  VARCHAR2
    , p11_a67 out nocopy  VARCHAR2
    , p11_a68 out nocopy  VARCHAR2
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  VARCHAR2
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  VARCHAR2
    , p11_a74 out nocopy  VARCHAR2
    , p11_a75 out nocopy  VARCHAR2
    , p11_a76 out nocopy  VARCHAR2
    , p11_a77 out nocopy  NUMBER
    , p11_a78 out nocopy  DATE
    , p11_a79 out nocopy  NUMBER
    , p11_a80 out nocopy  NUMBER
    , p11_a81 out nocopy  VARCHAR2
    , x_release_chr_id out nocopy  NUMBER
  )

  as
    ddp_trx_date date;
    ddx_tcnv_rec okl_release_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_release_pvt.create_release_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_release_reason_code,
      p_release_description,
      ddp_trx_date,
      p_source_trx_id,
      p_source_trx_type,
      ddx_tcnv_rec,
      x_release_chr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p11_a2 := ddx_tcnv_rec.rbr_code;
    p11_a3 := ddx_tcnv_rec.rpy_code;
    p11_a4 := ddx_tcnv_rec.rvn_code;
    p11_a5 := ddx_tcnv_rec.trn_code;
    p11_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p11_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p11_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p11_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p11_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p11_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p11_a12 := ddx_tcnv_rec.tax_deductible_local;
    p11_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p11_a14 := ddx_tcnv_rec.date_accrual;
    p11_a15 := ddx_tcnv_rec.accrual_status_yn;
    p11_a16 := ddx_tcnv_rec.update_status_yn;
    p11_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p11_a18 := ddx_tcnv_rec.currency_code;
    p11_a19 := ddx_tcnv_rec.attribute_category;
    p11_a20 := ddx_tcnv_rec.attribute1;
    p11_a21 := ddx_tcnv_rec.attribute2;
    p11_a22 := ddx_tcnv_rec.attribute3;
    p11_a23 := ddx_tcnv_rec.attribute4;
    p11_a24 := ddx_tcnv_rec.attribute5;
    p11_a25 := ddx_tcnv_rec.attribute6;
    p11_a26 := ddx_tcnv_rec.attribute7;
    p11_a27 := ddx_tcnv_rec.attribute8;
    p11_a28 := ddx_tcnv_rec.attribute9;
    p11_a29 := ddx_tcnv_rec.attribute10;
    p11_a30 := ddx_tcnv_rec.attribute11;
    p11_a31 := ddx_tcnv_rec.attribute12;
    p11_a32 := ddx_tcnv_rec.attribute13;
    p11_a33 := ddx_tcnv_rec.attribute14;
    p11_a34 := ddx_tcnv_rec.attribute15;
    p11_a35 := ddx_tcnv_rec.tcn_type;
    p11_a36 := ddx_tcnv_rec.rjn_code;
    p11_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p11_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p11_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p11_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p11_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p11_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p11_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p11_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p11_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p11_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p11_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p11_a48 := ddx_tcnv_rec.program_update_date;
    p11_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p11_a50 := ddx_tcnv_rec.creation_date;
    p11_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p11_a52 := ddx_tcnv_rec.last_update_date;
    p11_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p11_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p11_a55 := ddx_tcnv_rec.tsu_code;
    p11_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p11_a57 := ddx_tcnv_rec.description;
    p11_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p11_a59 := ddx_tcnv_rec.trx_number;
    p11_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p11_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p11_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p11_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p11_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p11_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p11_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p11_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p11_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p11_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p11_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p11_a71 := ddx_tcnv_rec.accrual_activity;
    p11_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p11_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p11_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p11_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p11_a76 := ddx_tcnv_rec.currency_conversion_type;
    p11_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p11_a78 := ddx_tcnv_rec.currency_conversion_date;
    p11_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p11_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p11_a81 := ddx_tcnv_rec.source_trx_type;

  end;

end okl_release_pvt_w;

/
