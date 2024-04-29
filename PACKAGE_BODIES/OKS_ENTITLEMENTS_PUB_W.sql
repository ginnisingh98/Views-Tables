--------------------------------------------------------
--  DDL for Package Body OKS_ENTITLEMENTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ENTITLEMENTS_PUB_W" as
  /* $Header: OKSWENTB.pls 120.3 2005/12/22 10:52 jvarghes noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p4(t out nocopy oks_entitlements_pub.apl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).charges_line_number := a0(indx);
          t(ddindx).contract_line_id := a1(indx);
          t(ddindx).coverage_id := a2(indx);
          t(ddindx).txn_group_id := a3(indx);
          t(ddindx).billing_type_id := a4(indx);
          t(ddindx).charge_amount := a5(indx);
          t(ddindx).discounted_amount := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t oks_entitlements_pub.apl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).charges_line_number;
          a1(indx) := t(ddindx).contract_line_id;
          a2(indx) := t(ddindx).coverage_id;
          a3(indx) := t(ddindx).txn_group_id;
          a4(indx) := t(ddindx).billing_type_id;
          a5(indx) := t(ddindx).charge_amount;
          a6(indx) := t(ddindx).discounted_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p16(t out nocopy oks_entitlements_pub.hdr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_600
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_CLOB_TABLE
    , a34 JTF_CLOB_TABLE
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_500
    , a37 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).org_id := a0(indx);
          t(ddindx).contract_id := a1(indx);
          t(ddindx).contract_number := a2(indx);
          t(ddindx).contract_number_modifier := a3(indx);
          t(ddindx).short_description := a4(indx);
          t(ddindx).contract_amount := a5(indx);
          t(ddindx).contract_status_code := a6(indx);
          t(ddindx).contract_type := a7(indx);
          t(ddindx).party_id := a8(indx);
          t(ddindx).template_yn := a9(indx);
          t(ddindx).template_used := a10(indx);
          t(ddindx).duration := a11(indx);
          t(ddindx).period_code := a12(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).bill_to_site_use_id := a15(indx);
          t(ddindx).ship_to_site_use_id := a16(indx);
          t(ddindx).agreement_id := a17(indx);
          t(ddindx).price_list_id := a18(indx);
          t(ddindx).modifier := a19(indx);
          t(ddindx).currency_code := a20(indx);
          t(ddindx).accounting_rule_id := a21(indx);
          t(ddindx).invoicing_rule_id := a22(indx);
          t(ddindx).terms_id := a23(indx);
          t(ddindx).po_number := a24(indx);
          t(ddindx).billing_profile_id := a25(indx);
          t(ddindx).billing_frequency := a26(indx);
          t(ddindx).billing_method := a27(indx);
          t(ddindx).regular_offset_days := a28(indx);
          t(ddindx).first_bill_to := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).first_bill_on := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).auto_renew_before_days := a31(indx);
          t(ddindx).qa_check_list_id := a32(indx);
          t(ddindx).renewal_note := a33(indx);
          t(ddindx).termination_note := a34(indx);
          t(ddindx).tax_exemption := a35(indx);
          t(ddindx).tax_status := a36(indx);
          t(ddindx).conversion_type := a37(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t oks_entitlements_pub.hdr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_600
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_CLOB_TABLE
    , a34 out nocopy JTF_CLOB_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_500
    , a37 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_600();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_CLOB_TABLE();
    a34 := JTF_CLOB_TABLE();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_500();
    a37 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_600();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_CLOB_TABLE();
      a34 := JTF_CLOB_TABLE();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_500();
      a37 := JTF_VARCHAR2_TABLE_500();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).org_id;
          a1(indx) := t(ddindx).contract_id;
          a2(indx) := t(ddindx).contract_number;
          a3(indx) := t(ddindx).contract_number_modifier;
          a4(indx) := t(ddindx).short_description;
          a5(indx) := t(ddindx).contract_amount;
          a6(indx) := t(ddindx).contract_status_code;
          a7(indx) := t(ddindx).contract_type;
          a8(indx) := t(ddindx).party_id;
          a9(indx) := t(ddindx).template_yn;
          a10(indx) := t(ddindx).template_used;
          a11(indx) := t(ddindx).duration;
          a12(indx) := t(ddindx).period_code;
          a13(indx) := t(ddindx).start_date_active;
          a14(indx) := t(ddindx).end_date_active;
          a15(indx) := t(ddindx).bill_to_site_use_id;
          a16(indx) := t(ddindx).ship_to_site_use_id;
          a17(indx) := t(ddindx).agreement_id;
          a18(indx) := t(ddindx).price_list_id;
          a19(indx) := t(ddindx).modifier;
          a20(indx) := t(ddindx).currency_code;
          a21(indx) := t(ddindx).accounting_rule_id;
          a22(indx) := t(ddindx).invoicing_rule_id;
          a23(indx) := t(ddindx).terms_id;
          a24(indx) := t(ddindx).po_number;
          a25(indx) := t(ddindx).billing_profile_id;
          a26(indx) := t(ddindx).billing_frequency;
          a27(indx) := t(ddindx).billing_method;
          a28(indx) := t(ddindx).regular_offset_days;
          a29(indx) := t(ddindx).first_bill_to;
          a30(indx) := t(ddindx).first_bill_on;
          a31(indx) := t(ddindx).auto_renew_before_days;
          a32(indx) := t(ddindx).qa_check_list_id;
          a33(indx) := t(ddindx).renewal_note;
          a34(indx) := t(ddindx).termination_note;
          a35(indx) := t(ddindx).tax_exemption;
          a36(indx) := t(ddindx).tax_status;
          a37(indx) := t(ddindx).conversion_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p16;

  procedure rosetta_table_copy_in_p19(t out nocopy oks_entitlements_pub.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_line_id := a0(indx);
          t(ddindx).contract_parent_line_id := a1(indx);
          t(ddindx).contract_id := a2(indx);
          t(ddindx).line_status_code := a3(indx);
          t(ddindx).duration := a4(indx);
          t(ddindx).period_code := a5(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).line_name := a8(indx);
          t(ddindx).bill_to_site_use_id := a9(indx);
          t(ddindx).ship_to_site_use_id := a10(indx);
          t(ddindx).agreement_id := a11(indx);
          t(ddindx).modifier := a12(indx);
          t(ddindx).price_list_id := a13(indx);
          t(ddindx).price_negotiated := a14(indx);
          t(ddindx).billing_profile_id := a15(indx);
          t(ddindx).billing_frequency := a16(indx);
          t(ddindx).billing_method := a17(indx);
          t(ddindx).regular_offset_days := a18(indx);
          t(ddindx).first_bill_to := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).first_bill_on := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).termination_date := rosetta_g_miss_date_in_map(a21(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t oks_entitlements_pub.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).contract_line_id;
          a1(indx) := t(ddindx).contract_parent_line_id;
          a2(indx) := t(ddindx).contract_id;
          a3(indx) := t(ddindx).line_status_code;
          a4(indx) := t(ddindx).duration;
          a5(indx) := t(ddindx).period_code;
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).end_date_active;
          a8(indx) := t(ddindx).line_name;
          a9(indx) := t(ddindx).bill_to_site_use_id;
          a10(indx) := t(ddindx).ship_to_site_use_id;
          a11(indx) := t(ddindx).agreement_id;
          a12(indx) := t(ddindx).modifier;
          a13(indx) := t(ddindx).price_list_id;
          a14(indx) := t(ddindx).price_negotiated;
          a15(indx) := t(ddindx).billing_profile_id;
          a16(indx) := t(ddindx).billing_frequency;
          a17(indx) := t(ddindx).billing_method;
          a18(indx) := t(ddindx).regular_offset_days;
          a19(indx) := t(ddindx).first_bill_to;
          a20(indx) := t(ddindx).first_bill_on;
          a21(indx) := t(ddindx).termination_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p22(t out nocopy oks_entitlements_pub.clvl_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).row_id := a0(indx);
          t(ddindx).line_id := a1(indx);
          t(ddindx).header_id := a2(indx);
          t(ddindx).parent_line_id := a3(indx);
          t(ddindx).line_level := a4(indx);
          t(ddindx).cp_id := a5(indx);
          t(ddindx).cp_name := a6(indx);
          t(ddindx).inv_item_id := a7(indx);
          t(ddindx).item_name := a8(indx);
          t(ddindx).site_id := a9(indx);
          t(ddindx).site_name := a10(indx);
          t(ddindx).system_id := a11(indx);
          t(ddindx).system_name := a12(indx);
          t(ddindx).customer_id := a13(indx);
          t(ddindx).customer_name := a14(indx);
          t(ddindx).party_id := a15(indx);
          t(ddindx).party_name := a16(indx);
          t(ddindx).quantity := a17(indx);
          t(ddindx).list_price := a18(indx);
          t(ddindx).price_negotiated := a19(indx);
          t(ddindx).line_name := a20(indx);
          t(ddindx).default_amcv_flag := a21(indx);
          t(ddindx).default_qty := a22(indx);
          t(ddindx).default_uom := a23(indx);
          t(ddindx).default_duration := a24(indx);
          t(ddindx).default_period := a25(indx);
          t(ddindx).minimum_qty := a26(indx);
          t(ddindx).minimum_uom := a27(indx);
          t(ddindx).minimum_duration := a28(indx);
          t(ddindx).minimum_period := a29(indx);
          t(ddindx).fixed_qty := a30(indx);
          t(ddindx).fixed_uom := a31(indx);
          t(ddindx).fixed_duration := a32(indx);
          t(ddindx).fixed_period := a33(indx);
          t(ddindx).level_flag := a34(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t oks_entitlements_pub.clvl_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).row_id;
          a1(indx) := t(ddindx).line_id;
          a2(indx) := t(ddindx).header_id;
          a3(indx) := t(ddindx).parent_line_id;
          a4(indx) := t(ddindx).line_level;
          a5(indx) := t(ddindx).cp_id;
          a6(indx) := t(ddindx).cp_name;
          a7(indx) := t(ddindx).inv_item_id;
          a8(indx) := t(ddindx).item_name;
          a9(indx) := t(ddindx).site_id;
          a10(indx) := t(ddindx).site_name;
          a11(indx) := t(ddindx).system_id;
          a12(indx) := t(ddindx).system_name;
          a13(indx) := t(ddindx).customer_id;
          a14(indx) := t(ddindx).customer_name;
          a15(indx) := t(ddindx).party_id;
          a16(indx) := t(ddindx).party_name;
          a17(indx) := t(ddindx).quantity;
          a18(indx) := t(ddindx).list_price;
          a19(indx) := t(ddindx).price_negotiated;
          a20(indx) := t(ddindx).line_name;
          a21(indx) := t(ddindx).default_amcv_flag;
          a22(indx) := t(ddindx).default_qty;
          a23(indx) := t(ddindx).default_uom;
          a24(indx) := t(ddindx).default_duration;
          a25(indx) := t(ddindx).default_period;
          a26(indx) := t(ddindx).minimum_qty;
          a27(indx) := t(ddindx).minimum_uom;
          a28(indx) := t(ddindx).minimum_duration;
          a29(indx) := t(ddindx).minimum_period;
          a30(indx) := t(ddindx).fixed_qty;
          a31(indx) := t(ddindx).fixed_uom;
          a32(indx) := t(ddindx).fixed_duration;
          a33(indx) := t(ddindx).fixed_period;
          a34(indx) := t(ddindx).level_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p26(t out nocopy oks_entitlements_pub.ent_cont_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).contract_number := a1(indx);
          t(ddindx).contract_number_modifier := a2(indx);
          t(ddindx).service_line_id := a3(indx);
          t(ddindx).service_name := a4(indx);
          t(ddindx).service_description := a5(indx);
          t(ddindx).coverage_term_line_id := a6(indx);
          t(ddindx).coverage_term_name := a7(indx);
          t(ddindx).coverage_term_description := a8(indx);
          t(ddindx).coverage_type_code := a9(indx);
          t(ddindx).coverage_type_meaning := a10(indx);
          t(ddindx).coverage_type_imp_level := a11(indx);
          t(ddindx).coverage_level_line_id := a12(indx);
          t(ddindx).coverage_level := a13(indx);
          t(ddindx).coverage_level_code := a14(indx);
          t(ddindx).coverage_level_start_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).coverage_level_end_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).coverage_level_id := a17(indx);
          t(ddindx).warranty_flag := a18(indx);
          t(ddindx).eligible_for_entitlement := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t oks_entitlements_pub.ent_cont_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).contract_number_modifier;
          a3(indx) := t(ddindx).service_line_id;
          a4(indx) := t(ddindx).service_name;
          a5(indx) := t(ddindx).service_description;
          a6(indx) := t(ddindx).coverage_term_line_id;
          a7(indx) := t(ddindx).coverage_term_name;
          a8(indx) := t(ddindx).coverage_term_description;
          a9(indx) := t(ddindx).coverage_type_code;
          a10(indx) := t(ddindx).coverage_type_meaning;
          a11(indx) := t(ddindx).coverage_type_imp_level;
          a12(indx) := t(ddindx).coverage_level_line_id;
          a13(indx) := t(ddindx).coverage_level;
          a14(indx) := t(ddindx).coverage_level_code;
          a15(indx) := t(ddindx).coverage_level_start_date;
          a16(indx) := t(ddindx).coverage_level_end_date;
          a17(indx) := t(ddindx).coverage_level_id;
          a18(indx) := t(ddindx).warranty_flag;
          a19(indx) := t(ddindx).eligible_for_entitlement;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p30(t out nocopy oks_entitlements_pub.get_contop_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).contract_number := a1(indx);
          t(ddindx).contract_number_modifier := a2(indx);
          t(ddindx).sts_code := a3(indx);
          t(ddindx).service_line_id := a4(indx);
          t(ddindx).service_name := a5(indx);
          t(ddindx).service_description := a6(indx);
          t(ddindx).coverage_term_line_id := a7(indx);
          t(ddindx).coverage_term_name := a8(indx);
          t(ddindx).coverage_term_description := a9(indx);
          t(ddindx).coverage_type_code := a10(indx);
          t(ddindx).coverage_type_meaning := a11(indx);
          t(ddindx).coverage_type_imp_level := a12(indx);
          t(ddindx).service_start_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).service_end_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).warranty_flag := a15(indx);
          t(ddindx).eligible_for_entitlement := a16(indx);
          t(ddindx).exp_reaction_time := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).exp_resolution_time := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).status_code := a19(indx);
          t(ddindx).status_text := a20(indx);
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).pm_program_id := a22(indx);
          t(ddindx).pm_schedule_exists := a23(indx);
          t(ddindx).hd_currency_code := a24(indx);
          t(ddindx).service_po_number := a25(indx);
          t(ddindx).service_po_required_flag := a26(indx);
          t(ddindx).covlvl_line_id := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t oks_entitlements_pub.get_contop_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).contract_number_modifier;
          a3(indx) := t(ddindx).sts_code;
          a4(indx) := t(ddindx).service_line_id;
          a5(indx) := t(ddindx).service_name;
          a6(indx) := t(ddindx).service_description;
          a7(indx) := t(ddindx).coverage_term_line_id;
          a8(indx) := t(ddindx).coverage_term_name;
          a9(indx) := t(ddindx).coverage_term_description;
          a10(indx) := t(ddindx).coverage_type_code;
          a11(indx) := t(ddindx).coverage_type_meaning;
          a12(indx) := t(ddindx).coverage_type_imp_level;
          a13(indx) := t(ddindx).service_start_date;
          a14(indx) := t(ddindx).service_end_date;
          a15(indx) := t(ddindx).warranty_flag;
          a16(indx) := t(ddindx).eligible_for_entitlement;
          a17(indx) := t(ddindx).exp_reaction_time;
          a18(indx) := t(ddindx).exp_resolution_time;
          a19(indx) := t(ddindx).status_code;
          a20(indx) := t(ddindx).status_text;
          a21(indx) := t(ddindx).date_terminated;
          a22(indx) := t(ddindx).pm_program_id;
          a23(indx) := t(ddindx).pm_schedule_exists;
          a24(indx) := t(ddindx).hd_currency_code;
          a25(indx) := t(ddindx).service_po_number;
          a26(indx) := t(ddindx).service_po_required_flag;
          a27(indx) := t(ddindx).covlvl_line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure rosetta_table_copy_in_p34(t out nocopy oks_entitlements_pub.output_tbl_ib, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_2000
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).contract_number := a1(indx);
          t(ddindx).contract_number_modifier := a2(indx);
          t(ddindx).sts_code := a3(indx);
          t(ddindx).service_line_id := a4(indx);
          t(ddindx).service_name := a5(indx);
          t(ddindx).service_description := a6(indx);
          t(ddindx).coverage_term_line_id := a7(indx);
          t(ddindx).coverage_term_name := a8(indx);
          t(ddindx).coverage_term_description := a9(indx);
          t(ddindx).coverage_type_code := a10(indx);
          t(ddindx).coverage_type_imp_level := a11(indx);
          t(ddindx).service_start_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).service_end_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).warranty_flag := a14(indx);
          t(ddindx).eligible_for_entitlement := a15(indx);
          t(ddindx).exp_reaction_time := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).exp_resolution_time := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).status_code := a18(indx);
          t(ddindx).status_text := a19(indx);
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).covlvl_line_id := a21(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p34;
  procedure rosetta_table_copy_out_p34(t oks_entitlements_pub.output_tbl_ib, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_2000();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_2000();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).contract_number_modifier;
          a3(indx) := t(ddindx).sts_code;
          a4(indx) := t(ddindx).service_line_id;
          a5(indx) := t(ddindx).service_name;
          a6(indx) := t(ddindx).service_description;
          a7(indx) := t(ddindx).coverage_term_line_id;
          a8(indx) := t(ddindx).coverage_term_name;
          a9(indx) := t(ddindx).coverage_term_description;
          a10(indx) := t(ddindx).coverage_type_code;
          a11(indx) := t(ddindx).coverage_type_imp_level;
          a12(indx) := t(ddindx).service_start_date;
          a13(indx) := t(ddindx).service_end_date;
          a14(indx) := t(ddindx).warranty_flag;
          a15(indx) := t(ddindx).eligible_for_entitlement;
          a16(indx) := t(ddindx).exp_reaction_time;
          a17(indx) := t(ddindx).exp_resolution_time;
          a18(indx) := t(ddindx).status_code;
          a19(indx) := t(ddindx).status_text;
          a20(indx) := t(ddindx).date_terminated;
          a21(indx) := t(ddindx).covlvl_line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p34;

  procedure rosetta_table_copy_in_p38(t out nocopy oks_entitlements_pub.output_tbl_entfrm, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_600
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).contract_number := a1(indx);
          t(ddindx).contract_number_modifier := a2(indx);
          t(ddindx).contract_known_as := a3(indx);
          t(ddindx).contract_short_description := a4(indx);
          t(ddindx).contract_status_code := a5(indx);
          t(ddindx).contract_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).contract_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).contract_terminated_date := rosetta_g_miss_date_in_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p38;
  procedure rosetta_table_copy_out_p38(t oks_entitlements_pub.output_tbl_entfrm, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_600
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_600();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_600();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).contract_number_modifier;
          a3(indx) := t(ddindx).contract_known_as;
          a4(indx) := t(ddindx).contract_short_description;
          a5(indx) := t(ddindx).contract_status_code;
          a6(indx) := t(ddindx).contract_start_date;
          a7(indx) := t(ddindx).contract_end_date;
          a8(indx) := t(ddindx).contract_terminated_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p38;

  procedure rosetta_table_copy_in_p41(t out nocopy oks_entitlements_pub.covlevel_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).covlevel_code := a0(indx);
          t(ddindx).covlevel_id := a1(indx);
          t(ddindx).inv_org_id := a2(indx);
          t(ddindx).covered_yn := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t oks_entitlements_pub.covlevel_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).covlevel_code;
          a1(indx) := t(ddindx).covlevel_id;
          a2(indx) := t(ddindx).inv_org_id;
          a3(indx) := t(ddindx).covered_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p44(t out nocopy oks_entitlements_pub.covlvl_id_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).covlvl_id := a0(indx);
          t(ddindx).covlvl_code := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p44;
  procedure rosetta_table_copy_out_p44(t oks_entitlements_pub.covlvl_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).covlvl_id;
          a1(indx) := t(ddindx).covlvl_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p44;

  procedure rosetta_table_copy_in_p47(t out nocopy oks_entitlements_pub.output_tbl_contract, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_number := a0(indx);
          t(ddindx).contract_number_modifier := a1(indx);
          t(ddindx).contract_category := a2(indx);
          t(ddindx).contract_status_code := a3(indx);
          t(ddindx).known_as := a4(indx);
          t(ddindx).short_description := a5(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).contract_amount := a9(indx);
          t(ddindx).currency_code := a10(indx);
          t(ddindx).hd_sts_meaning := a11(indx);
          t(ddindx).hd_cat_meaning := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p47;
  procedure rosetta_table_copy_out_p47(t oks_entitlements_pub.output_tbl_contract, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contract_number;
          a1(indx) := t(ddindx).contract_number_modifier;
          a2(indx) := t(ddindx).contract_category;
          a3(indx) := t(ddindx).contract_status_code;
          a4(indx) := t(ddindx).known_as;
          a5(indx) := t(ddindx).short_description;
          a6(indx) := t(ddindx).start_date;
          a7(indx) := t(ddindx).end_date;
          a8(indx) := t(ddindx).date_terminated;
          a9(indx) := t(ddindx).contract_amount;
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := t(ddindx).hd_sts_meaning;
          a12(indx) := t(ddindx).hd_cat_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p47;

  procedure rosetta_table_copy_in_p60(t out nocopy oks_entitlements_pub.ent_contact_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).contract_line_id := a1(indx);
          t(ddindx).contact_id := a2(indx);
          t(ddindx).contact_name := a3(indx);
          t(ddindx).contact_role_id := a4(indx);
          t(ddindx).contact_role_code := a5(indx);
          t(ddindx).contact_role_name := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p60;
  procedure rosetta_table_copy_out_p60(t oks_entitlements_pub.ent_contact_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).contract_line_id;
          a2(indx) := t(ddindx).contact_id;
          a3(indx) := t(ddindx).contact_name;
          a4(indx) := t(ddindx).contact_role_id;
          a5(indx) := t(ddindx).contact_role_code;
          a6(indx) := t(ddindx).contact_role_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p60;

  procedure rosetta_table_copy_in_p63(t out nocopy oks_entitlements_pub.prfeng_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).business_process_id := a0(indx);
          t(ddindx).engineer_id := a1(indx);
          t(ddindx).resource_type := a2(indx);
          t(ddindx).primary_flag := a3(indx);
          t(ddindx).resource_class := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p63;
  procedure rosetta_table_copy_out_p63(t oks_entitlements_pub.prfeng_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).business_process_id;
          a1(indx) := t(ddindx).engineer_id;
          a2(indx) := t(ddindx).resource_type;
          a3(indx) := t(ddindx).primary_flag;
          a4(indx) := t(ddindx).resource_class;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p63;

  procedure rosetta_table_copy_in_p70(t out nocopy oks_entitlements_pub.output_tbl_bp, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cov_txn_grp_line_id := a0(indx);
          t(ddindx).bp_id := a1(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p70;
  procedure rosetta_table_copy_out_p70(t oks_entitlements_pub.output_tbl_bp, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cov_txn_grp_line_id;
          a1(indx) := t(ddindx).bp_id;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p70;

  procedure rosetta_table_copy_in_p73(t out nocopy oks_entitlements_pub.output_tbl_bt, a0 JTF_NUMBER_TABLE
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
          t(ddindx).txn_bt_line_id := a0(indx);
          t(ddindx).txn_bill_type_id := a1(indx);
          t(ddindx).covered_upto_amount := a2(indx);
          t(ddindx).percent_covered := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p73;
  procedure rosetta_table_copy_out_p73(t oks_entitlements_pub.output_tbl_bt, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).txn_bt_line_id;
          a1(indx) := t(ddindx).txn_bill_type_id;
          a2(indx) := t(ddindx).covered_upto_amount;
          a3(indx) := t(ddindx).percent_covered;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p73;

  procedure rosetta_table_copy_in_p75(t out nocopy oks_entitlements_pub.output_tbl_br, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).bt_line_id := a0(indx);
          t(ddindx).br_line_id := a1(indx);
          t(ddindx).br_schedule_id := a2(indx);
          t(ddindx).bill_rate := a3(indx);
          t(ddindx).flat_rate := a4(indx);
          t(ddindx).uom := a5(indx);
          t(ddindx).percent_over_list_price := a6(indx);
          t(ddindx).start_hour := a7(indx);
          t(ddindx).start_minute := a8(indx);
          t(ddindx).end_hour := a9(indx);
          t(ddindx).end_minute := a10(indx);
          t(ddindx).monday_flag := a11(indx);
          t(ddindx).tuesday_flag := a12(indx);
          t(ddindx).wednesday_flag := a13(indx);
          t(ddindx).thursday_flag := a14(indx);
          t(ddindx).friday_flag := a15(indx);
          t(ddindx).saturday_flag := a16(indx);
          t(ddindx).sunday_flag := a17(indx);
          t(ddindx).labor_item_org_id := a18(indx);
          t(ddindx).labor_item_id := a19(indx);
          t(ddindx).holiday_yn := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p75;
  procedure rosetta_table_copy_out_p75(t oks_entitlements_pub.output_tbl_br, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).bt_line_id;
          a1(indx) := t(ddindx).br_line_id;
          a2(indx) := t(ddindx).br_schedule_id;
          a3(indx) := t(ddindx).bill_rate;
          a4(indx) := t(ddindx).flat_rate;
          a5(indx) := t(ddindx).uom;
          a6(indx) := t(ddindx).percent_over_list_price;
          a7(indx) := t(ddindx).start_hour;
          a8(indx) := t(ddindx).start_minute;
          a9(indx) := t(ddindx).end_hour;
          a10(indx) := t(ddindx).end_minute;
          a11(indx) := t(ddindx).monday_flag;
          a12(indx) := t(ddindx).tuesday_flag;
          a13(indx) := t(ddindx).wednesday_flag;
          a14(indx) := t(ddindx).thursday_flag;
          a15(indx) := t(ddindx).friday_flag;
          a16(indx) := t(ddindx).saturday_flag;
          a17(indx) := t(ddindx).sunday_flag;
          a18(indx) := t(ddindx).labor_item_org_id;
          a19(indx) := t(ddindx).labor_item_id;
          a20(indx) := t(ddindx).holiday_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p75;

  procedure rosetta_table_copy_in_p79(t out nocopy oks_entitlements_pub.srchline_inpcontlinerec_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).service_item_id := a0(indx);
          t(ddindx).contract_line_status_code := a1(indx);
          t(ddindx).coverage_type_code := a2(indx);
          t(ddindx).start_date_from := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).start_date_to := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date_from := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date_to := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).line_bill_to_site_id := a7(indx);
          t(ddindx).line_ship_to_site_id := a8(indx);
          t(ddindx).line_renewal_type_code := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p79;
  procedure rosetta_table_copy_out_p79(t oks_entitlements_pub.srchline_inpcontlinerec_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).service_item_id;
          a1(indx) := t(ddindx).contract_line_status_code;
          a2(indx) := t(ddindx).coverage_type_code;
          a3(indx) := t(ddindx).start_date_from;
          a4(indx) := t(ddindx).start_date_to;
          a5(indx) := t(ddindx).end_date_from;
          a6(indx) := t(ddindx).end_date_to;
          a7(indx) := t(ddindx).line_bill_to_site_id;
          a8(indx) := t(ddindx).line_ship_to_site_id;
          a9(indx) := t(ddindx).line_renewal_type_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p79;

  procedure rosetta_table_copy_in_p81(t out nocopy oks_entitlements_pub.srchline_covlvl_id_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).covlvl_id1 := a0(indx);
          t(ddindx).covlvl_id2 := a1(indx);
          t(ddindx).covlvl_code := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p81;
  procedure rosetta_table_copy_out_p81(t oks_entitlements_pub.srchline_covlvl_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).covlvl_id1;
          a1(indx) := t(ddindx).covlvl_id2;
          a2(indx) := t(ddindx).covlvl_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p81;

  procedure rosetta_table_copy_in_p83(t out nocopy oks_entitlements_pub.output_tbl_contractline, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_number := a0(indx);
          t(ddindx).contract_number_modifier := a1(indx);
          t(ddindx).contract_line_number := a2(indx);
          t(ddindx).contract_line_type := a3(indx);
          t(ddindx).service_name := a4(indx);
          t(ddindx).contract_description := a5(indx);
          t(ddindx).line_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).line_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).contract_line_status_code := a8(indx);
          t(ddindx).coverage_name := a9(indx);
          t(ddindx).service_id := a10(indx);
          t(ddindx).service_lse_id := a11(indx);
          t(ddindx).covlevel_lse_id := a12(indx);
          t(ddindx).contract_id := a13(indx);
          t(ddindx).coverage_line_id := a14(indx);
          t(ddindx).scs_code := a15(indx);
          t(ddindx).operating_unit := a16(indx);
          t(ddindx).operating_unit_name := a17(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p83;
  procedure rosetta_table_copy_out_p83(t oks_entitlements_pub.output_tbl_contractline, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contract_number;
          a1(indx) := t(ddindx).contract_number_modifier;
          a2(indx) := t(ddindx).contract_line_number;
          a3(indx) := t(ddindx).contract_line_type;
          a4(indx) := t(ddindx).service_name;
          a5(indx) := t(ddindx).contract_description;
          a6(indx) := t(ddindx).line_start_date;
          a7(indx) := t(ddindx).line_end_date;
          a8(indx) := t(ddindx).contract_line_status_code;
          a9(indx) := t(ddindx).coverage_name;
          a10(indx) := t(ddindx).service_id;
          a11(indx) := t(ddindx).service_lse_id;
          a12(indx) := t(ddindx).covlevel_lse_id;
          a13(indx) := t(ddindx).contract_id;
          a14(indx) := t(ddindx).coverage_line_id;
          a15(indx) := t(ddindx).scs_code;
          a16(indx) := t(ddindx).operating_unit;
          a17(indx) := t(ddindx).operating_unit_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p83;

  procedure get_all_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  DATE
    , p2_a4  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_CLOB_TABLE
    , p6_a34 out nocopy JTF_CLOB_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_inp_rec oks_entitlements_pub.inp_rec_type;
    ddx_all_contracts oks_entitlements_pub.hdr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.contract_id := p2_a0;
    ddp_inp_rec.contract_status_code := p2_a1;
    ddp_inp_rec.contract_type_code := p2_a2;
    ddp_inp_rec.end_date_active := rosetta_g_miss_date_in_map(p2_a3);
    ddp_inp_rec.party_id := p2_a4;





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_all_contracts(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_all_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p16(ddx_all_contracts, p6_a0
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
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      );
  end;

  procedure get_contract_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_contract_line_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_all_lines oks_entitlements_pub.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_contract_details(p_api_version,
      p_init_msg_list,
      p_contract_line_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_all_lines);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p19(ddx_all_lines, p6_a0
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
  end;

  procedure get_coverage_levels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_contract_line_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_covered_levels oks_entitlements_pub.clvl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_coverage_levels(p_api_version,
      p_init_msg_list,
      p_contract_line_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_covered_levels);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p22(ddx_covered_levels, p6_a0
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
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      );
  end;

  procedure get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  DATE
    , p2_a10  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_inp_rec oks_entitlements_pub.inp_cont_rec;
    ddx_ent_contracts oks_entitlements_pub.ent_cont_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.contract_number := p2_a0;
    ddp_inp_rec.contract_number_modifier := p2_a1;
    ddp_inp_rec.coverage_level_line_id := p2_a2;
    ddp_inp_rec.party_id := p2_a3;
    ddp_inp_rec.site_id := p2_a4;
    ddp_inp_rec.cust_acct_id := p2_a5;
    ddp_inp_rec.system_id := p2_a6;
    ddp_inp_rec.item_id := p2_a7;
    ddp_inp_rec.product_id := p2_a8;
    ddp_inp_rec.request_date := rosetta_g_miss_date_in_map(p2_a9);
    ddp_inp_rec.validate_flag := p2_a10;





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_contracts(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ent_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p26(ddx_ent_contracts, p6_a0
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
      );
  end;

  procedure get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  DATE
    , p2_a10  DATE
    , p2_a11  NUMBER
    , p2_a12  NUMBER
    , p2_a13  NUMBER
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_inp_rec oks_entitlements_pub.get_contin_rec;
    ddx_ent_contracts oks_entitlements_pub.get_contop_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.contract_number := p2_a0;
    ddp_inp_rec.contract_number_modifier := p2_a1;
    ddp_inp_rec.service_line_id := p2_a2;
    ddp_inp_rec.party_id := p2_a3;
    ddp_inp_rec.site_id := p2_a4;
    ddp_inp_rec.cust_acct_id := p2_a5;
    ddp_inp_rec.system_id := p2_a6;
    ddp_inp_rec.item_id := p2_a7;
    ddp_inp_rec.product_id := p2_a8;
    ddp_inp_rec.request_date := rosetta_g_miss_date_in_map(p2_a9);
    ddp_inp_rec.incident_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_inp_rec.business_process_id := p2_a11;
    ddp_inp_rec.severity_id := p2_a12;
    ddp_inp_rec.time_zone_id := p2_a13;
    ddp_inp_rec.dates_in_input_tz := p2_a14;
    ddp_inp_rec.calc_resptime_flag := p2_a15;
    ddp_inp_rec.validate_flag := p2_a16;
    ddp_inp_rec.sort_key := p2_a17;





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_contracts(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ent_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p30(ddx_ent_contracts, p6_a0
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
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      );
  end;

  procedure get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  NUMBER
    , p2_a11  NUMBER
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_inp_rec oks_entitlements_pub.input_rec_ib;
    ddx_ent_contracts oks_entitlements_pub.output_tbl_ib;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.contract_number := p2_a0;
    ddp_inp_rec.contract_number_modifier := p2_a1;
    ddp_inp_rec.service_line_id := p2_a2;
    ddp_inp_rec.party_id := p2_a3;
    ddp_inp_rec.site_id := p2_a4;
    ddp_inp_rec.cust_acct_id := p2_a5;
    ddp_inp_rec.system_id := p2_a6;
    ddp_inp_rec.item_id := p2_a7;
    ddp_inp_rec.product_id := p2_a8;
    ddp_inp_rec.business_process_id := p2_a9;
    ddp_inp_rec.severity_id := p2_a10;
    ddp_inp_rec.time_zone_id := p2_a11;
    ddp_inp_rec.dates_in_input_tz := p2_a12;
    ddp_inp_rec.calc_resptime_flag := p2_a13;
    ddp_inp_rec.validate_flag := p2_a14;





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_contracts(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ent_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p34(ddx_ent_contracts, p6_a0
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
  end;

  procedure get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  DATE
    , p2_a11  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_inp_rec oks_entitlements_pub.input_rec_entfrm;
    ddx_ent_contracts oks_entitlements_pub.output_tbl_entfrm;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.contract_number := p2_a0;
    ddp_inp_rec.contract_number_modifier := p2_a1;
    ddp_inp_rec.contract_customer_id := p2_a2;
    ddp_inp_rec.contract_service_item_id := p2_a3;
    ddp_inp_rec.covlvl_party_id := p2_a4;
    ddp_inp_rec.covlvl_site_id := p2_a5;
    ddp_inp_rec.covlvl_cust_acct_id := p2_a6;
    ddp_inp_rec.covlvl_system_id := p2_a7;
    ddp_inp_rec.covlvl_item_id := p2_a8;
    ddp_inp_rec.covlvl_product_id := p2_a9;
    ddp_inp_rec.request_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_inp_rec.validate_effectivity := p2_a11;





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_contracts(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ent_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p38(ddx_ent_contracts, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure validate_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_contract_line_id  NUMBER
    , p_busiproc_id  NUMBER
    , p_request_date  date
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p_verify_combination  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , x_combination_valid out nocopy  VARCHAR2
  )

  as
    ddp_request_date date;
    ddp_covlevel_tbl_in oks_entitlements_pub.covlevel_tbl_type;
    ddx_covlevel_tbl_out oks_entitlements_pub.covlevel_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_request_date := rosetta_g_miss_date_in_map(p_request_date);

    oks_entitlements_pub_w.rosetta_table_copy_in_p41(ddp_covlevel_tbl_in, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );







    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.validate_contract_line(p_api_version,
      p_init_msg_list,
      p_contract_line_id,
      p_busiproc_id,
      ddp_request_date,
      ddp_covlevel_tbl_in,
      p_verify_combination,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_covlevel_tbl_out,
      x_combination_valid);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    oks_entitlements_pub_w.rosetta_table_copy_out_p41(ddx_covlevel_tbl_out, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      );

  end;

  procedure search_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  DATE
    , p2_a4  DATE
    , p2_a5  DATE
    , p2_a6  DATE
    , p2_a7  DATE
    , p2_a8  DATE
    , p2_a9  NUMBER
    , p2_a10  DATE
    , p2_a11  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a6 out nocopy JTF_DATE_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_contract_rec oks_entitlements_pub.inp_cont_rec_type;
    ddp_clvl_id_tbl oks_entitlements_pub.covlvl_id_tbl;
    ddx_contract_tbl oks_entitlements_pub.output_tbl_contract;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_contract_rec.contract_number := p2_a0;
    ddp_contract_rec.contract_number_modifier := p2_a1;
    ddp_contract_rec.contract_status_code := p2_a2;
    ddp_contract_rec.start_date_from := rosetta_g_miss_date_in_map(p2_a3);
    ddp_contract_rec.start_date_to := rosetta_g_miss_date_in_map(p2_a4);
    ddp_contract_rec.end_date_from := rosetta_g_miss_date_in_map(p2_a5);
    ddp_contract_rec.end_date_to := rosetta_g_miss_date_in_map(p2_a6);
    ddp_contract_rec.date_terminated_from := rosetta_g_miss_date_in_map(p2_a7);
    ddp_contract_rec.date_terminated_to := rosetta_g_miss_date_in_map(p2_a8);
    ddp_contract_rec.contract_party_id := p2_a9;
    ddp_contract_rec.request_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_contract_rec.entitlement_check_yn := p2_a11;

    oks_entitlements_pub_w.rosetta_table_copy_in_p44(ddp_clvl_id_tbl, p3_a0
      , p3_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.search_contracts(p_api_version,
      p_init_msg_list,
      ddp_contract_rec,
      ddp_clvl_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_contract_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    oks_entitlements_pub_w.rosetta_table_copy_out_p47(ddx_contract_tbl, p7_a0
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
      );
  end;

  procedure get_react_resolve_by_time(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  DATE
  )

  as
    ddp_inp_rec oks_entitlements_pub.grt_inp_rec_type;
    ddx_react_rec oks_entitlements_pub.rcn_rsn_rec_type;
    ddx_resolve_rec oks_entitlements_pub.rcn_rsn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec.contract_line_id := p2_a0;
    ddp_inp_rec.business_process_id := p2_a1;
    ddp_inp_rec.severity_id := p2_a2;
    ddp_inp_rec.request_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_inp_rec.time_zone_id := p2_a4;
    ddp_inp_rec.dates_in_input_tz := p2_a5;
    ddp_inp_rec.category_rcn_rsn := p2_a6;
    ddp_inp_rec.compute_option := p2_a7;
    ddp_inp_rec.template_yn := p2_a8;






    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_react_resolve_by_time(p_api_version,
      p_init_msg_list,
      ddp_inp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_react_rec,
      ddx_resolve_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_react_rec.duration;
    p6_a1 := ddx_react_rec.uom;
    p6_a2 := ddx_react_rec.by_date_start;
    p6_a3 := ddx_react_rec.by_date_end;

    p7_a0 := ddx_resolve_rec.duration;
    p7_a1 := ddx_resolve_rec.uom;
    p7_a2 := ddx_resolve_rec.by_date_start;
    p7_a3 := ddx_resolve_rec.by_date_end;
  end;

  procedure get_coverage_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_contract_line_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
  )

  as
    ddx_coverage_type oks_entitlements_pub.covtype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_coverage_type(p_api_version,
      p_init_msg_list,
      p_contract_line_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_coverage_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_coverage_type.code;
    p6_a1 := ddx_coverage_type.meaning;
    p6_a2 := ddx_coverage_type.importance_level;
  end;

  procedure get_highimp_cp_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_customer_product_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
  )

  as
    ddx_importance_lvl oks_entitlements_pub.high_imp_level_k_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_highimp_cp_contract(p_api_version,
      p_init_msg_list,
      p_customer_product_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_importance_lvl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_importance_lvl.contract_number;
    p6_a1 := ddx_importance_lvl.contract_number_modifier;
    p6_a2 := ddx_importance_lvl.contract_status_code;
    p6_a3 := ddx_importance_lvl.contract_start_date;
    p6_a4 := ddx_importance_lvl.contract_end_date;
    p6_a5 := ddx_importance_lvl.contract_amount;
    p6_a6 := ddx_importance_lvl.coverage_type;
    p6_a7 := ddx_importance_lvl.coverage_imp_level;
  end;

  procedure check_coverage_times(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_request_date  date
    , p_time_zone_id  NUMBER
    , p_dates_in_input_tz  VARCHAR2
    , p_contract_line_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_covered_yn out nocopy  VARCHAR2
  )

  as
    ddp_request_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_request_date := rosetta_g_miss_date_in_map(p_request_date);








    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.check_coverage_times(p_api_version,
      p_init_msg_list,
      p_business_process_id,
      ddp_request_date,
      p_time_zone_id,
      p_dates_in_input_tz,
      p_contract_line_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_covered_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure check_reaction_times(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_request_date  date
    , p_sr_severity  NUMBER
    , p_time_zone_id  NUMBER
    , p_dates_in_input_tz  VARCHAR2
    , p_contract_line_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_react_within out nocopy  NUMBER
    , x_react_tuom out nocopy  VARCHAR2
    , x_react_by_date out nocopy  DATE
  )

  as
    ddp_request_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_request_date := rosetta_g_miss_date_in_map(p_request_date);











    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.check_reaction_times(p_api_version,
      p_init_msg_list,
      p_business_process_id,
      ddp_request_date,
      p_sr_severity,
      p_time_zone_id,
      p_dates_in_input_tz,
      p_contract_line_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_react_within,
      x_react_tuom,
      x_react_by_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure get_contacts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_contract_id  NUMBER
    , p_contract_line_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_ent_contacts oks_entitlements_pub.ent_contact_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_contacts(p_api_version,
      p_init_msg_list,
      p_contract_id,
      p_contract_line_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ent_contacts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    oks_entitlements_pub_w.rosetta_table_copy_out_p60(ddx_ent_contacts, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );
  end;

  procedure get_preferred_engineers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_contract_line_id  NUMBER
    , p_business_process_id  NUMBER
    , p_request_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_request_date date;
    ddx_prf_engineers oks_entitlements_pub.prfeng_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_request_date := rosetta_g_miss_date_in_map(p_request_date);





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_preferred_engineers(p_api_version,
      p_init_msg_list,
      p_contract_line_id,
      p_business_process_id,
      ddp_request_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_prf_engineers);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    oks_entitlements_pub_w.rosetta_table_copy_out_p63(ddx_prf_engineers, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      );
  end;

  procedure oks_validate_system(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_system_id  NUMBER
    , p_request_date  date
    , p_update_only_check  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_system_valid out nocopy  VARCHAR2
  )

  as
    ddp_request_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_request_date := rosetta_g_miss_date_in_map(p_request_date);






    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.oks_validate_system(p_api_version,
      p_init_msg_list,
      p_system_id,
      ddp_request_date,
      p_update_only_check,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_system_valid);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure default_contline_system(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_system_id  NUMBER
    , p_request_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  DATE
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  DATE
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  NUMBER
  )

  as
    ddp_request_date date;
    ddx_ent_contracts oks_entitlements_pub.default_contline_system_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_request_date := rosetta_g_miss_date_in_map(p_request_date);





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.default_contline_system(p_api_version,
      p_init_msg_list,
      p_system_id,
      ddp_request_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_ent_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_ent_contracts.contract_id;
    p7_a1 := ddx_ent_contracts.contract_number;
    p7_a2 := ddx_ent_contracts.contract_number_modifier;
    p7_a3 := ddx_ent_contracts.sts_code;
    p7_a4 := ddx_ent_contracts.service_line_id;
    p7_a5 := ddx_ent_contracts.service_name;
    p7_a6 := ddx_ent_contracts.service_description;
    p7_a7 := ddx_ent_contracts.coverage_term_line_id;
    p7_a8 := ddx_ent_contracts.coverage_term_name;
    p7_a9 := ddx_ent_contracts.coverage_term_description;
    p7_a10 := ddx_ent_contracts.coverage_type_code;
    p7_a11 := ddx_ent_contracts.coverage_type_meaning;
    p7_a12 := ddx_ent_contracts.coverage_type_imp_level;
    p7_a13 := ddx_ent_contracts.service_start_date;
    p7_a14 := ddx_ent_contracts.service_end_date;
    p7_a15 := ddx_ent_contracts.warranty_flag;
    p7_a16 := ddx_ent_contracts.eligible_for_entitlement;
    p7_a17 := ddx_ent_contracts.exp_reaction_time;
    p7_a18 := ddx_ent_contracts.exp_resolution_time;
    p7_a19 := ddx_ent_contracts.status_code;
    p7_a20 := ddx_ent_contracts.status_text;
    p7_a21 := ddx_ent_contracts.date_terminated;
    p7_a22 := ddx_ent_contracts.pm_program_id;
    p7_a23 := ddx_ent_contracts.pm_schedule_exists;
    p7_a24 := ddx_ent_contracts.hd_currency_code;
    p7_a25 := ddx_ent_contracts.service_po_number;
    p7_a26 := ddx_ent_contracts.service_po_required_flag;
    p7_a27 := ddx_ent_contracts.covlvl_line_id;
  end;

  procedure get_cov_txn_groups(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_inp_rec_bp oks_entitlements_pub.inp_rec_bp;
    ddx_cov_txn_grp_lines oks_entitlements_pub.output_tbl_bp;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_inp_rec_bp.contract_line_id := p2_a0;
    ddp_inp_rec_bp.check_bp_def := p2_a1;
    ddp_inp_rec_bp.sr_enabled := p2_a2;
    ddp_inp_rec_bp.dr_enabled := p2_a3;
    ddp_inp_rec_bp.fs_enabled := p2_a4;





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_cov_txn_groups(p_api_version,
      p_init_msg_list,
      ddp_inp_rec_bp,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_cov_txn_grp_lines);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    oks_entitlements_pub_w.rosetta_table_copy_out_p70(ddx_cov_txn_grp_lines, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

  procedure get_txn_billing_types(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_cov_txngrp_line_id  NUMBER
    , p_return_bill_rates_yn  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_txn_bill_types oks_entitlements_pub.output_tbl_bt;
    ddx_txn_bill_rates oks_entitlements_pub.output_tbl_br;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.get_txn_billing_types(p_api_version,
      p_init_msg_list,
      p_cov_txngrp_line_id,
      p_return_bill_rates_yn,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_txn_bill_types,
      ddx_txn_bill_rates);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    oks_entitlements_pub_w.rosetta_table_copy_out_p73(ddx_txn_bill_types, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );

    oks_entitlements_pub_w.rosetta_table_copy_out_p75(ddx_txn_bill_rates, p8_a0
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
      );
  end;

  procedure search_contract_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  DATE
    , p2_a5  DATE
    , p2_a6  DATE
    , p2_a7  DATE
    , p2_a8  DATE
    , p2_a9  DATE
    , p2_a10  NUMBER
    , p2_a11  VARCHAR2
    , p2_a12  DATE
    , p2_a13  VARCHAR2
    , p2_a14  NUMBER
    , p2_a15  NUMBER
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  DATE
    , p3_a4  DATE
    , p3_a5  DATE
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_contract_rec oks_entitlements_pub.srchline_inpcontrec_type;
    ddp_contract_line_rec oks_entitlements_pub.srchline_inpcontlinerec_type;
    ddp_clvl_id_tbl oks_entitlements_pub.srchline_covlvl_id_tbl;
    ddx_contract_tbl oks_entitlements_pub.output_tbl_contractline;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_contract_rec.contract_id := p2_a0;
    ddp_contract_rec.contract_number := p2_a1;
    ddp_contract_rec.contract_number_modifier := p2_a2;
    ddp_contract_rec.contract_status_code := p2_a3;
    ddp_contract_rec.start_date_from := rosetta_g_miss_date_in_map(p2_a4);
    ddp_contract_rec.start_date_to := rosetta_g_miss_date_in_map(p2_a5);
    ddp_contract_rec.end_date_from := rosetta_g_miss_date_in_map(p2_a6);
    ddp_contract_rec.end_date_to := rosetta_g_miss_date_in_map(p2_a7);
    ddp_contract_rec.date_terminated_from := rosetta_g_miss_date_in_map(p2_a8);
    ddp_contract_rec.date_terminated_to := rosetta_g_miss_date_in_map(p2_a9);
    ddp_contract_rec.contract_party_id := p2_a10;
    ddp_contract_rec.contract_renewal_type_code := p2_a11;
    ddp_contract_rec.request_date := rosetta_g_miss_date_in_map(p2_a12);
    ddp_contract_rec.entitlement_check_yn := p2_a13;
    ddp_contract_rec.authoring_org_id := p2_a14;
    ddp_contract_rec.contract_group_id := p2_a15;

    ddp_contract_line_rec.service_item_id := p3_a0;
    ddp_contract_line_rec.contract_line_status_code := p3_a1;
    ddp_contract_line_rec.coverage_type_code := p3_a2;
    ddp_contract_line_rec.start_date_from := rosetta_g_miss_date_in_map(p3_a3);
    ddp_contract_line_rec.start_date_to := rosetta_g_miss_date_in_map(p3_a4);
    ddp_contract_line_rec.end_date_from := rosetta_g_miss_date_in_map(p3_a5);
    ddp_contract_line_rec.end_date_to := rosetta_g_miss_date_in_map(p3_a6);
    ddp_contract_line_rec.line_bill_to_site_id := p3_a7;
    ddp_contract_line_rec.line_ship_to_site_id := p3_a8;
    ddp_contract_line_rec.line_renewal_type_code := p3_a9;

    oks_entitlements_pub_w.rosetta_table_copy_in_p81(ddp_clvl_id_tbl, p4_a0
      , p4_a1
      , p4_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    oks_entitlements_pub.search_contract_lines(p_api_version,
      p_init_msg_list,
      ddp_contract_rec,
      ddp_contract_line_rec,
      ddp_clvl_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_contract_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    oks_entitlements_pub_w.rosetta_table_copy_out_p83(ddx_contract_tbl, p8_a0
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
      );
  end;

end oks_entitlements_pub_w;

/
