--------------------------------------------------------
--  DDL for Package Body LNS_PAYOFF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_PAYOFF_PUB_W" as
  /* $Header: LNS_PAYOFFJ_B.pls 120.0 2005/05/31 18:30:33 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_payoff_pub.invoice_details_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cust_trx_id := a0(indx);
          t(ddindx).payment_schedule_id := a1(indx);
          t(ddindx).invoice_number := a2(indx);
          t(ddindx).installment_number := a3(indx);
          t(ddindx).transaction_type := a4(indx);
          t(ddindx).remaining_amount := a5(indx);
          t(ddindx).due_date := a6(indx);
          t(ddindx).purpose := a7(indx);
          t(ddindx).billed_flag := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t lns_payoff_pub.invoice_details_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cust_trx_id;
          a1(indx) := t(ddindx).payment_schedule_id;
          a2(indx) := t(ddindx).invoice_number;
          a3(indx) := t(ddindx).installment_number;
          a4(indx) := t(ddindx).transaction_type;
          a5(indx) := t(ddindx).remaining_amount;
          a6(indx) := t(ddindx).due_date;
          a7(indx) := t(ddindx).purpose;
          a8(indx) := t(ddindx).billed_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy lns_payoff_pub.cash_receipt_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cash_receipt_id := a0(indx);
          t(ddindx).receipt_amount := a1(indx);
          t(ddindx).receipt_currency := a2(indx);
          t(ddindx).exchange_rate := a3(indx);
          t(ddindx).exchange_date := a4(indx);
          t(ddindx).exchange_rate_type := a5(indx);
          t(ddindx).original_currency := a6(indx);
          t(ddindx).receipt_number := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t lns_payoff_pub.cash_receipt_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cash_receipt_id;
          a1(indx) := t(ddindx).receipt_amount;
          a2(indx) := t(ddindx).receipt_currency;
          a3(indx) := t(ddindx).exchange_rate;
          a4(indx) := t(ddindx).exchange_date;
          a5(indx) := t(ddindx).exchange_rate_type;
          a6(indx) := t(ddindx).original_currency;
          a7(indx) := t(ddindx).receipt_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure processpayoff(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_payoff_date  DATE
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cash_receipt_ids lns_payoff_pub.cash_receipt_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    lns_payoff_pub_w.rosetta_table_copy_in_p3(ddp_cash_receipt_ids, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_payoff_pub.processpayoff(p_api_version,
      p_init_msg_list,
      p_loan_id,
      p_payoff_date,
      ddp_cash_receipt_ids,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure getloaninvoices(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_payoff_date  DATE
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_invoices_tbl lns_payoff_pub.invoice_details_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    lns_payoff_pub.getloaninvoices(p_api_version,
      p_init_msg_list,
      p_loan_id,
      p_payoff_date,
      ddx_invoices_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    lns_payoff_pub_w.rosetta_table_copy_out_p1(ddx_invoices_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      );



  end;

end lns_payoff_pub_w;

/
