--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_ACCRUAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_ACCRUAL_PVT_W" as
  /* $Header: ozfwcacb.pls 120.5.12010000.3 2010/02/18 08:57:39 nepanda ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_claim_accrual_pvt.line_util_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).claim_line_util_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).claim_line_id := a7(indx);
          t(ddindx).utilization_id := a8(indx);
          t(ddindx).amount := a9(indx);
          t(ddindx).currency_code := a10(indx);
          t(ddindx).exchange_rate_type := a11(indx);
          t(ddindx).exchange_rate_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).exchange_rate := a13(indx);
          t(ddindx).acctd_amount := a14(indx);
          t(ddindx).util_curr_amount := a15(indx);
          t(ddindx).plan_curr_amount := a16(indx);
          t(ddindx).scan_unit := a17(indx);
          t(ddindx).activity_product_id := a18(indx);
          t(ddindx).uom_code := a19(indx);
          t(ddindx).quantity := a20(indx);
          t(ddindx).org_id := a21(indx);
          t(ddindx).univ_curr_amount := a22(indx);
          t(ddindx).fxgl_acctd_amount := a23(indx);
          t(ddindx).utilized_acctd_amount := a24(indx);
          t(ddindx).update_from_tbl_flag := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_claim_accrual_pvt.line_util_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).claim_line_util_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).claim_line_id;
          a8(indx) := t(ddindx).utilization_id;
          a9(indx) := t(ddindx).amount;
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := t(ddindx).exchange_rate_type;
          a12(indx) := t(ddindx).exchange_rate_date;
          a13(indx) := t(ddindx).exchange_rate;
          a14(indx) := t(ddindx).acctd_amount;
          a15(indx) := t(ddindx).util_curr_amount;
          a16(indx) := t(ddindx).plan_curr_amount;
          a17(indx) := t(ddindx).scan_unit;
          a18(indx) := t(ddindx).activity_product_id;
          a19(indx) := t(ddindx).uom_code;
          a20(indx) := t(ddindx).quantity;
          a21(indx) := t(ddindx).org_id;
          a22(indx) := t(ddindx).univ_curr_amount;
          a23(indx) := t(ddindx).fxgl_acctd_amount;
          a24(indx) := t(ddindx).utilized_acctd_amount;
          a25(indx) := t(ddindx).update_from_tbl_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p5(t out nocopy ozf_claim_accrual_pvt.offer_performance_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_id := a0(indx);
          t(ddindx).offer_performance_id := a1(indx);
          t(ddindx).product_attribute := a2(indx);
          t(ddindx).product_attr_value := a3(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).requirement_type := a6(indx);
          t(ddindx).estimated_value := a7(indx);
          t(ddindx).uom_code := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ozf_claim_accrual_pvt.offer_performance_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).offer_id;
          a1(indx) := t(ddindx).offer_performance_id;
          a2(indx) := t(ddindx).product_attribute;
          a3(indx) := t(ddindx).product_attr_value;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := t(ddindx).requirement_type;
          a7(indx) := t(ddindx).estimated_value;
          a8(indx) := t(ddindx).uom_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy ozf_claim_accrual_pvt.offer_earning_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_id := a0(indx);
          t(ddindx).acctd_amount_over := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ozf_claim_accrual_pvt.offer_earning_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).offer_id;
          a1(indx) := t(ddindx).acctd_amount_over;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure get_utiz_sql_stmt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_summary_view  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  NUMBER
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  DATE
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p9_a0 in out nocopy  VARCHAR2
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p_cust_account_id  NUMBER
    , x_utiz_sql_stmt out nocopy  VARCHAR2
  )

  as
    ddp_funds_util_flt ozf_claim_accrual_pvt.funds_util_flt_type;
    ddpx_currency_rec ozf_claim_accrual_pvt.currency_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_funds_util_flt.claim_line_id := p8_a0;
    ddp_funds_util_flt.fund_id := p8_a1;
    ddp_funds_util_flt.activity_type := p8_a2;
    ddp_funds_util_flt.activity_id := p8_a3;
    ddp_funds_util_flt.activity_product_id := p8_a4;
    ddp_funds_util_flt.schedule_id := p8_a5;
    ddp_funds_util_flt.offer_type := p8_a6;
    ddp_funds_util_flt.document_class := p8_a7;
    ddp_funds_util_flt.document_id := p8_a8;
    ddp_funds_util_flt.product_level_type := p8_a9;
    ddp_funds_util_flt.product_id := p8_a10;
    ddp_funds_util_flt.reference_type := p8_a11;
    ddp_funds_util_flt.reference_id := p8_a12;
    ddp_funds_util_flt.utilization_type := p8_a13;
    ddp_funds_util_flt.total_amount := p8_a14;
    ddp_funds_util_flt.old_total_amount := p8_a15;
    if p8_a16 is null
      then ddp_funds_util_flt.pay_over_all_flag := null;
    elsif p8_a16 = 0
      then ddp_funds_util_flt.pay_over_all_flag := false;
    else ddp_funds_util_flt.pay_over_all_flag := true;
    end if;
    ddp_funds_util_flt.total_units := p8_a17;
    ddp_funds_util_flt.old_total_units := p8_a18;
    ddp_funds_util_flt.quantity := p8_a19;
    ddp_funds_util_flt.uom_code := p8_a20;
    ddp_funds_util_flt.cust_account_id := p8_a21;
    ddp_funds_util_flt.relationship_type := p8_a22;
    ddp_funds_util_flt.related_cust_account_id := p8_a23;
    ddp_funds_util_flt.buy_group_cust_account_id := p8_a24;
    ddp_funds_util_flt.buy_group_party_id := p8_a25;
    ddp_funds_util_flt.select_cust_children_flag := p8_a26;
    ddp_funds_util_flt.pay_to_customer := p8_a27;
    ddp_funds_util_flt.prorate_earnings_flag := p8_a28;
    ddp_funds_util_flt.adjustment_type_id := p8_a29;
    ddp_funds_util_flt.end_date := rosetta_g_miss_date_in_map(p8_a30);
    ddp_funds_util_flt.run_mode := p8_a31;
    ddp_funds_util_flt.check_sales_rep_flag := p8_a32;
    ddp_funds_util_flt.group_by_offer := p8_a33;
    ddp_funds_util_flt.offer_payment_method := p8_a34;
    ddp_funds_util_flt.utiz_currency_code := p8_a35;
    ddp_funds_util_flt.bill_to_site_use_id := p8_a36;
    ddp_funds_util_flt.utilization_id := p8_a37;
    ddp_funds_util_flt.autopay_check := p8_a38;

    ddpx_currency_rec.functional_currency_code := p9_a0;
    ddpx_currency_rec.offer_currency_code := p9_a1;
    ddpx_currency_rec.universal_currency_code := p9_a2;
    ddpx_currency_rec.claim_currency_code := p9_a3;
    ddpx_currency_rec.transaction_currency_code := p9_a4;
    ddpx_currency_rec.association_currency_code := p9_a5;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.get_utiz_sql_stmt(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_summary_view,
      ddp_funds_util_flt,
      ddpx_currency_rec,
      p_cust_account_id,
      x_utiz_sql_stmt);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddpx_currency_rec.functional_currency_code;
    p9_a1 := ddpx_currency_rec.offer_currency_code;
    p9_a2 := ddpx_currency_rec.universal_currency_code;
    p9_a3 := ddpx_currency_rec.claim_currency_code;
    p9_a4 := ddpx_currency_rec.transaction_currency_code;
    p9_a5 := ddpx_currency_rec.association_currency_code;


  end;

  procedure create_line_util_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_VARCHAR2_TABLE_100
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_line_util_tbl ozf_claim_accrual_pvt.line_util_tbl_type;
    ddp_currency_rec ozf_claim_accrual_pvt.currency_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_accrual_pvt_w.rosetta_table_copy_in_p1(ddp_line_util_tbl, p7_a0
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
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      );

    ddp_currency_rec.functional_currency_code := p8_a0;
    ddp_currency_rec.offer_currency_code := p8_a1;
    ddp_currency_rec.universal_currency_code := p8_a2;
    ddp_currency_rec.claim_currency_code := p8_a3;
    ddp_currency_rec.transaction_currency_code := p8_a4;
    ddp_currency_rec.association_currency_code := p8_a5;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.create_line_util_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_line_util_tbl,
      ddp_currency_rec,
      p_mode,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure create_line_util(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p_mode  VARCHAR2
    , x_line_util_id out nocopy  NUMBER
  )

  as
    ddp_line_util_rec ozf_claim_accrual_pvt.line_util_rec_type;
    ddp_currency_rec ozf_claim_accrual_pvt.currency_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_line_util_rec.claim_line_util_id := p7_a0;
    ddp_line_util_rec.object_version_number := p7_a1;
    ddp_line_util_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_line_util_rec.last_updated_by := p7_a3;
    ddp_line_util_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_line_util_rec.created_by := p7_a5;
    ddp_line_util_rec.last_update_login := p7_a6;
    ddp_line_util_rec.claim_line_id := p7_a7;
    ddp_line_util_rec.utilization_id := p7_a8;
    ddp_line_util_rec.amount := p7_a9;
    ddp_line_util_rec.currency_code := p7_a10;
    ddp_line_util_rec.exchange_rate_type := p7_a11;
    ddp_line_util_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_line_util_rec.exchange_rate := p7_a13;
    ddp_line_util_rec.acctd_amount := p7_a14;
    ddp_line_util_rec.util_curr_amount := p7_a15;
    ddp_line_util_rec.plan_curr_amount := p7_a16;
    ddp_line_util_rec.scan_unit := p7_a17;
    ddp_line_util_rec.activity_product_id := p7_a18;
    ddp_line_util_rec.uom_code := p7_a19;
    ddp_line_util_rec.quantity := p7_a20;
    ddp_line_util_rec.org_id := p7_a21;
    ddp_line_util_rec.univ_curr_amount := p7_a22;
    ddp_line_util_rec.fxgl_acctd_amount := p7_a23;
    ddp_line_util_rec.utilized_acctd_amount := p7_a24;
    ddp_line_util_rec.update_from_tbl_flag := p7_a25;

    ddp_currency_rec.functional_currency_code := p8_a0;
    ddp_currency_rec.offer_currency_code := p8_a1;
    ddp_currency_rec.universal_currency_code := p8_a2;
    ddp_currency_rec.claim_currency_code := p8_a3;
    ddp_currency_rec.transaction_currency_code := p8_a4;
    ddp_currency_rec.association_currency_code := p8_a5;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.create_line_util(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_line_util_rec,
      ddp_currency_rec,
      p_mode,
      x_line_util_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_line_util_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_VARCHAR2_TABLE_100
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_line_util_tbl ozf_claim_accrual_pvt.line_util_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_accrual_pvt_w.rosetta_table_copy_in_p1(ddp_line_util_tbl, p7_a0
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
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.update_line_util_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_line_util_tbl,
      p_mode,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_line_util(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version out nocopy  NUMBER
  )

  as
    ddp_line_util_rec ozf_claim_accrual_pvt.line_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_line_util_rec.claim_line_util_id := p7_a0;
    ddp_line_util_rec.object_version_number := p7_a1;
    ddp_line_util_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_line_util_rec.last_updated_by := p7_a3;
    ddp_line_util_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_line_util_rec.created_by := p7_a5;
    ddp_line_util_rec.last_update_login := p7_a6;
    ddp_line_util_rec.claim_line_id := p7_a7;
    ddp_line_util_rec.utilization_id := p7_a8;
    ddp_line_util_rec.amount := p7_a9;
    ddp_line_util_rec.currency_code := p7_a10;
    ddp_line_util_rec.exchange_rate_type := p7_a11;
    ddp_line_util_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_line_util_rec.exchange_rate := p7_a13;
    ddp_line_util_rec.acctd_amount := p7_a14;
    ddp_line_util_rec.util_curr_amount := p7_a15;
    ddp_line_util_rec.plan_curr_amount := p7_a16;
    ddp_line_util_rec.scan_unit := p7_a17;
    ddp_line_util_rec.activity_product_id := p7_a18;
    ddp_line_util_rec.uom_code := p7_a19;
    ddp_line_util_rec.quantity := p7_a20;
    ddp_line_util_rec.org_id := p7_a21;
    ddp_line_util_rec.univ_curr_amount := p7_a22;
    ddp_line_util_rec.fxgl_acctd_amount := p7_a23;
    ddp_line_util_rec.utilized_acctd_amount := p7_a24;
    ddp_line_util_rec.update_from_tbl_flag := p7_a25;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.update_line_util(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_line_util_rec,
      p_mode,
      x_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure delete_line_util_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_VARCHAR2_TABLE_100
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_line_util_tbl ozf_claim_accrual_pvt.line_util_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_accrual_pvt_w.rosetta_table_copy_in_p1(ddp_line_util_tbl, p7_a0
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
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.delete_line_util_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_line_util_tbl,
      p_mode,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure init_line_util_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  VARCHAR2
  )

  as
    ddx_line_util_rec ozf_claim_accrual_pvt.line_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.init_line_util_rec(ddx_line_util_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_line_util_rec.claim_line_util_id;
    p0_a1 := ddx_line_util_rec.object_version_number;
    p0_a2 := ddx_line_util_rec.last_update_date;
    p0_a3 := ddx_line_util_rec.last_updated_by;
    p0_a4 := ddx_line_util_rec.creation_date;
    p0_a5 := ddx_line_util_rec.created_by;
    p0_a6 := ddx_line_util_rec.last_update_login;
    p0_a7 := ddx_line_util_rec.claim_line_id;
    p0_a8 := ddx_line_util_rec.utilization_id;
    p0_a9 := ddx_line_util_rec.amount;
    p0_a10 := ddx_line_util_rec.currency_code;
    p0_a11 := ddx_line_util_rec.exchange_rate_type;
    p0_a12 := ddx_line_util_rec.exchange_rate_date;
    p0_a13 := ddx_line_util_rec.exchange_rate;
    p0_a14 := ddx_line_util_rec.acctd_amount;
    p0_a15 := ddx_line_util_rec.util_curr_amount;
    p0_a16 := ddx_line_util_rec.plan_curr_amount;
    p0_a17 := ddx_line_util_rec.scan_unit;
    p0_a18 := ddx_line_util_rec.activity_product_id;
    p0_a19 := ddx_line_util_rec.uom_code;
    p0_a20 := ddx_line_util_rec.quantity;
    p0_a21 := ddx_line_util_rec.org_id;
    p0_a22 := ddx_line_util_rec.univ_curr_amount;
    p0_a23 := ddx_line_util_rec.fxgl_acctd_amount;
    p0_a24 := ddx_line_util_rec.utilized_acctd_amount;
    p0_a25 := ddx_line_util_rec.update_from_tbl_flag;
  end;

  procedure complete_line_util_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  VARCHAR2
  )

  as
    ddp_line_util_rec ozf_claim_accrual_pvt.line_util_rec_type;
    ddx_complete_rec ozf_claim_accrual_pvt.line_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_line_util_rec.claim_line_util_id := p0_a0;
    ddp_line_util_rec.object_version_number := p0_a1;
    ddp_line_util_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_line_util_rec.last_updated_by := p0_a3;
    ddp_line_util_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_line_util_rec.created_by := p0_a5;
    ddp_line_util_rec.last_update_login := p0_a6;
    ddp_line_util_rec.claim_line_id := p0_a7;
    ddp_line_util_rec.utilization_id := p0_a8;
    ddp_line_util_rec.amount := p0_a9;
    ddp_line_util_rec.currency_code := p0_a10;
    ddp_line_util_rec.exchange_rate_type := p0_a11;
    ddp_line_util_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_line_util_rec.exchange_rate := p0_a13;
    ddp_line_util_rec.acctd_amount := p0_a14;
    ddp_line_util_rec.util_curr_amount := p0_a15;
    ddp_line_util_rec.plan_curr_amount := p0_a16;
    ddp_line_util_rec.scan_unit := p0_a17;
    ddp_line_util_rec.activity_product_id := p0_a18;
    ddp_line_util_rec.uom_code := p0_a19;
    ddp_line_util_rec.quantity := p0_a20;
    ddp_line_util_rec.org_id := p0_a21;
    ddp_line_util_rec.univ_curr_amount := p0_a22;
    ddp_line_util_rec.fxgl_acctd_amount := p0_a23;
    ddp_line_util_rec.utilized_acctd_amount := p0_a24;
    ddp_line_util_rec.update_from_tbl_flag := p0_a25;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.complete_line_util_rec(ddp_line_util_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.claim_line_util_id;
    p1_a1 := ddx_complete_rec.object_version_number;
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := ddx_complete_rec.last_updated_by;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.last_update_login;
    p1_a7 := ddx_complete_rec.claim_line_id;
    p1_a8 := ddx_complete_rec.utilization_id;
    p1_a9 := ddx_complete_rec.amount;
    p1_a10 := ddx_complete_rec.currency_code;
    p1_a11 := ddx_complete_rec.exchange_rate_type;
    p1_a12 := ddx_complete_rec.exchange_rate_date;
    p1_a13 := ddx_complete_rec.exchange_rate;
    p1_a14 := ddx_complete_rec.acctd_amount;
    p1_a15 := ddx_complete_rec.util_curr_amount;
    p1_a16 := ddx_complete_rec.plan_curr_amount;
    p1_a17 := ddx_complete_rec.scan_unit;
    p1_a18 := ddx_complete_rec.activity_product_id;
    p1_a19 := ddx_complete_rec.uom_code;
    p1_a20 := ddx_complete_rec.quantity;
    p1_a21 := ddx_complete_rec.org_id;
    p1_a22 := ddx_complete_rec.univ_curr_amount;
    p1_a23 := ddx_complete_rec.fxgl_acctd_amount;
    p1_a24 := ddx_complete_rec.utilized_acctd_amount;
    p1_a25 := ddx_complete_rec.update_from_tbl_flag;
  end;

  procedure update_group_line_util(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_summary_view  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  NUMBER
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  DATE
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p_mode  VARCHAR2
  )

  as
    ddp_funds_util_flt ozf_claim_accrual_pvt.funds_util_flt_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_funds_util_flt.claim_line_id := p8_a0;
    ddp_funds_util_flt.fund_id := p8_a1;
    ddp_funds_util_flt.activity_type := p8_a2;
    ddp_funds_util_flt.activity_id := p8_a3;
    ddp_funds_util_flt.activity_product_id := p8_a4;
    ddp_funds_util_flt.schedule_id := p8_a5;
    ddp_funds_util_flt.offer_type := p8_a6;
    ddp_funds_util_flt.document_class := p8_a7;
    ddp_funds_util_flt.document_id := p8_a8;
    ddp_funds_util_flt.product_level_type := p8_a9;
    ddp_funds_util_flt.product_id := p8_a10;
    ddp_funds_util_flt.reference_type := p8_a11;
    ddp_funds_util_flt.reference_id := p8_a12;
    ddp_funds_util_flt.utilization_type := p8_a13;
    ddp_funds_util_flt.total_amount := p8_a14;
    ddp_funds_util_flt.old_total_amount := p8_a15;
    if p8_a16 is null
      then ddp_funds_util_flt.pay_over_all_flag := null;
    elsif p8_a16 = 0
      then ddp_funds_util_flt.pay_over_all_flag := false;
    else ddp_funds_util_flt.pay_over_all_flag := true;
    end if;
    ddp_funds_util_flt.total_units := p8_a17;
    ddp_funds_util_flt.old_total_units := p8_a18;
    ddp_funds_util_flt.quantity := p8_a19;
    ddp_funds_util_flt.uom_code := p8_a20;
    ddp_funds_util_flt.cust_account_id := p8_a21;
    ddp_funds_util_flt.relationship_type := p8_a22;
    ddp_funds_util_flt.related_cust_account_id := p8_a23;
    ddp_funds_util_flt.buy_group_cust_account_id := p8_a24;
    ddp_funds_util_flt.buy_group_party_id := p8_a25;
    ddp_funds_util_flt.select_cust_children_flag := p8_a26;
    ddp_funds_util_flt.pay_to_customer := p8_a27;
    ddp_funds_util_flt.prorate_earnings_flag := p8_a28;
    ddp_funds_util_flt.adjustment_type_id := p8_a29;
    ddp_funds_util_flt.end_date := rosetta_g_miss_date_in_map(p8_a30);
    ddp_funds_util_flt.run_mode := p8_a31;
    ddp_funds_util_flt.check_sales_rep_flag := p8_a32;
    ddp_funds_util_flt.group_by_offer := p8_a33;
    ddp_funds_util_flt.offer_payment_method := p8_a34;
    ddp_funds_util_flt.utiz_currency_code := p8_a35;
    ddp_funds_util_flt.bill_to_site_use_id := p8_a36;
    ddp_funds_util_flt.utilization_id := p8_a37;
    ddp_funds_util_flt.autopay_check := p8_a38;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.update_group_line_util(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_summary_view,
      ddp_funds_util_flt,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure delete_group_line_util(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p_mode  VARCHAR2
  )

  as
    ddp_funds_util_flt ozf_claim_accrual_pvt.funds_util_flt_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_funds_util_flt.claim_line_id := p7_a0;
    ddp_funds_util_flt.fund_id := p7_a1;
    ddp_funds_util_flt.activity_type := p7_a2;
    ddp_funds_util_flt.activity_id := p7_a3;
    ddp_funds_util_flt.activity_product_id := p7_a4;
    ddp_funds_util_flt.schedule_id := p7_a5;
    ddp_funds_util_flt.offer_type := p7_a6;
    ddp_funds_util_flt.document_class := p7_a7;
    ddp_funds_util_flt.document_id := p7_a8;
    ddp_funds_util_flt.product_level_type := p7_a9;
    ddp_funds_util_flt.product_id := p7_a10;
    ddp_funds_util_flt.reference_type := p7_a11;
    ddp_funds_util_flt.reference_id := p7_a12;
    ddp_funds_util_flt.utilization_type := p7_a13;
    ddp_funds_util_flt.total_amount := p7_a14;
    ddp_funds_util_flt.old_total_amount := p7_a15;
    if p7_a16 is null
      then ddp_funds_util_flt.pay_over_all_flag := null;
    elsif p7_a16 = 0
      then ddp_funds_util_flt.pay_over_all_flag := false;
    else ddp_funds_util_flt.pay_over_all_flag := true;
    end if;
    ddp_funds_util_flt.total_units := p7_a17;
    ddp_funds_util_flt.old_total_units := p7_a18;
    ddp_funds_util_flt.quantity := p7_a19;
    ddp_funds_util_flt.uom_code := p7_a20;
    ddp_funds_util_flt.cust_account_id := p7_a21;
    ddp_funds_util_flt.relationship_type := p7_a22;
    ddp_funds_util_flt.related_cust_account_id := p7_a23;
    ddp_funds_util_flt.buy_group_cust_account_id := p7_a24;
    ddp_funds_util_flt.buy_group_party_id := p7_a25;
    ddp_funds_util_flt.select_cust_children_flag := p7_a26;
    ddp_funds_util_flt.pay_to_customer := p7_a27;
    ddp_funds_util_flt.prorate_earnings_flag := p7_a28;
    ddp_funds_util_flt.adjustment_type_id := p7_a29;
    ddp_funds_util_flt.end_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_funds_util_flt.run_mode := p7_a31;
    ddp_funds_util_flt.check_sales_rep_flag := p7_a32;
    ddp_funds_util_flt.group_by_offer := p7_a33;
    ddp_funds_util_flt.offer_payment_method := p7_a34;
    ddp_funds_util_flt.utiz_currency_code := p7_a35;
    ddp_funds_util_flt.bill_to_site_use_id := p7_a36;
    ddp_funds_util_flt.utilization_id := p7_a37;
    ddp_funds_util_flt.autopay_check := p7_a38;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.delete_group_line_util(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_funds_util_flt,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure asso_accruals_to_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_claim_id  NUMBER
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  NUMBER
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  DATE
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
  )

  as
    ddp_funds_util_flt ozf_claim_accrual_pvt.funds_util_flt_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_funds_util_flt.claim_line_id := p8_a0;
    ddp_funds_util_flt.fund_id := p8_a1;
    ddp_funds_util_flt.activity_type := p8_a2;
    ddp_funds_util_flt.activity_id := p8_a3;
    ddp_funds_util_flt.activity_product_id := p8_a4;
    ddp_funds_util_flt.schedule_id := p8_a5;
    ddp_funds_util_flt.offer_type := p8_a6;
    ddp_funds_util_flt.document_class := p8_a7;
    ddp_funds_util_flt.document_id := p8_a8;
    ddp_funds_util_flt.product_level_type := p8_a9;
    ddp_funds_util_flt.product_id := p8_a10;
    ddp_funds_util_flt.reference_type := p8_a11;
    ddp_funds_util_flt.reference_id := p8_a12;
    ddp_funds_util_flt.utilization_type := p8_a13;
    ddp_funds_util_flt.total_amount := p8_a14;
    ddp_funds_util_flt.old_total_amount := p8_a15;
    if p8_a16 is null
      then ddp_funds_util_flt.pay_over_all_flag := null;
    elsif p8_a16 = 0
      then ddp_funds_util_flt.pay_over_all_flag := false;
    else ddp_funds_util_flt.pay_over_all_flag := true;
    end if;
    ddp_funds_util_flt.total_units := p8_a17;
    ddp_funds_util_flt.old_total_units := p8_a18;
    ddp_funds_util_flt.quantity := p8_a19;
    ddp_funds_util_flt.uom_code := p8_a20;
    ddp_funds_util_flt.cust_account_id := p8_a21;
    ddp_funds_util_flt.relationship_type := p8_a22;
    ddp_funds_util_flt.related_cust_account_id := p8_a23;
    ddp_funds_util_flt.buy_group_cust_account_id := p8_a24;
    ddp_funds_util_flt.buy_group_party_id := p8_a25;
    ddp_funds_util_flt.select_cust_children_flag := p8_a26;
    ddp_funds_util_flt.pay_to_customer := p8_a27;
    ddp_funds_util_flt.prorate_earnings_flag := p8_a28;
    ddp_funds_util_flt.adjustment_type_id := p8_a29;
    ddp_funds_util_flt.end_date := rosetta_g_miss_date_in_map(p8_a30);
    ddp_funds_util_flt.run_mode := p8_a31;
    ddp_funds_util_flt.check_sales_rep_flag := p8_a32;
    ddp_funds_util_flt.group_by_offer := p8_a33;
    ddp_funds_util_flt.offer_payment_method := p8_a34;
    ddp_funds_util_flt.utiz_currency_code := p8_a35;
    ddp_funds_util_flt.bill_to_site_use_id := p8_a36;
    ddp_funds_util_flt.utilization_id := p8_a37;
    ddp_funds_util_flt.autopay_check := p8_a38;

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.asso_accruals_to_claim(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_claim_id,
      ddp_funds_util_flt);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure check_offer_performance(p_cust_account_id  NUMBER
    , p_offer_id  NUMBER
    , p_resale_flag  VARCHAR2
    , p_check_all_flag  VARCHAR2
    , x_performance_flag out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_DATE_TABLE
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_offer_perf_tbl ozf_claim_accrual_pvt.offer_performance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.check_offer_performance(p_cust_account_id,
      p_offer_id,
      p_resale_flag,
      p_check_all_flag,
      x_performance_flag,
      ddx_offer_perf_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ozf_claim_accrual_pvt_w.rosetta_table_copy_out_p5(ddx_offer_perf_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );
  end;

  procedure check_offer_performance_tbl(p_claim_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a4 out nocopy JTF_DATE_TABLE
    , p1_a5 out nocopy JTF_DATE_TABLE
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 out nocopy JTF_NUMBER_TABLE
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_offer_perf_tbl ozf_claim_accrual_pvt.offer_performance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.check_offer_performance_tbl(p_claim_id,
      ddx_offer_perf_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    ozf_claim_accrual_pvt_w.rosetta_table_copy_out_p5(ddx_offer_perf_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      );
  end;

  procedure check_offer_earning_tbl(p_claim_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_offer_earn_tbl ozf_claim_accrual_pvt.offer_earning_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_accrual_pvt.check_offer_earning_tbl(p_claim_id,
      ddx_offer_earn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    ozf_claim_accrual_pvt_w.rosetta_table_copy_out_p7(ddx_offer_earn_tbl, p1_a0
      , p1_a1
      );
  end;

  function calculate_fxgl_amount(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p1_a0  VARCHAR2
    , p1_a1  VARCHAR2
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
  ) return number

  as
    ddp_line_util_rec ozf_claim_accrual_pvt.line_util_rec_type;
    ddp_currency_rec ozf_claim_accrual_pvt.currency_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_line_util_rec.claim_line_util_id := p0_a0;
    ddp_line_util_rec.object_version_number := p0_a1;
    ddp_line_util_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_line_util_rec.last_updated_by := p0_a3;
    ddp_line_util_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_line_util_rec.created_by := p0_a5;
    ddp_line_util_rec.last_update_login := p0_a6;
    ddp_line_util_rec.claim_line_id := p0_a7;
    ddp_line_util_rec.utilization_id := p0_a8;
    ddp_line_util_rec.amount := p0_a9;
    ddp_line_util_rec.currency_code := p0_a10;
    ddp_line_util_rec.exchange_rate_type := p0_a11;
    ddp_line_util_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_line_util_rec.exchange_rate := p0_a13;
    ddp_line_util_rec.acctd_amount := p0_a14;
    ddp_line_util_rec.util_curr_amount := p0_a15;
    ddp_line_util_rec.plan_curr_amount := p0_a16;
    ddp_line_util_rec.scan_unit := p0_a17;
    ddp_line_util_rec.activity_product_id := p0_a18;
    ddp_line_util_rec.uom_code := p0_a19;
    ddp_line_util_rec.quantity := p0_a20;
    ddp_line_util_rec.org_id := p0_a21;
    ddp_line_util_rec.univ_curr_amount := p0_a22;
    ddp_line_util_rec.fxgl_acctd_amount := p0_a23;
    ddp_line_util_rec.utilized_acctd_amount := p0_a24;
    ddp_line_util_rec.update_from_tbl_flag := p0_a25;

    ddp_currency_rec.functional_currency_code := p1_a0;
    ddp_currency_rec.offer_currency_code := p1_a1;
    ddp_currency_rec.universal_currency_code := p1_a2;
    ddp_currency_rec.claim_currency_code := p1_a3;
    ddp_currency_rec.transaction_currency_code := p1_a4;
    ddp_currency_rec.association_currency_code := p1_a5;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ozf_claim_accrual_pvt.calculate_fxgl_amount(ddp_line_util_rec,
      ddp_currency_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

end ozf_claim_accrual_pvt_w;

/
