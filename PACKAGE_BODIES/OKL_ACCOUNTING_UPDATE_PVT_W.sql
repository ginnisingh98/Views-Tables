--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_UPDATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_UPDATE_PVT_W" as
  /* $Header: OKLEAEUB.pls 120.1 2005/07/07 13:35:13 dkagrawa noship $ */
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

  procedure update_acct_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
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
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
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
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_accounting_update_pvt.aelv_rec_type;
    ddx_aelv_rec okl_accounting_update_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);


    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_update_pvt.update_acct_entries(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec,
      ddx_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aelv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_header_id);
    p6_a3 := ddx_aelv_rec.currency_conversion_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_aelv_rec.code_combination_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aelv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_number);
    p6_a7 := ddx_aelv_rec.ae_line_type_code;
    p6_a8 := ddx_aelv_rec.currency_conversion_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_aelv_rec.currency_conversion_rate);
    p6_a10 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_dr);
    p6_a11 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_cr);
    p6_a12 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_dr);
    p6_a13 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_cr);
    p6_a14 := ddx_aelv_rec.source_table;
    p6_a15 := rosetta_g_miss_num_map(ddx_aelv_rec.source_id);
    p6_a16 := ddx_aelv_rec.reference1;
    p6_a17 := ddx_aelv_rec.reference2;
    p6_a18 := ddx_aelv_rec.reference3;
    p6_a19 := ddx_aelv_rec.reference4;
    p6_a20 := ddx_aelv_rec.reference5;
    p6_a21 := ddx_aelv_rec.reference6;
    p6_a22 := ddx_aelv_rec.reference7;
    p6_a23 := ddx_aelv_rec.reference8;
    p6_a24 := ddx_aelv_rec.reference9;
    p6_a25 := ddx_aelv_rec.reference10;
    p6_a26 := ddx_aelv_rec.description;
    p6_a27 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_sub_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_aelv_rec.stat_amount);
    p6_a30 := ddx_aelv_rec.ussgl_transaction_code;
    p6_a31 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_id);
    p6_a32 := ddx_aelv_rec.accounting_error_code;
    p6_a33 := ddx_aelv_rec.gl_transfer_error_code;
    p6_a34 := rosetta_g_miss_num_map(ddx_aelv_rec.gl_sl_link_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_dr);
    p6_a36 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_cr);
    p6_a37 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_dr);
    p6_a38 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_cr);
    p6_a39 := ddx_aelv_rec.applied_from_trx_hdr_table;
    p6_a40 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_from_trx_hdr_id);
    p6_a41 := ddx_aelv_rec.applied_to_trx_hdr_table;
    p6_a42 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_to_trx_hdr_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_link_id);
    p6_a44 := ddx_aelv_rec.currency_code;
    p6_a45 := rosetta_g_miss_num_map(ddx_aelv_rec.program_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_aelv_rec.program_application_id);
    p6_a47 := ddx_aelv_rec.program_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_aelv_rec.request_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_aelv_rec.aeh_tbl_index);
    p6_a50 := rosetta_g_miss_num_map(ddx_aelv_rec.created_by);
    p6_a51 := ddx_aelv_rec.creation_date;
    p6_a52 := rosetta_g_miss_num_map(ddx_aelv_rec.last_updated_by);
    p6_a53 := ddx_aelv_rec.last_update_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_aelv_rec.last_update_login);
    p6_a55 := rosetta_g_miss_num_map(ddx_aelv_rec.account_overlay_source_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_value);
    p6_a57 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_code_id);
  end;

end okl_accounting_update_pvt_w;

/
