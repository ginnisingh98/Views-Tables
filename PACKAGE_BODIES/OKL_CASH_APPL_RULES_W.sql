--------------------------------------------------------
--  DDL for Package Body OKL_CASH_APPL_RULES_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_APPL_RULES_W" as
  /* $Header: OKLECAPB.pls 120.3 2007/08/02 15:52:06 nikshah ship $ */
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

  procedure okl_installed(p_org_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_cash_appl_rules.okl_installed(p_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure handle_manual_pay(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cons_bill_id  NUMBER
    , p_cons_bill_num  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_currency_conv_type  VARCHAR2
    , p_currency_conv_date  date
    , p_currency_conv_rate  NUMBER
    , p_irm_id  NUMBER
    , p_check_number  VARCHAR2
    , p_rcpt_amount  NUMBER
    , p_contract_id  NUMBER
    , p_contract_num  VARCHAR2
    , p_customer_id  NUMBER
    , p_customer_num  NUMBER
    , p_gl_date  date
    , p_receipt_date  date
    , p_bank_account_id  NUMBER
    , p_comments  VARCHAR2
    , p_create_receipt_flag  VARCHAR2
  )

  as
    ddp_currency_conv_date date;
    ddp_gl_date date;
    ddp_receipt_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_currency_conv_date := rosetta_g_miss_date_in_map(p_currency_conv_date);









    ddp_gl_date := rosetta_g_miss_date_in_map(p_gl_date);

    ddp_receipt_date := rosetta_g_miss_date_in_map(p_receipt_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_cash_appl_rules.handle_manual_pay(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cons_bill_id,
      p_cons_bill_num,
      p_currency_code,
      p_currency_conv_type,
      ddp_currency_conv_date,
      p_currency_conv_rate,
      p_irm_id,
      p_check_number,
      p_rcpt_amount,
      p_contract_id,
      p_contract_num,
      p_customer_id,
      p_customer_num,
      ddp_gl_date,
      ddp_receipt_date,
      p_bank_account_id,
      p_comments,
      p_create_receipt_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















  end;

  procedure create_manual_receipt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cons_bill_id  NUMBER
    , p_ar_inv_id  NUMBER
    , p_contract_id  NUMBER
    , x_cash_receipt_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  DATE := fnd_api.g_miss_date
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_rcpt_rec okl_cash_appl_rules.rcpt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_rcpt_rec.cash_receipt_id := rosetta_g_miss_num_map(p8_a0);
    ddp_rcpt_rec.amount := rosetta_g_miss_num_map(p8_a1);
    ddp_rcpt_rec.currency_code := p8_a2;
    ddp_rcpt_rec.customer_number := p8_a3;
    ddp_rcpt_rec.customer_id := rosetta_g_miss_num_map(p8_a4);
    ddp_rcpt_rec.receipt_number := p8_a5;
    ddp_rcpt_rec.receipt_date := rosetta_g_miss_date_in_map(p8_a6);
    ddp_rcpt_rec.exchange_rate_type := p8_a7;
    ddp_rcpt_rec.exchange_rate := rosetta_g_miss_num_map(p8_a8);
    ddp_rcpt_rec.exchange_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_rcpt_rec.remittance_bank_account_id := rosetta_g_miss_num_map(p8_a10);
    ddp_rcpt_rec.remittance_bank_account_num := p8_a11;
    ddp_rcpt_rec.remittance_bank_account_name := p8_a12;
    ddp_rcpt_rec.payment_trx_extension_id := rosetta_g_miss_num_map(p8_a13);
    ddp_rcpt_rec.receipt_method_id := rosetta_g_miss_num_map(p8_a14);
    ddp_rcpt_rec.org_id := rosetta_g_miss_num_map(p8_a15);
    ddp_rcpt_rec.gl_date := rosetta_g_miss_date_in_map(p8_a16);
    ddp_rcpt_rec.dff_attribute_category := p8_a17;
    ddp_rcpt_rec.dff_attribute1 := p8_a18;
    ddp_rcpt_rec.dff_attribute2 := p8_a19;
    ddp_rcpt_rec.dff_attribute3 := p8_a20;
    ddp_rcpt_rec.dff_attribute4 := p8_a21;
    ddp_rcpt_rec.dff_attribute5 := p8_a22;
    ddp_rcpt_rec.dff_attribute6 := p8_a23;
    ddp_rcpt_rec.dff_attribute7 := p8_a24;
    ddp_rcpt_rec.dff_attribute8 := p8_a25;
    ddp_rcpt_rec.dff_attribute9 := p8_a26;
    ddp_rcpt_rec.dff_attribute10 := p8_a27;
    ddp_rcpt_rec.dff_attribute11 := p8_a28;
    ddp_rcpt_rec.dff_attribute12 := p8_a29;
    ddp_rcpt_rec.dff_attribute13 := p8_a30;
    ddp_rcpt_rec.dff_attribute14 := p8_a31;
    ddp_rcpt_rec.dff_attribute15 := p8_a32;


    -- here's the delegated call to the old PL/SQL routine
    okl_cash_appl_rules.create_manual_receipt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cons_bill_id,
      p_ar_inv_id,
      p_contract_id,
      ddp_rcpt_rec,
      x_cash_receipt_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end okl_cash_appl_rules_w;

/
