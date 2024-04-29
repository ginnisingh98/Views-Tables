--------------------------------------------------------
--  DDL for Package Body AS_OPPORTUNITY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPPORTUNITY_PUB_W" as
  /* $Header: asxwop1b.pls 120.1 2005/08/01 05:38 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy as_opportunity_pub.header_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_400
    , a19 JTF_VARCHAR2_TABLE_400
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_DATE_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_400
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_400
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_DATE_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_200
    , a84 JTF_VARCHAR2_TABLE_200
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_200
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_200
    , a90 JTF_VARCHAR2_TABLE_200
    , a91 JTF_VARCHAR2_TABLE_200
    , a92 JTF_VARCHAR2_TABLE_200
    , a93 JTF_VARCHAR2_TABLE_200
    , a94 JTF_VARCHAR2_TABLE_200
    , a95 JTF_VARCHAR2_TABLE_200
    , a96 JTF_VARCHAR2_TABLE_200
    , a97 JTF_VARCHAR2_TABLE_200
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).lead_number := a10(indx);
          t(ddindx).orig_system_reference := a11(indx);
          t(ddindx).lead_source_code := a12(indx);
          t(ddindx).lead_source := a13(indx);
          t(ddindx).description := a14(indx);
          t(ddindx).source_promotion_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).source_promotion_code := a16(indx);
          t(ddindx).customer_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).customer_name := a18(indx);
          t(ddindx).customer_name_phonetic := a19(indx);
          t(ddindx).address_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).address := a21(indx);
          t(ddindx).address2 := a22(indx);
          t(ddindx).address3 := a23(indx);
          t(ddindx).address4 := a24(indx);
          t(ddindx).city := a25(indx);
          t(ddindx).state := a26(indx);
          t(ddindx).country := a27(indx);
          t(ddindx).province := a28(indx);
          t(ddindx).sales_stage_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).sales_stage := a30(indx);
          t(ddindx).win_probability := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).status_code := a32(indx);
          t(ddindx).status := a33(indx);
          t(ddindx).total_amount := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).converted_total_amount := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).channel_code := a36(indx);
          t(ddindx).channel := a37(indx);
          t(ddindx).decision_date := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).currency_code := a39(indx);
          t(ddindx).to_currency_code := a40(indx);
          t(ddindx).close_reason_code := a41(indx);
          t(ddindx).close_reason := a42(indx);
          t(ddindx).close_competitor_code := a43(indx);
          t(ddindx).close_competitor_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).close_competitor := a45(indx);
          t(ddindx).close_comment := a46(indx);
          t(ddindx).end_user_customer_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).end_user_customer_name := a48(indx);
          t(ddindx).end_user_address_id := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).owner_salesforce_id := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).owner_sales_group_id := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).parent_project := a52(indx);
          t(ddindx).parent_project_code := a53(indx);
          t(ddindx).updateable_flag := a54(indx);
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).initiating_contact_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).rank := a57(indx);
          t(ddindx).member_access := a58(indx);
          t(ddindx).member_role := a59(indx);
          t(ddindx).deleted_flag := a60(indx);
          t(ddindx).auto_assignment_type := a61(indx);
          t(ddindx).prm_assignment_type := a62(indx);
          t(ddindx).customer_budget := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).methodology_code := a64(indx);
          t(ddindx).sales_methodology_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).original_lead_id := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).decision_timeframe_code := a67(indx);
          t(ddindx).incumbent_partner_resource_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).incumbent_partner_party_id := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).vehicle_response_code := a71(indx);
          t(ddindx).budget_status_code := a72(indx);
          t(ddindx).followup_date := rosetta_g_miss_date_in_map(a73(indx));
          t(ddindx).no_opp_allowed_flag := a74(indx);
          t(ddindx).delete_allowed_flag := a75(indx);
          t(ddindx).prm_exec_sponsor_flag := a76(indx);
          t(ddindx).prm_prj_lead_in_place_flag := a77(indx);
          t(ddindx).prm_ind_classification_code := a78(indx);
          t(ddindx).prm_lead_type := a79(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).freeze_flag := a81(indx);
          t(ddindx).attribute_category := a82(indx);
          t(ddindx).attribute1 := a83(indx);
          t(ddindx).attribute2 := a84(indx);
          t(ddindx).attribute3 := a85(indx);
          t(ddindx).attribute4 := a86(indx);
          t(ddindx).attribute5 := a87(indx);
          t(ddindx).attribute6 := a88(indx);
          t(ddindx).attribute7 := a89(indx);
          t(ddindx).attribute8 := a90(indx);
          t(ddindx).attribute9 := a91(indx);
          t(ddindx).attribute10 := a92(indx);
          t(ddindx).attribute11 := a93(indx);
          t(ddindx).attribute12 := a94(indx);
          t(ddindx).attribute13 := a95(indx);
          t(ddindx).attribute14 := a96(indx);
          t(ddindx).attribute15 := a97(indx);
          t(ddindx).prm_referral_code := a98(indx);
          t(ddindx).total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(a99(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t as_opportunity_pub.header_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_400
    , a19 out nocopy JTF_VARCHAR2_TABLE_400
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_400
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_400
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_DATE_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_200
    , a84 out nocopy JTF_VARCHAR2_TABLE_200
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_200
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_200
    , a90 out nocopy JTF_VARCHAR2_TABLE_200
    , a91 out nocopy JTF_VARCHAR2_TABLE_200
    , a92 out nocopy JTF_VARCHAR2_TABLE_200
    , a93 out nocopy JTF_VARCHAR2_TABLE_200
    , a94 out nocopy JTF_VARCHAR2_TABLE_200
    , a95 out nocopy JTF_VARCHAR2_TABLE_200
    , a96 out nocopy JTF_VARCHAR2_TABLE_200
    , a97 out nocopy JTF_VARCHAR2_TABLE_200
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_400();
    a19 := JTF_VARCHAR2_TABLE_400();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_400();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_400();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_DATE_TABLE();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_200();
    a84 := JTF_VARCHAR2_TABLE_200();
    a85 := JTF_VARCHAR2_TABLE_200();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_200();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_200();
    a90 := JTF_VARCHAR2_TABLE_200();
    a91 := JTF_VARCHAR2_TABLE_200();
    a92 := JTF_VARCHAR2_TABLE_200();
    a93 := JTF_VARCHAR2_TABLE_200();
    a94 := JTF_VARCHAR2_TABLE_200();
    a95 := JTF_VARCHAR2_TABLE_200();
    a96 := JTF_VARCHAR2_TABLE_200();
    a97 := JTF_VARCHAR2_TABLE_200();
    a98 := JTF_VARCHAR2_TABLE_100();
    a99 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_400();
      a19 := JTF_VARCHAR2_TABLE_400();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_400();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_400();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_DATE_TABLE();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_200();
      a84 := JTF_VARCHAR2_TABLE_200();
      a85 := JTF_VARCHAR2_TABLE_200();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_200();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_200();
      a90 := JTF_VARCHAR2_TABLE_200();
      a91 := JTF_VARCHAR2_TABLE_200();
      a92 := JTF_VARCHAR2_TABLE_200();
      a93 := JTF_VARCHAR2_TABLE_200();
      a94 := JTF_VARCHAR2_TABLE_200();
      a95 := JTF_VARCHAR2_TABLE_200();
      a96 := JTF_VARCHAR2_TABLE_200();
      a97 := JTF_VARCHAR2_TABLE_200();
      a98 := JTF_VARCHAR2_TABLE_100();
      a99 := JTF_NUMBER_TABLE();
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
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a10(indx) := t(ddindx).lead_number;
          a11(indx) := t(ddindx).orig_system_reference;
          a12(indx) := t(ddindx).lead_source_code;
          a13(indx) := t(ddindx).lead_source;
          a14(indx) := t(ddindx).description;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).source_promotion_id);
          a16(indx) := t(ddindx).source_promotion_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a18(indx) := t(ddindx).customer_name;
          a19(indx) := t(ddindx).customer_name_phonetic;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).address_id);
          a21(indx) := t(ddindx).address;
          a22(indx) := t(ddindx).address2;
          a23(indx) := t(ddindx).address3;
          a24(indx) := t(ddindx).address4;
          a25(indx) := t(ddindx).city;
          a26(indx) := t(ddindx).state;
          a27(indx) := t(ddindx).country;
          a28(indx) := t(ddindx).province;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).sales_stage_id);
          a30(indx) := t(ddindx).sales_stage;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).win_probability);
          a32(indx) := t(ddindx).status_code;
          a33(indx) := t(ddindx).status;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).total_amount);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).converted_total_amount);
          a36(indx) := t(ddindx).channel_code;
          a37(indx) := t(ddindx).channel;
          a38(indx) := t(ddindx).decision_date;
          a39(indx) := t(ddindx).currency_code;
          a40(indx) := t(ddindx).to_currency_code;
          a41(indx) := t(ddindx).close_reason_code;
          a42(indx) := t(ddindx).close_reason;
          a43(indx) := t(ddindx).close_competitor_code;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).close_competitor_id);
          a45(indx) := t(ddindx).close_competitor;
          a46(indx) := t(ddindx).close_comment;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).end_user_customer_id);
          a48(indx) := t(ddindx).end_user_customer_name;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).end_user_address_id);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).owner_salesforce_id);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).owner_sales_group_id);
          a52(indx) := t(ddindx).parent_project;
          a53(indx) := t(ddindx).parent_project_code;
          a54(indx) := t(ddindx).updateable_flag;
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).initiating_contact_id);
          a57(indx) := t(ddindx).rank;
          a58(indx) := t(ddindx).member_access;
          a59(indx) := t(ddindx).member_role;
          a60(indx) := t(ddindx).deleted_flag;
          a61(indx) := t(ddindx).auto_assignment_type;
          a62(indx) := t(ddindx).prm_assignment_type;
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).customer_budget);
          a64(indx) := t(ddindx).methodology_code;
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).sales_methodology_id);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).original_lead_id);
          a67(indx) := t(ddindx).decision_timeframe_code;
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).incumbent_partner_resource_id);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).incumbent_partner_party_id);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a71(indx) := t(ddindx).vehicle_response_code;
          a72(indx) := t(ddindx).budget_status_code;
          a73(indx) := t(ddindx).followup_date;
          a74(indx) := t(ddindx).no_opp_allowed_flag;
          a75(indx) := t(ddindx).delete_allowed_flag;
          a76(indx) := t(ddindx).prm_exec_sponsor_flag;
          a77(indx) := t(ddindx).prm_prj_lead_in_place_flag;
          a78(indx) := t(ddindx).prm_ind_classification_code;
          a79(indx) := t(ddindx).prm_lead_type;
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a81(indx) := t(ddindx).freeze_flag;
          a82(indx) := t(ddindx).attribute_category;
          a83(indx) := t(ddindx).attribute1;
          a84(indx) := t(ddindx).attribute2;
          a85(indx) := t(ddindx).attribute3;
          a86(indx) := t(ddindx).attribute4;
          a87(indx) := t(ddindx).attribute5;
          a88(indx) := t(ddindx).attribute6;
          a89(indx) := t(ddindx).attribute7;
          a90(indx) := t(ddindx).attribute8;
          a91(indx) := t(ddindx).attribute9;
          a92(indx) := t(ddindx).attribute10;
          a93(indx) := t(ddindx).attribute11;
          a94(indx) := t(ddindx).attribute12;
          a95(indx) := t(ddindx).attribute13;
          a96(indx) := t(ddindx).attribute14;
          a97(indx) := t(ddindx).attribute15;
          a98(indx) := t(ddindx).prm_referral_code;
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).total_revenue_opp_forecast_amt);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t out nocopy as_opportunity_pub.line_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_DATE_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).lead_line_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).original_lead_line_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).interest_type_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).interest_type := a13(indx);
          t(ddindx).interest_status_code := a14(indx);
          t(ddindx).primary_interest_code_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).primary_interest_code := a16(indx);
          t(ddindx).secondary_interest_code_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).secondary_interest_code := a18(indx);
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).inventory_item_conc_segs := a20(indx);
          t(ddindx).organization_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).uom_code := a22(indx);
          t(ddindx).uom := a23(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).ship_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).total_amount := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).sales_stage_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).sales_stage := a28(indx);
          t(ddindx).win_probability := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).status_code := a30(indx);
          t(ddindx).status := a31(indx);
          t(ddindx).decision_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).channel_code := a33(indx);
          t(ddindx).channel := a34(indx);
          t(ddindx).unit_price := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).price := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).price_volume_margin := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).quoted_line_flag := a38(indx);
          t(ddindx).member_access := a39(indx);
          t(ddindx).member_role := a40(indx);
          t(ddindx).currency_code := a41(indx);
          t(ddindx).owner_scredit_percent := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).source_promotion_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).forecast_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).rolling_forecast_flag := a45(indx);
          t(ddindx).offer_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).product_category_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).product_cat_set_id := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).attribute_category := a50(indx);
          t(ddindx).attribute1 := a51(indx);
          t(ddindx).attribute2 := a52(indx);
          t(ddindx).attribute3 := a53(indx);
          t(ddindx).attribute4 := a54(indx);
          t(ddindx).attribute5 := a55(indx);
          t(ddindx).attribute6 := a56(indx);
          t(ddindx).attribute7 := a57(indx);
          t(ddindx).attribute8 := a58(indx);
          t(ddindx).attribute9 := a59(indx);
          t(ddindx).attribute10 := a60(indx);
          t(ddindx).attribute11 := a61(indx);
          t(ddindx).attribute12 := a62(indx);
          t(ddindx).attribute13 := a63(indx);
          t(ddindx).attribute14 := a64(indx);
          t(ddindx).attribute15 := a65(indx);
          t(ddindx).opp_worst_forecast_amount := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).opp_forecast_amount := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).opp_best_forecast_amount := rosetta_g_miss_num_map(a68(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t as_opportunity_pub.line_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_200();
    a65 := JTF_VARCHAR2_TABLE_200();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_200();
      a65 := JTF_VARCHAR2_TABLE_200();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
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
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).lead_line_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).original_lead_line_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).interest_type_id);
          a13(indx) := t(ddindx).interest_type;
          a14(indx) := t(ddindx).interest_status_code;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).primary_interest_code_id);
          a16(indx) := t(ddindx).primary_interest_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).secondary_interest_code_id);
          a18(indx) := t(ddindx).secondary_interest_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a20(indx) := t(ddindx).inventory_item_conc_segs;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a22(indx) := t(ddindx).uom_code;
          a23(indx) := t(ddindx).uom;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a25(indx) := t(ddindx).ship_date;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).total_amount);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).sales_stage_id);
          a28(indx) := t(ddindx).sales_stage;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).win_probability);
          a30(indx) := t(ddindx).status_code;
          a31(indx) := t(ddindx).status;
          a32(indx) := t(ddindx).decision_date;
          a33(indx) := t(ddindx).channel_code;
          a34(indx) := t(ddindx).channel;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).unit_price);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).price);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).price_volume_margin);
          a38(indx) := t(ddindx).quoted_line_flag;
          a39(indx) := t(ddindx).member_access;
          a40(indx) := t(ddindx).member_role;
          a41(indx) := t(ddindx).currency_code;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).owner_scredit_percent);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).source_promotion_id);
          a44(indx) := t(ddindx).forecast_date;
          a45(indx) := t(ddindx).rolling_forecast_flag;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).product_category_id);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).product_cat_set_id);
          a50(indx) := t(ddindx).attribute_category;
          a51(indx) := t(ddindx).attribute1;
          a52(indx) := t(ddindx).attribute2;
          a53(indx) := t(ddindx).attribute3;
          a54(indx) := t(ddindx).attribute4;
          a55(indx) := t(ddindx).attribute5;
          a56(indx) := t(ddindx).attribute6;
          a57(indx) := t(ddindx).attribute7;
          a58(indx) := t(ddindx).attribute8;
          a59(indx) := t(ddindx).attribute9;
          a60(indx) := t(ddindx).attribute10;
          a61(indx) := t(ddindx).attribute11;
          a62(indx) := t(ddindx).attribute12;
          a63(indx) := t(ddindx).attribute13;
          a64(indx) := t(ddindx).attribute14;
          a65(indx) := t(ddindx).attribute15;
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).opp_worst_forecast_amount);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).opp_forecast_amount);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).opp_best_forecast_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p9(t out nocopy as_opportunity_pub.line_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t as_opportunity_pub.line_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_line_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p12(t out nocopy as_opportunity_pub.sales_credit_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_400
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).sales_credit_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).original_sales_credit_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).lead_line_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).salesforce_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).person_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).employee_last_name := a15(indx);
          t(ddindx).employee_first_name := a16(indx);
          t(ddindx).salesgroup_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).salesgroup_name := a18(indx);
          t(ddindx).partner_customer_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).partner_customer_name := a20(indx);
          t(ddindx).partner_city := a21(indx);
          t(ddindx).partner_address_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).revenue_amount := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).revenue_percent := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).quota_credit_amount := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).quota_credit_percent := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).revenue_derived_col := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).quota_derived_col := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).member_access := a29(indx);
          t(ddindx).member_role := a30(indx);
          t(ddindx).manager_review_flag := a31(indx);
          t(ddindx).manager_review_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).line_tbl_index := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).delete_flag := a34(indx);
          t(ddindx).currency_code := a35(indx);
          t(ddindx).credit_type_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).credit_type := a37(indx);
          t(ddindx).credit_amount := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).credit_percent := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).attribute_category := a41(indx);
          t(ddindx).attribute1 := a42(indx);
          t(ddindx).attribute2 := a43(indx);
          t(ddindx).attribute3 := a44(indx);
          t(ddindx).attribute4 := a45(indx);
          t(ddindx).attribute5 := a46(indx);
          t(ddindx).attribute6 := a47(indx);
          t(ddindx).attribute7 := a48(indx);
          t(ddindx).attribute8 := a49(indx);
          t(ddindx).attribute9 := a50(indx);
          t(ddindx).attribute10 := a51(indx);
          t(ddindx).attribute11 := a52(indx);
          t(ddindx).attribute12 := a53(indx);
          t(ddindx).attribute13 := a54(indx);
          t(ddindx).attribute14 := a55(indx);
          t(ddindx).attribute15 := a56(indx);
          t(ddindx).opp_worst_forecast_amount := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).opp_forecast_amount := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).opp_best_forecast_amount := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).defaulted_from_owner_flag := a60(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t as_opportunity_pub.sales_credit_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_400
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_400();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_400();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
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
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).sales_credit_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).original_sales_credit_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).lead_line_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).salesforce_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).person_id);
          a15(indx) := t(ddindx).employee_last_name;
          a16(indx) := t(ddindx).employee_first_name;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).salesgroup_id);
          a18(indx) := t(ddindx).salesgroup_name;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).partner_customer_id);
          a20(indx) := t(ddindx).partner_customer_name;
          a21(indx) := t(ddindx).partner_city;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).partner_address_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).revenue_amount);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).revenue_percent);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).quota_credit_amount);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).quota_credit_percent);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).revenue_derived_col);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).quota_derived_col);
          a29(indx) := t(ddindx).member_access;
          a30(indx) := t(ddindx).member_role;
          a31(indx) := t(ddindx).manager_review_flag;
          a32(indx) := t(ddindx).manager_review_date;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).line_tbl_index);
          a34(indx) := t(ddindx).delete_flag;
          a35(indx) := t(ddindx).currency_code;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).credit_type_id);
          a37(indx) := t(ddindx).credit_type;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).credit_amount);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).credit_percent);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a41(indx) := t(ddindx).attribute_category;
          a42(indx) := t(ddindx).attribute1;
          a43(indx) := t(ddindx).attribute2;
          a44(indx) := t(ddindx).attribute3;
          a45(indx) := t(ddindx).attribute4;
          a46(indx) := t(ddindx).attribute5;
          a47(indx) := t(ddindx).attribute6;
          a48(indx) := t(ddindx).attribute7;
          a49(indx) := t(ddindx).attribute8;
          a50(indx) := t(ddindx).attribute9;
          a51(indx) := t(ddindx).attribute10;
          a52(indx) := t(ddindx).attribute11;
          a53(indx) := t(ddindx).attribute12;
          a54(indx) := t(ddindx).attribute13;
          a55(indx) := t(ddindx).attribute14;
          a56(indx) := t(ddindx).attribute15;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).opp_worst_forecast_amount);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).opp_forecast_amount);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).opp_best_forecast_amount);
          a60(indx) := t(ddindx).defaulted_from_owner_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p15(t out nocopy as_opportunity_pub.sales_credit_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sales_credit_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t as_opportunity_pub.sales_credit_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).sales_credit_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p20(t out nocopy as_opportunity_pub.obstacle_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).lead_obstacle_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).obstacle_code := a11(indx);
          t(ddindx).obstacle := a12(indx);
          t(ddindx).obstacle_status := a13(indx);
          t(ddindx).comments := a14(indx);
          t(ddindx).member_access := a15(indx);
          t(ddindx).member_role := a16(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).attribute_category := a18(indx);
          t(ddindx).attribute1 := a19(indx);
          t(ddindx).attribute2 := a20(indx);
          t(ddindx).attribute3 := a21(indx);
          t(ddindx).attribute4 := a22(indx);
          t(ddindx).attribute5 := a23(indx);
          t(ddindx).attribute6 := a24(indx);
          t(ddindx).attribute7 := a25(indx);
          t(ddindx).attribute8 := a26(indx);
          t(ddindx).attribute9 := a27(indx);
          t(ddindx).attribute10 := a28(indx);
          t(ddindx).attribute11 := a29(indx);
          t(ddindx).attribute12 := a30(indx);
          t(ddindx).attribute13 := a31(indx);
          t(ddindx).attribute14 := a32(indx);
          t(ddindx).attribute15 := a33(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t as_opportunity_pub.obstacle_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
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
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lead_obstacle_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a11(indx) := t(ddindx).obstacle_code;
          a12(indx) := t(ddindx).obstacle;
          a13(indx) := t(ddindx).obstacle_status;
          a14(indx) := t(ddindx).comments;
          a15(indx) := t(ddindx).member_access;
          a16(indx) := t(ddindx).member_role;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a18(indx) := t(ddindx).attribute_category;
          a19(indx) := t(ddindx).attribute1;
          a20(indx) := t(ddindx).attribute2;
          a21(indx) := t(ddindx).attribute3;
          a22(indx) := t(ddindx).attribute4;
          a23(indx) := t(ddindx).attribute5;
          a24(indx) := t(ddindx).attribute6;
          a25(indx) := t(ddindx).attribute7;
          a26(indx) := t(ddindx).attribute8;
          a27(indx) := t(ddindx).attribute9;
          a28(indx) := t(ddindx).attribute10;
          a29(indx) := t(ddindx).attribute11;
          a30(indx) := t(ddindx).attribute12;
          a31(indx) := t(ddindx).attribute13;
          a32(indx) := t(ddindx).attribute14;
          a33(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p23(t out nocopy as_opportunity_pub.obstacle_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_obstacle_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t as_opportunity_pub.obstacle_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_obstacle_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p26(t out nocopy as_opportunity_pub.competitor_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).lead_competitor_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).competitor_code := a10(indx);
          t(ddindx).competitor_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).relationship_party_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).competitor := a14(indx);
          t(ddindx).competitor_meaning := a15(indx);
          t(ddindx).competitor_rank := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).win_loss_status := a17(indx);
          t(ddindx).products := a18(indx);
          t(ddindx).comments := a19(indx);
          t(ddindx).member_access := a20(indx);
          t(ddindx).member_role := a21(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a22(indx));
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
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t as_opportunity_pub.competitor_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
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
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lead_competitor_id);
          a10(indx) := t(ddindx).competitor_code;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).competitor_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).relationship_party_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a14(indx) := t(ddindx).competitor;
          a15(indx) := t(ddindx).competitor_meaning;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).competitor_rank);
          a17(indx) := t(ddindx).win_loss_status;
          a18(indx) := t(ddindx).products;
          a19(indx) := t(ddindx).comments;
          a20(indx) := t(ddindx).member_access;
          a21(indx) := t(ddindx).member_role;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
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
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p29(t out nocopy as_opportunity_pub.competitor_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_competitor_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t as_opportunity_pub.competitor_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_competitor_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p32(t out nocopy as_opportunity_pub.order_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
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
    , a36 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).lead_order_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).order_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).order_header_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).date_ordered := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).order_type_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).order_type := a15(indx);
          t(ddindx).currency_code := a16(indx);
          t(ddindx).order_amount := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).member_access := a18(indx);
          t(ddindx).member_role := a19(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).attribute_category := a21(indx);
          t(ddindx).attribute1 := a22(indx);
          t(ddindx).attribute2 := a23(indx);
          t(ddindx).attribute3 := a24(indx);
          t(ddindx).attribute4 := a25(indx);
          t(ddindx).attribute5 := a26(indx);
          t(ddindx).attribute6 := a27(indx);
          t(ddindx).attribute7 := a28(indx);
          t(ddindx).attribute8 := a29(indx);
          t(ddindx).attribute9 := a30(indx);
          t(ddindx).attribute10 := a31(indx);
          t(ddindx).attribute11 := a32(indx);
          t(ddindx).attribute12 := a33(indx);
          t(ddindx).attribute13 := a34(indx);
          t(ddindx).attribute14 := a35(indx);
          t(ddindx).attribute15 := a36(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p32;
  procedure rosetta_table_copy_out_p32(t as_opportunity_pub.order_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
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
    a36 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
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
      a36 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lead_order_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).order_number);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).order_header_id);
          a13(indx) := t(ddindx).date_ordered;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).order_type_id);
          a15(indx) := t(ddindx).order_type;
          a16(indx) := t(ddindx).currency_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).order_amount);
          a18(indx) := t(ddindx).member_access;
          a19(indx) := t(ddindx).member_role;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a21(indx) := t(ddindx).attribute_category;
          a22(indx) := t(ddindx).attribute1;
          a23(indx) := t(ddindx).attribute2;
          a24(indx) := t(ddindx).attribute3;
          a25(indx) := t(ddindx).attribute4;
          a26(indx) := t(ddindx).attribute5;
          a27(indx) := t(ddindx).attribute6;
          a28(indx) := t(ddindx).attribute7;
          a29(indx) := t(ddindx).attribute8;
          a30(indx) := t(ddindx).attribute9;
          a31(indx) := t(ddindx).attribute10;
          a32(indx) := t(ddindx).attribute11;
          a33(indx) := t(ddindx).attribute12;
          a34(indx) := t(ddindx).attribute13;
          a35(indx) := t(ddindx).attribute14;
          a36(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p32;

  procedure rosetta_table_copy_in_p35(t out nocopy as_opportunity_pub.order_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_order_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t as_opportunity_pub.order_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_order_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure rosetta_table_copy_in_p38(t out nocopy as_opportunity_pub.contact_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
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
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).lead_contact_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).customer_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).address_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).phone_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).first_name := a14(indx);
          t(ddindx).last_name := a15(indx);
          t(ddindx).contact_number := a16(indx);
          t(ddindx).orig_system_reference := a17(indx);
          t(ddindx).contact_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).enabled_flag := a19(indx);
          t(ddindx).rank_code := a20(indx);
          t(ddindx).rank := a21(indx);
          t(ddindx).member_access := a22(indx);
          t(ddindx).member_role := a23(indx);
          t(ddindx).contact_party_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).primary_contact_flag := a25(indx);
          t(ddindx).role := a26(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).attribute_category := a28(indx);
          t(ddindx).attribute1 := a29(indx);
          t(ddindx).attribute2 := a30(indx);
          t(ddindx).attribute3 := a31(indx);
          t(ddindx).attribute4 := a32(indx);
          t(ddindx).attribute5 := a33(indx);
          t(ddindx).attribute6 := a34(indx);
          t(ddindx).attribute7 := a35(indx);
          t(ddindx).attribute8 := a36(indx);
          t(ddindx).attribute9 := a37(indx);
          t(ddindx).attribute10 := a38(indx);
          t(ddindx).attribute11 := a39(indx);
          t(ddindx).attribute12 := a40(indx);
          t(ddindx).attribute13 := a41(indx);
          t(ddindx).attribute14 := a42(indx);
          t(ddindx).attribute15 := a43(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p38;
  procedure rosetta_table_copy_out_p38(t as_opportunity_pub.contact_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
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
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
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
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).last_update_date;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a8(indx) := t(ddindx).program_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lead_contact_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).address_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).phone_id);
          a14(indx) := t(ddindx).first_name;
          a15(indx) := t(ddindx).last_name;
          a16(indx) := t(ddindx).contact_number;
          a17(indx) := t(ddindx).orig_system_reference;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).contact_id);
          a19(indx) := t(ddindx).enabled_flag;
          a20(indx) := t(ddindx).rank_code;
          a21(indx) := t(ddindx).rank;
          a22(indx) := t(ddindx).member_access;
          a23(indx) := t(ddindx).member_role;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).contact_party_id);
          a25(indx) := t(ddindx).primary_contact_flag;
          a26(indx) := t(ddindx).role;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a28(indx) := t(ddindx).attribute_category;
          a29(indx) := t(ddindx).attribute1;
          a30(indx) := t(ddindx).attribute2;
          a31(indx) := t(ddindx).attribute3;
          a32(indx) := t(ddindx).attribute4;
          a33(indx) := t(ddindx).attribute5;
          a34(indx) := t(ddindx).attribute6;
          a35(indx) := t(ddindx).attribute7;
          a36(indx) := t(ddindx).attribute8;
          a37(indx) := t(ddindx).attribute9;
          a38(indx) := t(ddindx).attribute10;
          a39(indx) := t(ddindx).attribute11;
          a40(indx) := t(ddindx).attribute12;
          a41(indx) := t(ddindx).attribute13;
          a42(indx) := t(ddindx).attribute14;
          a43(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p38;

  procedure rosetta_table_copy_in_p41(t out nocopy as_opportunity_pub.contact_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_contact_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t as_opportunity_pub.contact_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_contact_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p44(t out nocopy as_opportunity_pub.competitor_prod_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute15 := a0(indx);
          t(ddindx).attribute14 := a1(indx);
          t(ddindx).attribute13 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute11 := a4(indx);
          t(ddindx).attribute10 := a5(indx);
          t(ddindx).attribute9 := a6(indx);
          t(ddindx).attribute8 := a7(indx);
          t(ddindx).attribute7 := a8(indx);
          t(ddindx).attribute6 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute_category := a15(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).win_loss_status := a20(indx);
          t(ddindx).competitor_product_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).lead_line_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).lead_competitor_prod_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p44;
  procedure rosetta_table_copy_out_p44(t as_opportunity_pub.competitor_prod_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute15;
          a1(indx) := t(ddindx).attribute14;
          a2(indx) := t(ddindx).attribute13;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute11;
          a5(indx) := t(ddindx).attribute10;
          a6(indx) := t(ddindx).attribute9;
          a7(indx) := t(ddindx).attribute8;
          a8(indx) := t(ddindx).attribute7;
          a9(indx) := t(ddindx).attribute6;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute_category;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a17(indx) := t(ddindx).program_update_date;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a20(indx) := t(ddindx).win_loss_status;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).competitor_product_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).lead_line_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).lead_competitor_prod_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a29(indx) := t(ddindx).creation_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p44;

  procedure rosetta_table_copy_in_p47(t out nocopy as_opportunity_pub.competitor_prod_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_competitor_prod_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p47;
  procedure rosetta_table_copy_out_p47(t as_opportunity_pub.competitor_prod_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_competitor_prod_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p47;

  procedure rosetta_table_copy_in_p50(t out nocopy as_opportunity_pub.decision_factor_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute15 := a0(indx);
          t(ddindx).attribute14 := a1(indx);
          t(ddindx).attribute13 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute11 := a4(indx);
          t(ddindx).attribute10 := a5(indx);
          t(ddindx).attribute9 := a6(indx);
          t(ddindx).attribute8 := a7(indx);
          t(ddindx).attribute7 := a8(indx);
          t(ddindx).attribute6 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute4 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute_category := a15(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).decision_rank := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).decision_priority_code := a21(indx);
          t(ddindx).decision_factor_code := a22(indx);
          t(ddindx).lead_decision_factor_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).lead_line_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).create_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a29(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p50;
  procedure rosetta_table_copy_out_p50(t as_opportunity_pub.decision_factor_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute15;
          a1(indx) := t(ddindx).attribute14;
          a2(indx) := t(ddindx).attribute13;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute11;
          a5(indx) := t(ddindx).attribute10;
          a6(indx) := t(ddindx).attribute9;
          a7(indx) := t(ddindx).attribute8;
          a8(indx) := t(ddindx).attribute7;
          a9(indx) := t(ddindx).attribute6;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute4;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute_category;
          a16(indx) := t(ddindx).program_update_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).decision_rank);
          a21(indx) := t(ddindx).decision_priority_code;
          a22(indx) := t(ddindx).decision_factor_code;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).lead_decision_factor_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).lead_line_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).create_by);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a29(indx) := t(ddindx).creation_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p50;

  procedure rosetta_table_copy_in_p53(t out nocopy as_opportunity_pub.decision_factor_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_decision_factor_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p53;
  procedure rosetta_table_copy_out_p53(t as_opportunity_pub.decision_factor_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_decision_factor_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p53;

  procedure create_opp_header(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_salesgroup_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_lead_id out nocopy  NUMBER
    , p4_a0  DATE := fnd_api.g_miss_date
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  DATE := fnd_api.g_miss_date
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  NUMBER := 0-1962.0724
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  NUMBER := 0-1962.0724
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  NUMBER := 0-1962.0724
    , p4_a50  NUMBER := 0-1962.0724
    , p4_a51  NUMBER := 0-1962.0724
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  NUMBER := 0-1962.0724
    , p4_a56  NUMBER := 0-1962.0724
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  NUMBER := 0-1962.0724
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  NUMBER := 0-1962.0724
    , p4_a67  VARCHAR2 := fnd_api.g_miss_char
    , p4_a68  NUMBER := 0-1962.0724
    , p4_a69  NUMBER := 0-1962.0724
    , p4_a70  NUMBER := 0-1962.0724
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  VARCHAR2 := fnd_api.g_miss_char
    , p4_a73  DATE := fnd_api.g_miss_date
    , p4_a74  VARCHAR2 := fnd_api.g_miss_char
    , p4_a75  VARCHAR2 := fnd_api.g_miss_char
    , p4_a76  VARCHAR2 := fnd_api.g_miss_char
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  VARCHAR2 := fnd_api.g_miss_char
    , p4_a82  VARCHAR2 := fnd_api.g_miss_char
    , p4_a83  VARCHAR2 := fnd_api.g_miss_char
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  VARCHAR2 := fnd_api.g_miss_char
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  VARCHAR2 := fnd_api.g_miss_char
    , p4_a90  VARCHAR2 := fnd_api.g_miss_char
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  VARCHAR2 := fnd_api.g_miss_char
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  VARCHAR2 := fnd_api.g_miss_char
    , p4_a95  VARCHAR2 := fnd_api.g_miss_char
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p4_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p4_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p4_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p4_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p4_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p4_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p4_a9);
    ddp_header_rec.lead_number := p4_a10;
    ddp_header_rec.orig_system_reference := p4_a11;
    ddp_header_rec.lead_source_code := p4_a12;
    ddp_header_rec.lead_source := p4_a13;
    ddp_header_rec.description := p4_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p4_a15);
    ddp_header_rec.source_promotion_code := p4_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p4_a17);
    ddp_header_rec.customer_name := p4_a18;
    ddp_header_rec.customer_name_phonetic := p4_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p4_a20);
    ddp_header_rec.address := p4_a21;
    ddp_header_rec.address2 := p4_a22;
    ddp_header_rec.address3 := p4_a23;
    ddp_header_rec.address4 := p4_a24;
    ddp_header_rec.city := p4_a25;
    ddp_header_rec.state := p4_a26;
    ddp_header_rec.country := p4_a27;
    ddp_header_rec.province := p4_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p4_a29);
    ddp_header_rec.sales_stage := p4_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p4_a31);
    ddp_header_rec.status_code := p4_a32;
    ddp_header_rec.status := p4_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p4_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p4_a35);
    ddp_header_rec.channel_code := p4_a36;
    ddp_header_rec.channel := p4_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p4_a38);
    ddp_header_rec.currency_code := p4_a39;
    ddp_header_rec.to_currency_code := p4_a40;
    ddp_header_rec.close_reason_code := p4_a41;
    ddp_header_rec.close_reason := p4_a42;
    ddp_header_rec.close_competitor_code := p4_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p4_a44);
    ddp_header_rec.close_competitor := p4_a45;
    ddp_header_rec.close_comment := p4_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p4_a47);
    ddp_header_rec.end_user_customer_name := p4_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p4_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p4_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p4_a51);
    ddp_header_rec.parent_project := p4_a52;
    ddp_header_rec.parent_project_code := p4_a53;
    ddp_header_rec.updateable_flag := p4_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p4_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p4_a56);
    ddp_header_rec.rank := p4_a57;
    ddp_header_rec.member_access := p4_a58;
    ddp_header_rec.member_role := p4_a59;
    ddp_header_rec.deleted_flag := p4_a60;
    ddp_header_rec.auto_assignment_type := p4_a61;
    ddp_header_rec.prm_assignment_type := p4_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p4_a63);
    ddp_header_rec.methodology_code := p4_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p4_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p4_a66);
    ddp_header_rec.decision_timeframe_code := p4_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p4_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p4_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p4_a70);
    ddp_header_rec.vehicle_response_code := p4_a71;
    ddp_header_rec.budget_status_code := p4_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p4_a73);
    ddp_header_rec.no_opp_allowed_flag := p4_a74;
    ddp_header_rec.delete_allowed_flag := p4_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p4_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p4_a77;
    ddp_header_rec.prm_ind_classification_code := p4_a78;
    ddp_header_rec.prm_lead_type := p4_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p4_a80);
    ddp_header_rec.freeze_flag := p4_a81;
    ddp_header_rec.attribute_category := p4_a82;
    ddp_header_rec.attribute1 := p4_a83;
    ddp_header_rec.attribute2 := p4_a84;
    ddp_header_rec.attribute3 := p4_a85;
    ddp_header_rec.attribute4 := p4_a86;
    ddp_header_rec.attribute5 := p4_a87;
    ddp_header_rec.attribute6 := p4_a88;
    ddp_header_rec.attribute7 := p4_a89;
    ddp_header_rec.attribute8 := p4_a90;
    ddp_header_rec.attribute9 := p4_a91;
    ddp_header_rec.attribute10 := p4_a92;
    ddp_header_rec.attribute11 := p4_a93;
    ddp_header_rec.attribute12 := p4_a94;
    ddp_header_rec.attribute13 := p4_a95;
    ddp_header_rec.attribute14 := p4_a96;
    ddp_header_rec.attribute15 := p4_a97;
    ddp_header_rec.prm_referral_code := p4_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p4_a99);







    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p11_a0
      , p11_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.create_opp_header(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_salesgroup_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_lead_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure update_opp_header(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_lead_id out nocopy  NUMBER
    , p4_a0  DATE := fnd_api.g_miss_date
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  DATE := fnd_api.g_miss_date
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  NUMBER := 0-1962.0724
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  NUMBER := 0-1962.0724
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  NUMBER := 0-1962.0724
    , p4_a50  NUMBER := 0-1962.0724
    , p4_a51  NUMBER := 0-1962.0724
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  NUMBER := 0-1962.0724
    , p4_a56  NUMBER := 0-1962.0724
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  NUMBER := 0-1962.0724
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  NUMBER := 0-1962.0724
    , p4_a67  VARCHAR2 := fnd_api.g_miss_char
    , p4_a68  NUMBER := 0-1962.0724
    , p4_a69  NUMBER := 0-1962.0724
    , p4_a70  NUMBER := 0-1962.0724
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  VARCHAR2 := fnd_api.g_miss_char
    , p4_a73  DATE := fnd_api.g_miss_date
    , p4_a74  VARCHAR2 := fnd_api.g_miss_char
    , p4_a75  VARCHAR2 := fnd_api.g_miss_char
    , p4_a76  VARCHAR2 := fnd_api.g_miss_char
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  VARCHAR2 := fnd_api.g_miss_char
    , p4_a82  VARCHAR2 := fnd_api.g_miss_char
    , p4_a83  VARCHAR2 := fnd_api.g_miss_char
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  VARCHAR2 := fnd_api.g_miss_char
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  VARCHAR2 := fnd_api.g_miss_char
    , p4_a90  VARCHAR2 := fnd_api.g_miss_char
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  VARCHAR2 := fnd_api.g_miss_char
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  VARCHAR2 := fnd_api.g_miss_char
    , p4_a95  VARCHAR2 := fnd_api.g_miss_char
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p4_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p4_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p4_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p4_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p4_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p4_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p4_a9);
    ddp_header_rec.lead_number := p4_a10;
    ddp_header_rec.orig_system_reference := p4_a11;
    ddp_header_rec.lead_source_code := p4_a12;
    ddp_header_rec.lead_source := p4_a13;
    ddp_header_rec.description := p4_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p4_a15);
    ddp_header_rec.source_promotion_code := p4_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p4_a17);
    ddp_header_rec.customer_name := p4_a18;
    ddp_header_rec.customer_name_phonetic := p4_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p4_a20);
    ddp_header_rec.address := p4_a21;
    ddp_header_rec.address2 := p4_a22;
    ddp_header_rec.address3 := p4_a23;
    ddp_header_rec.address4 := p4_a24;
    ddp_header_rec.city := p4_a25;
    ddp_header_rec.state := p4_a26;
    ddp_header_rec.country := p4_a27;
    ddp_header_rec.province := p4_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p4_a29);
    ddp_header_rec.sales_stage := p4_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p4_a31);
    ddp_header_rec.status_code := p4_a32;
    ddp_header_rec.status := p4_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p4_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p4_a35);
    ddp_header_rec.channel_code := p4_a36;
    ddp_header_rec.channel := p4_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p4_a38);
    ddp_header_rec.currency_code := p4_a39;
    ddp_header_rec.to_currency_code := p4_a40;
    ddp_header_rec.close_reason_code := p4_a41;
    ddp_header_rec.close_reason := p4_a42;
    ddp_header_rec.close_competitor_code := p4_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p4_a44);
    ddp_header_rec.close_competitor := p4_a45;
    ddp_header_rec.close_comment := p4_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p4_a47);
    ddp_header_rec.end_user_customer_name := p4_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p4_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p4_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p4_a51);
    ddp_header_rec.parent_project := p4_a52;
    ddp_header_rec.parent_project_code := p4_a53;
    ddp_header_rec.updateable_flag := p4_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p4_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p4_a56);
    ddp_header_rec.rank := p4_a57;
    ddp_header_rec.member_access := p4_a58;
    ddp_header_rec.member_role := p4_a59;
    ddp_header_rec.deleted_flag := p4_a60;
    ddp_header_rec.auto_assignment_type := p4_a61;
    ddp_header_rec.prm_assignment_type := p4_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p4_a63);
    ddp_header_rec.methodology_code := p4_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p4_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p4_a66);
    ddp_header_rec.decision_timeframe_code := p4_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p4_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p4_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p4_a70);
    ddp_header_rec.vehicle_response_code := p4_a71;
    ddp_header_rec.budget_status_code := p4_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p4_a73);
    ddp_header_rec.no_opp_allowed_flag := p4_a74;
    ddp_header_rec.delete_allowed_flag := p4_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p4_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p4_a77;
    ddp_header_rec.prm_ind_classification_code := p4_a78;
    ddp_header_rec.prm_lead_type := p4_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p4_a80);
    ddp_header_rec.freeze_flag := p4_a81;
    ddp_header_rec.attribute_category := p4_a82;
    ddp_header_rec.attribute1 := p4_a83;
    ddp_header_rec.attribute2 := p4_a84;
    ddp_header_rec.attribute3 := p4_a85;
    ddp_header_rec.attribute4 := p4_a86;
    ddp_header_rec.attribute5 := p4_a87;
    ddp_header_rec.attribute6 := p4_a88;
    ddp_header_rec.attribute7 := p4_a89;
    ddp_header_rec.attribute8 := p4_a90;
    ddp_header_rec.attribute9 := p4_a91;
    ddp_header_rec.attribute10 := p4_a92;
    ddp_header_rec.attribute11 := p4_a93;
    ddp_header_rec.attribute12 := p4_a94;
    ddp_header_rec.attribute13 := p4_a95;
    ddp_header_rec.attribute14 := p4_a96;
    ddp_header_rec.attribute15 := p4_a97;
    ddp_header_rec.prm_referral_code := p4_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p4_a99);






    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_opp_header(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_lead_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure delete_opp_header(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_lead_id out nocopy  NUMBER
    , p4_a0  DATE := fnd_api.g_miss_date
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  DATE := fnd_api.g_miss_date
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  NUMBER := 0-1962.0724
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  NUMBER := 0-1962.0724
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  NUMBER := 0-1962.0724
    , p4_a50  NUMBER := 0-1962.0724
    , p4_a51  NUMBER := 0-1962.0724
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  NUMBER := 0-1962.0724
    , p4_a56  NUMBER := 0-1962.0724
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  NUMBER := 0-1962.0724
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  NUMBER := 0-1962.0724
    , p4_a67  VARCHAR2 := fnd_api.g_miss_char
    , p4_a68  NUMBER := 0-1962.0724
    , p4_a69  NUMBER := 0-1962.0724
    , p4_a70  NUMBER := 0-1962.0724
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  VARCHAR2 := fnd_api.g_miss_char
    , p4_a73  DATE := fnd_api.g_miss_date
    , p4_a74  VARCHAR2 := fnd_api.g_miss_char
    , p4_a75  VARCHAR2 := fnd_api.g_miss_char
    , p4_a76  VARCHAR2 := fnd_api.g_miss_char
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  VARCHAR2 := fnd_api.g_miss_char
    , p4_a82  VARCHAR2 := fnd_api.g_miss_char
    , p4_a83  VARCHAR2 := fnd_api.g_miss_char
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  VARCHAR2 := fnd_api.g_miss_char
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  VARCHAR2 := fnd_api.g_miss_char
    , p4_a90  VARCHAR2 := fnd_api.g_miss_char
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  VARCHAR2 := fnd_api.g_miss_char
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  VARCHAR2 := fnd_api.g_miss_char
    , p4_a95  VARCHAR2 := fnd_api.g_miss_char
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p4_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p4_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p4_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p4_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p4_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p4_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p4_a9);
    ddp_header_rec.lead_number := p4_a10;
    ddp_header_rec.orig_system_reference := p4_a11;
    ddp_header_rec.lead_source_code := p4_a12;
    ddp_header_rec.lead_source := p4_a13;
    ddp_header_rec.description := p4_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p4_a15);
    ddp_header_rec.source_promotion_code := p4_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p4_a17);
    ddp_header_rec.customer_name := p4_a18;
    ddp_header_rec.customer_name_phonetic := p4_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p4_a20);
    ddp_header_rec.address := p4_a21;
    ddp_header_rec.address2 := p4_a22;
    ddp_header_rec.address3 := p4_a23;
    ddp_header_rec.address4 := p4_a24;
    ddp_header_rec.city := p4_a25;
    ddp_header_rec.state := p4_a26;
    ddp_header_rec.country := p4_a27;
    ddp_header_rec.province := p4_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p4_a29);
    ddp_header_rec.sales_stage := p4_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p4_a31);
    ddp_header_rec.status_code := p4_a32;
    ddp_header_rec.status := p4_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p4_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p4_a35);
    ddp_header_rec.channel_code := p4_a36;
    ddp_header_rec.channel := p4_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p4_a38);
    ddp_header_rec.currency_code := p4_a39;
    ddp_header_rec.to_currency_code := p4_a40;
    ddp_header_rec.close_reason_code := p4_a41;
    ddp_header_rec.close_reason := p4_a42;
    ddp_header_rec.close_competitor_code := p4_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p4_a44);
    ddp_header_rec.close_competitor := p4_a45;
    ddp_header_rec.close_comment := p4_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p4_a47);
    ddp_header_rec.end_user_customer_name := p4_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p4_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p4_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p4_a51);
    ddp_header_rec.parent_project := p4_a52;
    ddp_header_rec.parent_project_code := p4_a53;
    ddp_header_rec.updateable_flag := p4_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p4_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p4_a56);
    ddp_header_rec.rank := p4_a57;
    ddp_header_rec.member_access := p4_a58;
    ddp_header_rec.member_role := p4_a59;
    ddp_header_rec.deleted_flag := p4_a60;
    ddp_header_rec.auto_assignment_type := p4_a61;
    ddp_header_rec.prm_assignment_type := p4_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p4_a63);
    ddp_header_rec.methodology_code := p4_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p4_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p4_a66);
    ddp_header_rec.decision_timeframe_code := p4_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p4_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p4_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p4_a70);
    ddp_header_rec.vehicle_response_code := p4_a71;
    ddp_header_rec.budget_status_code := p4_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p4_a73);
    ddp_header_rec.no_opp_allowed_flag := p4_a74;
    ddp_header_rec.delete_allowed_flag := p4_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p4_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p4_a77;
    ddp_header_rec.prm_ind_classification_code := p4_a78;
    ddp_header_rec.prm_lead_type := p4_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p4_a80);
    ddp_header_rec.freeze_flag := p4_a81;
    ddp_header_rec.attribute_category := p4_a82;
    ddp_header_rec.attribute1 := p4_a83;
    ddp_header_rec.attribute2 := p4_a84;
    ddp_header_rec.attribute3 := p4_a85;
    ddp_header_rec.attribute4 := p4_a86;
    ddp_header_rec.attribute5 := p4_a87;
    ddp_header_rec.attribute6 := p4_a88;
    ddp_header_rec.attribute7 := p4_a89;
    ddp_header_rec.attribute8 := p4_a90;
    ddp_header_rec.attribute9 := p4_a91;
    ddp_header_rec.attribute10 := p4_a92;
    ddp_header_rec.attribute11 := p4_a93;
    ddp_header_rec.attribute12 := p4_a94;
    ddp_header_rec.attribute13 := p4_a95;
    ddp_header_rec.attribute14 := p4_a96;
    ddp_header_rec.attribute15 := p4_a97;
    ddp_header_rec.prm_referral_code := p4_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p4_a99);






    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_opp_header(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_lead_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure create_opp_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_DATE_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_VARCHAR2_TABLE_2000
    , p4_a21 JTF_NUMBER_TABLE
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_DATE_TABLE
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_VARCHAR2_TABLE_100
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_DATE_TABLE
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_NUMBER_TABLE
    , p4_a36 JTF_NUMBER_TABLE
    , p4_a37 JTF_NUMBER_TABLE
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_NUMBER_TABLE
    , p4_a43 JTF_NUMBER_TABLE
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_NUMBER_TABLE
    , p4_a47 JTF_NUMBER_TABLE
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_NUMBER_TABLE
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_NUMBER_TABLE
    , p4_a67 JTF_NUMBER_TABLE
    , p4_a68 JTF_NUMBER_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_salesgroup_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p12_a0 JTF_VARCHAR2_TABLE_100
    , p12_a1 JTF_VARCHAR2_TABLE_300
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  DATE := fnd_api.g_miss_date
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  VARCHAR2 := fnd_api.g_miss_char
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  VARCHAR2 := fnd_api.g_miss_char
    , p5_a95  VARCHAR2 := fnd_api.g_miss_char
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  VARCHAR2 := fnd_api.g_miss_char
    , p5_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_line_tbl as_opportunity_pub.line_tbl_type;
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_line_out_tbl as_opportunity_pub.line_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    as_opportunity_pub_w.rosetta_table_copy_in_p6(ddp_line_tbl, p4_a0
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
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      );

    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p5_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p5_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p5_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p5_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p5_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p5_a9);
    ddp_header_rec.lead_number := p5_a10;
    ddp_header_rec.orig_system_reference := p5_a11;
    ddp_header_rec.lead_source_code := p5_a12;
    ddp_header_rec.lead_source := p5_a13;
    ddp_header_rec.description := p5_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p5_a15);
    ddp_header_rec.source_promotion_code := p5_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p5_a17);
    ddp_header_rec.customer_name := p5_a18;
    ddp_header_rec.customer_name_phonetic := p5_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p5_a20);
    ddp_header_rec.address := p5_a21;
    ddp_header_rec.address2 := p5_a22;
    ddp_header_rec.address3 := p5_a23;
    ddp_header_rec.address4 := p5_a24;
    ddp_header_rec.city := p5_a25;
    ddp_header_rec.state := p5_a26;
    ddp_header_rec.country := p5_a27;
    ddp_header_rec.province := p5_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p5_a29);
    ddp_header_rec.sales_stage := p5_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p5_a31);
    ddp_header_rec.status_code := p5_a32;
    ddp_header_rec.status := p5_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p5_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p5_a35);
    ddp_header_rec.channel_code := p5_a36;
    ddp_header_rec.channel := p5_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_header_rec.currency_code := p5_a39;
    ddp_header_rec.to_currency_code := p5_a40;
    ddp_header_rec.close_reason_code := p5_a41;
    ddp_header_rec.close_reason := p5_a42;
    ddp_header_rec.close_competitor_code := p5_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p5_a44);
    ddp_header_rec.close_competitor := p5_a45;
    ddp_header_rec.close_comment := p5_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p5_a47);
    ddp_header_rec.end_user_customer_name := p5_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p5_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p5_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p5_a51);
    ddp_header_rec.parent_project := p5_a52;
    ddp_header_rec.parent_project_code := p5_a53;
    ddp_header_rec.updateable_flag := p5_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p5_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p5_a56);
    ddp_header_rec.rank := p5_a57;
    ddp_header_rec.member_access := p5_a58;
    ddp_header_rec.member_role := p5_a59;
    ddp_header_rec.deleted_flag := p5_a60;
    ddp_header_rec.auto_assignment_type := p5_a61;
    ddp_header_rec.prm_assignment_type := p5_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p5_a63);
    ddp_header_rec.methodology_code := p5_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p5_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p5_a66);
    ddp_header_rec.decision_timeframe_code := p5_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p5_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p5_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p5_a70);
    ddp_header_rec.vehicle_response_code := p5_a71;
    ddp_header_rec.budget_status_code := p5_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_header_rec.no_opp_allowed_flag := p5_a74;
    ddp_header_rec.delete_allowed_flag := p5_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p5_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p5_a77;
    ddp_header_rec.prm_ind_classification_code := p5_a78;
    ddp_header_rec.prm_lead_type := p5_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p5_a80);
    ddp_header_rec.freeze_flag := p5_a81;
    ddp_header_rec.attribute_category := p5_a82;
    ddp_header_rec.attribute1 := p5_a83;
    ddp_header_rec.attribute2 := p5_a84;
    ddp_header_rec.attribute3 := p5_a85;
    ddp_header_rec.attribute4 := p5_a86;
    ddp_header_rec.attribute5 := p5_a87;
    ddp_header_rec.attribute6 := p5_a88;
    ddp_header_rec.attribute7 := p5_a89;
    ddp_header_rec.attribute8 := p5_a90;
    ddp_header_rec.attribute9 := p5_a91;
    ddp_header_rec.attribute10 := p5_a92;
    ddp_header_rec.attribute11 := p5_a93;
    ddp_header_rec.attribute12 := p5_a94;
    ddp_header_rec.attribute13 := p5_a95;
    ddp_header_rec.attribute14 := p5_a96;
    ddp_header_rec.attribute15 := p5_a97;
    ddp_header_rec.prm_referral_code := p5_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p5_a99);







    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p12_a0
      , p12_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.create_opp_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_line_tbl,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_salesgroup_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_line_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    as_opportunity_pub_w.rosetta_table_copy_out_p9(ddx_line_out_tbl, p13_a0
      , p13_a1
      );



  end;

  procedure update_opp_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_2000
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_VARCHAR2_TABLE_200
    , p5_a57 JTF_VARCHAR2_TABLE_200
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p5_a63 JTF_VARCHAR2_TABLE_200
    , p5_a64 JTF_VARCHAR2_TABLE_200
    , p5_a65 JTF_VARCHAR2_TABLE_200
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_VARCHAR2_TABLE_300
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  DATE := fnd_api.g_miss_date
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  DATE := fnd_api.g_miss_date
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  NUMBER := 0-1962.0724
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  DATE := fnd_api.g_miss_date
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  VARCHAR2 := fnd_api.g_miss_char
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  VARCHAR2 := fnd_api.g_miss_char
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_line_tbl as_opportunity_pub.line_tbl_type;
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_line_out_tbl as_opportunity_pub.line_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p6(ddp_line_tbl, p5_a0
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
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      );

    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p6_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p6_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p6_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p6_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p6_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p6_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p6_a9);
    ddp_header_rec.lead_number := p6_a10;
    ddp_header_rec.orig_system_reference := p6_a11;
    ddp_header_rec.lead_source_code := p6_a12;
    ddp_header_rec.lead_source := p6_a13;
    ddp_header_rec.description := p6_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p6_a15);
    ddp_header_rec.source_promotion_code := p6_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p6_a17);
    ddp_header_rec.customer_name := p6_a18;
    ddp_header_rec.customer_name_phonetic := p6_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p6_a20);
    ddp_header_rec.address := p6_a21;
    ddp_header_rec.address2 := p6_a22;
    ddp_header_rec.address3 := p6_a23;
    ddp_header_rec.address4 := p6_a24;
    ddp_header_rec.city := p6_a25;
    ddp_header_rec.state := p6_a26;
    ddp_header_rec.country := p6_a27;
    ddp_header_rec.province := p6_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p6_a29);
    ddp_header_rec.sales_stage := p6_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p6_a31);
    ddp_header_rec.status_code := p6_a32;
    ddp_header_rec.status := p6_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p6_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p6_a35);
    ddp_header_rec.channel_code := p6_a36;
    ddp_header_rec.channel := p6_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p6_a38);
    ddp_header_rec.currency_code := p6_a39;
    ddp_header_rec.to_currency_code := p6_a40;
    ddp_header_rec.close_reason_code := p6_a41;
    ddp_header_rec.close_reason := p6_a42;
    ddp_header_rec.close_competitor_code := p6_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p6_a44);
    ddp_header_rec.close_competitor := p6_a45;
    ddp_header_rec.close_comment := p6_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p6_a47);
    ddp_header_rec.end_user_customer_name := p6_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p6_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p6_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p6_a51);
    ddp_header_rec.parent_project := p6_a52;
    ddp_header_rec.parent_project_code := p6_a53;
    ddp_header_rec.updateable_flag := p6_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p6_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p6_a56);
    ddp_header_rec.rank := p6_a57;
    ddp_header_rec.member_access := p6_a58;
    ddp_header_rec.member_role := p6_a59;
    ddp_header_rec.deleted_flag := p6_a60;
    ddp_header_rec.auto_assignment_type := p6_a61;
    ddp_header_rec.prm_assignment_type := p6_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p6_a63);
    ddp_header_rec.methodology_code := p6_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p6_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p6_a66);
    ddp_header_rec.decision_timeframe_code := p6_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p6_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p6_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p6_a70);
    ddp_header_rec.vehicle_response_code := p6_a71;
    ddp_header_rec.budget_status_code := p6_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p6_a73);
    ddp_header_rec.no_opp_allowed_flag := p6_a74;
    ddp_header_rec.delete_allowed_flag := p6_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p6_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p6_a77;
    ddp_header_rec.prm_ind_classification_code := p6_a78;
    ddp_header_rec.prm_lead_type := p6_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p6_a80);
    ddp_header_rec.freeze_flag := p6_a81;
    ddp_header_rec.attribute_category := p6_a82;
    ddp_header_rec.attribute1 := p6_a83;
    ddp_header_rec.attribute2 := p6_a84;
    ddp_header_rec.attribute3 := p6_a85;
    ddp_header_rec.attribute4 := p6_a86;
    ddp_header_rec.attribute5 := p6_a87;
    ddp_header_rec.attribute6 := p6_a88;
    ddp_header_rec.attribute7 := p6_a89;
    ddp_header_rec.attribute8 := p6_a90;
    ddp_header_rec.attribute9 := p6_a91;
    ddp_header_rec.attribute10 := p6_a92;
    ddp_header_rec.attribute11 := p6_a93;
    ddp_header_rec.attribute12 := p6_a94;
    ddp_header_rec.attribute13 := p6_a95;
    ddp_header_rec.attribute14 := p6_a96;
    ddp_header_rec.attribute15 := p6_a97;
    ddp_header_rec.prm_referral_code := p6_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p6_a99);





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p11_a0
      , p11_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_opp_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_line_tbl,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_line_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    as_opportunity_pub_w.rosetta_table_copy_out_p9(ddx_line_out_tbl, p12_a0
      , p12_a1
      );



  end;

  procedure delete_opp_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_2000
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_VARCHAR2_TABLE_200
    , p5_a57 JTF_VARCHAR2_TABLE_200
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p5_a63 JTF_VARCHAR2_TABLE_200
    , p5_a64 JTF_VARCHAR2_TABLE_200
    , p5_a65 JTF_VARCHAR2_TABLE_200
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_VARCHAR2_TABLE_300
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  DATE := fnd_api.g_miss_date
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  DATE := fnd_api.g_miss_date
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  NUMBER := 0-1962.0724
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  DATE := fnd_api.g_miss_date
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  VARCHAR2 := fnd_api.g_miss_char
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  VARCHAR2 := fnd_api.g_miss_char
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  NUMBER := 0-1962.0724
  )

  as
    ddp_line_tbl as_opportunity_pub.line_tbl_type;
    ddp_header_rec as_opportunity_pub.header_rec_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_line_out_tbl as_opportunity_pub.line_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p6(ddp_line_tbl, p5_a0
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
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      );

    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a0);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p6_a1);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p6_a3);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p6_a4);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p6_a5);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p6_a6);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p6_a7);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_header_rec.lead_id := rosetta_g_miss_num_map(p6_a9);
    ddp_header_rec.lead_number := p6_a10;
    ddp_header_rec.orig_system_reference := p6_a11;
    ddp_header_rec.lead_source_code := p6_a12;
    ddp_header_rec.lead_source := p6_a13;
    ddp_header_rec.description := p6_a14;
    ddp_header_rec.source_promotion_id := rosetta_g_miss_num_map(p6_a15);
    ddp_header_rec.source_promotion_code := p6_a16;
    ddp_header_rec.customer_id := rosetta_g_miss_num_map(p6_a17);
    ddp_header_rec.customer_name := p6_a18;
    ddp_header_rec.customer_name_phonetic := p6_a19;
    ddp_header_rec.address_id := rosetta_g_miss_num_map(p6_a20);
    ddp_header_rec.address := p6_a21;
    ddp_header_rec.address2 := p6_a22;
    ddp_header_rec.address3 := p6_a23;
    ddp_header_rec.address4 := p6_a24;
    ddp_header_rec.city := p6_a25;
    ddp_header_rec.state := p6_a26;
    ddp_header_rec.country := p6_a27;
    ddp_header_rec.province := p6_a28;
    ddp_header_rec.sales_stage_id := rosetta_g_miss_num_map(p6_a29);
    ddp_header_rec.sales_stage := p6_a30;
    ddp_header_rec.win_probability := rosetta_g_miss_num_map(p6_a31);
    ddp_header_rec.status_code := p6_a32;
    ddp_header_rec.status := p6_a33;
    ddp_header_rec.total_amount := rosetta_g_miss_num_map(p6_a34);
    ddp_header_rec.converted_total_amount := rosetta_g_miss_num_map(p6_a35);
    ddp_header_rec.channel_code := p6_a36;
    ddp_header_rec.channel := p6_a37;
    ddp_header_rec.decision_date := rosetta_g_miss_date_in_map(p6_a38);
    ddp_header_rec.currency_code := p6_a39;
    ddp_header_rec.to_currency_code := p6_a40;
    ddp_header_rec.close_reason_code := p6_a41;
    ddp_header_rec.close_reason := p6_a42;
    ddp_header_rec.close_competitor_code := p6_a43;
    ddp_header_rec.close_competitor_id := rosetta_g_miss_num_map(p6_a44);
    ddp_header_rec.close_competitor := p6_a45;
    ddp_header_rec.close_comment := p6_a46;
    ddp_header_rec.end_user_customer_id := rosetta_g_miss_num_map(p6_a47);
    ddp_header_rec.end_user_customer_name := p6_a48;
    ddp_header_rec.end_user_address_id := rosetta_g_miss_num_map(p6_a49);
    ddp_header_rec.owner_salesforce_id := rosetta_g_miss_num_map(p6_a50);
    ddp_header_rec.owner_sales_group_id := rosetta_g_miss_num_map(p6_a51);
    ddp_header_rec.parent_project := p6_a52;
    ddp_header_rec.parent_project_code := p6_a53;
    ddp_header_rec.updateable_flag := p6_a54;
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p6_a55);
    ddp_header_rec.initiating_contact_id := rosetta_g_miss_num_map(p6_a56);
    ddp_header_rec.rank := p6_a57;
    ddp_header_rec.member_access := p6_a58;
    ddp_header_rec.member_role := p6_a59;
    ddp_header_rec.deleted_flag := p6_a60;
    ddp_header_rec.auto_assignment_type := p6_a61;
    ddp_header_rec.prm_assignment_type := p6_a62;
    ddp_header_rec.customer_budget := rosetta_g_miss_num_map(p6_a63);
    ddp_header_rec.methodology_code := p6_a64;
    ddp_header_rec.sales_methodology_id := rosetta_g_miss_num_map(p6_a65);
    ddp_header_rec.original_lead_id := rosetta_g_miss_num_map(p6_a66);
    ddp_header_rec.decision_timeframe_code := p6_a67;
    ddp_header_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p6_a68);
    ddp_header_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p6_a69);
    ddp_header_rec.offer_id := rosetta_g_miss_num_map(p6_a70);
    ddp_header_rec.vehicle_response_code := p6_a71;
    ddp_header_rec.budget_status_code := p6_a72;
    ddp_header_rec.followup_date := rosetta_g_miss_date_in_map(p6_a73);
    ddp_header_rec.no_opp_allowed_flag := p6_a74;
    ddp_header_rec.delete_allowed_flag := p6_a75;
    ddp_header_rec.prm_exec_sponsor_flag := p6_a76;
    ddp_header_rec.prm_prj_lead_in_place_flag := p6_a77;
    ddp_header_rec.prm_ind_classification_code := p6_a78;
    ddp_header_rec.prm_lead_type := p6_a79;
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p6_a80);
    ddp_header_rec.freeze_flag := p6_a81;
    ddp_header_rec.attribute_category := p6_a82;
    ddp_header_rec.attribute1 := p6_a83;
    ddp_header_rec.attribute2 := p6_a84;
    ddp_header_rec.attribute3 := p6_a85;
    ddp_header_rec.attribute4 := p6_a86;
    ddp_header_rec.attribute5 := p6_a87;
    ddp_header_rec.attribute6 := p6_a88;
    ddp_header_rec.attribute7 := p6_a89;
    ddp_header_rec.attribute8 := p6_a90;
    ddp_header_rec.attribute9 := p6_a91;
    ddp_header_rec.attribute10 := p6_a92;
    ddp_header_rec.attribute11 := p6_a93;
    ddp_header_rec.attribute12 := p6_a94;
    ddp_header_rec.attribute13 := p6_a95;
    ddp_header_rec.attribute14 := p6_a96;
    ddp_header_rec.attribute15 := p6_a97;
    ddp_header_rec.prm_referral_code := p6_a98;
    ddp_header_rec.total_revenue_opp_forecast_amt := rosetta_g_miss_num_map(p6_a99);





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p11_a0
      , p11_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_opp_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_line_tbl,
      ddp_header_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_line_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    as_opportunity_pub_w.rosetta_table_copy_out_p9(ddx_line_out_tbl, p12_a0
      , p12_a1
      );



  end;

  procedure create_sales_credits(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_400
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_200
    , p5_a43 JTF_VARCHAR2_TABLE_200
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_VARCHAR2_TABLE_200
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_VARCHAR2_TABLE_200
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_VARCHAR2_TABLE_200
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_VARCHAR2_TABLE_200
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_credit_tbl as_opportunity_pub.sales_credit_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_sales_credit_out_tbl as_opportunity_pub.sales_credit_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p12(ddp_sales_credit_tbl, p5_a0
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
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.create_sales_credits(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_sales_credit_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_sales_credit_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p15(ddx_sales_credit_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure update_sales_credits(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_400
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_200
    , p5_a43 JTF_VARCHAR2_TABLE_200
    , p5_a44 JTF_VARCHAR2_TABLE_200
    , p5_a45 JTF_VARCHAR2_TABLE_200
    , p5_a46 JTF_VARCHAR2_TABLE_200
    , p5_a47 JTF_VARCHAR2_TABLE_200
    , p5_a48 JTF_VARCHAR2_TABLE_200
    , p5_a49 JTF_VARCHAR2_TABLE_200
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_VARCHAR2_TABLE_200
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_credit_tbl as_opportunity_pub.sales_credit_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_sales_credit_out_tbl as_opportunity_pub.sales_credit_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p12(ddp_sales_credit_tbl, p5_a0
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
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_sales_credits(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_sales_credit_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_sales_credit_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p15(ddx_sales_credit_out_tbl, p11_a0
      , p11_a1
      );



  end;

end as_opportunity_pub_w;

/
