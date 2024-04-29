--------------------------------------------------------
--  DDL for Package Body LNS_FINANCIALS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FINANCIALS_W" as
  /* $Header: LNS_FINANCIALJ_B.pls 120.7.12010000.5 2010/03/19 08:34:32 gparuchu ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_financials.rate_schedule_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate_id := a0(indx);
          t(ddindx).begin_date := a1(indx);
          t(ddindx).end_date := a2(indx);
          t(ddindx).annual_rate := a3(indx);
          t(ddindx).spread := a4(indx);
          t(ddindx).begin_installment_number := a5(indx);
          t(ddindx).end_installment_number := a6(indx);
          t(ddindx).interest_only_flag := a7(indx);
          t(ddindx).phase := a8(indx);
          t(ddindx).floating_flag := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t lns_financials.rate_schedule_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rate_id;
          a1(indx) := t(ddindx).begin_date;
          a2(indx) := t(ddindx).end_date;
          a3(indx) := t(ddindx).annual_rate;
          a4(indx) := t(ddindx).spread;
          a5(indx) := t(ddindx).begin_installment_number;
          a6(indx) := t(ddindx).end_installment_number;
          a7(indx) := t(ddindx).interest_only_flag;
          a8(indx) := t(ddindx).phase;
          a9(indx) := t(ddindx).floating_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy lns_financials.amortization_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_2000
    , a29 JTF_VARCHAR2_TABLE_2000
    , a30 JTF_VARCHAR2_TABLE_2000
    , a31 JTF_VARCHAR2_TABLE_2000
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).installment_number := a0(indx);
          t(ddindx).due_date := a1(indx);
          t(ddindx).period_start_date := a2(indx);
          t(ddindx).period_end_date := a3(indx);
          t(ddindx).principal_amount := a4(indx);
          t(ddindx).interest_amount := a5(indx);
          t(ddindx).normal_int_amount := a6(indx);
          t(ddindx).add_prin_int_amount := a7(indx);
          t(ddindx).add_int_int_amount := a8(indx);
          t(ddindx).penal_int_amount := a9(indx);
          t(ddindx).fee_amount := a10(indx);
          t(ddindx).other_amount := a11(indx);
          t(ddindx).begin_balance := a12(indx);
          t(ddindx).end_balance := a13(indx);
          t(ddindx).total := a14(indx);
          t(ddindx).interest_cumulative := a15(indx);
          t(ddindx).principal_cumulative := a16(indx);
          t(ddindx).fees_cumulative := a17(indx);
          t(ddindx).other_cumulative := a18(indx);
          t(ddindx).rate_id := a19(indx);
          t(ddindx).rate_unadj := a20(indx);
          t(ddindx).rate_change_freq := a21(indx);
          t(ddindx).source := a22(indx);
          t(ddindx).grand_total_flag := a23(indx);
          t(ddindx).unpaid_prin := a24(indx);
          t(ddindx).unpaid_int := a25(indx);
          t(ddindx).interest_rate := a26(indx);
          t(ddindx).funded_amount := a27(indx);
          t(ddindx).normal_int_details := a28(indx);
          t(ddindx).add_prin_int_details := a29(indx);
          t(ddindx).add_int_int_details := a30(indx);
          t(ddindx).penal_int_details := a31(indx);
          t(ddindx).disbursement_amount := a32(indx);
          t(ddindx).period := a33(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t lns_financials.amortization_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_2000();
    a29 := JTF_VARCHAR2_TABLE_2000();
    a30 := JTF_VARCHAR2_TABLE_2000();
    a31 := JTF_VARCHAR2_TABLE_2000();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_2000();
      a29 := JTF_VARCHAR2_TABLE_2000();
      a30 := JTF_VARCHAR2_TABLE_2000();
      a31 := JTF_VARCHAR2_TABLE_2000();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_200();
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
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).installment_number;
          a1(indx) := t(ddindx).due_date;
          a2(indx) := t(ddindx).period_start_date;
          a3(indx) := t(ddindx).period_end_date;
          a4(indx) := t(ddindx).principal_amount;
          a5(indx) := t(ddindx).interest_amount;
          a6(indx) := t(ddindx).normal_int_amount;
          a7(indx) := t(ddindx).add_prin_int_amount;
          a8(indx) := t(ddindx).add_int_int_amount;
          a9(indx) := t(ddindx).penal_int_amount;
          a10(indx) := t(ddindx).fee_amount;
          a11(indx) := t(ddindx).other_amount;
          a12(indx) := t(ddindx).begin_balance;
          a13(indx) := t(ddindx).end_balance;
          a14(indx) := t(ddindx).total;
          a15(indx) := t(ddindx).interest_cumulative;
          a16(indx) := t(ddindx).principal_cumulative;
          a17(indx) := t(ddindx).fees_cumulative;
          a18(indx) := t(ddindx).other_cumulative;
          a19(indx) := t(ddindx).rate_id;
          a20(indx) := t(ddindx).rate_unadj;
          a21(indx) := t(ddindx).rate_change_freq;
          a22(indx) := t(ddindx).source;
          a23(indx) := t(ddindx).grand_total_flag;
          a24(indx) := t(ddindx).unpaid_prin;
          a25(indx) := t(ddindx).unpaid_int;
          a26(indx) := t(ddindx).interest_rate;
          a27(indx) := t(ddindx).funded_amount;
          a28(indx) := t(ddindx).normal_int_details;
          a29(indx) := t(ddindx).add_prin_int_details;
          a30(indx) := t(ddindx).add_int_int_details;
          a31(indx) := t(ddindx).penal_int_details;
          a32(indx) := t(ddindx).disbursement_amount;
          a33(indx) := t(ddindx).period;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p6(t out nocopy lns_financials.payoff_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).total_principal_remaining := a0(indx);
          t(ddindx).unpaid_principal := a1(indx);
          t(ddindx).unbilled_principal := a2(indx);
          t(ddindx).total_interest_remaining := a3(indx);
          t(ddindx).unpaid_interest := a4(indx);
          t(ddindx).additional_interest_due := a5(indx);
          t(ddindx).total_fees_remaining := a6(indx);
          t(ddindx).unpaid_fees := a7(indx);
          t(ddindx).additional_fees_due := a8(indx);
          t(ddindx).due_date := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t lns_financials.payoff_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
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
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).total_principal_remaining;
          a1(indx) := t(ddindx).unpaid_principal;
          a2(indx) := t(ddindx).unbilled_principal;
          a3(indx) := t(ddindx).total_interest_remaining;
          a4(indx) := t(ddindx).unpaid_interest;
          a5(indx) := t(ddindx).additional_interest_due;
          a6(indx) := t(ddindx).total_fees_remaining;
          a7(indx) := t(ddindx).unpaid_fees;
          a8(indx) := t(ddindx).additional_fees_due;
          a9(indx) := t(ddindx).due_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy lns_financials.payoff_tbl2, a0 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).payoff_purpose := a0(indx);
          t(ddindx).billed_amount := a1(indx);
          t(ddindx).unbilled_amount := a2(indx);
          t(ddindx).total_amount := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t lns_financials.payoff_tbl2, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).payoff_purpose;
          a1(indx) := t(ddindx).billed_amount;
          a2(indx) := t(ddindx).unbilled_amount;
          a3(indx) := t(ddindx).total_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy lns_financials.loan_activity_tbl, a0 JTF_DATE_TABLE
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
          t(ddindx).activity_date := a0(indx);
          t(ddindx).activity_amount := a1(indx);
          t(ddindx).ending_balance := a2(indx);
          t(ddindx).days_at_balance := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t lns_financials.loan_activity_tbl, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).activity_date;
          a1(indx) := t(ddindx).activity_amount;
          a2(indx) := t(ddindx).ending_balance;
          a3(indx) := t(ddindx).days_at_balance;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy lns_financials.payment_schedule_tbl, a0 JTF_DATE_TABLE
    , a1 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).period_begin_date := a0(indx);
          t(ddindx).period_end_date := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t lns_financials.payment_schedule_tbl, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).period_begin_date;
          a1(indx) := t(ddindx).period_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p13(t out nocopy lns_financials.date_tbl, a0 JTF_DATE_TABLE) as
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
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t lns_financials.date_tbl, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
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
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p14(t out nocopy lns_financials.amount_tbl, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t lns_financials.amount_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p15(t out nocopy lns_financials.vchar_tbl, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t lns_financials.vchar_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p17(t out nocopy lns_financials.fees_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).fee_id := a0(indx);
          t(ddindx).fee_name := a1(indx);
          t(ddindx).fee_amount := a2(indx);
          t(ddindx).fee_installment := a3(indx);
          t(ddindx).fee_description := a4(indx);
          t(ddindx).fee_schedule_id := a5(indx);
          t(ddindx).fee_waivable_flag := a6(indx);
          t(ddindx).waive_amount := a7(indx);
          t(ddindx).billed_flag := a8(indx);
          t(ddindx).active_flag := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t lns_financials.fees_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).fee_id;
          a1(indx) := t(ddindx).fee_name;
          a2(indx) := t(ddindx).fee_amount;
          a3(indx) := t(ddindx).fee_installment;
          a4(indx) := t(ddindx).fee_description;
          a5(indx) := t(ddindx).fee_schedule_id;
          a6(indx) := t(ddindx).fee_waivable_flag;
          a7(indx) := t(ddindx).waive_amount;
          a8(indx) := t(ddindx).billed_flag;
          a9(indx) := t(ddindx).active_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure shiftloandates(p_loan_id  NUMBER
    , p_new_start_date  DATE
    , p_phase  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  DATE
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  NUMBER
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  NUMBER
    , p3_a14 out nocopy  NUMBER
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  NUMBER
    , p3_a17 out nocopy  NUMBER
    , p3_a18 out nocopy  NUMBER
    , p3_a19 out nocopy  DATE
    , p3_a20 out nocopy  NUMBER
    , p3_a21 out nocopy  NUMBER
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  NUMBER
    , p3_a26 out nocopy  NUMBER
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  NUMBER
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  NUMBER
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  DATE
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  DATE
    , p3_a37 out nocopy  VARCHAR2
    , p3_a38 out nocopy  NUMBER
    , p3_a39 out nocopy  NUMBER
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  DATE
    , p3_a43 out nocopy  DATE
    , p3_a44 out nocopy  DATE
    , p3_a45 out nocopy  VARCHAR2
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  NUMBER
    , p3_a48 out nocopy  NUMBER
    , p3_a49 out nocopy  VARCHAR2
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  NUMBER
    , p3_a52 out nocopy  DATE
    , p3_a53 out nocopy  NUMBER
    , p3_a54 out nocopy  NUMBER
    , p3_a55 out nocopy  NUMBER
    , p3_a56 out nocopy  NUMBER
    , p3_a57 out nocopy  NUMBER
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  NUMBER
    , p3_a60 out nocopy  DATE
    , p3_a61 out nocopy  NUMBER
    , p3_a62 out nocopy  NUMBER
    , p3_a63 out nocopy  NUMBER
    , p3_a64 out nocopy  NUMBER
    , p3_a65 out nocopy  NUMBER
    , p3_a66 out nocopy  VARCHAR2
    , p3_a67 out nocopy  VARCHAR2
    , p3_a68 out nocopy  VARCHAR2
    , p3_a69 out nocopy  VARCHAR2
    , p3_a70 out nocopy  NUMBER
    , p3_a71 out nocopy  NUMBER
    , p3_a72 out nocopy  NUMBER
    , p3_a73 out nocopy  NUMBER
    , p3_a74 out nocopy  DATE
    , p3_a75 out nocopy  DATE
    , p3_a76 out nocopy  VARCHAR2
    , p3_a77 out nocopy  VARCHAR2
    , p3_a78 out nocopy  VARCHAR2
    , p3_a79 out nocopy  VARCHAR2
    , p3_a80 out nocopy  DATE
    , p3_a81 out nocopy  VARCHAR2
    , p3_a82 out nocopy  NUMBER
    , p3_a83 out nocopy  NUMBER
    , p3_a84 out nocopy  VARCHAR2
    , p3_a85 out nocopy  NUMBER
    , p3_a86 out nocopy  NUMBER
    , p3_a87 out nocopy  NUMBER
    , p3_a88 out nocopy  NUMBER
    , p3_a89 out nocopy  NUMBER
    , p3_a90 out nocopy  VARCHAR2
    , x_dates_shifted_flag out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_loan_details lns_financials.loan_details_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    lns_financials.shiftloandates(p_loan_id,
      p_new_start_date,
      p_phase,
      ddx_loan_details,
      x_dates_shifted_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_loan_details.loan_id;
    p3_a1 := ddx_loan_details.loan_term;
    p3_a2 := ddx_loan_details.loan_term_period;
    p3_a3 := ddx_loan_details.amortized_term;
    p3_a4 := ddx_loan_details.amortized_term_period;
    p3_a5 := ddx_loan_details.amortization_frequency;
    p3_a6 := ddx_loan_details.payment_frequency;
    p3_a7 := ddx_loan_details.first_payment_date;
    p3_a8 := ddx_loan_details.loan_start_date;
    p3_a9 := ddx_loan_details.requested_amount;
    p3_a10 := ddx_loan_details.funded_amount;
    p3_a11 := ddx_loan_details.remaining_balance;
    p3_a12 := ddx_loan_details.principal_paid_to_date;
    p3_a13 := ddx_loan_details.interest_paid_to_date;
    p3_a14 := ddx_loan_details.fees_paid_to_date;
    p3_a15 := ddx_loan_details.unpaid_principal;
    p3_a16 := ddx_loan_details.unpaid_interest;
    p3_a17 := ddx_loan_details.unbilled_principal;
    p3_a18 := ddx_loan_details.billed_principal;
    p3_a19 := ddx_loan_details.maturity_date;
    p3_a20 := ddx_loan_details.number_installments;
    p3_a21 := ddx_loan_details.num_amortization_intervals;
    p3_a22 := ddx_loan_details.reamortize_overpay;
    p3_a23 := ddx_loan_details.reamortize_underpay;
    p3_a24 := ddx_loan_details.reamortize_with_interest;
    p3_a25 := ddx_loan_details.reamortize_amount;
    p3_a26 := ddx_loan_details.reamortize_from_installment;
    p3_a27 := ddx_loan_details.reamortize_to_installment;
    p3_a28 := ddx_loan_details.last_installment_billed;
    p3_a29 := ddx_loan_details.day_count_method;
    p3_a30 := ddx_loan_details.pay_in_arrears;
    if ddx_loan_details.pay_in_arrears_boolean is null
      then p3_a31 := null;
    elsif ddx_loan_details.pay_in_arrears_boolean
      then p3_a31 := 1;
    else p3_a31 := 0;
    end if;
    p3_a32 := ddx_loan_details.custom_schedule;
    p3_a33 := ddx_loan_details.loan_status;
    p3_a34 := ddx_loan_details.last_interest_accrual;
    p3_a35 := ddx_loan_details.last_activity;
    p3_a36 := ddx_loan_details.last_activity_date;
    p3_a37 := ddx_loan_details.loan_currency;
    p3_a38 := ddx_loan_details.currency_precision;
    p3_a39 := ddx_loan_details.open_term;
    p3_a40 := ddx_loan_details.open_term_period;
    p3_a41 := ddx_loan_details.open_payment_frequency;
    p3_a42 := ddx_loan_details.open_first_payment_date;
    p3_a43 := ddx_loan_details.open_start_date;
    p3_a44 := ddx_loan_details.open_maturity_date;
    p3_a45 := ddx_loan_details.loan_phase;
    p3_a46 := ddx_loan_details.balloon_payment_type;
    p3_a47 := ddx_loan_details.balloon_payment_amount;
    p3_a48 := ddx_loan_details.amortized_amount;
    p3_a49 := ddx_loan_details.rate_type;
    p3_a50 := ddx_loan_details.open_rate_chg_freq;
    p3_a51 := ddx_loan_details.open_index_rate_id;
    p3_a52 := ddx_loan_details.open_index_date;
    p3_a53 := ddx_loan_details.open_ceiling_rate;
    p3_a54 := ddx_loan_details.open_floor_rate;
    p3_a55 := ddx_loan_details.open_first_percent_increase;
    p3_a56 := ddx_loan_details.open_adj_percent_increase;
    p3_a57 := ddx_loan_details.open_life_percent_increase;
    p3_a58 := ddx_loan_details.term_rate_chg_freq;
    p3_a59 := ddx_loan_details.term_index_rate_id;
    p3_a60 := ddx_loan_details.term_index_date;
    p3_a61 := ddx_loan_details.term_ceiling_rate;
    p3_a62 := ddx_loan_details.term_floor_rate;
    p3_a63 := ddx_loan_details.term_first_percent_increase;
    p3_a64 := ddx_loan_details.term_adj_percent_increase;
    p3_a65 := ddx_loan_details.term_life_percent_increase;
    p3_a66 := ddx_loan_details.open_to_term_flag;
    p3_a67 := ddx_loan_details.open_to_term_event;
    p3_a68 := ddx_loan_details.multiple_funding_flag;
    p3_a69 := ddx_loan_details.secondary_status;
    p3_a70 := ddx_loan_details.open_projected_interest_rate;
    p3_a71 := ddx_loan_details.term_projected_interest_rate;
    p3_a72 := ddx_loan_details.initial_interest_rate;
    p3_a73 := ddx_loan_details.last_interest_rate;
    p3_a74 := ddx_loan_details.first_rate_change_date;
    p3_a75 := ddx_loan_details.next_rate_change_date;
    p3_a76 := ddx_loan_details.calculation_method;
    p3_a77 := ddx_loan_details.interest_compounding_freq;
    p3_a78 := ddx_loan_details.payment_calc_method;
    p3_a79 := ddx_loan_details.orig_pay_calc_method;
    p3_a80 := ddx_loan_details.prin_first_pay_date;
    p3_a81 := ddx_loan_details.prin_payment_frequency;
    p3_a82 := ddx_loan_details.prin_number_installments;
    p3_a83 := ddx_loan_details.prin_amort_installments;
    p3_a84 := ddx_loan_details.prin_pay_in_arrears;
    if ddx_loan_details.prin_pay_in_arrears_bool is null
      then p3_a85 := null;
    elsif ddx_loan_details.prin_pay_in_arrears_bool
      then p3_a85 := 1;
    else p3_a85 := 0;
    end if;
    p3_a86 := ddx_loan_details.extend_from_installment;
    p3_a87 := ddx_loan_details.orig_number_installments;
    p3_a88 := ddx_loan_details.penal_int_rate;
    p3_a89 := ddx_loan_details.penal_int_grace_days;
    p3_a90 := ddx_loan_details.reamortize_on_funding;




  end;

  procedure validatepayoff(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p_payoff_date  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_details lns_financials.loan_details_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loan_details.loan_id := p0_a0;
    ddp_loan_details.loan_term := p0_a1;
    ddp_loan_details.loan_term_period := p0_a2;
    ddp_loan_details.amortized_term := p0_a3;
    ddp_loan_details.amortized_term_period := p0_a4;
    ddp_loan_details.amortization_frequency := p0_a5;
    ddp_loan_details.payment_frequency := p0_a6;
    ddp_loan_details.first_payment_date := p0_a7;
    ddp_loan_details.loan_start_date := p0_a8;
    ddp_loan_details.requested_amount := p0_a9;
    ddp_loan_details.funded_amount := p0_a10;
    ddp_loan_details.remaining_balance := p0_a11;
    ddp_loan_details.principal_paid_to_date := p0_a12;
    ddp_loan_details.interest_paid_to_date := p0_a13;
    ddp_loan_details.fees_paid_to_date := p0_a14;
    ddp_loan_details.unpaid_principal := p0_a15;
    ddp_loan_details.unpaid_interest := p0_a16;
    ddp_loan_details.unbilled_principal := p0_a17;
    ddp_loan_details.billed_principal := p0_a18;
    ddp_loan_details.maturity_date := p0_a19;
    ddp_loan_details.number_installments := p0_a20;
    ddp_loan_details.num_amortization_intervals := p0_a21;
    ddp_loan_details.reamortize_overpay := p0_a22;
    ddp_loan_details.reamortize_underpay := p0_a23;
    ddp_loan_details.reamortize_with_interest := p0_a24;
    ddp_loan_details.reamortize_amount := p0_a25;
    ddp_loan_details.reamortize_from_installment := p0_a26;
    ddp_loan_details.reamortize_to_installment := p0_a27;
    ddp_loan_details.last_installment_billed := p0_a28;
    ddp_loan_details.day_count_method := p0_a29;
    ddp_loan_details.pay_in_arrears := p0_a30;
    if p0_a31 is null
      then ddp_loan_details.pay_in_arrears_boolean := null;
    elsif p0_a31 = 0
      then ddp_loan_details.pay_in_arrears_boolean := false;
    else ddp_loan_details.pay_in_arrears_boolean := true;
    end if;
    ddp_loan_details.custom_schedule := p0_a32;
    ddp_loan_details.loan_status := p0_a33;
    ddp_loan_details.last_interest_accrual := p0_a34;
    ddp_loan_details.last_activity := p0_a35;
    ddp_loan_details.last_activity_date := p0_a36;
    ddp_loan_details.loan_currency := p0_a37;
    ddp_loan_details.currency_precision := p0_a38;
    ddp_loan_details.open_term := p0_a39;
    ddp_loan_details.open_term_period := p0_a40;
    ddp_loan_details.open_payment_frequency := p0_a41;
    ddp_loan_details.open_first_payment_date := p0_a42;
    ddp_loan_details.open_start_date := p0_a43;
    ddp_loan_details.open_maturity_date := p0_a44;
    ddp_loan_details.loan_phase := p0_a45;
    ddp_loan_details.balloon_payment_type := p0_a46;
    ddp_loan_details.balloon_payment_amount := p0_a47;
    ddp_loan_details.amortized_amount := p0_a48;
    ddp_loan_details.rate_type := p0_a49;
    ddp_loan_details.open_rate_chg_freq := p0_a50;
    ddp_loan_details.open_index_rate_id := p0_a51;
    ddp_loan_details.open_index_date := p0_a52;
    ddp_loan_details.open_ceiling_rate := p0_a53;
    ddp_loan_details.open_floor_rate := p0_a54;
    ddp_loan_details.open_first_percent_increase := p0_a55;
    ddp_loan_details.open_adj_percent_increase := p0_a56;
    ddp_loan_details.open_life_percent_increase := p0_a57;
    ddp_loan_details.term_rate_chg_freq := p0_a58;
    ddp_loan_details.term_index_rate_id := p0_a59;
    ddp_loan_details.term_index_date := p0_a60;
    ddp_loan_details.term_ceiling_rate := p0_a61;
    ddp_loan_details.term_floor_rate := p0_a62;
    ddp_loan_details.term_first_percent_increase := p0_a63;
    ddp_loan_details.term_adj_percent_increase := p0_a64;
    ddp_loan_details.term_life_percent_increase := p0_a65;
    ddp_loan_details.open_to_term_flag := p0_a66;
    ddp_loan_details.open_to_term_event := p0_a67;
    ddp_loan_details.multiple_funding_flag := p0_a68;
    ddp_loan_details.secondary_status := p0_a69;
    ddp_loan_details.open_projected_interest_rate := p0_a70;
    ddp_loan_details.term_projected_interest_rate := p0_a71;
    ddp_loan_details.initial_interest_rate := p0_a72;
    ddp_loan_details.last_interest_rate := p0_a73;
    ddp_loan_details.first_rate_change_date := p0_a74;
    ddp_loan_details.next_rate_change_date := p0_a75;
    ddp_loan_details.calculation_method := p0_a76;
    ddp_loan_details.interest_compounding_freq := p0_a77;
    ddp_loan_details.payment_calc_method := p0_a78;
    ddp_loan_details.orig_pay_calc_method := p0_a79;
    ddp_loan_details.prin_first_pay_date := p0_a80;
    ddp_loan_details.prin_payment_frequency := p0_a81;
    ddp_loan_details.prin_number_installments := p0_a82;
    ddp_loan_details.prin_amort_installments := p0_a83;
    ddp_loan_details.prin_pay_in_arrears := p0_a84;
    if p0_a85 is null
      then ddp_loan_details.prin_pay_in_arrears_bool := null;
    elsif p0_a85 = 0
      then ddp_loan_details.prin_pay_in_arrears_bool := false;
    else ddp_loan_details.prin_pay_in_arrears_bool := true;
    end if;
    ddp_loan_details.extend_from_installment := p0_a86;
    ddp_loan_details.orig_number_installments := p0_a87;
    ddp_loan_details.penal_int_rate := p0_a88;
    ddp_loan_details.penal_int_grace_days := p0_a89;
    ddp_loan_details.reamortize_on_funding := p0_a90;





    -- here's the delegated call to the old PL/SQL routine
    lns_financials.validatepayoff(ddp_loan_details,
      p_payoff_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure calculatepayoff(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_payoff_date  DATE
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_payoff_tbl lns_financials.payoff_tbl2;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    lns_financials.calculatepayoff(p_api_version,
      p_init_msg_list,
      p_loan_id,
      p_payoff_date,
      ddx_payoff_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    lns_financials_w.rosetta_table_copy_out_p8(ddx_payoff_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      );



  end;

  function getweightedrate(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_DATE_TABLE
    , p3_a2 JTF_DATE_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p3_a9 JTF_VARCHAR2_TABLE_100
  ) return number

  as
    ddp_loan_details lns_financials.loan_details_rec;
    ddp_rate_tbl lns_financials.rate_schedule_tbl;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loan_details.loan_id := p0_a0;
    ddp_loan_details.loan_term := p0_a1;
    ddp_loan_details.loan_term_period := p0_a2;
    ddp_loan_details.amortized_term := p0_a3;
    ddp_loan_details.amortized_term_period := p0_a4;
    ddp_loan_details.amortization_frequency := p0_a5;
    ddp_loan_details.payment_frequency := p0_a6;
    ddp_loan_details.first_payment_date := p0_a7;
    ddp_loan_details.loan_start_date := p0_a8;
    ddp_loan_details.requested_amount := p0_a9;
    ddp_loan_details.funded_amount := p0_a10;
    ddp_loan_details.remaining_balance := p0_a11;
    ddp_loan_details.principal_paid_to_date := p0_a12;
    ddp_loan_details.interest_paid_to_date := p0_a13;
    ddp_loan_details.fees_paid_to_date := p0_a14;
    ddp_loan_details.unpaid_principal := p0_a15;
    ddp_loan_details.unpaid_interest := p0_a16;
    ddp_loan_details.unbilled_principal := p0_a17;
    ddp_loan_details.billed_principal := p0_a18;
    ddp_loan_details.maturity_date := p0_a19;
    ddp_loan_details.number_installments := p0_a20;
    ddp_loan_details.num_amortization_intervals := p0_a21;
    ddp_loan_details.reamortize_overpay := p0_a22;
    ddp_loan_details.reamortize_underpay := p0_a23;
    ddp_loan_details.reamortize_with_interest := p0_a24;
    ddp_loan_details.reamortize_amount := p0_a25;
    ddp_loan_details.reamortize_from_installment := p0_a26;
    ddp_loan_details.reamortize_to_installment := p0_a27;
    ddp_loan_details.last_installment_billed := p0_a28;
    ddp_loan_details.day_count_method := p0_a29;
    ddp_loan_details.pay_in_arrears := p0_a30;
    if p0_a31 is null
      then ddp_loan_details.pay_in_arrears_boolean := null;
    elsif p0_a31 = 0
      then ddp_loan_details.pay_in_arrears_boolean := false;
    else ddp_loan_details.pay_in_arrears_boolean := true;
    end if;
    ddp_loan_details.custom_schedule := p0_a32;
    ddp_loan_details.loan_status := p0_a33;
    ddp_loan_details.last_interest_accrual := p0_a34;
    ddp_loan_details.last_activity := p0_a35;
    ddp_loan_details.last_activity_date := p0_a36;
    ddp_loan_details.loan_currency := p0_a37;
    ddp_loan_details.currency_precision := p0_a38;
    ddp_loan_details.open_term := p0_a39;
    ddp_loan_details.open_term_period := p0_a40;
    ddp_loan_details.open_payment_frequency := p0_a41;
    ddp_loan_details.open_first_payment_date := p0_a42;
    ddp_loan_details.open_start_date := p0_a43;
    ddp_loan_details.open_maturity_date := p0_a44;
    ddp_loan_details.loan_phase := p0_a45;
    ddp_loan_details.balloon_payment_type := p0_a46;
    ddp_loan_details.balloon_payment_amount := p0_a47;
    ddp_loan_details.amortized_amount := p0_a48;
    ddp_loan_details.rate_type := p0_a49;
    ddp_loan_details.open_rate_chg_freq := p0_a50;
    ddp_loan_details.open_index_rate_id := p0_a51;
    ddp_loan_details.open_index_date := p0_a52;
    ddp_loan_details.open_ceiling_rate := p0_a53;
    ddp_loan_details.open_floor_rate := p0_a54;
    ddp_loan_details.open_first_percent_increase := p0_a55;
    ddp_loan_details.open_adj_percent_increase := p0_a56;
    ddp_loan_details.open_life_percent_increase := p0_a57;
    ddp_loan_details.term_rate_chg_freq := p0_a58;
    ddp_loan_details.term_index_rate_id := p0_a59;
    ddp_loan_details.term_index_date := p0_a60;
    ddp_loan_details.term_ceiling_rate := p0_a61;
    ddp_loan_details.term_floor_rate := p0_a62;
    ddp_loan_details.term_first_percent_increase := p0_a63;
    ddp_loan_details.term_adj_percent_increase := p0_a64;
    ddp_loan_details.term_life_percent_increase := p0_a65;
    ddp_loan_details.open_to_term_flag := p0_a66;
    ddp_loan_details.open_to_term_event := p0_a67;
    ddp_loan_details.multiple_funding_flag := p0_a68;
    ddp_loan_details.secondary_status := p0_a69;
    ddp_loan_details.open_projected_interest_rate := p0_a70;
    ddp_loan_details.term_projected_interest_rate := p0_a71;
    ddp_loan_details.initial_interest_rate := p0_a72;
    ddp_loan_details.last_interest_rate := p0_a73;
    ddp_loan_details.first_rate_change_date := p0_a74;
    ddp_loan_details.next_rate_change_date := p0_a75;
    ddp_loan_details.calculation_method := p0_a76;
    ddp_loan_details.interest_compounding_freq := p0_a77;
    ddp_loan_details.payment_calc_method := p0_a78;
    ddp_loan_details.orig_pay_calc_method := p0_a79;
    ddp_loan_details.prin_first_pay_date := p0_a80;
    ddp_loan_details.prin_payment_frequency := p0_a81;
    ddp_loan_details.prin_number_installments := p0_a82;
    ddp_loan_details.prin_amort_installments := p0_a83;
    ddp_loan_details.prin_pay_in_arrears := p0_a84;
    if p0_a85 is null
      then ddp_loan_details.prin_pay_in_arrears_bool := null;
    elsif p0_a85 = 0
      then ddp_loan_details.prin_pay_in_arrears_bool := false;
    else ddp_loan_details.prin_pay_in_arrears_bool := true;
    end if;
    ddp_loan_details.extend_from_installment := p0_a86;
    ddp_loan_details.orig_number_installments := p0_a87;
    ddp_loan_details.penal_int_rate := p0_a88;
    ddp_loan_details.penal_int_grace_days := p0_a89;
    ddp_loan_details.reamortize_on_funding := p0_a90;



    lns_financials_w.rosetta_table_copy_in_p1(ddp_rate_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := lns_financials.getweightedrate(ddp_loan_details,
      p_start_date,
      p_end_date,
      ddp_rate_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    return ddrosetta_retval;
  end;

  procedure amortizeeploan(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_DATE_TABLE
    , p1_a2 JTF_DATE_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p_based_on_terms  VARCHAR2
    , p_installment_number  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_DATE_TABLE
    , p4_a2 out nocopy JTF_DATE_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_NUMBER_TABLE
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_NUMBER_TABLE
    , p4_a16 out nocopy JTF_NUMBER_TABLE
    , p4_a17 out nocopy JTF_NUMBER_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , p4_a19 out nocopy JTF_NUMBER_TABLE
    , p4_a20 out nocopy JTF_NUMBER_TABLE
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 out nocopy JTF_NUMBER_TABLE
    , p4_a25 out nocopy JTF_NUMBER_TABLE
    , p4_a26 out nocopy JTF_NUMBER_TABLE
    , p4_a27 out nocopy JTF_NUMBER_TABLE
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a32 out nocopy JTF_NUMBER_TABLE
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_loan_details lns_financials.loan_details_rec;
    ddp_rate_schedule lns_financials.rate_schedule_tbl;
    ddx_loan_amort_tbl lns_financials.amortization_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loan_details.loan_id := p0_a0;
    ddp_loan_details.loan_term := p0_a1;
    ddp_loan_details.loan_term_period := p0_a2;
    ddp_loan_details.amortized_term := p0_a3;
    ddp_loan_details.amortized_term_period := p0_a4;
    ddp_loan_details.amortization_frequency := p0_a5;
    ddp_loan_details.payment_frequency := p0_a6;
    ddp_loan_details.first_payment_date := p0_a7;
    ddp_loan_details.loan_start_date := p0_a8;
    ddp_loan_details.requested_amount := p0_a9;
    ddp_loan_details.funded_amount := p0_a10;
    ddp_loan_details.remaining_balance := p0_a11;
    ddp_loan_details.principal_paid_to_date := p0_a12;
    ddp_loan_details.interest_paid_to_date := p0_a13;
    ddp_loan_details.fees_paid_to_date := p0_a14;
    ddp_loan_details.unpaid_principal := p0_a15;
    ddp_loan_details.unpaid_interest := p0_a16;
    ddp_loan_details.unbilled_principal := p0_a17;
    ddp_loan_details.billed_principal := p0_a18;
    ddp_loan_details.maturity_date := p0_a19;
    ddp_loan_details.number_installments := p0_a20;
    ddp_loan_details.num_amortization_intervals := p0_a21;
    ddp_loan_details.reamortize_overpay := p0_a22;
    ddp_loan_details.reamortize_underpay := p0_a23;
    ddp_loan_details.reamortize_with_interest := p0_a24;
    ddp_loan_details.reamortize_amount := p0_a25;
    ddp_loan_details.reamortize_from_installment := p0_a26;
    ddp_loan_details.reamortize_to_installment := p0_a27;
    ddp_loan_details.last_installment_billed := p0_a28;
    ddp_loan_details.day_count_method := p0_a29;
    ddp_loan_details.pay_in_arrears := p0_a30;
    if p0_a31 is null
      then ddp_loan_details.pay_in_arrears_boolean := null;
    elsif p0_a31 = 0
      then ddp_loan_details.pay_in_arrears_boolean := false;
    else ddp_loan_details.pay_in_arrears_boolean := true;
    end if;
    ddp_loan_details.custom_schedule := p0_a32;
    ddp_loan_details.loan_status := p0_a33;
    ddp_loan_details.last_interest_accrual := p0_a34;
    ddp_loan_details.last_activity := p0_a35;
    ddp_loan_details.last_activity_date := p0_a36;
    ddp_loan_details.loan_currency := p0_a37;
    ddp_loan_details.currency_precision := p0_a38;
    ddp_loan_details.open_term := p0_a39;
    ddp_loan_details.open_term_period := p0_a40;
    ddp_loan_details.open_payment_frequency := p0_a41;
    ddp_loan_details.open_first_payment_date := p0_a42;
    ddp_loan_details.open_start_date := p0_a43;
    ddp_loan_details.open_maturity_date := p0_a44;
    ddp_loan_details.loan_phase := p0_a45;
    ddp_loan_details.balloon_payment_type := p0_a46;
    ddp_loan_details.balloon_payment_amount := p0_a47;
    ddp_loan_details.amortized_amount := p0_a48;
    ddp_loan_details.rate_type := p0_a49;
    ddp_loan_details.open_rate_chg_freq := p0_a50;
    ddp_loan_details.open_index_rate_id := p0_a51;
    ddp_loan_details.open_index_date := p0_a52;
    ddp_loan_details.open_ceiling_rate := p0_a53;
    ddp_loan_details.open_floor_rate := p0_a54;
    ddp_loan_details.open_first_percent_increase := p0_a55;
    ddp_loan_details.open_adj_percent_increase := p0_a56;
    ddp_loan_details.open_life_percent_increase := p0_a57;
    ddp_loan_details.term_rate_chg_freq := p0_a58;
    ddp_loan_details.term_index_rate_id := p0_a59;
    ddp_loan_details.term_index_date := p0_a60;
    ddp_loan_details.term_ceiling_rate := p0_a61;
    ddp_loan_details.term_floor_rate := p0_a62;
    ddp_loan_details.term_first_percent_increase := p0_a63;
    ddp_loan_details.term_adj_percent_increase := p0_a64;
    ddp_loan_details.term_life_percent_increase := p0_a65;
    ddp_loan_details.open_to_term_flag := p0_a66;
    ddp_loan_details.open_to_term_event := p0_a67;
    ddp_loan_details.multiple_funding_flag := p0_a68;
    ddp_loan_details.secondary_status := p0_a69;
    ddp_loan_details.open_projected_interest_rate := p0_a70;
    ddp_loan_details.term_projected_interest_rate := p0_a71;
    ddp_loan_details.initial_interest_rate := p0_a72;
    ddp_loan_details.last_interest_rate := p0_a73;
    ddp_loan_details.first_rate_change_date := p0_a74;
    ddp_loan_details.next_rate_change_date := p0_a75;
    ddp_loan_details.calculation_method := p0_a76;
    ddp_loan_details.interest_compounding_freq := p0_a77;
    ddp_loan_details.payment_calc_method := p0_a78;
    ddp_loan_details.orig_pay_calc_method := p0_a79;
    ddp_loan_details.prin_first_pay_date := p0_a80;
    ddp_loan_details.prin_payment_frequency := p0_a81;
    ddp_loan_details.prin_number_installments := p0_a82;
    ddp_loan_details.prin_amort_installments := p0_a83;
    ddp_loan_details.prin_pay_in_arrears := p0_a84;
    if p0_a85 is null
      then ddp_loan_details.prin_pay_in_arrears_bool := null;
    elsif p0_a85 = 0
      then ddp_loan_details.prin_pay_in_arrears_bool := false;
    else ddp_loan_details.prin_pay_in_arrears_bool := true;
    end if;
    ddp_loan_details.extend_from_installment := p0_a86;
    ddp_loan_details.orig_number_installments := p0_a87;
    ddp_loan_details.penal_int_rate := p0_a88;
    ddp_loan_details.penal_int_grace_days := p0_a89;
    ddp_loan_details.reamortize_on_funding := p0_a90;

    lns_financials_w.rosetta_table_copy_in_p1(ddp_rate_schedule, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_financials.amortizeeploan(ddp_loan_details,
      ddp_rate_schedule,
      p_based_on_terms,
      p_installment_number,
      ddx_loan_amort_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    lns_financials_w.rosetta_table_copy_out_p3(ddx_loan_amort_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      );
  end;

  procedure amortizeloan(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_DATE_TABLE
    , p1_a2 JTF_DATE_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p_based_on_terms  VARCHAR2
    , p_installment_number  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_DATE_TABLE
    , p4_a2 out nocopy JTF_DATE_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_NUMBER_TABLE
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_NUMBER_TABLE
    , p4_a16 out nocopy JTF_NUMBER_TABLE
    , p4_a17 out nocopy JTF_NUMBER_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , p4_a19 out nocopy JTF_NUMBER_TABLE
    , p4_a20 out nocopy JTF_NUMBER_TABLE
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 out nocopy JTF_NUMBER_TABLE
    , p4_a25 out nocopy JTF_NUMBER_TABLE
    , p4_a26 out nocopy JTF_NUMBER_TABLE
    , p4_a27 out nocopy JTF_NUMBER_TABLE
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a32 out nocopy JTF_NUMBER_TABLE
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_loan_details lns_financials.loan_details_rec;
    ddp_rate_schedule lns_financials.rate_schedule_tbl;
    ddx_loan_amort_tbl lns_financials.amortization_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loan_details.loan_id := p0_a0;
    ddp_loan_details.loan_term := p0_a1;
    ddp_loan_details.loan_term_period := p0_a2;
    ddp_loan_details.amortized_term := p0_a3;
    ddp_loan_details.amortized_term_period := p0_a4;
    ddp_loan_details.amortization_frequency := p0_a5;
    ddp_loan_details.payment_frequency := p0_a6;
    ddp_loan_details.first_payment_date := p0_a7;
    ddp_loan_details.loan_start_date := p0_a8;
    ddp_loan_details.requested_amount := p0_a9;
    ddp_loan_details.funded_amount := p0_a10;
    ddp_loan_details.remaining_balance := p0_a11;
    ddp_loan_details.principal_paid_to_date := p0_a12;
    ddp_loan_details.interest_paid_to_date := p0_a13;
    ddp_loan_details.fees_paid_to_date := p0_a14;
    ddp_loan_details.unpaid_principal := p0_a15;
    ddp_loan_details.unpaid_interest := p0_a16;
    ddp_loan_details.unbilled_principal := p0_a17;
    ddp_loan_details.billed_principal := p0_a18;
    ddp_loan_details.maturity_date := p0_a19;
    ddp_loan_details.number_installments := p0_a20;
    ddp_loan_details.num_amortization_intervals := p0_a21;
    ddp_loan_details.reamortize_overpay := p0_a22;
    ddp_loan_details.reamortize_underpay := p0_a23;
    ddp_loan_details.reamortize_with_interest := p0_a24;
    ddp_loan_details.reamortize_amount := p0_a25;
    ddp_loan_details.reamortize_from_installment := p0_a26;
    ddp_loan_details.reamortize_to_installment := p0_a27;
    ddp_loan_details.last_installment_billed := p0_a28;
    ddp_loan_details.day_count_method := p0_a29;
    ddp_loan_details.pay_in_arrears := p0_a30;
    if p0_a31 is null
      then ddp_loan_details.pay_in_arrears_boolean := null;
    elsif p0_a31 = 0
      then ddp_loan_details.pay_in_arrears_boolean := false;
    else ddp_loan_details.pay_in_arrears_boolean := true;
    end if;
    ddp_loan_details.custom_schedule := p0_a32;
    ddp_loan_details.loan_status := p0_a33;
    ddp_loan_details.last_interest_accrual := p0_a34;
    ddp_loan_details.last_activity := p0_a35;
    ddp_loan_details.last_activity_date := p0_a36;
    ddp_loan_details.loan_currency := p0_a37;
    ddp_loan_details.currency_precision := p0_a38;
    ddp_loan_details.open_term := p0_a39;
    ddp_loan_details.open_term_period := p0_a40;
    ddp_loan_details.open_payment_frequency := p0_a41;
    ddp_loan_details.open_first_payment_date := p0_a42;
    ddp_loan_details.open_start_date := p0_a43;
    ddp_loan_details.open_maturity_date := p0_a44;
    ddp_loan_details.loan_phase := p0_a45;
    ddp_loan_details.balloon_payment_type := p0_a46;
    ddp_loan_details.balloon_payment_amount := p0_a47;
    ddp_loan_details.amortized_amount := p0_a48;
    ddp_loan_details.rate_type := p0_a49;
    ddp_loan_details.open_rate_chg_freq := p0_a50;
    ddp_loan_details.open_index_rate_id := p0_a51;
    ddp_loan_details.open_index_date := p0_a52;
    ddp_loan_details.open_ceiling_rate := p0_a53;
    ddp_loan_details.open_floor_rate := p0_a54;
    ddp_loan_details.open_first_percent_increase := p0_a55;
    ddp_loan_details.open_adj_percent_increase := p0_a56;
    ddp_loan_details.open_life_percent_increase := p0_a57;
    ddp_loan_details.term_rate_chg_freq := p0_a58;
    ddp_loan_details.term_index_rate_id := p0_a59;
    ddp_loan_details.term_index_date := p0_a60;
    ddp_loan_details.term_ceiling_rate := p0_a61;
    ddp_loan_details.term_floor_rate := p0_a62;
    ddp_loan_details.term_first_percent_increase := p0_a63;
    ddp_loan_details.term_adj_percent_increase := p0_a64;
    ddp_loan_details.term_life_percent_increase := p0_a65;
    ddp_loan_details.open_to_term_flag := p0_a66;
    ddp_loan_details.open_to_term_event := p0_a67;
    ddp_loan_details.multiple_funding_flag := p0_a68;
    ddp_loan_details.secondary_status := p0_a69;
    ddp_loan_details.open_projected_interest_rate := p0_a70;
    ddp_loan_details.term_projected_interest_rate := p0_a71;
    ddp_loan_details.initial_interest_rate := p0_a72;
    ddp_loan_details.last_interest_rate := p0_a73;
    ddp_loan_details.first_rate_change_date := p0_a74;
    ddp_loan_details.next_rate_change_date := p0_a75;
    ddp_loan_details.calculation_method := p0_a76;
    ddp_loan_details.interest_compounding_freq := p0_a77;
    ddp_loan_details.payment_calc_method := p0_a78;
    ddp_loan_details.orig_pay_calc_method := p0_a79;
    ddp_loan_details.prin_first_pay_date := p0_a80;
    ddp_loan_details.prin_payment_frequency := p0_a81;
    ddp_loan_details.prin_number_installments := p0_a82;
    ddp_loan_details.prin_amort_installments := p0_a83;
    ddp_loan_details.prin_pay_in_arrears := p0_a84;
    if p0_a85 is null
      then ddp_loan_details.prin_pay_in_arrears_bool := null;
    elsif p0_a85 = 0
      then ddp_loan_details.prin_pay_in_arrears_bool := false;
    else ddp_loan_details.prin_pay_in_arrears_bool := true;
    end if;
    ddp_loan_details.extend_from_installment := p0_a86;
    ddp_loan_details.orig_number_installments := p0_a87;
    ddp_loan_details.penal_int_rate := p0_a88;
    ddp_loan_details.penal_int_grace_days := p0_a89;
    ddp_loan_details.reamortize_on_funding := p0_a90;

    lns_financials_w.rosetta_table_copy_in_p1(ddp_rate_schedule, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_financials.amortizeloan(ddp_loan_details,
      ddp_rate_schedule,
      p_based_on_terms,
      p_installment_number,
      ddx_loan_amort_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    lns_financials_w.rosetta_table_copy_out_p3(ddx_loan_amort_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      );
  end;

  procedure amortizeloan(p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , p_installment_number  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
    , p3_a2 out nocopy JTF_DATE_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_NUMBER_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_loan_amort_tbl lns_financials.amortization_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    lns_financials.amortizeloan(p_loan_id,
      p_based_on_terms,
      p_installment_number,
      ddx_loan_amort_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    lns_financials_w.rosetta_table_copy_out_p3(ddx_loan_amort_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      );
  end;

  procedure loanprojection(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_DATE_TABLE
    , p2_a2 JTF_DATE_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_VARCHAR2_TABLE_100
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
    , p3_a2 out nocopy JTF_DATE_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_NUMBER_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_loan_details lns_financials.loan_details_rec;
    ddp_rate_schedule lns_financials.rate_schedule_tbl;
    ddx_loan_amort_tbl lns_financials.amortization_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loan_details.loan_id := p0_a0;
    ddp_loan_details.loan_term := p0_a1;
    ddp_loan_details.loan_term_period := p0_a2;
    ddp_loan_details.amortized_term := p0_a3;
    ddp_loan_details.amortized_term_period := p0_a4;
    ddp_loan_details.amortization_frequency := p0_a5;
    ddp_loan_details.payment_frequency := p0_a6;
    ddp_loan_details.first_payment_date := p0_a7;
    ddp_loan_details.loan_start_date := p0_a8;
    ddp_loan_details.requested_amount := p0_a9;
    ddp_loan_details.funded_amount := p0_a10;
    ddp_loan_details.remaining_balance := p0_a11;
    ddp_loan_details.principal_paid_to_date := p0_a12;
    ddp_loan_details.interest_paid_to_date := p0_a13;
    ddp_loan_details.fees_paid_to_date := p0_a14;
    ddp_loan_details.unpaid_principal := p0_a15;
    ddp_loan_details.unpaid_interest := p0_a16;
    ddp_loan_details.unbilled_principal := p0_a17;
    ddp_loan_details.billed_principal := p0_a18;
    ddp_loan_details.maturity_date := p0_a19;
    ddp_loan_details.number_installments := p0_a20;
    ddp_loan_details.num_amortization_intervals := p0_a21;
    ddp_loan_details.reamortize_overpay := p0_a22;
    ddp_loan_details.reamortize_underpay := p0_a23;
    ddp_loan_details.reamortize_with_interest := p0_a24;
    ddp_loan_details.reamortize_amount := p0_a25;
    ddp_loan_details.reamortize_from_installment := p0_a26;
    ddp_loan_details.reamortize_to_installment := p0_a27;
    ddp_loan_details.last_installment_billed := p0_a28;
    ddp_loan_details.day_count_method := p0_a29;
    ddp_loan_details.pay_in_arrears := p0_a30;
    if p0_a31 is null
      then ddp_loan_details.pay_in_arrears_boolean := null;
    elsif p0_a31 = 0
      then ddp_loan_details.pay_in_arrears_boolean := false;
    else ddp_loan_details.pay_in_arrears_boolean := true;
    end if;
    ddp_loan_details.custom_schedule := p0_a32;
    ddp_loan_details.loan_status := p0_a33;
    ddp_loan_details.last_interest_accrual := p0_a34;
    ddp_loan_details.last_activity := p0_a35;
    ddp_loan_details.last_activity_date := p0_a36;
    ddp_loan_details.loan_currency := p0_a37;
    ddp_loan_details.currency_precision := p0_a38;
    ddp_loan_details.open_term := p0_a39;
    ddp_loan_details.open_term_period := p0_a40;
    ddp_loan_details.open_payment_frequency := p0_a41;
    ddp_loan_details.open_first_payment_date := p0_a42;
    ddp_loan_details.open_start_date := p0_a43;
    ddp_loan_details.open_maturity_date := p0_a44;
    ddp_loan_details.loan_phase := p0_a45;
    ddp_loan_details.balloon_payment_type := p0_a46;
    ddp_loan_details.balloon_payment_amount := p0_a47;
    ddp_loan_details.amortized_amount := p0_a48;
    ddp_loan_details.rate_type := p0_a49;
    ddp_loan_details.open_rate_chg_freq := p0_a50;
    ddp_loan_details.open_index_rate_id := p0_a51;
    ddp_loan_details.open_index_date := p0_a52;
    ddp_loan_details.open_ceiling_rate := p0_a53;
    ddp_loan_details.open_floor_rate := p0_a54;
    ddp_loan_details.open_first_percent_increase := p0_a55;
    ddp_loan_details.open_adj_percent_increase := p0_a56;
    ddp_loan_details.open_life_percent_increase := p0_a57;
    ddp_loan_details.term_rate_chg_freq := p0_a58;
    ddp_loan_details.term_index_rate_id := p0_a59;
    ddp_loan_details.term_index_date := p0_a60;
    ddp_loan_details.term_ceiling_rate := p0_a61;
    ddp_loan_details.term_floor_rate := p0_a62;
    ddp_loan_details.term_first_percent_increase := p0_a63;
    ddp_loan_details.term_adj_percent_increase := p0_a64;
    ddp_loan_details.term_life_percent_increase := p0_a65;
    ddp_loan_details.open_to_term_flag := p0_a66;
    ddp_loan_details.open_to_term_event := p0_a67;
    ddp_loan_details.multiple_funding_flag := p0_a68;
    ddp_loan_details.secondary_status := p0_a69;
    ddp_loan_details.open_projected_interest_rate := p0_a70;
    ddp_loan_details.term_projected_interest_rate := p0_a71;
    ddp_loan_details.initial_interest_rate := p0_a72;
    ddp_loan_details.last_interest_rate := p0_a73;
    ddp_loan_details.first_rate_change_date := p0_a74;
    ddp_loan_details.next_rate_change_date := p0_a75;
    ddp_loan_details.calculation_method := p0_a76;
    ddp_loan_details.interest_compounding_freq := p0_a77;
    ddp_loan_details.payment_calc_method := p0_a78;
    ddp_loan_details.orig_pay_calc_method := p0_a79;
    ddp_loan_details.prin_first_pay_date := p0_a80;
    ddp_loan_details.prin_payment_frequency := p0_a81;
    ddp_loan_details.prin_number_installments := p0_a82;
    ddp_loan_details.prin_amort_installments := p0_a83;
    ddp_loan_details.prin_pay_in_arrears := p0_a84;
    if p0_a85 is null
      then ddp_loan_details.prin_pay_in_arrears_bool := null;
    elsif p0_a85 = 0
      then ddp_loan_details.prin_pay_in_arrears_bool := false;
    else ddp_loan_details.prin_pay_in_arrears_bool := true;
    end if;
    ddp_loan_details.extend_from_installment := p0_a86;
    ddp_loan_details.orig_number_installments := p0_a87;
    ddp_loan_details.penal_int_rate := p0_a88;
    ddp_loan_details.penal_int_grace_days := p0_a89;
    ddp_loan_details.reamortize_on_funding := p0_a90;


    lns_financials_w.rosetta_table_copy_in_p1(ddp_rate_schedule, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    lns_financials.loanprojection(ddp_loan_details,
      p_based_on_terms,
      ddp_rate_schedule,
      ddx_loan_amort_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    lns_financials_w.rosetta_table_copy_out_p3(ddx_loan_amort_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      );
  end;

  procedure runopenprojection(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
    , p3_a2 out nocopy JTF_DATE_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_NUMBER_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_amort_tbl lns_financials.amortization_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    lns_financials.runopenprojection(p_init_msg_list,
      p_loan_id,
      p_based_on_terms,
      ddx_amort_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    lns_financials_w.rosetta_table_copy_out_p3(ddx_amort_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      );



  end;

  procedure runamortization(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_DATE_TABLE
    , p5_a2 out nocopy JTF_DATE_TABLE
    , p5_a3 out nocopy JTF_DATE_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_NUMBER_TABLE
    , p5_a17 out nocopy JTF_NUMBER_TABLE
    , p5_a18 out nocopy JTF_NUMBER_TABLE
    , p5_a19 out nocopy JTF_NUMBER_TABLE
    , p5_a20 out nocopy JTF_NUMBER_TABLE
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 out nocopy JTF_NUMBER_TABLE
    , p5_a25 out nocopy JTF_NUMBER_TABLE
    , p5_a26 out nocopy JTF_NUMBER_TABLE
    , p5_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a32 out nocopy JTF_NUMBER_TABLE
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_amort_tbl lns_financials.amortization_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    lns_financials.runamortization(p_api_version,
      p_init_msg_list,
      p_commit,
      p_loan_id,
      p_based_on_terms,
      ddx_amort_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    lns_financials_w.rosetta_table_copy_out_p3(ddx_amort_tbl, p5_a0
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
      );



  end;

  procedure getinstallment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  DATE
    , p5_a2 out nocopy  DATE
    , p5_a3 out nocopy  DATE
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  NUMBER
    , p5_a6 out nocopy  NUMBER
    , p5_a7 out nocopy  NUMBER
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  NUMBER
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  NUMBER
    , p5_a14 out nocopy  NUMBER
    , p5_a15 out nocopy  NUMBER
    , p5_a16 out nocopy  NUMBER
    , p5_a17 out nocopy  NUMBER
    , p5_a18 out nocopy  NUMBER
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  NUMBER
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  NUMBER
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_amortization_rec lns_financials.amortization_rec;
    ddx_fees_tbl lns_financials.fees_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    lns_financials.getinstallment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_loan_id,
      p_installment_number,
      ddx_amortization_rec,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_amortization_rec.installment_number;
    p5_a1 := ddx_amortization_rec.due_date;
    p5_a2 := ddx_amortization_rec.period_start_date;
    p5_a3 := ddx_amortization_rec.period_end_date;
    p5_a4 := ddx_amortization_rec.principal_amount;
    p5_a5 := ddx_amortization_rec.interest_amount;
    p5_a6 := ddx_amortization_rec.normal_int_amount;
    p5_a7 := ddx_amortization_rec.add_prin_int_amount;
    p5_a8 := ddx_amortization_rec.add_int_int_amount;
    p5_a9 := ddx_amortization_rec.penal_int_amount;
    p5_a10 := ddx_amortization_rec.fee_amount;
    p5_a11 := ddx_amortization_rec.other_amount;
    p5_a12 := ddx_amortization_rec.begin_balance;
    p5_a13 := ddx_amortization_rec.end_balance;
    p5_a14 := ddx_amortization_rec.total;
    p5_a15 := ddx_amortization_rec.interest_cumulative;
    p5_a16 := ddx_amortization_rec.principal_cumulative;
    p5_a17 := ddx_amortization_rec.fees_cumulative;
    p5_a18 := ddx_amortization_rec.other_cumulative;
    p5_a19 := ddx_amortization_rec.rate_id;
    p5_a20 := ddx_amortization_rec.rate_unadj;
    p5_a21 := ddx_amortization_rec.rate_change_freq;
    p5_a22 := ddx_amortization_rec.source;
    p5_a23 := ddx_amortization_rec.grand_total_flag;
    p5_a24 := ddx_amortization_rec.unpaid_prin;
    p5_a25 := ddx_amortization_rec.unpaid_int;
    p5_a26 := ddx_amortization_rec.interest_rate;
    p5_a27 := ddx_amortization_rec.funded_amount;
    p5_a28 := ddx_amortization_rec.normal_int_details;
    p5_a29 := ddx_amortization_rec.add_prin_int_details;
    p5_a30 := ddx_amortization_rec.add_int_int_details;
    p5_a31 := ddx_amortization_rec.penal_int_details;
    p5_a32 := ddx_amortization_rec.disbursement_amount;
    p5_a33 := ddx_amortization_rec.period;

    lns_financials_w.rosetta_table_copy_out_p17(ddx_fees_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );



  end;

  procedure getopeninstallment(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  DATE
    , p3_a2 out nocopy  DATE
    , p3_a3 out nocopy  DATE
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  NUMBER
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  NUMBER
    , p3_a14 out nocopy  NUMBER
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  NUMBER
    , p3_a17 out nocopy  NUMBER
    , p3_a18 out nocopy  NUMBER
    , p3_a19 out nocopy  NUMBER
    , p3_a20 out nocopy  NUMBER
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  NUMBER
    , p3_a25 out nocopy  NUMBER
    , p3_a26 out nocopy  NUMBER
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  NUMBER
    , p3_a33 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_amortization_rec lns_financials.amortization_rec;
    ddx_fees_tbl lns_financials.fees_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    lns_financials.getopeninstallment(p_init_msg_list,
      p_loan_id,
      p_installment_number,
      ddx_amortization_rec,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_amortization_rec.installment_number;
    p3_a1 := ddx_amortization_rec.due_date;
    p3_a2 := ddx_amortization_rec.period_start_date;
    p3_a3 := ddx_amortization_rec.period_end_date;
    p3_a4 := ddx_amortization_rec.principal_amount;
    p3_a5 := ddx_amortization_rec.interest_amount;
    p3_a6 := ddx_amortization_rec.normal_int_amount;
    p3_a7 := ddx_amortization_rec.add_prin_int_amount;
    p3_a8 := ddx_amortization_rec.add_int_int_amount;
    p3_a9 := ddx_amortization_rec.penal_int_amount;
    p3_a10 := ddx_amortization_rec.fee_amount;
    p3_a11 := ddx_amortization_rec.other_amount;
    p3_a12 := ddx_amortization_rec.begin_balance;
    p3_a13 := ddx_amortization_rec.end_balance;
    p3_a14 := ddx_amortization_rec.total;
    p3_a15 := ddx_amortization_rec.interest_cumulative;
    p3_a16 := ddx_amortization_rec.principal_cumulative;
    p3_a17 := ddx_amortization_rec.fees_cumulative;
    p3_a18 := ddx_amortization_rec.other_cumulative;
    p3_a19 := ddx_amortization_rec.rate_id;
    p3_a20 := ddx_amortization_rec.rate_unadj;
    p3_a21 := ddx_amortization_rec.rate_change_freq;
    p3_a22 := ddx_amortization_rec.source;
    p3_a23 := ddx_amortization_rec.grand_total_flag;
    p3_a24 := ddx_amortization_rec.unpaid_prin;
    p3_a25 := ddx_amortization_rec.unpaid_int;
    p3_a26 := ddx_amortization_rec.interest_rate;
    p3_a27 := ddx_amortization_rec.funded_amount;
    p3_a28 := ddx_amortization_rec.normal_int_details;
    p3_a29 := ddx_amortization_rec.add_prin_int_details;
    p3_a30 := ddx_amortization_rec.add_int_int_details;
    p3_a31 := ddx_amortization_rec.penal_int_details;
    p3_a32 := ddx_amortization_rec.disbursement_amount;
    p3_a33 := ddx_amortization_rec.period;

    lns_financials_w.rosetta_table_copy_out_p17(ddx_fees_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      );



  end;

  procedure preprocessinstallment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  DATE
    , p5_a2 out nocopy  DATE
    , p5_a3 out nocopy  DATE
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  NUMBER
    , p5_a6 out nocopy  NUMBER
    , p5_a7 out nocopy  NUMBER
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  NUMBER
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  NUMBER
    , p5_a14 out nocopy  NUMBER
    , p5_a15 out nocopy  NUMBER
    , p5_a16 out nocopy  NUMBER
    , p5_a17 out nocopy  NUMBER
    , p5_a18 out nocopy  NUMBER
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  NUMBER
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  NUMBER
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_amortization_rec lns_financials.amortization_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    lns_financials.preprocessinstallment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_loan_id,
      p_installment_number,
      ddx_amortization_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_amortization_rec.installment_number;
    p5_a1 := ddx_amortization_rec.due_date;
    p5_a2 := ddx_amortization_rec.period_start_date;
    p5_a3 := ddx_amortization_rec.period_end_date;
    p5_a4 := ddx_amortization_rec.principal_amount;
    p5_a5 := ddx_amortization_rec.interest_amount;
    p5_a6 := ddx_amortization_rec.normal_int_amount;
    p5_a7 := ddx_amortization_rec.add_prin_int_amount;
    p5_a8 := ddx_amortization_rec.add_int_int_amount;
    p5_a9 := ddx_amortization_rec.penal_int_amount;
    p5_a10 := ddx_amortization_rec.fee_amount;
    p5_a11 := ddx_amortization_rec.other_amount;
    p5_a12 := ddx_amortization_rec.begin_balance;
    p5_a13 := ddx_amortization_rec.end_balance;
    p5_a14 := ddx_amortization_rec.total;
    p5_a15 := ddx_amortization_rec.interest_cumulative;
    p5_a16 := ddx_amortization_rec.principal_cumulative;
    p5_a17 := ddx_amortization_rec.fees_cumulative;
    p5_a18 := ddx_amortization_rec.other_cumulative;
    p5_a19 := ddx_amortization_rec.rate_id;
    p5_a20 := ddx_amortization_rec.rate_unadj;
    p5_a21 := ddx_amortization_rec.rate_change_freq;
    p5_a22 := ddx_amortization_rec.source;
    p5_a23 := ddx_amortization_rec.grand_total_flag;
    p5_a24 := ddx_amortization_rec.unpaid_prin;
    p5_a25 := ddx_amortization_rec.unpaid_int;
    p5_a26 := ddx_amortization_rec.interest_rate;
    p5_a27 := ddx_amortization_rec.funded_amount;
    p5_a28 := ddx_amortization_rec.normal_int_details;
    p5_a29 := ddx_amortization_rec.add_prin_int_details;
    p5_a30 := ddx_amortization_rec.add_int_int_details;
    p5_a31 := ddx_amortization_rec.penal_int_details;
    p5_a32 := ddx_amortization_rec.disbursement_amount;
    p5_a33 := ddx_amortization_rec.period;



  end;

  procedure preprocessopeninstallment(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  DATE
    , p4_a2 out nocopy  DATE
    , p4_a3 out nocopy  DATE
    , p4_a4 out nocopy  NUMBER
    , p4_a5 out nocopy  NUMBER
    , p4_a6 out nocopy  NUMBER
    , p4_a7 out nocopy  NUMBER
    , p4_a8 out nocopy  NUMBER
    , p4_a9 out nocopy  NUMBER
    , p4_a10 out nocopy  NUMBER
    , p4_a11 out nocopy  NUMBER
    , p4_a12 out nocopy  NUMBER
    , p4_a13 out nocopy  NUMBER
    , p4_a14 out nocopy  NUMBER
    , p4_a15 out nocopy  NUMBER
    , p4_a16 out nocopy  NUMBER
    , p4_a17 out nocopy  NUMBER
    , p4_a18 out nocopy  NUMBER
    , p4_a19 out nocopy  NUMBER
    , p4_a20 out nocopy  NUMBER
    , p4_a21 out nocopy  VARCHAR2
    , p4_a22 out nocopy  VARCHAR2
    , p4_a23 out nocopy  VARCHAR2
    , p4_a24 out nocopy  NUMBER
    , p4_a25 out nocopy  NUMBER
    , p4_a26 out nocopy  NUMBER
    , p4_a27 out nocopy  NUMBER
    , p4_a28 out nocopy  VARCHAR2
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  VARCHAR2
    , p4_a31 out nocopy  VARCHAR2
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_amortization_rec lns_financials.amortization_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    lns_financials.preprocessopeninstallment(p_init_msg_list,
      p_commit,
      p_loan_id,
      p_installment_number,
      ddx_amortization_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddx_amortization_rec.installment_number;
    p4_a1 := ddx_amortization_rec.due_date;
    p4_a2 := ddx_amortization_rec.period_start_date;
    p4_a3 := ddx_amortization_rec.period_end_date;
    p4_a4 := ddx_amortization_rec.principal_amount;
    p4_a5 := ddx_amortization_rec.interest_amount;
    p4_a6 := ddx_amortization_rec.normal_int_amount;
    p4_a7 := ddx_amortization_rec.add_prin_int_amount;
    p4_a8 := ddx_amortization_rec.add_int_int_amount;
    p4_a9 := ddx_amortization_rec.penal_int_amount;
    p4_a10 := ddx_amortization_rec.fee_amount;
    p4_a11 := ddx_amortization_rec.other_amount;
    p4_a12 := ddx_amortization_rec.begin_balance;
    p4_a13 := ddx_amortization_rec.end_balance;
    p4_a14 := ddx_amortization_rec.total;
    p4_a15 := ddx_amortization_rec.interest_cumulative;
    p4_a16 := ddx_amortization_rec.principal_cumulative;
    p4_a17 := ddx_amortization_rec.fees_cumulative;
    p4_a18 := ddx_amortization_rec.other_cumulative;
    p4_a19 := ddx_amortization_rec.rate_id;
    p4_a20 := ddx_amortization_rec.rate_unadj;
    p4_a21 := ddx_amortization_rec.rate_change_freq;
    p4_a22 := ddx_amortization_rec.source;
    p4_a23 := ddx_amortization_rec.grand_total_flag;
    p4_a24 := ddx_amortization_rec.unpaid_prin;
    p4_a25 := ddx_amortization_rec.unpaid_int;
    p4_a26 := ddx_amortization_rec.interest_rate;
    p4_a27 := ddx_amortization_rec.funded_amount;
    p4_a28 := ddx_amortization_rec.normal_int_details;
    p4_a29 := ddx_amortization_rec.add_prin_int_details;
    p4_a30 := ddx_amortization_rec.add_int_int_details;
    p4_a31 := ddx_amortization_rec.penal_int_details;
    p4_a32 := ddx_amortization_rec.disbursement_amount;
    p4_a33 := ddx_amortization_rec.period;



  end;

  function calculateeppayment(p_loan_amount  NUMBER
    , p_num_intervals  NUMBER
    , p_ending_balance  NUMBER
    , p_pay_in_arrears  number
  ) return number

  as
    ddp_pay_in_arrears boolean;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    if p_pay_in_arrears is null
      then ddp_pay_in_arrears := null;
    elsif p_pay_in_arrears = 0
      then ddp_pay_in_arrears := false;
    else ddp_pay_in_arrears := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := lns_financials.calculateeppayment(p_loan_amount,
      p_num_intervals,
      p_ending_balance,
      ddp_pay_in_arrears);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    return ddrosetta_retval;
  end;

  function calculatepayment(p_loan_amount  NUMBER
    , p_periodic_rate  NUMBER
    , p_num_intervals  NUMBER
    , p_ending_balance  NUMBER
    , p_pay_in_arrears  number
  ) return number

  as
    ddp_pay_in_arrears boolean;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    if p_pay_in_arrears is null
      then ddp_pay_in_arrears := null;
    elsif p_pay_in_arrears = 0
      then ddp_pay_in_arrears := false;
    else ddp_pay_in_arrears := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := lns_financials.calculatepayment(p_loan_amount,
      p_periodic_rate,
      p_num_intervals,
      p_ending_balance,
      ddp_pay_in_arrears);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    return ddrosetta_retval;
  end;

end lns_financials_w;

/
