--------------------------------------------------------
--  DDL for Package Body OKL_RECEIPTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RECEIPTS_PVT_W" as
  /* $Header: OKLERCTB.pls 120.8 2008/05/14 11:22:38 sosharma noship $ */
  procedure rosetta_table_copy_in_p14(t out nocopy okl_receipts_pvt.appl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).con_inv_id := a1(indx);
          t(ddindx).ar_inv_id := a2(indx);
          t(ddindx).line_id := a3(indx);
          t(ddindx).original_applied_amount := a4(indx);
          t(ddindx).line_type := a5(indx);
          t(ddindx).amount_to_apply := a6(indx);
          t(ddindx).gl_date := a7(indx);
          t(ddindx).line_applied := a8(indx);
          t(ddindx).tax_applied := a9(indx);
          t(ddindx).trans_to_receipt_rate := a10(indx);
          t(ddindx).amount_applied_from := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t okl_receipts_pvt.appl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).con_inv_id;
          a2(indx) := t(ddindx).ar_inv_id;
          a3(indx) := t(ddindx).line_id;
          a4(indx) := t(ddindx).original_applied_amount;
          a5(indx) := t(ddindx).line_type;
          a6(indx) := t(ddindx).amount_to_apply;
          a7(indx) := t(ddindx).gl_date;
          a8(indx) := t(ddindx).line_applied;
          a9(indx) := t(ddindx).tax_applied;
          a10(indx) := t(ddindx).trans_to_receipt_rate;
          a11(indx) := t(ddindx).amount_applied_from;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure handle_receipt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  DATE
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , x_cash_receipt_id out nocopy  NUMBER
  )

  as
    ddp_rcpt_rec okl_receipts_pvt.rcpt_rec_type;
    ddp_appl_tbl okl_receipts_pvt.appl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rcpt_rec.cash_receipt_id := p5_a0;
    ddp_rcpt_rec.amount := p5_a1;
    ddp_rcpt_rec.currency_code := p5_a2;
    ddp_rcpt_rec.customer_number := p5_a3;
    ddp_rcpt_rec.customer_id := p5_a4;
    ddp_rcpt_rec.receipt_number := p5_a5;
    ddp_rcpt_rec.receipt_date := p5_a6;
    ddp_rcpt_rec.exchange_rate_type := p5_a7;
    ddp_rcpt_rec.exchange_rate := p5_a8;
    ddp_rcpt_rec.exchange_date := p5_a9;
    ddp_rcpt_rec.remittance_bank_account_id := p5_a10;
    ddp_rcpt_rec.customer_bank_account_id := p5_a11;
    ddp_rcpt_rec.remittance_bank_account_num := p5_a12;
    ddp_rcpt_rec.remittance_bank_account_name := p5_a13;
    ddp_rcpt_rec.payment_trx_extension_id := p5_a14;
    ddp_rcpt_rec.receipt_method_id := p5_a15;
    ddp_rcpt_rec.org_id := p5_a16;
    ddp_rcpt_rec.gl_date := p5_a17;
    ddp_rcpt_rec.dff_attribute_category := p5_a18;
    ddp_rcpt_rec.dff_attribute1 := p5_a19;
    ddp_rcpt_rec.dff_attribute2 := p5_a20;
    ddp_rcpt_rec.dff_attribute3 := p5_a21;
    ddp_rcpt_rec.dff_attribute4 := p5_a22;
    ddp_rcpt_rec.dff_attribute5 := p5_a23;
    ddp_rcpt_rec.dff_attribute6 := p5_a24;
    ddp_rcpt_rec.dff_attribute7 := p5_a25;
    ddp_rcpt_rec.dff_attribute8 := p5_a26;
    ddp_rcpt_rec.dff_attribute9 := p5_a27;
    ddp_rcpt_rec.dff_attribute10 := p5_a28;
    ddp_rcpt_rec.dff_attribute11 := p5_a29;
    ddp_rcpt_rec.dff_attribute12 := p5_a30;
    ddp_rcpt_rec.dff_attribute13 := p5_a31;
    ddp_rcpt_rec.dff_attribute14 := p5_a32;
    ddp_rcpt_rec.dff_attribute15 := p5_a33;
    ddp_rcpt_rec.create_mode := p5_a34;
    ddp_rcpt_rec.p_original_onacc_amount := p5_a35;
    ddp_rcpt_rec.p_apply_onacc_amount := p5_a36;

    okl_receipts_pvt_w.rosetta_table_copy_in_p14(ddp_appl_tbl, p6_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_receipts_pvt.handle_receipt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rcpt_rec,
      ddp_appl_tbl,
      x_cash_receipt_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_receipts_pvt_w;

/
