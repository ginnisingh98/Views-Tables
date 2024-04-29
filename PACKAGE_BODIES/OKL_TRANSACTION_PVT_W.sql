--------------------------------------------------------
--  DDL for Package Body OKL_TRANSACTION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANSACTION_PVT_W" as
  /* $Header: OKLETXNB.pls 120.1 2005/07/12 09:11:53 dkagrawa noship $ */
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

  procedure rosetta_table_copy_in_p11(t out nocopy okl_transaction_pvt.rev_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_transaction_pvt.rev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure create_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_new_chr_id  NUMBER
    , p_reason_code  VARCHAR2
    , p_description  VARCHAR2
    , p_trx_date  date
    , p_trx_type  VARCHAR2
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
    , p11_a82 out nocopy  DATE
  )

  as
    ddp_trx_date date;
    ddx_tcnv_rec okl_transaction_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.create_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_new_chr_id,
      p_reason_code,
      p_description,
      ddp_trx_date,
      p_trx_type,
      ddx_tcnv_rec);

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
    p11_a82 := ddx_tcnv_rec.canceled_date;
  end;

  procedure update_trx_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_status  VARCHAR2
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
  )

  as
    ddx_tcnv_rec okl_transaction_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.update_trx_status(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_status,
      ddx_tcnv_rec);

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
  end;

  procedure abandon_revisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p_contract_status  VARCHAR2
    , p_tsu_code  VARCHAR2
  )

  as
    ddp_rev_tbl okl_transaction_pvt.rev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_transaction_pvt_w.rosetta_table_copy_in_p11(ddp_rev_tbl, p5_a0
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.abandon_revisions(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rev_tbl,
      p_contract_status,
      p_tsu_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_contract_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_trx_date  date
  )

  as
    ddp_trx_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.check_contract_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_trx_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_contract_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p_stream_type_class  VARCHAR2
    , p_trx_date  date
  )

  as
    ddp_trx_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.check_contract_securitized(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_cle_id,
      p_stream_type_class,
      ddp_trx_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_service_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lease_id  NUMBER
    , p_service_id  NUMBER
    , p_description  VARCHAR2
    , p_trx_date  date
    , p_status  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  NUMBER
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  NUMBER
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  DATE
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  VARCHAR2
    , p10_a34 out nocopy  VARCHAR2
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  NUMBER
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  NUMBER
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  NUMBER
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  NUMBER
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  NUMBER
    , p10_a48 out nocopy  DATE
    , p10_a49 out nocopy  NUMBER
    , p10_a50 out nocopy  DATE
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  DATE
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  NUMBER
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  NUMBER
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  DATE
    , p10_a59 out nocopy  VARCHAR2
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
    , p10_a76 out nocopy  VARCHAR2
    , p10_a77 out nocopy  NUMBER
    , p10_a78 out nocopy  DATE
    , p10_a79 out nocopy  NUMBER
    , p10_a80 out nocopy  NUMBER
    , p10_a81 out nocopy  VARCHAR2
    , p10_a82 out nocopy  DATE
  )

  as
    ddp_trx_date date;
    ddx_tcnv_rec okl_transaction_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.create_service_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lease_id,
      p_service_id,
      p_description,
      ddp_trx_date,
      p_status,
      ddx_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p10_a2 := ddx_tcnv_rec.rbr_code;
    p10_a3 := ddx_tcnv_rec.rpy_code;
    p10_a4 := ddx_tcnv_rec.rvn_code;
    p10_a5 := ddx_tcnv_rec.trn_code;
    p10_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p10_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p10_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p10_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p10_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p10_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p10_a12 := ddx_tcnv_rec.tax_deductible_local;
    p10_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p10_a14 := ddx_tcnv_rec.date_accrual;
    p10_a15 := ddx_tcnv_rec.accrual_status_yn;
    p10_a16 := ddx_tcnv_rec.update_status_yn;
    p10_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p10_a18 := ddx_tcnv_rec.currency_code;
    p10_a19 := ddx_tcnv_rec.attribute_category;
    p10_a20 := ddx_tcnv_rec.attribute1;
    p10_a21 := ddx_tcnv_rec.attribute2;
    p10_a22 := ddx_tcnv_rec.attribute3;
    p10_a23 := ddx_tcnv_rec.attribute4;
    p10_a24 := ddx_tcnv_rec.attribute5;
    p10_a25 := ddx_tcnv_rec.attribute6;
    p10_a26 := ddx_tcnv_rec.attribute7;
    p10_a27 := ddx_tcnv_rec.attribute8;
    p10_a28 := ddx_tcnv_rec.attribute9;
    p10_a29 := ddx_tcnv_rec.attribute10;
    p10_a30 := ddx_tcnv_rec.attribute11;
    p10_a31 := ddx_tcnv_rec.attribute12;
    p10_a32 := ddx_tcnv_rec.attribute13;
    p10_a33 := ddx_tcnv_rec.attribute14;
    p10_a34 := ddx_tcnv_rec.attribute15;
    p10_a35 := ddx_tcnv_rec.tcn_type;
    p10_a36 := ddx_tcnv_rec.rjn_code;
    p10_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p10_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p10_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p10_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p10_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p10_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p10_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p10_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p10_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p10_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p10_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p10_a48 := ddx_tcnv_rec.program_update_date;
    p10_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p10_a50 := ddx_tcnv_rec.creation_date;
    p10_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p10_a52 := ddx_tcnv_rec.last_update_date;
    p10_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p10_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p10_a55 := ddx_tcnv_rec.tsu_code;
    p10_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p10_a57 := ddx_tcnv_rec.description;
    p10_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p10_a59 := ddx_tcnv_rec.trx_number;
    p10_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p10_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p10_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p10_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p10_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p10_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p10_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p10_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p10_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p10_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p10_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p10_a71 := ddx_tcnv_rec.accrual_activity;
    p10_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p10_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p10_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p10_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p10_a76 := ddx_tcnv_rec.currency_conversion_type;
    p10_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p10_a78 := ddx_tcnv_rec.currency_conversion_date;
    p10_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p10_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p10_a81 := ddx_tcnv_rec.source_trx_type;
    p10_a82 := ddx_tcnv_rec.canceled_date;
  end;

  procedure create_ppd_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_trx_date  date
    , p_trx_type  VARCHAR2
    , p_reason_code  VARCHAR2
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
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  DATE
    , p9_a79 out nocopy  NUMBER
    , p9_a80 out nocopy  NUMBER
    , p9_a81 out nocopy  VARCHAR2
    , p9_a82 out nocopy  DATE
  )

  as
    ddp_trx_date date;
    ddx_tcnv_rec okl_transaction_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_trx_date := rosetta_g_miss_date_in_map(p_trx_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_transaction_pvt.create_ppd_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_trx_date,
      p_trx_type,
      p_reason_code,
      ddx_tcnv_rec);

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
    p9_a71 := ddx_tcnv_rec.accrual_activity;
    p9_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p9_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p9_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p9_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p9_a76 := ddx_tcnv_rec.currency_conversion_type;
    p9_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p9_a78 := ddx_tcnv_rec.currency_conversion_date;
    p9_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p9_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p9_a81 := ddx_tcnv_rec.source_trx_type;
    p9_a82 := ddx_tcnv_rec.canceled_date;
  end;

end okl_transaction_pvt_w;

/
