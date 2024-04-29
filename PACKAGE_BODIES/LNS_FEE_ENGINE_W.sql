--------------------------------------------------------
--  DDL for Package Body LNS_FEE_ENGINE_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FEE_ENGINE_W" as
  /* $Header: LNS_FEE_ENGINJ_B.pls 120.3.12010000.4 2010/02/24 01:45:44 mbolli ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_fee_engine.fee_basis_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).fee_basis_name := a0(indx);
          t(ddindx).fee_basis_amount := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t lns_fee_engine.fee_basis_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).fee_basis_name;
          a1(indx) := t(ddindx).fee_basis_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy lns_fee_engine.fee_structure_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).fee_description := a2(indx);
          t(ddindx).fee_category := a3(indx);
          t(ddindx).fee_type := a4(indx);
          t(ddindx).fee_amount := a5(indx);
          t(ddindx).fee_basis := a6(indx);
          t(ddindx).start_date_active := a7(indx);
          t(ddindx).end_date_active := a8(indx);
          t(ddindx).number_grace_days := a9(indx);
          t(ddindx).fee_billing_option := a10(indx);
          t(ddindx).fee_rate_type := a11(indx);
          t(ddindx).fee_from_installment := a12(indx);
          t(ddindx).fee_to_installment := a13(indx);
          t(ddindx).fee_waivable_flag := a14(indx);
          t(ddindx).fee_editable_flag := a15(indx);
          t(ddindx).fee_deletable_flag := a16(indx);
          t(ddindx).minimum_overdue_amount := a17(indx);
          t(ddindx).fee_basis_rule := a18(indx);
          t(ddindx).currency_code := a19(indx);
          t(ddindx).disb_header_id := a20(indx);
          t(ddindx).disbursement_amount := a21(indx);
          t(ddindx).disbursement_date := a22(indx);
          t(ddindx).phase := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t lns_fee_engine.fee_structure_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).fee_id;
          a1(indx) := t(ddindx).fee_name;
          a2(indx) := t(ddindx).fee_description;
          a3(indx) := t(ddindx).fee_category;
          a4(indx) := t(ddindx).fee_type;
          a5(indx) := t(ddindx).fee_amount;
          a6(indx) := t(ddindx).fee_basis;
          a7(indx) := t(ddindx).start_date_active;
          a8(indx) := t(ddindx).end_date_active;
          a9(indx) := t(ddindx).number_grace_days;
          a10(indx) := t(ddindx).fee_billing_option;
          a11(indx) := t(ddindx).fee_rate_type;
          a12(indx) := t(ddindx).fee_from_installment;
          a13(indx) := t(ddindx).fee_to_installment;
          a14(indx) := t(ddindx).fee_waivable_flag;
          a15(indx) := t(ddindx).fee_editable_flag;
          a16(indx) := t(ddindx).fee_deletable_flag;
          a17(indx) := t(ddindx).minimum_overdue_amount;
          a18(indx) := t(ddindx).fee_basis_rule;
          a19(indx) := t(ddindx).currency_code;
          a20(indx) := t(ddindx).disb_header_id;
          a21(indx) := t(ddindx).disbursement_amount;
          a22(indx) := t(ddindx).disbursement_date;
          a23(indx) := t(ddindx).phase;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy lns_fee_engine.fee_calc_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).fee_category := a2(indx);
          t(ddindx).fee_type := a3(indx);
          t(ddindx).fee_amount := a4(indx);
          t(ddindx).fee_installment := a5(indx);
          t(ddindx).fee_description := a6(indx);
          t(ddindx).fee_schedule_id := a7(indx);
          t(ddindx).fee_waivable_flag := a8(indx);
          t(ddindx).fee_editable_flag := a9(indx);
          t(ddindx).fee_deletable_flag := a10(indx);
          t(ddindx).waive_amount := a11(indx);
          t(ddindx).billed_flag := a12(indx);
          t(ddindx).active_flag := a13(indx);
          t(ddindx).disb_header_id := a14(indx);
          t(ddindx).fee_billing_option := a15(indx);
          t(ddindx).phase := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t lns_fee_engine.fee_calc_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).fee_id;
          a1(indx) := t(ddindx).fee_name;
          a2(indx) := t(ddindx).fee_category;
          a3(indx) := t(ddindx).fee_type;
          a4(indx) := t(ddindx).fee_amount;
          a5(indx) := t(ddindx).fee_installment;
          a6(indx) := t(ddindx).fee_description;
          a7(indx) := t(ddindx).fee_schedule_id;
          a8(indx) := t(ddindx).fee_waivable_flag;
          a9(indx) := t(ddindx).fee_editable_flag;
          a10(indx) := t(ddindx).fee_deletable_flag;
          a11(indx) := t(ddindx).waive_amount;
          a12(indx) := t(ddindx).billed_flag;
          a13(indx) := t(ddindx).active_flag;
          a14(indx) := t(ddindx).disb_header_id;
          a15(indx) := t(ddindx).fee_billing_option;
          a16(indx) := t(ddindx).phase;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure calculatefees(p_loan_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_NUMBER_TABLE
    , p_installment  NUMBER
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_300
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_DATE_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_VARCHAR2_TABLE_100
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_VARCHAR2_TABLE_100
    , p3_a19 JTF_VARCHAR2_TABLE_100
    , p3_a20 JTF_NUMBER_TABLE
    , p3_a21 JTF_NUMBER_TABLE
    , p3_a22 JTF_DATE_TABLE
    , p3_a23 JTF_VARCHAR2_TABLE_100
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_basis_tbl lns_fee_engine.fee_basis_tbl;
    ddp_fee_structures lns_fee_engine.fee_structure_tbl;
    ddx_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    lns_fee_engine_w.rosetta_table_copy_in_p1(ddp_fee_basis_tbl, p1_a0
      , p1_a1
      );


    lns_fee_engine_w.rosetta_table_copy_in_p3(ddp_fee_structures, p3_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.calculatefees(p_loan_id,
      ddp_fee_basis_tbl,
      p_installment,
      ddp_fee_structures,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    lns_fee_engine_w.rosetta_table_copy_out_p5(ddx_fees_tbl, p4_a0
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
      );



  end;

  procedure writefeeschedule(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a7 in out nocopy JTF_NUMBER_TABLE
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_NUMBER_TABLE
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    lns_fee_engine_w.rosetta_table_copy_in_p5(ddp_fees_tbl, p3_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.writefeeschedule(p_init_msg_list,
      p_commit,
      p_loan_id,
      ddp_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    lns_fee_engine_w.rosetta_table_copy_out_p5(ddp_fees_tbl, p3_a0
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
      );



  end;

  procedure updatefeeschedule(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_300
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p3_a9 JTF_VARCHAR2_TABLE_100
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    lns_fee_engine_w.rosetta_table_copy_in_p5(ddp_fees_tbl, p3_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.updatefeeschedule(p_init_msg_list,
      p_commit,
      p_loan_id,
      ddp_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure getfeeschedule(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p_disb_header_id  NUMBER
    , p_phase  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.getfeeschedule(p_init_msg_list,
      p_loan_id,
      p_installment_number,
      p_disb_header_id,
      p_phase,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    lns_fee_engine_w.rosetta_table_copy_out_p5(ddx_fees_tbl, p5_a0
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
      );



  end;

  procedure getfeedetails(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_NUMBER_TABLE
    , p_based_on_terms  VARCHAR2
    , p_phase  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_basis_tbl lns_fee_engine.fee_basis_tbl;
    ddx_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    lns_fee_engine_w.rosetta_table_copy_in_p1(ddp_fee_basis_tbl, p3_a0
      , p3_a1
      );







    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.getfeedetails(p_init_msg_list,
      p_loan_id,
      p_installment,
      ddp_fee_basis_tbl,
      p_based_on_terms,
      p_phase,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    lns_fee_engine_w.rosetta_table_copy_out_p5(ddx_fees_tbl, p6_a0
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
      );



  end;

  procedure processfees(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_NUMBER_TABLE
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_basis_tbl lns_fee_engine.fee_basis_tbl;
    ddp_fee_structures lns_fee_engine.fee_structure_tbl;
    ddx_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    lns_fee_engine_w.rosetta_table_copy_in_p1(ddp_fee_basis_tbl, p4_a0
      , p4_a1
      );

    lns_fee_engine_w.rosetta_table_copy_in_p3(ddp_fee_structures, p5_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.processfees(p_init_msg_list,
      p_commit,
      p_loan_id,
      p_installment_number,
      ddp_fee_basis_tbl,
      ddp_fee_structures,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    lns_fee_engine_w.rosetta_table_copy_out_p5(ddx_fees_tbl, p6_a0
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
      );



  end;

  procedure getsubmitforapprfeeschedule(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_billed_flag  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_fees_tbl lns_fee_engine.fee_calc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    lns_fee_engine.getsubmitforapprfeeschedule(p_init_msg_list,
      p_loan_id,
      p_billed_flag,
      ddx_fees_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    lns_fee_engine_w.rosetta_table_copy_out_p5(ddx_fees_tbl, p3_a0
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
      );



  end;

end lns_fee_engine_w;

/
