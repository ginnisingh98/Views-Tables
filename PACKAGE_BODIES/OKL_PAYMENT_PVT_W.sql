--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_PVT_W" as
  /* $Header: OKLEPAYB.pls 120.1 2007/10/11 16:16:12 asawanka noship $ */
  procedure rosetta_table_copy_in_p18(t out nocopy okl_payment_pvt.payment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).con_inv_id := a0(indx);
          t(ddindx).ar_inv_id := a1(indx);
          t(ddindx).line_id := a2(indx);
          t(ddindx).amount := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t okl_payment_pvt.payment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).con_inv_id;
          a1(indx) := t(ddindx).ar_inv_id;
          a2(indx) := t(ddindx).line_id;
          a3(indx) := t(ddindx).amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure create_payments(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  DATE
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , x_payment_ref_number out nocopy  VARCHAR2
    , x_cash_receipt_id out nocopy  NUMBER
  )

  as
    ddp_receipt_rec okl_payment_pvt.receipt_rec_type;
    ddp_payment_tbl okl_payment_pvt.payment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_receipt_rec.currency_code := p7_a0;
    ddp_receipt_rec.currency_conv_type := p7_a1;
    ddp_receipt_rec.currency_conv_date := p7_a2;
    ddp_receipt_rec.currency_conv_rate := p7_a3;
    ddp_receipt_rec.irm_id := p7_a4;
    ddp_receipt_rec.rem_bank_acc_id := p7_a5;
    ddp_receipt_rec.contract_id := p7_a6;
    ddp_receipt_rec.contract_num := p7_a7;
    ddp_receipt_rec.cust_acct_id := p7_a8;
    ddp_receipt_rec.customer_num := p7_a9;
    ddp_receipt_rec.gl_date := p7_a10;
    ddp_receipt_rec.payment_date := p7_a11;
    ddp_receipt_rec.customer_site_use_id := p7_a12;
    ddp_receipt_rec.expiration_date := p7_a13;
    ddp_receipt_rec.payment_trxn_extension_id := p7_a14;

    okl_payment_pvt_w.rosetta_table_copy_in_p18(ddp_payment_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_payment_pvt.create_payments(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_receipt_rec,
      ddp_payment_tbl,
      x_payment_ref_number,
      x_cash_receipt_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end okl_payment_pvt_w;

/
