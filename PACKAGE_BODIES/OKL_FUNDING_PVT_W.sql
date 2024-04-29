--------------------------------------------------------
--  DDL for Package Body OKL_FUNDING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FUNDING_PVT_W" as
  /* $Header: OKLEFUNB.pls 120.4 2007/11/20 08:27:11 dcshanmu noship $ */
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

  procedure get_fund_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddx_fnd_rec okl_funding_pvt.fnd_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.get_fund_summary(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_contract_id,
      ddx_fnd_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_fnd_rec.total_fundable_amount);
    p6_a1 := rosetta_g_miss_num_map(ddx_fnd_rec.total_pre_funded);
    p6_a2 := rosetta_g_miss_num_map(ddx_fnd_rec.total_assets_funded);
    p6_a3 := rosetta_g_miss_num_map(ddx_fnd_rec.total_expenses_funded);
    p6_a4 := rosetta_g_miss_num_map(ddx_fnd_rec.total_adjustments);
    p6_a5 := rosetta_g_miss_num_map(ddx_fnd_rec.total_remaining_to_fund);
    p6_a6 := rosetta_g_miss_num_map(ddx_fnd_rec.total_supplier_retention);
    p6_a7 := rosetta_g_miss_num_map(ddx_fnd_rec.total_borrower_payments);
    p6_a8 := rosetta_g_miss_num_map(ddx_fnd_rec.total_subsidies_funded);
    p6_a9 := rosetta_g_miss_num_map(ddx_fnd_rec.total_manual_disbursement);
  end;

  procedure create_funding_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
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
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  DATE
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_funding_pvt.tapv_rec_type;
    ddx_tapv_rec okl_funding_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);


    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.create_funding_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec,
      ddx_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tapv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tapv_rec.object_version_number);
    p6_a2 := ddx_tapv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_tapv_rec.cct_id);
    p6_a4 := ddx_tapv_rec.currency_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_tapv_rec.ccf_id);
    p6_a6 := ddx_tapv_rec.funding_type_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_tapv_rec.khr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tapv_rec.art_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tapv_rec.tap_id_reverses);
    p6_a10 := rosetta_g_miss_num_map(ddx_tapv_rec.ippt_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tapv_rec.code_combination_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_tapv_rec.ipvs_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tapv_rec.tcn_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_tapv_rec.vpa_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_tapv_rec.ipt_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_tapv_rec.qte_id);
    p6_a17 := ddx_tapv_rec.invoice_category_code;
    p6_a18 := ddx_tapv_rec.payment_method_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_tapv_rec.cplv_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tapv_rec.pox_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tapv_rec.amount);
    p6_a22 := ddx_tapv_rec.date_invoiced;
    p6_a23 := ddx_tapv_rec.invoice_number;
    p6_a24 := ddx_tapv_rec.date_funding_approved;
    p6_a25 := ddx_tapv_rec.date_gl;
    p6_a26 := ddx_tapv_rec.workflow_yn;
    p6_a27 := ddx_tapv_rec.match_required_yn;
    p6_a28 := ddx_tapv_rec.ipt_frequency;
    p6_a29 := ddx_tapv_rec.consolidate_yn;
    p6_a30 := ddx_tapv_rec.wait_vendor_invoice_yn;
    p6_a31 := ddx_tapv_rec.date_requisition;
    p6_a32 := ddx_tapv_rec.description;
    p6_a33 := ddx_tapv_rec.currency_conversion_type;
    p6_a34 := rosetta_g_miss_num_map(ddx_tapv_rec.currency_conversion_rate);
    p6_a35 := ddx_tapv_rec.currency_conversion_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tapv_rec.vendor_id);
    p6_a37 := ddx_tapv_rec.attribute_category;
    p6_a38 := ddx_tapv_rec.attribute1;
    p6_a39 := ddx_tapv_rec.attribute2;
    p6_a40 := ddx_tapv_rec.attribute3;
    p6_a41 := ddx_tapv_rec.attribute4;
    p6_a42 := ddx_tapv_rec.attribute5;
    p6_a43 := ddx_tapv_rec.attribute6;
    p6_a44 := ddx_tapv_rec.attribute7;
    p6_a45 := ddx_tapv_rec.attribute8;
    p6_a46 := ddx_tapv_rec.attribute9;
    p6_a47 := ddx_tapv_rec.attribute10;
    p6_a48 := ddx_tapv_rec.attribute11;
    p6_a49 := ddx_tapv_rec.attribute12;
    p6_a50 := ddx_tapv_rec.attribute13;
    p6_a51 := ddx_tapv_rec.attribute14;
    p6_a52 := ddx_tapv_rec.attribute15;
    p6_a53 := ddx_tapv_rec.date_entered;
    p6_a54 := ddx_tapv_rec.trx_status_code;
    p6_a55 := rosetta_g_miss_num_map(ddx_tapv_rec.set_of_books_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_tapv_rec.try_id);
    p6_a57 := rosetta_g_miss_num_map(ddx_tapv_rec.request_id);
    p6_a58 := rosetta_g_miss_num_map(ddx_tapv_rec.program_application_id);
    p6_a59 := rosetta_g_miss_num_map(ddx_tapv_rec.program_id);
    p6_a60 := ddx_tapv_rec.program_update_date;
    p6_a61 := rosetta_g_miss_num_map(ddx_tapv_rec.org_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_tapv_rec.created_by);
    p6_a63 := ddx_tapv_rec.creation_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_tapv_rec.last_updated_by);
    p6_a65 := ddx_tapv_rec.last_update_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_tapv_rec.last_update_login);
    p6_a67 := ddx_tapv_rec.invoice_type;
    p6_a68 := ddx_tapv_rec.pay_group_lookup_code;
    p6_a69 := ddx_tapv_rec.vendor_invoice_number;
    p6_a70 := ddx_tapv_rec.nettable_yn;
    p6_a71 := rosetta_g_miss_num_map(ddx_tapv_rec.asset_tap_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_tapv_rec.legal_entity_id);
    p6_a73 := ddx_tapv_rec.transaction_date;
  end;

  procedure update_funding_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
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
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  DATE
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_funding_pvt.tapv_rec_type;
    ddx_tapv_rec okl_funding_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);


    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.update_funding_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec,
      ddx_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tapv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tapv_rec.object_version_number);
    p6_a2 := ddx_tapv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_tapv_rec.cct_id);
    p6_a4 := ddx_tapv_rec.currency_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_tapv_rec.ccf_id);
    p6_a6 := ddx_tapv_rec.funding_type_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_tapv_rec.khr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tapv_rec.art_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tapv_rec.tap_id_reverses);
    p6_a10 := rosetta_g_miss_num_map(ddx_tapv_rec.ippt_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tapv_rec.code_combination_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_tapv_rec.ipvs_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tapv_rec.tcn_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_tapv_rec.vpa_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_tapv_rec.ipt_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_tapv_rec.qte_id);
    p6_a17 := ddx_tapv_rec.invoice_category_code;
    p6_a18 := ddx_tapv_rec.payment_method_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_tapv_rec.cplv_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tapv_rec.pox_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tapv_rec.amount);
    p6_a22 := ddx_tapv_rec.date_invoiced;
    p6_a23 := ddx_tapv_rec.invoice_number;
    p6_a24 := ddx_tapv_rec.date_funding_approved;
    p6_a25 := ddx_tapv_rec.date_gl;
    p6_a26 := ddx_tapv_rec.workflow_yn;
    p6_a27 := ddx_tapv_rec.match_required_yn;
    p6_a28 := ddx_tapv_rec.ipt_frequency;
    p6_a29 := ddx_tapv_rec.consolidate_yn;
    p6_a30 := ddx_tapv_rec.wait_vendor_invoice_yn;
    p6_a31 := ddx_tapv_rec.date_requisition;
    p6_a32 := ddx_tapv_rec.description;
    p6_a33 := ddx_tapv_rec.currency_conversion_type;
    p6_a34 := rosetta_g_miss_num_map(ddx_tapv_rec.currency_conversion_rate);
    p6_a35 := ddx_tapv_rec.currency_conversion_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tapv_rec.vendor_id);
    p6_a37 := ddx_tapv_rec.attribute_category;
    p6_a38 := ddx_tapv_rec.attribute1;
    p6_a39 := ddx_tapv_rec.attribute2;
    p6_a40 := ddx_tapv_rec.attribute3;
    p6_a41 := ddx_tapv_rec.attribute4;
    p6_a42 := ddx_tapv_rec.attribute5;
    p6_a43 := ddx_tapv_rec.attribute6;
    p6_a44 := ddx_tapv_rec.attribute7;
    p6_a45 := ddx_tapv_rec.attribute8;
    p6_a46 := ddx_tapv_rec.attribute9;
    p6_a47 := ddx_tapv_rec.attribute10;
    p6_a48 := ddx_tapv_rec.attribute11;
    p6_a49 := ddx_tapv_rec.attribute12;
    p6_a50 := ddx_tapv_rec.attribute13;
    p6_a51 := ddx_tapv_rec.attribute14;
    p6_a52 := ddx_tapv_rec.attribute15;
    p6_a53 := ddx_tapv_rec.date_entered;
    p6_a54 := ddx_tapv_rec.trx_status_code;
    p6_a55 := rosetta_g_miss_num_map(ddx_tapv_rec.set_of_books_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_tapv_rec.try_id);
    p6_a57 := rosetta_g_miss_num_map(ddx_tapv_rec.request_id);
    p6_a58 := rosetta_g_miss_num_map(ddx_tapv_rec.program_application_id);
    p6_a59 := rosetta_g_miss_num_map(ddx_tapv_rec.program_id);
    p6_a60 := ddx_tapv_rec.program_update_date;
    p6_a61 := rosetta_g_miss_num_map(ddx_tapv_rec.org_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_tapv_rec.created_by);
    p6_a63 := ddx_tapv_rec.creation_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_tapv_rec.last_updated_by);
    p6_a65 := ddx_tapv_rec.last_update_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_tapv_rec.last_update_login);
    p6_a67 := ddx_tapv_rec.invoice_type;
    p6_a68 := ddx_tapv_rec.pay_group_lookup_code;
    p6_a69 := ddx_tapv_rec.vendor_invoice_number;
    p6_a70 := ddx_tapv_rec.nettable_yn;
    p6_a71 := rosetta_g_miss_num_map(ddx_tapv_rec.asset_tap_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_tapv_rec.legal_entity_id);
    p6_a73 := ddx_tapv_rec.transaction_date;
  end;

  procedure create_funding_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_2000
    , p5_a21 JTF_VARCHAR2_TABLE_3000
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
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_3000
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
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddx_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tpl_pvt_w.rosetta_table_copy_in_p8(ddp_tplv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.create_funding_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tplv_tbl,
      ddx_tplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tpl_pvt_w.rosetta_table_copy_out_p8(ddx_tplv_tbl, p6_a0
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
      );
  end;

  procedure create_funding_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_hdr_id  NUMBER
    , p_khr_id  NUMBER
    , p_vendor_site_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_DATE_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_3000
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_DATE_TABLE
    , p8_a42 out nocopy JTF_NUMBER_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_DATE_TABLE
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_DATE_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.create_funding_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_hdr_id,
      p_khr_id,
      p_vendor_site_id,
      ddx_tplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_tpl_pvt_w.rosetta_table_copy_out_p8(ddx_tplv_tbl, p8_a0
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
      );
  end;

  procedure update_funding_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_2000
    , p5_a21 JTF_VARCHAR2_TABLE_3000
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
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_3000
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
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddx_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tpl_pvt_w.rosetta_table_copy_in_p8(ddp_tplv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.update_funding_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tplv_tbl,
      ddx_tplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tpl_pvt_w.rosetta_table_copy_out_p8(ddx_tplv_tbl, p6_a0
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
      );
  end;

  procedure sync_header_amount(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_2000
    , p5_a21 JTF_VARCHAR2_TABLE_3000
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
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
  )

  as
    ddp_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tpl_pvt_w.rosetta_table_copy_in_p8(ddp_tplv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.sync_header_amount(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  function get_chr_exp_canbe_funded_amt(p_contract_id  NUMBER
    , p_vendor_site_id  NUMBER
    , p_due_date  date
  ) return number

  as
    ddp_due_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_due_date := rosetta_g_miss_date_in_map(p_due_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_funding_pvt.get_chr_exp_canbe_funded_amt(p_contract_id,
      p_vendor_site_id,
      ddp_due_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  function get_chr_exp_canbe_funded_amt(p_contract_id  NUMBER
    , p_due_date  date
  ) return number

  as
    ddp_due_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_due_date := rosetta_g_miss_date_in_map(p_due_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_funding_pvt.get_chr_exp_canbe_funded_amt(p_contract_id,
      ddp_due_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  function is_kle_id_unique(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_VARCHAR2_TABLE_100
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_DATE_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_NUMBER_TABLE
    , p0_a17 JTF_NUMBER_TABLE
    , p0_a18 JTF_NUMBER_TABLE
    , p0_a19 JTF_NUMBER_TABLE
    , p0_a20 JTF_VARCHAR2_TABLE_2000
    , p0_a21 JTF_VARCHAR2_TABLE_3000
    , p0_a22 JTF_VARCHAR2_TABLE_100
    , p0_a23 JTF_VARCHAR2_TABLE_500
    , p0_a24 JTF_VARCHAR2_TABLE_500
    , p0_a25 JTF_VARCHAR2_TABLE_500
    , p0_a26 JTF_VARCHAR2_TABLE_500
    , p0_a27 JTF_VARCHAR2_TABLE_500
    , p0_a28 JTF_VARCHAR2_TABLE_500
    , p0_a29 JTF_VARCHAR2_TABLE_500
    , p0_a30 JTF_VARCHAR2_TABLE_500
    , p0_a31 JTF_VARCHAR2_TABLE_500
    , p0_a32 JTF_VARCHAR2_TABLE_500
    , p0_a33 JTF_VARCHAR2_TABLE_500
    , p0_a34 JTF_VARCHAR2_TABLE_500
    , p0_a35 JTF_VARCHAR2_TABLE_500
    , p0_a36 JTF_VARCHAR2_TABLE_500
    , p0_a37 JTF_VARCHAR2_TABLE_500
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_DATE_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_DATE_TABLE
    , p0_a45 JTF_NUMBER_TABLE
    , p0_a46 JTF_DATE_TABLE
    , p0_a47 JTF_NUMBER_TABLE
    , p0_a48 JTF_VARCHAR2_TABLE_100
    , p0_a49 JTF_VARCHAR2_TABLE_100
    , p0_a50 JTF_NUMBER_TABLE
    , p0_a51 JTF_NUMBER_TABLE
    , p0_a52 JTF_VARCHAR2_TABLE_100
    , p0_a53 JTF_NUMBER_TABLE
  ) return varchar2

  as
    ddp_tplv_tbl okl_funding_pvt.tplv_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    okl_tpl_pvt_w.rosetta_table_copy_in_p8(ddp_tplv_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      );

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_funding_pvt.is_kle_id_unique(ddp_tplv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    return ddrosetta_retval;
  end;

  procedure contract_fee_canbe_funded(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_value out nocopy  NUMBER
    , p_contract_id  NUMBER
    , p_fee_line_id  NUMBER
    , p_effective_date  date
  )

  as
    ddp_effective_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.contract_fee_canbe_funded(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_value,
      p_contract_id,
      p_fee_line_id,
      ddp_effective_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  function get_chr_fee_canbe_funded_amt(p_contract_id  NUMBER
    , p_fee_line_id  NUMBER
    , p_effective_date  date
  ) return number

  as
    ddp_effective_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_effective_date := rosetta_g_miss_date_in_map(p_effective_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_funding_pvt.get_chr_fee_canbe_funded_amt(p_contract_id,
      p_fee_line_id,
      ddp_effective_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  procedure is_contract_fully_funded(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_value out nocopy  number
    , p_contract_id  NUMBER
  )

  as
    ddx_value boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_funding_pvt.is_contract_fully_funded(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_value,
      p_contract_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  if ddx_value is null
    then x_value := null;
  elsif ddx_value
    then x_value := 1;
  else x_value := 0;
  end if;

  end;

  procedure is_contract_fully_funded(p_contract_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_funding_pvt.is_contract_fully_funded(p_contract_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

end okl_funding_pvt_w;

/
