--------------------------------------------------------
--  DDL for Package Body CN_PLAN_ELEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLAN_ELEMENT_PVT_W" as
  /* $Header: cnwpeb.pls 120.2.12000000.2 2007/10/08 18:50:40 rnagired ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_plan_element_pvt.plan_element_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_1900
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_4000
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
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
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).quota_type_code := a3(indx);
          t(ddindx).target := a4(indx);
          t(ddindx).payment_amount := a5(indx);
          t(ddindx).performance_goal := a6(indx);
          t(ddindx).incentive_type_code := a7(indx);
          t(ddindx).start_date := a8(indx);
          t(ddindx).end_date := a9(indx);
          t(ddindx).credit_type_id := a10(indx);
          t(ddindx).interval_type_id := a11(indx);
          t(ddindx).calc_formula_id := a12(indx);
          t(ddindx).liability_account_id := a13(indx);
          t(ddindx).expense_account_id := a14(indx);
          t(ddindx).liability_account_cc := a15(indx);
          t(ddindx).expense_account_cc := a16(indx);
          t(ddindx).vesting_flag := a17(indx);
          t(ddindx).quota_group_code := a18(indx);
          t(ddindx).payment_group_code := a19(indx);
          t(ddindx).attribute_category := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).addup_from_rev_class_flag := a36(indx);
          t(ddindx).payee_assign_flag := a37(indx);
          t(ddindx).package_name := a38(indx);
          t(ddindx).object_version_number := a39(indx);
          t(ddindx).org_id := a40(indx);
          t(ddindx).indirect_credit_code := a41(indx);
          t(ddindx).quota_status := a42(indx);
          t(ddindx).call_type := a43(indx);
          t(ddindx).sreps_enddated_flag := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_plan_element_pvt.plan_element_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_1900
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_1900();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_4000();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
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
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_1900();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_4000();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
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
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
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
        a43.extend(t.count);
        a44.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).quota_type_code;
          a4(indx) := t(ddindx).target;
          a5(indx) := t(ddindx).payment_amount;
          a6(indx) := t(ddindx).performance_goal;
          a7(indx) := t(ddindx).incentive_type_code;
          a8(indx) := t(ddindx).start_date;
          a9(indx) := t(ddindx).end_date;
          a10(indx) := t(ddindx).credit_type_id;
          a11(indx) := t(ddindx).interval_type_id;
          a12(indx) := t(ddindx).calc_formula_id;
          a13(indx) := t(ddindx).liability_account_id;
          a14(indx) := t(ddindx).expense_account_id;
          a15(indx) := t(ddindx).liability_account_cc;
          a16(indx) := t(ddindx).expense_account_cc;
          a17(indx) := t(ddindx).vesting_flag;
          a18(indx) := t(ddindx).quota_group_code;
          a19(indx) := t(ddindx).payment_group_code;
          a20(indx) := t(ddindx).attribute_category;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := t(ddindx).addup_from_rev_class_flag;
          a37(indx) := t(ddindx).payee_assign_flag;
          a38(indx) := t(ddindx).package_name;
          a39(indx) := t(ddindx).object_version_number;
          a40(indx) := t(ddindx).org_id;
          a41(indx) := t(ddindx).indirect_credit_code;
          a42(indx) := t(ddindx).quota_status;
          a43(indx) := t(ddindx).call_type;
          a44(indx) := t(ddindx).sreps_enddated_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure is_valid_org(p_org_id  NUMBER
    , p_quota_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := cn_plan_element_pvt.is_valid_org(p_org_id,
      p_quota_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure create_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR
    , p4_a16 in out nocopy  VARCHAR
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_element cn_plan_element_pvt.plan_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_plan_element.quota_id := p4_a0;
    ddp_plan_element.name := p4_a1;
    ddp_plan_element.description := p4_a2;
    ddp_plan_element.quota_type_code := p4_a3;
    ddp_plan_element.target := p4_a4;
    ddp_plan_element.payment_amount := p4_a5;
    ddp_plan_element.performance_goal := p4_a6;
    ddp_plan_element.incentive_type_code := p4_a7;
    ddp_plan_element.start_date := p4_a8;
    ddp_plan_element.end_date := p4_a9;
    ddp_plan_element.credit_type_id := p4_a10;
    ddp_plan_element.interval_type_id := p4_a11;
    ddp_plan_element.calc_formula_id := p4_a12;
    ddp_plan_element.liability_account_id := p4_a13;
    ddp_plan_element.expense_account_id := p4_a14;
    ddp_plan_element.liability_account_cc := p4_a15;
    ddp_plan_element.expense_account_cc := p4_a16;
    ddp_plan_element.vesting_flag := p4_a17;
    ddp_plan_element.quota_group_code := p4_a18;
    ddp_plan_element.payment_group_code := p4_a19;
    ddp_plan_element.attribute_category := p4_a20;
    ddp_plan_element.attribute1 := p4_a21;
    ddp_plan_element.attribute2 := p4_a22;
    ddp_plan_element.attribute3 := p4_a23;
    ddp_plan_element.attribute4 := p4_a24;
    ddp_plan_element.attribute5 := p4_a25;
    ddp_plan_element.attribute6 := p4_a26;
    ddp_plan_element.attribute7 := p4_a27;
    ddp_plan_element.attribute8 := p4_a28;
    ddp_plan_element.attribute9 := p4_a29;
    ddp_plan_element.attribute10 := p4_a30;
    ddp_plan_element.attribute11 := p4_a31;
    ddp_plan_element.attribute12 := p4_a32;
    ddp_plan_element.attribute13 := p4_a33;
    ddp_plan_element.attribute14 := p4_a34;
    ddp_plan_element.attribute15 := p4_a35;
    ddp_plan_element.addup_from_rev_class_flag := p4_a36;
    ddp_plan_element.payee_assign_flag := p4_a37;
    ddp_plan_element.package_name := p4_a38;
    ddp_plan_element.object_version_number := p4_a39;
    ddp_plan_element.org_id := p4_a40;
    ddp_plan_element.indirect_credit_code := p4_a41;
    ddp_plan_element.quota_status := p4_a42;
    ddp_plan_element.call_type := p4_a43;
    ddp_plan_element.sreps_enddated_flag := p4_a44;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pvt.create_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_plan_element,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_plan_element.quota_id;
    p4_a1 := ddp_plan_element.name;
    p4_a2 := ddp_plan_element.description;
    p4_a3 := ddp_plan_element.quota_type_code;
    p4_a4 := ddp_plan_element.target;
    p4_a5 := ddp_plan_element.payment_amount;
    p4_a6 := ddp_plan_element.performance_goal;
    p4_a7 := ddp_plan_element.incentive_type_code;
    p4_a8 := ddp_plan_element.start_date;
    p4_a9 := ddp_plan_element.end_date;
    p4_a10 := ddp_plan_element.credit_type_id;
    p4_a11 := ddp_plan_element.interval_type_id;
    p4_a12 := ddp_plan_element.calc_formula_id;
    p4_a13 := ddp_plan_element.liability_account_id;
    p4_a14 := ddp_plan_element.expense_account_id;
    p4_a15 := ddp_plan_element.liability_account_cc;
    p4_a16 := ddp_plan_element.expense_account_cc;
    p4_a17 := ddp_plan_element.vesting_flag;
    p4_a18 := ddp_plan_element.quota_group_code;
    p4_a19 := ddp_plan_element.payment_group_code;
    p4_a20 := ddp_plan_element.attribute_category;
    p4_a21 := ddp_plan_element.attribute1;
    p4_a22 := ddp_plan_element.attribute2;
    p4_a23 := ddp_plan_element.attribute3;
    p4_a24 := ddp_plan_element.attribute4;
    p4_a25 := ddp_plan_element.attribute5;
    p4_a26 := ddp_plan_element.attribute6;
    p4_a27 := ddp_plan_element.attribute7;
    p4_a28 := ddp_plan_element.attribute8;
    p4_a29 := ddp_plan_element.attribute9;
    p4_a30 := ddp_plan_element.attribute10;
    p4_a31 := ddp_plan_element.attribute11;
    p4_a32 := ddp_plan_element.attribute12;
    p4_a33 := ddp_plan_element.attribute13;
    p4_a34 := ddp_plan_element.attribute14;
    p4_a35 := ddp_plan_element.attribute15;
    p4_a36 := ddp_plan_element.addup_from_rev_class_flag;
    p4_a37 := ddp_plan_element.payee_assign_flag;
    p4_a38 := ddp_plan_element.package_name;
    p4_a39 := ddp_plan_element.object_version_number;
    p4_a40 := ddp_plan_element.org_id;
    p4_a41 := ddp_plan_element.indirect_credit_code;
    p4_a42 := ddp_plan_element.quota_status;
    p4_a43 := ddp_plan_element.call_type;
    p4_a44 := ddp_plan_element.sreps_enddated_flag;



  end;

  procedure update_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR
    , p4_a16 in out nocopy  VARCHAR
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_element cn_plan_element_pvt.plan_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_plan_element.quota_id := p4_a0;
    ddp_plan_element.name := p4_a1;
    ddp_plan_element.description := p4_a2;
    ddp_plan_element.quota_type_code := p4_a3;
    ddp_plan_element.target := p4_a4;
    ddp_plan_element.payment_amount := p4_a5;
    ddp_plan_element.performance_goal := p4_a6;
    ddp_plan_element.incentive_type_code := p4_a7;
    ddp_plan_element.start_date := p4_a8;
    ddp_plan_element.end_date := p4_a9;
    ddp_plan_element.credit_type_id := p4_a10;
    ddp_plan_element.interval_type_id := p4_a11;
    ddp_plan_element.calc_formula_id := p4_a12;
    ddp_plan_element.liability_account_id := p4_a13;
    ddp_plan_element.expense_account_id := p4_a14;
    ddp_plan_element.liability_account_cc := p4_a15;
    ddp_plan_element.expense_account_cc := p4_a16;
    ddp_plan_element.vesting_flag := p4_a17;
    ddp_plan_element.quota_group_code := p4_a18;
    ddp_plan_element.payment_group_code := p4_a19;
    ddp_plan_element.attribute_category := p4_a20;
    ddp_plan_element.attribute1 := p4_a21;
    ddp_plan_element.attribute2 := p4_a22;
    ddp_plan_element.attribute3 := p4_a23;
    ddp_plan_element.attribute4 := p4_a24;
    ddp_plan_element.attribute5 := p4_a25;
    ddp_plan_element.attribute6 := p4_a26;
    ddp_plan_element.attribute7 := p4_a27;
    ddp_plan_element.attribute8 := p4_a28;
    ddp_plan_element.attribute9 := p4_a29;
    ddp_plan_element.attribute10 := p4_a30;
    ddp_plan_element.attribute11 := p4_a31;
    ddp_plan_element.attribute12 := p4_a32;
    ddp_plan_element.attribute13 := p4_a33;
    ddp_plan_element.attribute14 := p4_a34;
    ddp_plan_element.attribute15 := p4_a35;
    ddp_plan_element.addup_from_rev_class_flag := p4_a36;
    ddp_plan_element.payee_assign_flag := p4_a37;
    ddp_plan_element.package_name := p4_a38;
    ddp_plan_element.object_version_number := p4_a39;
    ddp_plan_element.org_id := p4_a40;
    ddp_plan_element.indirect_credit_code := p4_a41;
    ddp_plan_element.quota_status := p4_a42;
    ddp_plan_element.call_type := p4_a43;
    ddp_plan_element.sreps_enddated_flag := p4_a44;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pvt.update_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_plan_element,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_plan_element.quota_id;
    p4_a1 := ddp_plan_element.name;
    p4_a2 := ddp_plan_element.description;
    p4_a3 := ddp_plan_element.quota_type_code;
    p4_a4 := ddp_plan_element.target;
    p4_a5 := ddp_plan_element.payment_amount;
    p4_a6 := ddp_plan_element.performance_goal;
    p4_a7 := ddp_plan_element.incentive_type_code;
    p4_a8 := ddp_plan_element.start_date;
    p4_a9 := ddp_plan_element.end_date;
    p4_a10 := ddp_plan_element.credit_type_id;
    p4_a11 := ddp_plan_element.interval_type_id;
    p4_a12 := ddp_plan_element.calc_formula_id;
    p4_a13 := ddp_plan_element.liability_account_id;
    p4_a14 := ddp_plan_element.expense_account_id;
    p4_a15 := ddp_plan_element.liability_account_cc;
    p4_a16 := ddp_plan_element.expense_account_cc;
    p4_a17 := ddp_plan_element.vesting_flag;
    p4_a18 := ddp_plan_element.quota_group_code;
    p4_a19 := ddp_plan_element.payment_group_code;
    p4_a20 := ddp_plan_element.attribute_category;
    p4_a21 := ddp_plan_element.attribute1;
    p4_a22 := ddp_plan_element.attribute2;
    p4_a23 := ddp_plan_element.attribute3;
    p4_a24 := ddp_plan_element.attribute4;
    p4_a25 := ddp_plan_element.attribute5;
    p4_a26 := ddp_plan_element.attribute6;
    p4_a27 := ddp_plan_element.attribute7;
    p4_a28 := ddp_plan_element.attribute8;
    p4_a29 := ddp_plan_element.attribute9;
    p4_a30 := ddp_plan_element.attribute10;
    p4_a31 := ddp_plan_element.attribute11;
    p4_a32 := ddp_plan_element.attribute12;
    p4_a33 := ddp_plan_element.attribute13;
    p4_a34 := ddp_plan_element.attribute14;
    p4_a35 := ddp_plan_element.attribute15;
    p4_a36 := ddp_plan_element.addup_from_rev_class_flag;
    p4_a37 := ddp_plan_element.payee_assign_flag;
    p4_a38 := ddp_plan_element.package_name;
    p4_a39 := ddp_plan_element.object_version_number;
    p4_a40 := ddp_plan_element.org_id;
    p4_a41 := ddp_plan_element.indirect_credit_code;
    p4_a42 := ddp_plan_element.quota_status;
    p4_a43 := ddp_plan_element.call_type;
    p4_a44 := ddp_plan_element.sreps_enddated_flag;



  end;

  procedure delete_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR
    , p4_a16 in out nocopy  VARCHAR
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_element cn_plan_element_pvt.plan_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_plan_element.quota_id := p4_a0;
    ddp_plan_element.name := p4_a1;
    ddp_plan_element.description := p4_a2;
    ddp_plan_element.quota_type_code := p4_a3;
    ddp_plan_element.target := p4_a4;
    ddp_plan_element.payment_amount := p4_a5;
    ddp_plan_element.performance_goal := p4_a6;
    ddp_plan_element.incentive_type_code := p4_a7;
    ddp_plan_element.start_date := p4_a8;
    ddp_plan_element.end_date := p4_a9;
    ddp_plan_element.credit_type_id := p4_a10;
    ddp_plan_element.interval_type_id := p4_a11;
    ddp_plan_element.calc_formula_id := p4_a12;
    ddp_plan_element.liability_account_id := p4_a13;
    ddp_plan_element.expense_account_id := p4_a14;
    ddp_plan_element.liability_account_cc := p4_a15;
    ddp_plan_element.expense_account_cc := p4_a16;
    ddp_plan_element.vesting_flag := p4_a17;
    ddp_plan_element.quota_group_code := p4_a18;
    ddp_plan_element.payment_group_code := p4_a19;
    ddp_plan_element.attribute_category := p4_a20;
    ddp_plan_element.attribute1 := p4_a21;
    ddp_plan_element.attribute2 := p4_a22;
    ddp_plan_element.attribute3 := p4_a23;
    ddp_plan_element.attribute4 := p4_a24;
    ddp_plan_element.attribute5 := p4_a25;
    ddp_plan_element.attribute6 := p4_a26;
    ddp_plan_element.attribute7 := p4_a27;
    ddp_plan_element.attribute8 := p4_a28;
    ddp_plan_element.attribute9 := p4_a29;
    ddp_plan_element.attribute10 := p4_a30;
    ddp_plan_element.attribute11 := p4_a31;
    ddp_plan_element.attribute12 := p4_a32;
    ddp_plan_element.attribute13 := p4_a33;
    ddp_plan_element.attribute14 := p4_a34;
    ddp_plan_element.attribute15 := p4_a35;
    ddp_plan_element.addup_from_rev_class_flag := p4_a36;
    ddp_plan_element.payee_assign_flag := p4_a37;
    ddp_plan_element.package_name := p4_a38;
    ddp_plan_element.object_version_number := p4_a39;
    ddp_plan_element.org_id := p4_a40;
    ddp_plan_element.indirect_credit_code := p4_a41;
    ddp_plan_element.quota_status := p4_a42;
    ddp_plan_element.call_type := p4_a43;
    ddp_plan_element.sreps_enddated_flag := p4_a44;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pvt.delete_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_plan_element,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_plan_element.quota_id;
    p4_a1 := ddp_plan_element.name;
    p4_a2 := ddp_plan_element.description;
    p4_a3 := ddp_plan_element.quota_type_code;
    p4_a4 := ddp_plan_element.target;
    p4_a5 := ddp_plan_element.payment_amount;
    p4_a6 := ddp_plan_element.performance_goal;
    p4_a7 := ddp_plan_element.incentive_type_code;
    p4_a8 := ddp_plan_element.start_date;
    p4_a9 := ddp_plan_element.end_date;
    p4_a10 := ddp_plan_element.credit_type_id;
    p4_a11 := ddp_plan_element.interval_type_id;
    p4_a12 := ddp_plan_element.calc_formula_id;
    p4_a13 := ddp_plan_element.liability_account_id;
    p4_a14 := ddp_plan_element.expense_account_id;
    p4_a15 := ddp_plan_element.liability_account_cc;
    p4_a16 := ddp_plan_element.expense_account_cc;
    p4_a17 := ddp_plan_element.vesting_flag;
    p4_a18 := ddp_plan_element.quota_group_code;
    p4_a19 := ddp_plan_element.payment_group_code;
    p4_a20 := ddp_plan_element.attribute_category;
    p4_a21 := ddp_plan_element.attribute1;
    p4_a22 := ddp_plan_element.attribute2;
    p4_a23 := ddp_plan_element.attribute3;
    p4_a24 := ddp_plan_element.attribute4;
    p4_a25 := ddp_plan_element.attribute5;
    p4_a26 := ddp_plan_element.attribute6;
    p4_a27 := ddp_plan_element.attribute7;
    p4_a28 := ddp_plan_element.attribute8;
    p4_a29 := ddp_plan_element.attribute9;
    p4_a30 := ddp_plan_element.attribute10;
    p4_a31 := ddp_plan_element.attribute11;
    p4_a32 := ddp_plan_element.attribute12;
    p4_a33 := ddp_plan_element.attribute13;
    p4_a34 := ddp_plan_element.attribute14;
    p4_a35 := ddp_plan_element.attribute15;
    p4_a36 := ddp_plan_element.addup_from_rev_class_flag;
    p4_a37 := ddp_plan_element.payee_assign_flag;
    p4_a38 := ddp_plan_element.package_name;
    p4_a39 := ddp_plan_element.object_version_number;
    p4_a40 := ddp_plan_element.org_id;
    p4_a41 := ddp_plan_element.indirect_credit_code;
    p4_a42 := ddp_plan_element.quota_status;
    p4_a43 := ddp_plan_element.call_type;
    p4_a44 := ddp_plan_element.sreps_enddated_flag;



  end;

  procedure duplicate_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_quota_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  VARCHAR2
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  NUMBER
    , p5_a6 out nocopy  NUMBER
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  DATE
    , p5_a9 out nocopy  DATE
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  NUMBER
    , p5_a14 out nocopy  NUMBER
    , p5_a15 out nocopy  VARCHAR
    , p5_a16 out nocopy  VARCHAR
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  VARCHAR2
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  VARCHAR2
    , p5_a25 out nocopy  VARCHAR2
    , p5_a26 out nocopy  VARCHAR2
    , p5_a27 out nocopy  VARCHAR2
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  VARCHAR2
    , p5_a33 out nocopy  VARCHAR2
    , p5_a34 out nocopy  VARCHAR2
    , p5_a35 out nocopy  VARCHAR2
    , p5_a36 out nocopy  VARCHAR2
    , p5_a37 out nocopy  VARCHAR2
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  NUMBER
    , p5_a40 out nocopy  NUMBER
    , p5_a41 out nocopy  VARCHAR2
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  VARCHAR2
    , p5_a44 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddx_plan_element cn_plan_element_pvt.plan_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pvt.duplicate_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_quota_id,
      ddx_plan_element,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_plan_element.quota_id;
    p5_a1 := ddx_plan_element.name;
    p5_a2 := ddx_plan_element.description;
    p5_a3 := ddx_plan_element.quota_type_code;
    p5_a4 := ddx_plan_element.target;
    p5_a5 := ddx_plan_element.payment_amount;
    p5_a6 := ddx_plan_element.performance_goal;
    p5_a7 := ddx_plan_element.incentive_type_code;
    p5_a8 := ddx_plan_element.start_date;
    p5_a9 := ddx_plan_element.end_date;
    p5_a10 := ddx_plan_element.credit_type_id;
    p5_a11 := ddx_plan_element.interval_type_id;
    p5_a12 := ddx_plan_element.calc_formula_id;
    p5_a13 := ddx_plan_element.liability_account_id;
    p5_a14 := ddx_plan_element.expense_account_id;
    p5_a15 := ddx_plan_element.liability_account_cc;
    p5_a16 := ddx_plan_element.expense_account_cc;
    p5_a17 := ddx_plan_element.vesting_flag;
    p5_a18 := ddx_plan_element.quota_group_code;
    p5_a19 := ddx_plan_element.payment_group_code;
    p5_a20 := ddx_plan_element.attribute_category;
    p5_a21 := ddx_plan_element.attribute1;
    p5_a22 := ddx_plan_element.attribute2;
    p5_a23 := ddx_plan_element.attribute3;
    p5_a24 := ddx_plan_element.attribute4;
    p5_a25 := ddx_plan_element.attribute5;
    p5_a26 := ddx_plan_element.attribute6;
    p5_a27 := ddx_plan_element.attribute7;
    p5_a28 := ddx_plan_element.attribute8;
    p5_a29 := ddx_plan_element.attribute9;
    p5_a30 := ddx_plan_element.attribute10;
    p5_a31 := ddx_plan_element.attribute11;
    p5_a32 := ddx_plan_element.attribute12;
    p5_a33 := ddx_plan_element.attribute13;
    p5_a34 := ddx_plan_element.attribute14;
    p5_a35 := ddx_plan_element.attribute15;
    p5_a36 := ddx_plan_element.addup_from_rev_class_flag;
    p5_a37 := ddx_plan_element.payee_assign_flag;
    p5_a38 := ddx_plan_element.package_name;
    p5_a39 := ddx_plan_element.object_version_number;
    p5_a40 := ddx_plan_element.org_id;
    p5_a41 := ddx_plan_element.indirect_credit_code;
    p5_a42 := ddx_plan_element.quota_status;
    p5_a43 := ddx_plan_element.call_type;
    p5_a44 := ddx_plan_element.sreps_enddated_flag;




  end;

  procedure validate_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_action  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  DATE
    , p5_a9 in out nocopy  DATE
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR
    , p5_a16 in out nocopy  VARCHAR
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  VARCHAR2
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  NUMBER
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  DATE
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR
    , p6_a16  VARCHAR
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_element cn_plan_element_pvt.plan_element_rec_type;
    ddp_old_plan_element cn_plan_element_pvt.plan_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_plan_element.quota_id := p5_a0;
    ddp_plan_element.name := p5_a1;
    ddp_plan_element.description := p5_a2;
    ddp_plan_element.quota_type_code := p5_a3;
    ddp_plan_element.target := p5_a4;
    ddp_plan_element.payment_amount := p5_a5;
    ddp_plan_element.performance_goal := p5_a6;
    ddp_plan_element.incentive_type_code := p5_a7;
    ddp_plan_element.start_date := p5_a8;
    ddp_plan_element.end_date := p5_a9;
    ddp_plan_element.credit_type_id := p5_a10;
    ddp_plan_element.interval_type_id := p5_a11;
    ddp_plan_element.calc_formula_id := p5_a12;
    ddp_plan_element.liability_account_id := p5_a13;
    ddp_plan_element.expense_account_id := p5_a14;
    ddp_plan_element.liability_account_cc := p5_a15;
    ddp_plan_element.expense_account_cc := p5_a16;
    ddp_plan_element.vesting_flag := p5_a17;
    ddp_plan_element.quota_group_code := p5_a18;
    ddp_plan_element.payment_group_code := p5_a19;
    ddp_plan_element.attribute_category := p5_a20;
    ddp_plan_element.attribute1 := p5_a21;
    ddp_plan_element.attribute2 := p5_a22;
    ddp_plan_element.attribute3 := p5_a23;
    ddp_plan_element.attribute4 := p5_a24;
    ddp_plan_element.attribute5 := p5_a25;
    ddp_plan_element.attribute6 := p5_a26;
    ddp_plan_element.attribute7 := p5_a27;
    ddp_plan_element.attribute8 := p5_a28;
    ddp_plan_element.attribute9 := p5_a29;
    ddp_plan_element.attribute10 := p5_a30;
    ddp_plan_element.attribute11 := p5_a31;
    ddp_plan_element.attribute12 := p5_a32;
    ddp_plan_element.attribute13 := p5_a33;
    ddp_plan_element.attribute14 := p5_a34;
    ddp_plan_element.attribute15 := p5_a35;
    ddp_plan_element.addup_from_rev_class_flag := p5_a36;
    ddp_plan_element.payee_assign_flag := p5_a37;
    ddp_plan_element.package_name := p5_a38;
    ddp_plan_element.object_version_number := p5_a39;
    ddp_plan_element.org_id := p5_a40;
    ddp_plan_element.indirect_credit_code := p5_a41;
    ddp_plan_element.quota_status := p5_a42;
    ddp_plan_element.call_type := p5_a43;
    ddp_plan_element.sreps_enddated_flag := p5_a44;

    ddp_old_plan_element.quota_id := p6_a0;
    ddp_old_plan_element.name := p6_a1;
    ddp_old_plan_element.description := p6_a2;
    ddp_old_plan_element.quota_type_code := p6_a3;
    ddp_old_plan_element.target := p6_a4;
    ddp_old_plan_element.payment_amount := p6_a5;
    ddp_old_plan_element.performance_goal := p6_a6;
    ddp_old_plan_element.incentive_type_code := p6_a7;
    ddp_old_plan_element.start_date := p6_a8;
    ddp_old_plan_element.end_date := p6_a9;
    ddp_old_plan_element.credit_type_id := p6_a10;
    ddp_old_plan_element.interval_type_id := p6_a11;
    ddp_old_plan_element.calc_formula_id := p6_a12;
    ddp_old_plan_element.liability_account_id := p6_a13;
    ddp_old_plan_element.expense_account_id := p6_a14;
    ddp_old_plan_element.liability_account_cc := p6_a15;
    ddp_old_plan_element.expense_account_cc := p6_a16;
    ddp_old_plan_element.vesting_flag := p6_a17;
    ddp_old_plan_element.quota_group_code := p6_a18;
    ddp_old_plan_element.payment_group_code := p6_a19;
    ddp_old_plan_element.attribute_category := p6_a20;
    ddp_old_plan_element.attribute1 := p6_a21;
    ddp_old_plan_element.attribute2 := p6_a22;
    ddp_old_plan_element.attribute3 := p6_a23;
    ddp_old_plan_element.attribute4 := p6_a24;
    ddp_old_plan_element.attribute5 := p6_a25;
    ddp_old_plan_element.attribute6 := p6_a26;
    ddp_old_plan_element.attribute7 := p6_a27;
    ddp_old_plan_element.attribute8 := p6_a28;
    ddp_old_plan_element.attribute9 := p6_a29;
    ddp_old_plan_element.attribute10 := p6_a30;
    ddp_old_plan_element.attribute11 := p6_a31;
    ddp_old_plan_element.attribute12 := p6_a32;
    ddp_old_plan_element.attribute13 := p6_a33;
    ddp_old_plan_element.attribute14 := p6_a34;
    ddp_old_plan_element.attribute15 := p6_a35;
    ddp_old_plan_element.addup_from_rev_class_flag := p6_a36;
    ddp_old_plan_element.payee_assign_flag := p6_a37;
    ddp_old_plan_element.package_name := p6_a38;
    ddp_old_plan_element.object_version_number := p6_a39;
    ddp_old_plan_element.org_id := p6_a40;
    ddp_old_plan_element.indirect_credit_code := p6_a41;
    ddp_old_plan_element.quota_status := p6_a42;
    ddp_old_plan_element.call_type := p6_a43;
    ddp_old_plan_element.sreps_enddated_flag := p6_a44;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_element_pvt.validate_plan_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_action,
      ddp_plan_element,
      ddp_old_plan_element,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_plan_element.quota_id;
    p5_a1 := ddp_plan_element.name;
    p5_a2 := ddp_plan_element.description;
    p5_a3 := ddp_plan_element.quota_type_code;
    p5_a4 := ddp_plan_element.target;
    p5_a5 := ddp_plan_element.payment_amount;
    p5_a6 := ddp_plan_element.performance_goal;
    p5_a7 := ddp_plan_element.incentive_type_code;
    p5_a8 := ddp_plan_element.start_date;
    p5_a9 := ddp_plan_element.end_date;
    p5_a10 := ddp_plan_element.credit_type_id;
    p5_a11 := ddp_plan_element.interval_type_id;
    p5_a12 := ddp_plan_element.calc_formula_id;
    p5_a13 := ddp_plan_element.liability_account_id;
    p5_a14 := ddp_plan_element.expense_account_id;
    p5_a15 := ddp_plan_element.liability_account_cc;
    p5_a16 := ddp_plan_element.expense_account_cc;
    p5_a17 := ddp_plan_element.vesting_flag;
    p5_a18 := ddp_plan_element.quota_group_code;
    p5_a19 := ddp_plan_element.payment_group_code;
    p5_a20 := ddp_plan_element.attribute_category;
    p5_a21 := ddp_plan_element.attribute1;
    p5_a22 := ddp_plan_element.attribute2;
    p5_a23 := ddp_plan_element.attribute3;
    p5_a24 := ddp_plan_element.attribute4;
    p5_a25 := ddp_plan_element.attribute5;
    p5_a26 := ddp_plan_element.attribute6;
    p5_a27 := ddp_plan_element.attribute7;
    p5_a28 := ddp_plan_element.attribute8;
    p5_a29 := ddp_plan_element.attribute9;
    p5_a30 := ddp_plan_element.attribute10;
    p5_a31 := ddp_plan_element.attribute11;
    p5_a32 := ddp_plan_element.attribute12;
    p5_a33 := ddp_plan_element.attribute13;
    p5_a34 := ddp_plan_element.attribute14;
    p5_a35 := ddp_plan_element.attribute15;
    p5_a36 := ddp_plan_element.addup_from_rev_class_flag;
    p5_a37 := ddp_plan_element.payee_assign_flag;
    p5_a38 := ddp_plan_element.package_name;
    p5_a39 := ddp_plan_element.object_version_number;
    p5_a40 := ddp_plan_element.org_id;
    p5_a41 := ddp_plan_element.indirect_credit_code;
    p5_a42 := ddp_plan_element.quota_status;
    p5_a43 := ddp_plan_element.call_type;
    p5_a44 := ddp_plan_element.sreps_enddated_flag;




  end;

end cn_plan_element_pvt_w;

/
