--------------------------------------------------------
--  DDL for Package Body AMS_CAMP_SCHEDULE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMP_SCHEDULE_PUB_W" as
  /* $Header: amswschb.pls 120.1 2005/09/08 22:12 dbiswas noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
  AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_camp_schedule_pub.schedule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_300
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
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_VARCHAR2_TABLE_200
    , a72 JTF_VARCHAR2_TABLE_200
    , a73 JTF_VARCHAR2_TABLE_200
    , a74 JTF_VARCHAR2_TABLE_200
    , a75 JTF_VARCHAR2_TABLE_200
    , a76 JTF_VARCHAR2_TABLE_200
    , a77 JTF_VARCHAR2_TABLE_200
    , a78 JTF_VARCHAR2_TABLE_200
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    , a81 JTF_VARCHAR2_TABLE_200
    , a82 JTF_VARCHAR2_TABLE_4000
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_4000
    , a91 JTF_VARCHAR2_TABLE_4000
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_NUMBER_TABLE
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_DATE_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).schedule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).campaign_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).user_status_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).status_code := a9(indx);
          t(ddindx).status_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).source_code := a11(indx);
          t(ddindx).use_parent_code_flag := a12(indx);
          t(ddindx).start_date_time := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).end_date_time := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).timezone_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).activity_type_code := a16(indx);
          t(ddindx).activity_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).arc_marketing_medium_from := a18(indx);
          t(ddindx).marketing_medium_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).custom_setup_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).triggerable_flag := a21(indx);
          t(ddindx).trigger_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).notify_user_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).approver_user_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).owner_user_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).active_flag := a26(indx);
          t(ddindx).cover_letter_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).reply_to_mail := a28(indx);
          t(ddindx).mail_sender_name := a29(indx);
          t(ddindx).mail_subject := a30(indx);
          t(ddindx).from_fax_no := a31(indx);
          t(ddindx).accounts_closed_flag := a32(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).objective_code := a34(indx);
          t(ddindx).country_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).campaign_calendar := a36(indx);
          t(ddindx).start_period_name := a37(indx);
          t(ddindx).end_period_name := a38(indx);
          t(ddindx).priority := a39(indx);
          t(ddindx).workflow_item_key := a40(indx);
          t(ddindx).transaction_currency_code := a41(indx);
          t(ddindx).functional_currency_code := a42(indx);
          t(ddindx).budget_amount_tc := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).budget_amount_fc := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).language_code := a45(indx);
          t(ddindx).task_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).related_event_from := a47(indx);
          t(ddindx).related_event_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).attribute_category := a49(indx);
          t(ddindx).attribute1 := a50(indx);
          t(ddindx).attribute2 := a51(indx);
          t(ddindx).attribute3 := a52(indx);
          t(ddindx).attribute4 := a53(indx);
          t(ddindx).attribute5 := a54(indx);
          t(ddindx).attribute6 := a55(indx);
          t(ddindx).attribute7 := a56(indx);
          t(ddindx).attribute8 := a57(indx);
          t(ddindx).attribute9 := a58(indx);
          t(ddindx).attribute10 := a59(indx);
          t(ddindx).attribute11 := a60(indx);
          t(ddindx).attribute12 := a61(indx);
          t(ddindx).attribute13 := a62(indx);
          t(ddindx).attribute14 := a63(indx);
          t(ddindx).attribute15 := a64(indx);
          t(ddindx).activity_attribute_category := a65(indx);
          t(ddindx).activity_attribute1 := a66(indx);
          t(ddindx).activity_attribute2 := a67(indx);
          t(ddindx).activity_attribute3 := a68(indx);
          t(ddindx).activity_attribute4 := a69(indx);
          t(ddindx).activity_attribute5 := a70(indx);
          t(ddindx).activity_attribute6 := a71(indx);
          t(ddindx).activity_attribute7 := a72(indx);
          t(ddindx).activity_attribute8 := a73(indx);
          t(ddindx).activity_attribute9 := a74(indx);
          t(ddindx).activity_attribute10 := a75(indx);
          t(ddindx).activity_attribute11 := a76(indx);
          t(ddindx).activity_attribute12 := a77(indx);
          t(ddindx).activity_attribute13 := a78(indx);
          t(ddindx).activity_attribute14 := a79(indx);
          t(ddindx).activity_attribute15 := a80(indx);
          t(ddindx).schedule_name := a81(indx);
          t(ddindx).description := a82(indx);
          t(ddindx).related_source_code := a83(indx);
          t(ddindx).related_source_object := a84(indx);
          t(ddindx).related_source_id := rosetta_g_miss_num_map(a85(indx));
          t(ddindx).query_id := rosetta_g_miss_num_map(a86(indx));
          t(ddindx).include_content_flag := a87(indx);
          t(ddindx).content_type := a88(indx);
          t(ddindx).test_email_address := a89(indx);
          t(ddindx).greeting_text := a90(indx);
          t(ddindx).footer_text := a91(indx);
          t(ddindx).trig_repeat_flag := a92(indx);
          t(ddindx).tgrp_exclude_prev_flag := a93(indx);
          t(ddindx).orig_csch_id := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).cover_letter_version := rosetta_g_miss_num_map(a95(indx));
          t(ddindx).usage := a96(indx);
          t(ddindx).purpose := a97(indx);
          t(ddindx).last_activation_date := rosetta_g_miss_date_in_map(a98(indx));
          t(ddindx).sales_methodology_id := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).printer_address := a100(indx);
          t(ddindx).notify_on_activation_flag := a101(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_camp_schedule_pub.schedule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
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
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_VARCHAR2_TABLE_200
    , a72 out nocopy JTF_VARCHAR2_TABLE_200
    , a73 out nocopy JTF_VARCHAR2_TABLE_200
    , a74 out nocopy JTF_VARCHAR2_TABLE_200
    , a75 out nocopy JTF_VARCHAR2_TABLE_200
    , a76 out nocopy JTF_VARCHAR2_TABLE_200
    , a77 out nocopy JTF_VARCHAR2_TABLE_200
    , a78 out nocopy JTF_VARCHAR2_TABLE_200
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    , a81 out nocopy JTF_VARCHAR2_TABLE_200
    , a82 out nocopy JTF_VARCHAR2_TABLE_4000
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_NUMBER_TABLE
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_VARCHAR2_TABLE_100
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_4000
    , a91 out nocopy JTF_VARCHAR2_TABLE_4000
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_NUMBER_TABLE
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_DATE_TABLE
    , a99 out nocopy JTF_NUMBER_TABLE
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_100
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
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_300();
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
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_200();
    a67 := JTF_VARCHAR2_TABLE_200();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_VARCHAR2_TABLE_200();
    a70 := JTF_VARCHAR2_TABLE_200();
    a71 := JTF_VARCHAR2_TABLE_200();
    a72 := JTF_VARCHAR2_TABLE_200();
    a73 := JTF_VARCHAR2_TABLE_200();
    a74 := JTF_VARCHAR2_TABLE_200();
    a75 := JTF_VARCHAR2_TABLE_200();
    a76 := JTF_VARCHAR2_TABLE_200();
    a77 := JTF_VARCHAR2_TABLE_200();
    a78 := JTF_VARCHAR2_TABLE_200();
    a79 := JTF_VARCHAR2_TABLE_200();
    a80 := JTF_VARCHAR2_TABLE_200();
    a81 := JTF_VARCHAR2_TABLE_200();
    a82 := JTF_VARCHAR2_TABLE_4000();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_NUMBER_TABLE();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_4000();
    a91 := JTF_VARCHAR2_TABLE_4000();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_NUMBER_TABLE();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_DATE_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_100();
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
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_300();
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
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_200();
      a67 := JTF_VARCHAR2_TABLE_200();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_VARCHAR2_TABLE_200();
      a70 := JTF_VARCHAR2_TABLE_200();
      a71 := JTF_VARCHAR2_TABLE_200();
      a72 := JTF_VARCHAR2_TABLE_200();
      a73 := JTF_VARCHAR2_TABLE_200();
      a74 := JTF_VARCHAR2_TABLE_200();
      a75 := JTF_VARCHAR2_TABLE_200();
      a76 := JTF_VARCHAR2_TABLE_200();
      a77 := JTF_VARCHAR2_TABLE_200();
      a78 := JTF_VARCHAR2_TABLE_200();
      a79 := JTF_VARCHAR2_TABLE_200();
      a80 := JTF_VARCHAR2_TABLE_200();
      a81 := JTF_VARCHAR2_TABLE_200();
      a82 := JTF_VARCHAR2_TABLE_4000();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_NUMBER_TABLE();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_4000();
      a91 := JTF_VARCHAR2_TABLE_4000();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_NUMBER_TABLE();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_DATE_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_100();
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
        a100.extend(t.count);
        a101.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).schedule_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).campaign_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).user_status_id);
          a9(indx) := t(ddindx).status_code;
          a10(indx) := t(ddindx).status_date;
          a11(indx) := t(ddindx).source_code;
          a12(indx) := t(ddindx).use_parent_code_flag;
          a13(indx) := t(ddindx).start_date_time;
          a14(indx) := t(ddindx).end_date_time;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).timezone_id);
          a16(indx) := t(ddindx).activity_type_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).activity_id);
          a18(indx) := t(ddindx).arc_marketing_medium_from;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).marketing_medium_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).custom_setup_id);
          a21(indx) := t(ddindx).triggerable_flag;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).trigger_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).notify_user_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).approver_user_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).owner_user_id);
          a26(indx) := t(ddindx).active_flag;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).cover_letter_id);
          a28(indx) := t(ddindx).reply_to_mail;
          a29(indx) := t(ddindx).mail_sender_name;
          a30(indx) := t(ddindx).mail_subject;
          a31(indx) := t(ddindx).from_fax_no;
          a32(indx) := t(ddindx).accounts_closed_flag;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a34(indx) := t(ddindx).objective_code;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).country_id);
          a36(indx) := t(ddindx).campaign_calendar;
          a37(indx) := t(ddindx).start_period_name;
          a38(indx) := t(ddindx).end_period_name;
          a39(indx) := t(ddindx).priority;
          a40(indx) := t(ddindx).workflow_item_key;
          a41(indx) := t(ddindx).transaction_currency_code;
          a42(indx) := t(ddindx).functional_currency_code;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).budget_amount_tc);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).budget_amount_fc);
          a45(indx) := t(ddindx).language_code;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a47(indx) := t(ddindx).related_event_from;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).related_event_id);
          a49(indx) := t(ddindx).attribute_category;
          a50(indx) := t(ddindx).attribute1;
          a51(indx) := t(ddindx).attribute2;
          a52(indx) := t(ddindx).attribute3;
          a53(indx) := t(ddindx).attribute4;
          a54(indx) := t(ddindx).attribute5;
          a55(indx) := t(ddindx).attribute6;
          a56(indx) := t(ddindx).attribute7;
          a57(indx) := t(ddindx).attribute8;
          a58(indx) := t(ddindx).attribute9;
          a59(indx) := t(ddindx).attribute10;
          a60(indx) := t(ddindx).attribute11;
          a61(indx) := t(ddindx).attribute12;
          a62(indx) := t(ddindx).attribute13;
          a63(indx) := t(ddindx).attribute14;
          a64(indx) := t(ddindx).attribute15;
          a65(indx) := t(ddindx).activity_attribute_category;
          a66(indx) := t(ddindx).activity_attribute1;
          a67(indx) := t(ddindx).activity_attribute2;
          a68(indx) := t(ddindx).activity_attribute3;
          a69(indx) := t(ddindx).activity_attribute4;
          a70(indx) := t(ddindx).activity_attribute5;
          a71(indx) := t(ddindx).activity_attribute6;
          a72(indx) := t(ddindx).activity_attribute7;
          a73(indx) := t(ddindx).activity_attribute8;
          a74(indx) := t(ddindx).activity_attribute9;
          a75(indx) := t(ddindx).activity_attribute10;
          a76(indx) := t(ddindx).activity_attribute11;
          a77(indx) := t(ddindx).activity_attribute12;
          a78(indx) := t(ddindx).activity_attribute13;
          a79(indx) := t(ddindx).activity_attribute14;
          a80(indx) := t(ddindx).activity_attribute15;
          a81(indx) := t(ddindx).schedule_name;
          a82(indx) := t(ddindx).description;
          a83(indx) := t(ddindx).related_source_code;
          a84(indx) := t(ddindx).related_source_object;
          a85(indx) := rosetta_g_miss_num_map(t(ddindx).related_source_id);
          a86(indx) := rosetta_g_miss_num_map(t(ddindx).query_id);
          a87(indx) := t(ddindx).include_content_flag;
          a88(indx) := t(ddindx).content_type;
          a89(indx) := t(ddindx).test_email_address;
          a90(indx) := t(ddindx).greeting_text;
          a91(indx) := t(ddindx).footer_text;
          a92(indx) := t(ddindx).trig_repeat_flag;
          a93(indx) := t(ddindx).tgrp_exclude_prev_flag;
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).orig_csch_id);
          a95(indx) := rosetta_g_miss_num_map(t(ddindx).cover_letter_version);
          a96(indx) := t(ddindx).usage;
          a97(indx) := t(ddindx).purpose;
          a98(indx) := t(ddindx).last_activation_date;
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).sales_methodology_id);
          a100(indx) := t(ddindx).printer_address;
          a101(indx) := t(ddindx).notify_on_activation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_camp_schedule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_schedule_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  NUMBER := 0-1962.0724
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  DATE := fnd_api.g_miss_date
    , p7_a99  NUMBER := 0-1962.0724
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_schedule_rec ams_camp_schedule_pub.schedule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_schedule_rec.schedule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_schedule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_schedule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_schedule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_schedule_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_schedule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_schedule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_schedule_rec.campaign_id := rosetta_g_miss_num_map(p7_a7);
    ddp_schedule_rec.user_status_id := rosetta_g_miss_num_map(p7_a8);
    ddp_schedule_rec.status_code := p7_a9;
    ddp_schedule_rec.status_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_schedule_rec.source_code := p7_a11;
    ddp_schedule_rec.use_parent_code_flag := p7_a12;
    ddp_schedule_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_schedule_rec.end_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_schedule_rec.timezone_id := rosetta_g_miss_num_map(p7_a15);
    ddp_schedule_rec.activity_type_code := p7_a16;
    ddp_schedule_rec.activity_id := rosetta_g_miss_num_map(p7_a17);
    ddp_schedule_rec.arc_marketing_medium_from := p7_a18;
    ddp_schedule_rec.marketing_medium_id := rosetta_g_miss_num_map(p7_a19);
    ddp_schedule_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a20);
    ddp_schedule_rec.triggerable_flag := p7_a21;
    ddp_schedule_rec.trigger_id := rosetta_g_miss_num_map(p7_a22);
    ddp_schedule_rec.notify_user_id := rosetta_g_miss_num_map(p7_a23);
    ddp_schedule_rec.approver_user_id := rosetta_g_miss_num_map(p7_a24);
    ddp_schedule_rec.owner_user_id := rosetta_g_miss_num_map(p7_a25);
    ddp_schedule_rec.active_flag := p7_a26;
    ddp_schedule_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a27);
    ddp_schedule_rec.reply_to_mail := p7_a28;
    ddp_schedule_rec.mail_sender_name := p7_a29;
    ddp_schedule_rec.mail_subject := p7_a30;
    ddp_schedule_rec.from_fax_no := p7_a31;
    ddp_schedule_rec.accounts_closed_flag := p7_a32;
    ddp_schedule_rec.org_id := rosetta_g_miss_num_map(p7_a33);
    ddp_schedule_rec.objective_code := p7_a34;
    ddp_schedule_rec.country_id := rosetta_g_miss_num_map(p7_a35);
    ddp_schedule_rec.campaign_calendar := p7_a36;
    ddp_schedule_rec.start_period_name := p7_a37;
    ddp_schedule_rec.end_period_name := p7_a38;
    ddp_schedule_rec.priority := p7_a39;
    ddp_schedule_rec.workflow_item_key := p7_a40;
    ddp_schedule_rec.transaction_currency_code := p7_a41;
    ddp_schedule_rec.functional_currency_code := p7_a42;
    ddp_schedule_rec.budget_amount_tc := rosetta_g_miss_num_map(p7_a43);
    ddp_schedule_rec.budget_amount_fc := rosetta_g_miss_num_map(p7_a44);
    ddp_schedule_rec.language_code := p7_a45;
    ddp_schedule_rec.task_id := rosetta_g_miss_num_map(p7_a46);
    ddp_schedule_rec.related_event_from := p7_a47;
    ddp_schedule_rec.related_event_id := rosetta_g_miss_num_map(p7_a48);
    ddp_schedule_rec.attribute_category := p7_a49;
    ddp_schedule_rec.attribute1 := p7_a50;
    ddp_schedule_rec.attribute2 := p7_a51;
    ddp_schedule_rec.attribute3 := p7_a52;
    ddp_schedule_rec.attribute4 := p7_a53;
    ddp_schedule_rec.attribute5 := p7_a54;
    ddp_schedule_rec.attribute6 := p7_a55;
    ddp_schedule_rec.attribute7 := p7_a56;
    ddp_schedule_rec.attribute8 := p7_a57;
    ddp_schedule_rec.attribute9 := p7_a58;
    ddp_schedule_rec.attribute10 := p7_a59;
    ddp_schedule_rec.attribute11 := p7_a60;
    ddp_schedule_rec.attribute12 := p7_a61;
    ddp_schedule_rec.attribute13 := p7_a62;
    ddp_schedule_rec.attribute14 := p7_a63;
    ddp_schedule_rec.attribute15 := p7_a64;
    ddp_schedule_rec.activity_attribute_category := p7_a65;
    ddp_schedule_rec.activity_attribute1 := p7_a66;
    ddp_schedule_rec.activity_attribute2 := p7_a67;
    ddp_schedule_rec.activity_attribute3 := p7_a68;
    ddp_schedule_rec.activity_attribute4 := p7_a69;
    ddp_schedule_rec.activity_attribute5 := p7_a70;
    ddp_schedule_rec.activity_attribute6 := p7_a71;
    ddp_schedule_rec.activity_attribute7 := p7_a72;
    ddp_schedule_rec.activity_attribute8 := p7_a73;
    ddp_schedule_rec.activity_attribute9 := p7_a74;
    ddp_schedule_rec.activity_attribute10 := p7_a75;
    ddp_schedule_rec.activity_attribute11 := p7_a76;
    ddp_schedule_rec.activity_attribute12 := p7_a77;
    ddp_schedule_rec.activity_attribute13 := p7_a78;
    ddp_schedule_rec.activity_attribute14 := p7_a79;
    ddp_schedule_rec.activity_attribute15 := p7_a80;
    ddp_schedule_rec.schedule_name := p7_a81;
    ddp_schedule_rec.description := p7_a82;
    ddp_schedule_rec.related_source_code := p7_a83;
    ddp_schedule_rec.related_source_object := p7_a84;
    ddp_schedule_rec.related_source_id := rosetta_g_miss_num_map(p7_a85);
    ddp_schedule_rec.query_id := rosetta_g_miss_num_map(p7_a86);
    ddp_schedule_rec.include_content_flag := p7_a87;
    ddp_schedule_rec.content_type := p7_a88;
    ddp_schedule_rec.test_email_address := p7_a89;
    ddp_schedule_rec.greeting_text := p7_a90;
    ddp_schedule_rec.footer_text := p7_a91;
    ddp_schedule_rec.trig_repeat_flag := p7_a92;
    ddp_schedule_rec.tgrp_exclude_prev_flag := p7_a93;
    ddp_schedule_rec.orig_csch_id := rosetta_g_miss_num_map(p7_a94);
    ddp_schedule_rec.cover_letter_version := rosetta_g_miss_num_map(p7_a95);
    ddp_schedule_rec.usage := p7_a96;
    ddp_schedule_rec.purpose := p7_a97;
    ddp_schedule_rec.last_activation_date := rosetta_g_miss_date_in_map(p7_a98);
    ddp_schedule_rec.sales_methodology_id := rosetta_g_miss_num_map(p7_a99);
    ddp_schedule_rec.printer_address := p7_a100;
    ddp_schedule_rec.notify_on_activation_flag := p7_a101;


    -- here's the delegated call to the old PL/SQL routine
    ams_camp_schedule_pub.create_camp_schedule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_schedule_rec,
      x_schedule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_camp_schedule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  NUMBER := 0-1962.0724
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  DATE := fnd_api.g_miss_date
    , p7_a99  NUMBER := 0-1962.0724
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_schedule_rec ams_camp_schedule_pub.schedule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_schedule_rec.schedule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_schedule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_schedule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_schedule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_schedule_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_schedule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_schedule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_schedule_rec.campaign_id := rosetta_g_miss_num_map(p7_a7);
    ddp_schedule_rec.user_status_id := rosetta_g_miss_num_map(p7_a8);
    ddp_schedule_rec.status_code := p7_a9;
    ddp_schedule_rec.status_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_schedule_rec.source_code := p7_a11;
    ddp_schedule_rec.use_parent_code_flag := p7_a12;
    ddp_schedule_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_schedule_rec.end_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_schedule_rec.timezone_id := rosetta_g_miss_num_map(p7_a15);
    ddp_schedule_rec.activity_type_code := p7_a16;
    ddp_schedule_rec.activity_id := rosetta_g_miss_num_map(p7_a17);
    ddp_schedule_rec.arc_marketing_medium_from := p7_a18;
    ddp_schedule_rec.marketing_medium_id := rosetta_g_miss_num_map(p7_a19);
    ddp_schedule_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a20);
    ddp_schedule_rec.triggerable_flag := p7_a21;
    ddp_schedule_rec.trigger_id := rosetta_g_miss_num_map(p7_a22);
    ddp_schedule_rec.notify_user_id := rosetta_g_miss_num_map(p7_a23);
    ddp_schedule_rec.approver_user_id := rosetta_g_miss_num_map(p7_a24);
    ddp_schedule_rec.owner_user_id := rosetta_g_miss_num_map(p7_a25);
    ddp_schedule_rec.active_flag := p7_a26;
    ddp_schedule_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a27);
    ddp_schedule_rec.reply_to_mail := p7_a28;
    ddp_schedule_rec.mail_sender_name := p7_a29;
    ddp_schedule_rec.mail_subject := p7_a30;
    ddp_schedule_rec.from_fax_no := p7_a31;
    ddp_schedule_rec.accounts_closed_flag := p7_a32;
    ddp_schedule_rec.org_id := rosetta_g_miss_num_map(p7_a33);
    ddp_schedule_rec.objective_code := p7_a34;
    ddp_schedule_rec.country_id := rosetta_g_miss_num_map(p7_a35);
    ddp_schedule_rec.campaign_calendar := p7_a36;
    ddp_schedule_rec.start_period_name := p7_a37;
    ddp_schedule_rec.end_period_name := p7_a38;
    ddp_schedule_rec.priority := p7_a39;
    ddp_schedule_rec.workflow_item_key := p7_a40;
    ddp_schedule_rec.transaction_currency_code := p7_a41;
    ddp_schedule_rec.functional_currency_code := p7_a42;
    ddp_schedule_rec.budget_amount_tc := rosetta_g_miss_num_map(p7_a43);
    ddp_schedule_rec.budget_amount_fc := rosetta_g_miss_num_map(p7_a44);
    ddp_schedule_rec.language_code := p7_a45;
    ddp_schedule_rec.task_id := rosetta_g_miss_num_map(p7_a46);
    ddp_schedule_rec.related_event_from := p7_a47;
    ddp_schedule_rec.related_event_id := rosetta_g_miss_num_map(p7_a48);
    ddp_schedule_rec.attribute_category := p7_a49;
    ddp_schedule_rec.attribute1 := p7_a50;
    ddp_schedule_rec.attribute2 := p7_a51;
    ddp_schedule_rec.attribute3 := p7_a52;
    ddp_schedule_rec.attribute4 := p7_a53;
    ddp_schedule_rec.attribute5 := p7_a54;
    ddp_schedule_rec.attribute6 := p7_a55;
    ddp_schedule_rec.attribute7 := p7_a56;
    ddp_schedule_rec.attribute8 := p7_a57;
    ddp_schedule_rec.attribute9 := p7_a58;
    ddp_schedule_rec.attribute10 := p7_a59;
    ddp_schedule_rec.attribute11 := p7_a60;
    ddp_schedule_rec.attribute12 := p7_a61;
    ddp_schedule_rec.attribute13 := p7_a62;
    ddp_schedule_rec.attribute14 := p7_a63;
    ddp_schedule_rec.attribute15 := p7_a64;
    ddp_schedule_rec.activity_attribute_category := p7_a65;
    ddp_schedule_rec.activity_attribute1 := p7_a66;
    ddp_schedule_rec.activity_attribute2 := p7_a67;
    ddp_schedule_rec.activity_attribute3 := p7_a68;
    ddp_schedule_rec.activity_attribute4 := p7_a69;
    ddp_schedule_rec.activity_attribute5 := p7_a70;
    ddp_schedule_rec.activity_attribute6 := p7_a71;
    ddp_schedule_rec.activity_attribute7 := p7_a72;
    ddp_schedule_rec.activity_attribute8 := p7_a73;
    ddp_schedule_rec.activity_attribute9 := p7_a74;
    ddp_schedule_rec.activity_attribute10 := p7_a75;
    ddp_schedule_rec.activity_attribute11 := p7_a76;
    ddp_schedule_rec.activity_attribute12 := p7_a77;
    ddp_schedule_rec.activity_attribute13 := p7_a78;
    ddp_schedule_rec.activity_attribute14 := p7_a79;
    ddp_schedule_rec.activity_attribute15 := p7_a80;
    ddp_schedule_rec.schedule_name := p7_a81;
    ddp_schedule_rec.description := p7_a82;
    ddp_schedule_rec.related_source_code := p7_a83;
    ddp_schedule_rec.related_source_object := p7_a84;
    ddp_schedule_rec.related_source_id := rosetta_g_miss_num_map(p7_a85);
    ddp_schedule_rec.query_id := rosetta_g_miss_num_map(p7_a86);
    ddp_schedule_rec.include_content_flag := p7_a87;
    ddp_schedule_rec.content_type := p7_a88;
    ddp_schedule_rec.test_email_address := p7_a89;
    ddp_schedule_rec.greeting_text := p7_a90;
    ddp_schedule_rec.footer_text := p7_a91;
    ddp_schedule_rec.trig_repeat_flag := p7_a92;
    ddp_schedule_rec.tgrp_exclude_prev_flag := p7_a93;
    ddp_schedule_rec.orig_csch_id := rosetta_g_miss_num_map(p7_a94);
    ddp_schedule_rec.cover_letter_version := rosetta_g_miss_num_map(p7_a95);
    ddp_schedule_rec.usage := p7_a96;
    ddp_schedule_rec.purpose := p7_a97;
    ddp_schedule_rec.last_activation_date := rosetta_g_miss_date_in_map(p7_a98);
    ddp_schedule_rec.sales_methodology_id := rosetta_g_miss_num_map(p7_a99);
    ddp_schedule_rec.printer_address := p7_a100;
    ddp_schedule_rec.notify_on_activation_flag := p7_a101;


    -- here's the delegated call to the old PL/SQL routine
    ams_camp_schedule_pub.update_camp_schedule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_schedule_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_camp_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_validation_mode  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  NUMBER := 0-1962.0724
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  DATE := fnd_api.g_miss_date
    , p7_a99  NUMBER := 0-1962.0724
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_schedule_rec ams_camp_schedule_pub.schedule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_schedule_rec.schedule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_schedule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_schedule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_schedule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_schedule_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_schedule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_schedule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_schedule_rec.campaign_id := rosetta_g_miss_num_map(p7_a7);
    ddp_schedule_rec.user_status_id := rosetta_g_miss_num_map(p7_a8);
    ddp_schedule_rec.status_code := p7_a9;
    ddp_schedule_rec.status_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_schedule_rec.source_code := p7_a11;
    ddp_schedule_rec.use_parent_code_flag := p7_a12;
    ddp_schedule_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_schedule_rec.end_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_schedule_rec.timezone_id := rosetta_g_miss_num_map(p7_a15);
    ddp_schedule_rec.activity_type_code := p7_a16;
    ddp_schedule_rec.activity_id := rosetta_g_miss_num_map(p7_a17);
    ddp_schedule_rec.arc_marketing_medium_from := p7_a18;
    ddp_schedule_rec.marketing_medium_id := rosetta_g_miss_num_map(p7_a19);
    ddp_schedule_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a20);
    ddp_schedule_rec.triggerable_flag := p7_a21;
    ddp_schedule_rec.trigger_id := rosetta_g_miss_num_map(p7_a22);
    ddp_schedule_rec.notify_user_id := rosetta_g_miss_num_map(p7_a23);
    ddp_schedule_rec.approver_user_id := rosetta_g_miss_num_map(p7_a24);
    ddp_schedule_rec.owner_user_id := rosetta_g_miss_num_map(p7_a25);
    ddp_schedule_rec.active_flag := p7_a26;
    ddp_schedule_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a27);
    ddp_schedule_rec.reply_to_mail := p7_a28;
    ddp_schedule_rec.mail_sender_name := p7_a29;
    ddp_schedule_rec.mail_subject := p7_a30;
    ddp_schedule_rec.from_fax_no := p7_a31;
    ddp_schedule_rec.accounts_closed_flag := p7_a32;
    ddp_schedule_rec.org_id := rosetta_g_miss_num_map(p7_a33);
    ddp_schedule_rec.objective_code := p7_a34;
    ddp_schedule_rec.country_id := rosetta_g_miss_num_map(p7_a35);
    ddp_schedule_rec.campaign_calendar := p7_a36;
    ddp_schedule_rec.start_period_name := p7_a37;
    ddp_schedule_rec.end_period_name := p7_a38;
    ddp_schedule_rec.priority := p7_a39;
    ddp_schedule_rec.workflow_item_key := p7_a40;
    ddp_schedule_rec.transaction_currency_code := p7_a41;
    ddp_schedule_rec.functional_currency_code := p7_a42;
    ddp_schedule_rec.budget_amount_tc := rosetta_g_miss_num_map(p7_a43);
    ddp_schedule_rec.budget_amount_fc := rosetta_g_miss_num_map(p7_a44);
    ddp_schedule_rec.language_code := p7_a45;
    ddp_schedule_rec.task_id := rosetta_g_miss_num_map(p7_a46);
    ddp_schedule_rec.related_event_from := p7_a47;
    ddp_schedule_rec.related_event_id := rosetta_g_miss_num_map(p7_a48);
    ddp_schedule_rec.attribute_category := p7_a49;
    ddp_schedule_rec.attribute1 := p7_a50;
    ddp_schedule_rec.attribute2 := p7_a51;
    ddp_schedule_rec.attribute3 := p7_a52;
    ddp_schedule_rec.attribute4 := p7_a53;
    ddp_schedule_rec.attribute5 := p7_a54;
    ddp_schedule_rec.attribute6 := p7_a55;
    ddp_schedule_rec.attribute7 := p7_a56;
    ddp_schedule_rec.attribute8 := p7_a57;
    ddp_schedule_rec.attribute9 := p7_a58;
    ddp_schedule_rec.attribute10 := p7_a59;
    ddp_schedule_rec.attribute11 := p7_a60;
    ddp_schedule_rec.attribute12 := p7_a61;
    ddp_schedule_rec.attribute13 := p7_a62;
    ddp_schedule_rec.attribute14 := p7_a63;
    ddp_schedule_rec.attribute15 := p7_a64;
    ddp_schedule_rec.activity_attribute_category := p7_a65;
    ddp_schedule_rec.activity_attribute1 := p7_a66;
    ddp_schedule_rec.activity_attribute2 := p7_a67;
    ddp_schedule_rec.activity_attribute3 := p7_a68;
    ddp_schedule_rec.activity_attribute4 := p7_a69;
    ddp_schedule_rec.activity_attribute5 := p7_a70;
    ddp_schedule_rec.activity_attribute6 := p7_a71;
    ddp_schedule_rec.activity_attribute7 := p7_a72;
    ddp_schedule_rec.activity_attribute8 := p7_a73;
    ddp_schedule_rec.activity_attribute9 := p7_a74;
    ddp_schedule_rec.activity_attribute10 := p7_a75;
    ddp_schedule_rec.activity_attribute11 := p7_a76;
    ddp_schedule_rec.activity_attribute12 := p7_a77;
    ddp_schedule_rec.activity_attribute13 := p7_a78;
    ddp_schedule_rec.activity_attribute14 := p7_a79;
    ddp_schedule_rec.activity_attribute15 := p7_a80;
    ddp_schedule_rec.schedule_name := p7_a81;
    ddp_schedule_rec.description := p7_a82;
    ddp_schedule_rec.related_source_code := p7_a83;
    ddp_schedule_rec.related_source_object := p7_a84;
    ddp_schedule_rec.related_source_id := rosetta_g_miss_num_map(p7_a85);
    ddp_schedule_rec.query_id := rosetta_g_miss_num_map(p7_a86);
    ddp_schedule_rec.include_content_flag := p7_a87;
    ddp_schedule_rec.content_type := p7_a88;
    ddp_schedule_rec.test_email_address := p7_a89;
    ddp_schedule_rec.greeting_text := p7_a90;
    ddp_schedule_rec.footer_text := p7_a91;
    ddp_schedule_rec.trig_repeat_flag := p7_a92;
    ddp_schedule_rec.tgrp_exclude_prev_flag := p7_a93;
    ddp_schedule_rec.orig_csch_id := rosetta_g_miss_num_map(p7_a94);
    ddp_schedule_rec.cover_letter_version := rosetta_g_miss_num_map(p7_a95);
    ddp_schedule_rec.usage := p7_a96;
    ddp_schedule_rec.purpose := p7_a97;
    ddp_schedule_rec.last_activation_date := rosetta_g_miss_date_in_map(p7_a98);
    ddp_schedule_rec.sales_methodology_id := rosetta_g_miss_num_map(p7_a99);
    ddp_schedule_rec.printer_address := p7_a100;
    ddp_schedule_rec.notify_on_activation_flag := p7_a101;

    -- here's the delegated call to the old PL/SQL routine
    ams_camp_schedule_pub.validate_camp_schedule(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_validation_mode,
      ddp_schedule_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure copy_camp_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id out nocopy  NUMBER
    , x_custom_setup_id out nocopy  NUMBER
  )

  as
    ddp_attributes_table ams_cpyutility_pvt.copy_attributes_table_type;
    ddp_copy_columns_table ams_cpyutility_pvt.copy_columns_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_cpyutility_pvt_w.rosetta_table_copy_in_p0(ddp_attributes_table, p_attributes_table);

    ams_cpyutility_pvt_w.rosetta_table_copy_in_p2(ddp_copy_columns_table, p9_a0
      , p9_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    ams_camp_schedule_pub.copy_camp_schedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_object_id,
      ddp_attributes_table,
      ddp_copy_columns_table,
      x_new_object_id,
      x_custom_setup_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end ams_camp_schedule_pub_w;

/
