--------------------------------------------------------
--  DDL for Package Body PA_DEDUCTIONS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DEDUCTIONS_W" as
  /* $Header: PADCTNRB.pls 120.0.12010000.1 2009/07/21 10:59:25 sosharma noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy pa_deductions.g_dctn_hdrid, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t pa_deductions.g_dctn_hdrid, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy pa_deductions.g_dctn_txnid, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t pa_deductions.g_dctn_txnid, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy pa_deductions.g_dctn_hdrtbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).deduction_req_id := a0(indx);
          t(ddindx).project_id := a1(indx);
          t(ddindx).vendor_id := a2(indx);
          t(ddindx).vendor_site_id := a3(indx);
          t(ddindx).change_doc_num := a4(indx);
          t(ddindx).change_doc_type := a5(indx);
          t(ddindx).ci_id := a6(indx);
          t(ddindx).po_number := a7(indx);
          t(ddindx).po_header_id := a8(indx);
          t(ddindx).deduction_req_num := a9(indx);
          t(ddindx).debit_memo_num := a10(indx);
          t(ddindx).currency_code := a11(indx);
          t(ddindx).conversion_ratetype := a12(indx);
          t(ddindx).conversion_ratedate := a13(indx);
          t(ddindx).conversion_rate := a14(indx);
          t(ddindx).total_amount := a15(indx);
          t(ddindx).deduction_req_date := a16(indx);
          t(ddindx).debit_memo_date := a17(indx);
          t(ddindx).description := a18(indx);
          t(ddindx).status := a19(indx);
          t(ddindx).org_id := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t pa_deductions.g_dctn_hdrtbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_4000();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_4000();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).deduction_req_id;
          a1(indx) := t(ddindx).project_id;
          a2(indx) := t(ddindx).vendor_id;
          a3(indx) := t(ddindx).vendor_site_id;
          a4(indx) := t(ddindx).change_doc_num;
          a5(indx) := t(ddindx).change_doc_type;
          a6(indx) := t(ddindx).ci_id;
          a7(indx) := t(ddindx).po_number;
          a8(indx) := t(ddindx).po_header_id;
          a9(indx) := t(ddindx).deduction_req_num;
          a10(indx) := t(ddindx).debit_memo_num;
          a11(indx) := t(ddindx).currency_code;
          a12(indx) := t(ddindx).conversion_ratetype;
          a13(indx) := t(ddindx).conversion_ratedate;
          a14(indx) := t(ddindx).conversion_rate;
          a15(indx) := t(ddindx).total_amount;
          a16(indx) := t(ddindx).deduction_req_date;
          a17(indx) := t(ddindx).debit_memo_date;
          a18(indx) := t(ddindx).description;
          a19(indx) := t(ddindx).status;
          a20(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy pa_deductions.g_dctn_txntbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).deduction_req_id := a0(indx);
          t(ddindx).deduction_req_tran_id := a1(indx);
          t(ddindx).project_id := a2(indx);
          t(ddindx).task_id := a3(indx);
          t(ddindx).expenditure_type := a4(indx);
          t(ddindx).expenditure_item_date := a5(indx);
          t(ddindx).gl_date := a6(indx);
          t(ddindx).expenditure_org_id := a7(indx);
          t(ddindx).quantity := a8(indx);
          t(ddindx).override_quantity := a9(indx);
          t(ddindx).expenditure_item_id := a10(indx);
          t(ddindx).projfunc_currency_code := a11(indx);
          t(ddindx).orig_projfunc_amount := a12(indx);
          t(ddindx).override_projfunc_amount := a13(indx);
          t(ddindx).conversion_ratetype := a14(indx);
          t(ddindx).conversion_ratedate := a15(indx);
          t(ddindx).conversion_rate := a16(indx);
          t(ddindx).amount := a17(indx);
          t(ddindx).description := a18(indx);
          t(ddindx).status := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t pa_deductions.g_dctn_txntbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_4000();
    a19 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_4000();
      a19 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).deduction_req_id;
          a1(indx) := t(ddindx).deduction_req_tran_id;
          a2(indx) := t(ddindx).project_id;
          a3(indx) := t(ddindx).task_id;
          a4(indx) := t(ddindx).expenditure_type;
          a5(indx) := t(ddindx).expenditure_item_date;
          a6(indx) := t(ddindx).gl_date;
          a7(indx) := t(ddindx).expenditure_org_id;
          a8(indx) := t(ddindx).quantity;
          a9(indx) := t(ddindx).override_quantity;
          a10(indx) := t(ddindx).expenditure_item_id;
          a11(indx) := t(ddindx).projfunc_currency_code;
          a12(indx) := t(ddindx).orig_projfunc_amount;
          a13(indx) := t(ddindx).override_projfunc_amount;
          a14(indx) := t(ddindx).conversion_ratetype;
          a15(indx) := t(ddindx).conversion_ratedate;
          a16(indx) := t(ddindx).conversion_rate;
          a17(indx) := t(ddindx).amount;
          a18(indx) := t(ddindx).description;
          a19(indx) := t(ddindx).status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_deduction_hdr(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_NUMBER_TABLE
    , p0_a15 in out nocopy JTF_NUMBER_TABLE
    , p0_a16 in out nocopy JTF_DATE_TABLE
    , p0_a17 in out nocopy JTF_DATE_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  )

  as
    ddp_dctn_hdr pa_deductions.g_dctn_hdrtbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p4(ddp_dctn_hdr, p0_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    pa_deductions.create_deduction_hdr(ddp_dctn_hdr,
      p_msg_count,
      p_msg_data,
      p_return_status,
      p_calling_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_out_p4(ddp_dctn_hdr, p0_a0
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
      );




  end;

  procedure create_deduction_txn(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_DATE_TABLE
    , p0_a6 in out nocopy JTF_DATE_TABLE
    , p0_a7 in out nocopy JTF_NUMBER_TABLE
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_NUMBER_TABLE
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_NUMBER_TABLE
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  )

  as
    ddp_dctn_dtl pa_deductions.g_dctn_txntbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p5(ddp_dctn_dtl, p0_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    pa_deductions.create_deduction_txn(ddp_dctn_dtl,
      p_msg_count,
      p_msg_data,
      p_return_status,
      p_calling_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_out_p5(ddp_dctn_dtl, p0_a0
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
      );




  end;

  procedure update_deduction_hdr(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_NUMBER_TABLE
    , p0_a15 in out nocopy JTF_NUMBER_TABLE
    , p0_a16 in out nocopy JTF_DATE_TABLE
    , p0_a17 in out nocopy JTF_DATE_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  )

  as
    ddp_dctn_hdr pa_deductions.g_dctn_hdrtbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p4(ddp_dctn_hdr, p0_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    pa_deductions.update_deduction_hdr(ddp_dctn_hdr,
      p_msg_count,
      p_msg_data,
      p_return_status,
      p_calling_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_out_p4(ddp_dctn_hdr, p0_a0
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
      );




  end;

  procedure update_deduction_txn(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_DATE_TABLE
    , p0_a6 in out nocopy JTF_DATE_TABLE
    , p0_a7 in out nocopy JTF_NUMBER_TABLE
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_NUMBER_TABLE
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_NUMBER_TABLE
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  )

  as
    ddp_dctn_dtl pa_deductions.g_dctn_txntbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p5(ddp_dctn_dtl, p0_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    pa_deductions.update_deduction_txn(ddp_dctn_dtl,
      p_msg_count,
      p_msg_data,
      p_return_status,
      p_calling_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_out_p5(ddp_dctn_dtl, p0_a0
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
      );




  end;

  procedure delete_deduction_hdr(p_dctn_hdrid JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
  )

  as
    ddp_dctn_hdrid pa_deductions.g_dctn_hdrid;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p0(ddp_dctn_hdrid, p_dctn_hdrid);




    -- here's the delegated call to the old PL/SQL routine
    pa_deductions.delete_deduction_hdr(ddp_dctn_hdrid,
      p_msg_count,
      p_msg_data,
      p_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure delete_deduction_txn(p_dctn_txnid JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
  )

  as
    ddp_dctn_txnid pa_deductions.g_dctn_txnid;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p1(ddp_dctn_txnid, p_dctn_txnid);




    -- here's the delegated call to the old PL/SQL routine
    pa_deductions.delete_deduction_txn(ddp_dctn_txnid,
      p_msg_count,
      p_msg_data,
      p_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure validate_deduction_hdr(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_NUMBER_TABLE
    , p0_a15 in out nocopy JTF_NUMBER_TABLE
    , p0_a16 in out nocopy JTF_DATE_TABLE
    , p0_a17 in out nocopy JTF_DATE_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_dctn_hdr pa_deductions.g_dctn_hdrtbl;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p4(ddp_dctn_hdr, p0_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := pa_deductions.validate_deduction_hdr(ddp_dctn_hdr,
      p_msg_count,
      p_msg_data,
      p_return_status,
      p_calling_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
    pa_deductions_w.rosetta_table_copy_out_p4(ddp_dctn_hdr, p0_a0
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
      );




  end;

  procedure validate_deduction_txn(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_DATE_TABLE
    , p0_a6 in out nocopy JTF_DATE_TABLE
    , p0_a7 in out nocopy JTF_NUMBER_TABLE
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_NUMBER_TABLE
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_NUMBER_TABLE
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_dctn_dtl pa_deductions.g_dctn_txntbl;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_deductions_w.rosetta_table_copy_in_p5(ddp_dctn_dtl, p0_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := pa_deductions.validate_deduction_txn(ddp_dctn_dtl,
      p_msg_count,
      p_msg_data,
      p_return_status,
      p_calling_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
    pa_deductions_w.rosetta_table_copy_out_p5(ddp_dctn_dtl, p0_a0
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
      );




  end;

end pa_deductions_w;

/
