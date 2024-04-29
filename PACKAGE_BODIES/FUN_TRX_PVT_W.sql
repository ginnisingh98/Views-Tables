--------------------------------------------------------
--  DDL for Package Body FUN_TRX_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRX_PVT_W" as
  /* $Header: fun_trx_pvt_w_b.pls 120.6.12010000.2 2010/01/27 05:36:24 ychandra ship $ */
  l_ccid numarray;
  procedure rosetta_table_copy_in_p5(t out nocopy fun_trx_pvt.batch_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).batch_id := a0(indx);
          t(ddindx).batch_number := a1(indx);
          t(ddindx).initiator_id := a2(indx);
          t(ddindx).from_le_id := a3(indx);
          t(ddindx).from_ledger_id := a4(indx);
          t(ddindx).control_total := a5(indx);
          t(ddindx).currency_code := a6(indx);
          t(ddindx).exchange_rate_type := a7(indx);
          t(ddindx).status := a8(indx);
          t(ddindx).description := a9(indx);
          t(ddindx).trx_type_id := a10(indx);
          t(ddindx).trx_type_code := a11(indx);
          t(ddindx).gl_date := a12(indx);
          t(ddindx).batch_date := a13(indx);
          t(ddindx).reject_allowed := a14(indx);
          t(ddindx).from_recurring_batch := a15(indx);
          t(ddindx).automatic_proration_flag := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t fun_trx_pvt.batch_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
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
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).batch_id;
          a1(indx) := t(ddindx).batch_number;
          a2(indx) := t(ddindx).initiator_id;
          a3(indx) := t(ddindx).from_le_id;
          a4(indx) := t(ddindx).from_ledger_id;
          a5(indx) := t(ddindx).control_total;
          a6(indx) := t(ddindx).currency_code;
          a7(indx) := t(ddindx).exchange_rate_type;
          a8(indx) := t(ddindx).status;
          a9(indx) := t(ddindx).description;
          a10(indx) := t(ddindx).trx_type_id;
          a11(indx) := t(ddindx).trx_type_code;
          a12(indx) := t(ddindx).gl_date;
          a13(indx) := t(ddindx).batch_date;
          a14(indx) := t(ddindx).reject_allowed;
          a15(indx) := t(ddindx).from_recurring_batch;
          a16(indx) := t(ddindx).automatic_proration_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy fun_trx_pvt.trx_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).trx_id := a0(indx);
          t(ddindx).initiator_id := a1(indx);
          t(ddindx).recipient_id := a2(indx);
          t(ddindx).to_le_id := a3(indx);
          t(ddindx).to_ledger_id := a4(indx);
          t(ddindx).batch_id := a5(indx);
          t(ddindx).status := a6(indx);
          t(ddindx).init_amount_cr := a7(indx);
          t(ddindx).init_amount_dr := a8(indx);
          t(ddindx).reci_amount_cr := a9(indx);
          t(ddindx).reci_amount_dr := a10(indx);
          t(ddindx).ar_invoice_number := a11(indx);
          t(ddindx).invoicing_rule := a12(indx);
          t(ddindx).approver_id := a13(indx);
          t(ddindx).approval_date := a14(indx);
          t(ddindx).original_trx_id := a15(indx);
          t(ddindx).reversed_trx_id := a16(indx);
          t(ddindx).from_recurring_trx_id := a17(indx);
          t(ddindx).initiator_instance := a18(indx);
          t(ddindx).recipient_instance := a19(indx);
          t(ddindx).automatic_proration_flag := a20(indx);
          t(ddindx).trx_number := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t fun_trx_pvt.trx_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
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
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).trx_id;
          a1(indx) := t(ddindx).initiator_id;
          a2(indx) := t(ddindx).recipient_id;
          a3(indx) := t(ddindx).to_le_id;
          a4(indx) := t(ddindx).to_ledger_id;
          a5(indx) := t(ddindx).batch_id;
          a6(indx) := t(ddindx).status;
          a7(indx) := t(ddindx).init_amount_cr;
          a8(indx) := t(ddindx).init_amount_dr;
          a9(indx) := t(ddindx).reci_amount_cr;
          a10(indx) := t(ddindx).reci_amount_dr;
          a11(indx) := t(ddindx).ar_invoice_number;
          a12(indx) := t(ddindx).invoicing_rule;
          a13(indx) := t(ddindx).approver_id;
          a14(indx) := t(ddindx).approval_date;
          a15(indx) := t(ddindx).original_trx_id;
          a16(indx) := t(ddindx).reversed_trx_id;
          a17(indx) := t(ddindx).from_recurring_trx_id;
          a18(indx) := t(ddindx).initiator_instance;
          a19(indx) := t(ddindx).recipient_instance;
          a20(indx) := t(ddindx).automatic_proration_flag;
          a21(indx) := t(ddindx).trx_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy fun_trx_pvt.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_id := a0(indx);
          t(ddindx).trx_id := a1(indx);
          t(ddindx).line_number := a2(indx);
          t(ddindx).line_type := a3(indx);
          t(ddindx).init_amount_cr := a4(indx);
          t(ddindx).init_amount_dr := a5(indx);
          t(ddindx).reci_amount_cr := a6(indx);
          t(ddindx).reci_amount_dr := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t fun_trx_pvt.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).line_id;
          a1(indx) := t(ddindx).trx_id;
          a2(indx) := t(ddindx).line_number;
          a3(indx) := t(ddindx).line_type;
          a4(indx) := t(ddindx).init_amount_cr;
          a5(indx) := t(ddindx).init_amount_dr;
          a6(indx) := t(ddindx).reci_amount_cr;
          a7(indx) := t(ddindx).reci_amount_dr;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy fun_trx_pvt.init_dist_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).batch_dist_id := a0(indx);
          t(ddindx).line_number := a1(indx);
          t(ddindx).batch_id := a2(indx);
          t(ddindx).ccid := a3(indx);
          t(ddindx).amount_cr := a4(indx);
          t(ddindx).amount_dr := a5(indx);
          t(ddindx).description := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t fun_trx_pvt.init_dist_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).batch_dist_id;
          a1(indx) := t(ddindx).line_number;
          a2(indx) := t(ddindx).batch_id;
          a3(indx) := t(ddindx).ccid;
          a4(indx) := t(ddindx).amount_cr;
          a5(indx) := t(ddindx).amount_dr;
          a6(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy fun_trx_pvt.dist_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).dist_id := a0(indx);
          t(ddindx).dist_number := a1(indx);
          t(ddindx).trx_id := a2(indx);
          t(ddindx).line_id := a3(indx);
          t(ddindx).party_id := a4(indx);
          t(ddindx).party_type := a5(indx);
          t(ddindx).dist_type := a6(indx);
          t(ddindx).batch_dist_id := a7(indx);
          t(ddindx).amount_cr := a8(indx);
          t(ddindx).amount_dr := a9(indx);
          t(ddindx).ccid := a10(indx);
          t(ddindx).trx_number := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t fun_trx_pvt.dist_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).dist_id;
          a1(indx) := t(ddindx).dist_number;
          a2(indx) := t(ddindx).trx_id;
          a3(indx) := t(ddindx).line_id;
          a4(indx) := t(ddindx).party_id;
          a5(indx) := t(ddindx).party_type;
          a6(indx) := t(ddindx).dist_type;
          a7(indx) := t(ddindx).batch_dist_id;
          a8(indx) := t(ddindx).amount_cr;
          a9(indx) := t(ddindx).amount_dr;
          a10(indx) := t(ddindx).ccid;
          a11(indx) := t(ddindx).trx_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy fun_trx_pvt.number_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t fun_trx_pvt.number_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure init_batch_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_insert  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  DATE
    , p7_a13 in out nocopy  DATE
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_DATE_TABLE
    , p8_a15 in out nocopy JTF_NUMBER_TABLE
    , p8_a16 in out nocopy JTF_NUMBER_TABLE
    , p8_a17 in out nocopy JTF_NUMBER_TABLE
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_NUMBER_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_NUMBER_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_batch_rec fun_trx_pvt.batch_rec_type;
    ddp_trx_tbl fun_trx_pvt.trx_tbl_type;
    ddp_init_dist_tbl fun_trx_pvt.init_dist_tbl_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_batch_rec.batch_id := p7_a0;
    ddp_batch_rec.batch_number := p7_a1;
    ddp_batch_rec.initiator_id := p7_a2;
    ddp_batch_rec.from_le_id := p7_a3;
    ddp_batch_rec.from_ledger_id := p7_a4;
    ddp_batch_rec.control_total := p7_a5;
    ddp_batch_rec.currency_code := p7_a6;
    ddp_batch_rec.exchange_rate_type := p7_a7;
    ddp_batch_rec.status := p7_a8;
    ddp_batch_rec.description := p7_a9;
    ddp_batch_rec.trx_type_id := p7_a10;
    ddp_batch_rec.trx_type_code := p7_a11;
    ddp_batch_rec.gl_date := p7_a12;
    ddp_batch_rec.batch_date := p7_a13;
    ddp_batch_rec.reject_allowed := p7_a14;
    ddp_batch_rec.from_recurring_batch := p7_a15;
    ddp_batch_rec.automatic_proration_flag := p7_a16;

    fun_trx_pvt_w.rosetta_table_copy_in_p6(ddp_trx_tbl, p8_a0
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
      );

    fun_trx_pvt_w.rosetta_table_copy_in_p8(ddp_init_dist_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      );

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      );

    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.init_batch_validate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_insert,
      ddp_batch_rec,
      ddp_trx_tbl,
      ddp_init_dist_tbl,
      ddp_dist_lines_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_batch_rec.batch_id;
    p7_a1 := ddp_batch_rec.batch_number;
    p7_a2 := ddp_batch_rec.initiator_id;
    p7_a3 := ddp_batch_rec.from_le_id;
    p7_a4 := ddp_batch_rec.from_ledger_id;
    p7_a5 := ddp_batch_rec.control_total;
    p7_a6 := ddp_batch_rec.currency_code;
    p7_a7 := ddp_batch_rec.exchange_rate_type;
    p7_a8 := ddp_batch_rec.status;
    p7_a9 := ddp_batch_rec.description;
    p7_a10 := ddp_batch_rec.trx_type_id;
    p7_a11 := ddp_batch_rec.trx_type_code;
    p7_a12 := ddp_batch_rec.gl_date;
    p7_a13 := ddp_batch_rec.batch_date;
    p7_a14 := ddp_batch_rec.reject_allowed;
    p7_a15 := ddp_batch_rec.from_recurring_batch;
    p7_a16 := ddp_batch_rec.automatic_proration_flag;

    fun_trx_pvt_w.rosetta_table_copy_out_p6(ddp_trx_tbl, p8_a0
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
      );

    fun_trx_pvt_w.rosetta_table_copy_out_p8(ddp_init_dist_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      );

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      );
  end;

  procedure init_trx_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  NUMBER
    , p6_a9 in out nocopy  NUMBER
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  VARCHAR2
    , p6_a13 in out nocopy  NUMBER
    , p6_a14 in out nocopy  DATE
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  NUMBER
    , p6_a17 in out nocopy  NUMBER
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  VARCHAR2
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_currency_code  VARCHAR2
    , p_gl_date  DATE
    , p_trx_date  DATE
  )

  as
    ddp_trx_rec fun_trx_pvt.trx_rec_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_trx_rec.trx_id := p6_a0;
    ddp_trx_rec.initiator_id := p6_a1;
    ddp_trx_rec.recipient_id := p6_a2;
    ddp_trx_rec.to_le_id := p6_a3;
    ddp_trx_rec.to_ledger_id := p6_a4;
    ddp_trx_rec.batch_id := p6_a5;
    ddp_trx_rec.status := p6_a6;
    ddp_trx_rec.init_amount_cr := p6_a7;
    ddp_trx_rec.init_amount_dr := p6_a8;
    ddp_trx_rec.reci_amount_cr := p6_a9;
    ddp_trx_rec.reci_amount_dr := p6_a10;
    ddp_trx_rec.ar_invoice_number := p6_a11;
    ddp_trx_rec.invoicing_rule := p6_a12;
    ddp_trx_rec.approver_id := p6_a13;
    ddp_trx_rec.approval_date := p6_a14;
    ddp_trx_rec.original_trx_id := p6_a15;
    ddp_trx_rec.reversed_trx_id := p6_a16;
    ddp_trx_rec.from_recurring_trx_id := p6_a17;
    ddp_trx_rec.initiator_instance := p6_a18;
    ddp_trx_rec.recipient_instance := p6_a19;
    ddp_trx_rec.automatic_proration_flag := p6_a20;
    ddp_trx_rec.trx_number := p6_a21;

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      );




    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.init_trx_validate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trx_rec,
      ddp_dist_lines_tbl,
      p_currency_code,
      p_gl_date,
      p_trx_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddp_trx_rec.trx_id;
    p6_a1 := ddp_trx_rec.initiator_id;
    p6_a2 := ddp_trx_rec.recipient_id;
    p6_a3 := ddp_trx_rec.to_le_id;
    p6_a4 := ddp_trx_rec.to_ledger_id;
    p6_a5 := ddp_trx_rec.batch_id;
    p6_a6 := ddp_trx_rec.status;
    p6_a7 := ddp_trx_rec.init_amount_cr;
    p6_a8 := ddp_trx_rec.init_amount_dr;
    p6_a9 := ddp_trx_rec.reci_amount_cr;
    p6_a10 := ddp_trx_rec.reci_amount_dr;
    p6_a11 := ddp_trx_rec.ar_invoice_number;
    p6_a12 := ddp_trx_rec.invoicing_rule;
    p6_a13 := ddp_trx_rec.approver_id;
    p6_a14 := ddp_trx_rec.approval_date;
    p6_a15 := ddp_trx_rec.original_trx_id;
    p6_a16 := ddp_trx_rec.reversed_trx_id;
    p6_a17 := ddp_trx_rec.from_recurring_trx_id;
    p6_a18 := ddp_trx_rec.initiator_instance;
    p6_a19 := ddp_trx_rec.recipient_instance;
    p6_a20 := ddp_trx_rec.automatic_proration_flag;
    p6_a21 := ddp_trx_rec.trx_number;

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      );



  end;

  procedure init_dist_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_le_id  NUMBER
    , p_ledger_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
  )

  as
    ddp_init_dist_rec fun_trx_pvt.init_dist_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_init_dist_rec.batch_dist_id := p8_a0;
    ddp_init_dist_rec.line_number := p8_a1;
    ddp_init_dist_rec.batch_id := p8_a2;
    ddp_init_dist_rec.ccid := p8_a3;
    ddp_init_dist_rec.amount_cr := p8_a4;
    ddp_init_dist_rec.amount_dr := p8_a5;
    ddp_init_dist_rec.description := p8_a6;

    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.init_dist_validate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_le_id,
      p_ledger_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_init_dist_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_init_dist_rec.batch_dist_id;
    p8_a1 := ddp_init_dist_rec.line_number;
    p8_a2 := ddp_init_dist_rec.batch_id;
    p8_a3 := ddp_init_dist_rec.ccid;
    p8_a4 := ddp_init_dist_rec.amount_cr;
    p8_a5 := ddp_init_dist_rec.amount_dr;
    p8_a6 := ddp_init_dist_rec.description;
  end;

  procedure init_ic_dist_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_le_id  NUMBER
    , p_ledger_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  VARCHAR2
  )

  as
    ddp_dist_line_rec fun_trx_pvt.dist_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_dist_line_rec.dist_id := p8_a0;
    ddp_dist_line_rec.dist_number := p8_a1;
    ddp_dist_line_rec.trx_id := p8_a2;
    ddp_dist_line_rec.line_id := p8_a3;
    ddp_dist_line_rec.party_id := p8_a4;
    ddp_dist_line_rec.party_type := p8_a5;
    ddp_dist_line_rec.dist_type := p8_a6;
    ddp_dist_line_rec.batch_dist_id := p8_a7;
    ddp_dist_line_rec.amount_cr := p8_a8;
    ddp_dist_line_rec.amount_dr := p8_a9;
    ddp_dist_line_rec.ccid := p8_a10;
    ddp_dist_line_rec.trx_number := p8_a11;

    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.init_ic_dist_validate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_le_id,
      p_ledger_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dist_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_dist_line_rec.dist_id;
    p8_a1 := ddp_dist_line_rec.dist_number;
    p8_a2 := ddp_dist_line_rec.trx_id;
    p8_a3 := ddp_dist_line_rec.line_id;
    p8_a4 := ddp_dist_line_rec.party_id;
    p8_a5 := ddp_dist_line_rec.party_type;
    p8_a6 := ddp_dist_line_rec.dist_type;
    p8_a7 := ddp_dist_line_rec.batch_dist_id;
    p8_a8 := ddp_dist_line_rec.amount_cr;
    p8_a9 := ddp_dist_line_rec.amount_dr;
    p8_a10 := ddp_dist_line_rec.ccid;
    p8_a11 := ddp_dist_line_rec.trx_number;
  end;

  procedure init_generate_distributions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  DATE
    , p5_a13 in out nocopy  DATE
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  NUMBER
    , p5_a16 in out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 in out nocopy JTF_NUMBER_TABLE
    , p6_a14 in out nocopy JTF_DATE_TABLE
    , p6_a15 in out nocopy JTF_NUMBER_TABLE
    , p6_a16 in out nocopy JTF_NUMBER_TABLE
    , p6_a17 in out nocopy JTF_NUMBER_TABLE
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_batch_rec fun_trx_pvt.batch_rec_type;
    ddp_trx_tbl fun_trx_pvt.trx_tbl_type;
    ddp_init_dist_tbl fun_trx_pvt.init_dist_tbl_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_batch_rec.batch_id := p5_a0;
    ddp_batch_rec.batch_number := p5_a1;
    ddp_batch_rec.initiator_id := p5_a2;
    ddp_batch_rec.from_le_id := p5_a3;
    ddp_batch_rec.from_ledger_id := p5_a4;
    ddp_batch_rec.control_total := p5_a5;
    ddp_batch_rec.currency_code := p5_a6;
    ddp_batch_rec.exchange_rate_type := p5_a7;
    ddp_batch_rec.status := p5_a8;
    ddp_batch_rec.description := p5_a9;
    ddp_batch_rec.trx_type_id := p5_a10;
    ddp_batch_rec.trx_type_code := p5_a11;
    ddp_batch_rec.gl_date := p5_a12;
    ddp_batch_rec.batch_date := p5_a13;
    ddp_batch_rec.reject_allowed := p5_a14;
    ddp_batch_rec.from_recurring_batch := p5_a15;
    ddp_batch_rec.automatic_proration_flag := p5_a16;

    fun_trx_pvt_w.rosetta_table_copy_in_p6(ddp_trx_tbl, p6_a0
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
      );

    fun_trx_pvt_w.rosetta_table_copy_in_p8(ddp_init_dist_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p8_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.init_generate_distributions(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_batch_rec,
      ddp_trx_tbl,
      ddp_init_dist_tbl,
      ddp_dist_lines_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_batch_rec.batch_id;
    p5_a1 := ddp_batch_rec.batch_number;
    p5_a2 := ddp_batch_rec.initiator_id;
    p5_a3 := ddp_batch_rec.from_le_id;
    p5_a4 := ddp_batch_rec.from_ledger_id;
    p5_a5 := ddp_batch_rec.control_total;
    p5_a6 := ddp_batch_rec.currency_code;
    p5_a7 := ddp_batch_rec.exchange_rate_type;
    p5_a8 := ddp_batch_rec.status;
    p5_a9 := ddp_batch_rec.description;
    p5_a10 := ddp_batch_rec.trx_type_id;
    p5_a11 := ddp_batch_rec.trx_type_code;
    p5_a12 := ddp_batch_rec.gl_date;
    p5_a13 := ddp_batch_rec.batch_date;
    p5_a14 := ddp_batch_rec.reject_allowed;
    p5_a15 := ddp_batch_rec.from_recurring_batch;
    p5_a16 := ddp_batch_rec.automatic_proration_flag;

    fun_trx_pvt_w.rosetta_table_copy_out_p6(ddp_trx_tbl, p6_a0
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
      );

    fun_trx_pvt_w.rosetta_table_copy_out_p8(ddp_init_dist_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p8_a0
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
      );
  end;

  procedure create_reverse_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_trx_tbl_id JTF_NUMBER_TABLE
    , p_reversed_batch_number  VARCHAR2
    , p_reversal_method  VARCHAR2
    , p_reversed_batch_date  DATE
    , p_reversed_gl_date  DATE
    , p_reversed_description  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_reversed_batch_id in out nocopy  NUMBER
  )

  as
    ddp_trx_tbl_id fun_trx_pvt.number_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    fun_trx_pvt_w.rosetta_table_copy_in_p10(ddp_trx_tbl_id, p_trx_tbl_id);








    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.create_reverse_trx(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_trx_tbl_id,
      p_reversed_batch_number,
      p_reversal_method,
      p_reversed_batch_date,
      p_reversed_gl_date,
      p_reversed_description,
      x_return_status,
      x_reversed_batch_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure recipient_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_batch_rec fun_trx_pvt.batch_rec_type;
    ddp_trx_rec fun_trx_pvt.trx_rec_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_batch_rec.batch_id := p6_a0;
    ddp_batch_rec.batch_number := p6_a1;
    ddp_batch_rec.initiator_id := p6_a2;
    ddp_batch_rec.from_le_id := p6_a3;
    ddp_batch_rec.from_ledger_id := p6_a4;
    ddp_batch_rec.control_total := p6_a5;
    ddp_batch_rec.currency_code := p6_a6;
    ddp_batch_rec.exchange_rate_type := p6_a7;
    ddp_batch_rec.status := p6_a8;
    ddp_batch_rec.description := p6_a9;
    ddp_batch_rec.trx_type_id := p6_a10;
    ddp_batch_rec.trx_type_code := p6_a11;
    ddp_batch_rec.gl_date := p6_a12;
    ddp_batch_rec.batch_date := p6_a13;
    ddp_batch_rec.reject_allowed := p6_a14;
    ddp_batch_rec.from_recurring_batch := p6_a15;
    ddp_batch_rec.automatic_proration_flag := p6_a16;

    ddp_trx_rec.trx_id := p7_a0;
    ddp_trx_rec.initiator_id := p7_a1;
    ddp_trx_rec.recipient_id := p7_a2;
    ddp_trx_rec.to_le_id := p7_a3;
    ddp_trx_rec.to_ledger_id := p7_a4;
    ddp_trx_rec.batch_id := p7_a5;
    ddp_trx_rec.status := p7_a6;
    ddp_trx_rec.init_amount_cr := p7_a7;
    ddp_trx_rec.init_amount_dr := p7_a8;
    ddp_trx_rec.reci_amount_cr := p7_a9;
    ddp_trx_rec.reci_amount_dr := p7_a10;
    ddp_trx_rec.ar_invoice_number := p7_a11;
    ddp_trx_rec.invoicing_rule := p7_a12;
    ddp_trx_rec.approver_id := p7_a13;
    ddp_trx_rec.approval_date := p7_a14;
    ddp_trx_rec.original_trx_id := p7_a15;
    ddp_trx_rec.reversed_trx_id := p7_a16;
    ddp_trx_rec.from_recurring_trx_id := p7_a17;
    ddp_trx_rec.initiator_instance := p7_a18;
    ddp_trx_rec.recipient_instance := p7_a19;
    ddp_trx_rec.automatic_proration_flag := p7_a20;
    ddp_trx_rec.trx_number := p7_a21;

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p8_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.recipient_validate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_batch_rec,
      ddp_trx_rec,
      ddp_dist_lines_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddp_batch_rec.batch_id;
    p6_a1 := ddp_batch_rec.batch_number;
    p6_a2 := ddp_batch_rec.initiator_id;
    p6_a3 := ddp_batch_rec.from_le_id;
    p6_a4 := ddp_batch_rec.from_ledger_id;
    p6_a5 := ddp_batch_rec.control_total;
    p6_a6 := ddp_batch_rec.currency_code;
    p6_a7 := ddp_batch_rec.exchange_rate_type;
    p6_a8 := ddp_batch_rec.status;
    p6_a9 := ddp_batch_rec.description;
    p6_a10 := ddp_batch_rec.trx_type_id;
    p6_a11 := ddp_batch_rec.trx_type_code;
    p6_a12 := ddp_batch_rec.gl_date;
    p6_a13 := ddp_batch_rec.batch_date;
    p6_a14 := ddp_batch_rec.reject_allowed;
    p6_a15 := ddp_batch_rec.from_recurring_batch;
    p6_a16 := ddp_batch_rec.automatic_proration_flag;

    p7_a0 := ddp_trx_rec.trx_id;
    p7_a1 := ddp_trx_rec.initiator_id;
    p7_a2 := ddp_trx_rec.recipient_id;
    p7_a3 := ddp_trx_rec.to_le_id;
    p7_a4 := ddp_trx_rec.to_ledger_id;
    p7_a5 := ddp_trx_rec.batch_id;
    p7_a6 := ddp_trx_rec.status;
    p7_a7 := ddp_trx_rec.init_amount_cr;
    p7_a8 := ddp_trx_rec.init_amount_dr;
    p7_a9 := ddp_trx_rec.reci_amount_cr;
    p7_a10 := ddp_trx_rec.reci_amount_dr;
    p7_a11 := ddp_trx_rec.ar_invoice_number;
    p7_a12 := ddp_trx_rec.invoicing_rule;
    p7_a13 := ddp_trx_rec.approver_id;
    p7_a14 := ddp_trx_rec.approval_date;
    p7_a15 := ddp_trx_rec.original_trx_id;
    p7_a16 := ddp_trx_rec.reversed_trx_id;
    p7_a17 := ddp_trx_rec.from_recurring_trx_id;
    p7_a18 := ddp_trx_rec.initiator_instance;
    p7_a19 := ddp_trx_rec.recipient_instance;
    p7_a20 := ddp_trx_rec.automatic_proration_flag;
    p7_a21 := ddp_trx_rec.trx_number;

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p8_a0
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
      );
  end;

    procedure Modified(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_batch_rec fun_trx_pvt.batch_rec_type;
    ddp_trx_rec fun_trx_pvt.trx_rec_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
    l_count Number;
    r_count Number;
    l_index NUMBER;
    l_approver_record	ame_util.approverRecord2;
    l_event_key     varchar2(240);
    --x_return_status VARCHAR2(10);
  begin
    -- copy data to the local IN or IN-OUT args, if any
    x_return_status:='N';
    ddp_batch_rec.batch_id := p6_a0;
    ddp_batch_rec.batch_number := p6_a1;
    ddp_batch_rec.initiator_id := p6_a2;
    ddp_batch_rec.from_le_id := p6_a3;
    ddp_batch_rec.from_ledger_id := p6_a4;
    ddp_batch_rec.control_total := p6_a5;
    ddp_batch_rec.currency_code := p6_a6;
    ddp_batch_rec.exchange_rate_type := p6_a7;
    ddp_batch_rec.status := p6_a8;
    ddp_batch_rec.description := p6_a9;
    ddp_batch_rec.trx_type_id := p6_a10;
    ddp_batch_rec.trx_type_code := p6_a11;
    ddp_batch_rec.gl_date := p6_a12;
    ddp_batch_rec.batch_date := p6_a13;
    ddp_batch_rec.reject_allowed := p6_a14;
    ddp_batch_rec.from_recurring_batch := p6_a15;
    ddp_batch_rec.automatic_proration_flag := p6_a16;

    ddp_trx_rec.trx_id := p7_a0;
    ddp_trx_rec.initiator_id := p7_a1;
    ddp_trx_rec.recipient_id := p7_a2;
    ddp_trx_rec.to_le_id := p7_a3;
    ddp_trx_rec.to_ledger_id := p7_a4;
    ddp_trx_rec.batch_id := p7_a5;
    ddp_trx_rec.status := p7_a6;
    ddp_trx_rec.init_amount_cr := p7_a7;
    ddp_trx_rec.init_amount_dr := p7_a8;
    ddp_trx_rec.reci_amount_cr := p7_a9;
    ddp_trx_rec.reci_amount_dr := p7_a10;
    ddp_trx_rec.ar_invoice_number := p7_a11;
    ddp_trx_rec.invoicing_rule := p7_a12;
    ddp_trx_rec.approver_id := p7_a13;
    ddp_trx_rec.approval_date := p7_a14;
    ddp_trx_rec.original_trx_id := p7_a15;
    ddp_trx_rec.reversed_trx_id := p7_a16;
    ddp_trx_rec.from_recurring_trx_id := p7_a17;
    ddp_trx_rec.initiator_instance := p7_a18;
    ddp_trx_rec.recipient_instance := p7_a19;
    ddp_trx_rec.automatic_proration_flag := p7_a20;
    ddp_trx_rec.trx_number := p7_a21;

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p8_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    --fun_trx_pvt.IS_MODIFIED(p_api_version,
      --p_init_msg_list,
      --p_validation_level,
      --x_return_status,
      --x_msg_count,
      --x_msg_data,
      --ddp_batch_rec,
      --ddp_trx_rec,
      --ddp_dist_lines_tbl);


      l_count := ddp_dist_lines_tbl.COUNT;
      l_approver_record.name  := fnd_global.user_id;
      l_approver_record.approval_status := NULL;


	IF l_count >= 1 THEN
         FOR  i IN 1..l_count LOOP
              -- There should be atleast one line for recipient distribution
              --Debug('3');
              BEGIN
                     ame_api2.updateApprovalStatus(
                        applicationIdIn     => 435,
                        transactionTypeIn   => 'FUN_IC_RECI_TRX',
                        transactionIdIn     => ddp_dist_lines_tbl(i).trx_id,
                        approverIn          => l_approver_record);


                      SELECT DISTINCT ITEM_KEY INTO l_event_key
                      from WF_ITEM_ACTIVITY_STATUSES WIAS
                      where WIAS.ITEM_TYPE = 'FUNRMAIN'
                      AND ITEM_KEY LIKE  ddp_batch_rec.batch_id || '_' || ddp_dist_lines_tbl(i).trx_id || '%';

                       WF_ENGINE.HandleError(itemtype => 'FUNRMAIN',
	                          itemkey  => l_event_key,
                            activity    => 'RECIPIENT_APPROVAL:START',
                            command    => 'RETRY');



                EXCEPTION
                 	WHEN NO_DATA_FOUND THEN
                 		x_return_status :='E';
                END;

         END LOOP;

  END IF;

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p6_a0 := ddp_batch_rec.batch_id;
    p6_a1 := ddp_batch_rec.batch_number;
    p6_a2 := ddp_batch_rec.initiator_id;
    p6_a3 := ddp_batch_rec.from_le_id;
    p6_a4 := ddp_batch_rec.from_ledger_id;
    p6_a5 := ddp_batch_rec.control_total;
    p6_a6 := ddp_batch_rec.currency_code;
    p6_a7 := ddp_batch_rec.exchange_rate_type;
    p6_a8 := ddp_batch_rec.status;
    p6_a9 := ddp_batch_rec.description;
    p6_a10 := ddp_batch_rec.trx_type_id;
    p6_a11 := ddp_batch_rec.trx_type_code;
    p6_a12 := ddp_batch_rec.gl_date;
    p6_a13 := ddp_batch_rec.batch_date;
    p6_a14 := ddp_batch_rec.reject_allowed;
    p6_a15 := ddp_batch_rec.from_recurring_batch;
    p6_a16 := ddp_batch_rec.automatic_proration_flag;

    p7_a0 := ddp_trx_rec.trx_id;
    p7_a1 := ddp_trx_rec.initiator_id;
    p7_a2 := ddp_trx_rec.recipient_id;
    p7_a3 := ddp_trx_rec.to_le_id;
    p7_a4 := ddp_trx_rec.to_ledger_id;
    p7_a5 := ddp_trx_rec.batch_id;
    p7_a6 := ddp_trx_rec.status;
    p7_a7 := ddp_trx_rec.init_amount_cr;
    p7_a8 := ddp_trx_rec.init_amount_dr;
    p7_a9 := ddp_trx_rec.reci_amount_cr;
    p7_a10 := ddp_trx_rec.reci_amount_dr;
    p7_a11 := ddp_trx_rec.ar_invoice_number;
    p7_a12 := ddp_trx_rec.invoicing_rule;
    p7_a13 := ddp_trx_rec.approver_id;
    p7_a14 := ddp_trx_rec.approval_date;
    p7_a15 := ddp_trx_rec.original_trx_id;
    p7_a16 := ddp_trx_rec.reversed_trx_id;
    p7_a17 := ddp_trx_rec.from_recurring_trx_id;
    p7_a18 := ddp_trx_rec.initiator_instance;
    p7_a19 := ddp_trx_rec.recipient_instance;
    p7_a20 := ddp_trx_rec.automatic_proration_flag;
    p7_a21 := ddp_trx_rec.trx_number;

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p8_a0
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
      );
  end;


   function isOldDistId(distId number) return varchar2
    is
    begin

    FOR i IN 1..l_ccid.COUNT
        LOOP
        if to_char(distId) = l_ccid(i-1) then
        return 'Y';
        end if;

    end loop;
    return 'N';
    end isOldDistId;

  procedure is_Modified(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_batch_rec fun_trx_pvt.batch_rec_type;
    ddp_trx_rec fun_trx_pvt.trx_rec_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
    l_count Number;
    r_count Number;
    l_index NUMBER;
    --l_ccid NUMBER;
    TYPE numarray IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
    l_ccid numarray;
    --x_return_status VARCHAR2(10);
  begin
    -- copy data to the local IN or IN-OUT args, if any
    x_return_status:='N';
    ddp_batch_rec.batch_id := p6_a0;
    ddp_batch_rec.batch_number := p6_a1;
    ddp_batch_rec.initiator_id := p6_a2;
    ddp_batch_rec.from_le_id := p6_a3;
    ddp_batch_rec.from_ledger_id := p6_a4;
    ddp_batch_rec.control_total := p6_a5;
    ddp_batch_rec.currency_code := p6_a6;
    ddp_batch_rec.exchange_rate_type := p6_a7;
    ddp_batch_rec.status := p6_a8;
    ddp_batch_rec.description := p6_a9;
    ddp_batch_rec.trx_type_id := p6_a10;
    ddp_batch_rec.trx_type_code := p6_a11;
    ddp_batch_rec.gl_date := p6_a12;
    ddp_batch_rec.batch_date := p6_a13;
    ddp_batch_rec.reject_allowed := p6_a14;
    ddp_batch_rec.from_recurring_batch := p6_a15;
    ddp_batch_rec.automatic_proration_flag := p6_a16;

    ddp_trx_rec.trx_id := p7_a0;
    ddp_trx_rec.initiator_id := p7_a1;
    ddp_trx_rec.recipient_id := p7_a2;
    ddp_trx_rec.to_le_id := p7_a3;
    ddp_trx_rec.to_ledger_id := p7_a4;
    ddp_trx_rec.batch_id := p7_a5;
    ddp_trx_rec.status := p7_a6;
    ddp_trx_rec.init_amount_cr := p7_a7;
    ddp_trx_rec.init_amount_dr := p7_a8;
    ddp_trx_rec.reci_amount_cr := p7_a9;
    ddp_trx_rec.reci_amount_dr := p7_a10;
    ddp_trx_rec.ar_invoice_number := p7_a11;
    ddp_trx_rec.invoicing_rule := p7_a12;
    ddp_trx_rec.approver_id := p7_a13;
    ddp_trx_rec.approval_date := p7_a14;
    ddp_trx_rec.original_trx_id := p7_a15;
    ddp_trx_rec.reversed_trx_id := p7_a16;
    ddp_trx_rec.from_recurring_trx_id := p7_a17;
    ddp_trx_rec.initiator_instance := p7_a18;
    ddp_trx_rec.recipient_instance := p7_a19;
    ddp_trx_rec.automatic_proration_flag := p7_a20;
    ddp_trx_rec.trx_number := p7_a21;

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p8_a0
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
      );

      l_count := ddp_dist_lines_tbl.COUNT;
      l_ccid(0):='0';
	IF l_count >= 1 THEN
         FOR  i IN 1..l_count LOOP
              -- There should be atleast one line for recipient distribution
                      --Debug('3');
              IF ddp_dist_lines_tbl(i).dist_type = 'L' and ddp_dist_lines_tbl(i).party_type='R' THEN

                BEGIN
              	   SELECT ( DIST_ID )
                   INTO l_ccid(i)
                   FROM fun_dist_lines
		   where TRX_ID = ddp_dist_lines_tbl(i).trx_id
                   AND ROWNUM=1
                   and PARTY_TYPE_FLAG='R'
		   and DIST_TYPE_FLAG='L'
                   and (AMOUNT_CR=ddp_dist_lines_tbl(i).amount_cr
                        OR AMOUNT_DR=ddp_dist_lines_tbl(i).amount_dr )
                    AND 'N' = fun_trx_pvt_w.isOldDistId(dist_id);
		   --and DIST_ID NOT IN (l_ccid(i-1));
                EXCEPTION
                 	WHEN NO_DATA_FOUND THEN
                 		x_return_status :='Y';
                        EXIT;

                 	WHEN OTHERS THEN
                 		x_return_status :='Y';
		 END;
		 EXIT;
                 l_index := i;

              END IF;
          END LOOP;
        END IF;

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p6_a0 := ddp_batch_rec.batch_id;
    p6_a1 := ddp_batch_rec.batch_number;
    p6_a2 := ddp_batch_rec.initiator_id;
    p6_a3 := ddp_batch_rec.from_le_id;
    p6_a4 := ddp_batch_rec.from_ledger_id;
    p6_a5 := ddp_batch_rec.control_total;
    p6_a6 := ddp_batch_rec.currency_code;
    p6_a7 := ddp_batch_rec.exchange_rate_type;
    p6_a8 := ddp_batch_rec.status;
    p6_a9 := ddp_batch_rec.description;
    p6_a10 := ddp_batch_rec.trx_type_id;
    p6_a11 := ddp_batch_rec.trx_type_code;
    p6_a12 := ddp_batch_rec.gl_date;
    p6_a13 := ddp_batch_rec.batch_date;
    p6_a14 := ddp_batch_rec.reject_allowed;
    p6_a15 := ddp_batch_rec.from_recurring_batch;
    p6_a16 := ddp_batch_rec.automatic_proration_flag;

    p7_a0 := ddp_trx_rec.trx_id;
    p7_a1 := ddp_trx_rec.initiator_id;
    p7_a2 := ddp_trx_rec.recipient_id;
    p7_a3 := ddp_trx_rec.to_le_id;
    p7_a4 := ddp_trx_rec.to_ledger_id;
    p7_a5 := ddp_trx_rec.batch_id;
    p7_a6 := ddp_trx_rec.status;
    p7_a7 := ddp_trx_rec.init_amount_cr;
    p7_a8 := ddp_trx_rec.init_amount_dr;
    p7_a9 := ddp_trx_rec.reci_amount_cr;
    p7_a10 := ddp_trx_rec.reci_amount_dr;
    p7_a11 := ddp_trx_rec.ar_invoice_number;
    p7_a12 := ddp_trx_rec.invoicing_rule;
    p7_a13 := ddp_trx_rec.approver_id;
    p7_a14 := ddp_trx_rec.approval_date;
    p7_a15 := ddp_trx_rec.original_trx_id;
    p7_a16 := ddp_trx_rec.reversed_trx_id;
    p7_a17 := ddp_trx_rec.from_recurring_trx_id;
    p7_a18 := ddp_trx_rec.initiator_instance;
    p7_a19 := ddp_trx_rec.recipient_instance;
    p7_a20 := ddp_trx_rec.automatic_proration_flag;
    p7_a21 := ddp_trx_rec.trx_number;

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p8_a0
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
      );
  end;



  procedure ini_recipient_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_batch_rec fun_trx_pvt.batch_rec_type;
    ddp_trx_rec fun_trx_pvt.trx_rec_type;
    ddp_dist_lines_tbl fun_trx_pvt.dist_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_batch_rec.batch_id := p6_a0;
    ddp_batch_rec.batch_number := p6_a1;
    ddp_batch_rec.initiator_id := p6_a2;
    ddp_batch_rec.from_le_id := p6_a3;
    ddp_batch_rec.from_ledger_id := p6_a4;
    ddp_batch_rec.control_total := p6_a5;
    ddp_batch_rec.currency_code := p6_a6;
    ddp_batch_rec.exchange_rate_type := p6_a7;
    ddp_batch_rec.status := p6_a8;
    ddp_batch_rec.description := p6_a9;
    ddp_batch_rec.trx_type_id := p6_a10;
    ddp_batch_rec.trx_type_code := p6_a11;
    ddp_batch_rec.gl_date := p6_a12;
    ddp_batch_rec.batch_date := p6_a13;
    ddp_batch_rec.reject_allowed := p6_a14;
    ddp_batch_rec.from_recurring_batch := p6_a15;
    ddp_batch_rec.automatic_proration_flag := p6_a16;

    ddp_trx_rec.trx_id := p7_a0;
    ddp_trx_rec.initiator_id := p7_a1;
    ddp_trx_rec.recipient_id := p7_a2;
    ddp_trx_rec.to_le_id := p7_a3;
    ddp_trx_rec.to_ledger_id := p7_a4;
    ddp_trx_rec.batch_id := p7_a5;
    ddp_trx_rec.status := p7_a6;
    ddp_trx_rec.init_amount_cr := p7_a7;
    ddp_trx_rec.init_amount_dr := p7_a8;
    ddp_trx_rec.reci_amount_cr := p7_a9;
    ddp_trx_rec.reci_amount_dr := p7_a10;
    ddp_trx_rec.ar_invoice_number := p7_a11;
    ddp_trx_rec.invoicing_rule := p7_a12;
    ddp_trx_rec.approver_id := p7_a13;
    ddp_trx_rec.approval_date := p7_a14;
    ddp_trx_rec.original_trx_id := p7_a15;
    ddp_trx_rec.reversed_trx_id := p7_a16;
    ddp_trx_rec.from_recurring_trx_id := p7_a17;
    ddp_trx_rec.initiator_instance := p7_a18;
    ddp_trx_rec.recipient_instance := p7_a19;
    ddp_trx_rec.automatic_proration_flag := p7_a20;
    ddp_trx_rec.trx_number := p7_a21;

    fun_trx_pvt_w.rosetta_table_copy_in_p9(ddp_dist_lines_tbl, p8_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    fun_trx_pvt.ini_recipient_validate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_batch_rec,
      ddp_trx_rec,
      ddp_dist_lines_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddp_batch_rec.batch_id;
    p6_a1 := ddp_batch_rec.batch_number;
    p6_a2 := ddp_batch_rec.initiator_id;
    p6_a3 := ddp_batch_rec.from_le_id;
    p6_a4 := ddp_batch_rec.from_ledger_id;
    p6_a5 := ddp_batch_rec.control_total;
    p6_a6 := ddp_batch_rec.currency_code;
    p6_a7 := ddp_batch_rec.exchange_rate_type;
    p6_a8 := ddp_batch_rec.status;
    p6_a9 := ddp_batch_rec.description;
    p6_a10 := ddp_batch_rec.trx_type_id;
    p6_a11 := ddp_batch_rec.trx_type_code;
    p6_a12 := ddp_batch_rec.gl_date;
    p6_a13 := ddp_batch_rec.batch_date;
    p6_a14 := ddp_batch_rec.reject_allowed;
    p6_a15 := ddp_batch_rec.from_recurring_batch;
    p6_a16 := ddp_batch_rec.automatic_proration_flag;

    p7_a0 := ddp_trx_rec.trx_id;
    p7_a1 := ddp_trx_rec.initiator_id;
    p7_a2 := ddp_trx_rec.recipient_id;
    p7_a3 := ddp_trx_rec.to_le_id;
    p7_a4 := ddp_trx_rec.to_ledger_id;
    p7_a5 := ddp_trx_rec.batch_id;
    p7_a6 := ddp_trx_rec.status;
    p7_a7 := ddp_trx_rec.init_amount_cr;
    p7_a8 := ddp_trx_rec.init_amount_dr;
    p7_a9 := ddp_trx_rec.reci_amount_cr;
    p7_a10 := ddp_trx_rec.reci_amount_dr;
    p7_a11 := ddp_trx_rec.ar_invoice_number;
    p7_a12 := ddp_trx_rec.invoicing_rule;
    p7_a13 := ddp_trx_rec.approver_id;
    p7_a14 := ddp_trx_rec.approval_date;
    p7_a15 := ddp_trx_rec.original_trx_id;
    p7_a16 := ddp_trx_rec.reversed_trx_id;
    p7_a17 := ddp_trx_rec.from_recurring_trx_id;
    p7_a18 := ddp_trx_rec.initiator_instance;
    p7_a19 := ddp_trx_rec.recipient_instance;
    p7_a20 := ddp_trx_rec.automatic_proration_flag;
    p7_a21 := ddp_trx_rec.trx_number;

    fun_trx_pvt_w.rosetta_table_copy_out_p9(ddp_dist_lines_tbl, p8_a0
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
      );
  end;
end fun_trx_pvt_w;

/
