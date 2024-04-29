--------------------------------------------------------
--  DDL for Package Body CN_PLAN_ELEMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLAN_ELEMENT_PUB_W" as
  /* $Header: cnwppes.pls 120.1.12000000.2 2007/10/09 06:28:56 rnagired ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy cn_plan_element_pub.plan_element_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_1900
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).description := a1(indx);
          t(ddindx).period_type := a2(indx);
          t(ddindx).element_type := a3(indx);
          t(ddindx).target := a4(indx);
          t(ddindx).incentive_type := a5(indx);
          t(ddindx).credit_type := a6(indx);
          t(ddindx).calc_formula_name := a7(indx);
          t(ddindx).rt_sched_custom_flag := a8(indx);
          t(ddindx).package_name := a9(indx);
          t(ddindx).performance_goal := a10(indx);
          t(ddindx).payment_amount := a11(indx);
          t(ddindx).start_date := a12(indx);
          t(ddindx).end_date := a13(indx);
          t(ddindx).status := a14(indx);
          t(ddindx).interval_name := a15(indx);
          t(ddindx).payee_assign_flag := a16(indx);
          t(ddindx).vesting_flag := a17(indx);
          t(ddindx).addup_from_rev_class_flag := a18(indx);
          t(ddindx).expense_account_id := a19(indx);
          t(ddindx).liability_account_id := a20(indx);
          t(ddindx).quota_group_code := a21(indx);
          t(ddindx).payment_group_code := a22(indx);
          t(ddindx).attribute_category := a23(indx);
          t(ddindx).attribute1 := a24(indx);
          t(ddindx).attribute2 := a25(indx);
          t(ddindx).attribute3 := a26(indx);
          t(ddindx).attribute4 := a27(indx);
          t(ddindx).attribute5 := a28(indx);
          t(ddindx).attribute6 := a29(indx);
          t(ddindx).attribute7 := a30(indx);
          t(ddindx).attribute8 := a31(indx);
          t(ddindx).attribute9 := a32(indx);
          t(ddindx).attribute10 := a33(indx);
          t(ddindx).attribute11 := a34(indx);
          t(ddindx).attribute12 := a35(indx);
          t(ddindx).attribute13 := a36(indx);
          t(ddindx).attribute14 := a37(indx);
          t(ddindx).attribute15 := a38(indx);
          t(ddindx).org_id := a39(indx);
          t(ddindx).quota_id := a40(indx);
          t(ddindx).indirect_credit := a41(indx);
          t(ddindx).sreps_enddated_flag := a42(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_plan_element_pub.plan_element_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_1900
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_1900();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_1900();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
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
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).description;
          a2(indx) := t(ddindx).period_type;
          a3(indx) := t(ddindx).element_type;
          a4(indx) := t(ddindx).target;
          a5(indx) := t(ddindx).incentive_type;
          a6(indx) := t(ddindx).credit_type;
          a7(indx) := t(ddindx).calc_formula_name;
          a8(indx) := t(ddindx).rt_sched_custom_flag;
          a9(indx) := t(ddindx).package_name;
          a10(indx) := t(ddindx).performance_goal;
          a11(indx) := t(ddindx).payment_amount;
          a12(indx) := t(ddindx).start_date;
          a13(indx) := t(ddindx).end_date;
          a14(indx) := t(ddindx).status;
          a15(indx) := t(ddindx).interval_name;
          a16(indx) := t(ddindx).payee_assign_flag;
          a17(indx) := t(ddindx).vesting_flag;
          a18(indx) := t(ddindx).addup_from_rev_class_flag;
          a19(indx) := t(ddindx).expense_account_id;
          a20(indx) := t(ddindx).liability_account_id;
          a21(indx) := t(ddindx).quota_group_code;
          a22(indx) := t(ddindx).payment_group_code;
          a23(indx) := t(ddindx).attribute_category;
          a24(indx) := t(ddindx).attribute1;
          a25(indx) := t(ddindx).attribute2;
          a26(indx) := t(ddindx).attribute3;
          a27(indx) := t(ddindx).attribute4;
          a28(indx) := t(ddindx).attribute5;
          a29(indx) := t(ddindx).attribute6;
          a30(indx) := t(ddindx).attribute7;
          a31(indx) := t(ddindx).attribute8;
          a32(indx) := t(ddindx).attribute9;
          a33(indx) := t(ddindx).attribute10;
          a34(indx) := t(ddindx).attribute11;
          a35(indx) := t(ddindx).attribute12;
          a36(indx) := t(ddindx).attribute13;
          a37(indx) := t(ddindx).attribute14;
          a38(indx) := t(ddindx).attribute15;
          a39(indx) := t(ddindx).org_id;
          a40(indx) := t(ddindx).quota_id;
          a41(indx) := t(ddindx).indirect_credit;
          a42(indx) := t(ddindx).sreps_enddated_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_plan_element_pub.period_quotas_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
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
          t(ddindx).period_name := a0(indx);
          t(ddindx).period_target := a1(indx);
          t(ddindx).period_payment := a2(indx);
          t(ddindx).performance_goal := a3(indx);
          t(ddindx).attribute1 := a4(indx);
          t(ddindx).attribute2 := a5(indx);
          t(ddindx).attribute3 := a6(indx);
          t(ddindx).attribute4 := a7(indx);
          t(ddindx).attribute5 := a8(indx);
          t(ddindx).attribute6 := a9(indx);
          t(ddindx).attribute7 := a10(indx);
          t(ddindx).attribute8 := a11(indx);
          t(ddindx).attribute9 := a12(indx);
          t(ddindx).attribute10 := a13(indx);
          t(ddindx).attribute11 := a14(indx);
          t(ddindx).attribute12 := a15(indx);
          t(ddindx).attribute13 := a16(indx);
          t(ddindx).attribute14 := a17(indx);
          t(ddindx).attribute15 := a18(indx);
          t(ddindx).period_name_old := a19(indx);
          t(ddindx).org_id := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_plan_element_pub.period_quotas_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := t(ddindx).period_name;
          a1(indx) := t(ddindx).period_target;
          a2(indx) := t(ddindx).period_payment;
          a3(indx) := t(ddindx).performance_goal;
          a4(indx) := t(ddindx).attribute1;
          a5(indx) := t(ddindx).attribute2;
          a6(indx) := t(ddindx).attribute3;
          a7(indx) := t(ddindx).attribute4;
          a8(indx) := t(ddindx).attribute5;
          a9(indx) := t(ddindx).attribute6;
          a10(indx) := t(ddindx).attribute7;
          a11(indx) := t(ddindx).attribute8;
          a12(indx) := t(ddindx).attribute9;
          a13(indx) := t(ddindx).attribute10;
          a14(indx) := t(ddindx).attribute11;
          a15(indx) := t(ddindx).attribute12;
          a16(indx) := t(ddindx).attribute13;
          a17(indx) := t(ddindx).attribute14;
          a18(indx) := t(ddindx).attribute15;
          a19(indx) := t(ddindx).period_name_old;
          a20(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy cn_plan_element_pub.revenue_class_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_1900
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rev_class_name := a0(indx);
          t(ddindx).rev_class_target := a1(indx);
          t(ddindx).rev_class_payment_amount := a2(indx);
          t(ddindx).rev_class_performance_goal := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).attribute_category := a5(indx);
          t(ddindx).attribute1 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).attribute10 := a15(indx);
          t(ddindx).attribute11 := a16(indx);
          t(ddindx).attribute12 := a17(indx);
          t(ddindx).attribute13 := a18(indx);
          t(ddindx).attribute14 := a19(indx);
          t(ddindx).attribute15 := a20(indx);
          t(ddindx).rev_class_name_old := a21(indx);
          t(ddindx).org_id := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t cn_plan_element_pub.revenue_class_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_1900
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_1900();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_1900();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rev_class_name;
          a1(indx) := t(ddindx).rev_class_target;
          a2(indx) := t(ddindx).rev_class_payment_amount;
          a3(indx) := t(ddindx).rev_class_performance_goal;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).attribute_category;
          a6(indx) := t(ddindx).attribute1;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).attribute10;
          a16(indx) := t(ddindx).attribute11;
          a17(indx) := t(ddindx).attribute12;
          a18(indx) := t(ddindx).attribute13;
          a19(indx) := t(ddindx).attribute14;
          a20(indx) := t(ddindx).attribute15;
          a21(indx) := t(ddindx).rev_class_name_old;
          a22(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p11(t out nocopy cn_plan_element_pub.rev_uplift_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rev_class_name := a0(indx);
          t(ddindx).start_date := a1(indx);
          t(ddindx).end_date := a2(indx);
          t(ddindx).rev_class_payment_uplift := a3(indx);
          t(ddindx).rev_class_quota_uplift := a4(indx);
          t(ddindx).attribute_category := a5(indx);
          t(ddindx).attribute1 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).attribute10 := a15(indx);
          t(ddindx).attribute11 := a16(indx);
          t(ddindx).attribute12 := a17(indx);
          t(ddindx).attribute13 := a18(indx);
          t(ddindx).attribute14 := a19(indx);
          t(ddindx).attribute15 := a20(indx);
          t(ddindx).rev_class_name_old := a21(indx);
          t(ddindx).start_date_old := a22(indx);
          t(ddindx).end_date_old := a23(indx);
          t(ddindx).org_id := a24(indx);
          t(ddindx).object_version_number := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t cn_plan_element_pub.rev_uplift_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rev_class_name;
          a1(indx) := t(ddindx).start_date;
          a2(indx) := t(ddindx).end_date;
          a3(indx) := t(ddindx).rev_class_payment_uplift;
          a4(indx) := t(ddindx).rev_class_quota_uplift;
          a5(indx) := t(ddindx).attribute_category;
          a6(indx) := t(ddindx).attribute1;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).attribute10;
          a16(indx) := t(ddindx).attribute11;
          a17(indx) := t(ddindx).attribute12;
          a18(indx) := t(ddindx).attribute13;
          a19(indx) := t(ddindx).attribute14;
          a20(indx) := t(ddindx).attribute15;
          a21(indx) := t(ddindx).rev_class_name_old;
          a22(indx) := t(ddindx).start_date_old;
          a23(indx) := t(ddindx).end_date_old;
          a24(indx) := t(ddindx).org_id;
          a25(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p14(t out nocopy cn_plan_element_pub.trx_factor_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).trx_type := a0(indx);
          t(ddindx).event_factor := a1(indx);
          t(ddindx).rev_class_name := a2(indx);
          t(ddindx).org_id := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t cn_plan_element_pub.trx_factor_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).trx_type;
          a1(indx) := t(ddindx).event_factor;
          a2(indx) := t(ddindx).rev_class_name;
          a3(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p18(t out nocopy cn_plan_element_pub.rt_quota_asgns_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate_schedule_name := a0(indx);
          t(ddindx).calc_formula_name := a1(indx);
          t(ddindx).start_date := a2(indx);
          t(ddindx).end_date := a3(indx);
          t(ddindx).attribute_category := a4(indx);
          t(ddindx).attribute1 := a5(indx);
          t(ddindx).attribute2 := a6(indx);
          t(ddindx).attribute3 := a7(indx);
          t(ddindx).attribute4 := a8(indx);
          t(ddindx).attribute5 := a9(indx);
          t(ddindx).attribute6 := a10(indx);
          t(ddindx).attribute7 := a11(indx);
          t(ddindx).attribute8 := a12(indx);
          t(ddindx).attribute9 := a13(indx);
          t(ddindx).attribute10 := a14(indx);
          t(ddindx).attribute11 := a15(indx);
          t(ddindx).attribute12 := a16(indx);
          t(ddindx).attribute13 := a17(indx);
          t(ddindx).attribute14 := a18(indx);
          t(ddindx).attribute15 := a19(indx);
          t(ddindx).rate_schedule_name_old := a20(indx);
          t(ddindx).start_date_old := a21(indx);
          t(ddindx).end_date_old := a22(indx);
          t(ddindx).org_id := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t cn_plan_element_pub.rt_quota_asgns_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).rate_schedule_name;
          a1(indx) := t(ddindx).calc_formula_name;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          a4(indx) := t(ddindx).attribute_category;
          a5(indx) := t(ddindx).attribute1;
          a6(indx) := t(ddindx).attribute2;
          a7(indx) := t(ddindx).attribute3;
          a8(indx) := t(ddindx).attribute4;
          a9(indx) := t(ddindx).attribute5;
          a10(indx) := t(ddindx).attribute6;
          a11(indx) := t(ddindx).attribute7;
          a12(indx) := t(ddindx).attribute8;
          a13(indx) := t(ddindx).attribute9;
          a14(indx) := t(ddindx).attribute10;
          a15(indx) := t(ddindx).attribute11;
          a16(indx) := t(ddindx).attribute12;
          a17(indx) := t(ddindx).attribute13;
          a18(indx) := t(ddindx).attribute14;
          a19(indx) := t(ddindx).attribute15;
          a20(indx) := t(ddindx).rate_schedule_name_old;
          a21(indx) := t(ddindx).start_date_old;
          a22(indx) := t(ddindx).end_date_old;
          a23(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure create_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_1900
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_200
    , p8_a7 JTF_VARCHAR2_TABLE_200
    , p8_a8 JTF_VARCHAR2_TABLE_200
    , p8_a9 JTF_VARCHAR2_TABLE_200
    , p8_a10 JTF_VARCHAR2_TABLE_200
    , p8_a11 JTF_VARCHAR2_TABLE_200
    , p8_a12 JTF_VARCHAR2_TABLE_200
    , p8_a13 JTF_VARCHAR2_TABLE_200
    , p8_a14 JTF_VARCHAR2_TABLE_200
    , p8_a15 JTF_VARCHAR2_TABLE_200
    , p8_a16 JTF_VARCHAR2_TABLE_200
    , p8_a17 JTF_VARCHAR2_TABLE_200
    , p8_a18 JTF_VARCHAR2_TABLE_200
    , p8_a19 JTF_VARCHAR2_TABLE_200
    , p8_a20 JTF_VARCHAR2_TABLE_200
    , p8_a21 JTF_VARCHAR2_TABLE_100
    , p8_a22 JTF_NUMBER_TABLE
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_DATE_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_200
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_200
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_200
    , p9_a11 JTF_VARCHAR2_TABLE_200
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_200
    , p9_a14 JTF_VARCHAR2_TABLE_200
    , p9_a15 JTF_VARCHAR2_TABLE_200
    , p9_a16 JTF_VARCHAR2_TABLE_200
    , p9_a17 JTF_VARCHAR2_TABLE_200
    , p9_a18 JTF_VARCHAR2_TABLE_200
    , p9_a19 JTF_VARCHAR2_TABLE_200
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_100
    , p9_a22 JTF_DATE_TABLE
    , p9_a23 JTF_DATE_TABLE
    , p9_a24 JTF_NUMBER_TABLE
    , p9_a25 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_VARCHAR2_TABLE_100
    , p10_a3 JTF_NUMBER_TABLE
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_VARCHAR2_TABLE_200
    , p11_a5 JTF_VARCHAR2_TABLE_200
    , p11_a6 JTF_VARCHAR2_TABLE_200
    , p11_a7 JTF_VARCHAR2_TABLE_200
    , p11_a8 JTF_VARCHAR2_TABLE_200
    , p11_a9 JTF_VARCHAR2_TABLE_200
    , p11_a10 JTF_VARCHAR2_TABLE_200
    , p11_a11 JTF_VARCHAR2_TABLE_200
    , p11_a12 JTF_VARCHAR2_TABLE_200
    , p11_a13 JTF_VARCHAR2_TABLE_200
    , p11_a14 JTF_VARCHAR2_TABLE_200
    , p11_a15 JTF_VARCHAR2_TABLE_200
    , p11_a16 JTF_VARCHAR2_TABLE_200
    , p11_a17 JTF_VARCHAR2_TABLE_200
    , p11_a18 JTF_VARCHAR2_TABLE_200
    , p11_a19 JTF_VARCHAR2_TABLE_100
    , p11_a20 JTF_NUMBER_TABLE
    , p12_a0 JTF_VARCHAR2_TABLE_100
    , p12_a1 JTF_VARCHAR2_TABLE_100
    , p12_a2 JTF_DATE_TABLE
    , p12_a3 JTF_DATE_TABLE
    , p12_a4 JTF_VARCHAR2_TABLE_100
    , p12_a5 JTF_VARCHAR2_TABLE_200
    , p12_a6 JTF_VARCHAR2_TABLE_200
    , p12_a7 JTF_VARCHAR2_TABLE_200
    , p12_a8 JTF_VARCHAR2_TABLE_200
    , p12_a9 JTF_VARCHAR2_TABLE_200
    , p12_a10 JTF_VARCHAR2_TABLE_200
    , p12_a11 JTF_VARCHAR2_TABLE_200
    , p12_a12 JTF_VARCHAR2_TABLE_200
    , p12_a13 JTF_VARCHAR2_TABLE_200
    , p12_a14 JTF_VARCHAR2_TABLE_200
    , p12_a15 JTF_VARCHAR2_TABLE_200
    , p12_a16 JTF_VARCHAR2_TABLE_200
    , p12_a17 JTF_VARCHAR2_TABLE_200
    , p12_a18 JTF_VARCHAR2_TABLE_200
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_DATE_TABLE
    , p12_a22 JTF_DATE_TABLE
    , p12_a23 JTF_NUMBER_TABLE
    , x_loading_status out nocopy  VARCHAR2
    , p_is_duplicate  VARCHAR2
  )

  as
    ddp_plan_element_rec cn_plan_element_pub.plan_element_rec_type;
    ddp_revenue_class_rec_tbl cn_plan_element_pub.revenue_class_rec_tbl_type;
    ddp_rev_uplift_rec_tbl cn_plan_element_pub.rev_uplift_rec_tbl_type;
    ddp_trx_factor_rec_tbl cn_plan_element_pub.trx_factor_rec_tbl_type;
    ddp_period_quotas_rec_tbl cn_plan_element_pub.period_quotas_rec_tbl_type;
    ddp_rt_quota_asgns_rec_tbl cn_plan_element_pub.rt_quota_asgns_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_plan_element_rec.name := p7_a0;
    ddp_plan_element_rec.description := p7_a1;
    ddp_plan_element_rec.period_type := p7_a2;
    ddp_plan_element_rec.element_type := p7_a3;
    ddp_plan_element_rec.target := p7_a4;
    ddp_plan_element_rec.incentive_type := p7_a5;
    ddp_plan_element_rec.credit_type := p7_a6;
    ddp_plan_element_rec.calc_formula_name := p7_a7;
    ddp_plan_element_rec.rt_sched_custom_flag := p7_a8;
    ddp_plan_element_rec.package_name := p7_a9;
    ddp_plan_element_rec.performance_goal := p7_a10;
    ddp_plan_element_rec.payment_amount := p7_a11;
    ddp_plan_element_rec.start_date := p7_a12;
    ddp_plan_element_rec.end_date := p7_a13;
    ddp_plan_element_rec.status := p7_a14;
    ddp_plan_element_rec.interval_name := p7_a15;
    ddp_plan_element_rec.payee_assign_flag := p7_a16;
    ddp_plan_element_rec.vesting_flag := p7_a17;
    ddp_plan_element_rec.addup_from_rev_class_flag := p7_a18;
    ddp_plan_element_rec.expense_account_id := p7_a19;
    ddp_plan_element_rec.liability_account_id := p7_a20;
    ddp_plan_element_rec.quota_group_code := p7_a21;
    ddp_plan_element_rec.payment_group_code := p7_a22;
    ddp_plan_element_rec.attribute_category := p7_a23;
    ddp_plan_element_rec.attribute1 := p7_a24;
    ddp_plan_element_rec.attribute2 := p7_a25;
    ddp_plan_element_rec.attribute3 := p7_a26;
    ddp_plan_element_rec.attribute4 := p7_a27;
    ddp_plan_element_rec.attribute5 := p7_a28;
    ddp_plan_element_rec.attribute6 := p7_a29;
    ddp_plan_element_rec.attribute7 := p7_a30;
    ddp_plan_element_rec.attribute8 := p7_a31;
    ddp_plan_element_rec.attribute9 := p7_a32;
    ddp_plan_element_rec.attribute10 := p7_a33;
    ddp_plan_element_rec.attribute11 := p7_a34;
    ddp_plan_element_rec.attribute12 := p7_a35;
    ddp_plan_element_rec.attribute13 := p7_a36;
    ddp_plan_element_rec.attribute14 := p7_a37;
    ddp_plan_element_rec.attribute15 := p7_a38;
    ddp_plan_element_rec.org_id := p7_a39;
    ddp_plan_element_rec.quota_id := p7_a40;
    ddp_plan_element_rec.indirect_credit := p7_a41;
    ddp_plan_element_rec.sreps_enddated_flag := p7_a42;

    cn_plan_element_pub_w.rosetta_table_copy_in_p8(ddp_revenue_class_rec_tbl, p8_a0
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
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p11(ddp_rev_uplift_rec_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p14(ddp_trx_factor_rec_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p5(ddp_period_quotas_rec_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p18(ddp_rt_quota_asgns_rec_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      );



    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pub.create_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_plan_element_rec,
      ddp_revenue_class_rec_tbl,
      ddp_rev_uplift_rec_tbl,
      ddp_trx_factor_rec_tbl,
      ddp_period_quotas_rec_tbl,
      ddp_rt_quota_asgns_rec_tbl,
      x_loading_status,
      p_is_duplicate);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure update_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p_quota_name_old  VARCHAR2
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_VARCHAR2_TABLE_1900
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_200
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_200
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_200
    , p9_a11 JTF_VARCHAR2_TABLE_200
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_200
    , p9_a14 JTF_VARCHAR2_TABLE_200
    , p9_a15 JTF_VARCHAR2_TABLE_200
    , p9_a16 JTF_VARCHAR2_TABLE_200
    , p9_a17 JTF_VARCHAR2_TABLE_200
    , p9_a18 JTF_VARCHAR2_TABLE_200
    , p9_a19 JTF_VARCHAR2_TABLE_200
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_100
    , p9_a22 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_DATE_TABLE
    , p10_a2 JTF_DATE_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , p10_a6 JTF_VARCHAR2_TABLE_200
    , p10_a7 JTF_VARCHAR2_TABLE_200
    , p10_a8 JTF_VARCHAR2_TABLE_200
    , p10_a9 JTF_VARCHAR2_TABLE_200
    , p10_a10 JTF_VARCHAR2_TABLE_200
    , p10_a11 JTF_VARCHAR2_TABLE_200
    , p10_a12 JTF_VARCHAR2_TABLE_200
    , p10_a13 JTF_VARCHAR2_TABLE_200
    , p10_a14 JTF_VARCHAR2_TABLE_200
    , p10_a15 JTF_VARCHAR2_TABLE_200
    , p10_a16 JTF_VARCHAR2_TABLE_200
    , p10_a17 JTF_VARCHAR2_TABLE_200
    , p10_a18 JTF_VARCHAR2_TABLE_200
    , p10_a19 JTF_VARCHAR2_TABLE_200
    , p10_a20 JTF_VARCHAR2_TABLE_200
    , p10_a21 JTF_VARCHAR2_TABLE_100
    , p10_a22 JTF_DATE_TABLE
    , p10_a23 JTF_DATE_TABLE
    , p10_a24 JTF_NUMBER_TABLE
    , p10_a25 JTF_NUMBER_TABLE
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_NUMBER_TABLE
    , p12_a0 JTF_VARCHAR2_TABLE_100
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_VARCHAR2_TABLE_200
    , p12_a5 JTF_VARCHAR2_TABLE_200
    , p12_a6 JTF_VARCHAR2_TABLE_200
    , p12_a7 JTF_VARCHAR2_TABLE_200
    , p12_a8 JTF_VARCHAR2_TABLE_200
    , p12_a9 JTF_VARCHAR2_TABLE_200
    , p12_a10 JTF_VARCHAR2_TABLE_200
    , p12_a11 JTF_VARCHAR2_TABLE_200
    , p12_a12 JTF_VARCHAR2_TABLE_200
    , p12_a13 JTF_VARCHAR2_TABLE_200
    , p12_a14 JTF_VARCHAR2_TABLE_200
    , p12_a15 JTF_VARCHAR2_TABLE_200
    , p12_a16 JTF_VARCHAR2_TABLE_200
    , p12_a17 JTF_VARCHAR2_TABLE_200
    , p12_a18 JTF_VARCHAR2_TABLE_200
    , p12_a19 JTF_VARCHAR2_TABLE_100
    , p12_a20 JTF_NUMBER_TABLE
    , p13_a0 JTF_VARCHAR2_TABLE_100
    , p13_a1 JTF_VARCHAR2_TABLE_100
    , p13_a2 JTF_DATE_TABLE
    , p13_a3 JTF_DATE_TABLE
    , p13_a4 JTF_VARCHAR2_TABLE_100
    , p13_a5 JTF_VARCHAR2_TABLE_200
    , p13_a6 JTF_VARCHAR2_TABLE_200
    , p13_a7 JTF_VARCHAR2_TABLE_200
    , p13_a8 JTF_VARCHAR2_TABLE_200
    , p13_a9 JTF_VARCHAR2_TABLE_200
    , p13_a10 JTF_VARCHAR2_TABLE_200
    , p13_a11 JTF_VARCHAR2_TABLE_200
    , p13_a12 JTF_VARCHAR2_TABLE_200
    , p13_a13 JTF_VARCHAR2_TABLE_200
    , p13_a14 JTF_VARCHAR2_TABLE_200
    , p13_a15 JTF_VARCHAR2_TABLE_200
    , p13_a16 JTF_VARCHAR2_TABLE_200
    , p13_a17 JTF_VARCHAR2_TABLE_200
    , p13_a18 JTF_VARCHAR2_TABLE_200
    , p13_a19 JTF_VARCHAR2_TABLE_200
    , p13_a20 JTF_VARCHAR2_TABLE_100
    , p13_a21 JTF_DATE_TABLE
    , p13_a22 JTF_DATE_TABLE
    , p13_a23 JTF_NUMBER_TABLE
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_new_plan_element_rec cn_plan_element_pub.plan_element_rec_type;
    ddp_revenue_class_rec_tbl cn_plan_element_pub.revenue_class_rec_tbl_type;
    ddp_rev_uplift_rec_tbl cn_plan_element_pub.rev_uplift_rec_tbl_type;
    ddp_trx_factor_rec_tbl cn_plan_element_pub.trx_factor_rec_tbl_type;
    ddp_period_quotas_rec_tbl cn_plan_element_pub.period_quotas_rec_tbl_type;
    ddp_rt_quota_asgns_rec_tbl cn_plan_element_pub.rt_quota_asgns_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_new_plan_element_rec.name := p7_a0;
    ddp_new_plan_element_rec.description := p7_a1;
    ddp_new_plan_element_rec.period_type := p7_a2;
    ddp_new_plan_element_rec.element_type := p7_a3;
    ddp_new_plan_element_rec.target := p7_a4;
    ddp_new_plan_element_rec.incentive_type := p7_a5;
    ddp_new_plan_element_rec.credit_type := p7_a6;
    ddp_new_plan_element_rec.calc_formula_name := p7_a7;
    ddp_new_plan_element_rec.rt_sched_custom_flag := p7_a8;
    ddp_new_plan_element_rec.package_name := p7_a9;
    ddp_new_plan_element_rec.performance_goal := p7_a10;
    ddp_new_plan_element_rec.payment_amount := p7_a11;
    ddp_new_plan_element_rec.start_date := p7_a12;
    ddp_new_plan_element_rec.end_date := p7_a13;
    ddp_new_plan_element_rec.status := p7_a14;
    ddp_new_plan_element_rec.interval_name := p7_a15;
    ddp_new_plan_element_rec.payee_assign_flag := p7_a16;
    ddp_new_plan_element_rec.vesting_flag := p7_a17;
    ddp_new_plan_element_rec.addup_from_rev_class_flag := p7_a18;
    ddp_new_plan_element_rec.expense_account_id := p7_a19;
    ddp_new_plan_element_rec.liability_account_id := p7_a20;
    ddp_new_plan_element_rec.quota_group_code := p7_a21;
    ddp_new_plan_element_rec.payment_group_code := p7_a22;
    ddp_new_plan_element_rec.attribute_category := p7_a23;
    ddp_new_plan_element_rec.attribute1 := p7_a24;
    ddp_new_plan_element_rec.attribute2 := p7_a25;
    ddp_new_plan_element_rec.attribute3 := p7_a26;
    ddp_new_plan_element_rec.attribute4 := p7_a27;
    ddp_new_plan_element_rec.attribute5 := p7_a28;
    ddp_new_plan_element_rec.attribute6 := p7_a29;
    ddp_new_plan_element_rec.attribute7 := p7_a30;
    ddp_new_plan_element_rec.attribute8 := p7_a31;
    ddp_new_plan_element_rec.attribute9 := p7_a32;
    ddp_new_plan_element_rec.attribute10 := p7_a33;
    ddp_new_plan_element_rec.attribute11 := p7_a34;
    ddp_new_plan_element_rec.attribute12 := p7_a35;
    ddp_new_plan_element_rec.attribute13 := p7_a36;
    ddp_new_plan_element_rec.attribute14 := p7_a37;
    ddp_new_plan_element_rec.attribute15 := p7_a38;
    ddp_new_plan_element_rec.org_id := p7_a39;
    ddp_new_plan_element_rec.quota_id := p7_a40;
    ddp_new_plan_element_rec.indirect_credit := p7_a41;
    ddp_new_plan_element_rec.sreps_enddated_flag := p7_a42;


    cn_plan_element_pub_w.rosetta_table_copy_in_p8(ddp_revenue_class_rec_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p11(ddp_rev_uplift_rec_tbl, p10_a0
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
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p14(ddp_trx_factor_rec_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p5(ddp_period_quotas_rec_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p18(ddp_rt_quota_asgns_rec_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      );


    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pub.update_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_new_plan_element_rec,
      p_quota_name_old,
      ddp_revenue_class_rec_tbl,
      ddp_rev_uplift_rec_tbl,
      ddp_trx_factor_rec_tbl,
      ddp_period_quotas_rec_tbl,
      ddp_rt_quota_asgns_rec_tbl,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure delete_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_1900
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_200
    , p8_a7 JTF_VARCHAR2_TABLE_200
    , p8_a8 JTF_VARCHAR2_TABLE_200
    , p8_a9 JTF_VARCHAR2_TABLE_200
    , p8_a10 JTF_VARCHAR2_TABLE_200
    , p8_a11 JTF_VARCHAR2_TABLE_200
    , p8_a12 JTF_VARCHAR2_TABLE_200
    , p8_a13 JTF_VARCHAR2_TABLE_200
    , p8_a14 JTF_VARCHAR2_TABLE_200
    , p8_a15 JTF_VARCHAR2_TABLE_200
    , p8_a16 JTF_VARCHAR2_TABLE_200
    , p8_a17 JTF_VARCHAR2_TABLE_200
    , p8_a18 JTF_VARCHAR2_TABLE_200
    , p8_a19 JTF_VARCHAR2_TABLE_200
    , p8_a20 JTF_VARCHAR2_TABLE_200
    , p8_a21 JTF_VARCHAR2_TABLE_100
    , p8_a22 JTF_NUMBER_TABLE
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_DATE_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_200
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_200
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_200
    , p9_a11 JTF_VARCHAR2_TABLE_200
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_200
    , p9_a14 JTF_VARCHAR2_TABLE_200
    , p9_a15 JTF_VARCHAR2_TABLE_200
    , p9_a16 JTF_VARCHAR2_TABLE_200
    , p9_a17 JTF_VARCHAR2_TABLE_200
    , p9_a18 JTF_VARCHAR2_TABLE_200
    , p9_a19 JTF_VARCHAR2_TABLE_200
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_100
    , p9_a22 JTF_DATE_TABLE
    , p9_a23 JTF_DATE_TABLE
    , p9_a24 JTF_NUMBER_TABLE
    , p9_a25 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_DATE_TABLE
    , p10_a3 JTF_DATE_TABLE
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_VARCHAR2_TABLE_200
    , p10_a6 JTF_VARCHAR2_TABLE_200
    , p10_a7 JTF_VARCHAR2_TABLE_200
    , p10_a8 JTF_VARCHAR2_TABLE_200
    , p10_a9 JTF_VARCHAR2_TABLE_200
    , p10_a10 JTF_VARCHAR2_TABLE_200
    , p10_a11 JTF_VARCHAR2_TABLE_200
    , p10_a12 JTF_VARCHAR2_TABLE_200
    , p10_a13 JTF_VARCHAR2_TABLE_200
    , p10_a14 JTF_VARCHAR2_TABLE_200
    , p10_a15 JTF_VARCHAR2_TABLE_200
    , p10_a16 JTF_VARCHAR2_TABLE_200
    , p10_a17 JTF_VARCHAR2_TABLE_200
    , p10_a18 JTF_VARCHAR2_TABLE_200
    , p10_a19 JTF_VARCHAR2_TABLE_200
    , p10_a20 JTF_VARCHAR2_TABLE_100
    , p10_a21 JTF_DATE_TABLE
    , p10_a22 JTF_DATE_TABLE
    , p10_a23 JTF_NUMBER_TABLE
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_quota_rec cn_plan_element_pub.plan_element_rec_type;
    ddp_revenue_class_rec_tbl cn_plan_element_pub.revenue_class_rec_tbl_type;
    ddp_rev_uplift_rec_tbl cn_plan_element_pub.rev_uplift_rec_tbl_type;
    ddp_rt_quota_asgns_rec_tbl cn_plan_element_pub.rt_quota_asgns_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_quota_rec.name := p7_a0;
    ddp_quota_rec.description := p7_a1;
    ddp_quota_rec.period_type := p7_a2;
    ddp_quota_rec.element_type := p7_a3;
    ddp_quota_rec.target := p7_a4;
    ddp_quota_rec.incentive_type := p7_a5;
    ddp_quota_rec.credit_type := p7_a6;
    ddp_quota_rec.calc_formula_name := p7_a7;
    ddp_quota_rec.rt_sched_custom_flag := p7_a8;
    ddp_quota_rec.package_name := p7_a9;
    ddp_quota_rec.performance_goal := p7_a10;
    ddp_quota_rec.payment_amount := p7_a11;
    ddp_quota_rec.start_date := p7_a12;
    ddp_quota_rec.end_date := p7_a13;
    ddp_quota_rec.status := p7_a14;
    ddp_quota_rec.interval_name := p7_a15;
    ddp_quota_rec.payee_assign_flag := p7_a16;
    ddp_quota_rec.vesting_flag := p7_a17;
    ddp_quota_rec.addup_from_rev_class_flag := p7_a18;
    ddp_quota_rec.expense_account_id := p7_a19;
    ddp_quota_rec.liability_account_id := p7_a20;
    ddp_quota_rec.quota_group_code := p7_a21;
    ddp_quota_rec.payment_group_code := p7_a22;
    ddp_quota_rec.attribute_category := p7_a23;
    ddp_quota_rec.attribute1 := p7_a24;
    ddp_quota_rec.attribute2 := p7_a25;
    ddp_quota_rec.attribute3 := p7_a26;
    ddp_quota_rec.attribute4 := p7_a27;
    ddp_quota_rec.attribute5 := p7_a28;
    ddp_quota_rec.attribute6 := p7_a29;
    ddp_quota_rec.attribute7 := p7_a30;
    ddp_quota_rec.attribute8 := p7_a31;
    ddp_quota_rec.attribute9 := p7_a32;
    ddp_quota_rec.attribute10 := p7_a33;
    ddp_quota_rec.attribute11 := p7_a34;
    ddp_quota_rec.attribute12 := p7_a35;
    ddp_quota_rec.attribute13 := p7_a36;
    ddp_quota_rec.attribute14 := p7_a37;
    ddp_quota_rec.attribute15 := p7_a38;
    ddp_quota_rec.org_id := p7_a39;
    ddp_quota_rec.quota_id := p7_a40;
    ddp_quota_rec.indirect_credit := p7_a41;
    ddp_quota_rec.sreps_enddated_flag := p7_a42;

    cn_plan_element_pub_w.rosetta_table_copy_in_p8(ddp_revenue_class_rec_tbl, p8_a0
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
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p11(ddp_rev_uplift_rec_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      );

    cn_plan_element_pub_w.rosetta_table_copy_in_p18(ddp_rt_quota_asgns_rec_tbl, p10_a0
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
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      );


    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pub.delete_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_quota_rec,
      ddp_revenue_class_rec_tbl,
      ddp_rev_uplift_rec_tbl,
      ddp_rt_quota_asgns_rec_tbl,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end cn_plan_element_pub_w;

/
