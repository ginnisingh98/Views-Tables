--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEADS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEADS_PUB_W" as
  /* $Header: asxwslmb.pls 115.14 2003/09/18 22:44:07 ckapoor ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy as_sales_leads_pub.sales_lead_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_100
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
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_DATE_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sales_lead_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).lead_number := a10(indx);
          t(ddindx).status_code := a11(indx);
          t(ddindx).customer_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).address_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).source_promotion_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).initiating_contact_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).orig_system_reference := a16(indx);
          t(ddindx).contact_role_code := a17(indx);
          t(ddindx).channel_code := a18(indx);
          t(ddindx).budget_amount := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).currency_code := a20(indx);
          t(ddindx).decision_timeframe_code := a21(indx);
          t(ddindx).close_reason := a22(indx);
          t(ddindx).lead_rank_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).lead_rank_code := a24(indx);
          t(ddindx).parent_project := a25(indx);
          t(ddindx).description := a26(indx);
          t(ddindx).attribute_category := a27(indx);
          t(ddindx).attribute1 := a28(indx);
          t(ddindx).attribute2 := a29(indx);
          t(ddindx).attribute3 := a30(indx);
          t(ddindx).attribute4 := a31(indx);
          t(ddindx).attribute5 := a32(indx);
          t(ddindx).attribute6 := a33(indx);
          t(ddindx).attribute7 := a34(indx);
          t(ddindx).attribute8 := a35(indx);
          t(ddindx).attribute9 := a36(indx);
          t(ddindx).attribute10 := a37(indx);
          t(ddindx).attribute11 := a38(indx);
          t(ddindx).attribute12 := a39(indx);
          t(ddindx).attribute13 := a40(indx);
          t(ddindx).attribute14 := a41(indx);
          t(ddindx).attribute15 := a42(indx);
          t(ddindx).assign_to_person_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).assign_to_salesforce_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).assign_sales_group_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).assign_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).budget_status_code := a47(indx);
          t(ddindx).accept_flag := a48(indx);
          t(ddindx).vehicle_response_code := a49(indx);
          t(ddindx).total_score := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).scorecard_id := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).keep_flag := a52(indx);
          t(ddindx).urgent_flag := a53(indx);
          t(ddindx).import_flag := a54(indx);
          t(ddindx).reject_reason_code := a55(indx);
          t(ddindx).deleted_flag := a56(indx);
          t(ddindx).offer_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).incumbent_partner_party_id := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).incumbent_partner_resource_id := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).prm_exec_sponsor_flag := a60(indx);
          t(ddindx).prm_prj_lead_in_place_flag := a61(indx);
          t(ddindx).prm_sales_lead_type := a62(indx);
          t(ddindx).prm_ind_classification_code := a63(indx);
          t(ddindx).qualified_flag := a64(indx);
          t(ddindx).orig_system_code := a65(indx);
          t(ddindx).prm_assignment_type := a66(indx);
          t(ddindx).auto_assignment_type := a67(indx);
          t(ddindx).primary_contact_party_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).primary_cnt_person_party_id := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).primary_contact_phone_id := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).referred_by := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).referral_type := a72(indx);
          t(ddindx).referral_status := a73(indx);
          t(ddindx).ref_decline_reason := a74(indx);
          t(ddindx).ref_comm_ltr_status := a75(indx);
          t(ddindx).ref_order_number := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).ref_order_amt := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).ref_comm_amt := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).lead_date := rosetta_g_miss_date_in_map(a79(indx));
          t(ddindx).source_system := a80(indx);
          t(ddindx).country := a81(indx);
          t(ddindx).total_amount := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a83(indx));
          t(ddindx).lead_engine_run_date := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).lead_rank_ind := a85(indx);
          t(ddindx).current_reroutes := rosetta_g_miss_num_map(a86(indx));
          t(ddindx).marketing_score := rosetta_g_miss_num_map(a87(indx));
          t(ddindx).interaction_score := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).source_primary_reference := a89(indx);
          t(ddindx).source_secondary_reference := a90(indx);
          t(ddindx).sales_methodology_id := rosetta_g_miss_num_map(a91(indx));
          t(ddindx).sales_stage_id := rosetta_g_miss_num_map(a92(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t as_sales_leads_pub.sales_lead_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_2000();
    a27 := JTF_VARCHAR2_TABLE_100();
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
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_DATE_TABLE();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_DATE_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_VARCHAR2_TABLE_100();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_2000();
      a27 := JTF_VARCHAR2_TABLE_100();
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
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_DATE_TABLE();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_DATE_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_VARCHAR2_TABLE_100();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).sales_lead_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a9(indx) := t(ddindx).program_update_date;
          a10(indx) := t(ddindx).lead_number;
          a11(indx) := t(ddindx).status_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).address_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).source_promotion_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).initiating_contact_id);
          a16(indx) := t(ddindx).orig_system_reference;
          a17(indx) := t(ddindx).contact_role_code;
          a18(indx) := t(ddindx).channel_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).budget_amount);
          a20(indx) := t(ddindx).currency_code;
          a21(indx) := t(ddindx).decision_timeframe_code;
          a22(indx) := t(ddindx).close_reason;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).lead_rank_id);
          a24(indx) := t(ddindx).lead_rank_code;
          a25(indx) := t(ddindx).parent_project;
          a26(indx) := t(ddindx).description;
          a27(indx) := t(ddindx).attribute_category;
          a28(indx) := t(ddindx).attribute1;
          a29(indx) := t(ddindx).attribute2;
          a30(indx) := t(ddindx).attribute3;
          a31(indx) := t(ddindx).attribute4;
          a32(indx) := t(ddindx).attribute5;
          a33(indx) := t(ddindx).attribute6;
          a34(indx) := t(ddindx).attribute7;
          a35(indx) := t(ddindx).attribute8;
          a36(indx) := t(ddindx).attribute9;
          a37(indx) := t(ddindx).attribute10;
          a38(indx) := t(ddindx).attribute11;
          a39(indx) := t(ddindx).attribute12;
          a40(indx) := t(ddindx).attribute13;
          a41(indx) := t(ddindx).attribute14;
          a42(indx) := t(ddindx).attribute15;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).assign_to_person_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).assign_to_salesforce_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).assign_sales_group_id);
          a46(indx) := t(ddindx).assign_date;
          a47(indx) := t(ddindx).budget_status_code;
          a48(indx) := t(ddindx).accept_flag;
          a49(indx) := t(ddindx).vehicle_response_code;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).total_score);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).scorecard_id);
          a52(indx) := t(ddindx).keep_flag;
          a53(indx) := t(ddindx).urgent_flag;
          a54(indx) := t(ddindx).import_flag;
          a55(indx) := t(ddindx).reject_reason_code;
          a56(indx) := t(ddindx).deleted_flag;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).incumbent_partner_party_id);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).incumbent_partner_resource_id);
          a60(indx) := t(ddindx).prm_exec_sponsor_flag;
          a61(indx) := t(ddindx).prm_prj_lead_in_place_flag;
          a62(indx) := t(ddindx).prm_sales_lead_type;
          a63(indx) := t(ddindx).prm_ind_classification_code;
          a64(indx) := t(ddindx).qualified_flag;
          a65(indx) := t(ddindx).orig_system_code;
          a66(indx) := t(ddindx).prm_assignment_type;
          a67(indx) := t(ddindx).auto_assignment_type;
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).primary_contact_party_id);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).primary_cnt_person_party_id);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).primary_contact_phone_id);
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).referred_by);
          a72(indx) := t(ddindx).referral_type;
          a73(indx) := t(ddindx).referral_status;
          a74(indx) := t(ddindx).ref_decline_reason;
          a75(indx) := t(ddindx).ref_comm_ltr_status;
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).ref_order_number);
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).ref_order_amt);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).ref_comm_amt);
          a79(indx) := t(ddindx).lead_date;
          a80(indx) := t(ddindx).source_system;
          a81(indx) := t(ddindx).country;
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).total_amount);
          a83(indx) := t(ddindx).expiration_date;
          a84(indx) := t(ddindx).lead_engine_run_date;
          a85(indx) := t(ddindx).lead_rank_ind;
          a86(indx) := rosetta_g_miss_num_map(t(ddindx).current_reroutes);
          a87(indx) := rosetta_g_miss_num_map(t(ddindx).marketing_score);
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).interaction_score);
          a89(indx) := t(ddindx).source_primary_reference;
          a90(indx) := t(ddindx).source_secondary_reference;
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).sales_methodology_id);
          a92(indx) := rosetta_g_miss_num_map(t(ddindx).sales_stage_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy as_sales_leads_pub.sales_lead_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
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
    , a36 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sales_lead_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).sales_lead_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).status_code := a11(indx);
          t(ddindx).category_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).category_set_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).uom_code := a16(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).budget_amount := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).source_promotion_id := rosetta_g_miss_num_map(a19(indx));
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
          t(ddindx).offer_id := rosetta_g_miss_num_map(a36(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t as_sales_leads_pub.sales_lead_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
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
    , a36 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
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
    a36 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
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
      a36 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).sales_lead_line_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a9(indx) := t(ddindx).program_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).sales_lead_id);
          a11(indx) := t(ddindx).status_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).category_set_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a16(indx) := t(ddindx).uom_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).budget_amount);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).source_promotion_id);
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
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p10(t out nocopy as_sales_leads_pub.sales_lead_line_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sales_lead_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).return_status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t as_sales_leads_pub.sales_lead_line_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).sales_lead_line_id);
          a1(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p13(t out nocopy as_sales_leads_pub.sales_lead_contact_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
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
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_contact_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).sales_lead_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).contact_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).enabled_flag := a12(indx);
          t(ddindx).rank := a13(indx);
          t(ddindx).customer_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).address_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).phone_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).contact_role_code := a17(indx);
          t(ddindx).primary_contact_flag := a18(indx);
          t(ddindx).attribute_category := a19(indx);
          t(ddindx).attribute1 := a20(indx);
          t(ddindx).attribute2 := a21(indx);
          t(ddindx).attribute3 := a22(indx);
          t(ddindx).attribute4 := a23(indx);
          t(ddindx).attribute5 := a24(indx);
          t(ddindx).attribute6 := a25(indx);
          t(ddindx).attribute7 := a26(indx);
          t(ddindx).attribute8 := a27(indx);
          t(ddindx).attribute9 := a28(indx);
          t(ddindx).attribute10 := a29(indx);
          t(ddindx).attribute11 := a30(indx);
          t(ddindx).attribute12 := a31(indx);
          t(ddindx).attribute13 := a32(indx);
          t(ddindx).attribute14 := a33(indx);
          t(ddindx).attribute15 := a34(indx);
          t(ddindx).contact_party_id := rosetta_g_miss_num_map(a35(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t as_sales_leads_pub.sales_lead_contact_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
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
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
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
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_contact_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).sales_lead_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).contact_id);
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a5(indx) := t(ddindx).creation_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a11(indx) := t(ddindx).program_update_date;
          a12(indx) := t(ddindx).enabled_flag;
          a13(indx) := t(ddindx).rank;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).address_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).phone_id);
          a17(indx) := t(ddindx).contact_role_code;
          a18(indx) := t(ddindx).primary_contact_flag;
          a19(indx) := t(ddindx).attribute_category;
          a20(indx) := t(ddindx).attribute1;
          a21(indx) := t(ddindx).attribute2;
          a22(indx) := t(ddindx).attribute3;
          a23(indx) := t(ddindx).attribute4;
          a24(indx) := t(ddindx).attribute5;
          a25(indx) := t(ddindx).attribute6;
          a26(indx) := t(ddindx).attribute7;
          a27(indx) := t(ddindx).attribute8;
          a28(indx) := t(ddindx).attribute9;
          a29(indx) := t(ddindx).attribute10;
          a30(indx) := t(ddindx).attribute11;
          a31(indx) := t(ddindx).attribute12;
          a32(indx) := t(ddindx).attribute13;
          a33(indx) := t(ddindx).attribute14;
          a34(indx) := t(ddindx).attribute15;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).contact_party_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p16(t out nocopy as_sales_leads_pub.sales_lead_cnt_out_tbl_type, a0 JTF_NUMBER_TABLE
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
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t as_sales_leads_pub.sales_lead_cnt_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
  end rosetta_table_copy_out_p16;

  procedure rosetta_table_copy_in_p19(t out nocopy as_sales_leads_pub.assign_id_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).sales_group_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t as_sales_leads_pub.assign_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).sales_group_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure create_sales_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_DATE_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_DATE_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_NUMBER_TABLE
    , p10_a11 JTF_VARCHAR2_TABLE_100
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_NUMBER_TABLE
    , p10_a14 JTF_NUMBER_TABLE
    , p10_a15 JTF_NUMBER_TABLE
    , p10_a16 JTF_VARCHAR2_TABLE_100
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_NUMBER_TABLE
    , p10_a19 JTF_NUMBER_TABLE
    , p10_a20 JTF_VARCHAR2_TABLE_100
    , p10_a21 JTF_VARCHAR2_TABLE_200
    , p10_a22 JTF_VARCHAR2_TABLE_200
    , p10_a23 JTF_VARCHAR2_TABLE_200
    , p10_a24 JTF_VARCHAR2_TABLE_200
    , p10_a25 JTF_VARCHAR2_TABLE_200
    , p10_a26 JTF_VARCHAR2_TABLE_200
    , p10_a27 JTF_VARCHAR2_TABLE_200
    , p10_a28 JTF_VARCHAR2_TABLE_200
    , p10_a29 JTF_VARCHAR2_TABLE_200
    , p10_a30 JTF_VARCHAR2_TABLE_200
    , p10_a31 JTF_VARCHAR2_TABLE_200
    , p10_a32 JTF_VARCHAR2_TABLE_200
    , p10_a33 JTF_VARCHAR2_TABLE_200
    , p10_a34 JTF_VARCHAR2_TABLE_200
    , p10_a35 JTF_VARCHAR2_TABLE_200
    , p10_a36 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_DATE_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_DATE_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_DATE_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_100
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_100
    , p11_a18 JTF_VARCHAR2_TABLE_100
    , p11_a19 JTF_VARCHAR2_TABLE_100
    , p11_a20 JTF_VARCHAR2_TABLE_200
    , p11_a21 JTF_VARCHAR2_TABLE_200
    , p11_a22 JTF_VARCHAR2_TABLE_200
    , p11_a23 JTF_VARCHAR2_TABLE_200
    , p11_a24 JTF_VARCHAR2_TABLE_200
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_NUMBER_TABLE
    , x_sales_lead_id out nocopy  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  DATE := fnd_api.g_miss_date
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  NUMBER := 0-1962.0724
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  NUMBER := 0-1962.0724
    , p9_a58  NUMBER := 0-1962.0724
    , p9_a59  NUMBER := 0-1962.0724
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  VARCHAR2 := fnd_api.g_miss_char
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  NUMBER := 0-1962.0724
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  VARCHAR2 := fnd_api.g_miss_char
    , p9_a73  VARCHAR2 := fnd_api.g_miss_char
    , p9_a74  VARCHAR2 := fnd_api.g_miss_char
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  NUMBER := 0-1962.0724
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  DATE := fnd_api.g_miss_date
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  VARCHAR2 := fnd_api.g_miss_char
    , p9_a82  NUMBER := 0-1962.0724
    , p9_a83  DATE := fnd_api.g_miss_date
    , p9_a84  DATE := fnd_api.g_miss_date
    , p9_a85  VARCHAR2 := fnd_api.g_miss_char
    , p9_a86  NUMBER := 0-1962.0724
    , p9_a87  NUMBER := 0-1962.0724
    , p9_a88  NUMBER := 0-1962.0724
    , p9_a89  VARCHAR2 := fnd_api.g_miss_char
    , p9_a90  VARCHAR2 := fnd_api.g_miss_char
    , p9_a91  NUMBER := 0-1962.0724
    , p9_a92  NUMBER := 0-1962.0724
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_rec as_sales_leads_pub.sales_lead_rec_type;
    ddp_sales_lead_line_tbl as_sales_leads_pub.sales_lead_line_tbl_type;
    ddp_sales_lead_contact_tbl as_sales_leads_pub.sales_lead_contact_tbl_type;
    ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    ddx_sales_lead_cnt_out_tbl as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    ddp_sales_lead_rec.sales_lead_id := rosetta_g_miss_num_map(p9_a0);
    ddp_sales_lead_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a1);
    ddp_sales_lead_rec.last_updated_by := rosetta_g_miss_num_map(p9_a2);
    ddp_sales_lead_rec.creation_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_sales_lead_rec.created_by := rosetta_g_miss_num_map(p9_a4);
    ddp_sales_lead_rec.last_update_login := rosetta_g_miss_num_map(p9_a5);
    ddp_sales_lead_rec.request_id := rosetta_g_miss_num_map(p9_a6);
    ddp_sales_lead_rec.program_application_id := rosetta_g_miss_num_map(p9_a7);
    ddp_sales_lead_rec.program_id := rosetta_g_miss_num_map(p9_a8);
    ddp_sales_lead_rec.program_update_date := rosetta_g_miss_date_in_map(p9_a9);
    ddp_sales_lead_rec.lead_number := p9_a10;
    ddp_sales_lead_rec.status_code := p9_a11;
    ddp_sales_lead_rec.customer_id := rosetta_g_miss_num_map(p9_a12);
    ddp_sales_lead_rec.address_id := rosetta_g_miss_num_map(p9_a13);
    ddp_sales_lead_rec.source_promotion_id := rosetta_g_miss_num_map(p9_a14);
    ddp_sales_lead_rec.initiating_contact_id := rosetta_g_miss_num_map(p9_a15);
    ddp_sales_lead_rec.orig_system_reference := p9_a16;
    ddp_sales_lead_rec.contact_role_code := p9_a17;
    ddp_sales_lead_rec.channel_code := p9_a18;
    ddp_sales_lead_rec.budget_amount := rosetta_g_miss_num_map(p9_a19);
    ddp_sales_lead_rec.currency_code := p9_a20;
    ddp_sales_lead_rec.decision_timeframe_code := p9_a21;
    ddp_sales_lead_rec.close_reason := p9_a22;
    ddp_sales_lead_rec.lead_rank_id := rosetta_g_miss_num_map(p9_a23);
    ddp_sales_lead_rec.lead_rank_code := p9_a24;
    ddp_sales_lead_rec.parent_project := p9_a25;
    ddp_sales_lead_rec.description := p9_a26;
    ddp_sales_lead_rec.attribute_category := p9_a27;
    ddp_sales_lead_rec.attribute1 := p9_a28;
    ddp_sales_lead_rec.attribute2 := p9_a29;
    ddp_sales_lead_rec.attribute3 := p9_a30;
    ddp_sales_lead_rec.attribute4 := p9_a31;
    ddp_sales_lead_rec.attribute5 := p9_a32;
    ddp_sales_lead_rec.attribute6 := p9_a33;
    ddp_sales_lead_rec.attribute7 := p9_a34;
    ddp_sales_lead_rec.attribute8 := p9_a35;
    ddp_sales_lead_rec.attribute9 := p9_a36;
    ddp_sales_lead_rec.attribute10 := p9_a37;
    ddp_sales_lead_rec.attribute11 := p9_a38;
    ddp_sales_lead_rec.attribute12 := p9_a39;
    ddp_sales_lead_rec.attribute13 := p9_a40;
    ddp_sales_lead_rec.attribute14 := p9_a41;
    ddp_sales_lead_rec.attribute15 := p9_a42;
    ddp_sales_lead_rec.assign_to_person_id := rosetta_g_miss_num_map(p9_a43);
    ddp_sales_lead_rec.assign_to_salesforce_id := rosetta_g_miss_num_map(p9_a44);
    ddp_sales_lead_rec.assign_sales_group_id := rosetta_g_miss_num_map(p9_a45);
    ddp_sales_lead_rec.assign_date := rosetta_g_miss_date_in_map(p9_a46);
    ddp_sales_lead_rec.budget_status_code := p9_a47;
    ddp_sales_lead_rec.accept_flag := p9_a48;
    ddp_sales_lead_rec.vehicle_response_code := p9_a49;
    ddp_sales_lead_rec.total_score := rosetta_g_miss_num_map(p9_a50);
    ddp_sales_lead_rec.scorecard_id := rosetta_g_miss_num_map(p9_a51);
    ddp_sales_lead_rec.keep_flag := p9_a52;
    ddp_sales_lead_rec.urgent_flag := p9_a53;
    ddp_sales_lead_rec.import_flag := p9_a54;
    ddp_sales_lead_rec.reject_reason_code := p9_a55;
    ddp_sales_lead_rec.deleted_flag := p9_a56;
    ddp_sales_lead_rec.offer_id := rosetta_g_miss_num_map(p9_a57);
    ddp_sales_lead_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p9_a58);
    ddp_sales_lead_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p9_a59);
    ddp_sales_lead_rec.prm_exec_sponsor_flag := p9_a60;
    ddp_sales_lead_rec.prm_prj_lead_in_place_flag := p9_a61;
    ddp_sales_lead_rec.prm_sales_lead_type := p9_a62;
    ddp_sales_lead_rec.prm_ind_classification_code := p9_a63;
    ddp_sales_lead_rec.qualified_flag := p9_a64;
    ddp_sales_lead_rec.orig_system_code := p9_a65;
    ddp_sales_lead_rec.prm_assignment_type := p9_a66;
    ddp_sales_lead_rec.auto_assignment_type := p9_a67;
    ddp_sales_lead_rec.primary_contact_party_id := rosetta_g_miss_num_map(p9_a68);
    ddp_sales_lead_rec.primary_cnt_person_party_id := rosetta_g_miss_num_map(p9_a69);
    ddp_sales_lead_rec.primary_contact_phone_id := rosetta_g_miss_num_map(p9_a70);
    ddp_sales_lead_rec.referred_by := rosetta_g_miss_num_map(p9_a71);
    ddp_sales_lead_rec.referral_type := p9_a72;
    ddp_sales_lead_rec.referral_status := p9_a73;
    ddp_sales_lead_rec.ref_decline_reason := p9_a74;
    ddp_sales_lead_rec.ref_comm_ltr_status := p9_a75;
    ddp_sales_lead_rec.ref_order_number := rosetta_g_miss_num_map(p9_a76);
    ddp_sales_lead_rec.ref_order_amt := rosetta_g_miss_num_map(p9_a77);
    ddp_sales_lead_rec.ref_comm_amt := rosetta_g_miss_num_map(p9_a78);
    ddp_sales_lead_rec.lead_date := rosetta_g_miss_date_in_map(p9_a79);
    ddp_sales_lead_rec.source_system := p9_a80;
    ddp_sales_lead_rec.country := p9_a81;
    ddp_sales_lead_rec.total_amount := rosetta_g_miss_num_map(p9_a82);
    ddp_sales_lead_rec.expiration_date := rosetta_g_miss_date_in_map(p9_a83);
    ddp_sales_lead_rec.lead_engine_run_date := rosetta_g_miss_date_in_map(p9_a84);
    ddp_sales_lead_rec.lead_rank_ind := p9_a85;
    ddp_sales_lead_rec.current_reroutes := rosetta_g_miss_num_map(p9_a86);
    ddp_sales_lead_rec.marketing_score := rosetta_g_miss_num_map(p9_a87);
    ddp_sales_lead_rec.interaction_score := rosetta_g_miss_num_map(p9_a88);
    ddp_sales_lead_rec.source_primary_reference := p9_a89;
    ddp_sales_lead_rec.source_secondary_reference := p9_a90;
    ddp_sales_lead_rec.sales_methodology_id := rosetta_g_miss_num_map(p9_a91);
    ddp_sales_lead_rec.sales_stage_id := rosetta_g_miss_num_map(p9_a92);

    as_sales_leads_pub_w.rosetta_table_copy_in_p7(ddp_sales_lead_line_tbl, p10_a0
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
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p13(ddp_sales_lead_contact_tbl, p11_a0
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
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      );







    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.create_sales_lead(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_rec,
      ddp_sales_lead_line_tbl,
      ddp_sales_lead_contact_tbl,
      x_sales_lead_id,
      ddx_sales_lead_line_out_tbl,
      ddx_sales_lead_cnt_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    as_sales_leads_pub_w.rosetta_table_copy_out_p10(ddx_sales_lead_line_out_tbl, p13_a0
      , p13_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_out_p16(ddx_sales_lead_cnt_out_tbl, p14_a0
      , p14_a1
      );



  end;

  procedure update_sales_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  DATE := fnd_api.g_miss_date
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  NUMBER := 0-1962.0724
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  NUMBER := 0-1962.0724
    , p9_a58  NUMBER := 0-1962.0724
    , p9_a59  NUMBER := 0-1962.0724
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  VARCHAR2 := fnd_api.g_miss_char
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  NUMBER := 0-1962.0724
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  VARCHAR2 := fnd_api.g_miss_char
    , p9_a73  VARCHAR2 := fnd_api.g_miss_char
    , p9_a74  VARCHAR2 := fnd_api.g_miss_char
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  NUMBER := 0-1962.0724
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  DATE := fnd_api.g_miss_date
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  VARCHAR2 := fnd_api.g_miss_char
    , p9_a82  NUMBER := 0-1962.0724
    , p9_a83  DATE := fnd_api.g_miss_date
    , p9_a84  DATE := fnd_api.g_miss_date
    , p9_a85  VARCHAR2 := fnd_api.g_miss_char
    , p9_a86  NUMBER := 0-1962.0724
    , p9_a87  NUMBER := 0-1962.0724
    , p9_a88  NUMBER := 0-1962.0724
    , p9_a89  VARCHAR2 := fnd_api.g_miss_char
    , p9_a90  VARCHAR2 := fnd_api.g_miss_char
    , p9_a91  NUMBER := 0-1962.0724
    , p9_a92  NUMBER := 0-1962.0724
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_rec as_sales_leads_pub.sales_lead_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    ddp_sales_lead_rec.sales_lead_id := rosetta_g_miss_num_map(p9_a0);
    ddp_sales_lead_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a1);
    ddp_sales_lead_rec.last_updated_by := rosetta_g_miss_num_map(p9_a2);
    ddp_sales_lead_rec.creation_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_sales_lead_rec.created_by := rosetta_g_miss_num_map(p9_a4);
    ddp_sales_lead_rec.last_update_login := rosetta_g_miss_num_map(p9_a5);
    ddp_sales_lead_rec.request_id := rosetta_g_miss_num_map(p9_a6);
    ddp_sales_lead_rec.program_application_id := rosetta_g_miss_num_map(p9_a7);
    ddp_sales_lead_rec.program_id := rosetta_g_miss_num_map(p9_a8);
    ddp_sales_lead_rec.program_update_date := rosetta_g_miss_date_in_map(p9_a9);
    ddp_sales_lead_rec.lead_number := p9_a10;
    ddp_sales_lead_rec.status_code := p9_a11;
    ddp_sales_lead_rec.customer_id := rosetta_g_miss_num_map(p9_a12);
    ddp_sales_lead_rec.address_id := rosetta_g_miss_num_map(p9_a13);
    ddp_sales_lead_rec.source_promotion_id := rosetta_g_miss_num_map(p9_a14);
    ddp_sales_lead_rec.initiating_contact_id := rosetta_g_miss_num_map(p9_a15);
    ddp_sales_lead_rec.orig_system_reference := p9_a16;
    ddp_sales_lead_rec.contact_role_code := p9_a17;
    ddp_sales_lead_rec.channel_code := p9_a18;
    ddp_sales_lead_rec.budget_amount := rosetta_g_miss_num_map(p9_a19);
    ddp_sales_lead_rec.currency_code := p9_a20;
    ddp_sales_lead_rec.decision_timeframe_code := p9_a21;
    ddp_sales_lead_rec.close_reason := p9_a22;
    ddp_sales_lead_rec.lead_rank_id := rosetta_g_miss_num_map(p9_a23);
    ddp_sales_lead_rec.lead_rank_code := p9_a24;
    ddp_sales_lead_rec.parent_project := p9_a25;
    ddp_sales_lead_rec.description := p9_a26;
    ddp_sales_lead_rec.attribute_category := p9_a27;
    ddp_sales_lead_rec.attribute1 := p9_a28;
    ddp_sales_lead_rec.attribute2 := p9_a29;
    ddp_sales_lead_rec.attribute3 := p9_a30;
    ddp_sales_lead_rec.attribute4 := p9_a31;
    ddp_sales_lead_rec.attribute5 := p9_a32;
    ddp_sales_lead_rec.attribute6 := p9_a33;
    ddp_sales_lead_rec.attribute7 := p9_a34;
    ddp_sales_lead_rec.attribute8 := p9_a35;
    ddp_sales_lead_rec.attribute9 := p9_a36;
    ddp_sales_lead_rec.attribute10 := p9_a37;
    ddp_sales_lead_rec.attribute11 := p9_a38;
    ddp_sales_lead_rec.attribute12 := p9_a39;
    ddp_sales_lead_rec.attribute13 := p9_a40;
    ddp_sales_lead_rec.attribute14 := p9_a41;
    ddp_sales_lead_rec.attribute15 := p9_a42;
    ddp_sales_lead_rec.assign_to_person_id := rosetta_g_miss_num_map(p9_a43);
    ddp_sales_lead_rec.assign_to_salesforce_id := rosetta_g_miss_num_map(p9_a44);
    ddp_sales_lead_rec.assign_sales_group_id := rosetta_g_miss_num_map(p9_a45);
    ddp_sales_lead_rec.assign_date := rosetta_g_miss_date_in_map(p9_a46);
    ddp_sales_lead_rec.budget_status_code := p9_a47;
    ddp_sales_lead_rec.accept_flag := p9_a48;
    ddp_sales_lead_rec.vehicle_response_code := p9_a49;
    ddp_sales_lead_rec.total_score := rosetta_g_miss_num_map(p9_a50);
    ddp_sales_lead_rec.scorecard_id := rosetta_g_miss_num_map(p9_a51);
    ddp_sales_lead_rec.keep_flag := p9_a52;
    ddp_sales_lead_rec.urgent_flag := p9_a53;
    ddp_sales_lead_rec.import_flag := p9_a54;
    ddp_sales_lead_rec.reject_reason_code := p9_a55;
    ddp_sales_lead_rec.deleted_flag := p9_a56;
    ddp_sales_lead_rec.offer_id := rosetta_g_miss_num_map(p9_a57);
    ddp_sales_lead_rec.incumbent_partner_party_id := rosetta_g_miss_num_map(p9_a58);
    ddp_sales_lead_rec.incumbent_partner_resource_id := rosetta_g_miss_num_map(p9_a59);
    ddp_sales_lead_rec.prm_exec_sponsor_flag := p9_a60;
    ddp_sales_lead_rec.prm_prj_lead_in_place_flag := p9_a61;
    ddp_sales_lead_rec.prm_sales_lead_type := p9_a62;
    ddp_sales_lead_rec.prm_ind_classification_code := p9_a63;
    ddp_sales_lead_rec.qualified_flag := p9_a64;
    ddp_sales_lead_rec.orig_system_code := p9_a65;
    ddp_sales_lead_rec.prm_assignment_type := p9_a66;
    ddp_sales_lead_rec.auto_assignment_type := p9_a67;
    ddp_sales_lead_rec.primary_contact_party_id := rosetta_g_miss_num_map(p9_a68);
    ddp_sales_lead_rec.primary_cnt_person_party_id := rosetta_g_miss_num_map(p9_a69);
    ddp_sales_lead_rec.primary_contact_phone_id := rosetta_g_miss_num_map(p9_a70);
    ddp_sales_lead_rec.referred_by := rosetta_g_miss_num_map(p9_a71);
    ddp_sales_lead_rec.referral_type := p9_a72;
    ddp_sales_lead_rec.referral_status := p9_a73;
    ddp_sales_lead_rec.ref_decline_reason := p9_a74;
    ddp_sales_lead_rec.ref_comm_ltr_status := p9_a75;
    ddp_sales_lead_rec.ref_order_number := rosetta_g_miss_num_map(p9_a76);
    ddp_sales_lead_rec.ref_order_amt := rosetta_g_miss_num_map(p9_a77);
    ddp_sales_lead_rec.ref_comm_amt := rosetta_g_miss_num_map(p9_a78);
    ddp_sales_lead_rec.lead_date := rosetta_g_miss_date_in_map(p9_a79);
    ddp_sales_lead_rec.source_system := p9_a80;
    ddp_sales_lead_rec.country := p9_a81;
    ddp_sales_lead_rec.total_amount := rosetta_g_miss_num_map(p9_a82);
    ddp_sales_lead_rec.expiration_date := rosetta_g_miss_date_in_map(p9_a83);
    ddp_sales_lead_rec.lead_engine_run_date := rosetta_g_miss_date_in_map(p9_a84);
    ddp_sales_lead_rec.lead_rank_ind := p9_a85;
    ddp_sales_lead_rec.current_reroutes := rosetta_g_miss_num_map(p9_a86);
    ddp_sales_lead_rec.marketing_score := rosetta_g_miss_num_map(p9_a87);
    ddp_sales_lead_rec.interaction_score := rosetta_g_miss_num_map(p9_a88);
    ddp_sales_lead_rec.source_primary_reference := p9_a89;
    ddp_sales_lead_rec.source_secondary_reference := p9_a90;
    ddp_sales_lead_rec.sales_methodology_id := rosetta_g_miss_num_map(p9_a91);
    ddp_sales_lead_rec.sales_stage_id := rosetta_g_miss_num_map(p9_a92);




    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.update_sales_lead(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure create_sales_lead_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_NUMBER_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_NUMBER_TABLE
    , p_sales_lead_id  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_line_tbl as_sales_leads_pub.sales_lead_line_tbl_type;
    ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p7(ddp_sales_lead_line_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      );






    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.create_sales_lead_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_line_tbl,
      p_sales_lead_id,
      ddx_sales_lead_line_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_sales_leads_pub_w.rosetta_table_copy_out_p10(ddx_sales_lead_line_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure update_sales_lead_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_NUMBER_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_line_tbl as_sales_leads_pub.sales_lead_line_tbl_type;
    ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p7(ddp_sales_lead_line_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      );





    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.update_sales_lead_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_line_tbl,
      ddx_sales_lead_line_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    as_sales_leads_pub_w.rosetta_table_copy_out_p10(ddx_sales_lead_line_out_tbl, p10_a0
      , p10_a1
      );



  end;

  procedure delete_sales_lead_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_NUMBER_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_line_tbl as_sales_leads_pub.sales_lead_line_tbl_type;
    ddx_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p7(ddp_sales_lead_line_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      );





    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.delete_sales_lead_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_line_tbl,
      ddx_sales_lead_line_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    as_sales_leads_pub_w.rosetta_table_copy_out_p10(ddx_sales_lead_line_out_tbl, p10_a0
      , p10_a1
      );



  end;

  procedure create_sales_lead_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_NUMBER_TABLE
    , p_sales_lead_id  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_contact_tbl as_sales_leads_pub.sales_lead_contact_tbl_type;
    ddx_sales_lead_cnt_out_tbl as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p13(ddp_sales_lead_contact_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      );






    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.create_sales_lead_contacts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_contact_tbl,
      p_sales_lead_id,
      ddx_sales_lead_cnt_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_sales_leads_pub_w.rosetta_table_copy_out_p16(ddx_sales_lead_cnt_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure update_sales_lead_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_contact_tbl as_sales_leads_pub.sales_lead_contact_tbl_type;
    ddx_sales_lead_cnt_out_tbl as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p13(ddp_sales_lead_contact_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      );





    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.update_sales_lead_contacts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_contact_tbl,
      ddx_sales_lead_cnt_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    as_sales_leads_pub_w.rosetta_table_copy_out_p16(ddx_sales_lead_cnt_out_tbl, p10_a0
      , p10_a1
      );



  end;

  procedure delete_sales_lead_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_contact_tbl as_sales_leads_pub.sales_lead_contact_tbl_type;
    ddx_sales_lead_cnt_out_tbl as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );

    as_sales_leads_pub_w.rosetta_table_copy_in_p13(ddp_sales_lead_contact_tbl, p9_a0
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
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      );





    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.delete_sales_lead_contacts(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_contact_tbl,
      ddx_sales_lead_cnt_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    as_sales_leads_pub_w.rosetta_table_copy_out_p16(ddx_sales_lead_cnt_out_tbl, p10_a0
      , p10_a1
      );



  end;

end as_sales_leads_pub_w;

/
